public class ProfessorClassAdjustmentController {
    public static set<string> set_CategoryNames = new set<string>{'Hardcore Course','Hardcore Integrated Course','Mandatory Course'};
    public static set<string> set_OpenElectives = new set<string>{'Open Elective','Professional Elective','Practical/Term work'}; 
    public static Set<Id> set_ProfIds = new Set<Id>();
    public static Set<Id> set_OfferingIds = new Set<Id>();    
    public static Id FacultyRecId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(utility.CC_Faculty_RecType).getRecordTypeId();
    
    // Course Offering Schedules of Current Prfoessor on Leaves date
@AuraEnabled(cacheable=true)
public static List<hed__Course_Offering_Schedule__c> getSchedulesByEntryDate(Date scheduleDate, Date endDate, Id currentUserId) {
    Set<String> set_OfferingIds = new Set<String>();
    Set<Id> set_GroupId = new Set<Id>();

    if (scheduleDate == null || endDate == null) {
        throw new AuraHandledException('Start date and end date cannot be null.');
    }
    
    if (scheduleDate > endDate) {
        throw new AuraHandledException('Start date cannot be after end date.');
    }

     Contact contactRec = [SELECT Id FROM Contact WHERE OwnerId =: UserInfo.getUserId() limit 1];
    for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,Section__c FROM hed__Course_Enrollment__c WHERE Active_Connection__c = true and hed__Contact__c =: contactRec.Id ]) {
        set_OfferingIds.add(eachConn.hed__Course_Offering__c);
        set_GroupId.add(eachConn.Section__c);
    }
    set_GroupId.add(null);

    // Query the hed__Course_Offering_Schedule__c records based on Entry_Date__c
    List<hed__Course_Offering_Schedule__c> schedules = [
        SELECT Id, Course_ID__c, hed__Start_Time__c, hed__End_Time__c, Course_Offering_Section__c, Section__c, Date__c,
               Section__r.hed__Parent_Term__c, hed__Course_Offering__r.Category__c, School__c
        FROM hed__Course_Offering_Schedule__c
        WHERE Date__c >= :scheduleDate
        AND Date__c <= :endDate
        AND Status__c = 'Scheduled'
        //AND Professor__c =: currentUserId
        AND (hed__Course_Offering__c in: set_OfferingIds and Batch_Group__c in: set_GroupId) 
        AND (hed__Course_Offering__r.Category__c IN :set_CategoryNames OR hed__Course_Offering__r.Category__c IN :set_OpenElectives)
        AND Id NOT IN (
            SELECT Course_Offering_Schedule__c
            FROM class_adjustment__c
            WHERE Course_Offering_Schedule__c != NULL AND Requested_Course_Offering_Schedule__c = Null
            AND class_adjustment__c.Status__c != 'Rejected'
        )
        ORDER BY Date__c, Slot__c
    ];
    
    return schedules;
}

    // Fetch same sction available Professors
@AuraEnabled(cacheable=true)
public static Map<String, List<Contact>> getProfessorsBySameSection(Date scheduleDate, Date endDate, Id currentUserId, String courseOfferingSection, 
                                                                    Id semisterId, Time startTime, Time endTime) {
    Map<String, List<Contact>> professorMap = new Map<String, List<Contact>>();

    // Fetch the Employee Number of the current user
    String currentEmployeeNumber = [
        SELECT EmployeeNumber 
        FROM User 
        WHERE Id = :currentUserId
        LIMIT 1
    ].EmployeeNumber;

    // Query for other schedules excluding current user's schedule and conflicting times
    List<hed__Course_Offering_Schedule__c> otherSchedules = [
        SELECT Professor__c, Professor__r.EmployeeNumber, 
        hed__Start_Time__c, hed__End_Time__c, Date__c,Course_ID__c,Professor__r.Name
        FROM hed__Course_Offering_Schedule__c
        WHERE Course_Offering_Section__c = :courseOfferingSection
        AND Professor__c != :currentUserId
        AND Date__c >= :scheduleDate
        AND Status__c =: 'Scheduled'
        AND Date__c <= :endDate
        AND (
                (hed__Start_Time__c >= :startTime AND hed__Start_Time__c < :endTime) OR
                (hed__End_Time__c > :startTime AND hed__End_Time__c <= :endTime) OR
                (hed__Start_Time__c <= :startTime AND hed__End_Time__c >= :endTime)
            )
    ];
    
    List<class_adjustment__c> classAdjustments = [
        SELECT Id, Name, Course_Offering_Schedule__c, 
                Requested_Professor__c,Requested_Professor__r.Name,Requested_Professor__r.EmployeeNumber,
               Course_Offering_Schedule__r.hed__Course_Offering__r.Name
        FROM class_adjustment__c
        WHERE From_Date__c >= :scheduleDate
        AND To_Date__c <= :endDate
        AND (
                (Start_time__c >= :startTime AND Start_time__c < :endTime) OR
                (End_time__c > :startTime AND End_time__c <= :endTime) OR
                (Start_time__c <= :startTime AND End_time__c >= :endTime)
            )
        AND Status__c = 'Submitted'
        AND Requested_Course_Offering_Schedule__c = Null
    ];
                                                                        
   system.debug('semisterId:'+classAdjustments);
   
   // Query Course Enrollment records
    List<hed__Course_Enrollment__c> courseEnrollments = [
        SELECT Id, hed__Course_Offering__c, RecordTypeId, hed__Course_Offering__r.Category__c, 
        Section__c, hed__Contact__c, hed__Contact__r.Name,Course_Offering_Section__c
        FROM hed__Course_Enrollment__c 
        WHERE hed__Contact__c != null
        AND hed__Contact__r.Active__c = true
        //AND Active_Connection__c = true
        AND hed__Course_Offering__r.Category__c IN: set_CategoryNames
        AND Section__c = :semisterId
        AND Course_Offering_Section__c = :courseOfferingSection
        AND RecordTypeId = :FacultyRecId
    ];

                                                                        
                                                                        
    // Collect all hed__Contact__c values for querying Contact records
    Set<Id> contactIds = new Set<Id>();
    for (hed__Course_Enrollment__c eachConn : courseEnrollments) {
        contactIds.add(eachConn.hed__Contact__c);
    }

    // Query Contact records
    Map<Id, Contact> contactMap = new Map<Id, Contact>([
        SELECT Id, Name, Email, Employee_Number__c 
        FROM Contact 
        WHERE Id IN :contactIds
        AND Employee_Number__c != :currentEmployeeNumber
    ]);

    // Build the professor map
    for (hed__Course_Enrollment__c eachConn : courseEnrollments) {
        if (!professorMap.containsKey(eachConn.Course_Offering_Section__c)) {
            professorMap.put(eachConn.Course_Offering_Section__c, new List<Contact>());
        }
          system.debug('sameprofessorMap'+eachConn.hed__Contact__r.Name);

        Contact contact = contactMap.get(eachConn.hed__Contact__c);
        if (contact != null) {
            Boolean hasConflictingSchedule = false;

            for (hed__Course_Offering_Schedule__c schedule : otherSchedules) {
                if (schedule.Professor__r.EmployeeNumber == contact.Employee_Number__c) {
                    hasConflictingSchedule = true;
                    break;
                }
               
            }
              if (!hasConflictingSchedule) {
                for (class_adjustment__c adjustment : classAdjustments) {
                    if (adjustment.Requested_Professor__r.EmployeeNumber == contact.Employee_Number__c) {
                        hasConflictingSchedule = true;
                        break;
                    }
                }
            }

            // Add the contact if no conflicting schedule is found
            if (!hasConflictingSchedule) {
                professorMap.get(eachConn.Course_Offering_Section__c).add(contact);
            }
        }
    }
 system.debug('SameprofessorMap::'+professorMap);
    return professorMap;
}
 
    // Fetch Other section but who are handling same course available Professors 
@AuraEnabled(cacheable=true)
public static Map<String, List<Contact>> getProfessorsOtherSection(Date scheduleDate, Date endDate, Id currentUserId,
                                                                   String courseOfferingSection, Id semisterId, 
                                                                   Time startTime, Time endTime, String courseId) {
    Map<String, List<Contact>> professorMap = new Map<String, List<Contact>>();

    // Fetch the Employee Number of the current user
    String currentEmployeeNumber = [
        SELECT EmployeeNumber 
        FROM User 
        WHERE Id = :currentUserId
        LIMIT 1
    ].EmployeeNumber;

    // Query for other schedules excluding current user's schedule and conflicting times
    List<hed__Course_Offering_Schedule__c> otherSchedules = [
        SELECT Professor__c, Professor__r.EmployeeNumber, hed__Start_Time__c, hed__End_Time__c, Date__c, Course_ID__c, Professor__r.Name
        FROM hed__Course_Offering_Schedule__c
        WHERE Course_ID__c = :courseId
        AND Professor__c != :currentUserId
        AND Date__c >= :scheduleDate
        AND Status__c =: 'Scheduled'
        AND Date__c <= :endDate 
        AND (
                (hed__Start_Time__c >= :startTime AND hed__Start_Time__c < :endTime) OR
                (hed__End_Time__c > :startTime AND hed__End_Time__c <= :endTime) OR
                (hed__Start_Time__c <= :startTime AND hed__End_Time__c >= :endTime)
            )
    ];
                                                                       
   List<class_adjustment__c> classAdjustments = [
        SELECT Id, Name, Course_Offering_Schedule__c, 
                Requested_Professor__c,Requested_Professor__r.Name,Requested_Professor__r.EmployeeNumber,
               Course_Offering_Schedule__r.hed__Course_Offering__r.Name
        FROM class_adjustment__c
        WHERE From_Date__c >= :scheduleDate
        AND To_Date__c <= :endDate
        AND (
                (Start_time__c >= :startTime AND Start_time__c < :endTime) OR
                (End_time__c > :startTime AND End_time__c <= :endTime) OR
                (Start_time__c <= :startTime AND End_time__c >= :endTime)
            )
        AND Status__c = 'Submitted'
        AND Requested_Course_Offering_Schedule__c = Null
    ];

    system.debug('otherSchedules size: ' + otherSchedules.size());
         
    hed__Term__c semister = [SELECT Id, Name, hed__Parent_Term__c FROM hed__Term__c WHERE Id = :semisterId LIMIT 1];
    List<hed__Term__c> semisters = [SELECT Id, Name, hed__Parent_Term__c FROM hed__Term__c WHERE hed__Parent_Term__c = :semister.hed__Parent_Term__c];                                                                
    Set<Id> semisterIds = new Set<Id>();
    for (hed__Term__c sem : semisters) {
        semisterIds.add(sem.Id);
    }

    // Query Course Enrollment records
    List<hed__Course_Enrollment__c> courseEnrollments = [
        SELECT Id, hed__Course_Offering__c, RecordTypeId, hed__Course_Offering__r.Category__c, 
               Section__c, hed__Contact__c, hed__Contact__r.Name, Course_Offering_Section__c, Course_Code__c
        FROM hed__Course_Enrollment__c 
        WHERE hed__Contact__c != null
        AND hed__Contact__r.Active__c = true
        //AND Active_Connection__c = true
        AND  hed__Course_Offering__r.Category__c IN: set_CategoryNames
        AND Course_Code__c = :courseId
        AND Section__c IN :semisterIds        
        AND RecordTypeId = :FacultyRecId
    ];

    system.debug('courseEnrollments size: ' + courseEnrollments.size());

    // Collect all hed__Contact__c values for querying Contact records
    Set<Id> contactIds = new Set<Id>();
    for (hed__Course_Enrollment__c eachConn : courseEnrollments) {
        contactIds.add(eachConn.hed__Contact__c);
    }

    // Query Contact records
    Map<Id, Contact> contactMap = new Map<Id, Contact>([
        SELECT Id, Name, Email, Employee_Number__c 
        FROM Contact 
        WHERE Id IN :contactIds
        AND Employee_Number__c != :currentEmployeeNumber
    ]);

    // Build the professor map
    for (hed__Course_Enrollment__c eachConn : courseEnrollments) {
        if (!professorMap.containsKey(eachConn.Course_Code__c)) {
            professorMap.put(eachConn.Course_Code__c, new List<Contact>());
        }

        Contact contact = contactMap.get(eachConn.hed__Contact__c);
        if (contact != null) {
            Boolean hasConflictingSchedule = false;

            for (hed__Course_Offering_Schedule__c schedule : otherSchedules) {
                if (schedule.Professor__r.EmployeeNumber == contact.Employee_Number__c) {
                    hasConflictingSchedule = true;
                    break;
                }
            }
            // Check conflicts with class_adjustment__c
            for (class_adjustment__c adjustment : classAdjustments) {
                if (adjustment.Requested_Professor__r.EmployeeNumber == contact.Employee_Number__c) {
                    hasConflictingSchedule = true;
                    break;
                }
            }

            // Check if the professor has already been added to the list
            if (!hasConflictingSchedule) {
                List<Contact> professorList = professorMap.get(eachConn.Course_Code__c);
                // Use a Set to track if this professor is already added to the list for the course
                Set<String> addedProfessors = new Set<String>();
                for (Contact existingContact : professorList) {
                    addedProfessors.add(existingContact.Name);
                }

                // Only add if not already in the list
                if (!addedProfessors.contains(contact.Name)) {
                    professorList.add(contact);
                }
            }
        }
    }

    return professorMap;
}

// Fetch Entire School of available Professors
@AuraEnabled(cacheable=true)
public static Map<String, List<Contact>> getProfessorsEntireSchool(Date scheduleDate, Date endDate, Id currentUserId,
                                                                   String courseOfferingSection, Id semisterId, 
                                                                   Time startTime, Time endTime, String courseId,String category) {
    Map<String, List<Contact>> professorMap = new Map<String, List<Contact>>();

    // Fetch the Employee Number of the current user
    String currentEmployeeNumber = [
        SELECT EmployeeNumber 
        FROM User 
        WHERE Id = :currentUserId
        LIMIT 1
    ].EmployeeNumber;
         
    // Query for other schedules excluding current user's schedule and conflicting times
    List<hed__Course_Offering_Schedule__c> otherSchedules = [
        SELECT Professor__c, Professor__r.EmployeeNumber, hed__Start_Time__c, hed__End_Time__c, Date__c, Course_ID__c, Professor__r.Name
        FROM hed__Course_Offering_Schedule__c
        WHERE Course_ID__c = :courseId
        AND Professor__c != :currentUserId
        AND Date__c >= :scheduleDate
        AND Status__c =: 'Scheduled'
        AND Date__c <= :endDate 
        AND (
                (hed__Start_Time__c >= :startTime AND hed__Start_Time__c < :endTime) OR
                (hed__End_Time__c > :startTime AND hed__End_Time__c <= :endTime) OR
                (hed__Start_Time__c <= :startTime AND hed__End_Time__c >= :endTime)
            )
    ];

      List<class_adjustment__c> classAdjustments = [
        SELECT Id, Name, Course_Offering_Schedule__c, 
                Requested_Professor__c,Requested_Professor__r.Name,Requested_Professor__r.EmployeeNumber,
               Course_Offering_Schedule__r.hed__Course_Offering__r.Name
        FROM class_adjustment__c
        WHERE From_Date__c >= :scheduleDate
        AND To_Date__c <= :endDate
        AND (
                (Start_time__c >= :startTime AND Start_time__c < :endTime) OR
                (End_time__c > :startTime AND End_time__c <= :endTime) OR
                (Start_time__c <= :startTime AND End_time__c >= :endTime)
            )
        AND Status__c = 'Submitted'
        AND Requested_Course_Offering_Schedule__c = Null
    ];
                                                                       
    system.debug('EntireSchedules size: ' + otherSchedules.size());
         
    hed__Term__c semister = [SELECT Id, Name, hed__Parent_Term__c,hed__Parent_Term__r.hed__Account__c,hed__Parent_Term__r.hed__Account__r.ParentId,Program_Batch__r.School__c FROM hed__Term__c WHERE Id = :semisterId LIMIT 1];
   
    // Query Course Enrollment records
     List<hed__Course_Enrollment__c> courseEnrollments = new  List<hed__Course_Enrollment__c>();
     if(category == 'Hardcore Course' ||category == 'Mandatory Course' || category == 'Hardcore Integrated Course' ){
     courseEnrollments = [
        SELECT Id, hed__Course_Offering__c, RecordTypeId, hed__Course_Offering__r.Category__c, 
        Section__c, hed__Contact__c, hed__Contact__r.Name, Course_Offering_Section__c, Course_Code__c,
        Section__r.Record_Type_Name__c, Section__r.hed__Parent_Term__c,Section__r.hed__Parent_Term__r.hed__Account__c,hed__Account__r.Name
        FROM hed__Course_Enrollment__c 
        WHERE hed__Contact__c != null
        AND hed__Contact__r.Active__c = true
        AND Active_Connection__c = true
        AND hed__Course_Offering__r.Category__c IN: set_CategoryNames
        AND Section__r.Record_Type_Name__c = 'Sections'
         AND Section__r.active__c =true
        //AND Section__r.hed__Parent_Term__c =: semister.hed__Parent_Term__c  // particular sem prfessors
        //AND Section__r.hed__Parent_Term__r.hed__Account__c =: semister.hed__Parent_Term__r.hed__Account__c  // Department professors
        AND hed__Account__c =: semister.hed__Parent_Term__r.hed__Account__r.ParentId // whole School Professors
        //AND Section__r.hed__Parent_Term__r.hed__Account__r.ParentId =: semister.hed__Parent_Term__r.hed__Account__r.ParentId
        AND hed__Contact__r.Employee_Number__c != null
        AND RecordTypeId = :FacultyRecId
    ];
     }else{
         courseEnrollments = [
        SELECT Id, hed__Course_Offering__c, RecordTypeId, hed__Course_Offering__r.Category__c, 
        Section__c, hed__Contact__c, hed__Contact__r.Name, Course_Offering_Section__c, Course_Code__c,
        Section__r.Record_Type_Name__c, Section__r.hed__Parent_Term__c,Section__r.hed__Parent_Term__r.hed__Account__c,hed__Account__r.Name
        FROM hed__Course_Enrollment__c 
        WHERE hed__Contact__c != null
        AND hed__Contact__r.Active__c = true
        AND Active_Connection__c = true
        AND(hed__Course_Offering__r.Category__c IN: set_OpenElectives OR hed__Course_Offering__r.Category__c IN: set_CategoryNames)
        AND Section__r.Record_Type_Name__c = 'Sections'
        AND Section__r.active__c =true
        //AND Section__r.hed__Parent_Term__c =: semister.hed__Parent_Term__c  // particular sem prfessors
        //AND Section__r.hed__Parent_Term__r.hed__Account__c =: semister.hed__Parent_Term__r.hed__Account__c  // Department professors
        AND hed__Account__c =: semister.hed__Parent_Term__r.hed__Account__r.ParentId // whole School Professors
        //AND Section__r.hed__Parent_Term__r.hed__Account__r.ParentId =: semister.hed__Parent_Term__r.hed__Account__r.ParentId
        AND hed__Contact__r.Employee_Number__c != null
        AND RecordTypeId = :FacultyRecId
          ];
     }
    

    // Collect all hed__Contact__c values for querying Contact records
    Set<Id> contactIds = new Set<Id>();
    for (hed__Course_Enrollment__c eachConn : courseEnrollments) {
        contactIds.add(eachConn.hed__Contact__c);
    }
     system.debug('Fetch contactIds: ' + contactIds.size());
    // Query Contact records
    Map<Id, Contact> contactMap = new Map<Id, Contact>([
        SELECT Id, Name, Email, Employee_Number__c 
        FROM Contact 
        WHERE Id IN :contactIds
        AND Employee_Number__c != :currentEmployeeNumber
    ]);
 
    // Build the professor map
    for (hed__Course_Enrollment__c eachConn : courseEnrollments) {
        if (!professorMap.containsKey(eachConn.hed__Account__r.Name	)) {
            professorMap.put(eachConn.hed__Account__r.Name, new List<Contact>());
        }

        Contact contact = contactMap.get(eachConn.hed__Contact__c);
        if (contact != null) {
            Boolean hasConflictingSchedule = false;

            for (hed__Course_Offering_Schedule__c schedule : otherSchedules) {
                if (schedule.Professor__r.EmployeeNumber == contact.Employee_Number__c) {
                    hasConflictingSchedule = true;
                    break;
                }
            }
            // Check conflicts with class_adjustment__c
            for (class_adjustment__c adjustment : classAdjustments) {
                if (adjustment.Requested_Professor__r.EmployeeNumber == contact.Employee_Number__c) {
                    hasConflictingSchedule = true;
                    break;
                }
            }

            // Check if the professor has already been added to the list
            if (!hasConflictingSchedule) {
                List<Contact> professorList = professorMap.get(eachConn.hed__Account__r.Name);
                // Use a Set to track if this professor is already added to the list for the course
                Set<String> addedProfessors = new Set<String>();
                for (Contact existingContact : professorList) {
                    addedProfessors.add(existingContact.Name);
                }

                // Only add if not already in the list
                if (!addedProfessors.contains(contact.Name)) {
                    professorList.add(contact);
                }
            }
        }
    }


    system.debug('Return professorMap: ' + professorMap.size());
    return professorMap;
}

  // Class Adjustment Insertion   
  
    @AuraEnabled
    public static void ClassAdjustmentInsert(String adjustments) {
        List<Object> rawAdjustmentData = (List<Object>) JSON.deserializeUntyped(adjustments);
        List<Class_Adjustment__c> classAdjustments = new List<Class_Adjustment__c>();
        
        // Collect professor (Contact Ids) from input data
        Set<Id> contactIds = new Set<Id>();
        for (Object rawData : rawAdjustmentData) {
            Map<String, Object> data = (Map<String, Object>) rawData;
            String professor = (String) data.get('professor');
            if (!String.isBlank(professor)) {
                contactIds.add(Id.valueOf(professor));
            }
        }
        
        // Query Contact records
        Map<String, String> contactToEmployeeNumber = new Map<String, String>();
        for (Contact contact : [
            SELECT Id, Employee_Number__c 
            FROM Contact 
            WHERE Id IN :contactIds
        ]) {
            contactToEmployeeNumber.put(contact.Id, contact.Employee_Number__c);
        }
        
        // Query User records
        Map<String, Id> employeeNumberToUserId = new Map<String, Id>();
        for (User user : [
            SELECT Id, EmployeeNumber 
            FROM User 
            WHERE EmployeeNumber IN :contactToEmployeeNumber.values()
        ]) {
            employeeNumberToUserId.put(user.EmployeeNumber, user.Id);
        }
        
        // Process raw adjustment data and map Contact Ids to User Ids
        for (Object rawData : rawAdjustmentData) {
            Map<String, Object> data = (Map<String, Object>) rawData;
            
            String currentUserId = (String) data.get('currentUserId');
            String professor = (String) data.get('professor');
            String selectType = (String) data.get('selectType');
            Date scheduleDate = Date.valueOf((String) data.get('scheduleDate'));
            Date toDate = Date.valueOf((String) data.get('toDate'));
            String courseOfferingScheduleId = (String) data.get('courseOfferingScheduleId');
            Time startTime = parseTime((String) data.get('startTime'));
            Time endTime = parseTime((String) data.get('endTime'));
            system.debug('professor:'+professor);
            Id userId = null;
            if (!String.isBlank(professor) && contactToEmployeeNumber.containsKey(professor)) {
                String employeeNumber = contactToEmployeeNumber.get(professor);
                if (employeeNumberToUserId.containsKey(employeeNumber)) {
                    userId = employeeNumberToUserId.get(employeeNumber);
                }
            }
            if(userId !=null){ 
            classAdjustments.add(new Class_Adjustment__c(
                From_Date__c = scheduleDate,
                To_Date__c = toDate,
                Start_Time__c = startTime,
                End_Time__c = endTime,
                Status__c = 'Submitted',
                Requested_Professor__c = userId,
                Course_Offering_Schedule__c = courseOfferingScheduleId,
                selected_List__c = selectType,
                Professor__c = currentUserId
            ));
        }
        }
        if (!classAdjustments.isEmpty()) {
            insert classAdjustments;
        }
    }
    
    private static Time parseTime(String timeString) {
        if (String.isBlank(timeString)) {
            return null;
        }
        
        List<String> parts = timeString.split(':');
        return Time.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), 0, 0);
    }
  
@AuraEnabled(cacheable=true)
public static List<class_adjustment__c> getClassAdjustments(Date scheduleDate, Date endDate, Id currentUserId) {
    // Query class adjustments with related Course_Offering_Schedule__c and Professor
    List<class_adjustment__c> classAdjustments = [
        SELECT Id, Name, Course_Offering_Schedule__c, 
               Course_Offering_Schedule__r.Course_Offering_Section__c,Status__c,
               Course_Offering_Schedule__r.Professor__c,Requested_Professor__r.Name,
               Course_Offering_Schedule__r.hed__Course_Offering__r.Name
        FROM class_adjustment__c
        WHERE From_Date__c >= :scheduleDate
        AND To_Date__c <= :endDate
        AND Course_Offering_Schedule__r.Status__c = 'Scheduled'
        AND Course_Offering_Schedule__r.Professor__c = :currentUserId
        AND Requested_Course_Offering_Schedule__c = Null
    ];

    system.debug('scheduleDate:'+classAdjustments);
    return classAdjustments;
}

}