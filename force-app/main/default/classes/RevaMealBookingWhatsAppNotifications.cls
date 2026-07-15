public class RevaMealBookingWhatsAppNotifications {
    @InvocableMethod(label='Send Meal Booking WhatsApp Notification' description='Send WhatsApp notification for meal bookings')
    public static void sendMealBookingWhatsAppNotification(List<Id> mealBookingIds) {
        List<id> MealBook = new list<id>();
        List<id> MealMissed = new list<id>();
        List<Reva_Meal_Booking__c> mealBookings = [SELECT Id, Reva_Meal_Booking_Status__c, Type_of_meal__c, Reva_Meal_Booking_Date__c, Booking_For__r.MobilePhone, Booking_For__r.Name, Booking_For_User__r.Name FROM Reva_Meal_Booking__c WHERE Id IN :mealBookingIds];
        for (Reva_Meal_Booking__c m : mealBookings) {               
            if (m.Reva_Meal_Booking_Status__c.equalsIgnoreCase('Booked')) {           
                MealBook.add(m.id);    
            }  
            else if (m.Reva_Meal_Booking_Status__c.equalsIgnoreCase('Missed Meal')) {
                MealMissed.add(m.id);
            }    
        }
        if(!MealBook.isempty()){
            BookingWhatsappNotificationCallout(MealBook);
        }if(!MealMissed.isempty()){
            MissedWhatsappNotificationCallout(MealMissed);
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
            notification1.templateId = 'mealnotification_student';
            
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
                    if (key.trim() == 'studentname') {
                        notification1.params.put(key.trim(), requiredField.Booking_For__r.Name);
                    } else if (key.trim() == 'foodtype') {
                        // Assuming Start_Date__c is a Date field
                        notification1.params.put(key.trim(), requiredField.Reva_Mess_Menu__r.Type__c);
                    } else if (key.trim() == 'bookingdate') {
                        String formattedDateTime =string.valueof(requiredField.Reva_Meal_Booking_Date__c);
                        // String formattedDateTime = String.valueOf(requiredField.Reva_Meal_Booking_Date__c.format('dd-MM-yyyy'));
                        
                        // Assuming End_Date__c is a DateTime field
                        notification1.params.put(key.trim(), formattedDateTime);
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
    /************************************working one*******************************************/
    @Future(callout=true)
    public static void MissedWhatsappNotificationCallout(List<Id> recordIds) {
        // Query the relevant meal bookings once for all record IDs
        List<Reva_Meal_Booking__c> mealBookings = [
            SELECT Booking_For__r.Name, Booking_For__r.MobilePhone, Booking_For__c, 
            Reva_Meal_Booking_Status__c, Reva_Mess_Menu__r.Type__c, 
            Reva_Meal_Booking_Date__c
            FROM Reva_Meal_Booking__c
            WHERE Id IN :recordIds
        ];
        
        // Query to pre-aggregate missed meal counts
        Map<Id, Integer> missedMealCounts = new Map<Id, Integer>();
        Date startOfMonth = Date.today().toStartOfMonth();
        system.debug('startOfMonth'+startOfMonth);
        Integer daysInMonth = Date.daysInMonth(startOfMonth.year(), startOfMonth.month());
        Date endOfMonth = Date.newInstance(startOfMonth.year(), startOfMonth.month(), daysInMonth);
        AggregateResult[] missedMealResults = [
            SELECT Booking_For__c Id, COUNT(Id) missedCount
            FROM Reva_Meal_Booking__c
            WHERE (Reva_Meal_Booking_Status__c = 'Missed Meal' 
                   OR (Reva_Meal_Booking_Status__c = 'Availed' AND Is_Instant_Meal_Availed__c = TRUE)) 
            AND  Meal_Date__c >= :startOfMonth 
            AND Meal_Date__c <= :endOfMonth
            GROUP BY Booking_For__c
        ];
        for (AggregateResult ar : missedMealResults) {
            missedMealCounts.put((Id) ar.get('Id'), (Integer) ar.get('missedCount'));
        }
        
        // Fetch template metadata only once
        Map<String, String> templateFields = new Map<String, String>();
        for (WhatsApp_Notification_Template__mdt template : [
            SELECT Template_Field__c, Template_ID__c 
            FROM WhatsApp_Notification_Template__mdt 
            WHERE Template_ID__c = 'mealmissednotification_student'
        ]) {
            templateFields.put(template.Template_ID__c, template.Template_Field__c);
        }
        
        // Group notifications by phone number
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for (Reva_Meal_Booking__c booking : mealBookings) {
            if (!String.isBlank(booking.Booking_For__r.MobilePhone)) {
                String missedMeals = String.valueOf(missedMealCounts.get(booking.Booking_For__c));
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = 'mealmissednotification_student';
                notification.params = new Map<String, String>{
                    'studentname' => booking.Booking_For__r.Name,
                        'mealtype' => booking.Reva_Mess_Menu__r.Type__c,
                        'bookeddate' => String.valueOf(booking.Reva_Meal_Booking_Date__c),
                        //'bookeddate' => String.valueOf(requiredField.Reva_Meal_Booking_Date__c.format('dd-MM-yyyy')),
                        'missedmealsnumber' => missedMeals
                        };
                            
                            String mobilePhone = booking.Booking_For__r.MobilePhone.replace('+', '').replace('-', '');
                if (!phoneNotifications.containsKey(mobilePhone)) {
                    phoneNotifications.put(mobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
                }
                phoneNotifications.get(mobilePhone).add(notification);
            }
        }
        
        // Send all notifications in bulk per phone number
        if (!phoneNotifications.isEmpty()) {
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNotifications);
            System.debug('Bulk WhatsApp Notification Response: ' + response);
        }
    }
    /**************/
    /* @Future(callout=true)
public static void MissedWhatsappNotificationCallout(List<Id> recordIds) {
// Query the relevant meal bookings once for all record IDs
List<Reva_Meal_Booking__c> mealBookings = [
SELECT Booking_For__r.Id, Booking_For__r.Name, Booking_For__r.MobilePhone, 
Booking_For__c, Reva_Meal_Booking_Status__c, Reva_Mess_Menu__r.Type__c, 
Reva_Meal_Booking_Date__c
FROM Reva_Meal_Booking__c
WHERE Id IN :recordIds
];

// Collect all student IDs from meal bookings
Set<Id> studentIds = new Set<Id>();
for (Reva_Meal_Booking__c booking : mealBookings) {
if (booking.Booking_For__c != null) {
studentIds.add(booking.Booking_For__c);
}
}

// Fetch missed meal counts from Contact (Replacing Aggregate SOQL)
Map<Id, Decimal> missedMealCounts = new Map<Id, Decimal>();
if (!studentIds.isEmpty()) {
List<Contact> contactsWithMissedMeals = [
SELECT Id, Total_missed_meals_this_month__c 
FROM Contact 
WHERE Id IN :studentIds
];

for (Contact con : contactsWithMissedMeals) {
missedMealCounts.put(con.Id, con.Total_missed_meals_this_month__c != null ? con.Total_missed_meals_this_month__c : 0);
}
}

// Fetch template metadata only once
Map<String, String> templateFields = new Map<String, String>();
for (WhatsApp_Notification_Template__mdt template : [
SELECT Template_Field__c, Template_ID__c 
FROM WhatsApp_Notification_Template__mdt 
WHERE Template_ID__c = 'mealmissednotification_student'
]) {
templateFields.put(template.Template_ID__c, template.Template_Field__c);
}

// Group notifications by phone number
Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

for (Reva_Meal_Booking__c booking : mealBookings) {
if (booking.Booking_For__r != null && !String.isBlank(booking.Booking_For__r.MobilePhone)) {
// Get missed meal count from Contact field (converted to String for WhatsApp message)
Integer noOfMissedMeals = missedMealCounts.containsKey(booking.Booking_For__c) 
? missedMealCounts.get(booking.Booking_For__c).intValue()  // Convert Decimal to Integer
: 0;

Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
notification.templateId = 'mealmissednotification_student';
notification.params = new Map<String, String>{
'studentname' => booking.Booking_For__r.Name,
'mealtype' => booking.Reva_Mess_Menu__r != null ? booking.Reva_Mess_Menu__r.Type__c : 'N/A',
'bookeddate' => booking.Reva_Meal_Booking_Date__c != null ? String.valueOf(booking.Reva_Meal_Booking_Date__c) : 'N/A',
'missedmealsnumber' => String.valueOf(noOfMissedMeals)
};

String mobilePhone = booking.Booking_For__r.MobilePhone.replace('+', '').replace('-', '');
if (!phoneNotifications.containsKey(mobilePhone)) {
phoneNotifications.put(mobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
}
phoneNotifications.get(mobilePhone).add(notification);
}
}

// Send all notifications in bulk per phone number
if (!phoneNotifications.isEmpty()) {
HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNotifications);
System.debug('Bulk WhatsApp Notification Response: ' + response);
}
}*/
    
    /***********************changes ended here*********************************/
    
    
}