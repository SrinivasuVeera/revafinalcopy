/*
Use Case: This component is used to display the Education History Details on Documents Verification
Created By : Monika J
Created Date For POC : 15/03/2022
Modified Date For POC : 06/04/2022
*/

public with sharing class STOB_DocumentsVerification_Ctrl 
{
    @AuraEnabled
    public static WrapContacts getContactDetails(string ConId)
    {
        WrapContacts objWrpCon = new WrapContacts();
        objWrpCon.objCon = new Contact(); 
        objWrpCon.objCon = [select Id,Name,Program_Batch__c,Program_Batch__r.Name from Contact where Id =: ConId];
        return objWrpCon;
    }
    
    @AuraEnabled
    public static List<wrapDocuments> getDocumentDetails(string ContactId)
    {
        List<wrapDocuments> List_wrpDoc = new List<wrapDocuments>();
        string recordTypeId = Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get(Utility.Educ_History_Object_RecType_Edu_Docu).getRecordTypeId();
        for(hed__Education_History__c objEdHis : [select Id,Name,Data__c,City__c,Save_Confirm__c,Save_Return__c,Education_History_Name__c,Received_Hardcopy__c,
                                                  (SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.CreatedDate, ContentDocument.ContentSize 
                                                   ,ContentDocument.Owner.Name FROM ContentDocumentLinks order by ContentDocument.Createddate DESC limit 1),hed__Contact__c,hed__Verification_Status__c,Mandatory_for_SRN_Generation__c,Status_Remarks__c 
                                                  from hed__Education_History__c where hed__Contact__c =: ContactId and RecordTypeId =: recordTypeId order by Mandatory_for_SRN_Generation__c DESC])
        {
            wrapDocuments objWrpDoc = new wrapDocuments();
            
            if(objEdHis.hed__Verification_Status__c == 'Approved')
            {
                objWrpDoc.enableStatus = true; 
            }
            if(objEdHis.Data__c)
            {
              objWrpDoc.enableData = true;
            }
            
            objWrpDoc.objEducationHistory = objEdHis;
            List_wrpDoc.add(objWrpDoc);
        }
        return List_wrpDoc;        
    }
    
    @AuraEnabled
    public static WrapsaveReturnDocuments saveDocuments(List<hed__Education_History__c> lst_EducationHistories)
    {
        List<hed__Education_History__c> list_EduHistories = new List<hed__Education_History__c>();
        WrapsaveReturnDocuments objWrp = new WrapsaveReturnDocuments();
        try
        {
            string str_Educationhis;
            for(hed__Education_History__c objEducationHistory : lst_EducationHistories)
            {
                objEducationHistory.Save_Return__c = true;
                list_EduHistories.add(objEducationHistory);                
            }
            if(!list_EduHistories.IsEmpty())
            {
                update list_EduHistories;
            }
            objWrp.strMsg = 'Success';
            return objWrp;
        }
        catch(Exception ex)
        {
            objWrp.strMsg = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objWrp;            
        }      
    }
    
    @AuraEnabled
    public static wrapConfirmDocuments confirmDocuments(List<hed__Education_History__c> list_EdHis)
    {
        wrapConfirmDocuments objWrp = new wrapConfirmDocuments();
        List<hed__Education_History__c> list_EducationHis = new List<hed__Education_History__c>();
        try{
            for(hed__Education_History__c objEduhis : list_EdHis)
            {
                if(objEduhis.hed__Verification_Status__c == 'Approved')
                {
                    objEduhis.Save_Confirm__c = true;
                    list_EducationHis.add(objEduhis);
                }
            }
            if(!list_EducationHis.IsEmpty())
            {
                Update list_EducationHis;  
            }            
            objwrp.strMessage = 'Success';
            return objwrp;
        }
        catch(Exception ex)
        {
            objwrp.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objwrp;
        }          
    }
    
    @AuraEnabled 
    public static WrapDeleteFiles getdeletefiledetais(string str_conprtId)
    {
        WrapDeleteFiles objWrap = new WrapDeleteFiles();
        List<ContentDocumentLink> lst_contentDocuments = new List<ContentDocumentLink>();
        try
        {           
            for(ContentDocumentLink  objConducment : [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                                                      ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink 
                                                      WHERE LinkedEntityId =: str_conprtId])
            {
                lst_contentDocuments.add(objConducment);  
            }
            if(!lst_contentDocuments.Isempty())
            {
                delete lst_contentDocuments;
            }
            objWrap.strdeletefile = 'Success';
            return objWrap; 
        }       
        catch(Exception ex)
        {
            objWrap.strdeletefile = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objWrap;            
        }      
    }
    
    @AuraEnabled 
    public static List<string> getverificationStatus()
    {        
        List<string> options = new List<string>();
        Schema.DescribeFieldResult fieldResult = hed__Education_History__c.hed__Verification_Status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry p: pList) 
        {
            options.add(p.getValue());          
        }  
        return options;
    }     
    
    public class WrapContacts
    {
        @AuraEnabled public Contact objCon{get;set;}
        @AuraEnabled public hed__Program_Enrollment__c objProgEnrollment{get;set;}
    }
    
    public Class wrapDocuments
    {
        @AuraEnabled public hed__Education_History__c objEducationHistory{get;set;}
        //@AuraEnabled public Contact objContact{get;set;}
        @AuraEnabled public boolean enableStatus{get;set;}
        @AuraEnabled public boolean enableData{get;set;}
        public wrapDocuments()
        {
            enableStatus = false;
        }   
    }
    
    public class WrapsaveReturnDocuments
    {
        @AuraEnabled public string strMsg{get;set;}
        @AuraEnabled public List<hed__Education_History__c> lst_EducationHistories{get;set;}
    }
    
    public class wrapConfirmDocuments
    {
        @AuraEnabled public String strMessage {get; set;}
        @AuraEnabled public List<hed__Education_History__c> list_EdHis {get; set;}
    }
    
    public class WrapDeleteFiles
    {
        @AuraEnabled public string strdeletefile{get;set;}
        @AuraEnabled public List<ContentDocument> lst_Docfiles{get;set;}
    }
}