@RestResource(urlMapping = '/StudentRefundAPI')
global class SAP_StudentRefundAPI {
    @HttpPost
    global static List<InsertOrUpdateResponse> createOrUpdateStudentPayments(List<PaymentData> paymentDataList) {
        List<Student_Payment__c> studentPaymentsToUpsert = new List<Student_Payment__c>();
        List<InsertOrUpdateResponse> responseList = new List<InsertOrUpdateResponse>(); 
        for (PaymentData paymentData : paymentDataList) {
            InsertOrUpdateResponse response = new InsertOrUpdateResponse();   
            if (!isValidIdFormat(paymentData.Contact)) {
                response.Success = false;
                response.Message = 'Error: Invalid Contact ID';
                response.SAP_Code = paymentData.SAP_Code;
                responseList.add(response);
                continue;
            }
            try {
                
                if(String.isNotBlank(paymentData.SAP_Code) && isValidIdFormat(paymentData.Contact))
                {                  
                    Student_Payment__c newPayment = new Student_Payment__c(
                        Contact__c = paymentData.Contact,
                        SAP_Code__c = paymentData.SAP_Code+'-'+paymentData.Contact, 
                        Offline_Receipt_Number__c = paymentData.Offline_Receipt_Number,
                        Amount__c = paymentData.Amount,
                        Mode_of_Payment__c = paymentData.Mode_of_Payment,
                        Payment_Status__c = 'Refunded',
                        Integrated_with_SAP__c = true,
                        Payment_Mode_Type__c = paymentData.Payment_Mode_Type,
                        Description__c = paymentData.Remarks,
                        SFDC_Record_ID_Refund_API__c = paymentData.SFDC_RecordId
                    );
                    if(paymentData.Payment_Date_Time != null)
                    {
                        newPayment.Payment_Date_Time__c = paymentData.Payment_Date_Time;
                    }
                    
                    studentPaymentsToUpsert.add(newPayment);
                }
                else {
                    
                    response.Success = false;
                    response.Message = 'Error: SAP_Code is required for upsert';
                    response.SAP_Code = paymentData.SAP_Code;
                    response.SFDCRecordID = paymentData.SFDCRecordID;
                    responseList.add(response);
                    continue; 
                }
            } catch (Exception e) {
                 System.debug('An error occurred: ' + e.getMessage());
                response.Success = false;
                response.Message = 'Error: Unable to create/update payment record - ' + e.getMessage();
                response.SAP_Code = paymentData.SAP_Code;
                response.SFDCRecordID = paymentData.SFDCRecordID;
                responseList.add(response);
                continue; 
            }
            
        }
        
        List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>();
        if (!studentPaymentsToUpsert.isEmpty()) {
            upsertResults = Database.upsert(studentPaymentsToUpsert, Student_Payment__c.Fields.SAP_Code__c, false);
        }
        
        for (Integer i = 0; i < upsertResults.size(); i++) {
            Database.UpsertResult result = upsertResults[i];
            InsertOrUpdateResponse response = new InsertOrUpdateResponse();
            if (result.isSuccess()) {
                response.Success = true;
                response.Message = 'Record ' + (result.isCreated() ? 'created' : 'updated') + ' successfully';
                response.SFDCRecordID = result.getId();
                response.SAP_Code = studentPaymentsToUpsert[i].SAP_Code__c.substringBefore('-');
                
            } else {
                response.Success = false;
                response.Message = 'Error: Unable to ' + (result.isCreated() ? 'create' : 'update') + ' payment record - ' + result.getErrors()[0].getMessage();
                response.SFDCRecordID = studentPaymentsToUpsert[i].SAP_Code__c.substringAfter('-');
                response.SAP_Code = studentPaymentsToUpsert[i].SAP_Code__c.substringBefore('-');            }
            responseList.add(response);
            
        }
        
        return responseList;
    }
    public  static Boolean isValidIdFormat(String idString) {
        Pattern idPattern = Pattern.compile('^[a-zA-Z0-9]{18}|[a-zA-Z0-9]{15}$');
        return idPattern.matcher(idString).matches();
    }
    global class PaymentData {
        public String Contact;
        public String Offline_Receipt_Number;
        public Decimal Amount;
        public String Mode_of_Payment;
        public DateTime Payment_Date_Time;
        public String SFDCRecordID;
        public String SFDC_RecordId;
        public String Payment_Status;
        public String Payment_Mode_Type;
        public String SAP_Code;
        public String PaymentStatus;
        public String Remarks;
        
    }
    
    global class InsertOrUpdateResponse {
        public Boolean Success;
        public String Message;
        public Id SFDCRecordID;
        public String SAP_Code;
    }
}