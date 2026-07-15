@isTest
private class RPL_InterviewHandlerTest {
    
    @testSetup static void setup() {
        // Create common test accounts
        // Rpl_Student_Registration__c
        
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
        eCon.Mother__c = Mother.Id;
        eCon.Father__c = Father.Id;
        eCon.Email = 'test@gmail.com';
        
        insert eCon;
        
        
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        std.Contact__c = eCon.Id;
        
        
        insert std;
        
        
        
        //Date startDate = Date.Today();
        //Date endDate = Date.newInstance(2026, 2, 17);
        //Date endDate1 = Date.newInstance(2026, 2, 19);
        Date startDate = System.Today();
        Date endDate = System.Today().addDays(10);

        Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
        rpl.Rpl_Registration_Start_Date__c = startDate;
        rpl.Rpl_Registration_End_Date__c = endDate;
        rpl.Name = 'Test Reva Placement-01';
        
        insert rpl;
        
        
        Rpl_Company__c  cmp = new Rpl_Company__c();
        cmp.Name = 'Amozan';
       
         insert cmp;
        
        Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
        plc.Name = 'test Name';
        plc.Reva_Placement__c = rpl.Id;
        plc.Rpl_Company_Name__c = cmp.Id;
        plc.Rpl_Event_End_Date__c = endDate;
        //plc.Rpl_Event_Date_Time__c = endDate1;
        
        insert plc;
        
        
        Rpl_Student_Registration_Drive__c stdr = new Rpl_Student_Registration_Drive__c();
        stdr.Rpl_Placement_Drive__c =  plc.Id;
        stdr.Rpl_Student_Registration__c = std.Id;
        
        insert stdr;
              
    }

    @isTest
    static void testGetAllInterviewsWithValidInput() {
        // Create a test record for Rpl_Student_Registration_Drive__c
        Rpl_Placement_Drive__c  rplDrive = [SELECT ID FROM Rpl_Placement_Drive__c LIMIT 1]; 
        Rpl_Student_Registration_Drive__c testDrive = new Rpl_Student_Registration_Drive__c(
            Rpl_Is_Failed__c = false,
            Rpl_Is_Result_Out__c = false,
            Rpl_Placement_Drive__c = rplDrive.Id // Replace with actual Placement Drive Id
        );
        insert testDrive;
        
        

        // Create a test record for Rpl_Interview__c
       
        
        Rpl_Interview__c stdIntview = new Rpl_Interview__c();
        stdIntview.Placement_Drive__c = rplDrive.Id;
        stdIntview.Name = 'Test Result 1';
        stdIntview.Rpl_Round_Number__c = 1;
        insert stdIntview;

        // Call the getAllInterviews method with valid input
        RPL_InterviewHandler.RPL_InterviewHandlerWrapperClass result = RPL_InterviewHandler.getAllInterviews(testDrive.Id);

        // Add assertions as needed
        System.assertNotEquals(null, result, 'Wrapper class should not be null');
        System.assertNotEquals(null, result.interviewList, 'Interview list should not be null');
        System.assertNotEquals(null, result.studentRegistrationDrive, 'Student registration drive should not be null');
    }

}