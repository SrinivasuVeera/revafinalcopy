@isTest
private class AutocreatedRegHandler1682058407492_Test
{
    static testMethod void testCreateAndUpdateUser()
    {
        
        AutocreatedRegHandler1682058407492 handler = new AutocreatedRegHandler1682058407492 ();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        try
        {
            User u = handler.createUser(null, sampleData);
            
            // insert(u);
            //String uid = u.id;
            
            sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                           'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                           null, new Map<String, String>{});
            handler.updateUser(null, null, sampleData);
            
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
            objAccount.Name = 'test';
            insert objAccount;
            
            string UniversityRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAccount1 = ALU_TestDataFactory.CreateAccount('Test Account2',UniversityRecId1);
            objAccount1.id = objAccount.id;
            insert objAccount1;
            
            Contact objcon = ALU_TestDataFactory.createContact('test Contact');
            objcon.AccountId = objAccount1.id;
            objcon.Professor_Across_Schools__c = true;
            objcon.Application_Number__c = '123';
            objcon.Personal_Email__c = 'test@reva.edu.in';
            objcon.hed__Preferred_Email__c = 'Personal Email';
            objcon.MobilePhone ='8963210547';
            objcon.SRN_Number__c='Srn123';
            objcon.Nationality__c = 'Indian';
            objcon.Aadhar_Card_Number__c ='368845632147'; 
            objcon.PAN_Number__c ='HRAPO4561D';
            objcon.ownerid = userinfo.getUserId();
            insert objcon;
        }
        catch(Exception e)
        {
            
        }
        // User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
        
    }
}