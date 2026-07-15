public without sharing class BulkHallTicketExtension {
    public List<StudentWrapper> students {get; set;}
    public String assessmentType {get; set;}
    public String StartDate {get; set;}
    public String EndDate {get; set;}
    public Integer SemYear {get; set;}
    public Integer SemNextYear {get; set;}
    public Integer SemesterTerm {get; set;}
    public String evenorooddsem {get; set;}
    
    public BulkHallTicketExtension() {
        students = new List<StudentWrapper>();
        initializeBulkData();
    }
    
    private void initializeBulkData() {
        try {
            String semesterId = ApexPages.currentPage().getParameters().get('semesterId');
            String eligibility = ApexPages.currentPage().getParameters().get('eligibility');
            String selectedIdsParam = ApexPages.currentPage().getParameters().get('selectedIds');
            String studentId = ApexPages.currentPage().getParameters().get('studentId');
            
            List<Id> selectedContactIds = new List<Id>();
        if (String.isNotBlank(selectedIdsParam)) {
            for (String idStr : selectedIdsParam.split(',')) {
                if (String.isNotBlank(idStr)) {
                    selectedContactIds.add(Id.valueOf(idStr.trim()));
                }
            }
        }
            
            if (String.isBlank(semesterId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Semester ID is required'));
                return;
            }
            
            String query = 'SELECT Id, Name, Active_Semester__c, Active_Semester__r.Name, ' +
                      'SRN_Number__c, Active_Semester__r.Term_Number__c, ' +
                      'School_Portal__c, Program_Name__c, Program_Batch_Name__c, ' +
                      'Program_Batch__c, PhotoUrl, File_Passport_Size_Photo__c, ' +
                      'Student_Image__c, Upload_Image__c, Checking_Eligibility_for_Exam__c, HallTicket_QR_Data__c ' +
                      'FROM Contact ' +
                      'WHERE Active_Semester__c = :semesterId ' +
                      'AND Checking_Eligibility_for_Exam__c = :eligibility ' +
                      'AND SRN_Number__c != null';
             if (String.isNotBlank(studentId)) {
                // Single student mode
                query += ' AND Id = :studentId';
            } else if (!selectedContactIds.isEmpty()) {
                query += ' AND Id IN :selectedContactIds';
            } else {
                query += ' ORDER BY SRN_Number__c';
            }

        List<Contact> allStudents = Database.query(query);
            
            if (allStudents.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No eligible students found'));
                return;
            }
            
            // Get exam notifications for this semester (using first student's program batch as reference)
            Id recordTypeId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName().get('hed_IA_Notification').getRecordTypeId();
            List<Rve_Exam_Notification__c> examNotifications = [SELECT Id, Name, Rve_Publish__c, Rve_Semester__c,
                                                                Rve_Semester__r.Term_Number__c, hed_IA_Type__c, 
                                                                rve_Exam_Start_Date__c, Rve_End_Date__c,
                                                                hed_Program_Batch__c
                                                                FROM Rve_Exam_Notification__c 
                                                                WHERE Rve_Publish__c = true 
                                                                AND RecordTypeId = :recordTypeId 
                                                                AND Rve_Semester__c = :semesterId
                                                                LIMIT 1];
            
            if (examNotifications.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No published exam notifications found'));
                return;
            }
            
            Rve_Exam_Notification__c examNotification = examNotifications[0];
            
            // Set common properties for all students
            SemYear = Date.today().year();
            SemNextYear = Math.mod(SemYear + 1, 100);
            
            if (examNotification.Rve_Semester__r.Term_Number__c != null) {
                SemesterTerm = Integer.valueOf(examNotification.Rve_Semester__r.Term_Number__c);
                Integer termNumber = SemesterTerm;
                evenorooddsem = Math.mod(termNumber, 2) == 0 ? 'Even' : 'Odd';
            }
            
            assessmentType = (examNotification.hed_IA_Type__c == 'IA 1') ? 'INTERNAL ASSESSMENT 1' : 'INTERNAL ASSESSMENT 2';
            StartDate = examNotification.rve_Exam_Start_Date__c != null ? convertDate(examNotification.rve_Exam_Start_Date__c) : '';
            EndDate = examNotification.Rve_End_Date__c != null ? convertDate(examNotification.Rve_End_Date__c) : '';
            
            // Get all timeline items for this exam
            List<hed_Time_Table_Line_Item__c> timelineitems = [SELECT Id, Name, Course__c, Course__r.Name, Course__r.hed__Course_ID__c,
                                                              hed_Date__c, hed_Start_Time__c, hed_End_Time__c, 
                                                              Reva_Exam_Notification__c
                                                              FROM hed_Time_Table_Line_Item__c 
                                                              WHERE Reva_Exam_Notification__c = :examNotification.Id];
            
            Set<Id> courseIds = new Set<Id>();
            for (hed_Time_Table_Line_Item__c item : timelineitems) {
                if (item.Course__c != null) {
                    courseIds.add(item.Course__c);
                }
            }
            
            // Process each student
            for (Contact student : allStudents) {
                StudentWrapper wrapper = new StudentWrapper(student);
                
                if(student.HallTicket_QR_Data__c != null){
                	 wrapper.QrData = 'https://quickchart.io/qr?text=' + EncodingUtil.urlEncode(student.HallTicket_QR_Data__c, 'UTF-8');
            	}
                
                // Get passport photo
                wrapper.passportPhotoURL = getPassportPhotoURL(student.Id);
                
                // Get matched line items and time maps
                processStudentTimetable(wrapper, student, timelineitems, courseIds);
                
                students.add(wrapper);
            }
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            System.debug('Line: ' + e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e.getMessage()));
        }
    }
    
    private void processStudentTimetable(StudentWrapper wrapper, Contact student, List<hed_Time_Table_Line_Item__c> timelineitems, Set<Id> courseIds) {
        try {
            // Get student's active courses
            List<hed__Course_Enrollment__c> activeCourseConnections = [SELECT hed__Course_Offering__r.hed__Course__c
                                                                      FROM hed__Course_Enrollment__c
                                                                      WHERE Course_Offered_Semester__c = :student.Active_Semester__r.Name
                                                                      AND Active_Connection__c = true 
                                                                      AND hed__Course_Offering__r.hed__Course__c IN :courseIds
                                                                      AND hed__Contact__c = :student.Id];
            
            Set<Id> activeCourseIds = new Set<Id>();
            for (hed__Course_Enrollment__c conn : activeCourseConnections) {
                if (conn.hed__Course_Offering__r.hed__Course__c != null) {
                    activeCourseIds.add(conn.hed__Course_Offering__r.hed__Course__c);
                }
            }
            
            // Match timetable items
            for (hed_Time_Table_Line_Item__c lineItem : timelineitems) {
                if (lineItem.Course__r != null && activeCourseIds.contains(lineItem.Course__c)) {
                    wrapper.matchedLineItems.add(lineItem);
                    
                    // Populate time maps
                    wrapper.LineItemWithDate.put(lineItem.Id, convertDate(lineItem.hed_Date__c));
                    wrapper.StartTime.put(lineItem.Id, convertTime(lineItem.hed_Start_Time__c));
                    wrapper.EndTime.put(lineItem.Id, convertTime(lineItem.hed_End_Time__c));
                }
            }
        } catch (Exception e) {
            System.debug('Timetable processing error: ' + e.getMessage());
        }
    }
    
    private String getPassportPhotoURL(Id contactId) {
        try {
            String PHOTO_URL_BASE = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=';
            List<ContentDocumentLink> cdls = [SELECT ContentDocument.LatestPublishedVersionId
                                             FROM ContentDocumentLink
                                             WHERE ContentDocument.LatestPublishedVersion.Description = 'Passport Photo'
                                             AND LinkedEntityId = :contactId
                                             LIMIT 1];
            if (!cdls.isEmpty()) {
                return PHOTO_URL_BASE + cdls[0].ContentDocument.LatestPublishedVersionId;
            }
        } catch (Exception e) {
            System.debug('Passport photo error: ' + e.getMessage());
        }
        return null;
    }
    
    public static String convertTime(Time timeVal) {
        if (timeVal == null) return '';
        DateTime dt = DateTime.newInstance(Date.today(), timeVal);
        return dt.format('hh:mm a');
    }
    
    public static String convertDate(Date dateVal) {
        if (dateVal == null) return '';
        DateTime dt = DateTime.newInstance(dateVal.year(), dateVal.month(), dateVal.day());
        return dt.format('dd-MM-yy');
    }
    
    // Wrapper Class
    public class StudentWrapper {
        public Contact student {get; set;}
        public String passportPhotoURL {get; set;}
        public String QrData {get;set;}
        public List<hed_Time_Table_Line_Item__c> matchedLineItems {get; set;}
        public Map<Id, String> LineItemWithDate {get; set;}
        public Map<Id, String> StartTime {get; set;}
        public Map<Id, String> EndTime {get; set;}
        
        public StudentWrapper(Contact con) {
            this.student = con;
            this.matchedLineItems = new List<hed_Time_Table_Line_Item__c>();
            this.LineItemWithDate = new Map<Id, String>();
            this.StartTime = new Map<Id, String>();
            this.EndTime = new Map<Id, String>();
        }
    }
}