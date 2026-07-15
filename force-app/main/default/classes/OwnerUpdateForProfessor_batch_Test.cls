@isTest
public class OwnerUpdateForProfessor_batch_Test  
{
    public static testmethod void OwnerUpdateForProfessor()
    {
        string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId;  
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objContact = MSTR_TestDataFactory.createContact('test Contact');
        objContact.AccountId = objAcc.id;
        objContact.FirstName  = 'Test Con';
        objContact.LastName  ='LastCon';
        objContact.ReportsToId  = objContact.Id;
        objContact.Active__c = true;
        objContact.RecordTypeId = recordTypId;
        objContact.Employee_Number__c  ='EP134';         
        objContact.hed__WorkEmail__c  = 'TestCon00@reva.edu.in';
        insert objContact;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'];
        
        User objUser = new User(
            LastName = 'Te',
            FirstName ='testing',
            alias = 'testu'+'testing',
            Email = 'test@unitingambitionn.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            ContactId = objContact.Id,
            UserName='test@unitingambitions.com',
            EmployeeNumber ='EP134'
        );
        
        Test.startTest();
        OwnerUpdateForProfessor_batch owner = new OwnerUpdateForProfessor_batch();
        DataBase.executeBatch(owner);
        Test.stopTest();
        system.assertEquals(objContact.Employee_Number__c, 'EP134');
    } 
}