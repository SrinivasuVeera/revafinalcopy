//@RestResource(urlMapping='/RazorPayResponse/*')
//https://revauniversity9--revadev.my.salesforce.com/services/apexrest/RazorPayResponse
global class FEE_RazorPayResponse_API {
    global string PaymentId {get;set;}
    global string PaymentLinkId {get;set;}
    global string Status {get;set;}
    global string StatusMsg {get;set;}
    global string razorPay_Sign {get;set;}
    global Decimal Amount {get;set;}
    global string homeUrl{get;set;}
    global string PaymentMode{get;set;}
    global String PurposeofPayment{get;set;}
    global DateTime TransactionDateTime{get;set;}
    global string Applicant_HomeUrl{get;set;}
    global string ISTTransactionDateTime{get;set;}
    global string FEE_TYPE{get;set;}
    global final String SMS_TYPE ='Application_Number';
    global final String APPLICATION_FEE_TYPE ='Application Fee';
    global string Applicant_PortalUrl{get;set;}
    global String applicationNumber{get;set;}
    global String emailAddress{get;set;}
    global String ReferenceId{get;set;}

     global void updateStudentFee(){
    
        homeUrl = Razorpay_Details__c.getValues('HomeUrl').Value__c;  
        PaymentId = apexpages.currentpage().getparameters().get('razorpay_payment_id');
        PaymentLinkId = apexpages.currentpage().getparameters().get('razorpay_payment_link_id');
        Status = apexpages.currentpage().getparameters().get('razorpay_payment_link_status');
        razorPay_Sign = apexpages.currentpage().getparameters().get('razorpay_signature');
        ReferenceId = apexpages.currentpage().getparameters().get('razorpay_payment_link_reference_id');
       
        Student_Payment__c stu = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Payment_Date_Time__c,Reference_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
                                  Amount__c ,Razorpay_Signature__c FROM Student_Payment__c WHERE Payment_Link_Id__c =: PaymentLinkId];
        
        Amount = stu.Amount__c;
        if(Status =='paid')
        {
            stu.Payment_Status__c = 'Success';
            PaymentMode = 'Online';
            StatusMsg = 'Transaction Success..!!';
        }      
        else
        {
            stu.Payment_Status__c = 'Failed';  
            PaymentMode = 'Online';
            StatusMsg = 'Transaction Failed..!!';
        }    
        stu.Transaction_ID__c = PaymentId;
        stu.Mode_of_Payment__c = 'Online';
        //stu.Payment_Date_Time__c = system.now();
        stu.Razorpay_Signature__c = razorPay_Sign;
        stu.Payment_Gateway__c = 'Razorpay';
         PurposeofPayment = stu.Fee_Type__c;
         TransactionDateTime = stu.Payment_Date_Time__c;
         if(stu.Fee_Type__c == 'Hostel Fee' || stu.Fee_Type__c == 'Hostel Fee,'){              
             update stu;
         }
         
       // update stu;
        list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
        for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Line_Item_Payment_Gateway__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                       Student_Payment__c,Transaction_Date_Time__c,Student_Payment__r.Reference_Id__c,Student_Payment__r.Mode_of_Payment__c from Student_Fee_Payment__c  where
                                                       Payment_Link_Id__c =: PaymentLinkId])
        {
            if(Status =='paid')
                objStuFeePayment.Line_Item_Payment_Status__c = 'Success';
            else 
                objStuFeePayment.Line_Item_Payment_Status__c = 'Failed';
            
            objStuFeePayment.Reference_Id__c = objStuFeePayment.Student_Payment__r.Reference_Id__c;
            objStuFeePayment.Mode_of_Payment__c = objStuFeePayment.Student_Payment__r.Mode_of_Payment__c;
            objStuFeePayment.SF_Transaction_ID__c = PaymentId;
            objStuFeePayment.Line_Item_Payment_Gateway__c = 'Razorpay';
            objStuFeePayment.Transaction_Date_Time__c = system.now();
            lst_Studentfee.add(objStuFeePayment);
        }
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_RazorPayResponse_API';
        dblog.Method_Name__c = 'updateStudentFee';
        dblog.Processing_API_Name__c = 'RazorPay';            
        dblog.Data_Received__c = 'PaymentId='+PaymentId+'&PaymentLinkId='+PaymentLinkId+'&Status='+Status+'&razorPay_Sign='+razorPay_Sign;
        if(Status =='paid'){
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
        if(string.isNotBlank(PaymentId) && string.isNotBlank(PaymentLinkId)){
            FEE_RazorpayGetPaymentApi.ReceivedData(PaymentLinkId,PaymentId);
        }    
    }
    
    //Redirecting Applicants after successful Application Fee Payment
    global void updateApplicantFee(){
        
        Applicant_HomeUrl = Razorpay_Details__c.getValues('Applicant_HomeUrl').Value__c;
        Applicant_PortalUrl = Razorpay_Details__c.getValues('Applicant_PortalUrl').Value__c;
        system.debug('-->'+Applicant_HomeUrl) ;
        PaymentId = apexpages.currentpage().getparameters().get('razorpay_payment_id');
        PaymentLinkId = apexpages.currentpage().getparameters().get('razorpay_payment_link_id');
        Status = apexpages.currentpage().getparameters().get('razorpay_payment_link_status');
        razorPay_Sign = apexpages.currentpage().getparameters().get('razorpay_signature');
        List<Student_Payment__c> stuPayListUpdated = new List<Student_Payment__c>();
        Amount = 0;
        List<Student_Payment__c> stuPayList = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,Contact__r.Country_Code__c,Name,
                                                Amount__c ,Razorpay_Signature__c,Contact__r.Application_Number__c,contact__r.Name,
                                                Contact__r.FirstName,Contact__r.Program_Name__c,Contact__r.School_Name__c,contact__r.Email ,Contact__r.Application_Fee_Paid__c, Contact__r.MobilePhone
                                                FROM Student_Payment__c WHERE Payment_Link_Id__c =: PaymentLinkId]; 
        
        if(stuPayList.size() > 0)
        {
            // Amount = varStudentPayment.Amount__c;
            for(Student_Payment__c varStudentPayment : stuPayList){
                Amount += varStudentPayment.Amount__c;
                FEE_TYPE=varStudentPayment.Fee_Type__c;
                applicationNumber = varStudentPayment.Contact__r.Application_Number__c;
                emailAddress = varStudentPayment.Contact__r.Email;
                if(Status =='paid')
                {
                    varStudentPayment.Payment_Status__c = 'Success';
                    PaymentMode = 'Online';
                    StatusMsg = 'Transaction Success';
                    System.debug('varStudentPayment-->' + varStudentPayment.Contact__r);
                    System.debug('varStudentPayment.Contact__r.Application_Fee_Paid__c-->' + varStudentPayment.Contact__r.Application_Fee_Paid__c); 

                }      
                else
                {
                    varStudentPayment.Payment_Status__c = 'Failed';  
                    PaymentMode = 'Online';
                    StatusMsg = 'Transaction Failed';
                }    
                varStudentPayment.Transaction_ID__c = PaymentId;
                varStudentPayment.Mode_of_Payment__c = 'Online';
                varStudentPayment.Payment_Date_Time__c = system.now();
                varStudentPayment.Razorpay_Signature__c = razorPay_Sign;
                varStudentPayment.Payment_Gateway__c = 'Razorpay';
                PurposeofPayment = varStudentPayment.Fee_Type__c;
                TransactionDateTime = varStudentPayment.Payment_Date_Time__c;
                ISTTransactionDateTime = TransactionDateTime.format('dd-MM-yyyy HH:mm:ss', 'IST');
                stuPayListUpdated.add(varStudentPayment);
            }
            if(stuPayListUpdated.size() > 0){
                update stuPayListUpdated;
            }
            //String dtIST = dt.format('dd-MM-yyyy HH:mm:ss', 'IST');
           // update varStudentPayment;
        }
        
         
        list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
        for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Line_Item_Payment_Gateway__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                       Student_Payment__c,Transaction_Date_Time__c,Student_Payment__r.Reference_Id__c,Student_Payment__r.Mode_of_Payment__c from Student_Fee_Payment__c  where
                                                       Payment_Link_Id__c =: PaymentLinkId])
        {
            if(Status =='paid')
                objStuFeePayment.Line_Item_Payment_Status__c = 'Success';
            else 
                objStuFeePayment.Line_Item_Payment_Status__c = 'Failed';
            
            objStuFeePayment.Reference_Id__c = objStuFeePayment.Student_Payment__r.Reference_Id__c;
            objStuFeePayment.Mode_of_Payment__c = objStuFeePayment.Student_Payment__r.Mode_of_Payment__c;
            objStuFeePayment.SF_Transaction_ID__c = PaymentId;
            objStuFeePayment.Transaction_Date_Time__c = system.now();
            objStuFeePayment.Line_Item_Payment_Gateway__c = 'Razorpay';
            lst_Studentfee.add(objStuFeePayment);
        }
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_RazorPayResponse_API';
        dblog.Method_Name__c = 'updateStudentFee';
        dblog.Processing_API_Name__c = 'RazorPay';            
        dblog.Data_Received__c = 'PaymentId='+PaymentId+'&PaymentLinkId='+PaymentLinkId+'&Status='+Status+'&razorPay_Sign='+razorPay_Sign;
        if(Status =='paid'){
            dblog.Status__c = 'Success';
        }
        else{
            dblog.Status__c = 'Failure';
        }
        insert dblog;
        // dblog.Response__c = res.getBody();
        // dblog.User_Id__c = UserInfo.getUserId(); 
        if(lst_Studentfee.size()>0){
         //  update lst_Studentfee; 
        }
        if(string.isNotBlank(PaymentId) && string.isNotBlank(PaymentLinkId)){
            FEE_RazorpayGetPaymentApi.ReceivedData(PaymentLinkId,PaymentId);
        }
        
        
    }
    
}