public class SAP_DemandAPI {
    public static void DemandCreationAPI(List<Id> demandIds){
        RecursiveTriggerHandler.isFirstTime = false;
        Debug_Log__c debugLog = new Debug_Log__c();
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Student_Fee__c>lst_StduentFees = new List<Student_Fee__c>();
        
        try
        {
            SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Demand_API');
            String endpointURL = mdt.EndPointURL__c;
            
            List<RequestBodyWrapper> RequestBodyWrapperList = new List<RequestBodyWrapper>();
            for(Student_Fee__c objStudentFee :[SELECT Id, OwnerId, IsDeleted, Name, Actual_Program_Fee__c, Amount_Paid__c, Concession__c, Due_Date__c, Fee_Name__c, 
                                               SRN_Number__c, Session__c, Fee_Type__c ,Cancelled__c,Tuition_Premium__c, Amount__c, Application_Number__c ,
                                               Scholarship__c, Scholarship_Category__c, Demand_Integration_Date__c,Premium__c FROM Student_Fee__c where Cancelled__c = false AND 
                                               Id In : demandIds])
            {
                RequestBodyWrapper objReqWrp = new RequestBodyWrapper();
                
                
                objReqWrp.Application_Number = objStudentFee.Application_Number__c != null ? objStudentFee.Application_Number__c : '';
                objReqWrp.Session = objStudentFee.Session__c != null ? objStudentFee.Session__c : '';
                objReqWrp.FeeName = objStudentFee.Name != null ? objStudentFee.Name : '';
                objReqWrp.Scholarship = objStudentFee.Scholarship__c != null ? objStudentFee.Scholarship__c : 0.00;
                objReqWrp.SRNNumber = objStudentFee.SRN_Number__c != null ? objStudentFee.SRN_Number__c : '';
                objReqWrp.Concession = objStudentFee.Concession__c != null ? objStudentFee.Concession__c : 0.00;
                objReqWrp.Fee_Name = objStudentFee.Fee_Type__c != null ? objStudentFee.Fee_Type__c : '';
                objReqWrp.Premium = objStudentFee.Premium__c != null ? objStudentFee.Premium__c : 0.00;
                objReqWrp.Due_date = objStudentFee.Due_Date__c != null ? objStudentFee.Due_Date__c : date.today();
                objReqWrp.Actual_Program_Fee = objStudentFee.Actual_Program_Fee__c != null ? objStudentFee.Actual_Program_Fee__c : 0.00;
                objReqWrp.SACCode = System.Label.SAP_SACCode;
                objReqWrp.Total_Amount = objStudentFee.Amount__c != null ? objStudentFee.Amount__c : 0.00;
                objReqWrp.SFDCRecordId = objStudentFee.Id;
                RequestBodyWrapperList.add(objReqWrp);
            }
            
            String requestBodyJson = JSON.serialize(RequestBodyWrapperList);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBodyJson);
            request.setTimeout(120000);
            
            HttpResponse response = new Http().send(request);
            
            Decimal statusCode = response.getStatusCode();
            String responseBody = response.getBody();
            
            
            debugLog.Request__c = request.getBody();
            debugLog.Response__c = response.getBody();
            debugLog.Status_Code__c = response.getStatusCode();
            insert debugLog;
            
            
            if (statusCode == 200) 
            {
                OuterResponseWrapper outerResponseWrapper = (OuterResponseWrapper) JSON.deserialize(response.getBody(), OuterResponseWrapper.class);
                List<ResponseWrapper> responseWrappers = outerResponseWrapper.Response;
                
                for (ResponseWrapper responseWrapper : responseWrappers) 
                {
                    
                    if (responseWrapper.statusCode == 0 && responseWrapper.SFDCRecordId != null && responseWrapper.SAPID != null) 
                    {
                        Student_Fee__c update_Student_Fee = new Student_Fee__c(Id = responseWrapper.SFDCRecordId);
                        update_Student_Fee.SAP_ID__c = responseWrapper.SAPID;
                        update_Student_Fee.Demand_Number__c = responseWrapper.SAPID;
                        update_Student_Fee.Integrated_with_SAP__c = true;
                        update_Student_Fee.Demand_Integration_Date__c = System.Today();
                        Debug_Log__c dblog = new Debug_Log__c();
                        dblog.Student_Fee__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Status__c = 'Success';
                        dblog.Status_Code__c = responseWrapper.statusCode;
                        dblog.Request__c = request.getBody();
                        lst_DbLogs.add(dblog);
                        lst_StduentFees.add(update_Student_Fee);
                    }
                    else if(responseWrapper.statusCode == 1){
                        Student_Fee__c update_Student_Fee = new Student_Fee__c(Id = responseWrapper.SFDCRecordId);
                        update_Student_Fee.Demand_Number__c = responseWrapper.SAPID;
                        update_Student_Fee.SAP_ID__c = responseWrapper.SAPID;
                        Debug_Log__c dblog = new Debug_Log__c();
                        dblog.Student_Fee__c  = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Status__c = 'Failure';
                        dblog.Request__c = request.getBody();
                        dblog.Status_Code__c = responseWrapper.statusCode;
                        lst_DbLogs.add(dblog);
                        lst_StduentFees.add(update_Student_Fee);
                    }
                }
                if (!lst_StduentFees.isEmpty()) 
                {
                    Database.UpsertResult[] upsertResults = Database.upsert(lst_StduentFees, Student_Fee__c.Fields.Id, false);
                    for (Integer i = 0; i < upsertResults.size(); i++) {
                        if (!upsertResults[i].isSuccess()) {
                            lst_DbLogs[i].Response__c += upsertResults[i].getErrors()[0].getMessage();
                        }
                    }
                }
                if (!lst_DbLogs.isEmpty()) {
                    insert lst_DbLogs;
                }
                
            } 
            else 
            {
                System.debug('Error: ' + statusCode + ' ' + response.getStatus());
            }
            
        }
        catch (Exception e) 
        {
            System.debug('An error occurred: ' + e.getMessage());
            debugLog.Response__c +='====='+e.getMessage();
            upsert debugLog;
        }
    }
    public  static Boolean isValidIdFormat(String idString) {
        Pattern idPattern = Pattern.compile('^[a-zA-Z0-9]{18}|[a-zA-Z0-9]{15}$');
        return idPattern.matcher(idString).matches();
    }
    public class OuterResponseWrapper {
        public List<ResponseWrapper> Response;
    }
    public class RequestBodyWrapper 
    {
        public String Application_Number;
        public string FeeName;
        public String Session;
        public Decimal Scholarship;
        public String SRNNumber;
        public Decimal Concession;
        public String Fee_Name;
        public Decimal Premium;
        public date Due_date;
        public Decimal Actual_Program_Fee;
        public String SACCode;
        public Decimal Total_Amount;
        public String SFDCRecordId;
        
        
    }
    
    public class ResponseWrapper 
    {
        public String SFDCRecordId;
        public Integer statusCode;
        public String statusMessage;
        public String SAPID;
        public String responseObject;
    }
    
    
}