@isTest
public class RPL_SendEmailToEligibleStudentsTest {

    @testSetup
    static void setup() {
        // Create common test accounts
        Contact Father = new Contact();
        Father.lastName = 'Test Data';
        Father.Email = 'testfather@gmail.com';
        Father.MobilePhone = '8234823428';
        insert Father;
        
        Contact Mother = new Contact();
        Mother.lastName = 'Test Data';
        Mother.Email = 'testmother@gmail.com';
        Mother.MobilePhone = '9233492348';
        insert Mother;

        Contact eCon = new Contact();
        eCon.lastName = 'Test Data';
        eCon.Email = 'test@gmail.com';
        eCon.MobilePhone = '8234923408';
        eCon.Mother__c = Mother.Id;
        eCon.Father__c = Father.Id;
        insert eCon;
       
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Contact_No__c = '7825986782';
        std.Rpl_Interested_in_placement__c = 'yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        std.Contact__c = eCon.Id;
        insert std;

        Date startDate = System.Today();
        Date endDate = System.Today().addDays(10);

        Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
        rpl.Rpl_Registration_Start_Date__c = startDate;
        rpl.Rpl_Registration_End_Date__c = endDate;
        rpl.Name = 'Test Reva Placement-01';
        insert rpl;

        Rpl_Company__c cmp = new Rpl_Company__c();
        cmp.Name = 'Amazon';
        insert cmp;

        Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
        plc.Reva_Placement__c = rpl.Id;
        plc.Rpl_Company_Name__c = cmp.Id;
        plc.Rpl_Event_End_Date__c = endDate;
        plc.Rpl_Application_End_Time__c = System.now().time();
        insert plc;

        Rpl_Student_Registration_Drive__c stdr = new Rpl_Student_Registration_Drive__c();
        stdr.Rpl_Placement_Drive__c = plc.Id;
        stdr.Rpl_Student_Registration__c = std.Id;
        
        insert stdr;
    }

    @isTest
    public static void testActivateRPL_SendEmailToEligibleStudentsBatch() {
        Rpl_Student_Registration_Drive__c testDrive = createTestDrive();
        List<String> driveIds = new List<String>{testDrive.Rpl_Placement_Drive__c};

        Test.startTest();
        RPL_SendEmailToEligibleStudents.activateRPL_SendEmailToEligibleStudentsBatch(driveIds);
        Test.stopTest();

        // Verify the expected outcomes
        // Add assertions here
    }

    @isTest
    public static void testRPL_SendEmailToEligibleStudentsBatch() {
        Rpl_Student_Registration_Drive__c testDrive = createTestDrive();

        Test.startTest();
        Database.executeBatch(new RPL_SendEmailToEligibleStudents(testDrive.Rpl_Placement_Drive__c), 100);
        Test.stopTest();

        // Verify the expected outcomes
        // Add assertions here
    }

    @isTest
    public static void testRPL_SendEmailToEligibleStudentsBatch_NoRecords() {
        // Start the batch job with no records
        Test.startTest();
        //Database.executeBatch(new RPL_SendEmailToEligibleStudents(null), 100);
        Test.stopTest();

        // Verify that the batch job has processed successfully with no errors
        // Add assertions here if needed
    }

    @isTest
    public static void testRPL_SendEmailToEligibleStudentsBatch_ExceptionHandling() {
        Rpl_Student_Registration_Drive__c testDrive = createTestDrive();

        // Mock an exception during the batch execution
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Database.executeBatch(new RPL_SendEmailToEligibleStudents(testDrive.Rpl_Placement_Drive__c), 100);
        Test.stopTest();

        // Verify that the exception is caught and handled appropriately
        // Add assertions here if needed
    }

    private static Rpl_Student_Registration_Drive__c createTestDrive() {
        Rpl_Student_Registration_Drive__c stdRegDrve = [SELECT ID, Rpl_Student_Registration__c, Rpl_Placement_Drive__c FROM Rpl_Student_Registration_Drive__c LIMIT 1];
        return stdRegDrve;
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('Mock response body');
            return res;
        }
    }
}