@IsTest
public class HallTicketQRStudRoomAllotmntBatchTest {

    @testSetup
    static void setupData() {

               
        /* ------------------------------
           Record Types
        ------------------------------ */
        Id studentRtId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('Student')
            .getRecordTypeId();

        Id examRtId = Schema.SObjectType.Rve_Exam_Notification__c
            .getRecordTypeInfosByDeveloperName()
            .get('hed_IA_Notification')
            .getRecordTypeId();
        
        Account school = new Account(Name='Test School');
        insert school;

        Account program = new Account(Name='Test Program', ParentId=school.Id);
        insert program;
         // Create Program Plan (Batch)
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name='Test Batch 2025', hed__Account__c = program.Id, hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(5));
        insert programBatch;

        /* -------------------------------
           Create Student Contact
        --------------------------------*/
        Contact student = new Contact(
            LastName = 'Test Student',
            SRN_Number__c = 'SRN001',
            Application_Number__c = 'APP001',            
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRtId,
            Active__c = true,
            Program_Batch__c = programBatch.Id
        );
        insert student;

        /* -------------------------------
           Create Room Allotment
        --------------------------------*/
   
        
        IA_Seating_Room_Allotment__c room = new IA_Seating_Room_Allotment__c(
            Name = 'Room-101',
            Exam_Name__c = 'B. Tech in Civil Engineering-(2024-2028)',
            Room__c = 'Room-101',
            IA_Type__c = 'IA 1',
            Students__c = 'SRN001'
        );
		insert room;
        
        /* -------------------------------
           Create Invigilator Assignment
        --------------------------------*/
        rve_Invigilator_Assignment__c assign =
            new rve_Invigilator_Assignment__c(
                Name = 'Assignment-1',
                rve_Room_Allotment__c = room.Id,
                rve_Date__c = Date.newInstance(2025, 12, 29),
                   rve_Exam_Time__c     = Time.newInstance(10, 0, 0, 0),
                   rve_Exam_End_Time__c = Time.newInstance(13, 0, 0, 0)
            );
        insert assign;
    }

    @IsTest
    static void testBatchExecution() {

        Test.startTest();

        HallTicketQRStudRoomAllotmntBatch batch =
            new HallTicketQRStudRoomAllotmntBatch(
                'B. Tech in Civil Engineering-(2024-2028)',
                Date.newInstance(2025, 12, 29)
            );

        Database.executeBatch(batch, 1);

        Test.stopTest();

        /* -------------------------------
           Verify Hall Ticket Created
        --------------------------------*/
        List<HallTicketQR__c> hallTickets = [
            SELECT Id,
                   SRN__c,
                   Room__c,
                   Date__c
            FROM HallTicketQR__c
        ];

        System.assertEquals(
            1,
            hallTickets.size(),
            'One HallTicketQR record should be created'
        );

        System.assertEquals(
            'SRN001',
            hallTickets[0].SRN__c
        );

        System.assertEquals(
            Date.newInstance(2025, 12, 29),
            hallTickets[0].Date__c
        );
    }

}