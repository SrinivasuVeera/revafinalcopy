public with sharing class OpenElectiveProfessorAllotment_Ctrl {
    @AuraEnabled
    public static List<hed__Course__c> getCourses(String searchTerm, String courseCat) {
        System.debug('coursecat-->' + courseCat);
        List<hed__Course__c> courses = [
            SELECT Id, Name 
            FROM hed__Course__c 
            WHERE Category__c = :courseCat 
            AND (Name LIKE :('%' + searchTerm + '%') OR hed__Course_ID__c LIKE :('%' + searchTerm + '%'))
        ]; 
        return courses;
    }

    @AuraEnabled
    public static List<hed__Term__c> getSemesters(String courseId) {
        List<hed__Term__c> uniqueSemesters = new List<hed__Term__c>();
        Set<String> uniqueNames = new Set<String>();
        List<hed__Term__c> groupAllocations = [
            SELECT Id, Name, Course_Offering__r.Course_ID__c, 
                   (SELECT Id, hed__Contact__c, hed__Contact__r.Name FROM Course_Connections__r WHERE RecordType.Name = 'Faculty') 
            FROM hed__Term__c 
            WHERE RecordType.Name = 'Group Allocation' 
            AND Course_Offering__r.hed__Course__c = :courseId 
            AND hed__Parent_Term__r.Active__c = TRUE 
            ORDER BY Course_Offering__r.Name
        ];
        for (hed__Term__c term : groupAllocations) {
            if (!uniqueNames.contains(term.Name)) {
                uniqueNames.add(term.Name);
                uniqueSemesters.add(term);
            }
        }
        System.debug('uniqueSemesters' + uniqueSemesters);
        return uniqueSemesters;
    }

    @AuraEnabled
    public static List<Contact> getFaculty(String searchProf) {
        String queryString = '%' + searchProf + '%';
        List<Contact> faculty = [
            SELECT Id, Name 
            FROM Contact 
            WHERE RecordType.Name = 'Professor' 
            AND Name LIKE :queryString
        ];
        return faculty;
    }

    @AuraEnabled
    public static void createFacultyCourseConnections(String facultyConnections) {
        System.debug('faculty -->' + facultyConnections);
        Map<String, String> profSemesterMap = new Map<String, String>();
        List<respwrp> semesterList = (List<respwrp>) JSON.deserialize(facultyConnections, List<respwrp>.class);
        System.debug('semesterList-->' + semesterList);
        for (respwrp wrp : semesterList) {
            profSemesterMap.put(wrp.semesterName, wrp.Professor);
        }
        List<hed__Term__c> groupAllocations = [
            SELECT Id, Name, Course_Offering__c, Course_Offering__r.Course_ID__c,
                   (SELECT Id, hed__Contact__c, hed__Contact__r.Name FROM Course_Connections__r WHERE RecordType.Name = 'Faculty') 
            FROM hed__Term__c 
            WHERE RecordType.Name = 'Group Allocation' 
            AND Name IN :profSemesterMap.keySet() 
            AND hed__Parent_Term__r.Active__c = TRUE 
            AND Course_Offering__r.hed__Course__r.Category__c = 'Open Elective'
            ORDER BY Course_Offering__r.Name
        ];
        System.debug('groupallocation-->' + groupAllocations);
        List<hed__Course_Enrollment__c> insertCC = new List<hed__Course_Enrollment__c>();
        String courseConnProfRecType = Utility.CC_Faculty_RecType;
        Id ccProfRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(courseConnProfRecType).getRecordTypeId();
        for (hed__Term__c groups : groupAllocations) {
            hed__Course_Enrollment__c connection = new hed__Course_Enrollment__c();
            if (!groups.Course_Connections__r.isEmpty()) {
                connection.Id = groups.Course_Connections__r[0].Id;
            }
            connection.hed__Contact__c = profSemesterMap.get(groups.Name);
            connection.hed__Course_Offering__c = groups.Course_Offering__c;
            connection.Section__c = groups.Id;
            connection.RecordTypeId = ccProfRecTypeId;
            insertCC.add(connection);
        }
        if (!insertCC.isEmpty()) {
            Database.upsert(insertCC, false);
        }
    }

   // UPDATED APEX METHOD: USES GROUP-ALLOCATION QUERY AS SOURCE
// - Replaces the old semester/sections/course-offering queries with the provided
//   Group Allocation query (includes Course_Offering__r and Course_Connections__r).
// - Preserves facility, time-block, existing-schedule and schedule creation logic.



    // --- DTOs for safe serialization to LWC ---
    public class ScheduleDTO {
        @AuraEnabled public String groupName;
        @AuraEnabled public String courseName;
        @AuraEnabled public String parentOfferingName;
        @AuraEnabled public String sectionName;
        @AuraEnabled public String parentSemesterName;
        @AuraEnabled public String professorName;
        @AuraEnabled public String professorId;
        @AuraEnabled public Long startTime; // milliseconds from midnight
        @AuraEnabled public Long endTime;   // milliseconds from midnight
        @AuraEnabled public String scheduleDate; // yyyy-MM-dd
        @AuraEnabled public String dayOfWeek;
        @AuraEnabled public String facilityId;
    }

    public class TimetableData {
        @AuraEnabled public String semesterName;
        @AuraEnabled public List<ScheduleDTO> schedules;
        @AuraEnabled public Map<String, List<ScheduleDTO>> weeklyView;
    }

    // --- Helper: convert Time to milliseconds from midnight ---
    private static Long timeToMs(Time t) {
        if (t == null) return null;
        Long ms = (Long) t.hour() * 3600000L + (Long) t.minute() * 60000L + (Long) t.second() * 1000L + (Long) t.millisecond();
        return ms;
    }

    // You keep your other helpers (addDateRange, getDayOfWeek, getSemesterForSection, etc.)
    // ... assume those methods exist in this class

    @AuraEnabled
    public static TimetableData generateTimetable(String daySlotsJson) {
        System.debug('🟢🚀 generateTimetable called (entry)');
        System.debug('📦 Input daySlotsJson: ' + daySlotsJson);

        // 1) Query Group Allocation rows
        List<hed__Term__c> allocationTerms = [
            SELECT Id, Name,
                   hed__Parent_Term__c, hed__Parent_Term__r.Name,
                   Course_Offering__r.Id, Course_Offering__r.Name, Course_Offering__r.Course_ID__c,
                   Course_Offering__r.Parent_Course_Offering__r.Name, Course_Offering__r.hed__Course__c,
                   Course_Offering__r.Parent_Course_Offering__c,
                   (SELECT Id, hed__Contact__c, hed__Contact__r.Name FROM Course_Connections__r WHERE RecordType.Name = 'Faculty')
            FROM hed__Term__c
            WHERE RecordType.Name = 'Group Allocation'
              AND hed__Parent_Term__r.Active__c = TRUE
              AND Course_Offering__r.Category__c = 'Open Elective'
              AND hed__Parent_Term__r.Schedule_not_Created__c = TRUE
              AND hed__Parent_Term__r.Create_Open_Elective_timetable__c = TRUE
            ORDER BY Course_Offering__r.Name
        ];
        if (allocationTerms.isEmpty()) {
            throw new AuraHandledException('No Group Allocation terms found for Open Elective.');
        }

        // Map sectionId -> sectionName (group name) for later use in DTO
        Map<Id, String> sectionIdToName = new Map<Id, String>();
        for (hed__Term__c g : allocationTerms) sectionIdToName.put(g.Id, g.Name);

        // 2) Group allocationTerms by parent semester
        Map<Id, List<hed__Term__c>> semesterSections = new Map<Id, List<hed__Term__c>>();
        for (hed__Term__c grp : allocationTerms) {
            Id parentSemId = grp.hed__Parent_Term__c;
            if (parentSemId == null) continue;
            if (!semesterSections.containsKey(parentSemId)) semesterSections.put(parentSemId, new List<hed__Term__c>());
            semesterSections.get(parentSemId).add(grp);
        }

        // 3) Query parent semesters (dates/account)
        Set<Id> parentSemesterIds = semesterSections.keySet();
        List<hed__Term__c> parentSemesters = [
            SELECT Id, Name, hed__Start_Date__c, hed__End_Date__c, hed__Account__c, hed__Account__r.ParentId,
                   IA_1_Start_date__c, IA_1_End_date__c, IA_2_Start_date__c, IA_2_End_date__c,
                   Exam_Start_Date__c, Exam_End_Date__c
            FROM hed__Term__c
            WHERE Id IN :parentSemesterIds
        ];
        if (parentSemesters.isEmpty()) {
            throw new AuraHandledException('No parent semesters found for the selected Group Allocation records.');
        }
        Map<Id, hed__Term__c> parentSemById = new Map<Id, hed__Term__c>();
        for (hed__Term__c ps : parentSemesters) parentSemById.put(ps.Id, ps);

        // 4) Build SectionParentSemMap (representative id)
        Map<Id, Id> SectionParentSemMap = new Map<Id, Id>();
        for (Id semId : semesterSections.keySet()) {
            List<hed__Term__c> grpList = semesterSections.get(semId);
            if (grpList != null && !grpList.isEmpty()) SectionParentSemMap.put(semId, grpList[0].Id);
        }

        // 5) Deserialize daySlots and build ordered preferences (preserve order from JS)
        List<DaySlotWrapper> daySlots = (List<DaySlotWrapper>) JSON.deserialize(daySlotsJson, List<DaySlotWrapper>.class);
        List<String> orderedDsKeys = new List<String>();
        for (DaySlotWrapper dsw : daySlots) {
            if (dsw.day == null || dsw.slot == null) continue;
            String k = dsw.day + '-' + String.valueOf(dsw.slot);
            if (!orderedDsKeys.contains(k)) orderedDsKeys.add(k);
        }

        // 6) Build excluded/valid dates per parent semester
        Map<Id, Set<Date>> semesterExcludedDates = new Map<Id, Set<Date>>();
        Map<Id, List<Date>> semesterValidDates = new Map<Id, List<Date>>();
        for (hed__Term__c semester : parentSemesters) {
            Set<Date> excludedDates = new Set<Date>();
            addDateRange(excludedDates, semester.IA_1_Start_date__c, semester.IA_1_End_date__c);
            addDateRange(excludedDates, semester.IA_2_Start_date__c, semester.IA_2_End_date__c);
            addDateRange(excludedDates, semester.Exam_Start_Date__c, semester.Exam_End_Date__c);
            semesterExcludedDates.put(semester.Id, excludedDates);

            List<Date> validDates = new List<Date>();
            Date currentDate = semester.hed__Start_Date__c;
            while (currentDate <= semester.hed__End_Date__c) {
                if (!excludedDates.contains(currentDate)) validDates.add(currentDate);
                currentDate = currentDate.addDays(1);
            }
            semesterValidDates.put(semester.Id, validDates);
        }

        // 7) Facilities per account
        Set<Id> accountIds = new Set<Id>();
        for (hed__Term__c sem : parentSemesters) if (sem.hed__Account__r != null) accountIds.add(sem.hed__Account__r.ParentId);
        Map<Id, List<hed__Facility__c>> accountFacilities = new Map<Id, List<hed__Facility__c>>();
        for (hed__Facility__c fac : [SELECT Id, hed__Account__c FROM hed__Facility__c WHERE hed__Account__c IN :accountIds]) {
            if (!accountFacilities.containsKey(fac.hed__Account__c)) accountFacilities.put(fac.hed__Account__c, new List<hed__Facility__c>());
            accountFacilities.get(fac.hed__Account__c).add(fac);
        }

        // 8) Build semesterOfferings from allocationTerms (fallback to query)
        Map<Id, List<hed__Course_Offering__c>> semesterOfferings = new Map<Id, List<hed__Course_Offering__c>>();
        Set<Id> collectCourseIds = new Set<Id>();
        Set<Id> collectParentOfferingIds = new Set<Id>();
        for (hed__Term__c grp : allocationTerms) {
            Id parentSemId = grp.hed__Parent_Term__c;
            if (parentSemId == null) continue;
            if (grp.Course_Offering__r != null) {
                SObject co = grp.Course_Offering__r;
                if (co != null) {
                    hed__Course_Offering__c offering = new hed__Course_Offering__c();
                    if (co.get('Id') != null) offering.Id = (Id) co.get('Id');
                    offering.Name = (String) co.get('Name');
                    offering.hed__Course__c = (Id) co.get('hed__Course__c');
                    offering.Parent_Course_Offering__c = (Id) co.get('Parent_Course_Offering__c');
                    if (!semesterOfferings.containsKey(parentSemId)) semesterOfferings.put(parentSemId, new List<hed__Course_Offering__c>());
                    semesterOfferings.get(parentSemId).add(offering);
                    if (offering.hed__Course__c != null) collectCourseIds.add(offering.hed__Course__c);
                    if (offering.Parent_Course_Offering__c != null) collectParentOfferingIds.add(offering.Parent_Course_Offering__c);
                }
            }
        }
        if (semesterOfferings.isEmpty()) {
            for (hed__Course_Offering__c off : [
                SELECT Id, Name, hed__Course__c, hed__Course__r.Name, hed__Term__c,
                       Parent_Course_Offering__r.Name, Parent_Course_Offering__c, Category__c
                FROM hed__Course_Offering__c
                WHERE hed__Term__c IN :parentSemesterIds
            ]) {
                if (!semesterOfferings.containsKey(off.hed__Term__c)) semesterOfferings.put(off.hed__Term__c, new List<hed__Course_Offering__c>());
                semesterOfferings.get(off.hed__Term__c).add(off);
                if (off.hed__Course__c != null) collectCourseIds.add(off.hed__Course__c);
                if (off.Parent_Course_Offering__c != null) collectParentOfferingIds.add(off.Parent_Course_Offering__c);
            }
        }

        // 9) Resolve course names and parent offering names
        Map<Id, String> courseIdToName = new Map<Id, String>();
        if (!collectCourseIds.isEmpty()) {
            for (hed__Course__c c : [SELECT Id, Name FROM hed__Course__c WHERE Id IN :collectCourseIds]) courseIdToName.put(c.Id, c.Name);
        }
        Map<Id, String> parentOfferingIdToName = new Map<Id, String>();
        if (!collectParentOfferingIds.isEmpty()) {
            for (hed__Course_Offering__c p : [SELECT Id, Name FROM hed__Course_Offering__c WHERE Id IN :collectParentOfferingIds]) parentOfferingIdToName.put(p.Id, p.Name);
        }

        // 10) Pre-fetch time blocks
        Set<Integer> allSlots = new Set<Integer>();
        for (DaySlotWrapper ds : daySlots) allSlots.add(ds.slot);
        List<hed__Time_Block__c> allBlocks = [
            SELECT Id, Name, hed__End_Time__c, hed__Start_Time__c, Break__c, Slot__c, hed__Educational_Institution__c,
                   Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c
            FROM hed__Time_Block__c
            WHERE Break__c = FALSE
              AND hed__Educational_Institution__r.parentId IN :accountIds
              AND Slot__c IN :allSlots
              AND Active__c = TRUE
        ];
        Map<Id, Map<String, hed__Time_Block__c>> accountDaySlotToBlock = new Map<Id, Map<String, hed__Time_Block__c>>();
        for (hed__Time_Block__c block : allBlocks) {
            Map<String, hed__Time_Block__c> daySlotMap = accountDaySlotToBlock.get(block.hed__Educational_Institution__c);
            if (daySlotMap == null) daySlotMap = new Map<String, hed__Time_Block__c>();
            accountDaySlotToBlock.put(block.hed__Educational_Institution__c, daySlotMap);
            if (block.Monday__c) daySlotMap.put('Monday-' + block.Slot__c, block);
            if (block.Tuesday__c) daySlotMap.put('Tuesday-' + block.Slot__c, block);
            if (block.Wednesday__c) daySlotMap.put('Wednesday-' + block.Slot__c, block);
            if (block.Thursday__c) daySlotMap.put('Thursday-' + block.Slot__c, block);
            if (block.Friday__c) daySlotMap.put('Friday-' + block.Slot__c, block);
            if (block.Saturday__c) daySlotMap.put('Saturday-' + block.Slot__c, block);
            if (block.Sunday__c) daySlotMap.put('Sunday-' + block.Slot__c, block);
        }

        // 11) Build section ids & contactIds
        Set<Id> allSectionIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for (List<hed__Term__c> secs : semesterSections.values()) {
            for (hed__Term__c sec : secs) {
                allSectionIds.add(sec.Id);
                if (sec.Course_Connections__r != null && !sec.Course_Connections__r.isEmpty()) contactIds.add(sec.Course_Connections__r[0].hed__Contact__c);
            }
        }
        Map<Id, String> contactIdToName = new Map<Id, String>();
        Map<Id, String> contactIdToEmail = new Map<Id, String>();
        if (!contactIds.isEmpty()) {
            for (Contact c : [SELECT Id, Name, Email FROM Contact WHERE Id IN :contactIds]) {
                contactIdToName.put(c.Id, c.Name);
                contactIdToEmail.put(c.Id, c.Email);
            }
        }
        Map<String, Id> emailToUserId = new Map<String, Id>();
        if (!contactIdToEmail.isEmpty()) {
            for (User u : [SELECT Id, Email FROM User WHERE Email IN :contactIdToEmail.values()]) emailToUserId.put(u.Email, u.Id);
        }

        // 12) Fetch existing schedules
        List<hed__Course_Offering_Schedule__c> existingSchedules = new List<hed__Course_Offering_Schedule__c>();
        if (!allSectionIds.isEmpty()) {
            existingSchedules = [
                SELECT Id, Date__c, hed__Facility__c, hed__Start_Time__c, hed__End_Time__c, Section__c
                FROM hed__Course_Offering_Schedule__c
                WHERE (Section__c IN :allSectionIds OR Section__c IN :parentSemesterIds)
            ];
        }
        Map<Id, List<hed__Course_Offering_Schedule__c>> semesterExistingSchedules = new Map<Id, List<hed__Course_Offering_Schedule__c>>();
        for (hed__Course_Offering_Schedule__c existing : existingSchedules) {
            Id semesterId = getSemesterForSection(existing.Section__c, semesterSections);
            if (semesterId != null) {
                if (!semesterExistingSchedules.containsKey(semesterId)) semesterExistingSchedules.put(semesterId, new List<hed__Course_Offering_Schedule__c>());
                semesterExistingSchedules.get(semesterId).add(existing);
            }
        }

        // 13) Generate schedules (course-first -> parent-second) with reuse-last fallback
        Map<String, hed__Course_Offering_Schedule__c> dummyMap = new Map<String, hed__Course_Offering_Schedule__c>();
        List<hed__Course_Offering_Schedule__c> dummyToInsert = new List<hed__Course_Offering_Schedule__c>();
        List<hed__Course_Offering_Schedule__c> actualToInsert = new List<hed__Course_Offering_Schedule__c>();

        Map<String, String> courseNameToDaySlot = new Map<String, String>();
        Map<String, String> parentOfferingNameToDaySlot = new Map<String, String>();
        Set<String> createdScheduleKeys = new Set<String>();

        for (Id parentSemId : semesterSections.keySet()) {
            List<Date> validDates = semesterValidDates.get(parentSemId);
            List<hed__Term__c> sections = semesterSections.get(parentSemId);
            List<hed__Course_Offering__c> courseOfferings = semesterOfferings.get(parentSemId);
            hed__Term__c parentSem = parentSemById.get(parentSemId);
            List<hed__Facility__c> facilities = (parentSem != null && parentSem.hed__Account__r != null) ? accountFacilities.get(parentSem.hed__Account__r.ParentId) : null;
            List<hed__Course_Offering_Schedule__c> existing = semesterExistingSchedules.get(parentSemId);
            Map<String, hed__Time_Block__c> daySlotToBlock = (parentSem != null) ? accountDaySlotToBlock.get(parentSem.hed__Account__c) : null;

            if (sections == null || courseOfferings == null || facilities == null || daySlotToBlock == null || validDates == null) continue;

            for (hed__Term__c section : sections) {
                if (section.Course_Connections__r == null || section.Course_Connections__r.isEmpty() || courseOfferings.isEmpty()) continue;

                Id contactId = section.Course_Connections__r[0].hed__Contact__c;
                Id professorId = null;
                String contactEmail = contactIdToEmail.get(contactId);
                if (contactEmail != null && emailToUserId.containsKey(contactEmail)) professorId = emailToUserId.get(contactEmail);
                Id facultyConnectionId = section.Course_Connections__r[0].Id;

                for (hed__Course_Offering__c offering : courseOfferings) {
                    // Resolve courseName and parentOfferingName
                    String courseName = null;
                    if (offering.hed__Course__c != null && courseIdToName.containsKey(offering.hed__Course__c)) {
                        courseName = courseIdToName.get(offering.hed__Course__c);
                    } else {
                        courseName = offering.Name != null ? offering.Name : 'Unknown Course';
                    }
                    String parentOfferingName = null;
                    if (offering.Parent_Course_Offering__c != null && parentOfferingIdToName.containsKey(offering.Parent_Course_Offering__c)) {
                        parentOfferingName = parentOfferingIdToName.get(offering.Parent_Course_Offering__c);
                    }

                    for (Date schedDate : validDates) {
                        String dayOfWeek = getDayOfWeek(schedDate);

                        for (DaySlotWrapper ds : daySlots) {
                            if (ds.day != dayOfWeek) continue;
                            String dsKey = ds.day + '-' + String.valueOf(ds.slot);

                            // Determine selectedDaySlot by priority:
                            // 1. course mapping
                            // 2. parent mapping
                            // 3. assign from orderedDsKeys (reuse last if consumed)
                            String selectedDaySlot = null;
                            Boolean mustMatch = false;

                            if (courseName != null && courseNameToDaySlot.containsKey(courseName)) {
                                selectedDaySlot = courseNameToDaySlot.get(courseName);
                                mustMatch = true;
                                if (selectedDaySlot != dsKey) continue;
                            } else if (parentOfferingName != null && parentOfferingNameToDaySlot.containsKey(parentOfferingName)) {
                                selectedDaySlot = parentOfferingNameToDaySlot.get(parentOfferingName);
                                mustMatch = true;
                                if (selectedDaySlot != dsKey) continue;
                            } else {
                                // fallback: assign from orderedDsKeys; if none left, reuse last preference if exists
                                if (!orderedDsKeys.isEmpty()) {
                                    selectedDaySlot = orderedDsKeys[0]; // pick first available
                                    // if the dsKey does not equal selectedDaySlot, skip this ds (we only schedule on assigned pref)
                                    if (selectedDaySlot != dsKey) continue;
                                } else {
                                    // REUSE-LAST behavior: if no orderedDsKeys left, attempt to reuse any mapping that exists
                                    // Prefer course mapping (already checked), else parent mapping (already checked). If none exists, we fallback to allowing the dsKey (reuse)
                                    // to keep schedule going we allow dsKey
                                    selectedDaySlot = dsKey;
                                }
                            }

                            hed__Time_Block__c block = daySlotToBlock.get(dsKey);
                            if (block == null) continue;

                            // find available facility
                            Id availableFacility = null;
                            for (hed__Facility__c fac : facilities) {
                                Boolean conflict = false;
                                if (existing != null) {
                                    for (hed__Course_Offering_Schedule__c existingSched : existing) {
                                        if (existingSched.Section__c == section.Id &&
                                            existingSched.Date__c == schedDate &&
                                            existingSched.hed__Start_Time__c < block.hed__End_Time__c &&
                                            existingSched.hed__End_Time__c > block.hed__Start_Time__c) {
                                            conflict = true; break;
                                        }
                                    }
                                }
                                if (!conflict) { availableFacility = fac.Id; break; }
                            }
                            if (availableFacility == null) continue;

                            // avoid duplicates
                            String createdKey = section.Id + '-' + (offering.Id == null ? offering.Name : String.valueOf(offering.Id)) + '-' + String.valueOf(schedDate) + '-' + dsKey;
                            if (createdScheduleKeys.contains(createdKey)) continue;

                            String key = SectionParentSemMap.get(parentSemId) + '-' + section.Id + '-' + block.Id + '-' + offering.Id + '-' + dayOfWeek + '-' +
                                         block.hed__Start_Time__c + '-' + block.hed__End_Time__c;

                            if (!dummyMap.containsKey(key)) {
                                hed__Course_Offering_Schedule__c dummyRec = new hed__Course_Offering_Schedule__c(
                                    Section__c = SectionParentSemMap.get(parentSemId),
                                    Batch_Group__c = section.Id,
                                    hed__Course_Offering__c = offering.Id,
                                    hed__Time_Block__c = block.Id,
                                    Status__c = 'Scheduled',
                                    hed__Monday__c = (dayOfWeek == 'Monday'),
                                    hed__Tuesday__c = (dayOfWeek == 'Tuesday'),
                                    hed__Wednesday__c = (dayOfWeek == 'Wednesday'),
                                    hed__Thursday__c = (dayOfWeek == 'Thursday'),
                                    hed__Friday__c = (dayOfWeek == 'Friday'),
                                    hed__Saturday__c = (dayOfWeek == 'Saturday'),
                                    hed__Sunday__c = (dayOfWeek == 'Sunday')
                                );
                                dummyToInsert.add(dummyRec);
                                dummyMap.put(key, dummyRec);

                                // Confirm mappings:
                                if (courseName != null && !courseNameToDaySlot.containsKey(courseName)) {
                                    courseNameToDaySlot.put(courseName, selectedDaySlot);
                                }
                                if (parentOfferingName != null && !parentOfferingNameToDaySlot.containsKey(parentOfferingName)) {
                                    // allow parent mapping only if it doesn't conflict with course mapping
                                    if (!courseNameToDaySlot.containsKey(courseName) || courseNameToDaySlot.get(courseName) == selectedDaySlot) {
                                        parentOfferingNameToDaySlot.put(parentOfferingName, selectedDaySlot);
                                    }
                                }

                                // consume preference (remove first) — reuse-last behavior implemented above when empty
                                if (!orderedDsKeys.isEmpty() && orderedDsKeys[0] == selectedDaySlot) orderedDsKeys.remove(0);
                            }

                            // create actual schedule record
                            hed__Course_Offering_Schedule__c childRec = new hed__Course_Offering_Schedule__c(
                                Section__c = SectionParentSemMap.get(parentSemId),
                                Batch_Group__c = section.Id,
                                hed__Course_Offering__c = offering.Id,
                                hed__Time_Block__c = block.Id,
                                hed__Start_Time__c = block.hed__Start_Time__c,
                                hed__End_Time__c = block.hed__End_Time__c,
                                Date__c = schedDate,
                                Professor__c = professorId,
                                hed__Facility__c = availableFacility,
                                Faculty_Course_Connection__c = facultyConnectionId,
                                Status__c = 'Scheduled',
                                hed__Monday__c = (dayOfWeek == 'Monday'),
                                hed__Tuesday__c = (dayOfWeek == 'Tuesday'),
                                hed__Wednesday__c = (dayOfWeek == 'Wednesday'),
                                hed__Thursday__c = (dayOfWeek == 'Thursday'),
                                hed__Friday__c = (dayOfWeek == 'Friday'),
                                hed__Saturday__c = (dayOfWeek == 'Saturday'),
                                hed__Sunday__c = (dayOfWeek == 'Sunday')
                            );

                            actualToInsert.add(childRec);
                            createdScheduleKeys.add(createdKey);
                        } // daySlots loop
                    } // validDates loop
                } // offerings loop
            } // sections loop
        } // parentSemId loop

        // STEP 1: Insert dummy parents
        if (!dummyToInsert.isEmpty()) {
            Database.SaveResult[] dummySaveResults = Database.insert(dummyToInsert, false);
            // optional: handle errors/log them
        }

        // STEP 2: Link children to parents
        for (hed__Course_Offering_Schedule__c rec : actualToInsert) {
            if (rec.Date__c != null) {
                String dayOfWeek = getDayOfWeek(rec.Date__c);
                String key = rec.Section__c + '-' + rec.Batch_Group__c + '-' + rec.hed__Time_Block__c + '-' +
                             rec.hed__Course_Offering__c + '-' + dayOfWeek + '-' + rec.hed__Start_Time__c + '-' + rec.hed__End_Time__c;
                if (dummyMap.containsKey(key) && dummyMap.get(key).Id != null) rec.CO_Schedule_Parent__c = dummyMap.get(key).Id;
            }
        }

        // STEP 3: Insert actual schedules
        if (!actualToInsert.isEmpty()) insert actualToInsert;

        // --- Build DTOs for return (no SObjects)
        List<ScheduleDTO> dtoList = new List<ScheduleDTO>();
Map<String, List<ScheduleDTO>> weekly = new Map<String, List<ScheduleDTO>>();

for (hed__Course_Offering_Schedule__c rec : actualToInsert) {

    ScheduleDTO dto = new ScheduleDTO();

    // ---------------------------
    // Group Name
    // ---------------------------
    dto.groupName = sectionIdToName.containsKey(rec.Batch_Group__c)
        ? sectionIdToName.get(rec.Batch_Group__c)
        : '';

    // ---------------------------
    // Course Name (directly from relationship)
    // ---------------------------
    if (rec.hed__Course_Offering__r != null) {
        if (rec.hed__Course_Offering__r.Parent_Course_Offering__r != null) {
            dto.courseName = rec.hed__Course_Offering__r.Parent_Course_Offering__r.Name;
        } else {
            dto.courseName = rec.hed__Course_Offering__r.Name;
        }
    }

    // ---------------------------
    // Parent Semester Name (new)
    // ---------------------------
    if (rec.Section__r != null &&
        rec.Section__r.hed__Parent_Term__r != null) {

        dto.parentSemesterName = rec.Section__r.hed__Parent_Term__r.Name;
    }

    // ---------------------------
    // Professor Details
    // ---------------------------
    dto.professorId = rec.Professor__c != null ? String.valueOf(rec.Professor__c) : '';

    if (rec.Faculty_Course_Connection__r != null &&
        rec.Faculty_Course_Connection__r.hed__Contact__r != null) {

        dto.professorName = rec.Faculty_Course_Connection__r.hed__Contact__r.Name;
    }

    // ---------------------------
    // Start & End Time
    // ---------------------------
    dto.startTime = timeToMs(rec.hed__Start_Time__c);
    dto.endTime = timeToMs(rec.hed__End_Time__c);

    // ---------------------------
    // Schedule Date (KEEP AS Date)
    // ---------------------------
    dto.scheduleDate = rec.Date__c != null ? rec.Date__c.format() : null;

    // ---------------------------
    // Day of Week (safe)
    // ---------------------------
    dto.dayOfWeek = dto.scheduleDate != null
        ? getDayOfWeek(toDate(dto.scheduleDate))
        : null;

    dto.facilityId = rec.hed__Facility__c != null
        ? String.valueOf(rec.hed__Facility__c)
        : null;

    // ---------------------------
    // Add to collections
    // ---------------------------
    dtoList.add(dto);

    if (dto.dayOfWeek != null) {
        if (!weekly.containsKey(dto.dayOfWeek)) {
            weekly.put(dto.dayOfWeek, new List<ScheduleDTO>());
        }
        weekly.get(dto.dayOfWeek).add(dto);
    }
}


        // Prepare return data
        TimetableData data = new TimetableData();
        // Representative label GroupName (ParentSemester)
        if (!semesterSections.isEmpty()) {
            Id firstParentSemId = semesterSections.keySet().iterator().next();
            String repGroup = '';
            List<hed__Term__c> grpList = semesterSections.get(firstParentSemId);
            if (grpList != null && !grpList.isEmpty()) repGroup = grpList[0].Name;
            String parentName = parentSemById.containsKey(firstParentSemId) ? parentSemById.get(firstParentSemId).Name : '';
            data.semesterName = repGroup + ' (' + parentName + ')';
        } else {
            data.semesterName = parentSemesters.isEmpty() ? null : parentSemesters[0].Name;
        }
        data.schedules = dtoList;
        data.weeklyView = aggregateWeeklyView(actualToInsert);

        return data;
    } // end generateTimetable

    // Add or keep helper methods: addDateRange, getDayOfWeek, getSemesterForSection here...



// NOTE: This method assumes helper methods and classes exist in the same class: 
// DaySlotWrapper, addDateRange, getDayOfWeek, getSemesterForSection, aggregateWeeklyView, TimetableData





    private static Id getSemesterForSection(Id sectionId, Map<Id, List<hed__Term__c>> semesterSections) {
        for (Id semId : semesterSections.keySet()) {
            for (hed__Term__c sec : semesterSections.get(semId)) {
                if (sec.Id == sectionId) return semId;
            }
        }
        return null;
    }

    private static void addDateRange(Set<Date> dateSet, Date startDate, Date endDate) {
        if (startDate != null && endDate != null && startDate <= endDate) {
            Date current = startDate;
            while (current <= endDate) {
                dateSet.add(current);
                current = current.addDays(1);
            }
        }
    }

    private static String getDayOfWeek(Date d) {
        Datetime dt = Datetime.newInstance(d, Time.newInstance(0,0,0,0));
        return dt.format('EEEE');
    }

    private static Date toDate(String s) {
    if (String.isBlank(s)) return null;

    // Handle DD/MM/YYYY (04/08/2025)
    if (s.contains('/')) {
        List<String> p = s.split('/');
        if (p.size() == 3) {
            String ymd = p[2] + '-' + p[1] + '-' + p[0];
            return Date.valueOf(ymd);
        }
    }

    // Handle already-correct format
    return Date.valueOf(s);
}


    private static Map<String, List<ScheduleDTO>> aggregateWeeklyView(List<hed__Course_Offering_Schedule__c> schedules) {
        Map<String, List<ScheduleDTO>> view = new Map<String, List<ScheduleDTO>>();

        // Collect ids to bulk query related data
        Set<Id> courseIds = new Set<Id>();
        Set<Id> sectionIds = new Set<Id>();
        Set<Id> profIds = new Set<Id>();
        for (hed__Course_Offering_Schedule__c s : schedules) {
            if (s.hed__Course_Offering__c != null) courseIds.add(s.hed__Course_Offering__c);
            if (s.Section__c != null) sectionIds.add(s.Section__c);
            if (s.Professor__c != null) profIds.add(s.Professor__c);
        }

        Map<Id, hed__Course_Offering__c> courseMap = new Map<Id, hed__Course_Offering__c>(
            [SELECT Id, Name FROM hed__Course_Offering__c WHERE Id IN :courseIds]
        );
        Map<Id, hed__Term__c> sectionMap = new Map<Id, hed__Term__c>(
            [SELECT Id, Name FROM hed__Term__c WHERE Id IN :sectionIds AND RecordType.Name IN ('Group Allocation')]
        );
        Map<Id, User> profMap = new Map<Id, User>(
            [SELECT Id, Name FROM User WHERE Id IN :profIds]
        );

        // Per-day de-duplication sets: day -> Set of composite keys
        Map<String, Set<String>> daySeenKeys = new Map<String, Set<String>>();

        for (hed__Course_Offering_Schedule__c s : schedules) {
            if (s.Date__c == null) continue;
            String day = getDayOfWeek(s.Date__c); // e.g., 'Monday'

            if (!view.containsKey(day)) {
                view.put(day, new List<ScheduleDTO>());
                daySeenKeys.put(day, new Set<String>());
            }

            String groupName = sectionMap.containsKey(s.Section__c) ? sectionMap.get(s.Section__c).Name : '';
            String courseName = courseMap.containsKey(s.hed__Course_Offering__c) ? courseMap.get(s.hed__Course_Offering__c).Name : '';
            String professorName = profMap.containsKey(s.Professor__c) ? profMap.get(s.Professor__c).Name : '';
            Time startT = s.hed__Start_Time__c;
            Time endT = s.hed__End_Time__c;

            // Build a composite key to uniquely identify an entry on that day
            // Normalize null times to empty strings to avoid NPEs
            String startKey = String.valueOf(startT) ;
            String endKey = String.valueOf(endT) ;
            String composite = day + '|' + groupName + '|' + courseName + '|' + startKey + '|' + endKey;

            // Skip duplicates
            if (daySeenKeys.get(day).contains(composite)) {
                continue;
            }
            daySeenKeys.get(day).add(composite);

            ScheduleDTO entry = new ScheduleDTO();
            entry.groupName = groupName;
            entry.courseName = courseName;
            entry.professorName = professorName;
            entry.parentSemesterName=s.Course_Offering_Section__c;
            entry.professorId = s.Professor__c;
            entry.startTime = timeToMs(startT);
            entry.endTime = timeToMs(endT); //endT;
            entry.scheduleDate = s.Date__c.format();

            view.get(day).add(entry);
        }

        return view;
    }





    public class DaySlotWrapper {
        @AuraEnabled public String day;
        @AuraEnabled public Integer slot;
    }

    public class WeeklySchedule {
        @AuraEnabled public String groupName;
        @AuraEnabled public String courseName;
        @AuraEnabled public String professorName;
        @AuraEnabled public Time startTime;
        @AuraEnabled public Time endTime;
        //@AuraEnabled public date scheduleDate;

        public WeeklySchedule(hed__Course_Offering_Schedule__c sched) {
            groupName = sched.Section__r.Name;
            courseName = sched.hed__Course_Offering__r.Name;
            professorName = sched.Professor__r.Name;
            startTime = sched.hed__Start_Time__c;
            endTime = sched.hed__End_Time__c;
        }
    }

    /*public class TimetableData {
        @AuraEnabled public List<hed__Course_Offering_Schedule__c> schedules;
        @AuraEnabled public String semesterName;
        @AuraEnabled public Map<String, List<WeeklyEntry>> weeklyView;

        public TimetableData() {
            schedules = new List<hed__Course_Offering_Schedule__c>();
            weeklyView = new Map<String, List<WeeklyEntry>>();
        }
    }*/

    public class termFacultyWrapper {
        @AuraEnabled public List<hed__Term__c> semesters;
        @AuraEnabled public List<User> faculty;
    }

    public class respwrp {
        public String semesterName;
        public String Professor;
        public String courseconnection;
    }

    public class data {
        public List<respwrp> resdata { get; set; }
    }
    public class WeeklyEntry {
        @AuraEnabled public String groupName;
        @AuraEnabled public String courseName;
        @AuraEnabled public String professorName;
        @AuraEnabled public Id professorId;
        @AuraEnabled public time startTime;
        @AuraEnabled public time endTime;
        @auraEnabled public date scheduleDate;
   }

}