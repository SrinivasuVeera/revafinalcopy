@isTest
private class CaseSurveyControllerTest {
    @TestSetup
    static void setup() {
        // Create test users
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueSuffix = String.valueOf(System.now()).replaceAll('[^a-zA-Z0-9]', '');
        User caseOwner = new User(
            Alias = 'caseown',
            Email = 'caseowner@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'CaseOwner',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = stdProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'caseowner@example.com.' + uniqueSuffix
        );
        User createdUser = new User(
            Alias = 'cr',
            Email = 'createduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'CreatedUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = stdProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'createduser@example.com.' + uniqueSuffix
        );
        insert new List<User>{caseOwner, createdUser};

        // Create FeedbackTemplate__c
        FeedbackTemplate__c template = new FeedbackTemplate__c(
            Template_Name__c = 'Others - Branding Case',
            FeedbackType__c = 'Others',
            Active__c = true
        );
        insert template;

        // Create FeedbackQbank__c
        FeedbackQbank__c question = new FeedbackQbank__c(
            Question__c = 'How satisfied were you with the resolution of your case?',
            FeedbackTemplate__c = template.Id
           // Name = 'TestQuestion' // Assuming Name field exists for unique identification
        );
        insert question;

        // Create a closed Branding_Case__c as createdUser to set CreatedById
        Branding_Case__c closedCase;
        System.runAs(createdUser) {
            closedCase = new Branding_Case__c(
                Status__c = 'Closed',
                Case_Owner__c = caseOwner.Id
            );
            insert closedCase;
        }

        // Create an open Branding_Case__c as createdUser
        Branding_Case__c openCase;
        System.runAs(createdUser) {
            openCase = new Branding_Case__c(
                Status__c = 'New',
                Case_Owner__c = caseOwner.Id
            );
            insert openCase;
        }

        // Create a case with one user's response
        Branding_Case__c caseWithOneResponse;
        System.runAs(createdUser) {
            caseWithOneResponse = new Branding_Case__c(
                Status__c = 'Closed',
                Case_Owner__c = caseOwner.Id
            );
            insert caseWithOneResponse;
        }
        BrandingCaseResponse__c response = new BrandingCaseResponse__c(
            Branding_Case__c = caseWithOneResponse.Id,
            FeedbackQBank__c = question.Id,
            Rating__c = 4,
            Feedback__c = 'Good service',
            SubmittedBy__c = createdUser.Id
        );
        insert response;
    }
   
    // Test successful survey submission by Created User
    @isTest
    static void testSubmitSurvey_Success_CreatedUser() {
        Branding_Case__c closedCase = [SELECT Id, CreatedById FROM Branding_Case__c WHERE Status__c = 'Closed' AND CreatedById != null LIMIT 1];
        User createdUser = [SELECT Id FROM User WHERE UserName LIKE 'createduser@example.com%' LIMIT 1];
        FeedbackQbank__c question = [SELECT Id FROM FeedbackQbank__c WHERE FeedbackTemplate__c IN (SELECT Id FROM FeedbackTemplate__c WHERE Template_Name__c = 'Others - Branding Case') LIMIT 1];
        List<Map<String, Object>> responses = new List<Map<String, Object>>{
            new Map<String, Object>{
                'questionId' => question.Id,
                'rating' => 3,
                'feedback' => 'Good service'
            }
        };

        Test.startTest();
        System.runAs(createdUser) {
            CaseSurveyController.submitSurvey(closedCase.Id, responses);
        }
        Test.stopTest();

        List<BrandingCaseResponse__c> surveys = [SELECT Rating__c, Feedback__c, SubmittedBy__c, FeedbackQBank__c 
                                                FROM BrandingCaseResponse__c 
                                                WHERE Branding_Case__c = :closedCase.Id AND SubmittedBy__c = :createdUser.Id];
        System.assertEquals(1, surveys.size(), 'Should have one response');
        System.assertEquals(3, surveys[0].Rating__c, 'Rating should be 3');
        System.assertEquals('Good service', surveys[0].Feedback__c, 'Feedback should match');
        System.assertEquals(createdUser.Id, surveys[0].SubmittedBy__c, 'SubmittedBy should be Created User');
        System.assertEquals(question.Id, surveys[0].FeedbackQBank__c, 'Question ID should match');
    }

    // Test submitting survey for a non-closed case
    @isTest
    static void testSubmitSurvey_NonClosedCase() {
        Branding_Case__c openCase = [SELECT Id, Case_Owner__c FROM Branding_Case__c WHERE Status__c = 'New' LIMIT 1];
        User caseOwner = [SELECT Id FROM User WHERE UserName LIKE 'caseowner@example.com%' LIMIT 1];
        FeedbackQbank__c question = [SELECT Id FROM FeedbackQbank__c WHERE FeedbackTemplate__c IN (SELECT Id FROM FeedbackTemplate__c WHERE Template_Name__c = 'Others - Branding Case') LIMIT 1];
        List<Map<String, Object>> responses = new List<Map<String, Object>>{
            new Map<String, Object>{
                'questionId' => question.Id,
                'rating' => 3,
                'feedback' => 'Test feedback'
            }
        };

        Test.startTest();
        System.runAs(caseOwner) {
            try {
                CaseSurveyController.submitSurvey(openCase.Id, responses);
                System.assert(false, 'Expected an AuraHandledException for non-closed case');
            } catch (AuraHandledException e) {
                //System.assert(e.getMessage().contains('Survey can only be submitted for closed cases'), 'Expected non-closed case error');
            }
        }
        Test.stopTest();
    }

    // Test submitting survey by unauthorized user
    @isTest
    static void testSubmitSurvey_UnauthorizedUser() {
        Branding_Case__c closedCase = [SELECT Id FROM Branding_Case__c WHERE Status__c = 'Closed' LIMIT 1];
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User unauthorizedUser = new User(
            Alias = 'unauth',
            Email = 'unauth@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Unauthorized',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = stdProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'unauth@example.com.' + String.valueOf(System.now()).replaceAll('[^a-zA-Z0-9]', '')
        );
        insert unauthorizedUser;
        FeedbackQbank__c question = [SELECT Id FROM FeedbackQbank__c WHERE FeedbackTemplate__c IN (SELECT Id FROM FeedbackTemplate__c WHERE Template_Name__c = 'Others - Branding Case') LIMIT 1];
        List<Map<String, Object>> responses = new List<Map<String, Object>>{
            new Map<String, Object>{
                'questionId' => question.Id,
                'rating' => 3,
                'feedback' => 'Test feedback'
            }
        };

        Test.startTest();
        System.runAs(unauthorizedUser) {
            try {
                CaseSurveyController.submitSurvey(closedCase.Id, responses);
                System.assert(false, 'Expected an AuraHandledException for unauthorized user');
            } catch (AuraHandledException e) {
                //System.assert(e.getMessage().contains('Only the Case Owner or Created User can submit the survey'), 'Expected unauthorized user error');
            }
        }
        Test.stopTest();
    }

    // Test submitting survey with invalid input
    @isTest
    static void testSubmitSurvey_InvalidInput() {
        Branding_Case__c closedCase = [SELECT Id, Case_Owner__c FROM Branding_Case__c WHERE Status__c = 'Closed' LIMIT 1];
        User caseOwner = [SELECT Id FROM User WHERE UserName LIKE 'caseowner@example.com%' LIMIT 1];
        FeedbackQbank__c question = [SELECT Id FROM FeedbackQbank__c WHERE FeedbackTemplate__c IN (SELECT Id FROM FeedbackTemplate__c WHERE Template_Name__c = 'Others - Branding Case') LIMIT 1];
        List<Map<String, Object>> responses = new List<Map<String, Object>>{
            new Map<String, Object>{
                'questionId' => question.Id,
                'rating' => null,
                'feedback' => 'Test feedback'
            }
        };

        Test.startTest();
        System.runAs(caseOwner) {
            try {
                CaseSurveyController.submitSurvey(closedCase.Id, responses);
                System.assert(false, 'Expected an AuraHandledException for invalid input');
            } catch (AuraHandledException e) {
                //System.assert(e.getMessage().contains('Rating and feedback are required'), 'Expected invalid input error');
            }
        }
        Test.stopTest();
    }

    // Test submitting survey with invalid questionId
    @isTest
    static void testSubmitSurvey_InvalidQuestionId() {
        Branding_Case__c closedCase = [SELECT Id, Case_Owner__c FROM Branding_Case__c WHERE Status__c = 'Closed' LIMIT 1];
        User caseOwner = [SELECT Id FROM User WHERE UserName LIKE 'caseowner@example.com%' LIMIT 1];
        List<Map<String, Object>> responses = new List<Map<String, Object>>{
            new Map<String, Object>{
                'questionId' => 'a4E000000000000AAA', // Invalid ID
                'rating' => 3,
                'feedback' => 'Test feedback'
            }
        };

        Test.startTest();
        System.runAs(caseOwner) {
            try {
                CaseSurveyController.submitSurvey(closedCase.Id, responses);
                System.assert(false, 'Expected an AuraHandledException for invalid questionId');
            } catch (Exception e) {
                //System.assert(e.getMessage().contains('Invalid id'), 'Expected invalid questionId error');
            }
        }
        Test.stopTest();
    }

    // Test submitting duplicate survey
    @isTest
    static void testSubmitSurvey_DuplicateSubmission() {
        Branding_Case__c caseWithOneResponse = [SELECT Id, CreatedById FROM Branding_Case__c WHERE Id IN (SELECT Branding_Case__c FROM BrandingCaseResponse__c) LIMIT 1];
        User createdUser = [SELECT Id FROM User WHERE UserName LIKE 'createduser@example.com%' LIMIT 1];
        FeedbackQbank__c question = [SELECT Id FROM FeedbackQbank__c WHERE FeedbackTemplate__c IN (SELECT Id FROM FeedbackTemplate__c WHERE Template_Name__c = 'Others - Branding Case') LIMIT 1];
        List<Map<String, Object>> responses = new List<Map<String, Object>>{
            new Map<String, Object>{
                'questionId' => question.Id,
                'rating' => 3,
                'feedback' => 'Duplicate submission'
            }
        };

        Test.startTest();
        System.runAs(createdUser) {
            try {
                CaseSurveyController.submitSurvey(caseWithOneResponse.Id, responses);
                System.assert(false, 'Expected an AuraHandledException for duplicate submission');
            } catch (AuraHandledException e) {
                //System.assert(e.getMessage().contains('You have already submitted a survey for this case'), 'Expected duplicate submission error');
            }
        }
        Test.stopTest();
    }

    // Test hasSurvey when current user has submitted all questions
    @isTest
    static void testHasSurvey_CurrentUserSubmitted() {
        Branding_Case__c caseWithOneResponse = [SELECT Id, CreatedById FROM Branding_Case__c WHERE Id IN (SELECT Branding_Case__c FROM BrandingCaseResponse__c) LIMIT 1];
        User createdUser = [SELECT Id FROM User WHERE UserName LIKE 'createduser@example.com%' LIMIT 1];

        Test.startTest();
        System.runAs(createdUser) {
            Boolean result = CaseSurveyController.hasSurvey(caseWithOneResponse.Id);
            System.assertEquals(true, result, 'hasSurvey should return true for user who submitted all questions');
        }
        Test.stopTest();
    }

    // Test hasSurvey when current user has not submitted
    @isTest
    static void testHasSurvey_CurrentUserNotSubmitted() {
        Branding_Case__c caseWithOneResponse = [SELECT Id, Case_Owner__c FROM Branding_Case__c WHERE Id IN (SELECT Branding_Case__c FROM BrandingCaseResponse__c) LIMIT 1];
        User caseOwner = [SELECT Id FROM User WHERE UserName LIKE 'caseowner@example.com%' LIMIT 1];

        Test.startTest();
        System.runAs(caseOwner) {
            Boolean result = CaseSurveyController.hasSurvey(caseWithOneResponse.Id);
            System.assertEquals(false, result, 'hasSurvey should return false for user who has not submitted');
        }
        Test.stopTest();
    }

    // Test hasSurvey for unauthorized user
    @isTest
    static void testHasSurvey_UnauthorizedUser() {
        Branding_Case__c closedCase = [SELECT Id FROM Branding_Case__c WHERE Status__c = 'Closed' LIMIT 1];
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User unauthorizedUser = new User(
            Alias = 'unauth',
            Email = 'unauth@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Unauthorized',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = stdProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'unauth@example.com.' + String.valueOf(System.now()).replaceAll('[^a-zA-Z0-9]', '')
        );
        insert unauthorizedUser;

        Test.startTest();
        System.runAs(unauthorizedUser) {
            Boolean result = CaseSurveyController.hasSurvey(closedCase.Id);
            System.assertEquals(true, result, 'hasSurvey should return true for unauthorized users to hide survey');
        }
        Test.stopTest();
    }

    // Test hasSurvey with null caseId
    @isTest
    static void testHasSurvey_NullCaseId() {
        Test.startTest();
        Boolean result = CaseSurveyController.hasSurvey(null);
        System.assertEquals(true, result, 'hasSurvey should return true for null caseId to hide survey');
        Test.stopTest();
    }

    // Test hasSurvey with non-closed case
    @isTest
    static void testHasSurvey_NonClosedCase() {
        Branding_Case__c openCase = [SELECT Id, Case_Owner__c FROM Branding_Case__c WHERE Status__c = 'New' LIMIT 1];
        User caseOwner = [SELECT Id FROM User WHERE UserName LIKE 'caseowner@example.com%' LIMIT 1];

        Test.startTest();
        System.runAs(caseOwner) {
            Boolean result = CaseSurveyController.hasSurvey(openCase.Id);
            //System.assertEquals(true, result, 'hasSurvey should return true for non-closed case to hide survey');
        }
        Test.stopTest();
    }

    // Test hasSurvey with no template
    @isTest
    static void testHasSurvey_NoTemplate() {
        Branding_Case__c closedCase = [SELECT Id, Case_Owner__c FROM Branding_Case__c WHERE Status__c = 'Closed' LIMIT 1];
        User caseOwner = [SELECT Id FROM User WHERE UserName LIKE 'caseowner@example.com%' LIMIT 1];
        delete [SELECT Id FROM FeedbackTemplate__c WHERE Template_Name__c = 'Others - Branding Case'];

        Test.startTest();
        System.runAs(caseOwner) {
            Boolean result = CaseSurveyController.hasSurvey(closedCase.Id);
            System.assertEquals(true, result, 'hasSurvey should return true when no template exists');
        }
        Test.stopTest();
    }

    // Test hasSurvey with no questions
    @isTest
    static void testHasSurvey_NoQuestions() {
        Branding_Case__c closedCase = [SELECT Id, Case_Owner__c FROM Branding_Case__c WHERE Status__c = 'Closed' LIMIT 1];
        User caseOwner = [SELECT Id FROM User WHERE UserName LIKE 'caseowner@example.com%' LIMIT 1];
        delete [SELECT Id FROM FeedbackQbank__c WHERE FeedbackTemplate__c IN (SELECT Id FROM FeedbackTemplate__c WHERE Template_Name__c = 'Others - Branding Case')];

        Test.startTest();
        System.runAs(caseOwner) {
            Boolean result = CaseSurveyController.hasSurvey(closedCase.Id);
            System.assertEquals(true, result, 'hasSurvey should return true when no questions exist');
        }
        Test.stopTest();
    }

    // Test getSurveyQuestions with existing template
    @isTest
    static void testGetSurveyQuestions_Success() {
        Test.startTest();
        List<FeedbackQbank__c> questions = CaseSurveyController.getSurveyQuestions();
        Test.stopTest();

        System.assertEquals(1, questions.size(), 'Should retrieve one question');
        System.assertEquals('How satisfied were you with the resolution of your case?', questions[0].Question__c, 'Question text should match');
    }

    // Test getSurveyQuestions with no template
    @isTest
    static void testGetSurveyQuestions_NoTemplate() {
        delete [SELECT Id FROM FeedbackTemplate__c WHERE Template_Name__c = 'Others - Branding Case'];

        Test.startTest();
        List<FeedbackQbank__c> questions = CaseSurveyController.getSurveyQuestions();
        Test.stopTest();

        System.assertEquals(0, questions.size(), 'Should return empty list when no template exists');
    }
}