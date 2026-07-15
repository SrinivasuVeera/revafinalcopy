public without sharing class ExamQRAttendanceController {
    
    	private static final String KEY_NAME = 'DefaultKey';
    	private static Blob cachedKey;          
        
    	@AuraEnabled(cacheable=true)
        public static List<AttendanceCoordinatorWrapper1> getAttendanceCoordinatorData1(){
             List<AttendanceCoordinatorWrapper1> responseList = new List<AttendanceCoordinatorWrapper1>();
             // ---------------------
            //  Query 1
            // ---------------------
            List<rve_Invigilator_Assignment__c> assignList = [
                SELECT Id,
                    rve_Professor__r.Name,
                    Name,
                	rve_Date__c,
                    rve_Exam_Time__c,
                    rve_Exam_End_Time__c,
                    Block_Name__c,
                    rve_Room_Allotment__r.Capacity__c,
                    rve_Room_Allotment__r.Total_Students__c,
                    rve_Room_Allotment__r.Remaining_Capacity__c,
                    rve_Room_Allotment__r.Students__c,
                	rve_Room_Allotment__r.Exam_Name__c,
                	QR_Attendance_Update__c
                FROM rve_Invigilator_Assignment__c
                WHERE Attendance_Co_ordinator__c = :UserInfo.getUserId() 
                ORDER BY Name ASC
            ];
            // WHERE Attendance_Co_ordinator__c = :UserInfo.getUserId()
    		System.debug('assignList :'+assignList);
            // Process each Assignment
            for (rve_Invigilator_Assignment__c rec : assignList) {
    
                AttendanceCoordinatorWrapper1 wrap = new AttendanceCoordinatorWrapper1();
                wrap.recordId = rec.Id;
                wrap.professorName = rec.rve_Professor__r != null ? rec.rve_Professor__r.Name : null;
                wrap.assignmentName = rec.Name;
                wrap.examDate = rec.rve_Date__c;
                wrap.examStart = rec.rve_Exam_Time__c != null ? String.valueOf(rec.rve_Exam_Time__c) : null;
                wrap.examEnd   = rec.rve_Exam_End_Time__c != null ? String.valueOf(rec.rve_Exam_End_Time__c) : null;
                wrap.blockName = rec.Block_Name__c;
    			wrap.programBatchName = rec.rve_Room_Allotment__r.Exam_Name__c;
                wrap.qrAttendanceUpdate = rec.QR_Attendance_Update__c;
                
                wrap.capacity = rec.rve_Room_Allotment__r.Capacity__c;
                wrap.totalStudents = rec.rve_Room_Allotment__r.Total_Students__c;
                wrap.remainingCapacity = rec.rve_Room_Allotment__r.Remaining_Capacity__c;                
                
    
                responseList.add(wrap);
            }
    
            return responseList;
        }
	// ,Date examDate,Time startTime,Time endTime  	
    	
    	@AuraEnabled
        public static List<StudentDataWrapper1> getExamRoomStudentData(String examRoom,String examDate,String startTime,String endTime,String progBatchName) {
            Date d;
            Time st;
            Time et;
        
            if (examDate != null) {
                d = Date.valueOf(examDate); // yyyy-MM-dd
            }
            if (startTime != null) {
               st = parseTime(startTime);
            }
            if (endTime != null) {
                 et = parseTime(endTime);
            }
        
            System.debug('Date=' + d);
            System.debug('Start=' + st);
            System.debug('End=' + et);
        
     /*        List<HallTicketQR__c> studentList = [
                SELECT Id, SRN__c, Contact__r.Name, Attendance_Type__c
                FROM HallTicketQR__c
                WHERE Room__c = :examRoom
                AND Date__c = :d
                AND Start_time__c = :st
                AND End_time__c = :et
            ]; */
            
            List<HallTicketQR__c> studentList = [
                 SELECT Id,Contact__r.Name,Contact__r.Id, Application_Number__c, SRN__c, Date__c, Start_Time__c, End_Time__c, Attendance_Type__c, IA_Type__c,Program_Batch_Name__c 
                 FROM HallTicketQR__c 
             	 WHERE Room__c = :examRoom
                 AND Date__c = :d
                 AND Start_time__c = :st
                 AND End_time__c = :et
            	 AND Program_Batch_Name__c =:progBatchName]; 
        
      /*      List<StudentDataWrapper1> listStudent = new List<StudentDataWrapper1>();
            for (HallTicketQR__c hall : studentList) {
                StudentDataWrapper1 sw = new StudentDataWrapper1();
                sw.srn = hall.SRN__c;
                sw.name = hall.Contact__r != null ? hall.Contact__r.Name : null;
                sw.status = hall.Attendance_Type__c;
                listStudent.add(sw);
            } */
            
            List<StudentDataWrapper1> listStudent = new List<StudentDataWrapper1>();
            for (HallTicketQR__c hall : studentList) {
                StudentDataWrapper1 sw = new StudentDataWrapper1();
                sw.srn = hall.SRN__c;
                sw.name = hall.Contact__r != null ? hall.Contact__r.Name : null;
                sw.status = hall.Attendance_Type__c;
                sw.contactId = hall.Contact__r.Id;
                sw.ApplicationNumber = hall.Application_Number__c;
                sw.examDate = hall.Date__c;
                sw.startTime = hall.Start_time__c;
                sw.endTime = hall.End_time__c;
                sw.IAtype = hall.IA_Type__c; 
                sw.programBatchName = hall.Program_Batch_Name__c;
                listStudent.add(sw);
            }
            return listStudent;
        }
    
    	@AuraEnabled
        public static String updateStudentAttendance(String examRoom,String examDate,String startTime,String endTime,String studSRN) {
            try {
                /* -------------------------
                 * 1. Input validation
                 * ------------------------- */
                if (String.isBlank(examRoom) || String.isBlank(examDate) || String.isBlank(startTime) || String.isBlank(endTime) || String.isBlank(studSRN)) {
                    return 'ERROR: Missing required parameters.';
                }
        
                /* -------------------------
                 * 2. Convert Date & Time
                 * ------------------------- */
                Date examDt;
                Time startTm;
                Time endTm;
        
                try {
                    examDt = Date.valueOf(examDate); // yyyy-MM-dd
                    startTm = parseTime(startTime);
                    endTm   = parseTime(endTime);
                } catch (Exception e) {
                    return 'ERROR: Invalid date or time format.';
                }
        
                /* -------------------------
                 * 3. Fetch record safely
                 * ------------------------- */
                List<HallTicketQR__c> students = [
                    SELECT Id,
                    	   SRN__c,
                           Attendance_Type__c,
                           Scannedby__c,
                           Scanned_Date_Time__c
                    FROM HallTicketQR__c
                    WHERE Room__c = :examRoom
                      AND Date__c = :examDt
                      AND Start_time__c = :startTm
                      AND End_time__c = :endTm
                      AND SRN__c = :studSRN
                    LIMIT 1
                ];
        
                if (students.isEmpty()) {
                    return 'ERROR: No student record found.';
                }
        
                HallTicketQR__c student = students[0];
        
                /* -------------------------
                 * 4. Update record safely
                 * ------------------------- */
                if (student.Attendance_Type__c == true) {
                    return 'INFO: Attendance already marked.';
                }
        		
                student.Attendance_Type__c = true;
                student.Scanned_Date_Time__c = System.now();
                student.Scannedby__c = UserInfo.getUserId();  //:UserInfo.getUserId() 
        
                update student;
        
                /* -------------------------
                 * 5. Success response
                 * ------------------------- */
                return 'SUCCESS: Attendance updated successfully.';
        
            } catch (DmlException dmlEx) {
                return 'ERROR: Unable to update attendance.';
            } catch (Exception ex) {
                return 'ERROR: Unexpected error occurred.';
            }
        }   
    	
    	@AuraEnabled
        public static String updateFinalAttendance(String examRoom,String examDate,String startTime,String endTime,String programBatchName){
            Date d;
            Time st;
            Time et;
        
            if (examDate != null) {
                d = Date.valueOf(examDate); // yyyy-MM-dd
            }
            if (startTime != null) {
               st = parseTime(startTime);
            }
            if (endTime != null) {
                 et = parseTime(endTime);
            }
        
            System.debug('Date=' + d);
            System.debug('Start=' + st);
            System.debug('End=' + et);
        
     /*        List<HallTicketQR__c> studentList = [
                SELECT Id, SRN__c, Contact__r.Name, Attendance_Type__c
                FROM HallTicketQR__c
                WHERE Room__c = :examRoom
                AND Date__c = :d
                AND Start_time__c = :st
                AND End_time__c = :et
            ]; */
            
            List<HallTicketQR__c> studentList = [
                 SELECT Id,Contact__r.Id, Application_Number__c, SRN__c, Date__c, Start_Time__c, End_Time__c, Attendance_Type__c, IA_Type__c,Program_Batch_Name__c
                 FROM HallTicketQR__c 
             	 WHERE Room__c = :examRoom
                 AND Date__c = :d
                 AND Start_time__c = :st
                 AND End_time__c = :et
            	 AND Program_Batch_Name__c =: programBatchName];
            
            List<rve_Invigilator_Assignment__c> assignments = [
                SELECT Id, QR_Attendance_Update__c 
                FROM rve_Invigilator_Assignment__c 
                WHERE Name =: examRoom 
                AND rve_Date__c = :d 
                AND rve_Exam_Time__c = :st 
                AND rve_Exam_End_Time__c = :et  
                AND rve_Room_Allotment__r.Exam_Name__c =: programBatchName
            ];            
            
            if (assignments.isEmpty()) {
                System.debug('ERROR : No Invigilator Assignments Found');
                   return 'ERROR: No student record found.';                 
            }
             if (studentList.isEmpty()) {
                 System.debug('ERROR : No Records Found  Hall ticket QR');
                    return 'ERROR: No student record found.';               
            }
        
            rve_Invigilator_Assignment__c recAssignment = assignments[0];
            
            List<hed__Attendance_Event__c> recordsToInsert = new List<hed__Attendance_Event__c>();  
            for(HallTicketQR__c hallQR : studentList){                             
                hed__Attendance_Event__c attEventRec = new hed__Attendance_Event__c(
                    hed__Contact__c = hallQR.Contact__r.Id,
                    hed__Date__c = hallQR.Date__c,
                    hed__Start_Time__c = hallQR.Start_time__c,
                    hed__End_Time__c = hallQR.End_time__c,
                    hed__Attendance_Type__c = hallQR.Attendance_Type__c == true ? 'Present' : 'Absent',
                    IA_Type__c = hallQR.IA_Type__c                     
                ); 
                recordsToInsert.add(attEventRec);
            }
            
             if (!recordsToInsert.isEmpty()) {            
             	insert recordsToInsert;
                recAssignment.QR_Attendance_Update__c = true; 
                update recAssignment;
       		 }
            return 'SUCCESS';
        }
    
    	@AuraEnabled
        public static StudentWrapper decryptQR(String qrData,String examRoom,String examDate,String startTime,String endTime) {
            System.debug('Input QR Data : ' + qrData);        
            try {
                // 1️⃣ Validate QR format
                if (String.isBlank(qrData)) {
                    return messagePack('failure', 'Invalid QR format.');
                }
                
                if (String.isBlank(examRoom) || String.isBlank(examDate) || String.isBlank(startTime) || String.isBlank(endTime)) {                    
                    return messagePack('failure', 'Missing required parameters.');
                }
        
                List<String> parts = qrData.split(':');
                if (parts.size() != 3) {
                    return messagePack('failure', 'Invalid or tampered QR data.');
                }
        
                // 2️⃣ Decode QR parts
                Blob iv, cipherText, receivedHmac;
                try {
                    iv           = EncodingUtil.base64Decode(parts[0]);
                    cipherText   = EncodingUtil.base64Decode(parts[1]);
                    receivedHmac = EncodingUtil.base64Decode(parts[2]);
                } catch (Exception e) {
                    return messagePack('failure', 'Invalid QR encoding.');
                }
        
                // 3️⃣ Load AES key (same key used for encryption + HMAC)
                QR_Key_Store__mdt rec = [
                    SELECT AES_Key__c
                    FROM QR_Key_Store__mdt
                    WHERE DeveloperName = 'DefaultKey' AND Is_Active__c = true 
                    LIMIT 1
                ];
        
                if (String.isBlank(rec.AES_Key__c)) {
                    //'Encryption key not configured.'
                    return messagePack('failure', 'configuration issue');
                }
        
                Blob key = EncodingUtil.base64Decode(rec.AES_Key__c);
        
                // 4️⃣ Verify HMAC (tamper detection)
                String macInput = parts[0] + parts[1];
        
                Blob expectedHmac = Crypto.generateMac(
                    'HmacSHA256',
                    Blob.valueOf(macInput),
                    key
                );
        
                if (!expectedHmac.equals(receivedHmac)) {
                    return messagePack('failure', 'QR data has been tampered.');
                }
        
                // 5️⃣ Decrypt payload
                Blob decrypted;
                try {
                    decrypted = Crypto.decrypt(
                        'AES256',
                        key,
                        iv,
                        cipherText
                    );
                } catch (Exception e) {
                    return messagePack('failure', 'QR decryption failed.');
                }
        
                String decryptedJson = decrypted.toString();
                
                System.debug('decryptedJson :: '+decryptedJson);
        
                // 6️⃣ Parse decrypted JSON
                Map<String, Object> data;
                try {
                    data = (Map<String, Object>) JSON.deserializeUntyped(decryptedJson);
                } catch (Exception e) {
                    return messagePack('failure', 'Invalid decrypted data.');
                }
        
                String srn = (String) data.get('SRN');               
                String examType = (String) data.get('ExamType');
                String semName = (String) data.get('SemName');
                
                System.debug('srn : '+srn +'<<+>>'+'examType : '+examType+'<<+>>'+'semName : '+semName);
        
                if (String.isBlank(srn)) {
                    return messagePack('failure', 'SRN missing in QR.');
                }
                if (String.isBlank(examType)) {
                    return messagePack('failure', 'IA Type missing in QR.');
                }
                if (String.isBlank(semName)) {
                    return messagePack('failure', 'Semester Name missing in QR.');
                }
                
                // 7️⃣ Validate SRN in Hall Ticket
           /*     List<Hall_Ticket__c> htsList = [
                    SELECT Id, SRN__c, Is_Active__c, Scanned_Status__c,
                           CourseCode__c, StartDate__c, StartTime__c, EndTime__c
                    FROM Hall_Ticket__c
                    WHERE SRN__c = :srn
                    AND CourseCode__c = :CC
                    LIMIT 1
                ]; */
                
                /* -------------------------
                 * 1. Input validation
                 * ------------------------- */
          /*      if (String.isBlank(examRoom) || String.isBlank(examDate) || String.isBlank(startTime) || String.isBlank(endTime)) {                    
                    return messagePack('failure', 'Missing required parameters.');
                } */
        
                /* -------------------------
                 * 2. Convert Date & Time
                 * ------------------------- */
                Date examDt;
                Time startTm;
                Time endTm;
        
                try {
                    examDt = Date.valueOf(examDate); // yyyy-MM-dd
                    startTm = parseTime(startTime);
                    endTm   = parseTime(endTime);
                } catch (Exception e) {
                     return messagePack('failure', 'Invalid date or time format.');                    
                }
                
                List<HallTicketQR__c> htsList = [
                    SELECT Id, SRN__c, Attendance_Type__c 
                	FROM HallTicketQR__c WHERE SRN__c = :srn AND IA_Type__c = :examType 
                    AND Room__c =: examRoom AND Date__c =: examDt AND Start_time__c =: startTm AND End_time__c =: endTm LIMIT 1
                ];
        
                if (htsList.isEmpty()) {
                    // 'Invalid SRN.'
                    return messagePack('failure', 'Student Not Allotted to Current Exam Hall');
                }
        
                HallTicketQR__c ht = htsList[0];
        		System.debug('Selected Record : '+ht);
                if (ht.Attendance_Type__c) {
                    return messagePack('failure', 'Caution: SRN already registered.');
                }
        
                // 8️⃣ Continue with your existing timetable logic
                StudentWrapper studentData = getStudentData(srn);
                System.debug('studentData : '+studentData);
                List<hed_Time_Table_Line_Item__c> matchedLineItems1 = new List<hed_Time_Table_Line_Item__c>();
        		System.debug('studentData.matchedLineItems : '+studentData.matchedLineItems);
                if (!studentData.matchedLineItems.isEmpty()) {
                    for (hed_Time_Table_Line_Item__c lineItem : studentData.matchedLineItems) {
        
                        Datetime startDT = Datetime.newInstance(
                            lineItem.hed_Date__c,
                            lineItem.hed_Start_Time__c
                        );
                        Datetime endDT = Datetime.newInstance(
                            lineItem.hed_Date__c,
                            lineItem.hed_End_Time__c
                        );
        				System.debug('System.now : '+System.now());
                        System.debug('startDT : '+startDT+'  '+'endDT : '+endDT);
                        if (System.now() >= startDT && System.now() <= endDT) {
                            matchedLineItems1.add(lineItem);
                            studentData.matchedLineItems = matchedLineItems1;
                            return messagePack('success', 'QR decoded successfully.', studentData);
                        }
                    }
                }
        
                return messagePack('failure', 'Error: Current time is NOT within the timetable window.');
            }
            catch (Exception ex) {
                return messagePack('failure', 'QR validation failed.');
            }
        }
    
    	@AuraEnabled(cacheable=true)
        public static StudentWrapper getStudentData(String srnNumber) {
            StudentWrapper wrapper = new StudentWrapper();
          //  try{        
            String semesterNumber;
            Integer SemesterTerm;
            list<hed_Time_Table_Line_Item__c> timelineitems = new List<hed_Time_Table_Line_Item__c>();
            list<hed_Time_Table_Line_Item__c> matchedLineItems = new List<hed_Time_Table_Line_Item__c>();
            Map<Id,String> LineItemWithDate = new Map<Id,String>();
            Map<Id,String> StartTime = new Map<Id,string>();
            Map<Id,String> EndTime = new Map<Id,string>();
            
            Contact student = [
                Select Id, Name, Active_Semester__c,Active_Semester__r.Name,SRN_Number__c,Active_Semester__r.Term_Number__c,
                       School_Portal__c,Program_Name__c,Program_Batch_Name__c,Program_Batch__c,PhotoUrl,Checking_Eligibility_for_Exam__c,Exam_Approval__c,
                       File_Passport_Size_Photo__c,Student_Image__c,Upload_Image__c,Description 
                FROM Contact
                WHERE SRN_Number__c = :srnNumber
                LIMIT 1
            ];
    
            System.debug('Student Data=> '+student);
            
            String passportPhotoURL;
            String PHOTO_URL_BASE = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=';
    
            List<ContentDocumentLink> cdls = [
                SELECT ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE ContentDocument.LatestPublishedVersion.Description = 'Passport Photo'
                AND LinkedEntityId = :student.Id
                LIMIT 1
            ];
    
            if (!cdls.isEmpty()) {
                passportPhotoURL = PHOTO_URL_BASE + cdls[0].ContentDocument.LatestPublishedVersionId;
            } else {
                passportPhotoURL = student.PhotoUrl; // fallback to default
            }
            
            if (student.Active_Semester__r.Term_Number__c != null) {
                    semesterNumber = String.valueOf(student.Active_Semester__r.Term_Number__c);
              } else {
                    semesterNumber = 'No Semester Number';
            }
            System.debug('semesterNumber :'+semesterNumber);
            Id recordTypeId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName().get('hed_IA_Notification').getRecordTypeId();
                //  System.debug('recordTypeId=> '+recordTypeId);
                //  SYstem.debug('ProgramBatch=> '+student.Program_Batch__c);
                List<Rve_Exam_Notification__c> examNotifications = [Select Id, Name, Rve_Publish__c, Rve_Semester__c,
                                                                    Rve_Semester__r.Term_Number__c,hed_IA_Type__c,rve_Exam_Start_Date__c, Rve_End_Date__c From Rve_Exam_Notification__c Where
                                                                    Rve_Publish__c=true AND RecordTypeId =:recordTypeId AND hed_Program_Batch__c =:student.Program_Batch__c];
                
                System.debug('examNotifications=> '+examNotifications);
                if(!examNotifications.isEmpty())
                {
                    SemesterTerm = Integer.valueOf(examNotifications[0].Rve_Semester__r.Term_Number__c);
                }
                System.debug('SemesterTerm : '+SemesterTerm);	
            
                timelineitems = [select id ,name,Course__c, Course__r.name,Course__r.hed__Course_ID__c,
                                 hed_Date__c, hed_Start_Time__c, hed_End_Time__c, Reva_Exam_Notification__c, Reva_Exam_Notification__r.Rve_Semester__r.name,
                                 Reva_Exam_Notification__r.Name from hed_Time_Table_Line_Item__c where Reva_Exam_Notification__c =:examNotifications[0].id ];
                
                System.debug('timelineitems=> '+timelineitems);
    
                set<Id>CourseIds = new set<Id>();
                for(hed_Time_Table_Line_Item__c timetable: timelineitems)
                {
                    CourseIds.add(timetable.Course__c);
                }
                
                System.debug('CourseIds=> '+CourseIds);
            
                list<hed__Course_Enrollment__c>ActiveCourseConnections = [Select Id,Course_Offered_Semester__c,hed__Course_Offering__r.hed__Course__c from hed__Course_Enrollment__c
                                                                          where Course_Offered_Semester__c=:student.active_semester__r.name
                                                                          and Active_Connection__c=true and 
                                                                          hed__Course_Offering__r.hed__Course__c In:CourseIds and hed__Contact__c=:student.Id]; // hed__Contact__c=:usr.contactId
            
                System.debug('ActiveCourseConnections=> '+ActiveCourseConnections);
                // Create a Set of course IDs from ActiveCourseConnections for faster lookups
                Set<Id> activeCourseIds = new Set<Id>();
                if(!ActiveCourseConnections.isEmpty()){
                    for (hed__Course_Enrollment__c courseConnection : ActiveCourseConnections) {
                        if (courseConnection.hed__Course_Offering__r.hed__Course__c != null) {
                            activeCourseIds.add(courseConnection.hed__Course_Offering__r.hed__Course__c);
                        }
                    }
                }
                System.debug('activeCourseIds=> '+activeCourseIds);
            
                // Iterate through timetable line items and add matching ones to the new list
                if(!timelineitems.isEmpty()){
                    for (hed_Time_Table_Line_Item__c lineItem : timelineitems) {
                        System.debug('139=> '+activeCourseIds.contains(lineItem.Course__c));
                        if (lineItem.Course__r != null && activeCourseIds.contains(lineItem.Course__c)) { 
                            matchedLineItems.add(lineItem);
                        } 
                        
                       /* 
                         // Combine the date and time fields into full DateTimes
                         Datetime startDT = Datetime.newInstance(lineItem.hed_Date__c, lineItem.hed_Start_Time__c);
                         Datetime endDT   = Datetime.newInstance(lineItem.hed_Date__c, lineItem.hed_End_Time__c);
                        if (lineItem.Course__r != null && activeCourseIds.contains(lineItem.Course__c)) {                        
                            // Compare with current datetime
                            if (System.now() >= startDT && System.now() <= endDT) {
                                System.debug('✅ Current time is within the timetable window.');
                                matchedLineItems.add(lineItem);
                            } else {
                                System.debug('❌ Current time is NOT within the timetable window.');
                            }                        
                        } */ 
                    }
                }
                // Debug or use the matchedLineItems list as needed
                System.debug('Matched Line Items: ' + matchedLineItems.size());
            
            
                
                //  system.debug('timelineitems size'+ timelineitems.size());
                // System.debug('timelineitems=> '+timelineitems);
                for(hed_Time_Table_Line_Item__c lineitems : matchedLineItems){
                    
                    String FormattedDate = convertDate(lineitems.hed_Date__c);
                    LineItemWithDate.put(lineitems.Id,FormattedDate);
                    // System.debug('111=> '+LineItemWithDate);
                    string startTimes = convertTime(lineitems.hed_Start_Time__c);
                    StartTime.put(lineitems.Id,startTimes);
                    
                    // System.debug('StartTime=> '+startTimes);
                    string endtimes =  convertTime(lineitems.hed_End_Time__c);                           
                    EndTime.put(lineitems.Id,endtimes);
                    // System.debug('EndTime=> '+endtimes);
                    // System.debug('lineitems : '+lineitems);
                    String semesterName = lineitems.Reva_Exam_Notification__r.Rve_Semester__r.name;
                    SemesterNumber = semesterName.trim().split(' ')[semesterName.trim().split(' ').size() - 1];
                    System.debug('SemesterNumber=> '+SemesterNumber);
                }
          //  }catch(exception e){
          //      System.debug(e.getLineNumber());
          //      System.debug(e.getMessage());
         //   }
         
                    // Wrapper
                    wrapper.status = 'success';
                    wrapper.message = 'success';
                    wrapper.name = student.Name;
                    wrapper.srn = student.SRN_Number__c;
                    wrapper.schoolPortal = student.School_Portal__c;
                    wrapper.programName = student.Program_Name__c;
                    wrapper.semester = student.Active_Semester__r.Name;
                    wrapper.photoUrl = passportPhotoURL;
                    wrapper.semesterNumber = semesterNumber;
                    wrapper.SemesterTerm = SemesterTerm;
                    wrapper.timelineitems = timelineitems;
                    wrapper.matchedLineItems = matchedLineItems;
                    wrapper.LineItemWithDate = LineItemWithDate;
                    wrapper.StartTime = StartTime;
                    wrapper.EndTime = EndTime;
            
           return wrapper;
        }
    
    	/*	@AuraEnabled
            public static String validateStudent(String srn) {
                System.debug('Validating Student SRN: ' + srn );
        
                // Simulate validation logic
                if (String.isBlank(srn)) {
                    return 'Missing SRN or Course Code.';
                }
                
                List<HallTicketQR__c> htsList = [
                    SELECT Id, SRN__c, Attendance_Type__c
                    FROM HallTicketQR__c
                    WHERE SRN__c = :srn 
                    LIMIT 1
                ];
                
                HallTicketQR__c ht = htsList[0];
           
                ht.Attendance_Type__c = true; 
                update ht;
        
                return 'success';         
            } */
    
    /**************************************** Helper class Start **********************************/
    	@TestVisible
    	private static Time parseTime(String timeStr) {
            if (String.isBlank(timeStr)) return null;
        
            timeStr = timeStr.replace('Z', '');
            if (timeStr.contains('.')) {
                timeStr = timeStr.split('\\.')[0];
            }
        
            List<String> t = timeStr.split(':');
            return Time.newInstance(
                Integer.valueOf(t[0]),
                Integer.valueOf(t[1]),
                Integer.valueOf(t[2]),
                0
            );
		}
   
    	public class StudentDataWrapper1 {            
            @AuraEnabled public String srn;
            @AuraEnabled public String name;
            @AuraEnabled public Boolean status; // Tick/Cross // Attendance_Type__c
            @AuraEnabled public Id contactId;
            @AuraEnabled public String ApplicationNumber;
			@AuraEnabled public Date examDate;
			@AuraEnabled public Time startTime;
			@AuraEnabled public Time endTime;
			@AuraEnabled public String IAtype; // IA1 | IA2	
            @AuraEnabled public String programBatchName;
    	}
    
    	public class AttendanceCoordinatorWrapper1 {
            @AuraEnabled public Id recordId;
            @AuraEnabled public String professorName;
            @AuraEnabled public String assignmentName;
            @AuraEnabled public Date examDate;
            @AuraEnabled public String examStart;
			@AuraEnabled public String examEnd;
            @AuraEnabled public String blockName;
    		@AuraEnabled public String programBatchName;
            @AuraEnabled public Boolean qrAttendanceUpdate;
            
            // Screen 2 Data
            @AuraEnabled public Decimal capacity;
            @AuraEnabled public Decimal totalStudents;
            @AuraEnabled public Decimal remainingCapacity;
          //  @AuraEnabled public List<StudentDataWrapper> students;            
    	}
    
    	public class StudentWrapper {
            @AuraEnabled public String status { get; set; }
            @AuraEnabled public String message { get; set; }
            @AuraEnabled public String name { get; set; }
            @AuraEnabled public String srn { get; set; }
            @AuraEnabled public String schoolPortal { get; set; }
            @AuraEnabled public String programName { get; set; }
            @AuraEnabled public String semester { get; set; }
            @AuraEnabled public String photoUrl { get; set; }
            @AuraEnabled public String semesterNumber { get; set; }
            @AuraEnabled public Integer SemesterTerm { get; set; }
            @AuraEnabled public list<hed_Time_Table_Line_Item__c> timelineitems { get; set; }
            @AuraEnabled public list<hed_Time_Table_Line_Item__c> matchedLineItems {get;set;}
            @AuraEnabled public Map<Id,String> LineItemWithDate {get;set;}
            @AuraEnabled public Map<Id,String> StartTime {get;set;}
            @AuraEnabled public Map<Id,String> EndTime {get;set;}
        } 
    
    	public static StudentWrapper messagePack(String status, String msg){
            StudentWrapper wrapper = new StudentWrapper();
                    wrapper.status = status;
                    wrapper.message = msg;
                    wrapper.name = '';
                    wrapper.srn = '';
                    wrapper.schoolPortal = '';
                    wrapper.programName = '';
                    wrapper.semester = '';
                    wrapper.photoUrl = '';
                    wrapper.semesterNumber = '';
                    wrapper.SemesterTerm = 0;
                    wrapper.timelineitems = new List<hed_Time_Table_Line_Item__c>();
                    wrapper.matchedLineItems = new List<hed_Time_Table_Line_Item__c>();
                    wrapper.LineItemWithDate = new Map<Id, String>();
                    wrapper.StartTime = new Map<Id, String>();
                    wrapper.EndTime = new Map<Id, String>();
                   
            return wrapper;
    	}
    
    	public static StudentWrapper messagePack(String status, String msg, StudentWrapper data) {
            StudentWrapper wrapper = data != null ? data : new StudentWrapper();
            wrapper.status = status;
            wrapper.message = msg;
            return wrapper;
        }
    
    	public static string convertTime(Time TimeToBeConverted){
            // system.debug('TimeToBeConverted-->'+TimeToBeConverted);
            //  Time parsedTime = Time.valueOf(TimeToBeConverted.substring(0, 8));
            DateTime dateTime1 = DateTime.newInstance(Date.today(), TimeToBeConverted);
            String formattedTime = dateTime1.format('hh:mm a');
            // System.debug(formattedTime); // Output: 08:30 AM
            return  formattedTime;
        }
    
    	public static string convertDate(Date DateToBeConverted){
            Date examDate = DateToBeConverted;
            DateTime examDateTime = DateTime.newInstance(examDate.year(), examDate.month(), examDate.day());
            String ExamFormattedDate = examDateTime.format('dd-MM-yy');
            //  System.debug(ExamFormattedDate); // O;utput: 06-04-24
            return ExamFormattedDate;
        }
    
   /**************************************** Helper class Ends **********************************/    
    
   
    
}