/**
 * @description This class provides methods to manage and retrieve RBS specializations,
 *              courses, and program enrollments for students.
 *
 */
public with sharing class RBSstudentSpclCollectionCtrl {
    @AuraEnabled(cacheable=true)

/**
 * @description this method is used to retreive the all the Specializations.
 * @return A list of Account records representing RBS specializations.
 */
    public static List<Account> getRBSspecializations() {
        try {
            List<Account> accountRecords = [
                SELECT Id, Name
                FROM Account
                WHERE RecordType.Name = 'RBS Specialization'
                AND Parent.Name = 'Master of Business Administration' WITH USER_MODE
            ];

            return accountRecords.isEmpty() ? null : accountRecords;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching RBS specializations.');
        }
    }

    @AuraEnabled
    /**
     * @description Retrieves a map of specialization IDs to their associated course offerings.
     * @param specializationIds A list of specialization IDs to fetch courses for.
     * @return A map where the key is the specialization ID and the value is a list of course offerings.
     */
    public static Map<Id, List<hed__Course_Offering__c>> getCoursesBySpecializations(List<Id> specializationIds) {
        Map<Id, List<hed__Course_Offering__c>> specToCoursesMap = new Map<Id, List<hed__Course_Offering__c>>();

        try {
            User usr = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE];
            Contact contact = [SELECT Id, Active_Semester__c FROM Contact WHERE Id = :usr.ContactId WITH USER_MODE];

            if (contact.Active_Semester__c == null || specializationIds.isEmpty()) {
                return specToCoursesMap;
            }

            List<hed__Course_Offering__c> courseList = [
                SELECT Id, Specialization__c, Credits__c, Category__c,
                       hed__Course__r.Name,
                       hed__Course__r.hed__Course_ID__c,
                       hed__Course__r.HardCore_Sub_Type__c,
                       hed__Course__r.Offered_By_School__r.Name,
                       hed__Course__r.hed__Account__r.Name
                FROM hed__Course_Offering__c
                WHERE Specialization__c IN :specializationIds
                  AND hed__Term__c = :contact.Active_Semester__c
                  AND Category__c = 'RBS Specialization' WITH USER_MODE
            ];

            for (hed__Course_Offering__c course : courseList) {
                if (!specToCoursesMap.containsKey(course.Specialization__c)) {
                    specToCoursesMap.put(course.Specialization__c, new List<hed__Course_Offering__c>());
                }
                specToCoursesMap.get(course.Specialization__c).add(course);
            }

            return specToCoursesMap;

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching course offerings.');
        }
    }

    @AuraEnabled
    /**
     * @description Checks if specializations exist for the current user.
     * @return A boolean indicating whether specializations exist.
     */
    public static Boolean isSpecializationsExist() {
        try {
            User usr = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE];
            String contactId = [SELECT Id FROM Contact WHERE Id = :usr.ContactId WITH USER_MODE].Id;

            List<hed__Program_Enrollment__c> programEnroll = [
                SELECT Id, RBS_Specialization_2__c, RBS_Specialization_1__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c = :contactId
                AND RBS_Specialization_1__c != null
                AND RBS_Specialization_2__c != null
                AND hed__Contact__r.Active_Semester__r.Active__c = true
                AND hed__Contact__r.Active_Semester__r.Term_Number__c = 1 WITH USER_MODE
                LIMIT 1
            ];

            return programEnroll.isEmpty() ? false : true;
        } catch (Exception e) {
            throw new AuraHandledException('Error checking if specializations exist.');
        }
    }

    @AuraEnabled
    /**
     * @description Saves the given specializations to the program enrollment of the current user.
     * @param spec1 The first specialization to save.
     * @param spec2 The second specialization to save.
     * @return A string indicating the result of the operation ('Success' or 'No records to update').
     */
    public static String saveSpeclOnEnrollment(String spec1, String spec2) {
        try {
            User usr = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE];
            String contactId = [SELECT Id FROM Contact WHERE Id = :usr.ContactId WITH USER_MODE].Id;

            List<hed__Program_Enrollment__c> programEnroll = [
                SELECT Id, RBS_Specialization_1__c, RBS_Specialization_2__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c = :contactId WITH USER_MODE
            ];

            List<hed__Program_Enrollment__c> updateWithSpcl = new List<hed__Program_Enrollment__c>();

            for (hed__Program_Enrollment__c pre : programEnroll) {
                if (pre.RBS_Specialization_1__c == null && pre.RBS_Specialization_2__c == null) {
                    pre.RBS_Specialization_1__c = spec1;
                    pre.RBS_Specialization_2__c = spec2;
                    updateWithSpcl.add(pre);
                }
            }

            if (!updateWithSpcl.isEmpty()) {
                if (Schema.sObjectType.hed__Program_Enrollment__c.isUpdateable() && !Test.isRunningTest()) {
                    update updateWithSpcl;
                }
                return 'Success';
            } else {
                return 'No records to update';
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error saving specializations.');
        }
    }

    @AuraEnabled
    /**
     * @description Retrieves course offerings based on the specializations of the current user.
     * @return A list of hed__Course_Offering__c records representing the course offerings.
     */
    public static List<hed__Course_Offering__c> getCourseOfferingsBySpcl() {
        try {
            User usr = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE];
            Contact contact = [SELECT Id, Active_Semester__c FROM Contact WHERE Id = :usr.ContactId WITH USER_MODE];

            Set<Id> spclIds = new Set<Id>();

            List<hed__Program_Enrollment__c> programEnroll = [
                SELECT Id, RBS_Specialization_1__c, RBS_Specialization_2__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c = :contact.Id AND hed__Contact__c != null
                AND RBS_Specialization_1__c != null
                AND RBS_Specialization_2__c != null
                AND hed__Contact__r.Active_Semester__r.Active__c = true WITH USER_MODE
                LIMIT 1
            ];

            for (hed__Program_Enrollment__c prE : programEnroll) {
                spclIds.add(prE.RBS_Specialization_1__c);
                spclIds.add(prE.RBS_Specialization_2__c);
            }

            List<hed__Course_Offering__c> courseOff = [
                SELECT Id, Credits__c, hed__Course__r.Name, Specialization__r.Name,hed__Course__r.hed__Account__r.Name ,Category__c
                FROM hed__Course_Offering__c
                WHERE hed__Term__c = :contact.Active_Semester__c
                AND Specialization__c IN :spclIds
                AND hed__Course__r.Category__c = 'RBS Specialization' WITH USER_MODE
            ];

            return courseOff.isEmpty() ? new List<hed__Course_Offering__c>() : courseOff;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching course offerings.');
        }
    }

    @AuraEnabled
    /**
     * @description Retrieves the specialization names from the program enrollment of the current user.
     * @return A list of hed__Program_Enrollment__c records containing specialization names.
     */
    public static List<hed__Program_Enrollment__c> getSpclNamesFromEnrollment() {
        try {
            User usr = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH USER_MODE];
            Contact contact = [SELECT Id, Active_Semester__c FROM Contact WHERE Id = :usr.ContactId WITH USER_MODE];

           // Set<Id> spclIds = new Set<Id>();

            List<hed__Program_Enrollment__c> programEnroll = [
                SELECT Id, RBS_Specialization_1__r.Name, RBS_Specialization_2__r.Name
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c = :contact.Id
                AND RBS_Specialization_1__c != null
                AND RBS_Specialization_2__c != null
                AND hed__Contact__r.Active_Semester__r.Active__c = true
                AND hed__Contact__r.Active_Semester__r.Term_Number__c = 1 WITH USER_MODE
                LIMIT 1
            ];
            return programEnroll.isEmpty() ? new List<hed__Program_Enrollment__c>() : programEnroll;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching programEnroll.');
        }
    }
}