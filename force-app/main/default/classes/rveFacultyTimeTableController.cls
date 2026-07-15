public without sharing class rveFacultyTimeTableController {

public class timetableItem{
public String Id {get;set;}
public String StartTime {get;set;}
public String EndTime {get;set;}
public String LineItemDate {get;set;}
}
@AuraEnabled(cacheable=true)
public static List<hed__Program_Plan__c> searchProgramBatch(String searchKey) {
    String userId = userInfo.getUserId();
    String prgmBatchkey = '%' +  searchKey + '%';
    return[Select Id,Name,  hed__Account__r.Parent.Examination_Vertical_Head__c 
            from hed__Program_Plan__c where  hed__Account__r.Parent.Examination_Vertical_Head__c =:userId and Name LIKE:prgmBatchkey];
}

@AuraEnabled(cacheable=true)
public static List<hed__Term__c> getActiveSemester(String selectedValue){
    System.debug('selectedValue=> '+selectedvalue);
    return[Select Id,Name,Program_Batch__r.id, Active__c from hed__Term__c 
            where Program_Batch__r.id =:selectedValue and Active__c = true];
}


@AuraEnabled(cacheable=true)
public static List<hed__Course_Offering__c> getCourses(String activeSemester){
    List<hed__Course_Offering__c> hedcourselist=new List<hed__Course_Offering__c>();
    List<hed__Term__c> termdata=[Select Id,Name, Active__c, (Select id, name, hed__Course__r.hed__Course_ID__c,hed__Course__r.name from hed__Course_Offerings__r ) 
                                    from hed__Term__c where Id =:activeSemester and Active__c = true];
    for(hed__Term__c tt:termdata){
        for(hed__Course_Offering__c tss:tt.hed__Course_Offerings__r){
            hedcourselist.add(tss);
        }
    }
    
    return hedcourselist;
    
}


@AuraEnabled(cacheable=true)
public static List<hed_Time_Table_Line_Item__c> getExamScheduleItems() {
    String userId = userInfo.getUserId();
    return [SELECT Id, Name, hed_Date__c, hed_Start_Time__c, hed_End_Time__c,Course__r.hed__Course_ID__c ,CreatedDate,Reva_Exam_Notification__c,Reva_Exam_Notification__r.Rve_Semester__c,Reva_Exam_Notification__r.hed_IA_Type__c FROM hed_Time_Table_Line_Item__c
            where CreatedById =:userId AND Reva_Exam_Notification__r.Rve_Publish__c  = true ];
}

@AuraEnabled(cacheable=true)
public static List<hed_Time_Table_Line_Item__c> getIAExamTimeTable(){
    try {
        String programBatch;
        String userId = userInfo.getUserId();
        User userCon = [SELECT Id, Username, Name, ContactId FROM User WHERE Id = :userId];
        List<Contact> conList = [SELECT Id, FirstName, LastName, Record_Type_Name__c, Program_Batch__c, Active_Semester__c FROM Contact WHERE Id = :userCon.ContactId];
        List<hed_Time_Table_Line_Item__c> timetableLineItem = new List<hed_Time_Table_Line_Item__c>();

        if (!conList.isEmpty()) {
            for (Contact con : conList) {
                programBatch = con.Program_Batch__c;
                System.debug('programBatch-->> ' + programBatch);
            }

            List<Rve_Exam_Notification__c> rveIANotification = [SELECT Id, Name, hed_Program_Batch__c, Rve_Semester__c, Rve_Publish__c, 
                                                                    (SELECT Id, Name, hed_Date__c, Course__r.hed__Course_ID__c, 
                                                                            Reva_Exam_Notification__r.hed_IA_Type__c, hed_End_Time__c,
                                                                            hed_Start_Time__c FROM Time_Table_Line_Items__r) 
                                                                    FROM Rve_Exam_Notification__c 
                                                                    WHERE hed_Program_Batch__c = :programBatch AND Rve_Publish__c = true];

            if (!rveIANotification.isEmpty()) {
                for (Rve_Exam_Notification__c rveIA : rveIANotification) {
                    for (hed_Time_Table_Line_Item__c lineItems : rveIA.Time_Table_Line_Items__r) {
                        timetableLineItem.add(lineItems);
                    }
                }
            }
        }

        // Return the list regardless of whether it is empty or not
        return timetableLineItem;

    } catch (Exception e) {
        System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        return new List<hed_Time_Table_Line_Item__c>();
    }
}


// Function to update TimeTable LineItems which is coming from examScheduleDisplay LWC
@AuraEnabled
public static void updategetExamScheduleItems(String JsonString){
System.debug('JsonString=> '+JsonString);
List<hed_Time_Table_Line_Item__c>updatedlist = new List<hed_Time_Table_Line_Item__c>();
try{
            // Deserialize the JSON string into a list of EventData objects
    List<timetableItem> timetableItemlist = (List<timetableItem>) JSON.deserialize(jsonString, List<timetableItem>.class);

    if(timetableItemlist.size()>0)
    {
    // Iterate through each EventData object and convert the fields
    for (timetableItem timetable : timetableItemlist) {
        // Convert StartTime to Time
        Time startTime = getformattedtime(timetable.StartTime);
        Time EndTime = getformattedtime(timetable.EndTime);
        
        // Convert EventDate to Date
        Date eventDate = Date.valueOf(timetable.LineItemDate);

        // Perform your logic with the converted fields, e.g., update records
        System.debug('ID: ' + timetable.Id);
        System.debug('StartTime: ' + startTime);
        System.debug('EventDate: ' + eventDate);
        
        // Example update logic (assuming you have an sObject to update)
            hed_Time_Table_Line_Item__c record = [SELECT Id, hed_Start_Time__c,hed_End_Time__c, hed_Date__c FROM hed_Time_Table_Line_Item__c WHERE Id = :timetable.Id LIMIT 1];
            record.hed_Start_Time__c = startTime;
            record.hed_End_Time__c = EndTime;
            record.hed_Date__c = eventDate;
            System.debug('record=> '+record);
            updatedlist.add(record);
    }
}

        if(updatedlist.size()>0)
        {
        update updatedlist;

        }

}
catch(Exception e)
{
    System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
}

}

// Helper method to parse time from string

public static Time getformattedtime(String TimeTobeConverted) {
    try {
        List<String> timeParts = TimeTobeConverted.split(' '); // Split time and AM/PM
        String timeValue = timeParts[0]; // e.g., "01:00:00"
        String amPm = timeParts[1]; // e.g., "PM"

        // Further split the time value into hours, minutes, and seconds
        List<String> timeComponents = timeValue.split(':');
        Integer hour = Integer.valueOf(timeComponents[0]);
        Integer minute = Integer.valueOf(timeComponents[1]);
        Integer second = Integer.valueOf(timeComponents[2]);

        // Convert to 24-hour format
        if (amPm == 'PM' && hour != 12) {
            hour += 12; // Convert PM hours (except 12 PM) to 24-hour format
        } else if (amPm == 'AM' && hour == 12) {
            hour = 0; // Convert 12 AM to 0 hours
        }

        // Create Time instance
        Time startTimes = Time.newInstance(hour, minute, second, 0);
        return startTimes;
    } catch (Exception e) {
        System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        // Return a default time instance or handle it appropriately
        return Time.newInstance(0, 0, 0, 0); // Default to 00:00:00
    }
}
    
@AuraEnabled
public static string IATimeTableCreation(String notificationName, String semesterActive, String programBatch, String TimeTableData, String Iatypevalue) {
try {    
    Rve_Exam_Notification__c rveNotification;
    
    List<Rve_Exam_Notification__c> existingPublishedNotifications = [
        SELECT Id, Rve_Publish__c 
        FROM Rve_Exam_Notification__c 
        WHERE hed_Program_Batch__c = :programBatch 
        AND Rve_Semester__c = :semesterActive 
        AND hed_IA_Type__c = :Iatypevalue
        AND Rve_Publish__c = TRUE                 
        LIMIT 1
    ];

    if (!existingPublishedNotifications.isEmpty()) {        
        rveNotification = existingPublishedNotifications[0];
    } else {        
        Id IANotificationRecordType = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByName().get('IA Notification').getRecordTypeId();
        rveNotification = new Rve_Exam_Notification__c(
            Name = notificationName,
            Rve_Publish__c = true,
            Rve_Semester__c = semesterActive,
            hed_Program_Batch__c = programBatch,
            hed_IA_Type__c = Iatypevalue,                    
            RecordTypeId = IANotificationRecordType
        );
        insert rveNotification;
    }

    List<TimeTableData> timetableItemlist = (List<TimeTableData>) JSON.deserialize(TimeTableData, List<TimeTableData>.class);
    List<hed_Time_Table_Line_Item__c> itemsToInsert = new List<hed_Time_Table_Line_Item__c>();
    List<hed_Time_Table_Line_Item__c> itemsToUpdate = new List<hed_Time_Table_Line_Item__c>();

    if (timetableItemlist.size() > 0) {
        for(TimeTableData Instance : timetableItemlist) {     
            
            Time startTime = Time.newInstance(
                Integer.valueOf(Instance.StartTime.split(':')[0]),
                Integer.valueOf(Instance.StartTime.split(':')[1]),
                Integer.valueOf(Instance.StartTime.split(':')[2].substring(0, 2)),
                0
            );
            Time endTime = Time.newInstance(
                Integer.valueOf(Instance.EndTime.split(':')[0]),
                Integer.valueOf(Instance.EndTime.split(':')[1]),
                Integer.valueOf(Instance.EndTime.split(':')[2].substring(0, 2)),
                0
            );
            
            hed_Time_Table_Line_Item__c rveExamLineItem = new hed_Time_Table_Line_Item__c(
                Reva_Exam_Notification__c = rveNotification.Id,
                Name = Instance.CourseName,
                hed_Date__c = Instance.ExamDate,
                Course__c = Instance.CourseId,
                hed_Start_Time__c = startTime,
                hed_End_Time__c = endTime
            );

            if (String.isNotBlank(Instance.Id)) {                
                rveExamLineItem.Id = Instance.Id;
                itemsToUpdate.add(rveExamLineItem);
            } else {                
                itemsToInsert.add(rveExamLineItem);
            }
        }
    }
    if (!itemsToUpdate.isEmpty()) {
        Database.SaveResult[] updateResults = Database.update(itemsToUpdate, false);
        for(Database.SaveResult sr : updateResults) {
            if (!sr.isSuccess()) {
                System.debug('Update Error: ' + sr.getErrors()[0].getMessage());
            }
        }
    }

    if (!itemsToInsert.isEmpty()) {
        System.debug('data:'+itemsToInsert);
        Database.SaveResult[] insertResults = Database.insert(itemsToInsert, false);
            for(Database.SaveResult sr : insertResults) {
            
            if (!sr.isSuccess()) {
                System.debug('Insert Error: ' + sr.getErrors()[0].getMessage());
            }
        }
    }
    
    return 'success';
}
catch(Exception e)
{
    System.debug('Line=> '+e.getLineNumber()+' Exception=> ' + e.getMessage());
    return 'Apex Error on line ' + e.getLineNumber() + ': ' + e.getMessage();
}
}

@AuraEnabled(cacheable=true)
public static Map<String,Object> getSemesterWithIADates(Id semesterId){
hed__Term__c term = [SELECT IA_1_Start_date__c, IA_1_End_date__c,IA_2_Start_date__c, IA_2_End_date__c
    FROM   hed__Term__c WHERE  Id = :semesterId LIMIT 1
];

    return new Map<String,Object>{
        'ia1Start' => term.IA_1_Start_date__c,
        'ia1End'   => term.IA_1_End_date__c,
        'ia2Start' => term.IA_2_Start_date__c,
        'ia2End'   => term.IA_2_End_date__c
    };
}
@AuraEnabled(cacheable=true)
public static List<hed_Time_Table_Line_Item__c> getExistingIATimeTable(String notificationName, String semesterId, String programBatch, String iaType) {

List<hed_Time_Table_Line_Item__c> existingItems = [SELECT Id, hed_Date__c, hed_Start_Time__c, hed_End_Time__c, Course__c,Reva_Exam_Notification__r.Name,
            Reva_Exam_Notification__r.hed_IA_Type__c,CreatedDate FROM hed_Time_Table_Line_Item__c
    WHERE Reva_Exam_Notification__r.Name = :notificationName AND Reva_Exam_Notification__r.Rve_Semester__c = :semesterId AND Reva_Exam_Notification__r.hed_Program_Batch__c = :programBatch
        AND Reva_Exam_Notification__r.hed_IA_Type__c = :iaType AND Reva_Exam_Notification__r.Rve_Publish__c = true
        ];

return existingItems;
}


public class TimeTableData{
    public String Id {get;set;}
    public String CourseId {get;set;}
    public String CourseIdName {get;set;}
    public String CourseName {get;set;}
    public Date ExamDate {get;set;}
    public String StartTime {get;set;}
    public String EndTime {get;set;}

}

public class examStartTimeDetails{
    public string recordIdvalue{get;set;}
    public String starttime{get;set;} 
    public String courseName {get;set;}       
}

public class examEndTimeDetails{
    public string recordIdvalue {get;set;}
    public String endtime {get;set;} 
    public String courseName {get;set;}       
}

public class examDateDetails{
    public string recordIdvalue {get;set;}
    public String examdate {get;set;} 
    public String courseName {get;set;}       
}

}