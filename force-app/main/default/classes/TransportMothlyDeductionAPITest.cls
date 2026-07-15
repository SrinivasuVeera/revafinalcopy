@isTest
public class TransportMothlyDeductionAPITest {

    @isTest
    static void testMonthlyDeductionInsert() {
        // Step 1: Create mock data for Transport Registration
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Employee_Number__c = 'EMP001');
        insert testContact;

        Transport_Registeration__c testRegistration = new Transport_Registeration__c(Contact__c = testContact.Id);
        insert testRegistration;

        // Step 2: Prepare the JSON input for insertion
        String jsonInput = '[{'
            + '"Employee_Number": "EMP001",'
            + '"Employee_Name": "Test User",'
            + '"Type": "Transportation",'
            + '"HCM_Record_Id": "HCM123",'
            + '"Fiscal_Year": "2024",'
            + '"Fiscal_Month": "November",'
            + '"Actual_Deduction_Amount": 150.50,'
            + '"Current_Deduction_Amount": 50.25'
            + '}]';

        Test.startTest();

        // Simulate the HTTP request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the API method
        TransportMothlyDeductionAPI.MonthlyDeduction();

        Test.stopTest();

        // Assertions
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"Status":"Success"'), 'Response should indicate success');

        // Verify the insertion of TransportMonthlyDeduction record
        TransportMothlyDeduction__c insertedRecord = [SELECT Id, Employee_Number__c, Actual_Deduction_Amount__c 
                                                      FROM TransportMothlyDeduction__c 
                                                      WHERE HCM_Record_Id__c = 'HCM123'];
        System.assertNotEquals(null, insertedRecord, 'A TransportMonthlyDeduction record should be created');
        System.assertEquals(150.50, insertedRecord.Actual_Deduction_Amount__c, 'Actual deduction amount should match');
    }

    @isTest
    static void testMonthlyDeductionUpdate() {
        // Step 1: Create mock data for Transport Registration and an existing deduction record
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Employee_Number__c = 'EMP002');
        insert testContact;

        Transport_Registeration__c testRegistration = new Transport_Registeration__c(Contact__c = testContact.Id);
        insert testRegistration;

        TransportMothlyDeduction__c existingDeduction = new TransportMothlyDeduction__c(
            Employee_Number__c = 'EMP002',
            Employee_Name__c = 'Old User',
            Type__c = 'Transportation',
            HCM_Record_Id__c = 'HCM456',
            Fiscal_Year__c = '2023',
            Fiscal_Month__c = 'October',
            Actual_Deduction_Amount__c = 100.00,
            Current_Deduction_Amount__c = 25.00,
            Transport_Registration__c = testRegistration.Id
        );
        insert existingDeduction;

        // Step 2: Prepare the JSON input for update
        String jsonInput = '[{'
            + '"Employee_Number": "EMP002",'
            + '"Employee_Name": "Updated User",'
            + '"Type": "Transportation",'
            + '"HCM_Record_Id": "HCM456",'
            + '"Fiscal_Year": "2024",'
            + '"Fiscal_Month": "November",'
            + '"Actual_Deduction_Amount": 200.50,'
            + '"Current_Deduction_Amount": 75.25'
            + '}]';

        Test.startTest();

        // Simulate the HTTP request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the API method
        TransportMothlyDeductionAPI.MonthlyDeduction();

        Test.stopTest();

        // Assertions
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"Status":"Success"'), 'Response should indicate success');

        // Verify the update of TransportMonthlyDeduction record
        TransportMothlyDeduction__c updatedRecord = [SELECT Id, Employee_Name__c, Actual_Deduction_Amount__c 
                                                     FROM TransportMothlyDeduction__c 
                                                     WHERE HCM_Record_Id__c = 'HCM456'];
        System.assertNotEquals(null, updatedRecord, 'The TransportMonthlyDeduction record should be updated');
        System.assertEquals('Updated User', updatedRecord.Employee_Name__c, 'Employee name should be updated');
        System.assertEquals(200.50, updatedRecord.Actual_Deduction_Amount__c, 'Actual deduction amount should be updated');
    }

    @isTest
    static void testMonthlyDeductionNoTransportRegistration() {
        // Step 1: Prepare JSON input without matching transport registration
        String jsonInput = '[{'
            + '"Employee_Number": "EMP999",'
            + '"Employee_Name": "No Transport",'
            + '"Type": "Transportation",'
            + '"HCM_Record_Id": "HCM999",'
            + '"Fiscal_Year": "2024",'
            + '"Fiscal_Month": "November",'
            + '"Actual_Deduction_Amount": 150.50,'
            + '"Current_Deduction_Amount": 50.25'
            + '}]';

        Test.startTest();

        // Simulate the HTTP request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the API method
        TransportMothlyDeductionAPI.MonthlyDeduction();

        Test.stopTest();

        // Assertions
        System.assertEquals(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"Status":"Failed"'), 'Response should indicate failure');
        System.assert(responseBody.contains('No matching transport registration found'), 'Error message should indicate no matching transport registration');
    }
}