global class MSTR_SemStartSMS_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts 
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Date startDate = System.today();
        if(!test.isRunningTest())
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, hed__Contact__r.Name,
                                             hed__Contact__r.Mother__c, hed__Contact__r.Mother__r.MobilePhone, 
                                             hed__Contact__r.Father__c, hed__Contact__r.Father__r.MobilePhone,
                                             hed__Contact__r.Guardian__c, hed__Contact__r.Guardian__r.MobilePhone,
                                             Semester__r.Name, Semester__c, Semester__r.hed__Start_Date__c,
                                             Current_Academic_Year__c, hed__Contact__r.MobilePhone
                                             from hed__Program_Enrollment__c where Active__c = True AND
                                             hed__Contact__r.Student_Status__c IN ('Pursuing','Year Back')
                                             AND Semester__r.hed__Start_Date__c =: startDate.addDays(10)
                                             AND Semester__r.Active__c= True]);
        else
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, hed__Contact__r.Name,
                                             hed__Contact__r.Mother__c, hed__Contact__r.Mother__r.MobilePhone, 
                                             hed__Contact__r.Father__c, hed__Contact__r.Father__r.MobilePhone,
                                             hed__Contact__r.Guardian__c, hed__Contact__r.Guardian__r.MobilePhone,
                                             Semester__r.Name, Semester__c, Semester__r.hed__Start_Date__c,
                                             Current_Academic_Year__c, hed__Contact__r.MobilePhone
                                             from hed__Program_Enrollment__c]);
    }
    
    global void execute(Database.BatchableContext Bc, List<hed__Program_Enrollment__c> lstProgEnroll)
    {
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        for(hed__Program_Enrollment__c objProgEnroll : lstProgEnroll)
        {
            Date startDate = objProgEnroll.Semester__r.hed__Start_Date__c;
            
            Integer Day = startDate.day();
            Integer Month = startDate.month();
            Integer Year = startDate.year();
            
            String message = 'Dear '+ objProgEnroll.hed__Contact__r.Name +', Greetings from REVA University! '+ 
                'Pleased to inform you that the classes will commence for '+ objProgEnroll.Current_Academic_Year__c+', '
                + objProgEnroll.Semester__r.Name +' from '+ startDate +'. REVA University';
            if(String.isNotBlank(objProgEnroll.hed__Contact__r.MobilePhone))
            {
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = message;
                objShortMsg.recipient = '+91'+objProgEnroll.hed__Contact__r.MobilePhone;
                lstShortMsg.add(objShortMsg);
            }
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
        
        if(lstShortMsg.size() >0)
        {
            //Map Http Request
            HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Semester Start SMS', lstShortMsg); 
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);               
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}