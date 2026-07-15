/**
 * @Author: Devender Jadala
 * @Date: 2024-08-27
 * 
 * @Description:
 * The `SLCM_HCMQuarterApprovalHierarchyAPI` class is designed to fetch approval hierarchy data from the HCM system based on employee IDs 
 * and update corresponding Quarter request records in the SLCM system. This process involves obtaining an access token, 
 * making HTTP callouts to retrieve approval hierarchy data, deserializing the response, and updating the Quarter request records
 * with the appropriate approvers in SLCM.
 */
public class SLCM_HCMQuarterApprovalHierarchyAPI {

    /**
     * @Description:
     * This method processes a set of Quarter request IDs by making an HTTP callout to the HCM system to retrieve approval hierarchy data. 
     * It updates the Quarter request records with the appropriate approvers based on the employee ID associated with each request.
     * 
     * @param quarterReqIds Set of Quarter request record IDs to be processed.
     */
    public static List<Staff_Quarters_Request__c> approvalHierarchyCreationMethod(Set<Id> quarterReqIds) {

        String accessToken;
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Staff_Quarters_Request__c> quarterReqToUpdate = new List<Staff_Quarters_Request__c>();
        Map<Id, List<Approver>> quarterApproversMap = new Map<Id, List<Approver>>();
        
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
                lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', null, 'Access token is empty', 'Failure'));
                return null;
            }
            System.debug('Access token obtained successfully: ' + accessToken);
        } catch (Exception e) {
            System.debug('Error obtaining access token: ' + e.getMessage());
            lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', null, e.getMessage(), 'Failure'));
            return null;
        }

        // Step 2: Query Quarter Requests in Bulk
        List<Staff_Quarters_Request__c> quarterReqs = [
            SELECT Id, Quarter_Request_For__r.Employee_Number__c
            FROM Staff_Quarters_Request__c 
            WHERE Id IN :quarterReqIds 
            AND Quarter_Request_For__r.Employee_Number__c != null 
            AND Employee_Salary__c != null
            AND Status__c ='Request Submitted'
            AND HCM_Approval_Status__c = 'Deduction Request Initiated'
        ];

        if (quarterReqs.isEmpty()) {
            System.debug('No Quarter requests found matching the criteria.');
            lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', null, 'No Quarter requests found matching the criteria.', 'No Data'));
            return null;
        }

        for (Staff_Quarters_Request__c quarterReq : quarterReqs) {
            String HCM_Hierarchy_EndPoint = HCM_Endpoints__c.getInstance('Approval hierarchy API').End_Point__c;
            String currentEndpoint = HCM_Hierarchy_EndPoint + quarterReq.Quarter_Request_For__r.Employee_Number__c;
            try {
                // Step 3: Make the HTTP Callout
                HttpResponse res = getApprovalHierarchy(currentEndpoint, accessToken);

                // Debug: Log the response status code and body
                System.debug('Response Status Code: ' + res.getStatusCode());
                System.debug('Response Body: ' + res.getBody());

                // Defensive check: Ensure the response is not empty and has content
                if (res.getStatusCode() == 200 && !String.isEmpty(res.getBody())) {
                    try {
                        List<Approver> approversList = (List<Approver>) JSON.deserialize(res.getBody(), List<Approver>.class);
                        if (approversList.size()>0) {
                            System.debug('Deserialized approversList: ' + approversList);
                           quarterApproversMap.put(quarterReq.Id, approversList);
                           lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', currentEndpoint, JSON.serialize(approversList), 'Success'));
                        }
                        else {
                            System.debug(' No approversList:');
                            lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', currentEndpoint, res.getBody() ,'Approver List is Empty'));
                        }
                        

                    } catch (JSONException e) {
                        System.debug('JSON Deserialization Error: ' + e.getMessage());
                        lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', currentEndpoint, e.getMessage(), 'Deserialization Failure'));
                    }
                } else {
                    System.debug('Error: Unexpected response status or empty body.');
                    lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', currentEndpoint, res.getBody(), 'Failure'));
                }
            } catch (Exception e) {
                System.debug('Failed to get approval hierarchy: ' + e.getMessage());
                lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', currentEndpoint, e.getMessage(), 'Failure'));
            }
        }

        // Step 4: Prepare Records for Update
        if (!quarterApproversMap.isEmpty()) {
            System.debug('quarterApproversMap: ' + quarterApproversMap);
            for (Id quarterReqId : quarterApproversMap.keySet()) {
                List<Approver> approversList = quarterApproversMap.get(quarterReqId);
                Staff_Quarters_Request__c quarterReq = new Staff_Quarters_Request__c();
                quarterReq.Id = quarterReqId;

                for (Approver approver : approversList) {
                    if (approver.Approver_type == 'Reporting Manager') {
                        quarterReq.Reporting_Manager__c = [SELECT Id FROM User WHERE Contact.Employee_Number__c = :approver.Employee_Number OR EmployeeNumber = :approver.Employee_Number LIMIT 1].Id;
                        System.debug('Reporting Manager ID set: ' + quarterReq.Reporting_Manager__c);
                    } else if (approver.Approver_type == 'Admin Director') {
                        quarterReq.Admin_Director__c = [SELECT Id FROM User WHERE Contact.Employee_Number__c = :approver.Employee_Number OR EmployeeNumber = :approver.Employee_Number LIMIT 1].Id;
                        System.debug('Admin Director ID set: ' + quarterReq.Admin_Director__c);
                    } else if (approver.Approver_type == 'HR Lead') {
                        quarterReq.HR_Lead__c = [SELECT Id FROM User WHERE Contact.Employee_Number__c = :approver.Employee_Number OR EmployeeNumber = :approver.Employee_Number LIMIT 1].Id;
                        System.debug('HR Lead ID set: ' + quarterReq.HR_Lead__c);
                    }
                }
                //quarterReq.Hostel_Officer__c =[SELECT Id FROM User WHERE Profile.Name='Hostel Profile' AND IsActive = true Limit 1].Id;
                User hostelOfficer = [SELECT Id FROM User WHERE Profile.Name = 'Hostel Profile' AND IsActive = TRUE LIMIT 1];

                    if (hostelOfficer != null) {
                        quarterReq.Hostel_Officer__c = hostelOfficer.Id;
                    } else {
                        
                        System.debug('No active user with "Hostel Profile" found.');
                        
                        quarterReq.Hostel_Officer__c = null; 
                    }
                quarterReq.Status__c = 'Booked';
                quarterReqToUpdate.add(quarterReq);
            }
        } else {
            System.debug('No approvers were found to update.');
            lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMQuarterApprovalHierarchyAPI', null, 'No approvers found to update.', 'No Data'));
        }

        // Step 5: Execute Bulk Updates and Log Results
        if (!quarterReqToUpdate.isEmpty()) {
            System.debug('quarterReqToUpdate: ' + quarterReqToUpdate);
                List<Database.SaveResult>  updateResults = Database.update(quarterReqToUpdate, false);
                System.debug('updateResults------'+updateResults);
                for (Integer i = 0; i < updateResults.size(); i++) {
                    if (!updateResults[i].isSuccess()) {
                        lst_DbLogs[i].Response__c += updateResults[i].getErrors()[0].getMessage();
                    }
                    else{
                         System.debug('sucessss res---'+updateResults);
                    // Add successful records to the success list
                    successfulUpdates.add(quarterReqToUpdate[i]);
                    }
                }
                TriggerControl.isHCMQueueableRun = false;
        }

        if (!lst_DbLogs.isEmpty()) {
            insert lst_DbLogs;
        }
        return successfulUpdates;
    }

     /**
     * @Description:
     * Makes an HTTP GET request to the provided endpoint with the given access token.
     *
     * @param endpoint The URL endpoint to make the request to.
     * @param accessToken The access token for authorization.
     * @return HttpResponse The HTTP response from the endpoint.
     */
    private static HttpResponse getApprovalHierarchy(String endpoint, String accessToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        return http.send(req);
    }

    /**
     * @Description:
     * Creates a debug log record for tracking the process.
     *
     * @param methodName The name of the method where the log is being created.
     * @param className The name of the class where the log is being created.
     * @param request The request made (if applicable).
     * @param response The response received (if applicable).
     * @param status The status of the operation (e.g., Success, Failure).
     * @return Debug_Log__c A new Debug_Log__c record.
     */

    private static Debug_Log__c createDebugLog(String methodName, String className, String request, String response, String status) {
        Debug_Log__c log = new Debug_Log__c();
        log.Method_Name__c = methodName;
        log.Class_Name__c = className;
        log.Request__c = request;
        log.Response__c = response;
        //log.Status__c = status;
        return log;
    }

     /**
     * @Description:
     * The `Approver` class represents the data structure of the approvers returned by the HCM system.
     */
    public class Approver {
        public String Official_email;
        public String Employee_Number;
        public String Employee_Name;
        public String Approver_type;
    }
}