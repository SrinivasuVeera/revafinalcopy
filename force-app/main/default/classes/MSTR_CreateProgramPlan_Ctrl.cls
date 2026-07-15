public with sharing class MSTR_CreateProgramPlan_Ctrl 
{
    @AuraEnabled
    public static Map<Id,String> DisplayFacultyRecords()
    {        
        Map<Id,String> Map_AccFaculty = new Map<Id,String>();
        for(Account objAcc : [select Id,Name,RecordType.Name,Program_Type__c from Account Where RecordType.Name = :Utility.Acc_RecType_Educational_Institution
                              and Reva_University__c=false order by Sequence__c])
        {
            Map_AccFaculty.put(objAcc.Id,objAcc.Name);
        } 
        return Map_AccFaculty;
    } 
    @AuraEnabled
    public static List<Account> DisplayAccount(string ProgramType,string FacultyId)
    {  
        List<Account> lst_Acc = new List<Account>();
        for(Account objAcc : [select Id,Name,ParentId,Number_of_Semesters__c,Intake__c,Intake_Per_Section__c,Number_of_Batches__c,No_of_Years__c,Display_Name_Program__c,
                              RecordType.Name,Program_Type__c,Parent.Parentid from Account Where Program_Type__c =:ProgramType and Parent.Parentid=:FacultyId and
                              RecordType.Name =:Utility.Acc_RecType_Academic_Program])
        {
            lst_Acc.add(objAcc);
        } 
        return lst_Acc;
    }
    @AuraEnabled
    public static list<WrapperClass> DisplayProgramPlan(list<Account> lst_acc,date stdate)
    {  
        List<WrapperClass> lstWrap = new List<WrapperClass>();
        for(Account objacc : lst_acc)
        {    
            WrapperClass objWrap = new WrapperClass();
            objWrap.isChecked = true;
            hed__Program_Plan__c objProgPlan = new hed__Program_Plan__c();
            objProgPlan.hed__Account__c = objacc.id;
            objProgPlan.Batches_Per_Section__c = objacc.Number_of_Batches__c;
            objProgPlan.Intake__c = objacc.Intake__c;
            objProgPlan.Intake_Per_Section__c = objacc.Intake_Per_Section__c; 
            objProgPlan.No_of_Semesters__c = objacc.Number_of_Semesters__c;            
            objProgPlan.Number_of_Years__c = objacc.No_of_Years__c;
            if(stdate != null)
                objProgPlan.hed__Start_Date__c = stdate;
            objProgPlan.Name = objacc.Name; 
            objWrap.obj_ProgPlan = objProgPlan;
            lstWrap.add(objWrap);
        } 
        return lstWrap;      
    }
    @AuraEnabled
    public static ErrorWrapper ExistingProgramPlan(list<hed__Program_Plan__c>  lst_programPlan)
    { 
        ErrorWrapper WrapErr = new ErrorWrapper();
        set<Integer> set_Dates = new set<Integer>();
        set<id> set_Accids = new set<id>();
        
        for(hed__Program_Plan__c objPrgPlan : lst_programPlan) 
        {
            if(objPrgPlan.hed__Start_Date__c != null)
                set_Dates.add(objPrgPlan.hed__Start_Date__c.year());
            if(objPrgPlan.hed__Account__c != null)set_Accids.add(objPrgPlan.hed__Account__c);
        } 
        if(set_Dates.size()>0)
        {
            for(hed__Program_Plan__c objPlan : [Select Id,Name,hed__Account__c,hed__Start_Date__c,hed__End_Date__c,hed__Account__r.Display_Name_Program__c from hed__Program_Plan__c 
                                                where hed__Account__c in: set_Accids and hed__Start_Date__c!= null])
            {
                if(set_Dates.contains(objPlan.hed__Start_Date__c.year()))
                {
                    WrapErr.Errmsg='The Program Plan '+ objPlan.Name +' Already Exists';
                    break;
                }
            }
        }
        return WrapErr;      
    }
    @AuraEnabled
    public static ErrorWrapper CreateProgramPlan(list<hed__Program_Plan__c>  lst_programPlan)
    {   
        ErrorWrapper errWrap = new ErrorWrapper();
        set<id> set_accid = new set<id>();
        map<id,Account> map_acc = new map<id,Account>();
        for(hed__Program_Plan__c objProgPlan : lst_programPlan)
        {
            if(objProgPlan.hed__Account__c != null)  set_accid.add(objProgPlan.hed__Account__c);
        }
        if(set_accid.size()>0)
        {
            for(Account objAcc : [select Id,Name,ParentId,Number_of_Semesters__c,Intake__c,Intake_Per_Section__c,Number_of_Batches__c,No_of_Years__c,Display_Name_Program__c,
                                  RecordType.Name,Program_Type__c,Parent.Parentid from Account where id in: set_accid])
            {
                map_acc.put(objAcc.id,objAcc);
            }
        }
        list<hed__Program_Plan__c>  lst_NewprogramPlan = new list<hed__Program_Plan__c>();
        for(hed__Program_Plan__c objProgPlan : lst_programPlan)
        {            
            hed__Program_Plan__c objNewProgPlan = new hed__Program_Plan__c();
            objNewProgPlan.hed__Account__c = objProgPlan.hed__Account__c;
            objNewProgPlan.Batches_Per_Section__c = objProgPlan.Batches_Per_Section__c;
            objNewProgPlan.Intake__c = objProgPlan.Intake__c;
            objNewProgPlan.Intake_Per_Section__c = objProgPlan.Intake_Per_Section__c; 
            objNewProgPlan.No_of_Semesters__c = objProgPlan.No_of_Semesters__c;
            objNewProgPlan.Number_of_Years__c = objProgPlan.Number_of_Years__c;
            objNewProgPlan.hed__Start_Date__c = objProgPlan.hed__Start_Date__c;
            if(objProgPlan.Number_of_Years__c != null && objProgPlan.hed__Start_Date__c != null)
            {
                date enddate = objProgPlan.hed__Start_Date__c.addYears(Integer.valueof(objProgPlan.Number_of_Years__c));
                Integer endyear =  enddate.year();
                Integer styear = objProgPlan.hed__Start_Date__c.year();
                objNewProgPlan.hed__End_Date__c = enddate.adddays(-1);
                if(map_acc.get(objProgPlan.hed__Account__c) != null)
                {
                    if(map_acc.get(objProgPlan.hed__Account__c).Display_Name_Program__c != null)
                    objNewProgPlan.Name = map_acc.get(objProgPlan.hed__Account__c).Display_Name_Program__c+'-'+'('+styear+'-'+endyear+')';
                    else
                     objNewProgPlan.Name = ''+'-'+'('+styear+'-'+endyear+')';   
                }
                    
            }  
            //objNewProgPlan.Name = objProgPlan.Name;
            lst_NewprogramPlan.add(objNewProgPlan);
        }
        
        if(lst_NewprogramPlan.size()>0)
        {
            try
            {
                insert lst_NewprogramPlan;
                errWrap.Errmsg='Success';
            }
            catch(exception ex)
            {
                errWrap.Errmsg=ex.getMessage();
            }
        }  
        return errWrap;
    }   
    @AuraEnabled
    public static Map<String, String> getProgramType() 
    {
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get('Program_Type__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) 
        {
            System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
            mapPickListValues.put(objPickList.getValue(),objPickList.getLabel());
        }
        return mapPickListValues;
    }
    public class WrapperClass
    {
        @AuraEnabled public Boolean isChecked {get;set;}
        @AuraEnabled public hed__Program_Plan__c obj_ProgPlan {get;set;}
        public WrapperClass()
        {
            isChecked = false;
            obj_ProgPlan = new hed__Program_Plan__c();
        }
    }
    public class ErrorWrapper
    {
        @AuraEnabled Public string Errmsg{get;set;}
    }
}