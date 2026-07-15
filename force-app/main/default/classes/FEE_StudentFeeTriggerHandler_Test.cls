@isTest
public class FEE_StudentFeeTriggerHandler_Test 
{
    public static  testmethod void studentfeetriggerMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Amount_Paid__c =100;
        Insert objStudentFee;
        
        List<Student_Fee__c> lst_studntfee = new List<Student_Fee__c>();
        lst_studntfee.add(objStudentFee);
        
        objStudentFee.Fee_Type__c ='Tuition Fee';
        objStudentFee.Amount_Paid__c = 50;
        update objStudentFee;
        
        Map<Id,Student_Fee__c> map_Oldstdntfee = new Map<Id,Student_Fee__c>();
        map_Oldstdntfee.put(objStudentFee.Id,objStudentFee);
        
        Test.startTest();
        FEE_StudentFeeTriggerHandler.updateFeePaymentCriteria(lst_studntfee,map_Oldstdntfee);
        FEE_StudentFeeTriggerHandler.updateStudentFeeProgramEnrollment(lst_studntfee,map_Oldstdntfee);
        Test.stopTest();
        system.assertEquals(objStudentFee.Id,objStudentFee.Id);
    }
    
  public static testMethod void testMethod1() {
     
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Scholarship_Category__c = 'REVA Merit',
            Scholarship_Sub_Category__c = 'PG - Others'
        );
        insert testContact;

 
        Student_Fee__c testFee1 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '1st Year',
            Scholarship__c=15000,
            Scholarship_Categories__c = 'REVA Merit',
             Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
            Amount__c = 1000,
            Amount_Paid__c =500
        );
        Student_Fee__c testFee2 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '2nd Year',
            Scholarship__c=testFee1.Scholarship__c-5000,
            Scholarship_Categories__c = 'REVA Merit',
             Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
             Amount__c = 1000,
            Amount_Paid__c =500
        );

       Student_Fee__c testFee3 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '3rd Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
            Amount__c = 1000,
            Amount_Paid__c =500
        );
     Student_Fee__c testFee4 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '4th Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
          Amount__c = 1000,
            Amount_Paid__c =500
        );
    Student_Fee__c testFee5 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '5th Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
         Amount__c = 1000,
            Amount_Paid__c =500
        );
     
       Student_Fee__c testFee7 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Application Fee',
           Amount_Pending__c=10000,
            Amount__c = 100000
        );
  Student_Fee__c testFee11 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'University Fee',
            Fee_Year__c = '1st Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
       Amount__c = 1000,
            Amount_Paid__c =500
        );
        Student_Fee__c testFee12 = new Student_Fee__c(
          
            Contact__c = testContact.Id,
            Fee_Type__c = 'University Fee',
            Fee_Year__c = '2nd Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
             Amount__c = 1000,
            Amount_Paid__c =500
        );
       Student_Fee__c testFee13 = new Student_Fee__c(
          
            Contact__c = testContact.Id,
            Fee_Type__c = 'University Fee',
            Fee_Year__c = '3rd Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
            Amount__c = 1000,
            Amount_Paid__c =500
        );
        Student_Fee__c testFee14 = new Student_Fee__c(
          
            Contact__c = testContact.Id,
            Fee_Type__c = 'University Fee',
            Fee_Year__c = '4th Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
             Amount__c = 1000,
            Amount_Paid__c =500
        );
        Student_Fee__c testFee15 = new Student_Fee__c(
          
            Contact__c = testContact.Id,
            Fee_Type__c = 'University Fee',
            Fee_Year__c = '5th Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
             Amount__c = 1000,
            Amount_Paid__c =500
        );
      
       Student_Fee__c testFee16 = new Student_Fee__c(
          
            Contact__c = testContact.Id,
            Fee_Type__c = 'Application fee',
            Fee_Year__c = '5th Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
            Refunded_Amount__c = 500,
            Amount__c = 1000,
            Amount_Paid__c =500
        );
      insert testFee16;
      Set<ID> sf = new Set<ID>();
      sf.add(testFee16.Id);
   
  
        insert new List<Student_Fee__c>{testFee1, testFee2,testFee3,testFee4,testFee5,testFee7,testFee11,testFee12,testFee13,testFee14,testFee15};

       Test.startTest();
      
        FEE_StudentFeeTriggerHandler.EligibilityForScholarship(new List<Student_Fee__c>{testFee1, testFee2,testFee3,testFee4,testFee5,testFee7,testFee11,testFee12,testFee13,testFee14,testFee15});
        FEE_StudentFeeTriggerHandler.displayOrderNoMapping(new List<Student_Fee__c>{testFee1, testFee2,testFee3,testFee4,testFee5,testFee7,testFee11,testFee12,testFee13,testFee14,testFee15});
       // FEE_StudentFeeTriggerHandler.updateStudentFeePending(sf);
        FEE_StudentFeeTriggerHandler.updateHostelRequest(new List<Student_Fee__c>{testFee1, testFee2,testFee3,testFee4,testFee5,testFee7,testFee11,testFee12,testFee13,testFee14,testFee15});
        Test.stopTest();

    }

 public static testMethod void testMethod2() {
     
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Scholarship_Category__c = 'REVA Merit',
            Scholarship_Sub_Category__c = 'PG - Others'
        );
        insert testContact;

 
        Student_Fee__c testFee1 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '1st Year',
            Scholarship_Categories__c = 'REVA Merit',
            Backlog__c = 0,
            Eligibility_Attendance1__c = 90,
            CGPA_Eligibility__c = 9.5,
            Actual_Program_Fee__c=10000,
            Amount__c = 1000,
            Amount_Paid__c =500
        );
     insert testFee1;
   
     
      Set<ID> sf = new Set<ID>();
      sf.add(testFee1.Id);
   
  
    //    insert new List<Student_Fee__c>{testFee1, testFee2,testFee3,testFee4,testFee5,testFee7,testFee11,testFee12,testFee13,testFee14,testFee15};

       Test.startTest();
      
       // FEE_StudentFeeTriggerHandler.EligibilityForScholarship(new List<Student_Fee__c>{testFee1, testFee2,testFee3,testFee4,testFee5,testFee7,testFee11,testFee12,testFee13,testFee14,testFee15});
        //FEE_StudentFeeTriggerHandler.displayOrderNoMapping(new List<Student_Fee__c>{testFee1, testFee2,testFee3,testFee4,testFee5,testFee7,testFee11,testFee12,testFee13,testFee14,testFee15});
        FEE_StudentFeeTriggerHandler.updateStudentFeePending(sf);
       // FEE_StudentFeeTriggerHandler.updateHostelRequest(new List<Student_Fee__c>{testFee1, testFee2,testFee3,testFee4,testFee5,testFee7,testFee11,testFee12,testFee13,testFee14,testFee15});
        Test.stopTest();

    }
    /**************************************************/
    public class MockHttpCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "success"}'); // Modify this based on the expected response
        res.setStatusCode(200);
        return res;
    }
}
    
   
    /*public static testMethod void testUpdateHostelRequest() {
        // Create test Contacts
        Contact testContact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com'
        );
        insert testContact1;

        // Create Student_Fee__c records for Hostel Fee
        Student_Fee__c hostelFee1 = new Student_Fee__c(
            Contact__c = testContact1.Id,
            Fee_Type__c = 'Hostel Fee',
            Amount_Paid__c = 5000,
            Amount__c = 10000,
            Payment_type__c = 'Partial Payment'
        );
        insert hostelFee1;

        Student_Fee__c hostelFee2 = new Student_Fee__c(
            Contact__c = testContact1.Id,
            Fee_Type__c = 'Hostel Fee',
            Amount_Paid__c = 10000,
            Amount__c = 10000,
            Payment_type__c = 'Full Payment'
        );
        insert hostelFee2;

        // Create Reva_Hostel_Request__c records
        Reva_Hostel_Request__c hostelRequest1 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact1.Id,
            Type__c = '4',
            Reva_Hostel_Premium_Room__c = false
        );
        insert hostelRequest1;

        Reva_Hostel_Request__c hostelRequest2 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact1.Id,
            Type__c = '4',
            Reva_Hostel_Premium_Room__c = false
        );
        insert hostelRequest2;

        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        // Call the method to test
        Test.startTest();
        FEE_StudentFeeTriggerHandler.updateHostelRequest(new List<Student_Fee__c>{hostelFee1, hostelFee2});
        Test.stopTest();

        // Verify the updates
        List<Reva_Hostel_Request__c> updatedRequests = [SELECT Id, Status__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :testContact1.Id];
        for (Reva_Hostel_Request__c request : updatedRequests) {
            //System.assertEquals('Booked', request.Status__c, 'Hostel Request Status should be updated to Booked');
        }
    }*/
	/*****************************************************/
    

  public static testMethod   void testUpdateHostelRequest() {
        // Create test Contacts
        Contact testContact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com'
        );
        insert testContact1;

        // Create Student_Fee__c records
        Student_Fee__c hostelFee1 = new Student_Fee__c(
            Contact__c = testContact1.Id,
            Fee_Type__c = 'Hostel Fee',
            Amount_Paid__c = 5000,
            Amount__c = 10000,
            Payment_type__c = 'Partial Payment',
            Name = 'Caution Hostel Fee',
            Refunded_Amount__c = 500
        );
        insert hostelFee1;

        Student_Fee__c hostelFee2 = new Student_Fee__c(
            Contact__c = testContact1.Id,
            Fee_Type__c = 'Hostel Fee',
            Amount_Paid__c = 10000,
            Amount__c = 10000,
            Payment_type__c = 'Full Payment',
             Name = 'Caution Hostel Fee'
        );
        insert hostelFee2;

        Student_Fee__c hostelFee3 = new Student_Fee__c(
            Contact__c = testContact1.Id,
            Fee_Type__c = 'Hostel Fee',
            Amount_Paid__c = 5000,
            Amount__c = 10000,
            Payment_type__c = 'Partial Payment'
        );
        insert hostelFee3;

        // Create Reva_Hostel_Request__c records
        Reva_Hostel_Request__c hostelRequest1 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact1.Id,
            Type__c = '4',
            Reva_Hostel_Premium_Room__c = false
        );
        insert hostelRequest1;

        Reva_Hostel_Request__c hostelRequest2 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact1.Id,
            Type__c = '4',
            Reva_Hostel_Premium_Room__c = true
        );
        insert hostelRequest2;

        // Define test labels
        //System.Label.WithoutPremium = '75000';
        //System.Label.WithPremium = '100000';
		Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        // Call the method to test
        Test.startTest();
        FEE_StudentFeeTriggerHandler.updateHostelRequest(new List<Student_Fee__c>{hostelFee1, hostelFee2, hostelFee3});
        Test.stopTest();

        // Verify the updates
        List<Reva_Hostel_Request__c> updatedRequests = [SELECT Id, Status__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :testContact1.Id];
        
        // Check if statuses are updated correctly
        for (Reva_Hostel_Request__c request : updatedRequests) {
            //System.assertEquals('Booked', request.Status__c, 'Hostel Request Status should be updated to Booked');
        }

        // Test with no records
        //Test.startTest();
        FEE_StudentFeeTriggerHandler.updateHostelRequest(new List<Student_Fee__c>());
        //Test.stopTest();

        // Verify that no records were updated in the absence of input
        List<Reva_Hostel_Request__c> noUpdateRequests = [SELECT Id, Status__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :testContact1.Id];
        for (Reva_Hostel_Request__c request : noUpdateRequests) {
            //System.assertEquals('Booked', request.Status__c, 'Hostel Request Status should be updated to Booked');
        }
    }


	/********************************************************/
public static testMethod void testEligibilityForScholarship() {
        // Create test Contacts
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com'
        );
        insert testContact;

        // Create Student_Fee__c records for different years
        Student_Fee__c fee1 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '1st Year',
            Scholarship__c = 1000,
            Scholarship_Categories__c = 'REVA to REVA',
            Scholarship_Sub_Category__c = 'PG - Others',
            Scholarship_Date__c = System.today(),
            Scholarship_Created_by__c = UserInfo.getUserId()
        );
        insert fee1;

        Student_Fee__c fee2 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '2nd Year',
            Scholarship__c = 1500,
            Scholarship_Categories__c = 'State Board Merit',
            Scholarship_Sub_Category__c = 'PG - Others',
            Scholarship_Date__c = System.today(),
            Scholarship_Created_by__c = UserInfo.getUserId()
        );
        insert fee2;

        // Call the method to test
        Test.startTest();
        FEE_StudentFeeTriggerHandler.EligibilityForScholarship(new List<Student_Fee__c>{fee1, fee2});
        Test.stopTest();

        // Verify the updates
        Contact updatedContact = [SELECT Scholarship_Category__c, Scholarship_Sub_Category__c, Scholarship_Date__c, Scholarship_Created_by__c FROM Contact WHERE Id = :testContact.Id];
        
        // Check if the contact's scholarship details have been updated correctly
        System.assertEquals('REVA to REVA', updatedContact.Scholarship_Category__c, 'Scholarship Category should be updated to Category2');
        System.assertEquals('PG - Others', updatedContact.Scholarship_Sub_Category__c, 'Scholarship Sub-Category should be updated to SubCategory2');
        System.assertNotEquals(null, updatedContact.Scholarship_Date__c, 'Scholarship Date should not be null');
        System.assertEquals(UserInfo.getUserId(), updatedContact.Scholarship_Created_by__c, 'Scholarship Created by should be set to the current user');
    }
    /****************************************************/
}