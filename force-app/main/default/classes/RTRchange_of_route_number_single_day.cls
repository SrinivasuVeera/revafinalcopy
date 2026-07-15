global class RTRchange_of_route_number_single_day implements Database.Batchable<sobject>, Database.AllowsCallouts {
  // RecordIds property to store the input parameter
    public String RecordIds { get; set; }

    // Constructor to initialize RecordIds
    global RTRchange_of_route_number_single_day(String contactIds) {
        this.RecordIds = contactIds;
    }

    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, RTR_Number_of_Minutes__c, RTR_Date__c, RTR_Descriptions__c,RTR_Routes__r.Name,RTR_New_Number__r.Name
            FROM RTR_Reva_Transport_Request__c 
            WHERE Id = :RecordIds 
        ]);
    }

    // Execute method to process the records
    global void execute(Database.BatchableContext bc, List<RTR_Reva_Transport_Request__c> requestList) {
        try {
            // Lists to store data for notifications
            List<String> dateValues = new List<String>();
            //List<String> StartDate = new List<String>();
            //List<String> EndDate = new List<String>();
            //List<String> numberOfMinutes = new List<String>();
            List<String> descriptions = new List<String>();
            List<String> ExistingRouteMaster = new List<String>();
            List<String> NewRouteMaster = new List<String>();

            // Iterate through the records and gather data
            for (RTR_Reva_Transport_Request__c request : requestList) {
                //numberOfMinutes.add(String.valueOf(request.RTR_Number_of_Minutes__c));
                descriptions.add(request.RTR_Descriptions__c);
                dateValues.add(String.valueOf(request.RTR_Date__c));
                //StartDate.add(String.valueOf(request.RTR_Start_Date__c));
               // EndDate.add(String.valueOf(request.RTR_End_Date__c));
                ExistingRouteMaster.add(request.RTR_Routes__r.Name);
                NewRouteMaster.add(request.RTR_New_Number__r.Name);
            }

            // Query to fetch related contacts
            //List<Contact> contactList = [SELECT Id, Name, MobilePhone FROM Contact WHERE Id IN (SELECT Contact__c FROM Transport_Registeration__c WHERE Registration_Status__c = 'Active' AND Reva_Transport__r.Active__c = true) and MobilePhone != null];

            //New Changes------------------------------------>>>>>>>>>>>>
            List<Transport_Registeration__c> Transreg =[SELECT Id,Name,Route_Master__r.Name,Contact__r.Id from Transport_Registeration__c WHERE Registration_Status__c = 'Active' AND Reva_Transport__r.Active__c = true AND Route_Master__r.Name IN:ExistingRouteMaster];
            List<String> contactIds = new List<String>();
            system.debug('Transreg'+Transreg);
            
            for(Transport_Registeration__c trList : Transreg){
                contactIds.add(trList.Contact__r.Id);
               
            }
            // Query to fetch related contacts
            List<Contact> contactList = [SELECT Id, Name, MobilePhone FROM Contact WHERE Id IN: contactIds];

            system.debug('contactList'+contactList);
            //New Changes------------------------------------>>>>>>>>>>>>
            // Fetching template details
            String templateId = 'route_number_change_single_day_student_staff1';
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];

            
            // Iterate through contacts to create notifications
            for (Contact con : contactList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();

                // Set dynamic values for each key based on related record
                notification.params.put('studentname', con.Name);
                //notification.params.put('numberofminutes', String.join(numberOfMinutes, ','));
                notification.params.put('date', String.join(dateValues, ','));
               // notification.params.put('startdate', String.join(StartDate, ','));
                //notification.params.put('enddate', String.join(EndDate, ','));
               // notification.params.put('reason', String.join(descriptions, ','));
                notification.params.put('regularroutenumber', String.join(ExistingRouteMaster, ','));
                notification.params.put('updatedroutenumber', String.join(NewRouteMaster, ','));
				
                // Map to store notifications for each contact's phone number
            	Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

                // Add notification to map
                phoneNumbersToNotifications.put(con.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);
            }
          
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }

    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}