@isTest
public class ASM_StdProfileAPITest {
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
        Insert ObjCon;
    }
    
    static testMethod void exe(){
        List<Contact> scope = [SELECT Id FROM Contact];
        Set<Id> set_StdIds = new Set<Id>();
        Map<Id,String> map_DataChanges = new Map<Id,String>();
        for(Contact con : scope){
            set_StdIds.add(con.Id);
            map_DataChanges.put(con.Id, 'No-No-No');
        }
        ASM_MockCallout TestMock = new ASM_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","status":"Y"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        Test.startTest();
        ASM_StdProfileAPI.sendStdProfile_future(set_StdIds,map_DataChanges,true);
        List<List<Contact>> newconList = new list<List<Contact>>{scope};
        List<String> status = ASM_StdProfileAPI.sendStdProfile_Invokable(newconList);
        Test.stopTest();
    }
}