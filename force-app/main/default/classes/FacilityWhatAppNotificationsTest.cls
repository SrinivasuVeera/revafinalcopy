@isTest
private class FacilityWhatAppNotificationsTest {

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate a valid JSON response
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testMakeCalloutAsync() {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account', HouseholdRecId);
        objAcc.RecordTypeId = HouseholdRecId;
        insert objAcc;

        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test', objAcc.Id);
        objCon.FirstName = 'Test';
        objCon.LastName = 'Contact';
        objCon.MobilePhone = '9090909090';
        objCon.Aadhar_Card_Number__c = '098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Number__c = 'test123';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c = 'test123@reva.edu.in';
        objCon.Nationality__c = 'Indian';
        objCon.Email = 'test@gmail.com';
        insert objCon;

        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
        User testUser = new User(
            ProfileId = p.Id,
            Username = 'newUser@epeople.com',
            Email = 'pb@f.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'nuser',
            LastName = 'Baburao',
            FirstName = 'Lal',
            ContactId = objCon.Id,
            Phone = '9011113246'
        );
        insert testUser;

        // Use the test user context for further operations if needed
        System.runAs(testUser) 
        {
            // Debug the user to verify the phone number
            User currentUser = [SELECT Id, Phone,Name FROM User WHERE Id = :UserInfo.getUserId()];
            System.debug('Current User : ' + currentUser.Name);

            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;

            Facility_Request__c testRequest = new Facility_Request__c(
                Start_Date__c = Date.today(),
                Start_Time__c = Time.newInstance(9, 0, 0, 0),
                End_Date__c = Date.today().addDays(1),
                End_Time__c = Time.newInstance(17, 0, 0, 0),
                TemplateName__c = 'Requested',
                Building_Name__c = 'Building 1',
                Floor__c = 'Floor 2',
                Room_No__c = 'Room 101',
                Account__c = testAccount.Id
            );
            insert testRequest;

            // Debug the formula field value
            System.debug('Facility_Request__c.Reqester_Phone_Number__c: ' + testRequest.Reqester_Phone_Number__c);

            Facility_Request__c testRequest2 = new Facility_Request__c(
                Start_Date__c = Date.today(),
                Start_Time__c = Time.newInstance(9, 0, 0, 0),
                End_Date__c = Date.today().addDays(1),
                End_Time__c = Time.newInstance(17, 0, 0, 0),
                TemplateName__c = 'Approved',
                Building_Name__c = 'Building 1',
                Floor__c = 'Floor 2',
                Room_No__c = 'Room 101',
                Account__c = testAccount.Id,
                ApproverName__c = 'Test Approver'
            );
            insert testRequest2;

            Facility_Request__c testRequest3 = new Facility_Request__c(
                Start_Date__c = Date.today(),
                Start_Time__c = Time.newInstance(9, 0, 0, 0),
                End_Date__c = Date.today().addDays(1),
                End_Time__c = Time.newInstance(17, 0, 0, 0),
                TemplateName__c = 'Rejected',
                Building_Name__c = 'Building 1',
                Floor__c = 'Floor 2',
                Room_No__c = 'Room 101',
                Account__c = testAccount.Id,
                ApproverName__c = 'Test Approver'
            );
            insert testRequest3;

            Test.setMock(HttpCalloutMock.class, new RestMock());

            Test.startTest();
            FacilityWhatAppNotifications.sendWhatsAppNotifications(new List<String>{testRequest.Id, testRequest2.Id, testRequest3.Id});
            FacilityWhatAppNotifications.makeCalloutAsyncJob(new List<String>{testRequest.Id, testRequest2.Id, testRequest3.Id});
       
            Test.stopTest();
            
            /*Test.startTest();
            FacilityWhatAppNotifications.FacilityRejected(testRequest3);
            Test.stopTest();
            
            Test.startTest();
            FacilityWhatAppNotifications.FacilityApproved(testRequest2);
            Test.stopTest();
            
              Test.setMock(HttpCalloutMock.class, new RESTMOCK());
       
         Test.startTest();
       
        Call the future method directly
        FacilityWhatAppNotifications.makeCalloutAsyncJob(new List<String>{testRequest.Id, testRequest2.Id, testRequest3.Id});
        Test.stopTest();
        */
        }
    }
}