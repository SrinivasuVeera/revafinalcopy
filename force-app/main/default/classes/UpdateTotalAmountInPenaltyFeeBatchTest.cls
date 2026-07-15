@IsTest
public class UpdateTotalAmountInPenaltyFeeBatchTest {
    
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
    
    private class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success"}'); // Adjust as needed based on your expected response
            response.setStatusCode(200);
            return response;
        }
    }

    static testMethod void testBatchExecution() {
         string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
                Hostel_Room_Request_For__c = objCon.Id,
                Type__c = '4',
                Reva_Hostel_JoiningDate__c= system.Today()-45
            
            );
        insert hostelRequest;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        
        Student_Fee__c parentFee = new Student_Fee__c();
        
        		parentFee.Name = 'Hostel Fee - 2025';
                parentFee.Fee_Type__c = 'Hostel Fee';
                parentFee.contact__c=objCon.id;
                parentFee.Number_of_Installments__c = 1;
                parentFee.Paid_Installments__c = 0;
                parentFee.Amount_Pending__c = 3000;
                parentFee.Amount__c =3000;
        		parentFee.Date_of_Joining_Hostel__c =system.Today()-75;
        		
        insert parentFee;
                    
                
        
        
        List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for(Integer i = 0; i < 5; i++) {
            fees.add(new Student_Fee__c(
                Name = 'Hostel Penalty Fees',
                Fee_Type__c = 'Hostel Fee',
                contact__c=objCon.id,
                Student_Hostel_Fee__c=parentFee.Id,
                Number_of_Installments__c = 1,
                Paid_Installments__c = 0,
                
                Amount_Pending__c = 1000,
                Amount__c =3000
            ));
        }
        insert fees;

        // Start the batch job
        Test.startTest();
        UpdateTotalAmountInPenaltyFeeBatch batchJob = new UpdateTotalAmountInPenaltyFeeBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();
}
    
     @isTest
    static void testSchedulerExecution() {
        // Instantiate the scheduler class
        UpdateTotalAmountInPenaltyFeeScheduler scheduler = new UpdateTotalAmountInPenaltyFeeScheduler();
        
        Test.startTest();
        // Call the execute method to simulate the scheduler
        scheduler.execute(null);
        Test.stopTest();

        
    }
}