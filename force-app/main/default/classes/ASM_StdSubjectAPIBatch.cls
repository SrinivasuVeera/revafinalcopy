global class ASM_StdSubjectAPIBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Set<Id> semesterIds;

    global ASM_StdSubjectAPIBatch(Set<Id> semIds) {
        this.semesterIds = semIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,Name FROM hed__Term__c WHERE Id IN :semesterIds]);
    }

    global void execute(Database.BatchableContext BC, List<hed__Term__c> scope) {
        List<Id> scopeSemIds = new List<Id>();
       // Set<String> semnames = new Set<String>();
        for (hed__Term__c term : scope) {
            scopeSemIds.add(term.Id);
           // semnames.add(term.Name);
        }

       /* Set<Id> courseEnrollmentIds = new Set<Id>();
        for (hed__Course_Enrollment__c ce : [SELECT Id, Semester__c FROM hed__Course_Enrollment__c
            WHERE Semester__c IN :semnames AND Logisys_Integration__c != 'Yes' AND RecordType.DeveloperName = 'Student'
            AND Active_Connection__c = TRUE AND Push_Course_Connection_to_Logysis__c = FALSE])
        {                
            courseEnrollmentIds.add(ce.Id);
        } */

        if (!scopeSemIds.isEmpty()) {
            List<Debug_Log__c> dLog = ASM_StdSubjectAPI.sendStdSubject(scopeSemIds); // If method accepts Set<Id>
            insert dLog;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Optional logging or notification
    }
}