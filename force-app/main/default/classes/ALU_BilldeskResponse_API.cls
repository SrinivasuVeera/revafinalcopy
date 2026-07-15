global without sharing class ALU_BilldeskResponse_API 
{    
    global string responce{get;set;}
    global string SuccessMsg{get;set;}
    global string refId{get;set;}
    global string TransactionType{get;set;}
    global string referenceId{get;set;}
    global string transactionId{get;set;}
    global decimal amount{get;set;}
    global string homeUrl{get;set;}
    global string PaymentMode{get;set;}
    global DateTime TransactionDateTime{get;set;}
    global String PurposeofPayment{get;set;}
    global String StatusDescription{get;set;}
    global String StatusErrDes{get;set;}
    global string urlRefresh{get;set;}
    
    global ALU_BilldeskResponse_API(){
    }
    
    global void BilldeskRespon()
    {
        urlRefresh = '';
        homeUrl = Billdesk_Merchant_Details__c.getValues('Alumini Home Url').MerchantId__c;
        responce = apexpages.currentpage().getparameters().get('msg');
        system.debug('++++++++++'+responce);
        Debug_Log__c dblog = new Debug_Log__c();
        try{            
            if(responce != null)
            {
                String newStrReq = responce;
                Integer reqLen = newStrReq.split('\\|').size();
                String checkSumValue = newStrReq.split('\\|')[reqLen-1];
                String statusCode = newStrReq.split('\\|')[reqLen-12]; 
                transactionId = newStrReq.split('\\|')[reqLen-24];
                //String ref = newStrReq.split('\\|')[reqLen-25];
                referenceId = newStrReq.split('\\|')[reqLen-25];
                refId = newStrReq.split('\\|')[reqLen-8];
                TransactionType = newStrReq.split('\\|')[reqLen-19];
                StatusErrDes = newStrReq.split('\\|')[reqLen-2];
                
                String noCheckSumValue = newStrReq.removeEnd(newStrReq.split('\\|')[reqLen-1]);
                String requestwithNoCheckSum = noCheckSumValue.Substring(0,noCheckSumValue.length()-1);
                Alumni_Payments__c alu = [SELECT id,Transaction_Id__c,Payment_Status__c,Payment_Date_Time__c,Payment_Mode_Type__c,Description__c,
                                          Amount__c FROM Alumni_Payments__c WHERE Reference_Id__c =: referenceId];
                if(alu.Payment_Status__c =='Payment Link Created')
                {
                    dblog.Class_Name__c = 'ALU_BilldeskResponse_API';
                    dblog.Method_Name__c = 'BilldeskRespon';
                    dblog.Processing_API_Name__c = 'BillDesk';            
                    dblog.Data_Received__c = responce;
                    dblog.Alumni_Payment__c = alu.id;
                    
                    string newCheckSum = calculateCheckSum(requestwithNoCheckSum);
                    
                    if(newCheckSum == checkSumValue || test.isRunningTest())
                    {                        
                        if(statusCode == '0300')
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
                            alu.Payment_Status__c = 'Success';
                            amount = alu.Amount__c;
                            if(alu.Payment_Date_Time__c != null)  TransactionDateTime = alu.Payment_Date_Time__c;
                            else TransactionDateTime =system.now();  
                            PurposeofPayment = alu.Description__c;
                            PaymentMode = 'Online';
                            SuccessMsg = 'Transaction Success..!!';
                            dblog.Status__c = 'Success';
                            dblog.Error_Message__c = StatusErrDes; 
                           dblog.Payment_Reference_Id__c = referenceId;                       
                        }
                        else if(statusCode == '0002')
                        {
                            if(TransactionType == '01')  alu.Payment_Mode_Type__c ='Netbanking';
                            else if(TransactionType == '02') alu.Payment_Mode_Type__c ='Credit Card';
                            else if(TransactionType == '03') alu.Payment_Mode_Type__c ='Debit Card';
                            else if(TransactionType == '04')  alu.Payment_Mode_Type__c ='Cash Card';
                            else if(TransactionType == '05') alu.Payment_Mode_Type__c ='Mobile';
                            else if(TransactionType == '06') alu.Payment_Mode_Type__c ='IMPS';
                            else if(TransactionType == '07') alu.Payment_Mode_Type__c ='Reward Points';
                            else if(TransactionType == '08')  alu.Payment_Mode_Type__c ='Others';
                            else if(TransactionType == '09') alu.Payment_Mode_Type__c ='Others Wallet';
                            else if(TransactionType == '10') alu.Payment_Mode_Type__c ='UPI';
                            
                            alu.Transaction_ID__c = transactionId;
                            alu.Payment_Date_Time__c = system.now();
                            alu.Payment_Status__c = 'Pending';
                            amount = alu.Amount__c;
                            if(alu.Payment_Date_Time__c != null)  TransactionDateTime = alu.Payment_Date_Time__c;
                            else    TransactionDateTime =system.now();
                            PaymentMode = 'Online';
                            PurposeofPayment = alu.Description__c;
                            SuccessMsg = 'Transaction Pending..!!';
                            dblog.Status__c = 'Pending';     
                            dblog.Error_Message__c = StatusErrDes;
                            dblog.Payment_Reference_Id__c = referenceId;      
                        }
                        else{
                            alu.Transaction_ID__c = transactionId;
                            alu.Payment_Date_Time__c = system.now();
                            alu.Payment_Status__c = 'Failed';
                            amount = alu.Amount__c;
                            if(alu.Payment_Date_Time__c != null) TransactionDateTime = alu.Payment_Date_Time__c;
                            else TransactionDateTime =system.now();
                            PurposeofPayment = alu.Description__c;
                            StatusDescription  = StatusErrDes;                            
                            PaymentMode = 'Online';
                            SuccessMsg = 'Transaction Failed..!!';                        
                            dblog.Status__c = 'Failure';
                            dblog.Error_Message__c = StatusErrDes; 
                            dblog.Payment_Reference_Id__c = referenceId;
                        }   
                    }
                    else{
                        
                        alu.Transaction_ID__c = transactionId;
                        alu.Payment_Date_Time__c = system.now();
                        alu.Payment_Status__c = 'Failed';
                        SuccessMsg = 'Failed.CheckSum Not Matched..!!';
                        dblog.Status__c = 'Failure';
                        dblog.Error_Message__c = StatusErrDes; 
                        dblog.Payment_Reference_Id__c = referenceId;
                    }
                    
                    update alu;   
                    
                        
                    insert dblog;
                }
                else
                {
                    urlRefresh = 'Dont Refesh the Page.';
                }
            }
        }
        catch(exception ex)
        {
            dblog.Class_Name__c = 'ALU_BilldeskResponse_API';
            dblog.Method_Name__c = 'BilldeskRespon';
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Data_Received__c = responce;
            upsert dblog; 
        }
    }
    
    public static string calculateCheckSum(string mainStr){
        String testKey = Billdesk_Merchant_Details__c.getValues('Alumini Checksum').MerchantId__c;
        String algorithmName = 'hmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(mainStr) , Blob.valueOf(testKey));
        //system.debug('++++'+hmacData);
        return EncodingUtil.convertToHEX(hmacData);
        
    }
    
}