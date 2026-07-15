public without sharing class Eventhallcanclenotification {

    public static void sendAll(Id requestId) {

        Facility_Request__c req = [
            SELECT Id, Name, Start_Date__c, End_Date__c,
                   Start_Time__c, End_Time__c,Requester__c,
                   Facility__r.Name,Requester_Email__c, RequesterName__c, Requester_Phone__c,
                   Reason_of_Cancelation__c,Approver_Email__c, Approver_Name__c, Approver_phone__c,
                   CreatedBy.Name, CreatedBy.Email, CreatedBy.MobilePhone,
                  Approver__c, Approver__r.Name, Approver__r.Email, Approver__r.MobilePhone
            FROM Facility_Request__c
            WHERE Id = :requestId
        ];
        if (req.Reason_of_Cancelation__c != null) {
        FacilityRequestCancellationController.sendCancellationEmails(req);
        FacilityRequestCancellationController.sendWhatsAppNotifications(req);
        }
    }
    
}