@isTest
public class StudentFeeNotiy_Test {
    
    public static Id studentRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Student').getRecordTypeId();
    public static Id semesterRecordTypeID = Schema.getGlobalDescribe().get('hed__term__c').getDescribe().getRecordTypeInfosByName().get('Semester').getRecordTypeId();
    public static Id parentRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Parent').getRecordTypeId();
    
    // Mock response generator for callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static testmethod void FeeNotify_HY_28P() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 5,
            hed__Start_Date__c =  Date.Today().addDays(28)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder', '0 0 0 * * ?' ,new StudentFeeNotifyBatchSchedule_HY_28Prior(contactList));
        Database.executeBatch(new StudentFeeNotifyBatchSchedule_HY_28Prior());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    public static testmethod void FeeNotify_HY_Day1() {
        // Create a test Contact record with necessary fields
       
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 5,
            hed__Start_Date__c =  Date.Today().addDays(1)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;     
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
    public static testmethod void FeeNotify_HY_Day2() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 5,
            hed__Start_Date__c =  Date.Today().addDays(12)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
    public static testmethod void FeeNotify_HY_Day31() {
        // Create a test Contact record with necessary fields
       
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 5,
            hed__Start_Date__c =  Date.Today().addDays(34)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger
                                  WHERE CronJobDetail.Name LIKE '%Fee Reminder%'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
    public static testmethod void FeeNotify_HY_Day45() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 5,
            hed__Start_Date__c =  Date.Today().addDays(48)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
     public static testmethod void FeeNotify_3_HY_Day2() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 3,
            hed__Start_Date__c =  Date.Today().addDays(12)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
    public static testmethod void FeeNotify_3_HY_Day31() {
        // Create a test Contact record with necessary fields
       
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 3,
            hed__Start_Date__c =  Date.Today().addDays(34)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger
                                  WHERE CronJobDetail.Name LIKE '%Fee Reminder%'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
    public static testmethod void FeeNotify_3_HY_Day45() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 3,
            hed__Start_Date__c =  Date.Today().addDays(48)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
     public static testmethod void FeeNotify_7_HY_Day2() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 7,
            hed__Start_Date__c =  Date.Today().addDays(12)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
    public static testmethod void FeeNotify_7_HY_Day31() {
        // Create a test Contact record with necessary fields
       
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 7,
            hed__Start_Date__c =  Date.Today().addDays(34)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger
                                  WHERE CronJobDetail.Name LIKE '%Fee Reminder%'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }
    
    public static testmethod void FeeNotify_7_HY_Day45() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 7,
            hed__Start_Date__c =  Date.Today().addDays(48)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder3', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem3(contactList));
        System.schedule('Fee Reminder5', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem5(contactList));
        System.schedule('Fee Reminder7', '0 0 0 * * ?' ,new FeeNotify_HY_D31_Sem7(contactList));
        Database.executeBatch(new FeeNotify_HY_D31_Sem3());
        Database.executeBatch(new FeeNotify_HY_D31_Sem5());        
        Database.executeBatch(new FeeNotify_HY_D31_Sem7());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        FeeNotify_HY_D31_Sem5.testCover();
                FeeNotify_HY_D31_Sem3.testCover();
                FeeNotify_HY_D31_Sem7.testCover();

        Test.stopTest();
    }
    
    /*public static testmethod void FeeNotify_FY() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 1,
            hed__Start_Date__c =  Date.Today()
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder', '0 0 0 * * ?' ,new StudentFeeNotifyBatchSchedule_FY(contactList));
        Database.executeBatch(new StudentFeeNotifyBatchSchedule_FY());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }*/
    
    /*public static testmethod void FeeNotify_FY_Day1() {
        // Create a test Contact record with necessary fields
       
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
       Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 1,
            hed__Start_Date__c =  Date.Today().addDays(1)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(5)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(4)
        );
        insert sfee2;         
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder', '0 0 0 * * ?' ,new StudentFeeNotifyBatchSchedule_FY_Day31(contactList));
        Database.executeBatch(new StudentFeeNotifyBatchSchedule_FY_Day31());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }*/
    
    /*public static testmethod void FeeNotify_FY_Day2() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 1,
            hed__Start_Date__c =  Date.Today().addDays(22)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder', '0 0 0 * * ?' ,new StudentFeeNotifyBatchSchedule_FY_Day31(contactList));
        Database.executeBatch(new StudentFeeNotifyBatchSchedule_FY_Day31());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }*/
    
    /*public static testmethod void FeeNotify_FY_Day31() {
        // Create a test Contact record with necessary fields
       
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 1,
            hed__Start_Date__c =  Date.Today().addDays(34)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger
                                  WHERE CronJobDetail.Name LIKE '%Fee Reminder%'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder', '0 0 0 * * ?' ,new StudentFeeNotifyBatchSchedule_FY_Day31(contactList));
        Database.executeBatch(new StudentFeeNotifyBatchSchedule_FY_Day31());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        Test.stopTest();
    }*/
    
    /*public static testmethod void FeeNotify_FY_Day45() {
        // Create a test Contact record with necessary fields
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 1,
            hed__Start_Date__c =  Date.Today().addDays(48)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;
        
        Test.startTest();
        switch on (Integer)semester.Days_Remaining_To_Start__c{
            when -48{
                Database.executeBatch(new StudentFeeNotifyBatchSchedule_FY_Day31());        
                Database.executebatch(new StudentFeeNotificationBatch(contactList));
            }
        }
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder', '0 0 0 * * ?' ,new StudentFeeNotifyBatchSchedule_FY_Day31(contactList));
        Database.executeBatch(new StudentFeeNotifyBatchSchedule_FY_Day31());        
        Database.executebatch(new StudentFeeNotificationBatch(contactList));
        AbortFeeReminderBatches.abortJobByName();
        StudentFeeNotificationBatch.testCover();
        StudentFeeNotifyBatchSchedule_FY_Day31.testCover();
        Test.stopTest();
    }*/
    
    public static testmethod void FeeNotify_HY_NY_28P() {
        // Create a test Contact record with necessary fields
       
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;
        
        hed__Program_Plan__c prog = new hed__Program_Plan__c(
            Name  = 'B. Tech in Electronics and Communication Engineering-(2023-2027)',
            hed__Account__c  = acc.Id
        );
        insert prog;
        
        Contact contact1 = new Contact(
            LastName = 'TestStudent1',
            Program_Batch__c = prog.Id,
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRecordTypeId,
            Active__c = true,
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        Contact contact2 = new Contact(
            LastName = 'Father S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Father',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact2;
        
        Contact contact3 = new Contact(
            LastName = 'Mother S1',
            ReportsToId = contact1.Id,
            Type_of_Relationship__c = 'Mother',
            RecordTypeId = parentRecordTypeId,
            MobilePhone = '1234567890'
        );
        insert contact3;
        
        List<String> contactList = new List<String>();
        contactList.add(contact1.Id);
        
        hed__term__c semester = new hed__term__c(
            Name  = 'BT-ECE-2023-2027-Sem-3',
            Program_Batch__c = prog.Id,
            RecordTypeId = semesterRecordTypeID,
            hed__Account__c  = acc.Id,
            Term_Number__c	= 5,
            hed__Start_Date__c =  Date.Today().addDays(170)
        );
        insert semester;
        
        Student_Fee__c sfee = new Student_Fee__c(
            Name = 'Tuition Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'Tuition Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today().addDays(1)
        );
        insert sfee; 
        
        Student_Fee__c sfee2 = new Student_Fee__c(
            Name = 'University Fee 3rd Year',
            Contact__c  = contact1.Id,
            Fee_Type__c  = 'University Fee',
            Amount__c = 129214,
            Amount_Paid__c = 0,
            Amount_Pending__c = 129214,
            Due_Date__c = Date.Today()
        );
        insert sfee2;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.schedule('Fee Reminder', '0 0 0 * * ?' ,new StudentFeeNotifyBatchSchedule_HY_28P_NY(contactList));
        Database.executeBatch(new StudentFeeNotifyBatchSchedule_HY_28P_NY());        
        Database.executebatch(new StudentFeeNotificationBatch_NY(contactList));
        AbortFeeReminderBatches.abortJobByName();
        StudentFeeNotificationBatch_NY.testCover();
        Test.stopTest();
    }
}