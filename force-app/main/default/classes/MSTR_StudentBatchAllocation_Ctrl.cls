public class MSTR_StudentBatchAllocation_Ctrl
{
    @AuraEnabled
    public static WrapSectionTerm getTermDetails(string termId)
    {       
        WrapSectionTerm objTermwrp = new WrapSectionTerm();
        objTermwrp.objSemTerm = [select Id, Name, Program_Batch__c,Program_Batch__r.Name from hed__Term__c where Id =: termId];
        objTermwrp.lst_SemTerms = [select Id, Name, hed__Parent_Term__c from hed__Term__c where hed__Parent_Term__c =: termId
                                  AND Recordtype.Name =: Utility.Term_Object_RecType_Sections];
        
        return objTermwrp; 
    }
    
    @AuraEnabled
    public static WrapBatchMain getStudentMappingDetails(string str_TermId)
    {        
        WrapBatchMain  objBatchWrp = new WrapBatchMain();
        Map<string,WrapBatch> map_Batchwrp = new Map<string,WrapBatch>();
        string studentSecRecId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();
        Integer batchCount = 0;
        Integer sectionCount = 0;
        Integer count = 0;
        
        for(hed__Term__c objTerm :[select Id, Name, Section_Name__c, Batch_Number__c from hed__Term__c
                                   where hed__Parent_Term__c =: str_TermId])
        {
            batchCount = batchCount +1;
            WrapBatch objBtchwrp = new WrapBatch();
            objBtchwrp.batchNo = String.valueOf(objTerm.Batch_Number__c);
            objBtchwrp.batchName = 'Batch '+objTerm.Batch_Number__c;
            objBtchwrp.btchName = objTerm.Name;
            objBtchwrp.btchId = objTerm.Id;
            objBatchWrp.map_Batchwrp.put(objBtchwrp.batchNo, objBtchwrp);
            objBatchWrp.map_Batches.put(String.valueOf(objTerm.Batch_Number__c), 'Batch '+objTerm.Batch_Number__c);
            objBatchWrp.map_BatcheDetails.put(String.valueOf(objTerm.Batch_Number__c), objTerm);
        }
        List<Student_Semester_Mapping__c> lstStudMap = new List<Student_Semester_Mapping__c>();
        lstStudMap =  [Select Id from Student_Semester_Mapping__c where Section__c =:str_TermId AND Active__c =: True];  
        sectionCount = lstStudMap.size();
        //List<AggregateResult> lstSection = [Select SUM(Section__c) from hed__Program_Enrollment__c where Section__c=: str_TermId ORDER BY Section__c];
        /*for(hed__Term__c objHedTerm : [select Id,Name,hed__Parent_Term__c,Batch_Number__c from hed__Term__c where hed__Parent_Term__c =: str_TermId])
        {
            system.debug('==== objHedTerm ===='+objHedTerm);
             //objBatchWrp.map_Batches.put(String.valueOf(objHedTerm.Batch_Number__c), 'Batch '+objHedTerm.Name);

        }*/
        //System.debug('MapBatch=='+objBatchWrp.map_Batchwrp);
        for(hed__Program_Enrollment__c objPrgEnroll : [Select Id, Name, hed__Contact__c, hed__Contact__r.Name, SRN_Number__c,
                                                       Type_Of_Enrollment__c, hed__Program_Plan__c, Program_Enrollment_Status__c,
                                                       hed__Program_Plan__r.SRN_Format__c, Application_Number__c, Batch__c, 
                                                       Batch__r.Name, Batch_Number__c, Section__r.Name from hed__Program_Enrollment__c where 
                                                       Section__c =: str_TermId AND Active__c =: True
                                                       AND hed__Contact__r.Student_Status__c = 'Pursuing'
                                                       ORDER BY SRN_Number__c ASC])
        {
            WrapStudentTermMapping objStudentWrap = new WrapStudentTermMapping();
            objStudentWrap.studentName = objPrgEnroll.hed__Contact__r.Name;
            objStudentWrap.TermId = objPrgEnroll.Section__r.Name;
            objStudentWrap.srnNumber = objPrgEnroll.SRN_Number__c;
            //objStudentWrap.studentTermId = objStudentTerm.Id;
            objStudentWrap.programEnrollId = objPrgEnroll.Id;
            String strKey = String.valueOf(objPrgEnroll.Batch_Number__c);
            if(objBatchWrp.map_Batchwrp.get(strKey) != null)
            {
                count = count +1;
                objStudentWrap.isChecked = false;
                objBatchWrp.map_Batchwrp.get(strKey).totalRecords = objBatchWrp.map_Batchwrp.get(strKey).totalRecords + 1;  
                objStudentWrap.batchId = objBatchWrp.map_Batchwrp.get(strKey).btchId;
                objStudentWrap.oldBatchId = objBatchWrp.map_Batchwrp.get(strKey).btchId;
                objStudentWrap.batchName = objBatchWrp.map_Batchwrp.get(strKey).btchName;
                objStudentWrap.batchNumber = objBatchWrp.map_Batchwrp.get(strKey).batchNo;
                objBatchWrp.map_Batchwrp.get(strKey).lst_studentmap.add(objStudentWrap);
            }
            else
            {
                objBatchWrp.lstUnassigned.add(objStudentWrap); 
                objBatchWrp.totalUnassignedRecords = objBatchWrp.totalUnassignedRecords + 1;
            }
        }
        //System.debug('count=='+count);
        //System.debug('MapBatch=='+objBatchWrp.map_Batchwrp);
        if(count == 0)
        {
            if(objBatchWrp.lstUnassigned.size() > 0)
            {
                objBatchWrp.lstUnassigned.clear();
                objBatchWrp.totalUnassignedRecords = 0;
            }
            Integer newCount = 0;
            Integer totalRec = sectionCount / batchCount;
            Integer size = Integer.valueOf(Math.ceil(totalRec));
            Integer maxSize = size;
            Integer studentNo = 1;
            Integer batchNo = 1;    
            for(Student_Semester_Mapping__c objStudnetMapping : [Select Id, Name, RecordTypeId, Section__c, Active__c, 
                                                                 Section__r.Name,Program_Enrollment__c, Program_Enrollment__r.SRN_Number__c,
                                                                 Program_Enrollment__r.hed__Contact__r.Name from Student_Semester_Mapping__c
                                                                 where RecordTypeId =: studentSecRecId AND Section__c =: str_TermId 
                                                                 AND Program_Enrollment__r.hed__Contact__r.Student_Status__c = 'Pursuing'
                                                                 AND Active__c = True order by Program_Enrollment__r.SRN_Number__c ASC])
            {
                Integer key = (studentNo <= (batchNo*maxSize)) ? batchNo : batchNo +1;
                newCount = newCount+1;
                batchNo = key;
                WrapStudentTermMapping objStudentWrap = getStudentTermDetails(objStudnetMapping);
                String strKey = String.valueOf(key);
                if(objBatchWrp.map_Batchwrp.get(strKey) != null)
                {
                    objStudentWrap.isChecked = true;
                    objBatchWrp.map_Batchwrp.get(strKey).totalRecords = objBatchWrp.map_Batchwrp.get(strKey).totalRecords + 1;  
                    objStudentWrap.batchId = objBatchWrp.map_Batchwrp.get(strKey).btchId;
                    objStudentWrap.batchName = objBatchWrp.map_Batchwrp.get(strKey).btchName;
                    objStudentWrap.batchNumber = objBatchWrp.map_Batchwrp.get(strKey).batchNo;
                    objBatchWrp.map_Batchwrp.get(strKey).lst_studentmap.add(objStudentWrap);
                }
                else
                {
                    objBatchWrp.lstUnassigned.add(objStudentWrap); 
                    objBatchWrp.totalUnassignedRecords = objBatchWrp.totalUnassignedRecords + 1;
                }
                studentNo++;
            }
        }
        return objBatchWrp;
    }
    
    @AuraEnabled
    public static WrapperSaveStudentMapping saveStudentTerms(string strStudntTerms)
    {
        WrapperSaveStudentMapping objSaveWrp = new WrapperSaveStudentMapping();
        try
        {
            List<Student_Semester_Mapping__c> list_StudentMapping = new List<Student_Semester_Mapping__c>();
            List<WrapStudentTermMapping> list_studnetMaps = (List<WrapStudentTermMapping>)JSON.deserialize(strStudntTerms, List<WrapStudentTermMapping>.class);
            String studentBatchName = Utility.STM_RecType_Batch;
            String studentBatchRecId = Schema.getGlobalDescribe().get('Student_Semester_Mapping__c').getDescribe().getRecordTypeInfosByName().get(studentBatchName).getRecordTypeId();
            
            for(WrapStudentTermMapping objstudentWrp : list_studnetMaps)
            {
                Student_Semester_Mapping__c objStudentTerm = new Student_Semester_Mapping__c();
                objStudentTerm.Student_Batch__c = objstudentWrp.batchId;
                objStudentTerm.Name = objstudentWrp.studentName+'-'+objstudentWrp.batchName;
                objStudentTerm.RecordTypeId = studentBatchRecId;
                objStudentTerm.Active__c =true;
                objStudentTerm.Program_Enrollment__c = objstudentWrp.programEnrollId;
                objStudentTerm.Start_Date__c = System.today();
                objStudentTerm.External_Id__c = objstudentWrp.programEnrollId+'_'+objstudentWrp.batchId+'_'+System.now();
                list_StudentMapping.add(objStudentTerm);
            }
            
            if(!list_StudentMapping.IsEmpty())
            {
                Set<Id> setSTMIds = new Set<Id>();
                Database.UpsertResult[] lstResult = Database.upsert(list_StudentMapping, Student_Semester_Mapping__c.External_Id__c, True);
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
            objSaveWrp.strMessage = 'Success';
                
        }
        Catch(Exception ex)
        {
            objSaveWrp.strMessage = 'Error: '+ex.getMessage();
        }
        return objSaveWrp;
    }
    
    public static WrapStudentTermMapping getStudentTermDetails(Student_Semester_Mapping__c objStudentTerm)
    {
        WrapStudentTermMapping objWrapStdnt = new WrapStudentTermMapping();
        objWrapStdnt.studentName = objStudentTerm.Program_Enrollment__r.hed__Contact__r.Name;
        objWrapStdnt.TermId = objStudentTerm.Section__r.Name;
        objWrapStdnt.srnNumber = objStudentTerm.Program_Enrollment__r.SRN_Number__c;
        objWrapStdnt.studentTermId = objStudentTerm.Id;
        objWrapStdnt.programEnrollId = objStudentTerm.Program_Enrollment__c;
        return objWrapStdnt;
    }
    
    public class WrapSectionTerm
    {
        @AuraEnabled public list<hed__Term__c> lst_SemTerms{get;set;}
        @AuraEnabled public hed__Term__c objSemTerm{get;set;}
        @AuraEnabled public hed__Term__c objSecTerm{get;set;}
        public WrapSectionTerm()
        {
            objSemTerm = new hed__Term__c();
            lst_SemTerms = new List<hed__Term__c>();
        }
    }
    
    public class WrapBatchMain
    {
        @AuraEnabled public Map<string,WrapBatch> map_BatchWrp {get;set;}
        @AuraEnabled public Integer totalUnassignedRecords {get; set;}
        @AuraEnabled public List<WrapStudentTermMapping> lstUnassigned {get;set;}
        @AuraEnabled public Map<string,string> map_Batches {get;set;}
        @AuraEnabled public Map<String, hed__Term__c> map_BatcheDetails {get;set;}

        Public WrapBatchMain()
        {
            map_BatchWrp = new Map<string,WrapBatch>();
            map_Batches = new Map<string,string>();
            map_BatcheDetails = new Map<String, hed__Term__c>();
            lstUnassigned = new List<WrapStudentTermMapping>();
            totalUnassignedRecords = 0;
        }
        
    }
    
    public class WrapBatch
    {
        @AuraEnabled public string batchNo {get;set;}
        @AuraEnabled public string batchName{get;set;}
        @AuraEnabled public string btchName{get;set;}
        @AuraEnabled public string btchId{get;set;}
        @AuraEnabled public Integer totalRecords{get;set;}
        @AuraEnabled public List<WrapStudentTermMapping> lst_studentmap {get;set;}

        public WrapBatch()
        {
            totalRecords = 0; 
            lst_studentmap = new List<WrapStudentTermMapping>();
        }
    }
    
    public class WrapStudentTermMapping
    {
        @AuraEnabled public boolean isChecked{get;set;}
        @AuraEnabled public String TermId {get; set;}
        @AuraEnabled public String studentTermId {get; set;}
        @AuraEnabled public string studentName{get;set;}
        @AuraEnabled public string batchId{get;set;}
        @AuraEnabled public string srnNumber{get;set;}
        @AuraEnabled public string batchName{get;set;}
        @AuraEnabled public string programEnrollId{get;set;}
        @AuraEnabled public string batchNumber{get;set;}
        @AuraEnabled public string oldBatchId{get;set;}
        public WrapStudentTermMapping()
        {
            isChecked = false;  
        }
    }
    
    public class WrapperSaveStudentMapping
    {
        @AuraEnabled public String strMessage {get; set;}
    }
}