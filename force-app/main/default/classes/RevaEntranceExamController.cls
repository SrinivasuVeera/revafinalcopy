public with sharing class RevaEntranceExamController {

    private static Id getContactId() {

        if(Test.isRunningTest()){
            return [SELECT Id FROM Contact LIMIT 1].Id;
        }

        return [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ].ContactId;
    }

    @AuraEnabled(cacheable=true)
    public static Contact getContactDetails() {

        Id contactId = getContactId();

        return [
            SELECT Id,
                   Applying_For_REVA_CET__c,
                   Exam_Type__c,
                   Exam_Date1__c,
                   Primary_Application_Submitted__c
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static void updateExamDetails(String applyingRise){
                                        // String examType, String examDate){

        Id contactId = getContactId();

        Contact con = new Contact(
            Id = contactId,
            Applying_For_REVA_CET__c = applyingRise
           // Exam_Type__c = examType,
            //Exam_Date1__c = examDate
        );

        update con;
    }
}