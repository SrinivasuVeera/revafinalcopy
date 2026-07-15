@isTest
public class RegistrationProcessUtilityTest {
    
    @isTest
    public static void sequenceNumberMethod(){
        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = '230401';
        sequenceNo.Integer_Five__c = 94;
        insert sequenceNo;
        Test.startTest();
       
   		 //RegistrationProcessUtility.getNextSequence('230401');
       	 RegistrationProcessUtility.generateApplNoSequence('230401');
        Test.stopTest();
    }

    @isTest
    public static void challanNumberMethod(){
        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = 'RU23';
        sequenceNo.Integer_Five__c = 94;
        insert sequenceNo;
        Test.startTest();
       
   		 //RegistrationProcessUtility.getNextSequence('230401');
       	 RegistrationProcessUtility.generateChallanNoSequence('RU23');
        Test.stopTest();
    }

    @isTest
    public static void testCETApplicationNumber(){
        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = 'CET';
        sequenceNo.Integer_Five__c = 0;
        insert sequenceNo;
        
        Test.startTest();
       	String cetApplNo = RegistrationProcessUtility.getCETApplicationNumber('UG','CET');
        Test.stopTest();

        System.assertEquals('UGCET2500001', cetApplNo);
    }
     @isTest
    public static void testPGCETApplicationNumber(){
        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = 'PGCET';
        sequenceNo.Integer_Five__c = 0;
        insert sequenceNo;
        
        Test.startTest();
       	String cetApplNo = RegistrationProcessUtility.getCETApplicationNumber('UG','PGCET');
        Test.stopTest();

        System.assertEquals('PGCET2500001', cetApplNo);
    }
     @isTest
    public static void testComedKApplicationNumber(){
        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = 'CDK';
        sequenceNo.Integer_Five__c = 0;
        insert sequenceNo;
        
        Test.startTest();
       	String cetApplNo = RegistrationProcessUtility.getCETApplicationNumber('UG','CDK');
       RegistrationProcessUtility.getCounselorIndex();
        Test.stopTest();

        System.assertEquals('UGCDK2500001', cetApplNo);
    }
}