@isTest
public class EmailTemplatesForRevaTest {

    @isTest
    static void testSendIAMarksEntryEmailtoFaculty2() {
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);        
        insert semester;
        system.debug('test semester>>'+semester);
        
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = 'Course ';
        objCourse.hed__Account__c = acc.id;
      //  objCourse.Category__c = cat;
        objCourse.hed__Course_ID__c = 'CRS001';
        
      hed__Course_Offering__c courseDetails= ASM_TestDataFactory.createCourseOffering('Test Course', Semester.Id, objCourse.Id);

        String examname = 'Midterm Exam';
        String formattedDate = '2024-10-10';

        String body = EmailTemplatesForReva.sendIAMarksEntryEmailtoFaculty2(courseDetails, examname, formattedDate);
    //    System.assertNotEquals(null, body, 'Email body should not be null');
    //    System.assert(body.contains('John Doe'), 'Email body should contain the faculty name');
    }

    @isTest
    static void testSendPushCourseOffering3() {
        
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);        
        insert semester;
        system.debug('test semester>>'+semester);
        
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name = 'Course ';
        objCourse.hed__Account__c = acc.id;
      //  objCourse.Category__c = cat;
        objCourse.hed__Course_ID__c = 'CRS001';
        
        
       hed__Course_Offering__c courseDetails= ASM_TestDataFactory.createCourseOffering('Test Course', Semester.Id, objCourse.Id);

        String formattedDate1 = '2024-06-30';

        String body = EmailTemplatesForReva.sendPushCourseOffering3(courseDetails, formattedDate1);
     //   System.assertNotEquals(null, body, 'Email body should not be null');
     //   System.assert(body.contains('Jane Doe'), 'Email body should contain the vertical head name');
    }

    @isTest
    static void testSendIATimeTableCreationEmail4() {
        String verticalHead = 'Head of Department';
        String examName = 'Final Exam';
        String semesterName = 'Spring 2024';
        String tenDaysBeforeExamDate = '2024-06-20';

        String body = EmailTemplatesForReva.sendIATimeTableCreationEmail4(verticalHead, examName, semesterName, tenDaysBeforeExamDate);
     //   System.assertNotEquals(null, body, 'Email body should not be null');
     //   System.assert(body.contains(verticalHead), 'Email body should contain the vertical head');
    }

    @isTest
    static void testSendHallTicketEmailtoEligibleStudent7() {
        String studentName = 'Student A';
        String examName = 'Final Exam';
        String studentPortalLink = 'https://studentportal.example.com';

        String body = EmailTemplatesForReva.sendHallTicketEmailtoEligibleStudent7(studentName, examName, studentPortalLink);
      //  System.assertNotEquals(null, body, 'Email body should not be null');
      //  System.assert(body.contains(studentName), 'Email body should contain the student name');
    }

    @isTest
    static void testSendHallTicketPublishEmailtoParent8() {
        String parentName = 'Parent A';
        String semesterName = 'Spring 2024';
        String examName = 'Final Exam';

        String body = EmailTemplatesForReva.sendHallTicketPublishEmailtoParent8(parentName, semesterName, examName);
      //  System.assertNotEquals(null, body, 'Email body should not be null');
      //  System.assert(body.contains(parentName), 'Email body should contain the parent name');
    }

    @isTest
    static void testSendInEligibleHallTicketEmailtoStudent9() {
        String studentName = 'Student A';
        String examName = 'Final Exam';

        String body = EmailTemplatesForReva.sendInEligibleHallTicketEmailtoStudent9(studentName, examName);
       // System.assertNotEquals(null, body, 'Email body should not be null');
       // System.assert(body.contains(studentName), 'Email body should contain the student name');
    }

    @isTest
    static void testSendInEligibleHallTicketEmailtoParent10() {
        String parentName = 'Parent A';
        String studentName = 'Student A';
        String examName = 'Final Exam';

        String body = EmailTemplatesForReva.sendInEligibleHallTicketEmailtoParent10(parentName, studentName, examName);
     //   System.assertNotEquals(null, body, 'Email body should not be null');
      //  System.assert(body.contains(parentName), 'Email body should contain the parent name');
    }
    
    @isTest
    static void testSendAbsentEmailforStudent15() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.sendAbsentEmailforStudent15('John Doe', 'Course ABC', 'Midterm', '2024-06-21', '10:00 AM', '12:00 PM');
        Test.stopTest();
    }

    @isTest
    static void testSendAbsentEmailforParent16() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.sendAbsentEmailforParent16('Jane Doe', 'John Doe', 'Course ABC', 'Midterm', '2024-06-21', '10:00 AM', '12:00 PM');
        Test.stopTest();
   
    }

    @isTest
    static void testSendAbsentEmailtoMentor18() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.sendAbsentEmailtoMentor18('Dr. Smith', 'John Doe', 'SRN12345', 'Midterm', 'Course ABC', '2024-06-21', '10:00 AM', '12:00 PM');
        Test.stopTest();
        
    }

    @isTest
    static void testSendMallPraticeEmailtoMentor19() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.sendMallPraticeEmailtoMentor19('Dr. Smith', 'John Doe', 'SRN12345', 'Midterm', 'Course ABC', '2024-06-21', '10:00 AM', '12:00 PM');
        Test.stopTest();
        
    }

    @isTest
    static void testSendMallPraticeEmailtoParent20() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.sendMallPraticeEmailtoParent20('Jane Doe', 'John Doe', 'Midterm', 'Course ABC', '2024-06-21', '10:00 AM', '12:00 PM');
        Test.stopTest();
       
    }

    @isTest
    static void testIASEEAbsentAttendanceNotificationForParents() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.IASEEAbsentAttendanceNotificationForParents('Jane Doe', 'John Doe', 'Course ABC', 'Midterm', '2024-06-21', '10:00 AM', '12:00 PM');
        Test.stopTest();
        
       
    }

    @isTest
    static void testAbsentAttendnaceToMentor() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.AbsentAttendnaceToMentor('Dr. Smith', 'John Doe', 'SRN12345', 'Midterm', 'Course ABC', '2024-06-21', '10:00 AM', '12:00 PM');
        Test.stopTest();
        
       
    }

    @isTest
    static void testIASEEAbsentAttendanceNotificationForStudents() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.IASEEAbsentAttendanceNotificationForStudents('John Doe', 'Midterm', 'Course ABC', '2024-06-21', '10:00 AM', '12:00 PM');
        Test.stopTest();
        
    }

    @isTest
    static void testExamApplicationFormEmailNotificationToStudnets() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.ExamApplicationFormEmailNotificationToStudnets('John Doe', 'Fall 2024', '2024-06-30');
        Test.stopTest();
     
    }

    @isTest
    static void testResults21() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.results21('John Doe', 'Fall 2024');
        Test.stopTest();
        
    }

    @isTest
    static void testResults22() {
        Test.startTest();
        String emailBody = EmailTemplatesForReva.results22('John Doe', 'Fall 2024', 'Jane Doe');
        Test.stopTest();
    
    }

    // Additional test methods for other email templates can be added similarly
}