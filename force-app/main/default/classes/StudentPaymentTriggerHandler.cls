public without sharing class StudentPaymentTriggerHandler {
    Private Static final String SMS_TYPE = 'Application_Number';
    Private Static final String SMS_TYPE1 = 'Reset_Password_for_Application_Portal';
    Private static final String APPLICATION_FEE_TYPE = 'Application Fee';
    
    public static void handlePaymentUpdates(List<Student_Payment__c> stuPaymentsNew , Map<Id,Student_Payment__c> stuPaymentOldMap){
        System.debug('inside StudentPaymentTriggerHandler');
        System.debug('stuPaymentsNew '+stuPaymentsNew);
        List<Student_Payment__c> razorPayApplicationFeeRecords = new List<Student_Payment__c>();
        List<Student_Payment__c> billDeskApplicationFeeRecords = new List<Student_Payment__c>();
        List<Student_Payment__c> razorPayPAFUpdaterecords = new List<Student_Payment__c>();
        List<Student_Payment__c> billDeskPAFUpdaterecords = new List<Student_Payment__c>();
        List<Contact> razorPayApplicationFeeUpdatedContacts = new List<Contact>();
        List<Contact> billdeskApplicationFeeUpdatedContacts = new List<Contact>();
        List<Student_Payment__c> paytmApplicationFeeRecords = new List<Student_Payment__c>();
        List<Student_Payment__c> paytmPAFUpdaterecords = new List<Student_Payment__c>();
        List<Contact> paytmApplicationFeeUpdatedContacts = new List<Contact>();
        List<Student_Payment__c> eazypayApplicationFeeRecords = new List<Student_Payment__c>();
        List<Student_Payment__c> eazypayPAFUpdaterecords = new List<Student_Payment__c>();
        List<Contact> eazypayApplicationFeeUpdatedContacts = new List<Contact>();
        
        List<Student_Payment__c> razorPayDCETUpdaterecords = new List<Student_Payment__c>();
        List<Student_Payment__c> billDeskDCETUpdaterecords = new List<Student_Payment__c>();
		List<Student_Payment__c> paytmDCETUpdaterecords = new List<Student_Payment__c>();
		List<Student_Payment__c> eazypayDCETUpdaterecords = new List<Student_Payment__c>();
        
        Set<string> applicationIds = new Set<string>();
        Set<Id> studentFeeIds = new Set<Id>();
        Set<Id> stupayPendingContactSet = new Set<Id>();
        Set<Id> stupaySuccessContactSet = new Set<Id>();
        Set<Id> stupayFailedContactSet = new Set<Id>();
        Set<Id> stupayPendingSet = new Set<Id>();        
        Set<Id> stupaySuccessSet = new Set<Id>();  
        Set<Id> stupayFailedSet = new Set<Id>(); 
        Set<Id> stupayApplicationFeeSet = new Set<Id>(); 
        Set<Id> stupayApplicationFeeSuccessContactSet = new Set<Id>();     
        hed__Application__c appl = new hed__Application__c();
        Student_Fee__c sf = new Student_Fee__c();
        Student_Fee__c sfSecond = new Student_Fee__c();
        Set<Id> stuPayIds = new Set<Id>();
        for(Student_Payment__c sp : stuPaymentsNew){
            stuPayIds.add(sp.Id);
        }
        list<student_payment__c> ls = [select id,Amount__c, Contact__r.Application_Fee_Paid__C,contact__r.Admission_Mode__c,
                                       Contact__r.Application_Number__c,contact__c,Payment_Gateway__c,Payment_Status__c,
                                       Fee_Type__c,Mode_of_Payment__c from Student_payment__c where id IN :stuPayIds];
        
        for(Student_Payment__c sp : ls){
            applicationIds.add(sp.Contact__r.Application_Number__c);
            studentFeeIds.add(sp.contact__c);
            // if(sp.Mode_of_Payment__c == 'Online'){
            //     if(sp.Fee_Type__c != 'Application Fee'){
                if(sp.Payment_Status__c == 'Pending' && sp.Mode_of_Payment__c == 'Online' &&
                   	   (stuPaymentOldMap == null || (stuPaymentOldMap != null &&
                       (sp.Amount__c != stuPaymentOldMap.get(sp.Id).Amount__c ||
                        sp.Payment_Status__c != stuPaymentOldMap.get(sp.Id).Payment_Status__c)))){
                            System.debug('sp.contact__c' + sp.contact__c);
                    stupayPendingContactSet.add(sp.contact__c);
                    stupayPendingSet.add(sp.Id);
                    System.debug('stupayPendingContactSet' + stupayPendingContactSet);
                    System.debug('stupayPendingSet' + stupayPendingSet);
                } if(sp.Payment_Status__c != null && sp.Fee_Type__c != null && (sp.Fee_Type__c.contains('University Fee') || sp.Fee_Type__c.contains('Tuition Fee')) && sp.Payment_Status__c == 'Failed' && (stuPaymentOldMap == null || (stuPaymentOldMap != null && (sp.Amount__c != stuPaymentOldMap.get(sp.Id).Amount__c || sp.Payment_Status__c != stuPaymentOldMap.get(sp.Id).Payment_Status__c)))){
                    stupayFailedContactSet.add(sp.contact__c);
                    stupayFailedSet.add(sp.Id);
                } 
                    // else if(sp.Payment_Status__c == 'Success'){
                    //     stupaySuccessContactSet.add(sp.contact__c);
                    //     stupaySuccessSet.add(sp.Id);
                    // }
                // } 
                // else if(sp.Payment_Status__c == 'Success') {
                //     stupayApplicationFeeSet.add(sp.Id);
                //     stupayApplicationFeeSuccessContactSet.add(sp.contact__c);
                // }

            // }
            if(sp.Payment_Status__c != null && sp.Fee_Type__c != null &&
               		(sp.Fee_Type__c.contains('University Fee') || sp.Fee_Type__c.contains('Tuition Fee') || sp.Fee_Type__c.contains('Transportation Fee')) &&
               		sp.Payment_Status__c == 'Success'
               		&& (stuPaymentOldMap == null || (stuPaymentOldMap != null
               		&& (sp.Amount__c != stuPaymentOldMap.get(sp.Id).Amount__c || 
                        sp.Payment_Status__c != stuPaymentOldMap.get(sp.Id).Payment_Status__c)))) {
                stupaySuccessContactSet.add(sp.contact__c);
                stupaySuccessSet.add(sp.Id);
            }
        }
        // //to send whatsapp and sms notification when counselor entered amount by online mode
        if(stupayPendingContactSet.size() > 0){
            System.debug('before calling sms and whatsapp');
            callsendSMSAndWhatstapp(stupayPendingContactSet,stupayPendingSet,'Pending');
        } else {
            System.debug('stupayPendingContactSet id is empty');
        }
        // //to send whatsapp and sms notification when counselor entered amount by online mode
        if(stupaySuccessContactSet.size() > 0){
            System.debug('before calling sms and whatsapp');
            callsendSMSAndWhatstapp(stupaySuccessContactSet,stupaySuccessSet,'Success');
        } else {
            System.debug('stupaySuccessContactSet id is empty');
        }
         if(stupayFailedContactSet.size() > 0){
            System.debug('before calling sms and whatsapp');
            callsendSMSAndWhatstapp(stupayFailedContactSet,stupayFailedSet,'Failed');
        } else {
            System.debug('stupayFailedContactSet id is empty');
        }
        if(stupayApplicationFeeSuccessContactSet.size() > 0){
            System.debug('stupayApplicationFeeSuccessContactSet is -->'+stupayApplicationFeeSuccessContactSet);
        } else {
            System.debug('stupayApplicationFeeSuccessContactSet size is empty');
        }
        // if(stupayApplicationFeeSet.size() > 0){
        //     System.debug('before calling sms and whatsapp');
        //     callsendSMSAndWhatstapp(stupayApplicationFeeSuccessContactSet,stupayApplicationFeeSet,'Success');
        // } else {
        //     System.debug('stupayApplicationFeeSet id is empty');
        // }
        Map<String, hed__Application__c> applications = new Map<string, hed__Application__c>();
        Map<Id, Student_Fee__c> studentFees = new Map<Id, Student_Fee__c>();
         Map<Id, Student_Fee__c> studentFeesSecond = new Map<Id, Student_Fee__c>();
        for (hed__Application__c app : [SELECT id,Concession_Status__c, Provisional_Admission_Fee_Paid__c, Application_Number__c FROM hed__Application__c WHERE Application_Number__c IN :applicationIds]) {
            applications.put(app.Application_Number__c, app);
            
        } 
        for (Student_Fee__c sp : [SELECT id, contact__c, fee_year__c
                                  FROM student_fee__c 
                                  WHERE contact__c IN :studentFeeIds 
                                  and fee_year__c=: '1st Year' ]) {
            studentFees.put(sp.Contact__c, sp);
                       
        }
        for (Student_Fee__c spSec : [SELECT id, contact__c,contact__r.Admission_Mode__c, fee_year__c 
                                     FROM student_fee__c
                                     WHERE contact__c IN :studentFeeIds 
                                     and fee_year__c=: '2nd Year']) {
            studentFeesSecond.put(spSec.Contact__c, spSec);
            
        } 
        
        for(Student_Payment__c sp : ls){
            
            if(!applications.isEmpty()){
                appl = applications.get(sp.Contact__r.Application_Number__c);
                if(!studentFees.isEmpty()){
                    sf = studentFees.get(sp.contact__c);
                    
                 }
                if(!studentFeesSecond.isEmpty()){
                    sfSecond = studentFeesSecond.get(sp.contact__c);
                }
             }
            
            if(sp.Payment_Gateway__c == 'RazorPay' && sp.Payment_Status__c == 'Success' && stuPaymentOldMap != null && 
               stuPaymentOldMap.get(sp.Id).payment_status__c == 'Payment Link Created' && 
               sp.Contact__r.Application_Fee_Paid__C == false && sp.Fee_Type__c == 'Application Fee' ){
                   
                   razorPayApplicationFeeRecords.add(sp);
               }
            
            
            
            if(sp.Payment_Gateway__c == 'RazorPay' && sp.Payment_Status__c == 'Success' && sp.Contact__r.Application_Fee_Paid__C == true && 
               sp.Fee_Type__c != 'Application Fee' && sp.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false && sf.fee_year__c == '1st Year'){
                    // mode of payment -- online
                   razorPayPAFUpdaterecords.add(sp);
               } 
            
            // DCET Applicant PAF paid
            if(sp.Payment_Gateway__c == 'RazorPay' && sp.Payment_Status__c == 'Success' && sp.Contact__r.Application_Fee_Paid__C == true && 
               sp.Fee_Type__c != 'Application Fee' && sp.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false &&
               sfSecond.fee_year__c == '2nd Year' && sfSecond.contact__r.Admission_Mode__c == 'DCET'){
                    // mode of payment -- online
                   razorPayDCETUpdaterecords.add(sp);
               } 
            
            if(sp.Payment_Gateway__c == 'Billdesk'  && stuPaymentOldMap != null && ((sp.Payment_Status__c == 'Success' && stuPaymentOldMap.get(sp.Id).payment_status__c == 'Payment Link Created') 
                                                        || (sp.Payment_Status__c == 'Success' && stuPaymentOldMap.get(sp.Id).payment_status__c == 'Pending')) && 
               sp.Contact__r.Application_Fee_Paid__C == false && sp.Fee_Type__c == 'Application Fee'){
                   
                   billDeskApplicationFeeRecords.add(sp);
               }
            System.debug('line 144 '+sp);
            if(sp.Payment_Gateway__c == 'Billdesk' && sp.Payment_Status__c == 'Success' && sp.Contact__r.Application_Fee_Paid__C == true && 
               sp.Fee_Type__c != 'Application Fee' && sp.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false && sf.fee_year__c == '1st Year'){
                    // mode of payment -- online
                   billDeskPAFUpdaterecords.add(sp);
               } 
            
             // DCET Applicant PAF paid
            if(sp.Payment_Gateway__c == 'Billdesk' && sp.Payment_Status__c == 'Success' && sp.Contact__r.Application_Fee_Paid__C == true && 
               sp.Fee_Type__c != 'Application Fee' && sp.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false &&
               sfSecond.fee_year__c == '2nd Year' && sfSecond.contact__r.Admission_Mode__c == 'DCET'){
                    // mode of payment -- online
                  
                   billDeskDCETUpdaterecords.add(sp);
               } 
            
            if(sp.Payment_Gateway__c == 'Paytm'  && stuPaymentOldMap != null && ((sp.Payment_Status__c == 'Success' && stuPaymentOldMap.get(sp.Id).payment_status__c == 'Payment Link Created') 
                                                        || (sp.Payment_Status__c == 'Success' && stuPaymentOldMap.get(sp.Id).payment_status__c == 'Pending')) && 
               sp.Contact__r.Application_Fee_Paid__C == false && sp.Fee_Type__c == 'Application Fee'){
                   
                   paytmApplicationFeeRecords.add(sp);
               }
            
            if(sp.Payment_Gateway__c == 'Paytm' && sp.Payment_Status__c == 'Success' && sp.Contact__r.Application_Fee_Paid__C == true && 
               sp.Fee_Type__c != 'Application Fee' && sp.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false && sf.fee_year__c == '1st Year'){
                    // mode of payment -- online
                   paytmPAFUpdaterecords.add(sp);
               } 
            
             // DCET Applicant PAF paid
             if(sp.Payment_Gateway__c == 'Paytm' && sp.Payment_Status__c == 'Success' && sp.Contact__r.Application_Fee_Paid__C == true && 
               sp.Fee_Type__c != 'Application Fee' && sp.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false &&
                sfSecond.fee_year__c == '2nd Year' && sfSecond.contact__r.Admission_Mode__c == 'DCET'){
                    // mode of payment -- online
                   paytmDCETUpdaterecords.add(sp);
               } 
            
            if(sp.Payment_Gateway__c == 'Eazypay'  && stuPaymentOldMap != null && ((sp.Payment_Status__c == 'Success' && stuPaymentOldMap.get(sp.Id).payment_status__c == 'Payment Link Created') 
                                                        || (sp.Payment_Status__c == 'Success' && stuPaymentOldMap.get(sp.Id).payment_status__c == 'Pending')) && 
               sp.Contact__r.Application_Fee_Paid__C == false && sp.Fee_Type__c == 'Application Fee'){
                  
                   eazypayApplicationFeeRecords.add(sp);
               }
            
            if(sp.Payment_Gateway__c == 'Eazypay' && sp.Payment_Status__c == 'Success' && sp.Contact__r.Application_Fee_Paid__C == true && 
               sp.Fee_Type__c != 'Application Fee' && sp.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false && sf.fee_year__c == '1st Year'){
                    // mode of payment -- online
                    
                   eazypayPAFUpdaterecords.add(sp);
               } 
            
             // DCET Applicant PAF paid
             if(sp.Payment_Gateway__c == 'Eazypay' && sp.Payment_Status__c == 'Success' && sp.Contact__r.Application_Fee_Paid__C == true && 
               sp.Fee_Type__c != 'Application Fee' && sp.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false
                && sfSecond.fee_year__c == '2nd Year' && sfSecond.contact__r.Admission_Mode__c == 'DCET'){
                    // mode of payment -- online
                    
                   eazypayDCETUpdaterecords.add(sp);
               }
            
        }
        
        
        //4 methods passing razorPayApplicationFeeRecords
        if ( razorPayApplicationFeeRecords.size() > 0 ) {
            razorPayApplicationFeeUpdatedContacts =  updateApplicationFeeStatus(razorPayApplicationFeeRecords);
            System.debug('before calling sendapplication number');
            sendApplicationNumber(razorPayApplicationFeeUpdatedContacts,stupayApplicationFeeSuccessContactSet);
            updateCouponCount(razorPayApplicationFeeUpdatedContacts);
            
        }
        
        
        
        //4 methods passing billDeskApplicationFeeRecords
        if(billDeskApplicationFeeRecords.size() > 0){
            billdeskApplicationFeeUpdatedContacts = updateApplicationFeeStatus(billDeskApplicationFeeRecords);
            if(!system.isBatch()){
                System.debug('before calling sendapplication number');
                sendApplicationNumber(billdeskApplicationFeeUpdatedContacts,stupayApplicationFeeSuccessContactSet);
            }
            updateCouponCount(billdeskApplicationFeeUpdatedContacts);
        }
        //4 methods passing PaytmApplicationFeeRecords
        if ( PaytmApplicationFeeRecords.size() > 0 ) {
            PaytmApplicationFeeUpdatedContacts =  updateApplicationFeeStatus(PaytmApplicationFeeRecords);
            System.debug('before calling sendapplication number');
            sendApplicationNumber(PaytmApplicationFeeUpdatedContacts,stupayApplicationFeeSuccessContactSet);
            updateCouponCount(PaytmApplicationFeeUpdatedContacts);
            
        }
        
         //4 methods passing EazypayApplicationFeeRecords
        if ( eazypayApplicationFeeRecords.size() > 0 ) {
            eazypayApplicationFeeUpdatedContacts =  updateApplicationFeeStatus(eazypayApplicationFeeRecords);
            System.debug('before calling sendapplication number');
            sendApplicationNumber(eazypayApplicationFeeUpdatedContacts,stupayApplicationFeeSuccessContactSet);
            updateCouponCount(eazypayApplicationFeeUpdatedContacts);
            
        }
        
        // Update PAF in Application not DCET Applicant
        if(razorPayPAFUpdaterecords.size() > 0){
            updateProvAdmissionFee(razorPayPAFUpdaterecords);
        }
        if(billDeskPAFUpdaterecords.size() > 0){
            updateProvAdmissionFee(billDeskPAFUpdaterecords);
        }
        if(paytmPAFUpdaterecords.size()> 0){
            System.debug('before calling PAF amount fee update');
            updateProvAdmissionFee(paytmPAFUpdaterecords);
        }
         if(eazypayPAFUpdaterecords.size()> 0){
            updateProvAdmissionFee(eazypayPAFUpdaterecords);
        }
        
        // Update PAF in Application on DCET Applicants
        if(razorPayDCETUpdaterecords.size() > 0){
            updateProvAdmissionFee(razorPayDCETUpdaterecords);
        }
        if(billDeskDCETUpdaterecords.size() > 0){
            updateProvAdmissionFee(billDeskDCETUpdaterecords);
        }
        if(paytmDCETUpdaterecords.size()> 0){
            updateProvAdmissionFee(paytmDCETUpdaterecords);
        }
         if(eazypayDCETUpdaterecords.size()> 0){
            updateProvAdmissionFee(eazypayDCETUpdaterecords);
        }
    }
    
    public static void callsendSMSAndWhatstapp(Set<Id> conIdSet,Set<Id> stuPaySet, String category){
        System.debug('collecting contact records');
        Map<Id,Boolean> PAFFullPaidMap = calculatePAFPaidAmount(conIdSet);
        Map<String,Id> profileMap = new Map<String,Id>();
        for(Profile p : [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN ('Counselor','RO Profile','Admissions Profile','Admission Team Lead')
        ]){
            profileMap.put(p.Name, p.Id);
        }
        List<Contact> conListPAFPartialPaid = new List<Contact>();
        List<Contact> conList = new List<Contact>();
        Set<Id> conIdSetToSendNotificationLater = new Set<Id>();        
        System.debug('PAFFullPaidMap '+PAFFullPaidMap);
          System.debug('category '+category);
        // Map<Id,Boolean> PAFPaidMap = new Map<Id,Boolean>();
        // for(hed__Application__c app : [SELECT Id, Name, hed__Applicant__c, Offline_Payment_Initiated__c, Provisional_Admission_Fee_Paid__c FROM hed__Application__c WHERE hed__Applicant__c =: conIdSet]){
        //     PAFPaidMap.put(app.hed__Applicant__c,app.Provisional_Admission_Fee_Paid__c);
        // }
        List<Contact> contacts = [
        SELECT Id, Name, Application_Fee_Paid__C,
               MobilePhone, Country_Code__c,
               Record_Type_Name__c, Application_Number__c,
               Email, Owner.Name, Owner.MobilePhone,
               Owner.ProfileId
        FROM Contact
        WHERE Id IN :conIdSet
    ];
        for(Contact con : contacts){

        Boolean isValidOwner =
            con.Owner.MobilePhone != null &&
            (
                con.Owner.ProfileId == profileMap.get('Counselor') ||
                con.Owner.ProfileId == profileMap.get('RO Profile') ||
                con.Owner.ProfileId == profileMap.get('Admission Team Lead') ||
                con.Owner.ProfileId == profileMap.get('Admissions Profile')
            );

        if(isValidOwner){

            if(PAFFullPaidMap.get(con.Id) == true){
                conList.add(con);
            }
            else{
                conListPAFPartialPaid.add(con);
            }

        }else{
            conIdSetToSendNotificationLater.add(con.Id);
        }
    }
       if(conList.size() > 0){
            if(category == 'Pending'){
                System.debug('before calling Yellow_AI_Utility.sendSMSAndWhatstapp on pending status');
                sendSMSAndWhatstapp(conList, stuPaySet, 'admissionpaymentlink', 'Admission_Payment_Link');
                 //If AddedbyRajashekar
                 if(!system.isbatch()){
                     PAFPaymentSendEmails.makeCalloutAsync(stuPaySet);
                 }
                 
            } else if(category == 'Success'){
                System.debug('before calling Yellow_AI_Utility.sendSMSAndWhatstapp on success status');
                sendSMSAndWhatstapp(conList, stuPaySet, 'admissionfeeconfirmation', 'Payment_Confirmation');
               
            } else if(category == 'Failed'){
                System.debug('before calling Yellow_AI_Utility.sendSMSAndWhatstapp on Failed status');
                sendSMSAndWhatstapp(conList, stuPaySet, 'payment_reject_student','Admission_Payment_Link');
                PAFPaymentSendEmails.WhatstappNotificationCounselor(conListPAFPartialPaid,stuPaySet,'payment_reject_counselor');
                //If AddedbyRajashekar
                if(!system.isbatch()){
                     PAFPaymentSendEmails.makeCalloutAsync(stuPaySet);
                }
            }
       }
       if(conListPAFPartialPaid.size() > 0){
            if(category == 'Pending'){
                System.debug('before calling Yellow_AI_Utility.sendSMSAndWhatstapp on pending status');
                sendSMSAndWhatstapp(conListPAFPartialPaid, stuPaySet, 'admissionpaymentlink', 'Admission_Payment_Link');
               //If AddedbyRajashekar 
                if(!system.isbatch()){
                     PAFPaymentSendEmails.makeCalloutAsync(stuPaySet);
                }
            } else if(category == 'Success'){
                System.debug('before calling Yellow_AI_Utility.sendSMSAndWhatstapp on success status');
                sendSMSAndWhatstapp(conListPAFPartialPaid, stuPaySet, 'paymentconfirmation1_copy1', 'Partial_Payment_Confirmation');
               
            } else if(category == 'Failed'){
                System.debug('before calling Yellow_AI_Utility.sendSMSAndWhatstapp on pending status');
                sendSMSAndWhatstapp(conListPAFPartialPaid, stuPaySet, 'payment_reject_student', 'Admission_Payment_Link');
                PAFPaymentSendEmails.WhatstappNotificationCounselor(conListPAFPartialPaid,stuPaySet,'payment_reject_counselor');
                //If AddedbyRajashekar 
                 if(!system.isbatch()){
                    PAFPaymentSendEmails.makeCalloutAsync(stuPaySet);
                }
            } 
       }
       
       if(conIdSetToSendNotificationLater.size() > 0){
        // future method have to define and call here
        System.debug('need to send notifcation later');
        // futurecallsendSMSAndWhatstapp(conIdSetToSendNotificationLater);
        // SMSandWhatsappNotificationBatchScheduler sch = new SMSandWhatsappNotificationBatchScheduler();
        // System.schedule('Lead assignment schedule - I', '0 01 * * * ? ' , sch);
        // System.schedule('Lead assignment schedule - II', '0 16 * * * ? ' , sch);
        // System.schedule('Lead assignment schedule - III', '0 31 * * * ? ' , sch);
        // System.schedule('Lead assignment schedule - IV', '0 46 * * * ? ' , sch);
       }
       
    }

    public static Map<id,Boolean> calculatePAFPaidAmount(Set<Id> conIdSet){
        Map<Id,Decimal> PAFAmountDefined = new Map<Id,Decimal>();
        Map<Id,Decimal> PAFAmountPaid = new Map<Id,Decimal>();
        Map<Id,Boolean> PAFFullPaidMap = new Map<Id,Boolean>();
        for(Student_Fee__c stufee : [SELECT Id, Name, contact__c, Actual_Program_Fee__c, Amount_Paid__c, Amount_Pending__c, Amount__c, Provisional_Admission_Fee__c, Fee_type__c FROM Student_Fee__c where contact__c =: conIdSet AND Fee_type__c = 'University Fee']){
            if(stufee.Provisional_Admission_Fee__c != null){
                if(PAFAmountDefined.get(stufee.contact__c) == null){
                    PAFAmountDefined.put(stufee.contact__c,stufee.Provisional_Admission_Fee__c);
                } else {
                    PAFAmountDefined.put(stufee.contact__c,(PAFAmountDefined.get(stufee.contact__c) + stufee.Provisional_Admission_Fee__c));
                }
            }
        }
        System.debug('pafamountdefined '+PAFAmountDefined);
        for(Student_Payment__c stupay : [SELECT Id, Name, Amount__c, Contact__c, Fee_Type__c, Mode_of_Payment__c, Payment_Status__c, createddate FROM Student_Payment__c where contact__c =: conIdSet AND (Fee_Type__c = 'University Fee' OR Fee_Type__c = 'Tuition Fee') AND Payment_Status__c = 'Success']){
            if(PAFAmountPaid.get(stupay.contact__c) != null){
                PAFAmountPaid.put(stupay.contact__c,((PAFAmountPaid.get(stupay.contact__c) != null ? PAFAmountPaid.get(stupay.contact__c) : 0) + stupay.Amount__c));
            } else{
                PAFAmountPaid.put(stupay.contact__c,stupay.Amount__c);
            }
            // if(PAFAmountPaid.get(stupay.contact__c) == null){
            //     PAFAmountPaid.put(stupay.contact__c,stupay.Amount__c);
            // } else {
            //     PAFAmountPaid.put(stupay.contact__c,(PAFAmountPaid.get(stupay.contact__c) + stupay.Amount__c));
            // }
        }
        System.debug('PAFAmountPaid '+PAFAmountPaid);
        for(Id id : PAFAmountDefined.keySet()){
            if(PAFAmountDefined.get(id) == PAFAmountPaid.get(id)){
                PAFFullPaidMap.put(id,true);
            } else  {
                PAFFullPaidMap.put(id,false);
            }
        }
        System.debug('PAFFullPaidMap '+PAFFullPaidMap);
        return PAFFullPaidMap;
    }
    // @future(callout=true)
    // public static void futurecallsendSMSAndWhatstapp(Set<Id> conIdSet){
    //     Profile pr = [SELECT Id, Name FROM Profile WHERE Name = 'Counselor' LIMIT 1];
    //     List<Contact> conList = new List<Contact>();
    //     Set<Id> conIdSetToSendNotificationLater = new Set<Id>();
    //     for(Contact con : [SELECT id, name, Application_Fee_Paid__C, MobilePhone, Country_Code__c, Record_Type_Name__c, Application_Number__c, Email, Owner.Name, Owner.MobilePhone, owner.profileid FROM contact WHERE id =:  conIdSet]){
    //         if(con.Owner.MobilePhone != NULL && con.owner.profileid == pr.id){
                
    //             conList.add(con);
    //         } else {
                
    //             conIdSetToSendNotificationLater.add(con.Id);
    //         }
    //     }
    // //    if(conList.size() > 0){
    // //     Yellow_AI_Utility.sendSMSAndWhatstapp(conList, 'admissionpaymentlink', 'Admission_Payment_Link');
    // //    }
    // }

    // Updating PAF 
    public static void updateProvAdmissionFee(List<Student_Payment__c> lstStu) {
        
        Set<string> applicationIds = new Set<string>();
        for(Student_Payment__c sp : lstStu){
            applicationIds.add(sp.Contact__r.Application_Number__c);
            
        }
        Map<string, hed__Application__c> applications = new Map<string, hed__Application__c>();
        Map<Id, Student_Fee__c> studentFees = new Map<Id, Student_Fee__c>();
        
        for (hed__Application__c app : [SELECT id,Concession_Status__c, Provisional_Admission_Fee_Paid__c, Application_Number__c FROM hed__Application__c WHERE Application_Number__c IN :applicationIds]) {
            applications.put(app.Application_Number__c, app);
        } 
        
        List<hed__Application__c> lstAppl = new List<hed__Application__c>();
        for (Student_Payment__c stuPay : lstStu) {
            
            hed__Application__c appl = applications.get(stuPay.Contact__r.Application_Number__c);
            if(appl.Concession_Status__c == 'Initiated' || appl.Concession_Status__c == 'Under Approval'){
                AdmissionsProcessUtility.UnlockApplicationRecord(appl.Id);
            } 
            if (stuPay.payment_status__c == 'Success' && stuPay.Mode_of_Payment__c == 'Online' && appl.Provisional_Admission_Fee_Paid__c == false ) {
                system.debug('Inside True');
                appl.Provisional_Admission_Fee_Paid__c = true;
                System.debug('inside student payment trigger handler '+appl);
                lstAppl.add(appl);
            }
        }
	if(!lstAppl.isEmpty()){
                // update lstAppl;

    }
        
    }
    
    //Updating Application Fee Paid as True in Contact. 
    public static list<contact> updateApplicationFeeStatus(List<Student_Payment__c> lstSp){
        list<contact> lstCon = new list<contact>();
        contact con = [SELECT Id,Program_batch__c,Program_batch__r.Name, Name FROM Contact WHERE Id =: lstSp[0].Contact__c LIMIT 1];
        for(Student_Payment__c sp : lstSp){
            contact conRec = new contact();
            
            if(sp.payment_status__c == 'Success' && sp.Fee_Type__c == 'Application Fee' 
               && sp.contact__r.Application_Fee_Paid__c == false){
                   conRec.id = sp.contact__c;
                   conRec.Application_Fee_Paid__c = True;
                   conRec.Application_Fee_Paid_Date__c = System.today();
                   conRec.Quota__c = 'Management Quota';
                   conRec.Admission_Mode__c = 'UQ';
                   conRec.Enrollment_Type__c = con.Program_batch__r.Name.contains('(LE)') ? 'Lateral Entry' : 'Regular Entry';

                   lstCon.add(conRec);
               }
        }
       if(!lstCon.isEmpty()){
        update lstCon;
    }
        return lstCon;
    } 
    
    // Sending Application Number Via SMS and Whatsapp
    public static void sendApplicationNumber(list<contact> ConRecords, Set<Id> stupaySet){ 
        // System.debug('before calling Yellow_AI_Utility.sendSMSAndWhatstapp');
        // System.debug('ConRecords'+ConRecords);
        // System.debug('ConRecords'+stupaySet);
        // Yellow_AI_Utility.sendSMSAndWhatstapp(ConRecords,stupaySet, 'resetlinknew2', 'Reset_Password_for_Application_Portal');
        List<Contact> conRecs = [select id, Name, Email, Application_Fee_Paid__C, Record_Type_Name__c, MobilePhone, Country_Code__c, Application_Number__C 
                                 from Contact where Id in : conRecords];
        List<Student_Payment__c> StudentPayment = [select id,Name,Contact__c,Fee_Type__c from Student_Payment__c where Contact__c in : conRecords ];
        string feeType;
        for(Student_Payment__c stud : StudentPayment){
            feeType = stud.Fee_Type__c;
        }
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'resetlinknew2';
        // Fetch keys from custom metadata based on templateId
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        for( contact stu : conRecs ){
            if( stu.Application_Fee_Paid__C == true && stu.Record_Type_Name__c == 'Applicant'){
                notification1.params = new Map<String, String>();
                for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                    // Split values based on comma and add each as a separate key
                    String[] keys = metadata.Template_Field__c.split(',');
                    for (String key : keys) {
                        // You can set static values for each key
                        // Modify these lines to set your specific static values
                        if (key == 'ApplicantName') {
                            notification1.params.put(key, stu.Name);
                        } else if (key == 'ApplicationNo') {
                            notification1.params.put(key.trim(), stu.Application_Number__c);
                        } else if (key == 'PersonalMailid') {
                            notification1.params.put(key.trim(), stu.Email);
                        }
                    }
                }
                List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                String plusRemoved = stu.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                string mobile = stu.MobilePhone;
                mobile = mobile.remove('+91-');
                List<String> requiredVariables =  new List<String>();
                List<String> requiredVariables1 =  new List<String>();
                if(stu.Country_Code__c == 'India (+91)'){
                    requiredVariables.add(stu.Application_Number__c);
                    //requiredVariables1.add(stu.Name);
                    requiredVariables1.add(stu.Application_Number__c);
                    requiredVariables1.add(stu.Email);
                    if(!system.isbatch()){
                        // RegistrationFormUtility.futureSMS(SMS_TYPE, mobile, requiredVariables);
                        RegistrationFormUtility.futureSMS(SMS_TYPE1, mobile, requiredVariables1);
                    }
                }
            }
        }
        if(feeType != 'Transportation Fee'){
            //AddedbyRajashekar
             if(!system.isbatch()){
            System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
             }
        }
        
    }
    
    // Coupon Code
    public static void updateCouponCount(List<Contact> listOfContacts){
        List<Contact> conRec = [select id, Application_Number__c, Application_Fee_Paid__C, Record_Type_Name__c from contact where Id IN : listOfContacts];
        Map<Id,Coupon__c> couponMapToBeUpdated = new Map<Id, Coupon__c>();        
        Set<String> applNumbers = new Set<String>();
        Map<String, hed__Application__c> applMap = new Map<String, hed__Application__c>();
        Map<String,Coupon__c> mapCo = new Map<String,Coupon__c>();
        Map<String,Decimal> couponCountForMulti = new Map<String,Decimal>();
        
        for (Contact stuPay : conRec) {
            applNumbers.add(stuPay.Application_Number__c);
        }
        
        
        for (hed__Application__c app : [Select Id, Name, Application_Number__c, Applied_Coupon__C from hed__Application__c 
                                        where Application_Number__c in :applNumbers]) {
                                            applMap.put(app.Application_Number__c, app);
                                        } 
        
        for(Coupon__c coupon : [Select Id, Name, MultiUse__c, Current_Use_Count__c, Used_on_Application__c, Applicant__c from Coupon__C 
                                where Id in (Select Applied_Coupon__C from hed__Application__c 
                                             where Application_Number__c in :applNumbers)]){
                                                 mapCo.put(coupon.Id,coupon);  
                                                 if(coupon.MultiUse__c){
                                                     couponCountForMulti.put(coupon.Id,coupon.Current_Use_Count__c) ;  
                                                 }
                                             }
        
        for (Contact stuPay : conRec) {
            String applNumber = stuPay.Application_Number__c;
            hed__Application__c application = applMap.get(applNumber);
            String appliedCouponCode = application.Applied_Coupon__C;
            if (stuPay.Application_Fee_Paid__c == True) {
                if (appliedCouponCode != null) {
                    system.debug(1);
                    Coupon__c couponToBeUpdated = mapCo.get(appliedCouponCode);
                    
                    if (!couponToBeUpdated.MultiUse__c) {
                        couponToBeUpdated.Used_on_Application__c = application.Id;
                        couponMapToBeUpdated.put(couponToBeUpdated.Id,couponToBeUpdated);
                    } else {
                        if(couponCountForMulti.containsKey(couponToBeUpdated.Id)){
                            couponCountForMulti.put(couponToBeUpdated.Id, couponCountForMulti.get(couponToBeUpdated.Id)+1);
                        }
                        couponToBeUpdated.Current_Use_Count__c = couponCountForMulti.get(couponToBeUpdated.Id);
                        couponMapToBeUpdated.put(couponToBeUpdated.Id,couponToBeUpdated);
                    }
                }
            }
        }
        update couponMapToBeUpdated.values();
    }
    
    // public static void callingsendSMSAndWhatstapp(List<Student_Payment__c> stupayList){
    //     System.debug('inside callingsendSMSAndWhatstapp');
    //     Set<Id> stupayContactSet = new Set<Id>();
    //     for(Student_Payment__c sp : stupayList){
    //         // if(sp.Mode_of_Payment__c == 'Online'){ //Need to check why at this time online is not considered for process
    //             stupayContactSet.add(sp.contact__c);
    //         // }
    //     }

    //     // //to send whatsapp and sms notification when counselor entered amount by online mode
    //     // if(stupayContactSet.size() > 0){
    //     //     System.debug('before calling sms and whatsapp');
    //     //     callsendSMSAndWhatstapp(stupayContactSet);
    //     // } else {
    //     //     System.debug('con id is empty');
    //     // }
    // }

    
    public static void sendSMSAndWhatstapp(List<Contact> conRecs,Set<Id> stuPaySet, String whatsappTemplateName,String smsType){
        system.debug('call in sendSMSAndWhatstapp ');
        system.debug('conRecs -->'+conRecs);
        system.debug('conRecs -->'+conRecs);
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = whatsappTemplateName;
        Map<Id,Map<String,String>> conEmailSourceMap = new Map<Id,Map<String,String>>();
        Map<Id,Map<String,String>> ConfirmconEmailSourceMap = new Map<Id,Map<String,String>>();
        Map<Id,Map<String,String>> RejectconEmailSourceMap = new Map<Id,Map<String,String>>();
        // Fetch keys from custom metadata based on templateId
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Set<Id> conIds = new Set<Id>();
        for(Contact c : conRecs){
            conIds.add(c.Id);
        }
        List<Student_payment__c> stuPayList=[SELECT Id, Name,Mode_of_Payment__c,Payment_Mode_Type__c, Amount__c, Contact__c, Billdesk_Url__c,Fee_Type__c, payment_status__c FROM Student_payment__c WHERE Contact__c IN :conIds and id IN :stuPaySet ORDER BY CreatedDate Desc];
        Map<Id,Decimal> conStuPayAmount = new Map<Id,Decimal>();
        Map<Id,Id> conStuPayIdMap = new Map<Id,Id>();
        Map<Id,string> conStuPayModeMap = new Map<Id,string>();
        String feeTypes;
        for(Student_payment__c stupay : stuPayList){
            conStuPayAmount.put(stupay.Contact__c,stupay.Amount__c);
            conStuPayIdMap.put(stupay.Contact__c,stupay.Id);
            conStuPayModeMap.put(stupay.Contact__c,stupay.Payment_Mode_Type__c);
            feeTypes=stupay.Fee_Type__c;
        }
        System.debug('stuPayList --> '+stuPayList);
        System.debug('conStuPayAmount --> '+conStuPayAmount);
        List<Domain> domainList = [SELECT Id, DomainType, Domain, HttpsOption FROM Domain WHERE HttpsOption ='CommunityAlt'];
        // String directPaymentURL = 'https://' + domainList[0].Domain;
        // for(Student_payment__c StuPym:StudentPym ){        
        for( contact stu : conRecs ){   
            Map<String,String> localEmailSourceMap = new Map<String,String>();
             Map<String,String> RejectEmailSourceMap = new Map<String,String>();           
             Map<String,String> ConfirmationEmailSourceMap = new Map<String,String>();
            // if( stu.Application_Fee_Paid__C == true && stu.Record_Type_Name__c == 'Applicant'){
                notification1.params = new Map<String, String>();
                for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                    // Split values based on comma and add each as a separate key
                    String[] keys = metadata.Template_Field__c.split(',');
                    if(metadata.Template_ID__c == 'resetlinknew2'){
                        System.debug('resetlinknew2 --> '+whatsappTemplateName);
                        for (String key : keys) {
                            // You can set static values for each key
                            // Modify these lines to set your specific static values
                            if (key == 'ApplicantName') {
                                notification1.params.put(key, stu.Name);
                            } else if (key == 'ApplicationNo') {
                            notification1.params.put(key.trim(), stu.Application_Number__c);
                            } else if (key == 'PersonalMailid') {
                            notification1.params.put(key.trim(), stu.Email);
                            }
                        }  
                    } else if(metadata.Template_ID__c == 'admissionpaymentlink') { //YellowAI have to confirm the labelName
                        
                        // emailSourceMap.put(stu.Id,new Map<String,any>());
                        for (String key : keys) {
                            // You can set static values for each key
                            // Modify these lines to set your specific static values
                            if (key == 'ApplicantName') {
                                notification1.params.put(key, stu.Name); 
                                localEmailSourceMap.put(key,stu.name);
                            } else if (key == 'Amount') {
                                notification1.params.put(key.trim(),String.valueOf(conStuPayAmount.get(stu.Id))); //PAF amount entered by the counselor
                                localEmailSourceMap.put(key.trim(),String.valueOf(conStuPayAmount.get(stu.Id)));
                            } else if (key == 'URL') {
                               notification1.params.put(key.trim(), 'https://' + domainList[0].Domain + '/Admissions/s/payment-page?contactId='+ stu.id + '&isPAF=true&stupayid='+conStuPayIdMap.get(stu.Id));//Direct fee payment link
                               localEmailSourceMap.put(key.trim(),'https://' + domainList[0].Domain + '/Admissions/s/payment-page?contactId='+ stu.id + '&isPAF=true&stupayid='+conStuPayIdMap.get(stu.Id));
                            } else if (key == 'CounsellorName') {
                                notification1.params.put(key.trim(), stu.Owner.Name);//counselor name
                                localEmailSourceMap.put(key.trim(),stu.Owner.Name);
                            } else if (key == 'CounsellorMobileNo') {
                                notification1.params.put(key.trim(), stu.Owner.MobilePhone); //counselor mobilephone
                                localEmailSourceMap.put(key.trim(), stu.Owner.MobilePhone);
                            }
                        } 
                    } else if(metadata.Template_ID__c == 'admissionfeeconfirmation') { //YellowAI have to confirm the labelName
                        for (String key : keys) {
                            // You can set static values for each key
                            // Modify these lines to set your specific static values
                            if (key == 'StudentName') {
                                notification1.params.put(key, stu.Name);
                                ConfirmationEmailSourceMap.put(key, stu.Name);
                            } else if (key == 'TotalFee') {
                                notification1.params.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id))); //PAF amount entered by the counselor
                                ConfirmationEmailSourceMap.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id)));
                            } else if (key == 'Counsellorname') {
                                notification1.params.put(key.trim(), stu.Owner.Name);//counselor name
                                ConfirmationEmailSourceMap.put(key.trim(), stu.Owner.Name);
                            } else if (key == 'Counsellormobileno') {
                                notification1.params.put(key.trim(), stu.Owner.MobilePhone); //counselor mobilephone
                                ConfirmationEmailSourceMap.put(key.trim(), stu.Owner.MobilePhone);
                            }
                        } 
                    } 
                     else if(metadata.Template_ID__c == 'payment_reject_student') { //YellowAI have to confirm the labelName
                        for (String key : keys) {
                            // You can set static values for each key
                            // Modify these lines to set your specific static values
                             if (key == 'ApplicantName') {
                                notification1.params.put(key, stu.Name); 
                                 RejectEmailSourceMap.put(key, stu.Name);
                                 System.debug('Hiii:'+ stu.Name);
                            }else if (key == 'ModeofPayment') {
                            notification1.params.put(key.trim(), String.valueOf(conStuPayModeMap.get(stu.Id)));
                                RejectEmailSourceMap.put(key.trim(), String.valueOf(conStuPayModeMap.get(stu.Id))); 
                                 System.debug('Hiii:'+ String.valueOf(conStuPayModeMap.get(stu.Id)));
                            }  else if (key == 'Applicationno') {
                            notification1.params.put(key.trim(), stu.Application_Number__c);
                                RejectEmailSourceMap.put(key.trim(), stu.Application_Number__c); 
                                 System.debug('Hiii:'+ stu.Application_Number__c);
                            } else if (key == 'Amount') {
                                notification1.params.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id))); //PAF amount entered by the counselor
                                RejectEmailSourceMap.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id))); 
                                 System.debug('Hiii:'+String.valueOf(conStuPayAmount.get(stu.Id)));
                            }
                            else if (key == 'Dateandtime') {         
                                  DateTime currentDateTime = System.now();
                                String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
                                 notification1.params.put(key.trim(), formattedDateTime); 
                                RejectEmailSourceMap.put(key.trim(), formattedDateTime);
                                 System.debug('Hiii:'+formattedDateTime);
                        } 
                    }
                     }
                    else if(metadata.Template_ID__c == 'paymentconfirmation1_copy1') { //YellowAI have to confirm the labelName
                        for (String key : keys) {
                            // You can set static values for each key
                            // Modify these lines to set your specific static values
                            if (key == 'ApplicantName') {
                                notification1.params.put(key, stu.Name);
                                ConfirmationEmailSourceMap.put(key, stu.Name);
                            } else if (key == 'paidamount') {
                                notification1.params.put(key.trim(), String.valueOf(conStuPayAmount.get(stu.Id))); //PAF amount entered by the counselor
                                ConfirmationEmailSourceMap.put('TotalFee', String.valueOf(conStuPayAmount.get(stu.Id)));
                            } else if (key == 'CounselorName') {
                                notification1.params.put(key.trim(), stu.Owner.Name);//counselor name
                                ConfirmationEmailSourceMap.put('CounsellorName', stu.Owner.Name);
                            } else if (key == 'CounselormobileNo') {
                                notification1.params.put(key.trim(), stu.Owner.MobilePhone); //counselor mobilephone
                                ConfirmationEmailSourceMap.put('CounsellorMobileNo', stu.Owner.MobilePhone);
                            }
                        } 
                    }
                   
                }
                if(localEmailSourceMap.size() > 0){
                    conEmailSourceMap.put(stu.Id,localEmailSourceMap);
                }if(ConfirmationEmailSourceMap.size() > 0){
                    ConfirmconEmailSourceMap.put(stu.Id,ConfirmationEmailSourceMap);
                }
                if(RejectEmailSourceMap.size() > 0){
                    RejectconEmailSourceMap.put(stu.Id,RejectEmailSourceMap);
                }
                
                List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                if(stu.MobilePhone != null){
                    String plusRemoved = stu.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                }
              string mobile = stu.MobilePhone;
                if(mobile != null){
                     mobile = mobile.remove('+91-');
                }
                System.debug('sms area ');
                System.debug(stu);
                List<String> requiredVariables =  new List<String>();
                if(stu.Country_Code__c == 'India (+91)'){
                    System.debug('sms country check ');
                    if(smsType == 'Reset_Password_for_Application_Portal'){
                        requiredVariables.add(stu.Application_Number__c);
                        requiredVariables.add(stu.Email);
                        if(!system.isbatch()){
                            System.debug('sms Reset_Password_for_Application_Portal ');
                            RegistrationFormUtility.futureSMS(smsType, mobile, requiredVariables);
                        }
                    } 
                 else if(smsType == 'Admission_Payment_Link'){
                        System.debug('inside Admission payment link sms ');
                        requiredVariables.add(String.valueOf(conStuPayAmount.get(stu.Id))); //AmountEnteredbyCounsellor
                        requiredVariables.add('https://' + domainList[0].Domain + '/Admissions/s/payment-page?contactId='+ stu.id + '&isPAF=true&stupayid='+conStuPayIdMap.get(stu.Id));//Direct fee payment link
                        if(!system.isbatch()){
                            RegistrationFormUtility.futureSMS(smsType, mobile, requiredVariables);
                        }
                    } else if(smsType == 'Payment_Confirmation'){
                        System.debug('inside Admission payment confirmation sms ');
                        requiredVariables.add(stu.Name); //ApplicantName
                        requiredVariables.add(String.valueOf(conStuPayAmount.get(stu.Id))); //TotalProvisionalFeeReceived
                        if(!system.isbatch()){
                            RegistrationFormUtility.futureSMS(smsType, mobile, requiredVariables);
                        }
                    } else if(smsType == 'Partial_Payment_Confirmation'){
                        System.debug('inside Admission partial payment confirmation sms ');
                        requiredVariables.add(stu.Name); //ApplicantName
                        requiredVariables.add(String.valueOf(conStuPayAmount.get(stu.Id))); //TotalProvisionalFeeReceived
                        if(!system.isbatch()){
                            RegistrationFormUtility.futureSMS(smsType, mobile, requiredVariables);
                        }
                    } else {
                        System.debug('inside final else');
                    }
                }
            // }
        }
    // }
    	// System.debug('before calling queable apex --> '+phoneNumbersToNotifications);
        if(feeTypes !='Transportation Fee'){
            //AddedbyRajashekar
             if(!system.isbatch()){
                 System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
             }
        }
        // System.debug('email source map  '+conEmailSourceMap);
     //if AddedbyRajashekar to ensure governer limits
      if(RecursiveTriggerHandler.isEmailfromTrigger){
           RecursiveTriggerHandler.isEmailfromTrigger = false;
           System.debug('********************************');
System.debug('Email Map Size : ' + conEmailSourceMap.size());
System.debug('Email Map : ' + conEmailSourceMap);
System.debug('RecursiveTriggerHandler.isEmailfromTrigger = '
    + RecursiveTriggerHandler.isEmailfromTrigger);
System.debug('********************************');
          if(conEmailSourceMap.size() > 0){
              PAFPaymentSendEmails.sendDirectPaymentLinkEmail(conEmailSourceMap);
          }
          if(ConfirmconEmailSourceMap.size() > 0){
              PAFPaymentSendEmails.sendConfirmEmail(ConfirmconEmailSourceMap);
          }
          if(RejectconEmailSourceMap.size() > 0){
              PAFPaymentSendEmails.sendRejectionEmail(RejectconEmailSourceMap);
          }
      }
    }
    
    // New changes related to Hostel 27-06-2024//
    //*******Adding new method for sending notifications********//
   /* public static void sendPaymentNotifications(List<Student_Payment__c> payments) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
     
        Set<Id> paymentIds = new Set<Id>();
        for (Student_Payment__c payment : payments) {
            paymentIds.add(payment.Id);
        }
		 List<Student_Fee_Payment__c> feePayments = [SELECT Id, Line_Item_Payment_Status__c, Student_Fee__c 
                                                    FROM Student_Fee_Payment__c 
                                                    WHERE Student_Payment__c IN :paymentIds];

        for (Student_Fee_Payment__c feePayment : feePayments) {
            if (feePayment.Line_Item_Payment_Status__c == 'Success' && feePayment.Student_Fee__c != null) {
          
                RHStudentFeePaymentReceiptPDFGenerator.generateReceiptPDFAsync(feePayment.Id);
            }
        }
  
        if (!emailMessages.isEmpty()) {
            Messaging.sendEmail(emailMessages);
        }
    }*/
    public static void sendPaymentNotifications(List<Student_Payment__c> payments) {
    List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

    Set<Id> paymentIds = new Set<Id>();
    for (Student_Payment__c payment : payments) {
        paymentIds.add(payment.Id);
    }

    List<Student_Fee_Payment__c> feePayments = [SELECT Id, Line_Item_Payment_Status__c, Student_Fee__c 
                                                FROM Student_Fee_Payment__c 
                                                WHERE Student_Payment__c IN :paymentIds];

    for (Student_Fee_Payment__c feePayment : feePayments) {
        if (feePayment.Line_Item_Payment_Status__c == 'Success' && feePayment.Student_Fee__c != null) {
            try {
                // Generate PDF asynchronously
                //if condition AddedbyRajashekar as this is triggered from studentpaymenttrigger and future method is being called from here multiple times.
                if(RecursiveTriggerHandler.isFirstTimeEmail)
                {
                    RecursiveTriggerHandler.isFirstTimeEmail = false;
                    RHStudentFeePaymentReceiptPDFGenerator.generateReceiptPDFAsync(feePayment.Id);
                }
            } catch (Exception e) {
                // Handle the exception (for example, log it)
                System.debug('Exception occurred while generating PDF: ' + e.getMessage());
                // Optionally, add more specific handling or notifications
            }
        }
    }

   /* if (!emailMessages.isEmpty()) {
        try {
            // Send email messages
            Messaging.sendEmail(emailMessages);
        } catch (Exception e) {

            System.debug('Exception occurred while sending emails: ' + e.getMessage());
            // Optionally, add more specific handling or notifications
        }
    }*/
}

   //ending of changes//

     
}