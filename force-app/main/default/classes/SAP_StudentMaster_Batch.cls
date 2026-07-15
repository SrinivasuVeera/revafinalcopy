global class SAP_StudentMaster_Batch implements Schedulable,Database.Batchable<sObject>, Database.AllowsCallouts {
global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Program_Batch__c, hed__WorkEmail__c,Email, Aadhar_Card_Number__c, Application_Number__c, SAP_ID__c,
                                Primary_Academic_Program__r.SAP_ID__c,Enrollment_Type__c,Admission_Mode__c,Integrated_with_SAP__c,Quota__c,Father__r.MobilePhone,MobilePhone,School__c,Program_Batch__r.SAP_ID__c,Personal_Email__c,School__r.SAP_ID__c,
                                SRN_Number__c ,School__r.Parent.SAP_ID__c,Provisional_Admission_Fee_Paid_Date__c,Application_Fee_Paid_Date__c,
                                Student_Full_Name__c, Student_Status__c FROM Contact Where (Provisional_Admission_Fee_Paid_Date__c = TODAY OR Application_Fee_Paid_Date__c = TODAY) AND Integrated_with_SAP__c = false]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> lst_Contact) {
        list<Id> ContactIds = new List<Id>();
        
        for(Contact objContact:lst_Contact){
            ContactIds.add(objContact.Id);
        }
        if(!ContactIds.isEmpty())
        {
            SAP_StudentMaster_Batch_Handler.StudentMasterCreationMethod(ContactIds);
        }
    }
    
    global void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new SAP_StudentMaster_Batch(),5);
    }
    
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
    }

}