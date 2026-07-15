public class MSTR_StudentTermMapping_Handler 
{
    public static Boolean isAfterInsert = true;
    //Deactivating the Existing Section and Batch Record Type STM if a New Active Section or Batch is Created
    public static void deactiveSTM(list<Student_Semester_Mapping__c> lst_objSTM)
    {
        set<Id> set_STM = new set<Id>();
        set<Id> set_prgmEnroll = new set<Id>();
        set<Id> set_rectypeid = new set<Id>();
        List<Student_Semester_Mapping__c> lst_UpdateSTM = new List<Student_Semester_Mapping__c>();
        List<Student_Semester_Mapping__c> lst_UpdateBatchSTM = new List<Student_Semester_Mapping__c>();
        Set<String> recordTypeNames = new Set<String>();
        recordTypeNames.add(Utility.STM_RecType_Section);
        recordTypeNames.add(Utility.STM_RecType_Batch);
        
        for(Student_Semester_Mapping__c objSTM : lst_objSTM)
        {
            string recordTypeName = Schema.getGlobalDescribe().get('Student_Semester_Mapping__c').getDescribe().getRecordTypeInfosById().get(objSTM.RecordTypeId).getName();
            if(recordTypeNames.contains(recordTypeName) && objSTM.Active__c == true 
               && objSTM.Program_Enrollment__c != null)
            {
                set_rectypeid.add(objSTM.RecordTypeId);
                set_STM.add(objSTM.id);
                set_prgmEnroll.add(objSTM.Program_Enrollment__c);
            }               
        }
        if(!set_STM.isEmpty() && !set_prgmEnroll.isEmpty())
        {
            for(Student_Semester_Mapping__c objSTM:[Select Id, Name, Active__c, End_Date__c, Start_Date__c from 
                                                    Student_Semester_Mapping__c where RecordTypeId IN : set_rectypeid 
                                                    AND Active__c = true AND Program_Enrollment__c IN :set_prgmEnroll 
                                                    AND Id Not IN :set_STM])
            {
                if(objSTM.Start_Date__c == System.today())
                    objSTM.End_Date__c = System.today();
                else    
                    objSTM.End_Date__c = System.today().addDays(-1);
                objSTM.Active__c = false;
                lst_UpdateSTM.add(objSTM);
            }
            
            for(Student_Semester_Mapping__c objSTM:[Select Id, Name, Active__c, End_Date__c, Start_Date__c from 
                                                    Student_Semester_Mapping__c where Active__c = True AND
                                                    RecordType.Name =: Utility.STM_RecType_Batch AND 
                                                    Program_Enrollment__c IN :set_prgmEnroll AND Id Not IN :set_STM])
            {
                if(objSTM.Start_Date__c == System.today())
                    objSTM.End_Date__c = System.today();
                else    
                    objSTM.End_Date__c = System.today().addDays(-1);
                objSTM.Active__c = false;
                lst_UpdateBatchSTM.add(objSTM);
            }
            
            //System.debug('lst_UpdateSTM=='+lst_UpdateSTM);
            
            if(lst_UpdateSTM.size()>0)
                update lst_UpdateSTM;
            
            if(lst_UpdateBatchSTM.size() > 0 )
                update lst_UpdateBatchSTM;
        }
    }
    
    //Mapping STM in program Enroll when new batch and Section record type Student Semester Mapping is Created
   /* public static void mapStmToPrgmEnroll(List<Student_Semester_Mapping__c> lstStudSemMap)
    {
    	Set<Id> set_StudSemSecIds = new Set<Id>();
        Set<Id> set_StudSemBatchIds = new Set<Id>();
        for(Student_Semester_Mapping__c objSTM : lstStudSemMap)
        {
            string recordTypeName = Schema.getGlobalDescribe().get('Student_Semester_Mapping__c').getDescribe().getRecordTypeInfosById().get(objSTM.RecordTypeId).getName();
            if(recordTypeName == Utility.STM_RecType_Section && objSTM.Active__c == true 
               && objSTM.Section__c != null &&  objSTM.Program_Enrollment__c !=null)
            {
            	set_StudSemSecIds.add(objSTM.Id);                
            }
            else if(recordTypeName == Utility.STM_RecType_Batch && objSTM.Active__c == true 
                    && objSTM.Student_Batch__c != null &&  objSTM.Program_Enrollment__c !=null)
            {
                set_StudSemBatchIds.add(objSTM.Id);
            }           
        }
        
        if(!set_StudSemSecIds.isEmpty())
        {
            MSTR_MappingSTMtoProgmEnroll_Batch obj = new MSTR_MappingSTMtoProgmEnroll_Batch();
            Database.executeBatch(obj);
            //MapStudSemOfSection(set_StudSemSecIds);
        }
        else if(!set_StudSemBatchIds.isEmpty())
        {
            MSTR_MappingSTMtoProgmEnroll_Batch obj = new MSTR_MappingSTMtoProgmEnroll_Batch();
            Database.executeBatch(obj);
            //MapStudSemOfBatch(set_StudSemBatchIds);
        }
            
    }
    
    //Mapping Student Semester of Section To Program Enroll Section 
    @future
    public static void MapStudSemOfSection(Set<Id> set_StudSemSecIds)
    {      
        Map<Id, hed__Program_Enrollment__c> map_PrgmEnroll = new Map<Id, hed__Program_Enrollment__c>();
        
        for(Student_Semester_Mapping__c objSTM : [Select Id, RecordTypeId, Program_Enrollment__c, Active__c, 
                                                  Section__c, Student_Batch__c, Recordtype.Name from 
                                                  Student_Semester_Mapping__c where Id IN: set_StudSemSecIds])
        {
            if(objSTM.Recordtype.Name == Utility.STM_RecType_Section && objSTM.Active__c == true 
               && objSTM.Section__c != null &&  objSTM.Program_Enrollment__c !=null)
            {
                if(map_PrgmEnroll.get(objSTM.Program_Enrollment__c) == Null)
                {
                    map_PrgmEnroll.put(objSTM.Program_Enrollment__c, new hed__Program_Enrollment__c(Id = objSTM.Program_Enrollment__c));
                }
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Section__c = objSTM.Section__c;
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Batch__c = Null;
            }       
        }
        
        if(map_PrgmEnroll.size()>0)
            update map_PrgmEnroll.values();
    }
    
    //Mapping Student Semester of Batch To Program Enroll Batch 
    @future
    public static void MapStudSemOfBatch(Set<Id> set_StudSemBatchIds)
    {      
        Map<Id, hed__Program_Enrollment__c> map_PrgmEnroll = new Map<Id, hed__Program_Enrollment__c>();
        
        for(Student_Semester_Mapping__c objSTM : [Select Id, RecordTypeId, Program_Enrollment__c, Active__c, 
                                                  Section__c, Student_Batch__c, Recordtype.Name from 
                                                  Student_Semester_Mapping__c where Id IN: set_StudSemBatchIds])
        {
            if(objSTM.Recordtype.Name == Utility.STM_RecType_Batch && objSTM.Active__c == true 
               && objSTM.Student_Batch__c != null &&  objSTM.Program_Enrollment__c !=null)
            {
                if(map_PrgmEnroll.get(objSTM.Program_Enrollment__c) == Null)
                {
                    map_PrgmEnroll.put(objSTM.Program_Enrollment__c, new hed__Program_Enrollment__c(Id = objSTM.Program_Enrollment__c));
                }
                map_PrgmEnroll.get(objSTM.Program_Enrollment__c).Batch__c = objSTM.Student_Batch__c;
            }           
        }
        
        if(map_PrgmEnroll.size()>0)
            update map_PrgmEnroll.values();
    }
    
    //Create a Course Connection Record of Mandatory Category whenever a new section is created
    public static void CreateConSection(List<Student_Semester_Mapping__c> lstStudSemMap)
    {
        String sectionRecType = Utility.STM_RecType_Section;
        Set<Id> set_StudSemSectionIds = new Set<Id>();
        
        for(Student_Semester_Mapping__c objStudSem : lstStudSemMap)
        {
            String recordTypeName = Schema.getGlobalDescribe().get('Student_Semester_Mapping__c').getDescribe().getRecordTypeInfosById().get(objStudSem.RecordTypeId).getName();
            if(objStudSem.Section__c != Null && objStudSem.Program_Enrollment__c != Null
               && recordTypeName == sectionRecType && objStudSem.Semester_ID__c != Null )
            {
                set_StudSemSectionIds.add(objStudSem.Id);
            }
        }
        
        if(!set_StudSemSectionIds.isEmpty())
        {
            MSTR_CreateCourseConnForSection_Batch obj = new MSTR_CreateCourseConnForSection_Batch();
            Database.executeBatch(obj);
            //CourseConnSection(set_StudSemSectionIds);
        }
            
    }
    
    //Future Method to Create Course Connection Record of Mandatory Category whenever a new section is created
    @future
    public static void CourseConnSection(Set<Id> set_StudSemSectionIds)
    {
        String sectionRecType = Utility.STM_RecType_Section;
        Set<Id> set_SectParntIds = new Set<Id>();
        Set<Id> set_ProgEnrollIds = new Set<Id>();
        Set<String> set_Categories = new Set<String>();
        Map<String, List<hed__Course_Offering__c>> map_CourseOffer = new Map<String, List<hed__Course_Offering__c>>();
        Map<String, hed__Program_Enrollment__c> map_ProgEnroll = new Map<String, hed__Program_Enrollment__c>();
        List<Student_Semester_Mapping__c> lstNewStudSem = new List<Student_Semester_Mapping__c>();
        List<hed__Course_Enrollment__c> lstCourseConn = new List<hed__Course_Enrollment__c>();
        String courseConnStudRecType = Utility.CC_Stud_RecType;
        Id ccStudRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(courseConnStudRecType).getRecordTypeId();
        
        for(Mandatory_Courses_Category_Values__c objCatg : Mandatory_Courses_Category_Values__c.getAll().values())
        {
            set_Categories.add(objCatg.Name);
        }
        
        for(Student_Semester_Mapping__c objStudSem : [Select Id, Name, Section__c, Program_Enrollment__c, Semester_ID__c,
                                                      Student_Batch__c, Recordtype.Name from Student_Semester_Mapping__c 
                                                      where Id IN: set_StudSemSectionIds])
        {
            if(objStudSem.Section__c != Null && objStudSem.Program_Enrollment__c != Null
               && objStudSem.Recordtype.Name == sectionRecType && objStudSem.Semester_ID__c != Null )
            {
                set_SectParntIds.add(objStudSem.Semester_ID__c);
                set_ProgEnrollIds.add(objStudSem.Program_Enrollment__c);
                lstNewStudSem.add(objStudSem);
            }
        }
        
        if(!set_SectParntIds.isEmpty() && !set_ProgEnrollIds.isEmpty())
        {
            for(hed__Program_Enrollment__c objProgEnroll : [Select Id, Name, hed__Contact__c from 
                                                            hed__Program_Enrollment__c where Id IN: set_ProgEnrollIds])
            {
                map_ProgEnroll.put(objProgEnroll.Id, objProgEnroll);
            }
            
            for(hed__Course_Offering__c objCourseOffer : [Select Id, Name, hed__Term__c from hed__Course_Offering__c
                                                          where hed__Term__c IN: set_SectParntIds AND 
                                                          Category__c IN: set_Categories])
            {
                if(map_CourseOffer.get(objCourseOffer.hed__Term__c) == Null)
                {
                    map_CourseOffer.put(objCourseOffer.hed__Term__c, new List<hed__Course_Offering__c>());
                }
                map_CourseOffer.get(objCourseOffer.hed__Term__c).add(objCourseOffer); 
            }
            
            lstCourseConn = CreateCourseConnection(lstNewStudSem, map_ProgEnroll, map_CourseOffer, ccStudRecTypeId, sectionRecType);
            
            if(lstCourseConn.size() > 0)
                upsert lstCourseConn hed__Course_Enrollment__c.External_Id__c;
        }
    }
    
    //Create a Course Connection Record of Practical/TeamWork Category whenever a new Batch is created
    public static void CreateConBatch(List<Student_Semester_Mapping__c> lstStudSemMap)
    {
        String batchRecType = Utility.STM_RecType_Batch;
        Set<Id> set_StudSemBatchIds = new Set<Id>();
        
        for(Student_Semester_Mapping__c objStudSem : lstStudSemMap)
        {
            String recordTypeName = Schema.getGlobalDescribe().get('Student_Semester_Mapping__c').getDescribe().getRecordTypeInfosById().get(objStudSem.RecordTypeId).getName();
            if(objStudSem.Student_Batch__c != Null && objStudSem.Program_Enrollment__c != Null
               && recordTypeName == batchRecType && objStudSem.Semester_ID__c != Null )
            {
                set_StudSemBatchIds.add(objStudSem.Id);
            }
        }
        
        if(!set_StudSemBatchIds.isEmpty())
            CourseConnectionBatch(set_StudSemBatchIds);
        
    }
    
    //Future Method to Create Course Connection Record of Practical/TeamWork Category whenever a new Batch is created
    @future
    public static void CourseConnectionBatch(Set<Id> set_StudSemBatchIds)
    {
        String batchRecType = Utility.STM_RecType_Batch;
        Set<Id> set_SectParntIds = new Set<Id>();
        Set<Id> set_ProgEnrollIds = new Set<Id>();
        Set<String> set_Categories = new Set<String>();
        Map<String, List<hed__Course_Offering__c>> map_CourseOffer = new Map<String, List<hed__Course_Offering__c>>();
        Map<String, hed__Program_Enrollment__c> map_ProgEnroll = new Map<String, hed__Program_Enrollment__c>();
        List<Student_Semester_Mapping__c> lstNewStudSem = new List<Student_Semester_Mapping__c>();
        List<hed__Course_Enrollment__c> lstCourseConn = new List<hed__Course_Enrollment__c>();
        String courseConnStudRecType = Utility.CC_Stud_RecType;
        Id ccStudRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(courseConnStudRecType).getRecordTypeId();
        
        for(Practical_Course_Category__c objCatg : Practical_Course_Category__c.getAll().values())
        {
            set_Categories.add(objCatg.Name);
        }
        
        for(Student_Semester_Mapping__c objStudSem : [Select Id, Name, Section__c, Program_Enrollment__c, Semester_ID__c,
                                                      Student_Batch__c, Recordtype.Name from Student_Semester_Mapping__c 
                                                      where Id IN: set_StudSemBatchIds])
        {
            if(objStudSem.Student_Batch__c != Null && objStudSem.Program_Enrollment__c != Null
               && objStudSem.Recordtype.Name == batchRecType && objStudSem.Semester_ID__c != Null )
            {
                set_SectParntIds.add(objStudSem.Semester_ID__c);
                set_ProgEnrollIds.add(objStudSem.Program_Enrollment__c);
                lstNewStudSem.add(objStudSem);
            }
        }
        
        if(!set_SectParntIds.isEmpty() && !set_ProgEnrollIds.isEmpty())
        {
            for(hed__Program_Enrollment__c objProgEnroll : [Select Id, Name, hed__Contact__c from 
                                                            hed__Program_Enrollment__c where Id IN: set_ProgEnrollIds])
            {
                map_ProgEnroll.put(objProgEnroll.Id, objProgEnroll);
            }
            
            for(hed__Course_Offering__c objCourseOffer : [Select Id, Name, hed__Term__c from hed__Course_Offering__c
                                                          where hed__Term__c IN: set_SectParntIds AND 
                                                          Category__c IN: set_Categories])
            {
                if(map_CourseOffer.get(objCourseOffer.hed__Term__c) == Null)
                {
                    map_CourseOffer.put(objCourseOffer.hed__Term__c, new List<hed__Course_Offering__c>());
                }
                map_CourseOffer.get(objCourseOffer.hed__Term__c).add(objCourseOffer);
            }
            
            lstCourseConn = CreateCourseConnection(lstNewStudSem, map_ProgEnroll, map_CourseOffer, ccStudRecTypeId, batchRecType);
            
            if(lstCourseConn.size() > 0)
                upsert lstCourseConn hed__Course_Enrollment__c.External_Id__c;
        }
    }
    
    //Update a Course Connection Record of Electives Category whenever a new Group is created
    public static void CreateConGroup(List<Student_Semester_Mapping__c> lstStudSemMap)
    {
        String groupRecType = Utility.STM_RecType_Group;
        Set<Id> set_StudSemGroupIds = new Set<Id>();
        
        for(Student_Semester_Mapping__c objStudSem : lstStudSemMap)
        {
            String recordTypeName = Schema.getGlobalDescribe().get('Student_Semester_Mapping__c').getDescribe().getRecordTypeInfosById().get(objStudSem.RecordTypeId).getName();
            if(objStudSem.Student_Group__c != Null && objStudSem.Program_Enrollment__c != Null
               && recordTypeName == groupRecType && objStudSem.Semester_ID__c != Null )
            {
                set_StudSemGroupIds.add(objStudSem.Id);
            }
        }
        
        if(!set_StudSemGroupIds.isEmpty())
            CourseConGroup(set_StudSemGroupIds);
    }
    
    //Future Method to Update Course Connection Record of Electives Category whenever a new Group is created
    @future
    public static void CourseConGroup(Set<Id> set_StudSemGroupIds)
    {
        String groupRecType = Utility.STM_RecType_Group;
        Set<Id> set_SectParntIds = new Set<Id>();
        Set<Id> set_ProgEnrollIds = new Set<Id>();
        Set<String> set_Categories = new Set<String>();
        Map<String, List<hed__Course_Offering__c>> map_CourseOffer = new Map<String, List<hed__Course_Offering__c>>();
        Map<String, hed__Program_Enrollment__c> map_ProgEnroll = new Map<String, hed__Program_Enrollment__c>();
        List<Student_Semester_Mapping__c> lstNewStudSem = new List<Student_Semester_Mapping__c>();
        List<hed__Course_Enrollment__c> lstCourseConn = new List<hed__Course_Enrollment__c>();
        Map<String, List<hed__Course_Enrollment__c>> map_CoursConn = new Map<String, List<hed__Course_Enrollment__c>>();
        String courseConnStudRecType = Utility.CC_Stud_RecType;
        Id ccStudRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(courseConnStudRecType).getRecordTypeId();
        
        for(Elective_Course_Category__c objCatg : Elective_Course_Category__c.getAll().values())
        { 
            set_Categories.add(objCatg.Name);
        }
        
        for(Student_Semester_Mapping__c objStudSem : [Select Id, Name, Student_Group__c, Program_Enrollment__c, 
                                                      Semester_ID__c,Recordtype.Name from Student_Semester_Mapping__c 
                                                      where Id IN: set_StudSemGroupIds])
        {
            if(objStudSem.Student_Group__c != Null && objStudSem.Program_Enrollment__c != Null
               && objStudSem.Recordtype.Name == groupRecType && objStudSem.Semester_ID__c != Null )
            {
                set_SectParntIds.add(objStudSem.Semester_ID__c);
                set_ProgEnrollIds.add(objStudSem.Program_Enrollment__c);
                lstNewStudSem.add(objStudSem);
            }
        }
        
        if(!set_SectParntIds.isEmpty() && !set_ProgEnrollIds.isEmpty())
        {
            for(hed__Program_Enrollment__c objProgEnroll : [Select Id, Name, hed__Contact__c from 
                                                            hed__Program_Enrollment__c where Id IN: set_ProgEnrollIds])
            {
                map_ProgEnroll.put(objProgEnroll.Id, objProgEnroll);
            }
            
            for(hed__Course_Enrollment__c objCourseConn : [Select Id, Name, hed__Contact__c, hed__Course_Offering__c,
                                                           hed__Program_Enrollment__c, Section__c, External_Id__c,
                                                           RecordTypeId from hed__Course_Enrollment__c where
                                                           Section__c IN: set_SectParntIds AND 
                                                           hed__Course_Offering__r.Parent_Course_Offering__r.Category__c IN: set_Categories
                                                           AND hed__Program_Enrollment__c IN: set_ProgEnrollIds])
            {
                if(map_CoursConn.get(objCourseConn.Section__c+'_'+objCourseConn.hed__Program_Enrollment__c) == Null)
                {
                    map_CoursConn.put(objCourseConn.Section__c+'_'+objCourseConn.hed__Program_Enrollment__c, new List<hed__Course_Enrollment__c>());
                }
                map_CoursConn.get(objCourseConn.Section__c+'_'+objCourseConn.hed__Program_Enrollment__c).add(objCourseConn);
            }
            
            for(Student_Semester_Mapping__c objStudSem : lstNewStudSem)
            {
                if(map_CoursConn.get(objStudSem.Semester_ID__c+'_'+objStudSem.Program_Enrollment__c) != Null 
                   && map_ProgEnroll.get(objStudSem.Program_Enrollment__c) != Null)
                {
                    hed__Program_Enrollment__c objProgEnroll = map_ProgEnroll.get(objStudSem.Program_Enrollment__c);
                    for(hed__Course_Enrollment__c objCourseConn : map_CoursConn.get(objStudSem.Semester_ID__c+'_'+objStudSem.Program_Enrollment__c))
                    {
                        hed__Course_Enrollment__c objupdCourseConn = new hed__Course_Enrollment__c();
                        objupdCourseConn.Id = objCourseConn.Id;
                        objupdCourseConn.hed__Contact__c = objProgEnroll.hed__Contact__c;
                        //objupdCourseConn.hed__Course_Offering__c = objupdCourseConn.hed__Course_Offering__c;
                        objupdCourseConn.hed__Program_Enrollment__c = objProgEnroll.Id;
                        objupdCourseConn.Section__c = objStudSem.Student_Group__c;
                        objupdCourseConn.External_Id__c = objProgEnroll.Id+'_'+objupdCourseConn.hed__Course_Offering__c;
                        objupdCourseConn.RecordTypeId = ccStudRecTypeId;
                        lstCourseConn.add(objupdCourseConn);
                    }
                }
            }
            
            if(lstCourseConn.size() > 0)
                update lstCourseConn;
        }
    }
    
    //Create Course Connection Records
    public static List<hed__Course_Enrollment__c> CreateCourseConnection(List<Student_Semester_Mapping__c> lstNewStudSem, 
                                                                         Map<String, hed__Program_Enrollment__c> map_ProgEnroll,
                                                                         Map<String, List<hed__Course_Offering__c>> map_CourseOffer,
                                                                         Id ccStudRecTypeId, String strRecordTypeName)
    {
        List<hed__Course_Enrollment__c> lstCourseConn = new List<hed__Course_Enrollment__c>();
        for(Student_Semester_Mapping__c objStudSem : lstNewStudSem)
        {
            if(map_CourseOffer.get(objStudSem.Semester_ID__c) != Null 
               && map_ProgEnroll.get(objStudSem.Program_Enrollment__c) != Null)
            {
                hed__Program_Enrollment__c objProgEnroll = map_ProgEnroll.get(objStudSem.Program_Enrollment__c);
                for(hed__Course_Offering__c objCourseOffer : map_CourseOffer.get(objStudSem.Semester_ID__c))
                {
                    hed__Course_Enrollment__c objCourseConn = new hed__Course_Enrollment__c();
                    objCourseConn.hed__Contact__c = objProgEnroll.hed__Contact__c;
                    objCourseConn.hed__Course_Offering__c = objCourseOffer.Id;
                    objCourseConn.hed__Program_Enrollment__c = objProgEnroll.Id;
                    if(strRecordTypeName == Utility.STM_RecType_Batch)
                        objCourseConn.Section__c = objStudSem.Student_Batch__c;
                    else if(strRecordTypeName == Utility.STM_RecType_Section)
                        objCourseConn.Section__c = objStudSem.Section__c;
                    objCourseConn.External_Id__c = objProgEnroll.Id+'_'+objCourseOffer.Id;
                    objCourseConn.RecordTypeId = ccStudRecTypeId;
                    lstCourseConn.add(objCourseConn);
                }
            }
        }
        return lstCourseConn;
    }*/
}