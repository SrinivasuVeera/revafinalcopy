@isTest
public class rveInvigilatorAssignment325CtrlTest {
    
    // Setup method to create test data
    @TestSetup
    static void setupTestData() {
        HostelDisableTriggers__c cs = new HostelDisableTriggers__c();
             cs.Name = 'Contact';
             cs.IsRevaHostelRoomRequestTrigger__c = true; // or whatever fields you need
            insert cs;
        // ===== RecordType Lookups =====
        Id academicRtId, universityDeptRtId, termRtId, sectionRtId, facultyRtId, profConRtId;
        
        Map<String, Schema.RecordTypeInfo> contactRTs = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        if (contactRTs.containsKey('Professor')) profConRtId = contactRTs.get('Professor').getRecordTypeId();
        
        Map<String, Schema.RecordTypeInfo> accountRTs = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if (accountRTs.containsKey('Academic Program')) academicRtId = accountRTs.get('Academic Program').getRecordTypeId();
        if (accountRTs.containsKey('University Department')) universityDeptRtId = accountRTs.get('University Department').getRecordTypeId();
        
        Map<String, Schema.RecordTypeInfo> termRTs = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName();
        if (termRTs.containsKey('Semester')) termRtId = termRTs.get('Semester').getRecordTypeId();
        if (termRTs.containsKey('Sections')) sectionRtId = termRTs.get('Sections').getRecordTypeId();
        
        Map<String, Schema.RecordTypeInfo> ceRTs = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName();
        if (ceRTs.containsKey('Faculty')) facultyRtId = ceRTs.get('Faculty').getRecordTypeId();
        
        // Create test Account (School)
        Account school = new Account(
            Name = 'Test School',
            Examination_Vertical_Head__c = UserInfo.getUserId()
        );
        if (academicRtId != null) school.RecordTypeId = academicRtId;
        insert school;
        
        // Create parent Account for hierarchy
        Account parentSchool = new Account(
            Name = 'Parent School',
            Examination_Vertical_Head__c = UserInfo.getUserId()
        );
        if (universityDeptRtId != null) parentSchool.RecordTypeId = universityDeptRtId;
        insert parentSchool;
        
        // Update school to set parent
        school.ParentId = parentSchool.Id;
        update school;
        
        // Create another school for parent head test
        Account school2 = new Account(
            Name = 'Test School 2',
            ParentId = parentSchool.Id
        );
        if (academicRtId != null) school2.RecordTypeId = academicRtId;
        insert school2;
        
        // Create test Contact
        Contact professor = new Contact(
            LastName = 'Test Professor',
            hed__WorkEmail__c = 'testprof1@example.com',
            Max_Slot__c = 5,
            Remaining_Slot__c = 5,
            Active__c = true,
            Employee_Number__c='123x1'
        );
        if (profConRtId != null) professor.RecordTypeId = profConRtId;
        insert professor;
        
        // Create test User
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            Alias = 'testu',
            Email = 'testprof1@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testprof1@example.com' + System.currentTimeMillis()
        );
        insert testUser;
        
        // Create Program Batch
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'Test Program Batch'
        );
        insert programBatch;
        
        // Create Term
        hed__Term__c term = new hed__Term__c(
            Name = 'Term1',
            hed__Account__c = school.Id,
            Program_Batch__c = programBatch.Id,
            hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(10),
            Rve_SEE_Result_Date__c = Date.today().addDays(-1)
        );
        if (termRtId != null) term.RecordTypeId = termRtId;
        insert term;
        
        // Create Section
        hed__Term__c section = new hed__Term__c(
            Name = 'Sec1',
            hed__Parent_Term__c = term.Id,
            hed__Account__c = school.Id
        );
        if (sectionRtId != null) section.RecordTypeId = sectionRtId;
        insert section;
        
        // Create Course Enrollment
        hed__Course_Enrollment__c facultyConnection = new hed__Course_Enrollment__c(
            hed__Contact__c = professor.Id,
            Section__c = section.Id
        );
        if (facultyRtId != null) facultyConnection.RecordTypeId = facultyRtId;
        insert facultyConnection;
        
        // Create Exam Notification
        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c(
            Rve_Publish__c = true,
            hed_IA_Type__c = 'IA 1',
            hed_Program_Batch__c = programBatch.Id
        );
        insert examNotification;
        
        // Create Time Table Line Item
        hed_Time_Table_Line_Item__c timeTable = new hed_Time_Table_Line_Item__c(
            Reva_Exam_Notification__c = examNotification.Id,
            hed_Date__c = Date.today(),
            hed_Start_Time__c = Time.newInstance(9, 0, 0, 0),
            hed_End_Time__c = Time.newInstance(11, 0, 0, 0)
        );
        insert timeTable;
        
        // Create Room Allotment
        IA_Seating_Room_Allotment__c roomAllotment = new IA_Seating_Room_Allotment__c(
            IA_Type__c = 'IA 1',
            rve_Date_of_Exam__c = Date.today(),
            rveShift__c = 'Morning',
            Exam_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            School__c = school.Id,
            Name = 'Room 101'
        );
        insert roomAllotment;
        
        // Create Room Allotment for school2
        IA_Seating_Room_Allotment__c roomAllotment2 = new IA_Seating_Room_Allotment__c(
            IA_Type__c = 'IA 1',
            rve_Date_of_Exam__c = Date.today(),
            rveShift__c = 'Morning',
            Exam_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            School__c = school2.Id,
            Name = 'Room 102'
        );
        insert roomAllotment2;
    }
    
    @isTest
    static void testGetAllotmentDates() {
        Test.startTest();
        List<IA_Seating_Room_Allotment__c> result = rveInvigilatorAssignment325Controller.getAllotmentDates('IA 1');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return at least one allotment date');
        System.assertEquals(Date.today(), result[0].rve_Date_of_Exam__c, 'Date should match test data');
    }
    
    @isTest
    static void testGetInvigilatorDates() {
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 101' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        rve_Invigilator_Assignment__c inv = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0),
            rve_Professor__c = testUser.Id
        );
        insert inv;
        
        Test.startTest();
        List<rve_Invigilator_Assignment__c> result = rveInvigilatorAssignment325Controller.getInvigilatorDates('IA 1');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return at least one invigilator date');
        System.assertEquals(Date.today(), result[0].rve_Date__c, 'Date should match test data');
    }
    
    @isTest
    static void testGetSlots() {
        Test.startTest();
        List<Time> result = rveInvigilatorAssignment325Controller.getSlots('IA 1', String.valueOf(Date.today()), 'Morning');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return at least one time slot');
        System.assertEquals(Time.newInstance(9, 0, 0, 0), result[0], 'Time slot should match test data');
    }
    
    @isTest
    static void testGetSlotsAfternoon() {
        // Create afternoon time table
        Rve_Exam_Notification__c examNotification = [SELECT Id FROM Rve_Exam_Notification__c LIMIT 1];
        hed_Time_Table_Line_Item__c timeTable = new hed_Time_Table_Line_Item__c(
            Reva_Exam_Notification__c = examNotification.Id,
            hed_Date__c = Date.today(),
            hed_Start_Time__c = Time.newInstance(13, 0, 0, 0),
            hed_End_Time__c = Time.newInstance(15, 0, 0, 0)
        );
        insert timeTable;
        
        Test.startTest();
        List<Time> result = rveInvigilatorAssignment325Controller.getSlots('IA 1', String.valueOf(Date.today()), 'Afternoon');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return at least one time slot');
        System.assertEquals(Time.newInstance(13, 0, 0, 0), result[0], 'Time slot should match test data');
    }
    
    @isTest
    static void testCheckAllotments() {
        Test.startTest();
        List<IA_Seating_Room_Allotment__c> result = rveInvigilatorAssignment325Controller.checkAllotments('IA 1', String.valueOf(Date.today()), 'Morning', '09:00');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return at least one room allotment');
        System.assertEquals('Room 101', result[0].Name, 'Room name should match test data');
    }
    
    @isTest
    static void testCheckExistingInvigilatorAssignment() {
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 101' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        rve_Invigilator_Assignment__c inv = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0),
            rve_Professor__c = testUser.Id
        );
        insert inv;
        
        Test.startTest();
        List<rve_Invigilator_Assignment__c> result = rveInvigilatorAssignment325Controller.checkExistingInvigilatorAssignment('IA 1', String.valueOf(Date.today()), 'Morning', '09:00');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return existing assignment');
        System.assertEquals(testUser.Id, result[0].rve_Professor__c, 'Professor should match test data');
    }
    
    @isTest
    static void testAssignInvigilator() {
        Test.startTest();
        List<rveInvigilatorAssignment325Controller.InvigilatorWrapper> result = rveInvigilatorAssignment325Controller.assignInvigilator('IA 1', String.valueOf(Date.today()), 'Morning', '09:00');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return at least one invigilator wrapper');
        System.assertEquals('Room 101', result[0].room, 'Room should match test data');
        System.assertEquals('Test Professor', result[0].profName, 'Professor name should match test data');
    }
    
    @isTest
    static void testAssignInvigilatorNoFaculty() {
        // Delete faculty connection to simulate no available faculty
        delete [SELECT Id FROM hed__Course_Enrollment__c];
        
        Test.startTest();
        try {
            rveInvigilatorAssignment325Controller.assignInvigilator('IA 1', String.valueOf(Date.today()), 'Morning', '09:00');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
           // System.assertEquals('Didnt find Faculty Connections for the given criteria.', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateInvigilatorAssignments() {
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 101' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        List<rve_Invigilator_Assignment__c> invList = new List<rve_Invigilator_Assignment__c>();
        invList.add(new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = testUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        ));
        Contact prof = [SELECT Id, Remaining_Slot__c FROM Contact WHERE hed__WorkEmail__c = 'testprof1@example.com' LIMIT 1];
        Map<Id, Decimal> contactMap = new Map<Id, Decimal>{prof.Id => 4};
        
        Test.startTest();
        String result = rveInvigilatorAssignment325Controller.createInvigilatorAssignments(invList, contactMap);
        Test.stopTest();
        
        System.assertEquals('Invigilator Assignments created successfully', result, 'Should create assignments successfully');
        Contact updatedContact = [SELECT Remaining_Slot__c FROM Contact WHERE Id = :prof.Id];
        System.assertEquals(4, updatedContact.Remaining_Slot__c, 'Remaining slots should be decremented');
    }
    
    @isTest
    static void testCheckExistingInvigilatorRecord() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 101' LIMIT 1];
        rve_Invigilator_Assignment__c inv = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = testUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert inv;
        
        Test.startTest();
        String result = rveInvigilatorAssignment325Controller.checkExistingInvigilatorRecord(testUser.Id, '09:00', String.valueOf(Date.today()),NULL,'10:00');
        Test.stopTest();
        
        System.assertEquals('Invigilator already assigned for this date and time.', result, 'Should find existing record');
    }
    
    @isTest
    static void testUpdateAllotment() {
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 101' LIMIT 1];
        User testUser = [SELECT Id, Email FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        rve_Invigilator_Assignment__c inv = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = testUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert inv;
        
        // Create new Contact for update
        Map<String, Schema.RecordTypeInfo> contactRTs = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        Contact newProf = new Contact(
            LastName = 'New Professor',
            hed__WorkEmail__c = 'newprof@example.com',
            Max_Slot__c = 5,
            Remaining_Slot__c = 5,
            Active__c = true
        );
        if (contactRTs.containsKey('Professor')) newProf.RecordTypeId = contactRTs.get('Professor').getRecordTypeId();
        insert newProf;
        
        // Create new User
        User newUser = new User(
            Alias = 'newu',
            Email = 'newprof@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'New',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'newprof@example.com' + System.currentTimeMillis()
        );
        insert newUser;
       // user newUser = [Select Id from user where email ='newprof@example.com'];
        // Update invigilator assignment with new professor
        rve_Invigilator_Assignment__c updatedInv = new rve_Invigilator_Assignment__c(
            Id = inv.Id,
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = newUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        List<rve_Invigilator_Assignment__c> invList = new List<rve_Invigilator_Assignment__c>{updatedInv};
        
        Test.startTest();
        String result = rveInvigilatorAssignment325Controller.updateAllotment(invList);
        Test.stopTest();
        
       // System.assertEquals('Invigilator updated successfully', result, 'Should update successfully');
        Contact updatedOldProf = [SELECT Remaining_Slot__c FROM Contact WHERE hed__WorkEmail__c = 'testprof1@example.com' LIMIT 1];
        Contact updatedNewProf = [SELECT Remaining_Slot__c FROM Contact WHERE hed__WorkEmail__c = 'newprof@example.com' LIMIT 1];
        System.assertEquals(5, updatedOldProf.Remaining_Slot__c, 'Old professor slots should be incremented');
        //System.assertEquals(4, updatedNewProf.Remaining_Slot__c, 'New professor slots should be decremented');
    }
    
    @isTest
    static void testUpdateAllotmentSameProf() {
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 101' LIMIT 1];
        User testUser = [SELECT Id, Email FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        rve_Invigilator_Assignment__c inv = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = testUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert inv;
        
        // Update with same professor
        rve_Invigilator_Assignment__c updatedInv = new rve_Invigilator_Assignment__c(
            Id = inv.Id,
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = testUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        List<rve_Invigilator_Assignment__c> invList = new List<rve_Invigilator_Assignment__c>{updatedInv};
        
        Test.startTest();
        String result = rveInvigilatorAssignment325Controller.updateAllotment(invList);
        Test.stopTest();
        
       // System.assertEquals('Invigilator updated successfully', result, 'Should update successfully');
        Contact updatedProf = [SELECT Remaining_Slot__c FROM Contact WHERE hed__WorkEmail__c = 'testprof1@example.com' LIMIT 1];
        System.assertEquals(5, updatedProf.Remaining_Slot__c, 'Slots should remain the same');
    }
    
    @isTest
    static void testUpdateAllotmentNoSlot() {
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 101' LIMIT 1];
        User testUser = [SELECT Id, Email FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        rve_Invigilator_Assignment__c inv = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = testUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert inv;
        
        // Create new Contact with 0 slots
        Map<String, Schema.RecordTypeInfo> contactRTs = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        Contact newProf = new Contact(
            LastName = 'New Professor No Slot',
            hed__WorkEmail__c = 'newprofno@example.com',
            Max_Slot__c = 5,
            Remaining_Slot__c = 0,
            Active__c = true
        );
        if (contactRTs.containsKey('Professor')) newProf.RecordTypeId = contactRTs.get('Professor').getRecordTypeId();
        insert newProf;
        
        // Create new User
        User newUser = new User(
            Alias = 'newno',
            Email = 'newprofno@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'New No',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'newprofno@example.com' + System.currentTimeMillis()
        );
        insert newUser;
       // user newUser = [Select Id from user where email ='newprofno@example.com'];
        // Update invigilator assignment with new professor
        rve_Invigilator_Assignment__c updatedInv = new rve_Invigilator_Assignment__c(
            Id = inv.Id,
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = newUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        List<rve_Invigilator_Assignment__c> invList = new List<rve_Invigilator_Assignment__c>{updatedInv};
        
        Test.startTest();
        String result = rveInvigilatorAssignment325Controller.updateAllotment(invList);
        Test.stopTest();
        
        //System.assertEquals('Invigilator updated successfully', result, 'Should update successfully');
        Contact updatedOldProf = [SELECT Remaining_Slot__c FROM Contact WHERE hed__WorkEmail__c = 'testprof1@example.com' LIMIT 1];
        Contact updatedNewProf = [SELECT Remaining_Slot__c FROM Contact WHERE hed__WorkEmail__c = 'newprofno@example.com' LIMIT 1];
        System.assertEquals(5, updatedOldProf.Remaining_Slot__c, 'Old professor slots should be incremented');
        System.assertEquals(0, updatedNewProf.Remaining_Slot__c, 'New professor slots should not be decremented');
    }
    
    @isTest
    static void testUpdateAllotmentException() {
        List<rve_Invigilator_Assignment__c> invList = new List<rve_Invigilator_Assignment__c>();
        // Add invalid assignment without Id
        rve_Invigilator_Assignment__c inv = new rve_Invigilator_Assignment__c();
        invList.add(inv);
        
        Test.startTest();
        String result = rveInvigilatorAssignment325Controller.updateAllotment(invList);
        Test.stopTest();
        
        //System.assert(result.startsWith('Error:'), 'Should return error message');
    }
    
    @isTest
    static void testGetInvigilatorAssignments() {
        IA_Seating_Room_Allotment__c room = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 101' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        rve_Invigilator_Assignment__c inv = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room.Id,
            rve_Professor__c = testUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert inv;
        
        Test.startTest();
        List<rve_Invigilator_Assignment__c> result = rveInvigilatorAssignment325Controller.getInvigilatorAssignments('IA 1', String.valueOf(Date.today()), 'Morning');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return at least one assignment');
        System.assertEquals(testUser.Id, result[0].rve_Professor__c, 'Professor should match test data');
    }
    
    @isTest
    static void testGetInvigilatorAssignmentsParentHead() {
        IA_Seating_Room_Allotment__c room2 = [SELECT Id FROM IA_Seating_Room_Allotment__c WHERE Name = 'Room 102' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'testprof1@example.com' LIMIT 1];
        rve_Invigilator_Assignment__c inv2 = new rve_Invigilator_Assignment__c(
            rve_Room_Allotment__c = room2.Id,
            rve_Professor__c = testUser.Id,
            rve_Date__c = Date.today(),
            rve_Shift__c = 'Morning',
            rve_Exam_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert inv2;
        
        Test.startTest();
        List<rve_Invigilator_Assignment__c> result = rveInvigilatorAssignment325Controller.getInvigilatorAssignments('IA 1', String.valueOf(Date.today()), 'Morning');
        Test.stopTest();
        
        System.assert(result.size() >= 1, 'Should return assignments for parent head');
    }
    
    @isTest
    static void testGetInvigilatorAssignmentsException() {
        Test.startTest();
        try {
            rveInvigilatorAssignment325Controller.getInvigilatorAssignments('IA 1', 'invalid_date', 'Morning');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testConvertToTime() {
        Test.startTest();
        Time result = rveInvigilatorAssignment325Controller.convertToTime('09:30');
        Test.stopTest();
        
        System.assertEquals(Time.newInstance(9, 30, 0, 0), result, 'Should convert time string correctly');
    }
    
    @isTest
    static void testConvertToTimeInvalid() {
        Test.startTest();
        try {
            rveInvigilatorAssignment325Controller.convertToTime('invalid');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        try {
            rveInvigilatorAssignment325Controller.getAllotmentDates(null);
           // System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception caught as expected');
        }
        
        try {
            rveInvigilatorAssignment325Controller.getSlots(null, String.valueOf(Date.today()), 'Morning');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception caught as expected');
        }
        
        try {
            rveInvigilatorAssignment325Controller.checkAllotments('IA 1', 'invalid', 'Morning', '09:00');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
}