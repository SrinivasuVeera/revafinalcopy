global class ATT_AbsentFor4DaysSMSToMentor_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts 
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        if(!test.isRunningTest())
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, Attendance_Percentage_last_4Days__c,
                                             SRN_Number__c, hed__Contact__r.Name from hed__Program_Enrollment__c 
                                             where Active__c = True AND Attendance_Percentage_last_4Days__c <= 30 
                                             AND hed__Contact__c != Null AND SRN_Number__c != Null
                                             AND hed__Contact__r.Student_Status__c IN ('Pursuing','Year Back')]);
        else 
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, Attendance_Percentage_last_4Days__c,
                                             SRN_Number__c, hed__Contact__r.Name from hed__Program_Enrollment__c]);
    }
    
    global void execute(Database.BatchableContext Bc, List<hed__Program_Enrollment__c> lstProgEnroll)
    {
        Date yestDate = System.today().AddDays(-1);
        Integer yestDay = yestDate.day();
        Integer yestMonth = yestDate.month();
        Integer yestYear = yestDate.year();
        Date lastFourDate = System.today().AddDays(-4);
        Integer last4Day = lastFourDate.day();
        Integer last4Month = lastFourDate.month();
        Integer last4Year = lastFourDate.year();
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        Set<Id> set_ConIds = new Set<Id>();
        Map<Id, Case> map_Cases = new Map<Id, Case>();
        for(hed__Program_Enrollment__c objProgEnroll : lstProgEnroll)
        {
            set_ConIds.add(objProgEnroll.hed__Contact__c);
        }
        
        if(!set_ConIds.isEmpty())
        {
            for(Case objCase : [Select Id, ContactId, Mentor__c, Mentor_Mobile__c, Mentor__r.Name, Record_Type_Name__c 
                                From Case where Record_Type_Name__c = 'Mentee' AND Mentor__c != Null AND
                                ContactId IN: set_ConIds])
            {
                map_Cases.put(objCase.ContactId, objCase);
            }
            
            for(hed__Program_Enrollment__c objProgEnroll : lstProgEnroll)
            {
                if(map_Cases.get(objProgEnroll.hed__Contact__c) != Null)
                {
                    SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                    objShortMsg.message = 'Your mentee '+objProgEnroll.hed__Contact__r.Name+', SRN- '+  
                        objProgEnroll.SRN_Number__c+' has been irregular/ absent to classes from '+ 
                        yestDay+'-'+yestMonth+'-'+yestYear+' to '+last4Day+'-'+last4Month+'-'+last4Year+
                        '. Please check with mentee and parents if required. REVA University';
                    objShortMsg.recipient = '+91'+map_Cases.get(objProgEnroll.hed__Contact__c).Mentor_Mobile__c;
                    lstShortMsg.add(objShortMsg);
                }
            }
            
            System.debug('lstShortMsg=='+lstShortMsg.size());
            if(lstShortMsg.size() >0)
            {
                //Map Http Request
                HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Irregular to classes- Mentor', lstShortMsg); 
                
                //Send Request
                Http http = new Http();
                HttpResponse hRsp = http.send(hReq);
                System.debug('Response Code=='+ hRsp.getStatusCode());
                System.debug('Response Body=='+ hRsp.getBody());
            }
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}