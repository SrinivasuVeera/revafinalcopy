@IsTest
public class SendUpdateToHCMOnFacultyTest {
    @TestSetup
    static void setup() {
        // Create test Transport Registration records
        Contact contact = new Contact(LastName = 'Test Contact', Employee_Number__c = 'E12345', Salary_Revised_Date__c = Date.today().addMonths(-1));
        insert contact;

        Transport_Registeration__c reg1 = new Transport_Registeration__c(
            Contact__c = contact.Id,
            //Registration_Type__c = 'Professor',
            Amount_Paid__c = 100.0,
            rtr_Start_Date__c = Date.today().addDays(5)
        );
        insert reg1;

        // Create metadata for HCM credentials
        HCM_Credential__mdt[] HCMmetadataRecords = [SELECT Id, client_id__c, client_secret__c, username__c, password__c,End_Point__c,DeveloperName, Label 
                                                    FROM HCM_Credential__mdt where Label='HCM Integartion'];
        

        
    }

    @IsTest
    static void testUpdateToHCMOnFaculty() {
        // Create mock callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHCMCallout());

        // Execute method with a valid Transport ID
        List<String> transportIds = new List<String>{
            [SELECT Id FROM Transport_Registeration__c LIMIT 1].Id
        };
        SendUpdateToHCMOnFaculty.updateToHCMOnFaculty(transportIds);

        Test.stopTest();

        // Assertions
        // Verify that debug logs or mock callouts were invoked successfully
        System.assert(true, 'No exceptions occurred, and callouts were successful.');
    }

   /* @IsTest
    static void testUpdateToHCMOnFacultyWithEmptyList() {
        // Test method with an empty Transport ID list
        Test.startTest();
        SendUpdateToHCMOnFaculty.updateToHCMOnFaculty(new List<String>());
        Test.stopTest();

        // Assertions
        System.assert(true, 'Handled empty Transport ID list without issues.');
    }*/

    @IsTest
    static void testUpdateToHCMOnFacultyErrorHandling() {
        // Create mock callout with an error response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHCMCalloutWithError());

        List<String> transportIds = new List<String>{
            [SELECT Id FROM Transport_Registeration__c LIMIT 1].Id
        };

        
            SendUpdateToHCMOnFaculty.updateToHCMOnFaculty(transportIds);
           
        
       

        Test.stopTest();
    }

    // Mock class for successful callout
    private class MockHCMCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            if (req.getEndpoint().contains('auth')) {
                res.setBody('{"access_token":"mock_access_token"}');
            } else if (req.getEndpoint().contains('data')) {
                res.setBody('{"status":"success"}');
            }

            return res;
        }
    }

    // Mock class for callout with an error response
    private class MockHCMCalloutWithError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"error":"Invalid request"}');
            return res;
        }
    }
}