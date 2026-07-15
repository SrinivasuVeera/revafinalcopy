global class SemesterIAAutomationBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private Map<String, Set<String>> facultyEntryMap = new Map<String, Set<String>>();
    private Map<String, Set<String>> facultyFreezeMap = new Map<String, Set<String>>();
    
    private Set<String> ackSemNames = new Set<String>();
    private Set<String> freezeDirSemNames = new Set<String>();    
    
    private Map<String, Date> semToResultDateMap = new Map<String, Date>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator([SELECT Id, Name, IA_2_End_date__c, IA_2_Result_Date__c FROM hed__Term__c 
            WHERE Active__c = true AND RecordType.Name = 'Semester']);
    }
    
    global void execute(Database.BatchableContext BC, List<hed__Term__c> scope) {
        Date today = Date.today();
        
        for (hed__Term__c sem : scope) {
            semToResultDateMap.put(sem.Name, sem.IA_2_Result_Date__c);
            
            if (sem.IA_2_End_date__c != null && sem.IA_2_End_date__c.addDays(1) == today) {
                collectFacultyInfo(sem.Name, facultyEntryMap);
            }
            
            if (sem.IA_2_Result_Date__c != null) {               
                if (sem.IA_2_Result_Date__c == today) {
                    ackSemNames.add(sem.Name);
                }                
                if (sem.IA_2_Result_Date__c.addDays(5) == today) {
                    collectFacultyInfo(sem.Name, facultyFreezeMap);
                }               
                if (sem.IA_2_Result_Date__c.addDays(9) == today) {
                    freezeDirSemNames.add(sem.Name);
                }
            }
        }
    }
    private void collectFacultyInfo(String semName, Map<String, Set<String>> targetMap) {
        for (hed__Course_Enrollment__c cc : [SELECT hed__Contact__r.hed__WorkEmail__c, Semester_Name__c 
                                             FROM hed__Course_Enrollment__c  
                                             WHERE Active_Connection__c = true AND RecordType.Name = 'Faculty' 
                                             AND Semester_Name__c = :semName 
                                             AND hed__Contact__r.hed__WorkEmail__c != null]) {
                                                 String email = cc.hed__Contact__r.hed__WorkEmail__c;
                                                 if (!targetMap.containsKey(email)) {
                                                     targetMap.put(email, new Set<String>());
                                                 }
                                                 targetMap.get(email).add(cc.Semester_Name__c);
                                             }
    }
    
    global void finish(Database.BatchableContext BC) {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA University' LIMIT 1];
        Id oweaId = owea.size() > 0 ? owea[0].Id : null;
        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
        
        allEmails.addAll(prepareFacultyEmails(facultyEntryMap, 'Entry', oweaId));
        allEmails.addAll(prepareFacultyEmails(facultyFreezeMap, 'Freeze', oweaId));
        
        if (!ackSemNames.isEmpty()) {
            allEmails.addAll(prepareStudentEmails(ackSemNames, oweaId));
            allEmails.addAll(prepareVHEmails(ackSemNames, oweaId));
        }
        
        if (!freezeDirSemNames.isEmpty()) {
            allEmails.addAll(prepareDirectorEmails(freezeDirSemNames, oweaId));
        }
        
        if (!allEmails.isEmpty()) {
            Messaging.sendEmail(allEmails);
        }
    }
    
    private List<Messaging.SingleEmailMessage> prepareFacultyEmails(Map<String, Set<String>> facultyMap, String type, Id oweaId) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (String email : facultyMap.keySet()) {
            String joinedSems = String.join(new List<String>(facultyMap.get(email)), ', ');
            String firstSem = new List<String>(facultyMap.get(email))[0];
            Date resDate = semToResultDateMap.get(firstSem);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if (oweaId != null) mail.setOrgWideEmailAddressId(oweaId);
            mail.setToAddresses(new List<String>{email});
            if (type == 'Entry') {
                String formattedDate = (resDate != null ? resDate.format() : 'the Result Date');
                mail.setSubject('IA Marks Entry Required');
                mail.setHtmlBody('Dear Professor,<br/><br/>' +
                                 'Kindly enter the IA marks in SLCM for the courses you have handled in Semester <b>' + joinedSems + '</b> ' +
                                 'on or before <b>' + formattedDate + '</b> without fail. ' +
                                 'For any clarifications, please reach out to the Examination VH.<br/><br/>Thank you.');
            } else {
                String formattedDatePlus6 = (resDate != null ? resDate.addDays(6).format() : 'IA2 Result Date+6');
                mail.setSubject('Action Required: IA Marks Freeze');
                mail.setHtmlBody('Dear Professor,<br/><br/>' +
                                 'You are requested to verify and validate the IA marks that you have entered in SLCM for the courses you handled in Semester <b>' + joinedSems + '</b> ' +
                                 'and freeze the marks in SLCM on or before <b>' + formattedDatePlus6 + '</b> without fail.<br/><br/>' + 
                                 'Please note that once the IA marks are frozen in SLCM, no further edits will be allowed.<br/><br/>Thank you.');
            }
            emails.add(mail);
        }
        return emails;
    }
    
    private List<Messaging.SingleEmailMessage> prepareStudentEmails(Set<String> semNames, Id oweaId) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Contact std : [SELECT hed__WorkEmail__c, Active_Semester__r.Name FROM Contact 
                            WHERE Active_Semester__r.Name IN :semNames AND Record_Type_Name__c = 'Student' 
                            AND student_status__c = 'Pursuing' AND hed__WorkEmail__c != null]) {
                                
                                Date resDate = semToResultDateMap.get(std.Active_Semester__r.Name);
                                String deadline = resDate != null ? resDate.addDays(5).format() : 'Result Date + 5';
                                
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if (oweaId != null) mail.setOrgWideEmailAddressId(oweaId);
                                mail.setToAddresses(new List<String>{std.hed__WorkEmail__c});
                                mail.setSubject('Verification of IA Marks for Semester ' + std.Active_Semester__r.Name);
                                mail.setHtmlBody('Dear Student,<br/><br/>The IA marks (IA1 and IA2) for the courses of Semester <b>' + std.Active_Semester__r.Name + '</b> ' +
                                                 'have been entered. Please verify and acknowledge in SLCM on or before <b>' + deadline + '</b>.<br/><br/>Thank you.');
                                emails.add(mail);
                            }
        return emails;
    }
    
    private List<Messaging.SingleEmailMessage> prepareVHEmails(Set<String> semNames, Id oweaId) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (hed__Term__c term : [SELECT Name, hed__Account__r.Parent.Examination_Vertical_Head__r.Email,IA_2_Result_Date__c 
                                  FROM hed__Term__c WHERE Name IN :semNames]) {
                                      String vhEmail = term.hed__Account__r.Parent.Examination_Vertical_Head__r.Email;
                                      String deadline = term.IA_2_Result_Date__c != null ? term.IA_2_Result_Date__c.addDays(9).format() : 'Result Date + 9';
                                      if (vhEmail != null) {
                                          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                          if (oweaId != null) mail.setOrgWideEmailAddressId(oweaId);
                                          mail.setToAddresses(new List<String>{vhEmail});
                                          mail.setSubject('Tracking and Freezing of IA Marks for Semester ' + term.Name);               
                                          mail.setHtmlBody('Dear Director,<br/><br/>Kindly track the IA marks entry status for Semester <b>' + term.Name + '</b> ' +
                                                           '. Complete freeze on or before <b>' + deadline + '</b>.<br/><br/>Thank you.');
                                          emails.add(mail);
                                      }
                                  }
        return emails;
    }
    
    private List<Messaging.SingleEmailMessage> prepareDirectorEmails(Set<String> semNames, Id oweaId) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (hed__Term__c term : [SELECT Name, hed__Account__r.Parent.School_Head__r.Email, IA_2_Result_Date__c 
                                  FROM hed__Term__c WHERE Name IN :semNames]) {
                                      String dirEmail = term.hed__Account__r.Parent.School_Head__r.Email;
                                      String deadline = term.IA_2_Result_Date__c != null ? term.IA_2_Result_Date__c.addDays(11).format() : 'Result Date + 11';
                                      
                                      if (dirEmail != null) {
                                          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                          if (oweaId != null) mail.setOrgWideEmailAddressId(oweaId);
                                          mail.setToAddresses(new List<String>{dirEmail});
                                          mail.setSubject('Validation and Approval of IA Marks for Semester ' + term.Name);                
                                          mail.setHtmlBody('Dear Director,<br/><br/>You are requested to approve IA marks for Semester <b>' + term.Name + '</b> ' +
                                                           'and freeze on or before <b>' + deadline + '</b>.<br/><br/>Thank you.');
                                          emails.add(mail);
                                      }
                                  }
        return emails;
    }
}