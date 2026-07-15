global class RTREarlyDropOffMultipleBatchNotification implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public String RecordIds { get; set; }
    private List<Contact> allContacts;
    private Integer currentIndex;

    global RTREarlyDropOffMultipleBatchNotification(String contactIds) {
        this.RecordIds = contactIds;
        this.currentIndex = 0;
        this.allContacts = new List<Contact>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        if (allContacts.isEmpty()) {
            allContacts = [
                SELECT Id, Name, MobilePhone 
                FROM Contact 
                WHERE Id IN (
                    SELECT Contact__c 
                    FROM Transport_Registeration__c 
                    WHERE Registration_Status__c = 'Active' 
                    AND Reva_Transport__r.Active__c = true
                ) 
                AND MobilePhone != null
            ];
        }

        return Database.getQueryLocator([
            SELECT Id, RTR_Number_of_Minutes__c, RTR_End_Date__c, RTR_Start_Date__c, RTR_Descriptions__c 
            FROM RTR_Reva_Transport_Request__c 
            WHERE Id = :RecordIds 
        ]);
    }

    global void execute(Database.BatchableContext bc, List<RTR_Reva_Transport_Request__c> requestList) {
        Integer maxCallouts = 100;
        Integer processedCount = 0;

        try {
            String templateId = 'early_drop_off_multiple_days_student_staff_u1';

            while (currentIndex < allContacts.size() && processedCount < maxCallouts) {
                Contact con = allContacts[currentIndex];
                currentIndex++;

                List<String> startDateList = new List<String>();
                List<String> endDateList = new List<String>();
                List<String> numberOfMinutes = new List<String>();
                List<String> descriptions = new List<String>();

                for (RTR_Reva_Transport_Request__c request : requestList) {
                    numberOfMinutes.add(String.valueOf(request.RTR_Number_of_Minutes__c));
                    descriptions.add(request.RTR_Descriptions__c);
                    startDateList.add(String.valueOf(request.RTR_Start_Date__c));
                    endDateList.add(String.valueOf(request.RTR_End_Date__c));
                }

                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
                notification.params.put('name', con.Name);
                notification.params.put('numberofminutes', String.join(numberOfMinutes, ','));
                notification.params.put('startate', String.join(startDateList, ','));
                notification.params.put('enddate', String.join(endDateList, ','));
                notification.params.put('Reason', String.join(descriptions, ','));

                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                phoneNumbersToNotifications.put(con.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);

                processedCount++;
            }

            if (currentIndex < allContacts.size()) {
                System.enqueueJob(new RTREarlyDropOffMultipleBatchContinuation(this));
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' at line ' + e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Processing completed. Current Index: ' + currentIndex);
    }
}