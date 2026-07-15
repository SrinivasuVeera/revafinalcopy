public class SAP_OnlineAPI {
    @future(callout=true)
    public static void OnlineAPIMethod(List<Id> studentFeePayIds){
        RecursiveTriggerHandler.isFirstTime = false;
        Debug_Log__c debugLog = new Debug_Log__c();
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Student_Fee_Payment__c>lst_StduentFeePayments = new List<Student_Fee_Payment__c>();
        
        try
        {
            SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Online_Payment_API');
            String endpointURL = mdt.EndPointURL__c;
            
            List<RequestBodyWrapper> RequestBodyWrapperList = new List<RequestBodyWrapper>();
            for(Student_Fee_Payment__c objStudentFeePay :[SELECT Student_Fee__r.Name,Student_Fee__r.Fee_Type__c,Mode_of_Payment__c, Payment_Mode_Type__c,Line_Item_Payment_Gateway__c, Transaction_Status__c, Transaction_Date_Time__c, Id, Amount__c, Cheque_DD_Date__c,
                                                          Student_Fee__r.Contact__c,Push_to_SAP__c,Student_Fee__r.Demand_Number__c,  Student_Fee__r.Contact__r.SAP_ID__c,Student_Fee__r.Contact__r.Application_Number__c,
                                                          Cheque_DD_Realisation_Date__c, Cheque_DD_Number__c, Payment_Date__c,Reference_Id__c,SF_Transaction_ID__c,
                                                          Student_Fee__r.Contact__r.School__r.Parent.Name,Student_Fee__r.Contact__r.School__r.Name,Student_Fee__r.Contact__r.Primary_Academic_Program__r.Name,Student_Fee__r.Contact__r.Program_Batch__r.Name,Student_Fee__r.Contact__r.Active_Semester__r.Name 
                                                          FROM Student_Fee_Payment__c where 
                                                          Id In : studentFeePayIds])
            {
                RequestBodyWrapper objReqWrp = new RequestBodyWrapper();
                objReqWrp.Contact =objStudentFeePay.Student_Fee__r.Contact__r.Application_Number__c ;
                objReqWrp.Offline_Receipt_Number = '';
                objReqWrp.Amount =objStudentFeePay.Amount__c;
                objReqWrp.PaymentStatus = objStudentFeePay.Transaction_Status__c;
                objReqWrp.Payment_Date_Time = objStudentFeePay.Transaction_Date_Time__c.addHours(5).addMinutes(30);
                objReqWrp.FeeName = objStudentFeePay.Student_Fee__r.Name;
                objReqWrp.FeeType = objStudentFeePay.Student_Fee__r.Fee_Type__c;
				objReqWrp.Referenceid = objStudentFeePay.Reference_Id__c;
                objReqWrp.Transactionid = objStudentFeePay.SF_Transaction_ID__c;  
                //objReqWrp.Payment_Date_Time =  objStudentFeePay.Transaction_Date_Time__c.addHours(-objStudentFeePay.Transaction_Date_Time__c.hourGmt());
                objReqWrp.Demand_Number = objStudentFeePay.Student_Fee__r.Demand_Number__c;
                objReqWrp.Mode_of_Payment = objStudentFeePay.Mode_of_Payment__c;
                objReqWrp.Payment_Mode_Type = objStudentFeePay.Line_Item_Payment_Gateway__c;
                objReqWrp.PayAmount = objStudentFeePay.Amount__c;
                objReqWrp.CheckNumber = objStudentFeePay.Cheque_DD_Number__c;
                objReqWrp.Cheque_DD_Date = objStudentFeePay.Cheque_DD_Date__c;
                objReqWrp.Cheque_DD_Realisation_Date =objStudentFeePay.Cheque_DD_Realisation_Date__c;
                objReqWrp.SFDCRecordId = objStudentFeePay.Id;
                objReqWrp.Faculty = objStudentFeePay.Student_Fee__r.Contact__r.School__r.Parent.Name;
                objReqWrp.School = objStudentFeePay.Student_Fee__r.Contact__r.School__r.Name;
                objReqWrp.Program = objStudentFeePay.Student_Fee__r.Contact__r.Primary_Academic_Program__r.Name;
                objReqWrp.ProgramBatch = objStudentFeePay.Student_Fee__r.Contact__r.Program_Batch__r.Name;
                objReqWrp.Semester = objStudentFeePay.Student_Fee__r.Contact__r.Active_Semester__r.Name;
                RequestBodyWrapperList.add(objReqWrp);
            }
            
            String requestBodyJson = JSON.serialize(RequestBodyWrapperList);
             System.debug('requestBodyJson: ' + requestBodyJson);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBodyJson);
            
            HttpResponse response = new Http().send(request);
            system.debug('response'+response);
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
                OuterResponseWrapper outerResponseWrapper = (OuterResponseWrapper) JSON.deserialize(response.getBody(), OuterResponseWrapper.class);
                List<ResponseWrapper> responseWrappers = outerResponseWrapper.Response;
                //List<ResponseWrapper> responseWrappers = (List<ResponseWrapper>) JSON.deserialize(response.getBody(), List<ResponseWrapper>.class);
                System.debug('responseWrappers: ' + responseWrappers);
                for (ResponseWrapper responseWrapper : responseWrappers) 
                {
                    if (responseWrapper.statusCode == 0 && responseWrapper.SFDCRecordId != null && responseWrapper.SAPID != null) 
                    {
                        Student_Fee_Payment__c update_Student_Fee_Pay = new Student_Fee_Payment__c(Id = responseWrapper.SFDCRecordId);
                        update_Student_Fee_Pay.SAP_ID__c = responseWrapper.SAPID;
                        update_Student_Fee_Pay.Integrated_with_SAP__c = true;
                        update_Student_Fee_Pay.Push_to_SAP__c = false;
                        Debug_Log__c dblog = new Debug_Log__c();
                        dblog.Student_Fee_Payment__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Request__c = request.getBody();
                         dblog.Status__c = 'Success';
                        dblog.Status_Code__c = responseWrapper.statusCode;
                        lst_DbLogs.add(dblog);
                        lst_StduentFeePayments.add(update_Student_Fee_Pay);
                    }
                    else if(responseWrapper.statusCode == 1){
                        Student_Fee_Payment__c update_Student_Fee_Pay = new Student_Fee_Payment__c(Id = responseWrapper.SFDCRecordId);
                        update_Student_Fee_Pay.SAP_ID__c = responseWrapper.SAPID;
                        update_Student_Fee_Pay.Push_to_SAP__c = false;
                        Debug_Log__c dblog = new Debug_Log__c();
                        dblog.Student_Fee_Payment__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Request__c = request.getBody();
                         dblog.Status__c = 'Failure';
                         dblog.Status_Code__c = responseWrapper.statusCode;
                        
                        lst_DbLogs.add(dblog);
                        lst_StduentFeePayments.add(update_Student_Fee_Pay);
                    }
                }
                if (!lst_StduentFeePayments.isEmpty()) 
                {
                    //update lst_StduentFeePayments;
                    Database.UpsertResult[] upsertResults = Database.upsert(lst_StduentFeePayments, Student_Fee_Payment__c.Fields.Id, false);
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
    public class OuterResponseWrapper {
        public List<ResponseWrapper> Response;
    }
    public class RequestBodyWrapper 
    {
        public String Contact;
        public String Offline_Receipt_Number;
        public Decimal Amount;
        public String PaymentStatus;
        public String FeeName;
        public String FeeType;
        public Datetime Payment_Date_Time;
        public String Demand_Number;
        public String Mode_of_Payment;
        public String Payment_Mode_Type;
        public Decimal PayAmount;
        public String CheckNumber;
        public Date Cheque_DD_Date;
        public Date Cheque_DD_Realisation_Date;
        public String SFDCRecordId;
        public String Referenceid;
        public String Transactionid; 
        public String Faculty;
        public String School;
        public String Program;
        public String ProgramBatch;
        public String Semester;
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