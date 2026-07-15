/**
* @File Name : UpdateTheTotalAttendanceOfStudent.cls
* @Description : Update the attendance of each course connection
* @Author : Mahesh Gundaboina
* @Last Modified By :
* @Last Modified On : August 23, 2024
* @Modification Log : 03-09-2024
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 23, 2024 |   | Add DebugLog object to store the errors 
**/
/**
* @File Name : UpdateTheTotalAttendanceOfStudent.cls
* @Description : Update the attendance of each course connection
* @Author : Mahesh Gundaboina
* @Last Modified By :
* @Last Modified On : August 23, 2024
* @Modification Log : 03-09-2024
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 23, 2024 |   | Add DebugLog object to store the errors 
**/
public class UpdateTheTotalAttendanceOfStudent implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, hed__Contact__c, Total_Classes_Completed__c, Total_Classes_Attended__c 
            FROM hed__Course_Enrollment__c 
            WHERE Active_Connection__c = true AND hed__Contact__c != null AND LastModifiedDate = TODAY // LastModifiedDate = YESTERDAY //TODAY
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<hed__Course_Enrollment__c> scope) {
        if (scope == null || scope.isEmpty()) {
            // No records to process, exit early
            return; 
        }
        
        Map<Id, Decimal[]> contactDataMap = new Map<Id, Decimal[]>();
        Set<Id> contactIds = new Set<Id>();
        
        for (hed__Course_Enrollment__c enrollment : scope) {
            if (enrollment.hed__Contact__c != null) {
                contactIds.add(enrollment.hed__Contact__c);
            }
        }
        
        if (contactIds.isEmpty()) {
            return; 
        }
        
        List<hed__Course_Enrollment__c> courseConnections = [
            SELECT Id, hed__Contact__c, Total_Classes_Completed__c, Total_Classes_Attended__c 
            FROM hed__Course_Enrollment__c 
            WHERE hed__Contact__c IN :contactIds AND Active_Connection__c = true
        ];
        Map<Id, Decimal> totalClassesAttendedMap = new Map<Id, Decimal>();
        Map<Id, Decimal> totalClassesCompletedMap = new Map<Id, Decimal>();
        
        for (hed__Course_Enrollment__c courseConnection : courseConnections) {
            if (courseConnection.hed__Contact__c != null) {
                Decimal totalCompleted = courseConnection.Total_Classes_Completed__c != null ? courseConnection.Total_Classes_Completed__c : 0;
                Decimal totalAttended = courseConnection.Total_Classes_Attended__c != null ? courseConnection.Total_Classes_Attended__c : 0;
                
                // Update totalClassesCompletedMap
                if (totalClassesCompletedMap.containsKey(courseConnection.hed__Contact__c)) {
                    totalClassesCompletedMap.put(courseConnection.hed__Contact__c, 
                                                 totalClassesCompletedMap.get(courseConnection.hed__Contact__c) + totalCompleted);
                } else {
                    totalClassesCompletedMap.put(courseConnection.hed__Contact__c, totalCompleted);
                }
                
                // Update totalClassesAttendedMap
                if (totalClassesAttendedMap.containsKey(courseConnection.hed__Contact__c)) {
                    totalClassesAttendedMap.put(courseConnection.hed__Contact__c, 
                                                totalClassesAttendedMap.get(courseConnection.hed__Contact__c) + totalAttended);
                } else {
                    totalClassesAttendedMap.put(courseConnection.hed__Contact__c, totalAttended);
                }
            }
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        if (!totalClassesAttendedMap.isEmpty() && !totalClassesCompletedMap.isEmpty()) {
            for (Id contactId : totalClassesAttendedMap.keySet()) {
                Decimal totalCompleted = totalClassesCompletedMap.get(contactId);
                Decimal totalAttended = totalClassesAttendedMap.get(contactId);
                
                // Calculate the average attendance
                Decimal totalAvg = totalCompleted != 0 ? (totalAttended / totalCompleted) * 100 : 0;
                
                Contact contact = new Contact(Id = contactId);
                contact.Total_Average_Current_Sem_Attendance__c = totalAvg;
                contactsToUpdate.add(contact);
            }
        }
        
        // Updating the Contact List
        if (!contactsToUpdate.isEmpty()) {
            Database.SaveResult[] saveResults = Database.update(contactsToUpdate, false);
            system.debug('saveResults###' + saveResults);
            List<Debug_Log__c> debugLogs = new List<Debug_Log__c>();        
            
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    for (Database.Error error : sr.getErrors()) {
                        System.debug('Error updating contact: ' + sr.getId() + ' - ' + error.getMessage());                        
                        // Create a new DebugLog__c record to capture the error
                        Debug_Log__c debugLog = new Debug_Log__c();
                        debugLog.Class_Name__c = 'UpdateTheTotalAttendanceOfStudent: ' + sr.getId();
                        debugLog.Response__c = 'Error: ' + error.getMessage();
                        debugLogs.add(debugLog);
                    }
                }
            }
            
            if (!debugLogs.isEmpty()) {
                // Insert all DebugLog__c records at once
                insert debugLogs; 
            }
        }
       
    }
    
    public void finish(Database.BatchableContext bc) {
        // You can add any final processing here
    }
}