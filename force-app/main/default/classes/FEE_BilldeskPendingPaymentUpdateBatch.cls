global class FEE_BilldeskPendingPaymentUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext BC){
        dateTime startDate = system.now().addDays(-7);
        dateTime endDate = system.now();
        if(Test.isRunningTest()){
            return database.getQueryLocator([SELECT id,Transaction_ID__c,Fee_Type__c,Payment_Gateway__c,Reference_Id__c,Payment_Status__c,Payment_Date_Time__c,Payment_Mode_Type__c,Error_Description__c,
                                             Amount__c,BillDesk_Auth_Code__c,BillDesk_Refund_Code__c,Contact__r.MobilePhone,Contact__r.Country_Code__c,Contact__r.Application_Number__C,Contact__r.Application_fee_Paid__c, 
                                             Contact__r.Name,contact__r.record_type_name__c,contact__c, Contact__r.Email  FROM Student_Payment__c limit 1]);
        }
        else{
            return database.getQueryLocator([SELECT id,Transaction_ID__c,Fee_Type__c,Payment_Gateway__c,Reference_Id__c,Payment_Status__c,Payment_Date_Time__c,Payment_Mode_Type__c,Error_Description__c,Contact__r.Application_fee_Paid__c,
                                             Amount__c,BillDesk_Auth_Code__c,BillDesk_Refund_Code__c,Contact__r.MobilePhone,Contact__r.Country_Code__c,Contact__r.Application_Number__c, 
                                             Contact__r.Name,contact__c,contact__r.record_type_name__c, Contact__r.Email FROM Student_Payment__c WHERE (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Payment Link Created' OR Payment_Status__c = 'Failed') AND 
                                             Payment_Gateway__c = 'Billdesk' AND LastModifiedDate >=: startDate AND LastModifiedDate <=: endDate AND Reference_Id__c != Null]);   
            
        }
        
    }
    global void execute(Database.BatchableContext BC, List<Student_Payment__c> scope){
        final String APPLICATION_FEE_TYPE ='Application Fee';
        hed__Application__c appl = new hed__Application__c();
        list<hed__Application__c> applList = new list<hed__Application__c>();
        boolean applPAF;
        Student_Payment__c spRec = new Student_Payment__c();
        list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_BilldeskPendingPaymentUpdateBatch';
        dblog.Method_Name__c = 'BilldeskPendingBatch';
        dblog.Processing_API_Name__c = 'BillDesk';                    
        
        dateTime dt = system.now();
        string strDt =string.valueof(dt);
        String newStrDt = strDt.replaceAll('[^0-9]', '');
        for(Student_Payment__c sp : scope){
            if(sp.contact__r.record_type_name__c == 'Applicant'){
                applList = [Select Provisional_Admission_Fee_Paid__c, Application_Number__c from hed__Application__c
                            where Application_Number__c =: sp.Contact__r.Application_Number__c LIMIT 1];
                if(applList.size() >0){
                    
                    applPAF = applList[0].Provisional_Admission_Fee_Paid__c;
                    appl = applList[0];
                }
            }
            string baseReq = '0122|'+Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'|'+sp.Reference_Id__c;
            baseReq += '|'+ newStrDt;
            String genertedcheckSum = FEE_StudentPayment_Ctrl.calculateCheckSum(baseReq);
            genertedcheckSum = genertedcheckSum.toUppercase();
            baseReq = baseReq+'|'+genertedcheckSum;
            system.debug('+++++++++'+baseReq);
            
            string endPoint = Billdesk_Merchant_Details__c.getValues('QueryApiEndpoint').MerchantId__c;
            system.debug('====>>>'+endPoint);
            Http http1 = new Http();
            HttpRequest httpReq1 = new HttpRequest();
            HttpResponse httpRes1 = new HttpResponse();
            httpReq1.setEndpoint(endPoint);
            httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            string payload = 'msg='+baseReq;
            httpReq1.setbody(payload);
            httpReq1.setMethod('POST');
            httpReq1.setTimeout(120000);
            httpRes1 = http1.send(httpReq1);
            
            System.debug('Request Body====>'+httpReq1.getBody());
            System.debug('response Body====>'+httpRes1.getBody());
            system.debug('====status code===='+httpRes1.getStatusCode());
            
            string response = httpRes1.getBody();  
            system.debug('response+++++++'+response);    
            dblog.Data_Received__c = response;    
            dblog.Student_Payment__c = sp.id; 
            dblog.Request__c = 'URL: ' + endPoint + '\nBODY: ' + payload;
			dblog.Response__c = 'STATUS: ' + httpRes1.getStatusCode() + '\nBODY: ' + response;
            Integer reqLen = response.split('\\|').size();
            system.debug('reqLen+++++++'+reqLen);
            string queryStatus = response.split('\\|')[reqLen-2]; 
            String refundCode = response.split('\\|')[reqLen-6];
            String authCode = response.split('\\|')[reqLen-18];
            String errorDiscription = response.split('\\|')[reqLen-8];
            String paymentDateTimeString = response.split('\\|')[reqLen-19 ];
            String TransactionType = response.split('\\|')[reqLen-25];
            String transactionIdString = response.split('\\|')[reqLen-30];
            DateTime paymentDateTime;
            system.debug('+++++'+authCode);
            system.debug('+++++'+queryStatus);
            
            if(errorDiscription.length() > 254){ 
                errorDiscription = errorDiscription.substring(0,254);    
            }
            dblog.Payment_Reference_Id__c = sp.Reference_Id__c;
            
            if(queryStatus == 'Y'){
                if(authCode == '0300' && refundCode == 'NA'){
                    sp.Payment_Status__c = 'Success';
                   
                  if (!paymentDateTimeString.equals('NA')) {
                        List<String> dateTimeParts = paymentDateTimeString.split(' ');
                        List<String> dateParts = dateTimeParts[0].split('-');
                        List<String> timeParts = dateTimeParts[1].split(':');
                    
                        Integer year = Integer.valueOf(dateParts[2]);
                        Integer month = Integer.valueOf(dateParts[1]);
                        Integer day = Integer.valueOf(dateParts[0]);
                        Integer hour = Integer.valueOf(timeParts[0]);
                        Integer minute = Integer.valueOf(timeParts[1]);
                        Integer second = Integer.valueOf(timeParts[2]);
                    
                        sp.Payment_Date_Time__c = Datetime.newInstance(year, month, day, hour, minute, second);

                      
                     system.debug('Data and Time==='+paymentDateTimeString);
                      system.debug('Payment_Date_Time__c==='+sp.Payment_Date_Time__c);
                        }

                    
                    
                    sp.Transaction_ID__c = transactionIdString;
                   // system.debug('Payment Date and Time==='+paymentDateTime);
                    system.debug('TransactionID==='+transactionIdString);
                    if(TransactionType == '01')    sp.Payment_Mode_Type__c ='Netbanking';
                    else if(TransactionType == '02')  sp.Payment_Mode_Type__c ='Credit Card';
                    else if(TransactionType == '03')  sp.Payment_Mode_Type__c ='Debit Card';
                    else if(TransactionType == '04') sp.Payment_Mode_Type__c ='Cash Card';
                    else if(TransactionType == '05') sp.Payment_Mode_Type__c ='Mobile';
                    else if(TransactionType == '06')   sp.Payment_Mode_Type__c ='IMPS';
                    else if(TransactionType == '07')   sp.Payment_Mode_Type__c ='Reward Points';
                    else if(TransactionType == '08')  sp.Payment_Mode_Type__c ='Others';
                    else if(TransactionType == '09') sp.Payment_Mode_Type__c ='Others Wallet';
                    else if(TransactionType == '10')   sp.Payment_Mode_Type__c ='UPI';
                    system.debug('Payment_Mode_Type__c==='+sp.Payment_Mode_Type__c);
                }
                if(authCode == '0300' && refundCode == '0699'){
                    sp.Payment_Status__c = 'Refunded';
                }
                if(authCode == '0300' && refundCode == '0799'){
                    sp.Payment_Status__c = 'Refunded';
                }
                if(authCode == '0300' && refundCode == '0899'){
                    sp.Payment_Status__c = 'Refunded';
                }
                if(authCode == '0399'){
                    sp.Payment_Status__c = 'Failed';
                    sp.Error_Description__c = errorDiscription;
                }
                if(authCode == '0001'){
                    sp.Payment_Status__c = 'Failed';
                    sp.Error_Description__c = errorDiscription;
                }
                if(authCode == 'NA'){
                    sp.Payment_Status__c = 'Failed';
                    sp.Error_Description__c = errorDiscription;
                }
                if(authCode == '0002'){
                    sp.Payment_Status__c = 'Pending';
                    sp.Error_Description__c = errorDiscription;
                }
                
            }
            
            if(queryStatus == 'N'){
                sp.Error_Description__c = errorDiscription;
                
            }
            if(sp.Payment_Status__c == 'Success' || sp.Payment_Status__c == 'Refunded' || sp.Payment_Status__c == 'Pending'){
                dblog.Status__c = sp.Payment_Status__c;
            }
            else{
                dblog.Status__c = 'Failure';
            }
            sp.BillDesk_Refund_Code__c = refundCode;
            sp.BillDesk_Auth_Code__c = authCode;
            update sp;
            
            spRec = sp; // passing SP Record outside for loop to generate receipt for PAF paid
            
            if(sp.Payment_Status__c == 'Success' && sp.Fee_Type__c == APPLICATION_FEE_TYPE && sp.Contact__r.Application_Fee_Paid__c == false){
                
                //Passing the paymentId(Transaction_ID__C) - as the VisualFOrce is not able to retrieve the fields updated in this class.
                //Hence we are passing them as parameters and using the values in the VF Controller (StudentPaymentController)
                Id cvId = RegistrationFormUtility.generateReceipt(sp.Id, sp.Transaction_ID__c, sp.Payment_Gateway__c);
                RegistrationFormUtility.sendReceipt(sp.Id, cvId); 
            }  
            
            for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,Reference_Id__c,
                                                           Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                           Reference_Id__c =: sp.Reference_Id__c]){
                                                               objStuFeePayment.Line_Item_Payment_Gateway__c = sp.Payment_Gateway__c;
                                                               objStuFeePayment.Transaction_Date_Time__c = sp.Payment_Date_Time__c;
                                                               objStuFeePayment.SF_Transaction_ID__c = sp.Transaction_ID__c;
                                                               objStuFeePayment.Line_Item_Payment_Status__c = sp.Payment_Status__c; 
                                                               objStuFeePayment.Reference_Id__c = sp.Reference_Id__c;
                                                               lstSfp.add(objStuFeePayment);                                                        
                                                           }                      
        }
        
        if(lstSfp.size() > 0){
            update lstSfp;
        }
        insert dblog;
        
        // Sending Receipt for 1st Year Provisional Admission Fee paid as True
        if(applPAF == false && spRec.Payment_Status__c == 'Success' && spRec.Fee_Type__c != APPLICATION_FEE_TYPE){
            
            List<Student_Fee__c> sf = [select id, contact__c, fee_year__c from student_fee__c
                                       where contact__c =: spRec.Contact__c AND Fee_year__c='1st Year']; 
            if(!sf.isEmpty()){
                AdmissionsProcessUtility.generateOfflineReceipt(spRec.Id,spRec.Payment_Mode_Type__c,spRec.Payment_Gateway__c,spRec.Transaction_ID__c );
                
            } 
        }
        
    }
    global void finish(Database.BatchableContext BC){   
        //  BatchClass_Utility.sendBatchClassFailureMail('Fee Module', BC.getJobId(), 'Bill Desk Pending Payment','Student Payment');
    }
}