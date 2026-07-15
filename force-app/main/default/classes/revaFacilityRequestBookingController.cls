public without sharing class revaFacilityRequestBookingController {
    
    @AuraEnabled
    public static List<String> getFaciltyRequestFields() {
        List<String> fieldNames = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Facility_Request__c.fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        return fieldNames;
    }
    

    @AuraEnabled
    public static List<Facility_Request__c> getAllTimeSlots() {
        List<Facility_Request__c> allTimeSlots = [SELECT Id, End_Time__c, Start_Time__c FROM Facility_Request__c WHERE Start_Date__c >= TODAY];
        return allTimeSlots;        
    }
    
    @AuraEnabled
    public static List<hed__Facility__c> getEventFacilities() {
        List<hed__Facility__c> facilityData = [SELECT Id, hed__Facility_Type__c FROM hed__Facility__c WHERE hed__Facility_Type__c IN ('Event venues')];
        return facilityData;       
    }
    
    @AuraEnabled
   // public static List<hed__Facility__c> getLabFacilities(Id accountId) {
     public static List<hed__Facility__c> getLabFacilities() {

        List<hed__Facility__c> facilityData = [SELECT Id, hed__Facility_Type__c FROM hed__Facility__c WHERE hed__Facility_Type__c='Event Venues'];
        return facilityData;       
    } 
    
    @AuraEnabled
    public static List<Amenities__c> getAminities(Id facilityId, String Block, String Floor, String Room) {
       List<Amenities__c> aminityData = [SELECT Id, Block__c, Floor__c, Room__c, Item_Name__c FROM Amenities__c WHERE Block__c = :Block AND Floor__c = :Floor AND Room__c = :Room];
       return aminityData;       
    }

 
    
  // N.1 Get All Buildings
    @AuraEnabled(cacheable=true)
    public static List<String> getAllBuildings() {
        List<String> buildings = new List<String>();

        List<AggregateResult> results = [
            SELECT Block__c block
            FROM hed__Facility__c
            WHERE hed__Facility_Type__c='Event Venues' AND  Block__c != NULL
            GROUP BY Block__c
            ORDER BY Block__c
        ];

        for (AggregateResult ar : results) {
            buildings.add((String) ar.get('block'));
        }
        return buildings;
    }

    // N.2 Get All Floors under selected Building
    @AuraEnabled(cacheable=true)
    public static List<String> getFloorsByBuilding(String buildingName) {
        List<String> floors = new List<String>();

        List<AggregateResult> results = [
            SELECT Floor__c floor
            FROM hed__Facility__c
            WHERE hed__Facility_Type__c='Event Venues' AND Block__c = :buildingName
            AND Floor__c != NULL
            GROUP BY Floor__c
            ORDER BY Floor__c
        ];

        for (AggregateResult ar : results) {
            floors.add((String) ar.get('floor'));
        }
        return floors;
    }

    // N.3 Get Rooms under selected Building + Floor
    @AuraEnabled(cacheable=true)
    public static List<String> getRoomsByFloor(String buildingName, String floorNumber) {
        List<String> rooms = new List<String>();

        for (hed__Facility__c f : [
            SELECT Room__c 
            FROM hed__Facility__c
            WHERE hed__Facility_Type__c='Event Venues' AND Block__c = :buildingName
            AND Floor__c = :floorNumber
            ORDER BY Room__c
        ]) {
            rooms.add(f.Room__c);
        }

        return rooms;
    }
  
     @AuraEnabled(cacheable=true)
    public static List<hed__Facility__c> getAllFacilities(
        String facilityType,
        String buildingName,
        String floorNumber,
        String facilityName
    ) {
        String query =
            'SELECT Id, Name, Block__c, Floor__c, Room__c,' +
            ' hed__Facility_Type__c, hed__Capacity__c' +
            ' FROM hed__Facility__c WHERE Id != NULL';

        if (!String.isBlank(facilityType))
            query += ' AND hed__Facility_Type__c = \'' + String.escapeSingleQuotes(facilityType) + '\'';

        if (!String.isBlank(buildingName))
            query += ' AND Block__c = \'' + String.escapeSingleQuotes(buildingName) + '\'';

        if (!String.isBlank(floorNumber))
            query += ' AND Floor__c = \'' + String.escapeSingleQuotes(floorNumber) + '\'';

        if (!String.isBlank(facilityName))
            query += ' AND Room__c = \'' + String.escapeSingleQuotes(facilityName) + '\'';

        query += ' ORDER BY Block__c, Floor__c, Room__c';

        System.debug('### Final Query: ' + query);
        return Database.query(query);
    }



    @AuraEnabled
    public static Map<String, Object> validateAndSaveFacility(String selectedFields) {
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [ SELECT Id,Name FROM User WHERE Id = :UserInfo.getUserId() ];
        System.debug('INPUT JSON: ' + selectedFields);

        try {
            FacilityRequestWrapper data = (FacilityRequestWrapper)
                JSON.deserialize(selectedFields, FacilityRequestWrapper.class);

            if (data.startDate == null || data.endDate == null) {
                return errorResponse('Select Start Date and End Date');
            }
            if (String.isBlank(data.startTime) || String.isBlank(data.endTime)) {
                return errorResponse('Select Start Time and End Time');
            }
            if (String.isBlank(data.facilityReason) || data.facilityReason == null) {
                return errorResponse('Select Facility Reason');
            }
            if (data.attendeesNumber < 0) {
                return errorResponse('Enter Attendees Number'); 
            }  
            
            Time startTime = convertToTime(data.startTime);
            Time endTime   = convertToTime(data.endTime);

            Datetime newStartDT = Datetime.newInstance(data.startDate, startTime);
            Datetime newEndDT   = Datetime.newInstance(data.endDate, endTime);

           // Duplicate Check (Correct Overlap Logic) 
       /*    List<Facility_Request__c> userExisting = [
            SELECT Id, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c,
                   RequesterName__c, Reqester_Phone_Number__c
              FROM Facility_Request__c
              WHERE Facility_Type__c = :data.facilityType
              AND Building_Name__c = :data.buildingName
              AND Floor__c = :data.floorNumber
              AND Room_No__c = :data.roomNumber
              AND TemplateName__c != 'Rejected'
               ];

          List<Map<String, String>> userConflicts = new List<Map<String, String>>();

          for (Facility_Request__c b : userExisting) {
        if (b.Start_Date__c == null || b.End_Date__c == null ||
                    b.Start_Time__c == null || b.End_Time__c == null ||
                    b.Start_Time__c > b.End_Time__c) {

                    System.debug('Skipping invalid existing record: ' + b.Id);
                    continue;
                }
              
        // Convert existing booking into datetime
        Datetime existStart = Datetime.newInstance(b.Start_Date__c, b.Start_Time__c);
        Datetime existEnd   = Datetime.newInstance(b.End_Date__c, b.End_Time__c);

       // Overlap check: (start < newEnd) AND (end > newStart)
       if (existStart < newEndDT && existEnd > newStartDT) {
          userConflicts.add(new Map<String, String>{
            'recordId' => b.Id,
            'facilityName' => data.facilityName,
            'startDate' => b.Start_Date__c.format(),
            'endDate'   => b.End_Date__c.format(),
            'startTime' => formatTime(b.Start_Time__c),
            'endTime'   => formatTime(b.End_Time__c),
            'requesterName' => b.RequesterName__c,
            'requesterPhone' => b.Reqester_Phone_Number__c
              });
            }
           }

           if (!userConflicts.isEmpty()) {
            return conflictResponse(userConflicts);
            }
*/
            // Facility Lookup 
            Id facilityIdToAssign = null;
            hed__Facility__c facilityRec = null;

            if (!String.isBlank(data.facilityId)) {
                try {
                    facilityIdToAssign = Id.valueOf(data.facilityId);

                    facilityRec = [
                        SELECT Id, hed__Account__c
                        FROM hed__Facility__c
                        WHERE Id = :facilityIdToAssign LIMIT 1
                    ];
                } catch (Exception e) {
                    facilityIdToAssign = null;
                }
            }

            if (facilityIdToAssign == null && !String.isBlank(data.facilityName)) {
                List<hed__Facility__c> facByName = [
                    SELECT Id, hed__Account__c
                    FROM hed__Facility__c
                    WHERE Name = :data.facilityName
                    LIMIT 1
                ];

                if (!facByName.isEmpty()) {
                    facilityRec = facByName[0];
                    facilityIdToAssign = facilityRec.Id;
                }
            }

            // Conflict Check 
            List<Facility_Request__c> existingBookings = [
                SELECT Id, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c,
                       Facility__r.Name,
                       RequesterName__c, Reqester_Phone_Number__c
                FROM Facility_Request__c
               /* WHERE Facility_Type__c = :data.facilityType
                  AND Building_Name__c = :data.buildingName
                  AND Floor__c = :data.floorNumber
                  AND Room_No__c = :data.roomNumber
                  AND TemplateName__c NOT IN ('Rejected', 'Cancelled')*/
                
                WHERE Facility__c = :facilityIdToAssign
                AND (TemplateName__c = NULL 
                     OR TemplateName__c NOT IN ('Rejected', 'Cancelled') ) For Update
            ];
        

           /* List<Map<String, String>> conflicts = new List<Map<String, String>>();

            for (Facility_Request__c b : existingBookings) {
                if (b.Start_Date__c == null || b.End_Date__c == null ||
                    b.Start_Time__c == null || b.End_Time__c == null)
                    continue;
	
                Datetime existStart = Datetime.newInstance(b.Start_Date__c, b.Start_Time__c);
                Datetime existEnd   = Datetime.newInstance(b.End_Date__c, b.End_Time__c);

                // FULL overlap formula
                if (existStart < newEndDT && existEnd > newStartDT) {
                    conflicts.add(new Map<String, String>{
                        'recordId'  => b.Id,
                        'facilityName' => (b.Facility__r != null ? b.Facility__r.Name : ''),
                        'startDate' => b.Start_Date__c.format(),
                        'endDate'   => b.End_Date__c.format(),
                        'startTime' => formatTime(b.Start_Time__c),
                        'endTime'   => formatTime(b.End_Time__c),
                        'requesterName' => b.RequesterName__c,
                        'requesterPhone' => b.Reqester_Phone_Number__c
                    });
                }
            }
*/
List<Map<String, String>> conflicts = new List<Map<String, String>>();

for (Facility_Request__c b : existingBookings) {

    if (b.Start_Date__c == null || b.End_Date__c == null ||
        b.Start_Time__c == null || b.End_Time__c == null) {
        continue;
    }

    // ✅ Check date overlap first
    if (b.End_Date__c < data.startDate || b.Start_Date__c > data.endDate) {
        continue;
    }

    // 👉 Loop each day of NEW booking
    Date loopDate = data.startDate;

    while (loopDate <= data.endDate) {

        // 👉 Check if this day is within EXISTING booking
        if (loopDate >= b.Start_Date__c && loopDate <= b.End_Date__c) {

            // Existing booking time for that day
            Datetime existStartDT = Datetime.newInstance(loopDate, b.Start_Time__c);
            Datetime existEndDT   = Datetime.newInstance(loopDate, b.End_Time__c);

            // New booking time for that day
            Datetime newStartDTLoop = Datetime.newInstance(loopDate, startTime);
            Datetime newEndDTLoop   = Datetime.newInstance(loopDate, endTime);

            // Handle cross-midnight (optional safety)
            if (b.End_Time__c <= b.Start_Time__c) {
                existEndDT = existEndDT.addDays(1);
            }

            if (endTime <= startTime) {
                newEndDTLoop = newEndDTLoop.addDays(1);
            }

            // ✅ FINAL overlap check
            if (!(existEndDT <= newStartDTLoop || existStartDT >= newEndDTLoop)) {

                conflicts.add(new Map<String, String>{
                    'recordId'  => b.Id,
                    'facilityName' => (b.Facility__r != null ? b.Facility__r.Name : ''),
                    'startDate' => String.valueOf(loopDate),
                    'endDate'   => String.valueOf(loopDate),
                    'startTime' => formatTime(b.Start_Time__c),
                    'endTime'   => formatTime(b.End_Time__c),
                    'requesterName' => b.RequesterName__c,
                    'requesterPhone' => b.Reqester_Phone_Number__c
                });

                break; // stop checking more days
            }
        }

        loopDate = loopDate.addDays(1);
    }
}
            if (!conflicts.isEmpty()) {
                return conflictResponse(conflicts);
            }

            // ---------------------- INSERT FACILITY REQUEST ----------------------
            Facility_Request__c fr = new Facility_Request__c();

            fr.Building_Name__c = data.buildingName;
            fr.Facility_Type__c = data.facilityType;
            fr.Floor__c         = data.floorNumber;
            fr.Room_No__c       = data.roomNumber;
            fr.Reason_of_Booking__c = data.facilityReason;
            fr.Number_Of_Attendees__c = data.attendeesNumber;  
            fr.Additional_Amenities_Required__c = data.additionalFacility;
            fr.Additional_Amenities_Required2__c = data.additionalFacility2;
            fr.Quantity_Of_Additional_Amenities__c = data.quantityOfAdditionalAmenities;
            fr.Description__c = data.description;
            fr.Capacity__c = data.capacity;
            fr.Start_Date__c = data.startDate;
            fr.End_Date__c = data.endDate;
            fr.Start_Time__c = startTime;
            fr.End_Time__c   = endTime;
            fr.Requester__c = UserInfo.getUserId(); 

            if (facilityIdToAssign != null) {
                fr.Facility__c = facilityIdToAssign;
            }

            if (facilityRec != null && facilityRec.hed__Account__c != null) {
                fr.Account__c = facilityRec.hed__Account__c;
            }

            insert fr;

            return successResponse('Booking confirmed');

        } catch (Exception ex) {
            return errorResponse('Error saving booking: ' + ex.getMessage());
        }
    }

    //  Helper Responses 
    public static Map<String,Object> successResponse(String msg) {
        return new Map<String,Object>{
            'status' => 'success',
            'message' => msg
        };
    }

    public static Map<String,Object> conflictResponse(List<Map<String,String>> conflicts) {
        return new Map<String,Object>{
            'status' => 'conflict',
            'message' => 'Conflicts found',
            'conflicts' => conflicts
        };
    }

    public static Map<String, Object> errorResponse(String msg) {
        return new Map<String, Object>{
            'status' => 'Error',
            'message' => msg
        };
    }

  private static Time convertToTime(String timeStr) {
    if (String.isBlank(timeStr)) {
        throw new AuraHandledException('Invalid time value');
    }
    
    String[] parts = timeStr.split(' ');
    String[] hm = parts[0].split(':');

    Integer h = Integer.valueOf(hm[0]);
    Integer m = Integer.valueOf(hm[1]);
    String ampm = (parts.size() > 1) ? parts[1] : '';

    if (ampm == 'PM' && h != 12) h += 12;
    if (ampm == 'AM' && h == 12) h = 0;

    return Time.newInstance(h, m, 0, 0);
}

     /*  Utility Methods 
     private static Time convertToTime(String timeStr) {
        String[] parts = timeStr.split(' ');
        String[] hm = parts[0].split(':');

        Integer h = Integer.valueOf(hm[0]);
        Integer m = Integer.valueOf(hm[1]);
        String ampm = parts.size() > 1 ? parts[1] : '';

        if (ampm == 'PM' && h != 12) h += 12;
        if (ampm == 'AM' && h == 12) h = 0;

        return Time.newInstance(h, m, 0, 0);
    }*/

/*private static String formatTime(Time t) {
        String h = (t.hour() < 10 ? '0' : '') + t.hour();
        String m = (t.minute() < 10 ? '0' : '') + t.minute();
        return h + ':' + m;
    }*/
    
    public static String formatTime(Time t) {
      if (t == null) return '';

      Integer hour = t.hour();
      Integer minute = t.minute();

      // Determine AM/PM
      String ampm = (hour >= 12) ? 'PM' : 'AM';

      // Convert to 12-hour format without using %
      Integer displayHour;
     if (hour == 0) {
        displayHour = 12;       // midnight
     } else if (hour > 12) {
        displayHour = hour - 12; // e.g., 14 → 2
     } else {
        displayHour = hour;     // keep the same
     }

      // Format minutes
      String minuteStr = minute < 10 ? '0' + minute : String.valueOf(minute);

      return displayHour + ':' + minuteStr + ' ' + ampm;
   }



    @AuraEnabled
    public static List<Calendar_Timings__c> getTimeValues() {
        List<Calendar_Timings__c> timeValsList = [SELECT Id, Name FROM Calendar_Timings__c ORDER BY Id ASC];
        return timeValsList;
    }

    @AuraEnabled
    public static List<hed__Course_Offering_Schedule__c> getCourseScedules(Id recordId) {
        List<hed__Course_Offering_Schedule__c> courseTimeData = [SELECT Id, Name, hed__End_Time__c, hed__Start_Time__c, hed__Facility__c, Date__c, hed__Course_Offering__r.Active_Elective_Course__c FROM hed__Course_Offering_Schedule__c WHERE Id = :recordId];
        return courseTimeData; 
    }
    
    @AuraEnabled
    // Helper function to parse time string
    public static Time parseTime(String timeString) {
        String[] timeParts = timeString.split(' ');
        String[] hourMinute = timeParts[0].split(':');
        Integer hour = Integer.valueOf(hourMinute[0]);
        Integer minute = Integer.valueOf(hourMinute[1]);
        String amPm = timeParts[1];

        // Convert 12-hour format to 24-hour format
        if (amPm == 'PM' && hour != 12) {
            hour += 12;
        } else if (amPm == 'AM' && hour == 12) {
            hour = 0;
        }

        return Time.newInstance(hour, minute, 0, 0);
    }

    public class FacilityRequestWrapper {
        @AuraEnabled public String buildingName {get;set;}
        @AuraEnabled public String facilityName {get;set;}
        @AuraEnabled public String facilityType {get;set;}
        @AuraEnabled public String floorNumber {get;set;}
        @AuraEnabled public String roomNumber {get;set;}
        @AuraEnabled public Date startDate {get;set;}
        @AuraEnabled public Date endDate {get;set;}
        @AuraEnabled public String startTime {get;set;}
        @AuraEnabled public String endTime {get;set;}
        @AuraEnabled public String facilityReason {get;set;} 
        @AuraEnabled public Integer attendeesNumber {get;set;} 
        @AuraEnabled public String additionalFacility {get;set;}
        @AuraEnabled public String additionalFacility2 {get;set;} 
        @AuraEnabled public String quantityOfAdditionalAmenities {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Integer capacity {get;set;}
        @AuraEnabled public Boolean isElective {get;set;}
        @AuraEnabled public String  accountId {get;set;}
        @AuraEnabled public String facilityId {get;set;} 
        @AuraEnabled public Id approverId {get;set;}
       // @AuraEnabled publis String requesterName {get;set;}
       // @AureEnabled public String requesterPhone {get;set;}
    } 
    
    /*@AuraEnabled
    public static String saveFacilityRequest(String selectedFields, Id courseOfferingId) {
        String errorMessage = '';
        String accountId;
        boolean approvalStatus = false;

        FacilityRequestWrapper facilityWrappers = (FacilityRequestWrapper) JSON.deserialize(selectedFields, FacilityRequestWrapper.class);

        Time startTimeValue;
        Time endTimeValue;

        if (facilityWrappers != null) {
            // Handling startTime
            if (facilityWrappers.startTime != null && facilityWrappers.startTime != '') {
                List<String> startTimeComponents = facilityWrappers.startTime.split(':|\\s');
                Integer startHour = Integer.valueOf(startTimeComponents[0]);
                Integer startMinute = Integer.valueOf(startTimeComponents[1]);
                
                // Adjust for AM/PM
                if (startTimeComponents.size() > 2 && startTimeComponents[2].equalsIgnoreCase('PM') && startHour != 12) {
                    startHour += 12; // Convert PM hour to 24-hour format
                } else if (startTimeComponents.size() > 2 && startTimeComponents[2].equalsIgnoreCase('AM') && startHour == 12) {
                    startHour = 0; // Convert 12 AM to 0 hours
                }

                startTimeValue = Time.newInstance(startHour, startMinute, 0, 0);
            }

            System.debug('facilityRec::');

            // Handling endTime
            if (facilityWrappers.endTime != null && facilityWrappers.endTime != '') {
                List<String> endTimeComponents = facilityWrappers.endTime.split(':|\\s');
                Integer endHour = Integer.valueOf(endTimeComponents[0]);
                Integer endMinute = Integer.valueOf(endTimeComponents[1]);

                // Adjust for AM/PM
                if (endTimeComponents.size() > 2 && endTimeComponents[2].equalsIgnoreCase('PM') && endHour != 12) {
                    endHour += 12; // Convert PM hour to 24-hour format
                } else if (endTimeComponents.size() > 2 && endTimeComponents[2].equalsIgnoreCase('AM') && endHour == 12) {
                    endHour = 0; // Convert 12 AM to 0 hours
                }

                endTimeValue = Time.newInstance(endHour, endMinute, 0, 0);
            }
        }



        if (!Test.isRunningTest()){
        hed__Facility__c facilityRec = [SELECT Id, Name, hed__Account__c, hed__Account__r.Name FROM hed__Facility__c WHERE Name = :facilityWrappers.facilityName LIMIT 1];
        system.debug('facilityRec::--'+facilityRec);

        
        accountId = System.Label.defaultAccountId;
        accountId = '001J400000VC0HDIA1';
        system.debug('+++accountId++++'+accountId);

        User loggedInUsr = [SELECT Id, Department FROM User WHERE Id = :UserInfo.getUserId()];
        if (loggedInUsr.Department == facilityRec.hed__Account__r.Name) {
            approvalStatus = true;
        }}else{
            accountId = [SELECT id from Account LIMIT 1].id;
            system.debug('+++accountId++++'+accountId);
            approvalStatus = true;
        }

        Facility_Request__c part = new Facility_Request__c();
        part.Building_Name__c = facilityWrappers.buildingName;
        part.Facility_Type__c = facilityWrappers.facilityType;
        part.Floor__c = facilityWrappers.floorNumber;
        part.Room_No__c = facilityWrappers.roomNumber;
        part.Reason_of_Booking__c = facilityWrappers.facilityReason;
        part.Additional_Amenities_Required__c = facilityWrappers.additionalFacility;
        part.Additional_Amenities_Required2__c = facilityWrappers.additionalFacility2;
        part.Start_Date__c = facilityWrappers.startDate;
        part.End_Date__c = facilityWrappers.endDate;
        part.Start_Time__c = startTimeValue;
        part.End_Time__c = endTimeValue;
        part.Quantity_Of_Additional_Amenities__c = facilityWrappers.quantityOfAdditionalAmenities;
        part.Description__c = facilityWrappers.description;
        part.Capacity__c = facilityWrappers.capacity;
        part.Account__c = accountId;
        //part.Facility__c = facilityWrappers.facilityId;
        
        if (approvalStatus) {
            part.ApprovalStatus__c = 'Approved';
        }

        if (part != null) {
            try {
                insert part; 
                return 'Success';
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    errorMessage += e.getDmlMessage(i) + '\n';
                }
                return errorMessage;
            } catch (Exception e) {
                errorMessage = e.getMessage();
                return errorMessage;
            }
        }
        
        return 'Error in creating Facility Request';
    }*/

    @AuraEnabled
    public static List<Reva_Infra_Additional_Amenity__mdt> getAdditionalAmenities() {
        List<Reva_Infra_Additional_Amenity__mdt> additionalAminityData = [SELECT Name__c FROM Reva_Infra_Additional_Amenity__mdt];
        return additionalAminityData;       
    }
}