@isTest
private class ApplicantCallableUtils_Test {
  @TestSetup
    static void createTestData() {
        
      UserRole role = [SELECT Id FROM UserRole WHERE Name='Admin Role'];
      
      User user = new User();
      user.Username = 'testApplicantUser@example.com'; 
      user.Email = 'test@example.com';
      user.LastName = 'Test';
      user.Alias = 'test';
      user.TimeZoneSidKey = 'GMT';
      user.LocaleSidKey = 'en_US';
      user.EmailEncodingKey = 'UTF-8';
      user.ProfileId = [Select Id From Profile Where Name='Standard User'].id;
      user.LanguageLocaleKey = 'en_US';
      user.UserRoleId = role.id; 
      insert user;
    }
    
  @isTest
  static void testGetApplicantContactId() {
      User user = [select Id from User where Username = 'testApplicantUser@example.com'];
      system.runas(user){
          Map<String,Object> mapVals = New Map<String,Object>();
          Map<String,Object> output = New Map<String,Object>();
          mapVals.put('output',output);
          String action = 'getApplicantContactId';
          String applicantCallableUtilsClass = 'ApplicantCallableUtils'; 
          Callable extension = (Callable) Type.forName(applicantCallableUtilsClass).newInstance();
          Test.startTest();
          extension.call(action,mapVals);
          action = 'Test';
          extension.call(action,mapVals);
          Test.stopTest();
      }
  }
}