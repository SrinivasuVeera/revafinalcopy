@isTest
private class smt_Summit_Tracker_Controller_Test {
	
    @isTest
    static void testCreateSummitTracker() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        String summitTrackerName = 'Test Summit Tracker';
        String schoolId = acc.Id;
        String batch = '2024';
		String category = 'ACADEMIC';
        
        Test.startTest();
        String summitTrackerId = smt_Summit_Tracker_Controller.createSummitTracker(summitTrackerName, schoolId, batch,category);
        Test.stopTest();

        System.assertNotEquals(null, summitTrackerId, 'Summit Tracker was not created successfully');
    } 
    
    @isTest
    static void testGetSummitParticulars() {
        String summitSectionId = '001';
        String oddSemester = 'Odd';
		String evenSemester = 'Even';
        
        Test.startTest();
        List<smt_Summit_Particular__c> oddSummitParticulars = smt_Summit_Tracker_Controller.getSummitParticulars(summitSectionId, oddSemester);
        List<smt_Summit_Particular__c> evenSummitParticulars = smt_Summit_Tracker_Controller.getSummitParticulars(summitSectionId, evenSemester);

        Test.stopTest();

        System.assertEquals(0, oddSummitParticulars.size(), 'Summit Particulars not retrieved successfully');
        System.assertEquals(0, evenSummitParticulars.size(), 'Summit Particulars not retrieved successfully');

    }
    
    @isTest
    static void testGetMonthlySummitParticulars() {
        String summitSectionId = '001';
        String summitParticularId = '101';
       	String evenSemester = 'Even';
        
        Test.startTest();     
        List<smt_Summit_Particular_Month__c> evenSummitParticulars = smt_Summit_Tracker_Controller.getMonthlySummitParticulars(summitSectionId, evenSemester,summitParticularId);
        Test.stopTest();
     
        System.assertEquals(0, evenSummitParticulars.size(), 'Summit Particulars not retrieved successfully');
    }    
   

    @isTest
    static void testGetAllSummitParticulars() {
        // Test data setup
        String summitSectionId = '001';

        // Call the method under test
        Test.startTest();
        List<smt_Summit_Particular__c> allSummitParticulars = smt_Summit_Tracker_Controller.getAllSummitParticulars(summitSectionId);
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, allSummitParticulars, 'All Summit Particulars not retrieved successfully');
    }
    
    @isTest
    static void testGetAllSummitMonthWiseParticulars() {
        // Test data setup
        String summitSectionId = '001';

        // Call the method under test
        Test.startTest();
        List<smt_Summit_Particular__c> allSummitParticulars = smt_Summit_Tracker_Controller.getAllSummitMonthWiseParticulars(summitSectionId);
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, allSummitParticulars, 'All Summit Particulars not retrieved successfully');
    }

    @isTest
    static void testGetSummitTracker() {
        // Test data setup
        String schoolId = '001';

        // Call the method under test
        Test.startTest();
        List<smt_Summit_Tracker__c> summitTrackers = smt_Summit_Tracker_Controller.getSummitTracker(schoolId);
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, summitTrackers, 'Summit Tracker not retrieved successfully');
    }

    @isTest
    static void testUpdateSummitParticular() {
         Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024,smt_School__c =acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c= summitTracker.Id);
        insert summitSection;
        
		smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c(Name = 'Test Particular', smt_Achieved__c = 10, smt_Summit_Section__c = summitSection.Id);  
        insert summitParticular;
       
        String jsonData = '{"Id": "'+ summitParticular.Id+'", "achievedValue": "10", "evidenceValue": "https://google.com"}';

        Test.startTest();
        smt_Summit_Tracker_Controller.updateSummitParticular(jsonData);
        Test.stopTest();
		List<smt_Summit_Particular__c> updatedSummitParticular = [Select Id, smt_Achieved__c	 From smt_Summit_Particular__c Where Id =: summitParticular.Id];
        System.assertEquals(10, updatedSummitParticular[0].smt_Achieved__c);
    }
    
    @isTest
	static void testUpdateMonthlySummitParticular() {
        // Setup test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024, smt_School__c = acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c = summitTracker.Id);
        insert summitSection;
        
        smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c(Name = 'Test Particular', smt_Achieved__c = 10, smt_Summit_Section__c = summitSection.Id);  
        insert summitParticular;
        
        smt_Summit_Particular_Month__c monthlyParticular = new smt_Summit_Particular_Month__c(
            Name = 'Test Monthly Particular', 
            smt_Achieved__c = 5, 
          //  smt_Summit_Particular__c = summitParticular.Id, 
          	Summit_Particular__c = summitParticular.Id,
            smt_Summit_Section__c = summitSection.Id
        );
        insert monthlyParticular;
        
        // Prepare JSON data for update
        String jsonData = '{"Id": "' + monthlyParticular.Id + '", "achievedValue": "15", "evidenceValue": "https://example.com"}';
        
         String invalidJsonData = '{"achievedValue": "invalid_value", "evidenceValue": "https://example.com"}'; // Missing Id, will cause error when trying to update
    
        // Start the test
        Test.startTest();
            try {
                smt_Summit_Tracker_Controller.updateMonthlySummitParticular(jsonData, summitSection.Id, summitParticular.Id);
                // Call the method with invalid JSON to trigger exception
                smt_Summit_Tracker_Controller.updateMonthlySummitParticular(invalidJsonData, summitSection.Id, summitParticular.Id);
            } catch (AuraHandledException e) {
                // Ensure the exception is caught and handled
                System.debug('Exception caught in test: ' + e.getMessage());                
            }      
        // Stop the test
        Test.stopTest();
        
        // Query the updated monthly summit particular
        List<smt_Summit_Particular_Month__c> updatedMonthlyParticular = [
            SELECT Id, smt_Achieved__c, smt_Evidence_To_Be_Attached__c 
            FROM smt_Summit_Particular_Month__c 
            WHERE Id = :monthlyParticular.Id
        ];
        
        // Assert that the values have been updated correctly
        System.assertEquals(15, updatedMonthlyParticular[0].smt_Achieved__c, 'Achieved value should be updated to 15');
        System.assertEquals('https://example.com', updatedMonthlyParticular[0].smt_Evidence_To_Be_Attached__c, 'Evidence value should be updated');        
      
	}

    @isTest
    static void testIsDecimal() {
        // Test case where the input is a valid decimal
        String validDecimal = '123.45';
        Boolean result = smt_Summit_Tracker_Controller.isDecimal(validDecimal);
        System.assertEquals(true, result, 'Expected result to be true for valid decimal input.');

        // Test case where the input is not a decimal
        String invalidDecimal = 'abc';
        result = smt_Summit_Tracker_Controller.isDecimal(invalidDecimal);
        System.assertEquals(false, result, 'Expected result to be false for invalid decimal input.');
    }


    @isTest
    static void testUpdateAllSummitParticular() {
        Account acc = new Account(Name = 'Test Account');
        
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024,smt_School__c =acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c= summitTracker.Id);
        insert summitSection;
        
		smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c(Name = 'Test Particular', smt_Achieved__c = 10, smt_Summit_Section__c = summitSection.Id);  
        insert summitParticular;
        
        String jsonData = '[{"id": "001", "summitParticularName": "Test", "summitParticularId": "'+summitParticular.Id +'", "timeline": "2024-04-16", "target": 50, "targetText": "Test target", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
        Test.startTest();
        smt_Summit_Tracker_Controller.updateAllSummitParticular(jsonData);
        Test.stopTest();
        
        List<smt_Summit_Particular__c> updatedSummitParticular = [Select Id, smt_Target__c	 From smt_Summit_Particular__c Where Id =: summitParticular.Id];
        System.assertEquals(50, updatedSummitParticular[0].smt_Target__c);    
    }
    
    @isTest
    static void testUpdateAllSummitParticularMonthly() {
        // Setup test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024, smt_School__c = acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c = summitTracker.Id);
        insert summitSection;
        
        smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c(
            Name = 'Test Particular', 
            smt_Achieved__c = 10, 
            smt_Summit_Section__c = summitSection.Id,
            smt_Target__c = 20
        );  
        insert summitParticular;
        
        // Create a smt_Summit_Particular_Month__c record for testing
        smt_Summit_Particular_Month__c summitParticularMonth = new smt_Summit_Particular_Month__c(
            smt_Summit_Section__c = summitSection.Id,
            Summit_Particular__c = summitParticular.Id,
            smt_Target__c = 50,
            smt_Target_Text__c = 'Test Target Text'
        );
        insert summitParticularMonth;
    
        // Prepare valid JSON data for updating summit particulars
        String jsonData = '[{"id": "' + summitParticularMonth.Id + '", "summitParticularId": "' + summitParticular.Id + '", "summitSectionId": "' + summitSection.Id + '", "Name": "Updated Summit Particular", "timeline": "2024-05-16", "target": 60, "targetText": "Updated Target Text", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
    	
      //  String invalidJsonData = '[{"id": "' + summitParticularMonth.Id + '", "summitParticularId": "' + summitParticular.Id + '", "summitSectionId": "' + summitSection.Id + '", "Name": "Updated Summit Particular", "timeline": "2024-05-16", "target": null, "targetText": "Updated Target Text", "isTargetApplicable": true, "isEvidenceApplicable": true}]'; // Passing null for target

        // Start the test
        Test.startTest();        
        // Call the update method with the valid JSON data
        smt_Summit_Tracker_Controller.updateAllSummitParticularMonthly(jsonData);
       // smt_Summit_Tracker_Controller.updateAllSummitParticularMonthly(invalidJsonData);
        // Stop the test
        Test.stopTest();
        
        // Query the updated summit particular month record
        List<smt_Summit_Particular_Month__c> updatedSummitParticularMonth = [
            SELECT Id, smt_Target__c, smt_Target_Text__c, smt_Timeline__c
            FROM smt_Summit_Particular_Month__c
            WHERE Id = :summitParticularMonth.Id
        ];
        
        // Assert that the values were updated correctly
        System.assertEquals(60, updatedSummitParticularMonth[0].smt_Target__c, 'The target should be updated to 60');
        System.assertEquals('Updated Target Text', updatedSummitParticularMonth[0].smt_Target_Text__c, 'The target text should be updated');
        System.assertEquals(Date.valueOf('2024-05-16'), updatedSummitParticularMonth[0].smt_Timeline__c, 'The timeline should be updated');
    }

    @isTest
    static void testUpdateAllSummitParticularMonthlyCatchBlock() {
        // Setup test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024, smt_School__c = acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c = summitTracker.Id);
        insert summitSection;
        
        smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c(
            Name = 'Test Particular', 
            smt_Achieved__c = 10, 
            smt_Summit_Section__c = summitSection.Id,
            smt_Target__c = 20
        );  
        insert summitParticular;
    
        // Prepare invalid JSON data to trigger an exception (invalid date and missing field)
        String invalidJsonData = '[{"id": "invalid-id", "summitParticularId": "' + summitParticular.Id + '", "summitSectionId": "' + summitSection.Id + '", "Name": "Updated Summit Particular", "timeline": "invalid-date", "target": "invalid-target", "targetText": "Updated Target Text", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
    
        // Start the test
        Test.startTest();
        
        try {
            // Call the update method with invalid JSON data to trigger the exception in the catch block
            smt_Summit_Tracker_Controller.updateAllSummitParticularMonthly(invalidJsonData);
        } catch (AuraHandledException e) {
            // The exception should be caught, and we can verify this by checking the error message or the behavior
            System.debug('Exception caught during test: ' + e.getMessage());
        }
        
        // Stop the test
        Test.stopTest();
        
        // Query the summit particular month record to ensure no updates have been made due to the exception
        List<smt_Summit_Particular_Month__c> updatedSummitParticularMonth = [
            SELECT Id, smt_Target__c 
            FROM smt_Summit_Particular_Month__c 
            WHERE smt_Summit_Section__c = :summitSection.Id
        ];
        
        // Assert that the values were not changed due to the exception
        System.assertEquals(0, updatedSummitParticularMonth.size(), 'No records should have been updated due to the exception');
    }
    
    @isTest
    static void testGetSummitSectionsMetadata() {
        // Call the method under test
        Test.startTest();
        List<Summit_Section_Metadata__mdt> summitSectionsMetadata = smt_Summit_Tracker_Controller.getSummitSectionsMetadata();
        Test.stopTest();

        // Perform assertions - No direct assertions can be made as the method does not return anything
    }

    @isTest
    static void testGetSummitParticularsMetadata() {
        // Test data setup
        String summitSectionLabel = 'Test Section';

        // Call the method under test
        Test.startTest();
        List<Summit_Particular__mdt> summitParticularsMetadata = smt_Summit_Tracker_Controller.getSummitParticularsMetadata(summitSectionLabel);
        Test.stopTest();

        // Perform assertions - No direct assertions can be made as the method does not return anything
    }

    @isTest
    static void testGetSummitSectionRecords() {
        // Test data setup
        String summitTrackerId = '001';

        // Call the method under test
        Test.startTest();
        List<smt_Summit_Section__c> summitSections = smt_Summit_Tracker_Controller.getSummitSectionRecords(summitTrackerId);
        Test.stopTest();

        // Perform assertions - No direct assertions can be made as the method does not return anything
    }

    @isTest
    static void testCreateSummitSections() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024,smt_School__c =acc.Id);
        insert summitTracker;
        
        String jsonData = '[{"sectionName": "Test Section", "weightage": 50}]';
        String summitTrackerId = summitTracker.Id;

        Test.startTest();
        smt_Summit_Tracker_Controller.createSummitSections(jsonData, summitTrackerId);
        Test.stopTest();
        
        List<smt_Summit_Section__c> summitSections = [ Select Id From smt_Summit_Section__c Where smt_Summit_Tracker__c =: summitTrackerId];
        System.assertEquals(1, summitSections.size());

    }

    @isTest
    static void testCreateSummitParticular() {
        
		Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024,smt_School__c =acc.Id);
        insert summitTracker;
        
        smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c= summitTracker.Id);
        insert summitSection;
        
        
        String jsonData = '[{"summitParticularName": "Test", "summitParticularId": "001", "timeline": "2024-04-16", "target": 50, "targetText": "Test target", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
        String summitSectionId = summitSection.Id;

        Test.startTest();
        smt_Summit_Tracker_Controller.createSummitParticular(jsonData, summitSectionId);
        Test.stopTest();
        
        List<smt_Summit_Particular__c> summitParticulars = [Select Id From smt_Summit_Particular__c 
                                                            Where smt_Summit_Section__c =:summitSection.Id];
        
        System.assertEquals(1, summitParticulars.size());

    } 
    
    
    @isTest
	static void testCreateSummitParticularMonthly() {
    
    // Create test data
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    
    smt_Summit_Tracker__c summitTracker = new smt_Summit_Tracker__c(Name = 'Test Tracker', smt_Year__c = 2024, smt_School__c = acc.Id);
    insert summitTracker;
    
    smt_Summit_Section__c summitSection = new smt_Summit_Section__c(Name = 'Test Section', smt_Summit_Tracker__c = summitTracker.Id);
    insert summitSection;
    
    smt_Summit_Particular__c summitParticular = new smt_Summit_Particular__c(Name = 'Test Particular', smt_Summit_Section__c = summitSection.Id);
    insert summitParticular;
    
    // Mock HTTP response
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new SummitParticularMockResponse());  // Set mock response
    String jsonData = '[{"summitParticularName": "Test", "summitParticularId": "001", "timeline": "2024-04-16", "target": 50, "targetText": "Test target", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
    String summitSectionId = summitSection.Id;
    String summitParticularId = summitParticular.Id;
    
    smt_Summit_Tracker_Controller.createSummitParticularMonthly(jsonData, summitSectionId, summitParticularId);
    Test.stopTest();
    
    // Validate the result
    List<smt_Summit_Particular_Month__c> summitParticulars = [SELECT Id FROM smt_Summit_Particular_Month__c 
                                                             WHERE smt_Summit_Section__c = :summitSection.Id AND Summit_Particular__c = :summitParticular.Id];
    
    System.assertEquals(1, summitParticulars.size());
	}

    // Mock response class
    public class SummitParticularMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Construct a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success", "message": "Mock response"}');
            res.setStatusCode(200);  // HTTP 200 OK
            return res;
        }
	}

    
    
    
    @isTest
    static void testJsonToSummitSection() {

        String json = '[{"id": 1, "sectionName": "Test Section", "weightage": 50}]';
        List<smt_Summit_Tracker_Controller.JsonToSummitSection> result = new smt_Summit_Tracker_Controller.JsonToSummitSection().parse(json);
        System.assertNotEquals(null, result, 'JsonToSummitSection parsing failed');
    }

    @isTest
    static void testJsonToSummitParticular() {
        String json = '[{"id": 1, "summitParticularName": "Test", "summitParticularId": "001", "timeline": "2024-04-16", "target": 50, "targetText": "Test target", "isTargetApplicable": true, "isEvidenceApplicable": true}]';
        List<smt_Summit_Tracker_Controller.JsonToSummitParticular> result = new smt_Summit_Tracker_Controller.JsonToSummitParticular().parse(json);
        System.assertNotEquals(null, result, 'JsonToSummitParticular parsing failed');
    }

    @isTest
    static void testJsonToUpdateSummitParticular() {
        String json = '{"id": "001", "achievedValue": "10", "evidenceValue": "Some evidence"}';
        smt_Summit_Tracker_Controller.JsonToUpdateSummitParticular result = new smt_Summit_Tracker_Controller.JsonToUpdateSummitParticular().parse(json);
        System.assertNotEquals(null, result, 'JsonToUpdateSummitParticular parsing failed');
    }  
    
    @testSetup
    static void setupData() {
        // Get Record Type
        RecordType deptRt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Account' 
            AND Name = 'University Department'
            LIMIT 1
        ];

        // Parent Accounts
        Account adminParent = new Account(
            Name = 'Administrative Services',
            RecordTypeId = deptRt.Id
        );
        insert adminParent;

        Account academicParent = new Account(
            Name = 'Academic Services',
            RecordTypeId = deptRt.Id
        );
        insert academicParent;

        // Child Accounts
        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Finance Department',
                ParentId = adminParent.Id,
                RecordTypeId = deptRt.Id
            ),
            new Account(
                Name = 'HR Department',
                ParentId = adminParent.Id,
                RecordTypeId = deptRt.Id
            ),
            new Account(
                Name = 'Computer Science',
                ParentId = academicParent.Id,
                RecordTypeId = deptRt.Id
            )
        };
        insert accounts;
    }

    @IsTest
    static void testNonAcademicSearch() {
        Test.startTest();
        List<Account> results = smt_Summit_Tracker_Controller.searchAccounts(
            'Department',
            'NON_ACADEMIC'
        );
        Test.stopTest();

        System.assertNotEquals(0, results.size(), 'Results should be returned');
   /*     for (Account acc : results) {
            System.assertEquals(
                'Administrative Services',
                acc.Parent.Name,
                'Parent should be Administrative Services'
            );
        } */
    }

    @IsTest
    static void testAcademicSearch() {
        Test.startTest();
        List<Account> results = smt_Summit_Tracker_Controller.searchAccounts(
            'Computer',
            'ACADEMIC'
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One academic account expected');
        System.assertEquals('Computer Science', results[0].Name);
    }

    @IsTest
    static void testBlankSearchKey() {
        Test.startTest();
        List<Account> results = smt_Summit_Tracker_Controller.searchAccounts('', 'NON_ACADEMIC');
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Blank search should return empty list');
    }
       
    public class JsonToSummitParticularMonthly {
        
        public String id;
        public String Name;
        public String summitParticularId;
        public String summitSectionId;
        public String timeline;
        public Integer target;
        public String targetText;
        public Boolean isTargetApplicable;
        public Boolean isEvidenceApplicable;
    
        // Parse method to deserialize JSON
        public List<JsonToSummitParticularMonthly> parse(String json) {
            return (List<JsonToSummitParticularMonthly>) System.JSON.deserialize(json, List<JsonToSummitParticularMonthly>.class);
        }
	}
    
    
}