@RestResource(urlMapping='/api/createMonthlyDeduction/')
global without sharing class TransportMothlyDeductionAPI {

    @HttpPost
    global static void MonthlyDeduction() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<ResponseWrapper> responseList = new List<ResponseWrapper>();

        try {
            // Deserialize the incoming JSON into an Object first
            String jsonString = req.requestBody.toString();
            System.debug('Received JSON: ' + jsonString);
            Object deserializedData = JSON.deserializeUntyped(jsonString);
            System.debug('Deserialized Data: ' + deserializedData);

            // Check if the deserialized data is indeed a List
            if (deserializedData instanceof List<Object>) {
                List<Object> inputDataList = (List<Object>) deserializedData;

                // Lists to hold records for insert and update
                List<TransportMothlyDeduction__c> deductionsToInsert = new List<TransportMothlyDeduction__c>();
                List<TransportMothlyDeduction__c> deductionsToUpdate = new List<TransportMothlyDeduction__c>();

                Set<String> hcmRecordIds = new Set<String>();

                // Collect all HCM Record IDs from input for efficient querying
                for (Object inputItem : inputDataList) {
                    if (inputItem instanceof Map<String, Object>) {
                        Map<String, Object> inputData = (Map<String, Object>) inputItem;
                        String hcmRecordId = ((String) inputData.get('HCM_Record_Id')).trim();
                        if (hcmRecordId != null) {
                            hcmRecordIds.add(hcmRecordId);
                        }
                    }
                }

                // Query existing TransportMonthlyDeduction records by HCM_Record_Id
                Map<String, TransportMothlyDeduction__c> existingDeductionsMap = new Map<String, TransportMothlyDeduction__c>();
                if (!hcmRecordIds.isEmpty()) {
                    for (TransportMothlyDeduction__c existingDeduction : [
                        SELECT Id, HCM_Record_Id__c 
                        FROM TransportMothlyDeduction__c 
                        WHERE HCM_Record_Id__c IN :hcmRecordIds
                    ]) {
                        existingDeductionsMap.put(existingDeduction.HCM_Record_Id__c.trim(), existingDeduction);
                    }
                }
                System.debug('Existing Deductions Map: ' + existingDeductionsMap);

                // Process each item in the input data
                for (Object inputItem : inputDataList) {
                    if (inputItem instanceof Map<String, Object>) {
                        Map<String, Object> inputData = (Map<String, Object>) inputItem;

                        // Extract input data fields
                        String employeeNumber = (String) inputData.get('Employee_Number');
                        String employeeName = (String) inputData.get('Employee_Name');
                        String types = (String) inputData.get('Type');
                        String hcmRecordId = ((String) inputData.get('HCM_Record_Id')).trim();
                        String fiscalYear = (String) inputData.get('Fiscal_Year');
                        String fiscalMonth = (String) inputData.get('Fiscal_Month');
                        Decimal actualDeductionAmount = (Decimal) inputData.get('Actual_Deduction_Amount');
                        Decimal currentDeductionAmount = (Decimal) inputData.get('Current_Deduction_Amount');

                        System.debug('Processing Employee Number: ' + employeeNumber);

                        // Fetch Transport Registration record based on Employee Number
                        List<Transport_Registeration__c> transportRegistrations = [
                            SELECT Id 
                            FROM Transport_Registeration__c 
                            WHERE Contact__r.Employee_Number__c = :employeeNumber
                        ];
                        System.debug('Found Transport Registrations: ' + transportRegistrations);

                        if (!transportRegistrations.isEmpty()) {
                            Transport_Registeration__c transport = transportRegistrations[0];

                            // Check if a TransportMonthlyDeduction record already exists
                            if (existingDeductionsMap.containsKey(hcmRecordId)) {
                                // Update existing record
                                TransportMothlyDeduction__c existingDeduction = existingDeductionsMap.get(hcmRecordId);
                                existingDeduction.Employee_Number__c = employeeNumber;
                                existingDeduction.Employee_Name__c = employeeName;
                                existingDeduction.Type__c = types;
                                existingDeduction.Fiscal_Year__c = fiscalYear;
                                existingDeduction.Fiscal_Month__c = fiscalMonth;
                                existingDeduction.Actual_Deduction_Amount__c = actualDeductionAmount;
                                existingDeduction.Current_Deduction_Amount__c = currentDeductionAmount;
                                existingDeduction.Transport_Registration__c = transport.Id;

                                deductionsToUpdate.add(existingDeduction);
                                responseList.add(new ResponseWrapper(hcmRecordId, 'Success', null));
                            } else {
                                // Create new record
                                TransportMothlyDeduction__c newDeduction = new TransportMothlyDeduction__c();
                                newDeduction.Employee_Number__c = employeeNumber;
                                newDeduction.Employee_Name__c = employeeName;
                                newDeduction.Type__c = types;
                                newDeduction.Fiscal_Year__c = fiscalYear;
                                newDeduction.HCM_Record_Id__c = hcmRecordId;
                                newDeduction.Fiscal_Month__c = fiscalMonth;
                                newDeduction.Actual_Deduction_Amount__c = actualDeductionAmount;
                                newDeduction.Current_Deduction_Amount__c = currentDeductionAmount;
                                newDeduction.Transport_Registration__c = transport.Id;

                                deductionsToInsert.add(newDeduction);
                                responseList.add(new ResponseWrapper(hcmRecordId, 'Success', null));
                            }
                        } else {
                            responseList.add(new ResponseWrapper(hcmRecordId, 'Failed', 'No matching transport registration found.'));
                        }
                    }
                }

                // Bulk insert and update operations
                if (!deductionsToInsert.isEmpty()) insert deductionsToInsert;
                if (!deductionsToUpdate.isEmpty()) update deductionsToUpdate;

                res.responseBody = Blob.valueOf(JSON.serialize(responseList));
                res.statusCode = 200;
            } else {
                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(null, 'Failed', 'Invalid JSON structure.')));
                res.statusCode = 400;
            }
        } catch (Exception ex) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(null, 'Failed', ex.getMessage())));
            res.statusCode = 500;
        }
    }

    global class ResponseWrapper {
        public String HCM_Record_Id;
        public String Status;
        public String ErrorMessage;

        public ResponseWrapper(String hcmRecordId, String status, String errorMessage) {
            this.HCM_Record_Id = hcmRecordId;
            this.Status = status;
            this.ErrorMessage = errorMessage;
        }
    }
}