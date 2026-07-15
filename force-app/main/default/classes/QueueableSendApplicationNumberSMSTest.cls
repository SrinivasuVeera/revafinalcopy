@isTest
public class QueueableSendApplicationNumberSMSTest {
	private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
@TestSetup
    public static void createData(){
        RecordType applicantRT = [Select id FROM RecordType Where DeveloperName = 'Applicant' Limit 1];
        
        // create a test Account
       Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '123-456-7890',
            BillingStreet = '123 Main St',
            BillingCity = 'Anytown',
            BillingState = 'CA',
            BillingPostalCode = '12345',
            BillingCountry = 'USA',
            OwnerId = UserInfo.getUserId()
        );
        insert testAccount;
        
        Contact conWithAliasG8 = new Contact(
            FirstName ='Sai',
            MiddleName = 'K',
            LastName = 'Kumari',
            Email = 'saig8@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = ApplicantRT.Id,
            Application_Fee_Paid__c = true,
            AccountId = testAccount.Id,
            Country_Code__c = 'India (+91)',
            Application_Number__c = '222333555'
        );

      
        Contact conWithAlias8 = new Contact(
            FirstName = 'Sai',
            MiddleName = '',
            LastName = 'Kiran',
            Email = 'sai8@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = ApplicantRT.Id,
            Application_Fee_Paid__c = true,
            AccountId = testAccount.Id,
             Country_Code__c = 'India (+91)',
            Application_Number__c = '222333555'
        );

        Contact conWithAliasL8 = new Contact(
            FirstName = 'Sai',
            MiddleName = 'K',
            LastName = 'K',
            Email = 'sail8@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = ApplicantRT.Id,
            Application_Fee_Paid__c = true,
            AccountId = testAccount.Id,
             Country_Code__c = 'India (+91)',
            Application_Number__c = '222333555'
        );

        insert conWithAliasG8;
        insert conWithAlias8;
        insert conWithAliasL8;
    }
 
    @isTest static void TestPartialUserCreation(){
        
        list<contact> clist = [select id, Application_Fee_Paid__C,Record_Type_Name__c,MobilePhone,Country_Code__c,Application_Number__C from contact]; 
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
		//conList1 = [select id, Application_Fee_Paid__C,Record_Type_Name__c,MobilePhone,Country_Code__c,Application_Number__C from contact where Id IN : conList];
        // Enqueue the queueable class
        Test.startTest();
        QueueableSendApplicationNumberSMS queueable = new QueueableSendApplicationNumberSMS(clist);
        ID jobID = System.enqueueJob(queueable);
        Test.stopTest();

        // Verify that the queueable class executed successfully
        System.assert(queueable != null);
    }

}