/**
* @description       : This batch is used to fetch Semester room allotments from logisys.
* @author            : Aditya Dhulipala
* @group             : Cloud Odyssey
* @last modified on  : 05-04-2024
* @last modified by  : 
* @Comments          : this class will call from Schedule, It will run everyday 
**/
public with sharing class Rve_FetchSemesterRoomAllotmentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return database.getQueryLocator([SELECT Id,Rve_Semester__r.Exam_Start_Date__c, Rve_Semester__r.Exam_End_Date__c, 
                                         Rve_Publish__c, rve_Active__c  FROM Rve_Exam_Notification__c 
                                         WHERE Rve_Publish__c =true AND Rve_Semester__r.Exam_Start_Date__c<=TODAY 
                                         AND Rve_Semester__r.Exam_End_Date__c>=TODAY]);
    }
    public void execute(Database.BatchableContext Bc, List<Rve_Exam_Notification__c> lstNotifications)
    {
        List<Rve_Semester_Room_Allotment__c> roomArrangmentsToInsert = new List<Rve_Semester_Room_Allotment__c>();
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'Rve_FetchSemesterRoomAllotmentBatch';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Student semester Room Allotments from Logisys to SLCM';
        dLog.Object_Name__c = 'Rve_Semester_Room_Allotment__c';
        dLog.No_of_Records__c = lstNotifications.size();
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        List<String> sessions =new List<string>{'M','N'};
        for(string session: sessions){
            Rve_Exam_Notification__c notification = lstNotifications[0];
            Datetime today = Datetime.now(); 
          //  String formattedDate = today.format('yyyy-MM-dd'); 
            ExamDatesWrapper wrapper = new ExamDatesWrapper();
          //  Date currentDate = Date.today();
         String formattedDate = notification.Rve_Semester__r.Exam_End_Date__c.year() + '-' +
                       (notification.Rve_Semester__r.Exam_End_Date__c.month() < 10 ? '0' : '') + 
                       notification.Rve_Semester__r.Exam_End_Date__c.month() + '-' + 
                       (notification.Rve_Semester__r.Exam_End_Date__c.day() < 10 ? '0' : '') + 
                       notification.Rve_Semester__r.Exam_End_Date__c.day();


                System.debug('Formatted Date: ' + formattedDate);

                wrapper.edate= formattedDate;//formattedDate;
                wrapper.esession=session;
                String jsonBody = json.serialize(wrapper);
                dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
                HttpRequest hReq = LogisysAPIUtility.mapRequest('Rve_GetSemesterRoomAllotment',jsonBody);
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
                    dLog.Status__c=Status;
                    If(Status=='success'){
                        rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
                        system.debug('rsp-->'+rsp.data);
                        system.debug('resData-->'+responseMap.get('data'));
                        set<string> courseCode = new Set<string>();
                        set<String> studentSRN = new set<String>();
                        Map<string,Id> srnStudentIdMap = new Map<string,Id>();
                        Map<string,Id> courseCodeCourseIdMap = new Map<string,Id>();
                        For(resdata reswrapper: rsp.data.resdata ){
                            courseCode.add(reswrapper.subshort);
                            studentSRN.add(reswrapper.regno);
                        }
                        
                        For(hed__Course__c course : [Select Id,hed__Course_ID__c from hed__Course__c where hed__Course_ID__c IN :courseCode]){
                            courseCodeCourseIdMap.put(course.hed__Course_ID__c,course.Id);
                        }
                        for(Contact student :[Select Id,SRN_Number__c from Contact  where SRN_Number__c IN :studentSRN]){
                            srnStudentIdMap.put(student.SRN_Number__c,student.Id);
                        }
                        For(resdata responsewrp: rsp.data.resdata ){
                            system.debug('Response-->'+responsewrp);
                            If(srnStudentIdMap.get(responsewrp.regno)!=NULL){
                                Rve_Semester_Room_Allotment__c seating = new Rve_Semester_Room_Allotment__c();
                                seating.Name =responsewrp.regno;
                                seating.Rve_QP_Code__c=responsewrp.qpcode;
                                seating.Student__c= srnStudentIdMap.get(responsewrp.regno);
                                seating.Rve_Course__c=courseCodeCourseIdMap.get(responsewrp.subshort);
                                seating.Rve_Message__c=responsewrp.msg;
                                roomArrangmentsToInsert.add(seating);
                            }
                        }
                    }
                } 
        }
        If(roomArrangmentsToInsert.size()>0){
            insert roomArrangmentsToInsert;
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
      public String msg{get;set;}
      public String subshort{get;set;}   
  }
  public class dataWpr{
    public list<resdata> resdata{get;set;}
 }
}