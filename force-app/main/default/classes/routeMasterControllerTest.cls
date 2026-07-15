@isTest
private class routeMasterControllerTest {
 // Inner class to mock the SMS API callout
    private class SMSAPIMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Simulate a successful SMS API response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true}');
            return res;
        }
    }   
    @isTest
    static void testSearchRoute() {
        // Test data setup
        List<RTR_Route_Master__c> routeList = new List<RTR_Route_Master__c>();
        for (Integer i = 0; i < 5; i++) {
            routeList.add(new RTR_Route_Master__c(
                RTR_Route_Path__c = 'Path' + i
            ));
        }
        insert routeList;
        
         List<RTR_Route_Pick_Up_Point__c> pickUpPoints = new List<RTR_Route_Pick_Up_Point__c>();
    for (RTR_Route_Master__c route : routeList) {
        pickUpPoints.add(new RTR_Route_Pick_Up_Point__c(
            Pin_Code__c = '12345',
            RTR_Route_Master__c = route.Id
        ));
    }
    insert pickUpPoints;
        
        List<RTR_Route_Master__c> result = routeMasterController.searchRoute('Path');
        System.assertEquals(routeList.size(), result.size(), 'Incorrect number of records returned.');       
    }
    
    @isTest
    static void testSearchRecordType() {
        Id StudentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact cons = new Contact(FirstName= 'test name',
                                   LastName='Name',
                                   // Active_Semester__c = sem.Id,
                                   Application_Number__c = '1223467',
                                   Select_Category__c ='	Karnataka',
                                   //Father_Name__c= 'rahul',
                                   recordTypeId=StudentRecordTypeId,
                                   Mother_Name__c='sobha',
                                   Email='testuser@example.com'
                                  );
        
        insert cons;
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'];
        User testUser = new User(
            contactId = cons.Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            UserName = 'testuser@example.com',
            ProfileId = testProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        
        System.runAs(testUser) {           
            Contact result = routeMasterController.searchRecordType();
            System.assertEquals('test name', result.FirstName, 'Incorrect Contact record returned.');
        }
    }
    
    @isTest
    static void testUpdatePayableAmount() {
        // Test data setup (create a test user)
        Id ProfessorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        Contact cons = new Contact(FirstName= 'test name',
                                   LastName='Name',                                 
                                   Application_Number__c = '1223467',
                                   Select_Category__c ='	Karnataka',                                  
                                   recordTypeId=ProfessorRecordTypeId,
                                   Mother_Name__c='sobha',
                                   Email='testuser23@example.com',
                                   Salary__c = 20000 
                                  );
        
        insert cons;
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor'];
        User testUser = new User(
            //contactId = cons.Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser23@example.com',
            UserName = 'paytest123@example.com',
            ProfileId = testProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        System.runAs(testUser) {
            Decimal result = routeMasterController.updatePayableAmount();
            System.assertNotEquals(0, result, 'Payable amount should not be zero.');        
        }
    }
    
    //RevaRequestMethod
    @isTest
    static void testsearchRevaRequest(){
        // Test data setup (create a test user)
        Id StudentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact cons = new Contact(FirstName= 'test Request',
                                   LastName='request',
                                   Application_Number__c = '1223467',
                                   Select_Category__c ='	Karnataka',
                                   recordTypeId=StudentRecordTypeId,
                                   Mother_Name__c='sobha',
                                   Email='TestContact02@gmail.co');
        
        insert cons;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'];
        User testUser = new User(
            contactId = cons.Id,
            FirstName = 'TestReq',
            LastName = 'Users',
            Email = 'testusers@example.com',
            UserName = 'testusers@example.com',
            ProfileId = testProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        System.runAs(testUser){              
            List<RTR_Reva_Transport_Request__c> resultReq = routeMasterController.searchRevaRequest();            
            System.assertNotEquals(null, resultReq, 'Result should not be null');            
        }
    }
    
    
    @isTest
    static void testgetFacultyDetails(){
        // Test data setup (create a test user)
        Id ProfessorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        Contact cons = new Contact(FirstName= 'test Faculty',
                                   LastName='Details',
                                   Application_Number__c = '1223467',
                                   Select_Category__c ='Karnataka',
                                   recordTypeId=ProfessorRecordTypeId,
                                   Mother_Name__c='sobha',
                                   Email='testuserss@example.com');
        
        insert cons;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor'];
        User testUser = new User(
            //contactId = cons.Id,
            FirstName = 'TestFaculty',
            LastName = 'professor',
            Email = 'testuserss@example.com',
            UserName = 'testuserss@example.com',
            ProfileId = testProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        System.runAs(testUser){  
            
            contact conResult = routeMasterController.getFacultyDetails();
            
            System.assertNotEquals(null, conResult, 'Records should be found');
            System.assertEquals('test Faculty', conResult.FirstName, 'Results are not equal');            
        }
    }
    
    //Transport Registration
    @isTest
    static void testtransportRegistration(){
        Id StudentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId(); 
        Contact cons = new Contact(FirstName= 'test',
                                   LastName='Dhawal',
                                   Application_Number__c = 'REV3478',
                                   Select_Category__c ='Karnataka',
                                   recordTypeId= StudentRecordTypeId,
                                   Mother_Name__c='sobha',
                                   Email='testusers123@example.com');
        
        insert cons;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'];
        User testUser = new User(
            contactId = cons.Id,
            FirstName = 'test',
            LastName = 'Dhawal',
            Email = 'testusers123@example.com',
            UserName = 'testusers123@example.com',
            ProfileId = testProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;  
        
        //Student
        System.runAs(testUser){  
            testDataFactory.createTransport();
            RTR_Route_Master__c routemasterIds = testDataFactory.createRouteMaster();
            RTR_Route_Pick_Up_Point__c pickuppointIds = testDataFactory.createPickUpPoint();
            Reva_Transport__c revaTransportId = testDataFactory.createRevaTransport();
            Decimal montlyDeduction = 1000;
            Decimal concessionAmount = 2000;
            Decimal withoutConcessionAmount = null;
            Date selectedDate = System.Today();
            Boolean shortDistance = true;
            
            // student with concession
            routeMasterController.transportRegistration(routemasterIds.Id,
                                                        revaTransportId.Id,pickuppointIds.Id,'45000','RevaTransport2024',selectedDate, 
                                                        montlyDeduction,shortDistance, concessionAmount, '45000');
            //student without concession
            routeMasterController.transportRegistration(routemasterIds.Id,
                                                        revaTransportId.Id,pickuppointIds.Id,'45000','RevaTransport2024',selectedDate, 
                                                        montlyDeduction,shortDistance, withoutConcessionAmount, '45000');
              Test.setMock(HttpCalloutMock.class, new SMSAPIMock());
            
        } 
        
          //Applicant
        Contact ApplicantContact = testDataFactory.createApplicantCon();
        Profile testingProfile = [SELECT Id FROM Profile WHERE Name ='Applicant Profile'];
        User ApplicantUser = new User(
            contactId = ApplicantContact.Id,
            FirstName = 'test',
            LastName = 'DhawnTRS01',
            Email = 'testusers4312@example.com',
            UserName = 'testuserss123@example.com',
            ProfileId = testingProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        insert ApplicantUser;
  
        System.runAs(ApplicantUser){  
            testDataFactory.createTransport();
            RTR_Route_Master__c routemasterIds = testDataFactory.createRouteMaster();
            RTR_Route_Pick_Up_Point__c pickuppointIds = testDataFactory.createPickUpPoint();
            Reva_Transport__c revaTransportId = testDataFactory.createRevaTransport();
            Decimal montlyDeduction = 1000;
            Decimal concessionAmount = 2000;
            Decimal withoutConcessionAmount = null;
            Date selectedDate = System.Today();
                       
            //Applicant
            routeMasterController.transportRegistration(routemasterIds.Id,
                                                        revaTransportId.Id,pickuppointIds.Id,'45000','RevaTransport2024',selectedDate, 
                                                        montlyDeduction,true, withoutConcessionAmount, '45000');               
        }
        routeMasterController.testCoverage();
        
        //Professor
      /* Contact professorContact = testDataFactory.createProfessorCon();        
        Profile testProf = [SELECT Id FROM Profile WHERE Name = 'Professor'];
        User professorUser = new User(
            FirstName = 'test',
            LastName = 'Dhawan',
            Email = 'testusers1234@example.com',
            UserName = 'testuserss45@example.com',
            ProfileId = testProf.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert professorUser;
        
        System.runAs(professorUser){  
            testDataFactory.createTransport();
            RTR_Route_Master__c routemasterIds = testDataFactory.createRouteMaster();
            RTR_Route_Pick_Up_Point__c pickuppointIds = testDataFactory.createPickUpPoint();
            Reva_Transport__c revaTransportId = testDataFactory.createRevaTransport();
            Decimal montlyDeduction = 1000;
            Decimal concessionAmount = 2000;
            Decimal withoutConcessionAmount = null;
            Date selectedDate = System.Today();
                       
            //Professor without shortDistance
            routeMasterController.transportRegistration(routemasterIds.Id,
                                                        revaTransportId.Id,pickuppointIds.Id,'45000','RevaTransport2024',selectedDate, 
                                                        montlyDeduction,true, concessionAmount, '45000');  
            //Professor with shortDistance
            routeMasterController.transportRegistration(routemasterIds.Id,
                                                        revaTransportId.Id,pickuppointIds.Id,'45000','RevaTransport2024',selectedDate, 
                                                        montlyDeduction,false, concessionAmount, '45000');  
        }
         */
      
       
        //Non Teaching
      /*  Contact nonTeachingContact = testDataFactory.createNonTeachingCon();        
        Profile profileIds = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile'];
        User NonTeachingUser = new User(
            contactId = nonTeachingContact.Id,
            FirstName = 'test',
            LastName = 'DhawnTR01',
            Email = 'testusers431@example.com',
            UserName = 'testusers431@example.com',
            ProfileId = profileIds.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert NonTeachingUser;
        
        System.runAs(NonTeachingUser){  
            testDataFactory.createTransport();
            RTR_Route_Master__c routemasterIds = testDataFactory.createRouteMaster();
            RTR_Route_Pick_Up_Point__c pickuppointIds = testDataFactory.createPickUpPoint();
            Reva_Transport__c revaTransportId = testDataFactory.createRevaTransport();
            Decimal montlyDeduction = 1000;
            Decimal concessionAmount = 2000;
            Decimal withoutConcessionAmount = null;
            Date selectedDate = System.Today();
                       
            //NonTeaching without shortDistance
            routeMasterController.transportRegistration(routemasterIds.Id,
                                                        revaTransportId.Id,pickuppointIds.Id,'45000','RevaTransport2024',selectedDate, 
                                                        montlyDeduction,true, concessionAmount, '45000');  
            //NonTeaching with shortDistance
            routeMasterController.transportRegistration(routemasterIds.Id,
                                                        revaTransportId.Id,pickuppointIds.Id,'45000','RevaTransport2024',selectedDate, 
                                                        montlyDeduction,false, concessionAmount, '45000');  
        }*/
                
    }
}