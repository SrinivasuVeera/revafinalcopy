@RestResource(urlMapping='/PaytmS2SResponse/*')
global class FEE_PaytmS2SResponse_API {
    static boolean applPAF;
    static hed__Application__c appl;
    static list<hed__Application__c> applList;
    @HttpPost
    global static String ReceivedData()
    {
        final String APPLICATION_FEE_TYPE ='Application Fee';
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        paytmDateWrp paytmData = new paytmDateWrp(); 
        paytmData.MID = req.params.get('MID'); 
        paytmData.TXNID = req.params.get('TXNID');
        paytmData.ORDERID = req.params.get('ORDERID');
        paytmData.BANKTXNID = req.params.get('BANKTXNID');
        paytmData.TXNAMOUNT = req.params.get('TXNAMOUNT');
        paytmData.paytmCURRENCY = req.params.get('CURRENCY');
        paytmData.STATUS = req.params.get('STATUS');
        paytmData.RESPCODE = req.params.get('RESPCODE');
        paytmData.RESPMSG = req.params.get('RESPMSG');
        paytmData.TXNDATE = req.params.get('TXNDATE');
        paytmData.GATEWAYNAME = req.params.get('GATEWAYNAME');
        paytmData.BANKNAME = req.params.get('BANKNAME');
        paytmData.PAYMENTMODE = req.params.get('PAYMENTMODE');
        paytmData.CHECKSUMHASH = req.params.get('CHECKSUMHASH');
        
        system.debug('++++++'+req.params);
        
        if(string.isNotBlank(paytmData.ORDERID)){
            string paymentMode = '';
            
            if(paytmData.PAYMENTMODE == 'CC'){
                paymentMode = 'Credit card';
            }
            else if(paytmData.PAYMENTMODE == 'DC'){
                paymentMode = 'Debit card';
            }
            else if(paytmData.PAYMENTMODE == 'NB'){
                paymentMode = 'Net banking';
            }
            else if(paytmData.PAYMENTMODE == 'UPI'){
                paymentMode = 'UPI';
            }
            else if(paytmData.PAYMENTMODE == 'PPI'){
                paymentMode = 'Paytm wallet';
            }
            else if(paytmData.PAYMENTMODE == 'PAYTMCC'){
                paymentMode = 'Postpaid';
            }
            
            List<Student_Payment__c> stuPayList = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,
                                      Fee_Type__c,contact__c,contact__r.record_type_name__c,Contact__r.Email,Contact__r.Application_Number__C,contact__r.Application_Fee_Paid__c,
                                      Amount__c ,Razorpay_Signature__c,Payment_Mode_Type__c FROM Student_Payment__c WHERE Reference_Id__c =: paytmData.ORDERID];
            List<Student_Payment__c> stuPayListUpdated = new List<Student_Payment__c>();
            if(stuPayList[0].contact__r.record_type_name__c == 'Applicant'){
                
                list<hed__Application__c> applList = [Select Provisional_Admission_Fee_Paid__c, Application_Number__c from hed__Application__c
                                                      where Application_Number__c =: stuPayList[0].Contact__r.Application_Number__c LIMIT 1];
                if(applList.size() >0){
                    
                    applPAF = applList[0].Provisional_Admission_Fee_Paid__c;
                    appl = applList[0];
                }
            }
            for(Student_Payment__c stu: stuPayList){
                if(paytmData.STATUS =='TXN_SUCCESS'){
                    stu.Payment_Status__c = 'Success';
                    if(stu.Fee_Type__c == APPLICATION_FEE_TYPE && stu.contact__r.Application_Fee_Paid__c == false){
                
                        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :stu.id];
                        
                        if (documentLinks.size() == 0) {
                            // Sending Application Fee Receipt
                            Id cvId = RegistrationFormUtility.generateReceipt(stu.Id, stu.Transaction_ID__C, stu.Payment_Gateway__c);
                            RegistrationFormUtility.sendReceipt(stu.Id, cvId); 
                        }
                        
                    }
                     // Sending Receipt for 1st Year Provisional Admission Fee paid as True
                    if(applPAF == false && stu.Fee_Type__c != APPLICATION_FEE_TYPE){
                        
                        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :stu.id];
                        List<Student_Fee__c> sf = [select id, contact__c, fee_year__c from student_fee__c
                                                where contact__c =: stu.Contact__c AND Fee_year__c='1st Year']; 
                        if(!sf.isEmpty() && documentLinks.size() == 0){
                        
                            AdmissionsProcessUtility.generateOfflineReceipt(stu.Id,stu.Payment_Mode_Type__c,stu.Payment_Gateway__c,stu.Transaction_ID__c );
                            
                        } 
                    }
                }  
                else if(paytmData.STATUS =='PENDING'){
                    stu.Payment_Status__c = 'Pending';  
                }
                else{
                    stu.Payment_Status__c = 'Failed';
                }
                stu.Transaction_ID__c = paytmData.TXNID;
                stu.Mode_of_Payment__c = 'Online';
                stu.Payment_Date_Time__c = system.now();
                stu.Payment_Mode_Type__c = paymentMode;
                stu.Payment_Gateway__c = 'Paytm';
                stuPayListUpdated.add(stu);

            }
            //    Amount = stu.Amount__c;
            if(stuPayListUpdated.size() > 0){
              update stuPayListUpdated;  
            }
            // update stu;
            

            
            list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
            for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                           Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                           Reference_Id__c =: paytmData.ORDERID])
            {
                if(paytmData.STATUS =='TXN_SUCCESS'){
                    objStuFeePayment.Line_Item_Payment_Status__c = 'Success';
                }
                else if(paytmData.STATUS =='PENDING'){
                    objStuFeePayment.Line_Item_Payment_Status__c = 'Pending';  
                }
                else{ 
                    objStuFeePayment.Line_Item_Payment_Status__c = 'Failed';
                }
                
                objStuFeePayment.SF_Transaction_ID__c = paytmData.TXNID;
                objStuFeePayment.Transaction_Date_Time__c = system.now();
                objStuFeePayment.Payment_Mode_Type__c = paymentMode;
                lst_Studentfee.add(objStuFeePayment);
            }
            
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_PaytmS2SResponse_API';
            dblog.Method_Name__c = 'ReceivedData';
            dblog.Processing_API_Name__c = 'Paytm';            
            dblog.Data_Received__c = JSON.serialize(paytmData);
            dblog.Payment_Reference_Id__c = paytmData.ORDERID;
            if(paytmData.STATUS =='TXN_SUCCESS' || paytmData.STATUS =='PENDING'){
                dblog.Status__c = 'Success';
            }
            else{
                dblog.Status__c = 'Failure';
            }
            insert dblog;
            
            // dblog.Response__c = res.getBody();
            // dblog.User_Id__c = UserInfo.getUserId(); 
            if(lst_Studentfee.size()>0){
                update lst_Studentfee; 
            }
            
           
            
            
        }
        
        return null;
    }
    
    global class paytmDateWrp{
        public string MID{get;set;}
        public string TXNID{get;set;}
        public string ORDERID{get;set;}
        public string BANKTXNID{get;set;}
        public string TXNAMOUNT{get;set;}
        public string paytmCURRENCY{get;set;}
        public string STATUS{get;set;}
        public string RESPCODE{get;set;}
        public string RESPMSG{get;set;}
        public string TXNDATE{get;set;}
        public string GATEWAYNAME{get;set;}
        public string BANKNAME{get;set;}
        public string PAYMENTMODE{get;set;}
        public string CHECKSUMHASH{get;set;}
    }
}