public class RevaMealBookingMissedMealQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> missedSuccessIds = new List<Id>();
    private List<Reva_Meal_Booking__c> missedSuccessList = new List<Reva_Meal_Booking__c>();

    public void execute(QueueableContext context) {
        List<Reva_Meal_Booking__c> todayBookedMeals = [
            SELECT Id, Booking_For__c, Reva_Meal_Booking_Status__c, Meal_Date__c, Reva_Meal_Booking_Date__c,
                   Booking_For__r.Name, Booking_For_User__c, Booking_For_User__r.Name, Reva_Mess_Menu__r.Start_Time__c,
                   Reva_Mess_Menu__r.End_Time__c, Booking_For__r.MobilePhone, Reva_Mess_Menu__r.Type__c, Type_of_meal__c,
                   Display_Time__c,Booking_For__r.Email,Booking_For__r.LastName ,Booking_For__r.FirstName
            FROM Reva_Meal_Booking__c
            WHERE Meal_Date__c = :Date.today() 
              AND (Reva_Meal_Booking_Status__c = 'Booked' OR Reva_Meal_Booking_Status__c = 'Instant Meal')
              AND Meal_End_Time__c < :Datetime.now().time()
        ];

        List<Reva_Meal_Booking__c> bookingsToUpdate = new List<Reva_Meal_Booking__c>();

        for (Reva_Meal_Booking__c booking : todayBookedMeals) {
            try {
                DateTime now = DateTime.now();
                DateTime startTime = DateTime.newInstance(booking.Meal_Date__c, booking.Reva_Mess_Menu__r.Start_Time__c);
                DateTime endTime = DateTime.newInstance(booking.Meal_Date__c, booking.Reva_Mess_Menu__r.End_Time__c);

                if (now > endTime && (booking.Reva_Meal_Booking_Status__c == 'Booked' || booking.Reva_Meal_Booking_Status__c == 'Instant Meal')) {
                    booking.Reva_Meal_Booking_Status__c = 'Missed Meal';
                    bookingsToUpdate.add(booking);
                }
            } catch (Exception ex) {
                System.debug('Error processing booking ID: ' + booking.Id + ' - ' + ex.getMessage());
            }
        }

        if (!bookingsToUpdate.isEmpty()) {
            processUpdates(bookingsToUpdate);
        }

        sendNotifications();
    }

    private void processUpdates(List<Reva_Meal_Booking__c> bookingsToUpdate) {
        try {
            List<Database.SaveResult> updateResults = Database.update(bookingsToUpdate, false);

            for (Integer i = 0; i < updateResults.size(); i++) {
                if (updateResults[i].isSuccess()) {
                    missedSuccessIds.add(bookingsToUpdate[i].Id);
                    missedSuccessList.add(bookingsToUpdate[i]);
                } else {
                    for (Database.Error err : updateResults[i].getErrors()) {
                        System.debug('Failed to update record ID: ' + bookingsToUpdate[i].Id + ' - Error: ' + err.getMessage());
                    }
                }
            }
        } catch (DmlException ex) {
            System.debug('DML Exception during update: ' + ex.getMessage());
        }
    }

    private void sendNotifications() {
        try {
            if (!missedSuccessList.isEmpty()) {
                //RevaMealBookingSMSNotifications.sendMissedMealNotifications(missedSuccessList);
                 sendEmailNotifications(missedSuccessList);
            }
            if (!missedSuccessIds.isEmpty()) {
               // RevaMealBookingWhatsAppNotifications.MissedWhatsappNotificationCallout(missedSuccessIds);
            }
           
        } catch (Exception ex) {
            System.debug('Error sending notifications: ' + ex.getMessage());
        }
    }

    private void sendEmailNotifications(List<Reva_Meal_Booking__c> bookings) {
        List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];
        System.debug('orgWideEmailAddresses: ' + orgWideEmailAddresses);
        OrgWideEmailAddress orgWideEmail = new OrgWideEmailAddress();
        if (!orgWideEmailAddresses.isEmpty()) {
            orgWideEmail = orgWideEmailAddresses[0];
        }

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        for (Reva_Meal_Booking__c booking : bookings) {
            if (booking.Booking_For__c != null) {
                System.debug('booking.Booking_For__c:--- ' + booking.Booking_For__c);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(orgWideEmail.Id);
                email.setToAddresses(new List<String>{booking.Booking_For__r.Email});
                email.setSubject('Missed Meal Notification');
                email.setHtmlBody('Dear ' + booking.Booking_For__r.FirstName + ' ' + booking.Booking_For__r.LastName + ',<br/><br/>' +
                    'This is to inform you that you have missed receiving the meal that you booked. Please be informed that your meal booking option will be disabled if you miss receiving 10 meals.<br/><br/>' +
                    '<b>Details:</b><br/>' +
                    'Meal type: ' + booking.Type_of_meal__c + '<br/>' +
                    'Booked date: ' + booking.Reva_Meal_Booking_Date__c + '<br/><br/>' +
                    'Regards,<br/>Hostel office<br/>REVA University');
                System.debug('email---: ' + email);
                emailMessages.add(email);
            }
        }
   System.debug('emailMessages:--- ' + emailMessages);
        if (!emailMessages.isEmpty()) {
            try {
                Messaging.sendEmail(emailMessages);
            } catch (Exception ex) {
                System.debug('Error sending email: ' + ex.getMessage());
            }
        }
    }
}