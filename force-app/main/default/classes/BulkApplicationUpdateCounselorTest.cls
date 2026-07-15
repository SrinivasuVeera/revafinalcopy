@isTest
public class BulkApplicationUpdateCounselorTest {
    
    @isTest
    static void BulkApplicationUpdateCounselorTesting(){
        List<Id> appIds = new List<Id>();
        Profile pr = [SELECT Id, Name, Description FROM Profile where name ='System Administrator' LIMIT 1];
        User us = new User(
            firstName ='test',
            lastName ='User',
            Email='test@gmail.com',
            isActive = true,
            Username = 'test@gmail.com.reva.COUAT1908', 
            Alias ='lal',
            TimeZoneSidKey ='Asia/Kolkata', 
            LocaleSidKey='en_IN',
            EmailEncodingKey ='UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pr.Id
        );
        insert us;
        String programName = 'Bachelor of Architecture';
        
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
        
        Contact testContact1 = new Contact(
            FirstName = 'Test1',
            LastName = 'Contact1',
            Email = 'test1@test.com',
            Phone = '9999999999'
        );
        insert testContact1;
        
        Contact testContact2 = new Contact(
            FirstName = 'Test2',
            LastName = 'Contact2',
            Email = 'test2@test.com',
            Phone = '8888888888'
        );
        insert testContact2;
        //Create test hed__Application__c record and link it to the test contact record
        hed__Application__c testApplication1 = new hed__Application__c(
            hed__Applicant__c = testContact1.Id,
            hed__Application_Status__c = 'New',
            Concession_Status__c = 'Initiated',
            School__c = 'Test School',
            Application_Number__c = '1234',
            Concession_1st_Year__c = 0.0,
            Concession_2nd_Year__c = 0.0,
            Concession_3rd_Year__c = 0.0,
            Concession_4th_Year__c = 0.0,
            Concession_5th_Year__c =0.0
        );
        insert testApplication1;
        appIds.add(testApplication1.id);
        
        hed__Application__c testApplication2 = new hed__Application__c(
            hed__Applicant__c = testContact2.Id,
            hed__Application_Status__c = 'New',
            Concession_Status__c = 'Initiated',
            School__c = 'Test School2',
            Application_Number__c = '5678',
            Concession_1st_Year__c = 0.0,
            Concession_2nd_Year__c = 0.0,
            Concession_3rd_Year__c = 0.0,
            Concession_4th_Year__c = 0.0,
            Concession_5th_Year__c =0.0
        );
        insert testApplication2;
		randa__Application_Review__c testAR = new randa__Application_Review__c();
        testAR.randa__Application__c = testApplication1.id;
		insert testAR;
        
        appIds.add(testApplication2.id);
        System.assert(!appIds.isEmpty(),'List should not be empty'); 
        List<BulkApplicationUpdateCounselor.UpdateOwnerInput> UI = new List<BulkApplicationUpdateCounselor.UpdateOwnerInput>();
        BulkApplicationUpdateCounselor.UpdateOwnerInput input = new BulkApplicationUpdateCounselor.UpdateOwnerInput();
        input.recordIds = appIds;
        input.newOwnerId = us.Id;
        UI.add(input);
        Test.startTest();
        UpdateApplicationOwnerFlowAction.updateOwner(UI);
        Test.stopTest();
    }
}