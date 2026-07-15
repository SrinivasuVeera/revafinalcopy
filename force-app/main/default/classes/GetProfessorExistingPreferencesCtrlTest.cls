@isTest
public class GetProfessorExistingPreferencesCtrlTest {
    @testSetup
    static void setup() {
        string universityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objParentAccount = new Account();
        objParentAccount.Name='Test Parent Account';
        objParentAccount.RecordTypeId=universityRecId;
        insert objParentAccount; 
        
        Account objAccount = new Account();
        objAccount.Name='Test Account';
        objAccount.RecordTypeId=universityRecId;
        objAccount.ParentId=objParentAccount.Id;
        insert objAccount;                
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Contact';
        objContact.Professor_Across_Schools__c = True;
        objContact.AccountId = objParentAccount.Id;
        objContact.Email='professoruser@email.com';
        insert objContact;
        
        hed__Term__c objTerm = new hed__Term__c();
        objTerm.Name='Test Term';
        objTerm.Allow_Professors_for_Preferences__c = True;
        objTerm.hed__Account__c=objAccount.Id;
        insert objTerm;
        
        hed__Course__c objCourse = new hed__Course__c();
        objCourse.Name ='Test Course';
        objCourse.Credits__c = 3;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        objCourse.SEE_Conducted_Marks__c = 20;
        objCourse.Offered_By_School__c = objAccount.Id;
        objCourse.Credit_Hours__c = 20;
        objCourse.Maximum_External_Marks__c = 100;
        objCourse.Total_Maximum_Marks_IA_External__c = 50;
        objCourse.hed__Account__c=objAccount.Id;
        insert objCourse;
                
        hed__Course_Offering__c objCourseOffering = new hed__Course_Offering__c();
        objCourseOffering.Name='Test Course Offering';
        objCourseOffering.hed__Term__c = objTerm.Id;
        objCourseOffering.hed__Course__c=objCourse.Id;
        insert objCourseOffering;
        
        List<hed__Course_Offering__c> listCourseOfferings = new List<hed__Course_Offering__c>();
        
        for(Integer i=0;i<=20;i++){
            hed__Course_Offering__c objCourseOffering1 = new hed__Course_Offering__c();
            objCourseOffering1.Name='Test Course Offering '+String.valueof(i);
            objCourseOffering1.hed__Term__c = objTerm.Id;
            objCourseOffering1.hed__Course__c=objCourse.Id;
            objCourseOffering1.Offered_By_School__c = objParentAccount.Id;
            listCourseOfferings.add(objCourseOffering1);
        }
        insert listCourseOfferings;
        
        Professor_Student_Course_Preference__c objProfessorStudent = new Professor_Student_Course_Preference__c();
        objProfessorStudent.Name = 'Test ProfStudentName';
        objProfessorStudent.Course_Offering__c=objCourseOffering.Id;
        objProfessorStudent.Semester__c=objTerm.Id;            
        objProfessorStudent.Preference__c = '1';        
        objProfessorStudent.Professor__c=objContact.Id;
        objProfessorStudent.Course_Offering__c = objCourseOffering.Id;
        insert objProfessorStudent;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        
        User testUser = new User(
            Username = 'professoruser@test.com',
            Email = 'professoruser@email.com',
            Alias = 'tuser',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test',
            LastName = 'User'
        );
        insert testUser;
               
    }
    
    @isTest
    static void testGetExistingPrefCollection(){
        User testUser = [SELECT Id FROM User WHERE Username = 'professoruser@test.com' LIMIT 1];
        
        Contact objContact = [SELECT Id, Professor_Across_Schools__c FROM Contact];
        
        hed__Course_Offering__c objCourseOffering = [SELECT Id From hed__Course_Offering__c WHERE Name = 'Test Course Offering'];
        
        hed__Term__c objTerm = [SELECT Id FROM hed__Term__c WHERE Name='Test Term'];
        
        Professor_Student_Course_Preference__c objProfessorStudent = new Professor_Student_Course_Preference__c();
        objProfessorStudent.Name = 'Test ProfStudentName';
        objProfessorStudent.Course_Offering__c=objCourseOffering.Id;
        objProfessorStudent.Semester__c=objTerm.Id;            
        objProfessorStudent.Preference__c = '1';        
        objProfessorStudent.Professor__c=objContact.Id;
        objProfessorStudent.Course_Offering__c = objCourseOffering.Id;
        insert objProfessorStudent;
        
        System.runAs(testUser) {            
            GetProfessorExistingPreferencesCtrl.PreferenceWrapper result = GetProfessorExistingPreferencesCtrl.getExistingPrefCollection();
            
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');
            System.assertEquals(True, result.isAllowFreezing, 'Expected isAllowFreezing to be False');
            System.assertEquals('Allow', result.requiredOptions, 'Expected requiredOptions to be 10');                    
        }        
    }
    
    @isTest
    static void testGetExistingPrefCollectionNonProfessor(){
        User testUser = [SELECT Id FROM User WHERE Username = 'professoruser@test.com' LIMIT 1];
        
        Contact objContact = [SELECT Id, Professor_Across_Schools__c FROM Contact];
        objContact.Professor_Across_Schools__c=False;
        update objContact;
               
        
        System.runAs(testUser) {            
            GetProfessorExistingPreferencesCtrl.PreferenceWrapper result = GetProfessorExistingPreferencesCtrl.getExistingPrefCollection();
            
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');            
            System.assertEquals(True, result.isAllowFreezing, 'Expected isAllowFreezing to be False');
            System.assertEquals('Allow', result.requiredOptions, 'Expected requiredOptions to be 9');    
        }        
    }
    
      @isTest
    static void testGetExistingPrefCollectionThreeProfessors(){
        User testUser = [SELECT Id FROM User WHERE Username = 'professoruser@test.com' LIMIT 1];
        
        Contact objContact = [SELECT Id, Professor_Across_Schools__c FROM Contact];
        
        hed__Course_Offering__c objCourseOffering = [SELECT Id From hed__Course_Offering__c WHERE Name = 'Test Course Offering'];
        
        hed__Term__c objTerm = [SELECT Id FROM hed__Term__c WHERE Name='Test Term'];
        
        Professor_Student_Course_Preference__c objProfessorStudent = new Professor_Student_Course_Preference__c();
        objProfessorStudent.Name = 'Test ProfStudentName';
        objProfessorStudent.Course_Offering__c=objCourseOffering.Id;
        objProfessorStudent.Semester__c=objTerm.Id;            
        objProfessorStudent.Preference__c = '1';        
        objProfessorStudent.Professor__c=objContact.Id;
        objProfessorStudent.Course_Offering__c = objCourseOffering.Id;
        insert objProfessorStudent;
        
         Professor_Student_Course_Preference__c objProfessorStudent1 = new Professor_Student_Course_Preference__c();
        objProfessorStudent1.Name = 'Test ProfStudentName 1';
        objProfessorStudent1.Course_Offering__c=objCourseOffering.Id;
        objProfessorStudent1.Semester__c=objTerm.Id;            
        objProfessorStudent1.Preference__c = '1';        
        objProfessorStudent1.Professor__c=objContact.Id;
        objProfessorStudent1.Course_Offering__c = objCourseOffering.Id;
        insert objProfessorStudent1;
        
        System.runAs(testUser) {            
            GetProfessorExistingPreferencesCtrl.PreferenceWrapper result = GetProfessorExistingPreferencesCtrl.getExistingPrefCollection();
            
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');
            System.assertEquals(True,result.isAllowFreezing, 'Expected isAllowFreezing to be False');
            System.assertEquals('Allow',result.requiredOptions, 'Expected requiredOptions to be 8');    
        }        
    }
    
    @isTest
    static void testFreezeProPreference(){
        User testUser = [SELECT Id FROM User WHERE Username = 'professoruser@test.com' LIMIT 1];
        List<Professor_Student_Course_Preference__c> savedProPreference = [SELECT Id,Name,Course_Offering__c,Preference__c,Semester__c,Preference_No__c ,Professor__c FROM Professor_Student_Course_Preference__c];
        System.runAs(testUser) {            
            String result = GetProfessorExistingPreferencesCtrl.freezeProPreference(savedProPreference);
            
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');            
            System.assertEquals('Professor Preferences frozen successfully.', result, 'Expected success message to be returned');
        }  
    }
    
    @isTest
    static void testFreezeProPreferenceNullPreferences(){
        User testUser = [SELECT Id FROM User WHERE Username = 'professoruser@test.com' LIMIT 1];
        
        System.runAs(testUser) {            
            String result = GetProfessorExistingPreferencesCtrl.freezeProPreference(null);
            
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');            
            System.assertEquals('No preferences were provided to freeze.', result, 'Expected success message to be returned');
        }  
    }
    
    @isTest
    static void testFreezeProPreferenceEmptyPreferences(){
        User testUser = [SELECT Id FROM User WHERE Username = 'professoruser@test.com' LIMIT 1];
        List<Professor_Student_Course_Preference__c> savedProPreference = [SELECT Id,Name,Course_Offering__c,Preference__c,Semester__c,Preference_No__c ,Professor__c,Professor_Preference__c FROM Professor_Student_Course_Preference__c];
        for(Professor_Student_Course_Preference__c pre: savedProPreference){
                pre.Professor_Preference__c = true;
            }
            update savedProPreference;
        System.runAs(testUser) {            
            String result = GetProfessorExistingPreferencesCtrl.freezeProPreference(savedProPreference);                                      
    
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');
            System.assertEquals('No eligible preferences found to freeze/Already freezed.', result,' Expected no eligible preferences message to be returned');            
        }  
    }
    
     @isTest
    static void testGetExistingPrefCollectionOneCO(){
        User testUser = [SELECT Id FROM User WHERE Username = 'professoruser@test.com' LIMIT 1];        
        
         List<hed__Course_Offering__c> objCourseOffering = [Select Id,Offered_By_School__c From hed__Course_Offering__c Where Offered_By_School__c!=null];
        delete objCourseOffering;
       
        System.runAs(testUser) {            
            GetProfessorExistingPreferencesCtrl.PreferenceWrapper result = GetProfessorExistingPreferencesCtrl.getExistingPrefCollection();
    
            System.assertNotEquals(null, result, 'Expected a valid data to be returned');            
            System.assertEquals(True, result.isAllowFreezing, 'Expected isAllowFreezing to be True');
            System.assertEquals('Allow', result.requiredOptions, 'Expected requiredOptions to be Allow');
        }  
    } 
@isTest
static void testUpdatePreferences() {

    Professor_Student_Course_Preference__c pref =
        [SELECT Id, Preference__c
         FROM Professor_Student_Course_Preference__c
         LIMIT 1];

    pref.Preference__c = '2';

    Test.startTest();
    GetProfessorExistingPreferencesCtrl.updatePreferences(
        new List<Professor_Student_Course_Preference__c>{ pref }
    );
    Test.stopTest();

    Professor_Student_Course_Preference__c updatedPref =
        [SELECT Id, Preference__c
         FROM Professor_Student_Course_Preference__c
         WHERE Id = :pref.Id];

    System.assertEquals(
        '2',
        updatedPref.Preference__c
    );
}
@isTest
static void testUpdatePreferencesEmptyList() {

    Test.startTest();

    GetProfessorExistingPreferencesCtrl.updatePreferences(
        new List<Professor_Student_Course_Preference__c>()
    );

    Test.stopTest();

    System.assert(true);
}
@isTest
static void testGetExistingPrefCollection_NoProfessorContact() {

    Profile p = [
        SELECT Id
        FROM Profile
        WHERE Name = 'Professor'
        LIMIT 1
    ];

    User noContactUser = new User(
        Username = 'noprofessor@test.com',
        Email = 'noprofessor@test.com',
        Alias = 'npusr',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        FirstName = 'No',
        LastName = 'Professor'
    );

    insert noContactUser;

    System.runAs(noContactUser) {

        Test.startTest();

        GetProfessorExistingPreferencesCtrl.PreferenceWrapper result =
            GetProfessorExistingPreferencesCtrl.getExistingPrefCollection();

        Test.stopTest();

        System.assertEquals(false, result.isAllowFreezing);
        System.assertEquals(0, result.preferences.size());
    }
}    
    
}