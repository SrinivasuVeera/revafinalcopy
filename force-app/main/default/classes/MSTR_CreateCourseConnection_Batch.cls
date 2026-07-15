global class MSTR_CreateCourseConnection_Batch implements Database.Batchable<sObject>
{
    global set<Id> set_STMIds = new Set<Id>();
    global MSTR_CreateCourseConnection_Batch(Set<Id> set_StudTermIds)
    {
        set_STMIds = set_StudTermIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Set<String> set_RecordTypeName = new Set<String>();
        set_RecordTypeName.add(Utility.STM_RecType_Section);
        set_RecordTypeName.add(Utility.STM_RecType_Batch);
        set_RecordTypeName.add(Utility.STM_RecType_Group);
        return Database.getQueryLocator([Select Id, RecordTypeId, Program_Enrollment__c, Student_Batch__c,
                                         Program_Enrollment__r.SRN_Number__c, Active__c, Section__c,Student_Section_Batch_ID__c,
                                         Recordtype.Name, Semester_ID__c, Student_Group__c, Course_Offering_ID__c,
                                         Course_Connections_Created__c from Student_Semester_Mapping__c where
                                         Active__c =: True AND Recordtype.Name IN : set_RecordTypeName
                                         AND Program_Enrollment__c != Null AND CreatedDate = Today
                                         AND Course_Connections_Created__c =: False
                                         AND ID IN: set_STMIds]);
    }

    global void execute(Database.BatchableContext bc, List<Student_Semester_Mapping__c> lstStudSemMap)
    {
        Set<String> set_RecordTypeName = new Set<String>();
        set_RecordTypeName.add(Utility.STM_RecType_Section);
        set_RecordTypeName.add(Utility.STM_RecType_Batch);

        String groupRecType = Utility.STM_RecType_Group;

        Set<Id> set_SectParntIds = new Set<Id>();
        Set<Id> set_ProgEnrollIds = new Set<Id>();
        Set<Id> set_GroupParntIds = new Set<Id>();
        Set<Id> set_GroupProgEnrollIds = new Set<Id>();
        Set<String> set_MandCategories = new Set<String>();
        Set<String> set_PractCategories = new Set<String>();
        Set<String> set_GroupCategories = new Set<String>();
        Map<String, List<hed__Course_Offering__c>> map_CourseOffer = new Map<String, List<hed__Course_Offering__c>>();
        Map<String, hed__Program_Enrollment__c> map_ProgEnroll = new Map<String, hed__Program_Enrollment__c>();
        List<Student_Semester_Mapping__c> lstNewStudSem = new List<Student_Semester_Mapping__c>();
        List<Student_Semester_Mapping__c> lstUpdStudSem = new List<Student_Semester_Mapping__c>();
        Map<Id, Student_Semester_Mapping__c> map_StudeSem = new Map<Id, Student_Semester_Mapping__c>();
        List<hed__Course_Enrollment__c> lstCourseConn = new List<hed__Course_Enrollment__c>();
        Map<String, hed__Program_Enrollment__c> map_groupProgEnroll = new Map<String, hed__Program_Enrollment__c>();
        Map<String, List<hed__Course_Enrollment__c>> map_CoursConn = new Map<String, List<hed__Course_Enrollment__c>>();
        List<Student_Semester_Mapping__c> lstGroupNewStudSem = new List<Student_Semester_Mapping__c>();
        Map<Id, hed__Course_Enrollment__c> map_GroupCourseConn = new Map<Id, hed__Course_Enrollment__c>();
        String courseConnStudRecType = Utility.CC_Stud_RecType;
        Id ccStudRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(courseConnStudRecType).getRecordTypeId();

        for(Mandatory_Courses_Category_Values__c objCatg : Mandatory_Courses_Category_Values__c.getAll().values())
        {
            set_MandCategories.add(objCatg.Name);
        }

        for(Practical_Course_Category__c objCatg : Practical_Course_Category__c.getAll().values())
        {
            set_PractCategories.add(objCatg.Name);
        }

        for(Elective_Course_Category__c objCatg : Elective_Course_Category__c.getAll().values())
        {
            set_GroupCategories.add(objCatg.Name);
        }

        for(Student_Semester_Mapping__c objStudSem : lstStudSemMap)
        {
            if(objStudSem.Program_Enrollment__c != Null && set_RecordTypeName.contains(objStudSem.Recordtype.Name)
               && objStudSem.Student_Section_Batch_ID__c != Null)
            {
                set_SectParntIds.add(objStudSem.Student_Section_Batch_ID__c);
                set_ProgEnrollIds.add(objStudSem.Program_Enrollment__c);
                lstNewStudSem.add(objStudSem);
            }
            else if(groupRecType == objStudSem.Recordtype.Name && objStudSem.Program_Enrollment__c != Null
                    && objStudSem.Semester_ID__c != Null)
            {
                set_GroupParntIds.add(objStudSem.Semester_ID__c);
                set_GroupProgEnrollIds.add(objStudSem.Program_Enrollment__c);
                lstGroupNewStudSem.add(objStudSem);
            }
        }

        if(!set_SectParntIds.isEmpty() && !set_ProgEnrollIds.isEmpty())
        {
            for(hed__Program_Enrollment__c objProgEnroll : [Select Id, Name, hed__Contact__c, SRN_Number__c,Application_Number__c from
                                                            hed__Program_Enrollment__c where Id IN: set_ProgEnrollIds])
            {
                map_ProgEnroll.put(objProgEnroll.Id, objProgEnroll);
            }

            for(hed__Course_Offering__c objCourseOffer : [Select Id, Name, hed__Term__c, Category__c,
                                                          hed__Course__r.hed__Course_ID__c,hed__Course__r.Course_External_ID__c
                                                          from hed__Course_Offering__c
                                                          where hed__Term__c IN: set_SectParntIds
                                                          AND Category__c != Null])
            {
                if(set_MandCategories.contains(objCourseOffer.Category__c))
                {
                    String Key = objCourseOffer.hed__Term__c+'_'+Utility.STM_RecType_Section;
                    if(map_CourseOffer.get(Key) == Null)
                    {
                        map_CourseOffer.put(Key, new List<hed__Course_Offering__c>());
                    }
                    map_CourseOffer.get(Key).add(objCourseOffer);
                }
                else if(set_PractCategories.contains(objCourseOffer.Category__c))
                {
                    String Key = objCourseOffer.hed__Term__c+'_'+Utility.STM_RecType_Batch;
                    if(map_CourseOffer.get(Key) == Null)
                    {
                        map_CourseOffer.put(Key, new List<hed__Course_Offering__c>());
                    }
                    map_CourseOffer.get(Key).add(objCourseOffer);
                }
            }

            CourseOfferWrp objCourseOfferWrp = new CourseOfferWrp();
            objCourseOfferWrp = CreateCourseConnection(lstNewStudSem, map_ProgEnroll, map_CourseOffer, ccStudRecTypeId);
            lstCourseConn = objCourseOfferWrp.lstCourseConn;
            lstUpdStudSem = objCourseOfferWrp.mapNewUpdStudSems.values();

            if(lstCourseConn.size() > 0)
            {
                upsert lstCourseConn hed__Course_Enrollment__c.Logisys_External_Id__c;
            }

            if(lstUpdStudSem.size() >0)
                update lstUpdStudSem;
        }

        if(!set_GroupParntIds.isEmpty() && !set_GroupProgEnrollIds.isEmpty())
        {
            for(hed__Program_Enrollment__c objProgEnroll : [Select Id, Name, hed__Contact__c, SRN_Number__c,Application_Number__c from
                                                            hed__Program_Enrollment__c where Id IN: set_GroupProgEnrollIds])
            {
                map_groupProgEnroll.put(objProgEnroll.Id, objProgEnroll);
            }
            for(hed__Course_Enrollment__c objCourseConn : [Select Id, Name, hed__Contact__c, hed__Course_Offering__c,
                                                           hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                                                           hed__Program_Enrollment__c, Section__c, External_Id__c,
                                                           RecordTypeId, hed__Course_Offering__r.hed__Course__r.Course_External_ID__c,
                                                           Semester_ID__c from hed__Course_Enrollment__c where
                                                           Semester_ID__c IN: set_GroupParntIds AND
                                                          ( hed__Course_Offering__r.Parent_Course_Offering__r.Category__c IN: set_GroupCategories OR hed__Course_Offering__r.Category__c ='RBS Specialization')
                                                           AND hed__Program_Enrollment__c IN: set_GroupProgEnrollIds
                                                           AND hed__Course_Offering__r.Active__c =: True WITH USER_MODE])
            {
                if(map_CoursConn.get(objCourseConn.Semester_ID__c+'_'+objCourseConn.hed__Program_Enrollment__c+'_'+objCourseConn.hed__Course_Offering__c) == Null)
                {
                    map_CoursConn.put(objCourseConn.Semester_ID__c+'_'+objCourseConn.hed__Program_Enrollment__c+'_'+objCourseConn.hed__Course_Offering__c, new List<hed__Course_Enrollment__c>());
                }
                map_CoursConn.get(objCourseConn.Semester_ID__c+'_'+objCourseConn.hed__Program_Enrollment__c+'_'+objCourseConn.hed__Course_Offering__c).add(objCourseConn);
            }

            for(Student_Semester_Mapping__c objStudSem : lstGroupNewStudSem)
            {
                if(map_CoursConn.get(objStudSem.Semester_ID__c+'_'+objStudSem.Program_Enrollment__c+'_'+objStudSem.Course_Offering_ID__c) != Null
                   && map_groupProgEnroll.get(objStudSem.Program_Enrollment__c) != Null)
                {
                    hed__Program_Enrollment__c objProgEnroll = map_groupProgEnroll.get(objStudSem.Program_Enrollment__c);
                    for(hed__Course_Enrollment__c objCourseConn : map_CoursConn.get(objStudSem.Semester_ID__c+'_'+objStudSem.Program_Enrollment__c+'_'+objStudSem.Course_Offering_ID__c))
                    {
                        hed__Course_Enrollment__c objupdCourseConn = new hed__Course_Enrollment__c();
                        objupdCourseConn.Id = objCourseConn.Id;
                        objupdCourseConn.hed__Contact__c = objProgEnroll.hed__Contact__c;
                        objupdCourseConn.hed__Course_Offering__c = objCourseConn.hed__Course_Offering__c;
                        objupdCourseConn.hed__Program_Enrollment__c = objProgEnroll.Id;
                        objupdCourseConn.Section__c = objStudSem.Student_Group__c;

                        //objCourseConn.Logisys_External_Id__c = objProgEnroll.SRN_Number__c+''+objCourseConn.hed__Course_Offering__r.hed__Course__r.Course_External_ID__c;

                        if(objProgEnroll.SRN_Number__c != null)
                        {
                          objupdCourseConn.Logisys_External_Id__c = objProgEnroll.SRN_Number__c+''+objCourseConn.hed__Course_Offering__r.hed__Course__r.Course_External_ID__c;
                          objupdCourseConn.External_Id__c = objProgEnroll.SRN_Number__c+'_'+objCourseConn.hed__Course_Offering__c;
                        }
                        else
                        {
                            objupdCourseConn.External_Id__c = objProgEnroll.Application_Number__c+'_'+objCourseConn.hed__Course_Offering__c;
                            objupdCourseConn.Logisys_External_Id__c = objProgEnroll.Application_Number__c+''+objCourseConn.hed__Course_Offering__r.hed__Course__r.Course_External_ID__c;
                        }

                        objupdCourseConn.RecordTypeId = ccStudRecTypeId;
                        map_GroupCourseConn.put(objupdCourseConn.Id, objupdCourseConn);

                        Student_Semester_Mapping__c objUpdStudSem = new Student_Semester_Mapping__c();
                        objUpdStudSem.Id = objStudSem.Id;
                        objUpdStudSem.Course_Connections_Created__c = true;
                        map_StudeSem.put(objUpdStudSem.Id, objUpdStudSem);
                        //lstUpdStudSem.add(objUpdStudSem);
                    }
                }
            }

            if(map_GroupCourseConn.size() > 0)
            {
                update map_GroupCourseConn.values();
            }

            if(map_StudeSem.size() > 0)
                update map_StudeSem.values();
        }
    }

    global void finish(Database.BatchableContext bc)
    {
        //BatchClass_Utility.sendBatchClassFailureMail('Master Module', bc.getJobId(), 'Create Course Connection Batch','Student_Semester_Mapping__c');
    }

    //Create Course Connection Records
    public static CourseOfferWrp CreateCourseConnection(List<Student_Semester_Mapping__c> lstNewStudSem,
                                                        Map<String, hed__Program_Enrollment__c> map_ProgEnroll,
                                                        Map<String, List<hed__Course_Offering__c>> map_CourseOffer,
                                                        Id ccStudRecTypeId)
    {
        CourseOfferWrp objCourseOfferWrp = new CourseOfferWrp();
        for(Student_Semester_Mapping__c objStudSem : lstNewStudSem)
        {
            if(map_CourseOffer.get(objStudSem.Student_Section_Batch_ID__c+'_'+objStudSem.Recordtype.Name) != Null
               && map_ProgEnroll.get(objStudSem.Program_Enrollment__c) != Null)
            {

                hed__Program_Enrollment__c objProgEnroll = map_ProgEnroll.get(objStudSem.Program_Enrollment__c);
                for(hed__Course_Offering__c objCourseOffer : map_CourseOffer.get(objStudSem.Student_Section_Batch_ID__c+'_'+objStudSem.Recordtype.Name))
                {
                    hed__Course_Enrollment__c objCourseConn = new hed__Course_Enrollment__c();
                    objCourseConn.hed__Contact__c = objProgEnroll.hed__Contact__c;
                    objCourseConn.hed__Course_Offering__c = objCourseOffer.Id;
                    objCourseConn.hed__Program_Enrollment__c = objProgEnroll.Id;
                    if(objStudSem.Recordtype.Name == Utility.STM_RecType_Batch)
                        objCourseConn.Section__c = objStudSem.Student_Batch__c;
                    else if(objStudSem.Recordtype.Name == Utility.STM_RecType_Section)
                        objCourseConn.Section__c = objStudSem.Section__c;

                    if(objProgEnroll.SRN_Number__c != null)
                    {
                      objCourseConn.External_Id__c = objProgEnroll.SRN_Number__c+'_'+objCourseOffer.Id;
                      objCourseConn.Logisys_External_Id__c = objProgEnroll.SRN_Number__c+''+objCourseOffer.hed__Course__r.Course_External_ID__c;
                    }
                    else
                    {
                        objCourseConn.External_Id__c = objProgEnroll.Application_Number__c+'_'+objCourseOffer.Id;
                        objCourseConn.Logisys_External_Id__c = objProgEnroll.Application_Number__c+''+objCourseOffer.hed__Course__r.Course_External_ID__c;
                    }
                    objCourseConn.RecordTypeId = ccStudRecTypeId;


                    Student_Semester_Mapping__c objUpdStudSem = new Student_Semester_Mapping__c();
                    objUpdStudSem.Id = objStudSem.Id;
                    objUpdStudSem.Course_Connections_Created__c = true;

                    //objCourseOfferWrp.lstNewUpdStudSem.add(objUpdStudSem);

                    objCourseOfferWrp.lstCourseConn.add(objCourseConn);
                    objCourseOfferWrp.mapNewUpdStudSems.put(objUpdStudSem.Id, objUpdStudSem);
                }
            }
        }
        return objCourseOfferWrp;
    }

    public class CourseOfferWrp
    {
        public List<hed__Course_Enrollment__c> lstCourseConn;
        public Map<Id, Student_Semester_Mapping__c> mapNewUpdStudSems;
        public List<Student_Semester_Mapping__c> lstNewUpdStudSem;

        public CourseOfferWrp()
        {
            mapNewUpdStudSems = new Map<Id, Student_Semester_Mapping__c>();
            lstCourseConn = new List<hed__Course_Enrollment__c>();
            lstNewUpdStudSem = new List<Student_Semester_Mapping__c>();
        }
    }
}