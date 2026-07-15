global class Fee_WhatsAppCommunication implements Database.Batchable<sObject>, Database.AllowsCallouts {   
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        return Database.getQueryLocator([
            SELECT Id, Name, MobilePhone, ReportsToId, hed__WorkEmail__c, 
            Active_Semester__r.hed__Start_Date__c, Active_Semester__r.Term_Number__c
            FROM Contact 
            WHERE Student_Status__c = 'Pursuing'                
            AND RecordTypeId = :contactRecTypeId 
            AND Active_Semester__r.Term_Number__c != 1 
            AND Program_Type__c != 'Ph.D'
            //AND id = '003J400000J0AncIAF'
            AND School_Name__c NOT IN ('REVA Academy for Corporate Excellence', 'School of Performing Arts and Indic Studies')
            AND Primary_Academic_Program_Name__c != 'Bachelor of Commerce Sanjaynagar' 
            AND (Admission_Mode__c NOT IN ('CET','DCET','PGCET') OR Quota__c != 'Government Quota' OR Caste_Category__c NOT IN ('ST','SC'))                         
            AND Program_Batch__r.hed__Start_Date__c != null                
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> lstCon) {
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        Set<Id> studentIds = new Map<Id, SObject>(lstCon).keySet();
        Date todayDt = System.today();
        Map<Id, Contact> studentIdToParentMap = new Map<Id, Contact>();        
        
        Id parentRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        List<Contact> parentContacts = [
            SELECT Id, MobilePhone, ReportsToId 
            FROM Contact 
            WHERE ReportsToId IN :studentIds AND RecordTypeId = :parentRecTypeId
        ];
        for (Contact parent : parentContacts) {
            studentIdToParentMap.put(parent.ReportsToId, parent);
        }
        
        for (Contact con : lstCon) {
            Set<Id> set_BatchIds = new Set<Id>();
            for (hed__Program_Enrollment__c objProgEnroll : [
                SELECT Id, hed__Program_Plan__c 
                FROM hed__Program_Enrollment__c 
                WHERE hed__Contact__c = :con.Id AND Active__c = true
            ]) {
                set_BatchIds.add(objProgEnroll.hed__Program_Plan__c);
            }
            
            if (!set_BatchIds.isEmpty()) {
                List<hed__Term__c> lst_term = [
                    SELECT Id, hed__Start_Date__c, Term_Number__c 
                    FROM hed__Term__c 
                    WHERE Program_Batch__c IN :set_BatchIds AND hed__Start_Date__c != null AND Active__c = true
                ];
                
                for (hed__Term__c sem : lst_term) {
                    String feeYear = '';
                    if (sem.Term_Number__c == 3) feeYear = '2nd Year';
                    else if (sem.Term_Number__c == 5) feeYear = '3rd Year';
                    else if (sem.Term_Number__c == 7) feeYear = '4th Year';
                    else if (sem.Term_Number__c == 9) feeYear = '5th Year';
                    
                    if (String.isBlank(feeYear)) continue;
                    
                    Date semesterStartDate = sem.hed__Start_Date__c;
                    Date sevenDaysBefore = semesterStartDate.addDays(-6);
                    Date sixtyDaysAfter = semesterStartDate.addDays(61);
                    Date seventyDaysAfter = semesterStartDate.addDays(71);
                    Date eightyDaysAfter = semesterStartDate.addDays(81);
                    
                    boolean sendMessage = false;
                    if (todayDt == sevenDaysBefore) {
                        sendMessage = true;
                    } else if (todayDt > semesterStartDate && todayDt <= sixtyDaysAfter && getDayOfWeek(todayDt) == getDayOfWeek(semesterStartDate)) {
                        sendMessage = true;
                    } else if (todayDt > sixtyDaysAfter && todayDt <= seventyDaysAfter && Math.mod(todayDt.daysBetween(sixtyDaysAfter), 3) == 0) {
                        sendMessage = true;
                    } else if (todayDt > seventyDaysAfter && todayDt <= eightyDaysAfter && Math.mod(todayDt.daysBetween(seventyDaysAfter), 2) == 0) {
                        sendMessage = true;
                    }
                    
                    if (sendMessage) {
                        List<Student_Fee__c> feeList = [SELECT Id, Due_Date__c, Amount_Pending__c 
                                                        FROM Student_Fee__c WHERE Contact__c = :con.Id AND Amount_Pending__c > 0 AND Fee_Year__c = :feeYear AND Fee_Type__c IN ('University Fee', 'Tuition Fee')
                                                       ];
                        
                        if (!feeList.isEmpty()) {
                            Decimal totalPendingAmount = 0;
                            Date earliestDueDate;
                            
                            for (Student_Fee__c fee : feeList) {
                                totalPendingAmount += fee.Amount_Pending__c;
                                if (earliestDueDate == null || fee.Due_Date__c < earliestDueDate) {
                                    earliestDueDate = fee.Due_Date__c;
                                }
                            }
                            
                            if (!String.isBlank(con.MobilePhone)) {
                                Yellow_AI_Utility.WhatsAppNotification studentNotification = createWhatsAppMessage(con.Name, totalPendingAmount, earliestDueDate,'Student');
                                if (!phoneNumbersToNotifications.containsKey(con.MobilePhone)) {
                                    phoneNumbersToNotifications.put(con.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
                                }
                                phoneNumbersToNotifications.get(con.MobilePhone).add(studentNotification);
                            }
                            
                            if (studentIdToParentMap.containsKey(con.id)) {
                                Contact parent = studentIdToParentMap.get(con.id);
                                if (!String.isBlank(parent.MobilePhone)) {
                                    Yellow_AI_Utility.WhatsAppNotification parentNotification = createWhatsAppMessage(con.Name, totalPendingAmount, earliestDueDate,'Parent');
                                    if (!phoneNumbersToNotifications.containsKey(parent.MobilePhone)) {
                                        phoneNumbersToNotifications.put(parent.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
                                    }
                                    phoneNumbersToNotifications.get(parent.MobilePhone).add(parentNotification);
                                }
                            }
                        }
                    }
                }
            }
        }
        if (!phoneNumbersToNotifications.isEmpty()) {
            try {
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response status: ' + response.getStatusCode());
                System.debug('Response body: ' + response.getBody());
            } catch (Exception e) {
                System.debug('Exception while sending WhatsApp notifications: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {        
        
    }
    
    private String getDayOfWeek(Date dt) {
        DateTime dtTime = DateTime.newInstance(dt.year(), dt.month(), dt.day());
        return dtTime.format('E');
    }
    
    private Yellow_AI_Utility.WhatsAppNotification createWhatsAppMessage(String studentName, Decimal pendingAmount, Date dueDate,String recipientType) {
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'fee_payment_reminder_2025';
        notification.params = new Map<String, String>();
        if (recipientType == 'Parent') {
            notification.params.put('StudentName', 'Parent'); 
        } else {
            notification.params.put('StudentName', String.isNotBlank(studentName) ? studentName : 'Student');
        }
        //notification.params.put('StudentName', studentName != null ? studentName : 'Student');
        notification.params.put('Amount_Pending', String.valueOf(pendingAmount));
        notification.params.put('Fee_Due_Date', dueDate.format());
        return notification;
    }
}