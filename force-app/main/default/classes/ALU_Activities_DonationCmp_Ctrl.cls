public class ALU_Activities_DonationCmp_Ctrl {
    
    @AuraEnabled
    public static List<Alumni_Activities__c> getAluActivitieslist(){
        Id Alumni_Activities_FundRaisng_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Fund Raising Request').getRecordTypeId();
        
        return [SELECT Id, Name, Details__c, Venue__c, RecordTypeId,Contact__c,Funds_Raised_So_Far__c,  Date__c,Target_Fund_Raising_Amount__c,Activity_Name__c                                                     
                FROM Alumni_Activities__c  WHERE RecordTypeId =: Alumni_Activities_FundRaisng_RecType];
    }
    
    @AuraEnabled
    public static Alumni_Activities__c getAluActivitiySingle(string alId){
        Id Alumni_Activities_FundRaisng_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Fund Raising Request').getRecordTypeId();
        
        return [SELECT Id, Name, Details__c, Activity_Name__c, Venue__c, RecordTypeId,Contact__c,  Date__c,Target_Fund_Raising_Amount__c                                                     
                FROM Alumni_Activities__c  WHERE Id=:alId AND RecordTypeId =: Alumni_Activities_FundRaisng_RecType];
    }
    @AuraEnabled
    public static void createAluminiumActPay(string alActId ,decimal amountPaying ){
        string str_ContId;
        for(user objuser : [SELECT id, Name, ContactId FROM user WHERE id =: UserInfo.getUserId()])
        {
            str_ContId = objuser.ContactId;
        }
        Id Alumni_Activities_FundRaisng_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Fund Raising Request').getRecordTypeId();
        /*List<Alumni_Activities__c>  alActList = [SELECT Id, Name, Details__c, Venue__c, RecordTypeId,Contact__c,  Date__c,Target_Fund_Raising_Amount__c                                                     
FROM Alumni_Activities__c  WHERE Id=:alActId AND RecordTypeId =: Alumni_Activities_FundRaisng_RecType];*/
        List<Alumni_Payments__c> alpayList =new List<Alumni_Payments__c>();
        for(Alumni_Activities__c objalAct:[SELECT Id, Name, Details__c, Venue__c, RecordTypeId,Contact__c,  
                                           Date__c,Target_Fund_Raising_Amount__c                                                     
                                           FROM Alumni_Activities__c  WHERE Id=:alActId AND RecordTypeId =: Alumni_Activities_FundRaisng_RecType]){
                                               Alumni_Payments__c objAlPay = new Alumni_Payments__c();
                                               objAlPay.Amount__c = amountPaying;
                                               objAlPay.Contact__c = str_ContId;
                                               objAlPay.Payment_Date__c = system.today();
                                               objAlPay.Alumni_Activities_Fund_Raising_Request__c = objalAct.Id;
                                               alpayList.add(objAlPay);
                                           }
        
        if(!alpayList.isEmpty()){
            insert alpayList;
        }
    }
    
    
    @AuraEnabled
    public static List<Alu_Activity_WrapperClass> getAlumniActvities(){
        string str_ContId;
        Id Alumni_Activities_FundRaisng_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Fund Raising Request').getRecordTypeId();
        List<Alu_Activity_WrapperClass> aluActivityList = new List<Alu_Activity_WrapperClass>();
        for(user objuser : [SELECT id, Name, ContactId FROM user WHERE id =: UserInfo.getUserId()])
        {
            str_ContId = objuser.ContactId;
        }
        for(Alumni_Activities__c objAlumActivities : [SELECT id, name, Details__c, Venue__c,Funds_Raised_So_Far__c, RecordTypeId,Contact__c,  Date__c,Target_Fund_Raising_Amount__c                                                     
                                                      FROM Alumni_Activities__c WHERE RecordTypeId =: Alumni_Activities_FundRaisng_RecType] )
        {
            Alu_Activity_WrapperClass wrp = new Alu_Activity_WrapperClass();
            wrp.ActivityName = objAlumActivities.Name;
            wrp.ActivityDate = objAlumActivities.Date__c;
            wrp.FundRisingAmount   = objAlumActivities.Target_Fund_Raising_Amount__c;
            aluActivityList.add(wrp);
        }
        return aluActivityList;
    }
    public static void createAluminiumActivity(){
        //List<Alumni_Activities__c> aluActList = [SELECT Id,]
    }
    @AuraEnabled
    public static gateWayWrapper getMapDetails(){
        gateWayWrapper gtWrp = new gateWayWrapper();
        boolean razorpay = true;
        boolean billdesk = true;
        boolean paytm = true;
        boolean EazyPay = true;
        
        if(razorpay == true)
            gtWrp.map_PaymentGateway.put('RazorPay','RazorPay');
        if(paytm == true)
            gtWrp.map_PaymentGateway.put('PayTM','PayTM');
        if(EazyPay == true)
            gtWrp.map_PaymentGateway.put('EazyPay','EazyPay');
        if(billdesk == true)
            gtWrp.map_PaymentGateway.put('BillDesk','BillDesk');        
        system.debug('gtWrp '+gtWrp);
        gtWrp.Errmsg = 'Success';
        if(gtWrp.map_PaymentGateway.values().size() ==0)
        {
            gtWrp.Errmsg = 'Failure';
        }
        return gtWrp; 
    }
    @AuraEnabled
    public static PaymentResponseCall BillDeskPayGenratePaymentLink(list<Alumni_Activities__c> lstActivity,decimal PartialAmount,string feeType)
    {
        PaymentResponseCall reswrap = new PaymentResponseCall();
        string Name = '';
        decimal totAmt = PartialAmount;
        string email = '';
        string mobile = '';
        string contactId = '';
        string studentUniqueId = '';
        string ProgEnrollId='';
        string discription = '';
        string AlumniId;
        string RefId = Utility.generateRandomNumber();
        
        user currUser = new user();
        for(user objuser : [SELECT id, Name, ContactId,contact.Name,contact.Email,contact.MobilePhone,contact.SRN_No__c FROM user WHERE id =: UserInfo.getUserId()])
        {
            Name = objuser.contact.Name;
            email = objuser.contact.Email;
            mobile = objuser.contact.MobilePhone;
            contactId = objuser.ContactId;
            studentUniqueId = objuser.contact.SRN_No__c;
            currUser = objuser;
        }
        
        if(lstActivity != Null){
            for(Alumni_Activities__c pay : lstActivity)
            {                       
                discription = pay.Activity_Name__c;
                AlumniId = pay.id;                   
            }
        }
        else{
            discription = 'Voluntary Contribution';
        }
        
        
        
        string baseReq = Billdesk_Merchant_Details__c.getValues('Alumini Merchant').MerchantId__c+'|'+RefId+'|NA|'+totAmt+'.00|NA|NA|NA|INR|NA|R|'+Billdesk_Merchant_Details__c.getValues('Alumini Security Id').MerchantId__c+'|NA|NA|F|';
        string midReq = Name+'|'+email+'|'+mobile+'|'+RefId+'|'+studentUniqueId+'|NA|NA|';
        string returnUrl = Billdesk_Merchant_Details__c.getValues('Alumini Callback Url').MerchantId__c;
        
        string checkSum =  baseReq+midReq+returnUrl; 
        system.debug('Url+++++++'+checkSum);          
        String genertedcheckSum = calculateCheckSum(checkSum);
        genertedcheckSum = genertedcheckSum.toUppercase();
        checkSum = checkSum+'|'+genertedcheckSum;
        system.debug('Url1+++++++'+checkSum);
        string ep = Billdesk_Merchant_Details__c.getValues('PaymentEndPoint').MerchantId__c+checkSum;
        reswrap.short_url = ep;
        reswrap.statusCode = 200;     
        system.debug('Url2++++++'+ep);
        /*
        string payload = 'msg='+ep;
        string endPoint = 'https://uat.billdesk.com/pgidsk/PGIMerchantPayment'+payload;
            Http http1 = new Http();
            HttpRequest httpReq1 = new HttpRequest();
            HttpResponse httpRes1 = new HttpResponse();
            httpReq1.setEndpoint(endPoint);
            httpReq1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
           // string payload = 'msg='+ep;
           // httpReq1.setbody(payload);
            httpReq1.setMethod('POST');
            httpReq1.setTimeout(120000);
            httpRes1 = http1.send(httpReq1);
          system.debug('++++++++++++++'+httpRes1.getBody());
          
          while (httpRes1.getStatusCode() == 302) {
                httpReq1.setEndpoint(httpRes1.getHeader('Location'));
                httpRes1 = new Http().send(httpReq1);
            }  
          system.debug('++++++++++++++'+httpRes1.getBody());  
        */
        Alumni_Payments__c ap = new Alumni_Payments__c();
        ap.Alumni_Activities_Fund_Raising_Request__c = AlumniId;
        ap.Amount__c = totAmt;
        ap.Contact__c = contactId;
        ap.Description__c = discription;
        ap.Mode_of_Payment__c = 'Billdesk';
        ap.Payment_Date__c = system.today();
        ap.Payment_Status__c = 'Payment Link Created';
        ap.Payment_Url__c = ep;
        ap.Reference_Id__c = RefId;
        insert ap;
        
        Debug_Log__c dblog = new Debug_Log__c();
        dblog.Class_Name__c = 'ALU_Activities_DonationCmp_Ctrl';
        dblog.Method_Name__c = 'BillDeskPayGenratePaymentLink';
        dblog.Processing_API_Name__c = 'BillDesk';            
        dblog.Request__c = checkSum;
      //  dblog.Response__c = httpRes1.getBody();
        dblog.User_Id__c = UserInfo.getUserId();
        dblog.Alumni_Payment__c = ap.id;
        insert dblog;
        return reswrap;
    }
    
    public static string calculateCheckSum(string mainStr){
        String testKey = Billdesk_Merchant_Details__c.getValues('Alumini Checksum').MerchantId__c;
        String algorithmName = 'hmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(mainStr) , Blob.valueOf(testKey));
        //system.debug('++++'+hmacData);
        return EncodingUtil.convertToHEX(hmacData);
        
    }
    // ContentDocument Link Preview Code 
    @AuraEnabled
    public static ContentDocWraper GetDocument(string alumActivityId)
    {
        system.debug('=====>>>'+alumActivityId);
        ContentDocWraper objContDoc = new ContentDocWraper();
        List<ContentDocumentLink> lst_Cont = New List<ContentDocumentLink>();
        List<Alumni_Activities__c> lst_AlumniAct = New List<Alumni_Activities__c>();
        for(ContentDocumentLink objContLink: [SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,ContentDocument.FileExtension,
                                              ContentDocument.CreatedDate, ContentDocument.ContentSize ,ContentDocument.Owner.Name
                                              FROM ContentDocumentLink WHERE LinkedEntityId =: alumActivityId limit 1])
        {
            objContDoc.ContDocIds = objContLink.ContentDocumentId;
        }
        return objContDoc;
    }
    public class Alu_Activity_WrapperClass
    {
        @AuraEnabled public List<Alumni_Activities__c> list_AlumniActivies{get;set;}
        @AuraEnabled public string ActivityName;
        @AuraEnabled public date ActivityDate;
        @AuraEnabled public decimal FundRisingAmount;
    }
    public class gateWayWrapper
    {
        @AuraEnabled public Map<string,string> map_PaymentGateway {get;set;}
        @AuraEnabled public string Errmsg {get;set;}
        public gateWayWrapper()
        {
            map_PaymentGateway = new map<string,string>();
        }
    }
    public class PaymentResponseCall{
        @AuraEnabled public string id {get;set;}
        @AuraEnabled public string reference_id {get;set;}
        @AuraEnabled public string short_url {get;set;}
        @AuraEnabled public string status  {get;set;}
        @AuraEnabled public integer statusCode  {get;set;}
    }
    public class ContentDocWraper 
    {
        @AuraEnabled public string ContDocIds{get;set;}
    }
}