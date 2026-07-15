public class ATT_ProfessorDailyView_Ctr {

    @AuraEnabled
    public static Wrp  getSchedule(Date i_SelectedDate) {
        List<String> lst_Elec = new List<String>{'Open Elective', 'Professional Elective'};
        Wrp wr = new Wrp();
        List<ScheduleWrp> schList = new List<ScheduleWrp>();
        Set<String> set_OfferingIds = new Set<String>();
        Set<Id> set_GroupId = new Set<Id>();
        Set<Id> set_ProgId = new Set<Id>();
        Integer count = 0;
        Set<String> slots = new Set<String>();
        if(i_SelectedDate == null) i_SelectedDate = system.today();
        
        Contact contactRec = [SELECT Id FROM Contact WHERE OwnerId =: UserInfo.getUserId() limit 1];
        
        for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,Section__c FROM hed__Course_Enrollment__c WHERE Active_Connection__c = true and hed__Contact__c =: contactRec.Id]) {
            set_OfferingIds.add(eachConn.hed__Course_Offering__c);
            set_GroupId.add(eachConn.Section__c);
        }
        set_GroupId.add(null);
        if(set_OfferingIds.size() > 0 ) {
            for(hed__Course_Offering_Schedule__c eachCOS : [SELECT Id,hed__Start_Time__c,hed__End_Time__c,Section__r.hed__Parent_Term__r.hed__Account__r.Name,hed__Course_Offering__r.hed__Course__r.Category__c,
                                                          Date__c,Status__c,Section__r.hed__Parent_Term__r.Term_Number__c,Batch_Group__r.Batch_Short_Name__c, hed__Course_Offering__r.hed__Course__r.Name,hed__Time_Block__r.hed__Educational_Institution__c,Attendance_Ext_Enabled__c                                                          
                                                          FROM hed__Course_Offering_Schedule__c 
														  WHERE ((hed__Course_Offering__c in: set_OfferingIds and Batch_Group__c in: set_GroupId And Class_adjusted_schedule__c = false) 
                                                           OR(Class_adjusted_schedule__c = true And Professor__c =: UserInfo.getUserId()))                   
                                                           and Date__c =: i_SelectedDate    
                                                           Order by hed__Start_Time__c])
            {
                if(!lst_Elec.contains(eachCos.hed__Course_Offering__r.hed__Course__r.Category__c) || 
                   !slots.contains(String.valueOf(eachCOS.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachCOS.hed__End_Time__c).substringBeforeLast(':')) ||
                   (eachCos.hed__Course_Offering__r.hed__Course__r.Category__c != 'Open Elective' && !set_ProgId.contains(eachCOS.hed__Time_Block__r.hed__Educational_Institution__c))) {                    
                       count++;
                       ScheduleWrp wrp = new ScheduleWrp();
                       wrp.schDate = eachCOS.Date__c;
                       wrp.schId = eachCOS.Id;
                       wrp.seqNumber = count;
                       wrp.attcheckbox = eachCOS.Attendance_Ext_Enabled__c;
                       wrp.timeSlot = String.valueOf(eachCOS.hed__Start_Time__c).substringBeforeLast(':') + ' - ' + String.valueOf(eachCOS.hed__End_Time__c).substringBeforeLast(':');
                       if(!slots.contains(wrp.timeSlot)) set_ProgId = new Set<Id>();
                       slots.add(wrp.timeSlot);
                       
                       wrp.programName = eachCOS.Section__r.hed__Parent_Term__r.hed__Account__r.Name;
                       wrp.semNumber = Integer.valueof(eachCOS.Section__r.hed__Parent_Term__r.Term_Number__c);
                       wrp.courseName = eachCOS.hed__Course_Offering__r.hed__Course__r.Name;  
                       wrp.schstatus = eachCOS.Status__c;
                       schList.add(wrp);
                       set_ProgId.add(eachCOS.hed__Time_Block__r.hed__Educational_Institution__c);
                   }
            }
        }
        
        wr.schWrp =  schList;
        wr.sDate = system.today();
        return wr;
    }
    
     @AuraEnabled
    public static Wrp postforApproval(Date i_SelectedDate, String i_SelectedId) {
        if(String.isNotBlank(i_SelectedId)) {
            update new hed__Course_Offering_Schedule__c(Id=i_SelectedId, Status__c='Submitted for Reopen');
        }
        return getSchedule(i_SelectedDate);
    }
    
    public class Wrp{
        @AuraEnabled public List<ScheduleWrp> schWrp  {get;set;} 
        @AuraEnabled public Date sDate  {get;set;} 
        @AuraEnabled public Boolean showActions  {get;set;} 
    }
    
    public class ScheduleWrp{
        @AuraEnabled public Boolean attcheckbox {get;set;}
        @AuraEnabled public Date schDate {get;set;} 
        @AuraEnabled public String schId {get;set;} 
        @AuraEnabled public Integer seqNumber {get;set;} 
        @AuraEnabled public String timeSlot {get;set;} 
        @AuraEnabled public String programName {get;set;} 
        @AuraEnabled public Integer semNumber {get;set;} 
        @AuraEnabled public String groupName {get;set;} 
        @AuraEnabled public String courseName {get;set;} 
        @AuraEnabled public String schstatus {get;set;}        
    }
}