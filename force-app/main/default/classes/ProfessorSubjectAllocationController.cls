/**
 * @description Controller to transfer professor course connections
 *              from parent semester to child semesters (Sections, Batches, Groups).
 *
 * @author        Devender Jadala
 * @team          Cloud Odyssey
 * @createdDate   05/09/2025
 * @lastModified  06/09/2025 by Devender Jadala
 */
public with sharing class ProfessorSubjectAllocationController {

    @AuraEnabled
    /**
     * @description Allocates professor course connections from a parent semester to child semesters.
     * @param parentTermId The ID of the parent term (semester) to allocate connections from.
     * @return A message indicating the result of the allocation process.
     */
    public static String professorSubjectSecAllot(Id parentTermId) {
        if (parentTermId == null) {
            return 'Parent Term Id is required.';
        }

        try {
            String sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName()
                .get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
            String batchRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName()
                .get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
            String groupRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName()
                .get(Utility.Term_RecType_Group).getRecordTypeId();

            String facultyRtId = Schema.SObjectType.hed__Course_Enrollment__c
                .getRecordTypeInfosByName().get('Faculty').getRecordTypeId();

            Map<String, hed__Term__c> sectionNameToTerm = new Map<String, hed__Term__c>();
            for (hed__Term__c sec : [
                SELECT Id, Section_Name__c, hed__Parent_Term__c
                FROM hed__Term__c
                WHERE hed__Parent_Term__c = :parentTermId
                AND RecordTypeId = :sectionRtId WITH USER_MODE
            ]) {
                sectionNameToTerm.put(sec.Section_Name__c, sec);
            }

            Map<String, Id> batchKeyToId = new Map<String, Id>();
            for (hed__Term__c b : [
                SELECT Id, Section_Name__c, Batch_Number__c, hed__Parent_Term__c ,hed__Parent_Term__r.Section_Name__c
                FROM hed__Term__c
                WHERE hed__Parent_Term__c IN :new Map<Id, hed__Term__c>(sectionNameToTerm.values()).keySet()
                AND RecordTypeId = :batchRtId WITH USER_MODE
            ]) {
                if (b.hed__Parent_Term__r.Section_Name__c != null && b.Batch_Number__c != null) {
                    String key = b.hed__Parent_Term__r.Section_Name__c + '-' + b.Batch_Number__c;
                    batchKeyToId.put(key, b.Id);
                }
            }

            Map<String, Id> groupNameToId = new Map<String, Id>();
            for (hed__Term__c g : [
                SELECT Id, Group_Number__c ,Course_Offering__r.hed__Course__c
                FROM hed__Term__c
                WHERE hed__Parent_Term__c = :parentTermId
                AND RecordTypeId = :groupRtId WITH USER_MODE
            ]) {
                if (g.Group_Number__c != null) {
                    String groupKey = String.fromCharArray(new List<Integer>{64 + g.Group_Number__c.intValue()})+ '-' + g.Course_Offering__r.hed__Course__c;
                    groupNameToId.put(groupKey, g.Id);
                }
            }

            Set<Id> courseIds = new Set<id>();
            Map<String, hed__Course_Offering__c> courseOfferingKey = new Map<String, hed__Course_Offering__c>();
            for (hed__Course_Offering__c co : [
                SELECT Id, hed__Course__c, hed__Term__c, Category__c, hed__Course__r.Name
                FROM hed__Course_Offering__c
                WHERE hed__Term__c = :parentTermId
                OR hed__Term__c IN :new Map<Id, hed__Term__c>(sectionNameToTerm.values()).keySet() WITH USER_MODE
            ]) {
                String key = co.hed__Term__c + '-' + co.hed__Course__c;
                courseOfferingKey.put(key, co);
                courseIds.add(co.hed__Course__c);
            }

            List<hed__Course_Enrollment__c> parentConnections = [
                SELECT Id, hed__Contact__c, Allotted_Section__c, Allotted_Batch_Number__c,
                       hed__Course_Offering__c, hed__Course_Offering__r.hed__Course__c,hed__Primary__c,Secondary__c,
                       hed__Course_Offering__r.Category__c, hed__Course_Offering__r.hed__Course__r.Name
                FROM hed__Course_Enrollment__c
                WHERE hed__Course_Offering__r.hed__Term__c = :parentTermId WITH USER_MODE
            ];

            if (parentConnections.isEmpty()) {
                return 'No professor course connections exist in Parent Semester.';
            }

            Set<Id> courseOfferingWithConnections = new Set<Id>();
            for (hed__Course_Enrollment__c pc : parentConnections) {
                courseOfferingWithConnections.add(pc.hed__Course_Offering__c);
            }

            Boolean hasPractical = false,
             hasProfessional = false,
             hasNormal = false;
            for (hed__Course_Enrollment__c pc : parentConnections) {
                if (pc.hed__Course_Offering__r.Category__c == 'Practical/Term work') {
                    hasPractical = true;
                } else if (pc.hed__Course_Offering__r.Category__c == 'Professional Elective') {
                    hasProfessional = true;
                } else {
                    hasNormal = true;
                }
            }

            if (hasProfessional && groupNameToId.isEmpty()) {
                return 'Professional Elective professors exist, but Groups are not created under Parent Semester.';
            }
            if (hasPractical && batchKeyToId.isEmpty()) {
                return 'Practical professors exist, but Batches are not created under Sections.';
            }
            if (hasNormal && sectionNameToTerm.isEmpty()) {
                return 'Normal course professors exist, but Sections are not created under Parent Semester.';
            }

            List<hed__Course_Enrollment__c> existingChildConnections = [
                SELECT Id,hed__Primary__c
                FROM hed__Course_Enrollment__c
                WHERE (hed__Course_Offering__r.hed__Term__c IN :new Map<Id, hed__Term__c>(sectionNameToTerm.values()).keySet()
                       OR Section__c IN :groupNameToId.values())
                AND RecordTypeId = :facultyRtId  AND hed__Course_Offering__r.hed__Course__c IN :courseIds WITH USER_MODE
            ];
            if (!existingChildConnections.isEmpty()) {
                if (Schema.sObjectType.hed__Course_Enrollment__c.isDeletable()) {
                    delete existingChildConnections;
                } else {
                    return 'Insufficient permissions to delete Course Enrollments.';
                }
            }

            List<hed__Course_Enrollment__c> newConnections = new List<hed__Course_Enrollment__c>();

            for (hed__Course_Enrollment__c parentConn : parentConnections) {
                if (parentConn.hed__Contact__c == null)
                {
                    continue;
                }

                String childKey = null;
                if (parentConn.Allotted_Section__c != null) {
                    childKey = sectionNameToTerm.containsKey(parentConn.Allotted_Section__c)
                        ? sectionNameToTerm.get(parentConn.Allotted_Section__c).Id + '-' + parentConn.hed__Course_Offering__r.hed__Course__c
                        : null;
                }
                if (childKey == null || !courseOfferingKey.containsKey(childKey))
                {
                    continue;
                }

                hed__Course_Offering__c sectionOffering = courseOfferingKey.get(childKey);
                hed__Course_Enrollment__c newConn = new hed__Course_Enrollment__c();
                newConn.Id = parentConn.Id;
                newConn.hed__Contact__c = parentConn.hed__Contact__c;
                newConn.RecordTypeId = facultyRtId;

                newConn.Allotted_Batch_Number__c = parentConn.Allotted_Batch_Number__c;
                newConn.Allotted_Section__c = parentConn.Allotted_Section__c;
                newConn.Secondary__c = parentConn.Secondary__c;
                newConn.hed__Primary__c = parentConn.hed__Primary__c;


                if (sectionOffering.Category__c == 'Practical/Term work') {
                    newConn.hed__Course_Offering__c = sectionOffering.Id;
                    if (parentConn.Allotted_Section__c != null && parentConn.Allotted_Batch_Number__c != null) {

                        String batchKey = parentConn.Allotted_Section__c + '-' + parentConn.Allotted_Batch_Number__c;
                        if (batchKeyToId.containsKey(batchKey)) {
                            newConn.Section__c = batchKeyToId.get(batchKey);
                        } else {
                            continue;
                        }
                    } else {
                        continue;
                    }
                } else if (sectionOffering.Category__c == 'Professional Elective') {
                    newConn.hed__Course_Offering__c = parentConn.hed__Course_Offering__c;
                    if (parentConn.Allotted_Section__c != null) {
                        String groupKey = parentConn.Allotted_Section__c + '-' + parentConn.hed__Course_Offering__r.hed__Course__c;
                        if (groupNameToId.containsKey(groupKey)) {
                            newConn.Section__c = groupNameToId.get(groupKey);
                        } else {
                            continue;
                        }
                    } else {
                        continue;
                    }
                } else {
                    if (sectionNameToTerm.containsKey(parentConn.Allotted_Section__c)) {
                        newConn.hed__Course_Offering__c = sectionOffering.Id;
                        newConn.Section__c = sectionNameToTerm.get(parentConn.Allotted_Section__c).Id;
                    } else {
                        continue;
                    }
                }

                newConnections.add(newConn);
            }

            if (!newConnections.isEmpty()) {
                if (Schema.sObjectType.hed__Course_Enrollment__c.isCreateable() && Schema.sObjectType.hed__Course_Enrollment__c.isUpdateable()) {
                    Database.upsert(newConnections, false);
                } else {
                    return 'Insufficient permissions to create or update Course Enrollments.';
                }

                hed__Term__c parentTerm = new hed__Term__c(Id = parentTermId);
                parentTerm.Professors_Sections_Allotted__c = true;
                if (Schema.sObjectType.hed__Term__c.isUpdateable()) {
                    update parentTerm;
                } else {
                    return 'Insufficient permissions to update Term records.';
                }


                Set<Id> usedParentConnIds = new Set<Id>();
                for (hed__Course_Enrollment__c nc : newConnections) {
                    if (nc.Id != null) {
                        usedParentConnIds.add(nc.Id);
                    }
                }

                List<hed__Course_Enrollment__c> toDelete = new List<hed__Course_Enrollment__c>();
                for (hed__Course_Enrollment__c pc : parentConnections) {
                    if (!usedParentConnIds.contains(pc.Id)) {
                        toDelete.add(new hed__Course_Enrollment__c(Id = pc.Id));
                    }
                }

                if (!toDelete.isEmpty()) {
                    delete toDelete;
                }


            }

            return 'Allocation completed At Section/Batch/Group. New connections moved : ' + newConnections.size();

        } catch (Exception e) {
            return 'Unexpected Error: ' + e.getMessage();
        }
    }
}