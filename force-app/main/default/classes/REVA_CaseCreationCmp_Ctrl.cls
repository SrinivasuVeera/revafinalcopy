public with sharing class REVA_CaseCreationCmp_Ctrl 
{
    @AuraEnabled
    public static map<string,Case_Management__c> fetchSubCatDetails()
    {
        map<string,Case_Management__c> map_CaseManagement=new map<string,Case_Management__c>();
        for(Case_Management__c objCase:Case_Management__c.getAll().Values())
        {
            map_CaseManagement.put(objCase.Sub_Category__c,objCase);
        }
        return map_CaseManagement;
    }
     @AuraEnabled
    public static string DisplayRecType()
    {
        string CaseRecId; 
        Id CaseAluminiTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Utility.Case_AlumniAssist_RecType).getRecordTypeId();
       Id CaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Utility.Case_SupportRequest_RecType).getRecordTypeId(); 
        user usr = new user();
        usr =[select id,Name,Contactid,Contact.RecordtypeId,Contact.Recordtype.Name from User where id=:userinfo.getuserid()];
        if(usr.Contact.RecordtypeId != null && usr.Contact.Recordtype.Name =='Alumni')
            CaseRecId = CaseAluminiTypeId+'=>'+'false';
        else if(usr.Contact.RecordtypeId != null && usr.Contact.Recordtype.Name =='Student')
            CaseRecId = CaseRecTypeId+'=>'+'true';
        return CaseRecId;
    }
        
    @AuraEnabled
    public static responeWrapper CreateCaseWithFile(string file, string fileName, case objCase)
    {
        responeWrapper objresp=new responeWrapper();
        try
        {
            user usr = new user();
            usr =[select id,Name,Contactid,Contact.Recordtype.name from User where id=:userinfo.getuserid()];
            Id CaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Utility.Case_SupportRequest_RecType).getRecordTypeId();          
            Id CaseAluminiTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Utility.Case_AlumniAssist_RecType).getRecordTypeId();
            Case obCase=new Case();
            obCase.Category__c= objCase.Category__c;
            obCase.Sub_Category__c=objCase.Sub_Category__c;
            obCase.Subject=objCase.Subject;
            obCase.Description=objCase.Description;
            obCase.Case_Status__c=objCase.Case_Status__c;
            if(usr.Contact.Recordtype.name == Utility.Contact_RecType_Student)
                obCase.RecordTypeId=CaseRecTypeId;
            else if(usr.Contact.Recordtype.name == Utility.Contact_RecType_Alumni)
            {
                obCase.RecordTypeId=CaseAluminiTypeId;
                obCase.Origin='Alumni Portal';
            }
            obCase.Old_Case_Number__c=(objCase.Old_Case_Number__c != null) ? objCase.Old_Case_Number__c : null;
            insert obCase;
            
            if(!String.isBlank(file))
            {
                ContentVersion contentVersionRec = new ContentVersion();
                contentVersionRec.Title = fileName;  
                contentVersionRec.PathOnClient = '/' + fileName;  
                contentVersionRec.FirstPublishLocationId = obCase.Id;  
                contentVersionRec.VersionData = EncodingUtil.base64Decode(file);  
                contentVersionRec.IsMajorVersion = true;  
                Insert contentVersionRec;
            }
            objresp.strMessage='Success';
            objresp.CaseId=obCase.id;
        }
        catch(Exception ex)
        {
            objresp.strMessage='Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
        }
        return objresp;
    }
    public class responeWrapper
    {
        @AuraEnabled public string strMessage{get;set;}
        @AuraEnabled public string CaseId{get;set;}
        @AuraEnabled public string CaseRecId{get;set;}
    }
}