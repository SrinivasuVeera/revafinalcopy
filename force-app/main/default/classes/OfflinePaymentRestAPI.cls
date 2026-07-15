@RestResource(urlMapping = '/StudentPaymentOfflineAPI')
global class OfflinePaymentRestAPI {
    
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
                //response.SFDCRecordID = paymentData.SFDCRecordID;
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
                        Payment_Status__c = paymentData.PaymentStatus,
                        Auto_Allocate__c = true,
                        Integrated_with_SAP__c = true,
                        Cheque_Bank_Name__c = paymentData.Cheque_Bank_Name,
                        ChequeDD_Number__c = paymentData.Cheque_DD_Number,
                        Demand_Number__c = paymentData.Demand_Number,
                        Payment_Mode_Type__c = paymentData.Payment_Mode_Type,
                        Description__c = paymentData.Remarks
                    );
                    if(string.isNotBlank(paymentData.Cheque_DD_Date))
                    {
                        newPayment.ChequeDD_Date__c =date.valueof(paymentData.Cheque_DD_Date);
                    }
                    if(paymentData.Payment_Date_Time != null)
                    {
                        newPayment.Payment_Date_Time__c = paymentData.Payment_Date_Time;//datetime.valueof(paymentData.Payment_Date_Time);
                    }
                    if(string.isNotBlank(paymentData.Cheque_DD_Realisation_Date))
                    {
                        newPayment.ChequeDD_Realisation_Date__c = date.valueof(paymentData.Cheque_DD_Realisation_Date);
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
                response.Success = false;
                response.Message = 'Error: Unable to create/update payment record - ' + e.getMessage();
                  response.SAP_Code = paymentData.SAP_Code;
                response.SFDCRecordID = paymentData.SFDCRecordID;
                responseList.add(response);
                continue; 
            }
            //responseList.add(response);
        }
        
        List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>();
        if (!studentPaymentsToUpsert.isEmpty()) {
            upsertResults = Database.upsert(studentPaymentsToUpsert, Student_Payment__c.Fields.SAP_Code__c, false);
            //upsertResults.addAll(Database.upsert(studentPaymentsToUpdate, Student_Payment__c.Fields.SAP_Code__c, false));
        }
        
        for (Integer i = 0; i < upsertResults.size(); i++) {
            Database.UpsertResult result = upsertResults[i];
            //InsertOrUpdateResponse response = responseList[i];
            InsertOrUpdateResponse response = new InsertOrUpdateResponse();
            if (result.isSuccess()) {
                response.Success = true;
                response.Message = 'Record ' + (result.isCreated() ? 'created' : 'updated') + ' successfully';
                //response.SFDCRecordID = result.getId();
                response.SFDCRecordID = result.getId();
                response.SAP_Code = studentPaymentsToUpsert[i].SAP_Code__c.substringBefore('-');
                //responseList.add(response);
                
            } else {
                response.Success = false;
                response.Message = 'Error: Unable to ' + (result.isCreated() ? 'create' : 'update') + ' payment record - ' + result.getErrors()[0].getMessage();
                response.SFDCRecordID = studentPaymentsToUpsert[i].SAP_Code__c.substringAfter('-');
                response.SAP_Code = studentPaymentsToUpsert[i].SAP_Code__c.substringBefore('-');            }
            responseList.add(response);
            system.debug('response.Message '+response.Message);
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
        public String Demand_Number;
        public String Payment_Status;
        public String Payment_Mode_Type;
        public String Cheque_DD_Number;
        public string Cheque_DD_Date;
        public string Cheque_DD_Realisation_Date;
        public String Cheque_Bank_Name;
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