/**
* Author: Devender Jadala
* Date: 2024-08-28
* 
* Class Description:
* The SLCM_HCMHostelSalaryRangeAPI class is responsible for handling the salary range retrieval process from HCM for hostel room requests by Employee ID.
* It obtains an access token, sends HTTP callouts to an HCM salary range API for each relevant hostel request, 
* processes the response, and updates the Hostel request records in CRM. This class also logs the request 
* and response details for debugging purposes.
*/
public class SLCM_HCMHostelSalaryRangeAPI {
    /**
* The salaryRangeCreationMethod is the primary method for processing a set of hostel request IDs.
* It retrieves the salary range data for each HCM Response and updates the related records.
*
* @param hostelReqIds Set of Reva_Hostel_Request__c record IDs to process.
*/
    public static void salaryRangeCreationMethod(Set<Id> hostelReqIds) {
        System.debug('hostelReqIds---'+hostelReqIds);
        String accessToken;
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        List<Reva_Hostel_Request__c> hostelReqToUpdate = new List<Reva_Hostel_Request__c>();
        Map<Id, Reva_Hostel_Request__c> hostelReqMap = new Map<Id, Reva_Hostel_Request__c>();
        Map<Id, Reva_Hostel_Request__c> hstlReqRevisedSalaryDate = new Map<Id, Reva_Hostel_Request__c>();
        
        
        
        // Step 1: Obtain Access Token
        try {
            System.debug('hostelReqIds- inside acc try--');
            if(Test.isRunningTest()){
                accessToken = 'hjwvfkuvuyrbliw4ojkdcnjregtrtgrtrtwterttrow';
            }else{
                accessToken = RevaHostelHCM_AccessTokenRequest.getAccessToken();
            }
            System.debug('hostelReqIds---'+hostelReqIds);
            if (String.isEmpty(accessToken)) {
                System.debug('Error: Access token is empty.');
                lst_DbLogs.add(createDebugLog('salaryRangeCreationMethod', 'SLCM_HCMSalaryRangeAPI', null, 'Access token is empty.', 'Failure'));
                return;
            }
        } catch (Exception e) {
            System.debug('Error obtaining access token: ' + e.getMessage());
            lst_DbLogs.add(createDebugLog('salaryRangeCreationMethod', 'SLCM_HCMSalaryRangeAPI', null, e.getMessage(), 'Failure'));
            return;
        }
        
        // Step 2: Query Hostel Requests
        List<Reva_Hostel_Request__c> hostelReqs = [
            SELECT Id, Hostel_Room_Request_For__r.Employee_Number__c ,Type__c,Hostel_Room_Request_For__r.Salary_Revised_Date__c,Employee_Salary__c
            FROM Reva_Hostel_Request__c 
            WHERE Id IN :hostelReqIds 
            AND (Room_Request_Type__c = 'Non Teaching' OR Room_Request_Type__c = 'Professor')
            AND Hostel_Room_Request_For__c != null
            AND Hostel_Room_Request_For__r.Employee_Number__c != null
        ];
        
        if (hostelReqs.isEmpty()) {
            System.debug('No Hostel requests found matching the criteria.');
            lst_DbLogs.add(createDebugLog('salaryRangeCreationMethod', 'SLCM_HCMSalaryRangeAPI', null, 'No Hostel requests found matching the criteria.', 'Failure'));
            return;
        }
        
        // Map Hostel Request IDs to Employee Numbers
        for (Reva_Hostel_Request__c hostelReq : hostelReqs) {
            hostelReqMap.put(hostelReq.Id, hostelReq);
            if(hostelReq.Hostel_Room_Request_For__r.Salary_Revised_Date__c !=null){
                hstlReqRevisedSalaryDate.put(hostelReq.Id,hostelReq);  
            }  
            
        }
        
        // Step 3: Make HTTP Callouts and Process Responses
        for (Id hostelReqId : hostelReqMap.keySet()) {
            String HCM_SalaryRange_EndPoint = HCM_Endpoints__c.getInstance('Salary Range API').End_Point__c;
            
            String employeeNumber = hostelReqMap.get(hostelReqId).Hostel_Room_Request_For__r.Employee_Number__c;
            String reqType = 'Hostel';
            String requestEndpoint = HCM_SalaryRange_EndPoint ;
            System.debug('requestEndpoint2---'+requestEndpoint);
            requestEndpoint += 'Employee_Number=' + EncodingUtil.urlEncode(employeeNumber, 'UTF-8');
            System.debug('requestEndpoint--2-'+requestEndpoint);
            requestEndpoint += '&Type=' + EncodingUtil.urlEncode(reqType, 'UTF-8');
            System.debug('requestEndpoint--3-'+requestEndpoint);
            
            
            try {
                // Step 4: Make the HTTP Callout
                HttpResponse res = getSalaryRange(requestEndpoint, accessToken);
                Debug_Log__c debugLog = createDebugLog('salaryRangeCreationMethod', 'SLCM_HCMSalaryRangeAPI', requestEndpoint, res.getBody(), 'Pending');
                System.debug('res: ' + res);
                // Step 5: Process the Response
                if (res.getStatusCode() == 200 && !String.isEmpty(res.getBody())) {
                    System.debug('res: inside  '+res.getBody());
                    SalaryRangeData salaryResponse = (SalaryRangeData) JSON.deserialize(res.getBody(), SalaryRangeData.class);
                    System.debug('salaryResponse---'+salaryResponse);
                    if (salaryResponse != null && salaryResponse.Salary_Range != null) {
                        System.debug('salaryResponse---'+salaryResponse.Salary_Range );
                        Reva_Hostel_Request__c hostelReq = new Reva_Hostel_Request__c(Id = hostelReqId);
                        if(hstlReqRevisedSalaryDate.containsKey(hostelReqId) && hstlReqRevisedSalaryDate.get(hostelReqId).Employee_Salary__c != salaryResponse.Salary_Range){
                            System.debug('hostelReq.Employee_Salary__c---');
                            hostelReq.Salary_Last_Revised_Date__c = hstlReqRevisedSalaryDate.get(hostelReqId).Hostel_Room_Request_For__r.Salary_Revised_Date__c;
                            // hostelReq.Is_Revised_Salary_Push_to_HCM__c = false;
                            hostelReq.HCM_Revised_Salary_CNF_Error__c = '';
                        }
                        if(reqType == salaryResponse.Type){
                            hostelReq.Employee_Salary__c = salaryResponse.Salary_Range;
                            hostelReqToUpdate.add(hostelReq);
                            
                            debugLog.Status__c = 'Success';
                        }
                        
                    } else {
                        debugLog.Status__c = 'Failure';
                    }
                    debugLog.Response__c = res.getBody();
                } else {
                    debugLog.Status__c = 'Failure';
                }
                
                lst_DbLogs.add(debugLog);
                
            } catch (Exception e) {
                System.debug('Failed to get salary range data: ' + e.getMessage());
                Debug_Log__c debugLog = createDebugLog('salaryRangeCreationMethod', 'SLCM_HCMSalaryRangeAPI', requestEndpoint, e.getMessage(), 'Failure');
                lst_DbLogs.add(debugLog);
            }
        }
        
        // Step 6: Update Hostel Request Records
        if (!hostelReqToUpdate.isEmpty()) {
            System.debug('hostelReqToUpdate: ' +hostelReqToUpdate);
            Database.SaveResult[] updateResults = Database.update(hostelReqToUpdate, false);
            
            for (Integer i = 0; i < updateResults.size(); i++) {
                if (!updateResults[i].isSuccess()) {
                    lst_DbLogs[i].Response__c += updateResults[i].getErrors()[0].getMessage();
                }
            }
            TriggerControl.isHCMQueueableRun = false;
        }
        
        // Step 7: Insert Logs
        if (!lst_DbLogs.isEmpty()) {
            insert lst_DbLogs;
        }
    }
    
    /**
* The getSalaryRange method performs an HTTP GET request to the salary range API endpoint.
*
* @param endpoint The API endpoint URL.
* @param accessToken The access token for authorization.
* @return HttpResponse The response received from the HCM.
*/
    private static HttpResponse getSalaryRange(String endpoint, String accessToken) {
        System.debug('endpoint---'+endpoint);
        System.debug('endpoint accessToken---'+accessToken);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        return http.send(req);
    }
    
    /**
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
        log.Status__c = status;
        return log;
    }
    
    /**
* Inner class to represent the Salary Range API response structure.
*/
    public class SalaryRangeData {
        public String Employee_Number;
        public String Employee_Name;
        public Decimal Salary_Range;
        public String Type;
    }
}