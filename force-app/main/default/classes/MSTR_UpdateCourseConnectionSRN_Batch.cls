global class MSTR_UpdateCourseConnectionSRN_Batch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        return Database.getQueryLocator([Select ID,Field,OldValue,NewValue,createddate,ContactId,Contact.RecordtypeId,Contact.Student_Status__c,Contact.SRN_Number__c,Contact.Active__c From ContactHistory where createddate = Today and Field = 'SRN_Number__c'
                                         and Contact.RecordtypeId =: ContactRecTypeId and Contact.Student_Status__c IN('Pursuing','Year Back') and Contact.SRN_Number__c != null]); 
    }
    
    global void execute(Database.BatchableContext bc, List<ContactHistory> lst_ContactHistory)
    {
        set<Id> set_ConId = new set<Id>(); 
        List<hed__Course_Enrollment__c> list_CourseConnection = new List<hed__Course_Enrollment__c>();
        
        for(ContactHistory objConHis : lst_ContactHistory)
        {
            if(objConHis.ContactId != null)
            {
                set_ConId.add(objConHis.ContactId);  
            }
        }
        for(hed__Course_Enrollment__c objCourseCon : [select Id,Name,hed__Course_Offering__c,Logisys_External_Id__c,External_Id__c,hed__Course_Offering__r.hed__Course__r.Course_External_ID__c,hed__Course_Offering__r.Active__c,Active_Connection__c,
                                                      hed__Contact__c,hed__Contact__r.SRN_Number__c from hed__Course_Enrollment__c where hed__Contact__c In : set_ConId AND hed__Course_Offering__r.Active__c =: True AND Active_Connection__c =: True])
        {
            objCourseCon.Logisys_External_Id__c = objCourseCon.hed__Contact__r.SRN_Number__c+''+objCourseCon.hed__Course_Offering__r.hed__Course__r.Course_External_ID__c;   
            objCourseCon.External_Id__c = objCourseCon.hed__Contact__r.SRN_Number__c+'_'+objCourseCon.hed__Course_Offering__c;
            list_CourseConnection.add(objCourseCon);
        }        
        if(!list_CourseConnection.IsEmpty())
        {
            Update list_CourseConnection;
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}