public class CaseContactController {

    public Contact contact { get; set; }
    public Case caseRecord { get; set; }
    public Integer appointmentCount { get; set; }

    public CaseContactController(ApexPages.StandardController stdController) {
        // Initialize the standard controller with Case
        caseRecord = (Case)stdController.getRecord();
        system.debug('caseRecord '+ caseRecord );
        
        // Query the Case and its related Contact
        caseRecord = [SELECT Id, CaseNumber, Description, Reason_for_C__c, ContactId 
                      FROM Case 
                      WHERE Id = :caseRecord.Id LIMIT 1];

        // Query the related Contact using Case's ContactId
        if (caseRecord.ContactId != null) {
            contact = [SELECT Id, Name, Active_Semester__r.Name ,Program_Batch__r.Name, Course__c ,SRN_Number__c 
                       FROM Contact 
                       WHERE Id = :caseRecord.ContactId 
                       LIMIT 1];
        }
        // Count the number of Manodhaara_Appointment__c records related to the Case
        AggregateResult[] results = [SELECT COUNT(Id) appointmentCount 
                                     FROM ManodhaaraAppointment__c 
                                     WHERE Case__c = :caseRecord.Id];
        if (!results.isEmpty()) {
            appointmentCount = (Integer)results[0].get('appointmentCount');
        } else {
            appointmentCount = 0;
        }
    }
}