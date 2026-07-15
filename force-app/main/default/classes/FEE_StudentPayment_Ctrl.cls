public without sharing class FEE_StudentPayment_Ctrl 
{
    
    @AuraEnabled(cacheable=true)
    public static String getSiteUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    
    @AuraEnabled
    public static string getDownloadLink(String PaymentId){
        try{
            System.debug('PaymentId=> '+PaymentId);
            String User1 = [Select ContactId from user where Id=:UserInfo.getUserId() Limit 1].Id;
            PageReference pdfPage = Page.FEE_FeeReceipt; // Replace with your VF page name
            pdfPage.getParameters().put('id', PaymentId); // Pass parameters if needed
            Blob pdfBlob = pdfPage.getContentAsPDF(); 
            
            // Ensure the Blob is not empty
            if (pdfBlob == null || pdfBlob.size() == 0) {
                throw new AuraHandledException('Error: Generated PDF is empty.');
            }
            String base64Data = EncodingUtil.base64Encode(pdfBlob);
            System.debug('Base64 PDF Start => ' + base64Data.substring(0, 50)); // Check first 50 characters
            ContentVersion cv = new ContentVersion();
            cv.Title = 'FeeReceipt';
            cv.PathOnClient = 'FeeReceipt.pdf';
            cv.VersionData = pdfBlob;
            cv.OwnerId = User1;
          //  cv.FileExtension = 'application/pdf';
            insert cv;
            
             contentversion cx = [Select fileExtension,fileType,contentDocumentId from contentversion where Id=:cv.Id limit 1];
            System.debug(cx.FileExtension+' Type=> '+cx.FileType);

             return cx.ContentDocumentId;
            
        }
        catch(Exception e){
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void DeleteDocument(String recordId){
        ContentDocument cv = [Select Id from ContentDocument where Id=:recordId];
        if (cv != null) {
            // Delete the ContentDocument, which removes all related versions
            delete cv;
        }
    }
    
    @AuraEnabled
    public static StudentFeeWrapper DisplayStudentFeeRecords()
    {
        StudentFeeWrapper stuWrap = new StudentFeeWrapper();
        user usr = new user();
        usr =[select id,Name,ContactId from User where id=:userinfo.getUserId()];
        if(usr.ContactId != null)
        {            
            for(Student_Fee__c objStuFee : [select id,Name,Fee_Year__c,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Application_Number__c,Contact__r.Split_Booking_Fee__c,
                                            Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                            Course_Name_Course_Code__c,Program_Enrollment__c,Description__c,Due_Date__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,
                                            Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,
                                            Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c,
                                            (SELECT Id, Name, Student_Payment__r.Amount__c,Student_Payment__r.Split_Booking_Fee__c,Student_Payment__r.Partial_Booking_Fee__c,Student_Payment__r.Pending_Booking_Fee_FF__c,Student_Payment__r.Pending_Booking_Fee__c,Student_Payment__r.Payment_Status__c,Student_Payment__r.Split_Validation__c FROM Student_Fee_Payments__r where Student_Payment__r.Payment_Status__c != 'Success')
                                            from Student_Fee__c where Contact__c =: usr.ContactId  AND Cancelled__c = False order by Due_Date__c asc]) 
            {
                CheckboxWrapper checkWrap = new CheckboxWrapper();
                if(objStuFee.Name != null)
                    stuWrap.objStuname =objStuFee.Name;
                if(objStuFee.Contact__r.Application_Number__c != null)
                    stuWrap.objAppNumber=objStuFee.Contact__r.Application_Number__c;
                if(objStuFee.Contact__r.SRN_Number__c != null)
                    stuWrap.objSrnNumber=objStuFee.Contact__r.SRN_Number__c; 
                
                //stuWrap.TotalAmount = stuWrap.TotalAmount + objStuFee.Amount__c;
                //stuWrap.TotalPendingAmount = stuWrap.TotalPendingAmount + objStuFee.Amount_Pending__c;
                //stuWrap.TotalPaidAmount = stuWrap.TotalPaidAmount + objStuFee.Amount_Paid__c;
                        if (objStuFee.Amount__c != null) {
            				stuWrap.TotalAmount += objStuFee.Amount__c;
       						 }
              		    if (objStuFee.Amount_Pending__c != null) {
   							stuWrap.TotalPendingAmount += objStuFee.Amount_Pending__c;
							}
                        if (objStuFee.Amount_Paid__c != null) {
                            stuWrap.TotalPaidAmount += objStuFee.Amount_Paid__c;
                        }
               // stuWrap.TotalPendingAmount = stuWrap.TotalPendingAmount + objStuFee.Amount_Pending__c;
                //stuWrap.TotalPaidAmount = stuWrap.TotalPaidAmount + objStuFee.Amount_Paid__c;
                
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
            for(Student_Payment__c objStuPay : [select Id,Name,Amount__c,Contact__c,Description__c,Fee_Type__c,Mode_of_Payment__c,Offline_Receipt_Number__c,Online_Receipt_Number1__c,
                                                Payment_Date_Time__c,Payment_Link_Id__c,Payment_Url__c,Payment_Gateway__c,Program_Enrollment__c,Razorpay_Signature__c,Payment_Status__c,
                                                Transaction_ID__c,Transaction_Status__c 
                                                from Student_Payment__c where Payment_Status__c !=: 'Payment Link Created' AND Contact__c =: usr.ContactId Order by Createddate DESC]) 
            {
                stuWrap.lst_StuPaymentDetails.add(objStuPay);
            }
        }
        return stuWrap;
    } 
    @AuraEnabled //Single record validation
    public static ErrorWrapper ValidationDate(Id strSelid,date selduedate,string Conid)
    {
        system.debug('====strSelid==='+strSelid);
        ErrorWrapper errWrap = new ErrorWrapper();
        if(selduedate != null)
        {
            string selFeetype;
            boolean isLateFee = false;
            for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c,Parent_Student_Fee__c
                                            from Student_Fee__c where id =: strSelid and Contact__c =: Conid])
            {  
                if(objStuFee.Fee_Type__c !=  null)
                {
                    selFeetype = objStuFee.Fee_Type__c;
                }
                if(string.isNotBlank(objStuFee.Parent_Student_Fee__c)){
                    isLateFee = true;
                }
            }
            
            set<string> set_FeeType = new set<string>();
            set_FeeType.add('Tuition Fee');
            set_FeeType.add('University Fee');
            set_FeeType.add('Penalty Fee');
            if(!string.isBlank(selFeetype) && (selFeetype == 'Tuition Fee'))
            {                 
                for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c
                                                from Student_Fee__c where Due_Date__c <=: selduedate and Contact__c =: Conid 
                                                and Amount_Pending__c != null and Amount_Pending__c > 0 and Fee_Type__c =: 'University Fee' ])
                {                     
                    errWrap.DateError='Fee for Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';                    
                }
                
                Boolean hasPenaltyFee = false;
                for (Student_Fee__c objStuFee : [SELECT Id, Name, Fee_Type__c, Contact__c, Due_Date__c
                                                 FROM Student_Fee__c WHERE Due_Date__c <= :selduedate AND Contact__c = :Conid AND Amount_Pending__c != null 
                                                 AND Amount_Pending__c > 0 AND Fee_Type__c = 'Penalty Fee']) {
                                                     hasPenaltyFee = true;
                                                     errWrap.DateError = 'You have Penalty Fee So that you can'+'\''+'t made with Single Payment Go with PAY Multiples';
                                                     return errWrap;
                                                 }
            }
            else if(!string.isBlank(selFeetype) && (selFeetype == 'Tuition Fee'))
            {                 
                for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c
                                                from Student_Fee__c where Due_Date__c <=: selduedate and Contact__c =: Conid 
                                                and Amount_Pending__c != null and Amount_Pending__c > 0  and Fee_Type__c =: 'University Fee'])
                {                     
                    if(objStuFee.Fee_Type__c == 'University Fee')
                        errWrap.DateError='Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';                    
                    //else if(objStuFee.Fee_Type__c == 'Tuition Fee')
                    //   errWrap.DateError='Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';                    
                    
                }
                
            } 
            else if(!string.isBlank(selFeetype) && (selFeetype == 'University Fee'))
            {
                
                for(Student_Fee__c objStuFee : [select id,Name,Fee_Type__c,Contact__c,Due_Date__c
                                                from Student_Fee__c where Due_Date__c <: selduedate and Contact__c =: Conid 
                                                and Amount_Pending__c != null and Amount_Pending__c > 0  ])
                {                     
                    if(objStuFee.Fee_Type__c == 'University Fee')
                        errWrap.DateError='Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';                    
                    else if(objStuFee.Fee_Type__c == 'Tuition Fee')
                        errWrap.DateError='Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made'; 
                    
                }
                Boolean hasPenaltyFee = false;
                for (Student_Fee__c objStuFee : [SELECT Id, Name, Fee_Type__c, Contact__c, Due_Date__c
                                                 FROM Student_Fee__c WHERE Due_Date__c >= :selduedate AND Contact__c = :Conid AND Amount_Pending__c != null 
                                                 AND Amount_Pending__c > 0 AND Fee_Type__c = 'Penalty Fee']) {
                                                     hasPenaltyFee = true;
                                                     errWrap.DateError = 'You have Penalty Fee So that you can'+'\''+'t made with Single Payment Go with PAY Multiples';
                                                     return errWrap;
                                                 }
            } else if (selFeetype == 'Penalty Fee') {
                for (Student_Fee__c objStuFee : [SELECT Id, Name, Fee_Type__c, Contact__c, Due_Date__c
                                                 FROM Student_Fee__c WHERE Contact__c = :Conid AND Fee_Type__c = 'Penalty Fee'
                                                 AND Amount_Pending__c > 0]) {
                                                     errWrap.DateError = 'You have Penalty Fee So that you can'+'\''+'t made with Single Payment Go with PAY Multiples';
                                                     return errWrap;
                                                 }
            }
        }
        return errWrap;
    } 
    @AuraEnabled
    public static StudentFeeRecWrapper FetchFeeRecords(Id strSelid)
    {
        StudentFeeRecWrapper stuWrap = new StudentFeeRecWrapper();
        user usr = new user();
        usr =[select id,Name,ContactId from User where id=:userinfo.getUserId()];
        if(usr.ContactId != null)
        {   
            for(Student_Fee__c objStuFee : [select id,Name,Actual_Program_Fee__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Concession__c,Contact__c,Contact__r.Split_Booking_Fee__c,Contact__r.Application_Number__c,
                                            Contact__r.SRN_Number__c,Contact__r.Name,Contact__r.Mobilephone,Contact__r.Email,Fee_Payment_Criteria__r.Payment_Type__c,Payment_Type__c,Fee_Payment_Criteria__r.Fee_Type__c,
                                            Course_Name_Course_Code__c,Description__c,Due_Date__c,Program_Enrollment__c,Fee_Category__c,Fee_Payment_Criteria__c,Fee_Type__c,Number_of_Installments__c,Paid_Installments__c,Premium_Room__c,
                                            Premium__c,Received_Source__c,Room_Sharing_Details__c,Scholarship__c,Scholarship_Category__c,Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c,Fee_Payment_Criteria__r.Merchant_ID_GrayQuest__c,
                                            Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c,Fee_Payment_Criteria__r.Merchant_ID_Paytm__c,Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c,
                                            (SELECT Id, Name, Student_Payment__r.Amount__c,Student_Payment__r.Split_Booking_Fee__c,Student_Payment__r.Partial_Booking_Fee__c,Student_Payment__r.Pending_Booking_Fee_FF__c,Student_Payment__r.Pending_Booking_Fee__c,Student_Payment__r.Payment_Status__c,Student_Payment__r.Split_Validation__c FROM Student_Fee_Payments__r where Student_Payment__r.Payment_Status__c != 'Success')
                                            from Student_Fee__c where id=:strSelid and  Contact__c =: usr.ContactId order by Due_Date__c asc])
            {
                system.debug(objStuFee.Fee_Type__c+' ,'+objStuFee.Fee_Payment_Criteria__r.Fee_Type__c);
                if(objStuFee.Fee_Type__c == objStuFee.Fee_Payment_Criteria__r.Fee_Type__c)
                {
                    
                    // Hostel Related     
                    if (objStuFee.Fee_Type__c=='Hostel Fee'){
                        if (objStuFee.Payment_Type__c == 'Full Payment') {
                            // When Payment_Type__c is 'Full payment'
                            stuWrap.NoOfInstallments = 1;
                        } else {
                            // For other cases
                            if( objStuFee.Paid_Installments__c ==0){
                                stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c;
                            }else{
                                stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c+1;
                            }
                            
                        }
                        
                        if(objStuFee.Number_of_Installments__c  != null && objStuFee.Paid_Installments__c != null){
                            stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - objStuFee.Paid_Installments__c+1;
                        }
                    }
                    
                    
                    
                    stuWrap.StuFeeType = objStuFee.Fee_Type__c;
                    if (objStuFee.Fee_Type__c!='Hostel Fee'){
                        if(objStuFee.Number_of_Installments__c  != null && objStuFee.Paid_Installments__c != null)
                            
                            stuWrap.NoOfInstallments = objStuFee.Number_of_Installments__c - 1;
                    }
                    stuWrap.PendingAmount = objStuFee.Amount_Pending__c;
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Full Payment')  stuWrap.lst_StuFeePayment.add(objStuFee);
                    if(objStuFee.Fee_Payment_Criteria__r.Payment_Type__c =='Partial Payment') stuWrap.lst_StuFeePayment.add(objStuFee);
                    
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('RazorPay','RazorPay');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Paytm__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('PayTM','PayTM');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('EazyPay','EazyPay');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('BillDesk','BillDesk');
                    }
                    if(objStuFee.Fee_Payment_Criteria__r.Merchant_ID_GrayQuest__c != null)
                    {
                        stuWrap.map_PaymentGateway.put('GrayQuest','GrayQuest');
                    }
                }            
            }
        }
        system.debug(stuWrap);
        return stuWrap; 
    }
    
    @AuraEnabled
    public static Student_Fee__c getPenaltyFeeForContact(Id contactId) {
        // Query to fetch penalty fee records for the given contact ID
        List<Student_Fee__c> penaltyFees = [
            SELECT Id, Fee_Year__c 
            FROM Student_Fee__c 
            WHERE Contact__c = :contactId 
            AND Fee_Type__c = 'Penalty Fee' AND Amount_Pending__c > 0 LIMIT 1
        ];
        
        // Return the list of penalty fee records
        return (penaltyFees.size() > 0) ? penaltyFees[0] : null;
    }       
    
    @AuraEnabled
    public static StudentFeeRecWrapper MultiStduentFeeRecords(list<Student_Fee__c> lst_StuIds)
    {
        //system.debug('===lst_StuIds==='+lst_StuIds);
        StudentFeeRecWrapper stuWrap = new StudentFeeRecWrapper();
        boolean razorpay = true;
        boolean billdesk = true;
        boolean paytm = true;
        boolean EazyPay = true;
        boolean GrayQuest = true;
        for(Student_Fee__c objstufee : lst_StuIds)
        {
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_Billdesk__c == null && billdesk==true)
            {
                billdesk = false;
            }
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_Eazypay__c == null && EazyPay==true)
            {
                EazyPay = false;
            }
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_Razorpay__c == null && razorpay==true)
            {
                razorpay = false;
            }
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_Paytm__c == null && paytm==true)
            {
                paytm = false;
            }
            if(objstufee.Fee_Payment_Criteria__r.Merchant_ID_GrayQuest__c == null && GrayQuest==true)
            {
                GrayQuest = true;
            }
            system.debug('objstufee1==>'+objstufee);
            system.debug('objstufee2==>'+objstufee.Student_Fee_Payments__r);
            stuWrap.lst_StuFeePayment.add(objstufee);
        }
        
        if(razorpay == true)
            stuWrap.map_PaymentGateway.put('RazorPay','RazorPay');
        if(paytm == true)
            stuWrap.map_PaymentGateway.put('PayTM','PayTM');
        if(EazyPay == true)
            stuWrap.map_PaymentGateway.put('EazyPay','EazyPay');
        if(billdesk == true)
            stuWrap.map_PaymentGateway.put('BillDesk','BillDesk');  
        if(GrayQuest == true)
        stuWrap.map_PaymentGateway.put('GrayQuest','GrayQuest');
        
        stuWrap.Errmsg = 'Success';
        if(stuWrap.map_PaymentGateway.values().size() ==0)
        {
            stuWrap.Errmsg = 'Failure';
        }
        return stuWrap; 
    }
    @AuraEnabled
	public static ErrorWrapper ValidateMultiPayments(List<Student_Fee__c> lst_StuIds) {
    ErrorWrapper errWrap = new ErrorWrapper();
    
    Set<Id> setContactIds = new Set<Id>();
    Set<Date> selectedDueDates = new Set<Date>();
    Date maxSelectedDueDate;
    List<Date> dueDateList = new List<Date>();
    
    Boolean hasNonHostelFee = false;
    Set<String> nonHostelFeeTypes = new Set<String>{'University Fee', 'Tuition Fee'};
   
    for (Student_Fee__c fee : lst_StuIds) {
        if (fee.Contact__c != null && fee.Due_Date__c != null) {
            setContactIds.add(fee.Contact__c);
            selectedDueDates.add(fee.Due_Date__c);
            dueDateList.add(fee.Due_Date__c);

            if (nonHostelFeeTypes.contains(fee.Fee_Type__c)) {
                hasNonHostelFee = true;
            }
        }
    }

    if (setContactIds.isEmpty() || dueDateList.isEmpty()) {
        return errWrap; // Nothing to validate
    }

    dueDateList.sort();
    maxSelectedDueDate = dueDateList[dueDateList.size() - 1];
   
    if (!hasNonHostelFee) {
        return errWrap;
    }
        
    List<Student_Fee__c> pendingEarlierFees = [
        SELECT Id, Due_Date__c, Fee_Type__c
        FROM Student_Fee__c
        WHERE Contact__c IN :setContactIds
          AND Fee_Type__c IN :nonHostelFeeTypes
          AND Due_Date__c <= :maxSelectedDueDate
          AND Amount_Pending__c > 0
          AND Id NOT IN :lst_StuIds  
    ];

    if (!pendingEarlierFees.isEmpty()) {
        errWrap.DateError = 'Previous Year(s) is/are still pending. Only when they are cleared, this payment can be made';
    }

    return errWrap;
}
    @AuraEnabled
    public static Decimal getGrayQuestEmiAmount(Id contactId, List<Student_Fee__c> selectedFees, String mode) {
        try {
            Decimal amountToCalculate = 0;
            Set<String> includedFeeTypes = new Set<String>{
                    'University Fee',
                    'Tuition Fee',
                    'Hostel Fee',
                    'Transportation Fee',
                    'Miscellaneous Fee'
                };
            
            if(mode == 'single') {
                Student_Fee__c selectedFee = selectedFees[0];                
                if(selectedFee.Fee_Type__c == 'Tuition Fee' || selectedFee.Fee_Type__c == 'University Fee') {
                    amountToCalculate = getYearlyTotalAmount(contactId);
                } else {
                    amountToCalculate = selectedFee.Amount_Pending__c;
                }
            } else {                
                for(Student_Fee__c f : selectedFees) {                   
                    if (includedFeeTypes.contains(f.Fee_Type__c)) {
                        amountToCalculate += f.Amount_Pending__c;
                    }
                }
            }
            
            if(amountToCalculate <= 0) return 0;
            
            GrayQuest_Merchant_Details__c gqApi = GrayQuest_Merchant_Details__c.getValues('API_Key');
            GrayQuest_Merchant_Details__c gqClient = GrayQuest_Merchant_Details__c.getValues('Client_id');
            GrayQuest_Merchant_Details__c gqSecret = GrayQuest_Merchant_Details__c.getValues('Client_secret');
            GrayQuest_Merchant_Details__c emiUrl = GrayQuest_Merchant_Details__c.getValues('EMI_Plans_URL');
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(emiUrl.MerchantId__c + '?loan_amount=' + amountToCalculate + '&min_installment=true');
            req.setMethod('GET');
            req.setHeader('GQ-API-Key', gqApi.MerchantId__c);
            Blob headerValue = Blob.valueOf(gqClient.MerchantId__c + ':' + gqSecret.MerchantId__c);
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(headerValue));
            
            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                Map<String, Object> data = (Map<String, Object>)results.get('data');
                return Decimal.valueOf(String.valueOf(data.get('plan_total_emi_amount')));
            }
        } catch (Exception e) { return 0; }
        return 0;
    }
    
    @AuraEnabled
    public static GrayQuestResponse grayQuestGenerateLink(List<Student_Fee__c> lst_StuFeeDeatils, Decimal PartialAmount, String feeType) {
        if (lst_StuFeeDeatils == null || lst_StuFeeDeatils.isEmpty()) {
            throw new AuraHandledException('No fee records provided.');
        }
        
        Id conId = lst_StuFeeDeatils[0].Contact__c;
        Contact stud = [SELECT Id, Application_Number__c, Active_Semester__r.Term_Number__c FROM Contact WHERE Id = :conId LIMIT 1];
        
        Decimal finalAmount = 0;
        String description = '';
        List<Student_Fee__c> feesToProcess = new List<Student_Fee__c>();
        Set<String> includedFeeTypes = new Set<String>{
                    'University Fee',
                    'Tuition Fee',                    
                    'Transportation Fee',
                    'Miscellaneous Fee'
                };        
        
        if (feeType == 'single') {
            Student_Fee__c selectedFee = lst_StuFeeDeatils[0];
            if (selectedFee.Fee_Type__c == 'Tuition Fee' || selectedFee.Fee_Type__c == 'University Fee') {
               
                feesToProcess = [SELECT Id, Amount_Pending__c, Fee_Type__c, Program_Enrollment__c FROM Student_Fee__c 
                                 WHERE Contact__c = :conId AND Fee_Year__c = :getYearFromSem(stud) 
                                 AND (Fee_Type__c = 'Tuition Fee' OR Fee_Type__c = 'University Fee')
                                 AND Amount_Pending__c > 0 AND Cancelled__c = false];
            } else {
                feesToProcess.add(selectedFee);
            }
        } else {
            for (Student_Fee__c f : lst_StuFeeDeatils) {
                if (includedFeeTypes.contains(f.Fee_Type__c)) {
                    feesToProcess.add(f);
                }
            }
        }
        
        for(Student_Fee__c f : feesToProcess) {
            finalAmount += f.Amount_Pending__c;
            description += f.Fee_Type__c + ', ';
        }
        
        if (finalAmount <= 0) finalAmount = PartialAmount;
        String refId = Utility.generateRandomNumber();
       
        GrayQuestRequest gqReq = new GrayQuestRequest();
        gqReq.student_id = stud.Application_Number__c;
        gqReq.reference_id = refId;
        gqReq.fee_headers = new FeeHeaders();
        gqReq.fee_headers.total_payable = finalAmount;
        gqReq.fee_headers.current_payable = finalAmount;
        
        String siteUrl = !Test.isRunningTest() ? Network.getLoginUrl(Network.getNetworkId()).replace('/login', '') : '';
        gqReq.redirection = new Redirection();
        gqReq.redirection.success_url = siteUrl + '/GrayQuestResponse';
        gqReq.redirection.error_url = siteUrl + '/GrayQuestResponse'; 
        gqReq.notes = new Map<String, String>{'school' => 'REVA University'};
         
        GrayQuest_Merchant_Details__c settings = GrayQuest_Merchant_Details__c.getValues('API_Key');
        HttpRequest req = new HttpRequest();
        req.setEndpoint(GrayQuest_Merchant_Details__c.getValues('Redirect_URL').MerchantId__c + GrayQuest_Merchant_Details__c.getValues('Slug').MerchantId__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('GQ-API-Key', settings.MerchantId__c);
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(GrayQuest_Merchant_Details__c.getValues('Client_id').MerchantId__c + ':' + GrayQuest_Merchant_Details__c.getValues('Client_secret').MerchantId__c)));
        req.setBody(JSON.serialize(gqReq));
        
        HttpResponse res = new Http().send(req);
        GrayQuestResponse gqRes = (GrayQuestResponse)JSON.deserialize(res.getBody(), GrayQuestResponse.class);        
      
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201) {
           
            Student_Payment__c header = new Student_Payment__c(
                Amount__c = finalAmount,
                Contact__c = conId,
                Fee_Type__c = description.length() > 250 ? description.substring(0, 250) : description,
                Reference_Id__c = refId,
                Payment_Gateway__c = 'GrayQuest',
                Payment_Status__c = 'Payment Link Created',
                Mode_of_Payment__c = 'Online',
                Payment_Date_Time__c = System.now(),
                Payment_Url__c = gqRes.data != null ? gqRes.data.redirection_url : null
            );
            insert header;
            
            List<Student_Fee_Payment__c> lines = new List<Student_Fee_Payment__c>();
            for(Student_Fee__c f : feesToProcess) {
                lines.add(new Student_Fee_Payment__c(
                    Student_Payment__c = header.Id,
                    Student_Fee__c = f.Id,
                    Amount__c = f.Amount_Pending__c,
                    Line_Item_Payment_Gateway__c = 'GrayQuest',
                    Reference_Id__c = refId,
                    Mode_of_Payment__c = 'Online',
                    Line_Item_Payment_Status__c = 'Payment Link Created',
                    Transaction_Date_Time__c = System.now()
                ));
            }
            insert lines;
        }
        
        return gqRes;
    }
    
    private static String getYearFromSem(Contact c) {
        if (c.Active_Semester__r.Term_Number__c == null) return '';
        Integer term = (Integer)c.Active_Semester__r.Term_Number__c;
        if (term <= 2) return '1st Year';
        if (term <= 4) return '2nd Year';
        if (term <= 6) return '3rd Year';
        if (term <= 8) return '4th Year';
        return '5th Year';
    }
    private static Decimal getYearlyTotalAmount(Id contactId) {
        Contact stud = [SELECT Id,Active_Semester__c,Active_Semester__r.Term_Number__c FROM Contact WHERE Id = :contactId LIMIT 1];
        String feeyear = '';
        
        if (stud.Active_Semester__c != null && stud.Active_Semester__r.Term_Number__c != null) {
            Integer term = (Integer)stud.Active_Semester__r.Term_Number__c;
            if (term == 1 || term == 2) feeyear = '1st Year';
            else if (term == 3 || term == 4) feeyear = '2nd Year';
            else if (term == 5 || term == 6) feeyear = '3rd Year';
            else if (term == 7 || term == 8) feeyear = '4th Year';
            else if (term == 9 || term == 10) feeyear = '5th Year';
        }
        
        AggregateResult[] groupedResults = [SELECT SUM(Amount_Pending__c)amt FROM Student_Fee__c 
                                            WHERE Contact__c = :contactId 
                                            AND Fee_Year__c = :feeyear 
                                            AND (Fee_Type__c = 'Tuition Fee' OR Fee_Type__c = 'University Fee')
                                            AND Amount_Pending__c > 0 
                                            AND Cancelled__c = false];
        
        return (groupedResults[0].get('amt') != null) ? (Decimal)groupedResults[0].get('amt') : 0;
    }
    @AuraEnabled
    public static rezorpayResponseCall razorPayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType)
    {
        string Name = '';
        decimal totAmt = PartialAmount;
        string email = '';
        string mobile = '';
        string discription = '';
        string contactId = '';
        string ProgEnrollId='';
        string RefId = Utility.generateRandomNumber();
        system.debug('RefId==>'+RefId);
        list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        //  map<string,string> mapStuFee = new map<string,string>();
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            //totAmt = totAmt + fee.Amount_Pending__c;
            Name = fee.Contact__r.Name;
            email = fee.Contact__r.Email;
            mobile = fee.Contact__r.MobilePhone;
            // mobile = '9573248467';
            system.debug('mobile==>'+mobile);
            discription = discription + fee.Fee_Type__c+',';
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
        //objStuFeePay.Payment_Date_Time__c = system.now().addHours(5).addMinutes(30);
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        lstStuPayment.add(objStuFeePay);
        
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        
        if(lstStuPayment.size() > 0){
            
            razorPayRequestCall rq = new razorPayRequestCall();
            string amt = string.valueof(totAmt.round(System.RoundingMode.HALF_DOWN));
            amt = amt + '00';
            system.debug('amt==>'+amt);
            rq.ramount = decimal.valueof(amt);
            rq.rcurrency = 'INR';
            rq.accept_partial = false;
            //rq.first_min_partial_amount = 100;
            rq.expire_by = 1786948311;
            rq.reference_id = RefId;
            //  rq.reference_id = 'Ref-0002';
            rq.description = discription;
            rq.reminder_enable = true;
            rq.callback_url = Razorpay_Details__c.getValues('CallbackUrl').Value__c;
            rq.callback_method = 'get';
            
            customerWrp cw = new customerWrp();
            cw.name = Name;
            cw.contact = Mobile;
            cw.email = email;
            rq.customer = cw;
            
            notifyWrp nw = new notifyWrp();
            nw.sms = true;
            nw.email=true;
            rq.notify = nw;
            
            notesWrp nt = new notesWrp();
            nt.paymentType = 'FeePayment';
            nt.reference_id = RefId;
            rq.notes = nt;
            
            string jsonbody = json.serialize(rq);
            jsonbody = jsonbody.replace('"rcurrency"', '"currency"');
            jsonbody = jsonbody.replace('"ramount"', '"amount"'); 
            system.debug('jsonbody==>'+jsonbody);
            string endpoint = Razorpay_Details__c.getValues('Razorpay Endpoint').Value__c; 
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json'); 
            req.setBody(jsonbody);
            //System.debug('+++++++++++++'+jsonbody);
            //String username = Razorpay_Details__c.getValues('UserName').Value__c;
            //String password = Razorpay_Details__c.getValues('Password').Value__c;
            
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
            System.debug('++++reqBody++++++++'+ req );
            System.debug('++++resBody++++++++'+res.getBody());
            system.debug('====status code===='+res.getStatusCode());
            
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
            dblog.Method_Name__c = 'razorPayGenratePaymentLink';
            dblog.Processing_API_Name__c = 'RazorPay';            
            dblog.Request__c = req.getBody();
            dblog.Response__c = res.getBody();
            dblog.User_Id__c = UserInfo.getUserId();
            
            if(res.getStatusCode() == 200)
            {                      
                reswrap =  (rezorpayResponseCall)System.JSON.deserialize(resBody, rezorpayResponseCall.class);
                reswrap.statusCode = res.getStatusCode();              
                
                list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
                // for(Student_Payment__c sp : lstStuPayment){
                objStuFeePay.Payment_Link_Id__c = reswrap.id;
                objStuFeePay.Payment_Url__c = reswrap.short_url;
                objStuFeePay.Payment_Status__c = 'Payment Link Created';
                //}
                insert objStuFeePay;
                for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                    Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();   
                    if(feeType == 'single'){                 
                        sfp.Amount__c = totAmt;
                    }
                    else{
                        sfp.Amount__c = objstuFee.Amount_Pending__c;
                    }
                    sfp.Mode_of_Payment__c = 'Online';
                    sfp.Payment_Link_Id__c = reswrap.id;
                    sfp.Student_Fee__c =  objstuFee.id;   //mapStuFee.get(objstuFee.Fee_Type__c);
                    sfp.Student_Payment__c = objStuFeePay.id;
                    sfp.Line_Item_Payment_Gateway__c = 'Razorpay';
                    sfp.Reference_Id__c = RefId;
                    lstSfp.add(sfp);
                }
                //system.debug('==lstStuPayment==='+lstStuPayment);
                insert lstSfp;
                // system.debug('===after insert==='+lstSfp);
                dblog.Status__c = 'Success';
            }
            else{
                reswrap.statusCode = res.getStatusCode();
                dblog.Status__c = 'Failure';
            }
            insert dblog;
        }
        // system.debug('===reswrap==='+reswrap);
        return reswrap;
    }    
    @AuraEnabled
    public static rezorpayResponseCall BillDeskPayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType,string stuFeePayRecId)
    {
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        string Name = '';
        decimal totAmt = PartialAmount;
        string email = '';
        string mobile = '';
        string mobilevalue='';
        string contactId = '';
        string studentUniqueId = '';
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();
        list<Student_Payment__c> lstStuPayment = new list<Student_Payment__c>();
        System.debug('studentDetails1==>'+lst_StuFeeDeatils);
        Set<Id> stuFeeIdSet = new Set<Id>();
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            stuFeeIdSet.add(fee.Id);
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
        system.debug('objStuFeePay.Amount__c**********'+objStuFeePay.Amount__c);
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        //  objStuFeePay.Mode_of_Payment__c = 'Online';
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        lstStuPayment.add(objStuFeePay);
        system.debug('size===>'+lst_StuFeeDeatils.size());
        if(lstStuPayment.size() > 0){
            string str = '<TXNDATA><TXNSUMMARY><REQID>PGECOM201</REQID><PGMERCID>'+Billdesk_Merchant_Details__c.getValues('MainMerchant').MerchantId__c+'</PGMERCID>';
            str += '<RECORDS>'+lst_StuFeeDeatils.size()+'</RECORDS>';
            str += '<PGCUSTOMERID>'+RefId+'</PGCUSTOMERID>';
            str += '<AMOUNT>'+totAmt+'.00</AMOUNT>';
            dateTime dt = system.now();
            string strDt =string.valueof(dt);
            String newStrDt = strDt.replaceAll('[^0-9]', '');
            str += '<TXNDATE>'+newStrDt+'</TXNDATE></TXNSUMMARY>';
            
            integer count = 1;
            //system.debug('++++++++'+feeType);
            for(Student_Fee__c fee : lst_StuFeeDeatils)
            {
                str += '<RECORD ID="'+count+'"><MERCID>'+Billdesk_Merchant_Details__c.getValues(fee.Fee_Type__c).MerchantId__c+'</MERCID>';
                String amountToDisplay = (fee.Amount_Pending__c == Math.floor(fee.Amount_Pending__c)) 
                    ? String.valueOf(fee.Amount_Pending__c.intValue()) 
                    : String.valueOf(fee.Amount_Pending__c.setScale(2));
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
            system.debug('mainStr642'+mainStr);
            
            string endPoint = Billdesk_Merchant_Details__c.getValues('PaymentLink').MerchantId__c;
            Http http1 = new Http();
            HttpRequest httpReq1 = new HttpRequest();
            HttpResponse httpRes1 = new HttpResponse();
            httpReq1.setEndpoint(endPoint);
            System.debug('EndPoint-->> '+endPoint);
            httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            string payload = 'msg='+mainStr;
            System.debug('Stage1'+payload);
            httpReq1.setbody(payload);
            httpReq1.setMethod('POST');
            httpReq1.setTimeout(120000);
            httpRes1 = http1.send(httpReq1);
            
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
            dblog.Method_Name__c = 'BillDeskPayGenratePaymentLink';
            dblog.Processing_API_Name__c = 'BillDesk';            
            dblog.Request__c = httpReq1.getBody();
            dblog.Response__c = httpRes1.getBody();
            dblog.User_Id__c = UserInfo.getUserId();
            
            string statusCode;
            if(httpRes1.getStatusCode() == 200){
                string httpreq = httpReq1.getBody();
                string strXml = httpRes1.getBody();
                system.debug('httpreq-->>>>'+httpreq);
                System.debug('strXml-->>>> '+strXml);
                Dom.Document doc = new Dom.Document();  
                doc.load(strXml);
                Dom.XMLNode rootElement = doc.getRootElement();
                
                for(Dom.XMLNode child1 : rootElement.getChildElements())
                {
                    system.debug('child1'+child1);
                    for(Dom.XMLNode child2 : child1.getChildElements())
                    {   system.debug('child2'+child2);
                     if(child2.getName() == 'TXNSUMMARY'){   
                         for(Dom.XMLNode child3 : child2.getChildElements()){
                             system.debug('Child3Elements===>'+child3);
                             if(child3.getName() == 'STATUSCODE'){
                                 system.debug('getNme===>'+child3.getName()+child3.getText());
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
                string returnUrl = Billdesk_Merchant_Details__c.getValues('CallbackUrl').MerchantId__c;
                System.debug('Stage2 '+baseReq);
                string checkSum =  baseReq+midReq+returnUrl;           
                String genertedcheckSum = calculateCheckSum(checkSum);
                genertedcheckSum = genertedcheckSum.toUppercase();
                checkSum = checkSum+'|'+genertedcheckSum;
                // system.debug('checkSum===>'+checkSum);
                
                string ep = Billdesk_Merchant_Details__c.getValues('PaymentEndPoint').MerchantId__c+checkSum;
                reswrap.short_url = ep;
                reswrap.statusCode = 200; 
                Student_Payment__c objStuFeePay1 = new Student_Payment__c();
                Student_Payment__c checkForSplitObject = checkForSplitPayment(stuFeeIdSet , totAmt);
                system.debug('checkForSplitObject*************'+checkForSplitObject);
                if( checkForSplitObject!=null && !String.isEmpty(checkForSplitObject.Id)){
                    Student_Payment__c objStuFe = new Student_Payment__c();
                    objStuFe.Reference_Id__c = RefId;
                    objStuFe.Billdesk_Url__c = ep;
                    objStuFe.Contact__c = contactId;
                    objStuFe.Payment_Status__c = 'Payment Link Created';
                    objStuFe.Payment_Gateway__c = 'Billdesk';
                    objStuFe.Mode_of_Payment__c = 'Online';
                    objStuFe.Id = checkForSplitObject.Id;
                    //AddedbyRajashekarAug012024
                    if(objStuFe.Program_Enrollment__c == null || objStuFe.Program_Enrollment__c == ''){
                        objStuFe.Program_Enrollment__c = ProgEnrollId;
                    }
                    //endshere
                    update objStuFe;             
                    system.debug('update ObjectFeePay1**********'+objStuFe);
                }else{
                    
                    objStuFeePay1.Reference_Id__c = RefId;
                    objStuFeePay1.Amount__c = totAmt;
                    objStuFeePay1.Billdesk_Url__c = ep;
                    objStuFeePay1.Contact__c = contactId;
                    objStuFeePay1.Payment_Status__c = 'Payment Link Created';
                    objStuFeePay1.Payment_Gateway__c = 'Billdesk';
                    objStuFeePay1.Mode_of_Payment__c = 'Online';
                    objStuFeePay1.Fee_Type__c = discription; 
                    objStuFeePay1.Program_Enrollment__c = ProgEnrollId;
                    insert objStuFeePay1;
                    system.debug('Insert ObjectFeePay1**********'+objStuFeePay);
                }
                
                
                //  system.debug('==stu payment id==='+objStuFeePay.id);
                //AddedByRajashekar30july24
                list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
                
                if(stuFeePayRecId != null && stuFeePayRecId != ''){
                    Student_Fee_Payment__c sfpRec = [select id,Name from Student_Fee_Payment__c where id=:stuFeePayRecId];
                    for(Student_Fee__c objstuFee : lst_StuFeeDeatils){
                        if(feeType == 'single'){
                            sfpRec.Amount__c = totAmt;
                        }
                        else{
                            sfpRec.Amount__c = objstuFee.Amount_Pending__c;
                        }
                        sfpRec.Mode_of_Payment__c = 'Online';
                        sfpRec.Reference_Id__c = RefId;
                        /* sfp.Student_Fee__c =  objstuFee.id; 
if(checkForSplitObject != null && !String.isEmpty(checkForSplitObject.Id)){
sfp.Student_Payment__c = checkForSplitObject.Id;
}else{
sfp.Student_Payment__c = objStuFeePay1.id;
}*/
                        sfpRec.Line_Item_Payment_Gateway__c = 'Billdesk';                   
                    } 
                    update sfpRec;
                    //Endshere30july2024
                }else{
                    
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
                        if(checkForSplitObject != null && !String.isEmpty(checkForSplitObject.Id)){
                            sfp.Student_Payment__c = checkForSplitObject.Id;
                        }else{
                            sfp.Student_Payment__c = objStuFeePay1.id;
                        }
                        sfp.Line_Item_Payment_Gateway__c = 'Billdesk';                   
                        lstSfp.add(sfp);
                    }     
                }
                
                if(lstSfp.size() > 0){
                    /*********changed on 2907 hostel********/
                    insert lstSfp;
                    // upsert lstSfp;
                    set<Id> studentPaymentId = new Set<Id>();
                    set<Id> studentFeeId = new Set<Id>();
                    for(Student_Fee_Payment__c eStr : lstSfp){
                        if(!String.isEmpty(eStr.Student_Payment__c)){
                            studentPaymentId.add(eStr.Student_Payment__c);
                        }
                        if(!String.isEmpty(eStr.Student_Fee__c)){
                            studentFeeId.add(eStr.Student_Fee__c);
                        }
                    }
                    list<Student_Fee_Payment__c> deleteNotTransctionList = [SELECT ID FROM Student_Fee_Payment__c 
                                                                            WHERE  SF_Transaction_ID__c = NULL  
                                                                            AND Student_Fee__c IN : studentFeeId  AND Line_Item_Payment_Status__c = 'Success'];
                    system.debug('deleteNotTransctionList@@@@@@@@@@@@@@@@@'+deleteNotTransctionList);
                    if(!deleteNotTransctionList.isEmpty()){
                        // delete deleteNotTransctionList;
                    }
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
    
    @AuraEnabled
    public static rezorpayResponseCall easypayGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType)
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
            contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;  
            discription = discription + fee.Fee_Type__c+',';       
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
            para1 += '|'+Name+'|'+email+'|'+mobile+'|'+RefId;  
            
            string plainUrl = baseUrl + para1 + '&optional fields=xyz|xyz&returnurl='+EasyPay_Details__c.getValues('CallbackUrl').Value__c;
            plainUrl += '&Reference No='+RefId+'&submerchantid='+EasyPay_Details__c.getValues('Submerchantid').Value__c;
            plainUrl += '&transaction amount='+string.valueof(PartialAmount)+'&paymode=9';
            system.debug('PlainUrl+++++++'+plainUrl); 
            string str;
            if(!test.isRunningTest()){
                str = calculateAes(para1);
                
                str += '&optional fields='+calculateAes('xyz|xyz');
                str += '&returnurl='+calculateAes(EasyPay_Details__c.getValues('CallbackUrl').Value__c)+'&Reference No='+calculateAes(RefId)+'&submerchantid=';
                str += calculateAes(EasyPay_Details__c.getValues('Submerchantid').Value__c)+'&transaction amount='+calculateAes(string.valueof(PartialAmount))+'&paymode='+calculateAes('9');
            }
            else{
                str = 'test';
            }
            system.debug('++++++++'+str);
            baseUrl = baseUrl + str;
            system.debug('++++++++'+baseUrl);
            /* 
Debug_Log__c dblog = new Debug_Log__c();
dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
dblog.Method_Name__c = 'easypayGenratePaymentLink';
dblog.Processing_API_Name__c = 'EasyPay';            
dblog.Request__c = httpReq1.getBody();
dblog.Response__c = httpRes1.getBody();
dblog.User_Id__c = UserInfo.getUserId();
*/
            
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
            
        }
        else{
            reswrap.statusCode = 101;
            // dblog.Status__c = 'Failure';
        }
        system.debug('+++++++++++'+reswrap);
        return reswrap;
    }
    
    
    @AuraEnabled
    public static rezorpayResponseCall PaytmGenratePaymentLink(list<Student_Fee__c> lst_StuFeeDeatils,decimal PartialAmount,string feeType)
    {
        rezorpayResponseCall reswrap = new rezorpayResponseCall();
        decimal totAmt = PartialAmount;
        string applicationNo = '';
        string contactId = '';
        string ProgEnrollId='';
        string discription = '';
        string RefId = Utility.generateRandomNumber();  
        
        for(Student_Fee__c fee : lst_StuFeeDeatils)
        {
            applicationNo = fee.Contact__r.Application_Number__c;
            contactId = fee.Contact__c;
            ProgEnrollId = fee.Program_Enrollment__c;  
            discription = discription + fee.Fee_Type__c+','; 
        }
        
        Student_Payment__c objStuFeePay = new Student_Payment__c();
        objStuFeePay.Amount__c = totAmt;
        objStuFeePay.Contact__c = contactId;
        objStuFeePay.Fee_Type__c = discription; 
        objStuFeePay.Reference_Id__c = RefId;
        objStuFeePay.Program_Enrollment__c = ProgEnrollId;
        
        Map<string, string> parammap = new Map<string,string>();
        parammap.put('MID',Paytm_Details__c.getValues('MID').Value__c);
        parammap.put('ORDER_ID',RefId);
        
        paytmMain ptm = new paytmMain();
        ptm.body = new PaytmParamClass();
        ptm.body.requestType = 'Payment';
        ptm.body.mid = Paytm_Details__c.getValues('MID').Value__c;
        ptm.body.orderId = RefId;
        ptm.body.websiteName = 'DEFAULT';
        ptm.body.callbackUrl = Paytm_Details__c.getValues('CallbackUrl').Value__c;
        ptm.body.txnAmount = new paymentDetails();
        ptm.body.txnAmount.value = string.valueof(PartialAmount);
        ptm.body.txnAmount.ccurrency = 'INR';
        ptm.body.userInfo = new UserDetails();
        ptm.body.userInfo.custId = applicationNo;
        
        string jsonStr = JSON.serialize(ptm.body);
        system.debug('jsonStr+++++++++'+jsonStr);
        system.debug('Key+++++++++'+Paytm_Details__c.getValues('Merchant Key').Value__c);
        string checksumstring = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Details__c.getValues('Merchant Key').Value__c, jsonStr);
        system.debug('checksumstring+++++++++'+checksumstring);
        ptm.head = new headDetails();
        ptm.head.signature = checksumstring;
        
        system.debug('Ptm++++++++'+ptm);
        
        string baseUrl = Paytm_Details__c.getValues('Endpoint').Value__c + 'mid=' +Paytm_Details__c.getValues('MID').Value__c+'&' ;
        baseUrl += 'orderId='+RefId;
        
        
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
        dblog.Class_Name__c = 'FEE_StudentPayment_Ctrl';
        dblog.Method_Name__c = 'paytmGenratePaymentLink';
        dblog.Processing_API_Name__c = 'Paytm';            
        dblog.Request__c = req.getBody();
        dblog.Response__c = res.getBody();
        dblog.User_Id__c = UserInfo.getUserId();
        
        
        objStuFeePay.Reference_Id__c = RefId;
        //  objStuFeePay.Billdesk_Url__c = baseUrl;
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
                reswrap.statusCode = 200;
                reswrap.id = Paytm_Details__c.getValues('MID').Value__c;
                reswrap.status = RefId;
                reswrap.short_url = Paytm_Details__c.getValues('PaymentEndPoint').Value__c +'mid='+Paytm_Details__c.getValues('MID').Value__c+'&orderId='+RefId;
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
    
    public static string calculateCheckSum(string mainStr){
        String testKey = Billdesk_Merchant_Details__c.getValues('Checksum').MerchantId__c;
        String algorithmName = 'hmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(mainStr) , Blob.valueOf(testKey));
        //system.debug('++++'+hmacData);
        return EncodingUtil.convertToHEX(hmacData);
        
    }
    
    public static string calculateAes(string mainStr){
        /*String Key = EasyPay_Details__c.getValues('AES key').Value__c;
functions.Function accountFunction = functions.Function.get(label.FEE_Easypay_Function_Name);
functions.FunctionInvocation invocation = accountFunction.invoke('{ "input" : "' +mainStr +'", "key" : "'+ key + '"}');
Map<String, Object> mp_out = (Map<String, Object>) JSON.deserializeUntyped(invocation.getResponse()) ;
System.debug('Got response ' + mp_out);
string decode  = String.valueof(mp_out.get('encodedStr')).unescapeHtml4();
return decode;     */
        return '';
    }
    
    @AuraEnabled
    public static string singleRecordCheckLateFee(string feeId){
        
        Student_Fee__c objStuFee = [select id,Fee_Type__c,Parent_Student_Fee__c,Amount_Pending__c,Contact__c FROM Student_Fee__c WHERE id =: feeId];
        
        string sfId = '';
        if(string.isBlank(objStuFee.Parent_Student_Fee__c)){
            for(Student_Fee__c objSf : [select id,Parent_Student_Fee__c FROM Student_Fee__c WHERE Parent_Student_Fee__c =: objStuFee.id AND 
                                        Fee_Type__c =: objStuFee.Fee_Type__c AND Amount_Pending__c >: 0 AND Contact__c =: objStuFee.Contact__c]){
                                            sfId = objSf.id;
                                        }
        }
        else{
            //  sfId = objStuFee.Parent_Student_Fee__c;
        }
        
        string errorMsg = 'Success';
        if(string.isNotBlank(sfId)){
            errorMsg = 'Late Fee is Pending';
        }                
        return errorMsg;
    }
    
    @AuraEnabled
    public static list<string> multiRecordCheckLateFee(string feeId){
        list<string> lstIds = new list<string>();
        Student_Fee__c objStuFee = [select id,Parent_Student_Fee__c,Contact__c FROM Student_Fee__c WHERE id =: feeId];
        
        string sfId = '';
        if(string.isBlank(objStuFee.Parent_Student_Fee__c)){
            for(Student_Fee__c objSf : [select id,Parent_Student_Fee__c FROM Student_Fee__c WHERE Parent_Student_Fee__c =: objStuFee.id 
                                        AND Amount_Pending__c >: 0 AND Contact__c =: objStuFee.Contact__c]){
                                            lstIds.add(objSf.id);
                                        }
        }
        else{
            lstIds.add(objStuFee.Parent_Student_Fee__c);
        }
        
        return lstIds;
    }
    
    /***********************New Implementation*******************************/
    public static Student_Payment__c checkForSplitPayment(Set<Id> stuFeeIdSet, Decimal Amount){
        if(!stuFeeIdSet.isEmpty()){
            list<Student_Fee_Payment__c> studFeePayList = [SELECT Id, Name, Student_Payment__c, 
                                                           Student_Payment__r.Amount__c,
                                                           Student_Payment__r.Split_Booking_Fee__c,
                                                           Student_Payment__r.Partial_Booking_Fee__c,
                                                           Student_Payment__r.Pending_Booking_Fee_FF__c 
                                                           FROM Student_Fee_Payment__c 
                                                           WHERE Student_Fee__c IN : stuFeeIdSet 
                                                           AND Student_Payment__r.Amount__c =: Amount AND Student_Payment__r.Payment_Status__c != 'Success'];
            
            system.debug('inside the checkForSplitPayment_studFeePayList**************'+studFeePayList);
            set<Id> studPaymentIdSet = new set<Id>();
            for(Student_Fee_Payment__c stdFee : studFeePayList){
                if(stdFee.Student_Payment__r.Split_Booking_Fee__c == true){
                    if(!String.isEmpty(stdFee.Student_Payment__c)){
                        studPaymentIdSet.add(stdFee.Student_Payment__c);
                    }    
                }
            }
            
            if(!studPaymentIdSet.isEmpty()){
                Student_Payment__c studPaymentList = [SELECT ID, Amount__c, Contact__c, Fee_Type__c,Reference_Id__c, Program_Enrollment__c  
                                                      FROM Student_Payment__c 
                                                      WHERE ID IN : studPaymentIdSet lIMIT 1];
                return studPaymentList;
            }    
        }
        return null;
    }
    /********************************************************/
    
    
    
    /***********************AddedbyRajashekarAug272024*******************************/      
    @Auraenabled
    public static string getLoggedInUserProfile(){
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :currentUserId LIMIT 1];
        String profileName = currentUser.Profile.Name;
        System.debug('CurrentUserProfileName==>: ' + profileName);
        return profileName;
    }    
    /****************************Ends here*****************************************/
    
    
    public class StudentFeeWrapper
    {
        @AuraEnabled public list<CheckboxWrapper> lst_CheckboxWrap {get;set;}
        @AuraEnabled public list<Student_Fee__c> lst_StuPaidDetails {get;set;}
        @AuraEnabled public list<Student_Payment__c> lst_StuPaymentDetails {get;set;}
        @AuraEnabled public string objStuname {get;set;}
        @AuraEnabled public string objAppNumber {get;set;}
        @AuraEnabled public string objSrnNumber {get;set;}
        @AuraEnabled public decimal TotalAmount {get;set;}
        @AuraEnabled public decimal TotalPendingAmount {get;set;}
        @AuraEnabled public decimal TotalPaidAmount {get;set;}
        
        public StudentFeeWrapper()
        {
            lst_StuPaidDetails = new list<Student_Fee__c>();
            lst_StuPaymentDetails = new list<Student_Payment__c>();
            lst_CheckboxWrap = new list<CheckboxWrapper>();
            TotalAmount = 0;
            TotalPendingAmount = 0;
            TotalPaidAmount = 0;
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
    public class ErrorWrapper
    {
        @AuraEnabled public string DateError {get;set;}
        @AuraEnabled public Integer NoOfInstallments {get;set;}
    }  
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
        @AuraEnabled public string reference_id{get;set;}
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
    public class GrayQuestRequest {
    @AuraEnabled public String student_id;
    @AuraEnabled public String reference_id;
    @AuraEnabled public FeeHeaders fee_headers;
    @AuraEnabled public Map<String, String> notes;
    @AuraEnabled public Redirection redirection;
}

public class FeeHeaders {
    @AuraEnabled public Decimal total_payable; 
    @AuraEnabled public Decimal current_payable;
}

public class Redirection {
    @AuraEnabled public String success_url;
    @AuraEnabled public String error_url;
}

public class GrayQuestResponse {
    @AuraEnabled public Boolean success;
    @AuraEnabled public Integer status_code;
    @AuraEnabled public String message;
    @AuraEnabled public GrayQuestData data;
}

public class GrayQuestData {
    @AuraEnabled public String redirection_url;
}
}