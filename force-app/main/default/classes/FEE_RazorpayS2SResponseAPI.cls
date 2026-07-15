@RestResource(UrlMapping='/RazorpayS2SResponse/*')
global without sharing class FEE_RazorpayS2SResponseAPI { 
    static hed__Application__c appl;
    static list<hed__Application__c> applList;
    static boolean applPAF;
    
    @HttpPost
    global static void ReceivedData(){
        final String APPLICATION_FEE_TYPE ='Application Fee';
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_RazorpayS2SResponseAPI';
        dblog.Method_Name__c = 'ReceivedData';
        dblog.Processing_API_Name__c = 'RazorPay';
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        razorpayJSONparse wrpData = new razorpayJSONparse();
        List<Student_Payment__c> stuPayListUpdated = new List<Student_Payment__c>();
        try{
            // system.debug('+++++++++++++++++'+req);
            system.debug('+++++++++++++++++'+req.requestBody.toString());
            string jsonString = req.requestBody.toString();
            jsonString = jsonString.replace('"currency":', '"ccurrency":');
            dblog.Data_Received__c = jsonString;
            wrpData = razorpayJSONparse.parse(jsonString);              
            system.debug('+++++++++++++++++'+wrpData);
            system.debug('event+++++++++++++++++'+wrpData.event);
            if(wrpData.event == 'payment_link.paid'){
                system.debug('paymentLinkId+++++++++++++++++'+wrpData.payload.payment_link.entity.id);
                string PaymentLinkId = wrpData.payload.payment_link.entity.id;
                if(string.isNotBlank(PaymentLinkId)){
                    
                    List<Student_Payment__c> stuPayList = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
                                              Amount__c ,Razorpay_Signature__c,Payment_Mode_Type__c,Contact__r.Application_Fee_Paid__c,Contact__r.Primary_Academic_Program__r.name,
                                              Contact__r.Application_Number__c, contact__r.record_type_name__c,Contact__r.MobilePhone, Contact__r.Country_Code__c FROM Student_Payment__c WHERE Payment_Link_Id__c =: PaymentLinkId];
                    
                    if(stuPayList[0].contact__r.record_type_name__c == 'Applicant'){
                        
                        list<hed__Application__c> applList = [Select Provisional_Admission_Fee_Paid__c, Application_Number__c from hed__Application__c
                                                    where Application_Number__c =: stuPayList[0].Contact__r.Application_Number__c LIMIT 1];
                        if(applList.size() >0){
                            
                            applPAF = applList[0].Provisional_Admission_Fee_Paid__c;
                            
                            appl = applList[0];
                        }
                    }
                    // decimal Amount = stu.Amount__c;
                    system.debug('status+++++++++++++++++'+wrpData.payload.payment_link.entity.status);
                    system.debug('method+++++++++++++++++'+wrpData.payload.payment.entity.method);
                    for(Student_Payment__c stu : stuPayList){
                        if(wrpData.payload.payment_link.entity.status == 'paid'){
                            stu.Payment_Status__c = 'Success';
                        }
                        else{
                            stu.Payment_Status__c = 'Failed';
                        }
                        stu.Transaction_ID__c = wrpData.payload.payment.entity.id;
                        stu.Mode_of_Payment__c = 'Online';
                        stu.Payment_Date_Time__c = system.now();
                        //  stu.Razorpay_Signature__c = razorPay_Sign;
                        stu.Payment_Gateway__c = 'Razorpay';
                        stu.Payment_Mode_Type__c = wrpData.payload.payment.entity.method;
                        if(stu.Payment_Status__c == 'Success' && stu.Fee_Type__c == APPLICATION_FEE_TYPE && stu.Contact__r.Application_Fee_Paid__c == false){
                        
                            //Passing the paymentId(Transaction_ID__C) - as the VisualFOrce is not able to retrieve the fields updated in this class.
                            //Hence we are passing them as parameters and using the values in the VF Controller (StudentPaymentController)
                            Id cvId = RegistrationFormUtility.generateReceipt(stu.Id, stu.Transaction_ID__C, stu.Payment_Gateway__c);
                            RegistrationFormUtility.sendReceipt(stu.Id, cvId); 
                        }  
                        if(applPAF == false && stu.Payment_Status__c == 'Success' && stu.Fee_Type__c != APPLICATION_FEE_TYPE){
                            system.debug('PAF method');
                            List<Student_Fee__c> sf = [select id, contact__c, fee_year__c from student_fee__c
                                                       where contact__c =: stu.Contact__c AND Fee_year__c='1st Year']; 
                            if(!sf.isEmpty()){
                                
                                AdmissionsProcessUtility.generateOfflineReceipt(stu.Id,stu.Payment_Mode_Type__c,stu.Payment_Gateway__c,stu.Transaction_ID__c );
                                
                            } 
                        }
                        stuPayListUpdated.add(stu);
                    }
                    if(stuPayListUpdated.size() > 0){
                        update stuPayListUpdated;
                    }
                   
                    

                    
                    
                    
                    list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
                    for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Line_Item_Payment_Gateway__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                                   Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                                   Payment_Link_Id__c =: PaymentLinkId])
                    { 
                        if(wrpData.payload.payment_link.entity.status == 'paid')
                            objStuFeePayment.Line_Item_Payment_Status__c = 'Success';
                        else 
                            objStuFeePayment.Line_Item_Payment_Status__c = 'Failed';
                        objStuFeePayment.Line_Item_Payment_Gateway__c = 'Razorpay';
                        objStuFeePayment.SF_Transaction_ID__c = wrpData.payload.payment.entity.id;
                        objStuFeePayment.Payment_Mode_Type__c = wrpData.payload.payment.entity.method;
                        //objStuFeePayment.Amount__c = 
                        objStuFeePayment.Transaction_Date_Time__c = system.now();
                        lst_Studentfee.add(objStuFeePayment);
                    }
                    
                    if(lst_Studentfee.size()>0){
                        
                        update lst_Studentfee; 
                        
                    }
                    
                    if(wrpData.payload.payment_link.entity.status =='paid'){
                        dblog.Status__c = 'Success';
                    }
                    else{
                        dblog.Status__c = 'Failure';
                    }
                    insert dblog;
                    // Sending Receipt for 1st Year Provisional Admission Fee paid as True
                    
                    
                }
            }
            
            if(wrpData.event == 'payment.failed'){
                string refId = wrpData.payload.payment.entity.notes.reference_id;
                system.debug('refId failed'+refId);
                List<Student_Payment__c> stuList = new List<Student_Payment__c>();
                for (Student_Payment__c stu : [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
                                            Amount__c ,Razorpay_Signature__c,Payment_Mode_Type__c FROM Student_Payment__c WHERE Reference_Id__c =: refId]) {
                    system.debug('Student_Payment__c '+stu);
                    // decimal Amount = stu.Amount__c;
                    stu.Payment_Status__c = 'Failed';
                    stu.Transaction_ID__c = wrpData.payload.payment.entity.id;
                    stu.Mode_of_Payment__c = 'Online';
                    stu.Payment_Date_Time__c = system.now();
                    stu.Payment_Gateway__c = 'Razorpay';
                    stu.Payment_Mode_Type__c = wrpData.payload.payment.entity.method;
                    stuList.add(stu);
                } 
                if(stuList.size() > 0){
                    update stuList;
                }                        
                list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
                for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Line_Item_Payment_Gateway__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
                                                               Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
                                                               Reference_Id__c =: refId])
                {
                    objStuFeePayment.Line_Item_Payment_Status__c = 'Failed';                        
                    objStuFeePayment.SF_Transaction_ID__c = wrpData.payload.payment.entity.id;
                    objStuFeePayment.Payment_Mode_Type__c = wrpData.payload.payment.entity.method;
                    objStuFeePayment.Transaction_Date_Time__c = system.now();
                    objStuFeePayment.Line_Item_Payment_Gateway__c = 'Razorpay';
                    lst_Studentfee.add(objStuFeePayment);
                }
                if(lst_Studentfee.size()>0){
                    update lst_Studentfee; 
                }
                
                dblog.Status__c = 'Failure';
                insert dblog;
            }
            
        }
        catch(Exception Ex){
            system.debug('catch+++++++++'+string.valueof(ex));
            dblog.Status__c = 'Failure';
            dblog.Error_Message__c = string.valueof(Ex);
            upsert dblog;
        }
    }
    
    
}