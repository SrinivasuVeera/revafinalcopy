/** every day 
* @description       : This batch is used to fetch Semester attendance from logisys.
* @author            : Aditya Dhulipala
* @group             : Cloud Odyssey
* @last modified on  : 05-04-2024
* @last modified by  : 
* @Comments          : this class will call from Schedule, It will run everyday2 times  at afternooon 2pm and 6 pm
**/
public class Rve_FetchSemesterAttendanceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    string session;
    // Constructor to initialize RecordIds
    public Rve_FetchSemesterAttendanceBatch(String session) {
        this.session = session;
    }
    
   
    
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return database.getQueryLocator([SELECT Id,Rve_Semester__r.Exam_Start_Date__c, Rve_Semester__r.Exam_End_Date__c, 
                                         Rve_Publish__c, rve_Active__c  FROM Rve_Exam_Notification__c 
                                         WHERE Rve_Publish__c =true AND Rve_Semester__r.Exam_Start_Date__c<=TODAY 
                                         AND Rve_Semester__r.Exam_End_Date__c>=TODAY]);
    }
    public void execute(Database.BatchableContext Bc, List<Rve_Exam_Notification__c> lstNotifications)
    {
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'Rve_FetchSemesterAttendanceBatch';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Student semester Attendance from Logisys to SLCM';
        dLog.Object_Name__c = '	hed__Attendance_Event__c';
        dLog.No_of_Records__c = lstNotifications.size();
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        
        Datetime today = Datetime.now(); 
        String formattedDate = today.format('yyyy-MM-dd'); 
        
        Rve_Exam_Notification__c notification = lstNotifications[0];
        ExamDatesWrapper wrapper = new ExamDatesWrapper();
        wrapper.edate= formattedDate;
        wrapper.esession = session;
        String jsonBody = json.serialize(wrapper);
        System.debug('JsonBody'+jsonBody);
        dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
        HttpRequest hReq = LogisysAPIUtility.mapRequest('Rve_GetSemesterAttendance',jsonBody);
        Http http = new Http();
        HttpResponse hRsp = http.send(hReq);
        
        String response = hRsp+' ::: '+hRsp.getBody();
        dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
        system.debug('response-->'+response);
        if(hRsp.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(hRsp.getBody());
            String status = (String) responseMap.get('status');
            String resBody = hRsp.getBody();
            system.debug('resBody-->'+resBody);
            system.debug('status-->'+status);
            // dLog.Status__c=Status;
            If(Status=='success'){
                rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
                system.debug('rsp-->'+rsp.data);
                system.debug('resData-->'+responseMap.get('data'));
                List<Object> responses = new List<Object>();
                set<string> courseCode = new Set<string>();
                set<String> studentSRN = new set<String>();
                Map<string,Id> srnStudentIdMap = new Map<string,Id>();
                Map<string,Id> courseCodeCourseIdMap = new Map<string,Id>();
                For(resdata reswrapper: rsp.data.resdata ){
                    responses.add(reswrapper);
                    courseCode.add(reswrapper.subshort);
                    studentSRN.add(reswrapper.regno);
                }
                For(hed__Course__c course : [Select Id,hed__Course_ID__c from hed__Course__c where hed__Course_ID__c IN :courseCode]){
                    courseCodeCourseIdMap.put(course.hed__Course_ID__c,course.Id);
                }
                For(Contact student :[Select Id,SRN_Number__c from Contact  where SRN_Number__c IN :studentSRN]){
                    srnStudentIdMap.put(student.SRN_Number__c,student.Id);
                }
                
            }
        }
        
    }
    public void finish(DataBase.BatchableContext bc)
    {
        
    }
    public class ExamDatesWrapper{
        public string edate;
        public string esession;
    }
    public class rspWpr{
        public String status{get;set;}
        public dataWpr data;
        public Integer error_code{get;set;}
    }
    
    public class resdata{
        public String regno{get;set;}
        public String qpcode{get;set;}
        public String status{get;set;}
        public String subshort{get;set;}   
    }
    
    public class dataWpr{
        public list<resdata> resdata{get;set;}
    }
}