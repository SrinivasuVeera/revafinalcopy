/**
 * @author Devender Jadala
 * @comany Cloud Odyssey
 * @date 2023-10-04
 * @description This class is responsible for retrieving the existing preferences 
 *              of a professor. It ensures that the data is accessed securely 
 *              and adheres to the sharing rules defined in the Salesforce org.
 */
public with sharing class GetProfessorExistingPreferencesCtrl {

    /**
     * @description Wrapper class to encapsulate the professor's preferences data, 
     *              including whether freezing is allowed and the list of preferences.
     */
    public class PreferenceWrapper {
        @AuraEnabled public Boolean isAllowFreezing;
        @AuraEnabled public String requiredOptions;
        @AuraEnabled public List<Professor_Student_Course_Preference__c> preferences;
        @AuraEnabled public Integer maxTheory;
        @AuraEnabled public Integer maxPractical;
    }

    /**
     * @description Retrieves the existing preferences of a professor, including 
     *              whether freezing is allowed and the list of preferences.
     * @return A PreferenceWrapper object containing the professor's preferences 
     *         and whether freezing is allowed.
     */
    @AuraEnabled (cacheable=true)
    public static PreferenceWrapper getExistingPrefCollection() {
        try {
            PreferenceWrapper result = new PreferenceWrapper();

            User usr = getCurrentUser();
            if (usr == null || String.isBlank(usr.Email)) {
                return initializeEmptyPreferences(result);
            }

            Contact professorContact = getProfessorContact(usr.Email);
            if (professorContact == null) {
               return initializeEmptyPreferences(result);
            }
            Account schoolAcc = [SELECT Id,Max_Theory_Preferences__c,Max_Practical_Preferences__c
                    FROM Account WHERE Id = :professorContact.AccountId LIMIT 1];

            result.maxTheory = schoolAcc.Max_Theory_Preferences__c == null ? 0 : Integer.valueOf(schoolAcc.Max_Theory_Preferences__c);
            result.maxPractical = schoolAcc.Max_Practical_Preferences__c == null ? 0 : Integer.valueOf(schoolAcc.Max_Practical_Preferences__c);            

            //List<hed__Course_Offering__c> courseOfferingsList = getCourseOfferings(professorContact);
            List<Professor_Student_Course_Preference__c> prefList = getProfessorPreferences(professorContact.Id);

            result.preferences = prefList;
            result.requiredOptions = 'Allow';
            result.isAllowFreezing = true;
            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void updatePreferences(
        List<Professor_Student_Course_Preference__c> updatedPreferences
    ){
        if(updatedPreferences != null && !updatedPreferences.isEmpty()){
            update updatedPreferences;
        }
    }

    private static User getCurrentUser() {
        if (Schema.sObjectType.User.isAccessible()) {
            return [SELECT Id, Name, ContactId, Email FROM User WHERE Id = :UserInfo.getUserId()];
        }
        throw new AuraHandledException('Insufficient permissions to access User records.');
    }

    private static Contact getProfessorContact(String email) {
    if (Schema.sObjectType.Contact.isAccessible()) {

        List<Contact> contacts = [
            SELECT Id, Professor_Across_Schools__c, AccountId
            FROM Contact
            WHERE Email = :email
            AND Account.RecordType.Name = :Utility.Acc_RecType_University_Department
            LIMIT 1
        ];

        return contacts.isEmpty() ? null : contacts[0];
    }

    throw new AuraHandledException(
        'Insufficient permissions to access Contact records.'
    );
}

    /*private static List<hed__Course_Offering__c> getCourseOfferings(Contact professorContact) {
        if (Schema.sObjectType.hed__Course_Offering__c.isAccessible()) {
            if (professorContact.Professor_Across_Schools__c) {
                return [
                    SELECT Id
                    FROM hed__Course_Offering__c
                    WHERE hed__Term__r.Allow_Professors_for_Preferences__c = true
                ];
            } else {
                return [
                    SELECT Id
                    FROM hed__Course_Offering__c
                    WHERE hed__Term__r.Allow_Professors_for_Preferences__c = true
                    AND Offered_By_School__c = :professorContact.AccountId
                    AND hed__Term__r.hed__Account__r.ParentId = :professorContact.AccountId
                ];
            }
        }
        throw new AuraHandledException('Insufficient permissions to access Course Offering records.');
    }*/

    private static List<Professor_Student_Course_Preference__c> getProfessorPreferences(Id professorId) {
        if (Schema.sObjectType.Professor_Student_Course_Preference__c.isAccessible()) {
            return [
                SELECT Id, Name, Preference__c, Preference_No__c, Professor__r.Name,
                    Course_ID__c, Course_Offering__r.hed__Course__r.Name,
                    Course_Offering__r.hed__Course__r.HardCore_Sub_Type__c,
                    Course_Offering__r.hed__Course__r.Category__c, Semester__r.Name,
                    Semester__r.Allow_Professors_for_Preferences__c,
                    Course_Offering__r.Offered_By_School__r.Name, Semester__c,
                    Professor_Preference__c, Semester__r.Program_Batch__r.Name,
                    Semester__r.hed__Account__r.Name, Course_Offering__r.School__c
                FROM Professor_Student_Course_Preference__c
                WHERE Semester__r.Allow_Professors_for_Preferences__c = true
                AND Course_Offering__c != null
                AND Professor__c = :professorId
                AND Semester__c != null
                AND Preference__c != null
                AND Preference_No__c != null
            ];
        }
        throw new AuraHandledException('Insufficient permissions to access Professor Student Course Preference records.');
    }

    /*private static Boolean calculateAllowFreezing(Integer totalCourseOfferings, List<Professor_Student_Course_Preference__c> prefList, PreferenceWrapper result) {
        Integer totalPreferences = prefList.size();
        Integer oneCount = 0;

        for (Professor_Student_Course_Preference__c pref : prefList) {
            if (pref.Preference_No__c == 1) {
                oneCount++;
            }
        }

        if (totalCourseOfferings >= 20) {
            if (oneCount == 2) {
                result.requiredOptions = '10';
                return totalPreferences >= 10;
            } else if (oneCount == 1) {
                result.requiredOptions = '9';
                return totalPreferences == 9;
            } else {
                result.requiredOptions = '8';
                return totalPreferences == 8;
            }
        } else {
            result.requiredOptions = 'Allow';
            return true;
        }
    }*/
	@TestVisible
    private static PreferenceWrapper initializeEmptyPreferences(PreferenceWrapper result) {
        result.isAllowFreezing = false;
        result.preferences = new List<Professor_Student_Course_Preference__c>();
        return result;
    }

    
    /**
     * @description Freezes the professor's preferences by updating the Professor_Preference__c field to true 
     *              for eligible records.
     * @param savedProPreference A list of Professor_Student_Course_Preference__c records to be frozen.
     * @return A string message indicating the result of the operation.
     */
    @AuraEnabled
    public static String freezeProPreference(List<Professor_Student_Course_Preference__c> savedProPreference) {
        try {
            if (savedProPreference == null || savedProPreference.isEmpty()) {
                return 'No preferences were provided to freeze.';
            }
                
            Set<Id> passedPreferenceIds = new Set<Id>();
            for (Professor_Student_Course_Preference__c pref : savedProPreference) {
                passedPreferenceIds.add(pref.Id);
            }
    
            List<Professor_Student_Course_Preference__c> preferencesToUpdate = [
                SELECT Id, Professor_Preference__c
                FROM Professor_Student_Course_Preference__c
                WHERE  Semester__r.Allow_Professors_for_Preferences__c = true
                  AND Course_Offering__c != null
                  AND Professor__c !=  null
                  AND Semester__c != null
                  AND Professor_Preference__c = false
                  AND Preference__c != null
                  AND Preference_No__c != null
                  AND Id IN :passedPreferenceIds
            ];
    
            if (preferencesToUpdate.isEmpty()) {
                return 'No eligible preferences found to freeze/Already freezed.';
            }
    
            for (Professor_Student_Course_Preference__c pref : preferencesToUpdate) {
                pref.Professor_Preference__c = true;
            }
    
            try {
                if (Schema.sObjectType.Professor_Student_Course_Preference__c.isUpdateable()) {
                    update preferencesToUpdate;
                } else {
                    return 'Insufficient permissions to update Professor Preferences.';
                }
                return 'Professor Preferences frozen successfully.';
            } catch (DmlException dmlex) {
                return 'Error during update: ' + dmlex.getMessage();
            }
    
        } catch (Exception ex) {
            return 'Unexpected error: ' + ex.getMessage();
        }
    }
    
}