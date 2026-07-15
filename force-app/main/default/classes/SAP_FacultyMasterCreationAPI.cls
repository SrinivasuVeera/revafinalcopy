public class SAP_FacultyMasterCreationAPI {
    //@future(callout=true)
    public static void  FacultyMasterCreationMethod(List<Id> AccIds) {
         RecursiveTriggerHandler.isFirstTime = false;
        Debug_Log__c debugLog = new Debug_Log__c();
         debugLog.Method_Name__c = 'FacultyMasterCreationMethod';
        debugLog.Class_Name__c = 'SAP_FacultyMasterCreationAPI';
        List<Account> accountsToUpdate = new List<Account>(); 
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>(); 
        try {
            
            SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Faculty_Master_Creation');
            String endpointURL = mdt.EndPointURL__c;
            
            List<RequestBodyWrapper> RequestBodyWrapperList = new List<RequestBodyWrapper>();
            for(Account acc:[SELECT Name,SAP_Name__c, RecordTypeId,SAP_ID__c,Parent.SAP_ID__c,Push_to_SAP__c,Id FROM Account WHERE Id IN: AccIds])
            {
                RequestBodyWrapper requestBody = new RequestBodyWrapper();
                requestBody.Name = acc.SAP_Name__c;
                requestBody.FullName = acc.Name;
                requestBody.SFDCRecordId = acc.Id;
                if(acc.SAP_ID__c == null || acc.SAP_ID__c =='')
                {
                    requestBody.SAPID = '';
                }
                else{
                    requestBody.SAPID = acc.SAP_ID__c; 
                }
                
                RequestBodyWrapperList.add(requestBody);
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
           debugLog.Status_Code__c = response.getStatusCode();
            debugLog.Response__c = response.getBody();
            insert debugLog;
            
            
            if (statusCode == 200) {
                 OuterResponseWrapper outerResponseWrapper = (OuterResponseWrapper) JSON.deserialize(response.getBody(), OuterResponseWrapper.class);
                List<ResponseWrapper> responseWrappers = outerResponseWrapper.Response;
                //List<ResponseWrapper> responseWrappers = (List<ResponseWrapper>) JSON.deserialize(response.getBody(), List<ResponseWrapper>.class);
                System.debug('responseWrappers: ' + responseWrappers);
                for (ResponseWrapper responseWrapper : responseWrappers) {
                    
                    if (responseWrapper.statusCode == 0) {
                        Account accToUpdate = new Account(Id = responseWrapper.SFDCRecordId);
                        accToUpdate.SAP_ID__c = responseWrapper.SAPID;
                        accToUpdate.Integrated_with_SAP__c =true;
                        accToUpdate.Push_to_SAP__c =false;
                        Debug_Log__c dblog = new Debug_Log__c();
                        
                        dblog.Faculty_School_Program__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Request__c = request.getBody();
                         dblog.Status__c = 'Success';
                        dblog.Status_Code__c = responseWrapper.statusCode;
                        lst_DbLogs.add(dblog);
                        accountsToUpdate.add(accToUpdate);
                    }
                    else if(responseWrapper.statusCode == 1){
                        Account accToUpdate = new Account(Id = responseWrapper.SFDCRecordId);
                        accToUpdate.SAP_ID__c = responseWrapper.SAPID;
                        accToUpdate.Push_to_SAP__c =false;
                        Debug_Log__c dblog = new Debug_Log__c();
                        dblog.Faculty_School_Program__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                         dblog.Request__c = request.getBody();
                         dblog.Status__c = 'Failure';
                         dblog.Status_Code__c = responseWrapper.statusCode;
                        lst_DbLogs.add(dblog);
                        accountsToUpdate.add(accToUpdate);
                    }
                }
                if (!accountsToUpdate.isEmpty()) {
                    Database.UpsertResult[] upsertResults = Database.upsert(accountsToUpdate, Account.Fields.Id, false);
                    for (Integer i = 0; i < upsertResults.size(); i++) {
                        if (!upsertResults[i].isSuccess()) {
                            lst_DbLogs[i].Response__c += upsertResults[i].getErrors()[0].getMessage();
                        }
                    }
                    
                }
                if (!lst_DbLogs.isEmpty()) {
                    insert lst_DbLogs;
                }
            } else {
                System.debug('Error: ' + statusCode + ' ' + response.getStatus());
                
            }
        }
        catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            debugLog.Response__c +='====='+e.getMessage();
            upsert debugLog;
        }
        
    }
    
     public class OuterResponseWrapper {
        public List<ResponseWrapper> Response;
    }
    public class RequestBodyWrapper {
        public String Name;
        public String SFDCRecordId;
        public String FullName;
        public String SAPID;
    }
    
    public class ResponseWrapper {
        public String SFDCRecordId;
        public Integer statusCode;
        public String statusMessage;
        public String SAPID;
        public String responseObject;
    }
}