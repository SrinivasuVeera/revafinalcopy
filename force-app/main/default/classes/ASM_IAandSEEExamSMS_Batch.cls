global class ASM_IAandSEEExamSMS_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Date startDate = System.today();
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        if(!test.isRunningTest())
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, hed__Contact__r.Name,
                                             hed__Contact__r.Mother__c, hed__Contact__r.Mother__r.MobilePhone, 
                                             hed__Contact__r.Father__c, hed__Contact__r.Father__r.MobilePhone,
                                             hed__Contact__r.Guardian__c, hed__Contact__r.Guardian__r.MobilePhone,
                                             Semester__r.Name, Semester__c, Semester__r.IA_1_Start_date__c,
                                             Semester__r.IA_2_Start_date__c, Semester__r.Exam_Start_Date__c,
                                             Semester__r.Exam_End_Date__c, Semester__r.IA_1_End_date__c,
                                             Semester__r.IA_2_End_date__c,Current_Academic_Year__c, 
                                             hed__Contact__r.MobilePhone from hed__Program_Enrollment__c 
                                             where Active__c = True AND  Semester__r.Active__c = True AND
                                             hed__Contact__r.Student_Status__c IN ('Pursuing','Year Back')
                                             AND (Semester__r.IA_1_Start_date__c =: startDate.addDays(3) OR
                                                  Semester__r.IA_2_Start_date__c =: startDate.addDays(3) OR
                                                  Semester__r.Exam_Start_Date__c =: startDate.addDays(7))]);
        else
            return database.getQueryLocator([Select Id, Name, hed__Contact__c, hed__Contact__r.Name,
                                             hed__Contact__r.Mother__c, hed__Contact__r.Mother__r.MobilePhone, 
                                             hed__Contact__r.Father__c, hed__Contact__r.Father__r.MobilePhone,
                                             hed__Contact__r.Guardian__c, hed__Contact__r.Guardian__r.MobilePhone,
                                             Semester__r.Name, Semester__c, Semester__r.IA_1_Start_date__c,
                                             Semester__r.IA_2_Start_date__c, Semester__r.Exam_Start_Date__c,
                                             Semester__r.Exam_End_Date__c, Semester__r.IA_1_End_date__c,
                                             Semester__r.IA_2_End_date__c,Current_Academic_Year__c, 
                                             hed__Contact__r.MobilePhone from hed__Program_Enrollment__c]); 
    }
    
    global void execute(Database.BatchableContext Bc, List<hed__Program_Enrollment__c> lstProgEnroll)
    {
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        for(hed__Program_Enrollment__c objProgEnroll : lstProgEnroll)
        {
            if(objProgEnroll.Semester__r.IA_1_Start_date__c == startDate.addDays(3))
            {
                Date iaStartDate = objProgEnroll.Semester__r.IA_1_Start_date__c;
                Integer stDay = iaStartDate.day();
                Integer stMonth = iaStartDate.month();
                Integer stYear = iaStartDate.year();
                Date iaEndDate = objProgEnroll.Semester__r.IA_1_End_date__c;
                Integer edDay = iaEndDate.day();
                Integer edMonth = iaEndDate.month();
                Integer edYear = iaEndDate.year();
                
                String message = 'Dear '+ objProgEnroll.hed__Contact__r.Name +', Pleased to inform you that the '+ 
                    ' Internal Assessment 1 will start for '+ objProgEnroll.Current_Academic_Year__c +', '+  
                    objProgEnroll.Semester__r.Name +' from '+stDay+'-'+stMonth+'-'+stYear+' to '+ 
                    edDay+'-'+edMonth+'-'+edYear+'. Study Well! REVA University';
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
            else if(objProgEnroll.Semester__r.IA_2_Start_date__c == startDate.addDays(3))
            {
                Date iaStartDate = objProgEnroll.Semester__r.IA_2_Start_date__c;
                Integer stDay = iaStartDate.day();
                Integer stMonth = iaStartDate.month();
                Integer stYear = iaStartDate.year();
                Date iaEndDate = objProgEnroll.Semester__r.IA_2_End_date__c;
                Integer edDay = iaEndDate.day();
                Integer edMonth = iaEndDate.month();
                Integer edYear = iaEndDate.year();
                
                String message = 'Dear '+ objProgEnroll.hed__Contact__r.Name +', Pleased to inform you that the'+ 
                    ' Internal Assessment 2 will start for '+ objProgEnroll.Current_Academic_Year__c +', '+  
                    objProgEnroll.Semester__r.Name +' from '+stDay+'-'+stMonth+'-'+stYear+' to '+ 
                    edDay+'-'+edMonth+'-'+edYear+'. Study Well! REVA University';
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
            else if(objProgEnroll.Semester__r.Exam_Start_Date__c == startDate.addDays(7))
            {
                Date iaStartDate = objProgEnroll.Semester__r.Exam_Start_Date__c;
                Integer stDay = iaStartDate.day();
                Integer stMonth = iaStartDate.month();
                Integer stYear = iaStartDate.year();
                Date iaEndDate = objProgEnroll.Semester__r.Exam_End_Date__c;
                Integer edDay = iaEndDate.day();
                Integer edMonth = iaEndDate.month();
                Integer edYear = iaEndDate.year();
                
                String message = 'Dear '+ objProgEnroll.hed__Contact__r.Name +', Pleased to inform you that the'+ 
                    ' SEE will start for '+ objProgEnroll.Current_Academic_Year__c +', '+  
                    objProgEnroll.Semester__r.Name +' from '+stDay+'-'+stMonth+'-'+stYear+' to '+ 
                    edDay+'-'+edMonth+'-'+edYear+'. Study Well! REVA University';
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
        }
        
        if(lstShortMsg.size() >0)
        {
            //Map Http Request
            HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('IA and SEE Schedule', lstShortMsg); 
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}