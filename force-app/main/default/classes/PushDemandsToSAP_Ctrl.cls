public class PushDemandsToSAP_Ctrl 
{
    @AuraEnabled
    public static List<string> getProgramPlans()
    {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = hed__Program_Plan__c.Fee_Year__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p: pList)
        {
            
            options.add(p.getLabel());
        }
        return options;   
    } 
    
    @AuraEnabled 
    public static ProgramEnrollementWrap getProgEnrollNoGRN(string recId, string feeYear)
    {
        
        List<string> lstFeeType = new List<string>();
        lstFeeType.add('University Fee');
        lstFeeType.add('Tuition Fee');
        map<Id,Student_Fee__c> map_recordsCount = new map<Id, Student_Fee__c>();
        map<string,Student_Fee__c> map_StudentFee = new map<string, Student_Fee__c>();
        map<string,Student_Fee__c> map_StudentFee2 = new map<string, Student_Fee__c>();
        set<Id> set_ProgramEnrolIds = new set<Id>();
        for(Student_Fee__c objStudentFee : [select Id,Program_Enrollment__c,contact__c,Program_Enrollment__r.hed__Program_Plan__c,Fee_Paid__c,Fee_Type__c,Integration_Remarks__c
                                            ,Amount__c,Cancelled__c from Student_Fee__c where Fee_Year__c =: feeYear
                                            and (Integrated_with_SAP__c = TRUE OR Cancelled__c = true) and Fee_Type__c IN: lstFeeType
                                            //SAP_ID__c != null or SAP_ID__c != '')
                                            and Program_Enrollment__r.hed__Program_Plan__c =: recId
                                           ])
        {
            
            map_StudentFee.put(objStudentFee.Program_Enrollment__c+objStudentFee.Fee_Type__c,objStudentFee);
            if(map_recordsCount.ContainsKey(objStudentFee.Program_Enrollment__c))
            {
                map_recordsCount.put(objStudentFee.Program_Enrollment__c,objStudentFee);
                set_ProgramEnrolIds.add(objStudentFee.Program_Enrollment__c);
            }
            else
            {
                map_recordsCount.put(objStudentFee.Program_Enrollment__c,objStudentFee);
            }
        }
        
        for(Student_Fee__c objStudentFee : [select Id,Program_Enrollment__c,contact__c,Program_Enrollment__r.hed__Program_Plan__c,Fee_Paid__c,Fee_Type__c,Integration_Remarks__c 
                                            ,Amount__c from Student_Fee__c where Fee_Year__c =: feeYear
                                            and Fee_Type__c IN: lstFeeType
                                            and Program_Enrollment__r.hed__Program_Plan__c =: recId
                                           ])
        {
            map_StudentFee2.put(objStudentFee.Program_Enrollment__c+objStudentFee.Fee_Type__c,objStudentFee);
        }
        
        
        ProgramEnrollementWrap objPrgEnrollWrp = new ProgramEnrollementWrap();
        for(hed__Program_Enrollment__c objPrgEnroll : [Select Id, Name, hed__Contact__c, hed__Contact__r.Name, SRN_Number__c,
                                                       Type_Of_Enrollment__c, hed__Program_Plan__c, Program_Enrollment_Status__c,
                                                       hed__Program_Plan__r.SRN_Format__c, Application_Number__c,Dummy_2__c,Dummy_1__c,
                                                       University_Transferred_Student__c, Student_Status__c from hed__Program_Enrollment__c WHERE
                                                       Student_Status__c IN ('Pursuing') AND hed__Program_Plan__c =: recId 
                                                       and Id NOT IN: set_ProgramEnrolIds ORDER BY SRN_Number__c
                                                       //and Current_Academic_Year__c =:  feeYear
                                                       
                                                      ])
        {
            objPrgEnrollWrp.lstPrgEnroll.add(objPrgEnroll);
            IF(map_StudentFee2.size() >0)                
            {               
                if(map_StudentFee2.containsKey(objPrgEnroll.Id+'University Fee') ) 
                {
                    objPrgEnroll.Dummy_1__c = string.valueof(map_StudentFee2.get(objPrgEnroll.Id+'University Fee').Amount__c);
                    if(map_StudentFee2.get(objPrgEnroll.Id+'University Fee').Amount__c != null) objPrgEnroll.University_Fee__c = map_StudentFee2.get(objPrgEnroll.Id+'University Fee').Amount__c;
                }
                if(map_StudentFee2.containsKey(objPrgEnroll.Id+'Tuition Fee') ) { 
                    objPrgEnroll.Dummy_2__c = string.valueof(map_StudentFee2.get(objPrgEnroll.Id+'Tuition Fee').Amount__c);
                    if(map_StudentFee2.get(objPrgEnroll.Id+'Tuition Fee').Amount__c != null)  objPrgEnroll.Tuition_Fee__c = map_StudentFee2.get(objPrgEnroll.Id+'Tuition Fee').Amount__c;
                }
            }
            
            
            objPrgEnrollWrp.set_IdToBePused.add(objPrgEnroll.id);
        }
        for(hed__Program_Enrollment__c objPrgEnroll : [Select Id, Name, hed__Contact__c, hed__Contact__r.Name, SRN_Number__c,
                                                       Type_Of_Enrollment__c, hed__Program_Plan__c, Program_Enrollment_Status__c,
                                                       hed__Program_Plan__r.SRN_Format__c, Application_Number__c,
                                                       University_Transferred_Student__c, Student_Status__c from hed__Program_Enrollment__c WHERE
                                                       Student_Status__c IN ('Pursuing') AND hed__Program_Plan__c =: recId 
                                                       and Id IN: set_ProgramEnrolIds ORDER BY SRN_Number__c
                                                       
                                                      ])
        {
            if(map_StudentFee.containsKey(objPrgEnroll.Id+'University Fee') )
            {
                objPrgEnroll.Dummy_1__c = map_StudentFee.get(objPrgEnroll.Id+'University Fee').Fee_Paid__c;
                objPrgEnroll.University_Fee__c = map_StudentFee2.get(objPrgEnroll.Id+'University Fee').Amount__c;
            }
            if(map_StudentFee.containsKey(objPrgEnroll.Id+'Tuition Fee') ) 
            { 
                objPrgEnroll.Dummy_2__c = map_StudentFee.get(objPrgEnroll.Id+'Tuition Fee').Fee_Paid__c;
                objPrgEnroll.Tuition_Fee__c = map_StudentFee2.get(objPrgEnroll.Id+'Tuition Fee').Amount__c;
            }
            objPrgEnrollWrp.lstPrgEnrollPushedSap.add(objPrgEnroll);             
        }
        
        return objPrgEnrollWrp;
    }
    
    @AuraEnabled 
    public static string PushDemandsToSAP(List<hed__Program_Enrollment__c> lstPrgEnroll,string recId,string feeYear)
    {
        String BatchJobId;
        set<Id> set_ContactId = new set<Id>();
        list<Id>lst_ContactId = new list<id>();
        list<Id>lst_ContactId2 = new list<id>();
        for(hed__Program_Enrollment__c objProgEnroll : lstPrgEnroll)
        {
            if(string.IsnotBlank(objProgEnroll.hed__Contact__c) && objProgEnroll.Push_Check_Box__c) set_ContactId.add(objProgEnroll.hed__Contact__c);
        } 
        
        
        if(!set_ContactId.isEmpty() && string.isNotBlank(feeYear)){
            SAP_DemandAPI_Batch batch =  new SAP_DemandAPI_Batch(set_ContactId,feeYear);
            BatchJobId = Database.executeBatch(batch,5);
        }
        
        
        return BatchJobId;
    }
    
    @AuraEnabled
    public static WrapProcessPercentage getProcessPercentage()
    {
        
        String ClassName = 'SAP_DemandAPI_Batch';
        WrapProcessPercentage objWrpPercnt = new WrapProcessPercentage();
        try {
            if(!test.isrunningTest())
            {
                objWrpPercnt.AsyncJob_New = [Select ApexClassID,CompletedDate,ExtendedStatus,JobItemsProcessed,JobType,
                                             MethodName,NumberOfErrors,Status,TotalJobItems,CreatedBYID,ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name =:ClassName WITH USER_MODE
                                             ORDER BY CreatedDate DESC LIMIT 1];
            }
            else
            {
                objWrpPercnt.AsyncJob_New = [Select ApexClassID,CompletedDate,ExtendedStatus,JobItemsProcessed,JobType,
                                             MethodName,NumberOfErrors,Status,TotalJobItems,CreatedBYID FROM AsyncApexJob WHERE Status=:'Completed' WITH USER_MODE LIMIT 1];
            }
        } catch (Exception e) {
            // Handle the exception or log it as needed
            objWrpPercnt.AsyncJob_New = null; // Set it to null to indicate no records found
        }
        return objWrpPercnt;
    }
    
    // Declaring Wrapper class
    public class ProgramEnrollementWrap
    {
        @AuraEnabled public List<hed__Program_Enrollment__c> lstPrgEnroll {get; set;}
        @AuraEnabled public List<hed__Program_Enrollment__c> lstPrgEnrollPushedSap {get; set;}
        @AuraEnabled public set<id> set_IdToBePused{get; set;}
        public ProgramEnrollementWrap()
        {
            lstPrgEnroll = new List<hed__Program_Enrollment__c>();
            lstPrgEnrollPushedSap = new List<hed__Program_Enrollment__c>();
            set_IdToBePused = new set<id>();
        }
    }
    
    public class WrapProcessPercentage
    {
        @AuraEnabled public AsyncApexJob AsyncJob_New{get;set;}
    } 
    
}