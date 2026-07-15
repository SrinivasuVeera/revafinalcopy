global class ASM_IAMarksFomSfAPIBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global Date filterDate;
    global ASM_IAMarksFomSfAPIBatch(Date fDate){
        filterDate = fDate;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return database.getQueryLocator([SELECT Id,Name FROM hed__Term__c WHERE RecordType.DeveloperName = 'Sections' AND hed__Parent_Term__r.Rve_SEE_Result_Date__c =: filterDate]);
    }
    global void execute(Database.BatchableContext BC, List<hed__Term__c> scope){
        Set<Id> set_IamIds = new Set<Id>();
        for(IA_Marks__c iam : [SELECT Id FROM IA_Marks__c WHERE Active_Section__c=: scope[0].Id AND Logisys_Integration__c != 'Yes']){
            set_IamIds.add(iam.Id);
        }
        if(!set_IamIds.isEmpty() || Test.isRunningTest()){
            Debug_Log__c dLog = ASM_IAMarksFomSfAPI.sendIAMarks(set_IamIds,'I');
            Insert dLog;
        }
    }
    global void finish(Database.BatchableContext BC){       
    }
}