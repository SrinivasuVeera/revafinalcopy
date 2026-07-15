@isTest
private class RoomAllotmentPdfHandlerTest {
    @isTest
    static void testConstructor() {
        // Create test data
        Date testDate = Date.today();
        String dateParam = String.valueOf(testDate);
        String TimeParam = '11:00:00:000';
        Test.setCurrentPageReference(new PageReference(''));
        ApexPages.currentPage().getParameters().put('DatePass', dateParam);
        ApexPages.currentPage().getParameters().put('TimePass', TimeParam);
        
        Profile p = [Select Id from profile where name = 'Professor'];
        
         User u = new User(
         FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(), // unique username
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        
        );
        
        insert u;
        // Create test records
        String RecordTypeaccId = [Select Id from RecordType where sobjecttype='Account' and Name = 'University Department' limit 1].Id;
        Account acc = new Account(Name = 'Test School',Examination_Vertical_Head__c = u.Id,RecordtypeId = RecordTypeaccId);
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestIAProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        hed__Term__c ParentSemester = new hed__Term__c(
            Name = 'TestSemesterParent',
            hed__Account__c = acc.Id,
            hed__Start_Date__c = System.today(),
            hed__End_Date__c = System.today().adddays(2),
            Term_Number__c = 1,
            Program_Batch__c = ProgramBatch.Id
          //  IA_1_Start_date__c = System.today(),
          //  IA_1_End_date__c = System.today().adddays(2)
        );
        
   /*    System.debug('FirstCondition => ' + 
    (!String.isBlank(String.valueOf(ParentSemester.hed__Start_Date__c)) && 
    !String.isBlank(String.valueOf(ParentSemester.hed__End_Date__c)))
);

System.debug('SecondCondition => ' + 
    (Math.abs(ParentSemester.hed__Start_Date__c.daysBetween(Date.today())) <= 15 || 
    (Date.today() >= ParentSemester.hed__Start_Date__c && Date.today() <= ParentSemester.hed__End_Date__c))
);

System.debug('ThirdCondition => ' + 
    (Math.abs(ParentSemester.hed__End_Date__c.daysBetween(Date.today())) <= 15 || 
    (Date.today() >= ParentSemester.hed__Start_Date__c && Date.today() <= ParentSemester.hed__End_Date__c))
);

        
        
        
        Boolean isWithinRange = (System.today() >= ParentSemester.hed__Start_Date__c) && (System.today() <= ParentSemester.hed__End_Date__c);*/
     //   System.debug('Condition Result: ' + isWithinRange); // Should output: true
        insert ParentSemester;
        System.debug('ParentSemester=> '+ParentSemester);
        System.debug('ParentSemester=> '+ParentSemester.Active__c);

        Id RecordTypeId1 = [Select Id from RecordType where sobjecttype='hed__Term__c' and name='Sections' limit 1].Id;
        
        hed__Term__c Semester = new hed__Term__c(
            Name = 'TestSemester',
            hed__Account__c = acc.Id,
            hed__Start_Date__c = System.today(),
            hed__End_Date__c = System.today().adddays(2),
            Term_Number__c = 1,
            Program_Batch__c = ProgramBatch.Id,
            hed__Parent_Term__c = ParentSemester.Id,
            RecordTypeId = RecordTypeId1
        );
        
        insert Semester;
        
        RecordType ExamNotificationRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Rve_Exam_Notification__c' and DeveloperName='hed_IA_Notification'];
        
        Rve_Exam_Notification__c TestNotification = new Rve_Exam_Notification__c();
        TestNotification.Name = 'TestExamNotification';
        TestNotification.rve_Exam_Start_Date__c = System.Today();
        TestNotification.Rve_Publish__c = true;
        TestNotification.hed_Program_Batch__c = ProgramBatch.Id;
        TestNotification.hed_IA_Type__c = 'IA 1';
        TestNotification.RecordTypeId = ExamNotificationRecordType.Id;
        TestNotification.Rve_Semester__c = Semester.Id;
        insert TestNotification;
        
        System.debug('ExamNotification=> '+TestNotification);
        
        hed__Course__c Course = new hed__Course__c(
            Name = 'Test Course',
            hed__Account__c = acc.Id,
            HardCore_Sub_Type__c='Theory',
             Credits__c = 3.2,
            Category__c = 'Hardcore Course',
            Offered_By_School__c = acc.id,
            Credit_Hours__c = 2,
            L_T_P__c = '10',
            Maximum_External_Marks__c = 10,
            Total_Maximum_Marks_IA_External__c = 20,
            //Maximum_Internal_Marks__c = 0,
            No_of_IA_s__c = '2'
        );
        
        insert Course;
        
        hed__Course_Offering__c CourseOffering = new hed__Course_Offering__c(
        hed__Course__c = course.Id,
        hed__Term__c = semester.id,
        Name = 'Test Course'
        );
 
        insert CourseOffering;
        
        Id RecordTypeId = [Select Id from recordtype where sobjecttype='contact' and name='student' limit 1].Id;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            SRN_Number__c = 'SA001',
            Application_Number__c = 'SA001',
            Program_Batch__c = ProgramBatch.Id,
            Student_Status__c = 'Pursuing',
            recordtypeid = RecordTypeId,
            Active__c = true
        );
        insert testContact;
        System.debug('testContact=> '+testContact);
        
        hed__Course_Enrollment__c CourseEnr = new hed__Course_Enrollment__c(
        hed__Contact__c = testcontact.id,
        hed__Course_Offering__c = CourseOffering.id,
        Section__c = Semester.Id,
        External_Id__c = '1',
        Semester_ID__c = '1',
        Logisys_External_Id__c = '1'
        );
        
        insert CourseEnr;
        System.debug('CourseEnr=> '+CourseEnr);
        System.debug('CourseEnr=> '+CourseEnr.Active_Connection__c);

        hed_Time_Table_Line_Item__c TimeTableItem = new hed_Time_Table_Line_Item__c();
        TimeTableItem.Name = 'TestTimeTable';
        TimeTableItem.Reva_Exam_Notification__c = TestNotification.Id;
        TimeTableItem.hed_Date__c = System.today();
        TimeTableItem.hed_Start_Time__c = Time.newInstance(11, 0, 0, 0);
        TimeTableItem.hed_End_Time__c = Time.newInstance(12, 0, 0, 0);
        TimeTableItem.Course__c = Course.Id;

        insert TimeTableItem;
        
        System.debug('TimeTableItem=> '+TimeTableItem);
        
        hed__Facility__c Facility = new hed__Facility__c(
            Name = 'Test Facility',
            hed__Capacity__c = 50,
            Facility_Booked__c = false,
            Room_Name__c = 'TESLA LAB',
            Room__c = '301',
            Floor__c = '1st floor',
            Block__c = 'C.V. Raman Block',
            IA_Type__c = 'IA 1',
            hed__Account__c = acc.Id
        );
        insert Facility;
        
        IA_Seating_Room_Allotment__c SeatingRoom = new IA_Seating_Room_Allotment__c(
            Name = Facility.Room__c,
            Facility_Type__c = Facility.Id,
            Capacity__c = Facility.hed__Capacity__c,
            IA_Type__c = Facility.IA_Type__c,
            School__c = acc.Id,
            Room__c = Facility.Room__c,
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            rveShift__c = 'Morning',
            Exam_Time__c = Time.NewInstance(11, 0, 0, 0),
            End_Time__c = Time.NewInstance(12, 0, 0, 0),
            Alloted_Students__c = 'SA001,SA002',
            InEligible_SRN__c = 'SA003,SA004',
        //    Course_Name__c = 'Electronic Circuit',
            Exam_Name__c = TestNotification.Name,
            Assigned_Program_Batches__c = ProgramBatch.Id,
            Total_Students__c = 4
        ); 
        
        insert SeatingRoom;
        
                
        Contact testContact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact2',
            SRN_Number__c = 'SA003',
            Application_Number__c = 'SA003',
            Program_Batch__c = ProgramBatch.Id
        );
        insert testContact2;
    
        System.runas(u){
        // Call constructor
        Test.startTest();
        RoomAllotmentPdfHandler handler = new RoomAllotmentPdfHandler(new ApexPages.StandardController(new IA_Seating_Room_Allotment__c()));
        Test.stopTest();
        
        }
    }

    @isTest
    static void testCheckEvenOdd() {
        // Test the checkEvenOdd method
        System.assertEquals('Odd', RoomAllotmentPdfHandler.checkEvenOdd(1));
        System.assertEquals('Even', RoomAllotmentPdfHandler.checkEvenOdd(2));
        System.assertEquals('Odd', RoomAllotmentPdfHandler.checkEvenOdd(3));
        System.assertEquals('Even', RoomAllotmentPdfHandler.checkEvenOdd(4));
    }
    
    @isTest
    static void convertTime() {
       
    }
}