public with sharing class RoomBookingController {
  //ClassRoom and Laboratiory Booking for Slot Wiese 
    // --------- Wrappers ----------
    public class FacilityWrapper {
        @AuraEnabled public Id facilityId;
        @AuraEnabled public String facilityName;
        @AuraEnabled public String roomNumber;
        @AuraEnabled public String schoolName;
        @AuraEnabled public String facilityType;
        @AuraEnabled public String block;
        @AuraEnabled public Integer capacity; 
    }

    public class BookedSlotDetails {
        @AuraEnabled public Id scheduleId;
        @AuraEnabled public String slotName;
        @AuraEnabled public Date bookingDate;
        @AuraEnabled public String courseOfferingName;
        @AuraEnabled public String slot;
        @AuraEnabled public String section;
        @AuraEnabled public String facilityName;
        @AuraEnabled public String schoolName;
        @AuraEnabled public String block;
        @AuraEnabled public String bookedBy;
        @AuraEnabled public Boolean canOverride;
    }

    public class SlotAvailabilityResult {
        @AuraEnabled public Boolean isAvailable;
        @AuraEnabled public String message;
        @AuraEnabled public List<BookedSlotDetails> bookedSlots;
        @AuraEnabled public Integer createdCount;
        @AuraEnabled public Map<String, Integer> facilityCapacities;
    }

    public class FacilitySlotWrapper {
        @AuraEnabled public Id facilityId;
        @AuraEnabled public String facilityName;
        @AuraEnabled public List<String> slots;
    }

     // --------- Helper: Get Org-Wide Email Address ----------
    private static Id getOrgWideEmailAddressId(String emailAddress) {
        List<OrgWideEmailAddress> owas = [
            SELECT Id, Address, DisplayName, IsAllowAllProfiles, IsVerified
            FROM OrgWideEmailAddress
            WHERE Address = :emailAddress
            LIMIT 1
        ];
        if (!owas.isEmpty()) {
            if (owas[0].IsVerified) {
                return owas[0].Id;
            } else {
                System.debug('⚠️ Org-Wide Email exists but is NOT verified: ' + emailAddress);
            }
        } else {
            System.debug('⚠️ Org-Wide Email not found: ' + emailAddress);
        }
        return null;
    }

    private static final String COMMON_SENDER = 'alerts@reva.edu.in';
    	
    // --------- Lookups ----------
    @AuraEnabled(cacheable=true)
    public static List<String> getBlocks() {
        List<String> blocks = new List<String>();
        for (AggregateResult ar : [
            SELECT Block__c b FROM hed__Facility__c
            WHERE Block__c != null
            GROUP BY Block__c
            ORDER BY Block__c
        ]) {
            blocks.add((String)ar.get('b'));
        }
        return blocks;
    }

    @AuraEnabled(cacheable=true)
    public static List<FacilityWrapper> getFacilitiesByBlock(String blockValue) {
        List<FacilityWrapper> results = new List<FacilityWrapper>();
        if (String.isBlank(blockValue)) return results;

        for (hed__Facility__c f : [
            SELECT Id, Name, Room__c, hed__Account__r.Name, hed__Facility_Type__c, Block__c,hed__Capacity__c
            FROM hed__Facility__c
            WHERE Block__c = :blockValue
            AND hed__Facility_Type__c IN ('Classroom','Laboratory')
            ORDER BY Name
        ]) {
            results.add(wrapFacility(f));
        }
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<FacilityWrapper> getBlockFacilityDetails(String blockValue) {
        return getFacilitiesByBlock(blockValue);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getFixedSlots() {
        return new List<String>{ '1','2','4','5','7','8','9' };
    }

    // --------- Get current User Department ----------
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserDepartment() {
        User currentUser = [
            SELECT Department FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1
        ];
        return String.isNotBlank(currentUser.Department) ? currentUser.Department : 'Unknown';
    }
    
   // --------- CHECK ROOM STATUS ----------
           @AuraEnabled
       public static SlotAvailabilityResult checkRoomStatus(
         List<Id> facilityIds,
         Date startDate,
         Date endDate,
         List<String> selectedSlots,
         String bookingReason,
         Boolean overrideBooking
           ) {
         SlotAvailabilityResult result = new SlotAvailabilityResult();
         result.bookedSlots = new List<BookedSlotDetails>();
         result.createdCount = 0;
         result.facilityCapacities = new Map<String, Integer>();
         result.isAvailable = true;
         result.message = 'Booking confirmed.';

      // ---- Validations ----
        if (facilityIds == null || facilityIds.isEmpty()
            || startDate == null || endDate == null
            || selectedSlots == null || selectedSlots.isEmpty()) {
           result.isAvailable = false;
           result.message = 'Missing required inputs (facilities, dates or slots).';
           return result;
         }
       if (String.isBlank(bookingReason)) {
           result.isAvailable = false;
           result.message = 'Booking Reason is required.';
           return result;
          }
       if (endDate < startDate) {
          result.isAvailable = false;
          result.message = 'End Date cannot be before Start Date.';
          return result;
          }

        // Profile override check
        String profileName = [
        SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()
         ].Name;
        Boolean canOverride = new Set<String>{'System Administrator','Placement Admin','Examination Section Profile'}.contains(profileName);

       // Collect dates
       Set<Date> dateSet = new Set<Date>();
       for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
           dateSet.add(d);
          }

        // Convert slots
         List<Decimal> slotNums = new List<Decimal>();
         for (String s : selectedSlots) {
          try { slotNums.add(Decimal.valueOf(s)); } catch (Exception e) {}
              }

          // Facility capacities
        for (hed__Facility__c f : [SELECT Id, Name, hed__Capacity__c FROM hed__Facility__c WHERE Id IN :facilityIds]) {
        result.facilityCapacities.put(f.Name, f.hed__Capacity__c != null ? Integer.valueOf(f.hed__Capacity__c) : 0);
        }   

        // Course Offering conflicts
       List<hed__Course_Offering_Schedule__c> courseConflicts = [
          SELECT Id, Date__c, Slot__c, hed__Facility__c,School__c,
               hed__Course_Offering__r.Name,
               Section__r.Name, School_Head__r.Name,
               hed__Facility__r.Name, hed__Facility__r.Block__c,
               Section__r.hed__Account__r.Parent.Name
               //hed__Course_Offering__r.Offered_By_School__r.Name
         FROM hed__Course_Offering_Schedule__c
         WHERE hed__Facility__c IN :facilityIds
          AND Date__c IN :dateSet
          AND Slot__c IN :slotNums
       ];

    Set<String> conflictKeys = new Set<String>();
    for (hed__Course_Offering_Schedule__c b : courseConflicts) {
        String keyVal = key(b.hed__Facility__c, b.Date__c, String.valueOf(b.Slot__c));
        if (!conflictKeys.contains(keyVal)) {
            conflictKeys.add(keyVal);
            BookedSlotDetails d = new BookedSlotDetails();
            d.scheduleId = b.Id;
            d.bookingDate = b.Date__c;
            d.slotName = String.valueOf(b.Slot__c);
            d.courseOfferingName = (b.hed__Course_Offering__r != null) ? b.hed__Course_Offering__r.Name : null;
            d.section = (b.Section__r != null) ? b.Section__r.Name : null;
            d.facilityName = (b.hed__Facility__r != null) ? b.hed__Facility__r.Name : null;
            d.block = (b.hed__Facility__r != null) ? b.hed__Facility__r.Block__c : null;
            d.bookedBy = (b.School_Head__r != null) ? b.School_Head__r.Name : 'Unknown';
            d.canOverride = canOverride;
            d.schoolName = b.School__c;
            result.bookedSlots.add(d);
        }
    }

    // Facility Booking conflicts
    List<Facility_Booking__c> fbConflicts = [
        SELECT Id, Start_Date__c, End_Date__c, Slot__c, Department__c,
               Facility_name__r.Name, Facility_name__r.Block__c, Booked_By__r.Name
        FROM Facility_Booking__c
        WHERE Facility_name__c IN :facilityIds
          AND (Start_Date__c <= :endDate AND End_Date__c >= :startDate)
    ];
    for (Facility_Booking__c b : fbConflicts) {
        for (String slot : selectedSlots) {
            if (b.Slot__c != null && b.Slot__c.contains(slot)) {
                String keyVal = key(b.Facility_name__c, b.Start_Date__c, slot);
                if (!conflictKeys.contains(keyVal)) {
                    conflictKeys.add(keyVal);
                    BookedSlotDetails d = new BookedSlotDetails();
                    d.bookingDate = b.Start_Date__c;
                    d.slotName = slot;
                    d.schoolName = b.Department__c;
                    d.facilityName = b.Facility_name__r.Name;
                    d.block = b.Facility_name__r.Block__c;
                    d.bookedBy = (b.Booked_By__r != null) ? b.Booked_By__r.Name : null;
                    d.canOverride = false;
                    result.bookedSlots.add(d);
                }
            }
        }
    }

       // Final decision
     if (!conflictKeys.isEmpty() && !overrideBooking) {	
         result.isAvailable = false;
         result.message = canOverride
            ? 'Some slots are already booked. Review and click Override to proceed.'
            : 'These slots are already booked. Please check other facilities.';
          }
         else {
          result.isAvailable = true;
          result.message = 'Booking confirmed.';}

          return result;
         }

     // --------- SAVE & NOTIFY ----------
     @AuraEnabled
    public static SlotAvailabilityResult saveBookingAndCheck(
         List<Id> facilityIds,
         Date startDate,
         Date endDate,    
         List<String> selectedSlots,
         String bookingReason,
         Boolean overrideBooking
     ) {
     //  Check status
      SlotAvailabilityResult result = checkRoomStatus(facilityIds, startDate, endDate, selectedSlots, bookingReason, overrideBooking);

      // If not available and not override → just return
      if (!result.isAvailable && !overrideBooking) {
         return result;
       }

     // If override → update course offering + send emails (batched)
     if (overrideBooking && !result.bookedSlots.isEmpty()) {
        List<hed__Course_Offering_Schedule__c> conflicts = [
            SELECT Id, Date__c, Slot__c, hed__Facility__c, hed__Facility__r.Name,
                   hed__Course_Offering__r.Name, Section__r.Name,
                   Section__r.hed__Account__r.Parent.Vertical_Head__r.Email,
                   Section__r.hed__Account__r.Parent.School_Head__r.Email
            FROM hed__Course_Offering_Schedule__c
            WHERE hed__Facility__c IN :facilityIds
            AND Date__c >= :startDate AND Date__c <= :endDate
        ];
        if (!conflicts.isEmpty()) {
            removeFacilityFromCourseOffering(conflicts);
            for (hed__Course_Offering_Schedule__c b : conflicts) {
                b.Room_Change_Request__c = 'Pending';
            }
            update conflicts;
            sendBatchedOverrideEmails(conflicts);
        }
    }

    // INSERT INTO FACILITY_BOOKING
    User currentUser = [
        SELECT Id, Department, Email, Name FROM User WHERE Id = :UserInfo.getUserId()
    ];

    Set<Date> dateSet = new Set<Date>();
    for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
        dateSet.add(d);
    }

    List<Facility_Booking__c> fbList = new List<Facility_Booking__c>();
    for (Id fid : facilityIds) {
        for (Date d : dateSet) {
            Facility_Booking__c fb = new Facility_Booking__c();
            fb.Start_Date__c = d;
            fb.End_Date__c   = d;
            fb.Facility_name__c = fid;
            fb.Slot__c = String.join(selectedSlots, ',');
            fb.Reason__c = bookingReason;
            fb.Department__c = currentUser.Department;
            fb.Booked_By__c  = currentUser.Id;
            fbList.add(fb);
        }
    }
    if (!fbList.isEmpty()) {
        insert fbList;
        result.createdCount = fbList.size();
    }

    // Notify School Head if no conflicts
    if (result.isAvailable && result.bookedSlots.isEmpty()) {
        sendSingleSchoolHeadEmail(facilityIds, currentUser, startDate, endDate, selectedSlots, bookingReason);
    }

    // Always send email to Booker
    sendBookerConfirmationEmail(facilityIds, currentUser, startDate, endDate, selectedSlots, bookingReason);

    return result;
 }

     // --------- Helpers ----------
    private static void removeFacilityFromCourseOffering(List<hed__Course_Offering_Schedule__c> conflicts) {
       if (conflicts == null || conflicts.isEmpty()) return;
       for (hed__Course_Offering_Schedule__c c : conflicts) {
           c.hed__Facility__c = null;
       }
        update conflicts;
     }

     private static String key(Id facilityId, Date d, String slot) {
        return String.valueOf(facilityId) + '|' + String.valueOf(d) + '|' + slot;
        }

       // --------- BATCHED OVERRIDE EMAILS ----------
   private static void sendBatchedOverrideEmails(List<hed__Course_Offering_Schedule__c> conflicts) {
      if (conflicts.isEmpty()) return;
      
        User currentUser = [
         SELECT Name, Department FROM User WHERE Id = :UserInfo.getUserId()
        ];

      String bookedByName = currentUser.Name;
      String department = currentUser.Department != null ? currentUser.Department : 'Unknown';
      String baseUrl = System.URL.getOrgDomainUrl().toExternalForm();

       // Group conflicts by recipient email
       Map<String, List<hed__Course_Offering_Schedule__c>> groupedByEmail = new Map<String, List<hed__Course_Offering_Schedule__c>>();
       for (hed__Course_Offering_Schedule__c b : conflicts) {
          List<String> recipients = new List<String>();
          if (b.Section__r.hed__Account__r.Parent.Vertical_Head__r.Email != null)
              recipients.add(b.Section__r.hed__Account__r.Parent.Vertical_Head__r.Email);
          if (b.Section__r.hed__Account__r.Parent.School_Head__r.Email != null)
             recipients.add(b.Section__r.hed__Account__r.Parent.School_Head__r.Email);

          for (String email : recipients) {
            if (!groupedByEmail.containsKey(email)) groupedByEmail.put(email, new List<hed__Course_Offering_Schedule__c>());
            groupedByEmail.get(email).add(b);
         }
       }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (String email : groupedByEmail.keySet()) {
        List<hed__Course_Offering_Schedule__c> recConflicts = groupedByEmail.get(email);

        String body = 'Dear Sir/Madam,<br/><br/>' +
            'The following course sessions have been affected, as the allocated rooms have been booked by <b>' + bookedByName + '</b> from the <b>' + department + '</b> department for placement/examination work.<br/><br/>' +
    'Kindly review the affected sessions and select suitable alternate room facilities using the provided links to ensure continuity of the scheduled sessions.<br/><br/>' +
            '<table border="1" cellpadding="5" cellspacing="0">' +
            '<tr><th>Course</th><th>Date</th><th>Slot</th><th>Current Venue</th><th>Alternate Facility Link</th></tr>';

        for (hed__Course_Offering_Schedule__c b : recConflicts) {
            String appPageUrl = baseUrl + '/lightning/n/alternateRoomSelector?c__scheduleId=' + b.Id;
            body += '<tr>' +
                    '<td>' + b.hed__Course_Offering__r.Name + '</td>' +
                    '<td>' + b.Date__c.format() + '</td>' +
                    '<td>' + b.Slot__c + '</td>' +
                    '<td>' + (b.hed__Facility__r != null ? b.hed__Facility__r.Name : '-') + '</td>' +
                    '<td><a href="' + appPageUrl + '">Select Facility</a></td>' +
                    '</tr>';
        }

        body += '</table><br/><br/>' +
                'Thank you for your cooperation.<br/><br/>REVA University';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ email });
        mail.setSubject('Room Override - Multiple Sessions Affected');
        mail.setHtmlBody(body);

        Id owaId = getOrgWideEmailAddressId(COMMON_SENDER);
        if (owaId != null) mail.setOrgWideEmailAddressId(owaId);

        emails.add(mail);
      }

      if (!emails.isEmpty()) {
          Messaging.sendEmail(emails);
       }
   }

    // --------- SINGLE SCHOOL HEAD EMAIL ----------
   private static void sendSingleSchoolHeadEmail(List<Id> facilityIds, User currentUser, Date startDate, Date endDate, List<String> selectedSlots, String bookingReason) {
      Map<String, List<hed__Facility__c>> groupedByHead = new Map<String, List<hed__Facility__c>>();
      List<hed__Facility__c> facList = [
         SELECT Id, Name, Room__c, Floor__c, Block__c,
               hed__Account__r.School_Head__r.Name,
               hed__Account__r.School_Head__r.Email
         FROM hed__Facility__c
         WHERE Id IN :facilityIds AND hed__Account__r.School_Head__r.Email != null
         ];

    for (hed__Facility__c f : facList) {
        String email = f.hed__Account__r.School_Head__r.Email;
        if (!groupedByHead.containsKey(email)) groupedByHead.put(email, new List<hed__Facility__c>());
        groupedByHead.get(email).add(f);
    }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (String email : groupedByHead.keySet()) {
        List<hed__Facility__c> rooms = groupedByHead.get(email);

        String body = 'Dear ' + rooms[0].hed__Account__r.School_Head__r.Name + ',<br/><br/>' +
            'The following classrooms/labs have been allocated for <b>' + currentUser.Name + '</b> ' +
            '(Department: <b>' + (String.isNotBlank(currentUser.Department) ? currentUser.Department : 'Unknown') + '</b>):<br/><br/>' +
            '<table border="1" cellpadding="5" cellspacing="0">' +
            '<tr><th>Venue</th><th>Room No</th><th>Floor</th><th>Block</th></tr>';

        for (hed__Facility__c fac : rooms) {
            body += '<tr>' +
                    '<td>' + fac.Name + '</td>' +
                    '<td>' + fac.Room__c + '</td>' +
                    '<td>' + fac.Floor__c + '</td>' +
                    '<td>' + fac.Block__c + '</td>' +
                    '</tr>';
        }

        body += '</table><br/>' +
                'Date: ' + String.valueOf(startDate) + ' to ' + String.valueOf(endDate) + '<br/>' +
                'Slots: ' + String.join(selectedSlots, ', ') + '<br/>' +
                'Reason: ' + bookingReason + '<br/><br/>REVA University';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ email });
        mail.setSubject('Classroom/Lab Allocation Confirmation');
        mail.setHtmlBody(body);

        Id owaId = getOrgWideEmailAddressId(COMMON_SENDER);
        if (owaId != null) mail.setOrgWideEmailAddressId(owaId);

        emails.add(mail);
    }

    if (!emails.isEmpty()) Messaging.sendEmail(emails);
  }

   // --------- BOOKER EMAIL ----------
   private static void sendBookerConfirmationEmail(List<Id> facilityIds, User currentUser, Date startDate, Date endDate, List<String> selectedSlots, String bookingReason) {
      if (String.isBlank(currentUser.Email)) return;

        List<hed__Facility__c> facilities = [
           SELECT Id, Name, Room__c, Floor__c, Block__c 
           FROM hed__Facility__c 
           WHERE Id IN :facilityIds
           ];

      String dateInfo = (startDate == endDate)
          ? 'Date: ' + String.valueOf(startDate)
          : 'Date: From ' + String.valueOf(startDate) + ' To ' + String.valueOf(endDate);

      String facilityInfo = '';
        for (hed__Facility__c f : facilities) {
            facilityInfo += '<br/>• ' + f.Name +
                        ' (Room: ' + f.Room__c +
                        ', Floor: ' + f.Floor__c +
                        ', Block: ' + f.Block__c + ')';
           }

      String body = 'Dear ' + currentUser.Name + ',<br/><br/>' +
                  'Your booking request has been Confirmed.<br/><br/>' +
                  '<b>' + dateInfo + '</b><br/>' +
                  'Slots Booked: ' + String.join(selectedSlots, ', ') + '<br/>' +
                  'Venues Booked: ' + facilityInfo + '<br/><br/>' +
                  'Reason: ' + bookingReason + '<br/><br/>REVA University';

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new List<String>{ currentUser.Email });
    mail.setSubject('Room Booking Confirmation');
    mail.setHtmlBody(body);

    Id owaId = getOrgWideEmailAddressId(COMMON_SENDER);
    if (owaId != null) mail.setOrgWideEmailAddressId(owaId);

    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
   }

    // --------- Alternate Facilities ----------
    @AuraEnabled(cacheable=true)
    public static List<FacilityWrapper> getAlternateFacilitiesSameSchool(Date bookingDate, Decimal slot, String schoolName) {
        List<FacilityWrapper> results = new List<FacilityWrapper>();
        for (hed__Facility__c f : [
            SELECT Id, Name, Room__c, hed__Account__r.Name, hed__Facility_Type__c, Block__c,hed__Capacity__c
            FROM hed__Facility__c
            WHERE hed__Account__r.Name = :schoolName
              AND hed__Facility_Type__c IN ('Classroom','Laboratory')
              AND Id NOT IN (
                  SELECT hed__Facility__c 
                  FROM hed__Course_Offering_Schedule__c
                  WHERE Date__c = :bookingDate 
                  AND Slot__c = :slot
              )
            ORDER BY Name
        ]) {
            results.add(wrapFacility(f));
        }
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getOtherSchools(String excludeSchool) {
        List<String> schools = new List<String>();
        for (AggregateResult ar : [
            SELECT hed__Account__r.Name s 
            FROM hed__Facility__c 
            WHERE hed__Account__r.Name != null 
              AND hed__Account__r.Name != :excludeSchool
            GROUP BY hed__Account__r.Name
            ORDER BY hed__Account__r.Name
        ]) {
            schools.add((String)ar.get('s'));
        }
        return schools;
    }
    
      @AuraEnabled(cacheable=true)
   public static List<hed__Course_Offering_Schedule__c> getPendingRoomChangeRequests() {
      String userDept = [
         SELECT Department FROM User WHERE Id = :UserInfo.getUserId()
       ].Department;

     List<hed__Course_Offering_Schedule__c> allRequests = [
         SELECT Id, Date__c, Slot__c, School__c,
               hed__Course_Offering__r.Name,
               Section__r.Name,
               Batch_Group__r.Name,
               Room_Change_Request__c
         FROM hed__Course_Offering_Schedule__c
         WHERE Room_Change_Request__c = 'Pending'
              AND Date__c >= :Date.today()
              AND School__c = :userDept 
         ORDER BY Date__c ASC
         ];

    // remove duplicates safely
    Map<String, hed__Course_Offering_Schedule__c> uniqueRequests = new Map<String, hed__Course_Offering_Schedule__c>();

    for (hed__Course_Offering_Schedule__c req : allRequests) {
        String sectionName = req.Section__r != null ? req.Section__r.Name : '';
        String courseName  = req.hed__Course_Offering__r != null ? req.hed__Course_Offering__r.Name : '';
        String key = req.Date__c.format() + '-' + req.Slot__c + '-' + sectionName + '-' + courseName;

        if (!uniqueRequests.containsKey(key)) {
            uniqueRequests.put(key, req);
        }
    }

    return uniqueRequests.values();
    }

      // -- COMPLETED REQUESTS --
    @AuraEnabled(cacheable=true)
  public static List<hed__Course_Offering_Schedule__c> getCompletedRoomChangeRequests(Date startDate, Date endDate) {
    String userDept = [SELECT Department FROM User WHERE Id = :UserInfo.getUserId()].Department;
    return [
        SELECT Id, Date__c, Slot__c, School__c,
               hed__Course_Offering__r.Name,
               Section__r.Name,Batch_Group__r.Name,
               Room_Change_Request__c
        FROM hed__Course_Offering_Schedule__c
        WHERE Room_Change_Request__c = 'Completed'
          AND Date__c >= :startDate AND hed__Course_Offering__c != null AND Section__c != null
          AND Batch_Group__c != null
          AND Date__c <= :endDate
          AND School__c = :userDept 
        ORDER BY Date__c DESC
     ];
    }

    @AuraEnabled(cacheable=true)
    public static List<FacilityWrapper> getAlternateFacilitiesOtherSchool(Date bookingDate, Decimal slot, String schoolName) {
        List<FacilityWrapper> results = new List<FacilityWrapper>();
        for (hed__Facility__c f : [
            SELECT Id, Name, Room__c, hed__Account__r.Name, hed__Facility_Type__c, Block__c,hed__Capacity__c
            FROM hed__Facility__c
            WHERE hed__Account__r.Name = :schoolName
              AND hed__Facility_Type__c IN ('Classroom','Laboratory')
              AND Id NOT IN (
                  SELECT hed__Facility__c 
                  FROM hed__Course_Offering_Schedule__c
                  WHERE Date__c = :bookingDate 
                  AND Slot__c = :slot
              )
            ORDER BY Name
        ]) {
            results.add(wrapFacility(f));
        }
        return results;
    }

    @AuraEnabled
    public static String confirmAlternateBooking(Id scheduleId, Id newFacilityId) {
        if (scheduleId == null || newFacilityId == null) {
            return ' Missing schedule or facility information.';	
        }
       // 1. Update Schedule with new Facility
   List<hed__Course_Offering_Schedule__c> schedList = [
    SELECT Id, hed__Course_Offering__c, Section__c, Date__c, Batch_Group__r.id,
           hed__Course_Offering__r.Name, hed__Start_Time__c, hed__End_Time__c,
           Section__r.Name, Slot__c, Room_Change_Request__c,
           Section__r.hed__Account__r.Parent.Name,
           Section__r.hed__Account__r.Parent.Vertical_Head__r.Id,
           Section__r.hed__Account__r.Parent.Vertical_Head__r.Name,
           Section__r.hed__Account__r.Parent.Vertical_Head__r.Email,
           Section__r.hed__Account__r.Parent.Vertical_Head__r.Department
           FROM hed__Course_Offering_Schedule__c 
           WHERE Id = :scheduleId 
           LIMIT 1];
        if (schedList.isEmpty()) {
          return ' No schedule found for Id ' + scheduleId;
         }
        
       hed__Course_Offering_Schedule__c sched = schedList[0];

        //Find all pending requests with same Date, Slot, and Section
    List<hed__Course_Offering_Schedule__c> relatedPending = [
        SELECT Id, hed__Facility__c, Room_Change_Request__c
        FROM hed__Course_Offering_Schedule__c
        WHERE Date__c = :sched.Date__c
          AND Slot__c = :sched.Slot__c
          AND Section__c = :sched.Section__c
          AND Room_Change_Request__c = 'Pending'
    ];

    // Update all matching records
    for (hed__Course_Offering_Schedule__c r : relatedPending) {
        r.hed__Facility__c = newFacilityId;
        r.Room_Change_Request__c = 'Completed';
    }
    if (!relatedPending.isEmpty()) {
        update relatedPending;
        System.debug(' Updated ' + relatedPending.size() + ' related pending requests.');
    }else {
       sched.hed__Facility__c = newFacilityId;
       sched.Room_Change_Request__c = 'Completed';    
       update sched;
        System.debug(' Updated single schedule record as no related pending requests found.');
    }
      /*  sched = [
        SELECT Id, Date__c, Slot__c, hed__Start_Time__c, hed__End_Time__c,
               hed__Course_Offering__r.Name, Section__r.Name, 
               Section__c, Batch_Group__r.Id,
               hed__Facility__r.Name, hed__Facility__r.Block__c,
               hed__Facility__r.Floor__c, hed__Facility__r.Room__c,
               hed__Facility__r.hed__Account__r.Name
        FROM hed__Course_Offering_Schedule__c
        WHERE Id = :sched.Id
        LIMIT 1
    ];*/
    // 2. Fetch Facility Details
   List<hed__Facility__c> facList = [
    SELECT Id, Name, Room__c, Block__c, Floor__c, hed__Account__r.Name,hed__Capacity__c,
           hed__Account__r.School_Head__r.Email, hed__Account__r.School_Head__r.Name
    FROM hed__Facility__c
    WHERE Id = :newFacilityId
    LIMIT 1
        ];
      if (facList.isEmpty()) {
         return ' No facility found for Id ' + newFacilityId;  }
           hed__Facility__c fac = facList[0];

    // 3. Find enrolled students in same CourseOffering + Section
    List<hed__Course_Enrollment__c> enrollments = [
        SELECT Id, hed__Contact__r.hed__WorkEmail__c,hed__Contact__r.Email,hed__Contact__r.Name
        FROM hed__Course_Enrollment__c
        WHERE Course_Offering_ID_Formula__c = :sched.hed__Course_Offering__r.id
          AND Section__c = :sched.Batch_Group__r.id
          AND (hed__Contact__r.hed__WorkEmail__c != null OR hed__Contact__r.Email != null)
    ];

    if (!enrollments.isEmpty()) {
        List<String> emails = new List<String>();
        for (hed__Course_Enrollment__c e : enrollments) {
            emails.add(e.hed__Contact__r.hed__WorkEmail__c);
            System.debug('📧 Student: ' + e.hed__Contact__r.Name + ' → Email: ' + e.hed__Contact__r.hed__WorkEmail__c);
        }
        // Format date
          String formattedDate = (sched.Date__c != null) ? sched.Date__c.format() : 'N/A';

          // Format slot timing
         String slotDuration = (sched.hed__Start_Time__c != null && sched.hed__End_Time__c != null)
           ? formatTime(sched.hed__Start_Time__c) + ' - ' + formatTime(sched.hed__End_Time__c)
            : 'N/A';

           // 4. Send Email Students,Faciuity
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emails);
        mail.setSubject('Classroom Changed - ' + sched.hed__Course_Offering__r.Name);

        String body = 'Dear Students,<br/><br/>' +
            'Please note your classroom has been changed.<br/><br/>' +
            '<b>New Venue:</b> ' + fac.Name + '<br/>' +
            '<b>Room No:</b> ' + fac.Room__c + '<br/>' +
            '<b>Floor:</b> ' + fac.Floor__c + '<br/>' +
            '<b>Block:</b> ' + fac.Block__c + '<br/>' +
            '<b>Batch Group:</b> ' + sched.Section__r.Name + '<br/>' +
            '<b>Date: </b> ' + formattedDate + '<br/>' +
            '<b>Time:</b> ' + slotDuration + '<br/>' +
            '<b>Course Offering:</b> ' + sched.hed__Course_Offering__r.Name + '<br/>' +
            '<b>School:</b> ' + fac.hed__Account__r.Name + '<br/><br/>' +
            'Thank you.';

        mail.setHtmlBody(body);
        
       Id owaId = getOrgWideEmailAddressId(COMMON_SENDER);
            if (owaId != null) {
            mail.setOrgWideEmailAddressId(owaId);
            }
        
        System.debug('📨 Sending email to: ' + String.join(emails, ', '));
        System.debug('📩 Email Body → ' + body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        System.debug('✅ Email sent successfully.');
    }
        else {
        System.debug('⚠️ No enrolled students with emails found for this course offering + section.');
    }
        
        
   // ---------- School Head Email ----------
   if (fac.hed__Account__r.School_Head__r.Email != null) {
       Messaging.SingleEmailMessage headMail = new Messaging.SingleEmailMessage();
       headMail.setToAddresses(new List<String>{fac.hed__Account__r.School_Head__r.Email});
       headMail.setSubject('Classroom Allocation for Course : ' + sched.hed__Course_Offering__r.Name);

     String verticalHeadName = (sched.Section__r.hed__Account__r.Parent.Vertical_Head__r != null)
        ?sched.Section__r.hed__Account__r.Parent.Vertical_Head__r.Name : 'Vertical Head';
    String verticalHeadDept = (sched.Section__r.hed__Account__r.Parent.Vertical_Head__r !=null
         && sched.Section__r.hed__Account__r.Parent.Vertical_Head__r.Department !=null)
        ? sched.Section__r.hed__Account__r.Parent.Vertical_Head__r.Department : 'Department';

    // Slot timing (Time fields cannot use .format())
   String slotDuration = (sched.hed__Start_Time__c != null && sched.hed__End_Time__c != null)
    ? formatTime(sched.hed__Start_Time__c) + ' - ' + formatTime(sched.hed__End_Time__c)
    : 'N/A';

    
    String headBody = 'Dear ' + fac.hed__Account__r.School_Head__r.Name + ',<br/><br/>' +
        'A classroom has been assigned to <b>' + verticalHeadName + '</b> from <b>' + verticalHeadDept + '</b>.<br/><br/>' +
        '• <b>Venue:</b> ' + fac.Name + '<br/>' +
        '• <b>Room No:</b> ' + fac.Room__c + '<br/>' +
        '• <b>Floor:</b> ' + fac.Floor__c + '<br/>' +
        '• <b>Block:</b> ' + fac.Block__c + '<br/>' +
        '• <b>Date:</b> ' + sched.Date__c.format() + '<br/>' +
        '• <b>Slot:</b> ' + sched.Slot__c + ' – Duration: ' + slotDuration + '<br/>' +
        '• <b>Course Offering:</b> ' + sched.hed__Course_Offering__r.Name + '<br/>' +
        '• <b>Section:</b> ' + sched.Section__r.Name + '<br/>' +
        '• <b>Requesting School:</b> ' + sched.Section__r.hed__Account__r.Parent.Name + '<br/><br/>' +
        'Thank you for your support and cooperation.<br/><br/>' +
        'Thank you<br/>' +
        'REVA University';

      headMail.setHtmlBody(headBody);
     Id owaId = getOrgWideEmailAddressId(COMMON_SENDER);
            if (owaId != null) {
            headMail.setOrgWideEmailAddressId(owaId);
            }

    System.debug('📨 Sending email to School Head: ' + fac.hed__Account__r.School_Head__r.Email);
    System.debug('📩 Head Email Body → ' + headBody);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{headMail});
    } else {
      System.debug('⚠️ No School Head email found for facility account.');
   }

     return '✅ Alternate facility updated & notification sent to students.';

      }
    @AuraEnabled(cacheable=true)
   public static Map<String, String> getScheduleDetails(Id scheduleId) {
       List<hed__Course_Offering_Schedule__c> cosList = [
       SELECT Id, Name, Date__c, Slot__c, School__c,
             hed__Course_Offering__r.Name,
             Room_Change_Request__c,
             Section__r.Name
       FROM hed__Course_Offering_Schedule__c
       WHERE Id = :scheduleId
       LIMIT 1
        ];
      if (cosList.isEmpty()) {
      return new Map<String, String>{ 'error' => '❌ No schedule found for Id ' + scheduleId };
    }
      hed__Course_Offering_Schedule__c cos = cosList[0];

       Map<String, String> result = new Map<String, String>();
       result.put('courseOfferingName', cos.hed__Course_Offering__r.Name);
       result.put('sectionName', String.valueOf(cos.Section__r.Name));
       result.put('scheduleName', cos.Name);
       result.put('date', String.valueOf(cos.Date__c));
       result.put('slot', String.valueOf(cos.Slot__c));
       result.put('roomChangeStatus', String.valueOf(cos.Room_Change_Request__c));
       result.put('school', String.valueOf(cos.School__c));
       return result;
       }	
       public static String formatTime(Time t) {
         if (t == null) return 'N/A';
         Integer hour = t.hour();
         Integer minute = t.minute();
         String amPm = (hour >= 12) ? 'PM' : 'AM';
         Integer displayHour = (hour == 0) ? 12 : (hour > 12 ? hour - 12 : hour);

        // Pad minutes with leading zero if needed
         String minuteStr = (minute < 10) ? '0' + String.valueOf(minute) : String.valueOf(minute);

         return displayHour + ':' + minuteStr + ' ' + amPm;
     }

     // --------- Helper ----------
     private static FacilityWrapper wrapFacility(hed__Facility__c f) {
         FacilityWrapper w = new FacilityWrapper();
         w.facilityId   = f.Id;	
         w.facilityName = f.Name;
         w.roomNumber   = f.Room__c;
         w.schoolName   = (f.hed__Account__r == null) ? null : f.hed__Account__r.Name;
         w.facilityType = f.hed__Facility_Type__c;
         w.block        = f.Block__c;
         // w.capacity = f.hed__Capacity__c;
         //w.capacity     = (f.hed__Capacity__c != null) ? Integer.valueOf(f.hed__Capacity__c) : 0; 
          try {
          w.capacity = (f.get('hed__Capacity__c') != null)
             ? Integer.valueOf((Decimal)f.get('hed__Capacity__c'))
             : 0;
             } catch (Exception e) {
             w.capacity = 0;
             }	
            return w;
         }
}