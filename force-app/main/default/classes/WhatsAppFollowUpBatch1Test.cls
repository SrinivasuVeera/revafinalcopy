@isTest
private class WhatsAppFollowUpBatch1Test { 
    
    @isTest
    static void testBatchExecutionSuccessful() {
        // Create a test record type for Contact
        
		id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId(); 
        
        // Create Accounts
        Account accRecPerformingArts = new Account(Name = 'School of Performing Arts and Indic Studies');
        insert accRecPerformingArts;

        Account accRecPhd = new Account(Name = 'Ph.D in Management Studies', Program_Type__c = 'Ph.D');
        insert accRecPhd;
        
        // Create Program Plan
        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c(
            Name = 'Master of Business Administration(2024-2026)',
            hed__Account__c = accRecPhd.Id
        );
        insert mbaAcc;
        
        // Create an active Fee_Master__c record
        Fee_Master__c feeMaster = new Fee_Master__c(
            Program_Batch__c = mbaAcc.Id, // Adjust to match your batch logic
            Fee_Type__c = 'Application Fee',
            Applicant_Category__c = 'Indian (SAARC)',
            IsActive__c = true
        );
        insert feeMaster;       

        

        // Create Contacts that match the query criteria
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = False,
                Primary_Academic_Program__c = accRecPerformingArts.Id,
                //RecordTypeId = rt.Id,
                RecordTypeId  = conRecTypeId,
                Program_Batch__c = mbaAcc.Id
            );
            testContacts.add(applicant);
        }
        insert testContacts;

        // Set up mock response for WhatsApp utility callout
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(202);
        mockResponse.setBody('{"status":"success"}');
        Test.setMock(HttpCalloutMock.class, new YellowAIUtilityMock(mockResponse));

        
        
        Test.startTest();
        WhatsAppFollowUpBatch1 batch = new WhatsAppFollowUpBatch1();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchExecutionFailure() {
        // Create a test record type for Contact
        
		id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId(); 
        
        // Create Accounts
        Account accRecPerformingArts = new Account(Name = 'School of Performing Arts and Indic Studies');
        insert accRecPerformingArts;

        Account accRecPhd = new Account(Name = 'Ph.D in Management Studies', Program_Type__c = 'Ph.D');
        insert accRecPhd;
        
        // Create Program Plan
        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c(
            Name = 'Master of Business Administration(2024-2026)',
            hed__Account__c = accRecPhd.Id
        );
        insert mbaAcc;
        
        // Create an active Fee_Master__c record
        Fee_Master__c feeMaster = new Fee_Master__c(
            Program_Batch__c = mbaAcc.Id, // Adjust to match your batch logic
            Fee_Type__c = 'Application Fee',
            Applicant_Category__c = 'Indian (SAARC)',
            IsActive__c = true
        );
        insert feeMaster;    
       

        // Create Contacts that match the query criteria
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = False,
                Primary_Academic_Program__c = accRecPerformingArts.Id,
                //RecordTypeId = rt.Id,
                RecordTypeId  = conRecTypeId,
                Program_Batch__c = mbaAcc.Id
            );
            testContacts.add(applicant);
        }
        insert testContacts;

        // Set up mock response for WhatsApp utility callout
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('{"status":"failure"}');
        Test.setMock(HttpCalloutMock.class, new YellowAIUtilityMock(mockResponse));        
        
        Test.startTest();
        WhatsAppFollowUpBatch1 batch = new WhatsAppFollowUpBatch1();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    // Mock class for Yellow_AI_Utility
    private class YellowAIUtilityMock implements HttpCalloutMock {
        private HttpResponse mockResponse;

        YellowAIUtilityMock(HttpResponse response) {
            this.mockResponse = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}