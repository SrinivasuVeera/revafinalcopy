public class TT_ViewSchedule_SectionCls {
    
    @AuraEnabled
    public static ResponseWrp getTimeTableRecords(String i_SectionId){
        List<SlotTimeWrp> lst_Slot = new List<SlotTimeWrp>();
        Set<Time> uTime = new Set<Time>();
        String tempHold = '';
        Integer count ;
        List<String> lst_Elec = new List<String>{'Open Elective', 'Professional Elective'};
        Map<String,List<hed__Course_Offering_Schedule__c>> dayAndCOSMap = new Map<String,List<hed__Course_Offering_Schedule__c>>();
        List<String> daysList = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday', 'Saturday', 'Sunday'};
            ResponseWrp wrp = new ResponseWrp();
        if(String.isBlank(i_SectionId)) {
            wrp.resStatus  = 'Error';
            wrp.resMessage = 'Missing Section Id';
            return wrp;
        }
        hed__Term__c term =[SELECT hed__Account__r.Name,hed__Parent_Term__r.Academic_Year__c,hed__Account__r.Parent.name,Section_Name__c,hed__Parent_Term__r.Term_Number__c from hed__Term__c where Id =:i_SectionId];
        wrp.programName = term.hed__Account__r.Name;
        wrp.schoolName = term.hed__Account__r.Parent.name;
        wrp.semesterName = string.valueof(term.hed__Parent_Term__r.Term_Number__c);
        wrp.secName = term.Section_Name__c;
        wrp.acdYear = term.hed__Parent_Term__r.Academic_Year__c;
        wrp.lst_Faculties = getFaculties(i_SectionId);
        
        for(hed__Course_Offering_Schedule__c cosObj : [SELECT id,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Course_Offering__r.hed__Course__r.Category__c,hed__End_Time__c,hed__Start_Time__c,hed__Time_Block__c,hed__Time_Block__r.Name,Display_Name__c,
                                                       hed__Monday__c, hed__Tuesday__c,hed__Wednesday__c,Section__c,Section__r.Name, Break__c,Batch_Group__r.Batch_Short_Name__c,hed__Course_Offering__r.hed__Term__r.hed__Account__r.Parent.name,
                                                       hed__Thursday__c, hed__Friday__c, hed__Saturday__c, hed__Sunday__c,hed__Facility__c,hed__Course_Offering__r.hed__Course__r.Offered_By_School__r.name
                                                       FROM hed__Course_Offering_Schedule__c 
                                                       WHERE Section__c =: i_SectionId and Date__c = null
                                                       order by hed__Start_Time__c])
        {
            
            if(cosObj.hed__Monday__c && !uTime.contains(cosObj.hed__Start_Time__c)) {               
                lst_Slot.add(new SlotTimeWrp(String.valueOf(cosObj.hed__Start_Time__c).substringBeforeLast(':'),String.valueOf(cosObj.hed__End_Time__c).substringBeforeLast(':')));
                uTime.add(cosObj.hed__Start_Time__c);
            }
            
            String keyStr = cosObj.hed__Monday__c ? 'Monday' :
            cosObj.hed__Tuesday__c ? 'Tuesday' :
            cosObj.hed__Wednesday__c ? 'Wednesday' :
            cosObj.hed__Thursday__c ? 'Thursday' :
            cosObj.hed__Friday__c ? 'Friday' : 
            cosObj.hed__Saturday__c ? 'Saturday' :
            cosObj.hed__Sunday__c ? 'Sunday' : '';
            if(dayAndCOSMap.get(keyStr) == null)
                dayAndCOSMap.put(keyStr, new List<hed__Course_Offering_Schedule__c>{cosObj});			
            else
                dayAndCOSMap.get(keyStr).add(cosObj);
        }
        
        if(dayAndCOSMap.size() == 0) {
            wrp.resStatus  = 'Error';
            wrp.resMessage = 'No Schedule found for the given section.';
            return wrp;
        }        
        else{
            wrp.resStatus  = 'Success';
        }
        wrp.lst_TimeSlot = lst_Slot;
        wrp.lst_Sch = new List<ScheduleWrp>();
        Map<Time,String> slotAndCSMap ;
        for(String day:daysList){
            List<SlotWrp> lst_Slots = new List<SlotWrp>();
            slotAndCSMap = new Map<Time,String>();
            if(dayAndCOSMap.get(day) != null) {
                for(hed__Course_Offering_Schedule__c cos: dayAndCOSMap.get(day)){ 
                    String cs = slotAndCSMap.get(cos.hed__Start_Time__c);
                    if(String.isBlank(cs)) cs = '' ;
                    else  cs += '/ ';
                   
                    if(!(lst_Elec.contains(cos.hed__Course_Offering__r.hed__Course__r.Category__c) && cs.contains(cos.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c))){
                    
                    
                    if(cos.Break__c && !(cos.hed__Saturday__c  || cos.hed__Sunday__c)) cs = 'Break';
                    else if(!cos.Break__c && !(cos.hed__Saturday__c  || cos.hed__Sunday__c) && cos.hed__Course_Offering__c == null){
                        cs = cos.Display_Name__c == null ? '' : cos.Display_Name__c;
                    }
                    cs +=  cos.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c == null ? '' : cos.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c ;
                    if(cos.Batch_Group__r.Batch_Short_Name__c != null) cs += '(' + cos.Batch_Group__r.Batch_Short_Name__c + ')';
                    slotAndCSMap.put(cos.hed__Start_Time__c, cs);         
                    }
                }
                for(Time t: slotAndCSMap.keySet()){                   
                        lst_Slots.add(new SlotWrp(t + '',slotAndCSMap.get(t), 1));                                   
                }
                wrp.lst_Sch.add(new ScheduleWrp( day, lst_Slots));
            }
        }
        
        
        return wrp;
    }
    
    public static List<FacultyWrp> getFaculties(String i_SectionId) {
        Id facRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        List<FacultyWrp> o_Faculties = new List<FacultyWrp>();
        map<String, String> mp_Fac = new Map<String, String>();
        map<String, String> mp_CourseName = new Map<String, String>();
        hed__Term__c term =[SELECT 
                            Section_Name__c,
                            (SELECT Id,Course_Code__c,hed__Course_Offering__r.Name,hed__Contact__r.Name FROM Course_Connections__r where RecordTypeId =: facRecordTypeId)
                            FROM hed__Term__c WHERE Id =:i_SectionId ];
        
        for(hed__Course_Enrollment__c eachConn : term.Course_Connections__r) {
            mp_CourseName.put(eachConn.Course_Code__c, eachConn.hed__Course_Offering__r.Name);
            if(mp_Fac.get(eachConn.Course_Code__c) == null){
               mp_Fac.put(eachConn.Course_Code__c, eachConn.hed__Contact__r.Name);
            }
            else{
                mp_Fac.put(eachConn.Course_Code__c, mp_Fac.get(eachConn.Course_Code__c) + '/ '  + eachConn.hed__Contact__r.Name);
            }            
        }
        system.debug(mp_Fac);
        for(string eachConn : mp_Fac.keyset()) {
            o_Faculties.add(new FacultyWrp(null,eachConn,mp_CourseName.get(eachConn),mp_Fac.get(eachConn)));
        }
        return o_Faculties;
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
        // @AuraEnabled public String recId {get;set;}
        @AuraEnabled public String dayName {get;set;}
        @AuraEnabled public List<SlotWrp> lst_Slots {get;set;}        
        public ScheduleWrp(/* String recId,*/ String dayName, List<SlotWrp> lst_Slots) {
            //  this.recId = recId;
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
        public SlotTimeWrp(String sTime, String eTime){
            this.sTime = sTime;
            this.eTime = eTime;
        }
    }
    
    public class FacultyWrp{
        @AuraEnabled public String connectionId {get;set;}
        @AuraEnabled public String  courseCode {get;set;}
        @AuraEnabled public String  coursename {get;set;}
        @AuraEnabled public String  facultyName {get;set;}
        public FacultyWrp( String connectionId, String  courseCode,String  coursename ,String  facultyName ) {
            this.connectionId = connectionId;
            this.courseCode = courseCode;
            this.coursename = coursename;
            this.facultyName = facultyName;
        }      
    }
    
}