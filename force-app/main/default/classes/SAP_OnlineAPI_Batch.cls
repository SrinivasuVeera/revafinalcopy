global class SAP_OnlineAPI_Batch implements Schedulable,Database.Batchable<sObject>, Database.AllowsCallouts {
    global static final Date specificDate = Date.newInstance(2026, 4, 1);
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([SELECT Id, Name,Line_Item_Payment_Status__c,Push_to_SAP__c,CreatedDate,Student_Fee__r.Name,Transaction_Date_Time__c,Student_Fee__r.Contact__r.Integrated_with_SAP__c,
                                         Integrated_with_SAP__c,Mode_of_Payment__c FROM Student_Fee_Payment__c
                                         WHERE Mode_of_Payment__c = 'Online' AND Line_Item_Payment_Status__c = 'Success'
                                         AND Integrated_with_SAP__c = false AND (CreatedDate >=: specificDate OR Transaction_Date_Time__c >=: specificDate) AND Student_Fee__r.Contact__r.Integrated_with_SAP__c = TRUE]);
    }
    
    global void execute(Database.BatchableContext bc, List<Student_Fee_Payment__c> lst_Std_Fee_Payments) {
        list<Id> lst_Std_Fee_Pay_Ids = new List<Id>();
        
        for(Student_Fee_Payment__c objStdFeePayments:lst_Std_Fee_Payments){          
            
            lst_Std_Fee_Pay_Ids.add(objStdFeePayments.Id);
        }
        if(!lst_Std_Fee_Pay_Ids.isEmpty())
        {
            try {
                SAP_OnlineAPI_BatchHandler.OnlineAPIMethod(lst_Std_Fee_Pay_Ids);
            } catch(Exception e) {
                System.debug('Batch Callout failed: ' + e.getMessage());
            }
        } 
    }
    
    global void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new SAP_OnlineAPI_Batch(),1);
    }
    
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
    }
}