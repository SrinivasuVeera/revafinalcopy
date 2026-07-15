/**
 * Class Name: SLCM_HCMHostelCancellationAPI
 * Author: Jadala Devender
 * Description: 
 * This class handles the process of sending approved hostel cancellation requests to the HCM system. 
 * The process involves obtaining an access token, making an HTTP POST callout to the HCM Cancellation API, 
 * and processing the response. Based on the response, the hostel request records are updated accordingly in SLCM. 
 * The main purpose of this class is to ensure that once a hostel cancellation request is approved in SLCM, 
 * the corresponding data is confirmed and synchronized with HCM.
 */

 public class SLCM_HCMHostelCancellationAPI {

    /**
     * 
     * Method Name: sendApprovedCancellationToHCM
     * Description: 
     * This method sends approved hostel cancellation requests data to the HCM system for confirmation. 
     * It retrieves the relevant records, sends the data via an HTTP callout, and processes the response.
     * Based on the response, it updates the status of the hostel request records in SLCM.
     * 
     * @param hostelReqIds Set<Id> - A set of Ids representing the hostel requests to be confirmed.
     */
    public static void sendApprovedCancellationToHCM(Set<Id> hostelReqIds) {
        String accessToken;
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Reva_Hostel_Request__c> hostelReqToUpdate = new List<Reva_Hostel_Request__c>();
        Map<Id, hostelCanResWrapper> hostelReqCancelMap = new Map<Id, hostelCanResWrapper>();
        

        try {
            // Step 1: Obtain Access Token
            if(Test.isRunningTest()){
             accessToken = 'hjwvfkuvuyrbliw4ojkdcnjregtrtgrtrtwterttrow';
            }else{
                 accessToken = RevaHostelHCM_AccessTokenRequest.getAccessToken();
            }
            if (String.isEmpty(accessToken)) {
                System.debug('Error: Access token is empty.');
                lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMHostelCancellationAPI', null, 'Error: Access token is empty.', 'Failure'));
                insert lst_DbLogs;
                return;
            } 
        } catch (Exception e) {
            System.debug('Error obtaining access token: ' + e.getMessage());
            lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMHostelCancellationAPI', null, e.getMessage(), 'Failure'));
            insert lst_DbLogs;
            return;
        }

        // Step 2: Query to fetch relevant hostel requests
        List<Reva_Hostel_Request__c> hostelReqs = [
            SELECT Id, Hostel_Room_Request_For__r.Employee_Number__c, Employee_Salary__c, RevaHostelVacatingDate__c,
                   Cancellation_Request_Date__c, Cancellation_Reason__c, Cancellation_Approved_Date__c
            FROM Reva_Hostel_Request__c 
            WHERE Id IN :hostelReqIds 
            AND (Room_Request_Type__c = 'Non Teaching' OR Room_Request_Type__c = 'Professor')
            AND Hostel_Room_Request_For__c != null
            AND Hostel_Room_Request_For__r.Employee_Number__c != null 
            AND Is_HCM_Salary_Deduction_CNF__c = true
            AND Employee_Salary__c != null 
            AND Vacating_Request__c = 'Approved' 
            AND Approved_by_Hostel_Office__c = true
            AND Reva_Hostel_Room__c != null 
            AND Reva_Hostel_JoiningDate__c != null 
            AND Status__c = 'Vacate Approved'
        ];

        if (hostelReqs.isEmpty()) {
            System.debug('No valid hostel requests found for processing.');
            lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMHostelCancellationAPI', null, 'No valid hostel requests found for processing.', 'Failure'));
            insert lst_DbLogs;
            return;
        } 

        for (Reva_Hostel_Request__c hostelReq : hostelReqs) {
            try {
                // Step 3: Prepare the request wrapper
                hostelCanReqWrapper hstlWrap = new hostelCanReqWrapper();
                hstlWrap.Employee_Number = hostelReq.Hostel_Room_Request_For__r.Employee_Number__c;
                hstlWrap.Type = 'Hostel';
                hstlWrap.SLCM_Record_Id = hostelReq.Id;
                hstlWrap.Cancellation_Request_Date = hostelReq.Cancellation_Request_Date__c;
                hstlWrap.Cancellation_Reason = hostelReq.Cancellation_Reason__c;
                hstlWrap.Cancellation_Approved_Date =hostelReq.Cancellation_Approved_Date__c;
                hstlWrap.Vacate_Date =  hostelReq.RevaHostelVacatingDate__c;
                String jsonBody = JSON.serialize(new List<hostelCanReqWrapper>{hstlWrap});
                System.debug('Sending this JSON body: ' + jsonBody);
                String HCM_Cancellation_API_EndPoint = HCM_Endpoints__c.getInstance('Deduction Cancellation API').End_Point__c;
                HttpResponse res = sendApprovalConfirmation(HCM_Cancellation_API_EndPoint, accessToken, jsonBody);

                System.debug('Response Status Code: ' + res.getStatusCode());
                System.debug('Response Body: ' + res.getBody());

                if (res.getStatusCode() == 200 && !String.isEmpty(res.getBody())) {
                    try {
                        List<hostelCanResWrapper> respCnf = (List<hostelCanResWrapper>) JSON.deserialize(res.getBody(), List<hostelCanResWrapper>.class);
                        for (hostelCanResWrapper respoWr : respCnf) {
                            hostelReqCancelMap.put(hostelReq.Id, respoWr);
                        }

                        System.debug('Successfully deserialized response and added to map.');
                        lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMHostelCancellationAPI', jsonBody, res.getBody(), 'Success'));
                    } catch (JSONException e) {
                        System.debug('JSON Deserialization Error: ' + e.getMessage());
                        lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMHostelCancellationAPI', jsonBody, res.getBody(), 'Deserialization Failure'));
                    }
                } else {
                    System.debug('Error: Unexpected response status or empty body.');
                    lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMHostelCancellationAPI', jsonBody, res.getBody(), 'Failure'));
                }
            } catch (Exception e) {
                System.debug('Failed to get confirmation: ' + e.getMessage());
                lst_DbLogs.add(createDebugLog('sendApprovedCancellationToHCM', 'SLCM_HCMHostelCancellationAPI', null, e.getMessage(), 'Failure'));
            }
        }

        // Step 4: Prepare Records for Update
        if (!hostelReqCancelMap.isEmpty()) {
            System.debug('Updating records based on the response map.');
            for (Id hostelReqId : hostelReqCancelMap.keySet()) {
                Reva_Hostel_Request__c hostelReq = new Reva_Hostel_Request__c();
                hostelCanResWrapper respCnf = hostelReqCancelMap.get(hostelReqId);

                if (respCnf.Status == 'Success' && respCnf.SLCM_Record_Id.contains(hostelReqId)) {
                    hostelReq.Id = hostelReqId;
                    System.debug('Setting Is_HCM_Salary_Deduction_CNF__c to true for ' + hostelReqId);
                    hostelReq.Is_HCM_Salary_Deduction_Cancelled__c = true;
                    hostelReq.Status__c = 'Vacated';
                    hostelReq.Remark_HCM_Salary_Deduction_Cancellation__c = '';
                } else if (respCnf.Status == 'Failed' && respCnf.SLCM_Record_Id.contains(hostelReqId)) {
                    TriggerControl.isHCMQueueableRun = false;
                    hostelReq.Id = hostelReqId;
                    hostelReq.Remark_HCM_Salary_Deduction_Cancellation__c = respCnf.ErrorMessage + ' Or Re-Request Again for Vacating';
                    System.debug('Setting Is_HCM_Salary_Deduction_CNF__c to false and recording error for ' + hostelReqId);
                    hostelReq.Is_HCM_Salary_Deduction_Cancelled__c = false;
                }
                hostelReqToUpdate.add(hostelReq);
            }
        } 

        // Step 5: Execute Bulk Updates and Log Results
        if (!hostelReqToUpdate.isEmpty()) {
            System.debug('Updating ' + hostelReqToUpdate.size() + ' records.');
            Database.SaveResult[] updateResults = Database.update(hostelReqToUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                if (!updateResults[i].isSuccess()) {
                    System.debug('Error updating record ' + hostelReqToUpdate[i].Id + ': ' + updateResults[i].getErrors()[0].getMessage());
                    lst_DbLogs[i].Response__c += updateResults[i].getErrors()[0].getMessage();
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
     * @param endpoint String - The URL endpoint for the HCM Cancellation API.
     * @param accessToken String - The access token for authentication.
     * @param jsonBody String - The JSON body to be sent in the request.
     * @return HttpResponse - The response from the HCM system.
     */
    private static HttpResponse sendApprovalConfirmation(String endpoint, String accessToken, String jsonBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        return res;
    }

    /**
     * Method Name: createDebugLog
     * Description: 
     * This method creates a debug log record to store log information related to the process execution.
     * 
     * @param methodName String - The method where the log is being created.
     * @param className String - The class where the log is being created.
     * @param requestBody String - The request body sent to the API.
     * @param responseBody String - The response body received from the API.
     * @param status String - The status of the process (Success/Failure).
     * @return Debug_Log__c - The debug log record.
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

     /**
     * @class hostelCanReqWrapper
     * @description Wrapper class for the hostel cancellation request sent to the HCM system.
     */

     public class hostelCanReqWrapper {
        public String Employee_Number;
        public String Type;
        public String SLCM_Record_Id;
        public Date Cancellation_Request_Date;
        public Date Cancellation_Approved_Date;
        public String Cancellation_Reason;
        public Date Vacate_Date;
       
    }

    public class hostelCanResWrapper {
        public String Status;
        public String SLCM_Record_Id;
        public String ErrorMessage;
    }
}