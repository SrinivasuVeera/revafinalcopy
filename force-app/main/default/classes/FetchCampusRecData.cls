/**
 * @description class to fetch data related to mentor mentee and support requests.
 * @author Keval | 25/11/2019
 */

 public without sharing class FetchCampusRecData {

    /**
     * @description this class is to fetch the cases with subject used in mentor and mentee component
     * @param userId String - User Id for case reference.
     * @return List<Case> - List of cases related to the user.
     */
   
    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCases() {
        try{
         RecordType rt = [SELECT Id FROM RecordType 
                         WHERE SobjectType = 'Case' 
                         AND DeveloperName = 'Mentee' 
                         LIMIT 1];
        
        string contactId=[SELECT ContactId FROM User WHERE Id=:userInfo.getUserId() Limit 1].ContactId;
        List<Case> cases = [
            SELECT Id, CaseNumber, Program_Batch__c, Mentor_Name__c, Subject,Mentor_Mobile__c, Contact.Name 
            FROM Case 
            WHERE ContactId = :contactId AND RecordTypeId=:rt.Id ORDER BY CreatedDate DESC   
        ];
        // Print fetched case in debug logs
        system.debug(cases);
        if (cases.isEmpty()) {
           return null;
        }
        return cases;
    }
    catch(Exception e){ throw new AuraHandledException('Error fetching cases:' +e.getMessage());
    }
}

    /**
     * @description Fetches support request cases related to a specific user.
     * @param userId String - User Id for support request case reference.
     * @return List<Case> - List of support request cases related to the user.
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCasesWithoutSubject() {
        try {
            RecordType rt = [SELECT Id FROM RecordType 
                             WHERE SobjectType = 'Case' 
                             AND DeveloperName = 'Support_Request' 
                             LIMIT 1];
            
            string contactId=[SELECT ContactId FROM User WHERE Id=:userInfo.getUserId() Limit 1].ContactId;
                
            List<Case> supportReqList = [
                SELECT Id, CaseNumber, Category__c, Case_Status__c, Contact.Name
                FROM Case 
                WHERE ContactId = :contactId
                AND RecordTypeId=:rt.Id ORDER BY CreatedDate DESC
            ];
            
            return supportReqList;
        } catch(Exception e) { throw new AuraHandledException('Error fetching support request cases: ' + e.getMessage());
        }
    }
     
             /**
     * @This class is to fetch contact for campus recruitment drive
     * @param userId String - User Id for contact reference.
     * @return List<Contact> - List of contacts related to the user.
     */
        @AuraEnabled(cacheable=true)
        public static List<Contact> getContacts() {
            try {
                return [SELECT Id, Name, MobilePhone, Academic_Program__c FROM Contact LIMIT 50];
            } catch(Exception e) { throw new AuraHandledException('Error in fetching contacts: ' + e.getMessage());
            }
        }
    

}