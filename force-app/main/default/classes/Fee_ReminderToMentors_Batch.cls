global class Fee_ReminderToMentors_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        
        return Database.getQueryLocator([
            SELECT Id, Name, hed__WorkEmail__c
            FROM Contact 
            WHERE RecordTypeId = :contactRecTypeId 
                AND Account_Name__c != 'REVA Academy for Corporate Excellence' 
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Contact> lstCon) {
        try {
            for (Contact professor : lstCon) {
                List<Case> relatedCases = [
                    SELECT Id
                    FROM Case
                    WHERE ContactId = :professor.Id
                    LIMIT 1
                ];
                
                if (!relatedCases.isEmpty()) {
                    Case professorCase = relatedCases[0];

                    List<CaseTeamMember> caseTeamMembers = [
                        SELECT MemberId
                        FROM CaseTeamMember
                        WHERE ParentId = :professorCase.Id
                    ];
                    
                    if (!caseTeamMembers.isEmpty()) {
                        Set<Id> memberIds = new Set<Id>();
                        for (CaseTeamMember ctm : caseTeamMembers) {
                            memberIds.add(ctm.MemberId);
                        }

                        Id studentRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
                        List<Student_Fee__c> fees = [
                            SELECT Contact__c, Due_Date__c, Amount_Pending__c
                            FROM Student_Fee__c
                            WHERE Due_Date__c <= TODAY  
                                AND Amount_Pending__c > 0 
                                AND Contact__c IN :memberIds 
                                AND Contact__r.Student_Status__c = 'Pursuing' 
                                AND Contact__r.RecordTypeId = :studentRecTypeId
                        ];

                        if (!fees.isEmpty()) {
                            Map<Id, List<Student_Fee__c>> studentFeesMap = new Map<Id, List<Student_Fee__c>>();
                            for (Student_Fee__c fee : fees) {
                                if (!studentFeesMap.containsKey(fee.Contact__c)) {
                                    studentFeesMap.put(fee.Contact__c, new List<Student_Fee__c>());
                                }
                                studentFeesMap.get(fee.Contact__c).add(fee);
                            }

                            List<Contact> students = [
                                SELECT Id, Name, SRN_Number__c, hed__WorkEmail__c, Application_Number__c
                                FROM Contact 
                                WHERE Id IN :studentFeesMap.keySet()
                            ];

                            List<string> lst_ToEmail = new List<string>();
                            if (professor.hed__WorkEmail__c != null && professor.hed__WorkEmail__c.contains('@')) {
                                lst_ToEmail.add(professor.hed__WorkEmail__c);
                            }

                            List<OrgWideEmailAddress> oweaList = [
                                SELECT Id 
                                FROM OrgWideEmailAddress 
                                WHERE DisplayName = 'REVA Alerts' 
                                LIMIT 1
                            ];

                            if (!oweaList.isEmpty()) {
                                OrgWideEmailAddress owea = oweaList[0];
                                String emailBody = '<p>Dear Mr/ Ms. Mentor ' + professor.Name + ',</p>' +
                                    '<p>This is a reminder about the upcoming Fee Payment deadlines for your mentees.</p>' +
                                    '<table border="1" cellpadding="0" cellspacing="0" width="800px">' +
                                    '<tr>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>SRN Number</b></td>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>Application Number</b></td>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>Student Name</b></td>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>Total Pending Amount</b></td>' +
                                    '<td style="color:#f57f26;padding: 5px;text-align: center;"><b>Due Date</b></td>' +
                                    '</tr>';
                                
                                for (Contact student : students) {
                                    List<Student_Fee__c> studentFees = studentFeesMap.get(student.Id);
                                    if (studentFees != null && !studentFees.isEmpty()) {
                                        Decimal totalPendingAmount = 0;
                                        Date earliestDueDate = null;
									String strDateOfconf = '';
                                    String srnnumber = '';
                                        
                                        for (Student_Fee__c fee : studentFees) {
                                            totalPendingAmount += fee.Amount_Pending__c;
                                            if (earliestDueDate == null || fee.Due_Date__c < earliestDueDate) {
                                                earliestDueDate = fee.Due_Date__c;
                                            }
                                        }

                                        strDateOfconf = earliestDueDate != null ? DateTime.newInstance(earliestDueDate.year(), earliestDueDate.month(), earliestDueDate.day()).format('dd/MM/yyyy') : '';
                                        emailBody += '<tr>' +
                                            '<td style="padding: 5px;text-align: center;">' + student.SRN_Number__c + '</td>' +
                                            '<td style="padding: 5px;text-align: center;">' + student.Application_Number__c + '</td>' +
                                            '<td style="padding: 5px;text-align: center;">' + student.Name + '</td>' +
                                            '<td style="padding: 5px; text-align: center;">' + totalPendingAmount + '</td>' +
                                            '<td style="padding: 5px;text-align: center;">' + strDateOfconf + '</td>' +
                                            '</tr>';
                                    }
                                }

                                emailBody += '</table>' +
                                    '<p>Please ensure your mentees are aware of the upcoming deadlines and take the necessary steps for fee payment.</p>' +
                                    '<p>Thank you for your attention to this matter.</p>' +
                                    '<p><b>Note:</b> In case the mentee has paid the fee and is not updated in the Student Portal, please ask the mentee to reach out to the Accounts Department, 1st Floor, Admin Block.</p>' +
                                    '<p>The mentee will not be allowed to write IA if the outstanding is not cleared.</p>' +
                                    '<p>Sincerely,<br>Office of Finance and Accounts,<br>REVA University</p>';

                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.setToAddresses(lst_ToEmail);
                                email.setSubject('Fee Payment Reminder For Your Mentees');
                                email.setHtmlBody(emailBody);
                                email.setOrgWideEmailAddressId(owea.Id);

                                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error in execute method: ' + e.getMessage());
            System.debug('Error in execute getcause method: ' + e.getCause());
            System.debug('Error in execute getLineNumber method: ' + e.getLineNumber());
            System.debug('Error in execute getStackTraceString method: ' + e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Implement the finish logic if needed
    }
}