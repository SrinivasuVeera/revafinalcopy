@isTest
public class RPL_EligibilityHandlerClass_Test {
        @testSetup static void setup() {
        // Create common test accounts
        // Rpl_Student_Registration__c
        
        
        Contact eCon = new Contact();
        eCon.lastName = 'Test Data';
        eCon.Email = 'test@gmail.com';
        
        insert eCon;
        
        
       
        
        //Date startDate = Date.newInstance(2024, 1,24);
        //Date endDate = Date.newInstance(2026, 2, 17);
        //Date endDate1 = Date.newInstance(2026, 2, 19);
        Date startDate = System.Today();
        Date endDate = System.Today().addDays(10);
        Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
        rpl.Rpl_Registration_Start_Date__c = startDate;
        rpl.Rpl_Registration_End_Date__c = endDate;
        rpl.Name = 'Test Reva Placement-01';
        
        insert rpl;
        
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        std.Rpl_Companies_Got_Placed_In__c = 'Company1';
        std.Contact__c = eCon.Id;
        std.Reva_Placement__c = rpl.Id;
        
        
        insert std;
        
        
        
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
    static void testGetPlacementDriveId() {
        Rpl_Placement_Drive__c  rplDrive = [SELECT ID FROM Rpl_Placement_Drive__c LIMIT 1]; 
        Rpl_Eligibility__c eligibility = new Rpl_Eligibility__c(
            Rpl_Tenth_Percentage__c = 75,
            Rpl_Twelveth_Percentage__c = 80,
            Rpl_UG_Percentage1__c = 85,
            Rpl_PG_Percentage1__c = 90,
            Rpl_Current_Backlogs__c = 2,
            Rpl_Total_Backlogs__c = 5,
            Gender__c = 'Male',
            Offer_Count__c = 2,
            Rpl_Placement_Drive__c = rplDrive.Id,
            Rpl_Gap_Years__c = 1,
            Rpl_Placement_Interest__c = true,
            Rpl_Fee_Payment_Status__c = 'Exclude Students With Payment Pending',
            Rpl_Attendance_Percentage__c = 80,
             Rpl_Include_Students_With_Offer_In__c = 'Company1',
            Rpl_Exclude_Students_With_Offer_In__c = 'Company2'
            ,  
            Rpl_Specialization__c = 'MBA'
        );
        insert eligibility;

        /*RPL_EligibilityHandlerClass.CriteriaWrapperClass criteria = new RPL_EligibilityHandlerClass.CriteriaWrapperClass();
        criteria.tenthPercentage = 75;
        criteria.twelvePercentage = 80;
        criteria.UGPercentage = 85;
        criteria.PGPercentage = 90;
        criteria.currentBackLog = 2;
        criteria.specializationType = 'Computer Science';
        criteria.totalBacklogs = 5;
        criteria.gender = 'Male';
        criteria.OfferCount = 2;
        criteria.placementDriveId = eligibility.Rpl_Placement_Drive__c;
        criteria.gapYear = 1;
        criteria.placementInterest = true;
        criteria.attendance = 80;
        criteria.includeCompanies = 'Company1';
        criteria.excludeCompanies = 'Company2';*/

        Test.startTest();
        RPL_EligibilityHandlerClass.getPlacementDriveId(new List<Rpl_Eligibility__c>{eligibility}, false);
        Test.stopTest();
    }


    @isTest
    static void testSendEmail() {
        Set<String> toAddresses = new Set<String>{'test@example.com'};

        Test.startTest();
        //RPL_EligibilityHandlerClass.sendEmail(toAddresses);
        Test.stopTest();
    }
}