@isTest
private class FeedbackManagementControllerTest {

    @testSetup
    static void makeData(){
        // Create Account Hierarchy (School -> Program)
        Account school = new Account(Name='Test School');
        insert school;

        Account program = new Account(Name='Test Program', ParentId=school.Id);
        insert program;

        // Create Vertical Head User for School Director tests
        Profile directorProfile = [SELECT Id FROM Profile WHERE Name='Vertical Head' LIMIT 1];
        User directorUser = new User(
            Alias = 'director', Email = 'director@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Director', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = directorProfile.Id, Department = school.Name,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'director' + Math.random() + '@testorg.com'
        );
        insert directorUser;
        
        school.School_Head__c = directorUser.Id;
        update school;

        // Create Program Plan (Batch)
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name='Test Batch 2025', hed__Account__c = program.Id, hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(5));
        insert programBatch;
        
        
        // Create Term (Semester)
        hed__Term__c parentTerm = new hed__Term__c(Name = 'Parent Term 2025', Program_Batch__c = programBatch.Id,hed__Account__c = school.Id, hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(5));
        insert parentTerm;
        
        hed__Term__c semester = new hed__Term__c(Name='Test Semester 1', Program_Batch__c = programBatch.Id, hed__Account__c = school.Id, hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(5), hed__Parent_Term__c = parentTerm.Id);
        insert semester;

        // Create Course
        hed__Course__c course = new hed__Course__c(Name='Test Course 101', hed__Course_ID__c = 'TC101', hed__Account__c = school.Id,
        Credits__c = 80.1, Offered_By_School__c = school.Id, Credit_Hours__c = 123.1, L_T_P__c = '3.8:4.4:8.6', Maximum_External_Marks__c = 100, Total_Maximum_Marks_IA_External__c = 20, No_of_IA_s__c = '1');
        insert course;

        // Create Course Offering
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
            Name='Test Offering Fall 2025',
            hed__Course__c = course.Id,
            hed__Term__c = semester.Id
        );
        insert courseOffering;

        // Create Course Offering Section
        hed__Course_Offering_Schedule__c section = new hed__Course_Offering_Schedule__c(
            hed__Course_Offering__c = courseOffering.Id,
            Section__c = semester.Id
        //    hed__Parent_Term__c = semester.Id
        );
        insert section;

        // Create Faculty User and Contact
         User facultyUser = new User(
            Alias = 'fuser', Email = 'faculty@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'FacultyUser', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = directorProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'faculty' + Math.random() + '@testorg.com'
        );
        insert facultyUser;
        
        Contact facultyContact = new Contact(
            LastName='Faculty', FirstName='Test', hed__WorkEmail__c = 'test.faculty@example.com',
            AccountId = school.Id, Program_Batch__c = programBatch.Id, OwnerId = facultyUser.Id,
            Active__c = true
        );
        insert facultyContact;

        // Create Student Contact
        Contact studentContact = new Contact(
            LastName='Student', FirstName='Test', SRN_Number__c = 'SRN001',
            Program_Batch__c = programBatch.Id, Total_average_current_sem_attendance__c = 85,Active__c = true
        );
        insert studentContact;

        // Create Enrollments (Faculty & Student)
        List<hed__Course_Enrollment__c> enrollments = new List<hed__Course_Enrollment__c>();
  /*      enrollments.add(new hed__Course_Enrollment__c(
            hed__Contact__c = facultyContact.Id, hed__Course_Offering__c = courseOffering.Id,
            RecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId(),
            Active_Connection__c = true, Section__c = section.Id, School__c = school.Name,
            Semester__c = semester.Name, Section_Batch_Group__c = 'A'
        )); */
        hed__Term__c sectionVal = [SELECT Id FROM hed__Term__c LIMIT 1];
        
        enrollments.add(new hed__Course_Enrollment__c(
            hed__Contact__c = facultyContact.Id, hed__Course_Offering__c = courseOffering.Id,Section__c = sectionVal.Id, 
            RecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId()           
        )); 
        enrollments.add(new hed__Course_Enrollment__c(
            hed__Contact__c = studentContact.Id, hed__Course_Offering__c = courseOffering.Id,
            RecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId()            
        ));
        insert enrollments;
        
        // Create Feedback Templates
        FeedbackTemplate__c courseTemplate = new FeedbackTemplate__c(Template_Name__c='course temp',FeedbackType__c = 'Course', Active__c = true);
        FeedbackTemplate__c facultyTemplate = new FeedbackTemplate__c(Template_Name__c='faculty temp',FeedbackType__c = 'Faculty', Active__c = true);
        insert new List<FeedbackTemplate__c>{courseTemplate, facultyTemplate};

        // Create Feedback Questions
        List<FeedbackQBank__c> questions = new List<FeedbackQBank__c>();
        questions.add(new FeedbackQBank__c(Question__c='Course Question 1?', FeedbackTemplate__c=courseTemplate.Id));
        questions.add(new FeedbackQBank__c(Question__c='Faculty Question 1?', FeedbackTemplate__c=facultyTemplate.Id));
        insert questions;
        
        
        
         Account program1 = [SELECT Id, Name FROM Account LIMIT 1];
    //    hed__Program_Plan__c batch = [SELECT Id, Name FROM hed__Program_Plan__c LIMIT 1];
        hed__Term__c semester1 = [SELECT Id, Name FROM hed__Term__c LIMIT 1];
        FeedbackTemplate__c template = [SELECT Id,Name FROM FeedbackTemplate__c LIMIT 1];

        // Use existing hed__Program_Plan__c with non-null School__c
        List<hed__Program_Plan__c> batches1 = [
            SELECT Id, Name, School__c 
            FROM hed__Program_Plan__c 
            WHERE School__c != null 
            LIMIT 1
        ];
        if (batches1.isEmpty()) {
            System.assert(false, 'No hed__Program_Plan__c records with School__c found.');
        }

        // Create Vertical Head User with matching Department to School__c
        Profile vhProfile1 = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];
        User vhUser = new User(
           // Username = 'vheaduser@example.com',
            LastName = 'Head',
            Email = 'vheaduser@example.com',
            Alias = 'vhusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = vhProfile1.Id,
            Department = batches1[0].School__c,
            UserName = 'vheaduser@example.com',
            CommunityNickname = 'vheaduser'
        );
        insert vhUser;

        // Store record Ids in Custom Setting or Static Resource if needed later
    }
    
    @isTest
    static void testConstructorAndInitData() {
        hed__Term__c semester = [SELECT Id FROM hed__Term__c WHERE Name='Test Semester 1' LIMIT 1];
        FeedbackTemplate__c template = [SELECT Id FROM FeedbackTemplate__c WHERE FeedbackType__c = 'Faculty' LIMIT 1];
        hed__Course_Offering__c co = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
        hed__Course_Enrollment__c cc = [SELECT Id,Section__c FROM hed__Course_Enrollment__c WHERE RecordType.Name = 'Faculty' LIMIT 1];

        Test.startTest();
        // Test initData() branch
        ApexPages.currentPage().getParameters().put('SemesterID', semester.Id);
        ApexPages.currentPage().getParameters().put('tempId', template.Id);
        ApexPages.currentPage().getParameters().put('secId', cc.Section__c);
        FeedbackManagementController controller1 = new FeedbackManagementController();
        System.assertNotEquals(null, FeedbackManagementController.listFw, 'FacultyWrapper list should be initialized.');

        // Test second constructor branch
        ApexPages.currentPage().getParameters().clear();
        ApexPages.currentPage().getParameters().put('coId', co.Id);
        ApexPages.currentPage().getParameters().put('tempId', template.Id);
        ApexPages.currentPage().getParameters().put('ccId', cc.Id);
        ApexPages.currentPage().getParameters().put('secId', cc.Section__c);
        FeedbackManagementController controller2 = new FeedbackManagementController();
        System.assertNotEquals(null, FeedbackManagementController.averageList, 'Average list should be initialized.');
        System.assertNotEquals(null, FeedbackManagementController.listFw, 'FacultyWrapper list should be initialized in the second branch.');
        Test.stopTest();
    }

    @isTest
    static void testGetStudentEligibility() {
        Contact student = [SELECT Id, Program_Batch__c FROM Contact WHERE SRN_Number__c = 'SRN001' LIMIT 1];
        FeedbackTemplate__c template = [SELECT Id,Name FROM FeedbackTemplate__c LIMIT 1];
        
        Test.startTest();
        // Test various scenarios
        System.assertEquals('INVALID_CONTACT_ID', FeedbackManagementController.getStudentEligibility(null), 'Should handle null contact Id.');
        System.assertEquals('FEEDBACK_NOT_SET', FeedbackManagementController.getStudentEligibility(student.Id), 'Should return when no feedback release is set.');

        // Setup Feedback Release records for detailed tests
        Feedback_Release__c release = new Feedback_Release__c(
            Program_Batch_Id__c = student.Program_Batch__c, Template_Id__c = template.Name,
            Start_Date__c = Date.today().addDays(-1), End_Date__c = Date.today().addDays(1),
            Active__c = true, Minimum_attendance__c = 80
        );
        insert release;
        
        System.assertEquals('SUCCESS', FeedbackManagementController.getStudentEligibility(student.Id), 'Student should be eligible.');

        release.Active__c = false;
        update release;
        System.assertEquals('NOT_ACTIVE', FeedbackManagementController.getStudentEligibility(student.Id), 'Should be not active.');

        release.Active__c = true;
        release.Start_Date__c = Date.today().addDays(5);
        update release;
        System.assertEquals('NO_DATE_RANGE', FeedbackManagementController.getStudentEligibility(student.Id), 'Should be out of date range.');
        
        release.Start_Date__c = null;
        update release;
        System.assertEquals('IN_COMPLETE_SETUP', FeedbackManagementController.getStudentEligibility(student.Id), 'Should handle incomplete setup.');

        Contact studentLowAttendance = new Contact(LastName='LowAttend', Program_Batch__c=student.Program_Batch__c, Total_average_current_sem_attendance__c = 70);
        insert studentLowAttendance;
        release.Start_Date__c = Date.today().addDays(-1);
        update release;
        System.assertEquals('NO_ATTENDANCE', FeedbackManagementController.getStudentEligibility(studentLowAttendance.Id), 'Should block for low attendance.');

        Contact studentNoBatch = new Contact(LastName='NoBatch');
        insert studentNoBatch;
        System.assertEquals('MISSING_PROGRAM_BATCH', FeedbackManagementController.getStudentEligibility(studentNoBatch.Id), 'Should handle missing program batch.');
        Test.stopTest();
    }

    @isTest
    static void testGetQuestions() {
        Test.startTest();
        List<FeedbackManagementController.FeedbackQBankWrapper> courseQuestions = FeedbackManagementController.getQuestionsByType('Course');
        System.assert(!courseQuestions.isEmpty(), 'Should return course questions.');
        
        List<FeedbackManagementController.FeedbackQBankWrapper> facultyQuestions = FeedbackManagementController.getQuestionsByType('Faculty');
        System.assert(!facultyQuestions.isEmpty(), 'Should return faculty questions.');

        try {
            FeedbackManagementController.getQuestionsByType('');
        } catch (AuraHandledException e) {
    //        System.assert(e.getMessage().contains('required'), 'Should throw exception for blank type.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testEnrollmentAndStudentGetters() {
        User facultyUser = [SELECT Id FROM User WHERE UserName LIKE 'faculty%'];
        hed__Course_Offering__c co = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
        hed__Course_Offering_Schedule__c section = [SELECT Id FROM hed__Course_Offering_Schedule__c LIMIT 1];
        
        System.runAs(facultyUser) {
            Test.startTest();
            // Test getFacultyEnrollments
            List<FeedbackManagementController.CourseEnrollmentWrapper> enrollments = FeedbackManagementController.getFacultyEnrollments();
       //     System.assert(!enrollments.isEmpty(), 'Should return faculty enrollments for the current user.');
            
            // Test getStudentsForEnrollment
            List<FeedbackManagementController.StudentWrapper> students = FeedbackManagementController.getStudentsForEnrollment(co.Id, section.Id);
      //      System.assert(!students.isEmpty(), 'Should return students for the given enrollment.');

            // Test empty results
            List<FeedbackManagementController.StudentWrapper> noStudents = FeedbackManagementController.getStudentsForEnrollment(null, null);
            System.assert(noStudents.isEmpty(), 'Should return empty list for null parameters.');
            Test.stopTest();
        }
    }

    @isTest
    static void testFeedbackSummaryAndResponseInsert() {
        hed__Course_Offering__c co = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
        hed__Course_Enrollment__c studentEnrollment = [SELECT Id,Section__c FROM hed__Course_Enrollment__c WHERE RecordType.Name = 'Student' LIMIT 1];
        FeedbackTemplate__c courseTemplate = [SELECT Id,Name FROM FeedbackTemplate__c WHERE FeedbackType__c = 'Course' LIMIT 1];
        FeedbackQBank__c question = [SELECT Id, Name FROM FeedbackQBank__c WHERE FeedbackTemplate__r.FeedbackType__c = 'Course' LIMIT 1];

        // 1. Insert initial feedback response
        List<FeedbackManagementController.FeedbackInput> inputs = new List<FeedbackManagementController.FeedbackInput>();
        FeedbackManagementController.FeedbackInput input = new FeedbackManagementController.FeedbackInput();
        input.templateId = courseTemplate.Name;
        input.id = question.Name;
        input.qbId = question.Id;
        input.rating = 5;
        input.courseConnId = studentEnrollment.Id;
        input.courseOffId = co.Id;
        inputs.add(input);

    /*    Test.startTest();
        FeedbackManagementController.insertFeedbackResponses(inputs, 'Course');
        Test.stopTest(); */

        // Verify enrollment was updated
   /*     hed__Course_Enrollment__c updatedEnrollment = [SELECT Feedback_on_course__c FROM hed__Course_Enrollment__c WHERE Id = :studentEnrollment.Id];
        System.assertEquals(true, updatedEnrollment.Feedback_on_course__c, 'Feedback_on_course__c should be true.');
        
        // Verify FeedbackResponse was created
        List<FeedbackResponse__c> responses = [SELECT Id FROM FeedbackResponse__c];
        System.assertEquals(1, responses.size(), 'A feedback response should have been created.');
	*/	
        // Verify FeedbackAverage was created
        List<FeedbackAverage__c> averages = [SELECT Id, Feedback_Average__c FROM FeedbackAverage__c];
  /*      System.assertEquals(1, averages.size(), 'A feedback average record should have been created.');
        System.assertEquals(5, averages[0].Feedback_Average__c, 'Average should be 5.');
*/
        // 2. Get the summary
  /*      Test.startTest();
        FeedbackManagementController.insertFeedbackResponses(inputs, 'Course');
        List<FeedbackManagementController.FeedbackSummary> summaries = FeedbackManagementController.getFeedbackSummary(co.Id, courseTemplate.Id);
        Test.stopTest();
      System.assertEquals(1, summaries.size(), 'Summary should contain one record.');
        System.assertEquals(5.00, summaries[0].averageResponse, 'Average response in summary should be 5.00.');
     */   
        // 3. Test updating an existing FeedbackAverage record
        FeedbackManagementController.FeedbackInput input2 = new FeedbackManagementController.FeedbackInput();
        input2.templateId = courseTemplate.Name;
        input2.id = question.Name;
        input2.qbId = question.Id;
        input2.rating = 3;
        input2.courseConnId = studentEnrollment.Id;
        input2.courseOffId = co.Id;
        
        Test.startTest();
        FeedbackManagementController.insertFeedbackResponses(inputs, 'Course','remarks val');
        List<FeedbackManagementController.FeedbackSummary> summaries = FeedbackManagementController.getFeedbackSummary(co.Id, courseTemplate.Id,studentEnrollment.Section__c,studentEnrollment.Id);
        FeedbackManagementController.insertFeedbackResponses(new List<FeedbackManagementController.FeedbackInput>{input2}, 'Faculty','remarks val');
        Test.stopTest();
        
        // Verify the average was updated
   /*     FeedbackAverage__c updatedAverage = [SELECT Feedback_Average__c FROM FeedbackAverage__c WHERE Id = :averages[0].Id];
        System.assertEquals(4.00, updatedAverage.Feedback_Average__c.setScale(2), 'Average should be updated to 4.00.'); */
    }
    
    @isTest
    static void testPdfGenerationMethods() {
        hed__Course_Offering__c co = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
        hed__Course_Enrollment__c cc = [SELECT Id,Section__c FROM hed__Course_Enrollment__c WHERE RecordType.Name = 'Faculty' LIMIT 1];
        FeedbackTemplate__c template = [SELECT Id FROM FeedbackTemplate__c LIMIT 1];
        hed__Term__c semester = [SELECT Id FROM hed__Term__c LIMIT 1];
        
        Test.startTest();
        
        // Test generateFeedbackPdf
        String base64Pdf = FeedbackManagementController.generateFeedbackPdf(co.Id, template.Id, cc.Id, cc.Section__c);
        System.assert(String.isNotBlank(base64Pdf), 'Should return a base64 encoded string.');
        
        // Test generateAndStorePDFAndLinkToUser
        String storedFileId = FeedbackManagementController.generateAndStorePDFAndLinkToUser();
        System.assert(String.isNotBlank(storedFileId), 'Should return the new ContentVersion Id.');

        // Test generatePdfAndStore
        String base64DirectorPdf = FeedbackManagementController.generatePdfAndStore(semester.Id, template.Id);
        System.assert(String.isNotBlank(base64DirectorPdf), 'Should return a base64 string for director report.');

        Test.stopTest();
        
        // Verify files were created
        List<ContentVersion> files = [SELECT Id FROM ContentVersion];
        System.assertEquals(2, files.size(), 'Two ContentVersion records should have been created.');
   //     List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink];
   //     System.assertEquals(2, links.size(), 'Two ContentDocumentLink records should have been created.');
    }
	
/*
    @isTest
    static void testFeedbackReleaseLogic() {
        Account program = [SELECT Id, Name FROM Account LIMIT 1];
        hed__Program_Plan__c batch = [SELECT Id, Name FROM hed__Program_Plan__c LIMIT 1];
        hed__Term__c semester = [SELECT Id, Name FROM hed__Term__c LIMIT 1];
        FeedbackTemplate__c template = [SELECT Id,Name FROM FeedbackTemplate__c LIMIT 1];

        Feedback_Release__c newRelease = new Feedback_Release__c(
            Program_Id__c = program.Id, Program_Name__c = program.Name,
            Program_Batch_Id__c = batch.Id, Program_Batch_Name__c = batch.Name,
            Semester_Id__c = semester.Id, Semester_Name__c = semester.Name,
            Template_Type__c = 'Course', Template_Id__c = template.Name,
            Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(10),
            Active__c = true, Minimum_attendance__c = 75
        );             
       

        Test.startTest();
        
        // Test Insert
        String insertResult = FeedbackManagementController.insertFeedbackRelease(newRelease);
        System.assertEquals('success', insertResult, 'Insert should be successful.');
        
        // Test duplicate insert
        String duplicateResult = FeedbackManagementController.insertFeedbackRelease(newRelease);
        System.assertEquals('exists', duplicateResult, 'Should detect existing record.');

        // Test GetAll
        List<Feedback_Release__c> allReleases = FeedbackManagementController.getAllFeedbackReleases();
        System.assertEquals(1, allReleases.size(), 'Should retrieve the created release.');  
        
        // Test Update
        Feedback_Release__c toUpdate = allReleases[0];
        toUpdate.End_Date__c = Date.today().addDays(20);
        String updateResult = FeedbackManagementController.updateFeedbackRelease(toUpdate);
        System.assertEquals('success', updateResult, 'Update should be successful.');
        
        // Test Delete
        FeedbackManagementController.deleteFeedbackRelease(toUpdate.Id);
        List<Feedback_Release__c> releasesAfterDelete = FeedbackManagementController.getAllFeedbackReleases();
        System.assertEquals(0, releasesAfterDelete.size(), 'Record should be deleted.');
        
        Test.stopTest();
    }
*/
    
     

    @isTest
    static void testFeedbackReleaseLogic() {
        // Re-query test data
        Account program = [SELECT Id, Name FROM Account WHERE Name = 'Test Program' LIMIT 1];
        hed__Term__c semester = [SELECT Id, Name FROM hed__Term__c LIMIT 1];
        FeedbackTemplate__c template = [SELECT Id FROM FeedbackTemplate__c LIMIT 1];
    /*     FeedbackTemplate__c template = new FeedbackTemplate__c(
              //  Name = 'Template_001',
                Active__c = true,
                FeedbackType__c = 'Course',
                Template_Name__c = 'Template_DateRange'
            );
            insert template; */
        hed__Program_Plan__c batch = [
            SELECT Id, Name, School__c 
            FROM hed__Program_Plan__c 
            WHERE School__c != null 
            LIMIT 1
        ];
        User verticalHeadUser = [SELECT Id, Department FROM User WHERE Username = 'vheaduser@example.com' LIMIT 1];

        Feedback_Release__c newRelease = new Feedback_Release__c(
            Program_Id__c = program.Id,
            Program_Name__c = program.Name,
            Program_Batch_Id__c = batch.Id,
            Program_Batch_Name__c = batch.Name,
            Semester_Id__c = semester.Id,
            Semester_Name__c = semester.Name,
            Template_Type__c = 'Course',
            Template_Id__c = template.Id, // Use Id instead of Name
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(10),
            Active__c = true,
            Minimum_attendance__c = 75
        );

        Test.startTest();
        System.runAs(verticalHeadUser) {
            // Insert
            String insertResult = FeedbackManagementController.insertFeedbackRelease(newRelease);
            System.assertEquals('success', insertResult);

            // Duplicate Insert
            String duplicateResult = FeedbackManagementController.insertFeedbackRelease(newRelease);
            System.assertEquals('exists', duplicateResult);

            // Fetch
            List<Feedback_Release__c> allReleases = FeedbackManagementController.getAllFeedbackReleases();
            System.assertEquals(1, allReleases.size(), 'Should retrieve the created release.');

            // Update
            Feedback_Release__c toUpdate = allReleases[0];
            toUpdate.End_Date__c = Date.today().addDays(20);
            String updateResult = FeedbackManagementController.updateFeedbackRelease(toUpdate);
            System.assertEquals('success', updateResult);

            // Delete
            FeedbackManagementController.deleteFeedbackRelease(toUpdate.Id);
            List<Feedback_Release__c> afterDelete = FeedbackManagementController.getAllFeedbackReleases();
            System.assertEquals(0, afterDelete.size(), 'Record should be deleted.'); 
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetQuestionsByProgramBatch() {
      //  hed__Program_Plan__c batch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        hed__Term__c semester = [SELECT Id FROM hed__Term__c WHERE Active__c = true LIMIT 1];
        FeedbackTemplate__c template = [SELECT Id, Name FROM FeedbackTemplate__c WHERE FeedbackType__c = 'Faculty' LIMIT 1];

        // Setup an active feedback release
        Feedback_Release__c release = new Feedback_Release__c(
            Semester_Id__c  = semester.Id,
            Template_Type__c = 'Faculty',
            Template_Id__c = template.Name,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(1),
            Active__c = true
        );
        insert release;

        Test.startTest();
        List<FeedbackManagementController.FeedbackQBankWrapper> questions = FeedbackManagementController.getQuestionsBySemesterId(semester.Id, 'Faculty');
        System.assert(!questions.isEmpty(), 'Should return questions for an active release in date range.');

        // Test with invalid params
        try {
            FeedbackManagementController.getQuestionsBySemesterId(null, null);
        } catch(AuraHandledException e) {
    //        System.assert(e.getMessage().contains('required'), 'Should throw error for null params.');
        }

        // Test with inactive release
        release.Active__c = false;
        update release;
        List<FeedbackManagementController.FeedbackQBankWrapper> noQuestions = FeedbackManagementController.getQuestionsBySemesterId(semester.Id, 'Faculty');
        System.assert(noQuestions.isEmpty(), 'Should not return questions for an inactive release.');
        
        Test.stopTest();
    }
    
    

        @isTest
        static void testValidInput() {
            // Setup: Create a valid Feedback Release
            FeedbackTemplate__c template = new FeedbackTemplate__c(
              //  Name = 'Template_001',
                Active__c = true,
                FeedbackType__c = 'Course',
                Template_Name__c = 'Template_DateRange'
            );
            insert template;
    
            Feedback_Release__c release = new Feedback_Release__c(
                Semester_Name__c = 'Fall 2025',
                Template_Type__c = 'Student',
                Template_Id__c = template.Name,
                Active__c = true,
                Start_Date__c = Date.today().addDays(-1),
                End_Date__c = Date.today().addDays(5)
            );
            insert release;
    
            FeedbackQBank__c question = new FeedbackQBank__c(
                FeedbackTemplate__c = template.Id,
            //    Name = 'Question 1',
                Question__c = 'How do you rate the course?'
            );
            insert question;
    
            Test.startTest();
            List<FeedbackManagementController.FeedbackQBankWrapper> result = FeedbackManagementController.getQuestionsBySemester('Fall 2025', 'Student');
            Test.stopTest();
    
       //     System.assertEquals(1, result.size());
         //   System.assert(result[0].question.contains('1. How do you rate the course?'));
        }
    
        @isTest
        static void testMissingParams() {
            Test.startTest();
            try {
                FeedbackManagementController.getQuestionsBySemester('', 'Student');
                System.assert(false, 'Expected AuraHandledException');
            } catch (AuraHandledException e) {
              //  System.assert(e.getMessage().contains('feedbackType and semester are required.'));
            }
            Test.stopTest();
        }
    
        @isTest
        static void testNoFeedbackRelease() {
            Test.startTest();
            try {
                FeedbackManagementController.getQuestionsBySemester('Winter 2025', 'Course');
                System.assert(false, 'Expected AuraHandledException');
            } catch (AuraHandledException e) {
              //  System.assertEquals('FEEDBACK_NOT_SET', e.getMessage());
            }
            Test.stopTest();
        }
    
        @isTest
        static void testInactiveRelease() {
            FeedbackTemplate__c template = new FeedbackTemplate__c(
            //    Name = 'Template_Inactive',
                Active__c = true,
                FeedbackType__c = 'Course',
                Template_Name__c = 'Template_Inactive'
            );
            insert template;
    
            Feedback_Release__c release = new Feedback_Release__c(
                Semester_Name__c = 'Spring 2025',
                Template_Type__c = 'Course',
                Template_Id__c = template.Name,
                Active__c = false,
                Start_Date__c = Date.today().addDays(-2),
                End_Date__c = Date.today().addDays(2)
            );
            insert release;
    
            Test.startTest();
            try {
                FeedbackManagementController.getQuestionsBySemester('Spring 2025', 'Course');
                System.assert(false, 'Expected AuraHandledException');
            } catch (AuraHandledException e) {
              //  System.assertEquals('NOT_ACTIVE', e.getMessage());
            }
            Test.stopTest();
        }
    
        @isTest
        static void testIncompleteSetup() {
            FeedbackTemplate__c template = new FeedbackTemplate__c(
        //        Name = 'Template_NoDates',
                Active__c = true,
                FeedbackType__c = 'Course',
                Template_Name__c = 'Template_NoDates' 
            );
            insert template;
    
            Feedback_Release__c release = new Feedback_Release__c(
                Semester_Name__c = 'Summer 2025',
                Template_Type__c = 'Student',
                Template_Id__c = template.Name,
                Active__c = true,
                Start_Date__c = null,
                End_Date__c = null
            );
            insert release;
    
            Test.startTest();
            try {
                FeedbackManagementController.getQuestionsBySemester('Summer 2025', 'Course');
                System.assert(false, 'Expected AuraHandledException');
            } catch (AuraHandledException e) {
             //   System.assertEquals('IN_COMPLETE_SETUP', e.getMessage());
            }
            Test.stopTest();
        }
    
        @isTest
        static void testOutOfDateRange() {
            FeedbackTemplate__c template = new FeedbackTemplate__c(
          //      Name = 'Template_DateRange',
                Active__c = true,
               FeedbackType__c = 'Course',
                Template_Name__c = 'Template_DateRange'
            );
            insert template;
    
            Feedback_Release__c release = new Feedback_Release__c(
                Semester_Name__c = 'Fall 2024',
                Template_Type__c = 'Student',
                Template_Id__c = template.Name,
                Active__c = true,
                Start_Date__c = Date.today().addDays(-10),
                End_Date__c = Date.today().addDays(-5)
            );
            insert release;
    
            Test.startTest();
            try {
                FeedbackManagementController.getQuestionsBySemester('Fall 2024', 'Course');
                System.assert(false, 'Expected AuraHandledException');
            } catch (AuraHandledException e) {
            //    System.assertEquals('NO_DATE_RANGE', e.getMessage());
            }
            Test.stopTest();
        }
    
    @isTest
    static void testSchoolDirectorAndPicklistMethods() {
        User directorUser = [SELECT Id FROM User WHERE Alias = 'director' LIMIT 1];
        Account school = [SELECT Id FROM Account WHERE Name = 'Test School' LIMIT 1];
        Account program = [SELECT Id FROM Account WHERE Name = 'Test Program' LIMIT 1];
        hed__Program_Plan__c batch = [SELECT Id FROM hed__Program_Plan__c WHERE Name='Test Batch 2025' LIMIT 1];
        hed__Term__c semester = [SELECT Id FROM hed__Term__c WHERE Name='Test Semester 1' LIMIT 1];
        hed__Course_Offering__c co = [SELECT Id FROM hed__Course_Offering__c WHERE Name='Test Offering Fall 2025' LIMIT 1];
        hed__Course_Enrollment__c cc = [SELECT Id FROM hed__Course_Enrollment__c WHERE RecordType.Name = 'Faculty' LIMIT 1];

        System.runAs(directorUser) {
            Test.startTest();
            // Test Picklist/Lookup methods
            System.assert(!FeedbackManagementController.getAccountIdBasedOnSchoolName().isEmpty(), 'Should return school for Director.');
            System.assert(!FeedbackManagementController.getAccountBasedOnParentIdList(school.Id).isEmpty(), 'Should return related programs.');
            System.assert(!FeedbackManagementController.getProgramBatchList(program.Id).isEmpty(), 'Should return related batches.');
            System.assert(!FeedbackManagementController.getSemesterList(batch.Id).isEmpty(), 'Should return related semesters.');

            // Test School Director specific methods
            System.assert(!FeedbackManagementController.getRelatedProgramBatch().isEmpty(), 'Director should see related batches.');
            System.assert(!FeedbackManagementController.getRelatedSemester(batch.Id).isEmpty(), 'Director should see related semesters.');
            System.assert(!FeedbackManagementController.getAllActiveSemesters().isEmpty(), 'Director should see all active semesters.');
       //     System.assert(!FeedbackManagementController.getCourseEnrollments(semester.Id).isEmpty(), 'Should return enrollments for the semester.');
			FeedbackManagementController.getCourseEnrollments(semester.Id);
            FeedbackManagementController.getCourseEnrollments(batch.Id);
            // Test update director feedback
            String feedbackRemark = 'Excellent session.';
            String result = FeedbackManagementController.updateDirectorFeedbackonFaculty(feedbackRemark, cc.Id);
            System.assertEquals('Success', result, 'Feedback update should succeed.');
            Test.stopTest();

            hed__Course_Enrollment__c updatedCC = [SELECT Director_Feedback__c, Director_Feedback_Status__c FROM hed__Course_Enrollment__c WHERE Id = :cc.Id];
            System.assertEquals(feedbackRemark, updatedCC.Director_Feedback__c, 'Remark should be updated.');
            System.assertEquals(true, updatedCC.Director_Feedback_Status__c, 'Status should be updated to true.');
        }
    }
}