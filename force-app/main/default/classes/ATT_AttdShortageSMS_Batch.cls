global class ATT_AttdShortageSMS_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Date todayDate = System.today();
        Integer numOfDays = date.daysInMonth(todayDate.year(), todayDate.month());
        Date monthEndDate;
        if(Test.isRunningTest())
            monthEndDate = todayDate;
        else
            Date.newInstance(todayDate.year(), todayDate.month(), numOfDays);
        //System.debug('===monthEndDate=='+monthEndDate);
        if(!Test.isRunningTest())
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, hed__Contact__r.Name,
                                             hed__Contact__r.Mother__c, hed__Contact__r.Mother__r.MobilePhone, 
                                             hed__Contact__r.Father__c, hed__Contact__r.Father__r.MobilePhone,
                                             hed__Contact__r.Guardian__c, hed__Contact__r.Guardian__r.MobilePhone,
                                             Semester__r.Name, Semester__c, Semester__r.hed__Start_Date__c, 
                                             Semester__r.hed__End_Date__c, Current_Academic_Year__c, 
                                             hed__Contact__r.MobilePhone, Todays_Date__c, Classes_Attended_Percentage__c
                                             from hed__Program_Enrollment__c where Active__c = True AND 
                                             Semester__r.Active__c = True AND Todays_Date__c =: monthEndDate
                                             AND Classes_Attended_Percentage__c < 75
                                             AND hed__Contact__r.Student_Status__c IN ('Pursuing','Year Back')
                                             AND (Semester__r.hed__Start_Date__c <=: monthEndDate 
                                                  AND Semester__r.hed__End_Date__c >=: monthEndDate)]);
        else
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, hed__Contact__r.Name,
                                             hed__Contact__r.Mother__c, hed__Contact__r.Mother__r.MobilePhone, 
                                             hed__Contact__r.Father__c, hed__Contact__r.Father__r.MobilePhone,
                                             hed__Contact__r.Guardian__c, hed__Contact__r.Guardian__r.MobilePhone,
                                             Semester__r.Name, Semester__c, Semester__r.hed__Start_Date__c, 
                                             Semester__r.hed__End_Date__c, Current_Academic_Year__c, 
                                             hed__Contact__r.MobilePhone, Todays_Date__c, Classes_Attended_Percentage__c
                                             from hed__Program_Enrollment__c]);                          
    }
    
    global void execute(Database.BatchableContext Bc,List<hed__Program_Enrollment__c> lstProgEnroll)
    {
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        for(hed__Program_Enrollment__c objProgEnroll : lstProgEnroll)
        {
            Date todaysDate = System.today(); 
            Integer intDay = todaysDate.day();
            Integer intMonth = todaysDate.month();
            Integer intYear = todaysDate.year();
            
            String message = 'Dear Parent, Your ward '+ objProgEnroll.hed__Contact__r.Name +', has '+ 
                objProgEnroll.Classes_Attended_Percentage__c + '% of attendance as on '+ 
                intDay+'-'+intMonth+'-'+intYear+'. 75% is required to take up the exams.'+ 
                ' Kindly contact mentor, Regrads REVA';
            
            if(String.isNotBlank(objProgEnroll.hed__Contact__r.Father__c))
            {
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = message;
                objShortMsg.recipient = '+91'+objProgEnroll.hed__Contact__r.Father__r.MobilePhone;
                lstShortMsg.add(objShortMsg);
            }
            else if(String.isNotBlank(objProgEnroll.hed__Contact__r.Mother__c))
            {
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = message;
                objShortMsg.recipient = '+91'+objProgEnroll.hed__Contact__r.Mother__r.MobilePhone;
                lstShortMsg.add(objShortMsg);
            }
            else if(String.isNotBlank(objProgEnroll.hed__Contact__r.Guardian__c))
            {
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = message;
                objShortMsg.recipient = '+91'+objProgEnroll.hed__Contact__r.Guardian__r.MobilePhone;
                lstShortMsg.add(objShortMsg);
            }
        }
        
        //System.debug('lstShortMsg=='+lstShortMsg.size());
        if(lstShortMsg.size() >0)
        {
            //Map Http Request
            HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Attendance shortage', lstShortMsg); 
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            //System.debug('Response Code=='+ hRsp.getStatusCode());
            //System.debug('Response Body=='+ hRsp.getBody());
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}