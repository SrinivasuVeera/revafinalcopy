@IsTest(SeeAllData=true)
public class ALU_AlumniActivitiesEmailAlrt_Batch_Test 
{
    public static testMethod void Method1()
    {
        User Admin = [SELECT Id, Profile.Name, Email FROM User WHERE IsActive = true AND Profile.Name = 'Alumni Portal' limit 1];
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
       Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
        //objcon.hed__WorkEmail__c='123@reva.edu.in';
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
        
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Achievements').getRecordTypeId();
        Alumni_Activities__c objAluminActivities= ALU_TestDataFactory.createAlumniActivities(objcon.id);
        objAluminActivities.Date__c = system.today()+1;
        objAluminActivities.Approved_by_Admin__c = true;
        objAluminActivities.Email_Sent__c = false;
        objAluminActivities.Contact__c = objcon.id;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType;
        insert objAluminActivities;
     
        test.starttest();
                Database.executeBatch(new ALU_AlumniActivitiesEmailAlert_Batch(),1);
		test.stoptest();

    }
    public static testMethod void Method2()
    {
        User Admin = [SELECT Id, Profile.Name, Email FROM User WHERE IsActive = true AND Profile.Name = 'Alumni Portal' limit 1];
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
       Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
        //objcon.hed__WorkEmail__c='123@reva.edu.in';
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
        
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Blogs').getRecordTypeId();
        Alumni_Activities__c objAluminActivities= ALU_TestDataFactory.createAlumniActivities(objcon.id);
        objAluminActivities.Date__c = system.today()+1;
        objAluminActivities.Approved_by_Admin__c = true;
        objAluminActivities.Email_Sent__c = false;
        objAluminActivities.Contact__c = objcon.id;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType;
        insert objAluminActivities;
     
        test.starttest();
        Database.executeBatch(new ALU_AlumniActivitiesEmailAlert_Batch(),1);
		test.stoptest();

    }
     public static testMethod void Method3()
    {
        User Admin = [SELECT Id, Profile.Name, Email FROM User WHERE IsActive = true AND Profile.Name = 'Alumni Portal' limit 1];
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
       Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
        //objcon.hed__WorkEmail__c='123@reva.edu.in';
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
        
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Job Posting').getRecordTypeId();
        Alumni_Activities__c objAluminActivities= ALU_TestDataFactory.createAlumniActivities(objcon.id);
        objAluminActivities.Date__c = system.today()+1;
        objAluminActivities.Approved_by_Admin__c = true;
        objAluminActivities.Email_Sent__c = false;
        objAluminActivities.Contact__c = objcon.id;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType;
        insert objAluminActivities;
     
        test.starttest();
        Database.executeBatch(new ALU_AlumniActivitiesEmailAlert_Batch(),1);
		test.stoptest();

    }
     public static testMethod void Method4()
    {
        User Admin = [SELECT Id, Profile.Name, Email FROM User WHERE IsActive = true AND Profile.Name = 'Alumni Portal' limit 1];
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
       Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
        //objcon.hed__WorkEmail__c='123@reva.edu.in';
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
        objAluminActivities.Approved_by_Admin__c = true;
        objAluminActivities.Email_Sent__c = false;
        objAluminActivities.Contact__c = objcon.id;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType;
        insert objAluminActivities;
     
        test.starttest();
        Database.executeBatch(new ALU_AlumniActivitiesEmailAlert_Batch(),1);
		test.stoptest();

    }
}