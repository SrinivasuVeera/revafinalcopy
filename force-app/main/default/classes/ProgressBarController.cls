public with sharing class ProgressBarController {

    @AuraEnabled(cacheable=true)
    public static String getLoggedInProfile() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }

    @AuraEnabled(cacheable=true)
    public static String getApplicationStatus(Id recordId) {
        return [SELECT hed__Application_Status__c FROM hed__Application__c WHERE Id = :recordId LIMIT 1].hed__Application_Status__c;
    }

    @AuraEnabled
    public static void updateApplicationStatus(Id applicationId, String status) {
        hed__Application__c app = new hed__Application__c(
            Id = applicationId,
            hed__Application_Status__c = status
        );
        update app;
    }
}