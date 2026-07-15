/**
* @description: This Apex class, TT_ViewSchedule_ProfCls, is responsible for retrieving schedule information for the logged-in user
*               based on the selected date. It follows best practices and comments for bettercode readability and maintenance.
*               
* Note: The class adheres to the following requirements:
*       1. Contact record should be there for the logged-in user.
*       2. Contact OwnerId should be equal to the current logged-in user.
*       3. Course Connection record should be tagged to the contact, and Active Connection should be true.
*       4. In Course Offering Schedule, Course category picklist values should be any one of the values
*          ('Open Elective', 'Professional Elective').
*       5. In Course Offering Schedule, Date should be provided (Note: Date__c = THIS_WEEK).
*
* Last Modified By: Srinivas Chundru
* Last Modified Date: 2024-01-25 

*/

public class TT_ViewSchedule_ProfCls {
    @AuraEnabled
    public static List<Wrp> getSchedule(Date i_SelectedDate) {
        List<String> lst_Elec = new List<String>{'Open Elective', 'Professional Elective'};
            List<Wrp> wr = new List<Wrp>();
        Date loopingdate;
        List<ScheduleWrp> schList = new List<ScheduleWrp>();
        Set<String> set_OfferingIds = new Set<String>();
        Set<Id> set_GroupId = new Set<Id>();
        Set<Id> set_ProgId = new Set<Id>();
        Integer count = 0;
        Set<String> slots = new Set<String>();
        
        if (i_SelectedDate == null) {
            i_SelectedDate = system.today();
        }
        System.debug('Selected Date: ' + i_SelectedDate);
        
        Contact contactRec = [SELECT Id FROM Contact WHERE OwnerId = :UserInfo.getUserId() LIMIT 1]; 
        System.debug('Contact Record: ' + contactRec);
        
        for (hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,hed__Course_Offering__r.Name, Section__c,Section__r.Name FROM hed__Course_Enrollment__c WHERE Active_Connection__c = true AND hed__Contact__c = :contactRec.Id]) {
            set_OfferingIds.add(eachConn.hed__Course_Offering__c); 
            set_GroupId.add(eachConn.Section__c);
        
        System.debug('Course Enrollment Id: ' + eachConn.Id);
    System.debug('Course Offering Id: ' + eachConn.hed__Course_Offering__r.Name);
    System.debug('Section Id: ' + eachConn.Section__r.Name);
        }
        system.debug('Offering IDs: ' + set_OfferingIds);
        set_GroupId.add(null);
        System.debug('Group IDs: ' + set_GroupId);
        
        if (set_OfferingIds.size() > 0) {
            List<hed__Course_Offering_Schedule__c> cosList = [
                SELECT Id, hed__Start_Time__c, hed__End_Time__c, Section__r.hed__Parent_Term__r.hed__Account__r.Name, hed__Course_Offering__r.hed__Course__r.Category__c, Slot__c,
                Date__c, Section__r.Name, Status__c, Section__r.hed__Parent_Term__r.Term_Number__c, Batch_Group__r.Name, hed__Course_Offering__r.hed__Course__r.Name, hed__Time_Block__r.hed__Educational_Institution__c, hed__Facility__r.Name,Facility_Request__c, Facility_Request__r.Name, hed__Facility__r.hed__Facility_Type__c,Facility_Request__r.Facility_Type__c
                FROM hed__Course_Offering_Schedule__c 
                WHERE hed__Course_Offering__c IN :set_OfferingIds AND Date__c = THIS_WEEK AND Batch_Group__c IN :set_GroupId
                ORDER BY Date__c, hed__Start_Time__c
            ];
            System.debug('Retrieved Course Offering Schedules: ' + cosList.size() + ' records');            
            for (hed__Course_Offering_Schedule__c eachCOS : cosList) {
                System.debug('Processing Course Offering Schedule...');
                System.debug('Facility Name: ' + eachCOS.Facility_Request__r.Name);
                System.debug('Course Offering Schedule - ID: ' + eachCOS.Id + ', Start Time: ' + eachCOS.hed__Start_Time__c + ', End Time: ' + eachCOS.hed__End_Time__c + ', Facility Name: ' + eachCOS.Facility_Request__r.Name);
                System.debug('Course Offering Schedule - Section Name: ' + eachCOS.Section__r.Name + ', Status: ' + eachCOS.Status__c + ', Batch Group Name: ' + eachCOS.Batch_Group__r.Name);
                System.debug('Course Offering Schedule - Course Name: ' + eachCOS.hed__Course_Offering__r.hed__Course__r.Name + ', Category: ' + eachCOS.hed__Course_Offering__r.hed__Course__r.Category__c);
                System.debug('Course Offering Schedule - Time Block: ' + eachCOS.hed__Time_Block__r.hed__Educational_Institution__c);
                
                count++;
                if (loopingdate == null) {
                    loopingdate = eachCOS.Date__c;
                }
                
                if (loopingdate != eachCOS.Date__c) {
                    System.debug('Changing Date...');
                    
                    Integer d = loopingdate.day();
                    Integer mo = loopingdate.month();
                    Integer yr = loopingdate.year();                        
                    DateTime DT = DateTime.newInstance(yr, mo, d);
                    wr.add(new Wrp(schList, DT.format('EEEE'), schList.size()));
                    schList = new List<ScheduleWrp>();
                    loopingdate = eachCOS.Date__c;
                    set_ProgId = new Set<Id>();
                    slots = new Set<String>();
                } 
                
                if (!lst_Elec.contains(eachCOS.hed__Course_Offering__r.hed__Course__r.Category__c) || 
                    !slots.contains(String.valueOf(eachCOS.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachCOS.hed__End_Time__c).substringBeforeLast(':')) ||
                    !set_ProgId.contains(eachCOS.hed__Time_Block__r.hed__Educational_Institution__c)) 
                {  
                    System.debug('Processing Schedule Details...');
                    
                    ScheduleWrp wrp = new ScheduleWrp();
                    wrp.schDate = eachCOS.Date__c;
                    wrp.schId = eachCOS.Id;
                    wrp.slotNum = Integer.valueof(eachCOS.Slot__c);
                    wrp.timeSlot = String.valueOf(eachCOS.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachCOS.hed__End_Time__c).substringBeforeLast(':');
                    
                    if (!slots.contains(wrp.timeSlot)) {
                        set_ProgId = new Set<Id>();
                    }
                    
                    slots.add(wrp.timeSlot);
                    wrp.programName = eachCOS.Section__r.hed__Parent_Term__r.hed__Account__r.Name;
                    wrp.semNumber = Integer.valueof(eachCOS.Section__r.hed__Parent_Term__r.Term_Number__c);
                     System.debug('Sem Number added to ScheduleWrp: ' + wrp.semNumber);
                    wrp.courseName = eachCOS.hed__Course_Offering__r.hed__Course__r.Name;  
                    wrp.schstatus = eachCOS.Status__c;
                    wrp.groupName = eachCOS.Batch_Group__r.Name;
                   // wrp.hedFacilityName = eachCOS.hed__Facility__r.Name;
                   // System.debug('Facility Name added to ScheduleWrp: ' + wrp.hedFacilityName);
                   //wrp.hedFacilityType = eachCOS.hed__Facility__r.hed__Facility_Type__c;
                    //System.debug('Facility Type added to ScheduleWrp: ' + wrp.hedFacilityType);
                    wrp.hedFacilityName = eachCOS.Facility_Request__r.Name;
                    System.debug('Facility Name added to ScheduleWrp: ' + wrp.hedFacilityName);
                    wrp.hedFacilityType = eachCOS.Facility_Request__r.Facility_Type__c;
                    System.debug('Facility Type added to ScheduleWrp: ' + wrp.hedFacilityType);
                    
                    if (!lst_Elec.contains(eachCOS.hed__Course_Offering__r.hed__Course__r.Category__c)) {
                        wrp.secName = eachCOS.Section__r.Name;
                    }
                    
                    schList.add(wrp);
                    set_ProgId.add(eachCOS.hed__Time_Block__r.hed__Educational_Institution__c);
                    
                    if (count == cosList.size()) {
                        Integer d = loopingdate.day();
                        Integer mo = loopingdate.month();
                        Integer yr = loopingdate.year();                        
                        DateTime DT = DateTime.newInstance(yr, mo, d);
                        wr.add(new Wrp(schList, DT.format('EEEE'), schList.size()));
                    }
                }
            }
        }
        
        System.debug('Final Schedule Data: ' + wr);
        System.debug('Exiting getSchedule method...');
        
        return wr;
    }
    
    public class Wrp {
        @AuraEnabled public List<ScheduleWrp> schWrp  { get; set; } 
        @AuraEnabled public String sDay  { get; set; } 
        @AuraEnabled public Integer rowspa { get; set; } 
        
        public Wrp(List<ScheduleWrp> schWrp, String sDay, Integer rowspa) {
            this.schWrp = schWrp;
            this.sDay = sDay;
            this.rowspa = rowspa;
        }
    }
    
    public class ScheduleWrp {
        @AuraEnabled public Date schDate { get; set; } 
        @AuraEnabled public String schId { get; set; } 
        @AuraEnabled public Integer slotNum { get; set; } 
        @AuraEnabled public String timeSlot { get; set; } 
        @AuraEnabled public String programName { get; set; } 
        @AuraEnabled public Integer semNumber { get; set; } 
        @AuraEnabled public String secName { get; set; } 
        @AuraEnabled public String groupName { get; set; } 
        @AuraEnabled public String courseName { get; set; } 
        @AuraEnabled public String schstatus { get; set; } 
        @AuraEnabled public String hedFacilityName { get; set; } 
        @AuraEnabled public String hedFacilityType { get; set; }
        public ScheduleWrp() {
        }
    }
}