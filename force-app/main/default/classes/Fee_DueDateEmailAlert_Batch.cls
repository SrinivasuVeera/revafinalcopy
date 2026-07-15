global class Fee_DueDateEmailAlert_Batch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Fetch contacts that meet specific criteria
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        //Integer yr = Integer.valueOf(System.Label.Due_Date_Email_Alert_Year_Filter);
        
        return Database.getQueryLocator([SELECT Id, Name, Active__c, Quota__c, Last_Notification_Date__c, 
                   ReportsToId, Personal_Email__c, Father_Email_ID__c, Mother_Email_ID__c,Email, Program_Batch_Name__c, Program_Batch__r.hed__Start_Date__c, 
                   hed__WorkEmail__c, Active_Semester__r.hed__Start_Date__c, Active_Semester__r.Term_Number__c
            	FROM Contact WHERE Student_Status__c = 'Pursuing'                
                AND RecordTypeId = :ContactRecTypeId AND Active_Semester__r.Term_Number__c !=1 AND Program_Type__c != 'Ph.D'
            	AND School_Name__c NOT IN ('REVA Academy for Corporate Excellence', 'School of Performing Arts and Indic Studies')
                AND Primary_Academic_Program_Name__c !='Bachelor of Commerce Sanjaynagar' AND (Admission_Mode__c NOT IN ('CET','DCET','PGCET') OR Quota__c !='Government Quota' OR Caste_Category__c NOT IN ('ST','SC'))                         
                AND Program_Batch__r.hed__Start_Date__c != null                
        ]);
    }
    
    global void execute(Database.BatchableContext Bc, List<Contact> lstCon) {
        List<Messaging.SingleEmailMessage> lst_Email = new List<Messaging.SingleEmailMessage>();
        Date todayDt = System.today();
        Id ConParentTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        Set<Id> set_Reportid = new Set<Id>();
        for (Contact con : lstCon) {
            Set<Id> set_BatchIds = new Set<Id>();
            for (hed__Program_Enrollment__c objProgEnroll : [SELECT Id, Active__c, hed__Program_Plan__c, hed__Contact__c FROM hed__Program_Enrollment__c 
                WHERE hed__Contact__c = :con.Id AND Active__c = true
            ]) {
                set_BatchIds.add(objProgEnroll.hed__Program_Plan__c);
            }
            
            if (!set_BatchIds.isEmpty()) {
                // Fetch terms for the active program enrollments
                List<hed__Term__c> lst_term = new List<hed__Term__c>();
                for (hed__Term__c objTerm : [SELECT Id, Name, hed__Start_Date__c,Active__c,Program_Batch__c, Term_Number__c 
                    FROM hed__Term__c WHERE Program_Batch__c IN :set_BatchIds AND hed__Start_Date__c != null AND Active__c = true])
                {
                    lst_term.add(objTerm);
                }
                
                
                for (hed__Term__c sem : lst_term) {
                    String FeeYear = '';
                    if(sem.Term_Number__c == 3)
                    FeeYear = '2nd Year';
                    else if(sem.Term_Number__c == 5)
                        FeeYear = '3rd Year';
                    else if(sem.Term_Number__c == 7)
                        FeeYear = '4th Year';
                    else if(sem.Term_Number__c == 9)
                        FeeYear = '5th Year';
                    Date semesterStartDate = sem.hed__Start_Date__c;
                    
                   // Date fourWeeksBefore = semesterStartDate.addDays(-28);
                    Date sevenDaysBefore = semesterStartDate.addDays(-7);
                    Date thirtyDaysAfter = semesterStartDate.addDays(60);
                    Date fortyFiveDaysAfter = semesterStartDate.addDays(70);
                    Date sixtyDaysAfter = semesterStartDate.addDays(80);
                    
                    // Determine if an email should be sent today
                    Boolean sendEmail = false;
                     if (todayDt == sevenDaysBefore) {
                        sendEmail = true;
                        System.debug('Email should be sent (pre-start date check).');
                    } else if (todayDt > semesterStartDate && todayDt <= thirtyDaysAfter && getDayOfWeek(todayDt) == getDayOfWeek(semesterStartDate)) {
                        sendEmail = true;  // Once a week for the first 30 days
                        System.debug('Email should be sent (weekly for 30 days).');
                    } else if (todayDt > thirtyDaysAfter && todayDt <= fortyFiveDaysAfter && Math.mod(todayDt.daysBetween(thirtyDaysAfter), 3) == 0) {
                        sendEmail = true;  // Every 3 days from 31 to 45 days
                        System.debug('Email should be sent (every 3 days from 31 to 45 days).');
                    } else if (todayDt > fortyFiveDaysAfter && todayDt <= sixtyDaysAfter && Math.mod(todayDt.daysBetween(fortyFiveDaysAfter), 2) == 0) {
                        sendEmail = true;  // Every alternate day from 46 to 60 days
                        System.debug('Email should be sent (every alternate day from 46 to 60 days).');
                    }
                    
                    // Fetch all Student_Fee__c records for the contact with pending amounts
                    List<Student_Fee__c> feeList = [SELECT Id, Name,Fee_Year__c, Due_Date__c, Amount__c, Amount_Paid__c, Amount_Pending__c,Actual_Program_Fee__c 
                                                    FROM Student_Fee__c 
                                                    WHERE Contact__c = :con.Id 
                                                        AND Amount_Pending__c > 0 
                                                    AND Fee_Year__c =:FeeYear and Fee_Type__c IN ('University Fee','Tuition Fee')];
                    system.debug('feeList==='+feeList);
                    // Check if there are any fees due in the semester year
                    if (sendEmail && !feeList.isEmpty()) {
                        set_Reportid.add(con.Id);
                        Messaging.SingleEmailMessage email = createEmailMessage(con, ConParentTypeId, feeList, set_Reportid);
                        lst_Email.add(email);
                        System.debug('Email added to the list for contact: ' + con.Email);
                    }
                }
            }
        }
        
        // Send all accumulated emails
        if (!lst_Email.isEmpty()) {
            Messaging.sendEmail(lst_Email);
            System.debug('Emails sent: ' + lst_Email.size());
        }
    }
    
    // Helper method to get the day of the week as a three-letter abbreviation
    private String getDayOfWeek(Date dt) {
        // Convert Date to DateTime to use the format method
        DateTime dtTime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
        return dtTime.format('E'); // Returns day of the week abbreviation (Mon, Tue, etc.)
    }
    
    // Helper method to create an email message
    private Messaging.SingleEmailMessage createEmailMessage(Contact con, Id ConParentTypeId, List<Student_Fee__c> feeList, Set<Id> set_Reportid) {
        List<String> lst_CCEmail = new List<String>();
        List<String> lst_ToEmail = new List<String>();
        
        String TextBody = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><META http-equiv="Content-Type" content="text/html; charset=utf-8"></head><body>' +
            'Dear ' + con.Name + ',' + '<br>' +
            '<p>Greetings from REVA University!<p>' +
            '<p>This is a reminder that your fees for the current academic year (2025-2026) are pending. We kindly request you to settle the outstanding amount at the earliest to avoid any penalties and ensure uninterrupted academic participation.</p>' +
            '<p>Please find the details of your dues below:<p>' +
            '<table border="1" cellpadding="0" cellspacing="0" width="800px">' +
            '<tr><td style="color:#f57f26;"><center><b>Fee Name</b></center></td>' + '<td style="color:#f57f26;"><center><b>Due Date</b></center></td>' + '<td style="color:#f57f26;"><center><b>Total Amount</b></center></td>' + '<td style="color:#f57f26;"><center><b>Amount Paid</b></center></td>' + '<td style="color:#f57f26;"><center><b>Amount Pending</b></center></td>';
        
        // Iterate through student fees
        for (Student_Fee__c fee : feeList) {
             String strDateOfconf = '';
            if (fee.Due_Date__c != null) {
                strDateOfconf = Datetime.newInstance(fee.Due_Date__c.year(),
                                                     fee.Due_Date__c.month(),
                                                     fee.Due_Date__c.day()).format('dd/MM/yyyy');
            }
            
            // Add fee details to the email body
            TextBody += '<tr>' +
                '<td style="padding: 5px; text-align: center;">' + fee.Name + '</td>' +
                '<td style="padding: 5px; text-align: center;">' + strDateOfconf + '</td>' +
                '<td style="padding: 5px; text-align: center;">' + fee.Amount__c + '</td>' +
                '<td style="padding: 5px; text-align: center;">' + fee.Amount_Paid__c + '</td>' +
                '<td style="padding: 5px; text-align: center;">' + fee.Amount_Pending__c + '</td>' +
                '</tr>';
        }
        
        TextBody += '</table><br>' +
            '<p>Please note that a late payment penalty will be applicable as per the University\'s fee policy. Non-payment may also affect your attendance records and academic progression.</p>'+
            '<p>You can pay your fees easily via the Student Life Cycle Management (SLCM) portal.</p>'+ '<a href="https://reva-university.force.com/StudentPortal/s/student-fee" style="color:#f57f26; margin-top:0pt; margin-bottom:0pt; text-align:center;">Click here to make the Payment...</a>' +
            '<p><b>Important:</b> Please ensure all payments are made exclusively through the SLCM portal. Payments via NEFT or other methods will not be recognized and may lead to unnecessary delays or penalties.</p>'+
            '<p>We urge you to address this matter on priority to avoid disruption in your academic schedule.</p>'+
            '<p>If you have already made the payment, please ignore this message.</p>'+
            '<p>Thank you for your immediate attention.</p>'+            
            '<br>' +
            'Warm regards,<br>' +
            'Office of Finance and Accounts,<br>' +
            'REVA University</p>' +
            '</body></html>';
        
        // Add the Registrar's office email as CC if available
        if (con.hed__WorkEmail__c != null) {
            lst_ToEmail.add(con.hed__WorkEmail__c);
        }
        
        // Add additional contacts as CC recipients if there are any
        if (!set_Reportid.isEmpty()) {
            for (Contact objcon : [
                SELECT Id, Email, ReportsToId 
                FROM Contact 
                WHERE ReportsToId IN :set_Reportid 
                    AND RecordTypeId = :ConParentTypeId 
                    AND Email != null
            ]) {
                lst_CCEmail.add(objcon.Email);
            }
        }
        
        // Create the email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('REVA University - Outstanding Fee Payment Reminder');
        email.setHtmlBody(TextBody);
        email.setToAddresses(lst_ToEmail);
        email.setCcAddresses(lst_CCEmail);
        
        // Set Org-Wide Email Address if available
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts' LIMIT 1];
        if (!owea.isEmpty()) {
            email.setOrgWideEmailAddressId(owea[0].Id);
        }
        
        return email;
    }
    
    global void finish(Database.BatchableContext bc) {
        // Add any finish logic here if needed
    }
}