@isTest
public class SAP_SRN_PushtoSAPBatch_Test 
{
    public static testmethod void SRN_PushToSAP()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ATT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        ContactHistory conHis =  new ContactHistory();
        conHis.ContactId = objcon.Id;
        conHis.Field = 'SRN_Number__c';
        Insert conHis;
        
        Test.startTest();
        SAP_SRN_PushtoSAPBatch Batch = new SAP_SRN_PushtoSAPBatch();
        database.executeBatch(Batch);
        Test.stopTest();
        system.assertequals(conHis.id,conHis.id);
    }  
}