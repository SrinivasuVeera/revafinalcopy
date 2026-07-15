@isTest
public class ALU_EventRegistrationCmp_Ctrl_Test 
{
    public static testMethod void EventRegistrationMethod()
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
        Alumni_Activities__c objAluminActivities= ALU_TestDataFactory.createAlumniActivities(objcon.id);
        objAluminActivities.Date__c = system.today()+1;
        objAluminActivities.Contact__c = objcon.id;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType;
        insert objAluminActivities;
        
        Alumni_Event_Registrations__c objAluEventRegst = ALU_TestDataFactory.createAlumniEventReg(objcon.id, objAluminActivities.Id);
        objAluEventRegst.Contact__c = objcon.id;
        objAluEventRegst.Alumni_Activities_Event__c = objAluminActivities.id;
        insert objAluEventRegst;  
        
        List<Alumni_Event_Registrations__c> lstAlumniEventReg = new List<Alumni_Event_Registrations__c>();
        lstAlumniEventReg.add(objAluEventRegst);
        
        test.starttest();
        ALU_EventRegistrationCmp_Ctrl.getEventDetails();
        ALU_EventRegistrationCmp_Ctrl.sibmitedRegistration(objAluminActivities.id);
        ALU_EventRegistrationCmp_Ctrl.cancleRegistration(objAluminActivities.id);
        ALU_EventRegistrationCmp_Ctrl.GetDocument(objAluminActivities.id);
        test.stoptest();
        //system.assertEquals(objcourseSch.id, objcourseSch.id);     
    }
}