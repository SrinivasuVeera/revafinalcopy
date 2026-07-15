public class SAP_SRN_PushtoSAPBatchAPIHandler {
    public static void  StudentMasterCreationMethod(List<Id> ContactIds) {
        //RecursiveTriggerHandler.isFirstTime = false;
        Debug_Log__c debugLog = new Debug_Log__c();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        try {
            
            SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Student_Master_Creation');
            String endpointURL = mdt.EndPointURL__c;
            
            List<RequestBodyWrapper> RequestBodyWrapperList = new List<RequestBodyWrapper>();
            for(Contact objCon:[SELECT Id, Program_Batch__c, hed__WorkEmail__c,Email, Aadhar_Card_Number__c, Application_Number__c, SAP_ID__c,
                                Primary_Academic_Program__r.SAP_ID__c, School__c,Program_Batch__r.SAP_ID__c,Personal_Email__c,School__r.SAP_ID__c,
                                SRN_Number__c ,School__r.Parent.SAP_ID__c,
                                Student_Full_Name__c, Student_Status__c FROM Contact WHERE Id IN: ContactIds])
            {
                RequestBodyWrapper requestBody = new RequestBodyWrapper();
                requestBody.Aadhar_Card_Number = objCon.Aadhar_Card_Number__c;
                requestBody.Academic_Program = objCon.Primary_Academic_Program__r.SAP_ID__c;
                requestBody.Application_Number = objCon.Application_Number__c;
                
                requestBody.Faculty = objCon.School__r.Parent.SAP_ID__c;
                
                requestBody.hed_WorkEmail = objCon.hed__WorkEmail__c;
                requestBody.Personal_Email = objCon.Personal_Email__c;
                requestBody.SRN_Number = objCon.SRN_Number__c;
                requestBody.Program_Batch = objCon.Program_Batch__r.SAP_ID__c;
                requestBody.School = objCon.School__r.SAP_ID__c;
                requestBody.Student_Full_Name = objCon.Student_Full_Name__c;
                if(objCon.Student_Status__c =='Pursuing' || objCon.Student_Status__c =='YearBack'){
                    requestBody.Student_Status = true;
                }
                else{
                    requestBody.Student_Status = false;
                }
                requestBody.ContactRecordID = objCon.Id;
                //requestBody.Virtual_Bank_Account_Number = objCon.Application_Number__c;
                /*  if(objCon.SAP_ID__c==null || objCon.SAP_ID__c =='' )
{
requestBody.SAPId = '';
}
else{
requestBody.SAPId= objCon.SAP_ID__c;
}*/
                //requestBody.SAPID = objCon.SAP_ID__c;
                
                
                RequestBodyWrapperList.add(requestBody);
            }
            
            String requestBodyJson = JSON.serialize(RequestBodyWrapperList);
            system.debug('requestBodyJson '+requestBodyJson);
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointURL);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBodyJson);
            request.setTimeout(120000);
            
            HttpResponse response = new Http().send(request);
            
            Decimal statusCode = response.getStatusCode();
            String responseBody = response.getBody();
            System.debug('statusCode: ' + statusCode);
            System.debug('responseBody: ' + responseBody);
			 System.debug('requestBody: ' + request.getBody());
            System.debug('statuscode: ' +response.getStatusCode());
            
            
            debugLog.Request__c = request.getBody();
            debugLog.Response__c = response.getBody();
            debugLog.Status_Code__c = response.getStatusCode();
            insert debugLog;
            
            
            if (statusCode == 200) {
                OuterResponseWrapper outerResponseWrapper = (OuterResponseWrapper) JSON.deserialize(response.getBody(), OuterResponseWrapper.class);
                List<ResponseWrapper> responseWrappers = outerResponseWrapper.Response;
                //List<ResponseWrapper> responseWrappers = (List<ResponseWrapper>) JSON.deserialize(response.getBody(), List<ResponseWrapper>.class);
                System.debug('responseWrappers: ' + responseWrappers);
                for (ResponseWrapper responseWrapper : responseWrappers) {
                    
                    if (responseWrapper.statusCode == 0 && responseWrapper.SFDCRecordId != null && responseWrapper.SAPID != null) {
                        Contact  contactToUpdate = new Contact(Id = responseWrapper.SFDCRecordId);
                        contactToUpdate.SAP_ID__c = responseWrapper.SAPID;
                        contactToUpdate.Integrated_with_SAP__c =true;
                        contactToUpdate.Push_to_SAP__c = false;
                        contactToUpdate.Integrated_with_SAP_Date__c =system.today();
                        Debug_Log__c dblog = new Debug_Log__c();
                        
                        dblog.Contact__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Request__c = request.getBody();
                        dblog.Status__c = 'Success';
                        dblog.Status_Code__c = responseWrapper.statusCode;
                        lst_DbLogs.add(dblog);
                        contactsToUpdate.add(contactToUpdate);
                    }
                    else if(responseWrapper.statusCode == 1){
                        Contact  contactToUpdate = new Contact(Id = responseWrapper.SFDCRecordId);
                        contactToUpdate.SAP_ID__c = responseWrapper.SAPID;
                        contactToUpdate.Push_to_SAP__c = false;
                        Debug_Log__c dblog = new Debug_Log__c();
                        dblog.Contact__c = responseWrapper.SFDCRecordId;
                        dblog.Response__c = responseWrapper.responseObject;
                        dblog.Request__c = request.getBody();
                        dblog.Status__c = 'Failure';
                        dblog.Status_Code__c = responseWrapper.statusCode;
                            lst_DbLogs.add(dblog);
                        contactsToUpdate.add(contactToUpdate);
                    }
                }
                if (!contactsToUpdate.isEmpty()) {
                    RecursiveTriggerHandler.isFirstTime = false;
                    update contactsToUpdate;
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
            debugLog.Response__c +='Error:'+'====='+e.getMessage();
            upsert debugLog;
        }
        
    }
    
    public class OuterResponseWrapper {
        public List<ResponseWrapper> Response;
    }
    public class RequestBodyWrapper {
        public String Aadhar_Card_Number;
        public String Academic_Program; 
        public String Application_Number; 
        public String Faculty;
        public String hed_WorkEmail;
        public String Personal_Email;
        public String SRN_Number;
        public String Program_Batch;
        
        public String School;
        
        public String Student_Full_Name;
        public Boolean Student_Status;
        public String ContactRecordID;    
        //public String SAPID;
        //public String Virtual_Bank_Account_Number;
        //SFDCRecordId
    }
    
    public class ResponseWrapper {
        public String SFDCRecordId;
        public Integer statusCode;
        public String statusMessage;
        public String SAPID;
        public String responseObject;
    }
}