@RestResource(UrlMapping='/BillDeskServerResponse/*')
global without sharing class FEE_BilldeskServerResponseAPI 
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
            
            dblog.Class_Name__c = 'FEE_BilldeskServerResponseAPI';
            dblog.Method_Name__c = 'ReceivedData';
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Data_Received__c = data;
            dblog.Status__c = 'Success'; 
                  
            String newStrReq = data;
            Integer reqLen = newStrReq.split('\\|').size();
            system.debug('reqLen.Size+++++++++++'+reqLen);           
            String checkSumValue = newStrReq.split('\\|')[reqLen-1];
            string referenceId = newStrReq.split('\\|')[reqLen-25];
            string PaymentMode = newStrReq.split('\\|')[reqLen-19];
            string statusCode = newStrReq.split('\\|')[reqLen-12];
            string transactionId = newStrReq.split('\\|')[reqLen-24];
            string StatusErrDes = newStrReq.split('\\|')[reqLen-2];
            system.debug('+++++++++'+referenceId);            
            dblog.Payment_Reference_Id__c = referenceId;
            dblog.Status__c = 'Success'; 
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