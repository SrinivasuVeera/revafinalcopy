public class Yellow_AI_Utility {
    //public static HttpRequest generateNotificationJSON(String studentName, String dateOfAppointment, String startTime, String endTime) {
    //Get API Details
    //Yellow_AI_API_Setup__mdt yellowAPISetup = [SELECT Bot_ID__c, Sender_Phone_Number__c, URL__c, x_api_key__c FROM Yellow_AI_API_Setup__mdt][0];
    //Get Auth Details
    // SMS_API_Setup__mdt auth = [SELECT Username__c, Password__c, URL__c FROM SMS_API_Setup__mdt][0];

    public static HttpResponse sendWhatsAppNotifications(Map<String, List<WhatsAppNotification>> phoneNumbersToNotifications) {
        System.debug('phoneNumbersToNotifications=' + phoneNumbersToNotifications);
        // Generate the WhatsApp JSON payload
        String jsonData = generateWhatsAppJSON(phoneNumbersToNotifications);
        System.debug('#12=' + jsonData);
        Yellow_AI_API_Setup__mdt yellowAPISetup = [SELECT Bot_ID__c, Sender_Phone_Number__c, URL__c, x_api_key__c FROM Yellow_AI_API_Setup__mdt][0];
        // Create and configure an HttpRequest object
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('x-api-key', yellowAPISetup.x_api_key__c);
        httpReq.setEndpoint(yellowAPISetup.URL__c + yellowAPISetup.Bot_ID__c);
        httpReq.setMethod('POST');
        httpReq.setBody(jsonData);
        // Send the HTTP request
        httpRes = new Http().send(httpReq);
        // Log the response
        System.debug('Response Body: ' + httpRes.getBody());
        System.debug('Response Status: ' + httpRes.getStatusCode());
        return httpRes;
    }
    public static String generateWhatsAppJSON(Map<String, List<WhatsAppNotification>> phoneNumbersToNotifications) {
        system.debug('phoneNumbersToNotifications->>'+phoneNumbersToNotifications);
        Yellow_AI_API_Setup__mdt yellowAPISetup = [SELECT Bot_ID__c, Sender_Phone_Number__c, URL__c, x_api_key__c FROM Yellow_AI_API_Setup__mdt][0];
        // Create a JSON generator
        JSONGenerator gen = JSON.createGenerator(true);
        // Start building the JSON structure
        gen.writeStartObject();
        // UserDetails section (for each sender)

        for (String phoneNumber : phoneNumbersToNotifications.keySet()) {
			gen.writeFieldName('userDetails');
        	gen.writeStartObject();
            gen.writeStringField('number', phoneNumber);
            gen.writeEndObject();
            system.debug('phoneNumber->>'+phoneNumber);
            // Notification section
            gen.writeFieldName('notification');
            gen.writeStartObject();
            gen.writeStringField('type', 'whatsapp');
            gen.writeStringField('sender', yellowAPISetup.Sender_Phone_Number__c); // Replace with your sender ID
            gen.writeStringField('language', 'en');

            for (WhatsAppNotification notification : phoneNumbersToNotifications.get(phoneNumber)) {
                gen.writeStringField('templateId', notification.templateId); // Use the templateId as a key
                // Params section (for each notification)
                gen.writeFieldName('params');
                gen.writeStartObject();
                system.debug('notification'+notification);
                for (String key : notification.params.keySet()) {
                    System.debug('Key--> '+key);
                    if(notification.params.get(key) != null){
                         gen.writeStringField(key, notification.params.get(key));
                    }
                   
                } 
                gen.writeEndObject();
            } 
            gen.writeEndObject(); // End of Notification section

        }
        gen.writeEndObject(); // End of JSON structure
        System.debug('gen.getAsString()===>' + gen.getAsString());
        return gen.getAsString();
    }
    public class WhatsAppNotification {
        public String templateId;
        public Map<String, String> params = new Map<String, String>();
        // public String number; // Phone number for the notification
    }
}