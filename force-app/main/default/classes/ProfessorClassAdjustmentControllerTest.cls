@isTest
public class ProfessorClassAdjustmentControllerTest {

    @isTest
    static void testGetSchedulesByEntryDate() {
        // Setup test data
        // Create a user with a Professor profile
        Profile profProfile = [SELECT Id FROM Profile WHERE Name = 'Professor'];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profProfile.Id
        );
        insert testUser;

           Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = testAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
            // Create and insert a Term record
            hed__Term__c sem = new hed__Term__c(Name = 'test', hed__Account__c = testAccount.Id);
            insert sem;
    
            // Create and insert a Course record
        hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('Test Course', testAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        obj_Cour.Category__c = 'Hardcore Course';
        obj_Cour.Credits__c = 3;
        obj_Cour.Offered_By_School__c = testAccount.Id;
        obj_Cour.Credit_Hours__c = 20;
        obj_Cour.L_T_P__c = '2:1:0';
        obj_Cour.No_of_IA_s__c = '1';
        //obj_Cour.Maximum_Internal_Marks__c = 70;
        obj_Cour.Maximum_External_Marks__c = 30;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 85;           
        insert obj_Cour;
    
            // Create and insert a Course Offering record
            hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
                hed__Course__c = obj_Cour.Id,    
                hed__Term__c = sem.Id,
                Name = 'test',
                 Category__c = 'Hardcore Course'
            );
            insert courseOffering;
        
        // Create a course offering schedule
        hed__Course_Offering_Schedule__c schedule1 = new hed__Course_Offering_Schedule__c(
            Date__c = Date.today().addDays(1),
            hed__Start_Time__c = Time.newInstance(9, 0, 0, 0),
            hed__End_Time__c = Time.newInstance(10, 0, 0, 0),
            hed__Course_Offering__c = courseOffering.Id,
            Professor__c = testUser.Id,
            Status__c = 'Scheduled',
            Section__c = sem.Id
        );
        insert schedule1;

        // Create another schedule that should be excluded by the NOT IN subquery
        hed__Course_Offering_Schedule__c schedule2 = new hed__Course_Offering_Schedule__c(
            Date__c = Date.today().addDays(2),
            hed__Start_Time__c = Time.newInstance(11, 0, 0, 0),
            hed__End_Time__c = Time.newInstance(12, 0, 0, 0),
            hed__Course_Offering__c = courseOffering.Id,
            Professor__c = testUser.Id,
            Status__c = 'Scheduled',
            Section__c = sem.Id
        );
        insert schedule2;

        // Create a class adjustment record that excludes schedule2
        class_adjustment__c classAdjustment = new class_adjustment__c(
            Course_Offering_Schedule__c = schedule2.Id
        );
        insert classAdjustment;

        // Test the method
        Test.startTest();
        List<hed__Course_Offering_Schedule__c> result = ProfessorClassAdjustmentController.getSchedulesByEntryDate(
            Date.today(),
            Date.today().addDays(5),
            testUser.Id
        );
        Test.stopTest();

       }
 @isTest
    static void testGetProfessorsBySameSection() {
        // Setup test data

        // Create a user with the "Professor" profile
        Profile profProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profProfile.Id
        );
        insert testUser;

        // Create an account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a semester (Term)
        hed__Term__c sem = new hed__Term__c(Name = 'Section A', hed__Account__c = testAccount.Id);
        insert sem;

        // Create a course
       hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('Test Course', testAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        obj_Cour.Category__c = 'Hardcore Course';
        obj_Cour.Credits__c = 3;
        obj_Cour.Offered_By_School__c = testAccount.Id;
        obj_Cour.Credit_Hours__c = 20;
        obj_Cour.L_T_P__c = '2:1:0';
        obj_Cour.No_of_IA_s__c = '1';
        //obj_Cour.Maximum_Internal_Marks__c = 70;
        obj_Cour.Maximum_External_Marks__c = 30;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 85;   
        insert obj_Cour;

        // Create a course offering
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
            Name = 'Test Course Offering',
            hed__Course__c = obj_Cour.Id,
            hed__Term__c = sem.Id,
            Category__c = 'Hardcore Course'
        );
        insert courseOffering;

        // Create a professor (Contact)
        Contact professor1 = new Contact(
            FirstName = 'Prof',
            LastName = 'One',
            Email = 'prof1@example.com',
            Employee_Number__c = 'E001',
            Active__c = true
        );
        insert professor1;

        Contact professor2 = new Contact(
            FirstName = 'Prof',
            LastName = 'Two',
            Email = 'prof2@example.com',
            Employee_Number__c = 'E002',
            Active__c = true
        );
        insert professor2;

        // Create course enrollments for professors
        hed__Course_Enrollment__c enrollment1 = new hed__Course_Enrollment__c(
            hed__Contact__c = professor1.Id,
            hed__Course_Offering__c = courseOffering.Id,
            Section__c = sem.Id,
            RecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId()
        );
        insert enrollment1;

        hed__Course_Enrollment__c enrollment2 = new hed__Course_Enrollment__c(
            hed__Contact__c = professor2.Id,
            hed__Course_Offering__c = courseOffering.Id,
            Section__c = sem.Id,
           
            RecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId()
        );
        insert enrollment2;

        // Create course offering schedules
        hed__Course_Offering_Schedule__c schedule1 = new hed__Course_Offering_Schedule__c(
            Date__c = Date.today().addDays(1),
            hed__Start_Time__c = Time.newInstance(9, 0, 0, 0),
            hed__End_Time__c = Time.newInstance(10, 0, 0, 0),
             Section__c = sem.Id,
            hed__Course_Offering__c = courseOffering.Id,
            Professor__c = testUser.Id,
            Status__c = 'Scheduled'
        );
        insert schedule1;

        hed__Course_Offering_Schedule__c schedule2 = new hed__Course_Offering_Schedule__c(
            Date__c = Date.today().addDays(1),
            hed__Start_Time__c = Time.newInstance(10, 0, 0, 0),
            hed__End_Time__c = Time.newInstance(11, 0, 0, 0),
            Section__c = sem.Id,
            hed__Course_Offering__c = courseOffering.Id,
            Professor__c = testUser.Id,
            Status__c = 'Scheduled'
        );
        insert schedule2;

        // Create a class adjustment to exclude professor2
        class_adjustment__c adjustment = new class_adjustment__c(
            From_Date__c = Date.today().addDays(1),
            To_Date__c = Date.today().addDays(1),
            Start_time__c = Time.newInstance(10, 0, 0, 0),
            End_time__c = Time.newInstance(11, 0, 0, 0),
            Requested_Professor__c = testUser.Id,
            Status__c = 'Submitted'
        );
        insert adjustment;

        // Test the method
        Test.startTest();
        Map<String, List<Contact>> result = ProfessorClassAdjustmentController.getProfessorsBySameSection(
            Date.today(),
            Date.today().addDays(2),
            testUser.Id,
            'Section A',
            sem.Id,
            Time.newInstance(9, 0, 0, 0),
            Time.newInstance(11, 0, 0, 0)
        );
        
         Map<String, List<Contact>> result1 = ProfessorClassAdjustmentController.getProfessorsOtherSection(
            Date.today(),
            Date.today().addDays(2),
            testUser.Id,
            'Section A',
            sem.Id,
            Time.newInstance(9, 0, 0, 0),
            Time.newInstance(11, 0, 0, 0),
             'Reva2025'
        );
         Map<String, List<Contact>> result2 = ProfessorClassAdjustmentController.getProfessorsEntireSchool(
            Date.today(),
            Date.today().addDays(2),
            testUser.Id,
            'Section A',
            sem.Id,
            Time.newInstance(9, 0, 0, 0),
            Time.newInstance(11, 0, 0, 0),
             'Reva2025',
             'Hardcore Course'
        );
         Map<String, List<Contact>> result3 = ProfessorClassAdjustmentController.getProfessorsEntireSchool(
            Date.today(),
            Date.today().addDays(2),
            testUser.Id,
            'Section A',
            sem.Id,
            Time.newInstance(9, 0, 0, 0),
            Time.newInstance(11, 0, 0, 0),
             'Reva2025',
             'Open Elective'
        );
        List<class_adjustment__c> result5 = ProfessorClassAdjustmentController.getClassAdjustments(
        Date.today(),
        Date.today().addDays(2),
        testUser.Id
        );
        Test.stopTest();

       }

    
     @isTest
    static void testClassAdjustmentInsert() {
        // Setup test data
        Profile profProfile = [SELECT Id FROM Profile WHERE Name = 'Professor'];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profProfile.Id,
            EmployeeNumber = 'EMP001'
        );
        insert testUser;

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a Term record
        hed__Term__c term = new hed__Term__c(Name = 'Test Term', hed__Account__c = testAccount.Id);
        insert term;

        // Create a Course record
       hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('Test Course', testAccount.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        obj_Cour.Category__c = 'Hardcore Course';
        obj_Cour.Credits__c = 3;
        obj_Cour.Offered_By_School__c = testAccount.Id;
        obj_Cour.Credit_Hours__c = 20;
        obj_Cour.L_T_P__c = '2:1:0';
        obj_Cour.No_of_IA_s__c = '1';
        //obj_Cour.Maximum_Internal_Marks__c = 70;
        obj_Cour.Maximum_External_Marks__c = 30;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 85;
        insert obj_Cour;

        // Create a Course Offering record
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
            hed__Course__c = obj_Cour.Id,
            hed__Term__c = term.Id,
            Name = 'Test Offering',
            Category__c = 'Hardcore Course'
        );
        insert courseOffering;

        // Create a Course Offering Schedule
        hed__Course_Offering_Schedule__c schedule = new hed__Course_Offering_Schedule__c(
            Date__c = Date.today(),
            hed__Start_Time__c = Time.newInstance(9, 0, 0, 0),
            hed__End_Time__c = Time.newInstance(10, 0, 0, 0),
            hed__Course_Offering__c = courseOffering.Id,
            Professor__c = testUser.Id,
            Status__c = 'Scheduled',
            Section__c = term.Id
);
        insert schedule;

        // Create a Contact record for the professor
        Contact professorContact = new Contact(
            FirstName = 'Professor',
            LastName = 'Smith',
            Email = 'professor@example.com',
            AccountId = testAccount.Id,
            Employee_Number__c = 'EMP001'
        );
        insert professorContact;

        // Prepare JSON data for adjustments
        String adjustments = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'currentUserId' => testUser.Id,
                'professor' => professorContact.Id,
                'selectType' => 'Same Section',
                'scheduleDate' => Date.today(),
                'toDate' => Date.today().addDays(1),
                'courseOfferingScheduleId' => schedule.Id,
                'startTime' => '09:00',
                'endTime' => '10:00'
            }
        });

        // Test the method
        Test.startTest();
        ProfessorClassAdjustmentController.ClassAdjustmentInsert(adjustments);
        Test.stopTest();

        // Verify results
        List<Class_Adjustment__c> adjustmentsInserted = [
            SELECT Id, From_Date__c, To_Date__c, Start_Time__c, End_Time__c, Status__c,
                   Requested_Professor__c, Course_Offering_Schedule__c, selected_List__c, Professor__c
            FROM Class_Adjustment__c
        ];
  
    }
}