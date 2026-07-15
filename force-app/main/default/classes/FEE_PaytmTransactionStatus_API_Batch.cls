global class FEE_PaytmTransactionStatus_API_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts,System.Schedulable{
    
    public void execute(System.SchedulableContext sc){
        FEE_PaytmTransactionStatus_API_Batch bh = new FEE_PaytmTransactionStatus_API_Batch ();
        Database.executeBatch(bh);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return database.getQueryLocator([SELECT id,Payment_Status__c,Reference_Id__c,Fee_Type__c,contact__c,Contact__r.Application_Number__c,contact__r.record_type_name__c FROM Student_Payment__c WHERE Payment_Status__c = 'Pending' AND Payment_Gateway__c = 'Paytm']); 
        // return database.getQueryLocator([SELECT id,Payment_Status__c,Reference_Id__c FROM Student_Payment__c WHERE id =: 'a1P9D000002BL0Z']);
    }
    public void execute(Database.BatchableContext BC, List<Student_Payment__c> scope){
        final String APPLICATION_FEE_TYPE ='Application Fee';
        hed__Application__c appl = new hed__Application__c();
        list<hed__Application__c> applList = new  list<hed__Application__c>();
        boolean applPAF;
        map<string,Student_Payment__c> stuPayment = new map<string,Student_Payment__c>();
        List<Student_Payment__c> lstStu = new List<Student_Payment__c>();
        List<Student_Payment__c> lstStuPAF = new List<Student_Payment__c>();
        List<Student_Fee__c> lstStuFee = new List<Student_Fee__c>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Student_Payment__c stu : scope){
            
            if(stu.contact__r.record_type_name__c == 'Applicant'){
                
                applList = [Select Provisional_Admission_Fee_Paid__c, Application_Number__c from hed__Application__c
                            where Application_Number__c =: stu.Contact__r.Application_Number__c LIMIT 1];
                if(applList.size() >0){
                    
                    applPAF = applList[0].Provisional_Admission_Fee_Paid__c;
                    
                    appl = applList[0];
                }
            }
            paytmMain ptm = new paytmMain();
            ptm.body = new PaytmParamClass();
            ptm.body.mid = Paytm_Details__c.getValues('MID').Value__c;
            ptm.body.orderId = stu.Reference_Id__c;
            
            string jsonStr = JSON.serialize(ptm.body);
            system.debug('jsonStr+++++++++'+jsonStr);
            system.debug('Key+++++++++'+Paytm_Details__c.getValues('Merchant Key').Value__c);
            string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('Merchant Key').Value__c, jsonStr);
            system.debug('checksumstring+++++++++'+checksumstring);
            ptm.head = new headDetails();
            ptm.head.signature = checksumstring;
            
            system.debug('Ptm++++++++'+ptm);
            
            string baseUrl = Paytm_Details__c.getValues('Transaction Status').Value__c;
            
            string str = JSON.serialize(ptm);
            system.debug('HttpBody++++++++'+str); 
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(baseUrl);
            req.setHeader('Content-Type','application/json');
            req.setMethod('POST');
            req.setBody(str);
            req.setTimeout(120000);
            HttpResponse res = h.send(req);
            
            system.debug('++++++++'+res); 
            System.debug('++++resBody++++++++'+res.getBody());
            
            inisaliseResponse response1 = new inisaliseResponse();
            
            if(res.getStatusCode() == 200){
                response1 = (inisaliseResponse)System.JSON.deserialize(res.getBody(), inisaliseResponse.class);
                if(response1.body.resultInfo.resultStatus == 'TXN_SUCCESS'){
                    stu.Payment_Status__c = 'Success';
                    stuPayment.put(stu.id,stu);
                    
                }
                else if(response1.body.resultInfo.resultStatus == 'TXN_FAILURE'){
                    stu.Payment_Status__c = 'Failed';
                    stuPayment.put(stu.id,stu);
                    
                }
                else if(response1.body.resultInfo.resultStatus == 'NO_RECORD_FOUND'){
                    stu.Payment_Status__c = 'Failed';
                    stuPayment.put(stu.id,stu);
                    
                }                
            }            
        }
        
        list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
        for(Student_Fee_Payment__c sf : [select id,Line_Item_Payment_Status__c,Student_Payment__c FROM Student_Fee_Payment__c WHERE Student_Payment__c =: stuPayment.keyset()]){
            if(stuPayment.containsKey(sf.Student_Payment__c)){
                sf.Line_Item_Payment_Status__c = stuPayment.get(sf.Student_Payment__c).Payment_Status__c;
                lstSfp.add(sf);
            }
        }
        
        if(stuPayment.values().size() > 0){
            update stuPayment.values();
            
        }  
        // Getting values for Application Fee Receipt and PAF Receipt
        for(Student_Payment__c payment : [select id,Transaction_ID__C,Payment_Gateway__c,Payment_Status__c,Fee_Type__c,contact__r.Email,contact__c,Contact__r.Application_Number__c,contact__r.Name FROM Student_Payment__c WHERE Id =: stuPayment.keyset()]) {
            
            if(payment.Payment_Status__c == 'success' && payment.Fee_Type__c == APPLICATION_FEE_TYPE) {
            		lstStu.add(payment);
                
            }
            else if(payment.Payment_Status__c == 'success' && payment.Fee_Type__c != APPLICATION_FEE_TYPE){
                contactIds.add(payment.Contact__c); 
                lstStuPAF.add(payment);
                
            }
        }
        
        
        if(lstSfp.size() > 0){
            update lstSfp;
        }
       // Sending Receipt for 1st Year Provisional Admission Fee paid as True
        if(lstStu.size() > 0){
            BulkOnlineGenerateReceipt.generateReceipt(lstStu);
       }
        // Sending Receipt for 1st Year Provisional Admission Fee paid as True
        if(lstStuPAF.size() >0 && contactIds.size() > 0 && applPAF == false ){
            lstStuFee = [SELECT Id, Amount__c, Contact__c,fee_year__c FROM Student_Fee__c WHERE Contact__c IN :contactIds AND Fee_year__c='1st Year'];
            if(!lstStuFee.isEmpty()){
                
                BulkOnlineGenerateReceipt.generatePAFReceipt(lstStuPAF);
                
            } 
        }
        
    }        


public void finish(Database.BatchableContext BC){       
}

public class paytmMain{
    @AuraEnabled public PaytmParamClass body {get;set;}
    @AuraEnabled public headDetails head {get;set;}
}
public class PaytmParamClass{
    @AuraEnabled public string mid {get;set;}
    @AuraEnabled public string orderId {get;set;}
}
public class headDetails{
    @AuraEnabled public string signature {get;set;}
}

public class inisaliseResponse{
    @AuraEnabled public resBodyDetails body {get;set;}
    @AuraEnabled public resHeadDetails head {get;set;}
}
public class resHeadDetails{
    @AuraEnabled public string responseTimestamp {get;set;}
    @AuraEnabled public string version {get;set;}
    @AuraEnabled public string signature {get;set;}
}
public class resResultInfoDetails{
    @AuraEnabled public string resultStatus {get;set;}
    @AuraEnabled public string resultCode {get;set;}
    @AuraEnabled public string resultMsg {get;set;}
}
public class resBodyDetails{
    @AuraEnabled public resResultInfoDetails resultInfo {get;set;}
    @AuraEnabled public string txnId {get;set;}
    @AuraEnabled public string bankTxnId {get;set;}
    @AuraEnabled public string orderId {get;set;}
    @AuraEnabled public string txnAmount {get;set;}
    @AuraEnabled public string txnType {get;set;}
    @AuraEnabled public string gatewayName {get;set;}
    @AuraEnabled public string bankName {get;set;}
    @AuraEnabled public string mid {get;set;}
    @AuraEnabled public string paymentMode {get;set;}       
    @AuraEnabled public string refundAmt {get;set;}
    @AuraEnabled public string txnDate {get;set;}
    @AuraEnabled public string cardScheme {get;set;}
    @AuraEnabled public string rrnCode {get;set;}
    @AuraEnabled public string authCode {get;set;}
}
}