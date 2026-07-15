@isTest
public class WhatsAppFollowUpBatch3Test {
	 static testMethod void testBatchExecution3() {
         
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        //accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;       
         
        // Create Fee_Master__c records
        hed__Program_Plan__c progBatch = new hed__Program_Plan__c();
        progBatch.Name = 'B. Tech in Mechatronics Engineering-(2024-2028)';
        insert progBatch;

        List<Fee_Master__c> feeMasterList = new List<Fee_Master__c>();
        Fee_Master__c feeMaster = new Fee_Master__c(
            Program_Batch__c = progBatch.Id,
            IsActive__c = true,
            Fee_Type__c = 'Application Fee',
            Applicant_Category__c = 'Indian (SAARC)'
        );
        feeMasterList.add(feeMaster);
        insert feeMasterList;

        // Test data setup for hed__Application__c and hed__Applicant__c
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 1; i++) {
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Program_Batch__c = progBatch.Id, // Ensure this matches the Program_Batch__c in Fee_Master__c
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId(),
                Admission_Mode__c = 'UQ',
                Primary_Academic_Program__c = accRecPhd.Id
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) {
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0') + '2',
                hed__Application_Status__c = 'Incomplete'
            );
            applications.add(app);
        }
        insert applications;
   		
    //    Test.setMock(HttpCalloutMock.class, new WhatsAppMockResponse());
        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch3 batch = new WhatsAppFollowUpBatch3();
        Database.executeBatch(batch);
        Test.stopTest();
         
         
         
/*      
       id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
       Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
       // accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        //accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        hed__Program_Plan__c mbaAcc = new hed__Program_Plan__c();
        mbaAcc.Name = 'Master of Business Administration(2024)';
       // mbaAcc.RecordTypeId = accAcademicProgRecTypeId;
        mbaAcc.hed__Account__c =accRecPhd.Id;
        insert mbaAcc;
      
        // Test data setup
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) { // create multiple records for testing
            Contact applicant = new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i,
                Application_Fee_Paid__c = true,
                Primary_Academic_Program__c = accRecPhd.Id,
                RecordTypeId  = conRecTypeId,
                Admission_Mode__c ='UQ',
                Program_Batch__c=mbaAcc.Id
                
            );
            contacts.add(applicant);
        }
        insert contacts;

        List<hed__Application__c> applications = new List<hed__Application__c>();
        for (Integer i = 0; i < contacts.size(); i++) { 
            hed__Application__c app = new hed__Application__c(
                hed__Applicant__c = contacts[i].Id,
                Application_Number__c = 'APP' + String.valueOf(i).leftPad(3, '0'),
                hed__Application_Status__c = 'Incomplete'
            );
            applications.add(app);
        }
        insert applications;

     //  Test.setMock(HttpCalloutMock.class, new WhatsAppMockResponse());
        // Start the batch
        Test.startTest();
        WhatsAppFollowUpBatch3 batch = new WhatsAppFollowUpBatch3();
        Database.executeBatch(batch);
        Test.stopTest(); */
      } 
    
    // Mock response class for WhatsApp callout
    	public class WhatsAppMockResponse implements HttpCalloutMock {
        // This method mocks the response for the HTTP request
            public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status": "success"}');
                res.setStatusCode(200);
                return res;
            }
    	}
}