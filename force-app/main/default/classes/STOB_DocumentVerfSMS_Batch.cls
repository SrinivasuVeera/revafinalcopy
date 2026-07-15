global class STOB_DocumentVerfSMS_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Date todayDate = System.today();
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        if(!test.isRunningTest())
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, hed__Contact__r.Name,
                                             hed__Contact__r.MobilePhone, hed__Admission_Date__c
                                             from hed__Program_Enrollment__c where Active__c = True 
                                             AND Program_Enrollment_Status__c != 'Confirmed' 
                                             AND hed__Contact__r.Student_Status__c IN ('Pursuing','Year Back')
                                             AND Current_Academic_Year__c = '1st Year' AND
                                             (hed__Admission_Date__c =: todayDate.addDays(-5) OR
                                              hed__Admission_Date__c =: todayDate.addDays(-10) OR
                                              hed__Admission_Date__c =: todayDate.addDays(-15) OR
                                              hed__Admission_Date__c =: todayDate.addDays(-30))]);
        else
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, hed__Contact__r.Name,
                                             hed__Contact__r.MobilePhone, hed__Admission_Date__c
                                             from hed__Program_Enrollment__c]);
    }
    
    global void execute(Database.BatchableContext Bc, List<hed__Program_Enrollment__c> lstProgEnroll)
    {
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        for(hed__Program_Enrollment__c objProgEnroll : lstProgEnroll)
        {
            if(String.isNotBlank(objProgEnroll.hed__Contact__r.MobilePhone))
            {
                Date admissionDate = objProgEnroll.hed__Admission_Date__c;
                
                Integer Day = admissionDate.day();
                Integer Month = admissionDate.month();
                Integer Year = admissionDate.year();
                
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = 'Dear '+ objProgEnroll.hed__Contact__r.Name +' Please submit your official'+ 
                    +' documents to the Registrar'+'s Office to complete your admission process. REVA University';
                objShortMsg.recipient = '+91'+objProgEnroll.hed__Contact__r.MobilePhone;
                lstShortMsg.add(objShortMsg);
            }        
        }
        if(lstShortMsg.size() >0)
        {
            //Map Http Request
            HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Document Verification', lstShortMsg); 
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}