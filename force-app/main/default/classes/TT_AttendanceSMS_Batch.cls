global class TT_AttendanceSMS_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Set<Id> set_AttndEvtIds = new Set<Id>();
    global TT_AttendanceSMS_Batch(Set<Id> set_AttdEvts)
    {
        set_AttndEvtIds = set_AttdEvts;
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return database.getQueryLocator([Select Id, Name, hed__Contact__c, Course_Offering_Schedule__c, 
                                         hed__Attendance_Type__c, Course_Offering_Schedule__r.Section__c, 
                                         Course_Offering_Schedule__r.Section__r.Name,
                                         Course_Offering_Schedule__r.Date__c, hed__Contact__r.Name,
                                         Course_Offering_Schedule__r.hed__Start_Time__c, 
                                         Course_Offering_Schedule__r.hed__End_Time__c, hed__Date__c,
                                         hed__Contact__r.Mother__c, hed__Contact__r.Mother__r.MobilePhone, 
                                         hed__Contact__r.Father__c, hed__Contact__r.Father__r.MobilePhone,
                                         Course_Offering_Schedule__r.hed__Course_Offering__r.Name,
                                         hed__Contact__r.Guardian__c, hed__Contact__r.Guardian__r.MobilePhone    
                                         from hed__Attendance_Event__c where hed__Attendance_Type__c ='Absent'
                                         AND Id IN: set_AttndEvtIds]);
    }
    
    global void execute(Database.BatchableContext Bc, List<hed__Attendance_Event__c> lstAttndEvnts)
    {
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        for(hed__Attendance_Event__c objAttdnEvt : lstAttndEvnts)
        {
            SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
            //Date duedate = objAttdnEvt.hed__Date__c;
            Date duedate = objAttdnEvt.Course_Offering_Schedule__r.Date__c;
            
            String startTime = getTimeDetails(String.valueOf(objAttdnEvt.Course_Offering_Schedule__r.hed__Start_Time__c));
            String endTime = getTimeDetails(String.valueOf(objAttdnEvt.Course_Offering_Schedule__r.hed__End_Time__c));
            Integer Day = duedate.day();
            Integer Month = duedate.month();
            Integer Year = duedate.year();
            
            objShortMsg.message = 'Dear Parent, This is to inform you that Your ward '+ objAttdnEvt.hed__Contact__r.Name +', was marked '
                + objAttdnEvt.hed__Attendance_Type__c.toLowerCase() +' for '+ objAttdnEvt.Course_Offering_Schedule__r.hed__Course_Offering__r.Name
                +' class conducted on '+ Day+'-'+Month+'-'+Year +' from '+ startTime
                +' to '+endTime+'. REVA University';
            if(String.isNotBlank(objAttdnEvt.hed__Contact__r.Father__c))
                objShortMsg.recipient = '+91'+objAttdnEvt.hed__Contact__r.Father__r.MobilePhone;
            else if(String.isNotBlank(objAttdnEvt.hed__Contact__r.Mother__c))
                objShortMsg.recipient = '+91'+objAttdnEvt.hed__Contact__r.Mother__r.MobilePhone;
            else if(String.isNotBlank(objAttdnEvt.hed__Contact__r.Guardian__c))
                objShortMsg.recipient = '+91'+objAttdnEvt.hed__Contact__r.Guardian__r.MobilePhone;
            lstShortMsg.add(objShortMsg);
        }
        
        System.debug('lstShortMsg=='+lstShortMsg.size());
        if(lstShortMsg.size() >0)
        {
            //Map Http Request
            HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Absent SMS to Parent', lstShortMsg); 
            
            //Send Request
           /* Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            System.debug('Response Code=='+ hRsp.getStatusCode());
            System.debug('Response Body=='+ hRsp.getBody()); */
        }
    }
    
    global static String getTimeDetails(String timeDetails)
    {
        String[] outtimesplit = timeDetails.split(':');
        if(integer.valueof(outtimesplit[0]) >= 12)
        {
            integer outhour = integer.valueof(outtimesplit[0])-12;
            return String.Valueof(outhour)+':'+outtimesplit[1];
        }
        else
        {
            if(integer.valueof(outtimesplit[0]) < 10)
                return '0'+outtimesplit[0]+':'+outtimesplit[1];
            else
                return outtimesplit[0]+':'+outtimesplit[1];
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}