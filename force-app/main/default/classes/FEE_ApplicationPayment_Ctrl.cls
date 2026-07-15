public without sharing class FEE_ApplicationPayment_Ctrl 
{
    public static final String CONST_APPLICATION_FEE = 'Application Fee';
    // public static final String CONST__TUITION_FEE = 'Tuition Fee';
    // public static final String CONST__UNIVERSITY_FEE = 'University Fee';
    public static final String CONST_APPLICANTPORTAL_NAME = 'Application_Portal_Name';
    public static final String CONST_ADMIN_PROFILE = 'System Administrator';
    
    public static String getPortalName() {
        return [select Text_Value__c from General_Setting__mdt where DeveloperName = :CONST_APPLICANTPORTAL_NAME limit 1].Text_Value__c;
    }
    //This method displays only the 'Application Fee' for the Contact
    @AuraEnabled
    public static StudentFeeWrapper displayApplicantFeeRecords(String flowConId, Boolean isPAF, String stupayId)
    {
        String profileId = userInfo.getProfileId();
        profile guestName = [Select Name from profile where id=: profileId];
        string guestUserProfileName=(guestName.Name);
        StudentFeeWrapper stuWrap = new StudentFeeWrapper();
        List<Profile> idGuestProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = idGuestProfile[0].Name;
        
        System.debug('profileName-->' + guestUserProfileName);
        //  String varApplicationFee = 'Application Fee';
        System.debug('PName-->' + guestUserProfileName);
        System.debug('flowConId-->' + flowConId);
        System.debug('guestUserProfileName-->' + guestUserProfileName);
        Decimal totalPendingOnlineAmount = 0;
        if(profileName == guestUserProfileName || profileName == CONST_ADMIN_PROFILE )
        {    for(Student_Payment__c objStuPay : [select Id,Name,Amount__c,Payment_Mode_Type__c, Contact__c,Description__c,Fee_Type__c,Mode_of_Payment__c,Offline_Receipt_Number__c,Online_Receipt_Number1__c,
                            Payment_Date_Time__c,Payment_Link_Id__c,Payment_Url__c,Payment_Gateway__c,Program_Enrollment__c,Razorpay_Signature__c,Payment_Status__c,
                            Transaction_ID__c from Student_Payment__c where Payment_Status__c !=: 'Payment Link Created' AND Contact__c =: flowConId Order by Createddate DESC]) {
                // if((objStuPay.Payment_Status__c == 'Pending'|| objStuPay.Payment_Status__c == 'Failed')  && objStuPay.Mode_of_Payment__c =='Online' && objStuPay.Payment_Mode_Type__c == 'Online'){
                //     totalPendingOnlineAmount += objStuPay.Amount__c;
                // }
                stuWrap.lst_StuPaymentDetails.add(objStuPay);
            }
            if(isPAF == true){
                Student_Payment__c stupay = [SELECT Id,Name,Amount__c, Contact__c, Payment_Status__c FROM Student_Payment__c WHERE Id =:stupayId];
                stuWrap.DirectLinkPayment = (stupay.Payment_Status__c == 'Pending' || stupay.Payment_Status__c == 'Failed' || stupay.Payment_Status__c != 'Success') ? stupay.Amount__c : 0;
                stuWrap.isPAF = true;
            } else {
                System.debug('InsideIf-->');  
                //Query Fee record of the contact where Fee Type is 'Application fee'                          
                for(Student_Fee__c objStuFee : [select id,Name,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Application_Number__c,
                                                Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                                Course_Name_Course_Code__c,Program_Enrollment__c,Description__c,Due_Date__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,
                                                Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                                Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c
                                                from Student_Fee__c where Contact__c =: flowConId AND Fee_Type__c =: CONST_APPLICATION_FEE order by Due_Date__c asc]) 
                {
                    System.debug('InsideFor-->');
                    CheckboxWrapper checkWrap = new CheckboxWrapper();
                    if(objStuFee.Name != null)
                        stuWrap.objStuname =objStuFee.Name;
                    if(objStuFee.Contact__r.Application_Number__c != null)
                        stuWrap.objAppNumber=objStuFee.Contact__r.Application_Number__c;
                    if(objStuFee.Contact__r.SRN_Number__c != null)
                        stuWrap.objSrnNumber=objStuFee.Contact__r.SRN_Number__c;                 
                    if(objStuFee.Amount_Pending__c != null && objStuFee.Amount_Pending__c > 0)
                    {
                        checkWrap.ObjStuFeeDeatils = objStuFee;                    
                        stuWrap.lst_CheckboxWrap.add(checkWrap);
                    }
                    if(objStuFee.Amount_Pending__c == 0)
                    {
                        stuWrap.lst_StuPaidDetails.add(objStuFee);
                    }
                }
                
                Contact checkPUCContact = [SELECT Id, PUCDriveStudent__c FROM Contact WHERE Id =: flowConId LIMIT 1];
                if(checkPUCContact.PUCDriveStudent__c != null)
                {
                    stuWrap.isPUCContact = checkPUCContact.PUCDriveStudent__c;
                }
            }
        }
        return stuWrap;
    }

    //This method fetches the Application Fee record details on click of 'Make Payment' button
    @AuraEnabled
    public static StudentFeeRecWrapper fetchProvisionalAdmissionFeeRecords(string flowConId)
    {
        // system.debug('++++++++++'+strSelId);
        StudentFeeRecWrapper stuWrap = new StudentFeeRecWrapper();
        List<Student_Fee__c> stufeeList = new List<Student_Fee__c>();
        // String varApplicationFee = 'Application Fee';
        if(flowConId != null)
        {   
            for(Student_Fee__c objStuFee : [select id,Name,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Application_Number__c,
                                            Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                            Course_Name_Course_Code__c,Description__c,Due_Date__c,Program_Enrollment__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,
                                            Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                            Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c
                                            from Student_Fee__c where Contact__c =: flowConId AND (Fee_Type__c ='Tuition Fee' OR Fee_Type__c ='University Fee' or Fee_Type__c = 'Guest House Fee' or Fee_Type__c = 'Missed Meal Fee') ORDER BY Due_Date__c asc])
            {
                
                if(objStuFee.Fee_Type__c == objStuFee.Fee_Payment_Criteria__r.Fee_Type__c)
                {
                    stuWrap.StuFeeType = objStuFee.Fee_Type__c;
                    if(objStuFee.Number_of_Installments__c  != null && objStuFee.Paid_Installments__c != null)
                        stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c;
                    stuWrap.PendingAmount = objStuFee.Amount_Pending__c;
                    
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Full Payment')  stuWrap.lst_StuFeePayment.add(objStuFee);
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Partial Payment') stuWrap.lst_StuFeePayment.add(objStuFee);
                    
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('RazorPay','RazorPay');
                    }
                    // if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Paytm__c != null)
                    // {
                    //     stuWrap.map_PaymentGateway.put('PayTM','PayTM');
                    // }
                    // // if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c != null)
                    // // {
                    // //     stuWrap.map_PaymentGateway.put('EazyPay','EazyPay');
                    // // }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('BillDesk','BillDesk');
                    }                    
                    stufeeList.add(objStuFee);
                } 
                         
            }
        }
        stuWrap.lst_StuFeePayment = stufeeList;
        System.debug(stuWrap);
        return stuWrap; 
    }  

    //This method fetches the Application Fee record details on click of 'Make Payment' button
    @AuraEnabled
    public static StudentFeeRecWrapper fetchApplicantFeeRecords(Id strSelId, string flowConId)
    {
        system.debug('++++++++++'+strSelId);
        StudentFeeRecWrapper stuWrap = new StudentFeeRecWrapper();
        
        // String varApplicationFee = 'Application Fee';
        if(flowConId != null)
        {   
            for(Student_Fee__c objStuFee : [select id,Name,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Application_Number__c,
                                            Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                            Course_Name_Course_Code__c,Description__c,Due_Date__c,Program_Enrollment__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,
                                            Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                            Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c
                                            from Student_Fee__c where id=:strSelId and Contact__c =: flowConId AND Fee_Type__c =: CONST_APPLICATION_FEE order by Due_Date__c asc])
            {
                
                if(objStuFee.Fee_Type__c == objStuFee.Fee_Payment_Criteria__r.Fee_Type__c)
                {
                    stuWrap.StuFeeType = objStuFee.Fee_Type__c;
                    if(objStuFee.Number_of_Installments__c  != null && objStuFee.Paid_Installments__c != null)
                        stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c;
                    stuWrap.PendingAmount = objStuFee.Amount_Pending__c;
                    
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Full Payment')  stuWrap.lst_StuFeePayment.add(objStuFee);
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Partial Payment') stuWrap.lst_StuFeePayment.add(objStuFee);
                    
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('RazorPay','RazorPay');
                    }
                    // if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Paytm__c != null)
                    // {
                    //     stuWrap.map_PaymentGateway.put('PayTM','PayTM');
                    // }
                    // // if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c != null)
                    // // {
                    // //     stuWrap.map_PaymentGateway.put('EazyPay','EazyPay');
                    // // }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('BillDesk','BillDesk');
                    }                    
                }            
            }
        }
        return stuWrap; 
    }   
     
    //This method is used on click of 'Pay Now' button for the RazorPay PG
    @AuraEnabled
    public static rezorpayResponseCall razorPayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType, string flowConId)
    {
        string name = '';
        decimal totAmt = PartialAmount;
        string email = '';
        string mobile = '';
        string discription = '';
        string contactId = '';
        string ProgEnrollId='';
        string RefId = Utility.generateRandomNumber();
        list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        //  map<string,string> mapStuFee = new map<string,string>();
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            //totAmt = totAmt + fee.Amount_Pending__c;
            name = fee.Contact__r.Name;
            email = fee.Contact__r.Email;
            if(fee.Contact__r.MobilePhone != null && fee.Contact__r.MobilePhone.indexOf('-') > -1){
               mobile = fee.Contact__r.MobilePhone.substring(fee.Contact__r.MobilePhone.indexOf('-')+1);
            } else {
                mobile = fee.Contact__r.MobilePhone;
            }
            discription = discription + fee.Fee_Type__c;
            contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;         
            //    mapStuFee.put(fee.Fee_Type__c,fee.Id);
        }
        Student_Payment__c objStuFeePay = new Student_Payment__c();
        objStuFeePay.Amount__c = totAmt;
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        objStuFeePay.Mode_of_Payment__c = 'Online';
        objStuFeePay.Payment_Date_Time__c = system.now();
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        lstStuPayment.add(objStuFeePay);
        
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        
        if(lstStuPayment.size() > 0){
            
            razorPayRequestCall rq = new razorPayRequestCall();
            string amt = string.valueof(totAmt.round(System.RoundingMode.HALF_DOWN));
            amt = amt + '00';
            rq.ramount = decimal.valueof(amt);
            rq.rcurrency = 'INR';
            rq.accept_partial = false;
            
            //rq.first_min_partial_amount = 100;
                       // Example Unix timestamp
            Integer targetTimestamp = 1992405004;
            
            // Get the current Unix timestamp
            Datetime now = Datetime.now();
            Integer currentTimestamp = (Integer)now.getTime() / 1000;
            
            // Calculate the difference between current timestamp and target timestamp
            Integer timestampDifference = targetTimestamp + currentTimestamp;
            
            // Update rq.expire_by with the calculated timestamp difference
            rq.expire_by = timestampDifference;
            
            // Display the updated rq.expire_by value
            System.debug('Updated rq.expire_by value: ' + rq.expire_by);

            
            
            rq.reference_id = RefId;
            //  rq.reference_id = 'Ref-0002';
            rq.description = discription;
            rq.reminder_enable = true;
            rq.callback_url = Razorpay_Details__c.getValues('Applicant_CallbackUrl').Value__c;
            rq.callback_method = 'get';
            
            customerWrp cw = new customerWrp();
            cw.name = name;
            cw.contact = Mobile;
            cw.email = email;
            rq.customer = cw;
            
            notifyWrp nw = new notifyWrp();
            nw.sms = true;
            nw.email=true;
            rq.notify = nw;
            
            notesWrp nt = new notesWrp();
            nt.paymentType = 'FeePayment';
            rq.notes = nt;
            
            string jsonbody = json.serialize(rq);
            jsonbody = jsonbody.replace('"rcurrency"', '"currency"');
            jsonbody = jsonbody.replace('"ramount"', '"amount"'); 
            
            string endpoint = Razorpay_Details__c.getValues('Razorpay Endpoint').Value__c; 
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json'); 
            req.setBody(jsonbody);
            //System.debug('+++++++++++++'+jsonbody);
            String username = Razorpay_Details__c.getValues('UserName').Value__c;
            String password = Razorpay_Details__c.getValues('Password').Value__c;
            
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);                 
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resBody = res.getBody();
            System.debug('++++resBody++++++++'+res.getBody());
            system.debug('====status code===='+res.getStatusCode());
            
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_ApplicationPayment_Ctrl';
            dblog.Method_Name__c = 'razorPayGenratePaymentLink';
            dblog.Processing_API_Name__c = 'RazorPay';            
            dblog.Request__c = req.getBody();
            dblog.Response__c = res.getBody();
            dblog.User_Id__c = UserInfo.getUserId();
            
            // Check if payment transaction is successful
            if(res.getStatusCode() == 200)
            {   
                System.debug('Status200 Success-->');
                System.debug('flowConId-->' + flowConId);
                reswrap =  (rezorpayResponseCall)System.JSON.deserialize(resBody, rezorpayResponseCall.class);
                reswrap.statusCode = res.getStatusCode();              
                
                list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
                // for(Student_Payment__c sp : lstStuPayment){
                objStuFeePay.Payment_Link_Id__c = reswrap.id;
                objStuFeePay.Payment_Url__c = reswrap.short_url;
                objStuFeePay.Payment_Status__c = 'Payment Link Created';
                objStuFeePay.Payment_Gateway__c = 'RazorPay';
                //}
                insert objStuFeePay; // Create the Student Payment Record
                for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                    Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();   
                    // if(feeType == 'single'){                 
                    //     sfp.Amount__c = totAmt;
                    // }
                    // else{
                    //     sfp.Amount__c = objstuFee.Amount_Pending__c;
                    // }
                    sfp.Mode_of_Payment__c = 'Online';
                    sfp.Payment_Link_Id__c = reswrap.id;
                    sfp.Student_Fee__c =  objstuFee.id;   //mapStuFee.get(objstuFee.Fee_Type__c);
                    sfp.Student_Payment__c = objStuFeePay.id;
                    sfp.Amount__c = objStuFeePay.Amount__c;
                    sfp.Line_Item_Payment_Gateway__c = 'Razorpay';
                    sfp.Line_Item_Payment_Status__c='';
                    sfp.Reference_Id__c = RefId;
                    lstSfp.add(sfp);
                }
                //system.debug('==lstStuPayment==='+lstStuPayment);
                insert lstSfp; // Create the Student Fee Payment record and link it to the above inserted Student Payment record
                /*   if(flowConId != null){
Contact varConUpdate = [Select id, Application_Fee_Paid__c from Contact where id =:flowConId];
varConUpdate.Application_Fee_Paid__c = True;
update varConUpdate;
System.debug('varConUpdate-->' + varConUpdate);
System.debug('varConUpdate.Application_Fee_Paid__c-->' + varConUpdate.Application_Fee_Paid__c);
} */
                // system.debug('===after insert==='+lstSfp);
                dblog.Status__c = 'Success';
            }
            else{
                reswrap.statusCode = res.getStatusCode();
                dblog.Status__c = 'Failure';
            }
            insert dblog;
        }
        //system.debug('===reswrap==='+reswrap);
        return reswrap;
    }    
    
    //This method is used on click of 'Pay Now' button for the BillDeskPay PG 
    //Application Fee Payment
    
    @AuraEnabled
    public static rezorpayResponseCall BillDeskPayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType,string flowConId)
    {
        System.debug('INSIDE BillDeskPayGenratePaymentLink');
        System.debug('lst_StuFeeDeatils =' + lst_StuFeeDeatils);
        System.debug('PartialAmount=' + PartialAmount);
        System.debug('feeType=' + feeType);
        
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        string Name = '';
        decimal totAmt = PartialAmount;
        string email = '';
        string mobile = '';
        string mobilevalue = '';
        string contactId = '';
        string studentUniqueId = '';
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();
        list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            Name = fee.Contact__r.Name;
            
            if(string.isNotBlank(fee.Contact__r.Email)){
                email = fee.Contact__r.Email;
            }
            else{
                email = 'NA';
            }
            if(string.isNotBlank(fee.Contact__r.MobilePhone)){
                mobile = fee.Contact__r.MobilePhone;
            }
            else{
                mobile = 'NA';
            }
            mobilevalue=mobile.remove('+').remove('-');
            contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;  
            discription = discription + fee.Fee_Type__c;    
            studentUniqueId = fee.Contact__r.Application_Number__c;  
            if(string.isNotBlank(studentUniqueId)){ 
                studentUniqueId = studentUniqueId.replaceAll('[^a-zA-Z0-9\\s+]', '');
            }
            else{
                studentUniqueId = 'NA';
            }
        }
        
        Student_Payment__c objStuFeePay = new Student_Payment__c();
        objStuFeePay.Amount__c = totAmt;
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        //  objStuFeePay.Mode_of_Payment__c = 'Online';
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        lstStuPayment.add(objStuFeePay);
        
        if(lstStuPayment.size() > 0){
            string str = '<TXNDATA><TXNSUMMARY><REQID>PGECOM201</REQID><PGMERCID>'+
                Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+
                '</PGMERCID>';
            str += '<RECORDS>'+lst_StuFeeDeatils.size()+'</RECORDS>';
            str += '<PGCUSTOMERID>'+RefId+'</PGCUSTOMERID>';
            str += '<AMOUNT>'+totAmt+'.00</AMOUNT>';
            dateTime dt = system.now();
            string strDt =string.valueof(dt);
            String newStrDt = strDt.replaceAll('[^0-9]', '');
            str += '<TXNDATE>'+newStrDt+'</TXNDATE></TXNSUMMARY>';
            System.debug('str= ' + str);
            integer count = 1;
            //system.debug('++++++++'+feeType);
            for(Student_Fee__c fee : lst_StuFeeDeatils)
            {
                str += '<RECORD ID="'+count+'"><MERCID>'+Billdesk_Merchant_Details__c.getValues(fee.Fee_Type__c).MerchantId__c+'</MERCID>';
                if(feeType == 'single'){
                    str += '<AMOUNT>'+totAmt+'.00</AMOUNT>';
                }else{
                    str += '<AMOUNT>'+fee.Amount_Pending__c+'.00</AMOUNT>';
                }
                str += '<CUSTOMERID>'+RefId+count+'</CUSTOMERID>';
                str += '<ADDITIONALINFO1>'+Name+'</ADDITIONALINFO1>';
                str += '<ADDITIONALINFO2>'+email+'</ADDITIONALINFO2>';
                str += '<ADDITIONALINFO3>'+mobilevalue+'</ADDITIONALINFO3>';
                str += '<ADDITIONALINFO4>'+RefId+'</ADDITIONALINFO4>';
                str += '<ADDITIONALINFO5>'+fee.id+'</ADDITIONALINFO5>';
                str += '<ADDITIONALINFO6>'+studentUniqueId+'</ADDITIONALINFO6>';
                str += '<ADDITIONALINFO7>'+fee.Fee_Type__c+'</ADDITIONALINFO7>';
                str += '<FILLER1>NA</FILLER1>';
                str += '<FILLER2>NA</FILLER2>';
                str += '<FILLER3>NA</FILLER3>';
                str += '</RECORD>';
                count = count+1;
            }
            str += '</TXNDATA>';
            
            String gencheckSum = calculateCheckSum(str);
            gencheckSum = gencheckSum.toUppercase();
            string mainStr = '<?xml version="1.0" encoding="UTF-8"?><REQUEST>'+str;
            mainStr += '<CHECKSUM>'+gencheckSum+'</CHECKSUM></REQUEST>';
            
            string endPoint = Billdesk_Merchant_Details__c.getValues('PaymentLink').MerchantId__c;
            Http http1 = new Http();
            HttpRequest httpReq1 = new HttpRequest();
            HttpResponse httpRes1 = new HttpResponse();
            httpReq1.setEndpoint(endPoint);
            httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            string payload = 'msg='+mainStr;
            system.debug('Stage1'+payload);
            httpReq1.setbody(payload);
            httpReq1.setMethod('POST');
            httpReq1.setTimeout(120000);
            httpRes1 = http1.send(httpReq1);
            
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_ApplicationPayment_Ctrl';
            dblog.Method_Name__c = 'BillDeskPayGenratePaymentLink';
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Request__c = httpReq1.getBody();
            dblog.Response__c = httpRes1.getBody();
            dblog.User_Id__c = UserInfo.getUserId();
            
            string statusCode;
            if(httpRes1.getStatusCode() == 200){
                system.debug('httpRes1'+httpRes1.getStatusCode());
                string strXml = httpRes1.getBody(); 
                system.debug(strXml);
                Dom.Document doc = new Dom.Document();  
                doc.load(strXml);
                Dom.XMLNode rootElement = doc.getRootElement();
                for(Dom.XMLNode child1 : rootElement.getChildElements())
                {   system.debug('child1'+child1);
                 for(Dom.XMLNode child2 : child1.getChildElements())
                 {  system.debug('child2'+child2);
                  if(child2.getName() == 'TXNSUMMARY'){   
                      system.debug('getName'+child2.getName());
                      for(Dom.XMLNode child3 : child2.getChildElements()){
                          system.debug('child3'+child3);
                          if(child3.getName() == 'STATUSCODE'){
                              system.debug('STATUSCODE'+child3.getName());
                              statusCode = child3.getText();
                              
                          }    
                      }    
                  }
                 }
                }
            }
            else{
                reswrap.statusCode = httpRes1.getStatusCode();
            }
            
            if(statusCode == '0'){
                string baseReq = Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'|'+RefId+'|NA|'+totAmt+'.00|NA|NA|NA|INR|NA|R|'+Billdesk_Merchant_Details__c.getValues('SecurityId').MerchantId__c+'|NA|NA|F|';
                string midReq = Name+'|'+email+'|'+mobilevalue+'|'+RefId+'|'+studentUniqueId+'|NA|NA|';
                string returnUrl = Billdesk_Merchant_Details__c.getValues('Applicant_BillDesk_CallbackUrl').MerchantId__c;
                system.debug('Base Request: Stage 2 '+baseReq);
                system.debug('MID Request: '+midReq);
                system.debug('Return URL: '+returnUrl);
                string checkSum =  baseReq+midReq+returnUrl;           
                String genertedcheckSum = calculateCheckSum(checkSum);
                genertedcheckSum = genertedcheckSum.toUppercase();
                checkSum = checkSum+'|'+genertedcheckSum;
                system.debug('Piped URL :'+ checkSum);
                system.debug('checkSum===>'+checkSum);
                
                string ep = Billdesk_Merchant_Details__c.getValues('PaymentEndPoint').MerchantId__c+checkSum;
                reswrap.short_url = ep;
                reswrap.statusCode = 200;     
                
                objStuFeePay.Reference_Id__c = RefId;
                objStuFeePay.Billdesk_Url__c = ep;
                objStuFeePay.Payment_Status__c = 'Payment Link Created';
                objStuFeePay.Payment_Gateway__c = 'Billdesk';
                objStuFeePay.Mode_of_Payment__c = 'Online';
                insert objStuFeePay; 
                
                //  system.debug('==stu payment id==='+objStuFeePay.id);
                
                list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
                for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                    Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                    if(feeType == 'single'){
                        sfp.Amount__c = totAmt;
                    }
                    else{
                        sfp.Amount__c = objstuFee.Amount_Pending__c;
                    }
                    sfp.Mode_of_Payment__c = 'Online';
                    sfp.Reference_Id__c = RefId;
                    sfp.Student_Fee__c =  objstuFee.id;                       
                    sfp.Student_Payment__c = objStuFeePay.id;
                    sfp.Line_Item_Payment_Gateway__c = 'Billdesk';                   
                    lstSfp.add(sfp);
                }           
                if(lstSfp.size() > 0){
                    insert lstSfp;
                }
                dblog.Status__c = 'Success';
                dblog.Data_Received__c = ep;
            }
            else{
                reswrap.statusCode = integer.valueof(statusCode);
                dblog.Status__c = 'Failure';
            }
            insert dblog;
        }
        
        return reswrap;
    }


     //This method is used on click of 'Pay Now' button for the BillDeskPay PG 
     //Direct Fee Payment
     
    @AuraEnabled
    public static rezorpayResponseCall BillDeskPayGenratePAFPaymentLink(string flowConId, String stuPayId)
    {
        System.debug('inside BillDeskPayGenratePAFPaymentLink');
        System.debug('flowConId' + flowConId);
        System.debug('stuPayId' + stuPayId);
        List<Student_Fee__c> lst_StuFeeDeatils = [Select Id, Name, Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone, Contact__c, Program_Enrollment__c, Fee_Type__c, Contact__r.Application_Number__c, Fee_Payment_Criteria__c, Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c, Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,
                                                     Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c FROM Student_Fee__c WHERE Contact__c =: flowConId];
        List<Student_Payment__c> stuPayListUpdated = new list<Student_Payment__c>();
        List<Student_Payment__c> stupayList = [select Id, Name, Amount__c, Contact__c, Description__c, Fee_Type__c, Mode_of_Payment__c, Payment_Mode_Type__c, 
                                                    Offline_Receipt_Number__c, Online_Receipt_Number1__c, Payment_Date_Time__c, Payment_Link_Id__c, 
                                                    Payment_Url__c, Payment_Gateway__c, Program_Enrollment__c, Razorpay_Signature__c, Payment_Status__c, 
                                                    Transaction_ID__c,Contact__r.Application_Number__c, Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone from Student_Payment__c where (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Failed' or Payment_Status__c = 'Payment Link Created') AND 
                                                    Id =: stuPayId Order by Createddate DESC];
        
        System.debug('lst_StuFeeDeatils' + lst_StuFeeDeatils.size());
        System.debug('stupayList' + stupayList.size());
        System.debug('stupayList[0].Amount__c' + stupayList[0].Amount__c);
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        string Name = '';
        decimal totAmt = stupayList[0].Amount__c;
        string email = '';
        string mobile = '';
        string mobilevalue = '';
        string contactId = '';
        string studentUniqueId = '';
        string ProgEnrollId='';
        string discription = '';
        String feeType = stupayList[0].Fee_Type__c;
        if(stupayList[0].Fee_Type__c != null && feeType.contains(',')){
            feeType = feeType.substringBefore(',');
        }
        string RefId = Utility.generateRandomNumber();
        list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            Name = fee.Contact__r.Name;
            
            if(string.isNotBlank(fee.Contact__r.Email)){
                email = fee.Contact__r.Email;
            }
            else{
                email = 'NA';
            }
            if(string.isNotBlank(fee.Contact__r.MobilePhone)){
                mobile = fee.Contact__r.MobilePhone;
            }
            else{
                mobile = 'NA';
            }
            mobilevalue=mobile.remove('+').remove('-');
            contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;  
            discription = discription + fee.Fee_Type__c;    
            studentUniqueId = fee.Contact__r.Application_Number__c;  
            if(string.isNotBlank(studentUniqueId)){ 
                studentUniqueId = studentUniqueId.replaceAll('[^a-zA-Z0-9\\s+]', '');
            }
            else{
                studentUniqueId = 'NA';
            }
        }
        
        Student_Payment__c objStuFeePay = new Student_Payment__c();
        objStuFeePay.Amount__c = totAmt;
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        //  objStuFeePay.Mode_of_Payment__c = 'Online';
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        lstStuPayment.add(objStuFeePay);
        System.debug('merchant ID=' +  Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c);
        if(lstStuPayment.size() > 0){
            string str = '<TXNDATA><TXNSUMMARY><REQID>PGECOM201</REQID><PGMERCID>'+
                Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'</PGMERCID>';
            str += '<RECORDS>'+1+'</RECORDS>';
            str += '<PGCUSTOMERID>'+RefId+'</PGCUSTOMERID>';
            str += '<AMOUNT>'+totAmt+'</AMOUNT>';
            dateTime dt = system.now();
            string strDt =string.valueof(dt);
            String newStrDt = strDt.replaceAll('[^0-9]', '');
            str += '<TXNDATE>'+newStrDt+'</TXNDATE></TXNSUMMARY>';
            
            integer count = 1;
            //system.debug('++++++++'+feeType);
            // for(Student_Fee__c fee : lst_StuFeeDeatils)
            // {
                str += '<RECORD ID="'+count+'"><MERCID>'+Billdesk_Merchant_Details__c.getValues(feeType).MerchantId__c+'</MERCID>';
                // if(feeType == 'single'){
                    str += '<AMOUNT>'+totAmt+'</AMOUNT>';
                // }else{
                //     str += '<AMOUNT>'+fee.Amount_Pending__c+'.00</AMOUNT>';
                // }
                str += '<CUSTOMERID>'+RefId+count+'</CUSTOMERID>';
                str += '<ADDITIONALINFO1>'+Name+'</ADDITIONALINFO1>';
                str += '<ADDITIONALINFO2>'+email+'</ADDITIONALINFO2>';
                str += '<ADDITIONALINFO3>'+mobilevalue+'</ADDITIONALINFO3>';
                str += '<ADDITIONALINFO4>'+RefId+'</ADDITIONALINFO4>';
                str += '<ADDITIONALINFO5>'+stupayList[0].id+'</ADDITIONALINFO5>';
                str += '<ADDITIONALINFO6>'+studentUniqueId+'</ADDITIONALINFO6>';
                str += '<ADDITIONALINFO7>'+feeType+'</ADDITIONALINFO7>';
                str += '<FILLER1>NA</FILLER1>';
                str += '<FILLER2>NA</FILLER2>';
                str += '<FILLER3>NA</FILLER3>';
                str += '</RECORD>';
                // count = count+1;
            // }
            str += '</TXNDATA>';
            
            String gencheckSum = calculateCheckSum(str);
            gencheckSum = gencheckSum.toUppercase();
            string mainStr = '<?xml version="1.0" encoding="UTF-8"?><REQUEST>'+str;
            mainStr += '<CHECKSUM>'+gencheckSum+'</CHECKSUM></REQUEST>';
            
            string endPoint = Billdesk_Merchant_Details__c.getValues('PaymentLink').MerchantId__c;
            Http http1 = new Http();
            HttpRequest httpReq1 = new HttpRequest();
            HttpResponse httpRes1 = new HttpResponse();
            httpReq1.setEndpoint(endPoint);
            httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            string payload = 'msg='+mainStr;
            system.debug('Stage1'+payload);
            httpReq1.setbody(payload);
            httpReq1.setMethod('POST');
            httpReq1.setTimeout(120000);
            httpRes1 = http1.send(httpReq1);
            
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_ApplicationPayment_Ctrl';
            dblog.Method_Name__c = 'BillDeskPayGenratePAFPaymentLink';
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Request__c = httpReq1.getBody();
            dblog.Response__c = httpRes1.getBody();
            dblog.User_Id__c = UserInfo.getUserId();
            
            string statusCode;
            if(httpRes1.getStatusCode() == 200){
                system.debug('httpRes1'+httpRes1.getStatusCode());
                string strXml = httpRes1.getBody(); 
                system.debug(strXml);
                Dom.Document doc = new Dom.Document();  
                doc.load(strXml);
                Dom.XMLNode rootElement = doc.getRootElement();
                for(Dom.XMLNode child1 : rootElement.getChildElements())
                {   system.debug('child1'+child1);
                 for(Dom.XMLNode child2 : child1.getChildElements())
                 {  system.debug('child2'+child2);
                  if(child2.getName() == 'TXNSUMMARY'){   
                      system.debug('getName'+child2.getName());
                      for(Dom.XMLNode child3 : child2.getChildElements()){
                          system.debug('child3'+child3);
                          if(child3.getName() == 'STATUSCODE'){
                              system.debug('STATUSCODE'+child3.getName());
                              statusCode = child3.getText();
                              
                          }    
                      }    
                  }
                 }
                }
            }
            else{
                reswrap.statusCode = httpRes1.getStatusCode();
            }
            
            if(statusCode == '0'){
                string baseReq = Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'|'+RefId+'|NA|'+totAmt+'|NA|NA|NA|INR|NA|R|'+Billdesk_Merchant_Details__c.getValues('SecurityId').MerchantId__c+'|NA|NA|F|';
                string midReq = Name+'|'+email+'|'+mobilevalue+'|'+RefId+'|'+studentUniqueId+'|NA|NA|';
                string returnUrl = Billdesk_Merchant_Details__c.getValues('Applicant_BillDesk_CallbackUrl').MerchantId__c;
                system.debug('Base Request: Stage 2 '+baseReq);
                system.debug('MID Request: '+midReq);
                system.debug('Return URL: '+returnUrl);
                string checkSum =  baseReq+midReq+returnUrl;           
                String genertedcheckSum = calculateCheckSum(checkSum);
                genertedcheckSum = genertedcheckSum.toUppercase();
                checkSum = checkSum+'|'+genertedcheckSum;
                system.debug('Piped URL :'+ checkSum);
                system.debug('checkSum===>'+checkSum);
                
                string ep = Billdesk_Merchant_Details__c.getValues('PaymentEndPoint').MerchantId__c+checkSum;
                reswrap.short_url = ep;
                reswrap.statusCode = 200;     
                
                for(Student_Payment__c StuPay : stuPayList){
                    StuPay.Reference_Id__c = RefId;
                    StuPay.Billdesk_Url__c = ep;
                    StuPay.Payment_Gateway__c = 'Billdesk';
                    StuPay.Mode_of_Payment__c = 'Online';
                    StuPay.Program_Enrollment__c = ProgEnrollId;
                    StuPay.Id = StuPay.Id;
                    stuPayListUpdated.add(StuPay);
                }
                if(stuPayListUpdated.size() > 0){
                    update stuPayListUpdated; 
                }
                List<Student_Fee_Payment__c>  lstSfp = new List<Student_Fee_Payment__c>();
                for(Student_Fee_Payment__c sfp : [SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Student_Fee__c, Student_Payment__c, Transaction_Status__c FROM Student_Fee_Payment__c where Student_Fee__r.contact__c =:flowConId AND Student_Payment__r.Id =: stuPayId]){
                    sfp.Mode_of_Payment__c = 'Online';
                    sfp.Reference_Id__c = RefId;
                    sfp.Line_Item_Payment_Gateway__c = 'Billdesk'; 
                    lstSfp.add(sfp);
                }       
                if(lstSfp.size() > 0){
                    update lstSfp;
                }
                // list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
                // for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                //     Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                //     if(feeType == 'single'){
                //         sfp.Amount__c = totAmt;
                //     }
                //     else{
                //         sfp.Amount__c = objstuFee.Amount_Pending__c;
                //     }
                //     sfp.Mode_of_Payment__c = 'Online';
                //     sfp.Reference_Id__c = RefId;
                //     sfp.Student_Fee__c =  objstuFee.id;                       
                //     sfp.Student_Payment__c = objStuFeePay.id;
                //     sfp.Line_Item_Payment_Gateway__c = 'Billdesk';                   
                //     lstSfp.add(sfp);
                // }           
                // if(lstSfp.size() > 0){
                //     insert lstSfp;
                // }
                dblog.Status__c = 'Success';
                dblog.Data_Received__c = ep;
            }
            else{
                reswrap.statusCode = integer.valueof(statusCode);
                dblog.Status__c = 'Failure';
            }
            insert dblog;
        }
        
        return reswrap;
    }

    // //This method is used on click of 'Pay Now' button for the BillDeskPay PG
    
    // @AuraEnabled
    // public static rezorpayResponseCall BillDeskPayGenratePAFPaymentLink(string flowConId, String stuPayId) //list<Student_Fee__c> lst_StuFeeDeatils,,decimal PartialAmount,string feeType,
    // {
    //     List<Student_Fee__c> lst_StuFeeDeatils = [Select Id, Name, Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone, Contact__c, Program_Enrollment__c, Fee_Type__c, Contact__r.Application_Number__c, Fee_Payment_Criteria__c, Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c, Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,
    //                                                 Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c FROM Student_Fee__c WHERE Contact__c =: flowConId];
    //     rezorpayResponseCall reswrap = new rezorpayResponseCall();
    //     string Name = '';
    //     decimal totAmt = 0;
    //     string email = '';
    //     string mobile = '';
    //     string mobilevalue = '';
    //     string contactId = '';
    //     string studentUniqueId = '';
    //     string ProgEnrollId='';
    //     string discription = '';
    //     string RefId = Utility.generateRandomNumber();
    //     Decimal totalPendingOnlineAmount = 0;
    //     Set<Id> stuPayIdSet = new Set<Id>();
    //     List<Student_Payment__c> stuPayListUpdated = new list<Student_Payment__c>();
    //     List<Student_Payment__c> stupayList = [select Id, Name, Amount__c, Contact__c, Description__c, Fee_Type__c, Mode_of_Payment__c, Payment_Mode_Type__c, 
    //                                             Offline_Receipt_Number__c, Online_Receipt_Number1__c, Payment_Date_Time__c, Payment_Link_Id__c, 
    //                                             Payment_Url__c, Payment_Gateway__c, Program_Enrollment__c, Razorpay_Signature__c, Payment_Status__c, 
    //                                             Transaction_ID__c,Contact__r.Application_Number__c, Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone from Student_Payment__c where (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Failed') AND 
    //                                             Id =: stuPayId Order by Createddate DESC];
    //     for(Student_Payment__c objStuPay : stupayList){
    //         if(objStuPay.Mode_of_Payment__c =='Online'){
    //             totalPendingOnlineAmount += objStuPay.Amount__c;
    //             stuPayIdSet.add(objStuPay.Id);
    //         }
    //     }
    //     // List<Student_Fee_Payment__c>  stuFeePayList = [SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Student_Fee__c, Student_Payment__c, Transaction_Status__c FROM Student_Fee_Payment__c where Student_Fee__r.contact__c =:flowConId AND Student_Payment__r.Id =: stuPayIdSet];
    //     List<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        
    //     for(Student_Fee__c fee : lst_StuFeeDeatils)
    //     {
    //         Name = fee.Contact__r.Name;
            
    //         if(string.isNotBlank(fee.Contact__r.Email)){
    //             email = fee.Contact__r.Email;
    //         }
    //         else{
    //             email = 'NA';
    //         }
    //         if(string.isNotBlank(fee.Contact__r.MobilePhone)){
    //             mobile = fee.Contact__r.MobilePhone;
    //         }
    //         else{
    //             mobile = 'NA';
    //         }
    //         mobilevalue=mobile.remove('+').remove('-');
    //         contactId = fee.Contact__c;
    //         ProgEnrollId = fee.Program_Enrollment__c;  
    //         discription = discription + fee.Fee_Type__c;    
    //         studentUniqueId = fee.Contact__r.Application_Number__c;  
    //         if(string.isNotBlank(studentUniqueId)){ 
    //             studentUniqueId = studentUniqueId.replaceAll('[^a-zA-Z0-9\\s+]', '');
    //         }
    //         else{
    //             studentUniqueId = 'NA';
    //         }
    //     }
        
    //     Student_Payment__c objStuFeePay = new Student_Payment__c();
    //     // objStuFeePay.Amount__c = totAmt;
    //     objStuFeePay.Contact__c = contactId;
    //     objStuFeePay.Fee_Type__c = discription; 
    //     //  objStuFeePay.Mode_of_Payment__c = 'Online';
    //     objStuFeePay.Reference_Id__c = RefId;
    //     // objStuFeePay.Id = stupayList[0].Id;
    //     objStuFeePay.Program_Enrollment__c = ProgEnrollId;
    //     lstStuPayment.add(objStuFeePay);
        
    //     if(lstStuPayment.size() > 0){
    //     //     Name = stupayList[0].Contact__r.Name;
    //     //     email = stupayList[0].Contact__r.Email;
    //     //     mobile = stupayList[0].Contact__r.MobilePhone;
    //     //     mobilevalue=mobile.remove('+').remove('-');
    //     //     contactId = stupayList[0].Contact__c;
    //         totAmt = totalPendingOnlineAmount;
    //     // //     ProgEnrollId = fee.Program_Enrollment__c;  
    //     // //     discription = discription + fee.Fee_Type__c;    
    //     //     studentUniqueId = stupayList[0].Contact__r.Application_Number__c;  
    //     //     if(string.isNotBlank(studentUniqueId)){ 
    //     //         studentUniqueId = studentUniqueId.replaceAll('[^a-zA-Z0-9\\s+]', '');
    //     //     }
    //     //     else{
    //     //         studentUniqueId = 'NA';
    //     //     }
    //         string str = '<TXNDATA><TXNSUMMARY><REQID>PGECOM201</REQID><PGMERCID>'+Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'</PGMERCID>';
    //         str += '<RECORDS>'+1+'</RECORDS>';
    //         str += '<PGCUSTOMERID>'+RefId+'</PGCUSTOMERID>';
    //         str += '<AMOUNT>'+totAmt+'</AMOUNT>';
    //         dateTime dt = system.now();
    //         string strDt =string.valueof(dt);
    //         String newStrDt = strDt.replaceAll('[^0-9]', '');
    //         str += '<TXNDATE>'+newStrDt+'</TXNDATE></TXNSUMMARY>';
            
    //         integer count = 1;
    //         // system.debug('++++++++'+stupayList[0].Fee_Type__c);
    //         for(Student_Payment__c fee : stupayList)
    //         {
    //             String localfeetype = stupayList[0].Fee_Type__c;
    //             if(stupayList[0].Fee_Type__c != null && localfeetype.contains(',')){
    //                 localfeetype = localfeetype.substringBefore(',');
    //             }
    //             str += '<RECORD ID="'+count+'"><MERCID>'+Billdesk_Merchant_Details__c.getValues(localfeetype).MerchantId__c+'</MERCID>';
    //             // if(stupayList[0].Fee_Type__c == 'single'){
    //             //      str += '<AMOUNT>'+fee.Amount__c+'</AMOUNT>';
    //             // }else{
    //                 str += '<AMOUNT>'+fee.Amount__c+'</AMOUNT>';
    //             // }
    //             str += '<CUSTOMERID>'+RefId+count+'</CUSTOMERID>';
    //             str += '<ADDITIONALINFO1>'+Name+'</ADDITIONALINFO1>';
    //             str += '<ADDITIONALINFO2>'+email+'</ADDITIONALINFO2>';
    //             str += '<ADDITIONALINFO3>'+mobilevalue+'</ADDITIONALINFO3>';
    //             str += '<ADDITIONALINFO4>'+RefId+'</ADDITIONALINFO4>';
    //             str += '<ADDITIONALINFO5>'+fee.id+'</ADDITIONALINFO5>';
    //             str += '<ADDITIONALINFO6>'+studentUniqueId+'</ADDITIONALINFO6>';
    //             str += '<ADDITIONALINFO7>'+Billdesk_Merchant_Details__c.getValues(localfeetype).Name+'</ADDITIONALINFO7>';
    //             str += '<FILLER1>NA</FILLER1>';
    //             str += '<FILLER2>NA</FILLER2>';
    //             str += '<FILLER3>NA</FILLER3>';
    //             str += '</RECORD>';
    //             count = count+1;
    //         }
    //         str += '</TXNDATA>';
            
    //         String gencheckSum = calculateCheckSum(str);
    //         gencheckSum = gencheckSum.toUppercase();
    //         string mainStr = '<?xml version="1.0" encoding="UTF-8"?><REQUEST>'+str;
    //         mainStr += '<CHECKSUM>'+gencheckSum+'</CHECKSUM></REQUEST>';
            
    //         string endPoint = Billdesk_Merchant_Details__c.getValues('PaymentLink').MerchantId__c;
    //         Http http1 = new Http();
    //         HttpRequest httpReq1 = new HttpRequest();
    //         HttpResponse httpRes1 = new HttpResponse();
    //         httpReq1.setEndpoint(endPoint);
    //         httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    //         string payload = 'msg='+mainStr;
    //         system.debug('Stage1'+payload);
    //         httpReq1.setbody(payload);
    //         httpReq1.setMethod('POST');
    //         httpReq1.setTimeout(120000);
    //         httpRes1 = http1.send(httpReq1);
            
    //         Debug_Log__c dblog = new Debug_Log__c();
    //         dblog.Class_Name__c = 'FEE_ApplicationPayment_Ctrl';
    //         dblog.Method_Name__c = 'BillDeskPayGenratePAFPaymentLink';
    //         dblog.Processing_API_Name__c = 'BillDesk';            
    //         dblog.Request__c = httpReq1.getBody();
    //         dblog.Response__c = httpRes1.getBody();
    //         dblog.User_Id__c = UserInfo.getUserId();
            
    //         string statusCode;
    //         if(httpRes1.getStatusCode() == 200){
    //             system.debug('httpRes1'+httpRes1.getStatusCode());
    //             string strXml = httpRes1.getBody(); 
    //             system.debug(strXml);
    //             Dom.Document doc = new Dom.Document();  
    //             doc.load(strXml);
    //             Dom.XMLNode rootElement = doc.getRootElement();
    //             for(Dom.XMLNode child1 : rootElement.getChildElements())
    //             {   system.debug('child1'+child1);
    //              for(Dom.XMLNode child2 : child1.getChildElements())
    //              {  system.debug('child2'+child2);
    //               if(child2.getName() == 'TXNSUMMARY'){   
    //                   system.debug('getName'+child2.getName());
    //                   for(Dom.XMLNode child3 : child2.getChildElements()){
    //                       system.debug('child3'+child3);
    //                       if(child3.getName() == 'STATUSCODE'){
    //                           system.debug('STATUSCODE'+child3.getName());
    //                           statusCode = child3.getText();
                              
    //                       }    
    //                   }    
    //               }
    //              }
    //             }
    //         }
    //         else{
    //             reswrap.statusCode = httpRes1.getStatusCode();
    //         }
            
    //         if(statusCode == '0'){
    //             string baseReq = Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'|'+RefId+'|NA|'+totAmt+'|NA|NA|NA|INR|NA|R|'+Billdesk_Merchant_Details__c.getValues('SecurityId').MerchantId__c+'|NA|NA|F|';
    //             string midReq = Name+'|'+email+'|'+mobilevalue+'|'+RefId+'|'+studentUniqueId+'|NA|NA|';
    //             string returnUrl = Billdesk_Merchant_Details__c.getValues('Applicant_BillDesk_CallbackUrl').MerchantId__c;
    //             system.debug('Base Request: Stage 2 '+baseReq);
    //             system.debug('MID Request: '+midReq);
    //             system.debug('Return URL: '+returnUrl);
    //             string checkSum =  baseReq+midReq+returnUrl;           
    //             String genertedcheckSum = calculateCheckSum(checkSum);
    //             genertedcheckSum = genertedcheckSum.toUppercase();
    //             checkSum = checkSum+'|'+genertedcheckSum;
    //             system.debug('Piped URL :'+ checkSum);
    //             system.debug('checkSum===>'+checkSum);
                
    //             string ep = Billdesk_Merchant_Details__c.getValues('PaymentEndPoint').MerchantId__c+checkSum;
    //             reswrap.short_url = ep;
    //             reswrap.statusCode = 200;     
                
    //             for(Student_Payment__c StuPay : stuPayList){
    //                 StuPay.Reference_Id__c = RefId;
    //                 StuPay.Billdesk_Url__c = ep;
    //                 StuPay.Payment_Gateway__c = 'Billdesk';
    //                 StuPay.Mode_of_Payment__c = 'Online';
    //                 StuPay.Program_Enrollment__c = ProgEnrollId;
    //                 StuPay.Id = StuPay.Id;
    //                 stuPayListUpdated.add(StuPay);
    //             }
    //             if(stuPayListUpdated.size() > 0){
    //                 update stuPayListUpdated; 
    //             }
                
    //             //  system.debug('==stu payment id==='+objStuFeePay.id);
                
    //             // list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
    //             // for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
    //             //     Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
    //             //     if(feeType == 'single'){
    //             //         sfp.Amount__c = totAmt;
    //             //     }
    //             //     else{
    //             //         sfp.Amount__c = objstuFee.Amount_Pending__c;
    //             //     }
    //             //     sfp.Mode_of_Payment__c = 'Online';
    //             //     sfp.Reference_Id__c = RefId;
    //             //     sfp.Student_Fee__c =  objstuFee.id;                       
    //             //     sfp.Student_Payment__c = objStuFeePay.id;
    //             //     sfp.Line_Item_Payment_Gateway__c = 'Billdesk';                   
    //             //     lstSfp.add(sfp);
    //             // }           
    //             // if(lstSfp.size() > 0){
    //             //     insert lstSfp;
    //             // }
    //             dblog.Status__c = 'Success';
    //             dblog.Data_Received__c = ep;
    //             // string baseReq = Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'|'+RefId+'|NA|'+totAmt+'.00|NA|NA|NA|INR|NA|R|'+Billdesk_Merchant_Details__c.getValues('SecurityId').MerchantId__c+'|NA|NA|F|';
    //             // string midReq = Name+'|'+email+'|'+mobilevalue+'|'+RefId+'|'+studentUniqueId+'|NA|NA|';
    //             // string returnUrl = Billdesk_Merchant_Details__c.getValues('Applicant_BillDesk_CallbackUrl').MerchantId__c;
    //             // system.debug('Base Request: Stage 2 '+baseReq);
    //             // system.debug('MID Request: '+midReq);
    //             // system.debug('Return URL: '+returnUrl);
    //             // string checkSum =  baseReq+midReq+returnUrl;           
    //             // String genertedcheckSum = calculateCheckSum(checkSum);
    //             // genertedcheckSum = genertedcheckSum.toUppercase();
    //             // checkSum = checkSum+'|'+genertedcheckSum;
    //             // system.debug('Piped URL :'+ checkSum);
    //             // system.debug('checkSum===>'+checkSum);
                
    //             // string ep = Billdesk_Merchant_Details__c.getValues('PaymentEndPoint').MerchantId__c+checkSum;
    //             // reswrap.short_url = ep;
    //             // reswrap.statusCode = 200;     
                
    //             // for(Student_Payment__c stuPay: stupayList){
    //             //     stuPay.Reference_Id__c = RefId;
    //             //     stuPay.Billdesk_Url__c = ep;
    //             //     stuPay.Payment_Gateway__c = 'Billdesk';
    //             //     stuPay.Mode_of_Payment__c = 'Online';
    //             //     stuPayListUpdated.add(stuPay);
    //             // }
    //             // if(stuPayListUpdated.size()> 0){
    //             //     update stuPayListUpdated; 
    //             // }
                
    //             // //  system.debug('==stu payment id==='+objStuFeePay.id);
                
    //             // list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
    //             // // for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
    //             // //     Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
    //             // //     if(feeType == 'single'){
    //             // //         sfp.Amount__c = totAmt;
    //             // //     }
    //             // //     else{
    //             // //         sfp.Amount__c = objstuFee.Amount_Pending__c;
    //             // //     }
    //             // //     sfp.Mode_of_Payment__c = 'Online';
    //             // //     sfp.Reference_Id__c = RefId;
    //             // //     // sfp.Student_Fee__c =  objstuFee.id;                       
    //             // //     // sfp.Student_Payment__c = objStuFeePay.id;
    //             // //     sfp.Line_Item_Payment_Gateway__c = 'Billdesk';                   
    //             // //     lstSfp.add(sfp);
    //             // // }    
    //             // // for(Student_Fee_Payment__c sfp : stuFeePayList){
    //             // //     sfp.Mode_of_Payment__c = 'Online';
    //             // //     sfp.Reference_Id__c = RefId;
    //             // //     sfp.Line_Item_Payment_Gateway__c = 'Billdesk'; 
    //             // //     lstSfp.add(sfp);
    //             // // }       
    //             // // if(lstSfp.size() > 0){
    //             // //     update lstSfp;
    //             // // }
    //             // dblog.Status__c = 'Success';
    //             // dblog.Data_Received__c = ep;
    //         }
    //         else{
    //             reswrap.statusCode = integer.valueof(statusCode);
    //             dblog.Status__c = 'Failure';
    //         }
    //         insert dblog;
    //     // }

    //     // Student_Payment__c objStuFeePay = new Student_Payment__c();
    //     // objStuFeePay.Amount__c = totAmt;
    //     // objStuFeePay.Contact__c = contactId;
    //     // objStuFeePay.Fee_Type__c = discription; 
    //     // //  objStuFeePay.Mode_of_Payment__c = 'Online';
    //     // objStuFeePay.Reference_Id__c = RefId;
    //     // objStuFeePay.Program_Enrollment__c = ProgEnrollId;
    //     // lstStuPayment.add(objStuFeePay);
        
    //     // if(lstStuPayment.size() > 0){
    //     //     string str = '<TXNDATA><TXNSUMMARY><REQID>PGECOM201</REQID><PGMERCID>'+Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'</PGMERCID>';
    //     //     str += '<RECORDS>'+lst_StuFeeDeatils.size()+'</RECORDS>';
    //     //     str += '<PGCUSTOMERID>'+RefId+'</PGCUSTOMERID>';
    //     //     str += '<AMOUNT>'+totAmt+'</AMOUNT>';
    //     //     dateTime dt = system.now();
    //     //     string strDt =string.valueof(dt);
    //     //     String newStrDt = strDt.replaceAll('[^0-9]', '');
    //     //     str += '<TXNDATE>'+newStrDt+'</TXNDATE></TXNSUMMARY>';
            
    //     //     integer count = 1;
    //     //     //system.debug('++++++++'+feeType);
    //     //     for(Student_Fee__c fee : lst_StuFeeDeatils)
    //     //     {
    //     //         str += '<RECORD ID="'+count+'"><MERCID>'+Billdesk_Merchant_Details__c.getValues(fee.Fee_Type__c).MerchantId__c+'</MERCID>';
    //     //         // if(feeType == 'single'){
    //     //             str += '<AMOUNT>'+totAmt+'</AMOUNT>';
    //     //         // }else{
    //     //         //     str += '<AMOUNT>'+fee.Amount_Pending__c+'.00</AMOUNT>';
    //     //         // }
    //     //         str += '<CUSTOMERID>'+RefId+count+'</CUSTOMERID>';
    //     //         str += '<ADDITIONALINFO1>'+Name+'</ADDITIONALINFO1>';
    //     //         str += '<ADDITIONALINFO2>'+email+'</ADDITIONALINFO2>';
    //     //         str += '<ADDITIONALINFO3>'+mobilevalue+'</ADDITIONALINFO3>';
    //     //         str += '<ADDITIONALINFO4>'+RefId+'</ADDITIONALINFO4>';
    //     //         str += '<ADDITIONALINFO5>'+fee.id+'</ADDITIONALINFO5>';
    //     //         str += '<ADDITIONALINFO6>'+studentUniqueId+'</ADDITIONALINFO6>';
    //     //         str += '<ADDITIONALINFO7>'+fee.Fee_Type__c+'</ADDITIONALINFO7>';
    //     //         str += '<FILLER1>NA</FILLER1>';
    //     //         str += '<FILLER2>NA</FILLER2>';
    //     //         str += '<FILLER3>NA</FILLER3>';
    //     //         str += '</RECORD>';
    //     //         count = count+1;
    //     //     }
    //     //     str += '</TXNDATA>';
            
    //     //     String gencheckSum = calculateCheckSum(str);
    //     //     gencheckSum = gencheckSum.toUppercase();
    //     //     string mainStr = '<?xml version="1.0" encoding="UTF-8"?><REQUEST>'+str;
    //     //     mainStr += '<CHECKSUM>'+gencheckSum+'</CHECKSUM></REQUEST>';
            
    //     //     string endPoint = Billdesk_Merchant_Details__c.getValues('PaymentLink').MerchantId__c;
    //     //     Http http1 = new Http();
    //     //     HttpRequest httpReq1 = new HttpRequest();
    //     //     HttpResponse httpRes1 = new HttpResponse();
    //     //     httpReq1.setEndpoint(endPoint);
    //     //     httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    //     //     string payload = 'msg='+mainStr;
    //     //     system.debug('Stage1'+payload);
    //     //     httpReq1.setbody(payload);
    //     //     httpReq1.setMethod('POST');
    //     //     httpReq1.setTimeout(120000);
    //     //     httpRes1 = http1.send(httpReq1);
            
    //     //     Debug_Log__c dblog = new Debug_Log__c();
    //     //     dblog.Class_Name__c = 'FEE_ApplicationPayment_Ctrl';
    //     //     dblog.Method_Name__c = 'BillDeskPayGenratePAFPaymentLink';
    //     //     dblog.Processing_API_Name__c = 'BillDesk';            
    //     //     dblog.Request__c = httpReq1.getBody();
    //     //     dblog.Response__c = httpRes1.getBody();
    //     //     dblog.User_Id__c = UserInfo.getUserId();
            
    //     //     string statusCode;
    //     //     if(httpRes1.getStatusCode() == 200){
    //     //         system.debug('httpRes1'+httpRes1.getStatusCode());
    //     //         string strXml = httpRes1.getBody(); 
    //     //         system.debug(strXml);
    //     //         Dom.Document doc = new Dom.Document();  
    //     //         doc.load(strXml);
    //     //         Dom.XMLNode rootElement = doc.getRootElement();
    //     //         for(Dom.XMLNode child1 : rootElement.getChildElements())
    //     //         {   system.debug('child1'+child1);
    //     //          for(Dom.XMLNode child2 : child1.getChildElements())
    //     //          {  system.debug('child2'+child2);
    //     //           if(child2.getName() == 'TXNSUMMARY'){   
    //     //               system.debug('getName'+child2.getName());
    //     //               for(Dom.XMLNode child3 : child2.getChildElements()){
    //     //                   system.debug('child3'+child3);
    //     //                   if(child3.getName() == 'STATUSCODE'){
    //     //                       system.debug('STATUSCODE'+child3.getName());
    //     //                       statusCode = child3.getText();
                              
    //     //                   }    
    //     //               }    
    //     //           }
    //     //          }
    //     //         }
    //     //     }
    //     //     else{
    //     //         reswrap.statusCode = httpRes1.getStatusCode();
    //     //     }
            
    //     //     if(statusCode == '0'){
    //     //         string baseReq = Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'|'+RefId+'|NA|'+totAmt+'.00|NA|NA|NA|INR|NA|R|'+Billdesk_Merchant_Details__c.getValues('SecurityId').MerchantId__c+'|NA|NA|F|';
    //     //         string midReq = Name+'|'+email+'|'+mobilevalue+'|'+RefId+'|'+studentUniqueId+'|NA|NA|';
    //     //         string returnUrl = Billdesk_Merchant_Details__c.getValues('Applicant_BillDesk_CallbackUrl').MerchantId__c;
    //     //         system.debug('Base Request: Stage 2 '+baseReq);
    //     //         system.debug('MID Request: '+midReq);
    //     //         system.debug('Return URL: '+returnUrl);
    //     //         string checkSum =  baseReq+midReq+returnUrl;           
    //     //         String genertedcheckSum = calculateCheckSum(checkSum);
    //     //         genertedcheckSum = genertedcheckSum.toUppercase();
    //     //         checkSum = checkSum+'|'+genertedcheckSum;
    //     //         system.debug('Piped URL :'+ checkSum);
    //     //         system.debug('checkSum===>'+checkSum);
                
    //     //         string ep = Billdesk_Merchant_Details__c.getValues('PaymentEndPoint').MerchantId__c+checkSum;
    //     //         reswrap.short_url = ep;
    //     //         reswrap.statusCode = 200;     
                
    //     //         // objStuFeePay.Reference_Id__c = RefId;
    //     //         // objStuFeePay.Billdesk_Url__c = ep;
    //     //         // objStuFeePay.Payment_Status__c = 'Payment Link Created';
    //     //         // objStuFeePay.Payment_Gateway__c = 'Billdesk';
    //     //         // objStuFeePay.Mode_of_Payment__c = 'Online';
    //     //         // insert objStuFeePay; 
                
    //     //         for(Student_Payment__c stuPay: stupayList){
    //     //             stuPay.Reference_Id__c = RefId;
    //     //             stuPay.Billdesk_Url__c = ep;
    //     //             stuPay.Payment_Gateway__c = 'Billdesk';
    //     //             stuPay.Mode_of_Payment__c = 'Online';
    //     //             lstStuPayment.add(stuPay);
    //     //         }
    //     //         if(lstStuPayment.size()> 0){
    //     //             update lstStuPayment; 
    //     //         }
    //     //         //  system.debug('==stu payment id==='+objStuFeePay.id);
                
    //     //         // list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
    //     //         // for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
    //     //         //     Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
    //     //         //     if(feeType == 'single'){
    //     //         //         sfp.Amount__c = totAmt;
    //     //         //     }
    //     //         //     else{
    //     //         //         sfp.Amount__c = objstuFee.Amount_Pending__c;
    //     //         //     }
    //     //         //     sfp.Mode_of_Payment__c = 'Online';
    //     //         //     sfp.Reference_Id__c = RefId;
    //     //         //     sfp.Student_Fee__c =  objstuFee.id;                       
    //     //         //     sfp.Student_Payment__c = objStuFeePay.id;
    //     //         //     sfp.Line_Item_Payment_Gateway__c = 'Billdesk';                   
    //     //         //     lstSfp.add(sfp);
    //     //         // }           
    //     //         // if(lstSfp.size() > 0){
    //     //         //     insert lstSfp;
    //     //         // }
    //     //         dblog.Status__c = 'Success';
    //     //         dblog.Data_Received__c = ep;
    //     //     }
    //     //     else{
    //     //         reswrap.statusCode = integer.valueof(statusCode);
    //     //         dblog.Status__c = 'Failure';
    //     //     }
    //     //     insert dblog;
    //     }

    //     System.debug(reswrap);
    //     return reswrap;
    // }

    public static string calculateCheckSum(string mainStr){
        String testKey = Billdesk_Merchant_Details__c.getValues('Checksum').MerchantId__c;
        String algorithmName = 'hmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(mainStr) , Blob.valueOf(testKey));
        return EncodingUtil.convertToHEX(hmacData);
        
    }
    
    @AuraEnabled
    public static rezorpayResponseCall PaytmGeneratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType)
    {
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        decimal totAmt = PartialAmount;
        string applicationNo = '';
        string contactId ='';
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();  
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            applicationNo = fee.Contact__r.Application_Number__c;
            contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;  
            discription = discription + fee.Fee_Type__c;
        }
        
        Student_Payment__c objStuFeePay = new Student_Payment__c();
        objStuFeePay.Amount__c = totAmt;
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        
        Map<string, string> parammap = new Map<string,string>();
        parammap.put('MID',Paytm_Details__c.getValues('MID').Value__c);
        //parammap.put('MID',Paytm_Details__c.getValues('TestMID').Value__c);
        
        parammap.put('ORDER_ID',RefId);
        
        paytmMain ptm = new paytmMain();
        ptm.body = new PaytmParamClass();
        ptm.body.requestType = 'Payment';
        ptm.body.mid = Paytm_Details__c.getValues('MID').Value__c;
        //ptm.body.mid = Paytm_Details__c.getValues('TestMID').Value__c;
        
        ptm.body.orderId = RefId;
        ptm.body.websiteName = 'WEBSTAGING';
        ptm.body.callbackUrl = Paytm_Details__c.getValues('Applicant_Paytm_CallbackUrl').Value__c;
        system.debug('callbackUrl'+ptm.body.callbackUrl);
        //  ptm.body.callbackUrl = Paytm_Details__c.getValues('CallbackUrl').Value__c;
        ptm.body.txnAmount = new paymentDetails();
        ptm.body.txnAmount.value = string.valueof(PartialAmount);
        ptm.body.txnAmount.ccurrency = 'INR';
        ptm.body.userInfo = new UserDetails();
        ptm.body.userInfo.custId = applicationNo;
        
        string jsonStr = JSON.serialize(ptm.body);
        // jsonStr = jsonStr.replaceAll('"ccurrency":', '"currency":');
        system.debug('jsonStr+++++++++'+jsonStr);
        //system.debug('Key+++++++++'+Paytm_Details__c.getValues('TestMerchantKey').Value__c);
        string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('Merchant Key').Value__c, jsonStr);
        //string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('TestMerchantKey').Value__c, jsonStr);
        system.debug('checksumstring+++++++++'+checksumstring);
        ptm.head = new headDetails();
        ptm.head.signature = checksumstring;
        
        system.debug('Ptm++++++++'+ptm);
        string baseUrl = Paytm_Details__c.getValues('Endpoint').Value__c + 'mid=' +Paytm_Details__c.getValues('MID').Value__c+'&' ;
        //string baseUrl = Paytm_Details__c.getValues('TestEndpointURL').Value__c + 'mid=' +Paytm_Details__c.getValues('TestMID').Value__c+'&' ;
        baseUrl += 'orderId='+RefId;
        System.debug('+++ '+baseUrl);
        
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
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_ApplicationPayment_Ctrl';
        dblog.Method_Name__c = 'paytmGenratePaymentLink';
        dblog.Processing_API_Name__c = 'Paytm';            
        dblog.Request__c = req.getBody();
        dblog.Response__c = res.getBody();
        dblog.User_Id__c = UserInfo.getUserId();
        
        
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Payment_Url__c = baseUrl;
        objStuFeePay.Payment_Status__c = 'Payment Link Created';
        objStuFeePay.Payment_Gateway__c = 'Paytm';
        objStuFeePay.Mode_of_Payment__c = 'Online';
        insert objStuFeePay;
        
        list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
        for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
            Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
            if(feeType == 'single'){
                sfp.Amount__c = totAmt;
            }
            else{
                sfp.Amount__c = objstuFee.Amount_Pending__c;
            }
            sfp.Mode_of_Payment__c = 'Online';
            sfp.Reference_Id__c = RefId;
            sfp.Student_Fee__c =  objstuFee.id;                       
            sfp.Student_Payment__c = objStuFeePay.id;
            sfp.Line_Item_Payment_Gateway__c = 'Paytm';                   
            lstSfp.add(sfp);
        }           
        if(lstSfp.size() > 0){
            insert lstSfp;
        }
        
        inisaliseResponse response1 = new inisaliseResponse();
        
        if(res.getStatusCode() == 200){
            response1 = (inisaliseResponse)System.JSON.deserialize(res.getBody(), inisaliseResponse.class);
            
            if(response1.body.resultInfo.resultCode == '0000' || response1.body.resultInfo.resultCode == '0002'){
                reswrap.reference_id = response1.body.txnToken;
                system.debug(reswrap.reference_id);
                reswrap.statusCode = 200;
                reswrap.id = Paytm_Details__c.getValues('MID').Value__c;
                //reswrap.id = Paytm_Details__c.getValues('TestMID').Value__c;
                reswrap.status = RefId;
                reswrap.short_url = Paytm_Details__c.getValues('PaymentEndPoint').Value__c +'mid='+Paytm_Details__c.getValues('MID').Value__c+'&orderId='+RefId;
                //reswrap.short_url = Paytm_Details__c.getValues('TestPaymentPage').Value__c +'mid='+Paytm_Details__c.getValues('TestMID').Value__c+'&orderId='+RefId;
                system.debug(reswrap.short_url);
                dblog.Status__c = 'Success';
                
            }
            else{
                reswrap.statusCode = 101;
                dblog.Status__c = 'Failure';
            }
        }
        
        insert dblog;
        return reswrap;
    }

    @AuraEnabled
    public static rezorpayResponseCall paytmGeneratePAFPaymentLink(string flowConId, string stuPayId)
    {
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        // decimal totAmt = PartialAmount;
        string applicationNo = '';
        string contactId ='';
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();  
        Decimal totalPendingOnlineAmount = 0;
        List<Student_Payment__c> stupayListUpdated = new List<Student_Payment__c>();
        Set<Id> stuPayIdSet = new Set<Id>();
        // List<Student_Payment__c> stupayList = [select Id, Name, Amount__c, Contact__c, Description__c, Fee_Type__c, Mode_of_Payment__c, Payment_Mode_Type__c,
        //                                         Offline_Receipt_Number__c, Online_Receipt_Number1__c, Payment_Date_Time__c, Payment_Link_Id__c, 
        //                                         Payment_Url__c, Payment_Gateway__c, Program_Enrollment__c, Razorpay_Signature__c, Payment_Status__c, 
        //                                         Transaction_ID__c,Contact__r.Application_Number__c from Student_Payment__c where (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Failed') AND 
        //                                         Contact__c =: flowConId Order by Createddate DESC];
        List<Student_Payment__c> stupayList = [select Id, Name, Amount__c, Contact__c, Description__c, Fee_Type__c, Mode_of_Payment__c, Payment_Mode_Type__c,
                                                Offline_Receipt_Number__c, Online_Receipt_Number1__c, Payment_Date_Time__c, Payment_Link_Id__c, 
                                                Payment_Url__c, Payment_Gateway__c, Program_Enrollment__c, Razorpay_Signature__c, Payment_Status__c, 
                                                Transaction_ID__c,Contact__r.Application_Number__c from Student_Payment__c where (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Failed') AND 
                                                Id =: stuPayId];
        for(Student_Payment__c objStuPay : stupayList){
            if(objStuPay.Mode_of_Payment__c =='Online'){
                totalPendingOnlineAmount += objStuPay.Amount__c;
            }
            applicationNo = objStuPay.Contact__r.Application_Number__c;
        }

                                                // for(Student_Fee__c fee : lst_StuFeeDeatils)
        // {
            
            contactId = flowConId;
        //     ProgEnrollId = fee.Program_Enrollment__c;  
        //     discription = discription + fee.Fee_Type__c;
        // }
        Map<string, string> parammap = new Map<string,string>();
        parammap.put('MID',Paytm_Details__c.getValues('MID').Value__c);
        //parammap.put('MID',Paytm_Details__c.getValues('TestMID').Value__c);
        
        parammap.put('ORDER_ID',RefId);
        
        paytmMain ptm = new paytmMain();
        ptm.body = new PaytmParamClass();
        ptm.body.requestType = 'Payment';
        ptm.body.mid = Paytm_Details__c.getValues('MID').Value__c;
        //ptm.body.mid = Paytm_Details__c.getValues('TestMID').Value__c;
        
        ptm.body.orderId = RefId;
        ptm.body.websiteName = 'WEBSTAGING';
        ptm.body.callbackUrl = Paytm_Details__c.getValues('Applicant_Paytm_CallbackUrl').Value__c;
        system.debug('callbackUrl'+ptm.body.callbackUrl);
        //  ptm.body.callbackUrl = Paytm_Details__c.getValues('CallbackUrl').Value__c;
        ptm.body.txnAmount = new paymentDetails();
        ptm.body.txnAmount.value = string.valueof(totalPendingOnlineAmount);
        ptm.body.txnAmount.ccurrency = 'INR';
        ptm.body.userInfo = new UserDetails();
        ptm.body.userInfo.custId = applicationNo;
        // system.debug('applicationNo '+applicationNo);
        // system.debug('ptm.body.userInfo.custId  '+ptm.body.userInfo.custId);
        string jsonStr = JSON.serialize(ptm.body);
        // jsonStr = jsonStr.replaceAll('"ccurrency":', '"currency":');
        system.debug('jsonStr+++++++++'+jsonStr);
        //system.debug('Key+++++++++'+Paytm_Details__c.getValues('TestMerchantKey').Value__c);
        string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('Merchant Key').Value__c, jsonStr);
        //string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('TestMerchantKey').Value__c, jsonStr);
        system.debug('checksumstring+++++++++'+checksumstring);
        ptm.head = new headDetails();
        ptm.head.signature = checksumstring;
        
        system.debug('Ptm++++++++'+ptm);
        string baseUrl = Paytm_Details__c.getValues('Endpoint').Value__c + 'mid=' +Paytm_Details__c.getValues('MID').Value__c+'&' ;
        //string baseUrl = Paytm_Details__c.getValues('TestEndpointURL').Value__c + 'mid=' +Paytm_Details__c.getValues('TestMID').Value__c+'&' ;
        baseUrl += 'orderId='+RefId;
        System.debug('+++ '+baseUrl);
        
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
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'FEE_ApplicationPayment_Ctrl';
        dblog.Method_Name__c = 'paytmGeneratePAFPaymentLink';
        dblog.Processing_API_Name__c = 'Paytm';            
        dblog.Request__c = req.getBody();
        dblog.Response__c = res.getBody();
        dblog.User_Id__c = UserInfo.getUserId();
        for(Student_Payment__c objStuPay : stupayList){
            // if(objStuPay.Payment_Status__c == 'Pending' && objStuPay.Mode_of_Payment__c =='Online' && objStuPay.Payment_Mode_Type__c == 'Online'){
            //     totalPendingOnlineAmount += objStuPay.Amount__c;
            // }
            //applicationNo = objStuPay.Contact__r.Application_Number__c;
            objStuPay.Reference_Id__c = RefId;
            objStuPay.Payment_Date_Time__c = system.now();
            objStuPay.Payment_Url__c = baseUrl;
            objStuPay.Payment_Gateway__c = 'Paytm';
            objStuPay.Mode_of_Payment__c = 'Online';
            stupayListUpdated.add(objStuPay);
            stuPayIdSet.add(objStuPay.Id);
        }
        if(stupayListUpdated.size() > 0){
            update stupayListUpdated;
        }
        
        // Student_Payment__c objStuFeePay = new Student_Payment__c();
        // objStuFeePay.Amount__c = totAmt;
        // objStuFeePay.Contact__c = contactId;
        // objStuFeePay.Fee_Type__c = discription; 

        // objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        
        
        
        

        // objStuFeePay.Payment_Status__c = 'Success';
   
        // objStuFeePay.Id = stupayList[0].Id;
        
        
        list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
        for(Student_Fee_Payment__c sfp : [SELECT Id, Name, Amount__c, Line_Item_Payment_Gateway__c, Line_Item_Payment_Status__c, Mode_of_Payment__c, Payment_Link_Id__c, Payment_Mode_Type__c, Reference_Id__c, SF_Transaction_ID__c, Student_Fee__c, Student_Payment__c, Transaction_Status__c, Transaction_Date_Time__c FROM Student_Fee_Payment__c where Student_Payment__c =:stuPayIdSet ]){
            sfp.Mode_of_Payment__c = 'Online';
            sfp.Reference_Id__c = RefId;
            // sfp.Student_Fee__c =  objstuFee.id;                       
            // sfp.Student_Payment__c = objStuFeePay.id;
            sfp.Line_Item_Payment_Gateway__c = 'Paytm';                   
            lstSfp.add(sfp);
        }
        // for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
        //     Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
        //     if(feeType == 'single'){
        //         sfp.Amount__c = totAmt;
        //     }
        //     else{
        //         sfp.Amount__c = objstuFee.Amount_Pending__c;
        //     }
        //     
        // }           
        if(lstSfp.size() > 0){
            update lstSfp;
        }
        
        inisaliseResponse response1 = new inisaliseResponse();
        
        if(res.getStatusCode() == 200){
            response1 = (inisaliseResponse)System.JSON.deserialize(res.getBody(), inisaliseResponse.class);
            
            if(response1.body.resultInfo.resultCode == '0000' || response1.body.resultInfo.resultCode == '0002'){
                reswrap.reference_id = response1.body.txnToken;
                system.debug(reswrap.reference_id);
                reswrap.statusCode = 200;
                reswrap.id = Paytm_Details__c.getValues('MID').Value__c;
                //reswrap.id = Paytm_Details__c.getValues('TestMID').Value__c;
                reswrap.status = RefId;
                reswrap.short_url = Paytm_Details__c.getValues('PaymentEndPoint').Value__c +'mid='+Paytm_Details__c.getValues('MID').Value__c+'&orderId='+RefId;
                //reswrap.short_url = Paytm_Details__c.getValues('TestPaymentPage').Value__c +'mid='+Paytm_Details__c.getValues('TestMID').Value__c+'&orderId='+RefId;
                system.debug(reswrap.short_url);
                dblog.Status__c = 'Success';
                
            }
            else{
                reswrap.statusCode = 101;
                dblog.Status__c = 'Failure';
            }
        }
        
        insert dblog;
        return reswrap;
    }


    /*@Auraenabled
    public static rezorpayResponseCall easypayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType, string flowConId)
    {
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        string Name = '';
        decimal totAmt = PartialAmount;
        string email = '';
        string mobile = '';
        string contactId = '';
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();
        list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        string baseUrl = EasyPay_Details__c.getValues('EndPoint').Value__c+'merchantid='+EasyPay_Details__c.getValues('ICID').Value__c+'&mandatory fields=';
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            Name = fee.Contact__r.Name;
            email = fee.Contact__r.Email;
            mobile = fee.Contact__r.MobilePhone;
            system.debug('mobile:'+mobile);
            if(mobile!=null){
                if(mobile.contains('-')){
                    mobile = mobile.substringAfter('-');
                }
            }
            contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;  
            discription = discription + fee.Fee_Type__c;       
        }
        
        Student_Payment__c objStuFeePay = new Student_Payment__c();
        objStuFeePay.Amount__c = totAmt;
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        lstStuPayment.add(objStuFeePay);
        
        if(lstStuPayment.size() > 0){
            
            string para1 = RefId+'|'+EasyPay_Details__c.getValues('Submerchantid').Value__c+'|'+PartialAmount;
            para1 += '|'+Name+'|'+email+'|'+mobile+'|'+'ApplicationFee';  //studentpayment
            system.debug(para1);
            
            
            // string plainUrl = baseUrl + para1 + '&optional fields=xyz|xyz&returnurl='+EasyPay_Details__c.getValues('Applicant_CallbackUrl').Value__c;
            string plainUrl = baseUrl + para1 + '&optional fields=1111|0&returnurl='+EasyPay_Details__c.getValues('CallbackUrl').Value__c;
            plainUrl += '&Reference No='+RefId+'&submerchantid='+EasyPay_Details__c.getValues('Submerchantid').Value__c;
            plainUrl += '&transaction amount='+string.valueof(PartialAmount)+'&paymode=9';
            system.debug('PlainUrl+++++++'+plainUrl); 
            string str;
            if(!test.isRunningTest()){
                str = calculateAes(para1);
                
                str += '&optional fields='+calculateAes('xyz|xyz');
                //str += '&optional fields='+calculateAes('0|0');
                str += '&returnurl='+calculateAes(EasyPay_Details__c.getValues('CallbackUrl').Value__c)+'&Reference No='+calculateAes(RefId)+'&submerchantid=';
                str += calculateAes(EasyPay_Details__c.getValues('Submerchantid').Value__c)+'&transaction amount='+calculateAes(string.valueof(PartialAmount))+'&paymode='+calculateAes('9');
            }
            else{
                str = 'test';
            }
            system.debug('++++++++'+str);
            baseUrl = baseUrl + str;
            system.debug('++++++++'+baseUrl);
            
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_ApplicationPayment';
            dblog.Method_Name__c = 'easypayGenratePaymentLink';
            dblog.Processing_API_Name__c = 'EasyPay';
            HttpRequest req = new HttpRequest(); 
            HttpResponse res = new HttpResponse();
            dblog.Request__c = req.getBody();
            dblog.Response__c =res.getBody();
            dblog.User_Id__c = UserInfo.getUserId(); 
            
            
            objStuFeePay.Reference_Id__c = RefId;
            objStuFeePay.Billdesk_Url__c = baseUrl;
            objStuFeePay.Payment_Status__c = 'Payment Link Created';
            objStuFeePay.Payment_Gateway__c = 'Eazypay';
            objStuFeePay.Mode_of_Payment__c = 'Online';
            insert objStuFeePay;
            
            list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
            for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                if(feeType == 'single'){
                    sfp.Amount__c = totAmt;
                }
                else{
                    sfp.Amount__c = objstuFee.Amount_Pending__c;
                    system.debug('amount ='+sfp.Amount__c);
                }
                sfp.Mode_of_Payment__c = 'Online';
                sfp.Reference_Id__c = RefId;
                sfp.Student_Fee__c =  objstuFee.id;                       
                sfp.Student_Payment__c = objStuFeePay.id;
                sfp.Line_Item_Payment_Gateway__c = 'Eazypay';                   
                lstSfp.add(sfp);
            }           
            if(lstSfp.size() > 0){
                insert lstSfp;
            }
            reswrap.short_url = baseUrl;
            reswrap.statusCode = 200;
            system.debug('status -'+reswrap.statusCode);
            
        }
        else{
            reswrap.statusCode = 101;
            // dblog.Status__c = 'Failure';
        }
        system.debug('+++++++++++'+reswrap);
        return reswrap;
    }


    @Auraenabled
    public static rezorpayResponseCall easypayGenratePAFPaymentLink(string flowConId) //list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType, 
    {
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        string Name = '';
        decimal totAmt = 0;
        string email = '';
        string mobile = '';
        string contactId = '';
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();
        Decimal totalPendingOnlineAmount = 0;
        list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        List<Student_Payment__c> stupayList = [select Id, Name, Amount__c, Contact__c, Description__c, Fee_Type__c, Mode_of_Payment__c, Payment_Mode_Type__c,
                                                Offline_Receipt_Number__c, Online_Receipt_Number1__c, Payment_Date_Time__c, Payment_Link_Id__c, 
                                                Payment_Url__c, Payment_Gateway__c, Program_Enrollment__c, Razorpay_Signature__c, Payment_Status__c, 
                                                Transaction_ID__c,Contact__r.Application_Number__c, Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone
                                                from Student_Payment__c where (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Failed') AND 
                                                Contact__c =: flowConId Order by Createddate DESC];
        for(Student_Payment__c objStuPay : stupayList){
            if(objStuPay.Mode_of_Payment__c =='Online' && objStuPay.Payment_Mode_Type__c == 'Online'){
                totalPendingOnlineAmount += objStuPay.Amount__c;
            }
        }
        string baseUrl = EasyPay_Details__c.getValues('EndPoint').Value__c+'merchantid='+EasyPay_Details__c.getValues('ICID').Value__c+'&mandatory fields=';
        
        // for(Student_Fee__c fee : lst_StuFeeDeatils)
        // {
            // Name = stupayList[0].Contact__r.Name;
            // email = stupayList[0].Contact__r.Email;
            // mobile = stupayList[0].Contact__r.MobilePhone;
            // system.debug('mobile:'+mobile);
            // if(mobile!=null){
            //     if(mobile.contains('-')){
            //         mobile = mobile.substringAfter('-');
            //     }
            // }
            // contactId = stupayList[0].Contact__c;
            // ProgEnrollId = fee.Program_Enrollment__c;  
            // discription = stupayList[0] + fee.Fee_Type__c;       
        // }
        
        // Student_Payment__c objStuFeePay = new Student_Payment__c();
        // objStuFeePay.Amount__c = totAmt;
        // objStuFeePay.Contact__c = contactId;
        // objStuFeePay.Fee_Type__c = discription; 
        // objStuFeePay.Reference_Id__c = RefId;
        // objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        // lstStuPayment.add(objStuFeePay);
        
        if(stupayList.size() > 0){
            Name = stupayList[0].Contact__r.Name;
            email = stupayList[0].Contact__r.Email;
            mobile = stupayList[0].Contact__r.MobilePhone;
            system.debug('mobile:'+mobile);
            if(mobile!=null){
                if(mobile.contains('-')){
                    mobile = mobile.substringAfter('-');
                }
            }
            contactId = stupayList[0].Contact__c;
            string para1 = RefId+'|'+EasyPay_Details__c.getValues('Submerchantid').Value__c+'|'+totalPendingOnlineAmount;
            para1 += '|'+Name+'|'+email+'|'+mobile+'|'+'ApplicationFee';  //studentpayment
            system.debug(para1);
            
            
            // string plainUrl = baseUrl + para1 + '&optional fields=xyz|xyz&returnurl='+EasyPay_Details__c.getValues('Applicant_CallbackUrl').Value__c;
            string plainUrl = baseUrl + para1 + '&optional fields=1111|0&returnurl='+EasyPay_Details__c.getValues('CallbackUrl').Value__c;
            plainUrl += '&Reference No='+RefId+'&submerchantid='+EasyPay_Details__c.getValues('Submerchantid').Value__c;
            plainUrl += '&transaction amount='+string.valueof(stupayList[0].Amount__c)+'&paymode=9';
            system.debug('PlainUrl+++++++'+plainUrl); 
            string str;
            if(!test.isRunningTest()){
                str = calculateAes(para1);
                
                str += '&optional fields='+calculateAes('xyz|xyz');
                //str += '&optional fields='+calculateAes('0|0');
                str += '&returnurl='+calculateAes(EasyPay_Details__c.getValues('CallbackUrl').Value__c)+'&Reference No='+calculateAes(RefId)+'&submerchantid=';
                str += calculateAes(EasyPay_Details__c.getValues('Submerchantid').Value__c)+'&transaction amount='+calculateAes(string.valueof(totalPendingOnlineAmount))+'&paymode='+calculateAes('9');
            }
            else{
                str = 'test';
            }
            system.debug('++++++++'+str);
            baseUrl = baseUrl + str;
            system.debug('++++++++'+baseUrl);
            
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_ApplicationPayment';
            dblog.Method_Name__c = 'easypayGenratePAFPaymentLink';
            dblog.Processing_API_Name__c = 'EasyPay';
            HttpRequest req = new HttpRequest(); 
            HttpResponse res = new HttpResponse();
            dblog.Request__c = req.getBody();
            dblog.Response__c =res.getBody();
            dblog.User_Id__c = UserInfo.getUserId(); 
            for(Student_Payment__c objStuFeePay : stupayList){
                objStuFeePay.Reference_Id__c = RefId;
                objStuFeePay.Billdesk_Url__c = baseUrl;
                objStuFeePay.Payment_Gateway__c = 'Eazypay';
                objStuFeePay.Mode_of_Payment__c = 'Online';
                lstStuPayment.add(objStuFeePay);
            }
            
            // objStuFeePay.Reference_Id__c = RefId;
            // objStuFeePay.Billdesk_Url__c = baseUrl;
            // // objStuFeePay.Payment_Status__c = 'Payment Link Created';
            // objStuFeePay.Payment_Gateway__c = 'Eazypay';
            // objStuFeePay.Mode_of_Payment__c = 'Online';
            if(lstStuPayment.size() > 0){
                update lstStuPayment;
            }
            
            // list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
            // for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
            //     Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
            //     if(feeType == 'single'){
            //         sfp.Amount__c = totAmt;
            //     }
            //     else{
            //         sfp.Amount__c = objstuFee.Amount_Pending__c;
            //         system.debug('amount ='+sfp.Amount__c);
            //     }
            //     sfp.Mode_of_Payment__c = 'Online';
            //     sfp.Reference_Id__c = RefId;
            //     sfp.Student_Fee__c =  objstuFee.id;                       
            //     sfp.Student_Payment__c = objStuFeePay.id;
            //     sfp.Line_Item_Payment_Gateway__c = 'Eazypay';                   
            //     lstSfp.add(sfp);
            // }           
            // if(lstSfp.size() > 0){
            //     insert lstSfp;
            // }
            reswrap.short_url = baseUrl;
            reswrap.statusCode = 200;
            system.debug('status -'+reswrap.statusCode);
            
        }
        else{
            reswrap.statusCode = 101;
            // dblog.Status__c = 'Failure';
        }
        system.debug('+++++++++++'+reswrap);
        return reswrap;
    }*/
    
     //This method is used on click of 'Pay Now' button for the RazorPay PG
     @AuraEnabled
     public static rezorpayResponseCall razorPayGenratePAFPaymentLink(string flowConId, String stuPayId) //list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType, 
     {
         string name = '';
        //  decimal totAmt = PartialAmount;
         string email = '';
         string mobile = '';
         string discription = '';
         string contactId = '';
         string ProgEnrollId='';
         string RefId = Utility.generateRandomNumber();
         Decimal totalPendingOnlineAmount = 0;
         list<Student_Payment__c> stupayListUpdated = new list<Student_Payment__c>();
         Set<Id> stuPayIdSet = new Set<Id>();
         List<Student_Payment__c> stupayList = [select Id, Name, Amount__c, Contact__c, Description__c, Fee_Type__c, Mode_of_Payment__c, Payment_Mode_Type__c,
                                                Offline_Receipt_Number__c, Online_Receipt_Number1__c, Payment_Date_Time__c, Payment_Link_Id__c, 
                                                Payment_Url__c, Payment_Gateway__c, Program_Enrollment__c, Razorpay_Signature__c, Payment_Status__c, 
                                                Transaction_ID__c,Contact__r.Application_Number__c, Contact__r.Name, Contact__r.Email, Contact__r.MobilePhone
                                                from Student_Payment__c where (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Failed' OR Payment_Status__c = 'Payment Link Created') AND 
                                                Id =: stuPayId Order by Createddate DESC];
        for(Student_Payment__c objStuPay : stupayList){
            if(objStuPay.Mode_of_Payment__c =='Online'){
                totalPendingOnlineAmount += objStuPay.Amount__c;
            }
        }
                                                //  map<string,string> mapStuFee = new map<string,string>();
         
        //  for(Student_Fee__c fee : lst_StuFeeDeatils)
        //  {
             //totAmt = totAmt + fee.Amount_Pending__c;
       
             //    mapStuFee.put(fee.Fee_Type__c,fee.Id);
        //  }
        //  Student_Payment__c objStuFeePay = new Student_Payment__c();
        //  objStuFeePay.Amount__c = stupayList[0].Amount__c;
         
        //  objStuFeePay.Fee_Type__c = discription; 
        //  objStuFeePay.Mode_of_Payment__c = 'Online';

        //  objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        //  lstStuPayment.add(objStuFeePay);
         
         rezorpayResponseCall reswrap = new rezorpayResponseCall();
         
         if(stupayList.size() > 0){
            name = stupayList[0].Contact__r.Name;
            email = stupayList[0].Contact__r.Email;
            mobile = stupayList[0].Contact__r.MobilePhone;
           //  discription = discription + fee.Fee_Type__c;
            contactId = stupayList[0].Contact__c;
            ProgEnrollId = stupayList[0].Program_Enrollment__c;  
             razorPayRequestCall rq = new razorPayRequestCall();
             string amt = string.valueof((totalPendingOnlineAmount).round(System.RoundingMode.HALF_DOWN));
             amt = amt + '00';
             rq.ramount = decimal.valueof(amt);
             rq.rcurrency = 'INR';
             rq.accept_partial = false;
             
             //rq.first_min_partial_amount = 100;
                        // Example Unix timestamp
             Integer targetTimestamp = 1992405004;
             
             // Get the current Unix timestamp
             Datetime now = Datetime.now();
             Integer currentTimestamp = (Integer)now.getTime() / 1000;
             
             // Calculate the difference between current timestamp and target timestamp
             Integer timestampDifference = targetTimestamp + currentTimestamp;
             
             // Update rq.expire_by with the calculated timestamp difference
             rq.expire_by = timestampDifference;
             
             // Display the updated rq.expire_by value
             System.debug('Updated rq.expire_by value: ' + rq.expire_by);
 
             
             
             rq.reference_id = RefId;
             //  rq.reference_id = 'Ref-0002';
             rq.description = discription;
             rq.reminder_enable = true;
             rq.callback_url = Razorpay_Details__c.getValues('Applicant_CallbackUrl').Value__c;
             rq.callback_method = 'get';
             
             customerWrp cw = new customerWrp();
             cw.name = name;
             cw.contact = Mobile;
             cw.email = email;
             rq.customer = cw;
             
             notifyWrp nw = new notifyWrp();
             nw.sms = true;
             nw.email=true;
             rq.notify = nw;
             
             notesWrp nt = new notesWrp();
             nt.paymentType = 'FeePayment';
             rq.notes = nt;
             
             string jsonbody = json.serialize(rq);
             jsonbody = jsonbody.replace('"rcurrency"', '"currency"');
             jsonbody = jsonbody.replace('"ramount"', '"amount"'); 
             
             string endpoint = Razorpay_Details__c.getValues('Razorpay Endpoint').Value__c; 
             
             HttpRequest req = new HttpRequest();
             req.setEndpoint(endpoint);
             req.setMethod('POST');
             req.setHeader('Content-Type','application/json'); 
             req.setBody(jsonbody);
             //System.debug('+++++++++++++'+jsonbody);
             String username;
             String password;
             if(discription == 'Hostel Fee,'  || discription == 'Hostel Fee' ){
                username = Razorpay_Details__c.getValues('HostelUserName').Value__c;
                password = Razorpay_Details__c.getValues('HostelPassword').Value__c;  
            }
            else{
                username = Razorpay_Details__c.getValues('UserName').Value__c;
                password = Razorpay_Details__c.getValues('Password').Value__c;
            }
             Blob headerValue = Blob.valueOf(username + ':' + password);
             String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
             req.setHeader('Authorization', authorizationHeader);                 
             Http http = new Http();
             HTTPResponse res = http.send(req);
             String resBody = res.getBody();
             // System.debug('++++resBody++++++++'+res.getBody());
             // system.debug('====status code===='+res.getStatusCode());
             
             Debug_Log__c dblog = new Debug_Log__c();
             dblog.Class_Name__c = 'FEE_ApplicationPayment_Ctrl';
             dblog.Method_Name__c = 'razorPayGenratePAFPaymentLink';
             dblog.Processing_API_Name__c = 'RazorPay';            
             dblog.Request__c = req.getBody();
             dblog.Response__c = res.getBody();
             dblog.User_Id__c = UserInfo.getUserId();
             
             // Check if payment transaction is successful
             if(res.getStatusCode() == 200)
             {   
                 System.debug('Status200 Success-->');
                 System.debug('flowConId-->' + flowConId);
                 reswrap =  (rezorpayResponseCall)System.JSON.deserialize(resBody, rezorpayResponseCall.class);
                 reswrap.statusCode = res.getStatusCode();              
                 
                 list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
                 // for(Student_Payment__c sp : lstStuPayment){
                for(Student_Payment__c objStuFeePay : stupayList){
                    // if(objStuFeePay.Payment_Status__c == 'Pending' || objStuFeePay.Payment_Status__c == 'Failed'){
                        objStuFeePay.Contact__c = contactId;
                        objStuFeePay.Payment_Date_Time__c = system.now();
                        objStuFeePay.Reference_Id__c = RefId;
                        objStuFeePay.Payment_Link_Id__c = reswrap.id;
                        objStuFeePay.Payment_Url__c = reswrap.short_url;
                        objStuFeePay.Payment_Gateway__c = 'RazorPay';
                        stupayListUpdated.add(objStuFeePay);
                    // }

                }
                if(stupayListUpdated.size() > 0){
                    update stupayListUpdated; // update the Student Payment Record
                }
                System.debug('before reswrap id '+reswrap.id);
                System.debug('before reswrap id '+reswrap.id);
                for(Student_Fee_Payment__c sfp : [SELECT Id, Name, Amount__c, Line_Item_Payment_Gateway__c, Line_Item_Payment_Status__c, Mode_of_Payment__c, Payment_Link_Id__c, Payment_Mode_Type__c, Reference_Id__c, SF_Transaction_ID__c, Student_Fee__c, Student_Payment__c, Transaction_Status__c, Transaction_Date_Time__c FROM Student_Fee_Payment__c where Student_Payment__c =:stuPayId ]){
                    //     sfp.Mode_of_Payment__c = 'Online';
                    //     sfp.Reference_Id__c = RefId;
                    //     sfp.Payment_Link_Id__c = reswrap.id;
                    //     sfp.Line_Item_Payment_Gateway__c = 'Razorpay';     
                    sfp.Mode_of_Payment__c = 'Online';
                    sfp.Payment_Link_Id__c = reswrap.id;
                    // sfp.Student_Fee__c =  objstuFee.id;   //mapStuFee.get(objstuFee.Fee_Type__c);
                    // sfp.Student_Payment__c = objStuFeePay.id;
                    sfp.Line_Item_Payment_Gateway__c = 'Razorpay';
                    //sfp.Line_Item_Payment_Status__c='';
                    sfp.Reference_Id__c = RefId;              
                    lstSfp.add(sfp);
                }           
                if(lstSfp.size() > 0){
                    update lstSfp;
                }
                
                //  objStuFeePay.Id =  stupayList[0].Id;
                 //}
                 
                //  for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                //      Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();   
                //      if(feeType == 'single'){                 
                //          sfp.Amount__c = totAmt;
                //      }
                //      else{
                //          sfp.Amount__c = objstuFee.Amount_Pending__c;
                //      }
                //      sfp.Mode_of_Payment__c = 'Online';
                //      sfp.Payment_Link_Id__c = reswrap.id;
                //      sfp.Student_Fee__c =  objstuFee.id;   //mapStuFee.get(objstuFee.Fee_Type__c);
                //      sfp.Student_Payment__c = objStuFeePay.id;
                //      sfp.Line_Item_Payment_Gateway__c = 'Razorpay';
                //      sfp.Line_Item_Payment_Status__c='';
                //      sfp.Reference_Id__c = RefId;
                //      lstSfp.add(sfp);
                //  }
                //  //system.debug('==lstStuPayment==='+lstStuPayment);
                //  insert lstSfp; // Create the Student Fee Payment record and link it to the above inserted Student Payment record
                 /*   if(flowConId != null){
 Contact varConUpdate = [Select id, Application_Fee_Paid__c from Contact where id =:flowConId];
 varConUpdate.Application_Fee_Paid__c = True;
 update varConUpdate;
 System.debug('varConUpdate-->' + varConUpdate);
 System.debug('varConUpdate.Application_Fee_Paid__c-->' + varConUpdate.Application_Fee_Paid__c);
 } */
                 // system.debug('===after insert==='+lstSfp);
                 dblog.Status__c = 'Success';
             }
             else{
                 reswrap.statusCode = res.getStatusCode();
                 dblog.Status__c = 'Failure';
             }
             insert dblog;
         }
         //system.debug('===reswrap==='+reswrap);
         return reswrap;
     }


    /*public static string calculateAes(string mainStr){
        String Key = EasyPay_Details__c.getValues('AES key').Value__c;
        system.debug('mainstr:'+mainStr);
        system.debug('Key:'+Key);
        functions.Function accountFunction = functions.Function.get(label.FEE_Easypay_Function_Name);
        functions.FunctionInvocation invocation = accountFunction.invoke('{ "input" : "' +mainStr +'", "key" : "'+ key + '"}');
        system.debug('invocation:'+invocation);
        Map<String, Object> mp_out = (Map<String, Object>) JSON.deserializeUntyped(invocation.getResponse()) ;
        System.debug('Got response ' + mp_out);
        string decode  = String.valueof(mp_out.get('encodedStr')).unescapeHtml4();
        system.debug('Decoded+'+decode);
        return decode;     
    }*/
    
    
    public class StudentFeeWrapper
    {
        @AuraEnabled public list<CheckboxWrapper> lst_CheckboxWrap {get;set;}
        @AuraEnabled public list<Student_Fee__c> lst_StuPaidDetails {get;set;}
        @AuraEnabled public list<Student_Payment__c> lst_StuPaymentDetails {get;set;}
        @AuraEnabled public string objStuname {get;set;}
        @AuraEnabled public string objAppNumber {get;set;}
        @AuraEnabled public string objSrnNumber {get;set;}
        @AuraEnabled public boolean isPAF {get;set;}
        @AuraEnabled public Decimal DirectLinkPayment{get;set;}
        @AuraEnabled public boolean isPUCContact {get;set;}
        //    @AuraEnabled public decimal TotalAmount {get;set;}
        //    @AuraEnabled public decimal TotalPendingAmount {get;set;}
        //    @AuraEnabled public decimal TotalPaidAmount {get;set;}
        
        public StudentFeeWrapper()
        {
            lst_StuPaidDetails = new list<Student_Fee__c>();
            lst_StuPaymentDetails = new list<Student_Payment__c>();
            lst_CheckboxWrap = new list<CheckboxWrapper>();
            //    TotalAmount = 0;
            //    TotalPendingAmount = 0;
            //    TotalPaidAmount = 0;
        }
    } 
    public class StudentFeeRecWrapper
    {
        @AuraEnabled public list<Student_Fee__c> lst_StuFeePayment {get;set;}
        @AuraEnabled public string StuFeeType {get;set;}
        @AuraEnabled public Decimal NoOfInstallments {get;set;}
        @AuraEnabled public Decimal PendingAmount {get;set;}
        @AuraEnabled public Map<string,string> map_PaymentGateway {get;set;}
        @AuraEnabled public string Errmsg {get;set;}
        public StudentFeeRecWrapper()
        {
            lst_StuFeePayment = new list<Student_Fee__c>();
            map_PaymentGateway = new map<string,string>();
        }
    }
    public class CheckboxWrapper
    {
        @AuraEnabled public Student_Fee__c ObjStuFeeDeatils {get;set;}
        @AuraEnabled public boolean isChecked {get;set;}
        public CheckboxWrapper()
        {
            ObjStuFeeDeatils = new Student_Fee__c();
            isChecked = false;
        }    
    }
    // public class ErrorWrapper
    // {
    //     @AuraEnabled public string DateError {get;set;}
    // }  
    public class razorPayRequestCall{
        @AuraEnabled public decimal ramount {get;set;}
        @AuraEnabled public string rcurrency {get;set;}
        @AuraEnabled public boolean accept_partial {get;set;}
        //@AuraEnabled public decimal first_min_partial_amount {get;set;}
        @AuraEnabled public decimal expire_by {get;set;}
        @AuraEnabled public string reference_id {get;set;}
        @AuraEnabled public string description {get;set;}
        @AuraEnabled public boolean reminder_enable {get;set;}
        @AuraEnabled public string callback_url {get;set;}
        @AuraEnabled public string callback_method {get;set;}
        @AuraEnabled public customerWrp customer {get;set;}
        @AuraEnabled public notifyWrp notify {get;set;}
        @AuraEnabled public notesWrp notes {get;set;}
    }
    public class customerWrp{
        @AuraEnabled public string name {get;set;}
        @AuraEnabled public string contact {get;set;}
        @AuraEnabled public string email {get;set;}
    }
    public class notifyWrp{
        @AuraEnabled public boolean sms {get;set;}
        @AuraEnabled public boolean email {get;set;}
    }
    public class notesWrp{
        @AuraEnabled public string paymentType {get;set;}
    }
    
    public class rezorpayResponseCall{
        @AuraEnabled public string id {get;set;}
        @AuraEnabled public string reference_id {get;set;}
        @AuraEnabled public string short_url {get;set;}
        @AuraEnabled public string status  {get;set;}
        @AuraEnabled public integer statusCode  {get;set;}
    }
    public class paytmMain{
        @AuraEnabled public PaytmParamClass body {get;set;}
        @AuraEnabled public headDetails head {get;set;}
    }
    public class PaytmParamClass{
        @AuraEnabled public string requestType {get;set;}
        @AuraEnabled public string mid {get;set;}
        @AuraEnabled public string orderId {get;set;}
        @AuraEnabled public string websiteName {get;set;}
        @AuraEnabled public string callbackUrl {get;set;}  
        @AuraEnabled public paymentDetails txnAmount {get;set;}  
        @AuraEnabled public UserDetails userInfo {get;set;}    
        
    }
    
    public class paymentDetails{
        @AuraEnabled public string value {get;set;}
        @AuraEnabled public string ccurrency {get;set;}
    }
    
    public class UserDetails{
        @AuraEnabled public string custId {get;set;}
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
        @AuraEnabled public string txnToken {get;set;}
        @AuraEnabled public boolean isPromoCodeValid {get;set;}
        @AuraEnabled public boolean authenticated {get;set;}
    }      
    
}