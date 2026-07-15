public with sharing class MSTR_StudentSemesterPromotion_Ctrl 
{
    @AuraEnabled
    public static WrapSemesterTerm getSemesterDetails(string str_TermId)
    {
        WrapSemesterTerm objSemTerm = new WrapSemesterTerm();
        List<hed__Term__c> lstNextSem = new List<hed__Term__c>();
        objSemTerm.objSemester = [select Id, Name, Program_Batch__c, Term_Number__c from hed__Term__c where 
                                  Id =: str_TermId];
        lstNextSem = [select Id, Name, Term_Number__c, Program_Batch__c, Active__c from hed__Term__c 
                      where Term_Number__c =: objSemTerm.objSemester.Term_Number__c+1 AND
                      Program_Batch__c =: objSemTerm.objSemester.Program_Batch__c limit 1];

        if(lstNextSem.size() > 0 && lstNextSem[0].Active__c)
        {
            for(hed__Program_Enrollment__c objProgEnrollment : [Select Id, Name, Batch__c, Batch__r.Name, Batch_Number__c, 
                                                                Section__c, Section__r.Name, hed__Contact__c, Section_Number__c,
                                                                hed__Contact__r.Student_Full_Name__c, SRN_Number__c,
                                                                hed__Contact__r.Application_Number__c,Semester__c from
                                                                hed__Program_Enrollment__c where Semester__c =: str_TermId
                                                                AND Active__c =: True Order BY SRN_Number__c])
            {
                WrapProgramEnrollment objProgEnrllWrp = new WrapProgramEnrollment();
                objProgEnrllWrp.objProgEnroll = objProgEnrollment;
                objSemTerm.lstProgEnroll.add(objProgEnrllWrp);
            }
            objSemTerm.strMessage = 'Success';
        }
        else
        {
            objSemTerm.strMessage = 'You cannot Promote the Students to Next Semester because semester is Inactive..!';
        }
        return objSemTerm;
    }    
    
    @AuraEnabled
    public static WrapperClass updatestudentTermMappings(string str_selectSemId, 
                                                             List<hed__Program_Enrollment__c> list_Enrollments, 
                                                             List<String> lstSelectedIds)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        
        string str_studsemId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get('Student Semester').getRecordTypeId();
        string str_studBtchId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get('Student Batch').getRecordTypeId();
        string str_studSecId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get('Student Section').getRecordTypeId(); 
        string str_SectionRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        string str_BatchRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId(); 
        
        Set<Id> set_RecordTypeIds = new Set<Id>();
        Map<Decimal, hed__Term__c> map_NextSemSections = new Map<Decimal, hed__Term__c>();
        Map<String, hed__Term__c> map_NextSemBatches = new Map<String, hed__Term__c>();
        Set<Id> set_NextSemSectionIds = new Set<Id>();
        Set<Id> set_NextSemIds = new Set<Id>();
        List<Student_Semester_Mapping__c> lstupdateSemSTM = new List<Student_Semester_Mapping__c>();
        List<Student_Semester_Mapping__c> lstInsertSTM = new List<Student_Semester_Mapping__c>();
        hed__Term__c objPresentSem = new hed__Term__c();
        set_RecordTypeIds.add(str_studsemId);
        set_RecordTypeIds.add(str_studBtchId);
        set_RecordTypeIds.add(str_studSecId);
        
        try
        {
            Set<String> set_ProgEnrolIds = new Set<String>(lstSelectedIds);
            //Present Sem Details
            objPresentSem = [Select Id, Term_Number__c, Program_Batch__c from hed__Term__c where Id =: str_selectSemId];
            
            if(String.isNotBlank(objPresentSem.Program_Batch__c) &&  objPresentSem.Term_Number__c != Null)
            {
                //Next Sem Details
                for(hed__Term__c objSem : [select Id, Name, Term_Number__c, Program_Batch__c from hed__Term__c where 
                                           Term_Number__c =: objPresentSem.Term_Number__c+1 AND
                                           Program_Batch__c =: objPresentSem.Program_Batch__c])
                {
                    if(objSem.Term_Number__c == objPresentSem.Term_Number__c+1)
                    {
                        set_NextSemIds.add(objSem.Id);   
                    }
                }    
                
                if(!set_NextSemIds.isEmpty())
                {
                    //Next Sem Section Details
                    for(hed__Term__c objSection : [select Id, Name, RecordTypeId, hed__Parent_Term__c, Section_Number__c 
                                                   from hed__Term__c where hed__Parent_Term__c In: set_NextSemIds AND 
                                                   RecordTypeId =: str_SectionRecId])
                    {
                        map_NextSemSections.put(objSection.Section_Number__c, objSection);
                        set_NextSemSectionIds.add(objSection.Id);  
                    }
                    //Next Sem Batch Details
                    for(hed__Term__c objBatch : [select Id, Name, RecordTypeId, hed__Parent_Term__c, Batch_Number__c,
                                                 hed__Parent_Term__r.Section_Number__c  from hed__Term__c 
                                                 where hed__Parent_Term__c In: set_NextSemSectionIds AND 
                                                 RecordTypeId =: str_BatchRecId])
                    {
                        map_NextSemBatches.put(objBatch.hed__Parent_Term__r.Section_Number__c+'_'+objBatch.Batch_Number__c, objBatch);
                    }
                    
                    //Making STM of type Semester Inactive
                    for(Student_Semester_Mapping__c objSemStudnt : [Select Id, Active__c from Student_Semester_Mapping__c 
                                                                    where RecordTypeId IN : set_RecordTypeIds AND
                                                                    Active__c = True AND Semester_ID__c =: str_selectSemId
                                                                    AND Program_Enrollment__c IN : set_ProgEnrolIds])
                    {
                        objSemStudnt.Active__c = false;
                        lstupdateSemSTM.add(objSemStudnt);
                    }
                    
                    //Making STM of type Semester Active of Present Semester
                    for(Student_Semester_Mapping__c objSemStudnt : [Select Id, Active__c from Student_Semester_Mapping__c 
                                                                    where RecordTypeId =: str_studsemId AND Active__c = False 
                                                                    AND Program_Enrollment__c IN : set_ProgEnrolIds
                                                                    AND Semester__c IN : set_NextSemIds])
                    {
                        objSemStudnt.Active__c = True;
                        lstupdateSemSTM.add(objSemStudnt);
                    }
                    
                    //Creating the Semester and Section STM Records
                    for(hed__Program_Enrollment__c objProgEnroll : list_Enrollments)
                    {
                        if(map_NextSemSections.get(objProgEnroll.Section_Number__c) != Null)
                        {
                            Student_Semester_Mapping__c objSTM = new Student_Semester_Mapping__c();
                            objSTM.Section__c = map_NextSemSections.get(objProgEnroll.Section_Number__c).Id;
                            objSTM.Program_Enrollment__c = objProgEnroll.Id;
                            objSTM.RecordTypeId = str_studSecId;
                            objSTM.Active__c = true;
                            objSTM.Start_Date__c = System.today();
                            objSTM.External_Id__c = objProgEnroll.Id+'_'+map_NextSemSections.get(objProgEnroll.Section_Number__c).Id+'_'+System.now();
                            lstInsertSTM.add(objSTM);                    
                        }
                        if(map_NextSemBatches.get(objProgEnroll.Section_Number__c+'_'+objProgEnroll.Batch_Number__c) != Null)
                        {
                            Student_Semester_Mapping__c objSTM = new Student_Semester_Mapping__c();
                            objSTM.Student_Batch__c = map_NextSemBatches.get(objProgEnroll.Section_Number__c+'_'+objProgEnroll.Batch_Number__c).Id;
                            objSTM.Program_Enrollment__c = objProgEnroll.Id;
                            objSTM.RecordTypeId = str_studBtchId;
                            objSTM.Active__c = true;
                            objSTM.Start_Date__c = System.today();
                            objSTM.External_Id__c = objProgEnroll.Id+'_'+map_NextSemBatches.get(objProgEnroll.Section_Number__c+'_'+objProgEnroll.Batch_Number__c).Id+'_'+System.now();
                            lstInsertSTM.add(objSTM);
                        }
                    }
                    //Ask regarding next sem STM of Semester and In Program enroll Active Sem Mapping
                    if(lstupdateSemSTM.size() >0)
                    {
                        MSTR_StudentTermMapping_Handler.isAfterInsert = false;
                        update lstupdateSemSTM;
                    }
                    if(lstInsertSTM.size() >0)
                    {
                        Set<Id> setSTMIds = new Set<Id>();
                        Database.UpsertResult[] lstResult = Database.upsert(lstInsertSTM, Student_Semester_Mapping__c.External_Id__c, True);
                        for(Integer i = 0; i <lstResult.size(); i++)
                        {
                            if(lstResult[i].isSuccess())
                            {
                                setSTMIds.add(lstResult[i].Id);
                            }
                        }
                        if(!setSTMIds.isEmpty())
                        {
                            Database.executeBatch(new MSTR_MappingSTMtoProgmEnroll_Batch(setSTMIds));
                            Database.executeBatch(new MSTR_CreateCourseConnection_Batch(setSTMIds));
                        }
                    }
                    objWrapperClass.strMessage ='Success';
                }
                else
                   objWrapperClass.strMessage ='Something went wrong, Please check the records..!'; 
            }
            else
                objWrapperClass.strMessage ='Something went wrong, Please check the records..!';
        }        
        catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
        }
        return objWrapperClass;
    }
   
    public class WrapProgramEnrollment
    {
        @AuraEnabled public hed__Program_Enrollment__c objProgEnroll{get;set;}
        @AuraEnabled public Boolean isChecked{get;set;}
        
        public WrapProgramEnrollment()
        {
            isChecked = true;
            objProgEnroll = new hed__Program_Enrollment__c();
        }
    }
    
    public class WrapSemesterTerm
    {
        @AuraEnabled public string strMessage{get; set;}
        @AuraEnabled public hed__Term__c objSemester{get;set;}
        @AuraEnabled public List<WrapProgramEnrollment> lstProgEnroll {get;set;}        
        public WrapSemesterTerm()
        {
            lstProgEnroll = new List<WrapProgramEnrollment>();
            objSemester = new hed__Term__c(); 
        }
    }   
    
    public class WrapperClass
    {
        @AuraEnabled public string strMessage{get; set;}
    }   
}