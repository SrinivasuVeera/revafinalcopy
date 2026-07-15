@Istest
public class REVA_CaseTrigger_Handler_Test 
{
    public static testmethod void CaseTrigger()
    {
        Account objAccount = new Account();
        objAccount.Name = 'Name';
        insert objAccount;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
        objContact.AccountId = objAccount.id;
         objContact.Personal_Email__c = 'test@reva.edu.in';
        objContact.hed__Preferred_Email__c = 'Personal Email';
        insert objContact;
        
        Case objCase = new Case();
        objCase.ContactId = objContact.id;
        insert objCase;
        
        system.assertequals(objCase.id,objCase.id);
        
    }
}