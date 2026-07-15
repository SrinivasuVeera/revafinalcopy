@RestResource(urlMapping='/StudentExamFeeAPI/*')
global class FEE_StudentExamFee_API 
{
	@HttpPost
    global static void createDemandDetails()
    {
        ExamFeeRespWrap objRespWrap = new ExamFeeRespWrap();
        String jsonBody;
        RestRequest objRestRequest = RestContext.request;
        RestResponse objRestResponse = RestContext.response;
        List<Student_Fee__c> lstStudFees = new List<Student_Fee__c>();
        ReqExamWrp objReqExamWrp = new ReqExamWrp();
        jsonBody = objRestRequest.requestBody.toString().trim();
        
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'FEE_StudentExamFee_API';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'StudentExamFeeAPI';
        dLog.Object_Name__c = 'Student_Fee__c';
        Insert dLog;
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        
        try
        {
            if(jsonBody != null)
            {
                dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
                // Deserialize the JSON string into RequestWrapper
                objReqExamWrp = (ReqExamWrp) JSON.deserialize(jsonBody, ReqExamWrp.class);
                if(objReqExamWrp.studentfee != Null && objReqExamWrp.studentfee.size() >0)
                {
                    Set<String> set_SrnNos = new Set<String>();
                    Map<String, hed__Program_Enrollment__c> map_ProgEnrolls = new Map<String, hed__Program_Enrollment__c>();
                    for(StudentFeePayement objStudFeePay : objReqExamWrp.studentfee)
                    {
                        if(String.isNotBlank(objStudFeePay.StudentSrnNumber))
                            set_SrnNos.add(objStudFeePay.StudentSrnNumber); 
                    }
                    
                    if(!set_SrnNos.isEmpty())
                    {
                        for(hed__Program_Enrollment__c objProgEnroll : [Select Id, Name, SRN_Number__c, Active__c from 
                                                                        hed__Program_Enrollment__c where Active__c =: True 
                                                                        AND SRN_Number__c IN : set_SrnNos])
                        {
                            map_ProgEnrolls.put(objProgEnroll.SRN_Number__c, objProgEnroll);
                        }
                    }
                    
                    for(StudentFeePayement objStudFeePay : objReqExamWrp.studentfee)
                    {
                        Student_Fee__c objStudFee = new Student_Fee__c();
                        objStudFee.Name = String.isNotBlank(objStudFeePay.FeeName) ? objStudFeePay.FeeName : Null;
                        objStudFee.Exam_Application_Number__c = objStudFeePay.StudentExamAppNo; 
                        objStudFee.Fee_Type__c = 'Examination & Valuation Fee';
                        objStudFee.Received_Source__c = 'Logisys';
                        objStudFee.Due_Date__c = String.isNotBlank(objStudFeePay.DueDate) ? Date.parse(objStudFeePay.DueDate) : Null;
                        objStudFee.Amount__c = String.isNotBlank(objStudFeePay.Amount) ? Decimal.valueOf(objStudFeePay.Amount) : Null;
                        objStudFee.Amount_Pending__c = String.isNotBlank(objStudFeePay.Amount) ? Decimal.valueOf(objStudFeePay.Amount) : Null;
                        if(String.isNotBlank(objStudFeePay.StudentSrnNumber))
                        {
                            objStudFee.Contact__r =  new Contact(SRN_Number__c = objStudFeePay.StudentSrnNumber);
                            if(map_ProgEnrolls.get(objStudFeePay.StudentSrnNumber) != Null)
                                objStudFee.Program_Enrollment__c =  map_ProgEnrolls.get(objStudFeePay.StudentSrnNumber).Id;
                        }
                        lstStudFees.add(objStudFee);
                    }
                    
                    String status = '';
                    Integer successCount = 0;
                    Integer errorCount = 0;
                    List<resultWpr> list_resultWpr = new List<resultWpr>();
                    if(lstStudFees.size() > 0)
                    {
                        Database.UpsertResult[] result = Database.upsert(lstStudFees, Student_Fee__c.Exam_Application_Number__c, false);
                        for(Integer i=0;i<result.size();i++)
                        {
                            if(result[i].isSuccess())
                            {
                                successCount++;
                                resultWpr rw = new resultWpr();
                                rw.status = 'Success';
                                rw.studentExamAppNo = lstStudFees[i].Exam_Application_Number__c;
                                rw.error = '';
                                list_resultWpr.add(rw);
                            }
                            else
                            {
                                errorCount++;
                                resultWpr rw = new resultWpr();
                                rw.status = 'Failed';
                                rw.studentExamAppNo = lstStudFees[i].Exam_Application_Number__c;
                                rw.error = result[i].getErrors()[0].getMessage();
                                list_resultWpr.add(rw);
                            }
                        }
                        objRespWrap.result = list_resultWpr;
                        
                        if(successCount == lstStudFees.size())
                            status = 'Success';
                        else if(successCount > 0 && errorCount > 0)
                            status = 'Partial Success';
                        else
                            status = 'Failure';
                    }
                    objRespWrap.status = status;
                    objRespWrap.message = '';
                    dLog.Status__c = status;
                }
                else
                {
                    objRespWrap.status = 'Failed';
                    objRespWrap.message = 'Student Fee Data is Empty..!';
                    dLog.Error_Message__c = objRespWrap.message;
                }
            }
            else
            {
                objRespWrap.status = 'Failed';
                objRespWrap.message = 'Request Data is Empty..!';
                dLog.Error_Message__c = objRespWrap.message;
            }
            String response = Json.serialize(objRespWrap);
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
            update dLog;
        }
        catch(Exception ex)
        {
            dLog.Error_Message__c = String.valueOf(ex.getMessage())+'. At: '+ex.getStackTraceString();
            update dLog;
            
            objRespWrap.status = 'Failed';
            objRespWrap.message = dLog.Error_Message__c;
        }
        objRestResponse.addHeader('Content-Type', 'application/json');
        objRestResponse.responseBody = Blob.valueof(Json.serialize(objRespWrap));
    }
    
    global class ReqExamWrp
    {
        public List<StudentFeePayement> studentfee;
    }
    
    global class StudentFeePayement
    {
        public String StudentExamAppNo;
        public String StudentSrnNumber;
        public String FeeName;
        public String DueDate;
        public String Amount;
    }
    
    //Wrapper classes for Response Json
    global class ExamFeeRespWrap
    {
        public String status;
        public String message;
        public List<ResultWpr> result;
    }
    
    public class ResultWpr
    {
        public String status;
        public String studentExamAppNo;
        public String error;
    }
}