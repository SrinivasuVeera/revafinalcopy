public class StudentPaymentTriggerEmailHandler {
    public static String strSubject = '';
    public static String strHtmlBody = '';
    public static void sendEmail(Set<Id> paymentIds) {
       List<Student_Payment__c> paymentList = [SELECT Id, Contact__r.Email, Fee_Type__c, Contact__r.Father_Email_ID__c, Contact__r.Student_Full_Name__c, Payment_Mode_Type__c,
                                                Contact__r.RH_Current_Pursuing_Year_of_Student__c, Contact__r.Student_Personal_Email__c,Reference_Number__c,Amount__c FROM Student_Payment__c WHERE Fee_Type__c ='Hostel Fee' AND Id IN: paymentIds];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress objOWEA = [select Id from OrgWideEmailAddress where Address = 'alerts@reva.edu.in' LIMIT 1];
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue,DeveloperName, Body from EmailTemplate where DeveloperName = 'HOSTEL_Successful_Payment_Notification_Template' LIMIT 1];
        for (Student_Payment__c objRec : paymentList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            if (String.isNotBlank(objRec.Contact__r.Email)) {
                toAddresses.add(objRec.Contact__r.Email);
            }
            if (String.isNotBlank(objRec.Contact__r.Father_Email_ID__c)) {
                toAddresses.add(objRec.Contact__r.Father_Email_ID__c);
            }
            if (!toAddresses.isEmpty()) {
                mail.setToAddresses(toAddresses);
                mail.setOrgWideEmailAddressId(objOWEA.Id);
                mail.setSaveAsActivity(true);
                mail.setWhatId(objRec.Id);
                strSubject = emailTemplate.Subject;
                strHtmlBody = emailTemplate.HtmlValue;
                if (String.isNotBlank(strHtmlBody)) {
                    strHtmlBody = strHtmlBody.replace('[Students Name]', validateString(String.valueOf(objRec.Contact__r.Student_Full_Name__c)));
					//strHtmlBody = strHtmlBody.replace('[Students Class]', validateString(String.valueOf(objRec.Contact__r.Student_Full_Name__c)));
					//strHtmlBody = strHtmlBody.replace('[Students Study Stream]', validateString(String.valueOf(objRec.Contact__r.Student_Full_Name__c)));
					//strHtmlBody = strHtmlBody.replace('[Room Number]', validateString(String.valueOf(objRec.Contact__r.Student_Full_Name__c)));
					//strHtmlBody = strHtmlBody.replace('[Floor]', validateString(String.valueOf(objRec.Contact__r.Student_Full_Name__c)));
					//strHtmlBody = strHtmlBody.replace('[Block]', validateString(String.valueOf(objRec.Contact__r.Student_Full_Name__c)));
					strHtmlBody = strHtmlBody.replace('[Year of Study]', validateString(String.valueOf(objRec.Contact__r.RH_Current_Pursuing_Year_of_Student__c)));
                    strHtmlBody = strHtmlBody.replace('[Payment Iteration Number]', validateString(String.valueOf(objRec.Reference_Number__c)));
                    strHtmlBody = strHtmlBody.replace('[Payment Type]', validateString(String.valueOf(objRec.Payment_Mode_Type__c)));
                    strHtmlBody = strHtmlBody.replace('[Amount (in words)]', validateString(String.valueOf(objRec.Amount__c)));
                    strHtmlBody = strHtmlBody.replace('[Amount (in numbers)]', String.valueOf(objRec.Amount__c));
                }
                mail.setSubject(strSubject);
                mail.setHtmlBody(strHtmlBody);
                emailList.add(mail);
            }
            if (!emailList.isEmpty()) {
                try {
                  //  List<Messaging.SendEmailResult> emailRes = Messaging.sendEmail(emailList);
                } catch (Exception ex) {
                    
                }
            }
        }
    }
    
    public static String validateString(String data) {
        return String.isNotBlank(data) ? data : '';
    }
    
    public static void HostelRoomRequestUpdate(List<Student_Payment__c> studentFeePaymentList){
        Set<Id> contacts = new Set<Id>();
        for (Student_Payment__c studentPayment : studentFeePaymentList) {
            contacts.add(studentPayment.Contact__c);
        }
        Boolean updateRecordFlag = false;
        // 1st Year Student will get room allocation once they reach hostel and hostel office enters joining date. 
        List<Reva_Hostel_Request__c> Reva_Hostel_Requests = [Select Hostel_Room_Request_For__c, Reva_Hostel_Premium_Room__c, Type__c, Room_Request_Type__c, Status__c from Reva_Hostel_Request__c where Hostel_Room_Request_For__c IN: contacts AND Hostel_Room_Request_For__r.RH_Current_Pursuing_Year_of_Student__c != '1st Year'];
         System.debug('roomRequestStatus :::: '+Reva_Hostel_Requests);
        for (Student_Payment__c studentPayment : studentFeePaymentList) {
            if (studentPayment.Fee_Type__c.contains('Hostel Fee') && studentPayment.Payment_Status__c == 'Success'){
               
                for (Reva_Hostel_Request__c revaHostelRequest:  Reva_Hostel_Requests) {
                    Map<String,String> roomRequestStatus = new Map<String,String>();
                      System.debug('roomRequestStatus :::: '+revaHostelRequest.Hostel_Room_Request_For__c);
                       System.debug('roomRequestStatus :::: '+revaHostelRequest.Type__c); 
                    System.debug('roomRequestStatus :::: '+revaHostelRequest.Reva_Hostel_Premium_Room__c);
                    List<Contact> contactDetails = RevaHostelRequestAndAllotment.getContactDetails(revaHostelRequest.Hostel_Room_Request_For__c);
                    /*roomRequestStatus = RevaHostelRequestAndAllotment.RevaHostelRoomAllotment(revaHostelRequest.Hostel_Room_Request_For__c, 
                                                                                              revaHostelRequest.Type__c, 
                                                                                              revaHostelRequest.Reva_Hostel_Premium_Room__c,
                                                                                             System.today()); */

                 List<Reva_Hostel_Room__c> availableRooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability(revaHostelRequest.Type__c,'Student',contactDetails[Constants.baseIndex],revaHostelRequest.Reva_Hostel_Premium_Room__c);
                    System.debug('availableRooms :::: '+availableRooms);
                     System.debug('roomRequestStatus :::: '+revaHostelRequest.Status__c);
                    if (revaHostelRequest.Status__c == 'Booked') {
                        if (availableRooms.size()>0) {
                            revaHostelRequest.Reva_Hostel_Room__c  = availableRooms[Constants.baseIndex].Id;
                        	revaHostelRequest.Status__c = 'Room Allotted';
                            updateRecordFlag = true;
                        } else {
                            
                           revaHostelRequest.addError('Rooms are not available for selected category');
                            
                        }
                    }
                }
            }
        }
        if (updateRecordFlag) {
            update Reva_Hostel_Requests;
        }
    }
    
}