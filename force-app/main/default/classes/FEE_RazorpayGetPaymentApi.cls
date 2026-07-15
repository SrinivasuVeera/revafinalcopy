global without sharing class FEE_RazorpayGetPaymentApi{  
    @future(callout=true)   
    global static void ReceivedData(string PaymentLinkId,string paymentId){
        string endpoint = Razorpay_Details__c.getInstance('FetchPaymentEndpoint').Value__c+paymentId;
        string jsonbody;
        String username = Razorpay_Details__c.getInstance('UserName').Value__c;
        String password = Razorpay_Details__c.getInstance('Password').Value__c; 
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);                 
        Http http = new Http();
        HTTPResponse res = http.send(req);
        jsonbody = res.getBody();
        jsonbody = jsonbody.replace('currency', 'ccurrency');
        System.debug('====resBody====='+res.getBody());
        system.debug('====status code===='+res.getStatusCode());
        
        fromJSON wrap = new fromJSON();
        wrap =  (fromJSON)System.JSON.deserialize(jsonbody, fromJSON.class); 
        system.debug('====wrap===='+wrap);
        
        Student_Payment__c stu = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,
                                  Amount__c ,Payment_Mode_Type__c FROM Student_Payment__c WHERE Payment_Link_Id__c =: PaymentLinkId];
        
        stu.Payment_Mode_Type__c = wrap.method;
        update stu;
        
        list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
        for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                       Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                       Student_Payment__c =: stu.id])
        {
            objStuFeePayment.Payment_Mode_Type__c = stu.Payment_Mode_Type__c;               
            lst_Studentfee.add(objStuFeePayment);
        } 
        if(lst_Studentfee.size()>0){
            update lst_Studentfee;
        }                              
    }
    
    public class fromJSON{
        public String id;   
        public String entity;   
        public Integer amount;  
        public String ccurrency; 
        public String status;  
        public String order_id;
        public boolean international;
        public String method;   
        public Integer amount_refunded; 
        public boolean captured;
        public String description;  
        public String vpa;  
        public String email;    
        public String contact;  
        public Integer fee; 
        public Integer tax; 
        public Integer created_at;
    }
}