/**
 * @description  Controller for managing RBS student group allocations:
 *               retrieves term/course details, creates or deletes groups,
 *               and assigns/unassigns students while enforcing user-mode security.
 */
public with sharing class RBSstudentGroupAllocation_Ctrl {
    /**
     * @description Get term details and related course offerings.
     * @param recordId RBS specialization record Id.
     * @return DetailsWrp with term and course info.
     */
   @AuraEnabled
    public Static DetailsWrp getTermAndRBSCourseDetails(String recordId)
    {
        DetailsWrp objDetailsWrp = new DetailsWrp();
        for(hed__Term__c objTerm : [Select Id, Name, Program_Batch__c, Program_Batch__r.Name from hed__Term__c
                                    where Id =: recordId WITH USER_MODE])
        {
            objDetailsWrp.objTerm = objTerm;
        }

        for(hed__Course_Offering__c objCourseOffr : [Select Id, Name, Category__c, hed__Course__c, hed__Term__c,
                                                     hed__Course__r.Name, Specialization__r.Name,
                                                     Parent_Course_Offering__c, Assigned__c from hed__Course_Offering__c
                                                     where hed__Term__c =: recordId AND Specialization__r.Name != Null
                                                     AND Category__c IN ('RBS Specialization')
                                                     AND Active__c =: True AND Assigned__c > 0 WITH USER_MODE
                                                     ORDER BY Specialization__r.Name ])
        {
            ElectiveWrp objElectWrp = new ElectiveWrp();
            objElectWrp.parentCourseName = objCourseOffr.Specialization__r.Name;
            objElectWrp.parentCourseId = objCourseOffr.Specialization__c;
            objElectWrp.subjectName = objCourseOffr.Name;
            objElectWrp.subjectID = objCourseOffr.Id;
            objElectWrp.courseCode = objCourseOffr.hed__Course__r.Name;
            objElectWrp.totlNoOfStudents = Integer.valueOf(objCourseOffr.Assigned__c);
            if(objDetailsWrp.mapElectiveWrp.get(objElectWrp.parentCourseName) == Null)
            {
                objDetailsWrp.mapElectiveWrp.put(objElectWrp.parentCourseName, new List<ElectiveWrp>());
            }
            objDetailsWrp.mapElectiveWrp.get(objElectWrp.parentCourseName).add(objElectWrp);
        }
        //System.debug('objDetailsWrp.mapElectiveWrp=='+objDetailsWrp.mapElectiveWrp);
        return objDetailsWrp;
    }

    /**
     * @description Creates the specified number of RBS group term records for a course offering.
     * @param noOfGroup  Number of groups to create.
     * @param subjectId  Id of the Course Offering (hed__Course_Offering__c).
     * @param courseCode Course code to prefix each group name.
     * @param recordId   Id of the parent Term (hed__Term__c).
     * @return WrapperClass containing a status message (e.g., "Success" or error details).
     */
    @AuraEnabled
    public static WrapperClass createRBSGroups(Integer noOfGroup, String subjectId, String courseCode, String recordId)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        hed__Term__c objTerm = new hed__Term__c();
        objTerm = [Select Id, Name, hed__Account__c from hed__Term__c where Id =: recordId WITH USER_MODE];
        String recTypeName = Utility.Term_RecType_Group;
        String recTypeId = Schema.getGlobalDescribe().get('hed__Term__c').getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        List<hed__Term__c> lstGroups = new List<hed__Term__c>();
        try
        {
            for(Integer i=0; i< noOfGroup; i++)
            {
                String groupAlpha = String.fromCharArray( new List<integer> { 65 + i} );
                hed__Term__c objGroup = new hed__Term__c();
                objGroup.RecordTypeId = recTypeId;
                objGroup.hed__Account__c = objTerm.hed__Account__c;
                objGroup.Name = courseCode+'-'+groupAlpha; //objTerm.Name+'-'+courseCode+'-'+groupAlpha;
                objGroup.Course_Offering__c = subjectId;
                objGroup.hed__Parent_Term__c = recordId;
                objGroup.Group_Number__c = i+1;
                lstGroups.add(objGroup);
            }
            if(lstGroups.size() >0) {
                if(Schema.sObjectType.hed__Term__c.isCreateable()) {
                    insert lstGroups;
                    objWrapperClass.strMessage = 'Success';
                } else {
                    objWrapperClass.strMessage = 'Insufficient permissions to create Term records';
                }
            }
        }
        Catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage();
        }
        return objWrapperClass;
    }

    /**
     * @description Deletes existing group term allocations and related student mappings
     *              for the specified course offering and parent term.
     * @param subjectId Id of the Course Offering (hed__Course_Offering__c).
     * @param recordId  Id of the parent Term (hed__Term__c).
     * @return WrapperClass containing a status message ("Success" or error details).
     */
    @AuraEnabled
    public static WrapperClass deleteExistingGroupAllocations(String subjectId, String recordId)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        String recTypeName = Utility.Term_RecType_Group;

        List<hed__Term__c> lstGroupAllocation = new List<hed__Term__c>();
        Set<String> setGroupIds = new Set<String>();
        try
        {
            for(hed__Term__c objGroup : [Select Id from hed__Term__c where Course_Offering__c =:subjectId
                                         AND hed__Parent_Term__c=:recordId AND RecordType.Name=:recTypeName WITH USER_MODE])
            {
                setGroupIds.add(objGroup.Id);
                lstGroupAllocation.add(objGroup);
            }

            if(!setGroupIds.isEmpty())
            {
                List<Student_Semester_Mapping__c> lstStudMap = new List<Student_Semester_Mapping__c>();
                lstStudMap = [Select Id from Student_Semester_Mapping__c where Student_Group__c IN: setGroupIds WITH USER_MODE];
                if(lstStudMap.size() > 0) {
                    if(Schema.sObjectType.Student_Semester_Mapping__c.isDeletable()) {
                        delete lstStudMap;
                    } else {
                        objWrapperClass.strMessage = 'Insufficient permission to delete Student Semester Mapping records';
                        return objWrapperClass;
                    }
                }

            }

            if(lstGroupAllocation.size() > 0) {
                if(Schema.sObjectType.hed__Term__c.isDeletable()) {
                    delete lstGroupAllocation;
                } else {
                    objWrapperClass.strMessage = 'Insufficient permission to delete Term records';
                    return objWrapperClass;
                }
            }

            objWrapperClass.strMessage = 'Success';
        }
        Catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage();
        }
        return objWrapperClass;
    }

    /**
     * @description Retrieves existing RBS group details and student allocations for a course offering.
     * @param subjectId Id of the Course Offering (hed__Course_Offering__c).
     * @param recordId  Id of the parent Term (hed__Term__c).
     * @return WrapperClass with group info, assigned students, and unassigned course connections.
     */
    @AuraEnabled
    public static WrapperClass getExistingGroups(String subjectId, String recordId)
    {
        WrapperClass objWrapperClass = new WrapperClass();
       // List<hed__Term__c> lstGroupAllocation = new List<hed__Term__c>();
        String recTypeName = Utility.Term_RecType_Group;
        Set<Id> setGroupIds = new Set<Id>();
        Set<Id> setProgEnrollId = new Set<Id>();
        //Integer count = 0;
        for (hed__Term__c objGroup : [Select Id, Name, Group_Number__c from hed__Term__c where RecordType.Name=:recTypeName
                                      AND Course_Offering__c =:subjectId AND hed__Parent_Term__c=:recordId WITH USER_MODE])
        {
            GroupWrapperClass objGrpWrp = new GroupWrapperClass();
            objGrpWrp.groupNo = String.valueOf(objGroup.Group_Number__c);
            objGrpWrp.groupName = objGroup.Name;
            objGrpWrp.groupId = objGroup.Id;
            objWrapperClass.objGroupMainWrp.mapGroupWrp.put(objGrpWrp.groupNo, objGrpWrp);
            objWrapperClass.objGroupMainWrp.mapGroups.put(objGrpWrp.groupNo, objGrpWrp.groupName);
            objWrapperClass.objGroupMainWrp.mapGroupDetails.put(String.valueOf(objGroup.Group_Number__c), objGroup);
            setGroupIds.add(objGroup.Id);
        }

        if(!setGroupIds.isEmpty())
        {
            for(Student_Semester_Mapping__c objSTMGroup : [Select Id, Name, Program_Enrollment__c, Student_Group__c,
                                                           Program_Enrollment__r.Name, Program_Enrollment__r.SRN_Number__c,
                                                           Program_Enrollment__r.Section__c, Student_Group__r.Course_Offering__c,
                                                           Student_Group__r.Course_Offering__r.Name, Student_Group_Number__c,
                                                           Program_Enrollment__r.Section__r.Name, Student_Group__r.Name,
                                                           Program_Enrollment__r.hed__Contact__c, Program_Enrollment__r.hed__Program_Plan__c,
                                                           Program_Enrollment__r.hed__Contact__r.Name, Program_Enrollment__r.Semester__c,
                                                           Program_Enrollment__r.Semester__r.Name, Course_Offering_ID__c from
                                                           Student_Semester_Mapping__c where Student_Group__c IN: setGroupIds AND
                                                           Student_Group__r.Course_Offering__c =: subjectId WITH USER_MODE ORDER BY
                                                           Program_Enrollment__r.SRN_Number__c ASC])
            {
                CourseConnectionWrp objCourseConnection = new CourseConnectionWrp();
                objCourseConnection.isChecked = false;
                objCourseConnection.contactId = objSTMGroup.Program_Enrollment__r.hed__Contact__c;
                objCourseConnection.contactName = objSTMGroup.Program_Enrollment__r.hed__Contact__r.Name;
                objCourseConnection.progEnrollId = objSTMGroup.Program_Enrollment__c;
                objCourseConnection.progEnrollName = objSTMGroup.Program_Enrollment__r.Name;
                objCourseConnection.srnNumber = objSTMGroup.Program_Enrollment__r.SRN_Number__c;
                objCourseConnection.sectionId = objSTMGroup.Program_Enrollment__r.Section__c;
                objCourseConnection.sectionName = objSTMGroup.Program_Enrollment__r.Section__r.Name;
                objCourseConnection.progPlanId = objSTMGroup.Program_Enrollment__r.hed__Program_Plan__c;
                objCourseConnection.semesterId = objSTMGroup.Program_Enrollment__r.Semester__c;
                objCourseConnection.semesterName = objSTMGroup.Program_Enrollment__r.Semester__r.Name;
                objCourseConnection.subjectId = objSTMGroup.Student_Group__r.Course_Offering__c;
                objCourseConnection.subjectName = objSTMGroup.Student_Group__r.Course_Offering__r.Name;
                //objCourseConnection.courseOfferId = objSTMGroup.Course_Offering_ID__c;

                String strKey = String.valueOf(objSTMGroup.Student_Group_Number__c);
                if(objWrapperClass.objGroupMainWrp.mapGroupWrp.get(strKey) != Null)
                {
                    objCourseConnection.groupId = objWrapperClass.objGroupMainWrp.mapGroupWrp.get(strKey).groupId;
                    objCourseConnection.oldGroupId = objWrapperClass.objGroupMainWrp.mapGroupWrp.get(strKey).groupId;
                    objCourseConnection.groupName = objWrapperClass.objGroupMainWrp.mapGroupWrp.get(strKey).groupName;
                    objCourseConnection.groupNo = objWrapperClass.objGroupMainWrp.mapGroupWrp.get(strKey).groupNo;
                    objWrapperClass.objGroupMainWrp.mapGroupWrp.get(strKey).lstcourseCons.add(objCourseConnection);
                    setProgEnrollId.add(objSTMGroup.Program_Enrollment__c);
                }
            }
        }

        if(!setProgEnrollId.isEmpty())
        {
            for(hed__Course_Enrollment__c objCourseConn : [Select Id, Name, Section__c, Section__r.Name, hed__Program_Enrollment__c,
                                                           hed__Program_Enrollment__r.Name, hed__Program_Enrollment__r.SRN_Number__c,
                                                           hed__Program_Enrollment__r.hed__Contact__r.Name, Section__r.hed__Parent_Term__c,
                                                           hed__Program_Enrollment__r.hed__Contact__c, Section__r.hed__Parent_Term__r.Name,
                                                           Section__r.hed__Parent_Term__r.Program_Batch__c, hed__Course_Offering__c,
                                                           hed__Course_Offering__r.Name, hed__Program_Enrollment__r.Section__c,
                                                           hed__Program_Enrollment__r.Section__r.Name from hed__Course_Enrollment__c where
                                                           hed__Course_Offering__c=:subjectId AND hed__Course_Offering__c != null AND
                                                           hed__Program_Enrollment__c Not IN : setProgEnrollId  AND hed__Program_Enrollment__c !=null WITH USER_MODE
                                                           ORDER BY hed__Program_Enrollment__r.SRN_Number__c ASC])
            {
                CourseConnectionWrp objCourseConnection = getCourseConnectionData(objCourseConn);
                objWrapperClass.objGroupMainWrp.lstUnassigned.add(objCourseConnection);
            }
        }
        //if(count == 0)
            //objWrapperClass.objGroupMainWrp.lstUnassigned.clear();

        if(objWrapperClass.objGroupMainWrp.mapGroupWrp.size() > 0)
        {
            objWrapperClass.strMessage = 'Records Exists';
            objWrapperClass.totalGroupRecords = objWrapperClass.objGroupMainWrp.mapGroupWrp.size();
        }
        else {
            objWrapperClass.strMessage = 'Failure';
        }

        return objWrapperClass;
    }

    /**
     * @description Retrieves existing RBS group details and distributes enrolled students
     *              into groups based on the specified group size.
     * @param subjectId      Id of the Course Offering (hed__Course_Offering__c).
     * @param recordId       Id of the parent Term/Semester (hed__Term__c).
     * @param totalStudGroup Maximum number of students per group.
     * @return GroupMainWrp containing group mappings, assigned students, and unassigned list.
     */
    @AuraEnabled
    public static GroupMainWrp getGroupDetails(String subjectId, String recordId, Integer totalStudGroup)
    {
        GroupMainWrp objGroupMainWrp = new GroupMainWrp();
        //List<hed__Term__c> lstGroupAllocation = new List<hed__Term__c>();
        String recTypeName = Utility.Term_RecType_Group;

        for (hed__Term__c objGroup : [Select Id, Name, Group_Number__c from hed__Term__c where RecordType.Name=:recTypeName
                                      AND Course_Offering__c =:subjectId AND hed__Parent_Term__c=:recordId WITH USER_MODE])
        {
            GroupWrapperClass objGrpWrp = new GroupWrapperClass();
            objGrpWrp.groupNo = String.valueOf(objGroup.Group_Number__c);
            objGrpWrp.groupName = objGroup.Name;
            objGrpWrp.groupId = objGroup.Id;
            objGroupMainWrp.mapGroupWrp.put(objGrpWrp.groupNo, objGrpWrp);
            objGroupMainWrp.mapGroups.put(objGrpWrp.groupNo, objGrpWrp.groupName);
            objGroupMainWrp.mapGroupDetails.put(String.valueOf(objGroup.Group_Number__c), objGroup);
        }

        Integer maxSize = totalStudGroup;
        Integer studentNo = 1;
        Integer groupNo = 1;
        for(hed__Course_Enrollment__c objCourseConn : [Select Id, Name, hed__Program_Enrollment__r.Section__c,
                                                       Section__c, Section__r.Name, hed__Program_Enrollment__c,
                                                       hed__Program_Enrollment__r.Section__r.Name, Section__r.hed__Parent_Term__c,
                                                       hed__Program_Enrollment__r.Name, hed__Program_Enrollment__r.SRN_Number__c,
                                                       hed__Program_Enrollment__r.hed__Contact__r.Name,
                                                       hed__Program_Enrollment__r.hed__Contact__c, Section__r.hed__Parent_Term__r.Name,
                                                       Section__r.hed__Parent_Term__r.Program_Batch__c, hed__Course_Offering__c,
                                                       hed__Course_Offering__r.Name from hed__Course_Enrollment__c where
                                                       Semester_ID__c =:recordId AND hed__Course_Offering__c=:subjectId WITH USER_MODE
                                                       ORDER BY hed__Program_Enrollment__r.SRN_Number__c ASC])
        {
            Integer key = (studentNo <= (groupNo*maxSize)) ? groupNo : groupNo+1;
            groupNo = key;
            CourseConnectionWrp objCourseConnection = getCourseConnectionData(objCourseConn);
            String strKey = String.valueOf(key);
            if(objGroupMainWrp.mapGroupWrp.get(strKey) != Null)
            {
                objGroupMainWrp.mapGroupWrp.get(strKey).totalRecords = objGroupMainWrp.mapGroupWrp.get(strKey).totalRecords + 1;
                objCourseConnection.isChecked = true;
                objCourseConnection.groupId = objGroupMainWrp.mapGroupWrp.get(strKey).groupId;
                objCourseConnection.groupName = objGroupMainWrp.mapGroupWrp.get(strKey).groupName;
                objCourseConnection.groupNo = objGroupMainWrp.mapGroupWrp.get(strKey).groupNo;
                objGroupMainWrp.mapGroupWrp.get(strKey).lstcourseCons.add(objCourseConnection);
            }
            else
            {
                objGroupMainWrp.lstUnassigned.add(objCourseConnection);
                objGroupMainWrp.totalUnassignedRecords = objGroupMainWrp.totalUnassignedRecords +1;
            }
            studentNo++;
        }
        return objGroupMainWrp;
    }

    /**
     * @description Creates or updates Student Term Groups (RBS) based on the provided course connections.
     *              Optionally deletes existing mappings if `isExistDelete` is true and unassigned enrollments are handled.
     * @param strCourseCons       JSON string of CourseConnectionWrp objects representing student-course assignments.
     * @param isExistDelete       Boolean flag indicating whether to delete existing Student Semester Mapping records before creating new ones.
     * @param unAssignEnrolement  List of Program Enrollment Ids that are currently unassigned.
     * @return WrapperClass       Returns a wrapper containing a success or error message.
     */
    @AuraEnabled
    public static WrapperClass createStudTermGroupRBS(String strCourseCons,boolean isExistDelete,list<String> unAssignEnrolement)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        try
        {
            Set<String> setProgramEnrollIds = new Set<String>();
            Set<String> setOldSTMs = new Set<String>();
            Set<String> offeringIds = new Set<String>();
            Set<String> groupIds = new Set<String>();
            List<hed__Course_Enrollment__c> updateExistingConnection = new List<hed__Course_Enrollment__c>();
            setProgramEnrollIds.addAll(unAssignEnrolement);

            List<Student_Semester_Mapping__c> lstStudTermMap = new List<Student_Semester_Mapping__c>();
            List<CourseConnectionWrp> lstcourseConn= (List<CourseConnectionWrp>)JSON.deserialize(strCourseCons, List<CourseConnectionWrp>.class);
            String recTypeName = Utility.STM_RecType_Group;
            String recTypeId = Schema.getGlobalDescribe().get('Student_Semester_Mapping__c').getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();

            for(CourseConnectionWrp objcourseConn : lstcourseConn)
            {
                Student_Semester_Mapping__c objStudTermMap = new Student_Semester_Mapping__c();
                objStudTermMap.Active__c = true;
                objStudTermMap.Program_Enrollment__c = objcourseConn.progEnrollId;
                setProgramEnrollIds.add(objcourseConn.progEnrollId);
                if(String.isNotBlank(objcourseConn.oldGroupId) && objcourseConn.oldGroupId != objcourseConn.groupId){
                    setOldSTMs.add(objcourseConn.oldGroupId);
                }
                objStudTermMap.Student_Group__c = objcourseConn.groupId;
                objStudTermMap.Start_Date__c = System.today();
                objStudTermMap.Name = objcourseConn.contactName+'-'+objcourseConn.groupName;
                objStudTermMap.RecordTypeId = recTypeId;
                objStudTermMap.Course_Offering_ID__c = objcourseConn.subjectId;
                objStudTermMap.External_Id__c = objcourseConn.progEnrollId+'_'+objcourseConn.groupId+'_'+System.now();
                offeringIds.add(objcourseConn.subjectId);
                groupIds.add(objcourseConn.groupId);
                lstStudTermMap.add(objStudTermMap);

            }

            // if(!setProgramEnrollIds.isEmpty())
            // {
            //     Delete [Select Id from Student_Semester_Mapping__c where Student_Group__c IN: setOldSTMs
            //             AND Program_Enrollment__c IN: setProgramEnrollIds];
            // }

            if(isExistDelete){
                List<Student_Semester_Mapping__c> deleteUnAssignMap =[Select Id ,Course_Offering_ID__c from Student_Semester_Mapping__c where  Course_Offering_ID__c IN: offeringIds
                AND Program_Enrollment__c IN: setProgramEnrollIds WITH USER_MODE];
                delete deleteUnAssignMap;

                List<hed__Course_Enrollment__c> exiConnectionFromGroup = [SELECT id ,Semester_ID__c ,Section_Batch_Group__c ,Section__c , Course_Offering_Name__c from hed__Course_Enrollment__c WHERE hed__Course_Offering__c IN: offeringIds   AND hed__Program_Enrollment__c IN: setProgramEnrollIds WITH USER_MODE];

                for(hed__Course_Enrollment__c courseCo : exiConnectionFromGroup){
                    courseCo.Section__c = courseCo.Semester_ID__c;
                    //courseCo.Section_Batch_Group__c = courseCo.Semester_ID__c;
                    updateExistingConnection.add(courseCo);
                }

                if(!updateExistingConnection.isEmpty()) {
                    // Check update permission
                    if(Schema.sObjectType.hed__Course_Enrollment__c.isUpdateable()) {
                        update updateExistingConnection;
                    } else {
                        objWrapperClass.strMessage = 'Insufficient permission to update Course Enrollment records';
                        return objWrapperClass;
                    }
                }

            }

            if(lstStudTermMap.size() >0)
            {
                Set<Id> setSTMIds = new Set<Id>();
                Database.UpsertResult[] lstResult = Database.upsert(lstStudTermMap, Student_Semester_Mapping__c.External_Id__c, True);
                for(Integer i = 0; i <lstResult.size(); i++)
                {
                    if(lstResult[i].isSuccess())
                    {
                        setSTMIds.add(lstResult[i].Id);
                    }
                }
                if(!setSTMIds.isEmpty())
                {
                    Database.executeBatch(new MSTR_CreateCourseConnection_Batch(setSTMIds));
                }
            }

            objWrapperClass.strMessage = 'Success';
        }
        Catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage();
        }
        return objWrapperClass;
    }

    /**
     * @description Maps a hed__Course_Enrollment__c record to a CourseConnectionWrp wrapper object.
     * @param objCourseConn  The Course Enrollment record to extract data from.
     * @return CourseConnectionWrp  Returns a wrapper containing student, program enrollment, section, semester, and course details.
     */
    public static CourseConnectionWrp getCourseConnectionData(hed__Course_Enrollment__c objCourseConn)
    {
        CourseConnectionWrp objCourseConnection = new CourseConnectionWrp();
        objCourseConnection.contactId = objCourseConn.hed__Program_Enrollment__r.hed__Contact__c;
        objCourseConnection.contactName = objCourseConn.hed__Program_Enrollment__r.hed__Contact__r.Name;
        objCourseConnection.progEnrollId = objCourseConn.hed__Program_Enrollment__c;
        objCourseConnection.progEnrollName = objCourseConn.hed__Program_Enrollment__r.Name;
        objCourseConnection.srnNumber = objCourseConn.hed__Program_Enrollment__r.SRN_Number__c;
        objCourseConnection.sectionId = objCourseConn.hed__Program_Enrollment__r.Section__c;
        objCourseConnection.sectionName = objCourseConn.hed__Program_Enrollment__r.Section__r.Name;
        objCourseConnection.progPlanId = objCourseConn.Section__r.hed__Parent_Term__r.Program_Batch__c;
        objCourseConnection.semesterId = objCourseConn.Section__r.hed__Parent_Term__c;
        objCourseConnection.semesterName = objCourseConn.Section__r.hed__Parent_Term__r.Name;
        objCourseConnection.subjectId = objCourseConn.hed__Course_Offering__c;
        objCourseConnection.subjectName = objCourseConn.hed__Course_Offering__r.Name;
        objCourseConnection.courseOfferId = objCourseConn.Id;
        return objCourseConnection;
    }

    /**
     * @description Wrapper class to hold Term details and its related RBS elective courses.
     * @property objTerm          Stores the Term record.
     * @property mapElectiveWrp   Maps specialization names to lists of ElectiveWrp wrapper objects.
     */
    public class DetailsWrp
    {
       /** @description Term record for which the electives are fetched */
        @AuraEnabled public hed__Term__c objTerm {get; set;}

        /** @description Map of parent course name to list of electives for that course */
        @AuraEnabled public Map<String, List<ElectiveWrp>> mapElectiveWrp {get; set;}

        /**  @description Constructor initializes the term and the electives map */
        public DetailsWrp()
        {
            objTerm = new hed__Term__c();
            mapElectiveWrp = new Map<String, List<ElectiveWrp>>();
        }
    }

    /**
     * @description Wrapper to represent elective course details.
     */
    public class ElectiveWrp
    {
        /**
         * @description Name of the parent course or specialization
         */
        @AuraEnabled
        public String parentCourseName { get; set; }

        /**
         * @description Salesforce Id of the parent course
         */
        @AuraEnabled
        public String parentCourseId { get; set; }

        /**
         * @description Code of the elective course
         */
        @AuraEnabled
        public String courseCode { get; set; }

        /**
         * @description Name of the subject or elective
         */
        @AuraEnabled
        public String subjectName { get; set; }

        /**
         * @description Salesforce Id of the subject
         */
        @AuraEnabled
        public String subjectID { get; set; }

        /**
         * @description Total number of students enrolled in this course
         */
        @AuraEnabled
        public Integer totlNoOfStudents { get; set; }
   }

    /**
     *  @description wrapper class to store all the error/success messages
     */
    public class WrapperClass
    {
        /**
         *  @description Message indicating success or error status
         */
        @AuraEnabled
        public String strMessage { get; set; }

        /**
         *  @description Total number of groups retrieved or processed
         */
        @AuraEnabled
        public Integer totalGroupRecords { get; set; }

        /**
         *  @description Wrapper object containing details of groups and their students
         */
        @AuraEnabled
        public GroupMainWrp objGroupMainWrp { get; set; }

        /**
         *  @description Constructor initializes the GroupMainWrp object
         */
        public WrapperClass(){
            objGroupMainWrp = new GroupMainWrp();
        }
    }


   /**
     * @description Wrapper class to hold group details and student assignments
    */
    public class GroupMainWrp
    {
        /**
         * @description Map of group number to GroupWrapperClass containing group details
         */
        @AuraEnabled
        public Map<String, GroupWrapperClass> mapGroupWrp { get; set; }

        /**
         * @description Map of group number to group name
         */
        @AuraEnabled
        public Map<String, String> mapGroups { get; set; }

        /**
         * @description Map of group number to the corresponding hed__Term__c record
         */
        @AuraEnabled
        public Map<String, hed__Term__c> mapGroupDetails { get; set; }

        /**
         * @description List of CourseConnectionWrp objects representing unassigned students
         */
        @AuraEnabled
        public List<CourseConnectionWrp> lstUnassigned { get; set; }

        /**
         * @description Total number of unassigned student records
         */
        @AuraEnabled
        public Integer totalUnassignedRecords { get; set; }

        /**
         * @description Constructor initializes maps, lists, and counters
         */
        public GroupMainWrp()
        {
            mapGroupWrp = new Map<String, GroupWrapperClass>();
            lstUnassigned = new List<CourseConnectionWrp>();
            mapGroupDetails = new Map<String, hed__Term__c>();
            mapGroups = new Map<String, String>();
            totalUnassignedRecords = 0;
        }
    }


   /**
     * @description Wrapper class to hold details of a single group and its assigned students
    */
    public class GroupWrapperClass
    {
        /**
         * @description Group number (e.g., 1, 2, 3)
         */
        @AuraEnabled
        public String groupNo { get; set; }

        /**
         * @description Name of the group
         */
        @AuraEnabled
        public String groupName { get; set; }

        /**
         * @description Salesforce Id of the group record (hed__Term__c)
         */
        @AuraEnabled
        public String groupId { get; set; }

        /**
         * @description Total number of students assigned to this group
         */
        @AuraEnabled
        public Integer totalRecords { get; set; }

        /**
         * @description List of CourseConnectionWrp objects representing students in this group
         */
        @AuraEnabled
        public List<CourseConnectionWrp> lstcourseCons { get; set; }

        /**
         * @description Constructor initializes totalRecords to 0 and lstcourseCons to an empty list
         */
        public GroupWrapperClass()
        {
            totalRecords = 0;
            lstcourseCons = new List<CourseConnectionWrp>();
        }
    }


   /**
     * @description Wrapper class representing a student's course connection and group assignment
     */
    public class CourseConnectionWrp
    {
        /**
         * @description Indicates if the student is assigned to the group
         */
        @AuraEnabled
        public Boolean isChecked { get; set; }

        /**
         * @description Salesforce Id of the contact (student)
         */
        @AuraEnabled
        public String contactId { get; set; }

        /**
         * @description Name of the contact (student)
         */
        @AuraEnabled
        public String contactName { get; set; }

        /**
         * @description Salesforce Id of the Program Enrollment record
         */
        @AuraEnabled
        public String progEnrollId { get; set; }

        /**
         * @description Name of the Program Enrollment record
         */
        @AuraEnabled
        public String progEnrollName { get; set; }

        /**
         * @description SRN Number of the student
         */
        @AuraEnabled
        public String srnNumber { get; set; }

        /**
         * @description Salesforce Id of the Section record
         */
        @AuraEnabled
        public String sectionId { get; set; }

        /**
         * @description Name of the Section
         */
        @AuraEnabled
        public String sectionName { get; set; }

        /**
         * @description Salesforce Id of the Program Plan or Parent Term
         */
        @AuraEnabled
        public String progPlanId { get; set; }

        /**
         * @description Salesforce Id of the assigned group
         */
        @AuraEnabled
        public String groupId { get; set; }

        /**
         * @description Salesforce Id of the previously assigned group
         */
        @AuraEnabled
        public String oldGroupId { get; set; }

        /**
         * @description Name of the assigned group
         */
        @AuraEnabled
        public String groupName { get; set; }

        /**
         * @description Group number (e.g., 1, 2, 3)
         */
        @AuraEnabled
        public String groupNo { get; set; }

        /**
         * @description Salesforce Id of the Semester record
         */
        @AuraEnabled
        public String semesterId { get; set; }

        /**
         * @description Name of the Semester
         */
        @AuraEnabled
        public String semesterName { get; set; }

        /**
         * @description Salesforce Id of the Course Offering
         */
        @AuraEnabled
        public String subjectId { get; set; }

        /**
         * @description Name of the Course Offering
         */
        @AuraEnabled
        public String subjectName { get; set; }

        /**
         * @description Salesforce Id of the Course Enrollment record
         */
        @AuraEnabled
        public String courseOfferId { get; set; }

        /**
         * @description Constructor initializes isChecked to false
         */
        public CourseConnectionWrp()
        {
            isChecked = false;
        }
    }
}