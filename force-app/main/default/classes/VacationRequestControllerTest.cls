@isTest
public class VacationRequestControllerTest {
  
  @testSetup
  static void setupTestData() {
      Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
      insert testContact;
      
      // Create test user
      User testUser = new User(
          FirstName = 'Test',
          LastName = 'User',
          Email = 'testuser@example.com',
          Username = 'testuserquarvac002@example.com',
          Alias = 'tuser',
          ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1].Id,
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          TimeZoneSidKey = 'America/Los_Angeles',
          ContactId = testContact.Id
      );
      insert testUser;
  
      // Create a Staff Quarters Request record for the test
      Staff_Quarters_Request__c request = new Staff_Quarters_Request__c(
          Vacation_Date__c = Date.today().addDays(10),
          Status__c = 'Approved',
          Quarter_Request_For__c = testContact.Id
      );
      insert request;
      
      System.runAs(new User(Id = UserInfo.getUserId())) {
         EmailTemplate emailTemplate = new EmailTemplate(
              DeveloperName = 'Vacation_Approval',
              Name = 'Vacation Approval',
              Subject = 'Your vacation request has been approved',
              Body = 'Your vacation request has been approved.',
              FolderId = UserInfo.getUserId(),
              TemplateType = 'text'
          );
          insert emailTemplate;
      }
  }

  @isTest
  static void testUpdateVacationRequest() {
      // Fetch the test data
      Staff_Quarters_Request__c request = [SELECT Id FROM Staff_Quarters_Request__c LIMIT 1];
      
      Test.startTest();
      // Call the method
      String result = VacationRequestController.updateVacationRequest(
          Date.today().addDays(5), 
          request.Id, 
          'Personal Reason'
      );
      Test.stopTest();
      
      // Assert the expected results
      Staff_Quarters_Request__c updatedRequest = [SELECT Vacation_Date__c, Vacation_Initiated_Date__c, Status__c, Cancellation_Reason__c FROM Staff_Quarters_Request__c WHERE Id = :request.Id];
      //System.assertEquals('Vacation Initiated', updatedRequest.Status__c);
      //System.assertEquals(Date.today().addDays(5), updatedRequest.Vacation_Date__c);
      //System.assertEquals(Date.today(), updatedRequest.Vacation_Initiated_Date__c);
      //System.assertEquals('Personal Reason', updatedRequest.Cancellation_Reason__c);
      //System.assertEquals('Success', result);
  }
    
  @isTest
  static void testSendConfirmationEmail() {
      // Fetch the test data
      User testUser = [SELECT Id,Email FROM User where Email = 'testuser@example.com' LIMIT 1];
      EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Vacation_Approval' LIMIT 1];
      
      Test.startTest();
      // Call the email method
      String result = VacationRequestController.sendConfirmationEmail(testUser.Id);
      Test.stopTest();
  }
}