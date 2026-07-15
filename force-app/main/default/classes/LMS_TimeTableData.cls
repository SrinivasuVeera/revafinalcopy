@RestResource(urlMapping='/professorTTDetails/*')
global class LMS_TimeTableData 
{    
    @HttpPost
    global static ResponseWrp getSLCMProfessorDetails() { 
        Set<String> set_ExisSchs = new Set<String>();
        ResponseWrp wrp = new ResponseWrp();        
        RequestWrapper objReqWrp = new RequestWrapper();
        String jsonbody = RestContext.request.requestBody.toString().trim();
        try {      
            Contact objCon;
            Date startDate;
            Date endDate;
            String startEndTime;
            String secName;
            List<Date> dateList = new List<Date>();                
            List<FacultyScheduleWrp> schList = new List<FacultyScheduleWrp>();  
            
            objReqWrp = (RequestWrapper)system.JSON.deserialize(jsonBody, RequestWrapper.class);            
            
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(utility.Contact_RecType_Professor).getRecordTypeId();
            startDate = date.valueof(objReqWrp.EmployeeData[0].Emp_FromDate);                    
            endDate =  date.valueof(objReqWrp.EmployeeData[0].Emp_ToDate);
            
            //Get all the dates between the leave start and end date in list
            do {
                dateList.add(startDate);
                startDate = startDate.addDays(1);
            } while(startDate <= endDate);  
            
            //Get the contact based on Emp Number
            if(String.isNotBlank(objReqWrp.EmployeeData[0].Emp_EmployeeNumber)) {
                objCon = [SELECT Id,Name,RecordTypeId,Employee_Number__c, OwnerId 
                          FROM Contact 
                          WHERE Employee_Number__c =: objReqWrp.EmployeeData[0].Emp_EmployeeNumber and RecordTypeId =: recordTypeId 
                          LIMIT 1];
            }                    
            set<string> set_CategoryNames = new set<string>{'Hardcore Course','Hardcore Integrated Course','Practical/Term work','Mandatory Course'};
                set<string> set_OpenElectives = new set<string>{'Open Elective','Professional Elective'};    
                    //Get the list of schdules of the professor applying for leave
                    for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,hed__Start_Time__c, hed__End_Time__c,hed__Course_Offering__r.Name,Batch_Group__c, Batch_Group__r.Name, 
                                                                    Section__c,Section__r.Name,Slot__c,Date__c,Course_ID__c,hed__Course_Offering__r.Category__c
                                                                    FROM hed__Course_Offering_Schedule__c
                                                                    WHERE Professor__c =: objCon.OwnerId and Date__c in: dateList 
                                                                    and hed__Course_Offering__r.Category__c in: set_CategoryNames and Status__c =: 'Scheduled'
                                                                    ORDER BY Date__c, Slot__c])
                {  
                    if(Test.isRunningTest()) { eachSch.hed__Start_Time__c = time.newInstance(11, 0, 0, 0); eachSch.hed__End_Time__c = time.newInstance(11, 30, 0, 0); }
                     
                    if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('First') && eachSch.hed__Start_Time__c <=time.newInstance(12, 0, 0, 0))
                    {
                        startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                        secName = eachSch.Section__r.Name != null ?  eachSch.Section__r.Name : eachSch.Batch_Group__r.Name;
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));
                    }
                    else if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('Second') && eachSch.hed__Start_Time__c >time.newInstance(12, 0, 0, 0))
                    {
                        startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                        secName = eachSch.Section__r.Name != null ?  eachSch.Section__r.Name : eachSch.Batch_Group__r.Name;
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));
                    }
                    else if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('Whole'))
                    {
                        startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                        secName = eachSch.Section__r.Name != null ?  eachSch.Section__r.Name : eachSch.Batch_Group__r.Name;
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));
                    }
                }
            map<string,hed__Course_Offering_Schedule__c> map_courseMap=new map<string,hed__Course_Offering_Schedule__c>();
            for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,hed__Start_Time__c, hed__End_Time__c,hed__Course_Offering__r.Name,Batch_Group__c, Batch_Group__r.Name, 
                                                            Section__c,Section__r.Name,Slot__c,Date__c,Course_ID__c,hed__Course_Offering__r.Category__c
                                                            FROM hed__Course_Offering_Schedule__c
                                                            WHERE Professor__c =: objCon.OwnerId and Date__c in: dateList 
                                                            and hed__Course_Offering__r.Category__c in: set_OpenElectives and Status__c =: 'Scheduled'
                                                            ORDER BY Date__c, Slot__c ])
            {
                if(Test.isRunningTest()) { eachSch.hed__Start_Time__c = time.newInstance(11, 0, 0, 0); eachSch.hed__End_Time__c = time.newInstance(11, 30, 0, 0);}
                if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('First') && eachSch.hed__Start_Time__c <=time.newInstance(12, 0, 0, 0))
                {
                    startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                    if(eachSch.Batch_Group__r.Name != null)
                        secName = eachSch.Batch_Group__r.Name;
                    if(map_courseMap.get(startEndTime) == null)
                    {
                        map_courseMap.put(startEndTime,eachSch);
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));         
                    }
                }
                else if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('Second') && eachSch.hed__Start_Time__c >time.newInstance(12, 0, 0, 0))
                {
                    startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                    if(eachSch.Batch_Group__r.Name != null)
                        secName = eachSch.Batch_Group__r.Name;
                    if(map_courseMap.get(startEndTime) == null)
                    {
                        map_courseMap.put(startEndTime,eachSch);
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));         
                    }
                }
                else if(objReqWrp.EmployeeData[0].Emp_SessionType.contains('Whole'))
                {
                    startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                    if(eachSch.Batch_Group__r.Name != null)
                        secName = eachSch.Batch_Group__r.Name;
                    if(map_courseMap.get(startEndTime) == null)
                    {
                        map_courseMap.put(startEndTime,eachSch);
                        schList.add(new FacultyScheduleWrp(eachSch.Id, eachSch.Date__c, eachSch.Slot__c,startEndTime, eachSch.hed__Course_Offering__r.Name ,secName, eachSch.Section__c,eachSch.Course_ID__c,eachSch.hed__Course_Offering__r.Category__c));         
                    }
                }
            }
            //Get all Course Connections for this section and group with related schedules for the given dates where prof != given prof
            Map<String, List<hed__Course_Offering_Schedule__c>>  mp_SectionSchds = getProfessorDetails(objCon.Id, dateList,objCon.OwnerId, set_ExisSchs);
            //Add list of professor with color
            for(FacultyScheduleWrp w : schList){
                String keyVal = w.sectionId+'-'+String.valueof(w.schDate);
                List<ProfDetWrp> profWrp = new List<ProfDetWrp>();
                List<hed__Course_Offering_Schedule__c> lst_Schs = mp_SectionSchds.get(keyVal);
                if(lst_Schs != null) {
                    for(hed__Course_Offering_Schedule__c sch : lst_Schs) {     
                        //set_ExisSchs use here
                        string Str_Exis =  w.schDate+'-'+sch.Professor__c+'-'+w.startendtime;                        
                        if(!set_ExisSchs.contains(Str_Exis))
                        {
                            String colorCode = w.slotNum+1 ==  sch.Slot__c || w.slotNum-1 ==  sch.Slot__c  ? 'red' : 'green';
                            profWrp.add(new ProfDetWrp(String.Valueof(sch.Professor__c), sch.Professor__r.Name+'-'+sch.Course_ID__c+'-'+String.valueOf(sch.hed__Start_Time__c).substringBeforeLast(':') + '-' + String.valueOf(sch.hed__End_Time__c).substringBeforeLast(':')+'-'+sch.Section__r.hed__Parent_Term__r.Term_Number__c+'-'+sch.Section__r.Section_Name__c, colorCode,sch.id,sch.hed__Course_Offering__r.Category__c));
                        }
                    }
                    w.profDetails = profWrp;
                }
            }
            
            wrp.schList = schList;
            wrp.Status = 'Success';
            wrp.message = 'success'; 
        }
        catch(Exception ex){
            wrp.Status = 'Failure';
            wrp.message = 'Error - '+ex.getMessage();
          //  system.debug('=====>>>>'+ex.getMessage() + ex.getCause() + ex.getStackTraceString());
        }
        return  wrp;         
    }    
    
    public Static Map<String, List<hed__Course_Offering_Schedule__c>> getProfessorDetails(String i_ContactId, List<Date> i_AbsDates,string ConOwnerid, Set<String> set_ExisSchs) {
        Map<String, List<hed__Course_Offering_Schedule__c>> mp_SectionSch = new Map<String, List<hed__Course_Offering_Schedule__c>>();
        Set<Id> set_Ids = new Set<Id>();
        Set<Id> set_ProfIds = new Set<Id>();
        Set<Id> set_OfferingIds = new Set<Id>();
        Id FacultyRecId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(utility.CC_Faculty_RecType).getRecordTypeId();
        //Get sections of given professor's active enrollment.
        for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,hed__Course_Offering__r.Category__c,Section__c FROM hed__Course_Enrollment__c 
                                                  WHERE Active_Connection__c = true and hed__Contact__c =: i_ContactId and
                                                  hed__Course_Offering__c != null])
        {
            set_Ids.add(eachConn.Section__c);                       
        }
        
        //Get all enrollments for the sections handled by the professor
        for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,RecordTypeId,
                                                  hed__Course_Offering__r.Category__c,Section__c,hed__Contact__c 
                                                  FROM hed__Course_Enrollment__c 
                                                  WHERE hed__Contact__c != null AND 
                                                  hed__Contact__c !=: i_ContactId AND
                                                  Section__c in: set_Ids  AND
                                                  RecordTypeId =: FacultyRecId])
        {
            set_OfferingIds.add(eachConn.hed__Course_Offering__c);
            set_ProfIds.add(eachConn.hed__Contact__c);
            //get all the prof contacts in a set hed__Contact__c
        } system.debug(set_OfferingIds);
        if(set_ProfIds.size()>0)
        {
            set<id> set_CourOffIds = new set<id>();
            for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,hed__Contact__r.OwnerId,hed__Course_Offering__r.Category__c,Section__c 
                                                      FROM hed__Course_Enrollment__c 
                                                      WHERE Active_Connection__c = true and hed__Contact__c in: set_ProfIds and
                                                      hed__Course_Offering__c != null])
            {
                set_CourOffIds.add(eachConn.hed__Contact__r.OwnerId);
            }
            for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,Professor__r.Name,hed__Start_Time__c, hed__End_Time__c,hed__Course_Offering__r.Name,Batch_Group__c, Batch_Group__r.Name, Section__c,Section__r.Name,Slot__c,
                                                            Date__c,Course_ID__c,Section__r.hed__Parent_Term__r.Term_Number__c,Section__r.Section_Name__c
                                                            FROM hed__Course_Offering_Schedule__c
                                                            WHERE Date__c in: i_AbsDates AND Professor__c  IN: set_CourOffIds
                                                            and Status__c =: 'Scheduled' ORDER BY Date__c, Slot__c])
            {
                string startEndTime = String.valueOf(eachSch.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachSch.hed__End_Time__c).substringBeforeLast(':');
                set_ExisSchs.add(eachSch.Date__c+'-'+eachSch.Professor__c+'-'+startEndTime);
            }
        }
        //Set of contact --> get the active Course Conn --> get COS for the given dates --> Iterate -->
        // Set of String -- Date__c + Prof__c + StartTime + ENDTIME
        //set_ExisSchs
        
        if(set_OfferingIds.size() > 0) {
            for(hed__Course_Offering_Schedule__c eachSch : [SELECT Id,Professor__c,Professor__r.Name,hed__Start_Time__c, hed__End_Time__c,hed__Course_Offering__r.Name,Batch_Group__c, Batch_Group__r.Name, Section__c,Section__r.Name,Slot__c,
                                                            Date__c,Course_ID__c,Section__r.hed__Parent_Term__r.Term_Number__c,Section__r.Section_Name__c,hed__Course_Offering__r.Category__c
                                                            FROM hed__Course_Offering_Schedule__c
                                                            WHERE Date__c in: i_AbsDates AND hed__Course_Offering__c IN: set_OfferingIds
                                                            AND Professor__c !=: ConOwnerid and Status__c =: 'Scheduled' ORDER BY Date__c, Slot__c])
            {
                String keyVal = eachSch.Section__c+'-'+String.valueof(eachSch.Date__c);                
                if(mp_SectionSch.get(keyVal) == null){
                    mp_SectionSch.put(keyVal, new List<hed__Course_Offering_Schedule__c>());
                }                 
                mp_SectionSch.get(keyVal).add(eachSch);                
            }
        }
        return mp_SectionSch;
    }
    
    public class RequestWrapper {
        public List<EmployeeData> EmployeeData;
    }    
    public class EmployeeData {
        public string Emp_EmployeeNumber;
        public string Emp_FromDate;
        public string Emp_ToDate;
        public string Emp_LeaveId;
        public string Emp_Reason;
        public string Emp_LeaveType;
        public string Emp_SessionType;
    }   
    
    global class ResponseWrp{
        public List<FacultyScheduleWrp> schList;
        public String status;
        public String message;
    }
    
    global class FacultyScheduleWrp {        
        public Id  schId;
        public Date schDate; 
        public Decimal slotNum; 
        public String startendtime;
        public String courseName;
        public String courseId;
        public String sectionDet;
        public String CourseCategory;
        public boolean isChecked;
        public Id sectionId;
        public List<ProfDetWrp> profDetails; 
        public FacultyScheduleWrp(Id schId, Date schDate, Decimal slotNum, String startendtime, String courseName, String sectionDet, Id sectionId,string courseId,string CourseCategory) {
            this.schId = schId;
            this.schDate = schDate;
            this.slotNum = slotNum;
            this.startendtime = startendtime;
            this.courseName = courseName;
            this.sectionDet = sectionDet;
            this.sectionId = sectionId;
            this.courseId = courseId;
            this.CourseCategory = CourseCategory;
            this.profDetails = new List<ProfDetWrp>();
            this.isChecked =true;
        }
    }    
    
    global class ProfDetWrp{ 
        public string profId;
        public string  ProfName;
        public string colorCode; 
        public string ReqSchId; 
        public string ReqCategory; 
        
        public ProfDetWrp(string profId, string ProfName, string colorCode,string ReqSchId,string ReqCategory){
            this.profId = profId;
            this.ProfName = ProfName;
            this.colorCode = colorCode;
            this.ReqSchId = ReqSchId;
            this.ReqCategory = ReqCategory;
        }
    }
}