@isTest
public class RPL_StudentRegisterDriveControllerTest {
    @testSetup static void setup() {
        Contact eCon = new Contact();
        eCon.lastName = 'Test Data';
        eCon.Email = 'test@gmail.com';
        eCon.SRN_Number__c = '1VE09ME89';
        insert eCon;
        Contact eCon2 = new Contact();
        eCon2.lastName = 'Block Test';
        eCon2.Email = 'blocktest@gmail.com';
        eCon2.SRN_Number__c = '1VE09ME89ASWE';
        insert eCon2;
        Rpl_Student_Registration__c std1 = new Rpl_Student_Registration__c();
        std1.Name = 'Block Test Data';
        std1.Rpl_Personal_Mail_ID__c = 'blocktest1@gmail.com';
        std1.Rpl_Interested_in_placement__c = 'Yes';
        std1.Rpl_University_Mail_ID__c = '123123123123@reva.edu.in';
        std1.Contact__c = eCon2.Id;
        std1.Rpl_Is_Blocked__c = true;
        insert std1;
        
        
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        std.Contact__c = eCon.Id;
        std.Rpl_Is_Blocked__c = false;
        insert std;
        
        //Date startDate = Date.newInstance(2024, 1,25);
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
        plc.RPL_Number_Of_Applicants__c = 1;
        plc.Rpl_Event_End_Date__c = endDate;
        //plc.Rpl_Event_Date_Time__c = endDate1;
        insert plc;
        Rpl_Interview__c stdIntview = new Rpl_Interview__c();
        stdIntview.Placement_Drive__c = plc.Id;
        stdIntview.Name = 'Test Result 1';
        stdIntview.Rpl_Round_Number__c = 1;
        insert stdIntview;
        
        Rpl_Student_Registration_Drive__c stdr = new Rpl_Student_Registration_Drive__c();
        stdr.Rpl_Placement_Drive__c =  plc.Id;
        stdr.Rpl_Student_Registration__c = std.Id;
        stdr.Rpl_Interview__c = stdIntview.Id;
        stdr.Rpl_Is_Active__c = true;
        insert stdr;
    }
    
    @isTest
    static void testUpdateIsApplied() {
        Contact eCon  = [SELECT ID , SRN_Number__c FROM Contact LIMIT 1];
        Rpl_Student_Registration_Drive__c stdDrive = [SELECT ID , Name  FROM Rpl_Student_Registration_Drive__c limit 1 ];
        Test.startTest();
        String result = RPL_StudentRegisterDriveController.updateIsApplied(stdDrive.Id);
        Test.stopTest();
        
        Rpl_Student_Registration_Drive__c updatedStudentRegDrive = [SELECT Id, Rpl_IsApplied__c FROM Rpl_Student_Registration_Drive__c WHERE Id = :stdDrive.Id LIMIT 1];
        
        System.assertEquals('true', result, 'Expected update to be successful');
        System.assertEquals(true, updatedStudentRegDrive.Rpl_IsApplied__c, 'Expected Rpl_IsApplied__c to be true after update');
    }
    @isTest
    static void testGetEligibleDrives(){
        Contact eCon  = [SELECT ID , SRN_Number__c FROM Contact LIMIT 1];
        Test.startTest();
        List<Rpl_Student_Registration_Drive__c> srd = RPL_StudentRegisterDriveController.getAllEligibleDrives(eCon.Id);
        Test.stopTest();
        System.assertEquals(1, srd.size());
        System.assertEquals('test Name',srd[0].Rpl_Placement_Drive__r.Name);
    }
    @isTest
    static void testIsPresent(){
        Rpl_Student_Registration__c unBlockedStudent = [Select Id , Name , Contact__r.SRN_Number__c From Rpl_Student_Registration__c Where Name = 'Test Data1'];
        Rpl_Student_Registration__c blockedStudent = [Select Id , Name , Contact__r.SRN_Number__c From Rpl_Student_Registration__c Where Name = 'Block Test Data'];
        Rpl_Placement_Drive__c placementDrive = [Select Name From Rpl_Placement_Drive__c Limit 1];
        String unblockResult = RPL_StudentRegisterDriveController.updateIsPresent(unBlockedStudent.Contact__r.SRN_Number__c, placementDrive.Name);
        String blockResult = RPL_StudentRegisterDriveController.updateIsPresent(blockedStudent.Contact__r.SRN_Number__c, placementDrive.Name);
        System.assertEquals('true', unblockResult);
        System.assertEquals('false' , blockResult);
    }
    @isTest
    static void testGetDocument(){
        Rpl_Student_Registration_Drive__c srd = [Select Id From Rpl_Student_Registration_Drive__c Limit 1];
        RPL_StudentRegisterDriveController.AttachmentWrapper attachment = RPL_StudentRegisterDriveController.getAttachmentContent(srd.Id);
        System.assertEquals(null, attachment.Body);
        System.assertEquals(null, attachment.Name);
    }
    @isTest
    static void getNoOfEliigibleDrives(){
        Id loggedInUserId = UserInfo.getUserId();
        List<User> loggedInUser = [SELECT ContactId FROM User WHERE Id = :loggedInUserId LIMIT 1];
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        std.Contact__c = loggedInUser[0].ContactId;
        std.Rpl_Is_Blocked__c = false;
        insert std;
        Integer noOfEligibleDrives = RPL_StudentRegisterDriveController.getTotalNumberOfEligibleDrives();
        System.assertEquals(0,noOfEligibleDrives );
    }
    
    @isTest
    static void getSummaryDetais(){
        RPL_StudentRegisterDriveController.PlacementSummaryDetailsWrapper wrp = RPL_StudentRegisterDriveController.getPlacementSummaryDetails();
        System.assertEquals(wrp.upcomingDriveDate, 'N/A');
        System.assertEquals(wrp.totalDrives, 0);
        System.assertEquals(wrp.offerCount, 0);
        
        
    }
}