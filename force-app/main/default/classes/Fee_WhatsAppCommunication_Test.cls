@isTest
private class Fee_WhatsAppCommunication_Test {
    
    @testSetup
    static void makeData(){
        
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = objAcc.id;
        objAccount1.Program_Type__c = 'UG';
        insert objAccount1;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B.Sc in Physics, Mathematics, and Computer Science-(2022-2025)',
            hed__Start_Date__c = system.today().addDays(-5),
            hed__End_Date__c = system.today().addyears(+1),
            hed__Account__c = objAccount1.id
        );
        insert programBatch;
        
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        
        Contact parent = new Contact(
            LastName = 'Parent',
            MobilePhone = '1111111111'
        );
        insert parent;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.School__c = objAcc.id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Quota__c='Management Quota';
        objCon.Email='testing1234@reva.edu.in';
        objCon.Personal_Email__c='naveen123978@gmail.com';
        objCon.hed__Preferred_Email__c='Personal Email';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Program_Batch__c = programBatch.id;
        objCon.School__c=objAcc.id;
        objCon.Primary_Academic_Program__c = objAccount1.id;
        Insert objCon; 
        
        
        
        // Create Program Enrollment
        hed__Program_Enrollment__c progEnrollment = new hed__Program_Enrollment__c(
            hed__Contact__c = objCon.Id,
            hed__Program_Plan__c = programBatch.Id            
        );
        insert progEnrollment;
        
        // Create Term for 2nd Year fees (Term 3)
        hed__Term__c term = new hed__Term__c(
            Name = 'Term 3',
            hed__Account__c = objAccount1.id,
            Program_Batch__c = programBatch.Id,
            hed__Start_Date__c = Date.today().addDays(-7),
            hed__End_Date__c = system.today()+30,// 7 days from now
            Term_Number__c = 3            
        );
        insert term;
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        objStudentFee.Fee_Year__c='2nd year';
        objStudentFee.Due_Date__c = system.today()+58;
        //objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Actual_Program_Fee__c = 5000;
        objStudentFee.Amount_Paid__c = 0;
        objStudentFee.Amount_Pending__c = 5000;
        Insert objStudentFee;
    }
    
    @isTest
    static void testBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new WhatsAppMock());
        
        Test.startTest();
        Fee_WhatsAppCommunication batch = new Fee_WhatsAppCommunication();
        Database.executeBatch(batch);
        Test.stopTest();
        
        System.assertEquals(4, [SELECT count() FROM AsyncApexJob]);
    }
    
    @isTest
    static void testNoFeesToSend() {
        
        Student_Fee__c fee = [SELECT Id FROM Student_Fee__c LIMIT 1];
        fee.Amount_Pending__c = 0;
        update fee;
        
        Test.setMock(HttpCalloutMock.class, new WhatsAppMock());
        
        Test.startTest();
        Fee_WhatsAppCommunication batch = new Fee_WhatsAppCommunication();
        Database.executeBatch(batch);
        Test.stopTest();
        
        System.assertEquals(4, [SELECT count() FROM AsyncApexJob]);
    }
    
    public class WhatsAppMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}