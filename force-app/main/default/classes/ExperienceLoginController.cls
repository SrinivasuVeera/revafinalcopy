public with sharing class ExperienceLoginController {
    
    @AuraEnabled
    public static String login(String username, String password) {
        
        if(String.isBlank(username) || String.isBlank(password)){
            throw new AuraHandledException('Missing credentials.');
        }
        
        // Basic input sanitation
        username = username.trim();
        
        String startUrl = '/s/';
        PageReference result = Site.login(username, password, startUrl);
        
        if(result == null){
            throw new AuraHandledException('Invalid username or password.');
        }
        
        return result.getUrl();
    }
}