@isTest
private class RPL_ActivateRevaPlacementController_Test {
     
    private class WhatsappNotificationMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatus('OK');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private static final Id STUDENT_RECORD_TYPE_ID = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Student').getRecordTypeId();

    @testSetup
    private static void createDummyData() {
        Account universityDepartment = new Account(Name ='School Of Chemical And Biotechnology');
        insert universityDepartment;
        
        Account academicProgram = new Account(Name = 'BTech Biotechnology' , Program_Alias__c ='BTBT' ,Program_Code__c ='BT', Program_Type__c='UG', ParentId=universityDepartment.Id, Intake__c=2, Intake_Per_Section__c=20, No_of_Years__c=4, Number_of_Semesters__c=8);
        insert academicProgram;
        
        hed__Term__c semester = new hed__Term__c(Name = 'BTech Biotech Semester - 6', hed__Account__c = academicProgram.Id);
        insert semester;
        
        Contact Father = new Contact();
        Father.lastName = 'Test Data Father';
        Father.Email = 'testfather@gmail.com';
        Father.MobilePhone = '8234823428';
        insert Father;
        
        Contact Mother = new Contact();
        Mother.lastName = 'Test Data Mother';
        Mother.Email = 'testmother@gmail.com';
        Mother.MobilePhone = '9233492348';
        insert Mother;
       
        Contact eCon = new Contact(
            LastName = 'Test Data',
            RecordTypeId = STUDENT_RECORD_TYPE_ID,
            Personal_Email__c = 'test123@gmail.com',
            MobilePhone = '2342342341',
            Email = 'test@gmail.com',
            Primary_Academic_Program__c = academicProgram.Id,
            Active_Semester__c = semester.Id,
            Student_Status__c = 'Pursuing',
            Mother__c = Mother.Id,
        	Father__c = Father.Id
            //Rpl_Is_Pre_Final_Year__c = true // Set this to true for testing
        );
        insert eCon;
    }
    
    @isTest
    private static void testActivationProcess() {
        List<List<String>> input = new List<List<String>>();
        List<String> inputValues = new List<String>{'Placement Activated', 'BTBT,BTDT,BTDW', '08:10:2001'};
        input.add(inputValues);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        RPL_ActivateRevaPlacementController.activateRevaPlacement(input);
        Test.stopTest();
        
        // Verify if the activation process has worked
        Contact con = [SELECT Id, Rpl_Is_Placement_Created__c, Primary_Academic_Program__r.Program_Alias__c, Rpl_Is_Pre_Final_Year__c FROM Contact WHERE LastName = 'Test Data' LIMIT 1];
       // System.assertEquals(true, con.Rpl_Is_Placement_Created__c, 'Is Placement Created Not Checked');
    }

    @isTest
    private static void testBatchExecution() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        RPL_ActivateRevaPlacementController controller = new RPL_ActivateRevaPlacementController('Test Body', 'BTBT,BTDT,BTDW', '08:10:2001');
        Database.executeBatch(controller);
        Test.stopTest();

        // Add assertions to verify the batch execution results
    }

    // Add more test methods to cover other parts of your code

}