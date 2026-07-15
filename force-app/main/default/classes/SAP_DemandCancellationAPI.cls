public class SAP_DemandCancellationAPI {
    
   // @future(callout= true)    
    public static void DemandCancellation_APIMethod(List<Id> demandIds){
        RecursiveTriggerHandler.isFirstTime = false;
        Debug_Log__c debugLog = new Debug_Log__c();
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Student_Fee__c>lst_StduentFees = new List<Student_Fee__c>();
        
        try
        {
            SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Demand_Cancellation_API');
            String endpointURL = mdt.EndPointURL__c;
            
            List<RequestBodyWrapper> RequestBodyWrapperList = new List<RequestBodyWrapper>();
            for(Student_Fee__c objStudentFee :[SELECT Id, OwnerId, IsDeleted, Name, Actual_Program_Fee__c, Amount_Paid__c, Concession__c, Due_Date__c, Fee_Name__c, 
                                               SRN_Number__c, Session__c, Fee_Type__c ,Integrated_with_SAP__c,Tuition_Premium__c, Amount__c, Application_Number__c ,
                                               Scholarship__c, Scholarship_Category__c, Premium__c FROM Student_Fee__c where 
                                               Id In : demandIds AND Integrated_with_SAP__c = true and Cancelled__c = false])
            {
                RequestBodyWrapper objReqWrp = new RequestBodyWrapper();
                
                
                objReqWrp.Application_Number = objStudentFee.Application_Number__c != null ? objStudentFee.Application_Number__c : '';
                //objReqWrp.Application_Number = 'STUDENT11';
                objReqWrp.Session = objStudentFee.Session__c != null ? objStudentFee.Session__c : '';
                //objReqWrp.Scholarship = objStudentFee.Scholarship_Category__c != null ? objStudentFee.Scholarship_Category__c : '';
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
            System.debug('requestBodyJson: ' + requestBodyJson);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBodyJson);
            request.setTimeout(120000);
            
            HttpResponse response = new Http().send(request);
            system.debug('---HTPSResp=='+response);
            Decimal statusCode = response.getStatusCode();
            String responseBody = response.getBody();
            System.debug('statusCode: ' + statusCode);
            System.debug('responseBody: ' + responseBody);
            
            
            debugLog.Request__c = request.getBody();
            debugLog.Response__c = response.getBody();
            debugLog.Status_Code__c = response.getStatusCode();
            insert debugLog;
            
            
            if (statusCode == 200) 
            {
                if (!String.isBlank(response.getBody())) {
                    ApiResponse responseFromSAP = (ApiResponse)JSON.deserialize(response.getBody(), ApiResponse.class);
                    for (ResponseData responseData : responseFromSAP.ResponseData) 
                    {
                        String sapStatusCode = responseData.StatusCode;
                        
                        if (sapStatusCode == '0') {
                            String demandNo = responseData.DemandNo;    
                            Student_Fee__c updatedStudentFee = new Student_Fee__c(Id = responseData.SFDCRecordId);
                            updatedStudentFee.Cancelled__c = true;
                            
                            Debug_Log__c dblog = new Debug_Log__c();
                            dblog.Student_Fee__c = responseData.SFDCRecordId;
                            dblog.Response__c = responseData.responseObject;
                            dblog.Status__c = 'Success';
                            dblog.Status_Code__c = Decimal.Valueof(responseData.StatusCode);
                            dblog.Request__c = request.getBody();
                            lst_DbLogs.add(dblog);
                            lst_StduentFees.add(updatedStudentFee);
                        }
                        else if(sapStatusCode == '1'){
                            
                            Student_Fee__c updatedStudentFee = new Student_Fee__c(Id = responseData.SFDCRecordId);
                            
                            Debug_Log__c dblog = new Debug_Log__c();
                            dblog.Student_Fee__c  = responseData.SFDCRecordId;
                            dblog.Response__c = responseData.responseObject;
                            dblog.Status__c = 'Failure';
                            dblog.Request__c = request.getBody();
                            dblog.Status_Code__c = Decimal.Valueof(responseData.statusCode);
                            lst_DbLogs.add(dblog);
                            lst_StduentFees.add(updatedStudentFee);
                        }
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
    
    public class RequestBodyWrapper 
    {
        public String Application_Number;
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
    
    
    public class ResponseData {
        public String DemandNo;
        public String StatusCode;
        public String StatusMessage;
        public String responseObject;
        public String ErrorMsg;
        public String SFDCRecordId;
    }
    
    public class ApiResponse {
        public Integer StatusCode;
        public String StatusMessage;
        public List<ResponseData> ResponseData;
    }
}



/*
public class SAP_DemandCancellationAPI implements Queueable, Database.AllowsCallouts {

    private List<Id> demandIds;

    public SAP_DemandCancellationAPI(List<Id> demandIds) {
        this.demandIds = demandIds;
    }

    public void execute(QueueableContext qc) {

        RecursiveTriggerHandler.isFirstTime = false;
        Debug_Log__c debugLog = new Debug_Log__c();
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Student_Fee__c> lst_StudentFees = new List<Student_Fee__c>();

        try {
            SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Demand_Cancellation_API');
            String endpointURL = mdt.EndPointURL__c;

            List<RequestBodyWrapper> requestList = new List<RequestBodyWrapper>();

            for (Student_Fee__c obj : [
                SELECT Id, Application_Number__c, Session__c, Scholarship__c, SRN_Number__c,
                       Concession__c, Fee_Type__c, Premium__c, Due_Date__c, Actual_Program_Fee__c,
                       Amount__c, Integrated_with_SAP__c
                FROM Student_Fee__c
                WHERE Id IN :demandIds AND Integrated_with_SAP__c = true
            ]) {
                RequestBodyWrapper req = new RequestBodyWrapper();
                req.Application_Number = obj.Application_Number__c != null ? obj.Application_Number__c : '';
                req.Session = obj.Session__c != null ? obj.Session__c : '';
                req.Scholarship = obj.Scholarship__c != null ? obj.Scholarship__c : 0.00;
                req.SRNNumber = obj.SRN_Number__c != null ? obj.SRN_Number__c : '';
                req.Concession = obj.Concession__c != null ? obj.Concession__c : 0.00;
                req.Fee_Name = obj.Fee_Type__c != null ? obj.Fee_Type__c : '';
                req.Premium = obj.Premium__c != null ? obj.Premium__c : 0.00;
                req.Due_date = obj.Due_Date__c != null ? obj.Due_Date__c : Date.today();
                req.Actual_Program_Fee = obj.Actual_Program_Fee__c != null ? obj.Actual_Program_Fee__c : 0.00;
                req.SACCode = System.Label.SAP_SACCode;
                req.Total_Amount = obj.Amount__c != null ? obj.Amount__c : 0.00;
                req.SFDCRecordId = obj.Id;
                requestList.add(req);
            }

            String requestJson = JSON.serialize(requestList);

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);
            request.setBody(requestJson);

            HttpResponse response = new Http().send(request);

            debugLog.Request__c = requestJson;
            debugLog.Response__c = response.getBody();
            debugLog.Status_Code__c = response.getStatusCode();
            insert debugLog;

            if (response.getStatusCode() == 200) {
                ApiResponse apiResp = (ApiResponse)JSON.deserialize(response.getBody(), ApiResponse.class);

                for (ResponseData resp : apiResp.ResponseData) {
                    if (resp.StatusCode == '0') {
                        Student_Fee__c fee = new Student_Fee__c(Id = resp.SFDCRecordId);
                        fee.Cancelled__c = true;
                        lst_StudentFees.add(fee);

                        Debug_Log__c log = new Debug_Log__c(
                            Student_Fee__c = resp.SFDCRecordId,
                            Status__c = 'Success',
                            Response__c = resp.responseObject,
                            Status_Code__c = Decimal.valueOf(resp.StatusCode),
                            Request__c = requestJson
                        );
                        lst_DbLogs.add(log);
                    } else {
                        Debug_Log__c log = new Debug_Log__c(
                            Student_Fee__c = resp.SFDCRecordId,
                            Status__c = 'Failure',
                            Response__c = resp.responseObject,
                            Status_Code__c = Decimal.valueOf(resp.StatusCode),
                            Request__c = requestJson
                        );
                        lst_DbLogs.add(log);
                    }
                }

                if (!lst_StudentFees.isEmpty()) {
                    update lst_StudentFees;
                }
                if (!lst_DbLogs.isEmpty()) {
                    insert lst_DbLogs;
                }
            }

        } catch (Exception e) {
            debugLog.Response__c += ' ERROR: ' + e.getMessage();
            upsert debugLog;
        }
    }

    // Wrapper Classes
    public class RequestBodyWrapper {
        public String Application_Number;
        public String Session;
        public Decimal Scholarship;
        public String SRNNumber;
        public Decimal Concession;
        public String Fee_Name;
        public Decimal Premium;
        public Date Due_date;
        public Decimal Actual_Program_Fee;
        public String SACCode;
        public Decimal Total_Amount;
        public String SFDCRecordId;
    }

    public class ResponseData {
        public String DemandNo;
        public String StatusCode;
        public String StatusMessage;
        public String responseObject;
        public String ErrorMsg;
        public String SFDCRecordId;
    }

    public class ApiResponse {
        public Integer StatusCode;
        public String StatusMessage;
        public List<ResponseData> ResponseData;
    }
}*/