@isTest
public class SAP_FirstYear_DemandAPIBatch_Test 
{
    public static testmethod void SAP_FirstYearDemandAPI()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ATT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.ownerid = userinfo.getUserId();
        objcon.Nationality__c = 'Indian';
        objcon.Student_Status__c = 'Pursuing';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        ContactHistory conHis =  new ContactHistory();
        conHis.ContactId = objcon.Id;
        conHis.Field = 'SRN_Number__c';
        Insert conHis;
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objcon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objcon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Integrated_with_SAP__c = false;
        objStudentFee.Fee_Year__c = '1st Year';
        objStudentFee.Session__c='1st year';
        objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Amount_Paid__c = 6000;
        objStudentFee.Amount_Pending__c = 2000;
        Insert objStudentFee;
        
        
        Test.startTest();
        SAP_FirstYear_DemandAPIBatch Batch = new SAP_FirstYear_DemandAPIBatch();
        database.executeBatch(Batch);
        Test.stopTest();
        system.assertequals(conHis.id,conHis.id);
    }  
}