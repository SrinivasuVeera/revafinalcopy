@isTest
public class SAP_SRN_PushtoSAPBatchAPIHandler_Test
{
    public static testMethod void pushSAPBatchAPIHndlr1()	
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        //objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon1 = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon1.MobilePhone ='9090909090';
        objCon1.Aadhar_Card_Number__c ='098765435612';
        objCon1.RecordTypeId = StudentRecId;
        //objCon.AccountId = objAcc.Id;
        objcon1.Application_Number__c = 'test123';
        objcon1.SRN_Number__c ='123';
        objcon1.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon1.Nationality__c ='Indian';
        Insert objCon1; 
        
        
        List<id> lst_ContIds1 = new List<id>();
        lst_ContIds1.add(objCon1.id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpMockCallout(200,'OK','{"Response": [{"SFDCRecordId": "0031s000019UhZiAAK", "statusCode": 0, "SAPID": "SAP123", "responseObject": "Success"}]}'));
        //TestHttpMockCallout controller = new TestHttpMockCallout(200,'OK','{"Response": [{"SFDCRecordId": "0031s000019UhZiAAK", "statusCode": 0, "SAPID": "SAP123", "responseObject": "Success"}]}');	
        SAP_SRN_PushtoSAPBatchAPIHandler.StudentMasterCreationMethod(lst_ContIds1);
        Test.stopTest();
    }
    
    
    public static testMethod void pushSAPBatchAPIHndlr2()	
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        //objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon2 = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon2.MobilePhone ='9090909090';
        objCon2.Aadhar_Card_Number__c ='098765435612';
        objCon2.RecordTypeId = StudentRecId;
        //objCon.AccountId = objAcc.Id;
        objcon2.Application_Number__c = 'test123';
        objcon2.SRN_Number__c ='123';
        objcon2.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon2.Nationality__c ='Indian';
        objcon2.Student_Status__c = 'Pursuing';
        Insert objCon2; 
        
        
        List<id> lst_ContIds2 = new List<id>();
        lst_ContIds2.add(objCon2.id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpMockCallout(200,'OK','{"Response": [{"SFDCRecordId": "0031s000019UhZiAAK", "statusCode": 1, "SAPID": "SAP123", "responseObject": "Failure"}]}'));
        SAP_SRN_PushtoSAPBatchAPIHandler.StudentMasterCreationMethod(lst_ContIds2);
        Test.stopTest();
    }
 
   /* public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer code;
        String status;
        String bodyAsString;
        Blob bodyAsBlob;
        Map<String, String> responseHeaders;
        
    public MockHttpResponseGenerator(Integer code, String status, String body) 
    {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
    }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"Response": [{"SFDCRecordId": "0031s000019UhZiAAK", "statusCode": 0, "SAPID": "SAP123", "responseObject": "Success"}]}');
            return res;
        }

    }*/
    
}