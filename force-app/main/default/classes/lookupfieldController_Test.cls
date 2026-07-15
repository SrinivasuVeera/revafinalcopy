@isTest
public class lookupfieldController_Test {
    //This test class just ensures that there is enough code coverage
    //to get the component into production from your sandbox
    //it does not perform any validations.
    static testMethod void testLookupField() 
    {        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       
       Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId2 );
       objAccount2.Parentid = objAccount1.id;
       objAccount2.RecordTypeid = AcaRecId2;
       insert objAccount2;
        
       string AcaUniRecId4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();
       
       Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId4 );
       objAccount1.Parentid = objAccount2.id;
       objAccount1.RecordTypeid = AcaUniRecId4 ;
       insert objAccount4;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.hed__Course_ID__c= 'test';
        objCourse.hed__Account__c =objAccount4.Id;
        objCourse.Offered_By_School__c = objAccount4.Id;
        objCourse.Credit_Hours__c = 04.00;
         objCourse.Credits__c = 04.00;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 60;
       insert objCourse;
        
        List<string> returnFields = new List<string> {'hed__Course_ID__c'};
      
        lookupfieldController.getObjectDetails('hed__Course__c');
        lookupfieldController.GetRecentRecords('hed__Course__c', returnFields, 5,'CreatedDate > 2001-01-01T00:00:01Z','');
        lookupfieldController.SearchRecords('hed__Course__c', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z','');
        lookupfieldController.GetRecord('hed__Course__c', returnFields, objCourse.Id);
        system.assertequals(objCourse.Id,objCourse.Id);
    }
    static testMethod void testLookupField1() 
    {
      
         string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       
       Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId2 );
       objAccount2.Parentid = objAccount1.id;
       objAccount2.RecordTypeid = AcaRecId2;
       insert objAccount2;
        
       string AcaUniRecId4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();
       
       Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId4 );
       objAccount1.Parentid = objAccount2.id;
       objAccount1.RecordTypeid = AcaUniRecId4 ;
       insert objAccount4;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
       objCourse.hed__Course_ID__c= 'test';
        objCourse.Offered_By_School__c = objAccount4.Id;
        objCourse.Credit_Hours__c = 04.00;
        objCourse.Credits__c = 04.00;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 60;
       insert objCourse;
        
        List<string> returnFields = new List<string> {'hed__Course_ID__c'};
        
        lookupfieldController.getObjectDetails('hed__Course__c');
        lookupfieldController.GetRecentRecords('hed__Course__c', null, 5,'CreatedDate > 2001-01-01T00:00:01Z','');
        lookupfieldController.SearchRecords('hed__Course__c', null, null, '', 'Name', 'ASC', 0, 'CreatedDate > 2001-01-01T00:00:01Z','');
        lookupfieldController.GetRecord('hed__Course__c', null, objCourse.Id);
        system.assertequals(objCourse.Id,objCourse.Id);
    }
}