@isTest
private class RBSstudentSpclCollectionCtrlTest {

    // Setup method to create test data
    @TestSetup
    static void setupTestData() {
        
        
        string acaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Master of Business Administration',acaRecId1 );
        objAccount.RecordTypeid = acaRecId1;
        insert objAccount;

        string rbsSpclRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RBS Specialization').getRecordTypeId();
        Account objAccount3 = MSTR_TestDataFactory.CreateAccount('Marketing Specialization',rbsSpclRecordType );
        objAccount3.RecordTypeid = rbsSpclRecordType;
        objAccount3.ParentId = objAccount.Id;
        insert objAccount3;
        
        Account objAccount5 = MSTR_TestDataFactory.CreateAccount('Finance Specialization',rbsSpclRecordType );
        objAccount5.RecordTypeid = rbsSpclRecordType;
        objAccount5.ParentId = objAccount.Id;
        insert objAccount5;


        string acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household ).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Marketing Specialization44',acaRecId);
        objAccount1.RecordTypeid = acaRecId;
        insert objAccount1;
        string acaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household ).getRecordTypeId();
        Account objAccount12 = MSTR_TestDataFactory.CreateAccount('Finance Specialization45',acaRecId2);
        objAccount12.RecordTypeid = acaRecId2;
        insert objAccount12;

        // Create Contact
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = new Contact(
            LastName = 'Test Contact',
            AccountId = objAccount3.Id,
            Professor_Across_Schools__c = true,
            Application_Number__c = '123',
            hed__WorkEmail__c = 'testuser@reva.edu.in',
            Email = 'testuser@reva.edu.in',
            Employee_Number__c = 'REVA100101',
            MobilePhone = '8963210547',
            RecordTypeId = contactRecTypeId
        );
        insert objCon;


        // Create User linked to Contact
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1 ];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@reva.edu.in',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            EmployeeNumber = 'REVA100101',
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'testuser' + Math.random() + '@reva.edu.in',
            ContactId = objCon.Id
        );
        insert testUser;


        // Create Program Plan
        hed__Program_Plan__c objProgPlan = new hed__Program_Plan__c(
            Name = 'Test Program Plan',
            Provisionally_Admitted_Students__c = 20,
            Intake__c = 20,
            Intake_Per_Section__c = 5
        );
        insert objProgPlan;


        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        // Create Term
        hed__Term__c objTerm = new hed__Term__c(
            Name = 'Fall 2025',
            hed__Account__c = objAccount3.Id,
            RecordTypeId = termRtId,
            Program_Batch__c = objProgPlan.Id,
            hed__Start_Date__c = System.today(),
            hed__End_Date__c = System.today() +1,
            
            Term_Number__c = 1
        );
        insert objTerm;

        // Update Contact with Active Semester
        objCon.Active_Semester__c = objTerm.Id;
        update objCon;

        // Create Program Enrollment
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount1.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id;
        objProgEnroll.Application_Number__c ='123';
         objProgEnroll.hed__Contact__c = objCon.Id;
        objProgEnroll.Section__c = objTerm.id;
        objProgEnroll.RBS_Specialization_1__c = objAccount3.Id;
        objProgEnroll.RBS_Specialization_2__c = objAccount5.Id;
        insert objProgEnroll;

        // Create Program Enrollment without specializations for saveSpeclOnEnrollment test
        hed__Program_Enrollment__c emptyProgEnroll = new hed__Program_Enrollment__c(
            //hed__Contact__c = objCon.Id,
            hed__Account__c = objAccount3.Id,
            hed__Program_Plan__c = objProgPlan.Id,
            Section__c = objTerm.Id
        );
        insert emptyProgEnroll;

        // Create Course
        hed__Course__c objCourse = new hed__Course__c(
            Name = 'Business Analytics',
            hed__Account__c = objAccount.Id,
            Category__c = 'RBS Specialization',
            HardCore_Sub_Type__c = 'Theory',
            Credits__c = 4,
            Offered_By_School__c = objAccount.Id,
            Credit_Hours__c = 11,
            Maximum_External_Marks__c = 50,
            Total_Maximum_Marks_IA_External__c = 30,
            No_of_IA_s__c = '1',
        L_T_P__c='2:1:0'
        );
        insert objCourse;

        // Create Course Offering
        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'RBS Specialization';
        objCourseOff.Sequence__c =1;
        objCourseOff.Specialization__c = objAccount3.id;
        objCourseOff.Active__c =true;
        objCourseOff.Assigned__c = 2;
        insert objCourseOff;
    }

    @isTest
    static void testGetRBSspecializations() {

         User u = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in'  LIMIT 1];
         System.runAs(u){
            Test.startTest();
            List<Account> specializations = RBSstudentSpclCollectionCtrl.getRBSspecializations();
            System.assertEquals(true, specializations.size()>0, 'Expected one or more specialization');
            Test.stopTest();
         }

    }

    @isTest
    static void testGetCoursesBySpecializations() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];

        System.runAs(testUser) {
            // Retrieve specialization IDs
            List<Account> specs = [SELECT Id FROM Account WHERE RecordType.Name = 'RBS Specialization'];
            List<Id> specIds = new List<Id>();
            for (Account spec : specs) {
                specIds.add(spec.Id);
            }
            Test.startTest();
            Map<Id, List<hed__Course_Offering__c>> coursesMap = RBSstudentSpclCollectionCtrl.getCoursesBySpecializations(specIds);
            Test.stopTest();
            System.assertEquals(1, coursesMap.values().Size(), 'Courses map should not be null');
            System.assertNotEquals(null, coursesMap, 'Courses map should not be null');
        }
    }

    @isTest
    static void testGetCoursesBySpecializationsEmptyInput() {
        // Run as the test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<Id, List<hed__Course_Offering__c>> coursesMap = RBSstudentSpclCollectionCtrl.getCoursesBySpecializations(new List<Id>());
            Test.stopTest();

            System.assertEquals(0, coursesMap.size(), 'Expected empty map for empty specialization IDs');
        }
    }

    @isTest
    static void testIsSpecializationsExist() {
        // Run as the test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Boolean exists = RBSstudentSpclCollectionCtrl.isSpecializationsExist();
            System.assertEquals(true, exists, 'Specializations should exist');

            Test.stopTest();

        }
    }

    @isTest
    static void testIsSpecializationsExistNoSpecializations() {
        // Delete program enrollments with specializations
        delete [SELECT Id FROM hed__Program_Enrollment__c WHERE RBS_Specialization_1__c != null];

        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Boolean exists = RBSstudentSpclCollectionCtrl.isSpecializationsExist();
            Test.stopTest();

            System.assertEquals(false, exists, 'Specializations should not exist');
        }
    }

    @isTest
    static void testSaveSpeclOnEnrollment() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
         
            // Retrieve specialization IDs
            Account spec1 = [SELECT Id FROM Account WHERE Name = 'Finance Specialization' LIMIT 1];
            Account spec2 = [SELECT Id FROM Account WHERE Name = 'Marketing Specialization' LIMIT 1];
        
         hed__Program_Enrollment__c updatedEnrollments1 = [
                SELECT RBS_Specialization_1__c, RBS_Specialization_2__c
                FROM hed__Program_Enrollment__c
                WHERE RBS_Specialization_1__c = :spec2.Id AND RBS_Specialization_2__c = :spec1.Id];
        
        updatedEnrollments1.RBS_Specialization_1__c = null;
        updatedEnrollments1.RBS_Specialization_2__c = null;
        
        update updatedEnrollments1;
        
           System.runAs(testUser) {
            // Run as the test user
            String result;
       
            Test.startTest();

                result = RBSstudentSpclCollectionCtrl.saveSpeclOnEnrollment(spec1.Id, spec2.Id);

            Test.stopTest();

            // Verify the program enrollment was updated
            List<hed__Program_Enrollment__c> updatedEnrollments = [
                SELECT RBS_Specialization_1__c, RBS_Specialization_2__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c = :[SELECT ContactId FROM User WHERE Id = :testUser.Id].ContactId
                AND RBS_Specialization_1__c = :spec1.Id
            ];

            System.assertEquals('Success', result, 'Expected success message');
           // System.assertEquals(true, updatedEnrollments.size()>1, 'Expected one updated enrollment');
        }
    }

    @isTest
    static void testSaveSpeclOnEnrollmentNoRecords() {
        // Delete program enrollments with null specializations
        delete [SELECT Id FROM hed__Program_Enrollment__c WHERE RBS_Specialization_1__c = null];

        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            String result = RBSstudentSpclCollectionCtrl.saveSpeclOnEnrollment(null, null);
            Test.stopTest();

            System.assertEquals('No records to update', result, 'Expected no records to update');
        }
    }

    @isTest
    static void testGetCourseOfferingsBySpcl() {
        // Run as the test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            List<hed__Course_Offering__c> courseOfferings = RBSstudentSpclCollectionCtrl.getCourseOfferingsBySpcl();
            System.assertEquals(true, courseOfferings.size()>=1, 'Expected one course offering');
            Test.stopTest();

        }
    }

    @isTest
    static void testGetCourseOfferingsBySpclNoOfferings() {
        // Delete course offerings
        delete [SELECT Id FROM hed__Course_Offering__c];

        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            List<hed__Course_Offering__c> courseOfferings = RBSstudentSpclCollectionCtrl.getCourseOfferingsBySpcl();
            Test.stopTest();

            System.assertEquals(0, courseOfferings.size(), 'Expected empty course offerings list');
        }
    }

    @isTest
    static void testGetSpclNamesFromEnrollment() {
        // Run as the test user
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            List<hed__Program_Enrollment__c> enrollments = RBSstudentSpclCollectionCtrl.getSpclNamesFromEnrollment();
            System.assertEquals(true, enrollments.size()>0, 'Expected one or more program enrollments');
            Test.stopTest();

        }
    }

    @isTest
    static void testGetSpclNamesFromEnrollmentNoEnrollments() {
        // Delete program enrollments
        delete [SELECT Id FROM hed__Program_Enrollment__c];

        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@reva.edu.in' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            List<hed__Program_Enrollment__c> enrollments = RBSstudentSpclCollectionCtrl.getSpclNamesFromEnrollment();
            Test.stopTest();

            System.assertEquals(0, enrollments.size(), 'Expected empty program enrollment list');
        }
    }

}