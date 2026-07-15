@isTest
public class ASM_StdProfileAPIBatchTest {
	@TestSetup
    static void setup() {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2024',
         //   Program_Batch__c = ProgramBatch.Id,
            hed__Start_Date__c = Date.today().addDays(10),
            hed__Account__c = objAcc.Id
        );
        insert term;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.Logisys_Integration__c = 'No';
        Objcon.Active_Semester__c = term.Id;
        Insert ObjCon;
        System.debug('objcon=> '+ObjCon);
    }
    
    static testMethod void exe(){
        ASM_MockCallout TestMock = new ASM_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","status":"Y"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        Test.startTest();
        Date s = Date.today().addDays(Integer.valueOf(System.label.StudentMasterScheduleTime));
        System.debug('s=> '+s);
        Database.executeBatch(new ASM_StdProfileAPIBatch(s));
        Test.stopTest();
    }

}