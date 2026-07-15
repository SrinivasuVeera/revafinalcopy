public without sharing class  ALU_StudentNOCComp_Ctrl 
{
    @AuraEnabled
    public static WrapStudentFee getStntResltDetails()
    {
        WrapStudentFee objStdntfee = new WrapStudentFee();
        set<Id> set_ConIds = new set<Id>();
        
        for(User objUser :[SELECT Id,Name,ContactId FROM User WHERE Id =: userInfo.getUserId()
                           and ContactId != null])
        {
            set_ConIds.add(objUser.ContactId);    
        }
        
        if(!set_ConIds.IsEmpty())
        {
            for(Contact objCon : [select Id,Name,Send_Approval_to_RO_Team__c from Contact where Send_Approval_to_RO_Team__c = false and Id In : set_ConIds])
            {
               objStdntfee.list_Con.add(objCon); 
            }
            
            for(Student_Fee__c objStudentFee : [select Id,Name,Amount_Pending__c,Contact__c from Student_Fee__c where 
                                                Contact__c In : set_ConIds and Amount_Pending__c != null AND Amount_Pending__c != 0])
	            {
                objStdntfee.list_StudentFee.add(objStudentFee);  
            }
            
            for(hed__Term_Grade__c objResults : [select Id,Name,hed__Contact__c,hed__Result__c,Result_Summary__c,Course__c from hed__Term_Grade__c 
                                                 where hed__Contact__c In : set_ConIds and hed__Result__c != 'Pass' and Course__c != null and Result_Summary__c != null])
            {
                objStdntfee.list_Results.add(objResults); 
            }
        }
        return objStdntfee;
    }
    
    @AuraEnabled
    public static WrapSave saveContacts(string str_Pos,string str_plc,string str_Cmp,string str_Desig,string str_loc,
                                        date dt_doj,string str_jngrv, string str_prgm,string str_unvrst,date dt_dhs,
                                        string str_cnths,string str_lochs,string str_frname,string str_strted,
                                        string str_desgsu,string str_locsu,string str_typbs,string str_locb,string str_typjtrgt,
                                        string str_chng,string file,string fileName,string str_Othr)
    {
        WrapSave objSv = new WrapSave();
        set<Id> set_ConIds = new set<Id>();
        List<Contact> list_Con = new List<Contact>();
        string str_ConId;
        
        try
        {
            
            for(User objUser :[SELECT Id,Name,ContactId,Contact.Form_Submitted__c FROM User WHERE Id =: userInfo.getUserId()
                               and Contact.Form_Submitted__c = false and ContactId != null])
            {
                set_ConIds.add(objUser.ContactId);    
            }
            
            for(Contact objContact : [select Id,Name,Position_of_Student__c,Placement__c,Company__c,Designation__c,Form_Submitted__c,
                                      Location__c,Date_of_Joining__c,Joining_REVA__c,Which_Program__c,University_Name__c,
                                      Date_of_Joining_HS__c,Country_HS__c,Location_HS__c,Firm_Name__c,Started__c,Designation_SU__c,
                                      Location_SU__c,Type_of_Business__c,Location_B__c,Type_of_Job_Targeting__c,Coaching_required_from_REVA_University__c
                                      from Contact where Id In : set_ConIds])
            {
               
                str_ConId = objContact.Id;
                if(str_Pos != null) objContact.Position_of_Student__c = str_Pos;
                if(str_plc != null) objContact.Placement__c = str_plc;
                if(str_Cmp != null) objContact.Company__c = str_Cmp;
                if(str_Desig != null) objContact.Designation__c = str_Desig;
                if(str_loc != null) objContact.Location__c = str_loc;
                if(dt_doj != null) objContact.Date_of_Joining__c = dt_doj;
                if(str_jngrv != null) objContact.Joining_REVA__c = str_jngrv;
                if(str_prgm != null) objContact.Which_Program__c = str_prgm;
                if(str_unvrst != null) objContact.University_Name__c = str_unvrst;
                if(dt_dhs != null) objContact.Date_of_Joining_HS__c = dt_dhs;
                if(str_cnths != null) objContact.Country_HS__c = str_cnths;
                if(str_lochs != null) objContact.Location_HS__c = str_lochs;
                if(str_frname != null) objContact.Firm_Name__c = str_frname;
                if(str_strted != null) objContact.Started__c = str_strted;
                if(str_desgsu != null) objContact.Designation_SU__c = str_desgsu;
                if(str_locsu != null) objContact.Location_SU__c = str_locsu;
                if(str_typbs != null) objContact.Type_of_Business__c = str_typbs;
                if(str_locb != null) objContact.Location_B__c = str_locb;
                if(str_typjtrgt != null) objContact.Type_of_Job_Targeting__c = str_typjtrgt;
                if(str_chng != null) objContact.Coaching_required_from_REVA_University__c = str_chng;
                if(str_Othr != null) objContact.Others__c = str_Othr;
                objContact.Send_Approval_to_RO_Team__c = true;
                list_Con.add(objContact);
            }
            if(!list_Con.IsEmpty())
            {
                update list_Con;
            }
            
            if(!String.isBlank(file))
            {
                string newfilename = fileName.substringAfterLast('\\');
                ContentVersion contentVersionRec = new ContentVersion();  
                contentVersionRec.Title = newfilename;  
                contentVersionRec.PathOnClient = '/' + newfilename;  
                contentVersionRec.FirstPublishLocationId = str_ConId;  
                contentVersionRec.VersionData = EncodingUtil.base64Decode(file);  
                contentVersionRec.IsMajorVersion = true;  
                Insert contentVersionRec;
            }
            
            objSv.str_Message = 'Success';
            return objSv;  
        }
        catch(Exception ex)
        {
            objSv.str_Message = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objSv;   
        }
    }
    
    @AuraEnabled 
    public static Map<String, String> getStudentPositionDetails()
    {
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Contact.Position_of_Student__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p: pValues) 
        {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getPalcementDetails()
    {
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Contact.Placement__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p: pValues) 
        {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getJoiningReva()
    {
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Contact.Joining_REVA__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p: pValues) 
        {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    
    @AuraEnabled 
    public static Map<String, String> getStarted()
    {
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Contact.Started__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p: pValues) 
        {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getCoaching()
    {
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Contact.Coaching_required_from_REVA_University__c.getDescribe();
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p: pValues) 
        {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    
    public class WrapStudentFee
    {
        @AuraEnabled public List<Student_Fee__c> list_StudentFee{get;set;}
        @AuraEnabled public List<hed__Term_Grade__c> list_Results{get;set;}
        @AuraEnabled public List<Contact> list_Con{get;set;}
        
        public WrapStudentFee()
        {
            list_StudentFee = new List<Student_Fee__c>();
            list_Results = new List<hed__Term_Grade__c>();
            list_Con = new List<Contact>();
        }
    }
    
    public class WrapSave
    {
        @AuraEnabled public string str_Message{get;set;}
    }
    
}