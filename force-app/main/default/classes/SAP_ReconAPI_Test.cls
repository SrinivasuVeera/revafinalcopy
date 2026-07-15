@isTest
public class SAP_ReconAPI_Test 
{
    @isTest
    public static void SAPReconAPI()
    {
        User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser; 
        
        User objUser = new User();
        Contact objcon = new Contact();
        System.runAs(adminUser)
        {
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
            objAccount.RecordtypeId = UniversityRecId;  
            insert objAccount;
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            objcon = ALU_TestDataFactory.createContact('test Contact');
            objcon.AccountId = objAccount.id;
            objcon.Professor_Across_Schools__c = true;
            objcon.Application_Number__c = '123'; 
            objcon.Personal_Email__c = 'test@reva.edu.in';
            objcon.hed__Preferred_Email__c = 'Personal Email';
            objcon.MobilePhone ='8963210547';
            objcon.SRN_Number__c='Srn123';
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.Nationality__c = 'Indian';
            objcon.Aadhar_Card_Number__c ='368845632147'; 
            objcon.PAN_Number__c ='HRAPO4561D';
            objcon.ownerid = userinfo.getUserId();
            //objcon.Position_of_Student__c = 'Placed';
            objcon.Placement__c = 'On-Campus';
            objcon.Company__c = 'ttesting';
            objcon.Designation__c = 'ttt';
            objcon.Location__c = 'banglore';
            objcon.Date_of_Joining__c = system.today();
            objcon.Joining_REVA__c = 'yes';
            objcon.Which_Program__c = 'B.tech';
            objcon.University_Name__c = 'college';
            objcon.Date_of_Joining_HS__c = system.today();
            objcon.Country_HS__c = 'india';
            objcon.Location_HS__c = 'pune';
            objcon.Firm_Name__c = 'University';
            objcon.Started__c = 'yes';
            objcon.Designation_SU__c = 'executive';
            objcon.Location_SU__c = 'Karnataka';
            objcon.Type_of_Business__c = 'xxx';
            objcon.Location_B__c = 'yyy';
            objcon.Type_of_Job_Targeting__c = 'business';
            objcon.Coaching_required_from_REVA_University__c = 'yes';
            objcon.Others__c = 'ttesting';
            insert objcon;
            
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
            objUser.ContactId=objcon.id;                        
            insert objUser;
            
            Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            Student_Fee__c objStudntFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); 
            objStudntFee.Amount__c = 50000;
            objStudntFee.Amount_Pending__c=2;
            objStudntFee.Session__c = 'Testing';
            objStudntFee.Scholarship__c = 2000;
            objStudntFee.Amount_Paid__c=10000;
            objStudntFee.Premium__c = 20099;
            objStudntFee.Concession__c = 500;
            objStudntFee.Number_of_Installments__c =3;
            objStudntFee.Paid_Installments__c =1;
            objStudntFee.Actual_Program_Fee__c = 70000;
            objStudntFee.Exam_Application_Number__c = '1234555';
            objStudntFee.Reconciliation_Completed__c = true;
            objStudntFee.Due_Date__c = system.today().addDays(-1);
            insert objStudntFee;
            
            Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
            objStuPayment.Payment_Status__c ='Success';
            objStuPayment.fee_type__c= 'Application Fee';
            objStuPayment.Payment_Gateway__c = 'Billdesk';
            objStuPayment.Reference_Id__c = '1234';
            insert objStuPayment;
            
            Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudntFee.id,objStuPayment.id);
            objStuFeePay.Line_Item_Payment_Status__c ='Payment Link Created';
            objStuFeePay.Amount__c = 100000;
            objStuFeePay.Reference_Id__c = '1234';
            insert objStuFeePay;
            
            SAP_ReconAPI.Payment wrapPayment = new SAP_ReconAPI.Payment();
            wrapPayment.PaymentId = objStuFeePay.id;
            wrapPayment.Amount =   objStuFeePay.Amount__c;
            wrapPayment.Application_Number = objStudntFee.id;
            
            List<SAP_ReconAPI.Payment> lst_payment = new List<SAP_ReconAPI.Payment>();
            lst_payment.add(wrapPayment);
            
            List<id> list_studentfee = new List<id>();
            list_studentfee.add(objStudntFee.id);
            
            Debug_Log__c objdebuglog = new Debug_Log__c();
            objdebuglog.Student_Fee__c = objStudntFee.id;
            objdebuglog.Response__c = 'testing';
            objdebuglog.Status__c = 'Success';
            objdebuglog.Status_Code__c = 0;
            objdebuglog.Request__c = 'Test1';
            insert objdebuglog;
            
            List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
            lst_DbLogs.add(objdebuglog);
            
            List<Contact> list_Con = new List<Contact>();
            list_Con.add(objcon);
            
            update objcon;
            
            system.runAs(objUser)
            {
                Test.startTest();
                SAP_ReconAPICalloutMock fakeResponse = new SAP_ReconAPICalloutMock(200,'OK','{"StatusMessage":"Success","StatusCode":0,"ResponseData":[{"StatusMessage":"1","StatusCode":0,"SFDCRecordId":"' + objStudntFee.Id + '","responseObject":"1","ErrorMsg":"Mode of payment Failure","DemandNo":"12347"}]}',null);
                Test.setMock(HttpCalloutMock.class, fakeResponse);
                SAP_ReconAPI.sendSLCMReconciliationRequest(list_studentfee);
                Test.stopTest();
                system.assertEquals(objcon.Joining_REVA__c,'yes');
            }
        } 
    }
    @isTest
    public static void SAPReconAPI1()
    {
        User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser; 
        
        User objUser = new User();
        Contact objcon = new Contact();
        System.runAs(adminUser)
        {
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
            objAccount.RecordtypeId = UniversityRecId;  
            insert objAccount;
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            objcon = ALU_TestDataFactory.createContact('test Contact');
            objcon.AccountId = objAccount.id;
            objcon.Professor_Across_Schools__c = true;
            objcon.Application_Number__c = '123'; 
            objcon.Personal_Email__c = 'test@reva.edu.in';
            objcon.hed__Preferred_Email__c = 'Personal Email';
            objcon.MobilePhone ='8963210547';
            objcon.SRN_Number__c='Srn123';
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.Nationality__c = 'Indian';
            objcon.Aadhar_Card_Number__c ='368845632147'; 
            objcon.PAN_Number__c ='HRAPO4561D';
            objcon.ownerid = userinfo.getUserId();
            //objcon.Position_of_Student__c = 'Placed';
            objcon.Placement__c = 'On-Campus';
            objcon.Company__c = 'ttesting';
            objcon.Designation__c = 'ttt';
            objcon.Location__c = 'banglore';
            objcon.Date_of_Joining__c = system.today();
            objcon.Joining_REVA__c = 'yes';
            objcon.Which_Program__c = 'B.tech';
            objcon.University_Name__c = 'college';
            objcon.Date_of_Joining_HS__c = system.today();
            objcon.Country_HS__c = 'india';
            objcon.Location_HS__c = 'pune';
            objcon.Firm_Name__c = 'University';
            objcon.Started__c = 'yes';
            objcon.Designation_SU__c = 'executive';
            objcon.Location_SU__c = 'Karnataka';
            objcon.Type_of_Business__c = 'xxx';
            objcon.Location_B__c = 'yyy';
            objcon.Type_of_Job_Targeting__c = 'business';
            objcon.Coaching_required_from_REVA_University__c = 'yes';
            objcon.Others__c = 'ttesting';
            insert objcon;
            
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
            objUser.ContactId=objcon.id;                        
            insert objUser;
            
            Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            Student_Fee__c objStudntFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); 
            objStudntFee.Amount__c = 50000;
            objStudntFee.Amount_Pending__c=2;
            objStudntFee.Session__c = 'Testing';
            objStudntFee.Scholarship__c = 2000;
            objStudntFee.Amount_Paid__c=10000;
            objStudntFee.Premium__c = 20099;
            objStudntFee.Concession__c = 500;
            objStudntFee.Number_of_Installments__c =3;
            objStudntFee.Paid_Installments__c =1;
            objStudntFee.Actual_Program_Fee__c = 70000;
            objStudntFee.Exam_Application_Number__c = '1234555';
            objStudntFee.Reconciliation_Completed__c = true;
            objStudntFee.Due_Date__c = system.today().addDays(-1);
            insert objStudntFee;
            
            Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
            objStuPayment.Payment_Status__c ='Success';
            objStuPayment.fee_type__c= 'Application Fee';
            objStuPayment.Payment_Gateway__c = 'Billdesk';
            objStuPayment.Reference_Id__c = '1234';
            insert objStuPayment;
            
            Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudntFee.id,objStuPayment.id);
            objStuFeePay.Line_Item_Payment_Status__c ='Payment Link Created';
            objStuFeePay.Amount__c = 100000;
            objStuFeePay.Reference_Id__c = '1234';
            insert objStuFeePay;
            
            SAP_ReconAPI.Payment wrapPayment = new SAP_ReconAPI.Payment();
            wrapPayment.PaymentId = objStuFeePay.id;
            wrapPayment.Amount =   objStuFeePay.Amount__c;
            wrapPayment.Application_Number = objStudntFee.id;
            
                Debug_Log__c objdebuglog = new Debug_Log__c();
            objdebuglog.Student_Fee__c = objStudntFee.id;
            objdebuglog.Response__c = 'testing';
            objdebuglog.Status__c = 'Success';
            objdebuglog.Status_Code__c = 0;
            objdebuglog.Request__c = 'Test1';
            insert objdebuglog;
                        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
            lst_DbLogs.add(objdebuglog);

            List<SAP_ReconAPI.Payment> lst_payment = new List<SAP_ReconAPI.Payment>();
            lst_payment.add(wrapPayment);
            
            List<id> list_studentfee = new List<id>();
            list_studentfee.add(objStudntFee.id);
            
            List<Contact> list_Con = new List<Contact>();
            list_Con.add(objcon);
            
            update objcon;
            
            system.runAs(objUser)
            {
                Test.startTest();
                SAP_ReconAPICalloutMock fakeResponse = new SAP_ReconAPICalloutMock(200,'OK','{"StatusMessage":"Success","StatusCode":1,"ResponseData":[{"StatusMessage":"1","StatusCode":1,"SFDCRecordId":"' + objStudntFee.Id + '","responseObject":"1","ErrorMsg":"Mode of payment Failure","DemandNo":"12347"}]}',null);
                Test.setMock(HttpCalloutMock.class, fakeResponse);
                SAP_ReconAPI.sendSLCMReconciliationRequest(list_studentfee);
                Test.stopTest();
                system.assertEquals(objcon.Joining_REVA__c,'yes');
            }
        } 
    }
}