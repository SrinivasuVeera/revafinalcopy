public class SAP_ReconAPI {
    public static void sendSLCMReconciliationRequest(List<Id> demandIds) {
        Debug_Log__c debugLog = new Debug_Log__c();
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Student_Fee__c>lst_StduentFees = new List<Student_Fee__c>();
        try
        {
            SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Recon_API');
            String endpointURL = mdt.EndPointURL__c;
            list<RequestData> requestDataList = new list<RequestData>();
            for(Student_Fee__c objStudentFee :[SELECT Id, OwnerId, IsDeleted, Name, Actual_Program_Fee__c, Amount_Paid__c, Concession__c, Due_Date__c, Fee_Name__c, 
                                               SRN_Number__c, Session__c, Fee_Type__c ,Tuition_Premium__c, Amount__c, Application_Number__c ,Demand_Number__c,
                                                   Scholarship__c, Scholarship_Category__c,Reconciliation_Completed__c, Premium__c,(SELECT Id, Amount__c, Line_Item_Payment_Status__c,Exam_Application_Number__c,Name, Push_to_SAP__c,Recon_Record_ID__c,Integrated_with_SAP__c, Remarks__c, SAP_ID__c, Payment_Date__c
                                                                                                    FROM Student_Fee_Payments__r where Line_Item_Payment_Status__c = 'Success') FROM Student_Fee__c where 
                                               Id In : demandIds])
            {
                RequestData reqData = new RequestData();
                reqData.DemandNo = objStudentFee.Demand_Number__c;
                reqData.SFDCRecordId = objStudentFee.Id;
                List<Payment> sfpList = new List<Payment>();
                for(Student_Fee_Payment__c objSFP:objStudentFee.Student_Fee_Payments__r)
                {
                    Payment wrpSfP = new Payment();
                    wrpSfP.PaymentId = objSFP.Recon_Record_ID__c;
                    wrpSfP.Amount = objSFP.Amount__c;
                    wrpSfP.Application_Number =objStudentFee.Application_Number__c;
                    sfpList.add(wrpSfP);
                }
                reqData.Payment = sfpList;
                requestDataList.add(reqData); 
            }
            String requestBodyJson = JSON.serialize(requestDataList);
           
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBodyJson);
            HttpResponse response = new Http().send(request);
           
            Decimal statusCode = response.getStatusCode();
            String responseBody = response.getBody();
           
            debugLog.Request__c = request.getBody();
            debugLog.Response__c = response.getBody();
            debugLog.Status_Code__c = response.getStatusCode();
            insert debugLog;
            
            if (statusCode == 200) {
                if (!String.isBlank(response.getBody())) {
                    ApiResponse responseFromSAP = (ApiResponse)JSON.deserialize(response.getBody(), ApiResponse.class);
                    for (ResponseData responseData : responseFromSAP.ResponseData) 
                    {
                        String sapStatusCode = responseData.StatusCode;
                        
                        if (sapStatusCode == '0') {
                            String demandNo = responseData.DemandNo;    
                            Student_Fee__c updatedStudentFee = new Student_Fee__c();
                            
                            updatedStudentFee.Id = responseData.SFDCRecordId;
                            
                            updatedStudentFee.Reconciliation_Completed__c = true;
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
                            updatedStudentFee.Demand_Number__c = responseData.DemandNo;
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
    public class Payment {
        public String PaymentId;
        public Decimal Amount;
        public String Application_Number;
        
    }
    
    public class RequestData {
        public String DemandNo;
         public String SFDCRecordId;
        public List<Payment> Payment;
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