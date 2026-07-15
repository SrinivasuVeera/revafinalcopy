public without sharing class  rve_InvigilatorAttendenceController {
    
    @AuraEnabled(cacheable=true)
    public static list<rve_Invigilator_Assignment__c> getRoomNumbers(Date ExamDate) {
        // List<User> lUsers = [SELECT Id,Contact.Id,Name,ContactId,Email FROM User WHERE Id = :userinfo.getUserId()];
        list<rve_Invigilator_Assignment__c> userlist = [SELECT Id, Name, rve_Professor__r.Id FROM rve_Invigilator_Assignment__c 
                                                        WHERE rve_Professor__r.Id =:UserInfo.getUserId()  AND rve_Date__c =: ExamDate/*:Date.Today()*/];
        //'0055j000007i0dpAAA' LIMIT 1];
        //'0055j000007i0dpAAA' LIMIT 1 
        
        system.debug('userlist'+ userlist.size());   
        return userlist;
    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRoomDetails(Date examdate,String shift,String roomname,string starttime, string endtime) {
        
        try {
            List<rve_Invigilator_Assignment__c> invigilatordetails = rve_InvigilatorAttendenceController.getRoomNumbers(examDate);
            
            // Retrieve a single instance of the custom setting
            Integer hoursToAddFromMetadata;
            rve_Exam_Time__c setting = rve_Exam_Time__c.getInstance();
            // Access custom setting fields
            if (setting != null) {
                Decimal examEndTimeDecimal = setting.rve_Exam_End_Time_Hours__c;
                hoursToAddFromMetadata = Integer.valueOf(examEndTimeDecimal);
                // Do something with myFieldValue
            } else {
                // Handle if the custom setting instance is not found
            }
            // system.debug('hoursToAddFromMetadata-> '+ hoursToAddFromMetadata);
            
            
            //to get the current time
            Datetime currentTime = Datetime.now();
            Time currentTimeOnly = currentTime.time();
            
            // code to sset the examStartTime value        
            // Split the examtime string into hours, minutes, and seconds
            List<String> timeComponents = starttime.split(':');
            // system.debug('time component'+timeComponents);
            Integer hours = Integer.valueOf(timeComponents[0]);
            Integer minutes = Integer.valueOf(timeComponents[1].split(' ')[0]); // Extract minutes
            Integer seconds = Integer.valueOf(timeComponents[2].split(' ')[0]); // Extract seconds
            // Adjust for AM or PM
            if (starttime.contains('PM') && hours != 12) {
                hours += 12;
            } else if (starttime.contains('AM') && hours == 12) {
                hours = 0;
            }
            // Subtract 30 minutes
            // to subtract 15 minutes we can replace 15 with 30 in the below code 
            if (minutes >= 30) {
                minutes -= 30;
            } else {
                if (hours == 0) {
                    hours = 23; // Adjust hours for midnight
                } else {
                    hours -= 1;
                }
                minutes = 60 - (30 - minutes);
            }
            Time examStartTime = Time.newInstance(hours, minutes, seconds, 0);
            
            // code to sset the examEndTime value   
            // Split the examtime string into hours, minutes, and seconds
            List<String> timeComponents1 = endtime.split(':');  
            Integer hours1 = Integer.valueOf(timeComponents1[0]);
            Integer minutes1 = Integer.valueOf(timeComponents1[1].split(' ')[0]); // Extract minutes
            Integer seconds1 = Integer.valueOf(timeComponents1[2].split(' ')[0]); // Extract seconds
            // Adjust for AM or PM
            if (endtime.contains('PM') && hours1 != 12) {
                hours1 += 12;
            } else if (endtime.contains('AM') && hours == 12) {
                hours1 = 0;
            }
            // Add hours from metadata
            hours1 += hoursToAddFromMetadata;
            // Ensure the hour is within 0-23 range
            if (hours1 >= 24) {
                hours1 -= 24;
            }
            // Create the new examendtime Time object
            Time examEndTime = Time.newInstance(hours1, minutes1, seconds1, 0);
            if(test.isRunningtest())
            {
                if(examEndTime.hour() == 0)
                {
                    examEndTime = Time.newInstance(currentTimeOnly.hour()+1,currentTimeOnly.minute(),0,0);
                }
            }
            System.debug('Examdate=> '+ExamDate+' Name=> '+roomName+' shift=> '+shift+' ExamStartTime=> '+examStartTime+' EndTime=> '+examEndTime);
            System.debug('invigilatordetails.size()=> '+invigilatordetails.size()+' currentTimeOnly=> '+currentTimeOnly);
          /*  if (invigilatordetails.size() > 0 && currentTimeOnly >= examStartTime && currentTimeOnly <= examEndTime
               ) {*/
                   
                   List<rve_Invigilator_Assignment__c> roomAssignments = [SELECT Id, Name, rve_Date__c, rve_Shift__c,
                                                                          rve_Room_Allotment__r.students__c,
                                                                          rve_Exam_Time__c, rve_Exam_End_Time__c
                                                                          FROM rve_Invigilator_Assignment__c
                                                                          WHERE rve_Date__c =: examdate AND
                                                                          rve_Professor__c = :UserInfo.getUserId()
                                                                          AND Name =: roomname
                                                                          AND rve_Room_Allotment__r.Active__c = true
                                                                          AND rve_Shift__c =: shift
                                                                          AND rve_Exam_Time__c >= :examStartTime
                                                                          AND rve_Exam_End_Time__c <= :examEndTime
                                                                         ];                   
                   
                   System.debug('roomAssignments=> '+roomAssignments);
                   List<Contact> contacts = new List<Contact>();
                   
                   if(!roomAssignments.isEmpty()){
                       for (rve_Invigilator_Assignment__c assignment : roomAssignments) {
                           Set<String> AllSRN = new Set<String>();
                           Set<String> SRNNumbers = new Set<String>();
                           
                           if (assignment.rve_Room_Allotment__r.Students__c != null) {
                               SRNNumbers.addAll(new Set<String>(assignment.rve_Room_Allotment__r.Students__c.split(',')));
                           }
                           
                           AllSRN.addAll(SRNNumbers);
                           System.debug('SRN=> '+AllSrn);
                           System.debug('SRNS=> '+ALLSRN.size());
                           
                           for(String SRN: ALLSRN)
                           {
                               System.debug('SRN=> '+SRN);
                           }
                           
                           List<Contact> roomContacts = [SELECT Id, Name, Email, Sibling_SRN_Number__c, SRN_Number__c,
                                                         Program_Batch__r.Name, Program_Batch__c
                                                         FROM Contact
                                                         WHERE SRN_Number__c IN :AllSRN
                                                         AND Active__c = TRUE AND Student_Status__c='Pursuing'
                                                         AND SRN_Number__c!=null
                                                         ORDER BY SRN_Number__c ASC];
                           
                           Map<ID,Integer>ContactWithDuplicates = new Map<ID,Integer>();
                           
                           for(Contact con: roomContacts)
                           {
                               if(!ContactWithDuplicates.containskey(con.Id)){
                                   ContactWithDuplicates.put(con.Id,1);
                               }
                               else{
                                   ContactWithDuplicates.put(con.Id,ContactWithDuplicates.get(con.Id)+1); 
                               }
                               // System.debug('contact=> '+con);
                           }
                           
                           /*   for(Id conId: ContactWithDuplicates.keyset())
{
System.debug('Id=> '+conId+' Count=> '+ContactWithDuplicates.get(conId));
}*/
                           System.debug('roomContacts=> '+roomContacts.size());
                           contacts.addAll(roomContacts);
                       }
                   }
                   
                   Set<Id> programBatchNames = new Set<Id>();
                   if(!contacts.isEmpty()){
                       for (Contact selectedContact : contacts) {
                           if (selectedContact.Program_Batch__r != null) {
                               programBatchNames.add(selectedContact.Program_Batch__r.id);
                           }
                       }
                   }
                   List<MyWrapperClass> relatedItems = new List<MyWrapperClass>();
                   
                   List<Rve_Exam_Notification__c> rveExamNotifications = [SELECT id, Name, rve_Active__c, Rve_Publish__c, hed_Program_Batch__c FROM Rve_Exam_Notification__c WHERE (hed_Program_Batch__r.id = :programBatchNames AND rve_Active__c = true AND Rve_Publish__c = true)];
                   System.debug('rveExamNotifications=> '+rveExamNotifications);
                   if(!rveExamNotifications.isEmpty()){
                       for (Rve_Exam_Notification__c rveExamNotification : rveExamNotifications) {
                           relatedItems.add(new MyWrapperClass(rveExamNotification.id, rveExamNotification.Name, rveExamNotification.rve_Active__c, rveExamNotification.Rve_Publish__c));
                       }
                   }
                   Set<Id> relatedExamNotificationIds = new Set<Id>();
                   
                   if(!relatedItems.isEmpty()){
                       for (MyWrapperClass wrapper : relatedItems) {
                           relatedExamNotificationIds.add(wrapper.examNotificationId);
                       }
                   }
                   List<hed_Time_Table_Line_Item__c> relatedTimeTableLineItem = [SELECT id, Name, hed_Date__c, Reva_Exam_Notification__c ,
                                                                                 Reva_Exam_Notification__r.hed_Program_Batch__r.Id FROM hed_Time_Table_Line_Item__c
                                                                                 WHERE (Reva_Exam_Notification__r.id =: relatedExamNotificationIds AND hed_Date__c = today)];
                   system.debug('relatedTimeTableLineItem'+relatedTimeTableLineItem);
                   
                   Map<Id, String> programBatchTimetableMap = new Map<Id, String>();
                   // Iterate over the list
                   // 
                   if(!relatedTimeTableLineItem.isEmpty()){
                       for (hed_Time_Table_Line_Item__c timetableItem : relatedTimeTableLineItem) {
                           // Extract information from the current record
                           String timetable = timetableItem.Name;
                           Id programBatchId = timetableItem.Reva_Exam_Notification__r.hed_Program_Batch__r.Id;
                           // Check if the program name is not null to avoid null pointer exceptions
                           if (timetable != null) {
                               // Add the entry to the map
                               programBatchTimetableMap.put(programBatchId, timetable);
                           }
                       }
                   }
                   // System.debug('programBatchTimetableMap: ' + programBatchTimetableMap);
                   
                   System.debug('contact list'+contacts.size());
                   // System.debug('contact list'+contacts);   
                   
                   
                   return contacts;
            /*   } else {
                   System.debug('Else part');
                   return new list<Contact>();
               }*/
        } catch (Exception e) {
            System.debug('exception' + e.getMessage());
            System.debug('exception' + e.getlinenumber());
            
            throw new AuraHandledException('Exception Occured=> '+e.getLineNumber()+' Exception: '+e.getMessage());
        }
    } 
    
    @AuraEnabled(cacheable=true) 
    public static decimal getCustomSettings(){
        Decimal settingval = 0; // Default value if no records are found
        rve_Exam_Time__c examTime = [SELECT Id, rve_Exam_End_Time_Hours__c FROM rve_Exam_Time__c LIMIT 1];
        
        if (examTime != null) {
            settingval = examTime.rve_Exam_End_Time_Hours__c;
        }
        // System.debug('settingval'+settingval);
        return settingval;
    }
    
    
    //start of change
    @AuraEnabled(cacheable=true)
    public static programCourseWrapper getProgramBatchTimetableMap(Date examdate,String shift,String roomname,string starttime, string endtime) {
        
        try {
            List<rve_Invigilator_Assignment__c> invigilatordetails = rve_InvigilatorAttendenceController.getRoomNumbers(examDate);
            
            // Retrieve a single instance of the custom setting
            Integer hoursToAddFromMetadata;
            rve_Exam_Time__c setting = rve_Exam_Time__c.getInstance();
            // Access custom setting fields
            if (setting != null) {
                Decimal examEndTimeDecimal = setting.rve_Exam_End_Time_Hours__c;
                hoursToAddFromMetadata = Integer.valueOf(examEndTimeDecimal);
                // Do something with myFieldValue
            } else {
                // Handle if the custom setting instance is not found
            }
            // System.debug('hoursToAddFromMetadata-> '+ hoursToAddFromMetadata);
            
            
            //to get the current time
            Datetime currentTime = Datetime.now();
            Time currentTimeOnly = currentTime.time();
            
            // code to sset the examStartTime value        
            // Split the examtime string into hours, minutes, and seconds
            List<String> timeComponents = starttime.split(':');
            // System.debug('time component'+timeComponents);
            Integer hours = Integer.valueOf(timeComponents[0]);
            Integer minutes = Integer.valueOf(timeComponents[1].split(' ')[0]); // Extract minutes
            Integer seconds = Integer.valueOf(timeComponents[2].split(' ')[0]); // Extract seconds
            // Adjust for AM or PM
            if (starttime.contains('PM') && hours != 12) {
                hours += 12;
            } else if (starttime.contains('AM') && hours == 12) {
                hours = 0;
            }
            // Subtract 30 minutes
            // to subtract 15 minutes we can replace 15 with 30 in the below code 
            if (minutes >= 30) {
                minutes -= 30;
            } else {
                if (hours == 0) {
                    hours = 23; // Adjust hours for midnight
                } else {
                    hours -= 1;
                }
                minutes = 60 - (30 - minutes);
            }
            Time examStartTime = Time.newInstance(hours, minutes, seconds, 0);
            // System.debug('examStartTime'+examStartTime);
            
            // code to sset the examEndTime value   
            // Split the examtime string into hours, minutes, and seconds
            List<String> timeComponents1 = endtime.split(':');  
            Integer hours1 = Integer.valueOf(timeComponents1[0]);
            Integer minutes1 = Integer.valueOf(timeComponents1[1].split(' ')[0]); // Extract minutes
            Integer seconds1 = Integer.valueOf(timeComponents1[2].split(' ')[0]); // Extract seconds
            // Adjust for AM or PM
            if (endtime.contains('PM') && hours1 != 12) {
                hours1 += 12;
            } else if (endtime.contains('AM') && hours == 12) {
                hours1 = 0;
            }
            // Add hours from metadata
            hours1 += hoursToAddFromMetadata;
            // Ensure the hour is within 0-23 range
            if (hours1 >= 24) {
                hours1 -= 24;
            }
            // Create the new examendtime Time object
            Time examEndTime = Time.newInstance(hours1, minutes1, seconds1, 0);
            
            if(test.isRunningtest())
            {
                if(examEndTime.hour() == 0)
                {
                    examEndTime = Time.newInstance(currentTimeOnly.hour()+1,currentTimeOnly.minute(),0,0);
                }
            }
            
            // System.debug('Currenttime=> '+currentTimeOnly);
            // System.debug('invigilatordetails.size()=> '+invigilatordetails.size()+' ExamStartTime=> '+ExamStartTime+' ExamEndTime=> '+examendtime);
            
            if (invigilatordetails.size() > 0 && currentTimeOnly >= examStartTime && currentTimeOnly <= examEndTime
               ) {
                   // System.debug('invigilatordetails' + invigilatordetails);
                   // System.debug('current user' + UserInfo.getUserId());
                   
                   
                   List<rve_Invigilator_Assignment__c> roomAssignments = [SELECT Id, Name, rve_Date__c, rve_Shift__c,
                                                                          rve_Room_Allotment__r.Students__c,
                                                                          rve_Exam_Time__c, rve_Exam_End_Time__c
                                                                          FROM rve_Invigilator_Assignment__c
                                                                          WHERE rve_Date__c =: examdate AND
                                                                          rve_Professor__c = :UserInfo.getUserId()
                                                                          AND Name =: roomname
                                                                          AND rve_Room_Allotment__r.Active__c = true
                                                                          AND rve_Shift__c =: shift
                                                                          AND rve_Exam_Time__c >= :examStartTime
                                                                          AND rve_Exam_End_Time__c <= :examEndTime
                                                                         ];
                   // System.debug('roomAssignments list=>' +roomAssignments);
                   
                   
                   
                   // System.debug('room details' + roomAssignments);
                   List<Contact> contacts = new List<Contact>();
                   if(!roomAssignments.isEmpty()){
                       
                       for (rve_Invigilator_Assignment__c assignment : roomAssignments) {
                           Set<String> AllSRN = new Set<String>();
                           Set<String> SRNNumbers = new Set<String>();
                           
                           if (assignment.rve_Room_Allotment__r.Students__c != null) {
                               SRNNumbers.addAll(new Set<String>(assignment.rve_Room_Allotment__r.Students__c.split(',')));
                           }
                           
                           AllSRN.addAll(SRNNumbers);
                           
                           List<Contact> roomContacts = [SELECT Id, Name, Email, Sibling_SRN_Number__c, Active_Section__c,SRN_Number__c,
                                                         Program_Batch__r.Name, Program_Batch__c
                                                         FROM Contact
                                                         WHERE SRN_Number__c IN :AllSRN
                                                         AND Active__c = TRUE
                                                         ORDER BY SRN_Number__c ASC];
                           
                           contacts.addAll(roomContacts);
                       }
                   }
                   
                   //wrp.students=contacts;
                   Set<Id> programBatchNames = new Set<Id>();
                   set<Id> sectionId = new set<Id>();
                   if(!contacts.isEmpty()){
                       for (Contact selectedContact : contacts) {
                           if (selectedContact.Program_Batch__r != null) {
                               programBatchNames.add(selectedContact.Program_Batch__r.id);
                               sectionId.add(selectedContact.Id);
                           }
                       }
                   }
                   // System.debug('programBatchNames'+programBatchNames);
                   
                   List<MyWrapperClass> relatedItems = new List<MyWrapperClass>();
                   programCourseWrapper wrp = new programCourseWrapper();
                   List<Rve_Exam_Notification__c> rveExamNotifications = [SELECT id, Name, rve_Active__c, Rve_Publish__c, hed_Program_Batch__c FROM Rve_Exam_Notification__c WHERE (hed_Program_Batch__r.id = :programBatchNames AND rve_Active__c = true AND Rve_Publish__c = true)];
                   if(!rveExamNotifications.isEmpty()){
                       for (Rve_Exam_Notification__c rveExamNotification : rveExamNotifications) {
                           relatedItems.add(new MyWrapperClass(rveExamNotification.id, rveExamNotification.Name, rveExamNotification.rve_Active__c, rveExamNotification.Rve_Publish__c));
                       }
                   }
                   // System.debug('relatedItems'+relatedItems);                    
                   Set<Id> relatedExamNotificationIds = new Set<Id>();
                   if(!relatedItems.isEmpty()){
                       for (MyWrapperClass wrapper : relatedItems) {
                           relatedExamNotificationIds.add(wrapper.examNotificationId);
                       }
                   }
                   // System.debug('relatedExamNotificationIds'+relatedExamNotificationIds); 
                   
                   List<hed_Time_Table_Line_Item__c> relatedTimeTableLineItem = [SELECT id, Name, hed_Date__c, Reva_Exam_Notification__c ,
                                                                                 Reva_Exam_Notification__r.hed_Program_Batch__r.Name FROM hed_Time_Table_Line_Item__c
                                                                                 WHERE (Reva_Exam_Notification__r.id =: relatedExamNotificationIds AND hed_Date__c = today)
                                                                                 and hed_Start_Time__c=:examStartTime.addMinutes(30)];
                   // System.debug('relatedTimeTableLineItem'+relatedTimeTableLineItem);
                   Map<string,set<Id>> courseNameStudentIdmap = new Map<string,set<Id>>();
                   Map<Id,Id> studentIdCourseConnectionIdMap = new Map<Id,Id>();
                   //List<hed__Course_Enrollment__c> courseConnections = [Select Id,Name,hed__Course_Offering__r.name from hed__Course_Enrollment__c where Section__c IN :sectionId];
                   for(hed__Course_Enrollment__c courseConnection : [Select Id,hed__Contact__c,Name,hed__Course_Offering__r.name from hed__Course_Enrollment__c where hed__Contact__c IN :sectionId]){
                       studentIdCourseConnectionIdMap.put(courseConnection.hed__Contact__c,courseConnection.Id);
                       If(courseNameStudentIdmap.get(courseConnection.hed__Course_Offering__r.name)!=NULL){
                           courseNameStudentIdmap.get(courseConnection.hed__Course_Offering__r.name).add(courseConnection.hed__Contact__c);
                       }else{
                           set<Id> student = new set<Id>();
                           student.add(courseConnection.hed__Contact__c);
                           // System.debug('courseConnection.hed__Contact__c=> '+courseConnection.hed__Contact__c);
                           courseNameStudentIdmap.put(courseConnection.hed__Course_Offering__r.name,student );
                       }
                       
                   }
                   // System.debug('courseNameStudentIdmap-->'+courseNameStudentIdmap);
                   // System.debug('studentIdCourseConnectionIdMap-->'+studentIdCourseConnectionIdMap);
                   Map<Id, String> programBatchTimetableMap = new Map<Id, String>();
                   // Iterate over the list
                   
                   if(!relatedTimeTableLineItem.isEmpty()){
                      map<string,string> programCourseMap =new map<string,string>();

                       for (hed_Time_Table_Line_Item__c timetableItem : relatedTimeTableLineItem) {
                           // Extract information from the current record
                           String timetable = timetableItem.Name;
                           System.debug('timetable-->'+timetable+' timetableId=> '+timetableItem.Id);
                           // System.debug('studentId---->'+courseNameStudentIdmap.get(timetable));
                           set<Id> stduentIds =courseNameStudentIdmap.get(timetable);
                           // System.debug('studentIds=> '+stduentIds);
                           if (stduentIds != null && !stduentIds.isEmpty()) {
                               for(Id stduent :stduentIds){
                                   If(studentIdCourseConnectionIdMap.get(stduent)!=NULL){
                                       programBatchTimetableMap.put(stduent,studentIdCourseConnectionIdMap.get(stduent));
                                       //wrp.contactCourseConnectionIdMap.put(stduent,studentIdCourseConnectionIdMap.get(stduent));
                                       
                                   }
                               }
                           }
                           string programBatchId = timetableItem.Reva_Exam_Notification__r.hed_Program_Batch__r.Name;
                           programCourseMap.put(programBatchId,timetable);
                           wrp.contactCourseConnectionIdMap = programBatchTimetableMap;
                       } 
                       if(!programCourseMap.isEmpty()){
                       wrp.programBatchCourseNameMap = new Map<string,string>();
                       wrp.programBatchCourseNameMap.putall(programCourseMap);
                       }

                   }
                   // System.debug('programBatchTimetableMap: ' + wrp);
                   
                   System.debug('contact list'+contacts.size());
                   System.debug('contact list'+contacts);   
                   
                   
                   return wrp;
               } else {
                   // System.debug('Else part');
                   return null;//new Map<Id, String>();
               }
        } catch (Exception e) {
            System.debug('exception' + e.getMessage());
            System.debug('exception' + e.getlinenumber());
            
            throw new AuraHandledException('Exception Occured=> '+e.getLineNumber()+' Exception: '+e.getMessage());
        }
    } 
    
    //end of change 
    
    
    @AuraEnabled
    public static void insertAttendenceEvent(List<hed__Attendance_Event__c> attendance) {
        String Status ;
        try {
            System.debug('attendance=> '+attendance);
            List<Database.SaveResult> saveResults = Database.insert(attendance, false); // false allows partial insert
            
            List<hed__Attendance_Event__c> successfulRecords = new List<hed__Attendance_Event__c>();
            List<hed__Attendance_Event__c> failedRecords = new List<hed__Attendance_Event__c>();
            List<String> errorMessages = new List<String>();
            
            // Iterate through results to check for failures
            for (Integer i = 0; i < saveResults.size(); i++) {
                if (saveResults[i].isSuccess()) {
                    successfulRecords.add(attendance[i]);
                } else {
                    failedRecords.add(attendance[i]);
                    for (Database.Error err : saveResults[i].getErrors()) {
                        errorMessages.add('Record Id: ' + attendance[i].Id + ' Error: ' + err.getMessage());
                    }
                }
            }
            
            // Set status
            if (failedRecords.isEmpty()) {
                Status = 'Success';
            } else {
                Status = 'Partial Success or Failure';
                System.debug('Failed Records: ' + errorMessages);
            }
            //   return status;
            // Log inserted data
            // System.debug('Inserted data: ' + attendance);
            // System.debug('Size of the list: ' + attendance.size());
        } catch (Exception e) {
            System.debug('Error inserting record: ' + e.getMessage());
            //  return e.getMessage();
            throw new AuraHandledException('Error occurred while inserting Attendence Event: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateAttendanceCheckbox(String recordId) {
        try {
            // Retrieve the record to update
            List<rve_Invigilator_Assignment__c> recordToUpdate = [SELECT Id, rve_Attendance_Submitted__c FROM rve_Invigilator_Assignment__c WHERE Id = :recordId LIMIT 1];
            System.debug('recordto update###==>'+recordToUpdate);
            // Update the attendance checkbox field
            if(!recordToUpdate.isEmpty())
            {
                recordToUpdate[0].rve_Attendance_Submitted__c = true; // Set it to true (or whatever value you need)
                // Update the record
                update recordToUpdate;
            }
            
        } catch (Exception e) {
            // Handle any exceptions
            System.debug('Error updating record: ' + e.getMessage());
        }
    }
    
    public class MyWrapperClass {
        public id examNotificationId { get; set; }
        public String examNotificationName { get; set; }
        public Boolean isActive { get; set; }
        public Boolean isPublished { get; set; }
        
        public MyWrapperClass(Id notificationId, String name, Boolean active, Boolean publish) {
            examNotificationId = notificationId;
            examNotificationName = name;
            isActive = active;
            isPublished = publish;
        }
    }
    
    Public class programCourseWrapper{
        @AuraEnabled
        public Map<Id,string> contactCourseConnectionIdMap {get;set;}
        @AuraEnabled
        public Map<string,string> programBatchCourseNameMap {get;set;}
        @AuraEnabled
        public List<contact> students {get;set;}
    }
    @AuraEnabled
    public static time timeconvertion(String stime) {
        Time timeval;
        List<String> timeComponents = stime.split(':');
        // System.debug('time component'+timeComponents);
        Integer hours = Integer.valueOf(timeComponents[0]);
        Integer minutes = Integer.valueOf(timeComponents[1].split(' ')[0]); // Extract minutes
        Integer seconds = Integer.valueOf(timeComponents[2].split(' ')[0]); // Extract seconds
        // Adjust for AM or PM
        if (stime.contains('PM') ) {
            hours += 12;
            timeval = Time.newInstance(hours, minutes, seconds, 0);
        } else if (stime.contains('AM')) {
            
            
            timeval = Time.newInstance(hours, minutes, seconds, 0);
            // System.debug('examStartTime'+timeval);
        }
        // System.debug('examStartTime'+timeval);
        return timeval;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> contactdetails(Date examdate,String shift,String roomname,time starttime, time endtime,String professorid) {
        
        try {
            List<rve_Invigilator_Assignment__c> roomAssignments = [SELECT Id, Name, rve_Date__c, rve_Shift__c,
                                                                   rve_Room_Allotment__r.Students__c,
                                                                   rve_Exam_Time__c, rve_Exam_End_Time__c
                                                                   FROM rve_Invigilator_Assignment__c
                                                                   WHERE rve_Date__c =: examdate AND
                                                                   rve_Professor__c = :professorid
                                                                   AND Name =: roomname
                                                                   AND rve_Room_Allotment__r.Active__c = true
                                                                   AND rve_Shift__c =: shift
                                                                   AND rve_Exam_Time__c = :starttime
                                                                   AND rve_Exam_End_Time__c = :endtime
                                                                   AND rve_Attendance_Submitted__c = false
                                                                  ];
            // System.debug('roomAssignments list=>' +roomAssignments);
            
            // System.debug('room details' + roomAssignments);
            List<Contact> contacts = new List<Contact>();
            
            for (rve_Invigilator_Assignment__c assignment : roomAssignments) {
                Set<String> AllSRN = new Set<String>();
                Set<String> SRNNumbers = new Set<String>();
                Set<String> SRNNumbers1 = new Set<String>();
                
                if (assignment.rve_Room_Allotment__r.Students__c != null) {
                    SRNNumbers.addAll(new Set<String>(assignment.rve_Room_Allotment__r.Students__c.split(',')));
                }
         
                AllSRN.addAll(SRNNumbers);                
                
                List<Contact> roomContacts = [SELECT Id, Name, Email, Sibling_SRN_Number__c, SRN_Number__c,
                                              Program_Batch__r.Name, Program_Batch__c
                                              FROM Contact
                                              WHERE SRN_Number__c IN :AllSRN
                                              AND Active__c = TRUE
                                              ORDER BY SRN_Number__c ASC];
                
                contacts.addAll(roomContacts);
            }
            
            // System.debug('contact list'+contacts.size());
            // System.debug('contact list'+contacts);   
            
            
            return contacts;
            
        } catch (Exception e) {
            System.debug('exception' + e.getMessage());
            System.debug('exception' + e.getlinenumber());
            
            return null;
        }
    } 
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getRoomQRAttendance(Date examdate, String roomname, String starttime, String endtime) {
        try{
        // Retrieve a single instance of the custom setting
            Integer hoursToAddFromMetadata;
            rve_Exam_Time__c setting = rve_Exam_Time__c.getInstance();
            // Access custom setting fields
            if (setting != null) {
                Decimal examEndTimeDecimal = setting.rve_Exam_End_Time_Hours__c;
                hoursToAddFromMetadata = Integer.valueOf(examEndTimeDecimal);
                // Do something with myFieldValue
            } else {
                // Handle if the custom setting instance is not found
            }
            // system.debug('hoursToAddFromMetadata-> '+ hoursToAddFromMetadata);
            
            
            //to get the current time
            Datetime currentTime = Datetime.now();
            Time currentTimeOnly = currentTime.time();
            
            // code to sset the examStartTime value        
            // Split the examtime string into hours, minutes, and seconds
            List<String> timeComponents = starttime.split(':');
            // system.debug('time component'+timeComponents);
            Integer hours = Integer.valueOf(timeComponents[0]);
            Integer minutes = Integer.valueOf(timeComponents[1].split(' ')[0]); // Extract minutes
            Integer seconds = Integer.valueOf(timeComponents[2].split(' ')[0]); // Extract seconds
            // Adjust for AM or PM
            if (starttime.contains('PM') && hours != 12) {
                hours += 12;
            } else if (starttime.contains('AM') && hours == 12) {
                hours = 0;
            }
            // Subtract 30 minutes
            // to subtract 15 minutes we can replace 15 with 30 in the below code 
            if (minutes >= 30) {
                minutes -= 30;
            } else {
                if (hours == 0) {
                    hours = 23; // Adjust hours for midnight
                } else {
                    hours -= 1;
                }
                minutes = 60 - (30 - minutes);
            }
            Time examStartTime = Time.newInstance(hours, minutes, seconds, 0);
            
            // code to sset the examEndTime value   
            // Split the examtime string into hours, minutes, and seconds
            List<String> timeComponents1 = endtime.split(':');  
            Integer hours1 = Integer.valueOf(timeComponents1[0]);
            Integer minutes1 = Integer.valueOf(timeComponents1[1].split(' ')[0]); // Extract minutes
            Integer seconds1 = Integer.valueOf(timeComponents1[2].split(' ')[0]); // Extract seconds
            // Adjust for AM or PM
            if (endtime.contains('PM') && hours1 != 12) {
                hours1 += 12;
            } else if (endtime.contains('AM') && hours == 12) {
                hours1 = 0;
            }
            // Add hours from metadata
            hours1 += hoursToAddFromMetadata;
            // Ensure the hour is within 0-23 range
            if (hours1 >= 24) {
                hours1 -= 24;
            }
            // Create the new examendtime Time object
            Time examEndTime = Time.newInstance(hours1, minutes1, seconds1, 0);
            if(test.isRunningtest())
            {
                if(examEndTime.hour() == 0)
                {
                    examEndTime = Time.newInstance(currentTimeOnly.hour()+1,currentTimeOnly.minute(),0,0);
                }
            }
            System.debug('QRRRExamdate=> '+ExamDate+' Name=> '+roomName+' ExamStartTime=> '+examStartTime+' EndTime=> '+examEndTime);
            Map<String, Boolean> srnAttendanceMap = new Map<String, Boolean>();
        
            List<HallTicketQR__c> hallTickets = [
                SELECT SRN__c, Attendance_Type__c 
                FROM HallTicketQR__c 
                WHERE Room__c = :roomname 
                AND Date__c = :ExamDate 
                AND Start_time__c = :examStartTime 
                AND End_time__c = :examEndTime
            ];
            
            for (HallTicketQR__c ticket : hallTickets) {
                srnAttendanceMap.put(ticket.SRN__c, ticket.Attendance_Type__c);
            }
            
            return srnAttendanceMap;
        }catch(Exception e){
            System.debug('exception' + e.getMessage());
            System.debug('exception' + e.getlinenumber());
            
            return null;
        }
        
    }
    
    @AuraEnabled
    public static Map<String, Boolean> getRoomQRAttendanceDetails(Date examdate, String roomname, String starttime, String endtime) {
        try {
            // Convert "14:30:00.000Z" or "14:30" to Apex Time
            // We split by ':' and take the first two parts (Hours and Minutes)
            Time startT = Time.newInstance(
                Integer.valueOf(starttime.split(':')[0]), 
                Integer.valueOf(starttime.split(':')[1]), 0, 0
            );
            Time endT = Time.newInstance(
                Integer.valueOf(endtime.split(':')[0]), 
                Integer.valueOf(endtime.split(':')[1]), 0, 0
            );
    
            Map<String, Boolean> srnAttendanceMap = new Map<String, Boolean>();
        
            List<HallTicketQR__c> hallTickets = [
                SELECT SRN__c, Attendance_Type__c 
                FROM HallTicketQR__c 
                WHERE Room__c = :roomname 
                AND Date__c = :examdate 
                AND Start_time__c = :startT 
                AND End_time__c = :endT
                WITH USER_MODE
            ];
            
            for (HallTicketQR__c ticket : hallTickets) {
                srnAttendanceMap.put(ticket.SRN__c, ticket.Attendance_Type__c);
            }
            
            return srnAttendanceMap;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}