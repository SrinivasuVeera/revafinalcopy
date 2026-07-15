public class MealCancellationNotificationSMS {
    @InvocableMethod(label='Send Meal Cancellation SMS Notifications' description='Send SMS notifications for meal cancellations')
    public static void sendCancellationSMS(List<Id> bookingIds) {
        if (bookingIds != null && !bookingIds.isEmpty()) { 
            makeCalloutAsync(bookingIds);
            System.debug('Booking IDs::' + bookingIds);
        } else {
            System.debug('Booking ID list is empty');
        }
    }

    @Future(Callout=true)
    public static void makeCalloutAsync(List<Id> bookingIds) {
        List<Reva_Meal_Booking__c> mealBookingList = [
            SELECT Id, Booking_For__c, Booking_For__r.MobilePhone, Booking_For__r.Name, Reva_Meal_Booking_Status__c 
            FROM Reva_Meal_Booking__c 
            WHERE Id IN :bookingIds AND Reva_Meal_Booking_Status__c = 'Cancelled'
        ];

        if (!mealBookingList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            
            for (Reva_Meal_Booking__c mealBooking : mealBookingList) {
                if (mealBooking.Booking_For__c != null && mealBooking.Booking_For__r.MobilePhone != null) {
                    String recipientName = mealBooking.Booking_For__r.Name;
                    String recipientPhone = mealBooking.Booking_For__r.MobilePhone;

                    String message = 'Dear ' + recipientName + ', We are pleased to inform you that, your booked meal has been successfully cancelled as per your request. REVA';

                    SMS_API_Utility.shortMessageWrp sms = new SMS_API_Utility.shortMessageWrp();
                    sms.dltContentId = '1007769492154979765'; // Template ID for meal cancellation
                    sms.message = message;
                    sms.recipient = recipientPhone;
                    messageList.add(sms);

                    System.debug('Message prepared for: ' + recipientName + ', Phone: ' + recipientPhone);
                }
            }

            if (!messageList.isEmpty()) {
                SMS_API_Utility.SendSMSOneToMany('meal_cancellation_confirmation_student', messageList);
                System.debug('Messages sent: ' + messageList.size());
            } else {
                System.debug('No valid phone numbers found for SMS notifications');
            }
        } else {
            System.debug('No bookings found with status "Cancelled" for the provided IDs');
        }
    }
}