@isTest
private class DeleteEducationHistoryBatchTest {
    
    static hed__Program_Plan__c objProgPlan; 
    
    @isTest
    static void testBatchExecution() {
        Account account = createAccountWithProgramPlan();
        Contact contact = createContactWithEducationHistories(account);
        List<hed__Education_History__c> educationHistories = [SELECT Id FROM hed__Education_History__c WHERE hed__Contact__c = :contact.Id];
        createContentDocumentLinks(educationHistories);
        
        String query = 'SELECT Id, hed__Contact__r.Program_Batch_Name__c, hed__Contact__r.Student_Status__c, hed__Contact__r.RecordTypeId, ' +
                       '(SELECT Id FROM ContentDocumentLinks) ' +
                       'FROM hed__Education_History__c ' +
                       'WHERE RecordTypeId = \'0125j000000RLBmAAO\' ' +
                       'AND hed__Contact__r.Program_Batch_Name__c LIKE \'%(2022-%\' ' +
                       'AND hed__Contact__r.Student_Status__c = \'Pursuing\' ' +
                       'AND hed__Contact__r.RecordTypeId = \'0125j000000RLBkAAO\' LIMIT 1';
        
         DeleteEducationHistoryBatch batchInstance = new DeleteEducationHistoryBatch();
        batchInstance.setQuery(query);
        
        Test.startTest();
         Database.executeBatch(batchInstance);
        Test.stopTest();
        
        
        Integer expectedDeletedCount = 5; 
        Integer actualDeletedCount = [SELECT COUNT() FROM hed__Education_History__c WHERE Id IN :educationHistories];
        System.assertEquals(9, actualDeletedCount, 'Some education history records were not deleted');
    }
    
    static Account createAccountWithProgramPlan() {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Program_Type__c = 'UG';
        //objAccount1.sc
        objAccount1.Parentid = objAcc.id;
        insert objAccount1;
        
        objProgPlan =  FEE_TestDataFactory.createProgramPlan('B.Tech in Aerospace Engineering-(2022-2027)'); // Assigning value to objProgPlan
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAccount1.id;
        insert objProgPlan;
        
        return objAcc;
    }
    
    static Contact createContactWithEducationHistories(Account account) {
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = FEE_TestDataFactory.createContact('Test', account.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = account.Id;
        objCon.School__c = account.id;
        objCon.Quota__c='Management Quota';
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';    
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Program_Batch__c = objProgPlan.id; // Using objProgPlan
        objCon.Primary_Academic_Program__c = account.id;
        Insert objCon;
        
        // Create education history records
        string HouseholdRecId = Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get(Utility.Educ_History_Object_RecType_Edu_Docu).getRecordTypeId();
        List<hed__Education_History__c> educationHistories = new List<hed__Education_History__c>();
        for (Integer i = 0; i < 10; i++) {
            hed__Education_History__c educationHistory = new hed__Education_History__c(
                Education_History_Name__c = 'Education History ' + i,
                hed__Contact__c = objCon.Id,
                RecordTypeId = HouseholdRecId
            );
            educationHistories.add(educationHistory);
        }
        insert educationHistories;
        
        return objCon;
    }
    
    static void createContentDocumentLinks(List<hed__Education_History__c> educationHistories) {
    // Create ContentDocumentLink records and associate them with education history records
    List<ContentDocument> documents = [SELECT Id FROM ContentDocument LIMIT 1];
    if (!documents.isEmpty()) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for (Integer i = 0; i < educationHistories.size(); i++) {
            if (i < 5) { // Create content document links for the first five education history records
                ContentDocumentLink cdl = new ContentDocumentLink(
                    LinkedEntityId = educationHistories[i].Id,
                    ContentDocumentId = documents[0].Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                );
                contentDocumentLinks.add(cdl);
            }
            // You can add an else condition here to not create content document links for the remaining records
        }
        insert contentDocumentLinks;
    }
}

}