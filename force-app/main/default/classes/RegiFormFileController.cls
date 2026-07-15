public without sharing class RegiFormFileController {    

    public static String academicYear = '2024-2025';
    // Calculating fees paid for the academic is more than 50% 
    @AuraEnabled
    public static boolean checkRegistrationEligibility(Id contactId, Id ProgramBatchId){

        List<Student_Fee__c> feeDetailsList = new List<Student_Fee__c>();        
        try {
            Integer semNumber = isTodayWithinStartDateRange(ProgramBatchId, contactId);
            String year;
            // Except 0 (invalid) 1semester(Not considered) 
            if(semNumber > 1){    
                /* Date : 16-06-2025 Commented
                if(semNumber == 3){
                    year = '2nd Year';
                }
                if(semNumber == 5){
                    year = '3rd Year';
                }
                if(semNumber == 7){
                    year = '4th Year';
                }
                if(semNumber == 9){
                    year = '5th Year';
                }  */  
                
                // ------------------------------- Date : 16-06-2025 ---------------------------
                // Exception added for MBA-2024-2026-Sem-2 and MBA-2023-2025-Sem-4 
                if((ProgramBatchId =='a0K5j00000816aaEAA' && semNumber == 2) || (ProgramBatchId =='a0K5j000002FgdeEAC' && semNumber == 4)){
                    if(semNumber == 2){
                        year = '1st Year';
                    }
                    if(semNumber == 4){
                        year = '2nd Year';
                    }
                } else {	
                	if(semNumber == 3){
                    	year = '2nd Year';
                    }
                    if(semNumber == 5){
                        year = '3rd Year';
                    }
                    if(semNumber == 7){
                        year = '4th Year';
                    }
                    if(semNumber == 9){
                        year = '5th Year';
                    }
                }   
				//-----------------------------------------------------------------
            
                feeDetailsList = [SELECT Id, Name, Amount_Paid__c, Amount_Pending__c, Amount__c, Contact__c, Fee_Type__c, Fee_Year__c 
                            FROM Student_Fee__c 
                            WHERE FEE_YEAR__c =: year AND Contact__c =: contactId AND Fee_Type__c IN ('Tuition Fee','University Fee')];  //WHERE FEE_YEAR__c = '2nd Year' and Contact__c =: ='0035j000011aDmHAAU'];   
                if(feeDetailsList.size() > 0) {
                    // Calculated total fee paid for the year.  As per student registartion criteria student must be paid minimum 50% of the fee                        
                    double feeAmount = 0.0;
                    double feePaid = 0.0;
                        for(Student_Fee__c fee : feeDetailsList){
                            feeAmount = fee.Amount__c + feeAmount;
                            feePaid = fee.Amount_Paid__c + feePaid;
                        }
                        double feeAmount50per = feeAmount / 2;                     

                        if(feePaid >= feeAmount50per){
                            return true;                        
                        }
                }            
            }                    
            return false;           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }


    // Method to check if today's date is within (startDate - 30 days) to (endDate + 70 days)
    @AuraEnabled
    public static Integer isTodayWithinStartDateRange(Id ProgramBatchId, Id contactId) {            
            
        //    if(ProgramBatchId != null && contactId != null) {
                List<Contact> conList = [SELECT Id, Student_Status__c FROM Contact WHERE Id =: contactId AND Student_Status__c = 'Pursuing' LIMIT 1];
                List<hed__Term__c> semList = [SELECT Id, Name, Program_Batch_Name__c,Term_Number__c,Program_Batch__c,hed__Start_Date__c,hed__End_Date__c 
                                            FROM hed__Term__c 
                                            WHERE Program_Batch__c = :ProgramBatchId ];  // limit 1                                                       

                if(conList.size() > 0 && semList != null && semList.size() > 0){
                    for(hed__Term__c sem : semList){
                        if(sem.hed__Start_Date__c != null && sem.Term_Number__c != null){
                            Date startDateMinus30Days = sem.hed__Start_Date__c.addDays(-30);
                            Date startDatePlus70Days = sem.hed__Start_Date__c.addDays(70);
                            Date today = Date.today();
                            //Date today = Date.valueOf('2024-04-28');
                            if(today >= startDateMinus30Days && today <= startDatePlus70Days){
                                //return true;
                                Integer semNumber = Integer.valueOf(sem.Term_Number__c);
                                // Exclude 
                                if((ProgramBatchId =='a0K5j00000816aaEAA' && semNumber == 2) || (ProgramBatchId =='a0K5j000002FgdeEAC' && semNumber == 4)){
                                   return semNumber; 
                                } else if(semNumber > 1 && (Math.Mod(semNumber, 2) != 0)){
                                    return semNumber;
                                }
                            }
                        }
                    } 
                }
        //    }             
        return 0;
    }   

    @AuraEnabled
    public static Integer updateContactRegistrationField(Id contactId,Integer semester,Id ProgramBatchId) {
        try{ 
            if(contactId != null && ProgramBatchId != null && semester > 0) {
                boolean result = checkRegistrationEligibility(contactId, ProgramBatchId);
                hed__Term__c sem = [SELECT Id, Name, Term_Number__c FROM hed__Term__c WHERE Program_Batch__c =: ProgramBatchId AND Term_Number__c =: semester LIMIT 1]; 
                if(sem != null && result){               
                    Contact con = [SELECT Id, Sem_Registered__c, Registered_Semester_Name__c, Registered_Semester_Date__c FROM Contact WHERE Id = :contactId LIMIT 1];
                    if(con != null){
                        con.Sem_Registered__c = semester;
                        con.Registered_Semester_Name__c = sem.Name;
                        con.Registered_Semester_Date__c = Date.today();
                        con.Registered__c = true;
                        update con;

                        return 1;
                    }
                }
            }            
            return 0;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean checkSemRegistrationField(Id contactId, Id ProgramBatchId) {
        try{            
            Contact con = [SELECT Id, Sem_Registered__c FROM Contact WHERE Id = :contactId LIMIT 1]; //003Ip000001ZL3fIAG
            if(con != null && con.Sem_Registered__c != null){
                Integer semNumber = isTodayWithinStartDateRange(ProgramBatchId, contactId);
                if(semNumber > 1 && con.Sem_Registered__c > 1 && con.Sem_Registered__c == semNumber){
                    return false;
                }
            }
          return true;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string displayDetails(Id ProgramBatchId, Id contactId){
        try {
            Integer semNumber = isTodayWithinStartDateRange(ProgramBatchId, contactId);
            if(semNumber > 0){
                hed__Term__c sem = [SELECT Id, Name, Term_Number__c FROM hed__Term__c WHERE Program_Batch__c =: ProgramBatchId AND Term_Number__c =: semNumber LIMIT 1]; 
                if(sem != null){
                    String semesterName = sem.Name;
                    return semesterName;
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Integer sendNotifications(String contactId, Integer semesterNum, Id ProgramBatchId) {
        //    system.debug('Variables -->'+contactId+' :: '+ semesterNum+' :: '+ProgramBatchId);
        try {
            // Query the contact based on contactId
            Contact contactObj = [SELECT Id, Name,SRN_Number__c,hed__WorkEmail__c, MobilePhone, Program_Batch_Name__c FROM Contact WHERE Id = :contactId LIMIT 1];
        
            // Query parent contacts
            Id ConParentTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
            List<Contact> parentContactList = [SELECT Id, Name, Email, MobilePhone, ReportsToid FROM Contact WHERE ReportsToid = :contactId AND RecordTypeId = :ConParentTypeId];
        
            // Query the semester term
            hed__Term__c semester = [SELECT Id, Name, Term_Number__c FROM hed__Term__c WHERE Program_Batch__c = :ProgramBatchId AND Term_Number__c = :semesterNum LIMIT 1]; 
              
            Case caseObj = [SELECT Id, ContactId, RecordTypeId, Mentor_Name__c, Mentor_Email__c, Mentor_Mobile__c, Record_Type_Name__c,SRN__c FROM Case where ContactId =: contactId AND Record_Type_Name__c = 'Mentee'];          
    
                //***********************************   Email NOTIFICATIONS    *****************************************/         
            
                        // Send mail to Student
                    sendEmailToStudent(contactObj, parentContactList, semester.Name);                   
                        
                    // Send mail to Parent
                    sendEmailToParent(contactObj,parentContactList, semester.Name);

                        // Send mail to Mentor
                    sendEmailToMentor(caseObj.Mentor_Name__c, semester.Name, contactObj.Name, contactObj.SRN_Number__c, caseObj.Mentor_Mobile__c, caseObj.Mentor_Email__c, contactObj.MobilePhone);
                    
                //*************************************   WHATS APP NOTIFICATIONS    ********************************/ 
                    
                    //Send whatsApp Notification to Student
                    if(contactId != null && semester.Name != null && contactObj.SRN_Number__c != null){
                        RegNotificationForStudent studNotify = new RegNotificationForStudent(contactId,semester.Name,contactObj.SRN_Number__c);
                        Database.Executebatch(studNotify,10);
                    }    
                    //Send whatsApp Notification to Parent
                    if(contactObj != null && parentContactList != null && parentContactList.size() > 0 && semester.Name != null){
                        RegNotificationForParent parentNotify = new RegNotificationForParent(contactObj, parentContactList, semester.Name);
                        Database.Executebatch(parentNotify,10);
                    }

                    //Send whatsApp Notification to Mentor
                    RegNotificationForMentor mentorNotify = new RegNotificationForMentor(caseObj.Mentor_Name__c, semester.Name, contactObj.Name, contactObj.SRN_Number__c, caseObj.Mentor_Mobile__c, contactObj.MobilePhone);
                    Database.Executebatch(mentorNotify,10);

                    return 1;                          
                
        } catch (Exception e) {
            System.debug('Exception occurred while sending email : ' + e.getMessage());
            return -1; // Return -1 for any exception
        }
    }

    public static void sendEmailToStudent(Contact conObj, List<Contact> parentConList, string semesterName){
        try{
            List<String> parentEmailList = new List<String>();
            for(Contact con : parentConList){
                // parentEmailList.add(con.Email);
                if(con.Email != null){
                    parentEmailList.add(con.Email);
                    System.debug('Parent Email -->'+con.Email);
                }
            }
            if(conObj != null && conObj.hed__WorkEmail__c != null && conObj.Name != null && conObj.SRN_Number__c != null){
                    String toEmail = conObj.hed__WorkEmail__c;
                    String studName = conObj.Name;
                    String srnNumber = conObj.SRN_Number__c;
                    OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'REVA Alerts'];
                    // Create email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                    
                    // Set recipient email address
                    email.setToAddresses(new String[] {toEmail});
                    
                    // if(parentEmailList.size() > 0) {
                    //     email.setCCAddresses(parentEmailList);
                    // }
                    
                    email.setSubject('Successful Registration for the academic year '+academicYear); // Set email subject                    
                    email.setPlainTextBody('Dear ' + studName + ',\n\n We are pleased to inform you that your registration for '+semesterName+ ' has been\n '+
                    'completed successfully. Below are the details of your registration.\n\n'+
                    'Student Name: '+studName+ 
                    '\nStudent Registration Number (SRN): '+srnNumber+'\n\n'+             
                    
                    +'Best regards,\n'+'Reva University');
                    if(owea.size() > 0){
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                
                    // Send email
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    if (results[0].isSuccess()) {
                    //  System.debug('Email sent successfully.');
                    //  return 1; // Return 1 indicating success
                    } else {
                        System.debug('Failed to send email. Error: ' + results[0].getErrors()[0].getMessage());
                    //   return 0; // Return 0 indicating failure
                    }
            }        
        }catch(Exception e){
            System.debug('Exception occurred while sending email student: ' + e.getMessage());
           // return -1;
        }        
    }
    
    public static void sendEmailToParent(Contact conObj,List<Contact> parentList, string semesterName){
        try{
            List<String> emailList = new List<String>();
            String studName = conObj.Name;
            String srnNumber = conObj.SRN_Number__c;        
            for(Contact con : parentList){
                if(con.Email != null){
                    emailList.add(con.Email);
                  //  System.debug('Parent Email -->'+con.Email);
                }
            }
            if(conObj != null && parentList.size() > 0 && conObj.Name != null && conObj.SRN_Number__c != null && semesterName != null){
                OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'REVA Alerts'];
                // Create email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(emailList); // Set recipient email address
                email.setSubject('Successful Registration of '+studName+' for the academic year ' +academicYear); // Set email subject                
                email.setPlainTextBody('Dear Parent/Guardian,'+'\n\n We are pleased to inform you that the registration for '+semesterName+ ' of your ward,\n' + studName + ', has been completed successfully. Below are the details of the registration.\n\n'+
                                        'Student Registration Number (SRN): '+srnNumber+ '\n\n'+
                                        'Best regards,\nREVA University');

                if(owea.size() > 0){
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            
                // Send email
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                if (results[0].isSuccess()) {
                    System.debug('Email sent successfully.');
                //  return 1; // Return 1 indicating success
                } else {
                    System.debug('Failed to send email. Error: ' + results[0].getErrors()[0].getMessage());
                //   return 0; // Return 0 indicating failure
                }  
            }            
        //return 1;
       }catch(Exception e){
           System.debug('Exception occurred while sending email to Parent: ' + e.getMessage());
        //   return -1;
       } 
    }    

    public static void sendEmailToMentor(String mentorNameParam, string semNameParam,String studNameParam,String srnNumberParam,
                                        String mobilePhoneParam,String mentorEmailId,String studMobileParam){
            //    System.debug('Mentor Method Input :'+' Mentor Name :'+mentorNameParam+' semName :'+semNameParam+' studName :'+studNameParam+' srnNumber :'+srnNumberParam+
            //     'mobilePhone :'+mobilePhoneParam+' mentorEmailId :'+ mentorEmailId+' studMobile :'+studMobileParam);                             
        try{
            if(mentorNameParam != null && semNameParam != null && studNameParam != null && srnNumberParam != null &&
                mobilePhoneParam != null && mentorEmailId != null && studMobileParam != null){

                OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'REVA Alerts'];            
                // Create email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{mentorEmailId}); // Set recipient email address 
                email.setSubject('Semester Registration'); // Set email subject                
                email.setPlainTextBody('Dear '+mentorNameParam+','+'\n\n Your mentee has successfully registered for the academic year '+academicYear+ '. Please refer to \nthe details below.\n\n'+
                                        'Mentee Name: ' + studNameParam + '\nStudent Registration Number (SRN): '+srnNumberParam+'\n'+'Semester Name: '+semNameParam+'\nMentee Contact: '+studMobileParam+'\n\n'+                                  
                                        'Best regards,\nREVA University');
                if(owea.size() > 0){
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            
                // Send email
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                if (results[0].isSuccess()) {
                //   System.debug('Email sent successfully.');
                //  return 1; // Return 1 indicating success
                } else {
                    System.debug('Failed to send email. Error: ' + results[0].getErrors()[0].getMessage());
                //   return 0; // Return 0 indicating failure
                }           
            }
         //return 1;
       }catch(Exception e){
           System.debug('Exception occurred while Mentor sending email: ' + e.getMessage());
        //   return -1;
       } 
    }
}