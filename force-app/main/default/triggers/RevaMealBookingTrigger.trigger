trigger RevaMealBookingTrigger on Reva_Meal_Booking__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            RevaMealBookingTriggerHandler.preventDuplicateBookings(Trigger.new, Trigger.isInsert);
        }
    }
}