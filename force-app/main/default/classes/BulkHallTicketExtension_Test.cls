@IsTest
private class BulkHallTicketExtension_Test {

    @TestSetup
    static void setupData() {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();  
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        // Create a Semester (hed__Term__c)
        hed__Term__c term = new hed__Term__c(
            Name = 'Semester 3',
            Term_Number__c = 3,
            hed__Account__c = objAcc.Id,
            IA_1_Start_date__c = System.today().addDays(-40)
        );
        insert term;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = term.id;
        insert objTermParent;

        // Create Program Batch
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'CSE-2025'
        );
        insert programBatch;
        
        hed__Course__c course1 = TT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        course1.hed__Course_ID__c ='123';
        course1.L_T_P__c = '3:0:0';
        course1.No_of_IA_s__c = '1';
        course1.Credits__c = 2;
        course1.Offered_By_School__c = objAcc.Id;
        course1.Credit_Hours__c = 3.0;
        course1.SEE_Conducted_Marks__c = 1;
        course1.Maximum_External_Marks__c = 10;
        course1.Total_Maximum_Marks_IA_External__c = 100.0;
        //Insert course1;         
        
        hed__Course__c course2 = TT_TestDataFactory.CreateCourse('CourseName1', objAcc.Id);
        course2.hed__Course_ID__c ='124';
        course2.L_T_P__c = '3:0:0';
        course2.No_of_IA_s__c = '1';
        course2.Credits__c = 2;
        course2.Offered_By_School__c = objAcc.Id;
        course2.Credit_Hours__c = 3.0;
        course2.SEE_Conducted_Marks__c = 1;
        course2.Maximum_External_Marks__c = 10;
        course2.Total_Maximum_Marks_IA_External__c = 100.0;
        //Insert course2;         
        insert new List<hed__Course__c>{ course1, course2 };

        // Create Students (Contacts)
        List<Contact> students = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            students.add(new Contact(
                FirstName = 'Student',
                LastName = 'Test' + i,
                SRN_Number__c = 'SRN00' + i,
                Active_Semester__c = term.Id,
                Checking_Eligibility_for_Exam__c = 'Eligible',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId(),               
                Program_Batch__c = programBatch.Id
            ));
        }
        insert students;

        // Create Exam Notification (Published)
        Id recordTypeId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName()
            .get('hed_IA_Notification').getRecordTypeId();

        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c(
            Name = 'IA1 - Notification',
            Rve_Publish__c = true,
            Rve_Semester__c = term.Id,
            hed_IA_Type__c = 'IA 1',
            rve_Exam_Start_Date__c = Date.today(),
            Rve_End_Date__c = Date.today().addDays(10),
            RecordTypeId = recordTypeId,
            hed_Program_Batch__c = programBatch.Id
        );
        insert examNotification;

        // Create Time Table Line Items
        List<hed_Time_Table_Line_Item__c> timeItems = new List<hed_Time_Table_Line_Item__c>{
            new hed_Time_Table_Line_Item__c(
                Name = 'DS Exam',
                Course__c = course1.Id,
                hed_Date__c = Date.today(),
                hed_Start_Time__c = Time.newInstance(9, 0, 0, 0),
                hed_End_Time__c = Time.newInstance(12, 0, 0, 0),
                Reva_Exam_Notification__c = examNotification.Id
            ),
            new hed_Time_Table_Line_Item__c(
                Name = 'Algo Exam',
                Course__c = course2.Id,
                hed_Date__c = Date.today().addDays(1),
                hed_Start_Time__c = Time.newInstance(13, 0, 0, 0),
                hed_End_Time__c = Time.newInstance(16, 0, 0, 0),
                Reva_Exam_Notification__c = examNotification.Id
            )
        };
        insert timeItems;
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', term.Id, course1.id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = term.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        //obj_Cour_Off.Publish_to_Students__c = true;
        insert obj_Cour_Off;

        // Create Course Enrollments
        List<hed__Course_Enrollment__c> enrollments = new List<hed__Course_Enrollment__c>();
        for (Contact stu : students) {
            enrollments.add(new hed__Course_Enrollment__c(
                hed__Contact__c = stu.Id,               
                Section__c = objTermParent.Id,
                hed__Course_Offering__c = obj_Cour_Off.Id
            ));
        }
        insert enrollments;
    }

    @IsTest
    static void testInitializeBulkData() {
        // Get a valid semester ID
        hed__Term__c term = [SELECT Id FROM hed__Term__c LIMIT 1];

        // Mock page parameters
        Test.setCurrentPage(new PageReference('/apex/BulkHallTicketPage'));
        ApexPages.currentPage().getParameters().put('semesterId', term.Id);
        ApexPages.currentPage().getParameters().put('eligibility', 'Eligible');

        // Instantiate controller
        Test.startTest();
        BulkHallTicketExtension controller = new BulkHallTicketExtension();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, controller.students, 'Students list should not be null');
        System.assert(controller.students.size() > 0, 'Students should be fetched');
        System.assertNotEquals(null, controller.assessmentType, 'Assessment type should be set');
        System.assertNotEquals(null, controller.StartDate, 'Start date should be populated');
        System.assertNotEquals(null, controller.EndDate, 'End date should be populated');
        System.assert(controller.SemesterTerm != null, 'Semester term should be populated');
        System.assert(controller.evenorooddsem != null, 'Even/Odd semester flag should be set');

        // Check that timetable items are matched
        for (BulkHallTicketExtension.StudentWrapper stu : controller.students) {
            System.assertNotEquals(null, stu.LineItemWithDate, 'LineItemWithDate map should not be null');
        }
    }

    @IsTest
    static void testNoSemesterParam() {
        Test.setCurrentPage(new PageReference('/apex/BulkHallTicketPage'));
        ApexPages.currentPage().getParameters().put('eligibility', 'Eligible');

        Test.startTest();
        BulkHallTicketExtension controller = new BulkHallTicketExtension();
        Test.stopTest();

        // Should add a message about missing semesterId
        System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Should show error for missing semesterId');
    }
}