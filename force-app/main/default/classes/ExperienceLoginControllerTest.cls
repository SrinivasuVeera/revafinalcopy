@isTest
private class ExperienceLoginControllerTest {
    
    @isTest
    static void testLoginWithBlankUsername() {
        try {
            ExperienceLoginController.login('', 'password123');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testLoginWithBlankPassword() {
        try {
            ExperienceLoginController.login('testuser@example.com', '');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testLoginWithNullUsername() {
        try {
            ExperienceLoginController.login(null, 'password123');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testLoginWithNullPassword() {
        try {
            ExperienceLoginController.login('testuser@example.com', null);
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testLoginWithBothBlank() {
        try {
            ExperienceLoginController.login('', '');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testLoginWithInvalidCredentials() {
        // Site.login() returns null in test context with invalid credentials
        // This tests the null result branch → throws 'Invalid username or password.'
        try {
            ExperienceLoginController.login('invaliduser@example.com', 'wrongpassword');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testLoginWithWhitespaceUsername() {
        // Username with only whitespace should be treated as blank after trim check
        try {
            ExperienceLoginController.login('   ', 'password123');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testLoginWithWhitespaceAroundUsername() {
        // Valid-looking username with leading/trailing spaces — Site.login returns null in test context
        try {
            ExperienceLoginController.login('  testuser@example.com  ', 'wrongpassword');
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}