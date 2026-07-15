/**
 * Class Name: SLCM_HCMHostelCNFAPI
 * Author: Jadala Devender
 * Description: 
 * This class is responsible for sending approved confirmation data from SLCM to HCM for hostel requests. 
 * The process involves obtaining an access token, making an HTTP POST callout to the HCM Hostel Quarters API, 
 * and processing the response. Based on the response, the hostel request records are updated accordingly in SLCM. 
 * The main purpose of this class is to ensure that once a hostel request is approved in SLCM, 
 * the corresponding data is confirmed and synchronized with HCM.
 */
public class SLCM_HCMHostelCNFAPI {

    /**
     * Method Name: sendApprovedConfirmationHCM
     * Description: 
     * This method sends approved hostel request data to the HCM system for confirmation. 
     * It retrieves the relevant records, sends the data via an HTTP callout, and processes the response.
     * Based on the response, it updates the status of the hostel request records in SLCM.
     * 
     * @param hostelReqIds Set<Id> - A set of Ids representing the hostel requests to be confirmed.
     */
    public static List<Reva_Hostel_Request__c> sendApprovedConfirmationHCM(Set<Id> hostelReqIds) {
        String accessToken;
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Reva_Hostel_Request__c> hostelReqToUpdate = new List<Reva_Hostel_Request__c>();
        Map<Id, hostelResCnfWrapper> hostelApproversCnfMap = new Map<Id, hostelResCnfWrapper>();
        Map<Id, Reva_Hostel_Request__c> hostelExistingDataMap = new Map<Id, Reva_Hostel_Request__c>();
        
        //return to batch success records for notification

           List<Reva_Hostel_Request__c> successfulUpdates = new List<Reva_Hostel_Request__c>();
        

        try {
            // Step 1: Obtain Access Token
            if(Test.isRunningTest()){
             accessToken = 'hjwvfkuvuyrbliw4ojkdcnjregtrtgrtrtwterttrow';
            }else{
                 accessToken = RevaHostelHCM_AccessTokenRequest.getAccessToken();
            }
            if (String.isEmpty(accessToken)) {
                System.debug('Error: Access token is empty.');
                lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMHostelCNFAPI', null, 'Error: Access token is empty.', 'Failure'));
                insert lst_DbLogs;
                return null;
            } 
        } catch (Exception e) {
            System.debug('Error obtaining access token: ' + e.getMessage());
            lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMHostelCNFAPI', null, e.getMessage(), 'Failure'));
            insert lst_DbLogs;
            return null;
        }

        // Step 2: Query to fetch relevant hostel requests
        List<Reva_Hostel_Request__c> hostelReqs = [
            SELECT Id, Hostel_Room_Request_For__r.Employee_Number__c,Type__c, DeductionHalfAmount__c,Employee_Salary__c,Reva_Hostel_JoiningDate__c ,Salary_Last_Revised_Date__c,Is_Revised_Salary_Push_to_HCM__c ,Status__c
            FROM Reva_Hostel_Request__c 
            WHERE Id IN :hostelReqIds 
            AND (Room_Request_Type__c = 'Non Teaching' OR Room_Request_Type__c = 'Professor')
            AND Hostel_Room_Request_For__c != null
            AND Hostel_Room_Request_For__r.Employee_Number__c != null 
            AND Employee_Salary__c != null 
            AND HCM_Approval_Status__c = 'Deduction Approved' 
            AND Approved_by_Hostel_Office__c = true
            AND Reva_Hostel_JoiningDate__c != null 
            AND (Status__c = 'Approved' OR Status__c ='Room Allotted')
           
        ];

        if (hostelReqs.isEmpty()) {
            System.debug('No valid hostel requests found for processing.');
            lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMHostelCNFAPI', null, 'No valid hostel requests found for processing.', 'Failure'));
            insert lst_DbLogs;
            return null;
        } 
        for (Reva_Hostel_Request__c hostelReq : hostelReqs) {
            try {
                //To store exixting Data in Map
                hostelExistingDataMap.put(hostelReq.Id,hostelReq);
                // Step 3: Prepare the request wrapper
                hostelReqCnfWrapper hstlWrap = new hostelReqCnfWrapper();
                hstlWrap.Employee_Number = hostelReq.Hostel_Room_Request_For__r.Employee_Number__c;
                 hstlWrap.Amount = String.valueOf(hostelReq.Employee_Salary__c);
                 hstlWrap.Type = 'Hostel';
                if (hostelReq.Type__c == '2') {
                    hstlWrap.Hostel_OR_Quater_Type = '2 - Sharing';
                } else if (hostelReq.Type__c == '3') {
                    hstlWrap.Hostel_OR_Quater_Type = '3 - Sharing';
                } else if (hostelReq.Type__c == '4') {
                    hstlWrap.Hostel_OR_Quater_Type = '4 - Sharing';
                } else if (hostelReq.Type__c == '6') {
                    hstlWrap.Hostel_OR_Quater_Type = '6 - Sharing';
                } else if (hostelReq.Type__c == '8'){
                    hstlWrap.Hostel_OR_Quater_Type = '8 - Sharing'; // Handle default case
                } else if (hostelReq.Type__c == '4ExtraSpace'){
                    hstlWrap.Hostel_OR_Quater_Type = '4 - Sharing Extra Space'; // Handle default case
                }
                else {
                     hstlWrap.Hostel_OR_Quater_Type = ''; 
                }
                if(hostelReq.Status__c == 'Approved'){
                    hstlWrap.Start_date = Datetime.now().format('yyyy-MM-dd');
                }
                else if(hostelReq.Salary_Last_Revised_Date__c !=null && hostelReq.Status__c == 'Room Allotted' ) {
                     
                     hstlWrap.Start_date = String.valueOf(hostelReq.Salary_Last_Revised_Date__c);
                }
                hstlWrap.SLCM_Record_Id = hostelReq.Id;
                

                String jsonBody = JSON.serialize(new List<hostelReqCnfWrapper>{hstlWrap});
                System.debug('Sending this JSON body: ' + jsonBody);
                String HCM_HostelQuarters_API_EndPoint = HCM_Endpoints__c.getInstance('Hostel Quarters API').End_Point__c;
                HttpResponse res = sendApprovalConfirmation(HCM_HostelQuarters_API_EndPoint, accessToken, jsonBody);

                System.debug('Response Status Code: ' + res.getStatusCode());
                System.debug('Response Body: ' + res.getBody());

                if (res.getStatusCode() == 200 && !String.isEmpty(res.getBody())) {
                    try {
                        List<hostelResCnfWrapper> respCnf = (List<hostelResCnfWrapper>) JSON.deserialize(res.getBody(), List<hostelResCnfWrapper>.class);
                        for (hostelResCnfWrapper respoWr : respCnf) {
                            hostelApproversCnfMap.put(hostelReq.Id, respoWr);
                        }

                        System.debug('Successfully deserialized response and added to map.');
                        lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMHostelCNFAPI', jsonBody, res.getBody(), 'Success'));
                    } catch (JSONException e) {
                        System.debug('JSON Deserialization Error: ' + e.getMessage());
                        lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMHostelCNFAPI', jsonBody, res.getBody(), 'Failure'));
                    }
                } else {
                    System.debug('Error: Unexpected response status or empty body.');
                    lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMHostelCNFAPI', jsonBody, res.getBody(), 'Failure'));
                }
            } catch (Exception e) {
                System.debug('Failed to get confirmation: ' + e.getMessage());
                lst_DbLogs.add(createDebugLog('sendApprovedConfirmationHCM', 'SLCM_HCMHostelCNFAPI', null, e.getMessage(), 'Failure'));
            }
        }

        // Step 4: Prepare Records for Update
        if (!hostelApproversCnfMap.isEmpty()) {
            System.debug('Updating records based on the response map.');
            for (Id hostelReqId : hostelApproversCnfMap.keySet()) {
                Reva_Hostel_Request__c hostelReq = new Reva_Hostel_Request__c();
                hostelResCnfWrapper respCnf = hostelApproversCnfMap.get(hostelReqId);

                if (respCnf.Status == 'Success') { //&& respCnf.SLCM_Record_Id.contains(hostelReqId)
                    hostelReq.Id = hostelReqId;
                    System.debug('Setting Is_HCM_Salary_Deduction_CNF__c to true for ' + hostelReqId);
                    if (hostelExistingDataMap.get(hostelReqId).Status__c == 'Approved'){
                        hostelReq.Is_HCM_Salary_Deduction_CNF__c = true;
                        hostelReq.HCM_Salary_Approval_CNF_Error__c ='';
                    }
                    else if(hostelExistingDataMap.get(hostelReqId).Status__c == 'Room Allotted') {
                        hostelReq.Is_Revised_Salary_Push_to_HCM__c = true;
                        hostelReq.HCM_Revised_Salary_CNF_Error__c ='';
                    }   
                   
                } else if (respCnf.Status == 'Failed' ) { //&& respCnf.SLCM_Record_Id.contains(hostelReqId)
                    hostelReq.Id = hostelReqId;
                    System.debug('Setting Is_HCM_Salary_Deduction_CNF__c to false and recording error for ' + hostelReqId);
                    if (hostelExistingDataMap.get(hostelReqId).Status__c == 'Approved'){
                        hostelReq.Is_HCM_Salary_Deduction_CNF__c = false;
                         hostelReq.HCM_Salary_Approval_CNF_Error__c = respCnf.ErrorMessage +' OR Contact your Admin because deduction confirmation failed by HCM';
                    }
                    else if (hostelExistingDataMap.get(hostelReqId).Status__c == 'Room Allotted') {
                        hostelReq.Is_Revised_Salary_Push_to_HCM__c = false;
                       hostelReq.HCM_Revised_Salary_CNF_Error__c = respCnf.ErrorMessage +' Contact your Admin Because new revised salary deduction confirmation failed by HCM' ;
                    } 
                   
                   
                }
                hostelReqToUpdate.add(hostelReq);
            }
        } 

        // Step 5: Execute Bulk Updates and Log Results
        if (!hostelReqToUpdate.isEmpty()) {
            System.debug('hostelReqToUpdate---'+hostelReqToUpdate);
           List<Database.SaveResult> updateResults = Database.update(hostelReqToUpdate, false);
           for (Integer i = 0; i < updateResults.size(); i++) {
                if (!updateResults[i].isSuccess()) {
                    
                    // Log errors
                    System.debug('Error updating record ' + hostelReqToUpdate[i].Id + ': ' + updateResults[i].getErrors()[0].getMessage());
                    // Assuming lst_DbLogs is a list of some log object and needs to be updated
                    lst_DbLogs[i].Response__c += updateResults[i].getErrors()[0].getMessage();
                } else {
                    System.debug('sucessss res---'+updateResults);
                    // Add successful records to the success list
                    successfulUpdates.add(hostelReqToUpdate[i]);
                }
            }
            
        } 

        if (!lst_DbLogs.isEmpty()) {
            System.debug('Inserting ' + lst_DbLogs.size() + ' log entries.');
            insert lst_DbLogs;
        }
         return successfulUpdates ;
        
    }

    /**
     * Method Name: sendApprovalConfirmation
     * Description: 
     * This method makes an HTTP POST request to the specified endpoint, sending the JSON body and using the access token for authentication.
     * 
     * @param endpoint String - The endpoint URL to which the HTTP POST request will be sent.
     * @param accessToken String - The access token used for authentication in the HTTP request.
     * @param jsonBody String - The JSON-formatted string that will be sent in the body of the HTTP request.
     * @return HttpResponse - The HTTP response returned by the endpoint after the request is processed.
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
     * This helper method creates a Debug_Log__c object for logging purposes.
     * 
     * @param methodName String - The name of the method where the log is generated.
     * @param className String - The name of the class where the log is generated.
     * @param request String - The request payload, if applicable.
     * @param response String - The response payload, if applicable.
     * @param status String - The status of the log (e.g., 'Success', 'Failure').
     * @return Debug_Log__c - A Debug_Log__c object ready to be inserted.
     */
    private static Debug_Log__c createDebugLog(String methodName, String className, String request, String response, String status) {
        Debug_Log__c log = new Debug_Log__c();
        log.Method_Name__c = methodName;
        log.Class_Name__c = className;
        log.Request__c = request;
        log.Response__c = response;
      //  log.Status__c = status;
        System.debug('Creating log entry: ' + log);
        return log;
    }

    /**
     * Wrapper Class: hostelReqCnfWrapper
     * Description: 
     * A wrapper class representing the structure of the request payload sent to HCM for confirming hostel requests.
     */
    public class hostelReqCnfWrapper {
        public String Employee_Number;
        public String Start_date;
        public String Amount;
        public String Type;
        public Id SLCM_Record_Id;
        public String Hostel_OR_Quater_Type;
    }

    /**
     * Wrapper Class: hostelResCnfWrapper
     * Description: 
     * A wrapper class representing the structure of the response payload received from HCM after confirming hostel requests.
     */
    public class hostelResCnfWrapper {
        public String Status;
        public String ErrorMessage;
        public String SLCM_Record_Id;
    }
}