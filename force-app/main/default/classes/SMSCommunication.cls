global class SMSCommunication implements Database.Batchable<sObject>, Database.AllowsCallouts {

    // Declare RecordTypeId at class level
    global Id ContactRecTypeId;

    // Constructor to initialize RecordTypeId
    global SMSCommunication() {
        // Set the RecordTypeId for the "Student" record type
        this.ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    }

    // Batch start method to return the query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Fetch contacts based on criteria
        return Database.getQueryLocator([
            SELECT Id, Name, Active__c, Quota__c, Last_Notification_Date__c, 
                   ReportsToId, MobilePhone
            FROM Contact
            WHERE Student_Status__c = 'Pursuing'
            AND RecordTypeId = :ContactRecTypeId
            AND Program_Type__c != 'Ph.D'
            AND School_Name__c != 'REVA Academy for Corporate Excellence'
            AND Program_Batch__r.hed__Start_Date__c != null
        ]);
    }

    // Batch execute method to process each batch of contacts
    global void execute(Database.BatchableContext bc, List<Contact> lstCon) {
        // List to hold the SMS details
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        
        for(Contact con : lstCon) {
            // Create SMS message wrapper for each contact
            SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
            objShortMsg.message = 'REVA University is NOT associated with any unauthorized fresher\'s events promoted by outsiders. These are false claims and may risk your safety. Disregard such invites.';
            
            // Add to message list only if MobilePhone is not blank
            if(String.isNotBlank(con.MobilePhone)) {
                objShortMsg.recipient = '+91' + con.MobilePhone;
                lstShortMsg.add(objShortMsg);
            }
        }
        
        System.debug('Total messages to be sent: ' + lstShortMsg.size());
        
        if(lstShortMsg.size() > 0) {
            try {
                // Map HTTP Request and send SMS
                HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Misleading Information', lstShortMsg);
                //Http http = new Http();
                //HttpResponse hRsp = http.send(hReq);

                
            } catch(Exception ex) {
                // Catch and log any exceptions
                System.debug('Error occurred while sending SMS: ' + ex.getMessage());
            }
        }
    }

    // Time conversion utility method (24-hour to 12-hour format)
    global static String getTimeDetails(String timeDetails) {
        if (String.isBlank(timeDetails)) {
            return ''; // Handle null or empty input
        }
        String[] outTimeSplit = timeDetails.split(':');
        Integer hour = Integer.valueOf(outTimeSplit[0]);
        String minute = outTimeSplit[1];

        if (hour >= 12) {
            hour = hour == 12 ? 12 : hour - 12;
            return String.valueOf(hour) + ':' + minute + ' PM';
        } else {
            return (hour < 10 ? '0' : '') + String.valueOf(hour) + ':' + minute + ' AM';
        }
    }

    // Batch finish method to log completion
    global void finish(Database.BatchableContext bc) {
        
    }
}