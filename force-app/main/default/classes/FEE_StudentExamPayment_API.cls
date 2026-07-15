public class FEE_StudentExamPayment_API 
{
	@future(callout=true)
    public static void sendStudExamFee(Set<Id> set_StudPayFee)
    {
       
		Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'FEE_StudentExamPayment_API';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Student Exam Fee Data to Logisys';
        dLog.Object_Name__c = 'Student_Fee_Payment__c';
        dLog.No_of_Records__c = set_StudPayFee.size();
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;

        try
        {
            RequestWrp objRequestWrp = new RequestWrp();
            map<String,Student_Fee_Payment__c> map_Student_Fee_Payment = new map<string,Student_Fee_Payment__c>();
            for(Student_Fee_Payment__c objStudFeePay : [Select Id, Name, Student_Fee__c, Mode_of_Payment__c,
                                                        Line_Item_Payment_Gateway__c, Transaction_Date_Time__c,
                                                        Student_Fee__r.Name, Student_Fee__r.SRN_Number__c,
                                                        Student_Fee__r.Amount__c, Student_Fee__r.Amount_Paid__c,
                                                        SF_Transaction_ID__c, Amount__c, Exam_Application_Number__c,
                                                        Payment_Mode_Type__c, Line_Item_Payment_Status__c
                                                        from Student_Fee_Payment__c where ID IN: set_StudPayFee])
            {
                StudentFeePayWrp objStudFeePayWrp = new StudentFeePayWrp();
                objStudFeePayWrp.StudentApplicationNo = objStudFeePay.Exam_Application_Number__c;
                objStudFeePayWrp.StudentSrnNumber = String.isNotBlank(objStudFeePay.Student_Fee__r.SRN_Number__c) ? objStudFeePay.Student_Fee__r.SRN_Number__c : Null;
                objStudFeePayWrp.FeeName = String.isNotBlank(objStudFeePay.Student_Fee__r.Name) ? objStudFeePay.Student_Fee__r.Name : Null;
                objStudFeePayWrp.TotalAmount = String.isNotBlank(String.valueOf(objStudFeePay.Student_Fee__r.Amount__c)) ? String.valueOf(objStudFeePay.Student_Fee__r.Amount__c) : Null;
                objStudFeePayWrp.PaidAmount = String.isNotBlank(String.valueOf(objStudFeePay.Student_Fee__r.Amount_Paid__c)) ? String.valueOf(objStudFeePay.Student_Fee__r.Amount_Paid__c) : Null;
                objStudFeePayWrp.PaymentGateway = String.isNotBlank(objStudFeePay.Line_Item_Payment_Gateway__c) ? objStudFeePay.Line_Item_Payment_Gateway__c : Null;
                objStudFeePayWrp.TransactionId = String.isNotBlank(objStudFeePay.SF_Transaction_ID__c) ? objStudFeePay.SF_Transaction_ID__c : Null;
                objStudFeePayWrp.TransactionDateTime = String.isNotBlank(String.valueOf(objStudFeePay.Transaction_Date_Time__c)) ? String.valueOf(objStudFeePay.Transaction_Date_Time__c) : Null;
                objStudFeePayWrp.PaymentType = String.isNotBlank(objStudFeePay.Payment_Mode_Type__c) ? objStudFeePay.Payment_Mode_Type__c : Null;
                objStudFeePayWrp.PaymentMode = String.isNotBlank(objStudFeePay.Mode_of_Payment__c) ? objStudFeePay.Mode_of_Payment__c : Null;
                objStudFeePayWrp.PaymentStatus = String.isNotBlank(objStudFeePay.Line_Item_Payment_Status__c) ? objStudFeePay.Line_Item_Payment_Status__c : Null;
                objRequestWrp.studentFeePayment.add(objStudFeePayWrp);
                map_Student_Fee_Payment.put(objStudFeePay.Exam_Application_Number__c,objStudFeePay);
            }
            
            String jsonBody = json.serialize(objRequestWrp);
            System.debug('jsonBody=='+jsonBody);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);             
            HttpRequest hReq = LogisysAPIUtility.mapRequest('FEE_StudentExamPayment_API',jsonBody);
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            
            String response = hRsp+' ::: '+hRsp.getBody();
            
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
            if(hRsp.getStatusCode() == 200)
            {
                dLog.Status__c = 'Success';
                responseWrap objResponse = (responseWrap)Json.deserialize(string.Valueof(hRsp.getBody()), responseWrap.class);
                if(objResponse.Status == 'Failure') dLog.Status__c = 'Failure';
               
                Data objData = objResponse.data;
                List<Student_Fee_Payment__c> lst_StudFeePay = new List<Student_Fee_Payment__c>();
                for(Resdata objResdata : objData.resdata)
                {
                    if(objResdata.msg == 'Updated Successfully' && string.isNotBlank(objResdata.StudentApplicationNo) && map_Student_Fee_Payment.containsKey(objResdata.StudentApplicationNo))
                    {                    	
                    	map_Student_Fee_Payment.get(objResdata.StudentApplicationNo).Logisys_Integration__c = true;                         
                    }
                }
                utility.LogisysAPI = false;                 
                if(map_Student_Fee_Payment.size() > 0) update map_Student_Fee_Payment.values();
            }
            Insert dLog;
        }
        catch(Exception ex)
        {
            dLog.Status__c = 'Failure';
            dLog.Error_Message__c = ex.getMessage()+'. At: '+ex.getStackTraceString();
            Insert dLog;
        }
    }
    
    public class RequestWrp
    {
       public List<StudentFeePayWrp> studentFeePayment;
        public RequestWrp()
        {
            studentFeePayment = new List<StudentFeePayWrp>();
        }
    }
    
    public class StudentFeePayWrp
    {
        public String StudentApplicationNo;
        public String StudentSrnNumber;
        public String FeeName;
        public String TotalAmount;
        public String PaidAmount;
        public String PaymentGateway;
        public String TransactionId;
        public String TransactionDateTime;
        public String PaymentType;
        public String PaymentMode;
        public String PaymentStatus;
    }
    
   

    public class responseWrap {
        public Integer error_code;
        public String status;
        public Data data;
    }
    
    public class Data {
        public List<Resdata> resdata;
    }
    public class Resdata {
        public String status;
        public String msg;
        public String StudentApplicationNo;
        public String StudentSrnNumber;
    }
}