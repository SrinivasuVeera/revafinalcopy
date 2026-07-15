@isTest
private class WhatsAppMsgTriggeredSummeryTest {

    @isTest
    static void testGetWhatsAppTriggerCount_Batch1() {        
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'TestContact',
            Application_Fee_Paid__c = false,
            Primary_Academic_Program__c = '0015j00000etbToAAI'       
        );
        insert testContact;

        // Call the method to be tested
        List<Integer> result = WhatsAppMsgTriggeredSummery.getWhatsAppTriggerCount();

        // Assert that the result is as expected
        System.assertEquals(0, result[1], 'Expected batch1Count to be 0');
    }
	
    @isTest
    static void testGetWhatsAppTriggerCount_Batch2()
        {
            
		//Insert contact Record
        Contact cRec=new Contact();
        Id ApplicantReordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        cRec.LastName = 'Test';
        cRec.Application_Fee_Paid__c=true;
        cRec.Admission_Mode__c='UQ';       
        cRec.MobilePhone='801999999';
      
        insert cRec;
        //Insert test application
        hed__Application__c testApp = new hed__Application__c();
        testApp.hed__Application_Status__c='started';
        testApp.hed__Applicant__c=cRec.id;
        insert testApp;

   		// Call the method to be tested
        List<Integer> result = WhatsAppMsgTriggeredSummery.getWhatsAppTriggerCount();

        // Assert that the result is as expected
        System.assertEquals(0, result[1], 'Expected batch2Count to be 0');
}
    
     @isTest
    static void testGetWhatsAppTriggerCount_Batch3()
    {      
        
        //Insert contact Record
        Contact cRec=new Contact();
        Id ApplicantReordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        cRec.LastName = 'Test';
        cRec.Application_Fee_Paid__c=true;
        cRec.Admission_Mode__c='UQ';       
        cRec.MobilePhone='801999999';
      
        insert cRec;
        //Insert test application
        hed__Application__c testApp = new hed__Application__c();
        testApp.hed__Application_Status__c='Incomplete';
        testApp.hed__Applicant__c=cRec.id;
        insert testApp;

   		// Call the method to be tested
        List<Integer> result = WhatsAppMsgTriggeredSummery.getWhatsAppTriggerCount();

        // Assert that the result is as expected
        System.assertEquals(0, result[2], 'Expected batch2Count to be 0');
	}    
    
    @isTest
    static void testGetWhatsAppTriggerCount_PAFpending()
    {  
        //Integer currentYear = 2024;
        String batchYearPrefix = '2024';
        hed__Program_Plan__c progPlan = new hed__Program_Plan__c();
        progPlan.Name = 'Bachelor of Computer Applications-(2024-2027)';
        insert progPlan;
        
        //Insert contact Record
        Contact cRec=new Contact();
        Id ApplicantReordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        cRec.LastName = 'Test';
        cRec.Application_Fee_Paid__c=true;
        cRec.Admission_Mode__c='UQ';
      //  cRec.Program_Type__c = 'UG';
        cRec.MobilePhone='801999999';      
        cRec.Program_Batch__c = progPlan.Id;
        insert cRec;
        
        //Insert test application
        hed__Application__c recApp = new hed__Application__c();
        recApp.Application_Number__c = '23020700111';
        recApp.hed__Application_Status__c='In Review';
        recApp.Provisional_Admission_Fee_Paid__c = false;
        recApp.hed__Applicant__c=cRec.id;        
        insert recApp;

   		// Call the method to be tested
        List<Integer> result = WhatsAppMsgTriggeredSummery.getWhatsAppTriggerCount();

        // Assert that the result is as expected
        System.assertEquals(1, result[3], 'Expected PAF batch Count to be 1');
	} 
    
     @isTest
    static void testgetProvisionalAdmissionFeePaid()
    {  
        DateTime lastBatchRanDateTime = DateTime.now().addDays(-1);
        DateTime lastBatchRanDateTime1 = DateTime.now();
        
        hed__Program_Plan__c progPlan = new hed__Program_Plan__c();
        progPlan.Name = 'Bachelor of Computer Applications-(2024-2027)';
        insert progPlan;
        
        //Insert contact Record
        Contact cRec=new Contact();
        Id ApplicantReordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        cRec.LastName = 'Test';
        cRec.Application_Fee_Paid__c=true;
        cRec.Admission_Mode__c='UQ';       
        cRec.MobilePhone='801999999';      
        cRec.Program_Batch__c = progPlan.Id;
        insert cRec;
        
        //Insert test application
        hed__Application__c recApp = new hed__Application__c();
        recApp.Application_Number__c = '23020700111';
        recApp.hed__Application_Status__c='In Review';
        recApp.Provisional_Admission_Fee_Paid__c = true;
        recApp.hed__Applicant__c=cRec.id;
		//recApp.SystemModstamp = lastBatchRanDateTime1;        
        insert recApp;

   		// Call the method to be tested
        Integer result = WhatsAppMsgTriggeredSummery.getProvisionalAdmissionFeePaid(lastBatchRanDateTime);

        // Assert that the result is as expected
        System.assertEquals(1, result, 'Expected PAF batch Count to be 1');
	}
   
    @isTest
    static void testGetApplicationFeePaidCount() {
        // Create test data
        DateTime lastBatchRanDateTime = DateTime.now().addDays(-1);
        DateTime lastBatchRanDateTime1 = DateTime.now();
        List<Student_Payment__c> payments = new List<Student_Payment__c>{
            new Student_Payment__c(Fee_Type__c = 'Application Fee', Payment_Status__c = 'Success', Payment_Date_Time__c = lastBatchRanDateTime1)
        };
        insert payments;

        // Call the method to be tested
        Integer feePaidCount = WhatsAppMsgTriggeredSummery.getApplicationFeePaidCount(lastBatchRanDateTime);

        // Assert the result
        System.assertEquals(1, feePaidCount, 'Fee paid count should be 1');
        System.assertNotEquals(0, feePaidCount, 'Fee paid count should not be 0');
    }

    @isTest
    static void testGetLatestStatusChangeList() {
        // Create test data
        DateTime lastBatchRanDateTime = DateTime.now().addDays(-1);
        hed__Application__c application = new hed__Application__c();
        insert application;
        List<hed__Application__History> historyRecords = new List<hed__Application__History>{
            new hed__Application__History(
                Field = 'hed__Application_Status__c',              
                ParentId = application.Id
            )
        };
        upsert historyRecords;

        // Call the method to be tested
        List<hed__Application__History> latestStatusChangeList = WhatsAppMsgTriggeredSummery.getLatestStatusChangeList(lastBatchRanDateTime);

        // Assert the result
        System.assertEquals(1, latestStatusChangeList.size(), 'There should be one status change record');
      
    }

}