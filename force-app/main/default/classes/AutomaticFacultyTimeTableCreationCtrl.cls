/**
     * @description This class is responsible for generating and managing the automatic faculty timetable.
     * It includes methods for timetable creation, fetching existing schedules, and saving schedules.
     * Ensure that the appropriate sharing model is applied for security compliance.
     *
     * @author        Devender Jadala
     * @team          Cloud Odyssey
     * @createdDate   18/11/2025
     * @lastModified
     */
    public with sharing class AutomaticFacultyTimeTableCreationCtrl {

        @AuraEnabled
        /**
         * @description Generates a timetable for the given term record.
         * @param recordId The ID of the term record for which the timetable is to be generated.
         * @return A TimetableData object containing the generated timetable details.
         */
        public static TimetableData generateTimetable(Id recordId) {
            TimetableData result = new TimetableData();
            result.isTimetableCreated = false;
            Map<Id ,Set<Id>> processedTBIdsSecMap = new Map<Id ,Set<Id>>();

            // To get current semester detailes
            hed__Term__c term = [
                SELECT Id, Name, hed__Start_Date__c, hed__End_Date__c, hed__Account__c, hed__Account__r.ParentId,
                       IA_1_Start_date__c, IA_1_End_date__c, IA_2_Start_date__c, IA_2_End_date__c,Schedule_not_Created__c,
                       Exam_Start_Date__c, Exam_End_Date__c, hed__Account__r.Name
                FROM hed__Term__c
                WHERE Id = :recordId WITH USER_MODE
                LIMIT 1
            ];
            if (term == null) {
                throw new AuraHandledException('Term not found');
            }


            //If in semester level schedule not created is false then fetch existing schedules meaning schedules are already created
            if(term.Schedule_not_Created__c == false){
                result = getExistingOfferingSchedules(recordId);
                return result;

            }


            // To get all the time blocks related to thecurrent semester Acadamic program
            List<hed__Time_Block__c> blocks =  new List<hed__Time_Block__c>();
            Map<Id, hed__Time_Block__c> blockMap = new Map<Id, hed__Time_Block__c>();
            List<hed__Time_Block__c> breakBlocks = new List<hed__Time_Block__c>();

            List<hed__Time_Block__c> commonBlocks = [
                SELECT Id, Name, hed__End_Time__c, hed__Start_Time__c, Break__c,
                       Friday__c, Monday__c, Saturday__c, Sunday__c,
                       Thursday__c, Tuesday__c, Wednesday__c, Slot__c
                FROM hed__Time_Block__c
                WHERE  hed__Educational_Institution__c = :term.hed__Account__c AND Active__c = TRUE
                ORDER BY Slot__c ASC
            ];

            for (hed__Time_Block__c tb : commonBlocks) {
                if(tb.Break__c == false){
                    if(!blocks.contains(tb)){
                        blocks.add(tb);
                        blockMap.put(tb.Id, tb);
                    }
                } else {
                    if(!breakBlocks.contains(tb)){
                        breakBlocks.add(tb);
                    }

                }
            }

            // To Queary all the sections and batches and groups related to the current semester except open electives
            List<hed__Term__c> sections = [
                SELECT Id, Name, hed__Parent_Term__c, RecordType.Name,Section_Number__c,Section_Name__c,Course_Offering__r.Category__c,
                Course_Offering__r.Parent_Course_Offering__c
                FROM hed__Term__c
                WHERE (hed__Parent_Term__c = :term.Id OR hed__Parent_Term__r.hed__Parent_Term__c = :term.Id)
                AND RecordType.Name IN ('Sections', 'Batches', 'Group Allocation')
                AND course_Offering__r.hed__Course__r.Category__c != 'Open Elective' WITH USER_MODE
                ORDER BY Name ASC
            ];
            Map<Id, hed__Term__c> sectionMap = new Map<Id, hed__Term__c>(sections);

            // Get the all lab and classroom Facilities related to the current semester school
            List<hed__Facility__c> labFacilities = new List<hed__Facility__c>();
            List<hed__Facility__c> theoryFacilities = new List<hed__Facility__c>();
            Map<Id,String> facilityMap = new Map<Id,String>();
            for (hed__Facility__c f : [SELECT Id, Name,hed__Facility_Type__c,Block__c,Room__c, RecordType.Name FROM hed__Facility__c WHERE hed__Account__c = :term.hed__Account__r.ParentId AND Block__c != null AND Room__c != null AND hed__Facility_Type__c IN ('Laboratory','Classroom') WITH USER_MODE]) {
                String blockAndRoom = f.Block__c + ' - ' + f.Room__c;
                facilityMap.put(f.Id,blockAndRoom);
             if(f.hed__Facility_Type__c == 'Laboratory'){
                    labFacilities.add(f);
             }
              if (f.hed__Facility_Type__c == 'Classroom'){
                theoryFacilities.add(f);

             }
            }

            // All Faculty Course Connections related to the current semester's sections,batches and groups
            List<hed__Course_Enrollment__c> facultyConnections = [
                SELECT Id, hed__Course_Offering__c, hed__Course_Offering__r.Name, hed__Course_Offering__r.Category__c,hed__Contact__r.Name,hed__Contact__r.Email,
                       Section__r.hed__Parent_Term__c, hed__Course_Offering__r.hed__Course__r.Credit_Hours__c,
                       hed__Course_Offering__r.hed__Course__r.Category__c, hed__Course_Offering__r.Parent_Course_Offering__c,
                       hed__Contact__c, Section__c, Section__r.Name,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Primary__c
                FROM hed__Course_Enrollment__c
                WHERE (Section__r.hed__Parent_Term__c = :term.Id OR Section__r.hed__Parent_Term__r.hed__Parent_Term__c = :term.Id)
                AND RecordType.Name = 'Faculty' and hed__Contact__c != null and Section__c != null and hed__Course_Offering__c != null
                AND hed__Course_Offering__r.hed__Course__r.Category__c != 'Open Elective' WITH USER_MODE
            ];

            Map<Id,List<hed__Course_Enrollment__c>> facultyConnAccByoffering = new Map<Id,List<hed__Course_Enrollment__c>>();

            List<hed__Course_Enrollment__c> facultyConnectionsAcross = [
                SELECT Id, hed__Course_Offering__c, hed__Course_Offering__r.Name, hed__Course_Offering__r.Category__c,hed__Contact__r.Name,hed__Contact__r.Email,
                       Section__r.hed__Parent_Term__c, hed__Course_Offering__r.hed__Course__r.Credit_Hours__c,
                       hed__Course_Offering__r.hed__Course__r.Category__c, hed__Course_Offering__r.Parent_Course_Offering__c,
                       hed__Contact__c, Section__c, Section__r.Name,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c
                FROM hed__Course_Enrollment__c
                WHERE (Section__r.hed__Parent_Term__r.Active__c = true OR Section__r.hed__Parent_Term__r.hed__Parent_Term__r.Active__c = true)
                AND RecordType.Name = 'Faculty' and Active_Connection__c = true  and hed__Contact__c != null and Section__c != null and hed__Course_Offering__c != null
                AND hed__Course_Offering__r.Course_Offering_Active__c = true
                 WITH USER_MODE
            ];

            for(hed__Course_Enrollment__c fcAcross : facultyConnectionsAcross){
                if (fcAcross.Section__c == null) {
                    continue;
                }

                Id oid = fcAcross.hed__Course_Offering__c;
                if (oid == null) {
                    continue;
                }

                if(!facultyConnAccByoffering.containsKey(oid)){
                    facultyConnAccByoffering.put(oid,new List<hed__Course_Enrollment__c>());

                }
                facultyConnAccByoffering.get(oid).add(fcAcross);
            }

            // Process Dates - Build blackout dates and date-to-day mapping basec on exams
            Set<Date> blackoutDates = new Set<Date>();
            addDateRange(blackoutDates, term.IA_1_Start_date__c, term.IA_1_End_date__c);
            addDateRange(blackoutDates, term.IA_2_Start_date__c, term.IA_2_End_date__c);
            addDateRange(blackoutDates, term.Exam_Start_Date__c, term.Exam_End_date__c);

            Map<Date, String> dateToDay = new Map<Date, String>();
            Map<String, List<Date>> dayToDatesMap = new Map<String, List<Date>>();
            Map<String, List<Date>> firstWeekMap = new Map<String, List<Date>>();

            List<String> weekdays = new List<String>{
                'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
            };

            // Prepare both maps
            for (String day : weekdays) {
                dayToDatesMap.put(day, new List<Date>());
                firstWeekMap.put(day, new List<Date>());
            }

            Date currentDate = term.hed__Start_Date__c;

            // Counter to track first 7 days
            Integer firstWeekCounter = 0;

            if (currentDate != null) {

                while (currentDate <= term.hed__End_Date__c) {

                    if (!blackoutDates.contains(currentDate)) {

                        String dayName = DateTime.newInstance(currentDate, Time.newInstance(0,0,0,0))
                                                 .format('EEEE');

                        // --- Full semester mapping ---
                        dateToDay.put(currentDate, dayName);
                        dayToDatesMap.get(dayName).add(currentDate);

                        // --- First 7 days mapping (inside same loop) ---
                        if (firstWeekCounter < 7) {
                            firstWeekMap.get(dayName).add(currentDate);
                            firstWeekCounter++;
                        }
                    }

                    currentDate = currentDate.addDays(1);
                }
            }

            // Day -> blocks map
            Map<String, List<hed__Time_Block__c>> dayToBlocks = new Map<String, List<hed__Time_Block__c>>();
            Map<String, List<hed__Time_Block__c>> dayToBreakBlocks = new Map<String, List<hed__Time_Block__c>>();
            for (String day : weekdays) {

                if(!blocks.isEmpty()){
                    List<hed__Time_Block__c> listDay = new List<hed__Time_Block__c>();
                    for (hed__Time_Block__c tb : blocks) {
                        if (applies(day, tb)) {
                            listDay.add(tb);
                        }
                    }
                    dayToBlocks.put(day, listDay);
                }

                if(!breakBlocks.isEmpty()){
                    List<hed__Time_Block__c> listDay2 = new List<hed__Time_Block__c>();
                    for (hed__Time_Block__c tb : breakBlocks) {
                        if (applies(day, tb)) {
                            listDay2.add(tb);
                        }
                    }
                    dayToBreakBlocks.put(day, listDay2);
                }
            }

            // Create map for course details
            Map<Id, String> offeringName = new Map<Id, String>();
            Map<Id, Integer> offeringCredits = new Map<Id, Integer>();
            Map<Id, String> offeringCategory = new Map<Id, String>();
            Map<Id, String> courseCategory = new Map<Id, String>();
            Map<Id, Id> offeringParent = new Map<Id, Id>();
            Map<Id,List<hed__Course_Enrollment__c>> facultyConnByoffering = new Map<Id,List<hed__Course_Enrollment__c>>();

            Map<String, Id> contactIdToEmail = new Map<String, Id>();
            Map<Id, List<hed__Course_Enrollment__c>> sectionToFCs = new Map<Id, List<hed__Course_Enrollment__c>>();
            Set<Id> contactIds = new Set<Id>();
            List<hed__Course_Enrollment__c> peConnections = new List<hed__Course_Enrollment__c>();

            for (hed__Course_Enrollment__c fc : facultyConnections) {

                if (fc.Section__c == null) {
                    continue;
                }

                Id oid = fc.hed__Course_Offering__c;
                if (oid == null) {
                    continue;
                }

                if(!facultyConnByoffering.containsKey(oid)){
                    facultyConnByoffering.put(oid,new List<hed__Course_Enrollment__c>());

                }
                facultyConnByoffering.get(oid).add(fc);

                if (!sectionToFCs.containsKey(fc.Section__c)) {
                    sectionToFCs.put(fc.Section__c, new List<hed__Course_Enrollment__c>());
                }
                sectionToFCs.get(fc.Section__c).add(fc);
                if (fc.hed__Contact__c != null) {
                    contactIds.add(fc.hed__Contact__c);
                }

                if(fc.hed__Contact__r != null || fc.hed__Contact__r.Email != null){
                    contactIdToEmail.put(fc.hed__Contact__r.Email,fc.hed__Contact__c);
                }


                if (!offeringName.containsKey(oid)) {
                    offeringName.put(oid, fc.hed__Course_Offering__r?.Name);
                }
                if (!offeringCategory.containsKey(oid)) {
                    offeringCategory.put(oid, fc.hed__Course_Offering__r?.Category__c);
                }
                if (!offeringParent.containsKey(oid)) {
                    offeringParent.put(oid, fc.hed__Course_Offering__r?.Parent_Course_Offering__c);
                }
                if (!courseCategory.containsKey(oid)) {
                    courseCategory.put(oid, fc.hed__Course_Offering__r?.hed__Course__r?.Category__c);
                }
                if (!offeringCredits.containsKey(oid)) {
                    Integer cr2 = (fc.hed__Course_Offering__r?.hed__Course__r?.Credit_Hours__c != null)
                        ? Integer.valueOf(Math.round(fc.hed__Course_Offering__r.hed__Course__r.Credit_Hours__c)) : 1;
                    offeringCredits.put(oid, cr2);
                }
                if (fc.hed__Course_Offering__r.Category__c == 'Professional Elective') {
                    peConnections.add(fc);
                }

            }

            // conflict detection for professors and facilities and open electuives reservation
            Map<Id, Map<String, List<TimeInterval>>> profOccupied = new Map<Id, Map<String, List<TimeInterval>>>();
            Map<Id, Map<String, List<TimeInterval>>> facilityOccupied = new Map<Id, Map<String, List<TimeInterval>>>();
            Map<String, Map<String, Set<Id>>> reservedSDB = new Map<String, Map<String, Set<Id>>>();
            Map<String, Map<String, Set<Id>>> sectionDayBlockTaken = new Map<String, Map<String, Set<Id>>>();

            Set<Id> allSectionIds = sectionMap.keySet();

            Set<Id> sectionIds = new Set<Id>();
            Map<Id,Set<Id>> profEleparentGroupMap = new Map<Id,Set<Id>>();
            Map<Id,hed__Course_Offering__c> courseOfferingMapWithSem = new Map<Id,hed__Course_Offering__c>();
            Set<Id> sectionBatchsemIds = new Set<Id>();
            Map<Id ,List<String>> sectionWiselabWeekSuff = new Map<Id ,List<String>> ();
            Map<Id ,List<String>> groupParentOffWiseWeSuff = new Map<Id ,List<String>> ();

            Id sectionAId = null;
            for (hed__Term__c s : sections) {
                if (s.RecordType.Name != 'Group Allocation') {
                    sectionBatchsemIds.add(s.Id);
                }
                // store A section Id for assinging professional elective's sheduled record setion_c
                if(s.RecordType.Name == 'Sections' && sectionAId == null && s.Section_Name__c == 'A' && s.Section_Number__c == 1){
                    sectionAId = s.Id;
                }

                if(s.RecordType.Name == 'Sections'){
                    sectionIds.add(s.Id);
                }
                if(s.RecordType.Name == 'Group Allocation' && s.Course_Offering__r.Parent_Course_Offering__c != null && s.Course_Offering__r.Category__c == 'Professional Elective'){
                    Id parentOffId = s.Course_Offering__r.Parent_Course_Offering__c;
                    if(!profEleparentGroupMap.containsKey(parentOffId)){
                        profEleparentGroupMap.put(parentOffId,new Set<Id>());
                    }
                    profEleparentGroupMap.get(parentOffId).add(s.Id);
                    courseOfferingMapWithSem.put(s.Id,s.Course_Offering__r);


                    if (!groupParentOffWiseWeSuff.containsKey(parentOffId)) {
                        List<String>  weekDaysGroup = shuffleWeekdays(weekdays);
                        groupParentOffWiseWeSuff.put(parentOffId, weekDaysGroup);
                    }

                }
                if(s.RecordType.Name == 'Batches'){
                    Id batchParentId = s.hed__Parent_Term__c;
                      if (!sectionWiselabWeekSuff.containsKey(batchParentId)) {
                        List<String> weekdaysLab  = shuffleWeekdays(weekdays);
                    sectionWiselabWeekSuff.put(batchParentId, weekdaysLab);
                }
                }
            }

            // Get existing schedules related to the current semester's school and date > today
            List<hed__Course_Offering_Schedule__c> existingSchedules = [
                SELECT Id, Date__c, hed__Time_Block__c, hed__Start_Time__c, hed__End_Time__c,section__r.hed__Parent_Term__c,
                       Section__c, Professor__c,Professor__r.Email ,hed__Facility__c, hed__Course_Offering__c,Section__r.hed__Account__r.ParentId,
                       hed__Course_Offering__r.Category__c,Faculty_Course_Connection__c,Faculty_Course_Connection__r.Id
                FROM hed__Course_Offering_Schedule__c
               // WHERE Section__r.hed__Account__r.ParentId = :term.hed__Account__r.ParentId AND Date__c >= today
               WHERE Date__c >= today WITH USER_MODE ];
            for (hed__Course_Offering_Schedule__c ex : existingSchedules) {
                Id  exiProfessorConId = contactIdToEmail.get(ex.Professor__r.Email) != null ? contactIdToEmail.get(ex.Professor__r.Email) : ex.Faculty_Course_Connection__r.Id;
                Date exDate = ex.Date__c;
                if (ex.Section__r.hed__Account__r.ParentId == term.hed__Account__r.ParentId){
                if (exDate == null || !dateToDay.containsKey(exDate)) {
                    continue;
                }
                String day = dateToDay.get(exDate);
                Id blockId = matchBlockId(dayToBlocks, day, ex.hed__Time_Block__c, ex.hed__Start_Time__c, ex.hed__End_Time__c);
                if (blockId == null) {
                    continue;
                }
                hed__Time_Block__c blk = blockMap.get(blockId);
                if (blk == null) {
                    continue;
                }

                if (ex.hed__Facility__c != null) {
                    occupyInterval(facilityOccupied, ex.hed__Facility__c, day, blk.hed__Start_Time__c, blk.hed__End_Time__c);
                }
                // Within Semeter : If two or more professors are assigned to the same offering, occupy all of them because we are creating schedules for only one professor here

                if(facultyConnByoffering.containsKey(ex.hed__Course_Offering__c)){
                    for(hed__Course_Enrollment__c fc : facultyConnByoffering.get(ex.hed__Course_Offering__c)){
                        if(fc.hed__Contact__c != null){
                            occupyInterval(profOccupied, fc.hed__Contact__c, day, blk.hed__Start_Time__c, blk.hed__End_Time__c);
                        }
                    }

                }
                // if (ex.Professor__c != null) {
                //     occupyInterval(profOccupied, exiProfessorConId, day, blk.hed__Start_Time__c, blk.hed__End_Time__c);
                // }
                addSDB(sectionDayBlockTaken, ex.Section__c, day, blockId);

                if (ex.hed__Course_Offering__r.Category__c == 'Open Elective' && ex.section__r.hed__Parent_Term__c == term.Id) {
                    for (Id sectionId : allSectionIds) {
                        reserve(reservedSDB, sectionId, day, blockId);
                    }

                    for(Id secId : sectionIds){
                        if (!processedTBIdsSecMap.containsKey(secId)){
                            processedTBIdsSecMap.put(secId, new Set<Id>());
                        }
                        processedTBIdsSecMap.get(secId).add(blockId);
                    }


                }
              }

               // acroos all school active Semeter : If two or more professors are assigned to the same offering, occupy all of them because we are creating schedules for only one professor here
              else {
                if(facultyConnAccByoffering.containsKey(ex.hed__Course_Offering__c)){
                    for(hed__Course_Enrollment__c fc : facultyConnAccByoffering.get(ex.hed__Course_Offering__c)){
                        if(fc.hed__Contact__c != null){
                            String dayName = DateTime.newInstance(exDate, Time.newInstance(0,0,0,0)).format('EEEE');
                            occupyInterval(profOccupied, fc.hed__Contact__c, dayName, ex.hed__Start_Time__c, ex.hed__End_Time__c);
                        }
                    }
                }
                // if (ex.Professor__c != null) {

                //     String dayName = DateTime.newInstance(exDate, Time.newInstance(0,0,0,0)).format('EEEE');
                //     occupyInterval(profOccupied, exiProfessorConId, dayName, ex.hed__Start_Time__c, ex.hed__End_Time__c);

                // }
              }
            }

            Map<String, List<Map<String, Object>>> sectionWiseData = new Map<String, List<Map<String, Object>>>();
            Map<Id, List<Map<String, Object>>> facultyWiseData = new Map<Id, List<Map<String, Object>>>();
            List<String> suffWeekDays = shuffleWeekdays(weekdays);
            // Phase 1 - Professional Electives
            Map<Id ,Set<Id>> proEleProfessorMap = new Map<Id ,Set<Id>>();
            Map<Id, Map<Id, List<hed__Course_Enrollment__c>>> sectionToOfferingConnections = new Map<Id, Map<Id, List<hed__Course_Enrollment__c>>>();
            for (hed__Course_Enrollment__c fc : peConnections) {
                if (fc.Section__c == null) {
                    continue;
                }
                if (!sectionToOfferingConnections.containsKey(fc.Section__c)) {
                    sectionToOfferingConnections.put(fc.Section__c, new Map<Id, List<hed__Course_Enrollment__c>>());
                }


                Map<Id, List<hed__Course_Enrollment__c>> offeringMap = sectionToOfferingConnections.get(fc.Section__c);
                if (!offeringMap.containsKey(fc.hed__Course_Offering__c)) {
                    offeringMap.put(fc.hed__Course_Offering__c, new List<hed__Course_Enrollment__c>());
                }
                offeringMap.get(fc.hed__Course_Offering__c).add(fc);
            }

    Map<Id, Map<String, List<hed__Time_Block__c>>> parenrElectiveBlockmap = new Map<Id, Map<String, List<hed__Time_Block__c>>>();

    for (Id sectionId : sectionToOfferingConnections.keySet()) {
        String proParentId = courseOfferingMapWithSem.containsKey(sectionId)
            ? courseOfferingMapWithSem.get(sectionId).Parent_Course_Offering__c
            : null;

        List<String> weekdaysSuff = groupParentOffWiseWeSuff.containsKey(proParentId)
            ? groupParentOffWiseWeSuff.get(proParentId)
            : weekdays;

        Map<Id, List<hed__Course_Enrollment__c>> offeringMap = sectionToOfferingConnections.get(sectionId);

        for (Id offeringId : offeringMap.keySet()) {
            List<hed__Course_Enrollment__c> fcs = offeringMap.get(offeringId);
            if (fcs.isEmpty()) {
                continue;
            }

            Set<Id> profIds = new Set<Id>();
            Set<String> profNames = new Set<String>();
            for (hed__Course_Enrollment__c fc : fcs) {
                if (fc.hed__Contact__c != null) {
                    profIds.add(fc.hed__Contact__c);
                    profNames.add(fc.hed__Contact__r.Name);
                }
            }
            if (profIds.isEmpty()) {
                continue;
            }

            Integer requiredSlots = offeringCredits.get(offeringId) == null ? 1 : offeringCredits.get(offeringId);
            Integer placedSlots = 0;
            String unallocatedReason = '';
            Set<Id> usedBlockIds = new Set<Id>();

            // Try up to maxWeekCount full-week passes to fill required slots
            Integer maxWeekCount = 2;
            Integer weekCount = 0;

            while (placedSlots < requiredSlots && weekCount < maxWeekCount) {
                for (String day : weekdaysSuff) {
                    if (placedSlots >= requiredSlots){

                     break;
                    }

                    List<hed__Time_Block__c> dayBlocks = dayToBlocks.get(day);
                    if (dayBlocks == null || dayBlocks.isEmpty()) {
                        continue;
                    }

                    // If parent has blocks for this day, attempt to reuse them first.
                    List<hed__Time_Block__c> candidateBlocks = null;
                    if (parenrElectiveBlockmap.containsKey(proParentId)
                        && parenrElectiveBlockmap.get(proParentId).containsKey(day)) {

                        // parent's blocks for the same day
                        candidateBlocks = new List<hed__Time_Block__c>(parenrElectiveBlockmap.get(proParentId).get(day));
                    } else {
                        // fresh shuffled blocks for this day
                        candidateBlocks = shuffleBlocks(new List<hed__Time_Block__c>(dayBlocks));
                    }

                    // If parent blocks exist but professors are not free on some of them, we will try them (skip busy ones)
                    Boolean dayPlaced = false;
                    for (hed__Time_Block__c blk : candidateBlocks) {
                        // don't reuse a block already used for this offering in this run
                        if (usedBlockIds.contains(blk.Id)) {
                            continue;
                        }

                        String blockDay = day;
                        String blkActiveDay = getActiveDayName(blk);
                        if (blkActiveDay != null) {
                            blockDay = blkActiveDay;
                        }

                        Boolean profsFree = true;
                        for (Id pid : profIds) {
                            if (!isAvailable(pid, null, blk, blockDay, profOccupied, facilityOccupied)) {
                                profsFree = false;
                                break;
                            }
                        }
                        if (!profsFree) {
                            continue;
                        }

                        // check facility availability
                        Id facId = findAvailableFacility(theoryFacilities, profIds, blk, blockDay, profOccupied, facilityOccupied);
                        if (facId == null) {
                            // no facility for this block — skip
                            continue;
                        }

                        // check reservation/taken for this section (if parent reuse, allow reuse only if same-day parent block isn't exclusively taken)
                        if (isTakenSDB(sectionDayBlockTaken, sectionId, blockDay, blk.Id) ||
                            isReserved(reservedSDB, sectionId, blockDay, blk.Id)) {
                            continue;
                        }

                        // OK — allocate this block
                        for (Id profId : profIds) {
                            book(profOccupied, facilityOccupied, profId, facId, blk, blockDay);
                        }
                        addSDB(sectionDayBlockTaken, sectionId, blockDay, blk.Id);

                        // Reserve for other related sections
                        Set<Id> otherGroupSectionIds = new Set<Id>();
                        for (Id keyParentId : profEleparentGroupMap.keySet()) {
                            if (keyParentId != proParentId) {
                                otherGroupSectionIds.addAll(profEleparentGroupMap.get(keyParentId));
                            }
                        }
                        otherGroupSectionIds.addAll(sectionBatchsemIds);
                        for (Id sId : otherGroupSectionIds) {
                            reserve(reservedSDB, sId, blockDay, blk.Id);
                        }

                        // Output entries

                        // selection of correct faculty connection
                        hed__Course_Enrollment__c selectedFC;

                        // Only one pass — fastest possible
                        for (hed__Course_Enrollment__c fc : fcs) {
                            if (selectedFC == null) {
                                selectedFC = fc;
                            }
                            if (fc.hed__Primary__c == true) {
                                selectedFC = fc;
                                break;
                            }
                        }
                        for (Date schedDate : firstWeekMap.get(blockDay)) {
                           // for (hed__Course_Enrollment__c fc : fcs) {
                                addOutput(selectedFC, sectionWiseData, facultyWiseData,
                                    blk, schedDate, sectionId, offeringId, facId,
                                    'Locked', 'Professional Elective', sectionAId);
                           // }
                        }

                        // Save into parent map (by day) for future reuse
                        if (proParentId != null) {
                            if (!parenrElectiveBlockmap.containsKey(proParentId)) {
                                parenrElectiveBlockmap.put(proParentId, new Map<String, List<hed__Time_Block__c>>());
                            }
                            if (!parenrElectiveBlockmap.get(proParentId).containsKey(blockDay)) {
                                parenrElectiveBlockmap.get(proParentId).put(blockDay, new List<hed__Time_Block__c>());
                            }
                            parenrElectiveBlockmap.get(proParentId).get(blockDay).add(blk);

                            if (!proEleProfessorMap.containsKey(proParentId)) {
                                proEleProfessorMap.put(proParentId, new Set<Id>());
                            }
                            proEleProfessorMap.get(proParentId).addAll(profIds);
                        }
                        //processedTBIds.add(blk.Id);
                        for(Id secId : sectionIds){
                            if (!processedTBIdsSecMap.containsKey(secId)){
                                processedTBIdsSecMap.put(secId, new Set<Id>());
                            }
                            processedTBIdsSecMap.get(secId).add(blk.Id);
                        }

                        usedBlockIds.add(blk.Id);
                        placedSlots++;
                        dayPlaced = true;
                        break; // go to next required slot
                    }

                    if (placedSlots >= requiredSlots) {
                        break;
                    }

                }

                weekCount++;
            }

            if (placedSlots < requiredSlots) {
                result.unallocatedCourses.add(new Map<String, Object>{
                    'connectionId' => fcs[0].Id,
                    'placedSlots' => placedSlots,
                    'professorIds' => new Set<Id>(profIds),
                    'professorNames' => (profNames != null && !profNames.isEmpty())
                        ? String.join(new List<String>(profNames), ' / ')
                        : '',
                    'sectionId' => sectionId,
                    'sectionName' => fcs[0].Section__r.Name,
                    'courseOfferingId' => offeringId,
                    'courseName' => offeringName.get(offeringId),
                    'reason' => String.isNotBlank(unallocatedReason)
                        ? unallocatedReason + ' - ' + (requiredSlots - placedSlots) + ' Slots required'
                        : 'Could not find ' + (requiredSlots - placedSlots) + ' free slot(s) across the week.'
                });
            }
        }
    }



    // Phase 2 - Labs (Two contiguous slots)
    for (hed__Term__c section : sections) {
        if (section.RecordType?.Name != 'Batches') {
            continue;
        }

        Id sectionId = section.Id;
        List<String> weekdaysSuff = sectionWiselabWeekSuff.containsKey(section.hed__Parent_Term__c)
            ? sectionWiselabWeekSuff.get(section.hed__Parent_Term__c)
            : weekdays;

        // Collect all lab course enrollments for this section
        Map<Id, List<hed__Course_Enrollment__c>> offeringToLabs = new Map<Id, List<hed__Course_Enrollment__c>>();
        if (sectionToFCs.containsKey(sectionId)) {
            for (hed__Course_Enrollment__c fc : sectionToFCs.get(sectionId)) {
                if (fc.hed__Course_Offering__r?.Category__c == 'Practical/Term Work') {
                    if (!offeringToLabs.containsKey(fc.hed__Course_Offering__c)){
                        offeringToLabs.put(fc.hed__Course_Offering__c, new List<hed__Course_Enrollment__c>());
                    }
                    offeringToLabs.get(fc.hed__Course_Offering__c).add(fc);
                }
            }
        }

        Set<String> daysWithLab = new Set<String>();

        // Loop through each lab offering
        for (Id offeringId : offeringToLabs.keySet()) {
            List<hed__Course_Enrollment__c> labConnections = offeringToLabs.get(offeringId);
            if (labConnections.isEmpty()) {
                continue;
            }

            Set<Id> profIds = new Set<Id>();
            Set<String> profNames = new Set<String>();
            for (hed__Course_Enrollment__c fc : labConnections) {
                if (fc.hed__Contact__c != null) {
                    profIds.add(fc.hed__Contact__c);
                    profNames.add(fc.hed__Contact__r.Name);
                }
            }
            if (profIds.isEmpty()) {
                continue;
            }

            Integer creditHours = offeringCredits.get(offeringId) != null ? offeringCredits.get(offeringId) : 2;
            Integer totalRequiredSlots = ((Integer)Math.ceil((Decimal)creditHours / 2)) * 2;
            Integer placedSlots = 0;
            Set<Id> usedBlockIds = new Set<Id>();

            Integer weekCount = 0;
            Integer maxWeeks = 2; // prevent infinite looping

            // 🔁 Keep trying until we fill required slots or reach week limit
            while (placedSlots < totalRequiredSlots && weekCount < maxWeeks) {
                Boolean anyPlacedThisWeek = false;

                for (String day : weekdaysSuff) {
                    if (placedSlots >= totalRequiredSlots) {
                        break;
                    }

                    List<hed__Time_Block__c> db = dayToBlocks.get(day);
                    if (db == null || db.size() < 2 || daysWithLab.contains(day)) {
                        continue;
                    }

                    // Check pairs of continuous blocks
                    for (Integer i = 0; i < db.size() - 1; i++) {
                        hed__Time_Block__c b1 = db[i];
                        hed__Time_Block__c b2 = db[i + 1];

                        if (usedBlockIds.contains(b1.Id) || usedBlockIds.contains(b2.Id)) {
                            continue;
                        }

                        // Ensure contiguous (≤ 15 min gap)
                        DateTime dt1End = DateTime.newInstance(Date.today(), b1.hed__End_Time__c);
                        DateTime dt2Start = DateTime.newInstance(Date.today(), b2.hed__Start_Time__c);
                        if ((dt2Start.getTime() - dt1End.getTime()) > (15 * 60 * 1000)) {
                            continue;
                        }

                        // ✅ Use your optimized facility + professor availability logic
                        Id facId = findAvailableFacility(labFacilities, profIds, b1, day, profOccupied, facilityOccupied);
                        // Check also for the 2nd block
                        if (facId == null || !isFacilityAvailable(facId, b2, day, facilityOccupied)) {
                            continue;
                        }

                        // If any block is already taken or reserved, skip
                        if (isReserved(reservedSDB, sectionId, day, b1.Id) ||
                            isTakenSDB(sectionDayBlockTaken, sectionId, day, b1.Id) ||
                            isReserved(reservedSDB, sectionId, day, b2.Id) ||
                            isTakenSDB(sectionDayBlockTaken, sectionId, day, b2.Id)) {
                            continue;
                        }

                        // Book both blocks for professors + facility
                        for (Id profId : profIds) {
                            book(profOccupied, facilityOccupied, profId, facId, b1, day);
                            book(profOccupied, facilityOccupied, profId, facId, b2, day);
                        }

                        addSDB(sectionDayBlockTaken, sectionId, day, b1.Id);
                        addSDB(sectionDayBlockTaken, sectionId, day, b2.Id);
                        reserve(reservedSDB, section.hed__Parent_Term__c, day, b1.Id);
                        reserve(reservedSDB, section.hed__Parent_Term__c, day, b2.Id);

                        hed__Course_Enrollment__c selectedFC;

                        // Only one pass — fastest possible
                        for (hed__Course_Enrollment__c fc : labConnections) {
                            if (selectedFC == null) {
                                selectedFC = fc;
                            }
                            if (fc.hed__Primary__c == true) {
                                selectedFC = fc;
                                break;
                            }
                        }

                        // Output timetable entries for both blocks
                        for (Date schedDate : firstWeekMap.get(day)) {
                           // for (hed__Course_Enrollment__c fc : labConnections) {
                                addOutput(selectedFC, sectionWiseData, facultyWiseData, b1, schedDate,
                                    sectionId, offeringId, facId, 'Locked', 'Lab', null);
                                addOutput(selectedFC, sectionWiseData, facultyWiseData, b2, schedDate,
                                    sectionId, offeringId, facId, 'Locked', 'Lab', null);
                            //}
                        }

                        if (!processedTBIdsSecMap.containsKey(section.hed__Parent_Term__c)){
                            processedTBIdsSecMap.put(section.hed__Parent_Term__c, new Set<Id>());
                        }
                        processedTBIdsSecMap.get(section.hed__Parent_Term__c).add(b1.Id);
                        processedTBIdsSecMap.get(section.hed__Parent_Term__c).add(b2.Id);

                        // Mark day and blocks as used
                        daysWithLab.add(day);
                        usedBlockIds.addAll(new Set<Id>{ b1.Id, b2.Id });
                        placedSlots += 2;
                        anyPlacedThisWeek = true;
                        break;
                    }
                }

                // Stop looping if we couldn’t place any pair in this weekCount
                if (!anyPlacedThisWeek) {
                    break;
                }
                weekCount++;
            }

            // If lab slots could not be fully allocated
            if (placedSlots < totalRequiredSlots) {
                result.unallocatedCourses.add(new Map<String, Object>{
                    'connectionId' => labConnections[0].Id,
                    'placedSlots' => placedSlots,
                    'professorIds' => new Set<Id>(profIds),
                    'professorNames' => (profNames != null && !profNames.isEmpty())
                        ? String.join(new List<String>(profNames), ' / ')
                        : '',
                    'sectionId' => sectionId,
                    'sectionName' => section.Name,
                    'courseOfferingId' => offeringId,
                    'courseName' => offeringName.get(offeringId),
                    'reason' => 'Could not allocate ' + (totalRequiredSlots - placedSlots) +
                                ' contiguous lab slot(s). Facility or professor unavailable.'
                });
            }
        }
    }



            // Phase 3: Remaining Theory Courses(Hardcore ,Hordcore Integrated, Mandatory..,)
            for (hed__Term__c section : sections) {
                if (section.RecordType?.Name != 'Sections') {
                    continue;
                }
                Id sid = section.Id;
                List<hed__Course_Enrollment__c> fcs = sectionToFCs.get(sid);
                if (fcs == null) {
                    continue;
                }

                Map<Id, List<hed__Course_Enrollment__c>> offeringToFcs = new Map<Id, List<hed__Course_Enrollment__c>>();
                for (hed__Course_Enrollment__c fc : fcs) {
                    String cat = offeringCategory.get(fc.hed__Course_Offering__c);
                    String crsCat = courseCategory.get(fc.hed__Course_Offering__c);
                    if (cat == 'Professional Elective' || cat == 'Practical/Term Work' || crsCat == 'Practical/Term Work') {
                        continue;
                    }
                    if (!offeringToFcs.containsKey(fc.hed__Course_Offering__c)){
                        offeringToFcs.put(fc.hed__Course_Offering__c, new List<hed__Course_Enrollment__c>());
                    }
                    offeringToFcs.get(fc.hed__Course_Offering__c).add(fc);
                }

                for (Id offeringId : offeringToFcs.keySet()) {
                    List<hed__Course_Enrollment__c> courseFcs = offeringToFcs.get(offeringId);
                    if (courseFcs.isEmpty()) {
                        continue;
                    }

                    Set<Id> profIds = new Set<Id>();
                    Set<String> profNames = new Set<String>();
                    for (hed__Course_Enrollment__c fc : courseFcs) {
                        if (fc.hed__Contact__c != null) {
                            profIds.add(fc.hed__Contact__c);
                            profNames.add(fc.hed__Contact__r.Name);
                        }
                    }
                    if (profIds.isEmpty()) {
                        continue;
                    }

                    Integer requiredSlots = offeringCredits.get(offeringId) == null ? 1 : offeringCredits.get(offeringId);
                    Integer slotsAllocated = 0;
                    String unallottedReason = '';
                    Set<Id> usedBlockIds = new Set<Id>();

                    for (String day : suffWeekDays) {
                        if (slotsAllocated >= requiredSlots) {
                            break;
                        }
                        List<hed__Time_Block__c> timeBlocks = dayToBlocks.get(day);
                        if (timeBlocks == null || timeBlocks.isEmpty()) {
                            unallottedReason = 'No time blocks available in a week';
                            continue;
                        }

                        Boolean slotBookedThisDay = false;
                        // Randomize block order for this day
                        timeBlocks = shuffleBlocks(timeBlocks);
                        for (hed__Time_Block__c blk : timeBlocks) {
                            if (usedBlockIds.contains(blk.Id)) {
                                continue;
                            }

                            Id facId = findAvailableFacility(theoryFacilities, profIds, blk, day, profOccupied, facilityOccupied);
                            if (facId == null) {
                                unallottedReason = 'No facility available or professors busy';
                                continue;
                            }
                            if (isReserved(reservedSDB, sid, day, blk.Id) || isTakenSDB(sectionDayBlockTaken, sid, day, blk.Id)) {
                                unallottedReason = 'Slots already taken or reserved';
                                continue;
                            }

                            for (Id profId : profIds) {
                                book(profOccupied, facilityOccupied, profId, facId, blk, day);
                            }
                            addSDB(sectionDayBlockTaken, sid, day, blk.Id);

                            hed__Course_Enrollment__c selectedFC;

                            // Only one pass — fastest possible
                            for (hed__Course_Enrollment__c fc : courseFcs) {
                                if (selectedFC == null) {
                                    selectedFC = fc;
                                }
                                if (fc.hed__Primary__c == true) {
                                    selectedFC = fc;
                                    break;
                                }
                            }
                            for (Date schedDate : firstWeekMap.get(day)) {
                               // for (hed__Course_Enrollment__c fc : courseFcs) {
                                    addOutput(selectedFC,sectionWiseData, facultyWiseData, blk, schedDate, sid, offeringId, facId, 'Locked', 'section',null);
                               // }
                            }
                            // Mark this time block as used for this course (avoid same slot again)
                            if (!processedTBIdsSecMap.containsKey(sid)){
                                processedTBIdsSecMap.put(sid, new Set<Id>());
                            }
                            processedTBIdsSecMap.get(sid).add(blk.Id);

                            slotsAllocated++;
                            slotBookedThisDay = true;
                            break;
                        }
                    }

                    if (slotsAllocated < requiredSlots) {
                        result.unallocatedCourses.add(new Map<String, Object>{
                            'connectionId' => courseFcs[0].Id,
                            'placedSlots' => slotsAllocated,
                            'professorIds' => new Set<Id>(profIds),
                            'professorNames' => (profNames != null && !profNames.isEmpty())
                            ? String.join(new List<String>(profNames), ' / ')
                            : '',
                            'sectionId' => sid, 'sectionName' => section.Name,
                            'courseOfferingId' => offeringId, 'courseName' => offeringName.get(offeringId),
                            'reason' => 'Could not allocate ' + (requiredSlots - slotsAllocated) + ' slot(s). ' + (String.isNotBlank(unallottedReason) ? unallottedReason : 'No free slots or facility unavailable.')
                        });
                    }
                }
            }

            // Create Break allocation based on the break slots b/w Semester start and end dates
            for (hed__Term__c s : sections) {
                 if(s.RecordType?.Name == 'Group Allocation' || s.RecordType?.Name == 'Batches') {
                    continue;
                 }
                for (String day : weekdays) {
                 List<hed__Time_Block__c> breakTimeBlocks = dayToBreakBlocks.get(day);
                        if (breakTimeBlocks == null || breakTimeBlocks.isEmpty()) {
                            continue;
                        }
                for (hed__Time_Block__c blk : breakTimeBlocks) {
                    if ( isTakenSDB(sectionDayBlockTaken, s.Id, day, blk.Id)) {
                        continue;
                    }
                      addSDB(sectionDayBlockTaken, s.Id, day, blk.Id);
                    for (Date schedDate : firstWeekMap.get(day)) {

                     addOutput(new hed__Course_Enrollment__c(),sectionWiseData, facultyWiseData, blk, schedDate, s.Id, null, null, 'Locked', 'Break',null);

                    }
                    if (!processedTBIdsSecMap.containsKey(s.Id)){
                        processedTBIdsSecMap.put(s.Id, new Set<Id>());
                    }
                    processedTBIdsSecMap.get(s.Id).add(blk.Id);
                    //processedTBIds.add(blk.Id);
                }
            }
            }



        // Phase 4: Backfill Unallocated Courses(Pnly for professor elective and theory courses)

            List<Map<String, Object>> stillUnallocated = new List<Map<String, Object>>();

            // Iterate over the courses that were unallocated in the previous phases
            for (Map<String, Object> unallocatedCourse : result.unallocatedCourses) {
                Id sectionId = (Id)unallocatedCourse.get('sectionId');
                Id offeringId = (Id)unallocatedCourse.get('courseOfferingId');
                Set<Id> profIds = (Set<Id>)unallocatedCourse.get('professorIds');
                Integer requiredSlots = offeringCredits.get(offeringId) == null ? 1 : offeringCredits.get(offeringId); // Assuming single slots for simplicity
                Integer placedSlots = (Integer)unallocatedCourse.get('placedSlots');
                String courseOfferingCategory = offeringCategory.get(offeringId);
                String courseType = (courseOfferingCategory == 'Practical/Term Work') ? 'Lab' : (courseOfferingCategory == 'Professional Elective') ?'Professional Elective' :'Theory';

                List<hed__Course_Enrollment__c> courseFcs = new List<hed__Course_Enrollment__c>();
                if (sectionToFCs.containsKey(sectionId)) {
                    for(hed__Course_Enrollment__c fc : sectionToFCs.get(sectionId)) {
                        if(fc.hed__Course_Offering__c == offeringId) {
                            courseFcs.add(fc);
                        }
                    }
                }

                if(courseFcs.isEmpty()) {
                    stillUnallocated.add(unallocatedCourse);
                    continue;
                }

                String currentReason = '';

                if (courseType == 'Theory' || courseType == 'Professional Elective') {
                    for (String day : weekdays) {
                        if (placedSlots >= requiredSlots) {
                            break;
                        }
                        List<hed__Time_Block__c> timeBlocks = dayToBlocks.get(day);
                        if (timeBlocks == null || timeBlocks.isEmpty()) {
                            continue;
                        }
                        timeBlocks = shuffleBlocks(timeBlocks);

                        for (hed__Time_Block__c blk : timeBlocks) {
                            if (placedSlots >= requiredSlots) {
                                break;
                            }
                            Id facId = findAvailableFacility(theoryFacilities, profIds, blk, day, profOccupied, facilityOccupied);
                            if (facId == null) {
                                currentReason = 'No facility available or professors busy ';
                                continue;
                            }

                            if (isReserved(reservedSDB, sectionId, day, blk.Id) || isTakenSDB(sectionDayBlockTaken, sectionId, day, blk.Id)) {
                                currentReason = 'Slot already taken or reserved ';
                                continue;
                            }
                            for (Id profId : profIds) {
                                book(profOccupied, facilityOccupied, profId, facId, blk, day);
                            }
                            addSDB(sectionDayBlockTaken, sectionId, day, blk.Id);
                            if(courseType == 'Professional Elective') {
                                for (Id sId : sectionBatchsemIds) {
                                    reserve(reservedSDB, sId, day, blk.Id);
                                }
                            }

                            hed__Course_Enrollment__c selectedFC;

                            // Only one pass — fastest possible
                            for (hed__Course_Enrollment__c fc : courseFcs) {
                                if (selectedFC == null) {
                                    selectedFC = fc;
                                }
                                if (fc.hed__Primary__c == true) {
                                    selectedFC = fc;
                                    break;
                                }
                            }
                            for (Date schedDate : firstWeekMap.get(day)) {
                               // for (hed__Course_Enrollment__c fc : courseFcs) {
                                   addOutput(selectedFC, sectionWiseData, facultyWiseData, blk, schedDate, sectionId, offeringId, facId, 'Locked', 'section',null); // need to change parameter
                               // }
                            }
                        if(courseType == 'Professional Elective') {
                            for(Id secId : sectionIds){
                                if (!processedTBIdsSecMap.containsKey(secId)){
                                    processedTBIdsSecMap.put(secId, new Set<Id>());
                                }
                                processedTBIdsSecMap.get(secId).add(blk.Id);
                            }
                        } else {
                            if (!processedTBIdsSecMap.containsKey(sectionId)){
                                processedTBIdsSecMap.put(sectionId, new Set<Id>());
                            }
                            processedTBIdsSecMap.get(sectionId).add(blk.Id);
                        }


                            placedSlots++;
                        }
                    }
                }
                if (placedSlots < requiredSlots) {
                    unallocatedCourse.put('reason',  (requiredSlots - placedSlots) + ' slot(s) are required ,' + (String.isNotBlank(currentReason) ? currentReason : 'No free slots or facility unavailable .'));
                    stillUnallocated.add(unallocatedCourse);
                }
            }

            // sectionWiseData OR any map where you have all sectionIds
            for (Id sectionId : processedTBIdsSecMap.keySet()) {

                Set<Id> usedBlocks = processedTBIdsSecMap.get(sectionId);

                for (hed__Time_Block__c tb : commonBlocks) {
                    String blkActiveDay = getActiveDayName(tb);

                    // If block not used for this section → add Free Slot
                    if (!usedBlocks.contains(tb.Id)) {
                        for (Date schedDate : firstWeekMap.get(blkActiveDay)) {
                        addOutput(
                            new hed__Course_Enrollment__c(),
                            sectionWiseData,
                            facultyWiseData,
                            tb,
                            schedDate,
                            sectionId,
                            null,
                            null,
                            'Locked',
                            'Free_Slot',
                            null
                        );
                    }
                    }
                }
            }


            //Replace the main unallocated list with the courses that remain unallocated after backfilling
            result.unallocatedCourses = stillUnallocated;
            result.dayToDatesMap = dayToDatesMap;


            return processSectionWiseAllocationData(result, dayToBlocks, sectionMap, offeringName, sectionWiseData, facultyWiseData, contactIds,commonBlocks,weekdays,sections,facilityMap);

        }

        private static TimetableData processSectionWiseAllocationData(
            TimetableData result,
            Map<String, List<hed__Time_Block__c>> dayToBlocks,
            Map<Id, hed__Term__c> sectionMap,
            Map<Id, String> offeringName,
            Map<String, List<Map<String, Object>>> sectionWiseData,
            Map<Id, List<Map<String, Object>>> facultyWiseData,
            Set<Id> contactIds,
            List<hed__Time_Block__c> commonBlocks,
            List<String> weekdays,
            List<hed__Term__c> sections,
            Map<Id,String> facilityMap
        ) {
            // Query contacts once
            Map<Id, Contact> contactById = new Map<Id, Contact>(
                [SELECT Id, Name FROM Contact WHERE Id IN :contactIds WITH USER_MODE]
            );

            Map<String, List<Map<String, Object>>> sectionWiseByName =
                new Map<String, List<Map<String,Object>>>();

            for (String secKey : sectionWiseData.keySet()) {
                Map<String, Set<String>> courseToFacultyNames = new Map<String, Set<String>>();
                Map<String, Set<Id>> courseToFacultyIds = new Map<String, Set<Id>>();

                List<Map<String,Object>> schedules = sectionWiseData.get(secKey);

                for (Map<String,Object> sch : schedules) {
                    String rawCourse = String.valueOf(sch.get('hed__Course_Offering__c'));

                    Boolean isBreak = (rawCourse == null || rawCourse == 'Break');
                    Boolean isFreeSlot = (rawCourse == null || rawCourse == 'Free_Slot');

                    Id courseId = (!isBreak && !isFreeSlot && rawCourse != null && rawCourse.length() == 18)
                                    ? (Id) rawCourse : null;

                    String rawProf = String.valueOf(sch.get('Professor__c'));
                    Id profId = (rawProf != null && rawProf.length() == 18)
                                 ? (Id) rawProf : null;

                    String rawFacility = String.valueOf(sch.get('hed__Facility__c'));
                    Id facilityId = (rawFacility != null && rawFacility.length() == 18)
                                     ? (Id) rawFacility : null;

                    String facultyName = (profId != null && contactById.containsKey(profId))
                                        ? contactById.get(profId).Name : null;

                    if (isBreak) {
                        sch.put('CourseName', 'Break');
                    }
                    else if (isFreeSlot){
                        sch.put('CourseName', 'Free_Slot');
                    }
                    else {
                        if (!courseToFacultyNames.containsKey(rawCourse)) {
                            courseToFacultyNames.put(rawCourse, new Set<String>());
                            courseToFacultyIds.put(rawCourse, new Set<Id>());
                        }

                        if (facultyName != null) {
                            courseToFacultyNames.get(rawCourse).add(facultyName);
                        }
                        if (profId != null) {
                            courseToFacultyIds.get(rawCourse).add(profId);
                        }

                        sch.put('CourseName', offeringName.get(courseId));
                        sch.put('FacilityName', facilityMap.get(facilityId));
                    }
                    sch.put('timeBlockId', sch.get('hed__Time_Block__c'));
                    sch.put('startTime', sch.get('hed__Start_Time__c'));
                    sch.put('endTime', sch.get('hed__End_Time__c'));
                    sch.put('professorId', profId);
                    sch.put('courseOfferingId', courseId);
                }

                for (Map<String,Object> sch : schedules) {

                    String rawCourse = String.valueOf(sch.get('hed__Course_Offering__c'));

                    if (courseToFacultyNames.containsKey(rawCourse)) {
                        sch.put(
                            'FacultyName',
                            String.join(new List<String>(courseToFacultyNames.get(rawCourse)), '/ ')
                        );
                        sch.put(
                            'All_Professors__c',
                            new List<Id>(courseToFacultyIds.get(rawCourse))
                        );
                    }
                }

                // Build the final section name
                Id secIdVal = (secKey != null && secKey.length() == 18) ? (Id)secKey : null;
                String secName = (secIdVal != null && sectionMap.containsKey(secIdVal))
                                 ? sectionMap.get(secIdVal).Name
                                 : secKey;

                if (!sectionWiseByName.containsKey(secName)) {
                    sectionWiseByName.put(secName, new List<Map<String,Object>>());
                }

                sectionWiseByName.get(secName).addAll(schedules);
            }


            // Assign back to result
            result.timeBlocks = commonBlocks;
            result.weekDays = weekdays;
            result.sections = sections;
            result.sectionWiseSchedules = sectionWiseByName;
            result.facultyWiseSchedules = facultyWiseData;

            return result;
        }


        private static void addOutput(hed__Course_Enrollment__c fc,Map<String, List<Map<String, Object>>> sectionWiseData, Map<Id, List<Map<String, Object>>> facultyWiseData, hed__Time_Block__c tb, Date schedDate, Id sectionId, Id offId, Id facilityId, String statusVal,String courseType,Id sectionAId) {
            Map<String,Object> schedule = new Map<String,Object>{
                'hed__Time_Block__c' => tb.Id,
                'hed__Start_Time__c' => tb.hed__Start_Time__c,
                'hed__End_Time__c' => tb.hed__End_Time__c,
                'Date__c' => schedDate,
                'Professor__c' => fc.hed__Contact__c,
                'CourseId' => fc.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                'hed__Course_Offering__c' => (courseType == 'Break') ? 'Break' : (courseType == 'Free_Slot') ? 'Free_Slot' : offId,
                'hed__Facility__c' => facilityId,
                'Status__c' => statusVal,
                'Faculty_Course_Connection__c' => fc.Id,
                'Section__c' => (courseType == 'lab') ? fc.Section__r.hed__Parent_Term__c : (courseType == 'Professional Elective') ? sectionAId : sectionId,
                'Batch_Group__c' => (courseType == 'section') ? null : sectionId,
                'Monday__c' =>  tb.Monday__c,
                'Tuesday__c' =>  tb.Tuesday__c,
                'Wednesday__c' =>  tb.Wednesday__c,
                'Thursday__c' =>  tb.Thursday__c,
                'Friday__c' => tb.Friday__c,
                'Saturday__c' =>  tb.Saturday__c,
                'Sunday__c' =>  tb.Sunday__c
            };
           // processedTBIds.add(tb.Id);

            String key =  String.valueOf(sectionId);
            if (!sectionWiseData.containsKey(key)) {
                sectionWiseData.put(key, new List<Map<String,Object>>());
            }
            sectionWiseData.get(key).add(schedule);

            if (fc.hed__Contact__c != null) {
                if (!facultyWiseData.containsKey(fc.hed__Contact__c)) {
                    facultyWiseData.put(fc.hed__Contact__c, new List<Map<String,Object>>());
                }
                facultyWiseData.get(fc.hed__Contact__c).add(schedule);
            }
        }



        private static Boolean applies(String day, hed__Time_Block__c tb) {
            if (day == 'Monday') {
                return tb.Monday__c;
            }
            if (day == 'Tuesday') {
                return tb.Tuesday__c;
            }
            if (day == 'Wednesday') {
                return tb.Wednesday__c;
            }
            if (day == 'Thursday') {
                return tb.Thursday__c;
            }
            if (day == 'Friday') {
                return tb.Friday__c;
            }
            if (day == 'Saturday') {
                return tb.Saturday__c;
            }
            return false;
        }

        private static String getActiveDayName(hed__Time_Block__c blk) {
            if (blk.Monday__c){
                return 'Monday';
            }
            if (blk.Tuesday__c){
                return 'Tuesday';
            }
            if (blk.Wednesday__c){
                return 'Wednesday';
            }
            if (blk.Thursday__c){
                return 'Thursday';
            }
            if (blk.Friday__c){
                return 'Friday';
            }
            if (blk.Saturday__c){
                return 'Saturday';
            }
            if (blk.Sunday__c){
                return 'Sunday';
            }
            return null;
        }

        private static Id matchBlockId(Map<String, List<hed__Time_Block__c>> dayToBlocks, String day, Id blockId, Time st, Time et) {
            List<hed__Time_Block__c> db = dayToBlocks.get(day);
            if (db == null) {
                return null;
            }
            for (hed__Time_Block__c b : db) {
                if ((blockId != null && b.Id == blockId) || (b.hed__Start_Time__c == st && b.hed__End_Time__c == et)) {
                    return b.Id;
                }
            }
            return null;
        }

        private static Boolean isAvailable(Id profId, Id facilityId, hed__Time_Block__c block, String day,
                                           Map<Id, Map<String, List<TimeInterval>>> profOcc,
                                           Map<Id, Map<String, List<TimeInterval>>> facOcc) {
            Time s = block.hed__Start_Time__c;
            Time e = block.hed__End_Time__c;
            if (profId != null) {
                if (profOcc.containsKey(profId) && profOcc.get(profId).containsKey(day)) {
                    for (TimeInterval t : profOcc.get(profId).get(day)) {
                        if (overlaps(s, e, t.startTime, t.endTime)) {
                            return false;
                        }
                    }
                }
            }
            if (facilityId != null) {
                if (facOcc.containsKey(facilityId) && facOcc.get(facilityId).containsKey(day)) {
                    for (TimeInterval t : facOcc.get(facilityId).get(day)) {
                        if (overlaps(s, e, t.startTime, t.endTime)) {
                            return false;
                        }
                    }
                }
            }
            return true;
        }

        private static Id findAvailableFacility(
        List<hed__Facility__c> facilities,
        Set<Id> profIds,
        hed__Time_Block__c block,
        String day,
        Map<Id, Map<String, List<TimeInterval>>> profOcc,
        Map<Id, Map<String, List<TimeInterval>>> facOcc
    ) {
        Set<Id> availableProfs = new Set<Id>();
        for (Id pId : profIds) {
            if (isProfessorAvailable(pId, block, day, profOcc)) {
                availableProfs.add(pId);
            }
        }

        if (availableProfs.isEmpty()) {
            return null; // no professor available
        }

        // Step 2: Check each facility only once
        for (hed__Facility__c f : facilities) {
            if (!isFacilityAvailable(f.Id, block, day, facOcc)) {
                continue;
            }

            // Step 3: Verify all available professors fit this facility
            Boolean allFree = true;
            for (Id pId : availableProfs) {
                if (!isAvailable(pId, f.Id, block, day, profOcc, facOcc)) {
                    allFree = false;
                    break;
                }
            }
            if (allFree) {
                return f.Id; // found one facility suitable for all
            }
        }

        return null; // no matching combination found
    }

    private static Boolean isProfessorAvailable(Id profId, hed__Time_Block__c block, String day,
                                                Map<Id, Map<String, List<TimeInterval>>> profOcc) {
        if (profId == null || block == null) {
            return false;
        }
        if (!profOcc.containsKey(profId) || !profOcc.get(profId).containsKey(day)) {
            return true;
        }

        for (TimeInterval t : profOcc.get(profId).get(day)) {
            if (overlaps(block.hed__Start_Time__c, block.hed__End_Time__c,t.startTime, t.endTime)) {
                return false;
            }
        }
        return true;
    }

    private static Boolean isFacilityAvailable(Id facId, hed__Time_Block__c block, String day,
                                               Map<Id, Map<String, List<TimeInterval>>> facOcc) {
        if (facId == null || block == null) {
            return false;
        }
        if (!facOcc.containsKey(facId) || !facOcc.get(facId).containsKey(day)) {
            return true;
        }

        for (TimeInterval t : facOcc.get(facId).get(day)) {
            if (overlaps(block.hed__Start_Time__c, block.hed__End_Time__c,t.startTime, t.endTime)) {
                return false;
            }
        }
        return true;
    }


        private static void book(Map<Id, Map<String, List<TimeInterval>>> profOcc, Map<Id, Map<String, List<TimeInterval>>> facOcc, Id profId, Id facilityId, hed__Time_Block__c block, String day) {
            occupyInterval(profOcc, profId, day, block.hed__Start_Time__c, block.hed__End_Time__c);
            occupyInterval(facOcc, facilityId, day, block.hed__Start_Time__c, block.hed__End_Time__c);
        }

        private static void occupyInterval(Map<Id, Map<String,List<TimeInterval>>> occ, Id key, String day, Time s, Time e) {
            if (key == null || s == null || e == null) {
                return;
            }
            ensureDay(occ, key, day);
            occ.get(key).get(day).add(new TimeInterval(s,e));
        }

        private static void ensureDay(Map<Id, Map<String,List<TimeInterval>>> occ, Id key, String day) {
            if (!occ.containsKey(key)) {
                occ.put(key, new Map<String,List<TimeInterval>>());
            }
            if (!occ.get(key).containsKey(day)) {
                occ.get(key).put(day, new List<TimeInterval>());
            }
        }

        private static Boolean overlaps(Time s1, Time e1, Time s2, Time e2) {
            return (s1 < e2) && (e1 > s2);
        }

        private static void addSDB(Map<String, Map<String, Set<Id>>> sdb, Id sectionId, String day, Id blockId) {
            if (sectionId == null || day == null || blockId == null) {
                return;
            }
            String key = String.valueOf(sectionId);
            if (!sdb.containsKey(key)) {
                sdb.put(key, new Map<String, Set<Id>>());
            }
            if (!sdb.get(key).containsKey(day)) {
                sdb.get(key).put(day, new Set<Id>());
            }
            sdb.get(key).get(day).add(blockId);
        }

        private static Boolean isTakenSDB(Map<String, Map<String, Set<Id>>> sdb, Id sectionId, String day, Id blockId) {
            String key = String.valueOf(sectionId);
            return sdb.containsKey(key) && sdb.get(key).containsKey(day) && sdb.get(key).get(day).contains(blockId);
        }

        private static void reserve(Map<String, Map<String, Set<Id>>> reservedSDB, Id sectionId, String day, Id blockId) {
            if (sectionId == null || day == null || blockId == null) {
                return;
            }
            String key = String.valueOf(sectionId);
            if (!reservedSDB.containsKey(key)) {
                reservedSDB.put(key, new Map<String, Set<Id>>());
            }
            if (!reservedSDB.get(key).containsKey(day)) {
                reservedSDB.get(key).put(day, new Set<Id>());
            }
            reservedSDB.get(key).get(day).add(blockId);
        }

        private static Boolean isReserved(Map<String, Map<String, Set<Id>>> reservedSDB, Id sectionId, String day, Id blockId) {
            String key = String.valueOf(sectionId);
            return reservedSDB.containsKey(key) && reservedSDB.get(key).containsKey(day) && reservedSDB.get(key).get(day).contains(blockId);
        }

        private static void addDateRange(Set<Date> dates, Date startDate, Date endDate) {
            if (startDate == null || endDate == null) {
                return;
            }
            Date cur = startDate;
            while (cur <= endDate) {
                dates.add(cur);
                cur = cur.addDays(1);
            }
        }

        private class TimeInterval {
            public Time startTime;
            public Time endTime;
            /**
             * @description Constructor for the TimeInterval class.
             * @param s The start time of the interval.
             * @param e The end time of the interval.
             */
            public TimeInterval(Time s, Time e){
                 startTime=s; endTime=e;
                }
        }


        /**
         * @description This class represents the data structure for the timetable.
         * It includes details about time blocks, weekdays, sections, schedules, and unallocated courses.
         */
        public class TimetableData {
            @AuraEnabled public List<hed__Time_Block__c> timeBlocks;
            @AuraEnabled public List<String> weekDays;
            @AuraEnabled public boolean isTimetableCreated;
            @AuraEnabled public List<hed__Term__c> sections;
            @AuraEnabled public Map<String, List<Map<String, Object>>> sectionWiseSchedules;
            @AuraEnabled public Map<Id, List<Map<String, Object>>> facultyWiseSchedules;
            @AuraEnabled public List<Map<String, Object>> unallocatedCourses;
            @AuraEnabled public Map<String, List<Date>> dayToDatesMap;
            /**
             * @description Constructor for the TimetableData class.
             * Initializes the unallocatedCourses list.
             */
            public TimetableData() {
                unallocatedCourses = new List<Map<String, Object>>();
            }
        }

        @AuraEnabled
        /**
         * @description Saves the generated timetable schedules for the given term record.
         * @param recordId The ID of the term record for which the schedules are being saved.
         * @param timetableDataJson The JSON string containing the timetable data.
         * @param dayToDatesMap A map of weekdays to their corresponding dates.
         */
        public static void saveSchedules(Id recordId, String timetableDataJson , Map<String, List<Date>> dayToDatesMap) {


            Database.executeBatch(new TimeTableCourseOffSchedulesSaveBatch(recordId, timetableDataJson,dayToDatesMap), 1);
        }

        @AuraEnabled
        /**
         * @description Retrieves existing offering schedules for the given term record.
         * @param recordId The ID of the term record for which the schedules are being fetched.
         * @return A TimetableData object containing the existing schedules.
         */
        public static TimetableData getExistingOfferingSchedules(Id recordId) {
            TimetableData result = new TimetableData();

            Map<String, List<Map<String, Object>>> sectionWiseData = new Map<String, List<Map<String, Object>>>();
            Map<Id, List<Map<String, Object>>> facultyWiseData = new Map<Id, List<Map<String, Object>>>();
            Map<String, List<hed__Time_Block__c>> dayToBlocks = new Map<String, List<hed__Time_Block__c>>();
            //Map<String, List<hed__Time_Block__c>> dayToBreakBlocks = new Map<String, List<hed__Time_Block__c>>();
            Map<Id,String> facilityMap = new  Map<Id,String>();
            List<String> weekdays = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
            List<hed__Time_Block__c> existingBlocks = new List<hed__Time_Block__c>();
            List<hed__Term__c> sections = new List<hed__Term__c>();

            Map<Id, hed__Term__c> sectionMap = new Map<Id, hed__Term__c>();
            Map<Id, String> offeringName = new Map<Id, String>();
            Set<Id> contactIds = new Set<Id>();



            List<hed__Course_Offering_Schedule__c> existingSchedules = [
                SELECT Id, Date__c, hed__Time_Block__c, hed__Start_Time__c, hed__End_Time__c,hed__Time_Block__r.Name ,Section__r.Id,
                hed__Time_Block__r.hed__Start_Time__c,Status__c, hed__Time_Block__r.hed__End_Time__c,hed__Course_Offering__r.Name,hed__Facility__r.Room__c,Faculty_Course_Connection__r.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                Faculty_Course_Connection__r.Section__r.hed__Parent_Term__c,Section__r.Name,Batch_Group__r.Name,hed__Facility__r.Block__c,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                hed__Time_Block__r.Monday__c, hed__Time_Block__r.Tuesday__c, hed__Time_Block__r.Wednesday__c, hed__Time_Block__r.Thursday__c, hed__Time_Block__r.Friday__c, hed__Time_Block__r.Saturday__c, hed__Time_Block__r.Sunday__c,
                       Section__c, Professor__c,Free_Slot__c, hed__Facility__c, hed__Course_Offering__c,Batch_Group__c,Faculty_Course_Connection__c,Batch_Group__r.Id,hed__Time_Block__r.Break__c,
                       hed__Course_Offering__r.Category__c,Faculty_Course_Connection__r.hed__Contact__c,Faculty_Course_Connection__r.Name,hed__Facility__r.Id,Faculty_Course_Connection__r.Section__c,Faculty_Course_Connection__r.Section__r.Id
                FROM hed__Course_Offering_Schedule__c
                WHERE (Section__r.hed__Parent_Term__c = :recordId OR Section__r.hed__Parent_Term__r.hed__Parent_Term__c = :recordId)
                AND (Date__c >= :Date.today() AND Date__c <= :Date.today().addDays(7))
                AND Date__c != null AND hed__Time_Block__c != null AND (Section__c != null OR Batch_Group__c != null)  WITH USER_MODE
                ORDER BY Section__r.RecordType.Name ASC
            ];




            for (hed__Course_Offering_Schedule__c schedule : existingSchedules) {
                if (schedule.hed__Time_Block__c != null) {
                    existingBlocks.add(schedule.hed__Time_Block__r);
                }
                 String blockAndRoom = schedule.hed__Facility__r.Block__c +'-'+ schedule.hed__Facility__r.Room__c;
                if(!facilityMap.containsKey(schedule.hed__Facility__r.Id)){
                    facilityMap.put(schedule.hed__Facility__r.Id ,blockAndRoom);
                }


                Id sectionId = schedule.Batch_Group__c == null ? schedule.Section__r?.Id : schedule.Batch_Group__r?.Id;
                if (sectionId == null) {
                    continue;
                }

                Id offeringId = schedule.hed__Course_Offering__r != null ? schedule.hed__Course_Offering__r.Id : null;
                Id facId = schedule.hed__Facility__r != null ? schedule.hed__Facility__r.Id : null;

                if (!sectionMap.containsKey(sectionId)) {
                    sectionMap.put(sectionId, new hed__Term__c(Id = sectionId));
                } else {
                    sectionMap.put(sectionId, schedule.Batch_Group__c == null ? schedule.Section__r : schedule.Batch_Group__r);
                }

                if (offeringId != null && schedule.hed__Course_Offering__r != null) {
                    offeringName.put(offeringId, schedule.hed__Course_Offering__r?.Name);
                }

                if (schedule.Faculty_Course_Connection__r != null &&
                    schedule.Faculty_Course_Connection__r.hed__Contact__c != null) {
                    contactIds.add(schedule.Faculty_Course_Connection__r.hed__Contact__c);
                }

                if (schedule.Batch_Group__r != null || schedule.Section__r != null) {
                    sections.add(schedule.Batch_Group__c == null ? schedule.Section__r : schedule.Batch_Group__r);
                }

                String typeOfSlot = (schedule.hed__Time_Block__r != null && schedule.hed__Time_Block__r.Break__c == true)
                    ? 'Break'
                    : schedule.Free_Slot__c == true
                        ? 'Free_Slot'
                        : 'Section';

                if (typeOfSlot == 'Break') {
                    addOutput(
                        new hed__Course_Enrollment__c(),
                        sectionWiseData,
                        facultyWiseData,
                        schedule.hed__Time_Block__r,
                        schedule.Date__c,
                        sectionId,
                        null,
                        null,
                        schedule.Status__c,
                        'Break',
                        null
                    );
                } else if (typeOfSlot == 'Free_Slot') {
                    addOutput(
                        new hed__Course_Enrollment__c(),
                        sectionWiseData,
                        facultyWiseData,
                        schedule.hed__Time_Block__r,
                        schedule.Date__c,
                        sectionId,
                        null,
                        null,
                        schedule.Status__c,
                        'Free_Slot',
                        null
                    );

                }

                else {
                    addOutput(
                        schedule.Faculty_Course_Connection__r != null ? schedule.Faculty_Course_Connection__r :  new hed__Course_Enrollment__c(),
                        sectionWiseData,
                        facultyWiseData,
                        schedule.hed__Time_Block__r,
                        schedule.Date__c,
                        sectionId,
                        offeringId,
                        facId,
                        schedule.Status__c,
                        'Section',
                        sectionId
                    );
                }
            }


            for (String day : weekdays) {

                if(!existingBlocks.isEmpty()){
                    List<hed__Time_Block__c> listDay = new List<hed__Time_Block__c>();
                    for (hed__Time_Block__c tb : existingBlocks) {
                        if (applies(day, tb)) {
                            listDay.add(tb);
                       }
                    }
                     dayToBlocks.put(day, listDay);
                }
            }

            //result.unallocatedCourses = stillUnallocated;

            result.isTimetableCreated = true;
            result =  processSectionWiseAllocationData(result, dayToBlocks, sectionMap, offeringName, sectionWiseData, facultyWiseData, contactIds,existingBlocks,weekdays,sectionMap.values(),facilityMap);
            return result;

        }

        private static List<hed__Time_Block__c> shuffleBlocks(List<hed__Time_Block__c> blocks) {
            List<hed__Time_Block__c> shuffled = new List<hed__Time_Block__c>(blocks);
            Integer n = shuffled.size();
            for (Integer i = 0; i < n; i++) {
                Integer j = Math.abs(Crypto.getRandomInteger());
                j = Math.mod(j, n);
                hed__Time_Block__c temp = shuffled[i];
                shuffled[i] = shuffled[j];
                shuffled[j] = temp;
            }
            return shuffled;
        }

        private static List<String> shuffleWeekdays(List<String> weekdays) {
            if (weekdays == null || weekdays.size() <= 1) {
                return weekdays;
            }
            List<String> copy = new List<String>(weekdays);
            Integer n = copy.size();
            for (Integer i = 0; i < n; i++) {
                Integer j = Integer.valueOf(Math.floor(Math.random() * n));
                String temp = copy[i];
                copy[i] = copy[j];
                copy[j] = temp;
            }
            return copy;
        }
    }