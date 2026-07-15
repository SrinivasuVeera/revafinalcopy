public without Sharing class TT_ViewSchedule_StudentCls {
    @AuraEnabled
    public static ResponseWrp getTimeTableRecords(String selectedCourse) {
        System.debug('selectedCourse'+selectedCourse);
        System.debug('firstmethod called);');
        List<SlotTimeWrp> lst_Slot = new List<SlotTimeWrp>();
        List<ScheduleWrp> filteredSchedule = new List<ScheduleWrp>();
        Set<Time> uTime = new Set<Time>(); 
        Set<Id> set_Ids = new Set<Id>();
        Set<String> set_OfferingIds = new Set<String>();
        String tempHold = '';
        Integer count;
        Map<String, List<SlotWrp>> tempWrp = new Map<String, List<SlotWrp>>();
        Map<String, List<hed__Course_Offering_Schedule__c>> dayAndCOSMap = new Map<String, List<hed__Course_Offering_Schedule__c>>();
        List<String> daysList = new List<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
            ResponseWrp wrp = new ResponseWrp();
       User usr = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        //User usr = [SELECT Id, Name, ContactId FROM User WHERE Id = '0051e00000582SOAAY'];
        Contact contactRec = new Contact();
        String ContactId;
        if (usr.ContactId != null) {
            contactRec = [SELECT Id, Name, Recordtype.Name, ReportsToId FROM Contact WHERE id = :usr.ContactId];
            if (contactRec.Recordtype.Name == utility.Contact_RecType_Student) ContactId = contactRec.id;
            else if (contactRec.Recordtype.Name == utility.Contact_RecType_Parent) ContactId = contactRec.ReportsToId;
        }
        String sectionId = '';
        for (hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c, hed__Course_Offering__r.Category__c, Section__c FROM hed__Course_Enrollment__c 
                                                   WHERE Active_Connection__c = true AND hed__Contact__c = :ContactId]) {
                                                       set_OfferingIds.add(eachConn.hed__Course_Offering__c);
                                                       if (eachConn.Section__c != null && eachConn.hed__Course_Offering__r.Category__c == 'Hardcore Course') sectionId = eachConn.Section__c;
                                                       set_Ids.add(eachConn.Section__c);
                                                   }
        set_Ids.add(null);
        hed__Term__c term = [SELECT hed__Account__r.Name, hed__Parent_Term__r.Academic_Year__c, hed__Account__r.Parent.name, Section_Name__c, hed__Parent_Term__r.Term_Number__c FROM hed__Term__c WHERE Id = :sectionId];
        System.debug('Term ' + term);
        wrp.programName = term.hed__Account__r.Name;
        wrp.schoolName = term.hed__Account__r.Parent.name;
        wrp.semesterName = String.valueOf(term.hed__Parent_Term__r.Term_Number__c);
        wrp.secName = term.Section_Name__c;
        wrp.acdYear = term.hed__Parent_Term__r.Academic_Year__c;
        wrp.lst_Faculties = getFaculties(sectionId, set_OfferingIds); 
        System.debug('set_OfferingIds' + set_OfferingIds);
        if (set_OfferingIds.size() > 0) {
            for (hed__Course_Offering_Schedule__c cosObj : [SELECT Id, hed__Start_Time__c, hed__End_Time__c, Section__r.hed__Parent_Term__r.hed__Account__r.Name, hed__Course_Offering__c,
                                                            Status__c, Section__r.hed__Parent_Term__r.Term_Number__c, Batch_Group__r.Batch_Short_Name__c, hed__Course_Offering__r.hed__Course__r.Name ,
                                                            Break__c, hed__Monday__c, hed__Tuesday__c, hed__Wednesday__c, hed__Thursday__c, hed__Friday__c, hed__Saturday__c, hed__Sunday__c,
                                                            hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c, Display_Name__c, Free_Slot__c, hed__Facility__c, hed__Facility__r.Name,Facility_Request__r.Name
                                                            FROM hed__Course_Offering_Schedule__c 
                                                            WHERE Date__c = null AND Batch_Group__c IN :set_Ids AND 
                                                            (hed__Course_Offering__c IN :set_OfferingIds OR 
                                                             (Section__c = :sectionId AND hed__Course_Offering__c = null AND 
                                                              (hed__Saturday__c = true OR hed__Sunday__c = true OR Break__c = true OR Free_Slot__c = true OR Display_Name__c != null)))
                                                            ORDER BY hed__Start_Time__c]) 
            {
                if (!uTime.contains(cosObj.hed__Start_Time__c)) {
                    String dayvalue;
                    if(cosObj.hed__Monday__c){
                        dayvalue = 'Monday';
                    }
                    if(cosObj.hed__Tuesday__c){
                        dayvalue = 'Tuesday';
                    }
                    if(cosObj.hed__Wednesday__c){
                        dayvalue = 'Wednesday';
                    }
                    if(cosObj.hed__Thursday__c){
                        dayvalue = 'Thursday';
                    }
                    if(cosObj.hed__Friday__c){
                        dayvalue = 'Friday';
                    }
                    if(cosObj.hed__Saturday__c){
                        dayvalue = 'Saturday';
                    }
                    if(cosObj.hed__Sunday__c){
                        dayvalue = 'Sunday';
                    }
                    lst_Slot.add(new SlotTimeWrp(dayvalue, String.valueOf(cosObj.hed__Start_Time__c).substringBeforeLast(':'), String.valueOf(cosObj.hed__End_Time__c).substringBeforeLast(':')));
                    uTime.add(cosObj.hed__Start_Time__c);
                }
                String keyStr = cosObj.hed__Monday__c ? 'Monday' :
                cosObj.hed__Tuesday__c ? 'Tuesday' :
                cosObj.hed__Wednesday__c ? 'Wednesday' :
                cosObj.hed__Thursday__c ? 'Thursday' :
                cosObj.hed__Friday__c ? 'Friday' : 
                cosObj.hed__Saturday__c ? 'Saturday' :
                cosObj.hed__Sunday__c ? 'Sunday' : '';
                if (dayAndCOSMap.get(keyStr) == null)
                    dayAndCOSMap.put(keyStr, new List<hed__Course_Offering_Schedule__c>{cosObj});           
                else
                    dayAndCOSMap.get(keyStr).add(cosObj);
            }
        }
        List<SlotWrp> s;
        for (String dayName : daysList) { 
            s = new List<SlotWrp>();
            for (Time t : uTime) {
                s.add(new SlotWrp(t + '', '', 1)); 
            }
            tempWrp.put(dayName, s);
        }        
        if (dayAndCOSMap.size() == 0) {
            wrp.resStatus  = 'Error';
            wrp.resMessage = 'No Schedule found for the given Student.';
            return wrp;
        } else {
            wrp.resStatus  = 'Success';
        }
        System.debug('====Retrieved Course Offering Schedules====' + JSON.serialize(dayAndCOSMap));
        wrp.lst_TimeSlot = lst_Slot;
        wrp.lst_Sch = new List<ScheduleWrp>();
        for (String day : daysList) {
            List<SlotWrp> lst_Slots = new List<SlotWrp>();
            Map<String, String> slotAndCSMap = new Map<String, String>(); // Define the map here
            if (dayAndCOSMap.get(day) != null) {
                for (hed__Course_Offering_Schedule__c cos : dayAndCOSMap.get(day)) { 
                    String cs = slotAndCSMap.get(String.valueOf(cos.hed__Start_Time__c));
                    if (String.isBlank(cs)) cs = '' ;
                    else cs = '';
                    if (cos.Break__c && !(cos.hed__Saturday__c  || cos.hed__Sunday__c)) cs = 'Break';
                    else if (cos.Free_Slot__c) cs = '';
                    else if (!cos.Break__c && !(cos.hed__Saturday__c  || cos.hed__Sunday__c) && cos.hed__Course_Offering__c == null){
                        cs = cos.Display_Name__c == null ? '' : cos.Display_Name__c;
                    }
                    cs += cos.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c == null ? '' : cos.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c;
                    if (cos.Batch_Group__r.Batch_Short_Name__c != null) cs += '(' + cos.Batch_Group__r.Batch_Short_Name__c + ')';
                    slotAndCSMap.put(String.valueOf(cos.hed__Start_Time__c), cs);
                }
                List<SlotWrp> temp = tempWrp.get(day);
                for (SlotWrp slot : temp) {
                    if (slotAndCSMap.containsKey(slot.slotname)) {
                        lst_Slots.add(new SlotWrp(slot.slotname + '', slotAndCSMap.get(slot.slotname), 1));
                    } else {
                        lst_Slots.add(slot);
                    }
                }
                String formattedTime = tempWrp.get(day).get(uTime.size() - 1).slotname;
                System.debug('====formatted Time====' + formattedTime);
                String dayAndTime = day + ': (' + lst_Slots[0].slotname + ' - ' + formattedTime + ')';
                System.debug('====Day and Time====' + dayAndTime);
                wrp.lst_Sch.add(new ScheduleWrp(dayAndTime, day, lst_Slots));
            }
            system.debug('first ended');
            /*       
system.debug
String formattedTime = tempWrp.get(day).get(uTime.size() - 1).slotname;
String dayAndTime = day + ' - ' + lst_Slots[0].slotname + ' - ' + formattedTime;
System.debug('====Day and Time====' + dayAndTime);
wrp.lst_Sch.add(new ScheduleWrp(dayAndTime, day, lst_Slots));
}
*/
        }
        return wrp;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getDistinctCourseNames(String recordId) {
        System.debug('Record Id ' + recordId);
        system.debug('second method called');
        List<String> distinctCourseNames = new List<String>();        
        Set<String> courseNamesSet = new Set<String>();        
        for (hed__Course_Enrollment__c enrollment : [SELECT hed__Course_Offering__r.Name FROM hed__Course_Enrollment__c WHERE Active_Connection__c = true AND hed__Contact__c = :recordId]) {
            if (!courseNamesSet.contains(enrollment.hed__Course_Offering__r.Name)) {
                courseNamesSet.add(enrollment.hed__Course_Offering__r.Name);
                distinctCourseNames.add(enrollment.hed__Course_Offering__r.Name);
            }
        }
        System.debug('distinctCourseNames' + distinctCourseNames);
        return distinctCourseNames;
    }
    public static List<FacultyWrp> getFaculties(String i_SectionId, Set<String> set_OfferingIds) {
        Map<String, List<String>> courseFacilityMap = new Map<String, List<String>>();
        Map<String, String> courseDayAndTimeMap = new Map<String, String>();
        List<FacultyWrp> o_Faculties = new List<FacultyWrp>();
        String ScheduleName;
        String dayAndTime;
        List<String> facilities = new List<String>();
        // Querying start and end time and days in hed__Course_Offering_Schedule__c 
        for (hed__Course_Offering_Schedule__c schedule : [
            SELECT Id,hed__Facility__r.Name,Facility_Request__r.Name,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Course_Offering__r.Name,
            hed__Start_Time__c, hed__End_Time__c, hed__Monday__c, hed__Tuesday__c, hed__Wednesday__c,
            hed__Thursday__c, hed__Friday__c, hed__Saturday__c, hed__Sunday__c, Name , Facility_Request__r.Facility__r.Name
            FROM hed__Course_Offering_Schedule__c
            WHERE hed__Course_Offering__c IN :set_OfferingIds AND Date__c = null]) {
                String CsId=schedule.Id;
                System.debug('====couroff Id in getfaculty====' + CsId);
                String courseId = schedule.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c;
                System.debug('====couroff courseId in getfaculty====' + courseId);
                String facilityName = schedule.Facility_Request__r.Facility__r.Name;
                System.debug('====couroff facilityName in getfaculty====' + facilityName);
                ScheduleName = schedule.Name;
                System.debug('====couroff ScheduleName in getfaculty====' + ScheduleName);
                dayAndTime = getDayAndTime(schedule);
                System.debug('====couroff dayAndTime in getfaculty====' + dayAndTime);
                courseDayAndTimeMap.put(courseId, dayAndTime);
                System.debug('====couroff courseId in getfaculty====' + courseId);
                System.debug('====couroff dayAndTime in courseDayAndTimeMap====' + courseDayAndTimeMap.get(courseId));
                if (!courseFacilityMap.containsKey(courseId)) {
                    courseFacilityMap.put(courseId, new List<String>{facilityName});
                } else {
                    if (!courseFacilityMap.get(courseId).contains(facilityName)) {
                        courseFacilityMap.get(courseId).add(facilityName);
                    }
                }
                
                o_Faculties.add(new FacultyWrp(null, ScheduleName, courseId,  schedule.hed__Course_Offering__r.Name,
                                                   schedule.Facility_Request__r.Name, facilityName, dayAndTime));
                System.debug('====couroff courseFacilityMap in getfaculty====' + courseFacilityMap);
            }
         Map<String, String> mp_Fac = new Map<String, String>();   
		Map<String, String> mp_CourseName = new Map<String, String>();
        for (hed__Course_Enrollment__c eachConn : [
            SELECT Id, Course_Code__c, hed__Course_Offering__r.Name, hed__Contact__r.Name FROM hed__Course_Enrollment__c
            WHERE hed__Course_Offering__c IN :set_OfferingIds AND hed__Contact__r.RecordType.Name = 'Professor']) {
                mp_CourseName.put(eachConn.Course_Code__c, eachConn.hed__Course_Offering__r.Name);
                if (mp_Fac.get(eachConn.Course_Code__c) == null) {
                    mp_Fac.put(eachConn.Course_Code__c, eachConn.hed__Contact__r.Name);
                } else {
                    if (!mp_Fac.get(eachConn.Course_Code__c).contains(eachConn.hed__Contact__r.Name)) {
                        mp_Fac.put(eachConn.Course_Code__c, mp_Fac.get(eachConn.Course_Code__c) + '/ ' + eachConn.hed__Contact__r.Name);
                    }
                }
            }
        
        for (FacultyWrp wrp : o_Faculties) {
            if(mp_Fac.containsKey(wrp.courseCode)) {
            	wrp.facultyName = mp_Fac.get(wrp.courseCode);
            }
        }
        
         return o_Faculties;
       /* Map<String, String> mp_Fac = new Map<String, String>();       
        Map<String, String> mp_CourseName = new Map<String, String>();
        // Querying faculties related to course offerings
        for (hed__Course_Enrollment__c eachConn : [
            SELECT Id, Course_Code__c, hed__Course_Offering__r.Name, hed__Contact__r.Name FROM hed__Course_Enrollment__c
            WHERE hed__Course_Offering__c IN :set_OfferingIds AND hed__Contact__r.RecordType.Name = 'Professor']) {
                mp_CourseName.put(eachConn.Course_Code__c, eachConn.hed__Course_Offering__r.Name);
                if (mp_Fac.get(eachConn.Course_Code__c) == null) {
                    mp_Fac.put(eachConn.Course_Code__c, eachConn.hed__Contact__r.Name);
                } else {
                    if (!mp_Fac.get(eachConn.Course_Code__c).contains(eachConn.hed__Contact__r.Name)) {
                        mp_Fac.put(eachConn.Course_Code__c, mp_Fac.get(eachConn.Course_Code__c) + '/ ' + eachConn.hed__Contact__r.Name);
                    }
                }
            }
        for (String courseCode : mp_Fac.keySet()) {
            System.debug('====Processing courseCode: ' + courseCode + '====');
            if (courseFacilityMap.containsKey(courseCode)) {
                System.debug('====courseFacilityMap====' + courseFacilityMap);
                facilities = courseFacilityMap.get(courseCode);
                System.debug('====facilities====' + facilities); 
                for (String facility : facilities) {
                    System.debug('====facility====' + facility);
                    System.debug('====courseCode====' + courseCode);
                    String dayAndTime1 = courseDayAndTimeMap.get(courseCode);
                    System.debug('====dayAndTime in courseFacilityMap ====' + dayAndTime1);
                    System.debug('====ScheduleName in courseFacilityMap ====' + ScheduleName);
                    System.debug('====mp_CourseName====' + mp_CourseName);
                    System.debug('====mp_Fac====' + mp_Fac);
                    System.debug('==== courseDayAndTimeMap====' + courseDayAndTimeMap);
                    //System.debug('==== dayAndTime in courseDayAndTimeMap====' + courseDayAndTimeMap.get(courseId));
                    o_Faculties.add(new FacultyWrp(null, ScheduleName, courseCode, mp_CourseName.get(courseCode),
                                                   mp_Fac.get(courseCode), facility, dayAndTime1)); // Ensure dayAndTime is set
                    System.debug('====oFaculties====' + o_Faculties.get(0) );
                }
                
            }
        }
        system.debug('o_Faculties-->'+o_Faculties);
        system.debug('second ended');
        return o_Faculties;*/
    }
    private static String getDayAndTime(hed__Course_Offering_Schedule__c schedule) {        
        String dayAndTime = '';        
        if (schedule.hed__Monday__c) dayAndTime = 'Monday';        
        else if (schedule.hed__Tuesday__c) dayAndTime = 'Tuesday';        
        else if (schedule.hed__Wednesday__c) dayAndTime = 'Wednesday';        
        else if (schedule.hed__Thursday__c) dayAndTime = 'Thursday';        
        else if (schedule.hed__Friday__c) dayAndTime = 'Friday';        
        else if (schedule.hed__Saturday__c) dayAndTime = 'Saturday';        
        else if (schedule.hed__Sunday__c) dayAndTime = 'Sunday'; 
                System.debug('====Day and Time for Schedule====' + schedule.hed__Start_Time__c);        
                System.debug('====Day and Time for Schedule====' + schedule.hed__End_Time__c);        
        dayAndTime += ': (' + String.valueOf(schedule.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(schedule.hed__End_Time__c).substringBeforeLast(':') + ')';        
        System.debug('====Day and Time for Schedule====' + dayAndTime);        
        return dayAndTime;        
    }    
    public class ResponseWrp{
        @AuraEnabled public String resStatus {get;set;}        
        @AuraEnabled public String resMessage {get;set;}        
        @AuraEnabled public String schoolName {get;set;}        
        @AuraEnabled public String programName {get;set;}        
        @AuraEnabled public String semesterName {get;set;}        
        @AuraEnabled public String secName {get;set;}        
        @AuraEnabled public String acdYear  {get;set;}        
        @AuraEnabled public List<ScheduleWrp> lst_Sch {get;set;}          
        @AuraEnabled public List<SlotTimeWrp> lst_TimeSlot {get;set;}          
        @AuraEnabled public List<FacultyWrp> lst_Faculties {get;set;}          
    }    
    public class ScheduleWrp {       
        @AuraEnabled public String dayAndTime { get; set; }        
        @AuraEnabled public String dayName { get; set; }        
        @AuraEnabled public List<SlotWrp> lst_Slots { get; set; }        
        public ScheduleWrp(String dayAndTime, String dayName, List<SlotWrp> lst_Slots) {            
            System.debug('**dayAndTime in schedule wrapper//---->'+dayAndTime);            
            System.debug('**dayName in schedule wrapper//---->'+dayName);            
            this.dayAndTime = dayAndTime;            
            this.dayName = dayName;           
            this.lst_Slots = lst_Slots;            
        }       
    }    
    public class SlotWrp{        
        @AuraEnabled public String slotname {get;set;}        
        @AuraEnabled public String  courseNames {get;set;}        
        @AuraEnabled public Integer  colLen {get;set;}        
        public SlotWrp( String slotname, String  courseNames,Integer  colLen) {            
            this.slotname = slotname;            
            this.courseNames = courseNames;           
            this.colLen = colLen;           
        }              
    }    
        public class SlotTimeWrp{        
        @AuraEnabled public String sTime {get;set;}        
        @AuraEnabled public String eTime {get;set;} 
        @AuraEnabled public String day {get;set;}  
        public SlotTimeWrp(String day, String sTime, String eTime){            
            this.sTime = sTime;            
            this.eTime = eTime; 
            this.day = day;
             System.debug('**dayAndTime in SlotTimeWrpr---->'+sTime);            
             System.debug('**coursoffsch in SlotTimeWrp--->'+eTime);
        }        
    }    
    public class FacultyWrp{        
        @AuraEnabled public String connectionId {get;set;}        
        @AuraEnabled public String coursoffsch { get; set; }        
        @AuraEnabled public String  courseCode {get;set;}        
        @AuraEnabled public String  coursename {get;set;}        
        @AuraEnabled public String  facultyName {get;set;}        
        @AuraEnabled public String  facilityName {get;set;}
        @AuraEnabled public String dayAndTime { get; set; } // Add this attribute
        public FacultyWrp(String connectionId,String coursoffsch, String courseCode, String coursename, String facultyName, String facilityName, String dayAndTime) {            
            System.debug('**dayAndTime in faculty wrapper---->'+dayAndTime);            
            System.debug('**coursoffsch in faculty wrapper---->'+coursoffsch);            
            this.connectionId = connectionId;            
            this.coursoffsch = coursoffsch;            
            this.courseCode = courseCode;            
            this.coursename = coursename;            
            this.facultyName = facultyName;            
            this.facilityName = facilityName;
            this.dayAndTime = dayAndTime; // Populate this attribute            
        }              
    }   
}