@isTest
public class REVA_ContactDetailsCtrl_Test
{
    public static testMethod Void Method()
    {  
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        adminUser.UserRoleId = userRole.Id;
        adminUser.IsActive=true;
        update adminUser;
        
        User objUser = new User();
        
        System.runAs(adminUser)
        {
            Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId(); 
            Id accRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            Id accRecTypeId3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(); 
            
            Account Acc2=STOB_TestDataFactory.CreateAccount('REVA Test College');
            Acc2.RecordTypeId=accRecTypeId3;
            insert Acc2;
            
            Account Acc1=STOB_TestDataFactory.CreateAccount('REVA Engineering College');
            Acc1.RecordTypeId=accRecTypeId2;
            Acc1.Intake__c=1;
            Acc1.Intake_Per_Section__c=8;
            Acc1.Number_of_Batches__c=2;
            Acc1.Number_of_Semesters__c=2;
            Acc1.Program_Alias__c='1234AVC';
            Acc1.Program_Alias__c='AVCFD';
            Acc1.Program_Type__c='PG';
            insert Acc1;
            
            Account Acc=STOB_TestDataFactory.CreateAccount('REVA Mechanical College');
            Acc.RecordTypeId=accRecTypeId;
            Acc.Intake__c=2;
            Acc.Intake_Per_Section__c=10;
            Acc.Number_of_Batches__c=1;
            Acc.Number_of_Semesters__c=1;
            Acc.Program_Alias__c='12AVC';
            Acc.Program_Alias__c='AVC';
            Acc.Program_Type__c='PG';
            Acc.ParentId=Acc1.id;
            insert Acc;        
            
            hed__Program_Plan__c Prgmbtch=new hed__Program_Plan__c();
            Prgmbtch.Name='Batch 1';
            Prgmbtch.hed__Start_Date__c=system.today()-10;
            Prgmbtch.hed__End_Date__c=system.today()+10;
            Prgmbtch.hed__Account__c=Acc.id;
            insert Prgmbtch;
            
            Id accRecTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            contact con=new Contact();
            con.Lastname='Test';
            con.Enrollment_Type__c='Regular Entry';
            con.hed__Gender__c='Male';
            con.Application_Number__c='123';
            con.MobilePhone='9393949785';
            con.Primary_Academic_Program__c=Acc.id;
            con.Program_Batch__c=Prgmbtch.id;
            con.Quota__c='Management Quota';
            con.AccountId =Acc1.id;
            con.School__c=Acc1.id;
            con.RecordTypeId=accRecTypeId1;
            con.hed__WorkEmail__c='123@reva.edu.in';
            con.Nationality__c='Indian';
            con.AccountId=Acc2.id;
            insert con; 
            
            Profile objProfile = [SELECT Id FROM Profile WHERE Name='Student Portal Profile'];
            
            objUser.LastName = 'Test User';
            objUser.Alias = 'standt';
            objUser.email='TestUserCityHead@testorg.com';
            objUser.EmailEncodingKey='UTF-8';
            objUser.LanguageLocaleKey='en_US';
            objUser.LocaleSidKey='en_US';
            objUser.TimeZoneSidKey='America/Los_Angeles';
            objUser.username='TestUserCityHead@testorg.com';
            objUser.ProfileId = objProfile.Id;
            objUser.ContactId=con.id;     
            objUser.isActive=true;                   
            insert objUser; 
            
            Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria; 
            
            Student_Fee__c objStudentFee1 = new Student_Fee__c();
            objStudentFee1.Amount__c = 50000;
            objStudentFee1.Amount_Pending__c=10000;
            objStudentFee1.Amount_Paid__c=50000;
            objStudentFee1.Contact__c = con.id;
            objStudentFee1.Due_Date__c = system.today() - 1;
            objStudentFee1.Fee_Type__c = 'Tuition Fee';
            Insert objStudentFee1;   
            
            Professor_Student_Course_Preference__c objProfStu = new Professor_Student_Course_Preference__c();
            objProfStu.name = 'test';
            insert objProfStu;       
        }
        system.runAs(objUser)
        {
            Test.startTest();
            REVA_ContactDetailsCtrl.fetchContact();
            Test.stopTest();
        }        
    }       
}