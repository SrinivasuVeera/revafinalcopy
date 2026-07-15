@isTest
public class AutoApproveClassAdjustmentBatchTest {
    
    @isTest
    static void testAutoApproveBatch() {
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
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User objUser = new User();
        objUser.LastName = 'Test User';
        objUser.Alias = 'standt';
        objUser.email='TestUserCityHead@testorg.com';
        objUser.EmailEncodingKey='UTF-8';
        objUser.LanguageLocaleKey='en_US';
        objUser.LocaleSidKey='en_US';
        objUser.TimeZoneSidKey='America/Los_Angeles';
        objUser.username='TestUserCityHead@testorg.com';
        objUser.ProfileId = testProfile.Id;
        objUser.isactive=true;                        
        insert objUser;
        // Create School (Parent Account)
        Account school = new Account(Name = 'Science School', RecordTypeId = '0125j000000uuRnAAI');
        insert school;
        
        //Create Department (Child Account)
        Account department = new Account(Name = 'Physics Department', ParentId = school.Id);
        insert department;
        hed__Course__c course = createCourse('Physics', school);
        //  Create Course, Term, and Offering
        hed__Term__c term = new hed__Term__c(Name = 'Winter 2025', hed__Account__c = department.Id);
        insert term;
        
        hed__Course_Offering__c offering = new hed__Course_Offering__c(
            Name = 'Quantum Physics Offering',
            hed__Course__c = course.Id,
            hed__Term__c = term.Id
            // Offered_By_School__c = school.Id
        );
        insert offering;
        // Create Schedule (with Completed request)
        hed__Course_Offering_Schedule__c schedule = new hed__Course_Offering_Schedule__c(
            Date__c = Date.today(),
            hed__Course_Offering__c = offering.Id,
            Room_Change_Request__c = 'Completed',
            School_Head__c =objUser.Id,
            Section__c = term.Id
        );
        insert schedule;
                
        Class_Adjustment__c ca = new Class_Adjustment__c(
            From_Date__c = system.today()+5,
            To_Date__c = system.today()+7,
            Status__c = 'Submitted',
            Requested_Professor__c = objUser.Id,
            professor__c = objUser.Id,
            Course_Offering_Schedule__c = schedule.Id
        );
        insert ca;

        hed__Course_Offering_Schedule__c schedule2 = new hed__Course_Offering_Schedule__c(
            hed__Course_Offering__c = offering.Id,
            Room_Change_Request__c = 'Completed',
            School_Head__c =objUser.Id,
            Section__c = term.Id,
            Date__c = Date.today().addDays(-1),
            hed__Start_Time__c = Time.newInstance(14, 00, 0, 0),
            hed__End_Time__c   = Time.newInstance(15, 00, 0, 0),
            Class_adjusted_schedule__c = true
        );
        insert schedule2;
        
          Class_Adjustment__c a1 = new Class_Adjustment__c(
            Professor__c = objUser.Id,
            Requested_Professor__c = objUser.Id,
            Course_Offering_Schedule__c = schedule2.Id
        );

           insert a1;
        
        Test.startTest(); 
         String cronExp = '0 0 1 * * ?'; // Daily 1 AM
        AutoApproveClassAdjustmentschedule sched = new AutoApproveClassAdjustmentschedule();
        System.schedule('ClassAdjustmentAutoApproveScheduler', cronExp, sched);
        
        SchoolheadNotificationsSchedule sched1 = new SchoolheadNotificationsSchedule();
        System.schedule('SchoolHeadNotifications', cronExp, sched1);
        // 3. Execute batch only AFTER approval submission
        AutoApproveClassAdjustmentBatch batchObj = new AutoApproveClassAdjustmentBatch();
        Database.executeBatch(batchObj, 50);
        
        SchoolheadNotificationsBatch batchObj1 = new SchoolheadNotificationsBatch();
            Database.executeBatch(batchObj1, 200);
        Test.stopTest();  
    }
    
      private static hed__Course__c createCourse(String name, Account school) {
    hed__Course__c course = new hed__Course__c(
        Name = name,
        hed__Account__c = school.Id,
        Credits__c = 4.0, // Decimal (2,1)
        Offered_By_School__c = school.Id, // Lookup
        Credit_Hours__c = 60.000, // Decimal (3,3)
        Maximum_External_Marks__c = 70, // Number
        Total_Maximum_Marks_IA_External__c = 100, // Number
        hed__Course_ID__c ='R45rt6',Seminar_Maximum_Marks__c = 10.0,
        HardCore_Sub_Type__c = 'Theory',Quiz_Maximum_Marks__c=6.8,
        Category__c ='Hardcore Course',Results_Max_Marks__c =12.9,
        L_T_P__c = '1:0:0',Theory_Maximum_Marks__c= 15.0,
        No_of_IA_s__c = '2',Continuous_Learning_Max_Marks__c =10.9
    );
    insert course;
    return course;
}
}