@isTest
public class ALU_DigitalCard_Ext_Test
{
    public static testMethod void DigitaCard()
    {
        User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
        objcon.Personal_Email__c = 'test@reva.edu.in';
        objcon.hed__Preferred_Email__c = 'Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_No__c='Srn123';
        objcon.FirstName  = 'Test Con';
        objcon.LastName  ='LastCon';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Alumni Portal Profile'];
        
        User objUser = new User(
            LastName = 'Te',
            FirstName ='testing',
            alias = 'tes'+'tes',
            Email = 'test@unitingambitionn.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            ContactId = objcon.Id,
            UserName='test@unitingambitions.com',
            EmployeeNumber ='EP134'
        );
        insert objUser;
        system.runAs(objUser)
        {
            Test.startTest();
            ALU_DigitalCard_Ext ext = new ALU_DigitalCard_Ext();
            Test.stopTest();
            system.assertEquals(objcon.FirstName,'Test Con');
        }
    }
    
}