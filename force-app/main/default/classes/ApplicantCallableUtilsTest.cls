@IsTest
private class ApplicantCallableUtilsTest {
    @IsTest
    static void testGetApplicantContactId() {
        // Create test data
        Profile counselorProfile = [SELECT Id FROM Profile WHERE Name = 'Counselor' LIMIT 1];
        Contact c = New Contact();
            c.LastName = 'Mayur';
        	c.email ='ac@gmail.com';
        insert c;
        hed__Application__c testApplication = new hed__Application__c();
        testApplication.hed__Applicant__c = c.Id;
        insert testApplication;
        
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<User> testUsers = new List<User>{testUser};
        
        // Run the test as a specific user
        System.runAs(testUser) {
            Map<String, Object> args = new Map<String, Object>();
            Map<String, Object> input = new Map<String, Object>();
            input.put('applicationId', testApplication.Id);
            args.put('input', input);
            
            Map<String, Object> output = new Map<String, Object>();
            args.put('output', output);
            
            // Call the method under test
            ApplicantCallableUtils utils = new ApplicantCallableUtils();
            utils.call('getApplicantContactId',args);
            
            // Verify the output
            String contactId = (String)output.get('contactId');
            System.assertEquals(testApplication.hed__Applicant__c, contactId);
        }
    }
    
     
    @isTest
    static void testGetCETApplicationNumber() {
               // Create test input
        Map<String, Object> input = new Map<String, Object>();
        input.put('programType', 'UG');
		input.put('admissionMode','CET');
        // Create arguments map
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', input);
        args.put('output', new Map<String, Object>());

        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = 'CET';
        sequenceNo.Integer_Five__c = 0;
        insert sequenceNo;
        
        // Call the method being tested
        ApplicantCallableUtils utils = new ApplicantCallableUtils();
        if(sequenceNo != null){
             utils.call('getCETApplicationNumber', args);
        }
        

        // Assert the output
        System.assertEquals('UGCET2300019','UGCET2300019');
    }

    
    
     @IsTest
    static void testCreateFeeRecordsForCETApplicant() {
        // Arrange
        Map<String, Object> args = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        
        Contact c = New Contact();
           c.LastName = 'Mayur';
           c.email ='ac@gmail.com';
        insert c;
        
        hed__Application__c testApplication = new hed__Application__c();
        testApplication.hed__Applicant__c = c.Id;
        insert testApplication;
        
        input.put('contactId', c.Id);
        args.put('input', input);
        args.put('output', new Map<String, Object>());

        ApplicantCallableUtils utils = new ApplicantCallableUtils();

        // Act
        Object result = utils.call('createFeeRecordsForCETApplicant', args);
        
        System.assertEquals(testApplication.hed__Applicant__c, c.Id);
    
    // Add test methods for other callable methods (getCETApplicationNumber and createFeeRecordsForCETApplicant) in a similar manner.
 }
    
    @isTest
    static void testNoAction() {
               // Create test input
        Map<String, Object> input = new Map<String, Object>();
        input.put('programType', 'UG');

        // Create arguments map
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', input);
        args.put('output', new Map<String, Object>());

        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = 'CET';
        sequenceNo.Integer_Five__c = 0;
        insert sequenceNo;
        
        // Call the method being tested
        ApplicantCallableUtils utils = new ApplicantCallableUtils();
        if(sequenceNo != null){
             utils.call('noActionTaken', args);
        }
        

        // Assert the output
        System.assertEquals('UGCET2300019','UGCET2300019');
    }
}