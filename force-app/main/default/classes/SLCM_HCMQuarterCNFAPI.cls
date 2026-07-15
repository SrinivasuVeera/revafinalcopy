/**
 * Class Name: SLCM_HCMQuarterCNFAPI
 * Author: Jadala Devender
 * Description: 
 * This class is responsible for sending approved confirmation data from SLCM to HCM for Quarter requests. 
 * The process involves obtaining an access token, making an HTTP POST callout to the HCM Quarter Quarters API, 
 * and processing the response. Based on the response, the Quarter request records are updated accordingly in SLCM. 
 * The main purpose of this class is to ensure that once a Quarter request is approved in SLCM, 
 * the corresponding data is confirmed and synchronized with HCM.
 */

 public class SLCM_HCMQuarterCNFAPI {

    /**
     * Method Name: sendApprovedConfirmationHCM
     * Description: 
     * This method sends approved Quarter request data to the HCM system for confirmation. 
     * It retrieves the relevant records, sends the data via an HTTP callout, and processes the response.
     * Based on the response, it updates the status of the Quarter request records in SLCM.
     * 
     * @param quarterReqIds Set<Id> - A set of Ids representing the Quarter requests to be confirmed.
     */
    public static List<Staff_Quarters_Request__c> sendApprovedConfirmationHCM(Set<Id> quarterReqIds) {
        String accessToken;
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Staff_Quarters_Request__c> quarterReqToUpdate = new List<Staff_Quarters_Request__c>();
        Map<Id, quarterResCnfWrapper> quarterApproversCnfMap = new Map<Id, quarterResCnfWrapper>();
        Map<Id, Staff_Quarters_Request__c> quaterExistingDataMap = new Map<Id, Staff_Quarters_Request__c>();
        
        List<Staff_Quarters_Request__c> successfulUpdates = new List<Staff_Quarters_Request__c>();
        
        try {
            // Step 1: Obtain Access Token
            if(Test.isRunningTest()){
                accessToken = 'hjwvfkuvuyrbliw4ojkdcnjregtrtgrtrtwterttrow';
               }else{
                    accessToken = RevaHostelHCM_AccessTokenRequest.getAccessToken();
               }
            if (String.isEmpty(accessToken)) {
                System.debug('Error: Access token is empty.');
                lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMQuarterCNFAPI', null, 'Error: Access token is empty.', 'Failure'));
                insert lst_DbLogs;
                return null;
            } 
        } catch (Exception e) {
            System.debug('Error obtaining access token: ' + e.getMessage());
            lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMQuarterCNFAPI', null, e.getMessage(), 'Failure'));
            insert lst_DbLogs;
            return null;
        }

        // Step 2: Query to fetch relevant Quarter requests
        List<Staff_Quarters_Request__c> quarterReqs = [
            SELECT Id, Quarter_Request_For__r.Employee_Number__c,Salary_Last_Revised_Date__c,Deduction_Half_Amount__c,Type__c, Employee_Salary__c,Staff_Quarters_Joining_Date__c,Is_Revised_Salary_Push_to_HCM__c,Status__c
            FROM Staff_Quarters_Request__c 
            WHERE Id IN :quarterReqIds 
            AND Quarter_Request_For__r.Employee_Number__c != null  
            AND Employee_Salary__c != null 
            AND HCM_Approval_Status__c = 'Deduction Approved' 
            AND Approved_by_Hostel_Office__c = true
            AND Staff_Quarters_Joining_Date__c != null 
            AND (Status__c = 'Approved' OR Status__c ='Room Allotted')
            
        ];

        if (quarterReqs.isEmpty()) {
            System.debug('No valid Quarter requests found for processing.');
            lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMQuarterCNFAPI', null, 'No valid Quarter requests found for processing.', 'Failure'));
            insert lst_DbLogs;
            return null;
        } 
        for (Staff_Quarters_Request__c quarterReq : quarterReqs) {
            try {
                 quaterExistingDataMap.put(quarterReq.Id,quarterReq);
                // Step 3: Prepare the request wrapper
                quarterReqCnfWrapper quarterWrap = new quarterReqCnfWrapper();
                quarterWrap.Employee_Number = quarterReq.Quarter_Request_For__r.Employee_Number__c;
               
                quarterWrap.Amount = String.valueOf(quarterReq.Employee_Salary__c);
                quarterWrap.Type ='Quarter' ;//'Quarter';
                quarterWrap.Hostel_OR_Quater_Type = quarterReq.Type__c;
                quarterWrap.SLCM_Record_Id = quarterReq.Id;
                if(quarterReq.Status__c == 'Approved'){
                    quarterWrap.Start_date = Datetime.now().format('yyyy-MM-dd');
                }
                else if(quarterReq.Salary_Last_Revised_Date__c !=null && quarterReq.Status__c == 'Room Allotted' ) {
                     
                     quarterWrap.Start_date = String.valueOf(quarterReq.Salary_Last_Revised_Date__c);
                }

                String jsonBody = JSON.serialize(new List<quarterReqCnfWrapper>{quarterWrap});
                System.debug('Sending this JSON body: ' + jsonBody);
                String HCM_QuarterQuarters_API_EndPoint = HCM_Endpoints__c.getInstance('Hostel Quarters API').End_Point__c;
                HttpResponse res = sendApprovalConfirmation(HCM_QuarterQuarters_API_EndPoint, accessToken, jsonBody);

                System.debug('Response Status Code: ' + res.getStatusCode());
                System.debug('Response Body: ' + res.getBody());

                if (res.getStatusCode() == 200 && !String.isEmpty(res.getBody())) {
                    try {
                        List<quarterResCnfWrapper> respCnf = (List<quarterResCnfWrapper>) JSON.deserialize(res.getBody(), List<quarterResCnfWrapper>.class);
                        for (quarterResCnfWrapper respoWr : respCnf) {
                           
                                System.debug('Quarter salary confirmation Successful.');
                                quarterApproversCnfMap.put(quarterReq.Id, respoWr);
                            
                            
                        }

                        System.debug('Successfully deserialized response and added to map.');
                        lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMQuarterCNFAPI', jsonBody, res.getBody(), 'Success'));
                    } catch (JSONException e) {
                        System.debug('JSON Deserialization Error: ' + e.getMessage());
                        lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMQuarterCNFAPI', jsonBody, res.getBody(), 'Deserialization Failure'));
                    }
                } else {
                    System.debug('Error: Unexpected response status or empty body.');
                    lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMQuarterCNFAPI', jsonBody, res.getBody(), 'Failure'));
                }
            } catch (Exception e) {
                System.debug('Failed to get confirmation: ' + e.getMessage());
                lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMQuarterCNFAPI', null, e.getMessage(), 'Failure'));
            }
        }

        // Step 4: Prepare Records for Update
        if (!quarterApproversCnfMap.isEmpty()) {
            System.debug('Updating records based on the response map.');
            for (Id quarterReqId : quarterApproversCnfMap.keySet()) {
                Staff_Quarters_Request__c quarterReq = new Staff_Quarters_Request__c();
               
                quarterResCnfWrapper respCnf = quarterApproversCnfMap.get(quarterReqId);

                if (respCnf.Status == 'Success' && respCnf.SLCM_Record_Id.contains(quarterReqId)) {
                    quarterReq.Id = quarterReqId;
                    System.debug('Setting Is_HCM_Salary_Deduction_CNF__c to true for ' + quarterReqId);
                    
                    if (quaterExistingDataMap.get(quarterReqId).Status__c == 'Approved'){
                        quarterReq.Is_HCM_Salary_Deduction_CNF__c = true;
                        quarterReq.HCM_Salary_Approval_CNF_Error__c = '';
                    }
                    else if(quaterExistingDataMap.get(quarterReqId).Status__c == 'Room Allotted') {
                        quarterReq.Is_Revised_Salary_Push_to_HCM__c = true;
                        quarterReq.HCM_Revised_Salary_CNF_Error__c ='';
                    }
                    
                    
                    
                } else if (respCnf.Status == 'Failed' && respCnf.SLCM_Record_Id.contains(quarterReqId)) {
                    quarterReq.Id = quarterReqId;
                    System.debug('Setting Is_HCM_Salary_Deduction_CNF__c to false and recording error for ' + quarterReqId);
                    
                    
                    if (quaterExistingDataMap.get(quarterReqId).Status__c == 'Approved'){
                        quarterReq.Is_HCM_Salary_Deduction_CNF__c = false;
                         quarterReq.HCM_Salary_Approval_CNF_Error__c = respCnf.ErrorMessage +' OR Contact your Admin because deduction confirmation failed by HCM';
                    }
                    else if (quaterExistingDataMap.get(quarterReqId).Status__c == 'Room Allotted') {
                       quarterReq.Is_Revised_Salary_Push_to_HCM__c = false;
                       quarterReq.HCM_Revised_Salary_CNF_Error__c = respCnf.ErrorMessage +' Contact your Admin Because new revised salary deduction confirmation failed by HCM' ;
                    } 
                    
                }
                quarterReqToUpdate.add(quarterReq);
            }
        }

        // Step 5: Execute Bulk Updates and Log Results
        if (!quarterReqToUpdate.isEmpty()) {
            System.debug('quarterReqToUpdate---'+quarterReqToUpdate);
           List<Database.SaveResult> updateResults = Database.update(quarterReqToUpdate, false);
           for (Integer i = 0; i < updateResults.size(); i++) {
                if (!updateResults[i].isSuccess()) {
                    
                    // Log errors
                    System.debug('Error updating record ' + quarterReqToUpdate[i].Id + ': ' + updateResults[i].getErrors()[0].getMessage());
                    // Assuming lst_DbLogs is a list of some log object and needs to be updated
                    lst_DbLogs[i].Response__c += updateResults[i].getErrors()[0].getMessage();
                } else {
                    System.debug('sucessss res---'+updateResults);
                    // Add successful records to the success list
                    successfulUpdates.add(quarterReqToUpdate[i]);
                }
            }
        }

        if (!lst_DbLogs.isEmpty()) {
            System.debug('Inserting ' + lst_DbLogs.size() + ' log entries.');
            insert lst_DbLogs;
        }
        
        return successfulUpdates;
    }

    /**
     * Method Name: sendApprovalConfirmation
     * Description: 
     * This method makes an HTTP POST request to the specified endpoint, sending the JSON body and using the access token for authentication.
     * 
     * @param endpoint String - The URL to which the request is sent.
     * @param accessToken String - The access token to be used for authentication.
     * @param jsonBody String - The JSON body of the request.
     * @return HttpResponse - The response from the HTTP request.
     */
    private static HttpResponse sendApprovalConfirmation(String endpoint, String accessToken, String jsonBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setBody(jsonBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('res--->'+res);
        return res;
    }

    /**
     * Method Name: createDebugLog
     * Description: 
     * This method creates a debug log entry for tracking purposes.
     * 
     * @param methodName String - The method name where the log is created.
     * @param className String - The class name where the log is created.
     * @param requestBody String - The request body sent (if applicable).
     * @param responseBody String - The response body received (if applicable).
     * @param status String - The status of the operation (Success/Failure).
     * @return Debug_Log__c - The created debug log record.
     */
    private static Debug_Log__c createDebugLog(String methodName, String className, String requestBody, String responseBody, String status) {
        Debug_Log__c log = new Debug_Log__c();
        log.Method_Name__c = methodName;
        log.Class_Name__c = className;
        log.Request__c = requestBody;
        log.Response__c = responseBody;
        //log.Status__c = status;
        return log;
    }

    /**
     * Inner Class: quarterReqCnfWrapper
     * Description: 
     * This inner class is a wrapper for the Quarter request confirmation data sent to HCM.
     */
    public class quarterReqCnfWrapper {
        public String Employee_Number;
        public String Start_date;
        public String Amount;
        public String Type;
        public String Hostel_OR_Quater_Type;
        public Id SLCM_Record_Id;
    }

    /**
     * Inner Class: quarterResCnfWrapper
     * Description: 
     * This inner class is a wrapper for the response data received from HCM.
     */
    public class quarterResCnfWrapper {
        public String Status;
        public String SLCM_Record_Id;
        public String ErrorMessage;
    }
}