@isTest
public class LMS_ClassAdjustmentTriggerHandler_Test 
{
    public static testmethod void TriggerMethod()
    {
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
      /*  User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser)
        {*/
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
            
            Profile objProfile = [SELECT Id FROM Profile WHERE Name='Student Portal Profile'];
            User objUser = new User();
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
            
            Leave_Request__c objLR = new Leave_Request__c(); 
            objLR.From_Date__c = system.today();
            objLR.To_Date__c = system.today()+2;
            objLR.Leave_Request_Status__c = 'Submitted';
            objLR.HCM_Leave_Record_ID__c = '1234dets';            
            insert objLr;            
            
            Class_Adjustment__c objClAdj = new Class_Adjustment__c(); 
            objClAdj.From_Date__c = system.today()+5;
            objClAdj.To_Date__c = system.today()+7;
            objClAdj.Leave_Request__c = objLr.Id;
            objClAdj.Status__c = 'Submitted';
            objClAdj.Requested_Professor__c = objUser.Id;            
            insert objClAdj;
            
            map<id,Class_Adjustment__c> map_adj = new map<id,Class_Adjustment__c>();  
            map_adj.put(objClAdj.id,objClAdj);
             //objClAdj.Status__c = 'Approved';
            objClAdj.Status__c = 'Rejected';
            update objClAdj;
            
            list<Class_Adjustment__c> lst_adj = new list<Class_Adjustment__c>();
            lst_adj.add(objClAdj);
                
            test.starttest();
            SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
            Test.setMock(HttpCalloutMock.class,TestMock);
            LMS_ClassAdjustmentTriggerHandler.updateClassAdjustment(lst_adj,map_adj);
            test.stoptest();
           // system.assertEquals('Rejected', objClAdj.Status__c);
          }
     //  }
  }