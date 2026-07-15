// @RestResource(urlMapping='/EasyPayResponse/*')
global class FEE_EazyPayResponse_API {
    global string responseCode {get;set;}
    global string uniqueRefNumber {get;set;}
    global string transactionId {get;set;}
    global string serviceTaxAmount {get;set;}
    global string processingFeeAmount {get;set;}
    global string totalAmount{get;set;}    
    global string transactionAmount{get;set;}
    global string transactionDate{get;set;}
    global string interchangeValue{get;set;}
    global string tdr{get;set;}
    global string paymentMode{get;set;}
    global string subMerchantId{get;set;}
    global string referenceNo{get;set;}
    global string tps{get;set;}
    global string signature{get;set;}
    global string homeUrl{get;set;}
    global String PurposeofPayment{get;set;}
    global string StatusMsg{get;set;}
    global string Applicant_HomeUrl{get;set;}
    global string Applicant_PortalUrl{get;set;}
    global string FEE_TYPE{get;set;}
  	global string recordType{get;set;}
    
    global void updateStudentFee(){
        homeUrl=EasyPay_Details__c.getValues('HomeUrl').Value__c;
        Applicant_HomeUrl=EasyPay_Details__c.getValues('Applicant_HomeUrl').Value__c;
        Applicant_PortalUrl=EasyPay_Details__c.getValues('Applicant_PortalUrl').Value__c;
        signature = apexpages.currentpage().getparameters().get('RS');
        responseCode = apexpages.currentpage().getparameters().get('Response Code');
        uniqueRefNumber = apexpages.currentpage().getparameters().get('Unique Ref Number');
        transactionId = apexpages.currentpage().getparameters().get('ID');
        serviceTaxAmount = apexpages.currentpage().getparameters().get('Service Tax Amount');
        processingFeeAmount = apexpages.currentpage().getparameters().get('Processing Fee Amount');
        totalAmount = apexpages.currentpage().getparameters().get('Total Amount');
        transactionAmount = apexpages.currentpage().getparameters().get('Transaction Amount');
        transactionDate = apexpages.currentpage().getparameters().get('Transaction Date');
        interchangeValue = apexpages.currentpage().getparameters().get('interchange Value');
        tdr = apexpages.currentpage().getparameters().get('TDR');
        paymentMode = apexpages.currentpage().getparameters().get('Payment Mode');
        subMerchantId = apexpages.currentpage().getparameters().get('SubMerchantId');
        referenceNo = apexpages.currentpage().getparameters().get('ReferenceNo');
        tps = apexpages.currentpage().getparameters().get('TPS');
        string sheckSumRef = transactionId+'|'+responseCode+'|'+uniqueRefNumber+'|'+serviceTaxAmount+'|'+processingFeeAmount+'|'+totalAmount+'|'+transactionAmount+'|';
        sheckSumRef += transactionDate+'|'+interchangeValue+'|'+tdr+'|'+paymentMode+'|'+subMerchantId+'|'+referenceNo+'|'+tps+'|';
        sheckSumRef += EasyPay_Details__c.getValues('AES key').Value__c;
        Debug_Log__c dblog = new Debug_Log__c();
        
        try{
            system.debug('signature++++++++'+signature);
            system.debug('sheckSumRef++++++++'+sheckSumRef);
            system.debug('===referenceNo==='+referenceNo);
            if(string.isNotBlank(referenceNo) && referenceNo != Null && referenceNo != 'null'){
                Blob digest = Crypto.generateDigest('SHA-512', Blob.valueOf(sheckSumRef));
                String encryptedString = EncodingUtil.convertToHex(digest);
                system.debug('encryptedString+++++'+encryptedString);
                
                Student_Payment__c stu = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
                                              Amount__c ,Razorpay_Signature__c,Payment_Mode_Type__c,Contact__r.Application_Fee_Paid__c,Contact__r.Primary_Academic_Program__r.name,
                                              Contact__r.Application_Number__c, contact__r.record_type_name__c,Contact__r.MobilePhone, Contact__r.Country_Code__c FROM Student_Payment__c WHERE Reference_Id__c =: referenceNo];
                     FEE_TYPE = stu.Fee_Type__c;
                	recordType = stu.Contact__r.record_type_name__c;
                system.debug('recordtype=====>'+recordType);
                
                  if(encryptedString == signature )
                  {
                      
                  }  
                
                
                if(responseCode == 'E000' ){
                    stu.Payment_Status__c = 'Success'; 
                    StatusMsg = 'Transaction Success..!!';                   
                }
                else{
                    stu.Payment_Status__c = 'Failed'; 
                    StatusMsg = 'Transaction Failed..!!';
                }     
                stu.Transaction_ID__c = uniqueRefNumber;
                stu.Mode_of_Payment__c = 'Online';
                stu.Payment_Date_Time__c = system.now();
            //    stu.Razorpay_Signature__c = razorPay_Sign;
                stu.Payment_Gateway__c = 'Eazypay';
                stu.Payment_Mode_Type__c = paymentMode;
                PurposeofPayment = stu.Fee_Type__c;
                //update stu;
                system.debug('===responseCode ==='+responseCode); 
                list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
                for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                               Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                               Student_Payment__c =: stu.id])
                {
                    if(responseCode == 'E000'){
                        objStuFeePayment.Line_Item_Payment_Status__c = 'Success';
                    }    
                    else{ 
                        objStuFeePayment.Line_Item_Payment_Status__c = 'Failed'; 
                    }              
                        objStuFeePayment.SF_Transaction_ID__c = uniqueRefNumber;
                        objStuFeePayment.Transaction_Date_Time__c = system.now();
                        objStuFeePayment.Payment_Mode_Type__c = paymentMode;
                        lst_Studentfee.add(objStuFeePayment);
                }
                
                //update lst_Studentfee;
                dblog.Class_Name__c = 'FEE_EasyPayResponse_API';
                dblog.Method_Name__c = 'updateStudentFee';
                dblog.Processing_API_Name__c = 'EasyPay';            
                dblog.Data_Received__c = sheckSumRef;
                if(Payment_Gateway_Error_Msg__c.getValues('Eazypay-'+responseCode).Status__c == 'Success'){
                    dblog.Status__c = 'Success';
                }
                else{
                    dblog.Status__c = 'Failure';
                }
                insert dblog;
            }
        }
        catch(Exception Ex){
            dblog.Class_Name__c = 'FEE_EasyPayResponse_API';
            dblog.Method_Name__c = 'updateStudentFee';
            dblog.Processing_API_Name__c = 'EasyPay';            
            dblog.Data_Received__c = sheckSumRef;
            if(Payment_Gateway_Error_Msg__c.getValues('Eazypay-'+responseCode).Status__c == 'Success'){
                dblog.Status__c = 'Success';
            }
            else{
                dblog.Status__c = 'Failure';
            }
            upsert dblog;
        }
    }
}