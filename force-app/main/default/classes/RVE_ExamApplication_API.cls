/**
* @description       : This class is used to send students exam application details to logisys after completion of payment.
* @author            : Aditya Dhulipala
* @group             : Cloud Odyssey
* @last modified on  : 05-04-2024
* @last modified by  : 
* @Comments          : Calling this apex class into RVE_ExamApplication_API_trigger trigger
**/
public with sharing class RVE_ExamApplication_API {
    @future(callout=true)
    public static void sendExamApplication(Set<Id> set_examApplicationId)
    {
       
		Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'RVE_ExamApplication_API';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Student Exam application Data to Logisys';
        dLog.Object_Name__c = 'Rve_Exam_Application__c';
        dLog.No_of_Records__c = 1;
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;

        try
        {
            RequestWrp objRequestWrp = new RequestWrp();
            map<String,Rve_Exam_Application_Line_Item__c> map_Student_examApplication = new map<string,Rve_Exam_Application_Line_Item__c>();
            for(Rve_Exam_Application_Line_Item__c timetableLineItem : [Select Id,Course_Code__c,Rve_Exam_Application__c,Rve_Exam_Application__r.Rve_Logisys_Field_Check__c,
                                                                         Rve_Subject__c,  Rve_Exam_Application__r.Rve_Student__r.SRN_Number__c,
                                                                         Rve_Exam_Application__r.Rve_Student__r.Program_Code__c, Rve_Exam_Application__r.Rve_Student__r.Program__c,
                                                                         Rve_Exam_Application__r.Rve_Student__r.Program_Batch_Name__c,
                                                                         Rve_Exam_Application__r.Rve_Student__r.Active_Semester__r.Term_Number__c 
                                                                         FROM Rve_Exam_Application_Line_Item__c WHERE  Rve_Exam_Application__c IN :set_examApplicationId])
            {
                StudentExamApplicationWrp examApplicationWrp = new StudentExamApplicationWrp();
                String result = '';
                if(!test.isRunningtest()){
                String inputString = timetableLineItem.Rve_Exam_Application__r.Rve_Student__r.Program_Batch_Name__c;
                
                // Find the position of the first '-'
                Integer dashIndex = inputString.indexOf('-');
                
                // Extract the substring starting after the first '-'
                if (dashIndex != -1) {
                    result = inputString.substring(dashIndex + 1).trim(); // Trim to remove any leading spaces
                }
                }
                examApplicationWrp.regno = timetableLineItem.Rve_Exam_Application__r.Rve_Student__r.SRN_Number__c;
                if(!test.isRunningtest()){
                examApplicationWrp.degcode = String.isNotBlank(timetableLineItem.Rve_Exam_Application__r.Rve_Student__r.Program_Code__c) ? timetableLineItem.Rve_Exam_Application__r.Rve_Student__r.Program_Code__c+'-'+result : Null;
                System.debug('examApplicationWrp.degcode=> '+examApplicationWrp.degcode);
                }
                examApplicationWrp.degname = String.isNotBlank(timetableLineItem.Rve_Exam_Application__r.Rve_Student__r.Program__c) ? timetableLineItem.Rve_Exam_Application__r.Rve_Student__r.Program__c : Null;
                examApplicationWrp.sem = String.isNotBlank(String.valueOf(timetableLineItem.Rve_Exam_Application__r.Rve_Student__r.Active_Semester__r.Term_Number__c)) ? String.valueOf(timetableLineItem.Rve_Exam_Application__r.Rve_Student__r.Active_Semester__r.Term_Number__c) : Null;
                examApplicationWrp.subcode = String.isNotBlank(String.valueOf(timetableLineItem.Course_Code__c)) ? String.valueOf(timetableLineItem.Course_Code__c) : Null;
                examApplicationWrp.subname = String.isNotBlank(timetableLineItem.Rve_Subject__c) ? timetableLineItem.Rve_Subject__c : Null;
                examApplicationWrp.rtype = 'I';
                examApplicationWrp.attend = 'yes';
                objRequestWrp.studentExamApp.add(examApplicationWrp);
                map_Student_examApplication.put(timetableLineItem.Rve_Exam_Application__c,timetableLineItem);
            }
            
            String jsonBody = json.serialize(objRequestWrp);
            System.debug('jsonBody=='+jsonBody);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);             
            HttpRequest hReq = LogisysAPIUtility.mapRequest('Rve_SendSemesterApplication',jsonBody);
            
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
                /*for(Resdata objResdata : objData.resdata)
                {
                    if(objResdata.msg == 'Updated Successfully' && string.isNotBlank(objResdata.StudentApplicationNo) && map_Student_examApplication.containsKey(objResdata.StudentApplicationNo))
                    {                    	
                    	map_Student_examApplication.get(objResdata.StudentApplicationNo).Rve_Exam_Application__r.Rve_Logisys_Field_Check__c = true;                         
                    }
                }*/
                utility.LogisysAPI = false;                 
                //if(map_Student_examApplication.size() > 0) update map_Student_examApplication.values();
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
       public List<StudentExamApplicationWrp> studentExamApp;
        public RequestWrp()
        {
            studentExamApp = new List<StudentExamApplicationWrp>();
        }
    }
    
    public class StudentExamApplicationWrp
    {
        
        public String regno;
        public String degcode;
        public String degname;
        public String sem;
        public String subcode;
        public String subname;
        public String rtype;
        public String attend;
       
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