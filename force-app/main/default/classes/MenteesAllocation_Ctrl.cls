public without sharing class MenteesAllocation_Ctrl {
    @AuraEnabled
    public static TermDetailsWrp getTermDetails(String recId, Integer menteesPerMentor,List<String> selectedSchools) {
        TermDetailsWrp objTermDetailsWrp = new TermDetailsWrp();
        
        hed__Term__c objTerm = [
            SELECT Id, Name, school__c,Term_Number__c, Program_Batch__c, Program_Batch__r.Name
            FROM hed__Term__c WHERE Id = :recId LIMIT 1];
        objTermDetailsWrp.objTerm = objTerm;
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
        List<Account> allshcools = [SELECT id,Name from Account WHERE RecordTypeId =:accRecordTypeId AND Name !=:objTerm.School__c];
        objTermDetailsWrp.schools = allshcools;
        
        List<hed__Program_Enrollment__c> unassignedEnrollments = [
            SELECT Id,hed__Contact__r.Application_Number__c,Section__r.Name, hed__Contact__c,hed__Contact__r.Name,hed__Contact__r.LastName,hed__Contact__r.SRN_Number__c,hed__Program_Plan__c FROM hed__Program_Enrollment__c
            WHERE hed__Program_Plan__c = :objTerm.Program_Batch__c AND Semester__c = :recId AND Student_Status__c = 'Pursuing'
            AND hed__Contact__c NOT IN (SELECT ContactId FROM Case WHERE Record_Type_Name__c = 'Mentee')];
        
        //objTermDetailsWrp.totalUnassignedRecords = unassignedEnrollments.size();
        
        List<hed__Program_Enrollment__c> assignedEnrollments = [
            SELECT Id, hed__Contact__r.Application_Number__c,Section__r.Name,hed__Contact__c,hed__Contact__r.Name,hed__Contact__r.LastName,hed__Contact__r.SRN_Number__c,hed__Contact__r.Mentor__c,hed__Program_Plan__c 
            FROM hed__Program_Enrollment__c
            WHERE hed__Program_Plan__c = :objTerm.Program_Batch__c 
            AND Semester__c = :recId AND hed__Contact__r.Student_Status__c = 'Pursuing' AND hed__Contact__r.Mentor__c = NULL
            AND hed__Contact__c IN (
                SELECT ContactId 
                FROM Case 
                WHERE Record_Type_Name__c = 'Mentee'               
            )
        ];
        
        // Set Total Mentees (unassigned + assigned pursuing)
        // objTermDetailsWrp.totalUnassignedRecords = unassignedEnrollments + assignedEnrollments;
        List<hed__Program_Enrollment__c> allEnrollments = new List<hed__Program_Enrollment__c>();
        allEnrollments.addAll(unassignedEnrollments);
        allEnrollments.addAll(assignedEnrollments);
        if (objTerm.Term_Number__c == 1) {
            allEnrollments.sort(new NameComparator()); // Sort alphabetically by Name
        } else {
            allEnrollments.sort(new SRNNumberComparator()); // Sort by SRN_Number__c
        }
        
        objTermDetailsWrp.totalUnassignedRecords = allEnrollments.size();
        
        List<List<hed__Program_Enrollment__c>> menteeGroups = new List<List<hed__Program_Enrollment__c>>();
        List<hed__Program_Enrollment__c> tempGroup = new List<hed__Program_Enrollment__c>();
        
        for (Integer i = 0; i < allEnrollments.size(); i++) {
            tempGroup.add(allEnrollments[i]);            
            // If group is full or it's the last record, add to menteeGroups
            if (tempGroup.size() == menteesPerMentor || i == allEnrollments.size() - 1) {
                menteeGroups.add(new List<hed__Program_Enrollment__c>(tempGroup));
                tempGroup.clear();
            }
        }
        objTermDetailsWrp.menteeGroups = menteeGroups;
        
        List<Contact> professorsWithoutCases = [
            SELECT Id, Name, Max_Mentees__c,hed__WorkEmail__c FROM Contact WHERE Account_Name__c = :objTerm.school__c 
            AND Record_Type_Name__c = 'Professor' AND Max_Mentees__c !=null AND hed__WorkEmail__c !=NULL
            AND Id NOT IN (SELECT ContactId FROM Case WHERE Record_Type_Name__c = 'Mentor' AND ContactId != NULL)
            ORDER BY Name ASC];
        
        Set<String> emailToSchoolMap = new Set<String>();
        for (Contact prof : professorsWithoutCases) {
            emailToSchoolMap.add(prof.hed__WorkEmail__c);
        }      
        Set<String> validEmails = new Set<String>();
        if (!emailToSchoolMap.isEmpty()) {
            List<User> matchingUsers = [SELECT FederationIdentifier,isActive FROM User 
                                        WHERE FederationIdentifier IN :emailToSchoolMap AND isActive = true];
            
            for (User usr : matchingUsers) {
                // Ensure the Department (School) matches the Contact's Account_Namec (School)
                if (emailToSchoolMap.contains(usr.FederationIdentifier)) {
                    validEmails.add(usr.FederationIdentifier);
                }
            }
        }
        List<ProfessorWithMenteeCount> professorList = new List<ProfessorWithMenteeCount>();
        for (Contact prof : professorsWithoutCases) {  
            if (validEmails.contains(prof.hed__WorkEmail__c)) {
                ProfessorWithMenteeCount profWrapper = new ProfessorWithMenteeCount(prof, 0);
                professorList.add(profWrapper);
            }           
        }  
        
        List<Case> professorCases = [
            SELECT Id, ContactId FROM Case WHERE Record_Type_Name__c = 'Mentor' 
            AND ContactId IN (SELECT Id FROM Contact WHERE Account_Name__c = :objTerm.school__c 
                              AND Record_Type_Name__c = 'Professor' AND Max_Mentees__c !=null)];        
        
        Set<Id> professorCaseIds = new Set<Id>();
        Map<Id, Id> caseToProfessorMap = new Map<Id, Id>();
        
        for (Case c : professorCases) {
            professorCaseIds.add(c.Id);
            caseToProfessorMap.put(c.Id, c.ContactId);
        }
        Map<Id, Integer> professorMenteeCountMap = new Map<Id, Integer>();
        for (Id caseId : professorCaseIds) {
            professorMenteeCountMap.put(caseId, 0); // Default mentee count as 0
        }      
        
        Map<Id, Set<Id>> caseToContactMap = new Map<Id, Set<Id>>();
        for (CaseTeamMember ctm : [
            SELECT Id, ParentId, MemberId
            FROM CaseTeamMember
            WHERE ParentId IN :professorCaseIds
        ]) {
            if (!caseToContactMap.containsKey(ctm.ParentId)) {
                caseToContactMap.put(ctm.ParentId, new Set<Id>());
            }
            caseToContactMap.get(ctm.ParentId).add(ctm.MemberId);
        }
        System.debug('Case to Contact Map: ' + caseToContactMap);
        Set<Id> allMemberIds = new Set<Id>();
        for (Set<Id> memberIds : caseToContactMap.values()) {
            allMemberIds.addAll(memberIds); 
        }
        Set<Id> pursuingContacts = new Set<Id>();
        for (Contact c : [
            SELECT Id
            FROM Contact
            WHERE Id IN :allMemberIds
            AND Student_Status__c = 'Pursuing'
        ]) {
            pursuingContacts.add(c.Id);
        }
        System.debug('Pursuing Contacts: ' + pursuingContacts);
        Map<Id, Integer> professorToMenteeCount = new Map<Id, Integer>();
        for (Id caseId : caseToContactMap.keySet()) {
            Set<Id> contactIds = caseToContactMap.get(caseId);
            
            for (Id contactId : contactIds) {
                if (pursuingContacts.contains(contactId)) {
                    Id professorId = caseToProfessorMap.get(caseId);
                    
                    if (!professorToMenteeCount.containsKey(professorId)) {
                        professorToMenteeCount.put(professorId, 0);
                    }
                    professorToMenteeCount.put(professorId, professorToMenteeCount.get(professorId) + 1);
                }
            }
        }
        System.debug('Professor to Pursuing Mentee Count: ' + professorToMenteeCount);
        /*
for (AggregateResult ar : [
SELECT ParentId, COUNT(Id) menteeCount FROM CaseTeamMember
WHERE ParentId IN :professorCaseIds GROUP BY ParentId])
{
Id caseId = (Id) ar.get('ParentId');
Integer menteeCount = (Integer) ar.get('menteeCount');
professorMenteeCountMap.put(caseId, menteeCount); 

// Map Mentee Count to Professor ID
if (caseToProfessorMap.containsKey(caseId)) {
Id professorId = caseToProfessorMap.get(caseId);
if (!professorToMenteeCount.containsKey(professorId)) {
professorToMenteeCount.put(professorId, 0);
}
professorToMenteeCount.put(professorId, professorToMenteeCount.get(professorId) + menteeCount);
}
} */
        
        List<Contact> professorsWithCases = [
            SELECT Id, Name, Max_Mentees__c,hed__WorkEmail__c FROM Contact WHERE Account_Name__c = :objTerm.school__c 
            AND Record_Type_Name__c = 'Professor' AND Max_Mentees__c !=null AND hed__WorkEmail__c !=NULL
            AND Id IN (SELECT ContactId FROM Case WHERE id IN:professorMenteeCountMap.keySet()) ORDER BY Name ASC];
        
        Set<String> emailToSchoolMap1 = new Set<String>();
        for (Contact prof : professorsWithCases) {
            emailToSchoolMap1.add(prof.hed__WorkEmail__c);
        }      
        Set<String> validEmails1 = new Set<String>();
        if (!emailToSchoolMap1.isEmpty()) {
            List<User> matchingUsers1 = [SELECT FederationIdentifier,isActive FROM User 
                                         WHERE FederationIdentifier IN :emailToSchoolMap1 AND isActive = true];
            
            for (User usr : matchingUsers1) {                
                if (emailToSchoolMap1.contains(usr.FederationIdentifier)) {
                    validEmails1.add(usr.FederationIdentifier);
                }
            }
        }
        for (Contact prof : professorsWithCases) {
            Integer assignedMentees = professorToMenteeCount.containsKey(prof.id) ? professorToMenteeCount.get(prof.Id) : 0;
            if (assignedMentees < prof.Max_Mentees__c) {
                if (validEmails1.contains(prof.hed__WorkEmail__c)) {
                    ProfessorWithMenteeCount profWrapper = new ProfessorWithMenteeCount(prof, assignedMentees);
                    professorList.add(profWrapper);
                    system.debug('Professor with case==='+profWrapper);
                }
            }
        }
        List<Contact> crossSchoolProfessorsWithoutCases = new List<Contact>();        
        if (selectedSchools != null && !selectedSchools.isEmpty()) {
            crossSchoolProfessorsWithoutCases = [
                SELECT Id, Name, Max_Mentees__c, hed__WorkEmail__c 
                FROM Contact 
                WHERE AccountId IN :selectedSchools 
                AND Record_Type_Name__c = 'Professor' 
                AND Max_Mentees__c != null 
                AND hed__WorkEmail__c != null
                AND Id NOT IN (SELECT ContactId FROM Case WHERE Record_Type_Name__c = 'Mentor' AND ContactId != NULL)
                ORDER BY Name ASC
            ];
        }
        Set<String> crossEmailToSchoolMap = new Set<String>();
        for (Contact prof : crossSchoolProfessorsWithoutCases) {
            crossEmailToSchoolMap.add(prof.hed__WorkEmail__c);
        }
        Set<String> crossValidEmails = new Set<String>();
        if (!crossEmailToSchoolMap.isEmpty()) {
            List<User> crossMatchingUsers = [SELECT FederationIdentifier, isActive FROM User 
                                             WHERE FederationIdentifier IN :crossEmailToSchoolMap AND isActive = TRUE];
            for (User usr : crossMatchingUsers) {
                if (crossEmailToSchoolMap.contains(usr.FederationIdentifier)) {
                    crossValidEmails.add(usr.FederationIdentifier);
                }
            }
        }
        List<ProfessorWithMenteeCount> crossSchoolProfessorList = new List<ProfessorWithMenteeCount>();
        for (Contact prof : crossSchoolProfessorsWithoutCases) {
            if (crossValidEmails.contains(prof.hed__WorkEmail__c)) {
                ProfessorWithMenteeCount profWrapper = new ProfessorWithMenteeCount(prof, 0);
                crossSchoolProfessorList.add(profWrapper);
            }
        }
        List<Case> crossSchoolProfessorCases = new List<Case>();
        if (selectedSchools != null && !selectedSchools.isEmpty()) {
            crossSchoolProfessorCases = [
                SELECT Id, ContactId 
                FROM Case 
                WHERE Record_Type_Name__c = 'Mentor' 
                AND ContactId IN (SELECT Id FROM Contact WHERE AccountId IN :selectedSchools 
                                  AND Record_Type_Name__c = 'Professor' AND Max_Mentees__c != null)
            ];
        }
        Set<Id> crossSchoolProfessorCaseIds = new Set<Id>();
        Map<Id, Id> crossCaseToProfessorMap = new Map<Id, Id>();
        for (Case c : crossSchoolProfessorCases) {
            crossSchoolProfessorCaseIds.add(c.Id);
            crossCaseToProfessorMap.put(c.Id, c.ContactId);
        }
        Map<Id, Integer> crossSchoolProfessorMenteeCountMap = new Map<Id, Integer>();
        for (Id caseId : crossSchoolProfessorCaseIds) {
            crossSchoolProfessorMenteeCountMap.put(caseId, 0);
        }
        Map<Id, Set<Id>> crossCaseToContactMap = new Map<Id, Set<Id>>();
        for (CaseTeamMember ctm : [
            SELECT Id, ParentId, MemberId
            FROM CaseTeamMember
            WHERE ParentId IN :crossSchoolProfessorCaseIds
        ]) {
            if (!crossCaseToContactMap.containsKey(ctm.ParentId)) {
                crossCaseToContactMap.put(ctm.ParentId, new Set<Id>());
            }
            crossCaseToContactMap.get(ctm.ParentId).add(ctm.MemberId);
        }
        Set<Id> crossAllMemberIds = new Set<Id>();
        for (Set<Id> memberIds : crossCaseToContactMap.values()) {
            crossAllMemberIds.addAll(memberIds);
        }
        Set<Id> crossPursuingContacts = new Set<Id>();
        for (Contact c : [
            SELECT Id
            FROM Contact
            WHERE Id IN :crossAllMemberIds
            AND Student_Status__c = 'Pursuing'
        ]) {
            crossPursuingContacts.add(c.Id);
        }
        Map<Id, Integer> crossProfessorToMenteeCount = new Map<Id, Integer>();
        for (Id caseId : crossCaseToContactMap.keySet()) {
            Set<Id> contactIds = crossCaseToContactMap.get(caseId);
            for (Id contactId : contactIds) {
                if (crossPursuingContacts.contains(contactId)) {
                    Id professorId = crossCaseToProfessorMap.get(caseId);
                    if (!crossProfessorToMenteeCount.containsKey(professorId)) {
                        crossProfessorToMenteeCount.put(professorId, 0);
                    }
                    crossProfessorToMenteeCount.put(professorId, crossProfessorToMenteeCount.get(professorId) + 1);
                }
            }
        }
        List<Contact> crossSchoolProfessorsWithCases = new List<Contact>();
        if (selectedSchools != null && !selectedSchools.isEmpty()) {
            crossSchoolProfessorsWithCases = [
                SELECT Id, Name, Max_Mentees__c, hed__WorkEmail__c 
                FROM Contact 
                WHERE AccountId IN :selectedSchools  
                AND Record_Type_Name__c = 'Professor' 
                AND Max_Mentees__c != null 
                AND hed__WorkEmail__c != null
                AND Id IN (SELECT ContactId FROM Case WHERE Id IN :crossSchoolProfessorMenteeCountMap.keySet())
                ORDER BY Name ASC
            ];
        }
        Set<String> crossEmailToSchoolMap1 = new Set<String>();
        for (Contact prof : crossSchoolProfessorsWithCases) {
            crossEmailToSchoolMap1.add(prof.hed__WorkEmail__c);
        }
        Set<String> crossValidEmails1 = new Set<String>();
        if (!crossEmailToSchoolMap1.isEmpty()) {
            List<User> crossMatchingUsers1 = [SELECT FederationIdentifier, isActive FROM User 
                                              WHERE FederationIdentifier IN :crossEmailToSchoolMap1 AND isActive = TRUE];
            for (User usr : crossMatchingUsers1) {
                if (crossEmailToSchoolMap1.contains(usr.FederationIdentifier)) {
                    crossValidEmails1.add(usr.FederationIdentifier);
                }
            }
        }
        for (Contact prof : crossSchoolProfessorsWithCases) {
            Integer assignedMentees = crossProfessorToMenteeCount.containsKey(prof.Id) ? crossProfessorToMenteeCount.get(prof.Id) : 0;
            if (assignedMentees < prof.Max_Mentees__c) {
                if (crossValidEmails1.contains(prof.hed__WorkEmail__c)) {
                    ProfessorWithMenteeCount profWrapper = new ProfessorWithMenteeCount(prof, assignedMentees);
                    crossSchoolProfessorList.add(profWrapper);
                    system.debug('Cross School Professor with case===' + profWrapper);
                }
            }
        }
        objTermDetailsWrp.crossSchoolProfessors = crossSchoolProfessorList;
        system.debug('FInal cross shcool professors==='+objTermDetailsWrp.crossSchoolProfessors);
        objTermDetailsWrp.professors = professorList;
        system.debug('FInal professors==='+objTermDetailsWrp.professors);
        objTermDetailsWrp.ProfessorCount = professorList.size();
        return objTermDetailsWrp;
    }
    @AuraEnabled
    public static void submitMenteeAllocation(String termId, String allocationDataStr) {
        
        Map<String, List<String>> allocations = new Map<String, List<String>>();
        
        try {        
            Map<String, Object> untypedMap = (Map<String, Object>)JSON.deserializeUntyped(allocationDataStr);
            for (String key : untypedMap.keySet()) {
                Object value = untypedMap.get(key);
                if (value instanceof List<Object>) {
                    List<Object> menteeList = (List<Object>)value;
                    List<String> menteeIds = new List<String>();
                    for (Object menteeObj : menteeList) {
                        if (menteeObj instanceof String) {
                            menteeIds.add((String)menteeObj);
                        }
                    }
                    allocations.put(key, menteeIds);
                }
            }
        } catch (JSONException e) {
            throw new AuraHandledException('Error parsing allocation data: ' + e.getMessage());
        }
        List<Case> mentorCases = new List<Case>();
        List<Case> menteeCases = new List<Case>();
        List<Case> menteeCasesToInsert = new List<Case>(); 
        List<Case> menteeCasesToUpdate = new List<Case>();
        List<CaseTeamMember> caseTeamMembers = new List<CaseTeamMember>();
        List<Contact> contactsToUpdate = new List<Contact>();
        
        System.debug('data==' + allocations);       
        Map<Id, Case> existingMentorCases = new Map<Id, Case>();
        for (Case c : [SELECT Id, ContactId FROM Case WHERE Record_Type_Name__c = 'Mentor' 
                       AND ContactId IN :allocations.keySet()]) 
        {
            existingMentorCases.put(c.ContactId, c);
        }
        Map<Id, String> professorEmailMap = new Map<Id, String>();
        for (Contact prof : [SELECT Id, hed__WorkEmail__c FROM Contact WHERE Id IN :allocations.keySet() AND hed__WorkEmail__c != null]) {
            professorEmailMap.put(prof.Id, prof.hed__WorkEmail__c);
        }
        
        // Fetch user records based on Username = professor Email
        Map<String, Id> emailToUserIdMap = new Map<String, Id>();
        if (!professorEmailMap.isEmpty()) {
            for (User u : [SELECT Id, Username FROM User WHERE Username IN :professorEmailMap.values()]) {
                emailToUserIdMap.put(u.Username, u.Id);
            }
        }
        Id mentorRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Mentor').getRecordTypeId();
        Id menteeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Mentee').getRecordTypeId();
        
        for (String professorId : allocations.keySet()) {
            Case mentorCase;
            
            if (existingMentorCases.containsKey(professorId)) {
                mentorCase = existingMentorCases.get(professorId);
            } else 
            {   
                String profEmail = professorEmailMap.get(professorId);
                Id ownerUserId = (emailToUserIdMap.containsKey(profEmail)) ? emailToUserIdMap.get(profEmail) : UserInfo.getUserId();
                mentorCase = new Case(
                    RecordTypeId = mentorRecordTypeId,
                    ContactId = professorId,
                    Status = 'Queued',
                    Priority = 'Medium',
                    Origin = 'Email',
                    OwnerId = ownerUserId
                );
                mentorCases.add(mentorCase);                    
            }
        }
        
        if (!mentorCases.isEmpty()) {
            insert mentorCases;
            
            for (Case c : mentorCases) {
                existingMentorCases.put(c.ContactId, c);
            }
        }        
        System.debug('Existing Mentor Cases: ' + existingMentorCases);
        Set<String> allMenteeIds = new Set<String>();
        for (List<String> menteeIds : allocations.values()) {
            allMenteeIds.addAll(menteeIds);
        }
        Map<Id, Case> existingMenteeCases = new Map<Id, Case>(
            [SELECT Id, ContactId, Mentor__c 
             FROM Case 
             WHERE Record_Type_Name__c = 'Mentee' 
             AND ContactId IN :allMenteeIds]
        );
        for (String professorId : allocations.keySet()) {
            Case mentorCase = existingMentorCases.get(professorId);
            system.debug('mentor__c id==='+mentorCase);
            if (mentorCase != null && allocations.get(professorId) != null) {
                for (String menteeId : allocations.get(professorId)) {
                    Case existingCase = null;
                    for (Case c : existingMenteeCases.values()) {
                        if (c.ContactId == menteeId) {
                            existingCase = c;
                            break;
                        }
                    }
                    
                    if (existingCase != null) {                        
                        existingCase.Mentor__c = mentorCase.ContactId;
                        menteeCasesToUpdate.add(existingCase);
                    } else {
                        Case menteeCase = new Case(
                            RecordTypeId = menteeRecordTypeId,
                            ContactId = menteeId,
                            Mentor__c = mentorCase.ContactId,  
                            Status = 'Queued',
                            Priority = 'Medium',
                            Origin = 'Email'
                        );
                        menteeCasesToInsert.add(menteeCase);
                    }  
                    Contact menteeContact = new Contact(
                        Id = menteeId,
                        Mentor__c = mentorCase.ContactId  
                    );
                    contactsToUpdate.add(menteeContact);
                }
            }
        }
        
        if (!menteeCasesToInsert.isEmpty()) {
            insert menteeCasesToInsert;
            System.debug('Mentee Cases Inserted: ' + menteeCasesToInsert);
        }
        
        if (!menteeCasesToUpdate.isEmpty()) {
            update menteeCasesToUpdate;
            System.debug('Mentee Cases Updated: ' + menteeCasesToUpdate);
        }
        
        if (!contactsToUpdate.isEmpty()) {
            System.debug('Updating contacts with mentor assignments: ' + contactsToUpdate.size());
            update contactsToUpdate;
        } 
        CaseTeamRole role;
        try {
            role = [SELECT Id FROM CaseTeamRole WHERE Name = 'Student Member' LIMIT 1];
        } catch (QueryException e) {
            throw new AuraHandledException('CaseTeamRole "Student Member" not found: ' + e.getMessage());
        }
        List<Case> allMenteeCases = new List<Case>();
        allMenteeCases.addAll(menteeCasesToInsert);
        allMenteeCases.addAll(menteeCasesToUpdate);
        for (Case menteeCase : allMenteeCases) {
            if (menteeCase.ContactId != null) {                
                Case mentorCase = existingMentorCases.get(menteeCase.Mentor__c);                    
                if (mentorCase != null) {
                    CaseTeamMember ctm = new CaseTeamMember(
                        ParentId = mentorCase.Id, 
                        MemberId = menteeCase.ContactId,  
                        TeamRoleId = role.Id 
                    );
                    caseTeamMembers.add(ctm);
                }
            }
        }
        if (!caseTeamMembers.isEmpty()) {
            insert caseTeamMembers;
        }
        
        System.debug('Case Team Members Inserted: ' + caseTeamMembers);            
        
    }
    public class NameComparator implements System.Comparator<hed__Program_Enrollment__c> {
        public Integer compare(hed__Program_Enrollment__c a, hed__Program_Enrollment__c b) {
            String nameA = a.hed__Contact__r.Name != null ? a.hed__Contact__r.Name : '';
            String nameB = b.hed__Contact__r.Name != null ? b.hed__Contact__r.Name : '';
            return nameA.compareTo(nameB);
        }
    }
    
    public class SRNNumberComparator implements System.Comparator<hed__Program_Enrollment__c> {
        public Integer compare(hed__Program_Enrollment__c a, hed__Program_Enrollment__c b) {
            String srnA = a.hed__Contact__r.SRN_Number__c != null ? a.hed__Contact__r.SRN_Number__c : '';
            String srnB = b.hed__Contact__r.SRN_Number__c != null ? b.hed__Contact__r.SRN_Number__c : '';
            return srnA.compareTo(srnB);
        }
    }
    
    public class TermDetailsWrp {
        @AuraEnabled public hed__Term__c objTerm { get; set; }
        @AuraEnabled public Integer totalUnassignedRecords { get; set; }        
        @AuraEnabled public List<List<hed__Program_Enrollment__c>> menteeGroups { get; set; }
        @AuraEnabled public List<ProfessorWithMenteeCount> professors { get; set; }
        @AuraEnabled public Integer ProfessorCount { get; set; }
        @AuraEnabled public List<Account> schools { get; set; }
        @AuraEnabled public List<ProfessorWithMenteeCount> crossSchoolProfessors { get; set; }
    }
    
    public class ProfessorWithMenteeCount {
        @AuraEnabled public Contact professor { get; set; }
        @AuraEnabled public Integer menteeCount { get; set; }
        public ProfessorWithMenteeCount(Contact professor, Integer menteeCount) {
            this.professor = professor;
            this.menteeCount = menteeCount;
        }
    }   
    
}