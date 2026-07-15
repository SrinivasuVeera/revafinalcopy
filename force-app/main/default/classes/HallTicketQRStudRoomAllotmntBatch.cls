global class HallTicketQRStudRoomAllotmntBatch implements Database.Batchable<SObject>, Database.Stateful {  
    
    /**     
     * Description   : Batch class to generate HallTicketQR records for eligible
     *                 students based on invigilator assignments, exam name,
     *                 and exam date.    
     *
     * Notes         : - Processes records in bulk using Batch Apex
     *                 - Handles SRN-based student mapping
     *                 - Designed for scalable exam hall ticket generation
     * Developer     : Santoshkumar Bangarimath
     * Created Date  : 23-Dec-2025
     */
    
    private String examName;
    private Date examDate;
    
    // Error tracking
    global List<String> errorLogs = new List<String>();

    // Constructor
    global HallTicketQRStudRoomAllotmntBatch(String examName, Date examDate) {
        this.examName = examName;
        this.examDate = examDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id,
                   rve_Date__c,
                   rve_Exam_Time__c,
                   rve_Exam_End_Time__c,
                   rve_Room_Allotment__r.Room__c,
                   rve_Room_Allotment__r.IA_Type__c,
                   rve_Room_Allotment__r.Students__c
            FROM rve_Invigilator_Assignment__c
            WHERE rve_Room_Allotment__r.Exam_Name__c = :examName
              AND rve_Date__c = :examDate
        ]);
    }

    global void execute(Database.BatchableContext bc,
                        List<rve_Invigilator_Assignment__c> scope) {

        Set<String> srnSet = new Set<String>();

        // Collect SRNs
        for (rve_Invigilator_Assignment__c rec : scope) {
            if (rec.rve_Room_Allotment__r != null &&
                rec.rve_Room_Allotment__r.Students__c != null) {

                for (String srn :
                     rec.rve_Room_Allotment__r.Students__c.split(',')) {
                    srnSet.add(srn.trim());
                }
            }
        }

        if (srnSet.isEmpty()) return;

        // Query Students
        Map<String, Contact> srnStudentMap = new Map<String, Contact>();
        for (Contact c : [
            SELECT Id,
                   SRN_Number__c,
                   Application_Number__c,
                   Program_Batch__r.Name
            FROM Contact
            WHERE SRN_Number__c IN :srnSet
              AND Record_Type_Name__c = 'Student'
              AND Student_Status__c = 'Pursuing'
              AND Active__c = TRUE
        ]) {
            srnStudentMap.put(c.SRN_Number__c, c);
        }

        List<HallTicketQR__c> hallTicketList = new List<HallTicketQR__c>();

        for (rve_Invigilator_Assignment__c rec : scope) {

            if (rec.rve_Room_Allotment__r == null ||
                rec.rve_Room_Allotment__r.Students__c == null) continue;

            for (String srn :
                 rec.rve_Room_Allotment__r.Students__c.split(',')) {

                srn = srn.trim();
                if (!srnStudentMap.containsKey(srn)) continue;

                Contact con = srnStudentMap.get(srn);

                HallTicketQR__c ht = new HallTicketQR__c(
                    Application_Number__c = con.Application_Number__c,
                    Attendance_Type__c = false,
                    Contact__c = con.Id,
                    Date__c = examDate,
                    IA_Type__c = rec.rve_Room_Allotment__r.IA_Type__c,
                    Program_Batch_Name__c = con.Program_Batch__r.Name,
                    Room__c = rec.rve_Room_Allotment__r.Room__c,                
                    Scannedby__c = null,
                    Scanned_Date_Time__c = null,                 
                    slot__c = 0,
                    SRN__c = con.SRN_Number__c,
                    Start_time__c = rec.rve_Exam_Time__c,
                    End_time__c = rec.rve_Exam_End_Time__c,
                    Submitted_status__c = false
                );

                hallTicketList.add(ht);
            }
        }

        if (!hallTicketList.isEmpty()) {
            Database.SaveResult[] results =
                Database.insert(hallTicketList, false);

            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    errorLogs.add(
                        'Failed SRN: ' + hallTicketList[i].SRN__c +
                        ' - ' + results[i].getErrors()[0].getMessage()
                    );
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (!errorLogs.isEmpty()) {
            System.debug('Batch completed with errors: ' + errorLogs);
        }
    }
}

// Run In anonymous window
 /*   Database.executeBatch(
    new HallTicketQRStudRoomAllotmntBatch(
        'B. Tech in Artificial Intelligence and Data Science-(2023-2027)',
        Date.newInstance(2025, 12, 13)
    ),
    200 ); */