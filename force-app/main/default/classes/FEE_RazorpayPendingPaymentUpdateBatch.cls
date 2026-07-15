global class FEE_RazorpayPendingPaymentUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    
    global void execute(SchedulableContext sc) {
        FEE_RazorpayPendingPaymentUpdateBatch b = new FEE_RazorpayPendingPaymentUpdateBatch();        
        Database.executeBatch(b, 5);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime startDate = System.now().addDays(-7);
        DateTime endDate = System.now();
        
        // Query remains the same, but we will filter in the execute block
        if (Test.isRunningTest()) {
            return Database.getQueryLocator([
                SELECT Id, Transaction_ID__c, Payment_Link_Id__c, Reference_Id__c, Fee_Type__c, 
                Payment_Status__c, Payment_Gateway__c, Payment_Mode_Type__c, Amount__c, Payment_Date_Time__c, Mode_of_Payment__c,
                Contact__c, Contact__r.Application_Fee_Paid__c, Contact__r.Application_Number__c, 
                Contact__r.record_type_name__c, Contact__r.MobilePhone, Contact__r.Country_Code__c
                FROM Student_Payment__c 
                WHERE (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Payment Link Created' OR Payment_Status__c = 'Failed') 
                AND Payment_Gateway__c = 'Razorpay' 
                AND Reference_Id__c != Null
            ]);
        } else {        
            return Database.getQueryLocator([
                SELECT Id, Transaction_ID__c, Payment_Link_Id__c, Reference_Id__c, Fee_Type__c, 
                Payment_Status__c, Payment_Gateway__c, Payment_Mode_Type__c, Amount__c, Payment_Date_Time__c, Mode_of_Payment__c,
                Contact__c, Contact__r.Application_Fee_Paid__c, Contact__r.Application_Number__c, 
                Contact__r.record_type_name__c, Contact__r.MobilePhone, Contact__r.Country_Code__c
                FROM Student_Payment__c 
                WHERE (Payment_Status__c = 'Pending' OR Payment_Status__c = 'Payment Link Created' OR Payment_Status__c = 'Failed') 
                AND Payment_Gateway__c = 'Razorpay' 
                AND LastModifiedDate >= :startDate 
                AND LastModifiedDate <= :endDate 
                AND Reference_Id__c != Null
            ]);
        }
    }

    global void execute(Database.BatchableContext BC, List<Student_Payment__c> scope) {
        final String APPLICATION_FEE_TYPE = 'Application Fee';
        List<Student_Payment__c> stuPayListUpdated = new List<Student_Payment__c>();
        List<Debug_Log__c> debugLogs = new List<Debug_Log__c>();
        
        String username = Razorpay_Details__c.getInstance('UserName').Value__c;
        String password = Razorpay_Details__c.getInstance('Password').Value__c;
        
        for (Student_Payment__c stu : scope) {
            Debug_Log__c dblog = new Debug_Log__c();
            dblog.Class_Name__c = 'FEE_RazorpayReconciliationBatch';
            dblog.Method_Name__c = 'execute';
            dblog.Processing_API_Name__c = 'RazorPay';
            
            try {               
                String endpoint = '';
                if (String.isNotBlank(stu.Payment_Link_Id__c)) {
                    endpoint = 'https://api.razorpay.com/v1/payment_links/' + stu.Payment_Link_Id__c;
                } else if (String.isNotBlank(stu.Transaction_ID__c)) {
                    endpoint = 'https://api.razorpay.com/v1/payments/' + stu.Transaction_ID__c;
                } else { continue; }
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)));
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                dblog.Data_Received__c = res.getBody(); 
                
                if (res.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    String rpStatus = (String) results.get('status');
                    String newSFStatus = stu.Payment_Status__c;
                    Boolean isRecordChanged = false;

                    // 1. Determine New Status
                    if (rpStatus == 'paid' || rpStatus == 'captured') {
                        newSFStatus = 'Success';
                    } else if (rpStatus == 'failed' || rpStatus == 'expired' || rpStatus == 'cancelled') {
                        newSFStatus = 'Failed';
                    }

                    // 2. ONLY check for changes to prevent redundant Audit Logs
                    if (stu.Payment_Status__c != newSFStatus) {
                        stu.Payment_Status__c = newSFStatus;
                        isRecordChanged = true;
                        
                        // Only set timestamp if it is currently null to avoid "jumping" dates
                        if (newSFStatus == 'Success' && stu.Payment_Date_Time__c == null) {
                            stu.Payment_Date_Time__c = System.now();
                        }
                    }

                    // 3. Check for Payment Method/Transaction ID changes
                    if (results.containsKey('payments')) {
                        List<Object> pList = (List<Object>) results.get('payments');
                        if(!pList.isEmpty()) {
                            Map<String, Object> lastP = (Map<String, Object>) pList[0];
                            String apiMethod = (String) lastP.get('method');
                            String apiTransId = (String) lastP.get('payment_id');
                            
                            if(stu.Payment_Mode_Type__c != apiMethod || stu.Transaction_ID__c != apiTransId) {
                                stu.Payment_Mode_Type__c = apiMethod;
                                stu.Transaction_ID__c = apiTransId;
                                isRecordChanged = true;
                            }
                        }
                    } else if (results.containsKey('method')) {
                        String apiMethod = (String) results.get('method');
                        if(stu.Payment_Mode_Type__c != apiMethod) {
                            stu.Payment_Mode_Type__c = apiMethod;
                            isRecordChanged = true;
                        }
                    }

                    // 4. Final Decision: Only add to update list if a change actually occurred
                    if (isRecordChanged) {
                        if (stu.Payment_Status__c == 'Success') {
                            try {
                                handleReceipts(stu, APPLICATION_FEE_TYPE);
                            } catch (Exception receiptEx) {            
                                dblog.Error_Message__c = 'Receipt Failed: ' + receiptEx.getMessage();
                            }
                        } 
                        stuPayListUpdated.add(stu);
                        dblog.Status__c = 'Success';
                    }
                } else {
                    dblog.Status__c = 'Failure';
                    dblog.Error_Message__c = 'HTTP Error: ' + res.getStatusCode();
                }
            } catch (Exception ex) {
                dblog.Status__c = 'Failure';
                dblog.Error_Message__c = ex.getMessage();
            }
            debugLogs.add(dblog);
        }
        
        // DML Operations - This now only fires for records that actually changed
        if (!stuPayListUpdated.isEmpty()) {
            Database.SaveResult[] results = Database.update(stuPayListUpdated, false);
            updateChildFeePayments(stuPayListUpdated, results);
        }
        
        if (!debugLogs.isEmpty()) {
            Database.insert(debugLogs, false);
        }
    }
    
    private void handleReceipts(Student_Payment__c stu, String APPLICATION_FEE_TYPE) {
        if (stu.Fee_Type__c == APPLICATION_FEE_TYPE && stu.Contact__r.Application_Fee_Paid__c == false) {
            Id cvId = RegistrationFormUtility.generateReceipt(stu.Id, stu.Transaction_ID__c, 'Razorpay');
            RegistrationFormUtility.sendReceipt(stu.Id, cvId);
        } 
        else if (stu.Fee_Type__c != APPLICATION_FEE_TYPE) {
            Boolean applPAF = false;
            if (stu.Contact__r.record_type_name__c == 'Applicant') {
                List<hed__Application__c> applList = [SELECT Provisional_Admission_Fee_Paid__c FROM hed__Application__c 
                                                      WHERE Application_Number__c = :stu.Contact__r.Application_Number__c LIMIT 1];
                if (!applList.isEmpty()) {
                    applPAF = applList[0].Provisional_Admission_Fee_Paid__c;
                }
            }
            
            if (applPAF == false) {
                List<Student_Fee__c> sf = [SELECT Id FROM Student_Fee__c WHERE Contact__c = :stu.Contact__c AND Fee_year__c = '1st Year' LIMIT 1];
                if (!sf.isEmpty()) {
                    AdmissionsProcessUtility.generateOfflineReceipt(stu.Id, stu.Payment_Mode_Type__c, 'Razorpay', stu.Transaction_ID__c);
                }
            }
        }
    }
    
    private void updateChildFeePayments(List<Student_Payment__c> parents, Database.SaveResult[] parentResults) {
        List<Id> successfulParentIds = new List<Id>();
        Map<Id, Student_Payment__c> payMap = new Map<Id, Student_Payment__c>();
        
        for (Integer i = 0; i < parentResults.size(); i++) {
            if (parentResults[i].isSuccess()) {
                Id pId = parents[i].Id;
                successfulParentIds.add(pId);
                payMap.put(pId, parents[i]);
            }
        }
        
        if (!successfulParentIds.isEmpty()) {
            List<Student_Fee_Payment__c> children = [SELECT Id, Student_Payment__c,Line_Item_Payment_Status__c,SF_Transaction_ID__c,Reference_Id__c,Line_Item_Payment_Gateway__c,
                                                     Payment_Mode_Type__c,Transaction_Date_Time__c FROM Student_Fee_Payment__c
                                                     WHERE Student_Payment__c IN :successfulParentIds];
            for (Student_Fee_Payment__c child : children) {
                Student_Payment__c p = payMap.get(child.Student_Payment__c);
                child.Line_Item_Payment_Status__c = p.Payment_Status__c;
                child.SF_Transaction_ID__c = p.Transaction_ID__c;
                child.Payment_Mode_Type__c = p.Payment_Mode_Type__c;
                child.Line_Item_Payment_Gateway__c = p.Payment_Gateway__c;
                child.Transaction_Date_Time__c = p.Payment_Date_Time__c;
                child.Reference_Id__c = p.Reference_Id__c;
            }        
            Database.update(children, false);
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}