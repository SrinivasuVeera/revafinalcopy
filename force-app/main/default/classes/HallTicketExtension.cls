public without sharing class HallTicketExtension {
    public Contact student {get;set;}
    // public list<hed__Plan_Requirement__c> syllabus {get;set;}
    //public String instructions {get;set;}
    public Rve_Exam_Notification__c examNotification {get;set;}
    public String assessmentType {get;set;}
    public list<hed_Time_Table_Line_Item__c> timelineitems {get;set;}
    public list<hed_Time_Table_Line_Item__c> matchedLineItems {get;set;}
    public String SemesterNumber {get;set;}
    public String ExamFormattedDate {get;set;}
    public Map<Id,String> StartTime {get;set;}
    public Map<Id,String> EndTime {get;set;}
    public String StartDate {get;set;}
    public String EndDate {get;set;}
    public Integer SemesterTerm {get;set;}
    public String evenorooddsem {get;set;}
    public Map<Id,String> LineItemWithDate {get;set;}
    public string passportPhotoURL {get;set;}
    public Integer SemYear {get;set;}
    public Integer SemNextYear {get;set;}
    public String QrData {get;set;}
    
    public HallTicketExtension(ApexPages.StandardController controller) {
        LineItemWithDate = new Map<Id,String>();
        timelineitems = new List<hed_Time_Table_Line_Item__c>();
        matchedLineItems = new List<hed_Time_Table_Line_Item__c>();
        StartTime = new Map<Id,string>();
        EndTime = new Map<Id,string>();
        try{
            User usr            = [select id,Name,ContactId from User where Id =: userinfo.getUserId()];
            student 			= [Select Id, Name, Active_Semester__c,Active_Semester__r.Name,SRN_Number__c,Active_Semester__r.Term_Number__c,
                                   School_Portal__c,Program_Name__c,Program_Batch_Name__c,Program_Batch__c,PhotoUrl,
                                   File_Passport_Size_Photo__c,Student_Image__c,Upload_Image__c,HallTicket_QR_Data__c from Contact Where Id =:usr.ContactId];
            
            
            System.debug('teststudent>>'+student);
            if (student.Active_Semester__r.Term_Number__c != null) {
                SemesterNumber = String.valueOf(student.Active_Semester__r.Term_Number__c);
            } else {
                SemesterNumber = 'No Semester Number';
            }
            //   system.debug('SemesterNumber is####'+SemesterNumber);
            SemYear = Date.today().year();
            //  System.debug(SemYear); // Output: Current year (e.g., 2024)
            
            SemNextYear = Math.mod(SemYear + 1, 100);
            //   System.debug(SemNextYear); 
            
            String contactId = student.Id;
            //   System.debug('contactId-->> '+contactId);
            
            String PHOTO_URL_BASE = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=';
            List<ContentDocumentLink> cdls = [select ContentDocument.LatestPublishedVersionId,Visibility 
                                              from ContentDocumentLink
                                              where ContentDocument.LatestPublishedVersion.Description = 'Passport Photo' and 
                                              LinkedEntityId =:contactId];
            System.debug('cdls-->> '+cdls.size());           
            if (cdls.size() > 0) {
                ContentDocumentLink cdl = cdls[0];
                /*   System.debug('ContentDocumentLink-->> '+cdl);
                     System.debug('cdl=> '+cdl.ContentDocument.LatestPublishedVersionId);      */
                passportPhotoURL = PHOTO_URL_BASE + cdl.ContentDocument.LatestPublishedVersionId;      
                // System.debug('passportPhotoURL-->> '+passportPhotoURL);
                
            } 
            
            if(student.HallTicket_QR_Data__c != null){
                QrData = 'https://quickchart.io/qr?text=' + EncodingUtil.urlEncode(student.HallTicket_QR_Data__c, 'UTF-8');
            }
              
            Id recordTypeId 	= Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName().get('hed_IA_Notification').getRecordTypeId();
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
            //	system.debug('SemesterTerm===>'+SemesterTerm);
            /*   system.debug('programbatch'+ student.Program_Batch__c );
                 system.debug('semester'+ student.Active_Semester__c);
                 system.debug('recordtype'+ recordTypeId);
                 system.debug('examNotifications'+ examNotifications.size());*/
            //   System.debug('44=> '+examNotifications.Rve_Semester__r.Term_Number__c);
            assessmentType = '';
            if(!examNotifications.isEmpty() ){
                Integer termNumber;
                if(examNotifications[0].Rve_Semester__r.Term_Number__c != null) {
                    termNumber = Integer.valueOf(examNotifications[0].Rve_Semester__r.Term_Number__c);
                    
                    if (Math.mod(termNumber, 2) == 0) {
                        // Update the string variable to 'Even' if the term number is even
                        evenorooddsem = 'Even';
                    } else {
                        // Update the string variable to 'Odd' if the term number is odd
                        evenorooddsem = 'Odd';
                    }
                    
                    // Print or use the updated value of evenorooddsem as needed
                    // System.debug('Term Number ' + termNumber + ' is ' + evenorooddsem);
                } else {
                    // Handle the case where Term_Number__c is null
                    System.debug('Term Number is null');
                }
                //   system.debug('examNotifications sixe'+ examNotifications);
                
                examNotification	= examNotifications[0];
                //  system.debug('examNotifications sixe'+ examNotification);
                assessmentType		= (examNotification.hed_IA_Type__c == 'IA 1') ? 'INTERNAL ASSESSMENT 1' : 'INTERNAL ASSESSMENT 2';
                if (examNotification.rve_Exam_Start_Date__c != null) {
                    StartDate = convertDate(examNotification.rve_Exam_Start_Date__c);
                }
                
                if (examNotification.Rve_End_Date__c != null) {
                    EndDate = convertDate(examNotification.Rve_End_Date__c);
                }
                
            }
            timelineitems = [select id ,name,Course__c, Course__r.name,Course__r.hed__Course_ID__c,
                             hed_Date__c, hed_Start_Time__c, hed_End_Time__c, Reva_Exam_Notification__c, Reva_Exam_Notification__r.Rve_Semester__r.name,
                             Reva_Exam_Notification__r.Name from hed_Time_Table_Line_Item__c where Reva_Exam_Notification__c =:examNotifications[0].id ];
            
            System.debug('timelineitems=> '+timelineitems);

            set<Id>CourseIds = new set<Id>();
            for(hed_Time_Table_Line_Item__c timetable: timelineitems)
            {
                CourseIds.add(timetable.Course__c);
            }

            list<hed__Course_Enrollment__c>ActiveCourseConnections = [Select Id,Course_Offered_Semester__c,hed__Course_Offering__r.hed__Course__c from hed__Course_Enrollment__c
                                                                      where Course_Offered_Semester__c=:student.active_semester__r.name
                                                                      and Active_Connection__c=true and 
                                                                      hed__Course_Offering__r.hed__Course__c In:CourseIds and hed__Contact__c=:usr.contactId];
            // List of filtered timetable line items
         //   List<hed_Time_Table_Line_Item__c> matchedLineItems = new List<hed_Time_Table_Line_Item__c>();
            
            System.debug('ActiveCourseConnections=> '+ActiveCourseConnections);
            if(!ActiveCourseConnections.isEmpty())
            {
                for(hed__Course_Enrollment__c CourseConn: ActiveCourseConnections)
                {
                    System.debug('CourseConn=> '+CourseConn);
                }
            }
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
            // System.debug('Student : '+student);
            // System.debug('LineItemWithDate : '+LineItemWithDate);
            // System.debug('LineItems=> '+timelineitems);
            // System.debug('examNotifications : '+examNotifications);
            
        }catch(exception e){
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
        }
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
    
}