public with sharing class StudentVacationNOCController {
    public List<Reva_Hostel_Request__c> RevaHostelRequests { get; set; }
    public List<Contact> ConList { get; set; }

    public StudentVacationNOCController() {
       String recordId = ApexPages.currentPage().getParameters().get('RequestId');
       //string recordId = 'a2u1e000000bMSMAA2';
        System.debug('Request ID in VF page controller: ' + recordId);

        if (String.isNotBlank(recordId)) {
            RevaHostelRequests = [SELECT Id, Name, Reva_Hostel_JoiningDate__c, RevaHostelVacatingDate__c, Type__c, Hostel_Room_Request_For__c, 
                                    Block__c, Reva_Hostel_Room__c, Room_Request_for_Name__c, Room_Number__c, Status__c, 
                                    Approved_by_warden__c,Approved_by_ChiefWarden__c, Approved_by_Admin__c,Student_Fee__r.Amount_paid__c, Student_Fee__r.Amount_Pending__c, 
                                    Student_Fee__r.Amount__c FROM Reva_Hostel_Request__c WHERE Id = :recordId];

            if (!RevaHostelRequests.isEmpty()) {
                Id userId = RevaHostelRequests[0].Hostel_Room_Request_For__c;
                System.debug('Hostel Room Request For User ID: ' + userId);

                if (userId != null) {
                    User user = [SELECT ContactId FROM User WHERE ContactId = :userId LIMIT 1];
                    Id contactId = user.ContactId;

                    if (contactId != null) {
                        ConList = [SELECT Id, Student_Full_Name__c, MobilePhone, Date_of_Admission_in_Institute__c, 
                                    SRN_Number__c, Course__c FROM Contact WHERE Id = :contactId];
                        System.debug('Contact record: ' + ConList);
                    }
                }
            }
        }
    }
    
 
}