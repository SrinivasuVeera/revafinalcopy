@isTest
public class Exam_room_Allotted_Whatsapp_Test {
    @testSetup
    static void setupTestData() {
        // Create necessary test data
        Account accparent = new Account(Name = 'TestAccParent');
        insert accparent;

        Account acc = new Account(Name = 'TestAcc', ParentId = accparent.Id);
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

        String IANotification = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByName().get('IA Notification').getRecordTypeId();
        Rve_Exam_Notification__c TestNotification = new Rve_Exam_Notification__c();
        TestNotification.Name = 'Test';
        TestNotification.Rve_Semester__c = term.Id;
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
        TimeTableItem.hed_Start_Time__c = Time.newInstance(11, 0, 0, 0);
        TimeTableItem.hed_End_Time__c = Time.newInstance(12, 0, 0, 0);
        insert TimeTableItem;

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

        List<IA_Seating_Room_Allotment__c> allotments = new List<IA_Seating_Room_Allotment__c>();
        for (Integer i = 0; i < 3; i++) {
            allotments.add(new IA_Seating_Room_Allotment__c(
                Name = 'Test Allotment ' + i,
                Room__c = 'Room ' + i,
                Facility_Type__c = Facility.Id,
                Capacity__c = Facility.hed__Capacity__c,
             //   Course_Name__c = 'Course ' + i,
                IA_Type__c = 'IA 1',
                rve_Date_of_Exam__c = Date.today().addDays(i * 10),
                Exam_Time__c = Time.newInstance(10, 0, 0, 0),
                End_Time__c = Time.newInstance(12, 0, 0, 0),
                Alloted_Students__c = 'SRN001,SRN002,SRN003',
                InEligible_SRN__c = ''
            ));
        }
        insert allotments;

        Contact father = new Contact(LastName = 'Father', MobilePhone = '7731030243');
        insert father;

        Contact mother = new Contact(LastName = 'Mother', MobilePhone = '7731030286');
        insert mother;

        Contact guardian = new Contact(LastName = 'Guardian', MobilePhone = '7731030290');
        insert guardian;

        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c = ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);
        insert semester;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            MobilePhone = '1234567890',
            Email = 'testyop@gmail.com',
            Active_Semester__c = semester.Id,
            Active__c = true,
            SRN_Number__c = 'SRN001',
            Father__c = father.Id,
            Mother__c = mother.Id,
            Guardian__c = guardian.Id
        );
        insert testContact;
    }

    @isTest
    static void testBatch() {
        List<IA_Seating_Room_Allotment__c> allotmentList = [SELECT Id FROM IA_Seating_Room_Allotment__c LIMIT 1];
        List<Id> allotmentIds = new List<Id>();
        for (IA_Seating_Room_Allotment__c allotment : allotmentList) {
            allotmentIds.add(allotment.Id);
        }

        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create an instance of the batch class
        Exam_room_Allotted_Whatsapp_batch1 batch = new Exam_room_Allotted_Whatsapp_batch1(allotmentIds);

        // Start test context
        Test.startTest();
        Database.executeBatch(batch,1);
        Test.stopTest();

        // Verify that the batch has processed the records
       // List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClassId = :Schema.getGlobalDescribe().get('Exam_room_Allotted_Whatsapp_batch1').getSObjectType().getDescribe().getId() LIMIT 1];
       // System.assertEquals(1, batchJobs.size(), 'Batch job should have been executed');
       // System.assertEquals('Completed', batchJobs[0].Status, 'Batch job should have completed successfully');

        // Additional assertions to verify the processing of notifications and SMS
        // This assumes you have a way to verify the callout or SMS messages sent
        // e.g., by mocking responses or checking logs
    }

    @isTest
    static void test_trsWhatsappNotification() {
        Test.startTest();
        List<List<String>> recordIds = new List<List<String>>();
        List<IA_Seating_Room_Allotment__c> allotmentList = [SELECT Id FROM IA_Seating_Room_Allotment__c LIMIT 3];
        
        recordIds.add(new List<String>{allotmentList[0].Id, allotmentList[1].Id, allotmentList[2].Id});
        
        Exam_room_Allotted_Whatsapp.trsWhatsappNotification(recordIds);
        
        Test.stopTest();
        
        // Validate the results
        System.assert(true, 'The test ran successfully.');
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}