public class rveAttendanceEventHandler {

    public class InsertOrUpdateAttendanceEvent{

        @AuraEnabled
        public list<contact> ContactList {get;set;}

        @AuraEnabled
        public list<hed__Attendance_Event__c> AttendanceList {get;set;}

        @AuraEnabled
        public String InvigilatorRecordId {get;set;}

        @AuraEnabled
        public Time StartTime {get;set;}

        @AuraEnabled
        public Time EndTime {get;set;}


    }
/*
    public rveAttendanceEventHandler(){
        
    }*/
    
    @AuraEnabled
    public static list<hed__Attendance_Event__c> getAllAttendanceEvents(String ShiftType){
        try {
            Time Shift= Time.newInstance(12, 0, 0,0);
            list<hed__Attendance_Event__c>Attendancelist = new list<hed__Attendance_Event__c>();
            if(ShiftType == 'Morning'){
                
             Attendancelist = [Select Id,hed__Attendance_Type__c,hed__Arrival_Time__c,
                                                         hed__Contact__r.SRN_Number__c,hed__Contact__r.Name
                                                         from hed__Attendance_Event__c where hed__Date__c = :System.today() and hed__Arrival_Time__c<=:Shift];
            }
            if(ShiftType == 'Afternoon'){

             Attendancelist = [Select Id,hed__Attendance_Type__c,hed__Arrival_Time__c,
                                                             hed__Contact__r.SRN_Number__c,hed__Contact__r.Name
                                                             from hed__Attendance_Event__c where hed__Date__c = :System.today() and hed__Arrival_Time__c>=:Shift];
            }
            

        return Attendancelist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static InsertOrUpdateAttendanceEvent checkInvigilatorAssignment(String RoomNo,Date AttendanceDate,String AttendanceTime,String ProfessorId){
      System.debug('RoomNo=> '+RoomNo+' AttendanceDate=> '+AttendanceDate+' AttendanceTime=> '+AttendanceTime+' Professor=> '+professorId);
      InsertOrUpdateAttendanceEvent NewInstance = new InsertOrUpdateAttendanceEvent();
        NewInstance.ContactList = new List<contact>();
        NewInstance.AttendanceList = new List<hed__Attendance_Event__c>();  
      try {
            Time FormattedTime = parseTime(AttendanceTime);

            List<rve_Invigilator_Assignment__c> InvigilatorAssignment = [SELECT Id, Name, rve_Date__c, rve_Shift__c,rve_Exam_Time__c, rve_Exam_End_Time__c,rve_Attendance_Submitted__c,rve_Professor__c, rve_Professor__r.name
                                                                        FROM rve_Invigilator_Assignment__c
                                                                        WHERE rve_Date__c =:AttendanceDate AND Name=:RoomNo AND rve_Exam_Time__c=:FormattedTime AND rve_Professor__c=:ProfessorId Limit 1];

                                                                        
            System.debug('InvigilatorAssignment=> '+InvigilatorAssignment);
            if(!InvigilatorAssignment.isEmpty())
            {
                NewInstance.InvigilatorRecordId = InvigilatorAssignment[0].Id;
                NewInstance.StartTime = InvigilatorAssignment[0].rve_Exam_Time__c;
                NewInstance.EndTime = InvigilatorAssignment[0].rve_Exam_End_Time__c;
                if(InvigilatorAssignment[0].rve_Attendance_Submitted__c == false)
                {
                    System.debug('contactdetailsCalled');
                    NewInstance.ContactList = rve_InvigilatorAttendenceController.contactdetails(InvigilatorAssignment[0].rve_Date__c, InvigilatorAssignment[0].rve_Shift__c,InvigilatorAssignment[0].Name,InvigilatorAssignment[0].rve_Exam_Time__c, InvigilatorAssignment[0].rve_Exam_End_Time__c,ProfessorId);

                }
                else{
                    System.debug('getAttendanceBasedOnDateCalled');
                    NewInstance.AttendanceList = getAttendanceBasedOnDate(RoomNo,InvigilatorAssignment[0].rve_Date__c,AttendanceTime);
                }
        
            }

            
        } catch (Exception e) {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return NewInstance;

    }

    @AuraEnabled(Cacheable=true)
    public static list<hed__Attendance_Event__c> getAllAttendanceEventsForSchoolHead(){
        try {
           
            list<hed__Attendance_Event__c>Attendancelist = new list<hed__Attendance_Event__c>();
                
             Attendancelist = [Select Id,hed__Attendance_Type__c,hed__Start_Time__c,
                                                         hed__Contact__r.SRN_Number__c,hed__Contact__r.Name
                                                         from hed__Attendance_Event__c];

        return Attendancelist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list<hed__Attendance_Event__c> getAttendanceBasedOnDate(String RoomNo,Date AttendanceDate,String AttendanceTime){
        try {
            System.debug('RoomNo=> '+RoomNo+' AttendanceDate=> '+AttendanceDate+' AttendanceTime=> '+AttendanceTime);
            Time FormattedTime = parseTime(AttendanceTime);
            System.debug('FormattedTime=> '+FormattedTime);
            list<hed__Attendance_Event__c>Attendancelist = new list<hed__Attendance_Event__c>();
                
             Attendancelist = [Select Id,hed__Attendance_Type__c,hed__Start_Time__c,
                                                         hed__Contact__r.SRN_Number__c,hed__Contact__r.Name,hed_IA_Remarks__c
                                                         from hed__Attendance_Event__c where hed__Date__c=:AttendanceDate AND hed__Start_Time__c=:FormattedTime AND rve_Room_Number__c=:RoomNo Order By hed__Contact__r.SRN_Number__c Asc];


            System.debug('Attendancelist=> '+Attendancelist.size());
        return Attendancelist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Time parseTime(String timeString) {
        Time formattedTime;
        try {
            // Split the string to extract hours, minutes, and seconds
            List<String> parts = timeString.split(':');
            Integer hours = Integer.valueOf(parts[0]);
            Integer minutes = Integer.valueOf(parts[1]);
            Integer seconds = Integer.valueOf(parts[2].substring(0, 2)); // Remove ' AM' or ' PM'
            
            // Adjust hours if it's PM
            if (timeString.endsWith(' PM') && hours != 12) {
                hours += 12;
            } else if (timeString.endsWith(' AM') && hours == 12) {
                hours = 0;
            }
            
            // Construct a Time instance
            formattedTime = Time.newInstance(hours, minutes, seconds, 0);
        } catch (Exception e) {
            formattedTime = null;
            System.debug('Error parsing time: ' + e.getMessage());
        }
        return formattedTime;
    }

    @AuraEnabled
    public static string updateRecords(list<hed__Attendance_Event__c>Attendancelist){
        try {
            System.debug('Attendancelist=> '+Attendancelist);
            
            list<hed__Attendance_Event__c>RecordsToUpdate = new list<hed__Attendance_Event__c>();
            for (hed__Attendance_Event__c Attendances : Attendancelist) {
                if(Attendances.hed__Start_Time__c!=null){
                String aes = String.valueOf(Attendances.hed__Start_Time__c);
                String[] sea = aes.split(':');
                Time val = Time.newInstance(Integer.valueOf(sea[0]),Integer.valueOf(sea[1]),0,0);
                System.debug('Id=> '+Attendances.Id+'typeof=> '+Attendances.hed__Start_Time__c);
                hed__Attendance_Event__c acc = new hed__Attendance_Event__c(Id=Attendances.Id);
                acc.hed__Attendance_Type__c = Attendances.hed__Attendance_Type__c;
                acc.hed__Start_Time__c = val;
                acc.hed_IA_Remarks__c = Attendances.hed_IA_Remarks__c;
                RecordsToUpdate.add(acc);
            }
            else{
                System.debug('Id=> '+Attendances.Id+'typeof=> '+Attendances.hed__Arrival_Time__c);
                hed__Attendance_Event__c acc = new hed__Attendance_Event__c(Id=Attendances.Id);
                acc.hed__Attendance_Type__c = Attendances.hed__Attendance_Type__c;
                acc.hed_IA_Remarks__c = Attendances.hed_IA_Remarks__c;
                RecordsToUpdate.add(acc);               
            }
                
            }
            System.debug('RecordsToUpdate=> '+RecordsToUpdate);
            update(RecordsToUpdate);

        return 'success';
     } catch (Exception e) {
           System.debug('Line=> '+e.getLineNumber()+'Exception=> '+e.getMessage());
           return e.getMessage();
        }
}
}