global class FEE_SMSDueDateToStudent_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts  
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        Date todayDate = System.today();
        return database.getQueryLocator([Select Id, Name, Due_Date__c, Fee_Type__c, Contact__c, Contact__r.Name, 
                                         Amount_Pending__c, Student_Mobile_Number__c, Father_Mobile_Number__c, 
                                         Guardian_Mobile_Number__c, Mother_Mobile_Number__c from Student_Fee__c 
                                         where Amount_Pending__c > 0 AND (Due_Date__c =: todayDate.addDays(2) OR 
                                         Due_Date__c =: todayDate.addDays(7) OR Due_Date__c =: todayDate.addDays(15) 
                                         OR Due_Date__c =: todayDate.addDays(30))]);
    }
    
    global void execute(Database.BatchableContext Bc, List<Student_Fee__c> lstStudFee)
    {
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        for(Student_Fee__c objStudFee : lstStudFee)
        {
            String message = 'Gentle Reminder to Pay your '+ objStudFee.Fee_Type__c +' of Rs.'+ 
                objStudFee.Amount_Pending__c+'/- immediately. Please visit your University Student Portal '+ 
                'to make the payment. If Already Paid, Kindly Ignore. REVA University';
            if(String.isNotBlank(objStudFee.Student_Mobile_Number__c))
            {
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = message;
                objShortMsg.recipient = '+91'+objStudFee.Student_Mobile_Number__c;
                lstShortMsg.add(objShortMsg);
            }
            if(String.isNotBlank(objStudFee.Father_Mobile_Number__c))
            {
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = message;
                objShortMsg.recipient = '+91'+objStudFee.Father_Mobile_Number__c;
                lstShortMsg.add(objShortMsg);
            }
            else if(String.isNotBlank(objStudFee.Mother_Mobile_Number__c))
            {
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = message;
                objShortMsg.recipient = '+91'+objStudFee.Mother_Mobile_Number__c;
                lstShortMsg.add(objShortMsg);
            }
            else if(String.isNotBlank(objStudFee.Guardian_Mobile_Number__c))
            {
                SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
                objShortMsg.message = message;
                objShortMsg.recipient = '+91'+objStudFee.Guardian_Mobile_Number__c;
                lstShortMsg.add(objShortMsg);
            }
            
        }
        System.debug('lstShortMsg=='+lstShortMsg.size());
        if(lstShortMsg.size() >0)
        {
            //Map Http Request
            HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Fee Remainder to Student', lstShortMsg); 
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            System.debug('Response Code=='+ hRsp.getStatusCode());
            System.debug('Response Body=='+ hRsp.getBody());
        }
    }
    
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}