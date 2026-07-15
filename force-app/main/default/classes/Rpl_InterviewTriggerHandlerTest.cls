@isTest
private class Rpl_InterviewTriggerHandlerTest {
    
    private class WhatsappNotificationMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    @testSetup
    private static void createDummyData(){      
        
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
        eCon.lastName = 'LastNameTest';
        eCon.Email = 'test@gmail.com';
        eCon.SRN_Number__c = '12345';
        eCon.Mother__c = Mother.Id;
        eCon.Father__c = Father.Id;
        eCon.Phone = '8980293839';
        insert eCon;
        
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Student Name 1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'Yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        std.Contact__c = eCon.Id;
        std.Rpl_Contact_No__c = '7820911232';
        insert std;
        
        Date startDate = Date.today();
        startDate.addDays(2);        
        Date endDate = Date.today();
        endDate.addDays(7);
        Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
        rpl.Rpl_Registration_Start_Date__c = startDate;
        rpl.Rpl_Registration_End_Date__c = endDate;
        rpl.Name = 'Test Reva Placement-01';
        insert rpl;
        
        Rpl_Company__c  cmp1 = new Rpl_Company__c();
        cmp1.Name = 'Cloud Odyssey';
        insert cmp1;
        
        
        Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
        plc.Name = 'Cloud Odyssey Drive';
        plc.Reva_Placement__c = rpl.Id;
        plc.Rpl_Event_Date_Time__c = DateTime.Now().addDays(20); 
        plc.Rpl_Event_End_Date__c = Date.today().addDays(3);
        plc.Rpl_Event_Date__c = Date.today();
        plc.Rpl_Company_Name__c = cmp1.Id;
        plc.Rpl_CTC__c = 500000;
        insert plc; 
        
        Rpl_Student_Registration_Drive__c stdr = new Rpl_Student_Registration_Drive__c();
        stdr.Rpl_Placement_Drive__c =  plc.Id;
        stdr.Rpl_Student_Registration__c = std.Id;
        stdr.Rpl_Is_Failed__c = false;
        insert stdr;
    }
    
    @isTest
    private static void roundOneInsertCheck() {
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        
        Rpl_Student_Registration_Drive__c studentRegDrive1 = [Select Id, Rpl_Interview__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__r.Name = 'Cloud Odyssey Drive' Limit 1];
        System.assertEquals(null, studentRegDrive1.Rpl_Interview__c, 'Expected: Interview field should be empty, Actual: There is some lookup ID Filled');
        
        Rpl_Placement_Drive__c drive = [Select Id From Rpl_Placement_Drive__c Where Name = 'Cloud Odyssey Drive'];
        
        Rpl_Interview__c rs1 = new Rpl_Interview__c();
        rs1.Name = 'Aptitude';
        rs1.Rpl_Round_Number__c = 1;
        rs1.Placement_Drive__c = drive.Id;
        
        Test.startTest();
        insert rs1;
        Test.stopTest();
        
        Rpl_Student_Registration_Drive__c studentRegDrive2 = [Select Id, Rpl_Interview__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__r.Name = 'Cloud Odyssey Drive' Limit 1];
        System.assertEquals(rs1.Id, studentRegDrive2.Rpl_Interview__c, 'Expected: First Round Recruitment Stage Lookup To Be Filled');
    }
    
    @isTest
    private static void checkPullPrevRoundShortlistedStudentsTest() {
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        
        Rpl_Placement_Drive__c drive = [Select Id From Rpl_Placement_Drive__c Where Name = 'Cloud Odyssey Drive'];
        
        Rpl_Interview__c rs1 = new Rpl_Interview__c();
        rs1.Name = 'Aptitude';
        rs1.Rpl_Round_Number__c = 1;
        rs1.Placement_Drive__c = drive.Id;
        insert rs1;
        
        // Inserting the result for the first round, in DB it is the last round. But "Is Final Round" is unchecked.
        Rpl_Interview_Result__c result1 = new Rpl_Interview_Result__c();
        result1.Name = 'Aptitude';
        result1.Rpl_SRN__c = '12345';
        result1.Rpl_Round_Number__c = 1;
        result1.Rpl_Result__c = 'Shortlisted';
        result1.Rpl_Drive_Name__c = 'Cloud Odyssey Drive';
        
        insert result1;
        
        Rpl_Interview__c firstRound = [Select Id From Rpl_Interview__c Where Rpl_Round_Number__c = 1 And Placement_Drive__c = :drive.Id Limit 1];
        Rpl_Student_Registration_Drive__c srd = [Select Id, Rpl_Interview__c, Rpl_Interview__r.Name, Rpl_Interview__r.Rpl_Round_Number__c, Rpl_Is_Offered__c, Rpl_Is_Result_Out__c, Rpl_Is_Failed__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__c = :drive.Id Limit 1];
        
        System.assertEquals(firstRound.Id, srd.Rpl_Interview__c, 'Expected: First Round Of Interview Should Be Populated');
        System.assertEquals(false, srd.Rpl_Is_Result_Out__c, 'Expected: Is Result Out Should Be False, As "Is Final Round Is Unchecked"');
        
        Rpl_Interview__c rs2 = new Rpl_Interview__c();
        rs2.Name = 'Technical';
        rs2.Rpl_Round_Number__c = 2;
        rs2.Rpl_Pull_Prev_Round_Shortlisted_Students__c = true;
        rs2.Placement_Drive__c = drive.Id;
        
        Test.startTest();
        insert rs2;
        Test.stopTest();
        
        Rpl_Student_Registration_Drive__c srd2 = [Select Id, Rpl_Interview__c, Rpl_Interview__r.Name, Rpl_Interview__r.Rpl_Round_Number__c, Rpl_Is_Offered__c, Rpl_Is_Result_Out__c, Rpl_Is_Failed__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__c = :drive.Id Limit 1];
        System.assertEquals(rs2.Id, srd2.Rpl_Interview__c, 'Expected: Shortlisted Students To Be Pulled To Second Round');
        
        Rpl_Interview_Result__c result2 = new Rpl_Interview_Result__c();
        result2.Name = 'Technical';
        result2.Rpl_SRN__c = '12345';
        result2.Rpl_Round_Number__c = 2;
        result2.Rpl_Result__c = 'Shortlisted';
        result2.Rpl_Drive_Name__c = 'Cloud Odyssey Drive';
        
        insert result2;
        
        Rpl_Student_Registration_Drive__c srd3 = [Select Id, Rpl_Interview__c, Rpl_Interview__r.Name, Rpl_Interview__r.Rpl_Round_Number__c, Rpl_Is_Offered__c, Rpl_Is_Result_Out__c, Rpl_Is_Failed__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__c = :drive.Id Limit 1];
        System.assertEquals(false, srd3.Rpl_Is_Offered__c, 'Expected: Is offered to be false, as Technical round is not checked with Is Final Round');
        
        Rpl_Interview__c secondRound = [Select Id, Rpl_Is_Final_Round__c From Rpl_Interview__c Where Name = 'Technical' AND Placement_Drive__c = :drive.Id];
        secondRound.Rpl_Is_Final_Round__c = true;
        update secondRound;
        
        Rpl_Student_Registration_Drive__c srd4 = [Select Id, Rpl_Interview__c, Rpl_Interview__r.Name, Rpl_Interview__r.Rpl_Round_Number__c, Rpl_Is_Offered__c, Rpl_Is_Result_Out__c, Rpl_Is_Failed__c From Rpl_Student_Registration_Drive__c Where Rpl_Placement_Drive__c = :drive.Id Limit 1];
        System.assertEquals(true, srd4.Rpl_Is_Offered__c, 'Expected: Is Offered To Be True But Got False');
    }
    
    
}