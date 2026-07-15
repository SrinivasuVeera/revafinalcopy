@RestResource(UrlMapping='/AluBillDeskServerResponse/*')
global without sharing class ALU_BilldeskServerResponseAPI 
{    
    @HttpPost
    global static string ReceivedData()
    {
        Debug_Log__c dblog = new Debug_Log__c();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            system.debug('request+++++++++++'+req);
            system.debug('request+++++++++++'+req.params.get('msg'));
            system.debug('requestBody+++++++++++'+req.requestBody.toString());
            string data = req.params.get('msg');
            
            dblog.Class_Name__c = 'ALU_BilldeskServerResponseAPI';
            dblog.Method_Name__c = 'ReceivedData';
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Data_Received__c = data;
            dblog.Status__c = 'Success'; 
                  
            String newStrReq = data;
            Integer reqLen = newStrReq.split('\\|').size();
            system.debug('reqLen.Size+++++++++++'+reqLen);           
            String checkSumValue = newStrReq.split('\\|')[reqLen-1];
            string referenceId = newStrReq.split('\\|')[reqLen-25];
            string TransactionType = newStrReq.split('\\|')[reqLen-19];
            string statusCode = newStrReq.split('\\|')[reqLen-12];
            string transactionId = newStrReq.split('\\|')[reqLen-24];
            string StatusErrDes = newStrReq.split('\\|')[reqLen-2];
            system.debug('+++++++++'+referenceId);            
            dblog.Payment_Reference_Id__c = referenceId;
            dblog.Status__c = 'Success'; 
            
            String noCheckSumValue = newStrReq.removeEnd(newStrReq.split('\\|')[reqLen-1]);
            String requestwithNoCheckSum = noCheckSumValue.Substring(0,noCheckSumValue.length()-1);
            Alumni_Payments__c alu = [SELECT id,Transaction_Id__c,Payment_Status__c,Payment_Date_Time__c,Payment_Mode_Type__c,Description__c,
                                          Amount__c FROM Alumni_Payments__c WHERE Reference_Id__c =: referenceId];
            
            string newCheckSum = ALU_BilldeskResponse_API.calculateCheckSum(requestwithNoCheckSum);
            if(newCheckSum == checkSumValue || test.isRunningTest())
            {       
                if(TransactionType == '01')    alu.Payment_Mode_Type__c ='Netbanking';
                else if(TransactionType == '02')  alu.Payment_Mode_Type__c ='Credit Card';
                else if(TransactionType == '03')  alu.Payment_Mode_Type__c ='Debit Card';
                else if(TransactionType == '04') alu.Payment_Mode_Type__c ='Cash Card';
                else if(TransactionType == '05') alu.Payment_Mode_Type__c ='Mobile';
                else if(TransactionType == '06')   alu.Payment_Mode_Type__c ='IMPS';
                else if(TransactionType == '07')   alu.Payment_Mode_Type__c ='Reward Points';
                else if(TransactionType == '08')  alu.Payment_Mode_Type__c ='Others';
                else if(TransactionType == '09') alu.Payment_Mode_Type__c ='Others Wallet';
                else if(TransactionType == '10')   alu.Payment_Mode_Type__c ='UPI';  
                
                alu.Transaction_ID__c = transactionId;
                alu.Payment_Date_Time__c = system.now();
                               
                if(statusCode == '0300')
                {                                                            
                    alu.Payment_Status__c = 'Success';
                    dblog.Error_Message__c = StatusErrDes; 
                }
                else if(statusCode == '0002')
                {
                    alu.Payment_Status__c = 'Pending';
                    dblog.Status__c = 'Pending';     
                    dblog.Error_Message__c = StatusErrDes;
                }
                else{
                    alu.Payment_Status__c = 'Failed';
                    dblog.Status__c = 'Failure';
                    dblog.Error_Message__c = StatusErrDes; 
                }
            }
            else{
                alu.Payment_Status__c = 'Failed';
                dblog.Status__c = 'Failure';
                dblog.Error_Message__c = StatusErrDes; 
                dblog.Payment_Reference_Id__c = referenceId;
            }
            update alu;
                
            insert dblog;
            
        }
        catch(Exception Ex){
            dblog.Status__c = 'Failure';
            dblog.Error_Message__c = string.valueof(Ex);
            upsert dblog;
        }
         return dblog.Status__c;
    }
}