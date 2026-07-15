@isTest
public class ASM_ContactTrgHandlerTest {
	@TestSetup
    static void setup() {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.Logisys_Integration__c = 'Yes';
        Insert ObjCon;
    }
    
    static testMethod void exe(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        ASM_MockCallout TestMock = new ASM_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","status":"Y"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        Test.startTest();
        Update con;
        Test.stopTest();
    }
}