@isTest
public class COUP_CouponCodeUtilityTest {

    @isTest
    public static void CreateCouponTest() {
        List<COUP_CouponCodeUtility.UtilityRequest> urequestList = new List<COUP_CouponCodeUtility.UtilityRequest>();
        COUP_CouponCodeUtility.UtilityRequest uRequest = new COUP_CouponCodeUtility.UtilityRequest();
        uRequest.noOfCouponsToBeCreated = 2;
        uRequest.invocationType = 'SINGLE_USE_COUPON_CREATION';
        uRequest.DiscountPercent =10;
        uRequest.EffectiveFromDate =system.today()-1;
        uRequest.EffectiveToDate =system.today()+10;
        urequestList.add(uRequest);
		Test.startTest();
           COUP_CouponCodeUtility.decideByInvocation(urequestList);
        Test.stopTest();
    }
    
    @testSetup
    public static void CreateTestData(){
        String enteredCouponCode = 'REVA2023';
        String enteredCouponCode1 = 'REVADMIN2023';
        String enteredCouponCode2 = 'REVAPROGRAM2023';
        String enteredCouponCode3 = 'REVAPROGRAMADMIN2023';
        String enteredCouponCode4 = 'REVACAMPAIGN2023';
        String enteredCouponCode5 = 'REVACAMP2023';
        String enteredCouponCode6 = 'REVAINVALID2023';
        String enteredCouponCode7 = 'APPLICANTDISCOUNT';
        String enteredCouponCode8 = 'CAMPAIGNDISCOUNT';
        String enteredCouponCode9 = 'PROGRAMDISCOUNT';
        String enteredCouponCodeFree = 'FREECOUPON';
        String invalidCouponCode = 'InvalidCoupon';
        String programName = 'Bachelor of Architecture';
        String programName1= 'Master of Business Administration';
        String campaignName = 'REVA Registration_2023';
        
        RecordType academicProgramRT = [Select id FROM RecordType Where DeveloperName = 'Academic_Program' Limit 1];
        RecordType applicantRT = [Select id FROM RecordType Where DeveloperName = 'Applicant' Limit 1];
        
        Account program= new Account(
        	Name = programName,
            RecordTypeId = academicProgramRT.Id,    
            Program_Alias__c = 'Barch',
            Program_Type__c = 'UG',
            Program_Code__c = 'RA',
            Intake__c = 80,
            Intake_Per_Section__c = 40
        );
        insert program;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
        	Name = 'Bachelor of Architecture-(2023-2028)',
            hed__Account__c=program.id
        );
        insert programBatch;
        
        Fee_Master__c feeMasterBArc= new Fee_Master__c(
        	Program_Batch__c =programBatch.Id,
            Fee_Amount__c = 1000,
            Fee_Type__c='Application Fee'
        );
        insert feeMasterBArc;
        
        Account program1= new Account(
        	Name = programName1,
            RecordTypeId = academicProgramRT.Id,    
            Program_Alias__c = 'MBA',
            Program_Type__c = 'PG',
            Program_Code__c = 'MK',
            Intake__c = 360,
            Intake_Per_Section__c = 60
        );
        insert program1;
        
        hed__Program_Plan__c programBatch1 = new hed__Program_Plan__c(
        	Name = 'MBA-(2023-2025)',
            hed__Account__c=program1.id
        );
        insert programBatch1;
        
        Fee_Master__c feeMasterMBA= new Fee_Master__c(
        	Program_Batch__c =programBatch1.Id,
            Fee_Amount__c = 1000,
            Fee_Type__c='Application Fee'
        );
        insert feeMasterMBA;
        
        Contact Applicant1 = new Contact(
            FirstName = 'sai',
            MiddleName = 'k',
            LastName = 'K',
            Email = 'sai@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = applicantRT.Id,
            Application_Fee_Paid__c = false,
            Application_Number__c = '222333555',
            Primary_Academic_Program__c = program.Id
        );
        insert Applicant1;
       
        Contact Applicant2 = new Contact(
            FirstName = 'Jai',
            MiddleName = 'k',
            LastName = 'K',
            Email = 'jai@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = applicantRT.Id,
            Application_Fee_Paid__c = false,
            Application_Number__c = '222333556',
            Primary_Academic_Program__c = program.Id
        );
        insert Applicant2;
        
        Contact Applicant3 = new Contact(
            FirstName = 'John',
            MiddleName = 'k',
            LastName = 'K',
            Email = 'john@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = applicantRT.Id,
            Application_Fee_Paid__c = false,
            Application_Number__c = '222333555',
            Primary_Academic_Program__c = program.Id
        );
        insert Applicant3;
        
        Contact Applicant4 = new Contact(
            FirstName = 'Ram',
            MiddleName = 'k',
            LastName = 'K',
            Email = 'ram@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = applicantRT.Id,
            Application_Fee_Paid__c = false,
            Application_Number__c = '222333555',
            Primary_Academic_Program__c = program.Id
        );
        insert Applicant4;
        
        hed__Application__c Application = new hed__Application__c(
	        hed__Applicant__c = Applicant1.Id,
            hed__Applying_To__c = program.Id
        );
        insert Application;
        
        Campaign camp = new Campaign(
        	Name = campaignName,
            IsActive =true
        );
        insert camp;
        
        Coupon__c couponCode = new Coupon__c(
        	Applicant__c = Applicant1.Id,
          	Coupon_Code__c = enteredCouponCode,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode;
        
        Coupon__c couponCode1 =new Coupon__c(
        	Applicant__c = Applicant1.Id,
          	Coupon_Code__c = enteredCouponCode1,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1,
            Used_on_Application__c = Application.Id
        );
        insert couponCode1;
        
         Coupon__c couponCode2 = new Coupon__c(
            Program__c = program.Id,
          	Coupon_Code__c = enteredCouponCode2,
            Discount_Percent__c = 10,
            Max_Use_Count__c = 3,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode2;
        
        Coupon__c couponCode3 = new Coupon__c(
        	Program__c = program.Id,
          	Coupon_Code__c = enteredCouponCode3,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode3;
        
        Coupon__c couponCode4 = new Coupon__c(
            Campaign__c =  camp.Id,
          	Coupon_Code__c = enteredCouponCode4,
            Discount_Percent__c = 10,
            Max_Use_Count__c = 3,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode4;
        
        Coupon__c couponCode5 = new Coupon__c(
            Campaign__c =  camp.Id,
          	Coupon_Code__c = enteredCouponCode5,
            Discount_Percent__c = 10,
            Effective_From__c = system.today()+1,
            Effective_To__c = system.today()+2
        );
        insert couponCode5;
        
        Coupon__c couponCode6 = new Coupon__c(
        	Applicant__c = Applicant3.Id,
          	Coupon_Code__c = enteredCouponCode6,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode6;
        
        Coupon__c couponCode7 = new Coupon__c(
        	Applicant__c = Applicant4.Id,
          	Coupon_Code__c = enteredCouponCode7,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode7;
        
        Coupon__c couponCode8 = new Coupon__c(
        	Campaign__c = camp.Id,
          	Coupon_Code__c = enteredCouponCode8,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode8;
        
        Coupon__c couponCode9 = new Coupon__c(
        	Program__c=program.Id,
          	Coupon_Code__c = enteredCouponCode9,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode9;
        
        Coupon__c couponCodeFree = new Coupon__c(
        	Program__c=program.Id,
          	Coupon_Code__c = enteredCouponCodeFree,
            Discount_Percent__c = 100,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCodeFree;
        
        Student_Fee__c studentFee = new Student_Fee__c(
        	Name = 'Application Fee-222333555-john',
            Contact__c = Applicant3.Id,
            Fee_Master__c=feeMasterBArc.Id,
            Fee_Type__c='Application Fee',
            Amount_Pending__c = 1000,
         	Amount__c = 1000,
         	Amount_Paid__c = 0
        );
         insert studentFee;
         
         hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = Applicant3.Id,
            hed__Applying_To__c = program.Id,
            Applied_Coupon__c = couponCode6.Id
         );
         insert Application1;
        
        Student_Fee__c studentFeeSai = new Student_Fee__c(
        	Name = 'Application Fee-222333555-ram',
            Contact__c = Applicant1.Id,
            Fee_Master__c=feeMasterBArc.Id,
            Fee_Type__c='Application Fee',
            Amount_Pending__c = 1000,
         	Amount__c = 1000,
         	Amount_Paid__c = 0
        );
         insert studentFeeSai;
        
        Student_Fee__c studentFeeJai = new Student_Fee__c(
        	Name = 'Application Fee-222333555-ram',
            Contact__c = Applicant2.Id,
            Fee_Master__c=feeMasterBArc.Id,
            Fee_Type__c='Application Fee',
            Amount_Pending__c = 1000,
         	Amount__c = 1000,
         	Amount_Paid__c = 0
        );
         insert studentFeeJai;
        
            Student_Fee__c studentFee1 = new Student_Fee__c(
        	Name = 'Application Fee-222333555-ram',
            Contact__c = Applicant4.Id,
            Fee_Master__c=feeMasterBArc.Id,
            Fee_Type__c='Application Fee',
            Amount_Pending__c = 1000,
         	Amount__c = 1000,
         	Amount_Paid__c = 0
        );
         insert studentFee1;
         
         hed__Application__c Application2 = new hed__Application__c(
	        hed__Applicant__c = Applicant4.Id,
            hed__Applying_To__c = program.Id
         );
         insert Application2;
        
         hed__Application__c Application4 = new hed__Application__c(
	        hed__Applicant__c = Applicant2.Id,
            hed__Applying_To__c = program.Id
         );
         insert Application4;
    }
    
    @isTest static void validateSuccessCouponforApplicantTest(){
        string displayMsg = 'SUCCESS';
        String enteredCouponCode = 'REVA2023';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
                        
        hed__Application__c updateApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                                    Where hed__Applicant__c =:con.Id Limit 1];
        
        Student_Fee__c updateStudentFee = [Select id, Amount_Pending__c, Amount__c ,Amount_Paid__c,Description__c
                                    		From Student_Fee__c Where Contact__c =:con.Id Limit 1];

        
        updateApplication.Applied_Coupon__c = coupn.Id;
        update updateApplication;
   
        programId = acc.Id;
        contactId = con.Id;
    
        Test.startTest();
        COUP_CouponCodeUtility.validateCoupon(enteredCouponCode, contactId, programId);
        Test.stopTest();
        system.assertEquals('SUCCESS', displayMsg);
    }
    
    @isTest static void validateCouponCodeNotUsableforApplicantTest(){
        
        String enteredCouponCode = 'REVADMIN2023';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];

        hed__Application__c	Aplication = [Select id, name,hed__Applying_To__c From hed__Application__c 
                                           Where hed__Applicant__c = :con.Id];
       
        Aplication.Applied_Coupon__c = coupn.Id;
        Update Aplication;
        
        programId= acc.Id;
        contactId= con.Id;
    	
        Test.startTest();
        COUP_CouponCodeUtility.validateCoupon(enteredCouponCode, contactId, programId);
        Test.stopTest();    
    }
    
    @isTest static void validateCouponCodeNotApplicableforApplicantTest(){
        
        String enteredCouponCode = 'REVA2023';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        Contact con1 = [Select id, FirstName, LastName, Email From Contact Where Email = 'jai@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
        
        hed__Application__c	Aplication = [Select id, name,hed__Applying_To__c From hed__Application__c 
                                           Where hed__Applicant__c = :con1.Id];
       
        Aplication.Applied_Coupon__c = coupn.Id;
        Update Aplication;
       
        programId = acc.Id;
        contactId = con1.Id;
    
        Test.startTest();
        COUP_CouponCodeUtility.validateCoupon(enteredCouponCode, contactId, programId);
        Test.stopTest();
    }
    
   	@isTest static void validateSuccessCouponforProgramTest(){
        string displayMsg= 'SUCCESS';
        String enteredCouponCode = 'REVAPROGRAM2023';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
                
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
        
        programId= acc.Id;
        contactId= con.Id;
        
        Test.startTest();
            COUP_CouponCodeUtility.validateCoupon(enteredCouponCode, contactId, programId);
            Test.stopTest();
        system.assertEquals('SUCCESS', displayMsg);
    }
    
    @isTest static void validateCouponCodeNotUsableforProgramTest(){
        
        String enteredCouponCode = 'REVAPROGRAMADMIN2023';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
                
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
                
        programId= acc.Id;
        contactId= con.Id;
        
        Test.startTest();
            COUP_CouponCodeUtility.validateCoupon(enteredCouponCode, contactId, programId);
            Test.stopTest(); 
    }
    
    @isTest static void validateCouponCodeNotApplicableforProgramTest(){
        
        String enteredCouponCode = 'REVAPROGRAMADMIN2023';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
        String programName1= 'Master of Business Administration';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Account acc1 =[Select id,Name From Account Where Name  = : programName1];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
                
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
       
        programId= acc1.Id;
        contactId= con.Id;
    
        Test.startTest();
            COUP_CouponCodeUtility.validateCoupon(enteredCouponCode, contactId, programId);
            Test.stopTest();
    }

	@isTest static void validateSuccessCouponforCampaignTest(){
        String enteredCouponCode = 'REVACAMPAIGN2023';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
        String campaignName = 'REVA Registration_2023';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
                
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
                
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
        
        Campaign cmpaign = [Select id, Name From Campaign Where Name  = : campaignName];
       
        programId= acc.Id;
        contactId= con.Id;
        
        Test.startTest();
            COUP_CouponCodeUtility.validateCoupon(enteredCouponCode, contactId, programId);
            Test.stopTest();
    }
    
    @isTest static void validateCouponCodeNotUsableforCampaignTest(){
        
        String enteredCouponCode = 'REVACAMP2023';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
        String campaignName = 'REVA Registration_2023';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
                
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
                
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
        
        Campaign cmpaign = [Select id, Name From Campaign Where Name  = : campaignName];
        
        programId= acc.Id;
        contactId= con.Id;
        
        Test.startTest();
            COUP_CouponCodeUtility.validateCoupon(enteredCouponCode, contactId, programId);
            Test.stopTest(); 
    }

	 @isTest static void invalidCouponforApplicantTest(){
        String enteredCouponCode = 'REVAINVALID2023';
        String invalidCouponCode = 'InvalidCoupon';
        String ContactId;
        String programId;
        String programName = 'Bachelor of Architecture';
         
        Account acc =[Select id,Name From Account Where Name  = : programName];
         
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'john@gmail.com'];
         
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
     
        programId= acc.Id;
        contactId= con.Id;
    
        Test.startTest();
            COUP_CouponCodeUtility.validateCoupon(invalidCouponCode, contactId, programId);
            Test.stopTest();
    }

	@isTest static void applyApplicantDiscountTest(){
        String enteredCouponCode = 'APPLICANTDISCOUNT';
        String ContactId;
        String programName = 'Bachelor of Architecture';
        decimal discountedAmount;
        decimal originalAmount;
        decimal discountAppliedAmount;
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'ram@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];

        Student_Fee__c updateStudentFee = [Select id, Amount_Pending__c, Amount__c ,Amount_Paid__c,Description__c,Fee_Master__c,
                                    Fee_Master__r.Fee_Amount__c From Student_Fee__c Where Contact__c =:con.Id Limit 1];
        
        hed__Application__c updateApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                                    Where hed__Applicant__c =:con.Id Limit 1];
        
        contactId= con.Id;
    
        	Test.startTest();
            COUP_CouponCodeUtility.applyDiscount(enteredCouponCode, contactId);
            Test.stopTest();
    }
    
    @isTest static void applyCampaignDiscountTest(){
        String enteredCouponCode = 'CAMPAIGNDISCOUNT';
        String ContactId;
        String programName = 'Bachelor of Architecture';
        decimal discountedAmount;
        decimal originalAmount;
        decimal discountAppliedAmount;
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'ram@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];

        Student_Fee__c updateStudentFee = [Select id, Amount_Pending__c, Amount__c ,Amount_Paid__c,Description__c,Fee_Master__c,
                                    Fee_Master__r.Fee_Amount__c From Student_Fee__c Where Contact__c =:con.Id Limit 1];
        
        hed__Application__c updateApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                                    Where hed__Applicant__c =:con.Id Limit 1];
        
        contactId= con.Id;
    
        	Test.startTest();
            COUP_CouponCodeUtility.applyDiscount(enteredCouponCode, contactId);
            Test.stopTest();
    }
    
    @isTest static void applyProgramDiscountTest(){
        String enteredCouponCode = 'PROGRAMDISCOUNT';
        String ContactId;
        String programName = 'Bachelor of Architecture';
        decimal discountedAmount;
        decimal originalAmount;
        decimal discountAppliedAmount;
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'ram@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];

        Student_Fee__c updateStudentFee = [Select id, Amount_Pending__c, Amount__c ,Amount_Paid__c,Description__c,Fee_Master__c,
                                    Fee_Master__r.Fee_Amount__c From Student_Fee__c Where Contact__c =:con.Id Limit 1];
        
        hed__Application__c updateApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                                    Where hed__Applicant__c =:con.Id Limit 1];
        
        contactId= con.Id;
    
        	Test.startTest();
            COUP_CouponCodeUtility.applyDiscount(enteredCouponCode, contactId);
            Test.stopTest();
    }
    
    @isTest static void applyFreeDiscountTest(){
        String enteredCouponCode = 'FREECOUPON';
        String ContactId;
        String programName = 'Bachelor of Architecture';
        decimal discountedAmount;
        decimal originalAmount;
        decimal discountAppliedAmount;
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'ram@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];

        Student_Fee__c updateStudentFee = [Select id, Amount_Pending__c, Amount__c ,Amount_Paid__c,Description__c,Fee_Master__c,
                                    Fee_Master__r.Fee_Amount__c From Student_Fee__c Where Contact__c =:con.Id Limit 1];
        
        hed__Application__c updateApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                                    Where hed__Applicant__c =:con.Id Limit 1];
        
        contactId= con.Id;
    
        	Test.startTest();
            COUP_CouponCodeUtility.applyDiscount(enteredCouponCode, contactId);
            Test.stopTest();
    }
    
	@isTest static void removeDiscountTest(){
        
        List<COUP_CouponCodeUtility.UtilityRequest> urequestList = new List<COUP_CouponCodeUtility.UtilityRequest>();
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'john@gmail.com'];
        
        COUP_CouponCodeUtility.UtilityRequest uRequest = new COUP_CouponCodeUtility.UtilityRequest();
        uRequest.invocationType = 'NULLIFY_PREV_COUPON';
        uRequest.ContactId=con.id;
        urequestList.add(uRequest);

        Test.startTest();
        COUP_CouponCodeUtility.decideByInvocation(urequestList);
        Test.stopTest();

    }   
}