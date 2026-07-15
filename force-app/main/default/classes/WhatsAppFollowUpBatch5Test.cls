@isTest
public class WhatsAppFollowUpBatch5Test {    
    @testSetup
    static void setupTestData() {
        id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
         Account accRecBtech = new Account();
        accRecBtech.Name = 'B.Tech in Mechanical Engineering';
        accRecBtech.Program_Type__c = 'UG';
        insert accRecBtech;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024-2026)';    
        mbaAcc.hed__Account__c =accRecBtech.Id;
        insert mbaAcc;
        
        hed__Program_Plan__c progBatch = new hed__Program_Plan__c();
        progBatch.Name = 'B. Tech in Mechatronics Engineering-(2024-2028)';
        progBatch.hed__Account__c =accRecBtech.Id;
        insert progBatch;
        
        // Create test data for Fee_Master__c
        List<Fee_Master__c> feeMasters = new List<Fee_Master__c>();
        feeMasters.add(new Fee_Master__c(
            Program_Batch__c = progBatch.Id,
            IsActive__c = true,
            Fee_Type__c = 'Application Fee', 
            Applicant_Category__c = 'Indian (SAARC)'
        ));
        insert feeMasters;    


         User testUser = [SELECT Id, Name, Phone FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Create test data for hed__Application__c
        List<hed__Application__c> applications = new List<hed__Application__c>();
        Contact applicant = new Contact(
            Mobilephone = '+1234567890',
            LastName = 'Test Applicant',
            Application_Fee_Paid__c = true,
            Admission_Mode__c ='UQ',
            Primary_Academic_Program__c = accRecBtech.Id,                
            RecordTypeId  = conRecTypeId,          
            Program_Batch__c=progBatch.Id,
            OwnerId = testUser.Id
        );
        insert applicant;

        applications.add(new hed__Application__c(
            hed__Applicant__c = applicant.Id,
            hed__Application_Status__c = 'Interested',
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'APP000'                               
        ));
        insert applications;
    }

    @isTest
    static void testWhatsAppFollowUpBatch5() {
        // Start the test
        Test.startTest();

        // Instantiate the batch class
        WhatsAppFollowUpBatch5 batch = new WhatsAppFollowUpBatch5();

        // Execute the batch start method
        Database.QueryLocator ql = batch.start(null);
        System.assertNotEquals(null, ql);

              
        // Create a list of test applications for the execute method
        List<hed__Application__c> testApplications = [SELECT Id, hed__Applicant__r.Name, hed__Applicant__r.Mobilephone, hed__Applicant__r.Program_Batch__r.Name, hed__Applicant__r.Owner.Name, hed__Applicant__r.Owner.Phone FROM hed__Application__c LIMIT 1];
     
        // Execute the batch execute method
        batch.execute(null, testApplications);

        // Execute the batch finish method
        batch.finish(null);

        // End the test
        Test.stopTest();
    }
}