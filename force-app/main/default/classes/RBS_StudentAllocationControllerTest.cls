@IsTest
private class RBS_StudentAllocationControllerTest {
    // --- Test Setup Method ---
    @TestSetup
    static void setupTestData() {
        // Create necessary Accounts for Program Batch and Specializations
        Account programBatchAcc = new Account(Name = 'Test Program Batch Account', Type = 'University');
        insert programBatchAcc;

        string acaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',acaRecId1 );
        objAccount.RecordTypeid = acaRecId1;
        insert objAccount;

        Account spclAcc1 = new Account(Name = 'Specialization A', Type = 'Academic', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RBS_Specialization').getRecordTypeId());
        Account spclAcc2 = new Account(Name = 'Specialization B', Type = 'Academic', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RBS_Specialization').getRecordTypeId());
        Account spclAccUncategorized = new Account(Name = 'Uncategorized Specialization', Type = 'Academic', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RBS_Specialization').getRecordTypeId());
        insert new List<Account>{spclAcc1, spclAcc2, spclAccUncategorized};

        // Create a Program Batch (hed__Program_Batch__c)
        hed__Program_Plan__c  programBatch = new hed__Program_Plan__c (
            Name = 'Test Program Batch',
            hed__Account__c = programBatchAcc.Id
        );
        insert programBatch;

        // Create a Term
        hed__Term__c testTerm = new hed__Term__c(
            Name = 'Test Term A',
            hed__Account__c = programBatchAcc.Id
        );
        insert testTerm;

        // Create Courses with External IDs
        hed__Course__c course1 = new hed__Course__c(Name = 'Course A', Course_External_ID__c = 'CA001',
            hed__Account__c = objAccount.Id,
            Category__c = 'RBS Specialization',
            HardCore_Sub_Type__c = 'Theory',
            Credits__c = 4,
            Offered_By_School__c = objAccount.Id,
            Credit_Hours__c = 11,
            Maximum_External_Marks__c = 50,
            Total_Maximum_Marks_IA_External__c = 30,
             No_of_IA_s__c = '1',
              L_T_P__c='2:1:0');
        
        
        hed__Course__c course2 = new hed__Course__c(Name = 'Course B', Course_External_ID__c = 'CB002',
            hed__Account__c = objAccount.Id,
            Category__c = 'RBS Specialization',
            HardCore_Sub_Type__c = 'Theory',
            Credits__c = 4,
            Offered_By_School__c = objAccount.Id,
            Credit_Hours__c = 11,
            Maximum_External_Marks__c = 50,
            Total_Maximum_Marks_IA_External__c = 30,
             No_of_IA_s__c = '1',
              L_T_P__c='2:1:0');
        insert new List<hed__Course__c>{course1, course2};

        // Create Course Offerings
        // Course Offerings for Specialization A
        hed__Course_Offering__c co1spclA = new hed__Course_Offering__c(
            Name = 'CO A - Spcl A',
            hed__Term__c = testTerm.Id,
            Category__c = 'RBS Specialization',
            Specialization__c = spclAcc1.Id,
            Active__c = true,
            Assigned__c = 10,
            Sequence__c = 1,
            hed__Course__c = course1.Id
        );
        hed__Course_Offering__c co2spclA = new hed__Course_Offering__c(
            Name = 'CO B - Spcl A',
            hed__Term__c = testTerm.Id,
            Category__c = 'RBS Specialization',
            Specialization__c = spclAcc1.Id,
            Active__c = false,
            Assigned__c = 5,
            Sequence__c = 2,
            hed__Course__c = course2.Id
        );

        // Course Offering for Specialization B
        hed__Course_Offering__c co3spclB = new hed__Course_Offering__c(
            Name = 'CO C - Spcl B',
            hed__Term__c = testTerm.Id,
            Category__c = 'RBS Specialization',
            Specialization__c = spclAcc2.Id,
            Active__c = true,
            Assigned__c = 15,
            Sequence__c = 1,
            hed__Course__c = course1.Id
        );

        // Course Offering with no Specialization (will map to 'Uncategorized')
        hed__Course_Offering__c co4uncategorized = new hed__Course_Offering__c(
            Name = 'CO D - Uncat',
            hed__Term__c = testTerm.Id,
            Category__c = 'RBS Specialization', // Still within the categorySet for query
            Specialization__c = null, // Explicitly null for uncategorized test
            Active__c = true,
            Assigned__c = 8,
            Sequence__c = 3,
            hed__Course__c = course2.Id
        );

        insert new List<hed__Course_Offering__c>{co1spclA, co2spclA, co3spclB, co4uncategorized};

        // Create Contacts
        Contact studentContact1 = new Contact(FirstName = 'Student', LastName = 'One', Email = 'student1@example.com');
        Contact studentContact2 = new Contact(FirstName = 'Student', LastName = 'Two', Email = 'student2@example.com');
        Contact studentContact3 = new Contact(FirstName = 'Student', LastName = 'Three', Email = 'student3@example.com');
        insert new List<Contact>{studentContact1, studentContact2, studentContact3};

        // Create Program Enrollments
        hed__Program_Enrollment__c  pe1 = new hed__Program_Enrollment__c (
            //Name = 'PE-001',
            hed__Contact__c = studentContact1.Id,
            Semester__c = testTerm.Id,
            RBS_Specialization_1__c = spclAcc1.Id,
            SRN_Number__c = 'SRN123',
            Section__c = testTerm.Id
        );
        hed__Program_Enrollment__c pe2 = new hed__Program_Enrollment__c(
            //Name = 'PE-002',
            hed__Contact__c = studentContact2.Id,
            Semester__c = testTerm.Id,
            RBS_Specialization_2__c = spclAcc1.Id, // Student in Spcl A via Spec 2 field
            Application_Number__c = 'APP456', // Test Application_Number__c when SRN_Number__c is null
            Section__c = testTerm.Id
        );
         hed__Program_Enrollment__c pe3 = new hed__Program_Enrollment__c(
            //Name = 'PE-003',
            hed__Contact__c = studentContact3.Id,
            Semester__c = testTerm.Id,
            RBS_Specialization_1__c = spclAcc2.Id, // Student in Spcl B
            SRN_Number__c = 'SRN789',
            Section__c = testTerm.Id
        );
        hed__Program_Enrollment__c pe4noContact = new hed__Program_Enrollment__c(
            //Name = 'PE-004',
            Semester__c = testTerm.Id,
            RBS_Specialization_1__c = spclAcc1.Id,
            SRN_Number__c = 'SRN000'
        );

        insert new List<hed__Program_Enrollment__c>{pe1, pe2, pe3, pe4noContact};

        // Create an existing Course Enrollment for upsert testing
        hed__Course_Enrollment__c existingCE = new hed__Course_Enrollment__c(
            External_Id__c = pe1.SRN_Number__c + '_' + co1spclA.Id,
            hed__Course_Offering__c = co1spclA.Id,
            hed__Program_Enrollment__c = pe1.Id,
            Section__c = co1spclA.hed__Term__c,
            Logisys_External_Id__c = pe1.SRN_Number__c + course1.Course_External_ID__c,
            Semester_ID__c = co1spclA.hed__Term__c,
            hed__Contact__c = studentContact1.Id
        );
        insert existingCE;


        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];

        User testUser = new User(
            Username = 'sysadminuser444@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            EmployeeNumber = 'REVA92002',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;
    }


    @IsTest
    static void testDisplayCourseOfferingRecordsSuccess() {
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        // Get test data
        hed__Term__c testTerm = [SELECT Id FROM hed__Term__c LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            RBS_StudentAllocationController.CourseOfferingWrapper result =
                RBS_StudentAllocationController.displayCourseOfferingRecords(testTerm.Id);
        Test.stopTest();



        System.assertNotEquals(null, result, 'Wrapper should not be null.');
        System.assertNotEquals(null, result.termName, 'Term Name should be populated.');
        System.assertNotEquals(null, result.lstCourseOffrData, 'lstCourseOffrData should not be null.');

        // Verify specific categories and counts
        System.assert(result.mapCourseOfferingdata.containsKey('Specialization A'), 'Map should contain Specialization A');
        System.assertEquals(2, result.mapCourseOfferingdata.get('Specialization A').size(), 'Specialization A should have 2 offerings');
        System.assert(result.mapCourseOfferingdata.containsKey('Specialization B'), 'Map should contain Specialization B');
        System.assertEquals(1, result.mapCourseOfferingdata.get('Specialization B').size(), 'Specialization B should have 1 offering');
        System.assert(result.mapCourseOfferingdata.containsKey('Uncategorized'), 'Map should contain Uncategorized');
        System.assertEquals(1, result.mapCourseOfferingdata.get('Uncategorized').size(), 'Uncategorized should have 1 offering');

        // Verify data correctness for a sample CO
        RBS_StudentAllocationController.CourseOfferingdata sampleCO = result.mapCourseOfferingdata.get('Specialization A')[0];
        System.assertNotEquals(null, sampleCO.courseOfferingId, 'CO ID should not be null');
        System.assertEquals('CO A - Spcl A', sampleCO.Name, 'CO Name should match');
        System.assertEquals(true, sampleCO.active, 'CO Active status should be true');
        System.assertEquals('Specialization A', sampleCO.parentCourseOfferingName, 'parentCourseOfferingName should match Specialization A');
        System.assertNotEquals(null, sampleCO.specializationId, 'specializationId should not be null');
        }
    }

    @IsTest
    static void testDisplayCourseOfferingRecordsNoCourseOfferings() {
        // Create a new term with no associated course offerings
        /*hed__Term__c  newTerm = new hed__Term__c (Name = 'Empty Term', Program_Batch__c  = [SELECT Id FROM Program_Batch__c  LIMIT 1].Id);
        insert newTerm;*/
        Id accountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
         Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = accountRecTypeId;
        insert objAcc;

         Account objAcc1 = ASM_TestDataFactory.createAcc(12);
        objAcc1.ParentId= objAcc.id;
        insert objAcc1;

         hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc1.id;
        insert objProgPlan;


        hed__Term__c newTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        newTerm.Program_Batch__c  = objProgPlan.id;
        newTerm.hed__Start_Date__c = system.today()-15;
        newTerm.hed__End_Date__c =  system.today()+15;
        insert newTerm;
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            RBS_StudentAllocationController.CourseOfferingWrapper result =
                RBS_StudentAllocationController.displayCourseOfferingRecords(newTerm.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Wrapper should not be null.');
        System.assertNotEquals(null, result.ProgramPlanName, 'Program Plan Name should be populated.');
        System.assert(result.mapCourseOfferingdata.isEmpty(), 'mapCourseOfferingdata should be empty.');
        System.assertNotEquals(null, result.lstCourseOffrData, 'lstCourseOffrData should not be null.');
        System.assert(result.lstCourseOffrData.isEmpty(), 'lstCourseOffrData should be empty.');
        }
    }

    @IsTest
    static void testGetRBSstudentsbySpclSuccess() {
        // Get test data
        hed__Term__c testTerm = [SELECT Id FROM hed__Term__c LIMIT 1];
        Account spclAcc1 = [SELECT Id FROM Account WHERE Name = 'Specialization A' LIMIT 1];

        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            List<RBS_StudentAllocationController.RBSStudentWrapper> students =
                RBS_StudentAllocationController.getRBSstudentsbySpcl(spclAcc1.Id, testTerm.Id);
        Test.stopTest();

        System.assertNotEquals(null, students, 'Students list should not be null.');
        System.assertEquals(2, students.size(), 'Two students should be returned for Specialization A.');

        RBS_StudentAllocationController.RBSStudentWrapper student1 = students[0];
        System.assertEquals('Student One', student1.contactName, 'Contact name should match.');
        System.assertEquals('SRN123', student1.srnNumber, 'SRN Number should match.');
        System.assertEquals(spclAcc1.Id, student1.spclId, 'Specialization ID should match.');

        RBS_StudentAllocationController.RBSStudentWrapper student2 = students[1];
        System.assertEquals('Student Two', student2.contactName, 'Contact name should match.');
        System.assertEquals('APP456', student2.srnNumber, 'SRN Number should fallback to Application Number.');
        }
    }

	@IsTest
    static void testGetRBSstudentsbySpclInvalidInput() {
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            List<RBS_StudentAllocationController.RBSStudentWrapper> studentsNullSpcl =
                RBS_StudentAllocationController.getRBSstudentsbySpcl(null, 'aTermId');
            List<RBS_StudentAllocationController.RBSStudentWrapper> studentsBlankSpcl =
                RBS_StudentAllocationController.getRBSstudentsbySpcl('', 'aTermId');
            List<RBS_StudentAllocationController.RBSStudentWrapper> studentsNullTerm =
                RBS_StudentAllocationController.getRBSstudentsbySpcl('aSpclId', null);
            List<RBS_StudentAllocationController.RBSStudentWrapper> studentsBlankTerm =
                RBS_StudentAllocationController.getRBSstudentsbySpcl('aSpclId', '');
        Test.stopTest();


        System.assertEquals(0, studentsNullSpcl.size(), 'Should return empty list for null spclId.');
        System.assertEquals(0, studentsBlankSpcl.size(), 'Should return empty list for blank spclId.');
        System.assertEquals(0, studentsNullTerm.size(), 'Should return empty list for null termId.');
        System.assertEquals(0, studentsBlankTerm.size(), 'Should return empty list for blank termId.');
        }
    }

    @IsTest
    static void testCreateCourseConnectionsSuccessInsertAndUpdate() {
                Account spclAccB = [SELECT Id FROM Account WHERE Name = 'Specialization B' LIMIT 1];

        hed__Term__c testTerm = [SELECT Id FROM hed__Term__c LIMIT 1];
        Account spclAcc1 = [SELECT Id FROM Account WHERE Name = 'Specialization A' LIMIT 1];
        Contact studentContact1 = [SELECT Id, Name FROM Contact WHERE LastName = 'One' LIMIT 1];
        Contact studentContact3 = [SELECT Id, Name FROM Contact WHERE LastName = 'Three' LIMIT 1];
        hed__Program_Enrollment__c pe1 = [SELECT Id, SRN_Number__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentContact1.Id LIMIT 1];
        hed__Program_Enrollment__c pe3 = [SELECT Id, SRN_Number__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentContact3.Id LIMIT 1];
        hed__Course_Offering__c co1spclA = [SELECT Id, hed__Course__r.Course_External_ID__c FROM hed__Course_Offering__c WHERE Name = 'CO A - Spcl A' LIMIT 1];
        hed__Course_Offering__c co3spclB = [SELECT Id, hed__Course__r.Course_External_ID__c FROM hed__Course_Offering__c WHERE Name = 'CO C - Spcl B' LIMIT 1];

        // Prepare student data for JSON (one for update, one for insert)
        List<RBS_StudentAllocationController.RBSStudentWrapper> students = new List<RBS_StudentAllocationController.RBSStudentWrapper>();

        // Student 1 for update (for CO A - Spcl A)
        RBS_StudentAllocationController.RBSStudentWrapper sw1 = new RBS_StudentAllocationController.RBSStudentWrapper();
        sw1.contactId = studentContact1.Id;
        sw1.contactName = studentContact1.Name;
        sw1.programEnrId = pe1.Id;
        sw1.srnNumber = pe1.SRN_Number__c;
        sw1.spclId = spclAcc1.Id;
        students.add(sw1);

        // Student 3 for insert (for CO C - Spcl B)
        RBS_StudentAllocationController.RBSStudentWrapper sw2 = new RBS_StudentAllocationController.RBSStudentWrapper();
        sw2.contactId = studentContact3.Id;
        sw2.contactName = studentContact3.Name;
        sw2.programEnrId = pe3.Id;
        sw2.srnNumber = pe3.SRN_Number__c;
        sw2.spclId = spclAccB.Id; // Specialization B
        students.add(sw2);

        String studentJson = JSON.serialize(students);
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            String status = RBS_StudentAllocationController.createCourseConnections(studentJson, testTerm.Id);
        Test.stopTest();


        System.assertEquals('Success', status, 'Status should be Success for mixed operations.');

        // Verify that existing CE was handled (no new CE for it)
        Integer existingCERecords = [SELECT COUNT() FROM hed__Course_Enrollment__c WHERE External_Id__c = :pe1.SRN_Number__c + '_' + co1spclA.Id];
        System.assertEquals(1, existingCERecords, 'Existing Course Enrollment should still be one record.');

        // Verify new CE was inserted for Student 3 (Specialization B)
        Integer newCERecords = [SELECT COUNT() FROM hed__Course_Enrollment__c WHERE hed__Program_Enrollment__c = :pe3.Id AND hed__Course_Offering__c = :co3spclB.Id];
        System.assertEquals(1, newCERecords, 'New Course Enrollment should be inserted for Student 3 and Spcl B.');
        }
    }

    @IsTest
    static void testCreateCourseConnectionsEmptyStudentJson() {
        hed__Term__c testTerm = [SELECT Id FROM hed__Term__c LIMIT 1];
        String studentJson = '[]'; // Empty JSON array

        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {

        Test.startTest();
            String status = RBS_StudentAllocationController.createCourseConnections(studentJson, testTerm.Id);
        Test.stopTest();


        System.assertEquals('Failed', status, 'Status should be Failed for empty student JSON.');
        }
    }

    @IsTest
    static void testCreateCourseConnectionsNoOfferingsForSpecialization() {
        hed__Term__c testTerm = [SELECT Id FROM hed__Term__c LIMIT 1];
        Contact studentContact1 = [SELECT Id FROM Contact WHERE LastName = 'One' LIMIT 1];
        hed__Program_Enrollment__c pe1 = [SELECT Id, SRN_Number__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentContact1.Id LIMIT 1];

        // Create a new specialization with no associated course offerings for the term
        Account spclAccNoOfferings = new Account(Name = 'Specialization No Offerings', Type = 'Academic', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RBS_Specialization').getRecordTypeId());
        insert spclAccNoOfferings;

        List<RBS_StudentAllocationController.RBSStudentWrapper> students = new List<RBS_StudentAllocationController.RBSStudentWrapper>();
        RBS_StudentAllocationController.RBSStudentWrapper sw1 = new RBS_StudentAllocationController.RBSStudentWrapper();
        sw1.contactId = studentContact1.Id;
        sw1.programEnrId = pe1.Id;
        sw1.srnNumber = pe1.SRN_Number__c;
        sw1.spclId = spclAccNoOfferings.Id; // This specialization has no offerings
        students.add(sw1);

        String studentJson = JSON.serialize(students);

        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            String status = RBS_StudentAllocationController.createCourseConnections(studentJson, testTerm.Id);
        Test.stopTest();


        System.assertEquals('Failed', status, 'Status should be Failed if no offerings found for specialization.');
        // Verify no new Course Enrollments are created
        System.assertEquals(1, [SELECT COUNT() FROM hed__Course_Enrollment__c], 'No new Course Enrollments should be created.');
        }
    }

    @IsTest
    static void testCreateCourseConnectionsPartialSuccess() {
        hed__Term__c testTerm = [SELECT Id FROM hed__Term__c LIMIT 1];
        Account spclAcc1 = [SELECT Id FROM Account WHERE Name = 'Specialization A' LIMIT 1];
        Contact studentContact1 = [SELECT Id FROM Contact WHERE LastName = 'One' LIMIT 1];
        Contact studentContact3 = [SELECT Id FROM Contact WHERE LastName = 'Three' LIMIT 1];
        hed__Program_Enrollment__c pe1 = [SELECT Id, SRN_Number__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentContact1.Id LIMIT 1];
        hed__Program_Enrollment__c pe3 = [SELECT Id, SRN_Number__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :studentContact3.Id LIMIT 1];
        hed__Course_Offering__c co1spclA = [SELECT Id FROM hed__Course_Offering__c WHERE Name = 'CO A - Spcl A' LIMIT 1];

        List<RBS_StudentAllocationController.RBSStudentWrapper> students = new List<RBS_StudentAllocationController.RBSStudentWrapper>();

        // Valid student data (will succeed)
        RBS_StudentAllocationController.RBSStudentWrapper sw1 = new RBS_StudentAllocationController.RBSStudentWrapper();
        sw1.contactId = studentContact1.Id;
        sw1.programEnrId = pe1.Id;
        sw1.srnNumber = pe1.SRN_Number__c;
        sw1.spclId = spclAcc1.Id;
        students.add(sw1);

        // Invalid student data (will cause a failure, e.g., missing contactId which is checked by continue in loop)
        RBS_StudentAllocationController.RBSStudentWrapper swInvalid = new RBS_StudentAllocationController.RBSStudentWrapper();
        swInvalid.programEnrId = pe3.Id; // Provide some ID to make it deserialize
        swInvalid.srnNumber = 'INVALIDSRN';
        swInvalid.spclId = spclAcc1.Id;
        // swInvalid.contactId = null; // Explicitly make it invalid for `continue`
        students.add(swInvalid); // This one will be skipped by `if (String.isBlank(sw.contactId))`

        String studentJson = JSON.serialize(students);
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            // Test.setMock(Database.UpsertResult.class, new MockUpsertResult()); // If you want to mock upsert results
            String status = RBS_StudentAllocationController.createCourseConnections(studentJson, testTerm.Id);
        Test.stopTest();
        }
    }

     @IsTest
    static void testCreateCourseConnectionsExceptionHandling() {
        hed__Term__c testTerm = [SELECT Id FROM hed__Term__c LIMIT 1];
        String studentJson = 'This is not valid JSON';
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            String status = RBS_StudentAllocationController.createCourseConnections(studentJson, testTerm.Id);
        Test.stopTest();
        }
    }


    @IsTest
    static void testActivateCourseOfferingActivate() {
        hed__Course_Offering__c co = [SELECT Id, Active__c FROM hed__Course_Offering__c WHERE Name = 'CO B - Spcl A' LIMIT 1];

        RBS_StudentAllocationController.CourseOfferingdata data = new RBS_StudentAllocationController.CourseOfferingdata();
        data.courseOfferingId = co.Id;
        data.active = true; // Set to activate

        String jsonInput = JSON.serialize(data);
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {

        Test.startTest();
            RBS_StudentAllocationController.WrapperClass result = RBS_StudentAllocationController.activateCourseOffering(jsonInput);
        Test.stopTest();

        System.assertEquals('Success', result.strMessage, 'Message should be Success.');
        hed__Course_Offering__c updatedCo = [SELECT Id, Active__c FROM hed__Course_Offering__c WHERE Id = :co.Id];
        System.assertEquals(true, updatedCo.Active__c, 'Active__c should be true after activation.');
        }
    }

    @IsTest
    static void testActivateCourseOfferingDeactivate() {
        hed__Course_Offering__c co = [SELECT Id, Active__c FROM hed__Course_Offering__c WHERE Name = 'CO A - Spcl A' LIMIT 1];
        System.assertEquals(true, co.Active__c, 'Initial Active__c should be true.');

        RBS_StudentAllocationController.CourseOfferingdata data = new RBS_StudentAllocationController.CourseOfferingdata();
        data.courseOfferingId = co.Id;
        data.active = false; // Set to deactivate

        String jsonInput = JSON.serialize(data);
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            RBS_StudentAllocationController.WrapperClass result = RBS_StudentAllocationController.activateCourseOffering(jsonInput);
        Test.stopTest();


        System.assertEquals('Success', result.strMessage, 'Message should be Success.');
        hed__Course_Offering__c updatedCo = [SELECT Id, Active__c FROM hed__Course_Offering__c WHERE Id = :co.Id];
        System.assertEquals(false, updatedCo.Active__c, 'Active__c should be false after deactivation.');
        }
    }

    @IsTest
    static void testActivateCourseOfferingInvalidId() {
        RBS_StudentAllocationController.CourseOfferingdata data = new RBS_StudentAllocationController.CourseOfferingdata();
        data.courseOfferingId = 'a00xxxxxxxxxxxxxxx'; // Invalid/non-existent ID
        data.active = true;

        String jsonInput = JSON.serialize(data);

        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {

        Test.startTest();
            RBS_StudentAllocationController.WrapperClass result = RBS_StudentAllocationController.activateCourseOffering(jsonInput);
        Test.stopTest();
        System.assert(result.strMessage.contains('Error:'), 'Message should indicate an error.');
        }
    }

    @IsTest
    static void testActivateCourseOfferingMissingCourseOfferingId() {
        RBS_StudentAllocationController.CourseOfferingdata data = new RBS_StudentAllocationController.CourseOfferingdata();
        // data.courseOfferingId is intentionally left null
        data.active = true;

        String jsonInput = JSON.serialize(data);
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            RBS_StudentAllocationController.WrapperClass result = RBS_StudentAllocationController.activateCourseOffering(jsonInput);
        Test.stopTest();
        System.assertEquals('Error: Missing courseOfferingId', result.strMessage, 'Message should indicate missing ID.');
        }
    }

    @IsTest
    static void testActivateCourseOfferingNullInput() {
        String jsonInput = null;
        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            RBS_StudentAllocationController.WrapperClass result = RBS_StudentAllocationController.activateCourseOffering(jsonInput);
        Test.stopTest();

        System.assert(result.strMessage.contains('Error:'), 'Message should indicate an error.');
        }
    }

    @IsTest
    static void testActivateCourseOfferingBadJson() {
        String jsonInput = '{ "courseOfferingId": "abc", "active": true, '; // Malformed JSON

        User testUser = [SELECT Id FROM User WHERE Username = 'sysadminuser444@test.com' LIMIT 1];
        System.runAs(testUser) {
        Test.startTest();
            RBS_StudentAllocationController.WrapperClass result = RBS_StudentAllocationController.activateCourseOffering(jsonInput);
        Test.stopTest();


        System.assert(result.strMessage.contains('Error:'), 'Message should indicate an error.');
        System.assert(result.strMessage.contains('Unexpected end-of-input'), 'Error message should mention JSON parsing error.');
        }
    }
}