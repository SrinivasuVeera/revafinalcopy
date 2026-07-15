/**
 * @Author: Devender Jadala
 * @Date: 2024-08-27
 *
 * @Description:
 * The `SLCM_HCMHostelApprovalHierarchyAPI` class is designed to fetch approval hierarchy data from the HCM system 
 * based on employee IDs and update corresponding hostel request records in the SLCM system. 
 * This process involves obtaining an access token, making HTTP callouts to retrieve approval hierarchy data, 
 * deserializing the response, and updating the hostel request records with the appropriate approvers in SLCM.
 */
public class SLCM_HCMHostelApprovalHierarchyAPI {

    /**
     * @Description:
     * This method processes a set of hostel request IDs by making an HTTP callout to the HCM system 
     * to retrieve approval hierarchy data. It updates the hostel request records with the appropriate approvers 
     * based on the employee ID associated with each request.
     *
     * @param hostelReqIds Set of hostel request record IDs to be processed.
     */
    public static  List<Reva_Hostel_Request__c> approvalHierarchyCreationMethod(Set<Id> hostelReqIds) {
        String accessToken;
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Reva_Hostel_Request__c> hostelReqToUpdate = new List<Reva_Hostel_Request__c>();
        Map<Id, List<Approver>> hostelApproversMap = new Map<Id, List<Approver>>();
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
                lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMApprovalHierarchyAPI', 'Access Token Request', 'Access token is empty.', 'Failure'));
                return null;
            }
        } catch (Exception e) {
            System.debug('Error obtaining access token: ' + e.getMessage());
            lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMApprovalHierarchyAPI', 'Access Token Request', e.getMessage(), 'Failure'));
            return null;
        }

        // Step 2: Query Hostel Requests in Bulk
        List<Reva_Hostel_Request__c> hostelReqs = [
            SELECT Id, Hostel_Room_Request_For__r.Employee_Number__c 
            FROM Reva_Hostel_Request__c 
            WHERE Id IN :hostelReqIds 
            AND HCM_Approval_Status__c = 'Deduction Request Initiated'
            AND (Room_Request_Type__c = 'Non Teaching' OR Room_Request_Type__c = 'Professor')
            AND Hostel_Room_Request_For__c != null
            AND Hostel_Room_Request_For__r.Employee_Number__c != null 
            AND Employee_Salary__c != null
        ];

        if (hostelReqs.isEmpty()) {
            System.debug('No Hostel requests found matching the criteria.');
            lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMApprovalHierarchyAPI', null, 'No Hostel requests found matching the criteria.', 'No Data'));
            return null;
        }
        for (Reva_Hostel_Request__c hostelReq : hostelReqs) {
               String HCM_Hierarchy_EndPoint = HCM_Endpoints__c.getInstance('Approval hierarchy API').End_Point__c;

                String requestEndpoint = HCM_Hierarchy_EndPoint + hostelReq.Hostel_Room_Request_For__r.Employee_Number__c;
                try {
                    // Step 3: Make the HTTP Callout
                    HttpResponse res = getApprovalHierarchy(requestEndpoint, accessToken);

                    // Debug: Log the response status code and body
                    System.debug('Response Status Code: ' + res.getStatusCode());
                    System.debug('Response Body: ' + res.getBody());

                    // Defensive check: Ensure the response is not empty and has content
                    if (res.getStatusCode() == 200 && !String.isEmpty(res.getBody())) {
                        try {
                            List<Approver> approversList = (List<Approver>) JSON.deserialize(res.getBody(), List<Approver>.class);
                            System.debug('Deserialized approversList: ' + approversList);
                            if (approversList.size() > 0) {
                                hostelApproversMap.put(hostelReq.Id, approversList);
                                lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMApprovalHierarchyAPI', requestEndpoint, JSON.serialize(approversList), 'Success'));

                            }
                            else {
                                lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMApprovalHierarchyAPI', requestEndpoint, res.getBody(), 'Approved List is Empty'));

                            }
                        } catch (JSONException e) {
                            System.debug('JSON Deserialization Error: ' + e.getMessage());
                            lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMApprovalHierarchyAPI', requestEndpoint, res.getBody(), 'Deserialization Failure'));
                        }
                    } else {
                        System.debug('Error: Unexpected response status or empty body.');
                        lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMApprovalHierarchyAPI', requestEndpoint, res.getBody(), 'Failure due to empty body'));
                    }
                } catch (Exception e) {
                    System.debug('Failed to get approval hierarchy: ' + e.getMessage());
                    lst_DbLogs.add(createDebugLog('approvalHierarchyCreationMethod', 'SLCM_HCMApprovalHierarchyAPI', requestEndpoint, e.getMessage(), 'HTTP Callout Failure'));
                }
            }

            // Step 4: Prepare Records for Update
            if (!hostelApproversMap.isEmpty()) {
                System.debug('hostelApproversMap: ' + hostelApproversMap);
                for (Id hostelReqId : hostelApproversMap.keySet()) {
                    List<Approver> approversList = hostelApproversMap.get(hostelReqId);
                    Reva_Hostel_Request__c hostelReq = new Reva_Hostel_Request__c();
                    hostelReq.Id = hostelReqId;

                    for (Approver approver : approversList) {
                        if (approver.Approver_type == 'Reporting Manager') {
                            hostelReq.Reporting_Manager__c = [SELECT Id FROM User WHERE Contact.Employee_Number__c = :approver.Employee_Number OR EmployeeNumber  =:approver.Employee_Number LIMIT 1].Id;
                        } else if (approver.Approver_type == 'Admin Director') {
                            hostelReq.Admin_Director__c = [SELECT Id FROM User WHERE Contact.Employee_Number__c = :approver.Employee_Number OR EmployeeNumber  =:approver.Employee_Number LIMIT 1].Id;
                        } else if (approver.Approver_type == 'HR Lead') {
                            hostelReq.HR_Lead__c = [SELECT Id FROM User WHERE Contact.Employee_Number__c = :approver.Employee_Number OR EmployeeNumber  =:approver.Employee_Number LIMIT 1].Id;
                        }
                        
                        
                    }
					//hostelReq.Hostel_Officer__c =[SELECT Id FROM User WHERE Profile.Name='Hostel Profile' AND IsActive=True Limit 1].Id;
                    User hostelOfficer = [SELECT Id FROM User WHERE Profile.Name = 'Hostel Profile' AND IsActive = TRUE LIMIT 1];

                    if (hostelOfficer != null) {
                        hostelReq.Hostel_Officer__c = hostelOfficer.Id;
                    } else {
                        
                        System.debug('No active user with "Hostel Profile" found.');
                        
                        hostelReq.Hostel_Officer__c = null; 
                    }
                    hostelReq.Status__c = 'Booked';
                    hostelReqToUpdate.add(hostelReq);
                }
            }

            // Step 5: Execute Bulk Updates and Log Results
            if (!hostelReqToUpdate.isEmpty()) {
                System.debug('hostelReqToUpdate: ' + hostelReqToUpdate);
                List<Database.SaveResult>  updateResults = Database.update(hostelReqToUpdate, false);
                System.debug('updateResults------'+updateResults);
                for (Integer i = 0; i < updateResults.size(); i++) {
                    if (!updateResults[i].isSuccess()) {
                        lst_DbLogs[i].Response__c += updateResults[i].getErrors()[0].getMessage();
                    }
                    else{
                         System.debug('sucessss res---'+updateResults);
                    // Add successful records to the success list
                    successfulUpdates.add(hostelReqToUpdate[i]);
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
        System.debug('endpoint= 233=> ' + endpoint);
        System.debug('accessToken= 333=> ' + accessToken);
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