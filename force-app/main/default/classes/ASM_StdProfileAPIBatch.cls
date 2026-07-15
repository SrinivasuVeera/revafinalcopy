global class ASM_StdProfileAPIBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
     global Date filterDate;
     global ASM_StdProfileAPIBatch(Date fDate){
     filterDate = fDate;
     }
	global Database.QueryLocator start(Database.BatchableContext BC){
        //semester> start date>10 days before of start date   start(15) = today+5
        return database.getQueryLocator([SELECT Id,Name FROM Contact WHERE SRN_Number__c != '' AND Logisys_Integration__c != 'Yes' 
                                         AND Active_Semester__r.hed__Start_Date__c <= :filterDate  ]);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        Set<Id> set_StdIds = new Set<Id>();
        Map<Id,String> map_DataChanges = new Map<Id,String>();
        for(Contact con : scope){
            set_StdIds.add(con.Id);
            map_DataChanges.put(con.Id, 'No-No-No');
        }
        Debug_Log__c dLog = ASM_StdProfileAPI.sendStdProfiles(set_StdIds,map_DataChanges,true);
        Insert dLog;
    }
    global void finish(Database.BatchableContext BC){       
    }
}