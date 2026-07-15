global class HallTicketQRStudRoomAllotmntBatch1 implements Database.Batchable<SObject>, Database.Stateful {  
    
    /**     
     * Description   : Batch class to generate HallTicketQR records for eligible
     *                 students based on invigilator assignments, exam name,
     *                 and exam date.    
     *
     * Notes         : - Processes records in bulk using Batch Apex
     *                 - Handles SRN-based student mapping
     *                 - Designed for scalable exam hall ticket generation
     * 
     
     */
    
  //  private List<String> room;
    private Date examDate;
    
    // Error tracking
    global List<String> errorLogs = new List<String>();

    // Constructor
    global HallTicketQRStudRoomAllotmntBatch1(Date examDate) {
      //  this.room = room;
        this.examDate = examDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            /*SELECT Id,
                   rve_Date__c,
                   rve_Exam_Time__c,
                   rve_Exam_End_Time__c,
                   rve_Room_Allotment__r.Room__c,
                   rve_Room_Allotment__r.IA_Type__c,
                   rve_Room_Allotment__r.Students__c
            FROM rve_Invigilator_Assignment__c
            WHERE rve_Room_Allotment__r.Exam_Name__c = :examName
              AND rve_Date__c = :examDate*/
             SELECT Id,
            		Room__c,
            		IA_Type__c,
            		rve_Date_of_Exam__c,
            		Exam_Time__c,
            		End_Time__c,
            		Students__c
      		FROM IA_Seating_Room_Allotment__c 
            WHERE rve_Date_of_Exam__c =: examDate AND Active__c = true            
        ]);
    }

    global void execute(Database.BatchableContext bc,
                        List<IA_Seating_Room_Allotment__c> scope) {

        Set<String> srnSet = new Set<String>();
		Map<String, Set<String>> roomDataMap = new Map<String, Set<String>>();
                            
		   
        // Collect SRNs
        for (IA_Seating_Room_Allotment__c rec : scope) {
            if (rec.Room__c != null &&
                rec.Students__c != null) {

                for (String srn :
                     rec.Students__c.split(',')) {
                    srnSet.add(srn.trim());
                }
              roomDataMap.put(rec.Room__c, srnSet);
            }
        }

        if (roomDataMap.isEmpty()) return;

        // Query Students
        Map<String, Contact> srnStudentMap = new Map<String, Contact>();
        Map<String,Map<String,Contact>> roomWithContactMap = new Map<String,Map<String,Contact>>();
                            
		for (String roomNo : roomDataMap.keySet()) {            
            
            System.debug('Room: ' + roomNo);
    		Set<String> srnSetVal = roomDataMap.get(roomNo);   
            
            for (Contact c : [
                SELECT Id,
                       SRN_Number__c,
                       Application_Number__c,
                       Program_Batch__r.Name
                FROM Contact
                WHERE SRN_Number__c IN :srnSetVal
                  AND Record_Type_Name__c = 'Student'
                  AND Student_Status__c = 'Pursuing'
                  AND Active__c = TRUE
            ]) {
                if (!srnStudentMap.containsKey(c.SRN_Number__c)) {
                	srnStudentMap.put(c.SRN_Number__c, c);
                }
                roomWithContactMap.put(roomNo,srnStudentMap);
            }
        }

        List<HallTicketQR__c> hallTicketList = new List<HallTicketQR__c>();

        for (IA_Seating_Room_Allotment__c rec : scope) {

            if (rec.Room__c == null ||
                rec.Students__c == null) continue;

            for (String srn :
                 rec.Students__c.split(',')) {

                srn = srn.trim();
                if (!srnStudentMap.containsKey(srn)) continue;

                Contact con = srnStudentMap.get(srn);

                HallTicketQR__c ht = new HallTicketQR__c(
                    Application_Number__c = con.Application_Number__c,
                    Attendance_Type__c = false,
                    Contact__c = con.Id,
                    Date__c = examDate,
                    IA_Type__c = rec.IA_Type__c,
                    Program_Batch_Name__c = con.Program_Batch__r.Name,
                    Room__c = rec.Room__c,                
                    Scannedby__c = null,
                    Scanned_Date_Time__c = null,                 
                    slot__c = 0,
                    SRN__c = con.SRN_Number__c,
                    Start_time__c = rec.Exam_Time__c,
                    End_time__c = rec.End_Time__c,
                    Submitted_status__c = false
                );

                hallTicketList.add(ht);
            }
        }
                            
          System.debug('Size Of HallTicket ::::'+hallTicketList.size());

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