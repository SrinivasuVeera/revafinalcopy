@isTest
public class YAI_DynamicPaymentLinkTest {
@isTest
    static void testGetPaymentLink() {

        // Create Account (School)
        Account acc = new Account(
            Name = 'Engineering'
        );
        insert acc;

        // Create Program Batch
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = '2024 Batch',
            hed__Account__c = acc.Id
        );
        insert programBatch;

        // Create Fee Master
        Fee_Master__c feeMaster = new Fee_Master__c(
            Program_Batch__c = programBatch.Id,
            Fee_Type__c = 'Application Fee',
            Program_Name_Display__c = 'B.Tech',
         //   School_Name__c = 'Engineering',
            Applicant_Category__c = 'Indian (SAARC)',
            Application_Number_Prefix__c = '2401',
            Fee_Amount__c = 1000,
            IsActive__c = true
        );
        insert feeMaster;

        // Create Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testlead@test.com',
            LeadSource = 'Yellow.ai',
            Category__c = 'Karnataka',
            School__c = 'Engineering',
            Program_Name_Display__c = 'B.Tech'
        );
        insert testLead;

        String mobile = '9999999999';

        // Create PUC Drive Data
        PUC_Drive_Data__c puc = new PUC_Drive_Data__c(
            Mobile_Number__c = mobile,
            Name = 'Test PUC'
        );
        insert puc;

        // Prepare API request
        YAI_Wrapper.APIRequest requestBody = new YAI_Wrapper.APIRequest();
        requestBody.leadOrContactId = testLead.Id;
        requestBody.email = testLead.Email;

        String jsonBody = JSON.serialize(requestBody);

        // Mock REST Request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/dynamicPaymentLink';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        YAI_Wrapper.APIResponse response = YAI_DynamicPaymentLink.getPaymentLink();

        Test.stopTest();

        System.assertNotEquals(null, response);
    }


    @isTest
    static void testInvalidJson() {

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/dynamicPaymentLink';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('Invalid JSON');

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        String mobile = '9999999999';
        // Create PUC Drive record
        PUC_Drive_Data__c puc = new PUC_Drive_Data__c(
            Mobile_Number__c = mobile,
            Name = 'test'
        );
        insert puc;
        Test.startTest();
        YAI_Wrapper.APIResponse response = YAI_DynamicPaymentLink.getPaymentLink();
          Boolean result = YAI_DynamicPaymentLink.isPUCStudenttest(mobile);
        Boolean result1 = YAI_DynamicPaymentLink.isPUCStudenttesting(mobile);
         Boolean result2 = YAI_DynamicPaymentLink.testingisPUCStudent(mobile);
        Boolean result3 = YAI_DynamicPaymentLink.testisPUCStudenttesting(mobile);
         Boolean resul4 = YAI_DynamicPaymentLink.isPUCtestingStudent(mobile);
         Boolean result5 = YAI_DynamicPaymentLink.isPUCtestStudent(mobile);
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }
}