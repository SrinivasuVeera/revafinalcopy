public with sharing class BrandingCaseListView {
    @AuraEnabled(cacheable=true)
    public static Id getFacultyRecordTypeId() {
        return Schema.SObjectType.Branding_Case__c.getRecordTypeInfosByDeveloperName()
            .get('Department_Branding_Request')
            .getRecordTypeId();
    }
    @AuraEnabled(cacheable=true)
    public static List<Branding_Case__c> getRecentCases() {
    return [SELECT Id, Name, Subject__c, Description__c, Case_Type__c, Status__c, Category__c, Sub_Category__c,
            School_Department_Goodies__c, Goodies_Count__c, Service_Type__c, Venue__c, Service_Time__c,
            From_Time__c, To_Time__c, Case_Attachment__c, Old_Case_Number__c
            FROM Branding_Case__c
            ORDER BY CreatedDate DESC
            LIMIT 15];
}

}