public class SAP_ProgramBatchMasterCreationAPI 
{
    @future(callout=true)
    public static void  ProgramBatchMasterCreationMethod(List<Id> PgrmIds) 
    {
         RecursiveTriggerHandler.isFirstTime = false;
        Debug_Log__c debugLog = new Debug_Log__c();
        debugLog.Method_Name__c = 'ProgramBatchMasterCreationMethod';
        debugLog.Class_Name__c = 'SAP_ProgramBatchMasterCreationAPI';
        List<hed__Program_Plan__c> list_ProgamBatches = new List<hed__Program_Plan__c>();
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        
        try
        {
            SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Program_Batch_Creation');
            String endpointURL = mdt.EndPointURL__c;
            
            List<RequestBodyWrapper> RequestBodyWrapperList = new List<RequestBodyWrapper>();
            for(hed__Program_Plan__c objProgramPlan :[select Id,Name,hed__Account__c,Active__c,hed__End_Date__c,hed__Account__r.SAP_ID__c,SAP_Name__c,SAP_ID__c,
                                                      Intake__c,Number_of_Years__c,Record_ID__c,hed__Start_Date__c,Total_Number_Of_Lateral_Students__c,
                                                      Total_Number_Of_Regular_Students__c from hed__Program_Plan__c where 
                                                      Id In : PgrmIds])
            {
                RequestBodyWrapper objReqWrp = new RequestBodyWrapper();
                objReqWrp.ProgramSAPCODE = objProgramPlan.hed__Account__r.SAP_ID__c;
                objReqWrp.Active = objProgramPlan.Active__c;
                objReqWrp.End_Date = objProgramPlan.hed__End_Date__c;
                objReqWrp.Intake = objProgramPlan.Intake__c;
                objReqWrp.Number_of_Years = string.valueof(objProgramPlan.Number_of_Years__c);
                objReqWrp.Name = objProgramPlan.SAP_Name__c;
                objReqWrp.FullName = objProgramPlan.Name;
                if(objProgramPlan.SAP_ID__c==null || objProgramPlan.SAP_ID__c =='' )
                {
                    objReqWrp.SAPId = '';
                }
                else{
                    objReqWrp.SAPId= objProgramPlan.SAP_ID__c;
                }
                // objReqWrp.SAPId =objProgramPlan.SAP_ID__c;
                objReqWrp.Start_Date = objProgramPlan.hed__Start_Date__c;
                objReqWrp.Total_Number_Of_Lateral_Students = string.valueof(objProgramPlan.Total_Number_Of_Lateral_Students__c);
                objReqWrp.Total_Number_Of_Regular_Students = string.valueof(objProgramPlan.Total_Number_Of_Regular_Students__c);
                objReqWrp.SFDCRecordId = objProgramPlan.Id;
                RequestBodyWrapperList.add(objReqWrp);
            }
            
            String requestBodyJson = JSON.serialize(RequestBodyWrapperList);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBodyJson);
            
            HttpResponse response = new Http().send(request);
            
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
                        hed__Program_Plan__c objUpdtPrgmpln = new hed__Program_Plan__c(Id = responseWrapper.SFDCRecordId);
                        objUpdtPrgmpln.SAP_ID__c = responseWrapper.SAPID;
                        objUpdtPrgmpln.Integrated_with_SAP__c = true;
                        objUpdtPrgmpln.Push_to_SAP__c = false;
                        Debug_Log__c dblog = new Debug_Log__c();
                        dblog.Program_Plan__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Request__c = request.getBody();
                        dblog.Status__c = 'Success';
                        dblog.Status_Code__c = responseWrapper.statusCode;
                        lst_DbLogs.add(dblog);
                        list_ProgamBatches.add(objUpdtPrgmpln);
                    }
                    else if(responseWrapper.statusCode == 1){
                        hed__Program_Plan__c objUpdtPrgmpln = new hed__Program_Plan__c(Id = responseWrapper.SFDCRecordId);
                        objUpdtPrgmpln.SAP_ID__c = responseWrapper.SAPID;
                         objUpdtPrgmpln.Push_to_SAP__c = false;
                        Debug_Log__c dblog = new Debug_Log__c();
                        dblog.Program_Plan__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Request__c = request.getBody();
                        dblog.Status__c = 'Failure';
                        dblog.Status_Code__c = responseWrapper.statusCode;
                        lst_DbLogs.add(dblog);
                        list_ProgamBatches.add(objUpdtPrgmpln);
                    }
                }
                if (!list_ProgamBatches.isEmpty()) 
                {
                   // update list_ProgamBatches;
                     Database.UpsertResult[] upsertResults = Database.upsert(list_ProgamBatches, hed__Program_Plan__c.Fields.Id, false);
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
        public String ProgramSAPCODE;
        public Boolean Active;
        public date End_Date;
        public Decimal Intake;
        public String Number_of_Years;
        public String Name;
        public String FullName;
        public String SAPId;
        public date Start_Date;
        public String Total_Number_Of_Lateral_Students;
        public String Total_Number_Of_Regular_Students;
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