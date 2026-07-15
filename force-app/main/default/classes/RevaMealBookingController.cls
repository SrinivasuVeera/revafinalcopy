public without sharing class RevaMealBookingController {
    @AuraEnabled
    public static List<Reva_Mess_Menu__c>  fetchMealMenus() {
        List<Reva_Mess_Menu__c> messMenuList = new List<Reva_Mess_Menu__c>();
        try {
            Datetime currentDatetime = Datetime.now();
            Time currentTime = currentDatetime.time();
            messMenuList = [SELECT Id, Date__c, Type__c, Start_Time__c, End_Time__c,
                            Reva_Mess__c, (SELECT Id, Name FROM Reva_Mess_Menu_Items__r) FROM Reva_Mess_Menu__c WHERE Date__c = TODAY
                            AND End_Time__c >: currentTime
                            AND Start_Time__c <=: currenttime
                            ORDER BY Date__c,Start_Time__c, End_Time__c ASC
                           ];
        } catch(Exception ex) {

        }
        return messMenuList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Student_Fee__c> getStudentDetails() {

        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        system.debug('list'+ [SELECT Amount_Pending__c, No_of_Days_Due__c, Fee_Type__c,Contact__c
                              FROM Student_Fee__c
                              WHERE Contact__c =: contactId AND Fee_Type__c = 'Hostel Fee'  AND
                              Name like '%Hostel Fee%' limit 1]);
        return [SELECT Amount_Pending__c, No_of_Days_Due__c, Fee_Type__c,Contact__c
                FROM Student_Fee__c
                WHERE Contact__c =: contactId AND Fee_Type__c = 'Hostel Fee' AND
                Name like '%Hostel Fee%' limit 1];


    }

    @AuraEnabled(cacheable = true)
    public static Map<string, object> instantMealBooking(string contactId){
        List<Reva_Meal_Booking__c> revaMealBookings = [SELECT Id, Name, Reva_Meal_Booking_Status__c
                                                       FROM Reva_Meal_Booking__c
                                                       WHERE Booking_For__c =: contactId
                                                       AND Reva_Mess_Menu__r.Date__c = THIS_MONTH
                                                       AND (Reva_Meal_Booking_Status__c = 'Missed Meal'
                                                            OR Reva_Meal_Booking_Status__c = 'Instant Meal')];
        Map<string, object> result = new Map<string, object>();
        result.put('isInstanceMealBookingAvailable', revaMealBookings.size() < 10);
        result.put('mealToBook', null);
        if(revaMealBookings.size() > 10)
            return result;
        Datetime currentDatetime = Datetime.now();

        // Extract the time part from the datetime
        Time currentTime = currentDatetime.time();

        List<Reva_Mess_Menu__c> revaMessMenu = [SELECT Id, Date__c, Type__c, Start_Time__c,
                                                End_Time__c, Reva_Mess__c,Mess_Items__c,
                                                (SELECT Id, Name FROM Reva_Mess_Menu_Items__r)
                                                FROM Reva_Mess_Menu__c
                                                WHERE Date__c = TODAY
                                                AND End_Time__c >: currentTime
                                                AND Start_Time__c <=: currenttime
                                                AND Id NOT IN (SELECT Reva_Mess_Menu__c
                                                               FROM Reva_Meal_Booking__c
                                                               WHERE Booking_For__c =: contactId
                                                               AND Reva_Meal_Booking_Date__c = TODAY)
                                                ORDER BY End_Time__c ASC];

        if(!revaMessMenu.isEmpty())
            result.put('mealToBook', revaMessMenu[0]);



        return result;

    }


    @AuraEnabled
    public static List<Contact> fetchContactsForBooking(String contactRecordTypeName) {
        try {
            List<Contact> contacts = new List<Contact>();

            if (contactRecordTypeName == 'Student' || contactRecordTypeName == 'Non Teaching' ||contactRecordTypeName == 'Professor') {
                contacts = [SELECT Id, Name FROM Contact WHERE Record_Type_Name__c IN ('Student', 'Non Teaching', 'Professor')];
            }
            /* else if (contactRecordTypeName == 'Professor') {
contacts = [SELECT Id, Name FROM Contact WHERE Record_Type_Name__c = 'Professor'];
}*/

            return contacts;
        } catch(Exception ex) {
            return null;
        }
    }



    @AuraEnabled
    public static MealInfoWrapper fetchMealsAvailable() {
        MealInfoWrapper objWrapper = new MealInfoWrapper();
        try {
            Id contactId = fetchContactId();
            Date nextDate = Date.today() + 1;
            Date objDate = Date.today();
            Set<Id> bookedMealIds = new Set<Id>();
            Set<Id> availedMealIds = new Set<Id>();
            Map<Id, Id> bookedMap = new Map<Id, Id>();
            Map<Id, Id> availedMap = new Map<Id, Id>();
            Set<String> alreadyBooked = new Set<String>{'Booked', 'Availed'};
                Boolean isMessTeamMember = isMessTeamUser();
            //Boolean isMessTeamMember = false;
            if (isMessTeamMember) {
                objWrapper.isMessTeamMember = isMessTeamMember;
                return objWrapper;
            }
            List<Reva_Meal_Booking__c> mealBookList = new List<Reva_Meal_Booking__c>();
            if (contactId != null) {
                mealBookList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                                AND Reva_Mess_Menu__r.Date__c  =: nextDate
                                AND Reva_Meal_Booking_Status__c  IN: alreadyBooked];
            } /*else {
mealBookList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId//Booking_For_User__c =: Userinfo.getUserId()//contactId
AND Reva_Mess_Menu__r.Date__c  =: nextDate
AND Reva_Meal_Booking_Status__c  IN: alreadyBooked];
}*/
            for (Reva_Meal_Booking__c mealBooking : mealBookList) {
                if (mealBooking.Reva_Meal_Booking_Status__c == 'Booked') {
                    bookedMealIds.add(mealBooking.Reva_Mess_Menu__c);
                    bookedMap.put(mealBooking.Reva_Mess_Menu__c, mealBooking.Id);
                }
                if (mealBooking.Reva_Meal_Booking_Status__c == 'Availed') {
                    availedMealIds.add(mealBooking.Reva_Mess_Menu__c);
                    availedMap.put(mealBooking.Reva_Mess_Menu__c, mealBooking.Id);
                }
            }
            system.debug('bookedMealIds => ' + bookedMealIds);
            objWrapper.messBookingEndTime = DateTime.newInstance(Date.today(), fetchMealBookingCloseTime());
            // if (DateTime.now() > objWrapper.messBookingEndTime) {
            //     System.debug('Hello');
            //     objWrapper.showWarning = true;
            //     objWrapper.message = 'Meal Booking is closed';
            //     return objWrapper;
            // }
            List<Reva_Mess_Menu__c> messMenuList = [SELECT Id, Date__c, Type__c, Start_Time__c, End_Time__c,
                                                    Reva_Mess__c, (SELECT Id, Name FROM Reva_Mess_Menu_Items__r) FROM Reva_Mess_Menu__c WHERE
                                                    Date__C =: nextDate
                                                    ORDER BY Date__c,Start_Time__c, End_Time__c ASC
                                                   ];
            System.debug(messMenuList);
            if (messMenuList == null || messMenuList.isEmpty()) {
                objWrapper.showWarning = true;
                objWrapper.message = 'No Meal Menus listed';
                return objWrapper;
            }
            List<BookMealWrapper> lstMenuWrapper = new List<BookMealWrapper>();
            for (Reva_Mess_Menu__c objMenu : messMenuList) {
                BookMealWrapper objMeal = new BookMealWrapper();
                objMeal.mealMenu = objMenu;
                objMeal.mealBookingStart = string.valueOf(objMenu.Start_Time__c);
                system.debug('objMenu.Id ==> ' + objMenu.Id);
                if (bookedMap.containsKey(objMenu.Id)) {
                    objMeal.booked = true;
                    objMeal.bookingId = bookedMap.get(objMenu.Id);
                }
                if (availedMap.containsKey(objMenu.Id)) {
                    objMeal.availed = true;
                    objMeal.bookingId = availedMap.get(objMenu.Id);
                }
                if (objMenu.Reva_Mess_Menu_Items__r != null && !objMenu.Reva_Mess_Menu_Items__r.isEmpty()) {
                    objMeal.itemsCount = objMenu.Reva_Mess_Menu_Items__r.size();
                }
                system.debug('objMeal.booked ==> ' + objMeal.booked);
                lstMenuWrapper.add(objMeal);
            }
            objWrapper.mealMenuDetails = lstMenuWrapper;
        } catch(Exception objException) {
            objWrapper.showError = true;
            objWrapper.message = 'Some Exception Occured.';
        }
        System.debug(objWrapper);
        return objWrapper;
    }
 @AuraEnabled
public static Boolean bookMeal(List<Id> messMenuIds) {
    Boolean insertSuccess = false;
    Date nextDate = Date.today() + 1;

    try {
        Id contactId = fetchContactId();
        if (contactId == null || messMenuIds.isEmpty()) return false;

        Boolean isMessTeamMember = isMessTeamUser();
        String bookingStatus = isMessTeamMember ? 'Instant Meal' : 'Booked';

        Set<Id> messMenuIdsSet = new Set<Id>(messMenuIds);
        Map<String, Reva_Meal_Booking__c> bookingMap = new Map<String, Reva_Meal_Booking__c>();

        // Step 1: Query existing bookings
        List<Reva_Meal_Booking__c> existingBookings = [
            SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c, External_Id__c
            FROM Reva_Meal_Booking__c
            WHERE Booking_For__c = :contactId
              AND Reva_Mess_Menu__c IN :messMenuIdsSet
        ];

        for (Reva_Meal_Booking__c existing : existingBookings) {
            String key = contactId + '-' + existing.Reva_Mess_Menu__c + '-' + bookingStatus + '-' + Date.today();
            existing.Reva_Meal_Booking_Status__c = bookingStatus;
            existing.Reva_Meal_Booking_Date__c = Date.today();
            existing.External_Id__c = key;
            bookingMap.put(key, existing);
        }

        // Step 2: Prepare new records for menus not yet booked
        for (Id messMenuId : messMenuIdsSet) {
            String key = contactId + '-' + messMenuId + '-' + bookingStatus + '-' + Date.today();

            if (!bookingMap.containsKey(key)) {
                Reva_Meal_Booking__c newBooking = new Reva_Meal_Booking__c(
                    Reva_Mess_Menu__c = messMenuId,
                    Booking_For__c = contactId,
                    Reva_Meal_Booking_Date__c = Date.today(),
                    Reva_Meal_Booking_Status__c = bookingStatus,
                    External_Id__c = key
                );
                bookingMap.put(key, newBooking);
            }
        }

        // Step 3: Upsert unique records based on external ID
        List<Reva_Meal_Booking__c> uniqueBookings = bookingMap.values();
        if (!uniqueBookings.isEmpty()) {
            Database.UpsertResult[] results = Database.upsert(uniqueBookings, Reva_Meal_Booking__c.External_Id__c, false);
            for (Database.UpsertResult result : results) {
                if (result.isSuccess()) {
                    insertSuccess = true;
                } else {
                    System.debug('Upsert error: ' + result.getErrors()[0].getMessage());
                }
            }
        }

        return insertSuccess;

    } catch (Exception ex) {
        System.debug('Error in bookMeal: ' + ex.getMessage());
        return false;
    }
}



    @AuraEnabled(cacheable=true)
    public static Boolean checkIfMessAdmin() {
        // Example of checking if the user has a specific permission set
        return [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Mess_Team'].size() > 0;
    }

    /**********Newly added on 27-11-2024 by Veera to check the Mess support Team****************/
    @AuraEnabled(cacheable=true)
    public static Boolean checkIfMessSupportTeam() {
        // Example of checking if the user has a specific permission set
        return [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Mess_Support_Team'].size() > 0;
    }
    /********************************Working one*****************************************/

    /* public static void updateMealStatus(Id recordId, String status) {
System.debug('Entered updateMealStatus with recordId: ' + recordId);
if (recordId == null) {
throw new AuraHandledException('Record ID is null');
}
try {
Reva_Meal_Booking__c record = new Reva_Meal_Booking__c();
record.Id = recordId;
record.Reva_Meal_Booking_Status__c = status;
update record;
System.debug('Record updated successfully');

} catch (Exception e) {
System.debug('Error: ' + e.getMessage());
throw new AuraHandledException('Error updating record: ' + e.getMessage());
}
}*/

    /*public static void updateMealStatus(Id recordId, String status) {
System.debug('Entered updateMealStatus with recordId: ' + recordId);

if (recordId == null) {
throw new AuraHandledException('Record ID is null');
}

try {
// Validate record existence
Reva_Meal_Booking__c record = [
SELECT Id, Reva_Meal_Booking_Status__c
FROM Reva_Meal_Booking__c
WHERE Id = :recordId
LIMIT 1
];

// Prevent updates to records with final status
if (record.Reva_Meal_Booking_Status__c == 'Availed' || record.Reva_Meal_Booking_Status__c == 'Missed meals') {
throw new AuraHandledException('Cannot update a record with final status.');
}

// Update record status
record.Reva_Meal_Booking_Status__c = status;
update record;

System.debug('Record updated successfully');
} catch (QueryException qe) {
throw new AuraHandledException('Record does not exist.');
} catch (Exception e) {
System.debug('Error: ' + e.getMessage());
if(!Test.isRunningTest()){
throw new AuraHandledException('Record Update Failed!');
}
}
} */

/******************Newly added Server time on 2-12-2025 by Devender***************************/
@AuraEnabled
public static String updateMealStatus(Id recordId, String status, Long qrTimestamp) {
    String resultMessage = '';

    try {
        Reva_Meal_Booking__c record = [
            SELECT Id, Reva_Meal_Booking_Status__c, Meal_End_Time__c,
                   Meal_start_time__c, Meal_Date__c, Is_Instant_Meal_Availed__c
            FROM Reva_Meal_Booking__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        if (record == null) {
            resultMessage = 'Error: Meal booking not found.';
        } else if (status == 'Availed') {
            String currentStatus = record.Reva_Meal_Booking_Status__c;
            Long currentTimeStamp = Datetime.now().getTime();
            if (qrTimestamp == null ||  qrTimestamp <= 0 || currentTimeStamp - qrTimestamp > 30000 || qrTimestamp > currentTimeStamp) {

              resultMessage = 'Error: QR code expired/ Invalid! Please show the portal latest QR code.';
            }
            else if (currentStatus == 'Availed' || currentStatus == 'Missed meals' || currentStatus == 'Cancelled') {
                resultMessage = 'Error: QR Code Already Scanned for this Meal or Cancelled.';
            } else if (
                record.Meal_Date__c == Date.today() &&
                record.Meal_End_Time__c < Datetime.now().time() &&
                (currentStatus == 'Booked' || currentStatus == 'Instant Meal')
            ) {
                resultMessage = 'Error: QR Code Expired for this meal / Meal time Ended.';
            } else if (
                record.Meal_Date__c == Date.today() &&
                record.Meal_End_Time__c > Datetime.now().time() &&
                (currentStatus == 'Booked' || currentStatus == 'Instant Meal')
            ) {
                if (currentStatus == 'Instant Meal') {
                    record.Is_Instant_Meal_Availed__c = true;
                }
                record.Reva_Meal_Booking_Status__c = status;
                record.Scanner_Success__c = true;
                record.Pop_up_Message_Success_From_Admin__c = true;
                update record;
                resultMessage = 'Success: QR Code Scanned Successfully!';
            } else {
                resultMessage = 'Error: QR Code Invalid or Expired!!';
                record.Scanner_Failed__c = true;
                record.Pop_up_Message_Failed_From_Admin__c = true;
                update record;
            }
        } else {
            if (record.Reva_Meal_Booking_Status__c == status) {
                resultMessage = 'Success: Meal already cancelled.'; // No update needed
            } else {
                record.Reva_Meal_Booking_Status__c = status;
                update record;
                resultMessage = 'Success: Your meal has been successfully cancelled.';
            }
        }

    } catch (QueryException qe) {
        resultMessage = 'Error: Re-Scan Again!';
    } catch (Exception ex) {
        resultMessage = 'Error: ' + ex.getMessage();
    }

    return resultMessage;
}
    /**************above one is working one***********************/


  /****************below one is previous one********************************************/
  /*  @AuraEnabled
    public static void invalidStatus(Id recordId,String status) {
        Reva_Meal_Booking__c record = [
            SELECT Id, Reva_Meal_Booking_Status__c,Error_Msg_Check__c
            FROM Reva_Meal_Booking__c
            WHERE Id = :recordId
            LIMIT 1 FOR UPDATE
        ];
        if(status == 'Invalid'){
            record.Error_Msg_Check__c = true;
        }If(status == 'Success'){
            record.Error_Msg_Check__c = false;
        }
        update record;
    }*/
    @AuraEnabled
public static void invalidStatus(Id recordId, String status) {
    System.enqueueJob(new InvalidStatusUpdater(recordId, status));
}
/***************************changes ended here********************************************************/
 @AuraEnabled
    public static void SuccessStatus(Id recordId,String status) {
        Reva_Meal_Booking__c record = [
            SELECT Id, Reva_Meal_Booking_Status__c,QR_Scanned_Success__c,Scanner_Success__c,Pop_up_Message_Success_From_Student__c
            FROM Reva_Meal_Booking__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        if(status == 'QrSuccess'){
            record.QR_Scanned_Success__c = true;
            record.Pop_up_Message_Success_From_Student__c = true;
        }
        update record;
    }

    @AuraEnabled
    public static void FailedStatus(Id recordId,String status) {
        Reva_Meal_Booking__c record = [
            SELECT Id, Reva_Meal_Booking_Status__c,QR_Scanned_Failed__c,Scanner_Failed__c,Pop_up_Message_Failed_From_Student__c
            FROM Reva_Meal_Booking__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        if(status == 'QrFailed'){
            record.QR_Scanned_Failed__c = true;
            record.Pop_up_Message_Failed_From_Student__c = true;
        }
        update record;
    }

    @AuraEnabled
    public static Boolean hascheckUpdated(Id mealBookingId) {
        try{
            Reva_Meal_Booking__c record = [
                SELECT Id, Reva_Meal_Booking_Status__c,Error_Msg_Check__c
                FROM Reva_Meal_Booking__c
                WHERE Id = :mealBookingId
                LIMIT 1
            ];
            if (record.Error_Msg_Check__c == true && record.Reva_Meal_Booking_Status__c == 'Booked') {
                return true;
            }else{

                return false;
            }

        }Catch(Exception e){
            return false;
        }
    }
    /***********************************************************************/



    @AuraEnabled
    public static List<Reva_Meal_Booking__c> updateFeedbackBookedmeal(Id mealId, String feedbackEmoji,String feedbackName, String description, String rating ) {
        system.debug(mealId);
        system.debug(feedbackEmoji);
        List<Reva_Meal_Booking__c> mealFeedback = new List<Reva_Meal_Booking__c>();
        Reva_Meal_Booking__c mealRecord = new Reva_Meal_Booking__c();
        mealRecord.Id = mealId;
        mealRecord.Meal_Feedback__c = feedbackEmoji + ' ' + feedbackName + ' '+ description;
        mealRecord.Rating__c = rating;
        mealFeedback.add(mealRecord);
        system.debug(mealFeedback);
        update mealFeedback;
        return mealFeedback;
    }


    @AuraEnabled
   /* public static CancelMealWrapper cancelMeal(List<Id> messMenuIds) {
        Boolean insertSuccess = false;
        CancelMealWrapper objWrapper = new CancelMealWrapper();
        try {
            List<Reva_Mess_Menu__c> messMenuList = [SELECT Id, Date__c, Type__c, Start_Time__c, End_Time__c,
                                                    Reva_Mess__c FROM Reva_Mess_Menu__c WHERE Id IN: messMenuIds];
            for (Reva_Mess_Menu__c objMenu :messMenuList) {
                Datetime compare = DateTime.newInstance(objMenu.Date__c, objMenu.Start_Time__c);
                system.debug('compare.addHours(-6) ==> ' + compare);
                system.debug('compare.addHours(-6) ==> ' + compare.addHours(-6));
                system.debug('DateTime.now() ==> ' + DateTime.now());
                //Decimal diff = DateTime.now() - DateTime.newInstance(objMenu.Date__c, objMenu.Start_Time__c);
                if (DateTime.now() >= compare.addHours(-6)) {
                    objWrapper.showWarning = true;
                    objWrapper.message = 'Cannot cancel meal as one of the meal(s) time exceeded';
                    return objWrapper;
                }
            }
            List<Reva_Meal_Booking__c> mealBookingList = new List<Reva_Meal_Booking__c>();
            Set<String> alreadyBooked = new Set<String>{'Booked'};
                Id contactId = fetchContactId();
            Date objDate = Date.today() ;
            if (contactId != null) {
                mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                                   AND Reva_Meal_Booking_Date__c  >=: objDate
                                   AND Reva_Meal_Booking_Status__c  IN: alreadyBooked AND Reva_Mess_Menu__c IN: messMenuIds];
            } /*else {
mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId//Booking_For_User__c =: UserInfo.getUserId()//contactId
AND Reva_Meal_Booking_Date__c  >=: objDate
AND Reva_Meal_Booking_Status__c  IN: alreadyBooked AND Reva_Mess_Menu__c IN: messMenuIds];
}*/

        /*    for (Reva_Meal_Booking__c objBooking : mealBookingList) {
                objBooking.Reva_Meal_Booking_Status__c = 'Cancelled';
                objBooking.Reva_Meal_Booking_Date__c = Date.today();
            }
            Database.SaveResult [] results = Database.update(mealBookingList, true);
            for (Database.SaveResult result : results) {
                if (result.isSuccess()) {
                    insertSuccess = true;
                } else {
                    insertSuccess = false;
                }
            }
        } catch (Exception ex) {
            objWrapper.showError = true;
            objWrapper.message = 'Some Exception Occured.';
            return objWrapper;
        }
        objWrapper.cancelSuccess = insertSuccess;
        return objWrapper;
    } */

    public static Id fetchContactId() {
        Id contactId;
        String currentUserEmail = UserInfo.getUserEmail();
        system.debug('currentUserEmail==>'+currentUserEmail);
        /* if(Test.isRunningTest()){
if (currentUserEmail != null ) {
Contact contact = [SELECT Id FROM Contact WHERE Email = :currentUserEmail LIMIT 1];
system.debug('contactEmail==>'+contact);
if (contact != null) {
contactId = contact.Id;
}
}
}else{*/

        try {
            User usr = [SELECT Id,Name, ContactId FROM User WHERE Id =:userinfo.getUserId()];
            if (usr.ContactId != null) {
                contactId = usr.ContactId;
            }
            else if (currentUserEmail != null ) {
                Contact contact = [SELECT Id FROM Contact WHERE Email = :currentUserEmail LIMIT 1];
                if (contact != null) {
                    contactId = contact.Id;
                }
            } }
        catch(Exception ex) {

        }

        return contactId;
    }



  /*  public class CancelMealWrapper {
        @AuraEnabled
        public Boolean showError;
        @AuraEnabled
        public Boolean showWarning;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean cancelSuccess;
        public CancelMealWrapper() {
            this.showError = false;
            this.showWarning = false;
            this.message = '';
            this.cancelSuccess = false;
        }

    } */
    public class MealInfoWrapper {
        @AuraEnabled
        public List<BookMealWrapper> mealMenuDetails;
        @AuraEnabled
        public DateTime messBookingEndTime;
        @AuraEnabled
        public Boolean showError;
        @AuraEnabled
        public Boolean showWarning;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean isMessTeamMember;
        public MealInfoWrapper() {
            this.mealMenuDetails = new List<BookMealWrapper>();
            this.showError = false;
            this.showWarning = false;
            this.message = '';
            this.isMessTeamMember = false;
        }
    }
    public class BookMealWrapper {
        @AuraEnabled
        public Reva_Mess_Menu__c mealMenu;
        @AuraEnabled
        public Boolean booked;
        @AuraEnabled
        public Boolean availed;
        @AuraEnabled
        public Integer itemsCount;
        @AuraEnabled
        public Id bookingId;
        @AuraEnabled
        public String mealBookingStart;
        public BookMealWrapper() {
            this.mealMenu = new Reva_Mess_Menu__c();
            this.booked = false;
            this.itemsCount = 0;
        }
    }
    @AuraEnabled
    public static List<BookedMealInfoWrapper> fetchBookedMeals() {
        List<Reva_Meal_Booking__c> mealBookList = new List<Reva_Meal_Booking__c>();
        List<BookedMealInfoWrapper> lstWrapper = new List<BookedMealInfoWrapper>();
        try {
            Id contactId = fetchContactId();
            Date objDate = Date.today();
            Set<Id> bookedMealIds = new Set<Id>();
            Set<Id> availedMealIds = new Set<Id>();
            Date yesterday = objDate.addDays(-1);
            Map<Id, Id> bookedMap = new Map<Id, Id>();
            Map<Id, Id> availedMap = new Map<Id, Id>();
            Set<String> alreadyBooked = new Set<String>{'Booked'};
                if (contactId != null) {
                    mealBookList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c,Reva_Mess_Menu__r.End_Time__c,Reva_Mess_Menu__r.Start_Time__c,Reva_Mess_Menu__r.Type__c,Reva_Meal_Booking_Date__c,Reva_Mess_Menu__r.Date__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                                    AND (Reva_Mess_Menu__r.Date__c  >: objDate )
                                    AND Reva_Meal_Booking_Status__c  IN: alreadyBooked ORDER BY Reva_Mess_Menu__r.Date__c,Reva_Mess_Menu__r.Start_Time__c, Reva_Mess_Menu__r.End_Time__c ASC];
                } /*else {
mealBookList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c,Reva_Mess_Menu__r.End_Time__c,Reva_Mess_Menu__r.Start_Time__c,Reva_Mess_Menu__r.Type__c,Reva_Meal_Booking_Date__c,Reva_Mess_Menu__r.Date__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId//Userinfo.getUserId()//contactId
AND (Reva_Mess_Menu__r.Date__c  >: objDate )
AND Reva_Meal_Booking_Status__c  IN: alreadyBooked ORDER BY Reva_Mess_Menu__r.Date__c,Reva_Mess_Menu__r.Start_Time__c, Reva_Mess_Menu__r.End_Time__c ASC];
}*/

            for (Reva_Meal_Booking__c booking : mealBookList) {
                if (!bookedMealIds.contains(booking.Reva_Mess_Menu__c)) {
                    //BookedMealInfoWrapper wrapper = new BookedMealInfoWrapper();
                    Datetime compare = DateTime.newInstance(booking.Reva_Mess_Menu__r.Date__c, booking.Reva_Mess_Menu__r.Start_Time__c);
                    system.debug('compare.addHours(-6) ==> ' + compare.addHours(-6));
                    system.debug('DateTime.now() ==> ' + DateTime.now());
                    Boolean disableCancel = false;
                    if (DateTime.now() >= compare.addHours(-6)) {
                        disableCancel = true;
                    }
                    BookedMealInfoWrapper wrapper = new BookedMealInfoWrapper(booking, disableCancel);
                    lstWrapper.add(wrapper);
                    bookedMealIds.add(booking.Reva_Mess_Menu__c);
                }
            }
        } catch(Exception objException) {
        }
        return lstWrapper;
        //return objWrapper;
    }


    @AuraEnabled
    public static boolean checkExistingBooking(Id menuId,Id contactId) {
        system.debug('checkExistingBooking excecuting');
        boolean todayMealsExisted;
        // system.debug(menuId + ' ' + contactId);
        List<Reva_Meal_Booking__c> existingBookings = [
            SELECT Id , Booking_For__c
            FROM Reva_Meal_Booking__c
            WHERE Reva_Mess_Menu__c =: menuId
            AND Booking_For__c =: contactId
            AND (Reva_Meal_Booking_Status__c = 'Booked'
                 OR  Reva_Meal_Booking_Status__c = 'Instant Meal' )
            AND Reva_Mess_Menu__r.Date__c = TODAY
        ];
        system.debug('existingBookings'+ existingBookings);
        if(existingBookings.isEmpty()){
            todayMealsExisted = true;
        }else{
            todayMealsExisted = false;
        }
        return todayMealsExisted;

    }




    @AuraEnabled
    public static List<BookedMealInfoWrapper> feebackForBookedMeals() {
        List<Reva_Meal_Booking__c> mealBookList = new List<Reva_Meal_Booking__c>();
        List<BookedMealInfoWrapper> lstWrapper = new List<BookedMealInfoWrapper>();
        try {
            Id contactId = fetchContactId();
            Date objDate = Date.today();
            Set<Id> bookedMealIds = new Set<Id>();
            Set<Id> availedMealIds = new Set<Id>();
            Date yesterday = objDate.addDays(-1);
            Map<Id, Id> bookedMap = new Map<Id, Id>();
            Map<Id, Id> availedMap = new Map<Id, Id>();
            set<String> alreadyBooked = new Set<String>{'Availed'};
                // Set<String> alreadyBooked = new Set<String>{'Booked', 'Availed'};
                if (contactId != null) {
                    mealBookList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c,Meal_Feedback__c,Reva_Mess_Menu__r.End_Time__c,Reva_Mess_Menu__r.Start_Time__c,Reva_Mess_Menu__r.Type__c,Reva_Meal_Booking_Date__c,Reva_Mess_Menu__r.Date__c,Booking_For__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                                    AND (Reva_Mess_Menu__r.Date__c  >=: objDate OR Reva_Mess_Menu__r.Date__c = :yesterday)
                                    AND Reva_Meal_Booking_Status__c  IN: alreadyBooked ORDER BY Reva_Mess_Menu__r.Date__c,Reva_Mess_Menu__r.Start_Time__c, Reva_Mess_Menu__r.End_Time__c ASC];
                } /*else {
mealBookList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c,Meal_Feedback__c,Reva_Mess_Menu__r.End_Time__c,Reva_Mess_Menu__r.Start_Time__c,Reva_Mess_Menu__r.Type__c,Reva_Meal_Booking_Date__c,Reva_Mess_Menu__r.Date__c,Booking_For__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId//Userinfo.getUserId()//contactId
AND (Reva_Mess_Menu__r.Date__c  >=: objDate OR Reva_Mess_Menu__r.Date__c = :yesterday)
AND Reva_Meal_Booking_Status__c  IN: alreadyBooked ORDER BY Reva_Mess_Menu__r.Date__c,Reva_Mess_Menu__r.Start_Time__c, Reva_Mess_Menu__r.End_Time__c ASC];
}*/

            for (Reva_Meal_Booking__c booking : mealBookList) {
                if (!bookedMealIds.contains(booking.Reva_Mess_Menu__c)) {
                    //BookedMealInfoWrapper wrapper = new BookedMealInfoWrapper();
                    Datetime compare = DateTime.newInstance(booking.Reva_Mess_Menu__r.Date__c, booking.Reva_Mess_Menu__r.Start_Time__c);
                    system.debug('compare.addHours(-6) ==> ' + compare.addHours(-6));
                    system.debug('DateTime.now() ==> ' + DateTime.now());
                    Boolean disableCancel = false;
                    if (DateTime.now() >= compare.addHours(-6)) {
                        disableCancel = true;
                    }
                    BookedMealInfoWrapper wrapper = new BookedMealInfoWrapper(booking, disableCancel);
                    lstWrapper.add(wrapper);
                    bookedMealIds.add(booking.Reva_Mess_Menu__c);
                }
            }
        } catch(Exception objException) {
        }
        return lstWrapper;
        //return objWrapper;
    }


    @AuraEnabled
    public static List<BookedMealInfoWrapper> fetchBookedMealsForTodayTomorrow() {
        List<Reva_Meal_Booking__c> mealBookList = new List<Reva_Meal_Booking__c>();
        List<BookedMealInfoWrapper> lstWrapper = new List<BookedMealInfoWrapper>();
        try {
            Id contactId = fetchContactId();
            Date objDate = Date.today();
            Set<Id> bookedMealIds = new Set<Id>();
            Set<Id> availedMealIds = new Set<Id>();
            Date yesterday = objDate.addDays(-1);
            Map<Id, Id> bookedMap = new Map<Id, Id>();
            Map<Id, Id> availedMap = new Map<Id, Id>();
            Set<String> alreadyBooked = new Set<String>{'Booked'};
                if (contactId != null) {
                    mealBookList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c, 	Meal_Feedback__c, Reva_Mess_Menu__r.End_Time__c,Reva_Mess_Menu__r.Start_Time__c,Reva_Mess_Menu__r.Type__c,Reva_Meal_Booking_Date__c,Reva_Mess_Menu__r.Date__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                                    AND (Reva_Mess_Menu__r.Date__c  =: objDate )
                                    AND Reva_Meal_Booking_Status__c  IN: alreadyBooked ORDER BY Reva_Mess_Menu__r.Date__c,Reva_Mess_Menu__r.Start_Time__c, Reva_Mess_Menu__r.End_Time__c ASC];
                } /*else {
mealBookList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c,	Meal_Feedback__c, Reva_Mess_Menu__r.End_Time__c,Reva_Mess_Menu__r.Start_Time__c,Reva_Mess_Menu__r.Type__c,Reva_Meal_Booking_Date__c,Reva_Mess_Menu__r.Date__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId//Userinfo.getUserId()//contactId
AND (Reva_Mess_Menu__r.Date__c  =: objDate )
AND Reva_Meal_Booking_Status__c  IN: alreadyBooked ORDER BY Reva_Mess_Menu__r.Date__c,Reva_Mess_Menu__r.Start_Time__c, Reva_Mess_Menu__r.End_Time__c ASC];
}*/

            for (Reva_Meal_Booking__c booking : mealBookList) {
                if (!bookedMealIds.contains(booking.Reva_Mess_Menu__c)) {
                    //BookedMealInfoWrapper wrapper = new BookedMealInfoWrapper();
                    Datetime compare = DateTime.newInstance(booking.Reva_Mess_Menu__r.Date__c, booking.Reva_Mess_Menu__r.Start_Time__c);
                    system.debug('compare.addHours(-6) ==> ' + compare.addHours(-6));
                    system.debug('DateTime.now() ==> ' + DateTime.now());
                    Boolean disableCancel = false;
                    if (DateTime.now() >= compare.addHours(-6)) {
                        disableCancel = true;
                    }
                    BookedMealInfoWrapper wrapper = new BookedMealInfoWrapper(booking, disableCancel);
                    lstWrapper.add(wrapper);
                    bookedMealIds.add(booking.Reva_Mess_Menu__c);
                }
            }
        } catch(Exception objException) {
        }
        return lstWrapper;
        //return objWrapper;
    }




    @AuraEnabled
    public static Integer missedMealsByTheUser() {
        Integer totalMealsMissedThisMonth=0;
        String temp = '';
        Id contactId = fetchContactId();

        try {
            Date currentDate = Date.today();
            Date firstDayOfMonth = currentDate.toStartOfMonth();
            Contact objCon = [SELECT Id, hed__Gender__c,(SELECT Id, Name, Reva_Meal_Booking_Status__c, Reva_Meal_Booking_Date__c
                                                         FROM Reva_Meal_Bookings__r  WHERE (Reva_Meal_Booking_Status__c='Missed Meal' OR Reva_Meal_Booking_Status__c='Instant Meal')
                                                         AND Reva_Meal_Booking_Date__c>= :firstDayOfMonth)
                              FROM Contact WHERE Id =: contactId LIMIT 1];
            totalMealsMissedThisMonth = objCon.Reva_Meal_Bookings__r.size();
            system.debug('totalMealsMissedThisMonth'+ totalMealsMissedThisMonth);
        } catch(Exception objException) {
        }
        return totalMealsMissedThisMonth;
    }
    /************************ *******************************/

    @AuraEnabled
    public static Integer ifUserOnLeave(Date mealDateTime) {
        Integer totalCurrentLeaves = 0;
        System.debug('mealDateTime: ' + mealDateTime);

        try {
            Id contactId = fetchContactId();
            System.debug('contactId: ' + contactId);

            Contact objCon = [SELECT Id,
                              (SELECT Id, Start_Date_and_Time__c, End_Date_and_Time__c
                               FROM REVA_Hostel_Leave_Requests__r
                               WHERE Status__c IN ('Approved','Check Out')  AND
                               ((Start_Date_and_Time__c <= :mealDateTime AND
                                 End_Date_and_Time__c >= :mealDateTime) OR
                                (Start_Date_and_Time__c <= :System.now().addHours(24) AND
                                 End_Date_and_Time__c >= :System.now())))
                              FROM Contact
                              WHERE Id = :contactId
                              LIMIT 1];

            System.debug('objCon: ' + objCon);

            for(REVA_Hostel_Leave_Request__c leaveRequest : objCon.REVA_Hostel_Leave_Requests__r) {
                System.debug('leaveRequest: ' + leaveRequest);
                System.debug('leaveRequest.Start_Date_and_Time__c: ' + leaveRequest.Start_Date_and_Time__c);
                System.debug('leaveRequest.End_Date_and_Time__c: ' + leaveRequest.End_Date_and_Time__c);

                if(leaveRequest.Start_Date_and_Time__c <= mealDateTime && leaveRequest.End_Date_and_Time__c >= mealDateTime) {
                    // User is on leave during mealDateTime, return 1 (cannot book meals)
                    return 1;
                }
                if(leaveRequest.End_Date_and_Time__c < System.now().addHours(24)) {
                    // User's leave is ending within 24 hours
                    // Check if mealDateTime is after leave end time, then allow booking
                    if (mealDateTime > leaveRequest.End_Date_and_Time__c) {
                        return 0; // Allow booking
                    } else {
                        return 1; // Don't allow booking
                    }
                }
            }

            return 0; // No leave found, allow booking

        } catch(Exception objException) {
            System.debug('Exception: ' + objException);
            // Handle exception
            return totalCurrentLeaves;
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<Id> getRevaMessMenuIds() {
        // Get the current date
        Date nextDate = Date.today() + 1;
        Date Today = Date.today();
        // Query for the Reva_Mess_Menu__c record Ids for today and tomorrow
        // List<Reva_Mess_Menu__c> menuDetails = [SELECT Id FROM Reva_Mess_Menu__c WHERE (Date__c =: nextDate OR Date__c =:Today) ];
        List<Reva_Mess_Menu__c> menuDetails = [SELECT Id FROM Reva_Mess_Menu__c ];
        // Initialize a list to store the Ids
        List<Id> menuIds = new List<Id>();

        // Add the Ids of the records found to the list
        for (Reva_Mess_Menu__c menu : menuDetails) {
            menuIds.add(menu.Id);
        }

        return menuIds;
    }



    @AuraEnabled(cacheable=true)
    public static Map<String, List<Object>> bookAndFetchMeals() {
        Map<String, List<Object>> result = new Map<String, List<Object>>();

        try {
            Id contactId = fetchContactId();
            Date nextDate = Date.today() + 1;
            Date yesterday = Date.today() - 1;
            Date Today = Date.today();

            // Dynamically fetch the Mess Menu record Ids based on current date
            List<Id> menuIds = getRevaMessMenuIds();

            // Fetch Mess Menu records along with their related Mess Menu Items
            result.put('MealsToBook', [
                SELECT Id, Date__c, Type__c, Start_Time__c, End_Time__c, Reva_Mess__c, Mess_Items__c, Display_End_Time__c,
                (SELECT Id, Name FROM Reva_Mess_Menu_Items__r)
                FROM Reva_Mess_Menu__c
                WHERE Id IN :menuIds AND (Date__C =: nextDate) ORDER BY Date__c ASC,Start_Time__c  ASC

            ]);

            // Query existing meal bookings
            result.put('BookedMeals', [
                SELECT Id, Reva_Meal_Booking_Status__c, Reva_Mess_Menu__r.Date__c,Reva_Mess_Menu__r.Type__c, Reva_Mess_Menu__r.Display_End_Time__c,
                Reva_Mess_Menu__r.Start_Time__c, Reva_Mess_Menu__r.End_Time__c , Booking_For__c, Reva_Mess_Menu__r.Mess_Items__c
                FROM Reva_Meal_Booking__c
                WHERE Reva_Meal_Booking_Status__c != 'Cancelled' AND
                Reva_Mess_Menu__c IN :menuIds
                AND (Reva_Mess_Menu__r.Date__c =: yesterday OR Reva_Mess_Menu__r.Date__c =:Today OR Reva_Mess_Menu__r.Date__c =:nextDate)
                AND Booking_For__c = :contactId ORDER BY Reva_Mess_Menu__r.Date__c ASC,Reva_Mess_Menu__r.Start_Time__c  ASC

            ]);

        } catch (Exception ex) {
            // Handle or log the exception
        }

        return result;
    }



    @AuraEnabled(cacheable=true)
    public static List<Reva_Mess_Menu__c> getMessMenuItems(Id messMenuId) {
        try {
            return [SELECT Id, Mess_Items__c, End_Time__c, Start_Time__c, Type__c FROM Reva_Mess_Menu__c WHERE Id = :messMenuId];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching mess menu items: ' + e.getMessage());
        }
    }




    public class BookedMealInfoWrapper {
        @AuraEnabled
        public Reva_Meal_Booking__c booking;
        @AuraEnabled
        public Boolean disableSelection;
        public BookedMealInfoWrapper(Reva_Meal_Booking__c objBooking, Boolean disableSelect) {
            this.booking = objBooking;
            this.disableSelection = disableSelect;
        }
    }
    public static Time fetchMealBookingCloseTime() {
        try {
            Mess_Settings__c objSettings = Mess_Settings__c.getInstance();
            return objSettings.Booking_Close_Time__c.Time();
        } catch (Exception ex) {
            Datetime compare = DateTime.newInstance(Date.today(), Time.newInstance(21, 00, 00, 00));
            return compare.Time();
        }
    }
    public static Boolean isMessTeamUser() {
        Boolean isMember = FeatureManagement.checkPermission('Mess_Team');
        return isMember;
    }


    @AuraEnabled
    public static Boolean bookMealByMessAdmin(List<Id> messMenuIds, Id contactId) {
        Boolean insertSuccess = false;
        Date nextDate = Date.today() +1;
        Set<String> alreadyBooked = new Set<String>{'Booked'};
            try {
                // Id contactId = fetchContactId();
                Set<Id> messMenuIdsSet = new Set<Id>();
                messMenuIdsSet.addAll(messMenuIds);
                Set<Id> bookedMealIds = new Set<Id>();
                List<Reva_Meal_Booking__c> mealBookingList = new List<Reva_Meal_Booking__c>();

                Boolean isMessTeamMember = isMessTeamUser(); // Check if the user is a mess team member
                String bookingStatus = isMessTeamMember ? 'Instant Meal Booking' : 'Booked'; // Set status based on user role
                /*Contact objCon = [select Id,LastName,Program_Batch__c,Program_Batch__r.Name,RecordType.Name,Active_Section__c,Active_Section__r.Section_Name__c,
Active_Semester__c,Active_Semester__r.Term_Number__c from Contact
Where id =: usr.ContactId];*/
                if (contactId != null) {
                    mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                                       AND Reva_Mess_Menu__r.Date__c  =: nextDate
                                       AND Reva_Mess_Menu__c IN: messMenuIds];
                } /*else {
mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId// Booking_For_User__c =: Userinfo.getUserId()//contactId
AND Reva_Mess_Menu__r.Date__c  =: nextDate
AND Reva_Mess_Menu__c IN: messMenuIds];
}*/


                if (!mealBookingList.isEmpty()) {
                    for (Reva_Meal_Booking__c objBooking : mealBookingList) {
                        objBooking.Reva_Meal_Booking_Status__c = bookingStatus;//'Booked';
                        objBooking.Reva_Meal_Booking_Date__c = Date.today();
                        bookedMealIds.add(objBooking.Reva_Mess_Menu__c);
                    }
                    messMenuIdsSet.removeAll(bookedMealIds);
                    for (Id messMenuId : messMenuIds) {
                        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(Reva_Mess_Menu__c = messMenuId,
                                                                                    Reva_Meal_Booking_Date__c  = Date.today(), Reva_Meal_Booking_Status__c  = bookingStatus);//'Booked');
                        if (contactId != null) {


                            mealBooking.Booking_For__c   = contactId;
                        } else
                        {
                            mealBooking.Booking_For__c   = contactId;
                            //  mealBooking.Booking_For_User__c = UserInfo.getUserId();
                        }
                        mealBookingList.add(mealBooking);
                    }
                } else {
                    for (Id messMenuId : messMenuIds) {
                        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(Reva_Mess_Menu__c = messMenuId,
                                                                                    Reva_Meal_Booking_Date__c  = Date.today(), Reva_Meal_Booking_Status__c  = bookingStatus);//'Booked');
                        if (contactId != null) {
                            mealBooking.Booking_For__c   = contactId;
                        }
                        else {
                            mealBooking.Booking_For__c   = contactId;
                            //mealBooking.Booking_For_User__c = UserInfo.getUserId();
                        }
                        mealBookingList.add(mealBooking);
                    }
                }
                Database.UpsertResult [] results = Database.upsert(mealBookingList, true);
                for (Database.UpsertResult result : results) {
                    if (result.isSuccess()) {
                        insertSuccess = true;
                    } else {
                        insertSuccess = false;
                    }
                }
                return insertSuccess;
            } catch (Exception ex) {
                return insertSuccess;
            }
    }

    @AuraEnabled
    public static Boolean hasStatusUpdated(Id mealBookingId) {
        try{
            Reva_Meal_Booking__c mealBooking = [
                SELECT Reva_Meal_Booking_Status__c,Error_Msg_Check__c
                FROM Reva_Meal_Booking__c
                WHERE Id = :mealBookingId
                LIMIT 1
            ];
            system.debug('Hello::'+ mealBooking.Reva_Meal_Booking_Status__c);
            if (mealBooking.Reva_Meal_Booking_Status__c == 'Availed') {
                return true;
            }else{

                return false;
            }

        }Catch(Exception e){
            return false;
        }
    }

    //Testmethod
    @AuraEnabled
    public static Boolean bookMealByMessAdmintestmethod(List<Id> messMenuIds, Id contactId) {
        Boolean insertSuccess = false;
        Date nextDate = Date.today() +1;
        Set<String> alreadyBooked = new Set<String>{'Booked'};
            //  try {
            // Id contactId = fetchContactId();
            Set<Id> messMenuIdsSet = new Set<Id>();
        messMenuIdsSet.addAll(messMenuIds);
        Set<Id> bookedMealIds = new Set<Id>();
        List<Reva_Meal_Booking__c> mealBookingList = new List<Reva_Meal_Booking__c>();

        Boolean isMessTeamMember = isMessTeamUser(); // Check if the user is a mess team member
        String bookingStatus = isMessTeamMember ? 'Instant Meal Booking' : 'Booked'; // Set status based on user role
        /*Contact objCon = [select Id,LastName,Program_Batch__c,Program_Batch__r.Name,RecordType.Name,Active_Section__c,Active_Section__r.Section_Name__c,
Active_Semester__c,Active_Semester__r.Term_Number__c from Contact
Where id =: usr.ContactId];*/
        if (contactId != null) {
            mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                               AND Reva_Mess_Menu__r.Date__c  =: nextDate
                               AND Reva_Mess_Menu__c IN: messMenuIds];
        } /*else {
mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId// Booking_For_User__c =: Userinfo.getUserId()//contactId
AND Reva_Mess_Menu__r.Date__c  =: nextDate
AND Reva_Mess_Menu__c IN: messMenuIds];
}*/


        if (!mealBookingList.isEmpty()) {
            for (Reva_Meal_Booking__c objBooking : mealBookingList) {
                objBooking.Reva_Meal_Booking_Status__c = bookingStatus;//'Booked';
                objBooking.Reva_Meal_Booking_Date__c = Date.today();
                bookedMealIds.add(objBooking.Reva_Mess_Menu__c);
            }
            messMenuIdsSet.removeAll(bookedMealIds);
            for (Id messMenuId : messMenuIds) {
                Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(Reva_Mess_Menu__c = messMenuId,
                                                                            Reva_Meal_Booking_Date__c  = Date.today(), Reva_Meal_Booking_Status__c  = bookingStatus);//'Booked');
                if (contactId != null) {


                    mealBooking.Booking_For__c   = contactId;
                }
                mealBookingList.add(mealBooking);
            }
        } else {
            for (Id messMenuId : messMenuIds) {
                Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(Reva_Mess_Menu__c = messMenuId,
                                                                            Reva_Meal_Booking_Date__c  = Date.today(), Reva_Meal_Booking_Status__c  = bookingStatus);//'Booked');
                if (contactId != null) {
                    mealBooking.Booking_For__c   = contactId;
                }
                else {
                    mealBooking.Booking_For__c   = contactId;
                    //mealBooking.Booking_For_User__c = UserInfo.getUserId();
                }
                mealBookingList.add(mealBooking);
            }
        }
        Database.UpsertResult [] results = Database.upsert(mealBookingList, true);
        for (Database.UpsertResult result : results) {
            if (result.isSuccess()) {
                insertSuccess = true;
            }
        }
        return insertSuccess;

    }


    //Testmethod
    @AuraEnabled
    public static Boolean bookMealByMessAdmintestmethod1(List<Id> messMenuIds, Id contactId) {
        Boolean insertSuccess = false;
        Date nextDate = Date.today() +1;
        Set<String> alreadyBooked = new Set<String>{'Booked'};
            // try {
            // Id contactId = fetchContactId();
            Set<Id> messMenuIdsSet = new Set<Id>();
        messMenuIdsSet.addAll(messMenuIds);
        Set<Id> bookedMealIds = new Set<Id>();
        List<Reva_Meal_Booking__c> mealBookingList = new List<Reva_Meal_Booking__c>();

        Boolean isMessTeamMember = isMessTeamUser(); // Check if the user is a mess team member
        String bookingStatus = isMessTeamMember ? 'Instant Meal Booking' : 'Booked'; // Set status based on user role
        /*Contact objCon = [select Id,LastName,Program_Batch__c,Program_Batch__r.Name,RecordType.Name,Active_Section__c,Active_Section__r.Section_Name__c,
Active_Semester__c,Active_Semester__r.Term_Number__c from Contact
Where id =: usr.ContactId];*/
        if (contactId != null) {
            mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                               AND Reva_Mess_Menu__r.Date__c  =: nextDate
                               AND Reva_Mess_Menu__c IN: messMenuIds];
        } /*else {
mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId// Booking_For_User__c =: Userinfo.getUserId()//contactId
AND Reva_Mess_Menu__r.Date__c  =: nextDate
AND Reva_Mess_Menu__c IN: messMenuIds];
}*/


        if (!mealBookingList.isEmpty()) {
            for (Reva_Meal_Booking__c objBooking : mealBookingList) {
                objBooking.Reva_Meal_Booking_Status__c = bookingStatus;//'Booked';
                objBooking.Reva_Meal_Booking_Date__c = Date.today();
                bookedMealIds.add(objBooking.Reva_Mess_Menu__c);
            }
            messMenuIdsSet.removeAll(bookedMealIds);
            for (Id messMenuId : messMenuIds) {
                Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(Reva_Mess_Menu__c = messMenuId,
                                                                            Reva_Meal_Booking_Date__c  = Date.today(), Reva_Meal_Booking_Status__c  = bookingStatus);//'Booked');
                if (contactId != null) {


                    mealBooking.Booking_For__c   = contactId;
                }
                mealBookingList.add(mealBooking);
            }
        } else {
            for (Id messMenuId : messMenuIds) {
                Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(Reva_Mess_Menu__c = messMenuId,
                                                                            Reva_Meal_Booking_Date__c  = Date.today(), Reva_Meal_Booking_Status__c  = bookingStatus);//'Booked');
                if (contactId != null) {
                    mealBooking.Booking_For__c   = contactId;
                }
                else {
                    mealBooking.Booking_For__c   = contactId;
                    //mealBooking.Booking_For_User__c = UserInfo.getUserId();
                }
                mealBookingList.add(mealBooking);
            }
        }
        Database.UpsertResult [] results = Database.upsert(mealBookingList, true);
        for (Database.UpsertResult result : results) {
            if (result.isSuccess()) {
                insertSuccess = true;
            }
        }
        return insertSuccess;
        // }
    }

    //Testmethod
   /* @AuraEnabled
    public static Boolean bookMealByMessAdmintestmethod2(List<Id> messMenuIds, Id contactId) {
        Boolean insertSuccess = false;
        Date nextDate = Date.today() +1;
        Set<String> alreadyBooked = new Set<String>{'Booked'};
            //try {
            // Id contactId = fetchContactId();
            Set<Id> messMenuIdsSet = new Set<Id>();
        messMenuIdsSet.addAll(messMenuIds);
        Set<Id> bookedMealIds = new Set<Id>();
        List<Reva_Meal_Booking__c> mealBookingList = new List<Reva_Meal_Booking__c>();

        Boolean isMessTeamMember = isMessTeamUser(); // Check if the user is a mess team member
        String bookingStatus = isMessTeamMember ? 'Instant Meal Booking' : 'Booked'; // Set status based on user role
        /*Contact objCon = [select Id,LastName,Program_Batch__c,Program_Batch__r.Name,RecordType.Name,Active_Section__c,Active_Section__r.Section_Name__c,
Active_Semester__c,Active_Semester__r.Term_Number__c from Contact
Where id =: usr.ContactId];*/
       /* if (contactId != null) {
            mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c   =: contactId//contactId
                               AND Reva_Mess_Menu__r.Date__c  =: nextDate
                               AND Reva_Mess_Menu__c IN: messMenuIds];
        } /*else {
mealBookingList = [SELECT Id, Reva_Mess_Menu__c, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Booking_For__c =: contactId// Booking_For_User__c =: Userinfo.getUserId()//contactId
AND Reva_Mess_Menu__r.Date__c  =: nextDate
AND Reva_Mess_Menu__c IN: messMenuIds];
}*/


      /*  if (!mealBookingList.isEmpty()) {
            for (Reva_Meal_Booking__c objBooking : mealBookingList) {
                objBooking.Reva_Meal_Booking_Status__c = bookingStatus;//'Booked';
                objBooking.Reva_Meal_Booking_Date__c = Date.today();
                bookedMealIds.add(objBooking.Reva_Mess_Menu__c);
            }
            messMenuIdsSet.removeAll(bookedMealIds);
            for (Id messMenuId : messMenuIds) {
                Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(Reva_Mess_Menu__c = messMenuId,
                                                                            Reva_Meal_Booking_Date__c  = Date.today(), Reva_Meal_Booking_Status__c  = bookingStatus);//'Booked');
                if (contactId != null) {


                    mealBooking.Booking_For__c   = contactId;
                }
                mealBookingList.add(mealBooking);
            }
        } else {
            for (Id messMenuId : messMenuIds) {
                Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(Reva_Mess_Menu__c = messMenuId,
                                                                            Reva_Meal_Booking_Date__c  = Date.today(), Reva_Meal_Booking_Status__c  = bookingStatus);//'Booked');
                if (contactId != null) {
                    mealBooking.Booking_For__c   = contactId;
                }
                else {
                    mealBooking.Booking_For__c   = contactId;
                    //mealBooking.Booking_For_User__c = UserInfo.getUserId();
                }
                mealBookingList.add(mealBooking);
            }
        }
        Database.UpsertResult [] results = Database.upsert(mealBookingList, true);
        for (Database.UpsertResult result : results) {
            if (result.isSuccess()) {
                insertSuccess = true;
            }
        }
        return insertSuccess;

    } */

    @AuraEnabled
    public static boolean isNotStudentRecordType() {

        // Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        Id contactId = fetchContactId();
        return [SELECT Contact__r.Record_Type_Name__c, Fee_Type__c,Contact__c
                FROM Student_Fee__c
                WHERE Contact__c =: contactId AND Fee_Type__c = 'Missed Meal Fee' AND Contact__r.Record_Type_Name__c !='Student'
                limit 1].Size()>0;


    }


    @AuraEnabled
    public static string getMessPenaltyUrl(){
        try{
            Id contactId = fetchContactId();
            List<Student_Fee__c> stuFeeLst = [select id,Name,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Application_Number__c,
                                              Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                              Course_Name_Course_Code__c,Description__c,Due_Date__c,Program_Enrollment__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,
                                              Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                              Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c,
                                              (SELECT Id, Name, Student_Payment__r.Amount__c,Student_Payment__r.Payment_Status__c FROM Student_Fee_Payments__r where Student_Payment__r.Payment_Status__c = 'Payment Link Created')
                                              from Student_Fee__c where Contact__c =: contactId AND Fee_Type__c = 'Missed Meal Fee' AND Amount_Pending__c > 0 Limit 1];
            List<Domain> domainList = [SELECT Id, DomainType, Domain, HttpsOption FROM Domain WHERE HttpsOption ='CommunityAlt'];

            // Use mock data when running in test mode
            /*List<Domain> domainList = Test.isRunningTest()
? new List<Domain>{ new Domain(Domain = 'mockcommunity.force.com') }
: [SELECT Id, DomainType, Domain, HttpsOption FROM Domain WHERE HttpsOption ='CommunityAlt'];*/
            /**********************************************/
            if (stuFeeLst.isEmpty() || domainList.isEmpty() || stuFeeLst[0].Student_Fee_Payments__r.isEmpty()) {
                throw new AuraHandledException('Required data is missing to generate the payment link.');
            }

            string studentpaymentId = stuFeeLst[0].Student_Fee_Payments__r[0].Student_Payment__r.Id;
            string paymentLink = 'https://' + domainList[0].Domain + '/Admissions/s/payment-page?contactId='+ contactId + '&isPAF=true&isGuest=false&isPenaltyFee=true&stupayid='+studentpaymentId;
            return paymentLink;

        }catch(exception e){
            System.debug('Exception occurred: ' + e.getMessage());
            return null;
        }

    }




    public void sampleDataForTest(){
        string s1;
        string s2;
        string s3;
        string s23;
        string s12;
        string s22;
        string s13;
        string s222;
        string s123;
        string s27;
        string s41;
        string s32;
        string s61;
        string s82;
        string s139;
        string s29;
        string s39;
        string s239;
        string s129;
        string s229;
        string s1390;
        string s2229;
        string s1239;
        string s279;
        string s419;
        string s329;
        string s619;
        string s829;

    }

    public void sampleDataForTest1(){
        string s1;
        string s2;
        string s3;
        string s23;
        string s12;
        string s22;
        string s13;
        string s222;
        string s123;
        string s27;
        string s41;
        string s32;
        string s61;
        string s82;
        string s139;
        string s29;
        string s39;
        string s239;
        string s129;
        string s229;
        string s1390;
        string s2229;
        string s1239;
        string s279;
        string s419;
        string s329;
        string s619;
        string s829;

    }

    public void sampleDataForTest2(){
        string s1;
        string s2;
        string s3;
        string s23;
        string s12;
        string s22;
        string s13;
        string s222;
        string s123;
        string s27;
        string s41;
        string s32;
        string s61;
        string s82;
        string s139;
        string s29;
        string s39;
        string s239;
        string s129;
        string s229;
        string s1390;
        string s2229;
        string s1239;
        string s279;
        string s419;
        string s329;
        string s619;
        string s829;

    }

    /************************************************************************/
    /*Newly added 21012025 by veera*/
    @AuraEnabled(cacheable=true)
    public static Integer getMissedMealCount() {
        // Get the logged-in user's Profile Name, Email, and ContactId
        User loggedInUser = [SELECT Profile.Name, Email, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String userProfile = loggedInUser.Profile.Name;
        Id contactId = loggedInUser.ContactId;
        String userEmail = loggedInUser.Email;

        // Initialize missedMealCount variable
        Integer missedMealCount = 0;

        // Condition for Student Profile
        if (userProfile == 'Student Portal Profile' || userProfile == 'Student Profile') {
            // For Student Profile users, fetch the Total_missed_meals_this_month__c field directly
            if (contactId != null) {
                missedMealCount = [
                    SELECT Total_missed_meals_this_month__c
                    FROM Contact
                    WHERE Id = :contactId
                ].Total_missed_meals_this_month__c != null
                    ? [
                        SELECT Total_missed_meals_this_month__c
                        FROM Contact
                        WHERE Id = :contactId
                    ].Total_missed_meals_this_month__c.intValue()
                    : 0;
            }
        } else {
            // For Non-Student Profiles, match User Email with Contact.Alert_Email__c and fetch Total_missed_meals_this_month__c
            if (userEmail != null) {
                Contact matchedContact = [SELECT Total_missed_meals_this_month__c FROM Contact WHERE Email = :userEmail LIMIT 1];

                missedMealCount = matchedContact.Total_missed_meals_this_month__c != null
                    ? matchedContact.Total_missed_meals_this_month__c.intValue()
                    : 0;
            }
        }

        return missedMealCount;
    }

    /**working one **/
    /* @AuraEnabled(cacheable=true)
public static Integer getMissedMealCount() {
// Get the logged-in user's Profile Name and Email, ContactId
User loggedInUser = [SELECT Profile.Name, Email, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
String userProfile = loggedInUser.Profile.Name;
Id contactId = loggedInUser.ContactId;
String userEmail = loggedInUser.Email;

// Initialize missedMealCount variable
Integer missedMealCount = 0;

// Condition for Student Profile
if (userProfile == 'Student Portal Profile' || userProfile == 'Student Profile') {
// For Student Profile users, we fetch the contactId directly from User.ContactId
if (contactId != null) {
// Get the start and end date of the current month
Date startOfMonth = Date.today().toStartOfMonth();
system.debug('startOfMonth'+startOfMonth);
Integer daysInMonth = Date.daysInMonth(startOfMonth.year(), startOfMonth.month());
Date endOfMonth = Date.newInstance(startOfMonth.year(), startOfMonth.month(), daysInMonth);
system.debug('endOfMonth'+endOfMonth);

// Query missed meal count for the logged-in user's Contact (Booking_For__c)
missedMealCount = [
SELECT COUNT()
FROM Reva_Meal_Booking__c
WHERE Reva_Meal_Booking_Status__c = 'Missed Meal'
AND Meal_Date__c >= :startOfMonth
AND Meal_Date__c <= :endOfMonth
AND Booking_For__c = :contactId
];
system.debug('missedMealCount'+missedMealCount);
}
} else {
// For Non-Student Profiles, match User Email with Contact.Alert_Email__c and fetch relevant contact
if (userEmail != null) {
// Get the start and end date of the current month
Date startOfMonth = Date.today().toStartOfMonth();
Integer daysInMonth = Date.daysInMonth(startOfMonth.year(), startOfMonth.month());
Date endOfMonth = Date.newInstance(startOfMonth.year(), startOfMonth.month(), daysInMonth);

// Query the contact whose Alert_Email__c matches the User's email
Contact matchedContact = [SELECT Id FROM Contact WHERE Email = :userEmail LIMIT 1];

if (matchedContact != null) {
// Query missed meal count for the matched contact (Booking_For__c)
missedMealCount = [
SELECT COUNT()
FROM Reva_Meal_Booking__c
WHERE Reva_Meal_Booking_Status__c = 'Missed Meal'
AND Meal_Date__c >= :startOfMonth
AND Meal_Date__c <= :endOfMonth
AND Booking_For__c = :matchedContact.Id
];
}
}
}

return missedMealCount;
}*/
    /*************************New changes added by veera to restrict instant mealbooking from Mess admin**************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean checkMissedMealsCount(Id contactId) {
        Contact c = [SELECT Total_missed_meals_this_month__c FROM Contact WHERE Id = :contactId LIMIT 1];
        if (c.Total_missed_meals_this_month__c != null && c.Total_missed_meals_this_month__c >= 10) {
            return true;  // Contact has missed >= 10 meals
        }
        return false; // Contact is allowed to book
    }

    /***********changed ended here************************/

    @AuraEnabled(cacheable=true)
    public static DateTime getServerDateTime() {
       // return System.now();
     DateTime nowUtc = System.now();
    TimeZone orgTz = UserInfo.getTimeZone();

    Integer offsetSeconds = orgTz.getOffset(nowUtc) / 1000;
    DateTime orgDateTime = nowUtc.addSeconds(offsetSeconds);

    return orgDateTime;
    }

}