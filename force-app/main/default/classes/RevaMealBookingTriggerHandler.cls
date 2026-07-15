public class RevaMealBookingTriggerHandler {

    public static void preventDuplicateBookings(List<Reva_Meal_Booking__c> newRecords, Boolean isInsert) {
        Set<Id> menuIds = new Set<Id>();
        Set<Date> bookingDates = new Set<Date>();
        Set<Id> contactIds = new Set<Id>();
        Map<String, Id> incomingKeyToIdMap = new Map<String, Id>();

        for (Reva_Meal_Booking__c rec : newRecords) {
            if (rec.Reva_Mess_Menu__c != null &&
                rec.Meal_Date__c != null &&
                rec.Reva_Meal_Booking_Status__c != null &&
                rec.Booking_For__c != null) {

                String key = rec.Reva_Mess_Menu__c + '-' +
                             rec.Meal_Date__c + '-' +
                             rec.Reva_Meal_Booking_Status__c + '-' +
                             rec.Booking_For__c;

                incomingKeyToIdMap.put(key, rec.Id);
                menuIds.add(rec.Reva_Mess_Menu__c);
                bookingDates.add(rec.Meal_Date__c);
                contactIds.add(rec.Booking_For__c);
            }
        }

        if (incomingKeyToIdMap.isEmpty()) return;

        Map<String, Id> existingKeyToIdMap = new Map<String, Id>();
        for (Reva_Meal_Booking__c existing : [
            SELECT Id, Reva_Mess_Menu__c, Meal_Date__c,
                   Reva_Meal_Booking_Status__c, Booking_For__c
            FROM Reva_Meal_Booking__c
            WHERE Reva_Mess_Menu__c IN :menuIds
              AND Meal_Date__c IN :bookingDates
              AND Booking_For__c IN :contactIds
        ]) {
            if (existing.Reva_Mess_Menu__c != null &&
                existing.Meal_Date__c != null &&
                existing.Reva_Meal_Booking_Status__c != null &&
                existing.Booking_For__c != null) {

                String key = existing.Reva_Mess_Menu__c + '-' +
                             existing.Meal_Date__c + '-' +
                             existing.Reva_Meal_Booking_Status__c + '-' +
                             existing.Booking_For__c;

                existingKeyToIdMap.put(key, existing.Id);
            }
        }

        for (Reva_Meal_Booking__c rec : newRecords) {
            if (rec.Reva_Mess_Menu__c == null ||
                rec.Meal_Date__c == null ||
                rec.Reva_Meal_Booking_Status__c == null ||
                rec.Booking_For__c == null) {
                continue;
            }

            String key = rec.Reva_Mess_Menu__c + '-' +
                         rec.Meal_Date__c + '-' +
                         rec.Reva_Meal_Booking_Status__c + '-' +
                         rec.Booking_For__c;

            if (existingKeyToIdMap.containsKey(key)) {
                Id existingId = existingKeyToIdMap.get(key);
                // Prevent insert or cross-record update
                if (isInsert || (!isInsert && existingId != rec.Id)) {
                    rec.addError('Duplicate meal booking found with the same Menu, Date, Type, and Contact.');
                }
            }
        }
    }
}