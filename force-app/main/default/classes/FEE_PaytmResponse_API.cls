global class FEE_PaytmResponse_API 
{
     global string PurposeofPayment{get;set;}
    global string paymentMode{get;set;}
    global string homeUrl{get;set;}
    global paytmDateWrp paytmData{get;set;}
    global String applicationNumber{get;set;}
    global String emailAddress{get;set;}
    global string applicationHomeUrl{get;set;}
     global string FEE_TYPE{get;set;}
    global final String SMS_TYPE ='Application_Number';
    global string Applicant_PortalUrl{get;set;}
    
    
    global FEE_PaytmResponse_API(){
        
    }
    
    global void updateStudentFee(){
        homeUrl=Paytm_Details__c.getValues('HomeUrl').Value__c;
       paytmData = new paytmDateWrp(); 
       paytmData.MID = apexpages.currentpage().getparameters().get('MID'); 
       paytmData.TXNID = apexpages.currentpage().getparameters().get('TXNID');
       paytmData.ORDERID = apexpages.currentpage().getparameters().get('ORDERID');
       paytmData.BANKTXNID = apexpages.currentpage().getparameters().get('BANKTXNID');
       paytmData.TXNAMOUNT = apexpages.currentpage().getparameters().get('TXNAMOUNT');
       paytmData.paytmCURRENCY = apexpages.currentpage().getparameters().get('CURRENCY');
       paytmData.STATUS = apexpages.currentpage().getparameters().get('STATUS');
       paytmData.RESPCODE = apexpages.currentpage().getparameters().get('RESPCODE');
       paytmData.RESPMSG = apexpages.currentpage().getparameters().get('RESPMSG');
       paytmData.TXNDATE = apexpages.currentpage().getparameters().get('TXNDATE');
       paytmData.GATEWAYNAME = apexpages.currentpage().getparameters().get('GATEWAYNAME');
       paytmData.BANKNAME = apexpages.currentpage().getparameters().get('BANKNAME');
       paytmData.PAYMENTMODE = apexpages.currentpage().getparameters().get('PAYMENTMODE');
       paytmData.CHECKSUMHASH = apexpages.currentpage().getparameters().get('CHECKSUMHASH');
       system.debug('paytmData.RESPCODE+++++++++++++'+paytmData.RESPCODE);
       system.debug('paytmData.STATUS+++++++++++++'+paytmData.STATUS);
       system.debug('paytmData.RESPMSG+++++++++++++'+paytmData.RESPMSG);
       
       if(string.isNotBlank(paytmData.ORDERID)){
       
    //   string paymentMode = '';
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
       
        
       Student_Payment__c stu = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
                                  Amount__c ,Razorpay_Signature__c,Payment_Mode_Type__c FROM Student_Payment__c WHERE Reference_Id__c =: paytmData.ORDERID];
   /*                               
        if(paytmData.STATUS =='TXN_SUCCESS'){
            stu.Payment_Status__c = 'Success';
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
   */     
        PurposeofPayment = stu.Fee_Type__c;
    /*    update stu;
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
        
        
       // dblog.Response__c = res.getBody();
       // dblog.User_Id__c = UserInfo.getUserId(); 
        if(lst_Studentfee.size()>0){
            update lst_Studentfee; 
        }
      */  
      Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_PaytmResponse_API';
        dblog.Method_Name__c = 'updateStudentFee';
        dblog.Processing_API_Name__c = 'Paytm';            
        dblog.Data_Received__c = JSON.serialize(paytmData);
        if(paytmData.STATUS =='TXN_SUCCESS' || paytmData.STATUS =='PENDING'){
            dblog.Status__c = 'Success';
        }
        else{
            dblog.Status__c = 'Failure';
        }
        insert dblog;                          
    }                              
    
    }
global void updateApplicantFee(){
        
        // homeUrl = Paytm_Details__c.getValues('HomeUrl').Value__c;
        applicationHomeUrl=Paytm_Details__c.getValues('ApplicantHomeUrl').Value__c;
        Applicant_PortalUrl = Paytm_Details__c.getValues('Applicant_PortalUrl').Value__c;
        paytmData = new paytmDateWrp(); 
        paytmData.MID = apexpages.currentpage().getparameters().get('MID'); 
        paytmData.TXNID = apexpages.currentpage().getparameters().get('TXNID');
        paytmData.ORDERID = apexpages.currentpage().getparameters().get('ORDERID');
        paytmData.BANKTXNID = apexpages.currentpage().getparameters().get('BANKTXNID');
        paytmData.TXNAMOUNT = apexpages.currentpage().getparameters().get('TXNAMOUNT');
        paytmData.paytmCURRENCY = apexpages.currentpage().getparameters().get('CURRENCY');
        paytmData.STATUS = apexpages.currentpage().getparameters().get('STATUS');
        paytmData.RESPCODE = apexpages.currentpage().getparameters().get('RESPCODE');
        paytmData.RESPMSG = apexpages.currentpage().getparameters().get('RESPMSG');
        paytmData.TXNDATE = apexpages.currentpage().getparameters().get('TXNDATE');
        paytmData.GATEWAYNAME = apexpages.currentpage().getparameters().get('GATEWAYNAME');
        paytmData.BANKNAME = apexpages.currentpage().getparameters().get('BANKNAME');
        paytmData.PAYMENTMODE = apexpages.currentpage().getparameters().get('PAYMENTMODE');
        paytmData.CHECKSUMHASH = apexpages.currentpage().getparameters().get('CHECKSUMHASH');
        
        if(string.isNotBlank(paytmData.ORDERID)){
            system.debug(paytmData.PAYMENTMODE);
            
            
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
            } else if (paytmData.PAYMENTMODE == ''){
                paymentMode = 'Online';
            }
            
            
            Student_Payment__c stu = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
                                      Amount__c ,Razorpay_Signature__c,Payment_Mode_Type__c, 
                                      Contact__r.MobilePhone, Contact__r.Application_Number__C, Contact__r.Email, Contact__r.Application_Fee_Paid__c, Contact__r.Country_Code__c 
                                      FROM Student_Payment__c WHERE Reference_Id__c =: paytmData.ORDERID];
            FEE_TYPE=stu.Fee_Type__c;
            applicationNumber = stu.Contact__r.Application_Number__c;
            emailAddress = stu.Contact__r.Email;
            //    Amount = stu.Amount__c;
            if(paytmData.STATUS =='TXN_SUCCESS'){
                
                stu.Payment_Status__c = 'Success';
              /*  stu.Contact__r.Application_Fee_Paid__c = True;  
                update stu.Contact__r;*/
                
            }  
            else if(paytmData.STATUS =='PENDING'){
                stu.Payment_Status__c = 'Pending'; 
                if (paytmData.TXNDATE == null)
                    {
                        paytmData.TXNDATE = string.valueOf(system.now());
                    
                    }
            }
            else{
                stu.Payment_Status__c = 'Failed';
                if (paytmData.TXNDATE == null)
                    {
                        paytmData.TXNDATE = string.valueOf(system.now());
                    
                    }
            }
            stu.Transaction_ID__c = paytmData.TXNID;
            stu.Mode_of_Payment__c = 'Online';
            stu.Payment_Date_Time__c = system.now();
            stu.Payment_Mode_Type__c = paymentMode;
            stu.Payment_Gateway__c = 'Paytm';
            PurposeofPayment = stu.Fee_Type__c;
            //update stu;
           
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
            dblog.Class_Name__c = 'FEE_PaytmResponse_API';
            dblog.Method_Name__c = 'updateApplicantFee';
            dblog.Processing_API_Name__c = 'Paytm';            
            dblog.Data_Received__c = JSON.serialize(paytmData);
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
                
                //update lst_Studentfee; 
            }
            
            
        }
        
        
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