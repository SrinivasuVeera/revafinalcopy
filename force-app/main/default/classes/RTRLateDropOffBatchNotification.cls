global class RTRLateDropOffBatchNotification implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public String RecordIds { get; set; }
    private List<Contact> allContacts; // Holds all contacts
    private Integer currentIndex;      // Tracks the current index for processing
 
    global RTRLateDropOffBatchNotification(String contactIds) {
        this.RecordIds = contactIds;
        this.currentIndex = 0; // Initialize current index
        this.allContacts = new List<Contact>();
    }
 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Populate allContacts only once during the first execution
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
            SELECT Id, RTR_Number_of_Minutes__c, RTR_Date__c, RTR_Descriptions__c 
            FROM RTR_Reva_Transport_Request__c 
            WHERE Id = :RecordIds
        ]);
    }
 
    global void execute(Database.BatchableContext bc, List<RTR_Reva_Transport_Request__c> requestList) {
        Integer maxCallouts = 100; 
        Integer processedCount = 0; // Track callouts in this execution
 
        try {
            // Template details
            String templateId = 'late_drop_off_student_u';
 
            // Process contacts from the current index
            while (currentIndex < allContacts.size() && processedCount < maxCallouts) {
                Contact con = allContacts[currentIndex];
                currentIndex++; // Move to the next contact
 
                for (RTR_Reva_Transport_Request__c request : requestList) {
                    // Create the notification
                    Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                    notification.templateId = templateId;
                    notification.params = new Map<String, String>();
                    notification.params.put('name', con.Name);
                    notification.params.put('numberofminutes', String.valueOf(request.RTR_Number_of_Minutes__c));
                    notification.params.put('Date', String.valueOf(request.RTR_Date__c));
                    notification.params.put('Reason', request.RTR_Descriptions__c);
 
                    // Send notification
                    Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                    phoneNumbersToNotifications.put(con.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                    HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
 
                    processedCount++; 
                }
            }
 
            // If there are more contacts to process, chain with Queueable
            if (currentIndex < allContacts.size()) {
                
                System.enqueueJob(new RTRLateDropOffBatchContinuation(this));
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' at line ' + e.getLineNumber());
        }
    }
 
    global void finish(Database.BatchableContext bc) {
        System.debug('Processing completed. Current Index: ' + currentIndex);
    }
}