@isTest
public class ATT_BulkProxyAttendance_Ctrl_Test 
{
    public static TestMethod void BulkProxyAttend()
    {
        String UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ATT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        Insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        Insert objcon;
        
        DateTime dt = Datetime.now();
        String strTimeInAMorPM = dt.format('MM-dd-yyyy,hh:mm:ss'); 
        ATT_BulkProxyAttendance_Ctrl.Wrapper objWrp = new ATT_BulkProxyAttendance_Ctrl.Wrapper();
        Test.startTest();
        objWrp = ATT_BulkProxyAttendance_Ctrl.CreateProxyAttendance(strTimeInAMorPM,strTimeInAMorPM,'Srn123','Sports Meet');
        Test.stopTest();
        System.assertEquals('Success', objWrp.strMessage);
    }
}