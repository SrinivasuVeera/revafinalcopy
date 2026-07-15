@isTest
public class TestrveSeatingArrangementUpdated {
    @TestSetup
    static void makeData(){
        // Creating test data for the tests
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account accparent = new Account(Name='TestAccParent',RecordTypeid = AcaRecId);
        insert accparent;
        
        Account acc = new Account(Name='TestAcc',parentId=accparent.Id);
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2024',
            Program_Batch__c = ProgramBatch.Id,
            hed__Start_Date__c = Date.today().addMonths(-1),
            hed__End_Date__c = Date.today().addMonths(5),
            IA_1_Start_date__c = Date.today().addMonths(1),
            Exam_Start_Date__c = Date.today().addMonths(2),
            IA_1_End_date__c = Date.today().addMonths(3),
            IA_2_Start_date__c = Date.today().addMonths(4),
            IA_2_End_date__c = Date.today().addMonths(5),
            hed__Account__c = acc.Id
        );
        insert term;
        
        string IANotification = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByName().get('IA Notification').getRecordTypeId();
        Rve_Exam_Notification__c TestNotification = new Rve_Exam_Notification__c();
        TestNotification.Name = 'Test';
        TestNotification.Rve_Semester__c=term.Id;
        TestNotification.rve_Exam_Start_Date__c = System.Today();
        TestNotification.Rve_Publish__c = true;
        TestNotification.RecordTypeId = IANotification;
        TestNotification.hed_Program_Batch__c = ProgramBatch.Id;
        TestNotification.hed_IA_Type__c = 'IA 1';
        insert TestNotification;
        
        hed_Time_Table_Line_Item__c TimeTableItem = new hed_Time_Table_Line_Item__c();
        TimeTableItem.Name = 'TestTimeTable';
        TimeTableItem.Reva_Exam_Notification__c = TestNotification.Id;
        TimeTableItem.hed_Date__c = System.today();
        TimeTableItem.hed_Start_Time__c =Time.newInstance(11,0,0,0);
        TimeTableItem.hed_End_Time__c = Time.newInstance(12,0,0,0);
        insert TimeTableItem;
        
        hed__Facility__c Facility = new hed__Facility__c(
            name = 'Test Facility',
            hed__Capacity__c = 50,
            Facility_Booked__c = false,
            Room_Name__c = 'TESLA LAB',
            Room__c = '301',
            Floor__c = '1st floor',
            Block__c = 'C.V. Raman Block',
            IA_Type__c = 'IA 1',
            hed__Account__c = accparent.Id
        );
        insert Facility;
        
        hed__Facility__c Facility2 = new hed__Facility__c(
            name = 'Test',
            hed__Capacity__c = 50,
            Facility_Booked__c = false,
            Room_Name__c = 'TESLA LAB',
            Room__c = '302',
            Floor__c = '1st floor',
            Block__c = 'C.V. Raman Block',
            IA_Type__c = 'IA 1',
            hed__Account__c = accparent.Id
        );
        insert Facility2;
        
        IA_Seating_Room_Allotment__c SeatingRoom = new IA_Seating_Room_Allotment__c(
            Name = Facility.Room__c,
            Facility_Type__c = Facility.Id,
            Capacity__c = Facility.hed__Capacity__c,
            IA_Type__c = Facility.IA_Type__c,
            School__c = accparent.Id,
            Room__c = Facility.Room__c,
            Active__c = true,
            rve_Date_of_Exam__c = Date.today(),
            rveShift__c = 'Morning',
            Exam_Time__c = Time.NewInstance(11,0,0,0),
            End_Time__c = Time.NewInstance(12,0,0,0),
            Alloted_Students__c = 'SA001,SA002',
            InEligible_SRN__c = 'SA003,Sa004',
         //   Course_Name__c = 'Electronic Circuit',
            Exam_Name__c = TestNotification.Name,
            Assigned_Program_Batches__c = ProgramBatch.id,
            Total_Students__c = 4
        );
        
        insert SeatingRoom;
        
        Contact father = new Contact(
            FirstName = 'John father',
            LastName = 'Doe father',
            MobilePhone = '7894561230',
            Active_Semester__c = term.Id,
            Active__c = true,
            Email = 'Father@test.com'
        );
        insert father;
        Contact guardian = new Contact(
            FirstName = 'John guardian',
            LastName = 'Doe guardian',
            MobilePhone = '7894000000',
            Active_Semester__c = term.Id,
            Active__c = true,
            Email = 'guardian@test.com'
        );
        Insert guardian;
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact con = new Contact();
        con.FirstName = 'suraj';
        con.LastName = 'Madala';
        con.Program_Batch__c = ProgramBatch.Id;
        con.Student_Status__c = 'Pursuing';
        con.Application_Number__c = '7366345366';
        con.RecordTypeId = StudentRecId;
        con.SRN_Number__c='SA001';
        con.email = 'test@test.com';
        con.Active__c=true;
        con.MobilePhone='7894561230';
        con.Father__c = father.Id;
        con.Guardian__c =guardian.Id;
        insert con;
        
        Student_Fee__c StudentFee = new Student_Fee__c(
            Name = 'Test Student Fee',
            contact__c = con.Id,
            Amount_Pending__c=0
        );
        insert StudentFee;
        
        hed__Program_Enrollment__c ProgramEnrollmentEligible = new hed__Program_Enrollment__c(
            hed__Contact__c = con.Id,
            Total_Classes_Completed__c=40,
            Total_Classes_Attended__c=35,
            hed__Program_Plan__c = ProgramBatch.id
        );
        insert ProgramEnrollmentEligible;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Vaishnavi';
        con1.LastName = 'Madala';
        con1.Program_Batch__c = ProgramBatch.Id;
        con1.SRN_Number__c='SA003';
        con1.Active__c=true;
        con1.MobilePhone='7894561230';
        con1.Email='test1@test.com';
        con1.Father__c = father.Id;
        con1.Guardian__c=guardian.Id;
        insert con1;
        
        Student_Fee__c StudentInEligibleFee = new Student_Fee__c(
            Name = 'Test Student Fee InEligible',
            contact__c = con1.Id,
            Amount_Pending__c=1,
            Due_Date__c = System.today()
            
        );
        insert StudentInEligibleFee;
        
        hed__Program_Enrollment__c ProgramEnrollment = new hed__Program_Enrollment__c(
            hed__Contact__c = con.Id,
            Total_Classes_Completed__c=40,
            Total_Classes_Attended__c=25,
            hed__Program_Plan__c = ProgramBatch.id
        );
        insert ProgramEnrollment;
        
        
    }
    
    @isTest
    static void testGetActivePrograms() {
        List<hed__Program_Plan__c> ProgramBatchList = rveSeatingArrangementUpdated.getActivePrograms();
        System.assertNotEquals(null, ProgramBatchList);
    }
    
    @isTest
    static void testParseTime() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Time parsedTime = rveSeatingArrangementUpdated.parseTime('10:30:00');
        Time expectedTime = Time.newInstance(10, 30, 0, 0);
        System.assertEquals(expectedTime, parsedTime);        
    }
    
    @isTest
    static void testGetAccountId() {
        hed__Program_Plan__c programBatch = [SELECT Id, Name FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        Account acc = [SELECT Id, Name, ParentId FROM Account WHERE Name = 'TestAcc'];
        String accountId = rveSeatingArrangementUpdated.getAccountId(programBatch.Id);
        System.assertEquals(acc.ParentId, accountId);
    }
    
    @isTest
    static void testGetRevaExamNotifications() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<contact>InEligiblestudents = [Select Id from Contact where SRN_Number__c='SA003'];
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        List<hed_Time_Table_Line_Item__c> timeTableList = rveSeatingArrangementUpdated.getRevaExamNotifications('IA 1', 'Morning', programBatch.Id);
        List<Rve_Exam_Notification__c> notification =[select id,name from Rve_Exam_Notification__c WHERE Rve_Semester__r.Name='Fall 2024'];
        System.assert(notification.size() > 0, 'Expected at least one Rve_Exam_Notification__c record');
        
        List<String> notificationIds = new List<String>();
        notificationIds.add(notification[0].Id);      
        
        
     //   HallTicket_Published_whats.trsWhatsappNotification(New List<list<string>>{notificationIds});
        
        System.assertNotEquals(0, timeTableList.size());
    }
    
    @isTest
    static void testUpdateFacilities() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        hed__Program_Plan__c programBatch = [SELECT Id,hed__Account__r.parentId FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        hed__Facility__c facility = [SELECT Id, hed__Capacity__c,hed__Account__c FROM hed__Facility__c WHERE Room_Name__c = 'TESLA LAB' limit 1];
        Map<String, Integer> facilityMap = new Map<String, Integer>();
        facilityMap.put(facility.Id, 50);
        String status = rveSeatingArrangementUpdated.updateFacilities(facilityMap, programBatch.Id);
        //System.assertEquals('successful', status);
    }
    
    @isTest
    static void testGetRelatedSchool() {
        hed__Program_Plan__c programBatch = [SELECT Id,hed__Account__c FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        IA_Seating_Room_Allotment__c SeatingRoom = [Select Id,Name,Facility_Type__c,Capacity__c,IA_Type__c,School__c,Room__c,Active__c,
                                                    rve_Date_of_Exam__c,rveShift__c,Exam_Time__c,End_Time__c,Alloted_Students__c,InEligible_SRN__c,/*Course_Name__c*/
                                                    Exam_Name__c,Assigned_Program_Batches__c,Total_Students__c from IA_Seating_Room_Allotment__c where name='301'];
        
        hed__Facility__c facility = [Select name,hed__Capacity__c,Facility_Booked__c,Room_Name__c,Room__c,Floor__c,Block__c,IA_Type__c from hed__Facility__c where Room__c = '302' limit 1];
        System.debug('Facility=> '+facility);
        List<string> schoolIds = new List<String>();
        schoolIds.add(programBatch.hed__Account__c);
        rveSeatingArrangementUpdated.getRelatedSchool(String.valueOf(programBatch.Id), 'IA 1', 'Morning', System.today(), String.valueOf(Time.newInstance(11,0,0,0)),schoolIds);
        
    }
    
    @isTest
    static void testCheckProgramBatchAllotment() {
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        rveSeatingArrangementUpdated.checkProgramBatchAllotment(String.valueOf(programBatch.Id), System.today(), 'Morning', String.valueOf(Time.newInstance(11,0,0,0)));
    }
    
    @isTest
    static void testGetAllStudents() {
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        rveSeatingArrangementUpdated.getStudents(programBatch.Id,System.today(), 'Morning', String.valueOf(Time.newInstance(11,0,0,0)));
    }
    
    @isTest
    static void testCreateAllotments() {
        hed__Program_Plan__c programBatch = [SELECT Id,hed__Account__c,hed__Account__r.ParentId FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        hed__Facility__c facility = [SELECT Id, name, hed__Capacity__c, Facility_Booked__c, Room_Name__c, Room__c, Floor__c, Block__c,IA_Type__c FROM hed__Facility__c WHERE Room_Name__c = 'TESLA LAB' limit 1 ];
        Map<String, Integer> facilityMap = new Map<String, Integer>();
        facilityMap.put(facility.Id, 50);
        Map<String,List<String>>courseToSrnMap = new Map<String,List<String>>();
        
        List<String> eligibleStudents = new List<String>{'SA001'};
            courseToSrnMap.put('Data Structure',eligibleStudents);
            Set<String> ineligibleStudents = new Set<String>{'SA003'};
                rveSeatingArrangementUpdated.createAllotments(programBatch.Id, facilityMap, new List<hed__Facility__c>{facility},
                                                              courseToSrnMap, System.today(), 'Morning', Time.newInstance(11,0,0,0),
                                                              Time.newInstance(13,0,0,0), 'Data Structure', 'Test Exam');
    }
    
    @isTest
    static void testCreateOrUpdateAllotment() {
        hed__Program_Plan__c programBatch = [SELECT Id,hed__Account__c,hed__Account__r.ParentId FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        hed__Facility__c facility = [SELECT Id, name, hed__Capacity__c, Facility_Booked__c, Room_Name__c, Room__c, Floor__c, Block__c,IA_Type__c FROM hed__Facility__c WHERE Room_Name__c = 'TESLA LAB' limit 1];
        List<Object> updateExistingCapacity = new List<Object>{ new List<Object>{facility.Id, 50} };
 Map<String,List<String>>courseToSrnMap = new Map<String,List<String>>();
        
        List<String> eligibleStudents = new List<String>{'SA001'};
            courseToSrnMap.put('Data Structure',eligibleStudents);
        List<String> ineligibleStudentList = new List<String>{'SA003'};
                    rveSeatingArrangementUpdated.createOrUpdateAllotment(String.valueOf(programBatch.Id), updateExistingCapacity, new List<hed__Facility__c>{facility},
                                                                         courseToSrnMap, Date.today(), 'Morning', String.valueOf(Time.newInstance(11,0,0,0)));
        
    }
    @isTest
    Static void getschoolselection(){
        Account acc = [SELECT Name from Account where Name = 'TestAccParent' LIMIT 1];
        Test.startTest();
        rveSeatingArrangementUpdated.getSchoolsForSelection();
        Test.stopTest();        
    }
    @isTest
    static void getschoolprogram(){
      hed__Program_Plan__c programBatchId = [SELECT Id, hed__Account__r.ParentId, hed__Account__r.Parent.Name
            FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch' LIMIT 1];
        Test.startTest();
        rveSeatingArrangementUpdated.getSchoolByProgramBatch(programBatchId.id);
        Test.stopTest();
    }
    @isTest
    static void getInEligiblestudents(){
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'TestProgramBatch'];
        rveSeatingArrangementUpdated.getInEligiblestudents(ProgramBatch.id);
    }
    @isTest
    static void getFacilitiesDetails(){
        Account acc = [SELECT id,Name from Account where Name = 'TestAccParent' LIMIT 1];
        List<string> schoolIds = new List<string>();
        schoolIds.add(acc.id);
        rveSeatingArrangementUpdated.getFacilitiesDetails('IA 1','Morning', system.Today(),Time.newInstance(13,0,0,0),schoolIds);
    }
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "success", "data": {"resdata": [{"sem": "Semester", "examdate": "2024-05-15", "regno": "SA001", "subshort": "CRS001", "qpcode": "QP001", "doe": "15/05/2024", "session": "9:00 AM to 12:00 PM", "batch": "1"}]}}');     
            return res;
        }
    }
}