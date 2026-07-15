@isTest
public with sharing class KnowlarityUtils_Test {

    @TestSetup
    static void makeData(){
        Profile p = [select id from profile where name ='Counselor'];
        User counselorOwner = [Select id, name from User where ProfileId=:p.id Limit 1];

        List<sObject> recCollection = new List<sObject>();

        Lead l = new Lead();
        l.FirstName = 'First Name Lead';
        l.LastName = 'Last Name Lead';
        l.Status = 'Verified';
        l.Company = l.LastName;
        l.MobilePhone = '+91-7406507562';
        l.IsConverted= false;
        l.OwnerId = counselorOwner.Id;
        recCollection.add(l);

        Id conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact cPaid = new COntact();
        cPaid.FirstName = 'First Name Contact';
        cPaid.LastName = 'Last Name Contact';
        cPaid.Application_Fee_Paid__c = true;
        cPaid.RecordTypeId = conRecId;
        cPaid.OwnerId =  counselorOwner.Id;
        recCollection.add(cPaid);

        Contact cUnpaid = new COntact();
        cUnpaid.FirstName = 'First Name Contact';
        cUnpaid.LastName = 'Last Name Contact';
        cUnpaid.Application_Fee_Paid__c = false;
        cUnpaid.RecordTypeId = conRecId;
        cUnpaid.OwnerId =  counselorOwner.Id;
        recCollection.add(cUnpaid);

        insert recCollection;
    }

    @isTest
    public static void getCallListTest(){
        String buttonTypeAll ='ALL';
        String buttonTypeUnpaid ='Unpaid';
        String buttonTypePaid ='Paid';
        Profile p = [select id from profile where name ='Counselor'];
        User counselorOwner = [Select id, name from User where ProfileId=:p.id Limit 1];
        List<KnowlarityUtils.CallTarget> allCallTargetList;
        List<KnowlarityUtils.CallTarget> unPaidCallTargetList;
        List<KnowlarityUtils.CallTarget> paidCallTargetList;

        system.runAs(counselorOwner){
            Test.startTest();
            allCallTargetList =  KnowlarityUtils.getCallList(counselorOwner.Id, buttonTypeAll);
            unPaidCallTargetList = KnowlarityUtils.getCallList(counselorOwner.Id, buttonTypeUnpaid);
            paidCallTargetList = KnowlarityUtils.getCallList(counselorOwner.Id, buttonTypePaid);
            Test.stopTest();
        }


        system.assertEquals(3, allCallTargetList.size());
        system.assertEquals(1, unPaidCallTargetList.size());
        system.assertEquals(1, paidCallTargetList.size());
    }


}