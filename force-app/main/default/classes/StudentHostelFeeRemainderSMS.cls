public class StudentHostelFeeRemainderSMS {
     @Future(callout=true)
    public static void MainMethod(set<Id> StudentIds){
         List<SMS_API_Utility.shortMessageWrp> messageListStudent = new List<SMS_API_Utility.shortMessageWrp>();
        List<SMS_API_Utility.shortMessageWrp> messageListParent = new List<SMS_API_Utility.shortMessageWrp>();
        List<Student_Fee__C> stuFeeList= [SELECT Id, Name,Fee_for_Notifications__c, Contact__c,Contact__r.Name, Contact__r.MobilePhone, Contact__r.Email,Due_Date__c,Amount__c,
                                      Contact__r.Father_Mobile_Number__c,Contact__r.Mother_Mobile_Number__c,Amount_Paid__c,Amount_Pending__c,No_of_Days_Due__c,Number_of_days_due__c, Hostel_Due_Date__c From Student_Fee__c where Id IN:StudentIds ];
       
        system.debug('stuFeeList' +stuFeeList);
                // Separate records based on due days
        List<Student_Fee__c> reminderList   = new List<Student_Fee__c>();
        List<Student_Fee__c> feeDueList     = new List<Student_Fee__c>();
        List<Student_Fee__c> blockedList    = new List<Student_Fee__c>();

        for (Student_Fee__c fee : stuFeeList) {
            system.debug('stuFeeList' +fee.id);
            if (fee.Number_of_days_due__c != null) {
                if (fee.Number_of_days_due__c  >= -15 && fee.Number_of_days_due__c <= 0) {
                    reminderList.add(fee); // Early reminder
                    system.debug('Early reminder');
                } else if (fee.Number_of_days_due__c >= 1 && fee.Number_of_days_due__c <= 60) {
                    feeDueList.add(fee); // Fee due warning
                    system.debug(' Fee due warning'+feeDueList);
                } else if (fee.Number_of_days_due__c > 60) {
                    blockedList.add(fee); // Block notice
                    system.debug('Block notice');
                }
            }
        }

        // Call your prepared methods
        if (!reminderList.isEmpty()) {
            sendReminderSMS(reminderList,messageListStudent);
            sendReminderSMSParent(reminderList,messageListParent);
            system.debug('messageListStudent:'+messageListStudent);
            system.debug('messageListParent:'+messageListParent);
             if (!messageListStudent.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('HostelFeeReminderStudent', messageListStudent); 
                }
             if (!messageListParent.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('HostelfeeReminderParent', messageListParent); 
                }
        }
        if (!feeDueList.isEmpty()) {
            sendFeeDueSMS(feeDueList,messageListStudent);
             sendFeeDueSMSParent(feeDueList,messageListParent);
            system.debug('messageListStudent:'+messageListStudent);
            system.debug('messageListParent:'+messageListParent);
            if (!messageListStudent.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('HostelFeeDueStudent', messageListStudent);   
                }
             if (!messageListParent.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('HostelFeeDueParent', messageListParent);   
                }
        }
        if (!blockedList.isEmpty()) {
            sendBlockedSMS(blockedList,messageListStudent);
             sendBlockedSMSParent(blockedList,messageListParent);
            system.debug('messageListStudent:'+messageListStudent);
            system.debug('messageListParent:'+messageListParent);
           if (!messageListStudent.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('HostelmealBlockedStudent', messageListStudent);   
                }
             if (!messageListParent.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('HostelmealBlockedParent', messageListParent);   
                }
        }

        
    }
    public static void sendReminderSMS(List<Student_Fee__c> reminderList, List<SMS_API_Utility.shortMessageWrp> messageListStudent) {
       
        for (Student_Fee__c fee : reminderList) {
            String message = 'Dear ' + fee.Contact__r.Name + ', Your hostel fee is due by ' + fee.Hostel_Due_Date__c.format() +
                '. Please make the payment on time to avoid penalties. Pending Amount: ' + fee.Amount_Pending__c + ' REVA University';
            SMS_API_Utility.shortMessageWrp sms = new SMS_API_Utility.shortMessageWrp();
            sms.dltContentId = '1007631509231810000'; // Example DLT template ID
            sms.message = message;
            sms.recipient = fee.Contact__r.MobilePhone;
            messageListStudent.add(sms);
        }
    }
    public static void sendFeeDueSMS(List<Student_Fee__c> feeDueList, List<SMS_API_Utility.shortMessageWrp> messageListStudent) {
          system.debug('Fee due warning: '+feeDueList);
       for (Student_Fee__c fee : feeDueList) {
            String message = 'Dear ' + fee.Contact__r.Name + ', Your Hostel fee is overdue since ' + fee.Hostel_Due_Date__c.format() +
                '. Kindly pay the fee immediately to avoid further penalties. Pending Amount: ' + fee.Amount_Pending__c +
                ' Fine Amount: '+ fee.Fee_for_Notifications__c + ' Regards, REVA University';
            SMS_API_Utility.shortMessageWrp sms = new SMS_API_Utility.shortMessageWrp();
            sms.dltContentId = '1007020020598622443'; // Example DLT template ID
            sms.message = message;
            sms.recipient = fee.Contact__r.MobilePhone;
            messageListStudent.add(sms);
        }
    }
    
    public static void sendBlockedSMS(List<Student_Fee__c> blockedList, List<SMS_API_Utility.shortMessageWrp> messageListStudent) {
        
        for (Student_Fee__c fee : blockedList) {
            String message = 'Dear ' + fee.Contact__r.Name + ', Your Hostel fee is overdue by more than 120 days. Meal booking access has been temporarily disabled until the balance is cleared. Pending Amount: ' + fee.Amount_Pending__c +
                ' Fine Amount: '+ fee.Fee_for_Notifications__c + ' Regards, REVA University';
            SMS_API_Utility.shortMessageWrp sms = new SMS_API_Utility.shortMessageWrp();
            sms.dltContentId = '1007489329233615964'; // Example DLT template ID
            sms.message = message;
            sms.recipient = fee.Contact__r.MobilePhone;
            messageListStudent.add(sms);
        }
    }
    
    
     public static void sendReminderSMSParent(List<Student_Fee__c> reminderList, List<SMS_API_Utility.shortMessageWrp> messageListParent) {
        system.debug('messageListParent:'+reminderList);
        for (Student_Fee__c fee : reminderList) {
            String message = 'Dear Parent, Your wards hostel fee is due by ' + fee.Hostel_Due_Date__c.format() +
                '. Please ensure the payment is made on time to avoid penalty charges. Pending Amount: ' + fee.Amount_Pending__c + ' REVA University';
            SMS_API_Utility.shortMessageWrp sms = new SMS_API_Utility.shortMessageWrp();
            sms.dltContentId = '1007227655296967460'; // Example DLT template ID
            sms.message = message;
            sms.recipient = fee.Contact__r.Father_Mobile_Number__c;
            messageListParent.add(sms);
        }
    }
    public static void sendFeeDueSMSParent(List<Student_Fee__c> feeDueList, List<SMS_API_Utility.shortMessageWrp> messageListParent) {
        system.debug('messageListParent:'+feeDueList);
        for (Student_Fee__c fee : feeDueList) {
            String message = 'Dear Parent, Your wards hostel fee is overdue since ' + fee.Hostel_Due_Date__c.format() +
                '. Please ensure the fee is paid immediately. Pending Amount: ' + fee.Amount_Pending__c + ' Fine Amount : ' + fee.Fee_for_Notifications__c +  ' Regards, REVA University';
            SMS_API_Utility.shortMessageWrp sms = new SMS_API_Utility.shortMessageWrp();
            sms.dltContentId = '1007680972592123538'; // Example DLT template ID
            sms.message = message;
            sms.recipient = fee.Contact__r.Father_Mobile_Number__c;
            messageListParent.add(sms);
        }
    }
    
    public static void sendBlockedSMSParent(List<Student_Fee__c> blockedList, List<SMS_API_Utility.shortMessageWrp> messageListParent) {
        
        for (Student_Fee__c fee : blockedList) {
            String message = 'Dear Parent, Your wards hostel fee is overdue by more than 120 days. Meal booking has been disabled until the fee is cleared. Pending Amount:' + fee.Amount_Pending__c +
                ' Fine: '+ fee.Fee_for_Notifications__c + ' Regards REVA University';
            SMS_API_Utility.shortMessageWrp sms = new SMS_API_Utility.shortMessageWrp();
            sms.dltContentId = '1007441787008051622'; // Example DLT template ID
            sms.message = message;
            sms.recipient = fee.Contact__r.Father_Mobile_Number__c;
            messageListParent.add(sms);
        }
    }
    
}