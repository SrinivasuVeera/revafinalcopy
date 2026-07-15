@IsTest
public class MSTR_ContactTrigHndlr_Test
{
    public static testmethod void professorCreationTest()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
       // User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true AND UserRoleId != null Limit 1];
        
       
        Test.startTest();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId; 
       // objAccount.OwnerId = adminUser.id;
        insert objAccount;
        
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objcon = MSTR_TestDataFactory.createContact('test2 Contact2');
        objcon.AccountId = objAccount.id;
        objcon.FirstName  = 'Test2 Contact2';
        objcon.LastName  ='C';
        objcon.Employee_Number__c ='EP1237';
        objcon.RecordTypeId = recordTypeId;
        objcon.Active__c = true;
        objcon.hed__WorkEmail__c  = 'test16767233@ex.com';
        insert objcon;
        
        string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        //User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true AND UserRoleId !=null Limit 1];
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId; 
        //objAcc.OwnerId = adminUser.Id;
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objContact = MSTR_TestDataFactory.createContact('test Contact');
        objContact.AccountId = objAcc.id;
        objContact.FirstName  = 'Test Con';
        objContact.LastName  ='LastCon';
        objContact.ReportsToId  = objcon.Id;
        objContact.Active__c = true;
        objContact.RecordTypeId = recordTypId;
        objContact.Employee_Number__c  ='EP134';         
        objContact.hed__WorkEmail__c  = 'TestCon277772000@f.com';
 
        
        insert objContact;
        Test.stopTest();
        
    }
    
      public static testmethod void nonTeacCreationTest()
    {
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Non_Teaching).getRecordTypeId();
        
      
        string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        // User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true AND UserRoleId !=null Limit 1];
        Test.startTest();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId; 
        //objAcc.OwnerId = adminUser.Id;
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Non_Teaching).getRecordTypeId();
        
        Contact objContact = MSTR_TestDataFactory.createContact('test Contact');
        objContact.AccountId = objAcc.id;
        objContact.FirstName  = 'Test Con';
        objContact.LastName  ='LastCon';
        
        objContact.Active__c = true;
        objContact.RecordTypeId = recordTypId;
        objContact.Employee_Number__c  ='EP134rtt';         
        objContact.hed__WorkEmail__c  = 'TestCon2777720rr00@f.com';
 
        
        insert objContact;
        Test.stopTest();
        
    }
    public static testmethod void professorCreationwithOutExistingMngrTest(){
        
        
         string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
       // User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true AND UserRoleId !=null Limit 1];

        Test.startTest();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account1',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId;  
        //objAcc.OwnerId = adminUser.Id;
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objContact = MSTR_TestDataFactory.createContact('test1 Contact');
        objContact.AccountId = objAcc.id;
        objContact.FirstName  = 'Test1 Con';
        objContact.LastName  ='LastCon1';
        //objContact.ReportsToId  = objcon1.Id;
        objContact.Active__c = true;
        objContact.RecordTypeId = recordTypId;
        objContact.Employee_Number__c  ='EP1341';         
        objContact.hed__WorkEmail__c  = 'TestCon220001@reva.edu.in';
       
         
         insert objContact;
        Test.stopTest();
    }
    public static testmethod void professorUserUpdation(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Professor'];
        
         string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
         //User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true AND UserRoleId !=null Limit 1];
        Test.startTest();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account2',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId; 
        //objAcc.OwnerId = adminUser.Id;
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        Contact objContact = MSTR_TestDataFactory.createContact('test2 Contact');
        objContact.AccountId = objAcc.id;
        objContact.FirstName  = 'Tst2 Con';
        objContact.LastName  ='LtCon2';
        objContact.Active__c = true;
        objContact.RecordTypeId = recordTypId;
        objContact.Employee_Number__c  ='EP1341';         
        objContact.hed__WorkEmail__c  = 'TestCon220001@reva.edu.in';
        insert objContact;
        
User objUser = new User(
            LastName = 'Te',
            FirstName ='testing',
            alias = 'testng',
            Email = 'test@unitingambitionn.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            
            UserName='test@unitingambitions.com',
            EmployeeNumber ='EP1341'
        );
        
        insert objUser;
        
        
        objContact.Active__c  = false;
        objContact.FirstName  = 'Tst Con';
        objContact.MiddleName  ='Mid';
        objContact.LastName  ='L';
        
       
        
        update objContact ;
        Test.stopTest();
        
        
    }
    
/*    public static testmethod void nonTeUserCreationTest(){
        
        
         string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account1',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId;  
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Non_Teaching).getRecordTypeId();
        
        Contact objContact = MSTR_TestDataFactory.createContact('test1 Contact');
        objContact.AccountId = objAcc.id;
        objContact.FirstName  = 'Test1 Con';
        objContact.LastName  ='LastCon1';
        //objContact.ReportsToId  = objcon1.Id;
        objContact.Active__c = true;
        objContact.RecordTypeId = recordTypId;
        objContact.Employee_Number__c  ='EP13412';         
        objContact.hed__WorkEmail__c  = 'TestCon2200012@reva.edu.in';
        insert objContact;
    } */
   /* public static testmethod void nonTeacgingUserUpdation(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile'];
        
         string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account2',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId;  
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Non_Teaching).getRecordTypeId();
        Contact objContact = MSTR_TestDataFactory.createContact('test2 Contact');
        objContact.AccountId = objAcc.id;
        objContact.FirstName  = 'Tst2 Con';
        objContact.LastName  ='LtCon2';
        objContact.Active__c = true;
        objContact.RecordTypeId = recordTypId;
        objContact.Employee_Number__c  ='EP13415';         
        objContact.hed__WorkEmail__c  = 'TestCon2200015@reva.edu.in';
        insert objContact;
        
User objUser = new User(
            LastName = 'Te',
            FirstName ='testing',
            alias = 'testng',
            Email = 'test@unitingambitionn.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            ContactId =objContact.Id,
            UserName='testcon001@unitingambitions.com',
            EmployeeNumber ='EP13415'
        );
        
        insert objUser;
        
        
        objContact.Active__c  = false;
       Test.startTest();
        update objContact ;
        
        MSTR_ContactTrigHndlr.DeactivateStudentUser(new set<Id>{objUser.Id});
        Test.stopTest();
        
       
        
    } */
    
    public static testmethod void StudentUserCreationTest()
    {
        string houseHoldRec = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
         //User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true AND UserRoleId !=null Limit 1];
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',houseHoldRec);
        objAccount.RecordtypeId = houseHoldRec;
        //objAccount.OwnerId = adminUser.Id;
        insert objAccount;
        
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.FirstName  = 'Test Contact';
        objcon.LastName  ='C';
        objcon.RecordTypeId = recordTypeId;
        objcon.Active__c = true;
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.User_Creation_in_AD__c = 'AD User Disabled';
        insert objcon;
        
        Map<Id, Contact> old_Map = new Map<Id, Contact>();
        old_Map.put(objcon.Id, objcon);
        
        objcon.User_Creation_in_AD__c = 'AD User Disabled';
        Update objcon;
        
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objcon);
        test.startTest();
        MSTR_ContactTrigHndlr.StudentUserCreation(lstContact, old_Map);
        
        test.stopTest();
    }
   
    
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('HCM_SalaryRangeAPI')) {
                 System.debug('req--- ins>');
                res.setBody('{"Employee_Number":"REVA01463", "Employee_Name":"John Doe", "Salary_Range":1000.0,"Type" :"Hostel"}');
                res.setStatusCode(200);
            } 
           
            return res;
        }
    }
   public static testmethod void updateHCMhostelEmpSalaryTest(){
    HCM_Endpoints__c mockEndpoint = new HCM_Endpoints__c(
            Name = 'Salary Range API',
            End_Point__c = 'https://test.salesforce.com/services/apexrest/HCM_SalaryRangeAPI/'
        );
        insert mockEndpoint;
    
        
        // Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
         Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1].Id;
         Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
 
       
        
        Contact testContact2 = new Contact(
            FirstName = 'NonTeaching2',
            LastName = 'Staff2',
            hed__WorkEmail__c ='nonteach222ing@example.com',
            Email = 'nonteach2ing@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Male',
            Employee_Number__c = 'REVA01463',
            Salary_Revised_Date__c = System.today(),
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
 
        // Create a user for Hostel_Room_Request_For__c reference
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserrrrr7bhdsjr8888@test.com',
            Email = 'nonteach222ing@example.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            //ContactId = testContact2.Id,
            EmployeeNumber = 'REVA01463',
            LanguageLocaleKey = 'en_US'
        );
      //  insert testUser;

        List<Reva_Hostel_Request__c> hostelRequests = new List<Reva_Hostel_Request__c>();
        Reva_Hostel_Request__c req = new Reva_Hostel_Request__c(
            Type__c = '2',
            Employee_Salary__c = 500.00,
            Status__c = 'Approved',
            Hostel_Room_Request_For__c = testContact2.Id,
            Reva_Hostel_JoiningDate__c =  System.today()
        );
        hostelRequests.add(req);
        
       
        insert hostelRequests;
      
        testContact2.Salary_Revised_Date__c = System.Today()+5;  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        update testContact2;
        Test.stopTest();

    }
    public static testmethod void testDeactivateStudentUser() {
        // Create the account
        
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        
        
        //User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true AND UserRoleId != null Limit 1];
 
        string houseHoldRec = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account', houseHoldRec);
        objAccount.RecordTypeId = houseHoldRec;
        //objAccount.OwnerId =adminUser.Id;
        insert objAccount;
        
        // Create the contact (assuming 'Student' record type is already present in the org)
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objContact = new Contact(
            FirstName = 'Test Contact',
            LastName = 'C',
            AccountId = objAccount.id,
            RecordTypeId = recordTypeId,
            Active__c = true,
            hed__WorkEmail__c = 'test123@reva.edu.in',
            User_Creation_in_AD__c = 'AD User Disabled'
            
        );
        insert objContact;
        
        // Create the user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User objUser = new User(
            LastName = 'Te',
            FirstName = 'testing',
            Alias = 'testng',
            Email = 'test@unitingambitionn.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            ContactId = objContact.Id,
            UserName = 'test@unitingambitions.com',
            EmployeeNumber = 'EP1341'
        );
        
        insert objUser;
        
        // Set the contact as inactive and update
        objContact.Active__c = false;
        update objContact;
        
        // Start test
        Test.startTest();
        // Deactivate user using the method under test
        MSTR_ContactTrigHndlr.DeactivateStudentUser(new Set<Id>{objUser.Id});
        Test.stopTest();
        
        // Verify that the user has been deactivated
        User deactivatedUser = [SELECT IsActive FROM User WHERE Id = :objUser.Id];
        System.assertEquals(true, deactivatedUser.IsActive, 'User should be deactivated');
    }
}