public class SMSQueueable implements Queueable, Database.AllowsCallouts {
    private String SMSType;
    private String messageListJson;

    // Constructor to initialize parameters
    public SMSQueueable(String SMSType, String messageListJson) {
        this.SMSType = SMSType;
        this.messageListJson = messageListJson;
    }

    // Execute method for the Queueable class
    public void execute(QueueableContext context) {
        System.debug('Deserializing messageListJson: ' + messageListJson);
        try {
            // Deserialize the JSON string back into the List of shortMessageWrp
            List<SMS_API_Utility.shortMessageWrp> messageList = 
                (List<SMS_API_Utility.shortMessageWrp>) JSON.deserialize(messageListJson, List<SMS_API_Utility.shortMessageWrp>.class);
            
            SMS_API_Utility.SendSMSOneToMany(SMSType, messageList);
        } catch (Exception e) {
            System.debug('Deserialization error: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }
    }
}


/*public class SMSQueueable implements Queueable, Database.AllowsCallouts {
    private String SMSType;
    private String messageListJson;

    // Constructor to initialize parameters
    public SMSQueueable(String SMSType, String messageListJson) {
        this.SMSType = SMSType;
        this.messageListJson = messageListJson;
    }

    // Execute method for the Queueable class
    public void execute(QueueableContext context) {
        // Deserialize the JSON string back into the List of shortMessageWrp
        List<SMS_API_Utility.shortMessageWrp> messageList = 
            (List<SMS_API_Utility.shortMessageWrp>) JSON.deserialize(messageListJson, List<SMS_API_Utility.shortMessageWrp>.class);
        
        SMS_API_Utility.SendSMSOneToMany(SMSType, messageList);
    }
}
*/