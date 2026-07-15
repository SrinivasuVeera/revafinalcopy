/**
 * Class Name: SLCM_HCMQuarterCancellationAPI
 * Author: Jadala Devender
 * Description: 
 * This class handles the process of sending approved quarter cancellation requests to the HCM system. 
 * The process involves obtaining an access token, making an HTTP POST callout to the HCM Cancellation API, 
 * and processing the response. Based on the response, the quarter request records are updated accordingly in SLCM. 
 * The main purpose of this class is to ensure that once a quarter cancellation request is approved in SLCM, 
 * the corresponding data is confirmed and synchronized with HCM.
 */

 public class SLCM_HCMQuarterCancellationAPI {

    /**
     * Method Name: sendApprovedCancellationToHCM
     * Description: 
     * This method sends approved quarter cancellation requests data to the HCM system for confirmation. 
     * It retrieves the relevant records, sends the data via an HTTP callout, and processes the response.
     * Based on the response, it updates the status of the quarter request records in SLCM.
     * 
     * @param quarterReqIds Set<Id> - A set of Ids representing the quarter requests to be confirmed.
     */
    public static void sendApprovedCancellationToHCM(Set<Id> quarterReqIds) {
        String accessToken;
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Staff_Quarters_Request__c> quarterReqToUpdate = new List<Staff_Quarters_Request__c>();
        Map<Id, quarterCanResWrapper> quarterReqCancelMap = new Map<Id, quarterCanResWrapper>();

        try {
            // Step 1: Obtain Access Token
            if(Test.isRunningTest()){
             accessToken = 'hjwvfkuvuyrbliw4ojkdcnjregtrtgrtrtwterttrow';
            }else{
                 accessToken = RevaHostelHCM_AccessTokenRequest.getAccessToken();
            }
            if (String.isEmpty(accessToken)) {
                System.debug('Error: Access token is empty.');
                lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMQuarterCancellationAPI', null, 'Error: Access token is empty.', 'Failure'));
                insert lst_DbLogs;
                return;
            } 
        } catch (Exception e) {
            System.debug('Error obtaining access token: ' + e.getMessage());
            lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMQuarterCancellationAPI', null, e.getMessage(), 'Failure'));
            insert lst_DbLogs;
            return;
        }

        // Step 2: Query to fetch relevant quarter requests
        List<Staff_Quarters_Request__c> quarterReqs = [
            SELECT Id, Quarter_Request_For__r.Employee_Number__c, Employee_Salary__c,Vacation_Date__c,
                   Vacation_Initiated_Date__c, Cancellation_Reason__c, Cancellation_Approved_Date__c
            FROM Staff_Quarters_Request__c 
            WHERE Id IN :quarterReqIds 
            AND Quarter_Request_For__r.Employee_Number__c != null 
            AND Is_HCM_Salary_Deduction_CNF__c = true
            AND Employee_Salary__c != null 
            AND Status__c = 'Vacation Approved' 
            AND Approved_by_Hostel_Office__c = true
            AND Staff_Quarters_Joining_Date__c != null
            AND Vacation_Date__c != null
        ];

        if (quarterReqs.isEmpty()) {
            System.debug('No valid quarter requests found for processing.');
            lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMQuarterCancellationAPI', null, 'No valid quarter requests found for processing.', 'Failure'));
            insert lst_DbLogs;
            return;
        } 

        for (Staff_Quarters_Request__c quarterReq : quarterReqs) {
            try {
                // Step 3: Prepare the request wrapper
                quarterCanReqWrapper quarterWrap = new quarterCanReqWrapper();
                quarterWrap.Employee_Number = quarterReq.Quarter_Request_For__r.Employee_Number__c;
                quarterWrap.Type = 'Quarter';
                quarterWrap.SLCM_Record_Id = quarterReq.Id;
                quarterWrap.Cancellation_Request_Date = quarterReq.Vacation_Initiated_Date__c;
                quarterWrap.Cancellation_Reason = quarterReq.Cancellation_Reason__c;
                quarterWrap.Cancellation_Approved_Date = quarterReq.Cancellation_Approved_Date__c;
                quarterWrap.Vacate_Date = quarterReq.Vacation_Date__c;
                

                String jsonBody = JSON.serialize(new List<quarterCanReqWrapper>{quarterWrap});
                System.debug('Sending this JSON body: ' + jsonBody);
                String HCM_Cancellation_API_EndPoint = HCM_Endpoints__c.getInstance('Deduction Cancellation API').End_Point__c;
                HttpResponse res = sendApprovalConfirmation(HCM_Cancellation_API_EndPoint, accessToken, jsonBody);

                System.debug('Response Status Code: ' + res.getStatusCode());
                System.debug('Response Body: ' + res.getBody());

                if (res.getStatusCode() == 200 && !String.isEmpty(res.getBody())) {
                    try {
                        List<quarterCanResWrapper> respCnf = (List<quarterCanResWrapper>) JSON.deserialize(res.getBody(), List<quarterCanResWrapper>.class);
                        for (quarterCanResWrapper respoWr : respCnf) {
                            quarterReqCancelMap.put(quarterReq.Id, respoWr);
                        }

                        System.debug('Successfully deserialized response and added to map.');
                        lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMQuarterCancellationAPI', jsonBody, res.getBody(), 'Success'));
                    } catch (JSONException e) {
                        System.debug('JSON Deserialization Error: ' + e.getMessage());
                        lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMQuarterCancellationAPI', jsonBody, res.getBody(), 'Deserialization Failure'));
                    }
                } else {
                    System.debug('Error: Unexpected response status or empty body.');
                    lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMQuarterCancellationAPI', jsonBody, res.getBody(), 'Failure'));
                }
            } catch (Exception e) {
                System.debug('Failed to get confirmation: ' + e.getMessage());
                lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMQuarterCancellationAPI', null, e.getMessage(), 'Failure'));
            }
        }

        // Step 4: Prepare Records for Update
        if (!quarterReqCancelMap.isEmpty()) {
            System.debug('Updating records based on the response map.');
            for (Id quarterReqId : quarterReqCancelMap.keySet()) {
                Staff_Quarters_Request__c quarterReq = new Staff_Quarters_Request__c();
                
                quarterCanResWrapper respCnf = quarterReqCancelMap.get(quarterReqId);

                if (respCnf.Status == 'Success' && respCnf.SLCM_Record_Id == quarterReqId) {
                    quarterReq.Id = quarterReqId;
                    System.debug('Setting Is_HCM_Salary_Deduction_Cancelled__c to true for ' + quarterReqId);
                    quarterReq.Is_HCM_Salary_Deduction_Cancelled__c = true;
                    quarterReq.Status__c = 'Vacation Completed';
                } else if (respCnf.Status == 'Failed' && respCnf.SLCM_Record_Id == quarterReqId) {
                    TriggerControl.isHCMQueueableRun = false;
                    quarterReq.Id = quarterReqId;
                    System.debug('Setting Is_HCM_Salary_Deduction_CNF__c to false and recording error for ' + quarterReqId);
                    quarterReq.Remark_HCM_Salary_Deduction_Cancellation__c = respCnf.ErrorMessage + ' Or Re-Request Again for Vacating';
                }
                quarterReqToUpdate.add(quarterReq);
            }
        } 

        // Step 5: Execute Bulk Updates and Log Results
        if (!quarterReqToUpdate.isEmpty()) {
            System.debug('Updating ' + quarterReqToUpdate.size() + ' records.');
            Database.SaveResult[] updateResults = Database.update(quarterReqToUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                if (!updateResults[i].isSuccess()) {
                    System.debug('Error updating record ' + quarterReqToUpdate[i].Id + ': ' + updateResults[i].getErrors()[0].getMessage());
                    lst_DbLogs[i].Response__c += updateResults[i].getErrors()[0].getMessage();
                } else {
                    System.debug('Record ' + quarterReqToUpdate[i].Id + ' updated successfully.');
                }
            }
        } 

        if (!lst_DbLogs.isEmpty()) {
            System.debug('Inserting ' + lst_DbLogs.size() + ' log entries.');
            insert lst_DbLogs;
        }
    }

    /**
     * Method Name: sendApprovalConfirmation
     * Description: 
     * This method performs the HTTP POST request to send the cancellation confirmation data to the HCM system.
     * 
     * @param endpoint String - The API endpoint URL.
     * @param accessToken String - The access token for authentication.
     * @param requestBody String - The JSON request body.
     * @return HttpResponse - The response from the HCM system.
     */
    private static HttpResponse sendApprovalConfirmation(String endpoint, String accessToken, String requestBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }

    /**
     * Method Name: createDebugLog
     * Description: 
     * This helper method creates a new Debug_Log__c record.
     * 
     * @param methodName String - The method name where the log is created.
     * @param className String - The class name where the log is created.
     * @param requestBody String - The request body being logged.
     * @param responseBody String - The response body being logged.
     * @param status String - The status of the log.
     * @return Debug_Log__c - The created debug log record.
     */
    private static Debug_Log__c createDebugLog(String methodName, String className, String requestBody, String responseBody, String status) {
        Debug_Log__c log = new Debug_Log__c();
        log.Method_Name__c = methodName;
        log.Class_Name__c = className;
        log.Request__c = requestBody;
        log.Response__c = responseBody;
        log.Status__c = status;
        return log;
    }

    // Wrapper class for the request
    public class quarterCanReqWrapper {
        public String Employee_Number;
        public String Type;
        public Id SLCM_Record_Id;
        public Date Cancellation_Request_Date;
        public String Cancellation_Reason;
        public Date Cancellation_Approved_Date;
        public Date Vacate_Date;
    }

    // Wrapper class for the response
    public class quarterCanResWrapper {
        public String Status;
        public Id SLCM_Record_Id;
        public String ErrorMessage;
    }
}