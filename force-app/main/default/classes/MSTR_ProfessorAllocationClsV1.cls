/**
* @author      Devender Jadala
* @class       MSTR_ProfessorAllocationClsV1
* @description Handles Professor allocation logic for Theory, Practical, Group, and Elective courses.
* @Team            : Cloud Odyssey
* @last modified on  : 01-09-2025
* @last modified by  : Devender Jadala
*/

public with sharing class MSTR_ProfessorAllocationClsV1 {
    /**
* @description Retrieves term details based on the provided term ID.
* @param termId The ID of the term to retrieve.
* @return The term details as a hed__Term__c object.
* @throws AuraHandledException if an error occurs during the query.
*/
    @AuraEnabled
    public static hed__Term__c getTermDetails(String termId) {
        try {
            return [
                SELECT Id, Name, Program_Batch__r.Name,Approval_Status__c,hed__Parent_Term__c,Sections_Created__c,Professors_Sections_Allotted__c,
                Program_Batch__r.hed__Account__r.ParentId, No_of_professor_per_Batch__c,No_of_professor_per_Section__c, Program_Batch__r.Batches_Per_Section__c,
                No_Of_Sections__c
                FROM hed__Term__c
                WHERE Id = :termId WITH USER_MODE
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error in getTermDetails: ' + e.getMessage());
        }
    }


    /**
* @description Retrieves the program plan details for the specified term ID.
* @param termId The ID of the term for which the program plan is retrieved.
* @return A wrapper object containing categorized course details and sections.
* @throws AuraHandledException if an error occurs during the process.
*/
    @AuraEnabled
    public static MainCourseWrap getProgramPlan(String termId) {
        try {
            MainCourseWrap mainWrp = new MainCourseWrap();
            mainWrp.lstSection = new List<String>();

            // Core data fetch
            List<hed__Term__c> sections = fetchSections(termId, mainWrp);
            Map<String, Boolean> mapCourseOff = fetchCourseOfferingFlags(termId);
            Map<String, List<hed__Course_Enrollment__c>> mapProfessors = fetchProfessorAssignments(sections);

            // Categorization
            classifyCoursesByCategory(sections, mapCourseOff, mapProfessors, mainWrp,termId);

            // Professional electives
            mainWrp.listProfElective = fetchProfessionalElectives(termId);

            return mainWrp;

        } catch (QueryException qe) {
            throw new AuraHandledException('Query failed: ' + qe.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error in getProgramPlan: ' + e.getMessage());
        }
    }

/*
    private static hed__Term__c fetchTerm(String termId) {
        try {
            return [
                SELECT Id, Program_Batch__c
                FROM hed__Term__c
                WHERE Id = :termId WITH USER_MODE
                LIMIT 1

            ];
        } catch (QueryException qe) {
            throw new AuraHandledException('No Term found for the provided Id: ' + termId);
        }
    }
*/

    private static List<hed__Term__c> fetchSections(String termId, MainCourseWrap mainWrp) {
        String sectionRtId = Schema.SObjectType.hed__Term__c
            .getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();

        List<hed__Term__c> sections = [
            SELECT Id, Name, hed__Parent_Term__c, Section_Name__c, Section_Number__c
            FROM hed__Term__c
            WHERE hed__Parent_Term__c = :termId
            AND RecordTypeId = :sectionRtId WITH USER_MODE
            ORDER BY Section_Number__c ASC

        ];

        for (hed__Term__c sec : sections) {
            mainWrp.lstSection.add('Section ' + sec.Section_Name__c);
        }
        return sections;
    }

    private static Map<String, Boolean> fetchCourseOfferingFlags(String termId) {
        Map<String, Boolean> mapCourseOff = new Map<String, Boolean>();
        for (hed__Course_Offering__c co : [
            SELECT Id, hed__Course__c, Faculty_Course_Connection_Created__c
            FROM hed__Course_Offering__c
            WHERE hed__Term__c = :termId
            WITH USER_MODE
        ]) {
            mapCourseOff.put(co.hed__Course__c, co.Faculty_Course_Connection_Created__c);
        }
        return mapCourseOff;
    }

    private static Map<String, List<hed__Course_Enrollment__c>> fetchProfessorAssignments(List<hed__Term__c> sections) {
        Map<String, List<hed__Course_Enrollment__c>> mapProfessors = new Map<String, List<hed__Course_Enrollment__c>>();
        if (sections.isEmpty()) {
            return mapProfessors;
        }


        String facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c
            .getRecordTypeInfosByName().get('Faculty').getRecordTypeId();

        List<Id> termIds = new List<Id>();
        for (hed__Term__c sec : sections) {
            termIds.add(sec.Id);
        }

        for (hed__Course_Enrollment__c ce : [
            SELECT Id, hed__Course_Offering__r.hed__Course__c, Section__r.Section_Name__c,hed__Primary__c
            FROM hed__Course_Enrollment__c
            WHERE RecordTypeId = :facultyRtId
            AND Section__c IN :termIds
            WITH USER_MODE
        ]) {
            String key = ce.hed__Course_Offering__r.hed__Course__c + '-' + ce.Section__r.Section_Name__c;
            if (!mapProfessors.containsKey(key)) {
                mapProfessors.put(key, new List<hed__Course_Enrollment__c>());
            }
            mapProfessors.get(key).add(ce);
        }
        return mapProfessors;
    }

    private static void classifyCoursesByCategory(
        List<hed__Term__c> sections,
        Map<String, Boolean> mapCourseOff,
        Map<String, List<hed__Course_Enrollment__c>> mapProfessors,
        MainCourseWrap mainWrp,
        String termId
    ) {
        Map<String, CourseWrap> mapHardCore = new Map<String, CourseWrap>();
        Map<String, CourseWrap> mapHcIntegrated = new Map<String, CourseWrap>();
        Map<String, CourseWrap> mapPractical = new Map<String, CourseWrap>();
        Map<String, CourseWrap> mapMandatory = new Map<String, CourseWrap>();


        for (hed__Term__c sec : [
            SELECT Id, Name, Section_Name__c,
            (SELECT Id,
             Category__c,
             hed__Course__c,
             hed__Course__r.Name, Faculty_Course_Connection_Created__c,
             Sequence__c,
             hed__Term__r.hed__Parent_Term__r.No_of_professor_per_Section__c,
             hed__Term__c,
             hed__Term__r.Section_Name__c
             FROM hed__Course_Offerings__r
             ORDER BY Sequence__c ASC)
            FROM hed__Term__c
            WHERE (Id IN :sections AND hed__Parent_Term__r.Professors_Sections_Allotted__c  = true AND hed__Parent_Term__r.Approval_Status__c = 'Confirmed' ) OR Id = :termId
            WITH USER_MODE
        ]) {
            for (hed__Course_Offering__c co : sec.hed__Course_Offerings__r) {
                CourseWrap cw = mapCourses(co);
                cw.isConfirmed = mapCourseOff.get(co.hed__Course__c);

                if (co.Category__c == 'Hardcore Course') {
                    addToCategory(mapHardCore, co, cw, mapProfessors);
                } else if (co.Category__c == 'Practical/Term Work') {
                    addToCategory(mapPractical, co, cw, mapProfessors);
                } else if (co.Category__c == 'Hardcore Integrated Course') {
                    addToCategory(mapHcIntegrated, co, cw, mapProfessors);
                } else if (co.Category__c == 'Mandatory Course') {
                    addToCategory(mapMandatory, co, cw, mapProfessors);
                }
            }
        }

        mainWrp.listHardCore = mapHardCore.values();
        mainWrp.listHcIntegrated = mapHcIntegrated.values();
        mainWrp.listPractical = mapPractical.values();
        mainWrp.listMandatory = mapMandatory.values();
    }

    private static void addToCategory(
        Map<String, CourseWrap> mapCat,
        hed__Course_Offering__c co,
        CourseWrap cw,
        Map<String, List<hed__Course_Enrollment__c>> mapProfessors
    ) {
        String courseId = co.hed__Course__c;

        // If map already has this course
        if (mapCat.containsKey(courseId)) {
            CourseWrap existingCW = mapCat.get(courseId);

            // ✅ If we already stored a "Faculty_Course_Connection_Created__c == true" course,
            // don’t override or update anything
            if (existingCW.hasCourseOfferingConfirmed) {
                return;
            }

            // ✅ If the new record has Faculty_Course_Connection_Created__c == true
            // replace old entry with this new "priority" one
            if (co.Faculty_Course_Connection_Created__c) {
                cw.lstSection.add(mapCourseSection(co, mapProfessors));
                cw.hasCourseOfferingConfirmed = true;  // mark it inside wrapper
                mapCat.put(courseId, cw);
                return;
            }

            // ✅ Otherwise just keep adding sections to existing course
            existingCW.lstSection.add(mapCourseSection(co, mapProfessors));
        }
        else {
            // If not present in map yet
            cw.lstSection.add(mapCourseSection(co, mapProfessors));
            cw.hasCourseOfferingConfirmed = co.Faculty_Course_Connection_Created__c;
            mapCat.put(courseId, cw);
        }
    }


    private static List<ParentWrap> fetchProfessionalElectives(String termId) {
        String groupId = Schema.SObjectType.hed__Term__c
            .getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();

        List<hed__Course_Offering__c> courseOfferings = [
            SELECT Id, Name, Parent_Course_Offering__c, Parent_Course_Offering__r.Name,
            hed__Course__c, hed__Course__r.Name,
            Category__c,Faculty_Course_Connection_Created__c,
            hed__Term__c, hed__Term__r.Section_Name__c,
            Sequence__c,
            hed__Term__r.No_of_professor_per_Section__c
            FROM hed__Course_Offering__c
            WHERE hed__Term__c = :termId
            AND Category__c = 'Professional Elective'
            WITH USER_MODE
            ORDER BY Parent_Course_Offering__c, Sequence__c ASC
        ];

        Set<Id> courseOfferingIds = new Set<Id>();
        for (hed__Course_Offering__c co : courseOfferings) {
            courseOfferingIds.add(co.Id);
        }

        Map<Id, List<CourseSectionWrap>> mapCourseOfferingToSections = new Map<Id, List<CourseSectionWrap>>();
        for (hed__Term__c termRec : [
            SELECT Id, Name, Section_Name__c, Course_Offering__c, Group_Number__c
            FROM hed__Term__c
            WHERE Course_Offering__c IN :courseOfferingIds
            AND RecordTypeId = :groupId
            WITH USER_MODE
        ]) {
            if (!mapCourseOfferingToSections.containsKey(termRec.Course_Offering__c)) {
                mapCourseOfferingToSections.put(termRec.Course_Offering__c, new List<CourseSectionWrap>());
            }

            CourseSectionWrap secWrap = new CourseSectionWrap();
            secWrap.recordId = termRec.Id;
            secWrap.groupName = String.fromCharArray(new List<Integer>{64 + termRec.Group_Number__c.intValue()});
            secWrap.groupId = termRec.Id;
            secWrap.termId = termRec.Id;
            mapCourseOfferingToSections.get(termRec.Course_Offering__c).add(secWrap);
        }

        Map<Id, ParentWrap> mapProfessionalCourses = new Map<Id, ParentWrap>();
        for (hed__Course_Offering__c co : courseOfferings) {
            if (co.Parent_Course_Offering__c != null) {
                ParentWrap parentRec;
                if (!mapProfessionalCourses.containsKey(co.Parent_Course_Offering__c)) {
                    parentRec = new ParentWrap();
                    parentRec.parentId = co.Parent_Course_Offering__c;
                    parentRec.parentCourseName = co.Parent_Course_Offering__r.Name;
                    mapProfessionalCourses.put(co.Parent_Course_Offering__c, parentRec);
                } else {
                    parentRec = mapProfessionalCourses.get(co.Parent_Course_Offering__c);
                }

                CourseWrap childCourse = new CourseWrap();
                childCourse.courseId = co.hed__Course__c;

                childCourse.courseOfferId = co.Id;
                childCourse.courseName = co.hed__Course__r.Name;
                childCourse.isCourseOfferingConfirmed = co.Faculty_Course_Connection_Created__c;
                childCourse.count = string.valueof(co.Sequence__c);


                if (mapCourseOfferingToSections.containsKey(co.Id)) {
                    childCourse.lstSection = mapCourseOfferingToSections.get(co.Id);
                }

                parentRec.lstCourse.add(childCourse);
            }
        }

        return mapProfessionalCourses.values();
    }




    /**
* @description Maps a course offering to a CourseWrap object.
* @param courseOffer The course offering record to be mapped.
* @return A CourseWrap object containing details of the course offering.
*/
    @AuraEnabled
    public static CourseWrap mapCourses(hed__Course_Offering__c courseOffer){
        CourseWrap courses = new CourseWrap();
        courses.count = string.valueof(courseOffer.Sequence__c);
        courses.courseName = courseOffer.hed__Course__r.Name;
        courses.courseId = courseOffer.hed__Course__c;
        courses.courseOfferId = courseOffer.Id;
        courses.isCourseOfferingConfirmed = courseOffer.Faculty_Course_Connection_Created__c;
        return courses;
    }


    /**
* @description Maps a course offering to a CourseSectionWrap object.
* @param courseOffer The course offering record to be mapped.
* @param mapProfessors A map of course offering keys to lists of course enrollments.
* @return A CourseSectionWrap object containing details of the course section.
*/
    @AuraEnabled
    public static CourseSectionWrap mapCourseSection(hed__Course_Offering__c courseOffer,map<string,list<hed__Course_Enrollment__c>> mapProfessors){
        CourseSectionWrap courses = new CourseSectionWrap();
        courses.count = string.valueof(courseOffer.Sequence__c);
        courses.recordId = courseOffer.id;
        courses.courseName = courseOffer.hed__Course__r.Name;
        courses.courseId = courseOffer.hed__Course__c;
        courses.sectionName = courseOffer.hed__Term__r.Section_Name__c;
        courses.termId = courseOffer.hed__Term__c;
        courses.minCource = courseOffer.hed__Term__r.hed__Parent_Term__r.No_of_professor_per_Section__c;
        string coName = courseOffer.hed__Course__c+'-'+courseOffer.hed__Term__r.Section_Name__c;

        if(mapProfessors.containsKey(coName) && courseOffer.hed__Term__r.hed__Parent_Term__r.No_of_professor_per_Section__c != Null){
            if(courseOffer.hed__Term__r.hed__Parent_Term__r.No_of_professor_per_Section__c <= mapProfessors.get(coName).size()){
                courses.professorAssiened = true;
            }
        }
        return courses;
    }


    /**
* @description Retrieves batch preference details for the specified term, course, and category.
* @param termId The ID of the term to retrieve preferences for.
* @param courseId The ID of the course to retrieve preferences for.
* @param category The category of the course.
* @return A list of BatchPreferenceWrapper objects containing batch preference details.
* @throws AuraHandledException if the number of professors per batch is not configured.
*/
    @AuraEnabled
    public static List<BatchPreferenceWrapper> getPreferencesDetailsBatch(String termId, String courseId, String category) {
        hed__Term__c term = getTermDetails(termId);
        if (term.No_of_professor_per_Batch__c == null   || term.No_of_professor_per_Batch__c <= 0) {
            throw new AuraHandledException('No professors allowed per batch not confugured . Please check the semester level configuration.');
        }
        return getPreferencesDetails(termId, courseId, category, 'Batch',term, term.No_of_professor_per_Batch__c);
    }


    /**
* @description Retrieves preference details for theory courses based on the specified term, course, and category.
* @param termId The ID of the term to retrieve preferences for.
* @param courseId The ID of the course to retrieve preferences for.
* @param category The category of the course.
* @return A list of BatchPreferenceWrapper objects containing preference details for theory courses.
* @throws AuraHandledException if the number of professors per section is not configured.
*/
    @AuraEnabled
    public static List<BatchPreferenceWrapper> getPreferencesDetailsTheory(String termId, String courseId, String category) {
        hed__Term__c term = getTermDetails(termId);
        if (term.No_of_professor_per_Section__c == null || term.No_of_professor_per_Section__c <= 0) {
            throw new AuraHandledException('No professors allowed per section not confugure . Please check the semester level configuration.');

        }
        return getPreferencesDetails(termId, courseId, category, 'Theory', term ,term.No_of_professor_per_Section__c);
    }

    @AuraEnabled
    /**
* @description Retrieves preference details for group courses based on the specified term, course, and category.
* @param termId The ID of the term to retrieve preferences for.
* @param courseId The ID of the course to retrieve preferences for.
* @param category The category of the course.
* @return A list of BatchPreferenceWrapper objects containing preference details for group courses.
* @throws AuraHandledException if the number of professors per section is not configured.
*/
    public static List<BatchPreferenceWrapper> getPreferencesDetailsGroup(String termId, String courseId, String category) {
        hed__Term__c term = getTermDetails(termId);
        if (term.No_of_professor_per_Section__c == null || term.No_of_professor_per_Section__c <= 0) {
            throw new AuraHandledException('No professors allowed per section not confugure . Please check the semester level configuration.');

        }
        return getPreferencesDetails(termId, courseId, category, 'Group',term, term.No_of_professor_per_Section__c);
    }

    // 🔹 Generic Method for all 3
    private static List<BatchPreferenceWrapper> getPreferencesDetails(
        String termId, String courseId, String category, String type, hed__Term__c term, Decimal targetSlots
    ) {
        try {
            Map<String, BatchPreferenceWrapper> preferenceMap = new Map<String, BatchPreferenceWrapper>();

            // 1. Fetch container terms (Batch/Section/Group)
            String contactRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
            List<Contact> proList;
            BatchPreferenceWrapper autoWrap;
            BatchPreferenceWrapper manualWrap;
            List<hed__Course_Enrollment__c> existingConnections;
            List<Professor_Student_Course_Preference__c> prefs = fetchPreferences(termId, courseId, category, type);
            Boolean isSectionLevelAllocationAllowed ;

            if(term.Professors_Sections_Allotted__c == true && term.Approval_Status__c == 'Confirmed'){
                isSectionLevelAllocationAllowed = true;
            }
            else{

                isSectionLevelAllocationAllowed = false;
            }

            if(isSectionLevelAllocationAllowed){
                List<hed__Term__c> terms = fetchTerms(termId, courseId, type);
                proList = fetchProfessors(terms, contactRtId,type);
                existingConnections = fetchExistingConnections(courseId, terms, type);

                // 5. Auto Allocation
                autoWrap = buildAutoAllocationGeneric(terms, existingConnections, prefs, proList, targetSlots, type,isSectionLevelAllocationAllowed);
                if (autoWrap != null && !autoWrap.batchAssignments.isEmpty()) {
                    preferenceMap.put('AUTO', autoWrap);
                }

                // 6. Manual Allocation
                manualWrap = buildManualAllocation(terms, preferenceMap, proList, targetSlots,isSectionLevelAllocationAllowed,type);
                if (manualWrap != null && !manualWrap.batchAssignments.isEmpty()) {
                    preferenceMap.put('MANUAL', manualWrap);
                }
            }
            else {

                existingConnections = fetchExistingConnections(courseId, new List<hed__Term__c>{term}, type);
                proList = fetchProfessors(new List<hed__Term__c>{term}, contactRtId,type);
                autoWrap = buildAutoAllocationGeneric(new List<hed__Term__c>{term}, existingConnections, prefs, proList, targetSlots, type,isSectionLevelAllocationAllowed);
                if (autoWrap != null && !autoWrap.batchAssignments.isEmpty()) {
                    preferenceMap.put('AUTO', autoWrap);
                }

                // 6. Manual Allocation
                manualWrap = buildManualAllocation(new List<hed__Term__c>{term}, preferenceMap, proList, targetSlots,isSectionLevelAllocationAllowed,type);
                if (manualWrap != null && !manualWrap.batchAssignments.isEmpty()) {
                    preferenceMap.put('MANUAL', manualWrap);
                }
            }



            return preferenceMap.values();


        } catch (Exception e) {
            throw new AuraHandledException('Error in getPreferencesDetails(' + type + '): ' + e.getMessage());
        }
    }


    private static List<hed__Term__c> fetchTerms(String termId, String courseId, String type) {
        if (type == 'Batch') {
            String batchRtId = Schema.SObjectType.hed__Term__c
                .getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
            return [
                SELECT Id, Name, Batch_Short_Name__c,Group_Number__c,Section_Name__c,
                hed__Parent_Term__r.hed__Parent_Term__r.Program_Batch__r.hed__Account__r.ParentId
                FROM hed__Term__c
                WHERE hed__Parent_Term__r.hed__Parent_Term__c = :termId
                AND RecordTypeId = :batchRtId WITH USER_MODE
                ORDER BY Batch_Short_Name__c ASC
            ];
        } else if (type == 'Theory') {
            String sectionRtId = Schema.SObjectType.hed__Term__c
                .getRecordTypeInfosByName().get('Sections').getRecordTypeId();
            return [
                SELECT Id, Name, Section_Name__c, Group_Number__c,Batch_Short_Name__c,
                hed__Parent_Term__r.Program_Batch__r.hed__Account__r.ParentId
                FROM hed__Term__c
                WHERE hed__Parent_Term__c = :termId
                AND RecordTypeId = :sectionRtId WITH USER_MODE
                ORDER BY Section_Name__c ASC
            ];
        } else if (type == 'Group') {
            String groupRtId = Schema.SObjectType.hed__Term__c
                .getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
            return [
                SELECT Id, Name, Group_Number__c,Batch_Short_Name__c,Section_Name__c,
                hed__Parent_Term__r.Program_Batch__r.hed__Account__r.ParentId
                FROM hed__Term__c
                WHERE hed__Parent_Term__c = :termId
                AND RecordTypeId = :groupRtId
                AND Course_Offering__r.hed__Course__c = :courseId WITH USER_MODE
                ORDER BY Group_Number__c ASC
            ];
        }
        return new List<hed__Term__c>();
    }

    private static List<Contact> fetchProfessors(List<hed__Term__c> terms, String contactRtId,String type) {

        Id parentSchoolId;

        if(terms.isEmpty()){
            return new List<Contact>();
        }


        if(terms[0].hed__Parent_Term__c == null ){
            parentSchoolId  = terms[0].Program_Batch__r.hed__Account__r.ParentId ;

        }
        else {
            parentSchoolId = (type == 'Batch')
                ? terms[0].hed__Parent_Term__r.hed__Parent_Term__r.Program_Batch__r.hed__Account__r.ParentId
                : terms[0].hed__Parent_Term__r.Program_Batch__r.hed__Account__r.ParentId;
        }
        return [
            SELECT Id, Name, Designation__c, Employee_Number__c,Active__c
            FROM Contact
            WHERE (AccountId = :parentSchoolId OR Professor_Across_Schools__c = true)
            AND RecordTypeId = :contactRtId AND Active__c = true WITH USER_MODE
        ];
    }

    private static List<hed__Course_Enrollment__c> fetchExistingConnections(String courseId, List<hed__Term__c> terms, String type) {
        return [
            SELECT Id, hed__Contact__c, hed__Contact__r.Name, hed__Contact__r.Designation__c,
            Section__c, hed__Course_Offering__r.hed__Course__c,Allotted_Section__c ,Allotted_Batch_Number__c,hed__Primary__c
            FROM hed__Course_Enrollment__c
            WHERE (  hed__Course_Offering__c = :courseId
                   OR hed__Course_Offering__r.hed__Course__c = :courseId)
            AND Section__c IN :terms
            AND RecordType.Name = 'Faculty' WITH USER_MODE
        ];
    }

    private static List<Professor_Student_Course_Preference__c> fetchPreferences(String termId, String courseId, String category, String type) {
        return [
            SELECT Id, Preference__c, Professor__c, Professor__r.Name, Professor__r.Designation__c,Number_of_Times_Course_Handled__c,
            Semester__r.No_of_professor_per_Batch__c, Course_Offering__c, Course_Offering__r.hed__Course__c
            FROM Professor_Student_Course_Preference__c
            WHERE Semester__c = :termId
            AND (  Course_Offering__c = :courseId
                 OR Course_Offering__r.hed__Course__c = :courseId)
            AND Course_Offering__r.Category__c = :category
            AND Professor__c != null WITH USER_MODE
            ORDER BY Preference__c ASC
        ];
    }


    private static BatchPreferenceWrapper buildAutoAllocationGeneric(
        List<hed__Term__c> terms,
        List<hed__Course_Enrollment__c> existingConnections,
        List<Professor_Student_Course_Preference__c> prefs,
        List<Contact> proList,
        Decimal targetSlots,
        String type,
        boolean isSectionLevelAllocationAllowed
    ) {
        BatchPreferenceWrapper autoWrap = new BatchPreferenceWrapper();
        autoWrap.preferenceLabel = 'Auto-Allocation';

        autoWrap.availableProfessors = proList;

        Map<String, Professor_Student_Course_Preference__c> prMap = new Map<String, Professor_Student_Course_Preference__c>();
        for (Professor_Student_Course_Preference__c pr : prefs) {
            prMap.put(pr.Professor__c + '-' + pr.Course_Offering__r.hed__Course__c, pr);
        }

        Set<Id> usedPrefProfessors = new Set<Id>();
        if(isSectionLevelAllocationAllowed){
            autoWrap.isSectionLevelAllocationAllowed = isSectionLevelAllocationAllowed;
            for (hed__Term__c t : terms) {
                BatchAssignmentWrapper assign = new BatchAssignmentWrapper();
                assign.batchId = String.valueOf( t.Id);
                assign.batchName = (type == 'Group')
                    ? String.fromCharArray(new List<Integer>{64 + t.Group_Number__c.intValue()})
                    : (t.Batch_Short_Name__c != null ? t.Batch_Short_Name__c : t.Section_Name__c);

                        // existing connections
                        if(!existingConnections.isEmpty()){
                            for (hed__Course_Enrollment__c cc : existingConnections) {
                                if (cc.Section__c == t.Id) {
                                    String ukey = cc.hed__Contact__c + '-' + cc.hed__Course_Offering__r.hed__Course__c;
                                    ProfessorWrapper pw = new ProfessorWrapper();
                                    pw.professorId = cc.hed__Contact__c;
                                    pw.professorName = cc.hed__Contact__r.Name;
                                    pw.designation = cc.hed__Contact__r.Designation__c;
                                    pw.professorAssigned = true;
                                    pw.isPrimary = cc.hed__Primary__c;
                                    pw.prefrence = prMap.containsKey(ukey) ? prMap.get(ukey).Preference__c : 'Manual';
                                    pw.isAlreadyConnectedToCourse = true;
                                    assign.professorsForBatch.add(pw);
                                }
                            }
                        }
                else {
                    for(Professor_Student_Course_Preference__c pr: prefs){
                        //Professor_Student_Course_Preference__c pr = prefs[prefIndex++];
                        if (!usedPrefProfessors.contains(pr.Professor__c)) {

                            ProfessorWrapper pw = new ProfessorWrapper();
                            pw.professorId = pr.Professor__c;
                            pw.professorName = pr.Professor__r.Name;
                            pw.designation = pr.Professor__r.Designation__c;
                            pw.prefrence = pr.Preference__c;
                            pw.professorAssigned = false;
                            pw.isPrimary = false;
                            pw.isAlreadyConnectedToCourse = false;
                            assign.professorsForBatch.add(pw);
                            // remaining--;
                            usedPrefProfessors.add(pr.Professor__c);
                            break;
                        }
                    }
                }


                // fill remaining from prefs
                // Decimal remaining = targetSlots - assign.professorsForBatch.size();
                // while (remaining > 0 && prefIndex < prefs.size()) {


                if (!assign.professorsForBatch.isEmpty()) {
                    autoWrap.batchAssignments.add(assign);
                }
            }
        }

        else if (!isSectionLevelAllocationAllowed && type == 'Batch') {
            autoWrap.isSectionLevelAllocationAllowed = isSectionLevelAllocationAllowed;
            Integer noOfSections = terms[0].No_of_Sections__c != null ? terms[0].No_of_Sections__c.intValue() : 0;
            //Integer noOfBatchesPerSection = terms[0].Program_Batch__r.Batches_Per_Section__c != null ? terms[0].Program_Batch__r.Batches_Per_Section__c.intValue() * noOfSections : 0;
            Integer noOfBatchesPerSection = terms[0].Program_Batch__r.Batches_Per_Section__c != null ? terms[0].Program_Batch__r.Batches_Per_Section__c.intValue() : 0;
            for (Integer secIndex = 0; secIndex < noOfSections; secIndex++) {
                String sectionName = String.fromCharArray(new List<Integer>{65 + secIndex});
                String sectionId   = 'TEMP-SEC-' + String.valueOf(secIndex+1);

                for (Integer batchIndex = 0; batchIndex < noOfBatchesPerSection; batchIndex++) {
                    BatchAssignmentWrapper assign = new BatchAssignmentWrapper();
                    assign.batchId   = sectionId + '-BATCH-' + String.valueOf(batchIndex+1);
                    assign.batchName = sectionName + String.valueOf(batchIndex+1);

                    Integer filled = 0;
                    if(!existingConnections.isEmpty()){
                        for (hed__Course_Enrollment__c cc : existingConnections) {
                            String batchName = sectionName + String.valueOf(batchIndex+1);
                            String batchKey = cc.Allotted_Section__c + cc.Allotted_Batch_Number__c ;
                            if (cc.Section__c == terms[0].Id && batchKey == batchName && filled < targetSlots) {
                                String ukey = cc.hed__Contact__c + '-' + cc.hed__Course_Offering__r.hed__Course__c;
                                ProfessorWrapper pw = new ProfessorWrapper();
                                pw.professorId = cc.hed__Contact__c;
                                pw.professorName = cc.hed__Contact__r.Name;
                                pw.designation = cc.hed__Contact__r.Designation__c;
                                pw.professorAssigned = true;
                                pw.isPrimary = cc.hed__Primary__c;
                                pw.prefrence = prMap.containsKey(ukey) ? prMap.get(ukey).Preference__c : 'Manual';
                                pw.isAlreadyConnectedToCourse = true;
                                assign.professorsForBatch.add(pw);
                                filled++;
                                //usedPrefProfessors.add(cc.hed__Contact__c);
                            }
                        }
                    }else {
                        for (Professor_Student_Course_Preference__c pr : prefs) {
                            if (!usedPrefProfessors.contains(pr.Professor__c) && filled < targetSlots) {
                                ProfessorWrapper pw = new ProfessorWrapper();
                                pw.professorId   = pr.Professor__c;
                                pw.professorName = pr.Professor__r.Name;
                                pw.designation   = pr.Professor__r.Designation__c;
                                pw.prefrence     = pr.Preference__c;
                                pw.professorAssigned = false;
                                pw.isPrimary = false;
                                pw.isAlreadyConnectedToCourse = false;

                                assign.professorsForBatch.add(pw);
                                usedPrefProfessors.add(pr.Professor__c);
                                filled++;
                            }
                        }
                    }


                    // Fill remaining slots as empty if not enough professors
                    // while (filled < targetSlots) {
                    //     ProfessorWrapper empty = new ProfessorWrapper();
                    //     empty.professorAssigned = false;
                    //     empty.prefrence = 'Auto';
                    //     assign.professorsForBatch.add(empty);
                    //     filled++;
                    // }



                    if (!assign.professorsForBatch.isEmpty()) {
                        autoWrap.batchAssignments.add(assign);
                    }
                }
            }
        }

        else {
            autoWrap.isSectionLevelAllocationAllowed = isSectionLevelAllocationAllowed;

            Integer noOfSections = terms[0].No_of_Sections__c != null ? terms[0].No_of_Sections__c.intValue() : 0;
            // Integer noOfBatchesPerSection = terms[0].Program_Batch__r.Batches_Per_Section__c != null ? terms[0].Program_Batch__r.Batches_Per_Section__c.intValue()  : 0;

            for (Integer secIndex = 0; secIndex < noOfSections; secIndex++) {
                BatchAssignmentWrapper assign = new BatchAssignmentWrapper();
                assign.batchId = 'TEMP-SEC-' + String.valueOf(secIndex+1);

                assign.batchName =  String.fromCharArray(new List<Integer>{65 + secIndex});
                // 65 = 'A', so Section-A, Section-B, etc.

                Integer filled = 0;
                if(!existingConnections.isEmpty()){
                    for (hed__Course_Enrollment__c cc : existingConnections) {
                        String sectionName = String.fromCharArray(new List<Integer>{65 + secIndex});
                        if (cc.Section__c == terms[0].Id && cc.Allotted_Section__c == sectionName  && filled < targetSlots) {
                            String ukey = cc.hed__Contact__c + '-' + cc.hed__Course_Offering__r.hed__Course__c;
                            ProfessorWrapper pw = new ProfessorWrapper();
                            pw.professorId = cc.hed__Contact__c;
                            pw.professorName = cc.hed__Contact__r.Name;
                            pw.designation = cc.hed__Contact__r.Designation__c;
                            pw.professorAssigned = true;
                            pw.isPrimary = cc.hed__Primary__c;
                            pw.prefrence = prMap.containsKey(ukey) ? prMap.get(ukey).Preference__c : 'Manual';
                            pw.isAlreadyConnectedToCourse = true;
                            assign.professorsForBatch.add(pw);
                            //usedPrefProfessors.add(cc.hed__Contact__c);
                            filled++;
                        }
                    }
                }else {
                for (Professor_Student_Course_Preference__c pr : prefs) {
                    if (!usedPrefProfessors.contains(pr.Professor__c) && filled < targetSlots) {
                        ProfessorWrapper pw = new ProfessorWrapper();
                        pw.professorId = pr.Professor__c;
                        pw.professorName = pr.Professor__r.Name;
                        pw.designation = pr.Professor__r.Designation__c;
                        pw.prefrence = pr.Preference__c;
                        pw.professorAssigned = false;
                        pw.isPrimary = false;
                        pw.isAlreadyConnectedToCourse = false;

                        assign.professorsForBatch.add(pw);
                        usedPrefProfessors.add(pr.Professor__c);
                        filled++;
                    }
                }
            }

                if (!assign.professorsForBatch.isEmpty()) {
                    autoWrap.batchAssignments.add(assign);
                }
            }

        }

        return autoWrap;
    }

    private static BatchPreferenceWrapper buildManualAllocation(
        List<hed__Term__c> terms,
        Map<String, BatchPreferenceWrapper> preferenceMap,
        List<Contact> proList,
        Decimal targetSlots,
        boolean isSectionLevelAllocationAllowed,
        String type
    ) {
        BatchPreferenceWrapper manualWrap = new BatchPreferenceWrapper();
        manualWrap.preferenceLabel = 'Manual-Allocation';
        manualWrap.availableProfessors = proList;
        if(isSectionLevelAllocationAllowed){
            manualWrap.isSectionLevelAllocationAllowed = isSectionLevelAllocationAllowed;
            for (hed__Term__c t : terms) {
                Boolean alreadyInAuto = false;

                if (preferenceMap.containsKey('AUTO')) {
                    for (BatchAssignmentWrapper a : preferenceMap.get('AUTO').batchAssignments) {
                        if (a.batchId == String.valueOf( t.Id)) {
                            alreadyInAuto = true;
                            if (a.professorsForBatch.size() < targetSlots) {
                                BatchAssignmentWrapper manualBatch = new BatchAssignmentWrapper();
                                manualBatch.batchId = String.valueOf( t.Id);
                                manualBatch.batchName = (t.Batch_Short_Name__c != null ? t.Batch_Short_Name__c
                                                         : t.Section_Name__c != null ? t.Section_Name__c
                                                         :  String.fromCharArray(new List<Integer>{64 + t.Group_Number__c.intValue()}));
                                Decimal remaining = targetSlots - a.professorsForBatch.size();
                                for (Decimal i = 0; i < remaining; i++) {
                                    ProfessorWrapper empty = new ProfessorWrapper();
                                    empty.professorAssigned = false;
                                    empty.isPrimary = false;
                                    empty.prefrence = 'Manual';
                                    manualBatch.professorsForBatch.add(empty);
                                }
                                manualWrap.batchAssignments.add(manualBatch);
                            }
                            break;
                        }
                    }
                }

                if (!alreadyInAuto) {
                    BatchAssignmentWrapper manualBatch = new BatchAssignmentWrapper();
                    manualBatch.batchId = String.valueOf( t.Id);
                    manualBatch.batchName = (t.Batch_Short_Name__c != null ? t.Batch_Short_Name__c
                                             : t.Section_Name__c != null ? t.Section_Name__c
                                             :  String.fromCharArray(new List<Integer>{64 + t.Group_Number__c.intValue()}));
                    for (Integer i = 0; i < targetSlots; i++) {
                        ProfessorWrapper empty = new ProfessorWrapper();
                        empty.professorAssigned = false;
                        empty.isPrimary = false;
                        manualBatch.professorsForBatch.add(empty);
                    }
                    manualWrap.batchAssignments.add(manualBatch);
                }
            }

        }
        else if ( !isSectionLevelAllocationAllowed && type == 'Batch') {
            manualWrap.isSectionLevelAllocationAllowed = isSectionLevelAllocationAllowed;


            Integer noOfSections = terms[0].No_of_Sections__c != null ? terms[0].No_of_Sections__c.intValue() : 0;
            Integer noOfBatchesPerSection = terms[0].Program_Batch__r.Batches_Per_Section__c != null ? terms[0].Program_Batch__r.Batches_Per_Section__c.intValue(): 0;

            for (Integer secIndex = 0; secIndex < noOfSections; secIndex++) {
                String sectionName =  String.fromCharArray(new List<Integer>{65 + secIndex});
                String sectionId   = 'TEMP-SEC-' + String.valueOf(secIndex+1);

                for (Integer batchIndex = 0; batchIndex < noOfBatchesPerSection; batchIndex++) {
                    String batchId = sectionId + '-BATCH-' + String.valueOf(batchIndex+1);

                    BatchAssignmentWrapper manualBatch = new BatchAssignmentWrapper();
                    manualBatch.batchId   = batchId;
                    manualBatch.batchName = sectionName + String.valueOf(batchIndex+1);

                    Integer alreadyAssigned = 0;

                    // If AUTO exists, count already assigned professors
                    if (preferenceMap.containsKey('AUTO')) {
                        for (BatchAssignmentWrapper a : preferenceMap.get('AUTO').batchAssignments) {
                            if (a.batchId == batchId) {
                                alreadyAssigned = a.professorsForBatch.size();
                                break;
                            }
                        }
                    }

                    Integer remaining = targetSlots.intValue() - alreadyAssigned;

                    for (Integer slot = 0; slot < remaining; slot++) {
                        ProfessorWrapper empty = new ProfessorWrapper();
                        empty.professorAssigned = false;
                        empty.isPrimary = false;
                        empty.prefrence = 'Manual';
                        manualBatch.professorsForBatch.add(empty);
                    }

                    if (!manualBatch.professorsForBatch.isEmpty()) {
                        manualWrap.batchAssignments.add(manualBatch);
                    }
                }
            }
        }

        else {
            manualWrap.isSectionLevelAllocationAllowed = isSectionLevelAllocationAllowed;
            Integer noOfSections = terms[0].No_of_Sections__c != null ? terms[0].No_of_Sections__c.intValue() : 0;
            // Integer noOfBatchesPerSection = terms[0].Program_Batch__r.Batches_Per_Section__c != null ? terms[0].Program_Batch__r.Batches_Per_Section__c.intValue()  : 0;

            for (Integer secIndex = 0; secIndex < noOfSections; secIndex++) {
                String secId = 'TEMP-SEC-' + String.valueOf(secIndex+1);
                BatchAssignmentWrapper manualBatch = new BatchAssignmentWrapper();
                manualBatch.batchId = secId;
                manualBatch.batchName =  String.fromCharArray(new List<Integer>{65 + secIndex});

                Integer alreadyAssigned = 0;

                if (preferenceMap.containsKey('AUTO')) {
                    for (BatchAssignmentWrapper a : preferenceMap.get('AUTO').batchAssignments) {
                        if (a.batchId == secId) {
                            alreadyAssigned = a.professorsForBatch.size();
                            break;
                        }
                    }
                }

                Integer remaining = targetSlots.intValue() - alreadyAssigned;

                for (Integer slot = 0; slot < remaining; slot++) {
                    ProfessorWrapper empty = new ProfessorWrapper();
                    empty.professorAssigned = false;
                    empty.isPrimary = false;
                    empty.prefrence = 'Manual';
                    manualBatch.professorsForBatch.add(empty);
                }

                if (!manualBatch.professorsForBatch.isEmpty()) {
                    manualWrap.batchAssignments.add(manualBatch);
                }
            }


        }


        return manualWrap;
    }




    /**
* @description Saves professor preferences for course allocations.
* @param saveWrapper A list of ProfessorBatchWrapper objects containing professor and batch details.
* @return A ResponseWrapper object indicating the success or failure of the operation.
*/
    @AuraEnabled
    public static ResponseWrapper saveProfessorPreferences(List<ProfessorBatchWrapper> saveWrapper) {
        ResponseWrapper res = new ResponseWrapper();

        if (saveWrapper == null || saveWrapper.isEmpty()) {
            res.success = false;
            res.message = 'No data received from client.';
            return res;
        }

        try {


            Set<Id> courseIds = collectOfferingIds(saveWrapper);
            deleteExistingEnrollments(courseIds,saveWrapper[0].termId);



            List<hed__Course_Enrollment__c> toInsert = prepareNewEnrollments(saveWrapper,courseIds);
            insertNewEnrollments(toInsert ,saveWrapper[0].termId);

            res.success = true;
            res.message = 'Professor details saved successfully.';
        } catch (Exception e) {
            res.success = false;
            res.message = 'Error while saving professor preferences: ' + e.getMessage();
        }

        return res;
    }

    private static Set<Id> collectOfferingIds(List<ProfessorBatchWrapper> saveWrapper) {
        Set<Id> courseIds = new Set<Id>();
        for (ProfessorBatchWrapper w : saveWrapper) {
            if (String.isNotBlank(w.courseId)) {
                courseIds.add(w.courseId);
            }
        }
        return courseIds;
    }
    private static void updateCourseOfferings(Set<Id> courseIds, Id termId) {
        List<hed__Course_Offering__c> courseOfferings = new List<hed__Course_Offering__c>();
        for (hed__Course_Offering__c co : [
            SELECT Id, hed__Course__c, Faculty_Course_Connection_Created__c
            FROM hed__Course_Offering__c
            WHERE hed__Course__c IN :courseIds AND (hed__Term__r.hed__Parent_Term__c = :termId OR hed__Term__c = :termId) WITH USER_MODE
        ]) {
            co.Faculty_Course_Connection_Created__c = true;
            courseOfferings.add(co);
        }
        if (!courseOfferings.isEmpty()) {
            if (Schema.sObjectType.hed__Course_Offering__c.isUpdateable()) {
                update courseOfferings;
            } else {
                throw new AuraHandledException('Insufficient permissions to update Course Offerings.');
            }
        }
    }


    private static void deleteExistingEnrollments(Set<Id> courseIds, Id termId) {
        if (!courseIds.isEmpty()) {
            List<hed__Course_Enrollment__c> existing = [
                SELECT Id ,Section__r.hed__Parent_Term__c,hed__Course_Offering__r.hed__Course__c,hed__Primary__c
                FROM hed__Course_Enrollment__c
                WHERE hed__Course_Offering__r.hed__Course__c IN :courseIds AND RecordType.Name = 'Faculty'
                AND (Section__r.hed__Parent_Term__c = :termId OR Section__r.hed__Parent_Term__r.hed__Parent_Term__c  = :termId OR Section__c =: termId) WITH USER_MODE
            ];
            if (!existing.isEmpty() && Schema.sObjectType.hed__Course_Enrollment__c.isDeletable()) {
                delete existing;
            }
        }
    }

    private static List<hed__Course_Enrollment__c> prepareNewEnrollments(List<ProfessorBatchWrapper> saveWrapper, Set<Id> courseIds) {
        List<hed__Course_Enrollment__c> toInsert = new List<hed__Course_Enrollment__c>();
        String ccRtId = Schema.SObjectType.hed__Course_Enrollment__c
            .getRecordTypeInfosByName()
            .get('Faculty')
            .getRecordTypeId();

        map<String,List<hed__Course_Offering__c>>  mapingCourseOfferings = mapingCourseOfferings(saveWrapper,courseIds);


        // Collect all batch IDs to query in bulk
        Set<Id> batchIds = new Set<Id>();
        for (ProfessorBatchWrapper w : saveWrapper) {
            if (String.isNotBlank(w.batchId)) {
                batchIds.add(w.batchId);
            }
        }

        // Query all batches in bulk and store in a map
        Map<Id, hed__Term__c> batchMap = new Map<Id, hed__Term__c>(
            [SELECT Id, hed__Parent_Term__c FROM hed__Term__c WHERE Id IN :batchIds WITH USER_MODE]
        );

        for (ProfessorBatchWrapper w : saveWrapper) {
            if (String.isNotBlank(w.professorId) && String.isNotBlank(w.courseOffId)) {
                hed__Term__c batch = String.isNotBlank(w.batchId) ? batchMap.get(w.batchId) : null;


                hed__Course_Enrollment__c ce = new hed__Course_Enrollment__c();
                String key = w.courseId + '-' +
                    (String.isNotBlank(w.batchId)
                     ?batch.hed__Parent_Term__c
                     : (String.isNotBlank(w.sectionId)
                        ? w.sectionId
                        : w.termId));
                ce.RecordTypeId = ccRtId;
                ce.hed__Primary__c = w.isPrimary;
                ce.Secondary__c = w.isPrimary ? false : true;
                ce.hed__Contact__c = w.professorId;
                ce.hed__Course_Offering__c = mapingCourseOfferings.get(key) != null && !mapingCourseOfferings.get(key).isEmpty() ? mapingCourseOfferings.get(key)[0].Id : w.courseOffId;
                ce.Section__c = String.isNotBlank(w.batchId) ? w.batchId : String.isNotBlank(w.sectionId) ? w.sectionId : w.termId;
                ce.Allotted_Section__c = String.isNotBlank(w.sectionCode) ? w.sectionCode : null;
                ce.Allotted_Batch_Number__c = String.isNotBlank(w.batchCode) ? w.batchCode : null;
                toInsert.add(ce);
            }
        }
        return toInsert;
    }

    private static map<String,List<hed__Course_Offering__c>>  mapingCourseOfferings(List<ProfessorBatchWrapper> saveWrapper,  Set<Id> courseIds) {

        Map<String, List<hed__Course_Offering__c>> courseOfferingMap = new Map<String, List<hed__Course_Offering__c>>();

        for (hed__Course_Offering__c co : [
            SELECT Id, hed__Course__c, Faculty_Course_Connection_Created__c,hed__Term__c,hed__Term__r.hed__Parent_Term__c
            FROM hed__Course_Offering__c
            WHERE hed__Course__c IN :courseIds
            AND (hed__Term__r.hed__Parent_Term__c = :saveWrapper[0].termId OR hed__Term__c = :saveWrapper[0].termId)
            WITH USER_MODE
        ]) {

            // Build the composite key (Course + Section/Group)
            String key = co.hed__Course__c + '-' + co.hed__Term__c ;

            if (!courseOfferingMap.containsKey(key)) {
                courseOfferingMap.put(key, new List<hed__Course_Offering__c>());
            }
            courseOfferingMap.get(key).add(co);
        }
        return courseOfferingMap;
    }


    private static void insertNewEnrollments(List<hed__Course_Enrollment__c> toInsert, Id termId) {
        if (!toInsert.isEmpty()) {
            if (Schema.sObjectType.hed__Course_Enrollment__c.isCreateable()) {
                insert toInsert;

                // Query the newly inserted enrollments with their course offerings
                List<hed__Course_Enrollment__c> newEnrollments = [
                    SELECT Id, hed__Course_Offering__c, hed__Primary__c,
                           hed__Course_Offering__r.hed__Course__c,
                           hed__Course_Offering__r.hed__Course__r.Name
                    FROM hed__Course_Enrollment__c
                    WHERE Id IN :toInsert
                ];

                Set<Id> courseIds = new Set<Id>();
                for (hed__Course_Enrollment__c ce : newEnrollments) {
                    if (ce.hed__Course_Offering__c != null) {
                        courseIds.add(ce.hed__Course_Offering__r.hed__Course__c);
                    }
                }

                if (!courseIds.isEmpty()) {
                    updateCourseOfferings(courseIds, termId);
                }

            } else {
                throw new AuraHandledException('Insufficient permissions to create Course Enrollments.');
            }
        }

    }
    
    @AuraEnabled(cacheable=true)
public static List<ProfessorPreferenceWrapper> getProfessorPreferencesForCourse(
    Id semesterId,
    Id courseId
){
    List<ProfessorPreferenceWrapper> result = new List<ProfessorPreferenceWrapper>();

    for(Professor_Student_Course_Preference__c pref : [
        SELECT Id,
               Preference__c,
               Professor__c,Number_of_Times_Course_Handled__c,
               Professor__r.Name
        FROM Professor_Student_Course_Preference__c
        WHERE Semester__c = :semesterId
        AND Course_Offering__r.hed__Course__c = :courseId
        AND Professor_Preference__c = true
        ORDER BY Preference__c ASC
    ]){
        ProfessorPreferenceWrapper w = new ProfessorPreferenceWrapper();
        w.preference = pref.Preference__c;
        w.professorId = pref.Professor__c;
        w.professorName = pref.Professor__r.Name;
        w.numberOfTimesCourseHandled = pref.Number_of_Times_Course_Handled__c;
        
        result.add(w);
    }

    return result;
}
 public class ProfessorPreferenceWrapper{

    @AuraEnabled
    public String preference;

    @AuraEnabled
    public Id professorId;

    @AuraEnabled
    public String professorName;
     
     @AuraEnabled
    public Decimal numberOfTimesCourseHandled;
}

    /**
* @description Wrapper class to hold categorized course details and sections.
*/
    public class MainCourseWrap{

        /**
* @description List of hardcore courses.
*/
        @AuraEnabled public list<CourseWrap> listHardCore {get;set;}

        /**
* @description List of open elective courses.
*/
        @AuraEnabled public list<ParentWrap> listOpenElective {get;set;}

        /**
* @description List of professional elective courses.
*/
        @AuraEnabled public list<ParentWrap> listProfElective {get;set;}

        /**
* @description List of practical courses.
*/
        @AuraEnabled public list<CourseWrap> listPractical {get;set;}

        /**
* @description List of hardcore integrated courses.
*/
        @AuraEnabled public list<CourseWrap> listHcIntegrated {get;set;}

        /**
* @description List of mandatory courses.
*/
        @AuraEnabled public list<CourseWrap> listMandatory {get;set;}

        /**
* @description List of section names.
*/
        @AuraEnabled public list<string> lstSection {get;set;}

    }

    /**
* @description Wrapper class for parent course details.
*/
    public class ParentWrap{
        /**
* @description The count of courses.
*/
        @AuraEnabled public string count {get;set;}

        /**
* @description The record ID of the parent course.
*/
        @AuraEnabled public string recordId {get;set;}

        /**
* @description The name of the course.
*/
        @AuraEnabled public string courseName {get;set;}

        /**
* @description The ID of the course.
*/
        @AuraEnabled public string courseId {get;set;}

        /**
* @description Indicates whether the course is confirmed.
*/
        @AuraEnabled public boolean isConfirmed {get;set;}

        /**
* @description List of child courses associated with the parent course.
*/
        @AuraEnabled public list<CourseWrap> lstCourse {get;set;}

        /**
* @description The name of the parent course.
*/
        @AuraEnabled public string parentCourseName {get;set;}

        /**
* @description The ID of the parent course.
*/
        @AuraEnabled public string parentId {get;set;}

        /**
* @description Constructor for the ParentWrap class.
*/
        public ParentWrap(){
            lstCourse = new list<CourseWrap> ();
        }
    }




    /**
* @description Wrapper class for course details.
*/
    public class CourseWrap{
        /**
* @description The count of courses.
*/
        @AuraEnabled public string count {get;set;}

        /**
* @description The name of the course.
*/
        @AuraEnabled public string courseName {get;set;}
        /**
* @description The ID of the course.
*/
        @AuraEnabled public string courseId {get;set;}

        /**
* @description Indicates whether the course is confirmed.
*/
        @AuraEnabled public boolean isConfirmed {get;set;}

        /**
* @description Indicates whether the course has a faculty connection.
*/
        @AuraEnabled public boolean hasCourseOfferingConfirmed {get;set;}

        /**
* @description The ID of the course offering.
*/
        @AuraEnabled public Id courseOfferId {get;set;}

        /**
* @description Indicates whether the course offering is confirmed.
*/
        @AuraEnabled public boolean isCourseOfferingConfirmed {get;set;}

        /**
* @description A list of course sections associated with the course.
*/
        @AuraEnabled public list<CourseSectionWrap> lstSection {get;set;}

        /**
* @description Constructor for the CourseWrap class.
* Initializes the list of course sections.
*/
        public CourseWrap(){
            lstSection = new list<CourseSectionWrap> ();
        }
    }



    /**
* @description Wrapper class for course section details.
*/
    public class CourseSectionWrap{
        /**
* @description The count of courses.
*/
        @AuraEnabled public string count {get;set;}

        /**
* @description The record ID of the course section.
*/
        @AuraEnabled public string recordId {get;set;}

        /**
* @description The name of the course.
*/
        @AuraEnabled public string courseName {get;set;}

        /**
* @description The ID of the course.
*/
        @AuraEnabled public string courseId {get;set;}

        /**
* @description The name of the section.
*/
        @AuraEnabled public string sectionName {get;set;}

        /**
* @description The name of the batch.
*/
        @AuraEnabled public string batchName {get;set;}

        /**
* @description The name of the group.
*/
        @AuraEnabled public string groupName {get;set;}

        /**
* @description The ID of the group.
*/
        @AuraEnabled public string groupId {get;set;}

        /**
* @description The ID of the term.
*/
        @AuraEnabled public string termId {get;set;}

        /**
* @description The minimum number of courses.
*/
        @AuraEnabled public decimal minCource {get;set;}

        /**
* @description Indicates whether a professor is assigned.
*/
        @AuraEnabled public boolean professorAssiened {get;set;}

        /**
* @description Constructor for the CourseSectionWrap class.
* Initializes the professorAssiened field to false.
*/
        public CourseSectionWrap(){
            professorAssiened = false;
        }
    }


    /**
* @description Wrapper class for batch preference details.
*/
    public class BatchPreferenceWrapper {
        /**
* @description The label for the preference (e.g., Auto-Allocation or Manual-Allocation).
*/
        @AuraEnabled public String preferenceLabel { get; set; }
/**
    * @description Indicates whether section-level allocation is allowed for the batch preference.
*/
    @AuraEnabled public boolean isSectionLevelAllocationAllowed { get; set; }

/**
* @description A list of batch assignments associated with the preference.
*/
        @AuraEnabled public List<BatchAssignmentWrapper> batchAssignments { get; set; }

        /**
* @description A list of available professors for the batch preference.
*/
        @AuraEnabled public List<Contact> availableProfessors { get; set; }

        /**
* @description Constructor for the BatchPreferenceWrapper class.
* Initializes the batchAssignments and availableProfessors lists.
*/
        public BatchPreferenceWrapper(){
            batchAssignments = new list<BatchAssignmentWrapper>();
            availableProfessors = new list<Contact>();
        }
    }

    /**
* @description Wrapper class for batch assignment details.
*/
    public class BatchAssignmentWrapper {
        /**
* @description The ID of the batch.
*/
        @AuraEnabled public String batchId { get; set; }

        /**
* @description The name of the batch.
*/
        @AuraEnabled public String batchName { get; set; }

        /**
* @description The name of the professor.
*/
        @AuraEnabled public String professorName { get; set; }

        /**
* @description The designation of the professor.
*/
        @AuraEnabled public String designation { get; set; }

        /**
* @description The ID of the professor.
*/
        @AuraEnabled public Id professorId { get; set; }


        /**
* @description A list of professors assigned to the batch.
*/
        @AuraEnabled public List<ProfessorWrapper> professorsForBatch { get; set; }

        /**
* @description Constructor for the BatchAssignmentWrapper class.
* Initializes the professorsForBatch list.
*/
        public BatchAssignmentWrapper(){
/**
* @description Initializes the list of professors for the batch.
*/
            professorsForBatch = new list<ProfessorWrapper>();
        }
    }

    /**
    * @description Wrapper class for professor details.
    */
    public class ProfessorWrapper {
        /**
* @description The name of the professor.
*/
        @AuraEnabled public String professorName { get; set; }

        /**
* @description The designation of the professor.
*/
        @AuraEnabled public String designation { get; set; }

        /**
* @description The ID of the professor.
*/
        @AuraEnabled public Id professorId { get; set; }


        /**
* @description Indicates whether the professor is already connected to the course.
*/
        @AuraEnabled public Boolean isAlreadyConnectedToCourse  { get; set; }

        /**
* @description Indicates whether the professor is assigned to the batch.
*/
        @AuraEnabled public Boolean professorAssigned  { get; set; }
		/**
* @description Indicates whether the professor is the primary instructor for the batch.
*/
        @AuraEnabled public Boolean isPrimary  { get; set; }

        /**
* @description The preference of the professor for the course.
*/
        @AuraEnabled public String prefrence  { get; set; }
    }
    // batch related wrppers------------------------//

    /**
* @description Wrapper class for professor batch details.
*/
    public class ProfessorBatchWrapper {
        /**
* @description The ID of the batch.
*/
        @AuraEnabled public String batchId {get; set;}

        /**
* @description The ID of the section.
*/
        @AuraEnabled public String sectionId {get; set;}

/**
* @description The code of the section.
*/
        @AuraEnabled public String sectionCode {get; set;}

/**
* @description The code of the batch.
*/
        @AuraEnabled public String batchCode {get; set;}


/**
* @description Indicates whether section-level allocation is allowed for the professor batch.
*/
        @AuraEnabled public boolean isSectionLevelAllocationAllowed {get; set;}


        /**
* @description The ID of the professor.
*/
        @AuraEnabled public String professorId {get; set;}

        /**
* @description The ID of the course offering.
*/
        @AuraEnabled public String courseOffId {get; set;}
        /**
* @description The ID of the course.
*/
        @AuraEnabled public String courseId {get; set;}

        /**
* @description The ID of the term.
*/
        @AuraEnabled public String termId {get; set;}

        /**
        * @description Indicates whether the professor is the primary instructor for the batch.
        */
        @AuraEnabled public boolean isPrimary {get; set;}
    }

    /**
* @description Wrapper class for response details.
*/
    public class ResponseWrapper {
        /**
* @description Indicates whether the operation was successful.
*/
        @AuraEnabled public Boolean success {get; set;}

        /**
* @description The message associated with the operation result.
*/
        @AuraEnabled public String message {get; set;}
    }

}