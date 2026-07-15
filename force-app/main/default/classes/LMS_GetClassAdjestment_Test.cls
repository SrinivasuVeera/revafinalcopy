@isTest
public class LMS_GetClassAdjestment_Test 
{
    public static testmethod void LMS_GetClassAdjestmentmethod()
    {
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser)
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
            
            LMS_GetClassAdjestment.Adjustmentwrapper adjWrpr = new LMS_GetClassAdjestment.Adjustmentwrapper();
            adjWrpr.Name = objClAdj.Name;
            adjWrpr.Id = objClAdj.Id;
            adjWrpr.Status = objClAdj.Status__c;
            adjWrpr.LeaveReqName = objLr.Name;
            adjWrpr.Hcmid = objLr.HCM_Leave_Record_ID__c;
            
            list<LMS_GetClassAdjestment.Adjustmentwrapper> lst_adjWrpr = new list<LMS_GetClassAdjestment.Adjustmentwrapper>();
            lst_adjWrpr.add(adjWrpr); 
            
            LMS_GetClassAdjestment.ReqWrapper reqwrap  = new LMS_GetClassAdjestment.ReqWrapper();
            reqwrap.Details = lst_adjWrpr;
            
            LMS_GetClassAdjestment.GetRequest getreq = new LMS_GetClassAdjestment.GetRequest();
            getreq.leaveRecordId = '1234dets';
            
            string jsondata = JSON.serialize(getreq);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/GetClassAdjustment'; //Request URL
            req.requestBody = Blob.valueof(jsondata);
            req.httpMethod = 'POST';
            
            RestContext.request = req;
            RestContext.response= res;
            
            Test.startTest();       
            LMS_GetClassAdjestment.GetLeaveRequest();        
            Test.stopTest();  
            system.assertEquals('1234dets', getreq.leaveRecordId);
        } 
    }
}