public class MealCancellationNotificationWhatsapp {
 @InvocableMethod(label='Send Meal Cancel WhatsApp Notification' description='Send WhatsApp notification for meal cancelled')
    public static void sendMealCancelWhatsAppNotification(List<Id> mealCancelIds) {
        List<id> MealBook = new list<id>();
        List<Reva_Meal_Booking__c> mealBookings = [SELECT Id, Reva_Meal_Booking_Status__c, Type_of_meal__c, Reva_Meal_Booking_Date__c, Booking_For__r.MobilePhone, Booking_For__r.Name, Booking_For_User__r.Name FROM Reva_Meal_Booking__c WHERE Id IN :mealCancelIds];
         for (Reva_Meal_Booking__c m : mealBookings) {               
               if (m.Reva_Meal_Booking_Status__c.equalsIgnoreCase('Cancelled')) {           
                   MealBook.add(m.id);    
            }      
        }
        if(!MealBook.isempty()){
            BookingWhatsappNotificationCallout(MealBook);
        }
    }
     @Future(callout=true)
    public static void BookingWhatsappNotificationCallout(List<Id> recordIds) {
        // Fetch the related record data
        List<Reva_Meal_Booking__c> requiredFields = [
            SELECT Booking_For__r.Name, Booking_For__r.MobilePhone, CreatedDate, Reva_Meal_Booking_Status__c,Reva_Mess_Menu__r.Type__c,Reva_Meal_Booking_Date__c
            FROM Reva_Meal_Booking__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        // Check if related record is found
        if (!requiredFields.isEmpty() && !String.isBlank(requiredFields[0].Booking_For__r.MobilePhone)) {
            Reva_Meal_Booking__c requiredField = requiredFields[0];

            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'meal_cancellation_confirmation_student';

            // Fetch keys from custom metadata based on templateId
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
        System.debug('templateMetadata: ' + templateMetadata);
            // Populate the params map dynamically
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                // Split values based on comma and add each as a separate key
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    // You can set dynamic values for each key based on the related record
                    if (key.trim() == 'student_name') {
                        notification1.params.put(key.trim(), requiredField.Booking_For__r.Name);
                    } 
                }
            }
			
            // Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            System.debug('notification1: ' + notification1);
            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            phoneNumbersToNotifications.put(requiredField.Booking_For__r.MobilePhone, notifications);
             if(requiredField.Booking_For__r.MobilePhone!=null){
                    String plusRemoved = requiredField.Booking_For__r.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                 phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                   }    
            
            // Send notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp notification response: ' + response);
        } else {
            System.debug('No related record found for the provided ID');
        }
    }
     @Future(callout=true)
    public static void MissedWhatsappNotificationCallout(List<Id> recordIds) {
        // Fetch the related record data
        List<Reva_Meal_Booking__c> requiredFields = [
            SELECT Booking_For__r.Name, Booking_For__r.MobilePhone, CreatedDate, Reva_Meal_Booking_Status__c,Reva_Mess_Menu__r.Type__c,Reva_Meal_Booking_Date__c
            FROM Reva_Meal_Booking__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
         Id studentRecordId;
        for(Reva_Meal_Booking__c m:requiredFields){
       studentRecordId =m.Booking_For__r.id;
            }
        List<Reva_Meal_Booking__c> missedMealBookings = [SELECT id, Reva_Meal_Booking_Status__c, Booking_For__c FROM Reva_Meal_Booking__c WHERE Reva_Meal_Booking_Status__c = 'Missed Meal' AND Booking_For__c =: studentRecordId];
        String noOfMissedMeals = String.valueof(missedMealBookings.size());
        // Check if related record is found
        if (!requiredFields.isEmpty() && !String.isBlank(requiredFields[0].Booking_For__r.MobilePhone)) {
            Reva_Meal_Booking__c requiredField = requiredFields[0];

            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'meal_cancellation_confirmation_student';

            // Fetch keys from custom metadata based on templateId
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
        System.debug('templateMetadata: ' + templateMetadata);
            // Populate the params map dynamically
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                // Split values based on comma and add each as a separate key
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    // You can set dynamic values for each key based on the related record
                    if (key.trim() == 'student_name') {
                        notification1.params.put(key.trim(), requiredField.Booking_For__r.Name);
                    }
                }
            }
			
            // Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            System.debug('notification1: ' + notification1);
            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            // phoneNumbersToNotifications.put(requiredField.Booking_For__r.MobilePhone, notifications);
            if(requiredField.Booking_For__r.MobilePhone !=null){
                String plusRemoved = requiredField.Booking_For__r.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
            } 
            // Send notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp notification response: ' + response);
        } else {
            System.debug('No related record found for the provided ID');
        }
    }
    
}