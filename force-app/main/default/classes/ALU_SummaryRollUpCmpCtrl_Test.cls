@isTest
public class ALU_SummaryRollUpCmpCtrl_Test 
{
    public static testMethod void SummaryRollUp()
    {
        User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
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
        insert objcon;
        
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
        Id Alumni_Activities_Event_RecType1 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Job Posting').getRecordTypeId();
        Id Alumni_Activities_Event_RecType2 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Job Seeking').getRecordTypeId();
        Id Alumni_Activities_Event_RecType3= Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Fund Raising Request').getRecordTypeId();
        Id Alumni_Activities_Event_RecType4 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Achievements').getRecordTypeId();
        Alumni_Activities__c objAluminActivities= ALU_TestDataFactory.createAlumniActivities(objcon.id);
        objAluminActivities.Date__c = system.today()+1;
        objAluminActivities.Contact__c = objcon.id;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType1;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType2;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType3;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType4;
        objAluminActivities.Approved_by_Admin__c = true;
        objAluminActivities.Date__c = system.today();
        insert objAluminActivities;
        
        Id Alumni_Activities_Event_RecType5 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
        Alumni_Activities__c objAluminActivities1= ALU_TestDataFactory.createAlumniActivities(objcon.id);
        objAluminActivities1.Date__c = system.today();
        objAluminActivities1.RecordTypeId = Alumni_Activities_Event_RecType5;
        Insert objAluminActivities1;
        
        Alumni_Event_Registrations__c objAluEventRegst = ALU_TestDataFactory.createAlumniEventReg(objcon.id, objAluminActivities.Id);
        objAluEventRegst.Alumni_Activities_Event__c = objAluminActivities1.id;
        insert objAluEventRegst;  
        
        Alumni_Payments__c objAluPayments = ALU_TestDataFactory.createPayments(objcon.id);
        objAluPayments.Amount__c = 2000;
        insert objAluPayments;
        
        test.starttest();
        ALU_SummaryRollUpCmp_Ctrl.getMethod1();
        test.stoptest();
    }
}