public with sharing class RoomUtilizationBlock {

      @AuraEnabled(cacheable=true)
   public static String getUserProfileName( ) {
     return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1 ].Profile.Name;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRoomUtilizationData(Date selectedStartDate, Date selectedEndDate) {
        Date startDate, endDate;

        if (selectedStartDate != null && selectedEndDate != null) {
            startDate = selectedStartDate;
            endDate = selectedEndDate;
        } else {
            startDate = System.today();
            endDate = startDate;
        }

        List<AggregateResult> bookedRoomResults = [
            SELECT 
                hed__Facility__r.Room__c roomNumber,
                hed__Facility__r.Block__c block,
                hed__Time_Block__r.hed__Educational_Institution__r.Parent.Name school,
                COUNT(Id) totalBookedDays
            FROM hed__Course_Offering_Schedule__c
            WHERE Date__c >= :startDate 
                AND Date__c <= :endDate
                AND hed__Facility__c != NULL
                AND hed__Facility__r.hed__Facility_Type__c IN ('Classroom', 'Laboratory')
            GROUP BY hed__Facility__r.Room__c, hed__Facility__r.Block__c,
                     hed__Time_Block__r.hed__Educational_Institution__r.Parent.Name
        ];

        List<Map<String, Object>> roomUtilizationList = new List<Map<String, Object>>();

        for (AggregateResult result : bookedRoomResults) {
            Map<String, Object> roomData = new Map<String, Object>();
            roomData.put('RoomNumber', result.get('roomNumber'));
            roomData.put('Block', result.get('block'));
            roomData.put('School', result.get('school'));
            roomData.put('BookedDays', result.get('totalBookedDays'));
            roomUtilizationList.add(roomData);
        }

        return roomUtilizationList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getBlockSchoolRoomSummary(Date selectedStartDate, Date selectedEndDate) {
        Date startDate = selectedStartDate != null ? selectedStartDate : System.today();
        Date endDate = selectedEndDate != null ? selectedEndDate : startDate;

        List<hed__Facility__c> allRooms = [
            SELECT Id, Room__c, Block__c, hed__Account__r.Name
            FROM hed__Facility__c
            WHERE hed__Facility_Type__c IN ('Classroom', 'Laboratory')
                AND Block__c != NULL
                AND hed__Account__r.Name != NULL
        ];

        List<AggregateResult> bookedRooms = [
            SELECT hed__Facility__r.Room__c roomNumber
            FROM hed__Course_Offering_Schedule__c
            WHERE Date__c >= :startDate 
                AND Date__c <= :endDate
                AND hed__Facility__c != NULL
                AND hed__Facility__r.hed__Facility_Type__c IN ('Classroom', 'Laboratory')
            GROUP BY hed__Facility__r.Room__c
        ];

        Set<String> bookedRoomNumbers = new Set<String>();
        for (AggregateResult ar : bookedRooms) {
            bookedRoomNumbers.add((String)ar.get('roomNumber'));
        }

        Map<String, Map<String, List<String>>> blockSchoolRoomsMap = new Map<String, Map<String, List<String>>>();

        for (hed__Facility__c room : allRooms) {
            String block = room.Block__c;
            String school = room.hed__Account__r.Name;
            String roomNumber = room.Room__c;

            if (!blockSchoolRoomsMap.containsKey(block)) {
                blockSchoolRoomsMap.put(block, new Map<String, List<String>>());
            }
            Map<String, List<String>> schoolRoomsMap = blockSchoolRoomsMap.get(block);

            if (!schoolRoomsMap.containsKey(school)) {
                schoolRoomsMap.put(school, new List<String>());
            }
            schoolRoomsMap.get(school).add(roomNumber);
        }

        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();

        for (String blockName : blockSchoolRoomsMap.keySet()) {
            Map<String, Object> blockData = new Map<String, Object>();
            List<Map<String, Object>> schoolList = new List<Map<String, Object>>();

            Integer blockTotalRooms = 0;
            Integer blockBookedRooms = 0;

            for (String schoolName : blockSchoolRoomsMap.get(blockName).keySet()) {
                List<String> schoolRoomList = blockSchoolRoomsMap.get(blockName).get(schoolName);
                Integer totalRooms = schoolRoomList.size();
                Integer bookedRoomsCount = 0;

                for (String roomNo : schoolRoomList) {
                    if (bookedRoomNumbers.contains(roomNo)) {
                        bookedRoomsCount++;
                    }
                }

                blockTotalRooms += totalRooms;
                blockBookedRooms += bookedRoomsCount;

                Map<String, Object> schoolData = new Map<String, Object>();
                schoolData.put('SchoolName', schoolName);
                schoolData.put('TotalRooms', totalRooms);
                schoolData.put('BookedRooms', bookedRoomsCount);
                schoolData.put('BookingPercentage', totalRooms > 0 ? (Decimal.valueOf(bookedRoomsCount) / totalRooms) * 100 : 0);

                schoolList.add(schoolData);
            }

            blockData.put('Block', blockName);
            blockData.put('TotalRooms', blockTotalRooms);
            blockData.put('BookedRooms', blockBookedRooms);
            blockData.put('BookingPercentage', blockTotalRooms > 0 ? (Decimal.valueOf(blockBookedRooms) / blockTotalRooms) * 100 : 0);
            blockData.put('Schools', schoolList);

            finalResult.add(blockData);
        }

        return finalResult;
    }
 
        @AuraEnabled(cacheable=true)
 public static List<Map<String, Object>> getAvailableRoomsByBlock(String blockName,Date startDate,Date endDate) {

    List<Map<String, Object>> availableRooms = new List<Map<String, Object>>();

    if(startDate == null || endDate == null) {
        return availableRooms;
    }

    // Daily slots
    List<Integer> allSlots =
        new List<Integer>{1,2,4,5,7,8,9};

    // Get all rooms
    List<hed__Facility__c> allRooms;

    if(blockName == 'All') {

    allRooms = [SELECT Id, Room__c,hed__Facility_Type__c,hed__Account__r.School_Head__r.Name,
               Floor__c,Block__c, hed__Account__r.Name  FROM hed__Facility__c
              WHERE hed__Facility_Type__c IN ('Classroom', 'Laboratory') AND Room__c != null ];

    } else {

       allRooms = [SELECT Id,Room__c, Floor__c, Block__c,hed__Account__r.School_Head__r.Name,hed__Facility_Type__c,
                hed__Account__r.Name FROM hed__Facility__c
              WHERE hed__Facility_Type__c IN ('Classroom', 'Laboratory') AND Room__c != null AND Block__c = :blockName ];
     }

    // Get booked schedules
    List<hed__Course_Offering_Schedule__c> bookedSchedules;

   if(blockName == 'All') {

      bookedSchedules = [SELECT Date__c,Slot__c,hed__Facility__r.Room__c FROM hed__Course_Offering_Schedule__c
         WHERE Date__c >= :startDate AND Date__c <= :endDate
                       AND hed__Facility__r.hed__Facility_Type__c IN ('Classroom', 'Laboratory')];

     } else {

    bookedSchedules = [SELECT Date__c, Slot__c, hed__Facility__r.Room__c FROM hed__Course_Offering_Schedule__c
               WHERE Date__c >= :startDate AND Date__c <= :endDate
                    AND hed__Facility__r.hed__Facility_Type__c IN ('Classroom', 'Laboratory')
                    AND hed__Facility__r.Block__c = :blockName ];
    }

    // Room + Date => booked slots
    Map<String, Set<Integer>> bookedSlotMap =
        new Map<String, Set<Integer>>();

    for(hed__Course_Offering_Schedule__c rec : bookedSchedules) {

        if(rec.Date__c != null &&
           rec.Slot__c != null &&
           rec.hed__Facility__r.Room__c != null) {

            String key =
                rec.hed__Facility__r.Room__c +
                '_' +
                String.valueOf(rec.Date__c);

            if(!bookedSlotMap.containsKey(key)) {

                bookedSlotMap.put(
                    key,
                    new Set<Integer>()
                );
            }

            bookedSlotMap.get(key)
                .add(Integer.valueOf(rec.Slot__c));
        }
    }

    // Find available slots
    for(Date d = startDate;
        d <= endDate;
        d = d.addDays(1)) {

        for(hed__Facility__c room : allRooms) {

            String key =
                room.Room__c +
                '_' +
                String.valueOf(d);

            Set<Integer> bookedSlots =
                bookedSlotMap.containsKey(key)
                ? bookedSlotMap.get(key)
                : new Set<Integer>();

            List<String> availableSlotList =
                new List<String>();

            for(Integer slotNo : allSlots) {

                if(!bookedSlots.contains(slotNo)) {

                    availableSlotList.add(
                        String.valueOf(slotNo)
                    );
                }
            }

            // Show only if any slot free
            if(!availableSlotList.isEmpty()) {

                Map<String, Object> row =
                    new Map<String, Object>();

                row.put(
                    'Date',
                    d.format()
                );

                row.put(
                    'Block',
                    room.Block__c
                );

                row.put(
                    'RoomNumber',
                    room.Room__c
                );

                row.put(
                    'Floor',
                    room.Floor__c
                );

                row.put(
                    'SchoolName',
                    room.hed__Account__r.Name
                );
                row.put(
                     'SchoolHead',
                    room.hed__Account__r.School_Head__r != null
                    ? room.hed__Account__r.School_Head__r.Name
                    : ''
                );

              row.put(
                 'RoomType',
                  room.hed__Facility_Type__c
             );

               /* row.put(
                    'AvailableSlots',
                    String.join(
                        availableSlotList,
                        ', '
                    )*/
                    row.put(
    'AvailableSlots',
    availableSlotList != null
        ? String.join(availableSlotList, ', ')
        : ''
                );

                availableRooms.add(row);
            }
        }
    }

    return availableRooms;
  }

        @AuraEnabled(cacheable=true)
    public static List<String> getAllBlocks() {

      List<String> blockList = new List<String>();

      blockList.add('All');

       for(AggregateResult ar : [SELECT Block__c blockName FROM hed__Facility__c
                 WHERE Block__c != null GROUP BY Block__c ORDER BY Block__c ]) {

        blockList.add((String) ar.get('blockName'));
    }

    return blockList;
}
   /* @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAvailableRoomsByBlock(String blockName, Date startDate, Date endDate) {
        if (blockName == null || startDate == null || endDate == null) return new List<Map<String, Object>>();

        List<hed__Facility__c> allRooms = [
            SELECT Id, Room__c, Floor__c, Block__c, hed__Account__r.Name
            FROM hed__Facility__c
            WHERE Block__c = :blockName
                AND hed__Facility_Type__c IN ('Classroom', 'Laboratory')
                AND Room__c != null
        ];

        Map<String, hed__Facility__c> roomNumberToFacility = new Map<String, hed__Facility__c>();
        for (hed__Facility__c facility : allRooms) {
            roomNumberToFacility.put(facility.Room__c, facility);
        }

        List<AggregateResult> bookedResults = [
            SELECT Date__c, hed__Facility__r.Room__c roomNumber
            FROM hed__Course_Offering_Schedule__c
            WHERE Date__c >= :startDate AND Date__c <= :endDate
                AND hed__Facility__r.Block__c = :blockName
                AND hed__Facility__r.hed__Facility_Type__c IN ('Classroom', 'Laboratory')
                AND hed__Facility__r.Room__c != null
            GROUP BY Date__c, hed__Facility__r.Room__c
        ];

        Set<String> bookedRoomDateKeys = new Set<String>();
        for (AggregateResult ar : bookedResults) {
            String roomNo = (String) ar.get('roomNumber');
            Date dateVal = (Date) ar.get('Date__c');
            if (roomNo != null && dateVal != null) {
                bookedRoomDateKeys.add(roomNo + '_' + String.valueOf(dateVal));
            }
        }

        List<Map<String, Object>> availableRooms = new List<Map<String, Object>>();
        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            for (hed__Facility__c room : allRooms) {
                String key = room.Room__c + '_' + String.valueOf(d);
                if (!bookedRoomDateKeys.contains(key)) {
                    Map<String, Object> entry = new Map<String, Object>();
                    entry.put('Date', d);
                    entry.put('RoomNumber', room.Room__c);
                    entry.put('Floor', room.Floor__c);
                    entry.put('SchoolName', room.hed__Account__r.Name);
                    availableRooms.add(entry);
                }
            }
        }

        return availableRooms;
    }

    @AuraEnabled(cacheable=true)
public static List<Map<String, Object>> exportAllBlockData(Date startDate, Date endDate) {
    List<Map<String, Object>> exportData = new List<Map<String, Object>>();

    for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
        List<Map<String, Object>> summaryList = getBlockSchoolRoomSummary(currentDate, currentDate);

        for (Map<String, Object> blockData : summaryList) {
            String blockName = (String) blockData.get('Block');
            List<Map<String, Object>> schools = (List<Map<String, Object>>) blockData.get('Schools');

            for (Map<String, Object> schoolData : schools) {
                Map<String, Object> row = new Map<String, Object>();
                row.put('Date', currentDate.format());
                row.put('BlockName', blockName);
                row.put('SchoolName', schoolData.get('SchoolName'));
                row.put('TotalRooms', schoolData.get('TotalRooms'));
                row.put('BookedRooms', schoolData.get('BookedRooms'));
                row.put('BookingPercentage', schoolData.get('BookingPercentage'));
                exportData.add(row);
            }
        }
    }

    return exportData;
}*/
    @AuraEnabled(cacheable=true)
public static List<Map<String, Object>> exportAllBlockData(Date startDate, Date endDate) {
    List<Map<String, Object>> exportData = new List<Map<String, Object>>();

    for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
        List<Map<String, Object>> summaryList = getBlockSchoolRoomSummary(currentDate, currentDate);

        for (Map<String, Object> blockData : summaryList) {
            String blockName = (String) blockData.get('Block');
            List<Map<String, Object>> schools = (List<Map<String, Object>>) blockData.get('Schools');

            // Aggregate totals for the block
            Integer totalRooms = 0;
            Integer bookedRooms = 0;

            for (Map<String, Object> schoolData : schools) {
                totalRooms += (Integer) schoolData.get('TotalRooms');
                bookedRooms += (Integer) schoolData.get('BookedRooms');
            }

            Decimal bookingPercentage = totalRooms > 0 
                ? (Decimal.valueOf(bookedRooms) / totalRooms) * 100 
                : 0;

            Map<String, Object> row = new Map<String, Object>();
            row.put('Date', currentDate.format());
            row.put('BlockName', blockName);
            row.put('TotalRooms', totalRooms);
            row.put('BookedRooms', bookedRooms);
            row.put('BookingPercentage', bookingPercentage.setScale(2));

            exportData.add(row);
        }
    }

    return exportData;
}

    @AuraEnabled(cacheable=true)
public static List<Map<String, Object>> exportBlockData(Date startDate, Date endDate, String blockName) {
    if (String.isBlank(blockName)) return new List<Map<String, Object>>();

    List<Map<String, Object>> dataList = new List<Map<String, Object>>();

    for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {

        // Get all facilities in the block
        List<hed__Facility__c> facilities = [
            SELECT Id, Room__c, Block__c, hed__Account__r.Name
            FROM hed__Facility__c
            WHERE Block__c = :blockName AND hed__Facility_Type__c IN ('Classroom', 'Laboratory')
        ];

        // Group rooms by school
        Map<String, List<String>> schoolToRooms = new Map<String, List<String>>();
        for (hed__Facility__c fac : facilities) {
            String schoolName = fac.hed__Account__r.Name;
            if (!schoolToRooms.containsKey(schoolName)) {
                schoolToRooms.put(schoolName, new List<String>());
            }
            schoolToRooms.get(schoolName).add(fac.Room__c);
        }

        // Booking counts grouped by room for the current date
        Map<String, Integer> roomBookingCount = new Map<String, Integer>();
        List<AggregateResult> bookings = [
            SELECT hed__Facility__r.Room__c roomNumber, COUNT(Id) bookingCount
            FROM hed__Course_Offering_Schedule__c
            WHERE Date__c = :currentDate
                AND hed__Facility__r.Block__c = :blockName
            GROUP BY hed__Facility__r.Room__c
        ];
        for (AggregateResult ar : bookings) {
            String roomNo = (String) ar.get('roomNumber');
            Integer count = (Integer) ar.get('bookingCount');
            roomBookingCount.put(roomNo, count);
        }

        for (String schoolName : schoolToRooms.keySet()) {
            List<String> roomList = schoolToRooms.get(schoolName);
            Integer totalRooms = roomList.size();
            Integer bookedRooms = 0;

            for (String roomNo : roomList) {
                if (roomBookingCount.containsKey(roomNo)) {
                    bookedRooms += 1;
                }
            }

            Decimal percent = totalRooms > 0 ? (Decimal.valueOf(bookedRooms) / totalRooms) * 100 : 0;

            Map<String, Object> row = new Map<String, Object>();
            row.put('Date', currentDate.format());
            row.put('SchoolName', schoolName);
            row.put('TotalRooms', totalRooms);
            row.put('BookedRooms', bookedRooms);
            row.put('BookingPercentage', percent.setScale(2));
            row.put('BlockName', blockName);
            dataList.add(row);
        }
    }

    return dataList;
}

}