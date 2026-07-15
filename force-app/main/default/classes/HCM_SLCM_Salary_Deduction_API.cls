@RestResource(urlMapping='/SalaryDeductionAPI')
global class HCM_SLCM_Salary_Deduction_API {

    @HttpPost
    global static List<ResponseWrapper> doPost() {
        String requestBody = RestContext.request.requestBody.toString();
        List<SalaryDeductionWrapper> deductions = new List<SalaryDeductionWrapper>();
        List<ResponseWrapper> responses = new List<ResponseWrapper>();
        List<Debug_Log__c> lst_DbLogs = new List<Debug_Log__c>();
        
        

        try {
            // Deserialize JSON request into list of SalaryDeductionWrapper objects
            deductions = (List<SalaryDeductionWrapper>) JSON.deserialize(requestBody, List<SalaryDeductionWrapper>.class);
        } catch (JSONException e) {
            return createErrorResponse('Invalid JSON format', null, lst_DbLogs);
        }

        // Process each deduction
        for (SalaryDeductionWrapper deduction : deductions) {
            ResponseWrapper response = processDeduction(deduction, lst_DbLogs);
            responses.add(response);
        }

        // Log debug records
        if (!lst_DbLogs.isEmpty()) {
            insert lst_DbLogs;
        }

        return responses;
    }

    private static ResponseWrapper processDeduction(SalaryDeductionWrapper deduction, List<Debug_Log__c> lst_DbLogs) {
        ResponseWrapper response;
        Id requestId = null;
        List<Reva_Hostel_Request__c> hstleRequset = new List<Reva_Hostel_Request__c> ();
        List<Staff_Quarters_Request__c> quarterRequset = new List<Staff_Quarters_Request__c> ();
        
        //List<Reva_Hostel_Request__c> updateHostelRevisedCNF = new  List<Reva_Hostel_Request__c>();

        try {
            // Validate the deduction and ensure the Employee_Number exists
            if (deduction != null &&  deduction.Employee_Number !='' && deduction.Employee_Number != null) {
                
                // Determine the relevant request object based on the Type
                if (deduction.Type == 'Hostel') {
                    System.debug('inside Hostel');
                    requestId = getHostelRequestId(deduction.Employee_Number);
                } else if (deduction.Type == 'Quarter') {
                    System.debug('inside Quarter');
                    requestId = getQuartersRequestId(deduction.Employee_Number);
                }

                if (requestId == null) {
                    System.debug('inside Null value');
                    // Employee number not found, return an error response
                    response = new ResponseWrapper('Failed', deduction.HCM_Record_Id, 'Employee number not found In '+deduction.Type +' OR Salary deduction not yet confirmed by HCM');
                    lst_DbLogs.add(createDebugLog('processDeduction', JSON.serialize(deduction), JSON.serialize(response), 'Failure - Employee number not found'));
                    return response;
                }

                // Check if an existing deduction record matches the given criteria
                List<HCM_Monthly_Salary_Deduction__c> existingDeductions = [
                    SELECT Id, Fiscal_Year__c, Fiscal_Month__c, HCM_Record_Id__c,Employee_Number__c,Type__c, Employee_Name__c,Actual_Deduction_Amount__c,Current_Deduction_Amount__c
                    FROM HCM_Monthly_Salary_Deduction__c 
                    WHERE  // Record Id for every Month  AB
                     Fiscal_Month__c = :deduction.Fiscal_Month //  APR
                    AND Fiscal_Year__c = :deduction.Fiscal_Year  //2024
                    AND HCM_Record_Id__c =:deduction.HCM_Record_Id
                    AND (Staff_Quarters_Request__c != null or REVA_Hostel_Request__c !=null)
                    LIMIT 1
                ];

                HCM_Monthly_Salary_Deduction__c hcmDeduction;
                
                if (existingDeductions.isEmpty()  ) {
                    System.debug('inside existingDeductions empty');
                    // No existing record, create a new one
                    hcmDeduction = new HCM_Monthly_Salary_Deduction__c();
                    hcmDeduction.Employee_Name__c = deduction.Employee_Name;
                    hcmDeduction.Employee_Number__c = deduction.Employee_Number;
                    hcmDeduction.HCM_Record_Id__c = deduction.HCM_Record_Id;
                    hcmDeduction.Fiscal_Year__c = deduction.Fiscal_Year;
                    hcmDeduction.Fiscal_Month__c = deduction.Fiscal_Month;
                    hcmDeduction.Type__c = deduction.Type;
                    
                    if (deduction.Type == 'Hostel' ) {
                         hcmDeduction.Reva_Hostel_Request__c = requestId;
                        hstleRequset = [SELECT Id ,Is_Revised_Salary_Push_to_HCM__c FROM Reva_Hostel_Request__c 
                                                           WHERE Hostel_Room_Request_For__r.Employee_Number__c = :deduction.Employee_Number 
                                                           ORDER BY CreatedDate DESC limit 1] ;
                        
                        
                         hstleRequset[0].Is_Revised_Salary_Push_to_HCM__c = false;

                    } else if (deduction.Type == 'Quarter' ) {
                        hcmDeduction.Staff_Quarters_Request__c = requestId;
                        quarterRequset= [SELECT Is_Revised_Salary_Push_to_HCM__c,Id FROM Staff_Quarters_Request__c 
                                                           WHERE Quarter_Request_For__r.Employee_Number__c = :deduction.Employee_Number 
                                                           AND Is_HCM_Salary_Deduction_CNF__c = true ORDER BY CreatedDate DESC limit 1];
                        quarterRequset[0].Is_Revised_Salary_Push_to_HCM__c = false;
                    }
                } else {
                    System.debug('inside existingDeduction  not empty');
                    // Existing record found, update it
                    hcmDeduction = existingDeductions[0];
                }

                // Set common fields
                hcmDeduction.Actual_Deduction_Amount__c = deduction.Actual_Deduction_Amount;
                hcmDeduction.Current_Deduction_Amount__c = deduction.Current_Deduction_Amount;
                
                
                
                
                

                // Insert or update the record
                if (existingDeductions.isEmpty()) {
                    System.debug('inside if for insert');
                    insert hcmDeduction;
                } else {
                    System.debug('inside if for update');
                    update hcmDeduction;
                }
                if(!hstleRequset.isEmpty()){
                    update hstleRequset;
                }
                if(!quarterRequset.isEmpty()){
                    update quarterRequset;
                }
                System.debug('hcmDeduction--'+hcmDeduction);
                
                // Assign success response
                response = new ResponseWrapper('Success', deduction.HCM_Record_Id, null);
                lst_DbLogs.add(createDebugLog('Success', JSON.serialize(deduction), JSON.serialize(response), 'Success -Salary Deduction record Created/Updated Successfully'));
                
            } else {
                System.debug('fail--');
                // Assign failure response for invalid input
                response = new ResponseWrapper('Failed', deduction.HCM_Record_Id, 'Invalid request or Missing Employee Number');
                lst_DbLogs.add(createDebugLog('processDeduction', JSON.serialize(deduction), JSON.serialize(response), 'Failure - Invalid Data'));
            } 
        } catch (Exception ex) {
            response = new ResponseWrapper('Failed', deduction.HCM_Record_Id, ex.getMessage());
        }

        return response;
    }

    // Helper method to fetch the Hostel Request Id by Employee Number
    private static Id getHostelRequestId(String employeeNumber) {
        try {
            System.debug('employeeNumber hostel--'+employeeNumber);
            return [SELECT Id FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__r.Employee_Number__c = :employeeNumber AND Is_HCM_Salary_Deduction_CNF__c = true ORDER BY CreatedDate DESC
            LIMIT 1].Id;
        } catch (Exception e) {
            return null; // Return null if no record is found
        }
    }

    // Helper method to fetch the Staff Quarters Request Id by Employee Number
    private static Id getQuartersRequestId(String employeeNumber) {
        try {
            System.debug('employeeNumber quarter--'+employeeNumber);
            return [SELECT Id FROM Staff_Quarters_Request__c WHERE Quarter_Request_For__r.Employee_Number__c = :employeeNumber AND Is_HCM_Salary_Deduction_CNF__c = true ORDER BY CreatedDate DESC
            LIMIT 1].Id;
        } catch (Exception e) {
            return null; // Return null if no record is found
        }
    }

    // Helper method to create an error response
    private static List<ResponseWrapper> createErrorResponse(String errorMessage, String hcmRecordId, List<Debug_Log__c> lst_DbLogs) {
        List<ResponseWrapper> errorResponse = new List<ResponseWrapper>();
        ResponseWrapper response = new ResponseWrapper('Failed', hcmRecordId, errorMessage);
        errorResponse.add(response);
        lst_DbLogs.add(createDebugLog('doPost', null, JSON.serialize(response), errorMessage));
        return errorResponse;
    }

    // Helper method to create a debug log entry
    private static Debug_Log__c createDebugLog(String methodName, String requestBody, String responseBody, String message) {
        Debug_Log__c log = new Debug_Log__c();
        log.Class_Name__c = 'HCM_SLCM_Salary_Deduction_API';
        log.Method_Name__c = methodName;
        //log.Request_Body__c = requestBody;
        //log.Response_Body__c = responseBody;
        //log.Message__c = message;
        return log;
    }

    // Wrapper class for Salary Deduction
    global class SalaryDeductionWrapper {
        public String Employee_Number;
        public String Employee_Name;
        public String Type;
        public String HCM_Record_Id;
        public String Fiscal_Year;
        public String Fiscal_Month;
        public Decimal Actual_Deduction_Amount;
        public Decimal Current_Deduction_Amount;
    }

    // Wrapper class for Response
    global class ResponseWrapper {
        public String Status;
        public String HCM_Record_Id;
        public String ErrorMessage;

        public ResponseWrapper(String Status, String hcmRecordId, String errorMessage) {
            this.Status = Status;
            this.HCM_Record_Id = hcmRecordId;
            this.ErrorMessage = errorMessage;
        }
    }
}