@isTest
public class RPL_AdmitCardTemplateControllerTest {

    @isTest
    static void testGenerateAdmitCard() {
		
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
        eCon.Mother__c = Mother.Id;
        eCon.Father__c = Father.Id;
        eCon.MobilePhone = '7812938493';
        insert eCon;
        
        
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
         std.Rpl_Contact_No__c ='9553052925';
        std.Contact__c = eCon.Id;
        insert std;
        
        
        
        //Date startDate = Date.newInstance(2024, 1,26);
        Date startDate = System.Today();
        Date endDate = System.Today().addDays(10);
       // Date endDate1 = Date.newInstance(2026, 2, 19);
        Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
        rpl.Rpl_Registration_Start_Date__c = startDate;
        rpl.Rpl_Registration_End_Date__c = endDate;
        rpl.Name = 'Test Reva Placement-01';
        
        insert rpl;
        
        
        Rpl_Company__c  cmp = new Rpl_Company__c();
        cmp.Name = 'Amozan';
       
         insert cmp;
        
        Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
        //plc.Rpl_Drive_Name__c = 'test Name';
        plc.Reva_Placement__c = rpl.Id;
        plc.Rpl_Company_Name__c = cmp.Id;
        plc.Rpl_Event_End_Date__c = endDate;
        //plc.Rpl_Event_Date_Time__c = endDate1;
        
        insert plc;
        
        
        Rpl_Student_Registration_Drive__c testStudentRegDrive = new Rpl_Student_Registration_Drive__c();
        testStudentRegDrive.Rpl_Placement_Drive__c =  plc.Id;
        testStudentRegDrive.Rpl_Student_Registration__c = std.Id;
        
        insert testStudentRegDrive;
       

        // Call the method to test
        Test.startTest();
        RPL_AdmitCardTemplateController.generateAdmitCard(testStudentRegDrive.Id, 'test@example.com');
        Test.stopTest();

        // Add assertions as needed
        // Example: Check if the attachment is created
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :testStudentRegDrive.Id];
       // System.assertEquals(1, attachments.size(), 'Attachment not created.');
    }

    @isTest
    static void testSavePDFAsAttachment() {
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
        eCon.Email = 'test@gmail.com';eCon.Mother__c = Mother.Id;
        eCon.Father__c = Father.Id;
        eCon.MobilePhone = '8323940234';
       
        
        insert eCon;
        
        
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
         std.Rpl_Contact_No__c ='9553052925';
        std.Contact__c = eCon.Id;
        
        
        insert std;
        
        
        
        //Date startDate = Date.newInstance(2024, 1,26);
        Date startDate = System.Today();
        Date endDate = System.Today().addDays(10);
        //Date endDate = Date.newInstance(2026, 2, 17);
        //Date endDate1 = Date.newInstance(2026, 2, 19);
        Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
        rpl.Rpl_Registration_Start_Date__c = startDate;
        rpl.Rpl_Registration_End_Date__c = endDate;
        rpl.Name = 'Test Reva Placement-01';
        
        insert rpl;
        
        
        Rpl_Company__c  cmp = new Rpl_Company__c();
        cmp.Name = 'Amozan';
       
         insert cmp;
        
        Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
       // plc.Rpl_Drive_Name__c = 'test Name';
        plc.Reva_Placement__c = rpl.Id;
        plc.Rpl_Company_Name__c = cmp.Id;
        plc.Rpl_Event_End_Date__c = endDate;
        //plc.Rpl_Event_Date_Time__c = endDate1;
        
        insert plc;
        
        
        Rpl_Student_Registration_Drive__c testStudentRegDrive = new Rpl_Student_Registration_Drive__c();
        testStudentRegDrive.Rpl_Placement_Drive__c =  plc.Id;
        testStudentRegDrive.Rpl_Student_Registration__c = std.Id;
        
        insert testStudentRegDrive;

        Blob pdfBlob = Blob.valueOf('Test PDF Content');

        // Call the method to test
        Test.startTest();
        RPL_AdmitCardTemplateController.savePDFAsAttachment(testStudentRegDrive.Id, pdfBlob, 'test@example.com');
        Test.stopTest();

        // Add assertions as needed
        // Example: Check if the attachment is created
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :testStudentRegDrive.Id];
        System.assertEquals(1, attachments.size(), 'Attachment not created.');
    }
}