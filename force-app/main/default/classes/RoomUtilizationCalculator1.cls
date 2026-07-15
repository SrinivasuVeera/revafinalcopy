public with sharing class RoomUtilizationCalculator1 {

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserDepartment() {
        User currentUser = [SELECT Department FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser.Department != null ? currentUser.Department : 'Unknown';
    }
        @AuraEnabled(cacheable=true)
    public static List<String> getAllUserDepartments() {
        Set<String> departmentSet = new Set<String>();
        for (AggregateResult ar : [
            SELECT Department FROM User WHERE Department != null AND Department LIKE '%School%' GROUP BY Department
        ]) {
            departmentSet.add((String)ar.get('Department'));
        }
        return new List<String>(departmentSet);
    }


    @AuraEnabled(cacheable=true)
    public static Integer calculateTotalSlots(Date startDate, Date endDate, Integer dailySlots) {
        Integer totalSlots = 0;
        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            String dayOfWeek = DateTime.newInstance(d.year(), d.month(), d.day()).format('EEEE', 'en_US');
            if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                totalSlots += dailySlots;
            }
        }
        return totalSlots;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRoomUtilizationData(String timeRange, String userDepartment) {
        Integer dailySlots = 7;

        // Determine Date Range
        Date startDate, endDate;
        if (timeRange == 'This Week') {
            startDate = System.today().toStartOfWeek();
            endDate = startDate.addDays(6);
        } else if (timeRange == 'Last Week') {
            startDate = System.today().toStartOfWeek().addDays(-7);
            endDate = startDate.addDays(6);
        } else if (timeRange == 'Next Week') {
            startDate = System.today().toStartOfWeek().addDays(7);
            endDate = startDate.addDays(6);  
        } else if (timeRange == 'This Month') {
            startDate = Date.today().toStartOfMonth();
            endDate = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        } else if (timeRange == 'Last Month') {
            startDate = Date.today().addMonths(-1).toStartOfMonth();
            endDate = Date.today().toStartOfMonth().addDays(-1);
        } else if (timeRange == 'Next Month') {
            startDate = Date.today().addMonths(1).toStartOfMonth();
            endDate = Date.today().addMonths(2).toStartOfMonth().addDays(-1);
        } else {
            startDate = System.today();
            endDate = startDate;
        }

        Integer totalSlots = calculateTotalSlots(startDate, endDate, dailySlots);

        // Fetch all rooms
        List<hed__Facility__c> allRooms = [
            SELECT Room__c, Block__c, Floor__c, hed__Facility_Type__c
            FROM hed__Facility__c
            WHERE hed__Account__r.Name = :userDepartment
            AND hed__Facility_Type__c IN ('Classroom', 'Laboratory')
        ];
        Integer totalRooms = allRooms.size();

        // Fetch Course Offering records
        List<hed__Course_Offering_Schedule__c> bookedSchedules = [
            SELECT Date__c, Slot__c, hed__Facility__r.Room__c
            FROM hed__Course_Offering_Schedule__c
            WHERE Date__c >= :startDate AND Date__c <= :endDate
            AND hed__Facility__c != NULL
            AND School__c = :userDepartment
            AND hed__Facility__r.hed__Facility_Type__c IN ('Classroom', 'Laboratory')
        ];

        // Deduplicate by Room + Date + Slot
        Set<String> uniqueBookings = new Set<String>();
        Map<String, Integer> bookedSlotsPerRoom = new Map<String, Integer>();

        for (hed__Course_Offering_Schedule__c rec : bookedSchedules) {
            if (rec.hed__Facility__r.Room__c != null && rec.Date__c != null && rec.Slot__c != null) {
                String key = rec.hed__Facility__r.Room__c + '-' + rec.Date__c + '-' + rec.Slot__c;
                if (!uniqueBookings.contains(key)) {
                    uniqueBookings.add(key);
                    String room = rec.hed__Facility__r.Room__c;
                    bookedSlotsPerRoom.put(room, bookedSlotsPerRoom.containsKey(room) ? bookedSlotsPerRoom.get(room) + 1 : 1);
                }
            }
        }

        // Construct response list
        List<Map<String, Object>> roomUtilizationList = new List<Map<String, Object>>();

        for (hed__Facility__c room : allRooms) {
            String roomNumber = String.valueOf(room.Room__c);
            Integer roomBookedSlots = bookedSlotsPerRoom.containsKey(roomNumber) ? bookedSlotsPerRoom.get(roomNumber) : 0;
            Integer availableSlots = Math.max(totalSlots - roomBookedSlots, 0);
            Decimal utilization = (totalSlots > 0) ? (Decimal.valueOf(roomBookedSlots) / Decimal.valueOf(totalSlots)) * 100 : 0;
            Integer roundedUtil = Math.min(100, Math.round(utilization));

            Map<String, Object> roomData = new Map<String, Object>{
                'roomNumber' => roomNumber,
                'block' => String.valueOf(room.Block__c),
                'floor' => String.valueOf(room.Floor__c),
                'type' => String.valueOf(room.hed__Facility_Type__c),
                'totalSlots' => totalSlots,
                'roomBooked' => roomBookedSlots,
                'availableSlots' => availableSlots,
                'slotPercentage' => utilization,
                'utilizationPercentage' => roundedUtil,
                'school' => userDepartment
            };

            roomUtilizationList.add(roomData);
        }

        return roomUtilizationList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Integer>> getRoomSlotDetails(String roomNumber, String timeRange, String slotType, String userDepartment) {
        List<Integer> allSlots = new List<Integer>{1, 2, 4, 5, 7, 8, 9}; 
        Map<String, List<Integer>> slotData = new Map<String, List<Integer>>();

        Date startDate, endDate;
        if (timeRange == 'This Week') {
            startDate = Date.today().toStartOfWeek();
            endDate = startDate.addDays(5);
        } else if (timeRange == 'Next Week') {
            startDate = Date.today().toStartOfWeek().addDays(8);    
            endDate = startDate.addDays(5);
        } else {
            return slotData; // Only This Week and Next Week allowed
        }

        if (String.isEmpty(roomNumber)) {
            return slotData;
        }

        List<hed__Course_Offering_Schedule__c> allocatedSlots = [
            SELECT Date__c, Slot__c
            FROM hed__Course_Offering_Schedule__c
            WHERE hed__Facility__r.Room__c = :roomNumber
            AND Date__c >= :startDate AND Date__c <= :endDate
            AND School__c = :userDepartment
        ];

        Map<String, Set<Integer>> bookedSlotsMap = new Map<String, Set<Integer>>();
        for (hed__Course_Offering_Schedule__c slotRec : allocatedSlots) {
            if (slotRec.Date__c != null && slotRec.Slot__c != null) {
                String dateKey = slotRec.Date__c.format();
                if (!bookedSlotsMap.containsKey(dateKey)) {
                    bookedSlotsMap.put(dateKey, new Set<Integer>());
                }
                bookedSlotsMap.get(dateKey).add(slotRec.Slot__c.intValue());
            }
        }

        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            String dayOfWeek = DateTime.newInstance(d.year(), d.month(), d.day()).format('EEEE', 'en_US');
            if (dayOfWeek == 'Friday' || dayOfWeek == 'Saturday') {
                continue;
            }
            String dateKey = d.format();
            Set<Integer> bookedSlots = bookedSlotsMap.containsKey(dateKey) ? bookedSlotsMap.get(dateKey) : new Set<Integer>();
            Set<Integer> availableSlots = new Set<Integer>();

            for (Integer slot : allSlots) {
                if (!bookedSlots.contains(slot)) {
                    availableSlots.add(slot);
                }
            }

            slotData.put(dateKey, slotType == 'Booked' ? new List<Integer>(bookedSlots) : new List<Integer>(availableSlots));
        }

        return slotData;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> exportAvailableSlotData(String timeRange, String userDepartment) {
        List<Map<String, Object>> availableSlotExport = new List<Map<String, Object>>();
        List<Integer> allSlots = new List<Integer>{1, 2, 4, 5, 7, 8, 9};

        Date startDate, endDate;
        if (timeRange == 'This Week') {
            startDate = Date.today().toStartOfWeek();
            endDate = startDate.addDays(5);
        } else if (timeRange == 'Next Week') {
            startDate = Date.today().toStartOfWeek().addDays(8);    
            endDate = startDate.addDays(5);
        } else {
            return availableSlotExport;
        }

        // Query rooms with Block and Floor info
        List<hed__Facility__c> rooms = [
            SELECT Room__c, Block__c, Floor__c
            FROM hed__Facility__c
            WHERE hed__Account__r.Name = :userDepartment
            AND hed__Facility_Type__c IN ('Classroom', 'Laboratory')
        ];

        Map<String, Map<String, String>> roomInfoMap = new Map<String, Map<String, String>>();
        for (hed__Facility__c room : rooms) {
            if (room.Room__c != null) {
                roomInfoMap.put(room.Room__c, new Map<String, String>{
                    'block' => String.valueOf(room.Block__c),
                    'floor' => String.valueOf(room.Floor__c)
                });
            }
        }

        List<hed__Course_Offering_Schedule__c> bookings = [
            SELECT Date__c, Slot__c, hed__Facility__r.Room__c
            FROM hed__Course_Offering_Schedule__c
            WHERE Date__c >= :startDate AND Date__c <= :endDate
            AND School__c = :userDepartment
            AND hed__Facility__r.Room__c != null
        ];

        Map<String, Set<Integer>> bookedSlotsByRoomDate = new Map<String, Set<Integer>>();
        for (hed__Course_Offering_Schedule__c rec : bookings) {
            String key = rec.hed__Facility__r.Room__c + '-' + rec.Date__c;
            if (!bookedSlotsByRoomDate.containsKey(key)) {
                bookedSlotsByRoomDate.put(key, new Set<Integer>());
            }
            bookedSlotsByRoomDate.get(key).add(rec.Slot__c.intValue());
        }

        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            String dayOfWeek = DateTime.newInstance(d.year(), d.month(), d.day()).format('EEEE', 'en_US');
            if (dayOfWeek == 'Friday' || dayOfWeek == 'Saturday') continue;

            for (String roomNum : roomInfoMap.keySet()) {
                String key = roomNum + '-' + d;
                Set<Integer> booked = bookedSlotsByRoomDate.containsKey(key) ? bookedSlotsByRoomDate.get(key) : new Set<Integer>();
                List<Integer> available = new List<Integer>();

                for (Integer s : allSlots) {
                    if (!booked.contains(s)) available.add(s);
                }

                Map<String, String> roomMeta = roomInfoMap.get(roomNum);

                availableSlotExport.add(new Map<String, Object>{
                    'date' => d,
                    'roomNumber' => roomNum,
                    'block' => roomMeta.get('block'),
                    'floor' => roomMeta.get('floor'),
                    'availableSlots' => available,
                        'school' => userDepartment
                });
            }
        }

        return availableSlotExport;
    }
}