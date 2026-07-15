public with sharing class StaffVacationNOCController {
    public Staff_Quarters_Request__c staffQuarterRequests { get; set; }
    public Contact Con { get; set; }
    
    public StaffVacationNOCController() {
        // Get the record Id from the page parameter
        String recordId = ApexPages.currentPage().getParameters().get('id');
    //   String recordId = 'a3K1e000000dmFuEAI';
        System.debug('request id in vf page controller' + recordId);
        // Query the Staff_Quarters_Request__c object along with the Hostel_Room_Request_For__c field
        staffQuarterRequests = [SELECT Id, Name, Staff_Quarters_Joining_Date__c, Vacation_Date__c , Room_Request_For__c
                                FROM Staff_Quarters_Request__c
                                WHERE Id = :recordId 
                               ];
        List<String> userEmails = new List<String>();
        System.debug('staff quarter record: '+ staffQuarterRequests);
        System.debug('joining date: '+ staffQuarterRequests.Staff_Quarters_Joining_Date__c);
        System.debug('vacation date: '+ staffQuarterRequests.Vacation_Date__c);
        userEmails.add(staffQuarterRequests.Room_Request_For__c); 
        System.debug('requests.Room_Request_For__c: '+ staffQuarterRequests.Room_Request_For__c);
        System.debug('User Email: '+ userEmails);
        //  System.debug('contact id: '+ request.Room_Request_For__r.Contact);
        

        
        List<String> contactEmails = new List<String>();
            User usr = [SELECT Email, Id, ContactId  FROM User WHERE id = :staffQuarterRequests.Room_Request_For__c LIMIT 1];
        system.debug('User details:'+ usr);
            if (usr != null && usr.Email != null) {
                contactEmails.add(usr.Email);
            } 
        for(String Email: contactEmails){
            if(Email != null){
                con = [SELECT Id, Name, Department, Designation__c, Employee_Number__c, Date_of_Joining__c, hed__Gender__c, MobilePhone, hed__WorkEmail__c, Aadhar_Card_Number__c, Blood_Group__c, Email,Emergency_Contact_Number__c, OtherAddress, OtherStreet, OtherState, OtherCity, OtherPostalCode
                       FROM Contact
                       WHERE hed__WorkEmail__c = :Email];
                System.debug('Contact record: '+ con);
                System.debug('con.Name: ' + con.Name);
                System.debug('con.Designation__c: ' + con.Designation__c);
                System.debug('con.Employee_Number__c: ' + con.Employee_Number__c);
            }
        }
    }
}



/*
public with sharing class StaffVacationNOCController {
    public Staff_Quarters_Request__c staffQuarterRequests { get; set; }
    public Contact Con { get; set; }
    
    public StaffVacationNOCController() {
        // Get the record Id from the page parameter
        String recordId = ApexPages.currentPage().getParameters().get('id');
        //string recordId = 'a3K1e000000dmFuEAI';
        System.debug('request id in vf page controller' + recordId);
        // Query the Staff_Quarters_Request__c object along with the Hostel_Room_Request_For__c field
        staffQuarterRequests = [SELECT Id, Name, Staff_Quarters_Joining_Date__c, Vacation_Date__c, Type__c, Room_Request_For__c
                                FROM Staff_Quarters_Request__c
                                WHERE Id = :recordId 
                               ];
        List<id> userIds = new List<id>();
        System.debug('staff quarter record: '+ staffQuarterRequests);
        userIds.add(staffQuarterRequests.Room_Request_For__c);
        System.debug('requests.Room_Request_For__c: '+ staffQuarterRequests.Room_Request_For__c);
        System.debug('userid: '+ userIds);
        //  System.debug('contact id: '+ request.Room_Request_For__r.Contact);
        
        
        List<Id> contactIds = new List<Id>();
        for(Id users : userIds) { 
            System.debug('users id: '+ users);
            User usr = [SELECT ContactId FROM User WHERE Id =: users];
            contactIds.add(usr.Contactid);	
            System.debug('contact id in user: '+ contactIds);
        }
        for(id conId: contactIds){
            if(conId!= null){
                con = [SELECT id, Name, Designation__c, Employee_Number__c, Date_of_Joining__c, hed__Gender__c, OtherPhone, Aadhar_Card_Number__c, Blood_Group__c, Email 
                       FROM Contact
                       WHERE Id =:conId];
                System.debug('contact record: '+ con);
                System.debug('con.Name: ' + con.Name);
                System.debug('con.Designation__c: ' + con.Designation__c);
                System.debug('con.Employee_Number__c: ' + con.Employee_Number__c);
            }
        }
    }
}*/