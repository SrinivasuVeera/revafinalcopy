@IsTest
private class OpenElectiveProfessorAllotment_CtrlTest {
    @TestSetup
    static void setupData(){
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;

        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();

        Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount2.Parentid = objAccount1.id;
        objAccount2.RecordTypeid = AcaRecId1;
        insert objAccount2;

        string AcaUniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId );
        objAccount.Parentid = objAccount2.id;
        objAccount.RecordTypeid = AcaUniRecId ;
        insert objAccount;
        hed__Course__c cur = new hed__Course__c();
        cur.Name = 'Test Course';
        cur.hed__Course_ID__c = 'T1';
        cur.hed__Credit_Hours__c = 80;
        cur.Category__c = 'Open Elective';
        cur.Credits__c = 4;
        cur.hed__Account__c = objAccount.id;
        cur.HardCore_Sub_Type__c = 'Project';
        cur.Offered_By_School__c = objAccount.Id;
        cur.Credit_Hours__c = 04.00;
        cur.Maximum_External_Marks__c = 50;
        cur.Total_Maximum_Marks_IA_External__c = 60;
        insert cur;


        hed__Term__c termH = new hed__Term__c();
        termH.Name = 'Test TermH';
        termH.RecordTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
        termH.hed__Start_Date__c = System.Today()-5;
        termH.hed__Account__c = objAccount.id;
        termH.hed__End_Date__c = System.Today()+5;
        insert termH;



        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',termH.id,cur.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Term__c term = new hed__Term__c();
        term.Name = 'Test Term';
        term.RecordTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Group Allocation').getRecordTypeId();
        term.hed__Parent_Term__c = termH.Id;
        term.hed__Account__c = objAccount.id;
        term.Course_Offering__c = objCourseOff1.Id;
        insert term;

   /* Id facultyRecordTypeId = Schema.SObjectType.Course_Connection__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();

    // Create Course Connection related to Course Offering & Contact
    Course_Connection__c courseConn = new Course_Connection__c(
        hed__Contact__c = facultyContact.Id,
        RecordTypeId = facultyRecordTypeId,
        hed__Course_Offering__c = objCourseOff1.Id
    );
    insert courseConn; */
    Account parentAcc = new Account(Name = 'ParentAccount');
    insert parentAcc;

    Account instAcc = new Account(
        Name = 'Institution',
        ParentId = parentAcc.Id,
        RecordTypeid = AcaUniRecId
    );
    insert instAcc;

    hed__Term__c parentSem = new hed__Term__c(
        Name = 'ParentSem',
        hed__Start_Date__c = Date.today(),
        hed__End_Date__c = Date.today().addDays(7),
        hed__Account__c = instAcc.Id,
        Schedule_not_Created__c = true,
        Create_Open_Elective_timetable__c = true
    );
    insert parentSem;

    hed__Course__c course = new hed__Course__c(Name = 'Physics');
        course.hed__Course_ID__c = 'T1';
        course.hed__Credit_Hours__c = 80;
        course.Category__c = 'Open Elective';
        course.Credits__c = 4;
        course.hed__Account__c = instAcc.id;
        course.HardCore_Sub_Type__c = 'Project';
        course.Offered_By_School__c = instAcc.Id;
        course.Credit_Hours__c = 04.00;
        course.Maximum_External_Marks__c = 50;
        course.Total_Maximum_Marks_IA_External__c = 60;
    insert course;

    hed__Course_Offering__c parentOffering = new hed__Course_Offering__c(
        Name = 'PhysicsParentOffering-1',
        Category__c = 'Open Elective',
        hed__Term__c = parentSem.Id,
        hed__Course__c = course.Id
    );
    insert parentOffering;

    hed__Course_Offering__c offering = new hed__Course_Offering__c(
        Name = 'PhysicsOffering',
        hed__Course__c = course.Id,
        Parent_Course_Offering__c = parentOffering.Id,
        hed__Term__c = parentSem.Id,
        Category__c = 'Open Elective'
    );
    insert offering;

    Contact faculty = new Contact(
        LastName = 'ProfA',
        Email = 'profA@test.com'
    );
    insert faculty;

    Id gaRT = Schema.SObjectType.hed__Term__c
        .getRecordTypeInfosByName()
        .get('Group Allocation')
        .getRecordTypeId();

    hed__Term__c groupAlloc = new hed__Term__c(
        Name = 'GA1',
        RecordTypeId = gaRT,
        hed__Parent_Term__c = parentSem.Id,
        Course_Offering__c = offering.Id,
        hed__Account__c = instAcc.Id
    );
    insert groupAlloc;

    Id facultyRT = Schema.SObjectType.hed__Course_Enrollment__c
        .getRecordTypeInfosByName()
        .get('Faculty')
        .getRecordTypeId();

    hed__Course_Enrollment__c cc = new 	hed__Course_Enrollment__c(
        RecordTypeId = facultyRT,
        Section__c = groupAlloc.Id,
        Faculty__c = faculty.Id
    );
    insert cc;

     hed__Facility__c facility = new hed__Facility__c(
        Name = 'Room101',
        hed__Account__c = parentAcc.Id
    );
    insert facility;

    hed__Time_Block__c tb1 = new hed__Time_Block__c(
        Name = 'TB-Mon-1',
        Slot__c = 1,
        Active__c = true,
        Break__c = false,
        hed__Educational_Institution__c = instAcc.Id,
        hed__Start_Time__c = Time.newInstance(9, 0, 0, 0),
        hed__End_Time__c = Time.newInstance(10, 0, 0, 0),
        Monday__c = true
    );
    insert tb1;

    hed__Time_Block__c tb2 = new hed__Time_Block__c(
        Name = 'TB-Tue-2',
        Slot__c = 2,
        Active__c = true,
        Break__c = false,
        hed__Educational_Institution__c = instAcc.Id,
        hed__Start_Time__c = Time.newInstance(10, 0, 0, 0),
        hed__End_Time__c = Time.newInstance(11, 0, 0, 0),
        Tuesday__c = true
    );
    insert tb2;
    }

    @IsTest
    static void testGetCourses() {
        Test.startTest();
        List<hed__Course__c> courses = OpenElectiveProfessorAllotment_Ctrl.getCourses('Test' ,'Open Elective');
        Test.stopTest();
        System.assertEquals(1, courses.size(), 'Expected one course to be returned');
    }

    @IsTest
    static void testGetSemesters() {
        Test.startTest();
        List<hed__Term__c> semesters = OpenElectiveProfessorAllotment_Ctrl.getSemesters([SELECT Id FROM hed__Course__c LIMIT 1].Id);
        Test.stopTest();
        System.assertEquals(1, semesters.size(), 'Expected one semester to be returned');
    }

    @IsTest
    static void testGetFaculty() {
        Test.startTest();
        List<Contact> faculty = OpenElectiveProfessorAllotment_Ctrl.getFaculty('Test');
        Test.stopTest();
        System.assertEquals(0, faculty.size(), 'Expected no faculty to be returned');
    }

    @IsTest
    static void testCreateFacultyCourseConnections() {
        hed__Term__c term = [SELECT Id,Name FROM hed__Term__c WHERE Name ='Test Term' LIMIT 1];
        Test.startTest();
        Id profContactRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Professor'];


       /* Contact professor = new Contact(
            FirstName = 'Johnjjfj',
            LastName = 'Doe33rr3',
            Active__c = true,
            RecordTypeId = profContactRTId,
            Employee_Number__c ='EP1237yywey',
            hed__WorkEmail__c  = 'test16767233ttettw@ex.com'
        );
        insert professor; */
        Account objAcc = [SELECT Id FROM Account WHERE Name ='Test Account1' LIMIT 1];

        Contact professor = MSTR_TestDataFactory.createContact('test2 Contact');
        professor.AccountId = objAcc.id;
        professor.FirstName  = 'Tst2 Con';
        professor.LastName  ='LtCon2345';
        professor.Active__c = true;
        professor.RecordTypeId = profContactRTId;
        professor.Employee_Number__c  ='EP1341';
        professor.hed__WorkEmail__c  = 'TestCon220001@reva.edu.in';
        insert professor;

        User objUser = new User(
            LastName = 'Te testing',
            FirstName ='testing',
            alias = 'testng',
            Email = 'test16767233ttettw@ex.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            UserName='test16767233ttettw@ex.com',
            EmployeeNumber ='EP1237yywey'
        );

        insert objUser;


        OpenElectiveProfessorAllotment_Ctrl.respwrp wrapperObj = new OpenElectiveProfessorAllotment_Ctrl.respwrp();
        wrapperObj.semesterName = term.Name;
        wrapperObj.Professor = professor.Id;
        wrapperObj.courseconnection = term.Id;

        List<OpenElectiveProfessorAllotment_Ctrl.respwrp> wrapperList = new List<OpenElectiveProfessorAllotment_Ctrl.respwrp>();
        wrapperList.add(wrapperObj);

        String facultyConnections = JSON.serialize(wrapperList);


        OpenElectiveProfessorAllotment_Ctrl.createFacultyCourseConnections(facultyConnections);
        Test.stopTest();

        // Verify that the Course Enrollment was created
        // List<hed__Course_Enrollment__c> connections = [
        //     SELECT Id, hed__Contact__c, Section__c
        //     FROM hed__Course_Enrollment__c
        // ];
        //System.assertEquals(2, connections.size(), 'One Course Enrollment should have been created for the professor.');

    }
    @IsTest
    static void testTimeTableCeation(){
        /*hed__Term__c term = [SELECT Id,Name FROM hed__Term__c WHERE Name ='Test Term' LIMIT 1];
        Id profContactRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1].Id;
        Id termGroupAllocationRId = [SELECT Id FROM RecordType WHERE SObjectType = 'hed__Term__c' AND Name = 'Group Allocation' LIMIT 1].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Professor'];
        Account objAcc = [SELECT Id FROM Account WHERE Name ='Test Account1' LIMIT 1];*/
        String jsonInput = '[{"day":"Monday","slot":1},{"day":"Tuesday","slot":2}]';

        Test.startTest();
        OpenElectiveProfessorAllotment_Ctrl.generateTimetable(jsonInput);
        Test.stopTest();
    }

}