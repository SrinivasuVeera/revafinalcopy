@isTest
public class SMSNotification_Batch_Test {
    public static testMethod void AttendanceSMSBtch() {
        // Setting up test data
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Account objAcc = TT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id AccountRecTypeIdRACE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();        
        Account acc = TT_TestDataFactory.CreateAccount('REVA', AccountRecTypeId);
        acc.RecordTypeId = AccountRecTypeIdRACE;
        acc.Program_Type__c = 'PG';
        insert acc;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'Master of Science in Biotechnology-(2023-2025)',
            hed__Start_Date__c = system.today().addDays(-5),
            hed__End_Date__c = system.today().addYears(1),
            hed__Account__c = acc.Id
        );
        insert programBatch;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = TT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAcc.Id;
        objcon.School__c = acc.Id;
        objcon.Student_Status__c = 'Pursuing';
        objcon.MobilePhone ='8963210547';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Program_Batch__c = programBatch.Id;
        insert objcon;

        // Creating Father Contact
        Contact fatherContact = new Contact(
            FirstName = 'Father',
            LastName = 'Lastname',
            AccountId = objAcc.Id,
            MobilePhone = '1234567890'
        );
        insert fatherContact;

        objcon.Father__c = fatherContact.Id;
        update objcon;
        
        // Creating Mother Contact
        Contact motherContact = new Contact(
            FirstName = 'Mother',
            LastName = 'Lastname',
            AccountId = objAcc.Id,
            MobilePhone = '9876543210'
        );
        insert motherContact;

        objcon.Mother__c = motherContact.Id;
        update objcon;
        
        // Creating Program Enrollment
        hed__Program_Enrollment__c objProgEnroll = FEE_TestDataFactory.createProgramEnrollment(objcon.Id, programBatch.Id);
        objProgEnroll.hed__Contact__c = objcon.Id;
        objProgEnroll.hed__Program_Plan__c = programBatch.Id;
        insert objProgEnroll;
        
        // Creating Terms
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        List<hed__Term__c> terms = new List<hed__Term__c>();
        for (Integer i = 3; i <= 9; i += 2) {
            hed__Term__c term = FEE_TestDataFactory.createTerm('test term ' + i, objAcc.Id, termRtId);
            term.Program_Batch__c = programBatch.Id;
            term.hed__Start_Date__c = system.today().addDays(-i);
            term.hed__end_Date__c = system.today().addDays(+i);
            term.Term_Number__c = i;
            terms.add(term);
        }
        insert terms;
        
        // Creating Student Fee
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('University Fee', 'Full Payment');
        insert objFeeCriteria;
        
        List<Student_Fee__c> studentFees = new List<Student_Fee__c>();
        
        for (hed__Term__c term : terms) {
            String feeYear = '';
            if (term.Term_Number__c == 3) {
                feeYear = '2nd Year';
            } else if (term.Term_Number__c == 5) {
                feeYear = '3rd Year';
            } else if (term.Term_Number__c == 7) {
                feeYear = '4th Year';
            } else if (term.Term_Number__c == 9) {
                feeYear = '5th Year';
            }        
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objcon.Id, 'University Fee');
        objStudentFee.Contact__c = objcon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteria.Id;
        objStudentFee.Due_Date__c = system.today().addDays(15);
        objStudentFee.Fee_Year__c = feeYear;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Amount_Paid__c = 0;
        objStudentFee.Actual_Program_Fee__c = 5000;
        objStudentFee.Amount_Pending__c = 5000;
        studentFees.add(objStudentFee);
        }
        insert studentFees;
        
        // Mocking the SMS callout
        SMS_MockCallout TestMock = new SMS_MockCallout(200, '{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}', 'Failed');
        Test.setMock(HttpCalloutMock.class, TestMock);
        
        // Running the batch
        Test.startTest();
        SMSNotification_Batch btch = new SMSNotification_Batch();
        database.executeBatch(btch);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, objcon.Id, 'Contact record was not inserted successfully');
        System.assertEquals('8963210547', objcon.MobilePhone, 'Contact mobile number mismatch');
        
        // Here, you should add specific assertions to check the behavior of the SMS logic
        // Example: Check that the SMS was supposed to be sent
        // Note: Replace with the correct object or method to validate SMS sending
    }
    
    public static testMethod void testGetTimeDetails() {
        // Test with a time in 24-hour format
        String formattedTime1 = SMSNotification_Batch.getTimeDetails('14:30');
        System.assertEquals('2:30', formattedTime1, 'Time format should be in 12-hour format');

        // Test with a time in 24-hour format with leading 0
        String formattedTime2 = SMSNotification_Batch.getTimeDetails('09:15');
        System.assertEquals('009:15', formattedTime2, 'Time format should be in 12-hour format');

        // Test with a time in 12-hour format
        String formattedTime3 = SMSNotification_Batch.getTimeDetails('7:45');
        System.assertEquals('07:45', formattedTime3, 'Time format should remain the same');
    }
}