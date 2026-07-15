public with sharing class CaseSurveyController {
    @AuraEnabled
    public static void submitSurvey(Id caseId, List<Map<String, Object>> responses) {
        try {            
            if (caseId == null || responses == null || responses.isEmpty()) {
                throw new AuraHandledException('Invalid input parameters');
            }
            Id currentUserId = UserInfo.getUserId();
            
            Branding_Case__c caseRecord = [SELECT Status__c, Case_Owner__c, CreatedById 
                                           FROM Branding_Case__c WHERE Id = :caseId LIMIT 1];
            
            if (caseRecord.Status__c != 'Closed') {
                throw new AuraHandledException('Survey can only be submitted for closed cases');
            }
            
            Boolean isCaseOwner = caseRecord.Case_Owner__c == currentUserId;
            Id contactId = caseRecord.CreatedById;
            Boolean isCreatedUser = false;
            if (contactId != null) {
                List<User> relatedUsers = [SELECT Id FROM User WHERE Id = :contactId LIMIT 1];
                isCreatedUser = !relatedUsers.isEmpty() && relatedUsers[0].Id == currentUserId;
            }
            if (!isCaseOwner && !isCreatedUser) {
                throw new AuraHandledException('Only the Case Owner or Created User can submit the survey');
            }
            List<BrandingCaseResponse__c> existingSurveys = [SELECT Id 
                                                             FROM BrandingCaseResponse__c 
                                                             WHERE Branding_Case__c = :caseId 
                                                             AND SubmittedBy__c = :currentUserId 
                                                             LIMIT 1];
            if (!existingSurveys.isEmpty()) {
                throw new AuraHandledException('You have already submitted a survey for this case');
            }
            for (Map<String, Object> response : responses) {
                if (!response.containsKey('questionId') || !response.containsKey('rating') || !response.containsKey('feedback')) {
                    throw new AuraHandledException('Invalid response format');
                }
                Integer rating = Integer.valueOf(response.get('rating'));
                String feedback = String.valueOf(response.get('feedback'));
                if (rating == null || rating < 1 || rating > 5 || String.isBlank(feedback)) {
                    throw new AuraHandledException('Rating and feedback are required for all questions');
                }
            }
            List<BrandingCaseResponse__c> surveyResponses = new List<BrandingCaseResponse__c>();
            for (Map<String, Object> response : responses) {
                surveyResponses.add(new BrandingCaseResponse__c(
                    Branding_Case__c = caseId,
                    FeedbackQBank__c = (Id)response.get('questionId'),
                    Rating__c = Integer.valueOf(response.get('rating')),
                    Feedback__c = String.valueOf(response.get('feedback')),
                    SubmittedBy__c = currentUserId
                ));
            }
            insert surveyResponses;
        } catch (Exception e) {
            System.debug('submitSurvey Exception: ' + e.getMessage());
            throw new AuraHandledException('Error submitting survey: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean hasSurvey(Id caseId) {
        try {
            if (caseId == null) {
                System.debug('hasSurvey: caseId is null');
                return true;
            }
            Id currentUserId = UserInfo.getUserId();
            Branding_Case__c caseRecord = [SELECT Case_Owner__c, CreatedById 
                                           FROM Branding_Case__c 
                                           WHERE Id = :caseId 
                                           LIMIT 1];
            Boolean isCaseOwner = caseRecord.Case_Owner__c == currentUserId;
            Id contactId = caseRecord.CreatedById;
            Boolean isCreatedUser = false;
            if (contactId != null) {
                List<User> relatedUsers = [SELECT Id FROM User WHERE Id = :contactId LIMIT 1];
                isCreatedUser = !relatedUsers.isEmpty() && relatedUsers[0].Id == currentUserId;
            }
            if (!isCaseOwner && !isCreatedUser) {
                System.debug('hasSurvey: User is not authorized');
                return true;
            }
            List<FeedbackTemplate__c> templates = [SELECT Id 
                                                   FROM FeedbackTemplate__c 
                                                   WHERE FeedbackType__c = 'Others' 
                                                   AND Template_Name__c = 'Others - Branding Case' 
                                                   AND Active__c = true 
                                                   LIMIT 1];
            if (templates.isEmpty()) {
                System.debug('hasSurvey: No FeedbackTemplate__c found');
                return true; // Hide survey if no template exists
            }
            List<FeedbackQbank__c> questions = [SELECT Id 
                                                FROM FeedbackQbank__c 
                                                WHERE FeedbackTemplate__c = :templates[0].Id];
            if (questions.isEmpty()) {
                System.debug('hasSurvey: No FeedbackQbank__c records found');
                return true; // Hide survey if no questions exist
            }
            Set<Id> questionIds = new Set<Id>();
            for (FeedbackQbank__c question : questions) {
                questionIds.add(question.Id);
            }            
            List<BrandingCaseResponse__c> responses = [SELECT SubmittedBy__c, FeedbackQBank__c 
                                                       FROM BrandingCaseResponse__c 
                                                       WHERE Branding_Case__c = :caseId 
                                                       AND SubmittedBy__c =:currentUserId 
                                                       AND FeedbackQBank__c IN :questionIds];
            Set<Id> userQuestionIds = new Set<Id>();
            for (BrandingCaseResponse__c response : responses) {
                userQuestionIds.add(response.FeedbackQBank__c);
            }
            if (userQuestionIds.size() == questionIds.size()) {
                System.debug('hasSurvey: Current user has submitted all questions');
                return true; // Hide survey for current user
            }
            return false;            
        } catch (Exception e) {
            System.debug('hasSurvey Exception: ' + e.getMessage());
            throw new AuraHandledException('Error checking survey existence: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FeedbackQbank__c> getSurveyQuestions() {
        try {
            List<FeedbackTemplate__c> templates = [SELECT Id 
                                                   FROM FeedbackTemplate__c 
                                                   WHERE FeedbackType__c = 'Others' 
                                                   AND Template_Name__c = 'Others - Branding Case' 
                                                   AND Active__c = true 
                                                   LIMIT 1];
            if (templates.isEmpty()) {
                System.debug('getSurveyQuestions: No FeedbackTemplate__c found');
                return new List<FeedbackQbank__c>(); // Return empty list if no template
            }
            List<FeedbackQbank__c> questions = [SELECT Id, Question__c 
                                                FROM FeedbackQbank__c 
                                                WHERE FeedbackTemplate__c = :templates[0].Id 
                                                ORDER BY CreatedDate];
            System.debug('getSurveyQuestions: Found ' + questions.size() + ' questions');
            return questions;
        } catch (Exception e) {
            System.debug('getSurveyQuestions Exception: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving survey questions: ' + e.getMessage());
        }
    }
}