public class InfraApprovalSMS {
    @InvocableMethod(label='Infra Send FacilityRequest SMS Notifications' description='Infra Send notifications via SMS')
    public static void infraSMSNotification(List<String> recordIds) {
        if (recordIds != null && !recordIds.isEmpty()) { 
            makeCalloutAsync(recordIds);
            system.debug('recordIds::'+recordIds);
        } else {
            System.debug('RecordIds List is Empty');
        }
    }
    
    @Future(Callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
       
        List<Facility_Request__c> TrRegList = [SELECT Id, Name, Start_Date__c,Account__c, Start_Time__c, End_Date__c, End_Time__c, 
                                               Facility_Name__c, Building_Name__c, Additional_Amenities_Required__c, Floor__c,
                                               Room_No__c, Current_User_Name__c, Current_User_Phone__c,  RequesterName__c,
                                               Reqester_Phone_Number__c, TemplateName__c, ApprovalStatus__c, ApproverName__c, 
                                               ApproverPhoneNumber__c,ApprovalLink__c,Account__r.Name,Account__r.Id,Approver__r.Name,
                                               Approver__r.Phone,RequesterEmail__c,Email__c,Reason_of_Booking__c,Approval_Comments__c
                                               FROM Facility_Request__c WHERE Id IN :recordIds];
        Set<Id> accIds = new Set<Id>();
        Set<String> roomIds = new Set<String>();
        for(Facility_Request__c fr : TrRegList) {
            accIds.add(fr.Account__c);
            roomIds.add(fr.Room_No__c);
        }
        Map<Id, Facility_Request__c> accFacilityMap = new  Map<Id, Facility_Request__c>();
        for(Facility_Request__c fac : [
            SELECT Account__c, RequesterName__c, Reqester_Phone_Number__c,RequesterEmail__c
            FROM Facility_Request__c
            LIMIT 1
        ]) {
            accFacilityMap.put(fac.Account__c , fac);
        }
        
        if (!TrRegList.isEmpty()) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>(); // Define messageList here
            
            for (Facility_Request__c trReg : TrRegList) {
                // Determine which method to call based on TemplateName__c value
                if (trReg.TemplateName__c == 'Requested') {
                    system.debug('Requested');
                    FacilityRequest(trReg, messageList, accFacilityMap);
                } else if (trReg.TemplateName__c == 'Rejected') {
                    system.debug('Rejected');
                    FacilityRejected(trReg, messageList, accFacilityMap);
                } else if (trReg.TemplateName__c == 'Approved') {
                    system.debug('Approved');
                    FacilityApproved(trReg, messageList,accFacilityMap);
                }
            }
            
            if (!messageList.isEmpty()) {
                for (Facility_Request__c trReg : TrRegList) {
                    if (messageList.size() > 0 && trReg.TemplateName__c == 'Requested') {
                        SMS_API_Utility.SendSMSOneToMany('Infra_Approval_Request_SMS', messageList);
                    } else if (messageList.size() > 0 && trReg.TemplateName__c == 'Rejected') {
                        SMS_API_Utility.SendSMSOneToMany('Infra_Rejected_SMS', messageList);	
                    } else if (messageList.size() > 0 && trReg.TemplateName__c == 'Approved') {
                        SMS_API_Utility.SendSMSOneToMany('Infra_Approved_SMS', messageList);
                    }
                }
            }
        } else {
            System.debug('No related records found for the provided IDs');
        }
    
    }
    
    // FacilityRequest method to handle Facility Request notifications
    public static void FacilityApproved(Facility_Request__c record, List<SMS_API_Utility.shortMessageWrp> messageList,  Map<Id, Facility_Request__c> accFacilityMap) {
        List<Facility_Request__c> facilities = [
            SELECT Account__c, RequesterName__c, Reqester_Phone_Number__c,RequesterEmail__c, ApproverName__c
            FROM Facility_Request__c
            LIMIT 1
        ];
        // String phoneNumber = '';
        //String approvrName = '';
        if (!facilities.isEmpty()) {
            Facility_Request__c facility = facilities[0];
            String phoneNumber = facility.Reqester_Phone_Number__c;
            String approvrName = facility.RequesterName__c;
            //String approvrName = facility.ApproverName__c;
          //  system.debug('@@@@@@@@@@@@@@@@@@@@'+facility.ApproverName__c);
        }
        String roomName = record.Name;
        String reqName = record.RequesterName__c;
        String block = record.Building_Name__c;
        String roomNumber = record.Room_No__c;
        Facility_Request__c fac =   accFacilityMap.get(record.Account__c);
        String approvrName = record.Approver__r.Name;
        system.debug('approvrName::'+approvrName);
        String Department = record.Account__r.Name;
        Time startTime = record.Start_Time__c;
        String amPmStart = startTime.hour() >= 12 ? 'PM' : 'AM';
        Integer hourStart = Math.mod(startTime.hour(), 12) == 0 ? 12 : Math.mod(startTime.hour(), 12);
        String timeStringStart = hourStart + ':' + startTime.minute().format() + ' ' + amPmStart;
        
        Time endTime = record.End_Time__c;
        String amPmEnd = endTime.hour() >= 12 ? 'PM' : 'AM';
        Integer hourEnd = Math.mod(endTime.hour(), 12) == 0 ? 12 : Math.mod(endTime.hour(), 12);
        String timeStringEnd = hourEnd + ':' + endTime.minute().format() + ' ' + amPmEnd;
        
        String phnNumber = String.valueOf(record.Reqester_Phone_Number__c);
        String approvalLink=Label.FacilityRequestApprovalURL+ record.Id + '/view';
        
        
        //String approvalLink=record.ApprovalLink__c;
        System.debug('approvalLink: ' + approvalLink);
        // String approverName =  fac.Requester_Name__r.Name; 
        String approverName =  approvrName;// Assuming an approver name for demo
        String schoolName =  Department;
        //String schoolName = record.Account__r.Name;
        String message = 'Dear ' + reqName + '\nYour Booking request of\nBlock: ' + block + '\nRoom No: ' + roomNumber + '\nRoom Name: ' + roomName + '\nis APPROVED\nfor Period ' + timeStringStart + ' to ' + timeStringEnd + '.\nRegards\n' + approverName + '\nREVA University';
        
        
        
        // Assuming you have a method to send SMS and you pass the message and phone number
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007394442464004138';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        // shrtMessage.recipient = fac.Requester_Name__r.Phone;
        messageList.add(shrtMessage);
    }
    
    // FacilityRejected method to handle Facility Rejected notifications 
    public static void FacilityRejected(Facility_Request__c record, List<SMS_API_Utility.shortMessageWrp> messageList,  Map<Id, Facility_Request__c> accFacilityMap) {
        List<Facility_Request__c> facilities = [
            SELECT Account__c, RequesterName__c, Reqester_Phone_Number__c, RequesterEmail__c, Reason_of_Booking__c,Approval_Comments__c	
            FROM Facility_Request__c
            LIMIT 1
        ];
        // String phoneNumber = '';
        //String approvrName = '';
        if (!facilities.isEmpty()) {
            Facility_Request__c facility = facilities[0];
            String phoneNumber = facility.Reqester_Phone_Number__c;
            String approvrName = facility.RequesterName__c;
        }
        String roomName = record.Name;
        String reqName = record.RequesterName__c;
        String block = record.Building_Name__c;
        String roomNumber = record.Room_No__c;
        Facility_Request__c fac =   accFacilityMap.get(record.Account__c);
        String approvrName = record.Approver__r.Name;
        String Department = record.Account__r.Name;
        String reason = record.Approval_Comments__c;
        Time startTime = record.Start_Time__c;
        String amPmStart = startTime.hour() >= 12 ? 'PM' : 'AM';
        Integer hourStart = Math.mod(startTime.hour(), 12) == 0 ? 12 : Math.mod(startTime.hour(), 12);
        String timeStringStart = hourStart + ':' + startTime.minute().format() + ' ' + amPmStart;
        
        Time endTime = record.End_Time__c;
        String amPmEnd = endTime.hour() >= 12 ? 'PM' : 'AM';
        Integer hourEnd = Math.mod(endTime.hour(), 12) == 0 ? 12 : Math.mod(endTime.hour(), 12);
        String timeStringEnd = hourEnd + ':' + endTime.minute().format() + ' ' + amPmEnd;
        	
        String phnNumber = String.valueOf(record.Reqester_Phone_Number__c);
        String approvalLink=Label.FacilityRequestApprovalURL+ record.Id + '/view';
        
        
        //String approvalLink=record.ApprovalLink__c;
        System.debug('approvalLink: ' + approvalLink);
        // String approverName =  fac.Requester_Name__r.Name; 
        String approverName =  approvrName;// Assuming an approver name for demo
        String schoolName =  Department;
        //String schoolName = record.Account__r.Name;
       // String reason = reasonOfBooking;
        
        String message = 'Dear ' + reqName + '\nYour Booking request of\nBlock: ' + block + '\nRoom No: ' + roomNumber + '\nRoom Name: ' + roomName + '\nFor the period ' + timeStringStart + ' to ' + timeStringEnd + '\nis REJECTED due to ' + reason +'.\nRegards\n' + approverName + '\nREVA University';
        	
        
        // Assuming you have a method to send SMS and you pass the message and phone number
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007004382008236270';
        shrtMessage.message = message;
        shrtMessage.recipient = phnNumber;
        // shrtMessage.recipient = fac.Requester_Name__r.Phone;
        messageList.add(shrtMessage);
    }
    
    // FacilityApproved method to handle Facility Approved notifications
 public static void FacilityRequest(Facility_Request__c record, List<SMS_API_Utility.shortMessageWrp> messageList,  Map<Id, Facility_Request__c> accFacilityMap) {
              List<Facility_Request__c> facilities = [
        SELECT  Account__c, RequesterName__c, Reqester_Phone_Number__c,RequesterEmail__c
        FROM Facility_Request__c
       // WHERE hed__Account__c = :record.Account__c
        LIMIT 1
    ];
   // String phoneNumber = '';
    //String approvrName = '';
          if (!facilities.isEmpty()) {
            Facility_Request__c facility = facilities[0];
            String phoneNumber = facility.Reqester_Phone_Number__c;
            String approvrName = facility.RequesterName__c;
        }
    String roomName = record.Name;
    String reqName = record.RequesterName__c;
    String block = record.Building_Name__c;
    String roomNumber = record.Room_No__c;
    Facility_Request__c fac =   accFacilityMap.get(record.Account__c);
     String approvrName = record.Approver__r.Name;
     String Department = record.Account__r.Name;
    Time startTime = record.Start_Time__c;
    String amPmStart = startTime.hour() >= 12 ? 'PM' : 'AM';
    Integer hourStart = Math.mod(startTime.hour(), 12) == 0 ? 12 : Math.mod(startTime.hour(), 12);
    String timeStringStart = hourStart + ':' + startTime.minute().format() + ' ' + amPmStart;

    Time endTime = record.End_Time__c;
    String amPmEnd = endTime.hour() >= 12 ? 'PM' : 'AM';
    Integer hourEnd = Math.mod(endTime.hour(), 12) == 0 ? 12 : Math.mod(endTime.hour(), 12);
    String timeStringEnd = hourEnd + ':' + endTime.minute().format() + ' ' + amPmEnd;

  //String phnNumber = String.valueOf(record.ApproverPhoneNumber__c);
 String phnNumber = String.valueOf(record.Approver__r.Phone);
     system.debug('phnNumber'+phnNumber);
     
String approvalLink=Label.FacilityRequestApprovalURL+ record.Id + '/view';
     

   //String approvalLink=record.ApprovalLink__c;
     System.debug('approvalLink: ' + approvalLink);
   // String approverName =  fac.Requester_Name__r.Name; 
    String approverName =  approvrName;// Assuming an approver name for demo
      String schoolName =  Department;
    //String schoolName = record.Account__r.Name;
    String message = 'Dear ' + approverName + '\nKindly, approve\n'+'\nBooking of: ' + block + '\nRoom No: ' + roomNumber + '\nRoom Name: ' + roomName + '\nPeriod of ' + timeStringStart + ' to ' + timeStringEnd + '\nApproval Link: ' + approvalLink + '.\nRequested By: ' + reqName + '\nREVA University';

    // Assuming you have a method to send SMS and you pass the message and phone number
    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
    shrtMessage.dltContentId = '1007737346283460548	';
    shrtMessage.message = message;
   shrtMessage.recipient = phnNumber ;
   // shrtMessage.recipient = fac.Requester_Name__r.Phone;
    messageList.add(shrtMessage);
}

}