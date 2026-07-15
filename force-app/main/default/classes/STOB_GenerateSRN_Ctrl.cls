public with sharing class STOB_GenerateSRN_Ctrl 
{
    @AuraEnabled 
    public static List<String> getStudentType()
    {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = hed__Program_Enrollment__c.Type_Of_Enrollment__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p: pList)
        {
            options.add(p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static hed__Program_Plan__c getProgramPlanDetails(Id recId)
    {
        return [Select Id, Name, SRN_Format__c, hed__Account__r.Program_Code__c, Total_Number_Of_Lateral_Students__c,
                Total_Number_Of_Regular_Students__c, Number_of_University_Transferred_Student__c from 
                hed__Program_Plan__c where Id =: recId];
    }
    
    @AuraEnabled 
    public static ProgramEnrollementWrap getProgEnrollNoGRN(String studentType, hed__Program_Plan__c objProgmPlan)
    {
        ProgramEnrollementWrap objPrgEnrollWrp = new ProgramEnrollementWrap();
        for(hed__Program_Enrollment__c objPrgEnroll : [Select Id, Name, hed__Contact__c, hed__Contact__r.Name,hed__Contact__r.student_status__c, SRN_Number__c,
                                                       Type_Of_Enrollment__c, hed__Program_Plan__c, Program_Enrollment_Status__c,
                                                       hed__Program_Plan__r.SRN_Format__c, Application_Number__c,
                                                       University_Transferred_Student__c from hed__Program_Enrollment__c 
                                                       where hed__Program_Plan__c =: objProgmPlan.Id 
                                                       AND Type_Of_Enrollment__c =:studentType AND SRN_Number__c = Null
                                                       AND Program_Enrollment_Status__c = 'Confirmed' AND hed__Contact__c != Null AND hed__Contact__r.student_status__c='Pursuing'
                                                       ORDER BY hed__Contact__r.Name ASC])
        {
            objPrgEnrollWrp.lstPrgEnroll.add(objPrgEnroll);
        }
        return objPrgEnrollWrp;
    }
    
    @AuraEnabled 
    public static ProgramEnrollementWrap getProgramEnrollment(String studentType, hed__Program_Plan__c objProgmPlan, 
                                                              List<hed__Program_Enrollment__c> lstProgEnroll)
    {
        ProgramEnrollementWrap objPrgEnrollWrp = new ProgramEnrollementWrap();
        Integer count = 0;
        Integer transferCount = 0;
        String srnFormat;
        Integer regularSRN = 0;
        Integer lateralSRN = 0;
        Integer srnFormatLen = objProgmPlan.SRN_Format__c.length();
        
        if(studentType == 'Lateral Entry')
        {
            String srnUnv = objProgmPlan.SRN_Format__c.left(3).substring(0, 1);
            String srnYear = objProgmPlan.SRN_Format__c.left(3).substring(1, 3);
            Integer lateralEntry = Integer.valueOf(srnYear);
            lateralEntry = lateralEntry + 1;
            srnFormat = srnUnv+lateralEntry+objProgmPlan.hed__Account__r.Program_Code__c;            
            if(objProgmPlan.Total_Number_Of_Lateral_Students__c > 0)
            {
                Integer total = Integer.valueOf(objProgmPlan.Total_Number_Of_Lateral_Students__c);
                count = Integer.valueOf(Label.STOB_Lateral_Entry_SRN_Starting_No) + total;                
            }
            else
            {
                count = Integer.valueOf(Label.STOB_Lateral_Entry_SRN_Starting_No);
            } 
        }
        else
        {
            if(objProgmPlan.Total_Number_Of_Regular_Students__c > 0)
                count = Integer.valueOf(objProgmPlan.Total_Number_Of_Regular_Students__c);
            if(objProgmPlan.Number_of_University_Transferred_Student__c > 0)
            {
                if(objProgmPlan.hed__Account__r.Program_Code__c.length() == 3)
                {
                    Integer total = Integer.valueOf(objProgmPlan.Number_of_University_Transferred_Student__c);
                    transferCount = Integer.valueOf(Label.STOB_University_Transfer_3_digits_SRN_No) + total;
                }
                else if(objProgmPlan.hed__Account__r.Program_Code__c.length() == 2)
                {
                    Integer total = Integer.valueOf(objProgmPlan.Number_of_University_Transferred_Student__c);
                    transferCount = Integer.valueOf(Label.STOB_University_Transfer_SRN_No) + total;
                }
            }
            else
            {
                if(objProgmPlan.hed__Account__r.Program_Code__c.length() == 3)
                {
                    transferCount = Integer.valueOf(Label.STOB_University_Transfer_3_digits_SRN_No);
                }
                else if(objProgmPlan.hed__Account__r.Program_Code__c.length() == 2)
                {
                    transferCount = Integer.valueOf(Label.STOB_University_Transfer_SRN_No);
                }
            }
        }
        
        for(hed__Program_Enrollment__c objPrgEnroll : lstProgEnroll)
        {
            if(objPrgEnroll.Type_Of_Enrollment__c == 'Lateral Entry')
            {
                count = count + 1;
                objPrgEnroll.SRN_Number__c = srnFormat+String.valueOf(Count);   //.replace('0', '');            // String.valueOf(Count).leftpad(2,'0')
            }
            else
            {
                if(objPrgEnroll.University_Transferred_Student__c == true)
                {
                    transferCount = transferCount +1;
                    integer srnLength = integer.valueof((objProgmPlan.SRN_Format__c+String.valueOf(transferCount)).length());  //.replace('0','')).length()
                    if(srnLength == 8)
                        objPrgEnroll.SRN_Number__c = objProgmPlan.SRN_Format__c+String.valueOf(transferCount);   //.replace('0','');    //  String.valueOf(transferCount).leftpad(2,'0') 
                }
                else
                {
                    count = count + 1;
                    if(srnFormatLen == 6 && count <= 99)
                    {
                        objPrgEnroll.SRN_Number__c = objProgmPlan.SRN_Format__c+String.valueOf(Count).leftpad(2,'0');
                    }
                    else if(srnFormatLen == 5 && count <= 999)
                    {
                        objPrgEnroll.SRN_Number__c = objProgmPlan.SRN_Format__c+String.valueOf(Count).leftpad(3,'0');
                    }
                    else if((srnFormatLen == 6 && count > 99) || (srnFormatLen == 5 && count > 999))
                    {
                        break;
                    }
                }
            }
            objPrgEnrollWrp.lstPrgEnroll.add(objPrgEnroll);
        }
        return objPrgEnrollWrp;
    }
    
    @AuraEnabled 
    public static GeneratedSRNWrp generatedSRN(String studentType, hed__Program_Plan__c objProgmPlan)
    {
        GeneratedSRNWrp objGeneratedSRNWrp = new GeneratedSRNWrp();
        for(hed__Program_Enrollment__c objPrgEnroll : [Select Id, Name, hed__Contact__c, hed__Contact__r.Name,hed__Contact__r.student_status__c, SRN_Number__c,
                                                       Type_Of_Enrollment__c, hed__Program_Plan__c, Program_Enrollment_Status__c,
                                                       hed__Program_Plan__r.SRN_Format__c, Application_Number__c from 
                                                       hed__Program_Enrollment__c where hed__Program_Plan__c =: objProgmPlan.Id 
                                                       AND Type_Of_Enrollment__c =:studentType AND SRN_Number__c != Null
                                                       AND Program_Enrollment_Status__c = 'Confirmed' AND hed__Contact__c != Null AND hed__Contact__r.student_status__c='Pursuing'
                                                       ORDER BY SRN_Number__c ASC])
        {
            objGeneratedSRNWrp.lstGenPrgEnroll.add(objPrgEnroll);
        }
        return objGeneratedSRNWrp;
    }
    
    @AuraEnabled 
    public static WrapperClass updatePrgEnrollement(List<hed__Program_Enrollment__c> lstPrgEnroll, 
                                                    hed__Program_Plan__c objProgmPlan, String studentType,
                                                    Integer totalRegStud, Integer totalUnivTransStud)
    {
        WrapperClass objWrpClass = new WrapperClass();
        try
        {
            update lstPrgEnroll;
            if(studentType == 'Lateral Entry')
                objProgmPlan.Total_Number_Of_Lateral_Students__c = objProgmPlan.Total_Number_Of_Lateral_Students__c + lstPrgEnroll.size();
            else
            {
                objProgmPlan.Total_Number_Of_Regular_Students__c = objProgmPlan.Total_Number_Of_Regular_Students__c + totalRegStud;
                objProgmPlan.Number_of_University_Transferred_Student__c = objProgmPlan.Number_of_University_Transferred_Student__c + totalUnivTransStud;
            }
            update objProgmPlan;
            objWrpClass.strMessage = 'Success';
            return objWrpClass;
        }
        catch(Exception ex)
        {
            System.debug('Error=='+ex.getMessage()+'==Trace=='+ex.getStackTraceString());
            objWrpClass.strMessage = 'Error: '+ex.getMessage();
            return objWrpClass;
        }
    }
    
    public class ProgramEnrollementWrap
    {
        @AuraEnabled public List<hed__Program_Enrollment__c> lstPrgEnroll {get; set;}
        public ProgramEnrollementWrap()
        {
            lstPrgEnroll = new List<hed__Program_Enrollment__c>();
        }
    }
    
    public class GeneratedSRNWrp
    {
        @AuraEnabled public List<hed__Program_Enrollment__c> lstGenPrgEnroll {get; set;}
        public GeneratedSRNWrp()
        {
            lstGenPrgEnroll = new List<hed__Program_Enrollment__c>();
        }
    }
    
    public class WrapperClass
    {
        @AuraEnabled public String strMessage {get; set;}
    }
}