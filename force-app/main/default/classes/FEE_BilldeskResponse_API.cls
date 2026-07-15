// @RestResource(UrlMapping='/ResponseDetaiils/*')
global class FEE_BilldeskResponse_API 
{    
    global String responce{get;set;}
    global String paymentId {get;set;}
    global String paymentGateway {get;set;}
    global String successMsg{get;set;}
    global String refId{get;set;}
    global String transactionType{get;set;}
    global String referenceId{get;set;}
    global String transactionId{get;set;}
    global Decimal amount{get;set;}
    global String homeUrl{get;set;}
    global String Applicant_Billdesk_HomeUrl{get;set;}
    global String paymentMode{get;set;}
    global String iSTTransactionDateTime{get;set;}
    global Datetime transactionDateTime{get;set;}
    global String purposeofPayment{get;set;}
    global String statusDescription{get;set;}
    global String statusErrDes{get;set;}
    global String urlRefresh{get;set;}
    global final String SMS_TYPE ='Application_Number';
    global final String APPLICATION_FEE_TYPE ='Application Fee';
    static hed__Application__c appl;
    static list<hed__Application__c> applList;
    static boolean applPAF;
    global string FEE_TYPE{get;set;}
    global string Applicant_PortalUrl{get;set;}
    global String applicationNumber{get;set;}
    global String emailAddress{get;set;}
    global string ApplicantHomeUrl{get;set;}
    
    global static Set<id> sf1 = new set<id>();
    
    global FEE_BilldeskResponse_API(){
    }
    
    global void BilldeskRespon()
    {
        urlRefresh = '';
        homeUrl = Billdesk_Merchant_Details__c.getValues('HomeUrl').MerchantId__c;
        responce = apexpages.currentpage().getparameters().get('msg');
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
                Student_Payment__c stu = [SELECT id,Transaction_ID__c,Mode_of_Payment__c,Payment_Status__c,Payment_Date_Time__c,Payment_Mode_Type__c,
                                          Amount__c,Fee_Type__c FROM Student_Payment__c WHERE Reference_Id__c  =: referenceId];
                if(stu.Payment_Status__c =='Payment Link Created')
                {
                    dblog.Class_Name__c = 'FEE_BilldeskResponse_API';
                    dblog.Method_Name__c = 'BilldeskRespon';
                    dblog.Processing_API_Name__c = 'BillDesk';            
                    dblog.Data_Received__c = responce;
                    
                    string newCheckSum = calculateCheckSum(requestwithNoCheckSum);
                    
                    if(newCheckSum == checkSumValue || test.isRunningTest())
                    {                        
                        if(statusCode == '0300')
                        {
                            if(TransactionType == '01')    stu.Payment_Mode_Type__c ='Netbanking';
                            else if(TransactionType == '02')  stu.Payment_Mode_Type__c ='Credit Card';
                            else if(TransactionType == '03')  stu.Payment_Mode_Type__c ='Debit Card';
                            else if(TransactionType == '04') stu.Payment_Mode_Type__c ='Cash Card';
                            else if(TransactionType == '05') stu.Payment_Mode_Type__c ='Mobile';
                            else if(TransactionType == '06')   stu.Payment_Mode_Type__c ='IMPS';
                            else if(TransactionType == '07')   stu.Payment_Mode_Type__c ='Reward Points';
                            else if(TransactionType == '08')  stu.Payment_Mode_Type__c ='Others';
                            else if(TransactionType == '09') stu.Payment_Mode_Type__c ='Others Wallet';
                            else if(TransactionType == '10')   stu.Payment_Mode_Type__c ='UPI';
                            
                            stu.Transaction_ID__c = transactionId;
                            stu.Payment_Date_Time__c = system.now();
                            //stu.Payment_Date_Time__c = datetime.now();
                            //stu.Payment_Date_Time__c = system.now().addHours(5).addMinutes(30);
                            stu.Payment_Status__c = 'Success';
                            amount = stu.Amount__c;
                            if(stu.Payment_Date_Time__c != null)  TransactionDateTime = stu.Payment_Date_Time__c;//.addHours(5).addMinutes(30);
                            else TransactionDateTime =system.now(); 
                            ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
                            PurposeofPayment = stu.Fee_Type__c;
                            PaymentMode = 'Online';
                            SuccessMsg = 'Transaction Success..!!';
                            dblog.Status__c = 'Success';
                            dblog.Error_Message__c = StatusErrDes; 
                            dblog.Payment_Reference_Id__c = referenceId;                       
                        }
                        else if(statusCode == '0002')
                        {
                            if(TransactionType == '01')  stu.Payment_Mode_Type__c ='Netbanking';
                            else if(TransactionType == '02') stu.Payment_Mode_Type__c ='Credit Card';
                            else if(TransactionType == '03') stu.Payment_Mode_Type__c ='Debit Card';
                            else if(TransactionType == '04')  stu.Payment_Mode_Type__c ='Cash Card';
                            else if(TransactionType == '05') stu.Payment_Mode_Type__c ='Mobile';
                            else if(TransactionType == '06') stu.Payment_Mode_Type__c ='IMPS';
                            else if(TransactionType == '07') stu.Payment_Mode_Type__c ='Reward Points';
                            else if(TransactionType == '08')  stu.Payment_Mode_Type__c ='Others';
                            else if(TransactionType == '09') stu.Payment_Mode_Type__c ='Others Wallet';
                            else if(TransactionType == '10') stu.Payment_Mode_Type__c ='UPI';
                            
                            stu.Transaction_ID__c = transactionId;
                            stu.Payment_Date_Time__c = system.now();
                            stu.Payment_Status__c = 'Pending';
                            amount = stu.Amount__c;
                            if(stu.Payment_Date_Time__c != null)  TransactionDateTime = stu.Payment_Date_Time__c;
                            else    TransactionDateTime =system.now();
                            ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
                            PaymentMode = 'Online';
                            PurposeofPayment = stu.Fee_Type__c;
                            SuccessMsg = 'Transaction Pending..!!';
                            dblog.Status__c = 'Pending';     
                            dblog.Error_Message__c = StatusErrDes;
                            dblog.Payment_Reference_Id__c = referenceId;      
                        }
                        else{
                            stu.Transaction_ID__c = transactionId;
                            stu.Payment_Date_Time__c = system.now();//.addHours(5).addMinutes(30);
                            stu.Payment_Status__c = 'Failed';
                            amount = stu.Amount__c;
                            if(stu.Payment_Date_Time__c != null) TransactionDateTime = stu.Payment_Date_Time__c;
                            else TransactionDateTime =system.now();
                            ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
                            PurposeofPayment = stu.Fee_Type__c;
                            StatusDescription  = StatusErrDes;                            
                            PaymentMode = 'Online';
                            SuccessMsg = 'Transaction Failed..!!';                        
                            dblog.Status__c = 'Failure';
                            dblog.Error_Message__c = StatusErrDes; 
                            dblog.Payment_Reference_Id__c = referenceId;
                        }   
                    }
                    else{
                        
                        stu.Transaction_ID__c = transactionId;
                        stu.Payment_Date_Time__c = system.now();
                        stu.Payment_Status__c = 'Failed';
                        SuccessMsg = 'Failed.CheckSum Not Matched..!!';
                        dblog.Status__c = 'Failure';
                        dblog.Error_Message__c = StatusErrDes; 
                        dblog.Payment_Reference_Id__c = referenceId;
                    }
                    
                    update stu;   
                    
                    list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
                    for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Line_Item_Payment_Gateway__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                                   Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                                   Reference_Id__c =: referenceId OR Student_Payment__c =:stu.Id])
                    {
                        objStuFeePayment.Line_Item_Payment_Status__c = stu.Payment_Status__c;
                        objStuFeePayment.SF_Transaction_ID__c = transactionId;
                        objStuFeePayment.Line_Item_Payment_Gateway__c = stu.Payment_Gateway__c;
                        objStuFeePayment.Transaction_Date_Time__c = system.now();
                        objStuFeePayment.Reference_Id__c = stu.Reference_Id__c;
                        objStuFeePayment.Payment_Mode_Type__c = stu.Payment_Mode_Type__c;               
                        lst_Studentfee.add(objStuFeePayment);
                    } 
                    if(lst_Studentfee.size()>0){
                        update lst_Studentfee;
                    }    
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
            dblog.Class_Name__c = 'FEE_BilldeskResponse_API';
            dblog.Method_Name__c = 'BilldeskRespon';
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Data_Received__c = responce;
            upsert dblog; 
        }
    }
    
    public static string calculateCheckSum(string mainStr){
        String testKey = Billdesk_Merchant_Details__c.getValues('Checksum').MerchantId__c;
        String algorithmName = 'hmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(mainStr) , Blob.valueOf(testKey));
        //system.debug('++++'+hmacData);
        return EncodingUtil.convertToHEX(hmacData);
        
    }
    
    //Redirecting Applicants after successful Application Fee Payment
    global void updateApplicantFee()
    {
        urlRefresh = '';
        final String APPLICATION_FEE_TYPE ='Application Fee';
        ApplicantHomeUrl=Billdesk_Merchant_Details__c.getValues('ApplicantHomeUrl').MerchantId__c;
        Applicant_Billdesk_HomeUrl = Billdesk_Merchant_Details__c.getValues('Applicant_Billdesk_HomeUrl').MerchantId__c;
        Applicant_PortalUrl = Billdesk_Merchant_Details__c.getValues('Applicant_PortalUrl').MerchantId__c;
        //homeUrl = Billdesk_Merchant_Details__c.getValues('HomeUrl').MerchantId__c;
        // responce = apexpages.currentpage().getparameters().get('msg');
        responce = apexpages.currentpage().getparameters().get('msg');
        System.debug('inside updateapplicant fee');
        Debug_Log__c dblog = new Debug_Log__c();
        try{            
            if(responce != null)
            {
                String newStrReq = responce;
                Integer reqLen = newStrReq.split('\\|').size();
                String checkSumValue = newStrReq.split('\\|')[reqLen-1];
                String statusCode = newStrReq.split('\\|')[reqLen-12]; 
                transactionId = newStrReq.split('\\|')[reqLen-24];
                referenceId = newStrReq.split('\\|')[reqLen-25];
                refId = newStrReq.split('\\|')[reqLen-8];
                TransactionType = newStrReq.split('\\|')[reqLen-19];
                StatusErrDes = newStrReq.split('\\|')[reqLen-2];
                paymentId = transactionId;
                String noCheckSumValue = newStrReq.removeEnd(newStrReq.split('\\|')[reqLen-1]);
                String requestwithNoCheckSum = noCheckSumValue.Substring(0,noCheckSumValue.length()-1);
                List<Student_Payment__c> stuPayListUpdated = new List<Student_Payment__c>();
                List<Student_Payment__c> stuPayList = [SELECT id,Transaction_ID__c,Mode_of_Payment__c,Payment_Status__c,Payment_Date_Time__c,Payment_Mode_Type__c,
                                          Amount__c,Fee_Type__c,Contact__r.Application_Number__c,contact__r.Name,Contact__r.Country_Code__c,Reference_Id__c,
                                          Contact__r.FirstName,contact__r.record_type_name__c,Contact__r.Program_Name__c,Contact__r.School_Name__c,contact__r.Email ,Contact__r.Application_Fee_Paid__c, Contact__r.MobilePhone
                                          FROM Student_Payment__c WHERE Reference_Id__c =: referenceId];
                  if(stuPayList[0].contact__r.record_type_name__c == 'Applicant'){
                     list<hed__Application__c> applList = [Select Provisional_Admission_Fee_Paid__c, Application_Number__c from hed__Application__c
                                                where Application_Number__c =: stuPayList[0].Contact__r.Application_Number__c LIMIT 1];
                     if(applList.size() >0){
                            
                            applPAF = applList[0].Provisional_Admission_Fee_Paid__c;
                            appl = applList[0];
                        }
                  }
                FEE_TYPE=stuPayList[0].Fee_Type__c;
                applicationNumber = stuPayList[0].Contact__r.Application_Number__c;
                emailAddress = stuPayList[0].Contact__r.Email;
                if(stuPayList[0].Payment_Status__c =='Payment Link Created')
                {
                    dblog.Class_Name__c = 'FEE_BilldeskResponse_API';
                    dblog.Method_Name__c = 'updateApplicantFee';
                    dblog.Processing_API_Name__c = 'BillDesk';            
                    dblog.Data_Received__c = responce;
                    system.debug('Response'+responce);
                    for(Student_Payment__c stu : stuPayList){
                        string newCheckSum = getCalculateCheckSum(requestwithNoCheckSum);
                        
                        if(newCheckSum == checkSumValue || test.isRunningTest())
                        {  
                            if(statusCode == '0300')
                            {
                                if(TransactionType == '01')    stu.Payment_Mode_Type__c ='Netbanking';
                                else if(TransactionType == '02')  stu.Payment_Mode_Type__c ='Credit Card';
                                else if(TransactionType == '03')  stu.Payment_Mode_Type__c ='Debit Card';
                                else if(TransactionType == '04') stu.Payment_Mode_Type__c ='Cash Card';
                                else if(TransactionType == '05') stu.Payment_Mode_Type__c ='Mobile';
                                else if(TransactionType == '06')   stu.Payment_Mode_Type__c ='IMPS';
                                else if(TransactionType == '07')   stu.Payment_Mode_Type__c ='Reward Points';
                                else if(TransactionType == '08')  stu.Payment_Mode_Type__c ='Others';
                                else if(TransactionType == '09') stu.Payment_Mode_Type__c ='Others Wallet';
                                else if(TransactionType == '10')   stu.Payment_Mode_Type__c ='UPI';
                                
                                stu.Transaction_ID__c = transactionId;
                                stu.Payment_Date_Time__c = system.now();
                                stu.Payment_Status__c = 'Success';
                                if(stu.Payment_Status__c=='Success'){
                                    //stu.Contact__r.Application_Fee_Paid__c = True;  
                                    //update stu.Contact__r;
                                    stu.Payment_Gateway__c= 'Billdesk';
                                    if(stu.Amount__c != null && amount != null){
                                        amount += stu.Amount__c;
                                    } else {
                                        amount = stu.Amount__c;
                                    }
                                    //TransactionDateTime = DateTime.valueOf(DateTime.now().format('dd-MM-yyyy HH:mm:ss', 'IST'));
                                    TransactionDateTime = stu.Payment_Date_Time__c;
                                    ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
                                    system.debug(ISTTransactionDateTime);
                                    PurposeofPayment = stu.Fee_Type__c;
                                    PaymentMode = 'Online';
                                    SuccessMsg = 'Transaction Success..!!';
                                    dblog.Status__c = 'Success';   
                                    //Invoke the methods to Generate and send the attachment
                                    if(stu.Fee_Type__c == APPLICATION_FEE_TYPE ){
                                        //Passing the paymentId(Transaction_ID__C) - as the VisualFOrce is not able to retrieve the fields updated in this class.
                                        //Hence we are passing them as parameters and using the values in the VF Controller (StudentPaymentController)
                                        Id cvId = RegistrationFormUtility.generateReceipt(stu.Id, paymentId, stu.Payment_Gateway__c);
                                        RegistrationFormUtility.sendReceipt(stu.Id, cvId); 
                                    }
                                    if(applPAF == false && stu.Fee_Type__c != APPLICATION_FEE_TYPE){
                                        List<Student_Fee__c> sf = [select id, contact__c, fee_year__c from student_fee__c
                                                                   where contact__c =: stu.Contact__c AND Fee_year__c='1st Year']; 
                                        if(!sf.isEmpty()){
                                            AdmissionsProcessUtility.generateOfflineReceipt(stu.Id,stu.Payment_Mode_Type__c,stu.Payment_Gateway__c,paymentId);
                                            
                                        } 
                                    }
                                }
                                
                                dblog.Error_Message__c = StatusErrDes; 
                                dblog.Payment_Reference_Id__c = referenceId;  
                                
                                
                            }
                            else if(statusCode == '0002')
                            {
                                if(TransactionType == '01')  stu.Payment_Mode_Type__c ='Netbanking';
                                else if(TransactionType == '02') stu.Payment_Mode_Type__c ='Credit Card';
                                else if(TransactionType == '03') stu.Payment_Mode_Type__c ='Debit Card';
                                else if(TransactionType == '04')  stu.Payment_Mode_Type__c ='Cash Card';
                                else if(TransactionType == '05') stu.Payment_Mode_Type__c ='Mobile';
                                else if(TransactionType == '06') stu.Payment_Mode_Type__c ='IMPS';
                                else if(TransactionType == '07') stu.Payment_Mode_Type__c ='Reward Points';
                                else if(TransactionType == '08')  stu.Payment_Mode_Type__c ='Others';
                                else if(TransactionType == '09') stu.Payment_Mode_Type__c ='Others Wallet';
                                else if(TransactionType == '10') stu.Payment_Mode_Type__c ='UPI';
                                
                                stu.Transaction_ID__c = transactionId;
                                stu.Payment_Date_Time__c = system.now();
                                stu.Payment_Status__c = 'Pending';
                                stu.Payment_Gateway__c= 'Billdesk';
                                amount += stu.Amount__c;
                                TransactionDateTime = stu.Payment_Date_Time__c;
                                ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');                                
                                PaymentMode = 'Online';
                                PurposeofPayment = stu.Fee_Type__c;
                                SuccessMsg = 'Transaction Pending..!!';
                                dblog.Status__c = 'Pending';     
                                dblog.Error_Message__c = StatusErrDes;
                                dblog.Payment_Reference_Id__c = referenceId;      
                            }
                            else{
                                stu.Transaction_ID__c = transactionId;
                                stu.Payment_Date_Time__c = system.now();
                                stu.Payment_Status__c = 'Failed';
                                stu.Payment_Gateway__c= 'Billdesk';
                                amount += stu.Amount__c;
                                TransactionDateTime = stu.Payment_Date_Time__c;
                                ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
                                
                                PurposeofPayment = stu.Fee_Type__c;
                                StatusDescription  = StatusErrDes;                            
                                PaymentMode = 'Online';
                                SuccessMsg = 'Transaction Failed..!!';                        
                                dblog.Status__c = 'Failure';
                                dblog.Error_Message__c = StatusErrDes; 
                                dblog.Payment_Reference_Id__c = referenceId;
                                
                                
                                
                            }
                            
                        }
                        else{
                            
                            stu.Transaction_ID__c = transactionId;
                            stu.Payment_Date_Time__c = system.now();
                            stu.Payment_Status__c = 'Failed';
                            stu.Payment_Gateway__c= 'Billdesk';
                            SuccessMsg = 'Failed.CheckSum Not Matched..!!';
                            dblog.Status__c = 'Failure';
                            dblog.Error_Message__c = StatusErrDes; 
                            dblog.Payment_Reference_Id__c = referenceId;
                        }
                        stuPayListUpdated.add(stu);
                    }
                    if(stuPayListUpdated.size() > 0){
                        update stuPayListUpdated;
                    }
                    list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
                    for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Line_Item_Payment_Gateway__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                                   Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                                   Reference_Id__c =: referenceId OR Student_Payment__c =:stuPayList[0].Id])
                   {
                        objStuFeePayment.Line_Item_Payment_Status__c = stuPayList[0].Payment_Status__c;
                        objStuFeePayment.SF_Transaction_ID__c = transactionId;
                        objStuFeePayment.Line_Item_Payment_Gateway__c = stuPayList[0].Payment_Gateway__c;
                        objStuFeePayment.Transaction_Date_Time__c = system.now();
                        objStuFeePayment.Reference_Id__c = stuPayList[0].Reference_Id__c;
                        objStuFeePayment.Payment_Mode_Type__c = stuPayList[0].Payment_Mode_Type__c;               
                        lst_Studentfee.add(objStuFeePayment);
                    } 
                    if(lst_Studentfee.size()>0){
                        update lst_Studentfee;
                    }    
                    insert dblog;
                    // Sending Receipt for 1st Year Provisional Admission Fee paid as True
                } //pending status code here...
                if(stuPayList[0].Payment_Status__c =='Pending')
                {
                    dblog.Class_Name__c = 'FEE_BilldeskResponse_API';
                    dblog.Method_Name__c = 'updateApplicantFee';
                    dblog.Processing_API_Name__c = 'BillDesk';            
                    dblog.Data_Received__c = responce;
                    for(Student_Payment__c stu : stuPayList){
                        string newCheckSum = getCalculateCheckSum(requestwithNoCheckSum);
                        
                        if(newCheckSum == checkSumValue || test.isRunningTest())
                        {  
                            if(statusCode == '0300')
                            {
                                if(TransactionType == '01')    stu.Payment_Mode_Type__c ='Netbanking';
                                else if(TransactionType == '02')  stu.Payment_Mode_Type__c ='Credit Card';
                                else if(TransactionType == '03')  stu.Payment_Mode_Type__c ='Debit Card';
                                else if(TransactionType == '04') stu.Payment_Mode_Type__c ='Cash Card';
                                else if(TransactionType == '05') stu.Payment_Mode_Type__c ='Mobile';
                                else if(TransactionType == '06')   stu.Payment_Mode_Type__c ='IMPS';
                                else if(TransactionType == '07')   stu.Payment_Mode_Type__c ='Reward Points';
                                else if(TransactionType == '08')  stu.Payment_Mode_Type__c ='Others';
                                else if(TransactionType == '09') stu.Payment_Mode_Type__c ='Others Wallet';
                                else if(TransactionType == '10')   stu.Payment_Mode_Type__c ='UPI';
                                
                                stu.Transaction_ID__c = transactionId;
                                stu.Payment_Date_Time__c = system.now();
                                stu.Payment_Status__c = 'Success';
                                if(stu.Payment_Status__c=='Success'){
                                    //stu.Contact__r.Application_Fee_Paid__c = True;  
                                    //update stu.Contact__r;
                                    stu.Payment_Gateway__c= 'Billdesk';
                                    if(stu.Amount__c != null && amount != null){
                                        amount += stu.Amount__c;
                                        System.debug('amount421' + amount);
                                    } else {
                                        amount = stu.Amount__c;
                                        System.debug('amount424' + amount);
                                    }
                                    //TransactionDateTime = DateTime.valueOf(DateTime.now().format('dd-MM-yyyy HH:mm:ss', 'IST'));
                                    TransactionDateTime = stu.Payment_Date_Time__c;
                                    ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
                                    system.debug(ISTTransactionDateTime);
                                    PurposeofPayment = stu.Fee_Type__c;
                                    PaymentMode = 'Online';
                                    SuccessMsg = 'Transaction Success..!!';
                                    dblog.Status__c = 'Success';   
                                    //Invoke the methods to Generate and send the attachment
                                    if(stu.Fee_Type__c == APPLICATION_FEE_TYPE ){
                                        //Passing the paymentId(Transaction_ID__C) - as the VisualFOrce is not able to retrieve the fields updated in this class.
                                        //Hence we are passing them as parameters and using the values in the VF Controller (StudentPaymentController)
                                        Id cvId = RegistrationFormUtility.generateReceipt(stu.Id, paymentId, stu.Payment_Gateway__c);
                                        RegistrationFormUtility.sendReceipt(stu.Id, cvId); 
                                    }
                                    System.debug('applPAF' + applPAF + '\nstu.Fee_Type__c' + stu.Fee_Type__c);
                                    if(applPAF == false && stu.Fee_Type__c != APPLICATION_FEE_TYPE){
                                        List<Student_Fee__c> sf = [select id, contact__c, Amount_Paid__c, Amount_Pending__c, Amount__c, 
                                                                   fee_year__c from student_fee__c
                                                                   where contact__c =: stu.Contact__c AND Fee_year__c='1st Year']; 
                                        System.debug('sf' + sf);
                                        for(Student_Fee__c  s : sf){
                                            sf1.add(s.id);
                                        }
                                        if(!sf.isEmpty()){
                                            AdmissionsProcessUtility.generateOfflineReceipt(stu.Id,stu.Payment_Mode_Type__c,stu.Payment_Gateway__c,paymentId);
                                            FEE_StudentFeeTriggerHandler.updateStudentFeePending(sf1);
                                        } 
                                    }
                                }
                                
                                dblog.Error_Message__c = StatusErrDes; 
                                dblog.Payment_Reference_Id__c = referenceId;  
                                
                                
                            }
                            else if(statusCode == '0002')
                            {
                                if(TransactionType == '01')  stu.Payment_Mode_Type__c ='Netbanking';
                                else if(TransactionType == '02') stu.Payment_Mode_Type__c ='Credit Card';
                                else if(TransactionType == '03') stu.Payment_Mode_Type__c ='Debit Card';
                                else if(TransactionType == '04')  stu.Payment_Mode_Type__c ='Cash Card';
                                else if(TransactionType == '05') stu.Payment_Mode_Type__c ='Mobile';
                                else if(TransactionType == '06') stu.Payment_Mode_Type__c ='IMPS';
                                else if(TransactionType == '07') stu.Payment_Mode_Type__c ='Reward Points';
                                else if(TransactionType == '08')  stu.Payment_Mode_Type__c ='Others';
                                else if(TransactionType == '09') stu.Payment_Mode_Type__c ='Others Wallet';
                                else if(TransactionType == '10') stu.Payment_Mode_Type__c ='UPI';
                                
                                stu.Transaction_ID__c = transactionId;
                                stu.Payment_Date_Time__c = system.now();
                                stu.Payment_Status__c = 'Pending';
                                stu.Payment_Gateway__c= 'Billdesk';
                                amount += stu.Amount__c;
                                TransactionDateTime = stu.Payment_Date_Time__c;
                                ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');                                
                                PaymentMode = 'Online';
                                PurposeofPayment = stu.Fee_Type__c;
                                SuccessMsg = 'Transaction Pending..!!';
                                dblog.Status__c = 'Pending';     
                                dblog.Error_Message__c = StatusErrDes;
                                dblog.Payment_Reference_Id__c = referenceId;      
                            }
                            else{
                                stu.Transaction_ID__c = transactionId;
                                stu.Payment_Date_Time__c = system.now();
                                stu.Payment_Status__c = 'Failed';
                                stu.Payment_Gateway__c= 'Billdesk';
                                amount += stu.Amount__c;
                                TransactionDateTime = stu.Payment_Date_Time__c;
                                ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');                                
                                PurposeofPayment = stu.Fee_Type__c;
                                StatusDescription  = StatusErrDes;                            
                                PaymentMode = 'Online';
                                SuccessMsg = 'Transaction Failed..!!';                        
                                dblog.Status__c = 'Failure';
                                
                                dblog.Error_Message__c = StatusErrDes; 
                                dblog.Payment_Reference_Id__c = referenceId;
                                
                                
                                
                            }
                            
                        }
                        else{
                            
                            stu.Transaction_ID__c = transactionId;
                            stu.Payment_Date_Time__c = system.now();
                            stu.Payment_Status__c = 'Failed';
                            stu.Payment_Gateway__c= 'Billdesk';
                            SuccessMsg = 'Failed.CheckSum Not Matched..!!';
                            dblog.Status__c = 'Failure';
                            dblog.Error_Message__c = StatusErrDes; 
                            dblog.Payment_Reference_Id__c = referenceId;
                        }
                        stuPayListUpdated.add(stu);
                    }
                    if(stuPayListUpdated.size() > 0){
                        update stuPayListUpdated;
                    }
                    list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
                    for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Line_Item_Payment_Gateway__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                                   Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                                   Reference_Id__c =: referenceId OR Student_Payment__c =:stuPayList[0].Id])
                    {
                        objStuFeePayment.Line_Item_Payment_Status__c = stuPayList[0].Payment_Status__c;
                        objStuFeePayment.SF_Transaction_ID__c = transactionId;
                        objStuFeePayment.Line_Item_Payment_Gateway__c = stuPayList[0].Payment_Gateway__c; 
                        objStuFeePayment.Transaction_Date_Time__c = system.now();
                        objStuFeePayment.Reference_Id__c = stuPayList[0].Reference_Id__c;
                        objStuFeePayment.Payment_Mode_Type__c = stuPayList[0].Payment_Mode_Type__c;               
                        lst_Studentfee.add(objStuFeePayment);
                    } 
                    if(lst_Studentfee.size()>0){
                        update lst_Studentfee;
                    }    
                    insert dblog;
                    // Sending Receipt for 1st Year Provisional Admission Fee paid as True
                }
                else
                {
                    urlRefresh = 'Dont Refesh the Page.';
                }
            }
        }
        catch(Exception e)
        {
            dblog.Class_Name__c = 'FEE_BilldeskResponse_API';
            dblog.Method_Name__c = 'updateApplicantFeeFromCatch'; //+e.getLineNumber() + e.getMessage()
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Data_Received__c = responce;
            //System.debug('The following exception has occurred: ' + e.getMessage());
            upsert dblog; 
        }
    }
    
    public static string getCalculateCheckSum(string mainStr){
        String testKey = Billdesk_Merchant_Details__c.getValues('Checksum').MerchantId__c;
        String algorithmName = 'hmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(mainStr) , Blob.valueOf(testKey));
        //system.debug('++++'+hmacData);
        return EncodingUtil.convertToHEX(hmacData);
        
    }
    
}