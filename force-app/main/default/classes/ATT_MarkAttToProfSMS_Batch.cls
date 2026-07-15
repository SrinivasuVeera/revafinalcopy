global class ATT_MarkAttToProfSMS_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts 
{
	global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return database.getQueryLocator([Select Id, Name, Professor__c, Professor__r.Name, Section__c, 
                                         Section__r.Name, hed__Course_Offering__c, hed__Course_Offering__r.Name,
                                         Date__c, hed__Start_Time__c, hed__End_Time__c, Professor__r.MobilePhone
                                         from hed__Course_Offering_Schedule__c WHERE Date__c != NULL AND 
                                         Date__c = YESTERDAY AND Status__c ='Scheduled' 
                                         AND Professor__r.IsActive = True]);
    }
    
    global void execute(Database.BatchableContext Bc, List<hed__Course_Offering_Schedule__c> lstCourseOffSch)
    {
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        for(hed__Course_Offering_Schedule__c objCourseOffSch : lstCourseOffSch)
        {
            if(String.isNotBlank(objCourseOffSch.Professor__r.MobilePhone))
            {
                String startTime = getTimeDetails(String.valueOf(objCourseOffSch.hed__Start_Time__c));
                String endTime = getTimeDetails(String.valueOf(objCourseOffSch.hed__End_Time__c));
                Date classDate = objCourseOffSch.Date__c;
                
                Integer Day = classDate.day();
                Integer Month = classDate.month();
                Integer Year = classDate.year();
                
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = 'Dear Sir/ Madam, Gentle remainder to mark attendance of '+ 
                    objCourseOffSch.hed__Course_Offering__r.Name +' class conducted on '+ Day+'-'+Month+'-'+Year+
                    ' between '+ startTime +'-'+endTime+' for '+ objCourseOffSch.Section__r.Name+'. REVA University';
                objShortMsg.recipient = '+91'+objCourseOffSch.Professor__r.MobilePhone;
                lstShortMsg.add(objShortMsg);
            }
        }
        
        System.debug('lstShortMsg=='+lstShortMsg.size());
        if(lstShortMsg.size() >0)
        {
            //Map Http Request
            HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Mark Attendance Professor', lstShortMsg); 
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            System.debug('Response Code=='+ hRsp.getStatusCode());
            System.debug('Response Body=='+ hRsp.getBody());
        }
    }
    
    global static String getTimeDetails(String timeDetails)
    {
        String[] outtimesplit = timeDetails.split(':');
        if(integer.valueof(outtimesplit[0]) >= 12)
        {
            integer outhour = integer.valueof(outtimesplit[0])-12;
            return String.Valueof(outhour)+':'+outtimesplit[1]+'PM';
        }
        else
        {
            return outtimesplit[0]+':'+outtimesplit[1]+'AM';
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}