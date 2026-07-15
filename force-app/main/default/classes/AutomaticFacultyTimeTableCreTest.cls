@isTest
private class AutomaticFacultyTimeTableCreTest {
    @testSetup
    static void setup() {
        string universityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        String sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        String batchRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        String groupRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
        String facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();

        string academicRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();


        Account objAcc = new Account();
        objAcc.Name = 'Test Account 1';
        objAcc.RecordTypeId = universityRecId;
        insert objAcc;


        Account academicAcc = new Account();
        academicAcc.Name = 'academicAcc acc';
        academicAcc.RecordTypeId = academicRecId;
        academicAcc.ParentId = objAcc.Id;
        insert academicAcc;


        hed__Time_Block__c timeBlock1 = new hed__Time_Block__c(
            Name = 'Test Time Block',
            hed__Educational_Institution__c = academicAcc.Id,
            hed__Start_Time__c = time.newInstance(8, 30, 0, 0),
            hed__End_Time__c = time.newInstance(10, 0, 0, 0),
            Monday__c = true,
            Slot__c = 3,
            Active__c = true
        );
        insert timeBlock1;

        hed__Time_Block__c timeBlock2 = new hed__Time_Block__c(
            Name = 'Test Time Block',
            hed__Educational_Institution__c = academicAcc.Id,
            hed__Start_Time__c = time.newInstance(10, 0, 0, 0),
            hed__End_Time__c = time.newInstance(11, 0, 0, 0),
            Monday__c = true,
            Slot__c = 2,
            Active__c = true
        );
        insert timeBlock2;

        hed__Time_Block__c timeBlock3 = new hed__Time_Block__c(
            Name = 'Test Time Block',
            hed__Educational_Institution__c = academicAcc.Id,
            hed__Start_Time__c = time.newInstance(12, 0, 0, 0),
            hed__End_Time__c = time.newInstance(13, 0, 0, 0),
            Monday__c = true,
            Slot__c = 1,
            Active__c = true
        );
        insert timeBlock3;





        hed__Time_Block__c timeBlock4 = new hed__Time_Block__c(
            Name = 'Test Time Block',
            hed__Educational_Institution__c = academicAcc.Id,
            hed__Start_Time__c = time.newInstance(9, 0, 0, 0),
            hed__End_Time__c = time.newInstance(10, 0, 0, 0),
            Tuesday__c = true,
            Slot__c = 3,
            Active__c = true
        );
        insert timeBlock4;

        hed__Time_Block__c timeBlock6 = new hed__Time_Block__c(
            Name = 'Test Time Block',
            hed__Educational_Institution__c = academicAcc.Id,
            hed__Start_Time__c = Time.newInstance(10, 0, 0, 0),
            hed__End_Time__c = Time.newInstance(11, 0, 0, 0),
            Tuesday__c = true,
            Slot__c = 2,
            Active__c = true
        );
        insert timeBlock6;

        hed__Time_Block__c timeBlock5 = new hed__Time_Block__c(
            Name = 'Test Time Block',
            hed__Educational_Institution__c = academicAcc.Id,
            hed__Start_Time__c = Time.newInstance(12, 0, 0, 0),
            hed__End_Time__c = Time.newInstance(13, 0, 0, 0),
            Tuesday__c = true,
            Slot__c = 1,
            Active__c = true
        );
        insert timeBlock5;


        hed__Time_Block__c breakBlock = new hed__Time_Block__c(
            Name = 'Test Time Block',
            hed__Educational_Institution__c = academicAcc.Id,
            hed__Start_Time__c = time.newInstance(12, 30, 0, 0),
            hed__End_Time__c = time.newInstance(15, 0, 0, 0),
            Monday__c = true,
            Slot__c = 3,
            Active__c = true,
            Break__c = True
        );
        insert breakBlock;

        hed__Time_Block__c freeSlot = new hed__Time_Block__c(
            Name = 'Test Time Block',
            hed__Educational_Institution__c = academicAcc.Id,
            hed__Start_Time__c = time.newInstance(12, 30, 0, 0),
            hed__End_Time__c = time.newInstance(15, 0, 0, 0),
            Friday__c = true,
            Slot__c = 3,
            Active__c = true,
            Break__c = False
        );
        insert freeSlot;


        hed__Facility__c facility = new hed__Facility__c(
            Name = 'Test Facility',
            hed__Account__c = objAcc.Id,
            hed__Facility_Type__c = 'Classroom',
            Block__c = 'A',
            Room__c = '101'
        );
        insert facility;

        hed__Facility__c facility1 = new hed__Facility__c(
            Name = 'Test Facility',
            hed__Account__c = objAcc.Id,
            hed__Facility_Type__c = 'Classroom',
            Block__c = 'A',
            Room__c = '105'
        );
        insert facility1;

        hed__Facility__c facility2 = new hed__Facility__c(
            Name = 'Test Facility',
            hed__Account__c = objAcc.Id,
            hed__Facility_Type__c = 'Laboratory',
            Block__c = 'B',
            Room__c = '102'
        );
        insert facility2;


        hed__Term__c term1 = new hed__Term__c();
        term1.Name = 'Parent Sem-1';
        term1.Section_Number__c = 1;
        term1.hed__Account__c=academicAcc.Id;
        term1.hed__Start_Date__c = Date.today();
        term1.hed__End_Date__c = Date.today().addDays(30);
        term1.Schedule_not_Created__c = true;
        term1.Allow_time_table_replication__c = true;
        insert term1;

        hed__Term__c term2 = new hed__Term__c();
        term2.Name = 'Section-1';
        term2.Section_Number__c  = 1;
        term2.hed__Parent_Term__c = term1.Id;
        term2.RecordTypeId = sectionRtId;
        term2.hed__Account__c=academicAcc.Id;
        insert term2;

        hed__Term__c term3 = new hed__Term__c();
        term3.Name = 'section-2';
        term3.Section_Number__c  = 2;
        term3.hed__Parent_Term__c = term1.Id;
        term3.RecordTypeId = sectionRtId;
        term3.hed__Account__c=academicAcc.Id;
        insert term3;


        hed__Term__c term4 = new hed__Term__c();
        term4.Name = 'Sec-1 Batch 1';
        term4.hed__Parent_Term__c = term2.Id;
        term4.RecordTypeId = batchRtId;
        term4.hed__Account__c=academicAcc.Id;
        insert term4;

        hed__Term__c term5 = new hed__Term__c();
        term5.Name = 'Sec-2 Batch 1';
        term5.hed__Parent_Term__c = term3.Id;
        term5.RecordTypeId = batchRtId;
        term5.hed__Account__c = academicAcc.Id;
        insert term5;





        hed__Course__c course = new hed__Course__c();
        course.Name = 'Test course';
        course.hed__Account__c = objAcc.Id;
        course.Credits__c = 3;
        course.Offered_By_School__c = objAcc.Id;
        course.Credit_Hours__c = 3;
        course.Maximum_External_Marks__c = 100;
        course.Total_Maximum_Marks_IA_External__c = 50;
        course.No_of_IA_s__c = '1';
        course.L_T_P__c='1:2:3';
        insert course;


        hed__Course__c coursePrac = new hed__Course__c();
        coursePrac.Name = 'Test course';
        coursePrac.hed__Account__c = objAcc.Id;
        coursePrac.Credits__c = 3;
        coursePrac.Offered_By_School__c = objAcc.Id;
        coursePrac.Credit_Hours__c = 4;
        coursePrac.Maximum_External_Marks__c = 100;
        coursePrac.Total_Maximum_Marks_IA_External__c = 50;
        coursePrac.No_of_IA_s__c = '1';
        coursePrac.L_T_P__c='1:2:3';
        insert coursePrac;


        hed__Course__c coursetheory = new hed__Course__c();
        coursetheory.Name = 'Test course';
        coursetheory.hed__Account__c = objAcc.Id;
        coursetheory.Credits__c = 3;
        coursetheory.Offered_By_School__c = objAcc.Id;
        coursetheory.Credit_Hours__c = 4;
        coursetheory.Maximum_External_Marks__c = 100;
        coursetheory.Total_Maximum_Marks_IA_External__c = 50;
        coursetheory.No_of_IA_s__c = '1';
        coursetheory.L_T_P__c='1:2:3';
        insert coursetheory;

        hed__Course_Offering__c peParentOffering = new hed__Course_Offering__c();
        peParentOffering.Name = 'Test Course Offer 1';
        peParentOffering.hed__Course__c = course.Id;
        peParentOffering.hed__Term__c = term1.Id;
        peParentOffering.Category__c = 'Professional Elective';
        insert peParentOffering;


        hed__Course_Offering__c courseOffering1 = new hed__Course_Offering__c();
        courseOffering1.Name = 'Test Course Offer 1';
        courseOffering1.hed__Course__c = course.Id;
        courseOffering1.hed__Term__c = term1.Id;
        courseOffering1.Parent_Course_Offering__c = peParentOffering.Id;
        courseOffering1.Category__c = 'Professional Elective';
        insert courseOffering1;


        hed__Term__c term8 = new hed__Term__c();
        term8.Name = 'Test Term 8';
        term8.Group_Number__c = 2;
        term8.hed__Parent_Term__c = term1.Id;
        term8.hed__Account__c= academicAcc.Id;
        term8.RecordTypeId = groupRtId;
        term8.Course_Offering__c = courseOffering1.Id;
        insert term8;

        hed__Course__c openEle = new hed__Course__c();
        openEle.Name = 'Test course';
        openEle.hed__Account__c = objAcc.Id;
        openEle.Credits__c = 3;
        openEle.Offered_By_School__c = objAcc.Id;
        openEle.Credit_Hours__c = 4;
        openEle.Maximum_External_Marks__c = 100;
        openEle.Total_Maximum_Marks_IA_External__c = 50;
        openEle.No_of_IA_s__c = '1';
        openEle.L_T_P__c='1:2:3';
        insert openEle;

        hed__Course_Offering__c opEleeOffering1 = new hed__Course_Offering__c();
        opEleeOffering1.Name = 'Test Course Offer 2';
        opEleeOffering1.hed__Course__c = openEle.Id;
        opEleeOffering1.hed__Term__c = term1.Id;
        opEleeOffering1.Category__c = 'Open Elective';
        insert opEleeOffering1;

        hed__Term__c term9 = new hed__Term__c();
        term9.Name = 'Test Term 9';
        term9.Group_Number__c = 2;
        term9.hed__Parent_Term__c = term1.Id;
        term9.hed__Account__c= academicAcc.Id;
        term9.RecordTypeId = groupRtId;
        term9.Course_Offering__c = opEleeOffering1.Id;
        insert term9;

        hed__Course_Offering__c courseOffering2 = new hed__Course_Offering__c();
        courseOffering2.Name = 'Test Course Offer 2';
        courseOffering2.hed__Course__c = coursetheory.Id;
        courseOffering2.hed__Term__c = term2.Id;
        courseOffering2.Category__c = 'Hardcore Course';
        insert courseOffering2;



        hed__Course_Offering__c courseOffering3 = new hed__Course_Offering__c();
        courseOffering3.Name = 'Test Course Offer 3';
        courseOffering3.hed__Course__c = coursePrac.Id;
        courseOffering3.hed__Term__c = term2.Id;
        courseOffering3.Category__c = 'Practical/Term work';
        insert courseOffering3;


        hed__Course_Offering__c courseOffering4 = new hed__Course_Offering__c();
        courseOffering4.Name = 'Test Course Offer 2';
        courseOffering4.hed__Course__c = coursetheory.Id;
        courseOffering4.hed__Term__c = term3.Id;
        courseOffering4.Category__c = 'Hardcore Course';
        insert courseOffering4;

        hed__Course_Offering__c courseOffering5 = new hed__Course_Offering__c();
        courseOffering5.Name = 'Test Course Offer 3';
        courseOffering5.hed__Course__c = coursePrac.Id;
        courseOffering5.hed__Term__c = term3.Id;
        courseOffering5.Category__c = 'Practical/Term work';
        insert courseOffering5;

        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();

        // --- Professor 3 ---
        Contact professor3 = MSTR_TestDataFactory.createContact('Contact 1');
        professor3.AccountId = objAcc.Id; // Uncomment if you have an objAccount created
        professor3.FirstName = 'Test';
        professor3.LastName = 'Contact 1';
        professor3.Active__c = true;
        professor3.Email = 'prof3ereee@example4.com';
        professor3.hed__WorkEmail__c = 'prof3ereee@example4.com';
        professor3.Employee_Number__c = 'E003';
        professor3.RecordTypeId = recordTypeId;
        insert professor3;

        // --- Professor 1 ---
        Contact professor1 = MSTR_TestDataFactory.createContact('One professor');
        professor1.AccountId = objAcc.Id; // Uncomment if you have an objAccount created
        professor1.FirstName = 'Prof';
        professor1.LastName = 'One professor';
        professor1.Active__c = true;
        professor1.Email = 'prof1wqeqrfwe@1example.com';
        professor1.hed__WorkEmail__c = 'prof1wqeqrfwe@1example.com';
        professor1.Employee_Number__c = 'E001';
        professor1.RecordTypeId = recordTypeId;
        insert professor1;

        // --- Professor 2 ---
        Contact professor2 = MSTR_TestDataFactory.createContact('Two professor');
        professor2.AccountId = objAcc.Id; // Uncomment if you have an objAccount created
        professor2.FirstName = 'Prof';
        professor2.LastName = 'Two professor';
        professor2.Active__c = true;
        professor2.Email = 'prof2dwedew@example2.com';
        professor2.hed__WorkEmail__c = 'prof2dwedew@example2.com';
        professor2.Employee_Number__c = 'E002';
        professor2.RecordTypeId = recordTypeId;
        insert professor2;

        hed__Course_Enrollment__c courseEnrollment1 = new hed__Course_Enrollment__c();
        courseEnrollment1.hed__Course_Offering__c = courseOffering2.Id;
        courseEnrollment1.RecordTypeId = facultyRtId;
        courseEnrollment1.hed__Contact__c = professor1.Id;
        courseEnrollment1.Allotted_Section__c='A';
        courseEnrollment1.Section__c = term2.Id;
        //courseEnrollment1.Allotted_Batch_Number__c = String.valueof(batchTerm.Batch_Number__c);
        insert courseEnrollment1;


        hed__Course_Enrollment__c courseEnrollment2 = new hed__Course_Enrollment__c();
        courseEnrollment2.hed__Course_Offering__c = courseOffering3.Id;
        courseEnrollment2.RecordTypeId = facultyRtId;
        courseEnrollment2.hed__Contact__c = professor2.Id;
        courseEnrollment2.Allotted_Section__c='B';
        courseEnrollment2.Section__c = term5.Id;
        courseEnrollment2.Allotted_Batch_Number__c = String.valueof(term5.Batch_Number__c);
        insert courseEnrollment2;

        hed__Course_Enrollment__c courseEnrollment4 = new hed__Course_Enrollment__c();
        courseEnrollment4.hed__Course_Offering__c = courseOffering3.Id;
        courseEnrollment2.RecordTypeId = facultyRtId;
        courseEnrollment4.hed__Contact__c = professor1.Id;
        courseEnrollment4.Allotted_Section__c='B';
        courseEnrollment4.Section__c = term5.Id;
        courseEnrollment4.Allotted_Batch_Number__c = String.valueof(term5.Batch_Number__c);
        insert courseEnrollment4;



        hed__Course_Enrollment__c courseEnrollment3 = new hed__Course_Enrollment__c();
        courseEnrollment3.hed__Course_Offering__c = courseOffering1.Id;
        courseEnrollment3.RecordTypeId = facultyRtId;
        courseEnrollment3.hed__Contact__c = professor1.Id;
        courseEnrollment3.Allotted_Section__c='A';
        courseEnrollment3.Section__c = term8.Id;
        insert courseEnrollment3;



        hed__Course_Enrollment__c courseEnrollmentOpenEle = new hed__Course_Enrollment__c();
        courseEnrollmentOpenEle.hed__Course_Offering__c = opEleeOffering1.Id;
        courseEnrollmentOpenEle.RecordTypeId = facultyRtId;
        courseEnrollmentOpenEle.hed__Contact__c = professor3.Id;
        courseEnrollmentOpenEle.Allotted_Section__c='A';
        courseEnrollmentOpenEle.Section__c = term9.Id;
        insert courseEnrollmentOpenEle;

        hed__Course_Offering_Schedule__c objcourseSch1 = TT_TestDataFactory.CreateCourseSchedule(opEleeOffering1.id,term3.id);
        objcourseSch1.hed__Start_Time__c =  Time.newInstance(12, 0, 0, 0);
        objcourseSch1.hed__End_Time__c =  Time.newInstance(13, 0, 0, 0);
        objcourseSch1.hed__Monday__c =false;
        objcourseSch1.hed__Tuesday__c =true;
        objcourseSch1.hed__Wednesday__c =false;
        objcourseSch1.hed__Thursday__c = false;
        objcourseSch1.hed__Friday__c =false;
        objcourseSch1.hed__Saturday__c =false;
        objcourseSch1.hed__Sunday__c =false;
        objcourseSch1.hed__Facility__c = facility1.Id;
        objcourseSch1.Faculty_Course_Connection__c = courseEnrollmentOpenEle.Id;
        objcourseSch1.hed__Time_Block__c = timeBlock5.Id;
        objcourseSch1.Date__c = System.Today() +6;
        objcourseSch1.Section__c = term3.Id;
        objcourseSch1.Professor__c = UserInfo.getUserId();
        insert objcourseSch1;




        hed__Course_Offering_Schedule__c objcourseSch2 = TT_TestDataFactory.CreateCourseSchedule(courseOffering2.id,term2.id);
        objcourseSch2.hed__Start_Time__c =  Time.newInstance(12, 0, 0, 0);
        objcourseSch2.hed__End_Time__c =  Time.newInstance(13, 0, 0, 0);
        objcourseSch2.hed__Monday__c =false;
        objcourseSch2.hed__Tuesday__c =true;
        objcourseSch2.hed__Wednesday__c =false;
        objcourseSch2.hed__Thursday__c = false;
        objcourseSch2.hed__Friday__c =false;
        objcourseSch2.hed__Saturday__c =false;
        objcourseSch2.hed__Sunday__c =false;
        objcourseSch2.hed__Facility__c = facility1.Id;
        objcourseSch2.Faculty_Course_Connection__c = courseEnrollment1.Id;
        objcourseSch2.hed__Time_Block__c = timeBlock5.Id;
        objcourseSch2.Date__c = System.Today() +6;
        objcourseSch2.Professor__c = UserInfo.getUserId();
        insert objcourseSch2;



        hed__Course_Offering_Schedule__c objcourseSch3 = TT_TestDataFactory.CreateCourseSchedule(courseOffering2.id,term2.id);
        objcourseSch3.hed__Start_Time__c =  Time.newInstance(12, 30, 0, 0);
        objcourseSch3.hed__End_Time__c =  Time.newInstance(15, 0, 0, 0);
        objcourseSch3.hed__Monday__c = true;
        objcourseSch3.hed__Tuesday__c = false;
        objcourseSch3.hed__Wednesday__c = false;
        objcourseSch3.hed__Thursday__c = false;
        objcourseSch3.hed__Friday__c = false;
        objcourseSch3.hed__Saturday__c = false;
        objcourseSch3.hed__Sunday__c = false;
        objcourseSch3.Break__c = true;
        //objcourseSch3.hed__Facility__c = facili ty1.Id;
        //objcourseSch3.Faculty_Course_Connection__c = courseEnrollment1.Id;
        objcourseSch3.hed__Time_Block__c = breakBlock.Id;
        objcourseSch3.Date__c = System.Today() +6;
        insert objcourseSch3;





        //courseEnrollment4.Allotted_Batch_Number__c = String.valueof(batchTerm.Batch_Number__c);
        // insert courseEnrollment4;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User testUser = new User(
            Username = 'sysadminuser@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;

    }
    @isTest
    static void testGenerateTimetable() {

        User u = [SELECT Id from User WHERE Email = 'sysadminuser@email.com'];
        hed__Term__c term = [SELECT Id, Schedule_not_Created__c, hed__Account__c FROM hed__Term__c WHERE Name = 'Parent Sem-1' LIMIT 1];
        AutomaticFacultyTimeTableCreationCtrl.TimetableData result;
        AutomaticFacultyTimeTableCreationCtrl.TimetableData result2;
       // System.runAs(u) {

            // Call the method
            Test.startTest();
            result = AutomaticFacultyTimeTableCreationCtrl.generateTimetable(term.Id);
            result2 = AutomaticFacultyTimeTableCreationCtrl.getExistingOfferingSchedules(term.Id);
            Test.stopTest();
       // }

        System.assertNotEquals(result.sectionWiseSchedules,null, 'Result should not be null');
        System.assertNotEquals(result2.sectionWiseSchedules,null , 'Result should not be null');
    }
    @isTest
    static void testSaveSchedules() {

        User u = [SELECT Id from User WHERE Email = 'sysadminuser@email.com'];

       // System.runAs(u) {
            hed__Term__c term = [SELECT Id,hed__End_Date__c,hed__Start_Date__c, Schedule_not_Created__c,hed__Account__c FROM hed__Term__c WHERE Name = 'Parent Sem-1' LIMIT 1];
            Test.startTest();
            AutomaticFacultyTimeTableCreationCtrl.TimetableData result = AutomaticFacultyTimeTableCreationCtrl.generateTimetable(term.Id);

            Date startDate = term.hed__Start_Date__c;
            Date endDate   = term.hed__End_Date__c;

            Map<String, List<Date>> dayToDatesMap = new Map<String, List<Date>>();

            Date currentDate = startDate;

            while (currentDate <= endDate) {

                String dayName = DateTime.newInstance(currentDate, Time.newInstance(0,0,0,0)).format('EEEE');

                if (!dayToDatesMap.containsKey(dayName)) {
                    dayToDatesMap.put(dayName, new List<Date>());
                }

                dayToDatesMap.get(dayName).add(currentDate);

                currentDate = currentDate.addDays(1);
            }
            String jsonString = JSON.serialize(result);
            AutomaticFacultyTimeTableCreationCtrl.saveSchedules(term.Id, jsonString ,dayToDatesMap);
            Test.stopTest();
       // }

        hed__Term__c term1 = [SELECT Id,hed__End_Date__c,Schedule_not_Created__c ,hed__Start_Date__c, hed__Account__c FROM hed__Term__c WHERE Name = 'Parent Sem-1' LIMIT 1];
        System.assertEquals(term1.Schedule_not_Created__c, false ,'Schedule_not_Created__c must upadted as false');
    }

}