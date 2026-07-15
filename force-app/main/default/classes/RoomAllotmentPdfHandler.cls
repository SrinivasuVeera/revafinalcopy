public without sharing class RoomAllotmentPdfHandler {
    
    public Map<String, set<String>> RoomWithProgramBatches { get; private set; }
    public Map<String, Map<String, List<hed__Course_Enrollment__c>>> RoomWithCourseAndContact {get; set;}
    public Map<String,Map<String,Map<String,List<hed__Course_Enrollment__c>>>> RoomWithProgramWithCourseAndConnections {get;set;}
    public Map<String, Map<String,List<Contact>>> programBatchWithContacts { get; private set; }
    public Map<String, String> ProgramWithCourseIds {get; set;}
    public Map<String, Map<String, Set<String>>> RoomWithCourseNames { get; set; }
    public Map<String, String> ProgramWithSemester {get;set;}
    public Map<String, String> RoomWithBlockNames {get;set;}
    public Map<String, String> RoomWithIAType {get;set;}
    public Map<String,String> ProgramWithCourseName {get;set;}
    
    public Date DateWiseAllotment { get; private set; }
    public Time TimeWiseAllotment {get; private set; }
    public String schoolName { get; private set; }
    public Map<String,String> StartTime {get;set;}
    public Map<String,String> EndTime {get;set;}
    public String formattedDate { get; private set; }
    public String FormattedSemDate {get;set;}
    public String SemesterType {get;set;}
    public Boolean DisplayEligible { get; set; }
    public Boolean DisplayInEligible { get; set; }
    
    public RoomAllotmentPdfHandler(ApexPages.StandardController controller) {
        DisplayEligible = false;
        DisplayInEligible = false;
        RoomWithProgramBatches = new Map<String,Set<String>>();
        RoomWithIAType = new Map<String,String>();
        programBatchWithContacts = new Map<String,Map<String,List<Contact>>>();
        RoomWithCourseAndContact = new Map<String, Map<String, List<hed__Course_Enrollment__c>>>();
        RoomWithProgramWithCourseAndConnections = new Map<String,Map<String,Map<String,List<hed__Course_Enrollment__c>>>>();
        ProgramWithCourseIds = new Map<String,String>();
        RoomWithCourseNames = new Map<String, Map<String, Set<String>>>();
        ProgramWithSemester = new Map<String, String>();
        RoomWithBlockNames = new Map<String,String>();
        StartTime = new Map<String,String>();
        EndTime = new MAp<String,String>();
        String AllotmentDate = ApexPages.currentPage().getParameters().get('DatePass');
        String AllotmentTime = ApexPages.currentPage().getParameters().get('TimePass');
        System.debug('DisplayTable=> ' + AllotmentDate);
        System.debug('AllotmentTime=> '+AllotmentTime);
        if (AllotmentDate != null) {
            DateWiseAllotment = Date.valueOf(AllotmentDate);
        }
        if(AllotmentTime !=null)
        {
            List<String>timelist = AllotmentTime.split(':');
            
            TimeWiseAllotment = Time.newInstance(Integer.valueOf(timelist[0]),Integer.valueOf(timelist[1]),Integer.valueOf(timelist[2]),0);
        }
        getProgramBatchSRNs();
        // Example condition for displaying the table and fields based on type
    }
    
    public void getProgramBatchSRNs() {
        try {
            // Step 1: Query Seating_Room_Allotment__c records
            List<IA_Seating_Room_Allotment__c> allotments = [SELECT Id,Name,IA_Type__c,Facility_Type__r.Block__c, rve_Date_of_Exam__c,School__r.Name,
                                                             Assigned_Program_Batches__c,Exam_Time__c,End_Time__c, Students__c,
                                                             School__r.Examination_Vertical_Head__c FROM IA_Seating_Room_Allotment__c where rve_Date_of_Exam__c=:DateWiseAllotment
                                                             and Exam_Time__c = :TimeWiseAllotment and (School__r.parent.Examination_Vertical_Head__c=:userinfo.getuserId()
                                                                                                        or School__r.Examination_Vertical_Head__c=:userinfo.getuserId())];
            System.debug('allotments=> '+allotments);
            List<hed_Time_Table_Line_Item__c>TimeTableList = new List<hed_Time_Table_Line_Item__c>();
            Date dateValue = allotments[0].rve_Date_of_Exam__c!=null?allotments[0].rve_Date_of_Exam__c:Date.today();
            
            // Format the Date object to "dd/MM/yyyy" format
            formattedDate = datevalue.day()+'/'+datevalue.month()+'/'+datevalue.year();
            // System.debug('Date=> ' + formattedDate);
            
            Date parsedDate;
            
            // Parse the input date string into a Date object
            try {
                parsedDate = Date.newInstance(
                    datevalue.year(),datevalue.month(),datevalue.day()
                );
            } catch (Exception e) {
                System.debug('Error parsing date: ' + e.getMessage());
                // Handle error or invalid date format
            }
            
            // Convert the Date object to a DateTime object
            DateTime dt = DateTime.newInstance(parsedDate, Time.newInstance(0, 0, 0, 0));
            
            // Format the DateTime object into the desired output format
            if (dt != null) {
                FormattedSemDate = dt.format('MMMM yyyy');
                //  System.debug('Formatted Date: ' + FormattedSemDate); // Output: March 2024
            }
            
            schoolName = allotments[0].School__r.Name;
            
            for (IA_Seating_Room_Allotment__c allotment : allotments) {
                //   System.debug('88=> '+allotment.Name);
                Set<String>RoomCoursenames = new set<string>();
                Map<Id,Set<String>>ProgramWithcourse = new Map<Id,Set<String>>();
                RoomWithBlockNames.put(allotment.Name,allotment.Facility_Type__r.Block__c);
                RoomWithIAType.put(allotment.Name,allotment.IA_Type__c);
                // Step 3: Get program batches
                // Parse Assigned Program Batches to get Program Batch IDs
                List<String> programBatchIds = allotment.Assigned_Program_Batches__c.split(',');
                System.debug('223=> ' + programBatchIds);
                
                TimeTableList = [SELECT Id, Course__r.hed__Course_ID__c, Course__r.Name,Reva_Exam_Notification__r.Rve_Semester__r.Name,
                                 Reva_Exam_Notification__r.hed_Program_Batch__r.Name FROM hed_Time_Table_Line_Item__c
                                 WHERE hed_Date__c = :allotment.rve_Date_of_Exam__c 
                                 AND Reva_Exam_Notification__r.Rve_Publish__c = true AND Reva_Exam_Notification__r.hed_Program_Batch__c IN :programBatchIds
                                 AND hed_Start_Time__c =:allotment.Exam_Time__c
                                 Order By Course__r.Name];
                
                System.debug('TimeTableList=> '+TimeTableList);
                
                List<hed__Program_Plan__c>ProgramBatches = [Select Id,name from hed__Program_Plan__c where Id In:programBatchIds];
                
                set<string>programnames = new set<string>();
                Set<String> courseCodes = new Set<String>();
                for (hed_Time_Table_Line_Item__c timeTable : TimeTableList) {
                    String batchName = timeTable.Reva_Exam_Notification__r.hed_Program_Batch__r.Name;
                    String courseCode = timeTable.Course__r.hed__Course_ID__c;

                    programNames.add(batchName);
                    if (courseCode != null) courseCodes.add(courseCode);

                    // Fixed: No more overwriting!
                    Id batchId = timeTable.Reva_Exam_Notification__r.hed_Program_Batch__c;
                    if (!ProgramWithcourse.containsKey(batchId)) {
                        ProgramWithcourse.put(batchId, new Set<String>());
                    }
                    ProgramWithcourse.get(batchId).add(courseCode);

                    ProgramWithCourseIds.put(batchName, courseCode); // Note: overwrites if multiple courses
                    ProgramWithSemester.put(batchName, timeTable.Reva_Exam_Notification__r.Rve_Semester__r.Name);

                    // Even/Odd semester
                    Matcher matcher = Pattern.compile('[0-9]+').matcher(timeTable.Reva_Exam_Notification__r.Rve_Semester__r.Name);
                    while (matcher.find()) {
                        SemesterType = checkEvenOdd(Integer.valueOf(matcher.group(0)));
                    }
                }

                RoomWithProgramBatches.put(allotment.Name, programNames);

                Set<String> srnsToQuery = new Set<String>();
                if (allotment.Students__c != null) {
                    srnsToQuery.addAll(allotment.Students__c.split(','));
                }                
                //  System.debug('coursenames=> '+coursenames);
               List<hed__Course_Enrollment__c> CourseConnections = new List<hed__Course_Enrollment__c>();
                if (!Test.isRunningTest()) {
                    CourseConnections = [SELECT Id, hed__Contact__r.SRN_Number__c,
                                                hed__Course_Offering__r.hed__Course__r.Name,
                                                hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                                                hed__Contact__r.Name,
                                                hed__Contact__r.Program_Batch__r.Name
                                         FROM hed__Course_Enrollment__c
                                         WHERE hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c IN :courseCodes
                                           AND hed__Contact__r.SRN_Number__c IN :srnsToQuery
                                           AND Active_Connection__c = true
                                           AND hed__Contact__r.Student_Status__c = 'Pursuing'
                                           AND hed__Contact__r.Record_Type_Name__c = 'Student'
                                           AND hed__Contact__r.Active__c = true
                                         ORDER BY hed__Contact__r.SRN_Number__c];
                } else {
                    CourseConnections = [SELECT Id, hed__Contact__r.SRN_Number__c,
                                                hed__Course_Offering__r.hed__Course__r.Name,
                                                hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                                                hed__Contact__r.Name,
                                                hed__Contact__r.Program_Batch__r.Name
                                         FROM hed__Course_Enrollment__c];
                }
                // Step 4: Create a map of Program Batch name to list of Contacts
                for (hed__Course_Enrollment__c CourseCon : CourseConnections) {
                    String room = allotment.Name;
                    String programBatch = CourseCon.hed__Contact__r.Program_Batch__r.Name;
                    String courseCode = CourseCon.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c;

                    if (String.isBlank(courseCode)) continue;

                    if (!RoomWithProgramWithCourseAndConnections.containsKey(room)) {
                        RoomWithProgramWithCourseAndConnections.put(room, new Map<String, Map<String, List<hed__Course_Enrollment__c>>>());
                    }
                    Map<String, Map<String, List<hed__Course_Enrollment__c>>> programBatchMap = RoomWithProgramWithCourseAndConnections.get(room);

                    if (!programBatchMap.containsKey(programBatch)) {
                        programBatchMap.put(programBatch, new Map<String, List<hed__Course_Enrollment__c>>());
                    }
                    Map<String, List<hed__Course_Enrollment__c>> courseMap = programBatchMap.get(programBatch);

                    if (!courseMap.containsKey(courseCode)) {
                        courseMap.put(courseCode, new List<hed__Course_Enrollment__c>());
                    }
                    courseMap.get(courseCode).add(CourseCon);

                    programBatchMap.put(programBatch, courseMap);
                    RoomWithProgramWithCourseAndConnections.put(room, programBatchMap);
                    
                  /*  if (RoomWithCourseNames.containsKey(Key)) {
                        // Outer key exists, get the inner map
                        Map<String, Set<String>> innerMap = RoomWithCourseNames.get(Key);
                        
                        // Check if the inner key (Program Batch Name) exists
                        if (innerMap.containsKey(innerKey)) {
                            // Inner key exists, add the course to the set
                            innerMap.get(innerKey).add(courseName);
                        } else {
                            // Inner key doesn't exist, create a new set and add the course
                            Set<String> courses = new Set<String>();
                            courses.add(courseName);
                            innerMap.put(innerKey, courses);
                        }
                    }
                    else {
                        // Outer key doesn't exist, create a new inner map
                        Map<String, Set<String>> innerMap = new Map<String, Set<String>>();
                        Set<String> courses = new Set<String>();
                        courses.add(courseName); // Add the first course to the set
                        innerMap.put(innerKey, courses);
                        RoomWithCourseNames.put(Key, innerMap); // Insert the inner map into the outer map
                    }
                    
                    RoomCoursenames.add(courseName);*/
                    
                 //   System.debug('key=> '+key+' coursename=> '+courseName);
                    StartTime.put(allotment.name,convertTime(allotment.Exam_Time__c));
                    EndTime.put(allotment.name,convertTime(allotment.End_Time__c));
                    
                /*    
                    // Check if the outer map already has the allotment name
                    if (!RoomWithCourseAndContact.containsKey(key)) {
                        System.debug('Outer key=> '+key);
                        // Initialize the inner map if the allotment is not yet in the outer map
                        RoomWithCourseAndContact.put(key, new Map<String, List<hed__Course_Enrollment__c>>());
                    }
                    
                    // Get the inner map for this allotment
                    Map<String, List<hed__Course_Enrollment__c>> courseMap = RoomWithCourseAndContact.get(key);
                    
                    // Check if the inner map already has the course name
                    if (!courseMap.containsKey(courseName)) {
                        System.debug('Inside Inner Map=> '+coursename);
                        // Initialize the list if the course is not yet in the inner map
                        courseMap.put(courseName, new List<hed__Course_Enrollment__c>());
                    }
                    // Add the current CourseConnection to the appropriate list
                    courseMap.get(courseName).add(courseCon);
                    System.debug('coursemap=> '+courseMap);
                    RoomWithCourseAndContact.put(key, courseMap);
                    
                }*/
            }
            System.debug('Courses=> '+RoomWithProgramBatches);
            System.debug('Roomwithcourse=> '+RoomWithProgramWithCourseAndConnections);
            //  System.debug('RoomCourses=> '+RoomWithCourseNames);
            System.debug('Keys in the map: ' + RoomWithCourseNames.keySet());
            for(String key: RoomWithCourseAndContact.keySet()){
                system.debug('Key=>'+key);
                Map<String,List<hed__Course_Enrollment__c>>mpo = RoomWithCourseAndContact.get(key);
                for(String st : mpo.keySet())
                {
                    System.debug('st=> '+st);
                }
            } 
        }
            }
            catch(Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }
    
    public static String checkEvenOdd(Integer semnumber) {
        if (Math.mod(semnumber, 2) == 0) {
            return 'Even';  // The number is even
        } else {
            return 'Odd';   // The number is odd
        }
    }
    
    public static string convertTime(Time TimeToBeConverted){
        DateTime dateTimeValue = DateTime.newInstance(Date.today(), TimeToBeConverted);
        String formattedTime = dateTimeValue.format('h:mm a');
        //  System.debug('51=> '+formattedTime);
        return formattedTime;
    }
}