public without sharing class rewaTimeSlot {
    // @AuraEnabled(cacheable=true)
    // public static List<ManodhaaraAppointment__c> getTimeSlotsByDate(Date selectedDate) {
    //     List<ManodhaaraAppointment__c> timeSlots = [SELECT Id, Name, Time_Slot__c FROM ManodhaaraAppointment__c WHERE Appointment_Date__c = :selectedDate];
    //     return timeSlots;
    // }

    // @AuraEnabled(cacheable=true)
    // public static List<String> getPicklistValues() {
    //     List<String> picklistValues = new List<String>();
    //     Schema.DescribeFieldResult fieldResult = ManodhaaraAppointment__c.Time_Slot__c.getDescribe();
    //     system.debug('this is fiels value'+ picklistValues);
    //     system.debug('this is fiels value'+ fieldResult);
        
        
    //     List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
    //     for (Schema.PicklistEntry entry : picklistEntries) {
    //         picklistValues.add(entry.getValue());
    //     }
    //      system.debug('this is fiels value'+ picklistEntries);
    //     return picklistValues;
    // }  
    
    @AuraEnabled
    public static Map<String, List<RSW_Manodhaara_CMT__mdt>> fetchCustomMetadataMap() {
        Map<String, List<RSW_Manodhaara_CMT__mdt>> dateToCMDTMap = new Map<String, List<RSW_Manodhaara_CMT__mdt>>();

        // Fetch the start and end time from Custom Metadata
        RSW_Manodhaara_CMT__mdt metadataRecord = RSW_Manodhaara_CMT__mdt.getInstance('Manodhaara_CMT_Setting'); // Replace with your Custom Metadata developer name
        String startTimeText = metadataRecord.RSW_Start_Day_Time__c;
        String endTimeText = metadataRecord.RSW_Day_End_Time__c;

        // Manually parse start and end times into DateTime objects
        DateTime startTime = parseCustomTime(startTimeText);
        DateTime endTime = parseCustomTime(endTimeText);

        // Calculate the number of 1-hour intervals between start and end times
        Integer numberOfIntervals = (Integer)((endTime.getTime() - startTime.getTime())+0.5) / (1000 * 60 * 60);

        // Iterate through intervals and populate the map with time slots
        for (Integer i = 0; i < 4; i++) {
            DateTime startHour = startTime.addHours(i);
            
            // Skip the 1:00 - 1:30 slot
    if (startHour.hour() == 13 && startHour.minute() == 0) {
        Break;
    }
            
            DateTime endHour = startHour.addHours(1);

            // Format the hour range as 'h a - h a' (e.g., '10 AM - 11 AM')
            String hourRange = startHour.format('h:mm a') + ' - ' + endHour.format('h:mm a');

            // Add the time slot to the map
            if (!dateToCMDTMap.containsKey(hourRange)) {
                dateToCMDTMap.put(hourRange, new List<RSW_Manodhaara_CMT__mdt>());
            }
        }
        
           for (Integer i = 4; i < numberOfIntervals; i++) {
          //  DateTime startTime = 
            //system.debug('startTime--'+startTime);
            DateTime startHour = startTime.addHours(i);
            startHour = startHour.addminutes(30);
              // system.debug('startHour--'+startHour);
            
            DateTime endHour = startHour.addHours(1);

            // Format the hour range as 'h a - h a' (e.g., '10 AM - 11 AM')
            String hourRange = startHour.format('h:mm a') + ' - ' + endHour.format('h:mm a');

            // Add the time slot to the map
            if (!dateToCMDTMap.containsKey(hourRange)) {
                dateToCMDTMap.put(hourRange, new List<RSW_Manodhaara_CMT__mdt>());
            }
        }

        return dateToCMDTMap;
    }

    // Helper method to parse custom time format like "10 AM"
    private static DateTime parseCustomTime(String timeString) {
        // Split the time string into hours and minutes
       //List<String> timeParts = timeString.split(' ');
        List<String> timeParts = timeString.split('[: ]');

        if (timeParts.size() == 3) {
            String hourPart = timeParts[0];
            String minPart = timeParts[1];
            String ampmPart = timeParts[2];

            // Extract hours and AM/PM
            Integer hours = Integer.valueOf(hourPart);
            Integer minutes = 0; // You can add minute handling if needed

            // Adjust for PM
            if (ampmPart.equalsIgnoreCase('PM') && hours < 12) {
                hours += 12;
            }

            // Create a DateTime object with a dummy date (e.g., today)
            DateTime now = DateTime.now();
            DateTime dateTimeResult = DateTime.newInstance(now.year(), now.month(), now.day(), hours, minutes, 0);

            return dateTimeResult;
        }

        // Return null or handle parsing errors as needed
        return null;
    }
    }