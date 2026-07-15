public without sharing class rve_IAExamApproval {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getContacts() {
        try {
            Map<String, Object> result = new Map<String, Object>();
            System.debug('STEP 1: Method Started - getContacts');
            
            // Step 2: Querying Contacts
            List<Contact> contacts = [
                SELECT Id, SRN_Number__c, Name, Active_Semester__c, Checking_Eligibility_for_Exam__c, Program_Batch__c, Program_Batch__r.Name,
                School__r.School_Head__c, School__r.Examination_Vertical_Head__c, Application_Number__c, Total_average_current_sem_attendance__c
                FROM Contact 
                WHERE Active__c = true 
                AND Checking_Eligibility_for_Exam__c = 'InEligible' 
                AND Student_Status__c = 'pursuing' 
                AND (School__r.School_Head__c = :UserInfo.getUserId() 
                     OR School__r.Examination_Vertical_Head__c = :UserInfo.getUserId()) 
                ORDER BY SRN_Number__c
            ];
            System.debug('STEP 2: Contacts fetched => ' + contacts);
            
            Boolean isVerticalHead = false;
            if (!contacts.isEmpty()) {
                isVerticalHead = contacts[0].School__r.School_Head__c == UserInfo.getUserId();
                System.debug('STEP 3: isVerticalHead => ' + isVerticalHead);
            //}
            
            Set<Id> contactIds = new Set<Id>();
            Set<Id> ProgrambatchId = new Set<Id>();
            Set<Id> semId = new Set<Id>();
            for (Contact con : contacts) {
                if (con.Active_Semester__c != null) {
                    semId.add(con.Active_Semester__c);
                    contactIds.add(con.Id);
                    if (con.Program_Batch__c != null) {
                        ProgrambatchId.add(con.Program_Batch__c);
                    }
                }
            }
            System.debug('STEP 4: ContactIds => ' + contactIds);
            System.debug('STEP 4: ProgramBatchIds => ' + ProgrambatchId);
            
            Date today = Date.today();
            Date Threedays_From_Today = System.today().adddays(Integer.valueOf(System.label.HallTicketScheduleTime));
            System.debug('STEP 5: Today => ' + today + ', 3 days from today => ' + Threedays_From_Today);
            /*******************Newly added***************************/
            Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Rve_Exam_Notification__c']) {
            recordTypeMap.put(rt.Name, rt.Id);
        }
            /********************ended here************************************/
            List<Rve_Exam_Notification__c> examNotifications = [
                SELECT Id, hed_IA_Type__c, rve_Exam_Start_Date__c, Rve_Semester__r.IA_1_End_date__c, Rve_Semester__r.IA_2_End_date__c,
                Rve_Semester__c, hed_Program_Batch__c, rve_Active__c,RecordTypeId,Rve_Semester__r.Exam_Start_Date__c,
                Rve_Semester__r.hed__Start_Date__c,Rve_Semester__r.Exam_End_Date__c,Rve_Semester__r.hed__End_Date__c,RecordType.Name
                FROM Rve_Exam_Notification__c
                WHERE Rve_Publish__c = true
                AND rve_Active__c =true
                AND Rve_Semester__c IN :semId
                //AND hed_Program_Batch__c IN :ProgrambatchId
                AND rve_Exam_Start_Date__c <= :Threedays_From_Today
            ];
            System.debug('STEP 6: ExamNotifications fetched => ' + examNotifications);
            
            Map<Id, List<Rve_Exam_Notification__c>> programBatchToNotifications = new Map<Id, List<Rve_Exam_Notification__c>>();
            for (Rve_Exam_Notification__c exam : examNotifications) {
                if (!programBatchToNotifications.containsKey(exam.hed_Program_Batch__c)) {
                    programBatchToNotifications.put(exam.hed_Program_Batch__c, new List<Rve_Exam_Notification__c>());
                }
                programBatchToNotifications.get(exam.hed_Program_Batch__c).add(exam);
            }
            System.debug('STEP 7: programBatchToNotifications map => ' + programBatchToNotifications);
            
            List<Contact> eligibleContacts = new List<Contact>();
           // Id recordtypeOfrevExamNot = [select Id,Name from RecordType where sObjectType='Rve_Exam_Notification__c' LIMIT 1].id;
            for (Contact con : contacts) {
                if (!programBatchToNotifications.containsKey(con.Program_Batch__c)) continue;
                
               /* Boolean shouldDisplay = false;
                
                for (Rve_Exam_Notification__c exam : programBatchToNotifications.get(con.Program_Batch__c)) {
                    Date displayFrom = exam.rve_Exam_Start_Date__c != null ? exam.rve_Exam_Start_Date__c.addDays(-2) : null;
                    Date displayTo;
                    
                   // if (exam.hed_IA_Type__c == 'IA 1' && exam.RecordTypeId ==recordtypeOfrevExamNot ) {
                      if (exam.hed_IA_Type__c == 'IA 1' && exam.RecordTypeId == recordTypeMap.get('IA Notification') ) {
                        displayTo = exam.Rve_Semester__r.IA_1_End_date__c;
                    //} else if (exam.hed_IA_Type__c == 'IA 2' && exam.RecordTypeId ==recordtypeOfrevExamNot ) {
                      } else if (exam.hed_IA_Type__c == 'IA 2' && exam.RecordTypeId ==recordTypeMap.get('IA Notification') ) {
                        displayTo = exam.Rve_Semester__r.IA_2_End_date__c;
                    } else if (exam.RecordType.Name == 'Semester Notification') {
                        displayTo = exam.Rve_Semester__r.Exam_End_Date__c;
                    }
                   
                    
                    if (displayFrom != null && displayTo != null && today >= displayFrom && today <= displayTo) {
                        shouldDisplay = true;
                        break;
                    }
                }*/
                
             //  if (shouldDisplay) {
                    eligibleContacts.add(con);
               // }
            }
            System.debug('STEP 8: Eligible Contacts => ' + eligibleContacts);
            
            Boolean exist_examinationNotification = examNotifications.isEmpty();
            System.debug('STEP 9: exist_examinationNotification => ' + exist_examinationNotification);
            
            Map<Id, Decimal> pendingAmountMap = new Map<Id, Decimal>();
            if (!eligibleContacts.isEmpty()) {
                List<Student_Fee__c> feeList = [
                    SELECT Contact__c, Amount_Pending__c
                    FROM Student_Fee__c
                    WHERE Contact__c IN :eligibleContacts AND Due_Date__c <= TODAY AND Amount_Pending__c > 0
                ];
                System.debug('STEP 10: Student Fees fetched => ' + feeList);
                
                for (Student_Fee__c fee : feeList) {
                    if (!pendingAmountMap.containsKey(fee.Contact__c)) {
                        pendingAmountMap.put(fee.Contact__c, 0);
                    }
                    pendingAmountMap.put(fee.Contact__c, pendingAmountMap.get(fee.Contact__c) + fee.Amount_Pending__c);
                }
            }
            System.debug('STEP 11: pendingAmountMap => ' + pendingAmountMap);
            
            result.put('pendingAmounts', pendingAmountMap);
            result.put('contacts', eligibleContacts);
            result.put('isVerticalHead', isVerticalHead);
            result.put('exist_examinationNotification', exist_examinationNotification);
        } else{
            result.put('pendingAmounts', null);
            result.put('contacts', null);
            result.put('isVerticalHead', null);
            result.put('exist_examinationNotification', true);

        }
            System.debug('STEP 12: Final Result => ' + result);
            return result;
        } catch (Exception e) {
            System.debug('ERROR Line => ' + e.getLineNumber() + ' Message => ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
   
    @AuraEnabled
    public static void updateContacts(List<Contact> contacts) {
        Set<Id> contactIds = new Set<Id>();
        for (Contact con : contacts) {
            contactIds.add(con.Id);
        }
        // Re-query contacts to get all required fields
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, Name, Active_Semester__c, Exam_Approval__c, Description,Active_Semester__r.Name
            FROM Contact
            WHERE Id IN :contactIds
        ]);
        List<Contact> updatedContacts = new List<Contact>();
        List<Exam_Approval_History__c> historyRecords = new List<Exam_Approval_History__c>();
        for (Contact inputCon : contacts) {
            Contact fullCon = contactMap.get(inputCon.Id);
            fullCon.Exam_Approval__c = inputCon.Exam_Approval__c;
            fullCon.Description = inputCon.Description;
            updatedContacts.add(fullCon);
            if (inputCon.Exam_Approval__c == true) {
                Exam_Approval_History__c history = new Exam_Approval_History__c();
                history.Contact__c = fullCon.Id;
                history.Semester__c = fullCon.Active_Semester__c;
                history.Approved_By__c = UserInfo.getUserId();
                history.Approved_Date__c = Date.today();
                history.Comments__c = inputCon.Description;
                // Set custom Name value
                if (fullCon.Name != null && fullCon.Active_Semester__c != null) {
                    history.Name = fullCon.Name + ' - ' + fullCon.Active_Semester__r.Name;
                }
                history.Approved__c = TRUE;
                historyRecords.add(history);
            }
        }
        if (!updatedContacts.isEmpty()) {
            update contacts;
        }
        if (!historyRecords.isEmpty()) {
            insert historyRecords;
        }
    }
}