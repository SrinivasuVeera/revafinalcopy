/**
* @description       : This class is used to fetch Each student Exam time table and store in exam timetable line item object.
* @author            : Aditya Dhulipala
* @group             : Cloud Odyssey
* @last modified on  : 10-03-2024
* @last modified by  : 
* @Comments          : Calling this batch into schedule class, it will run every day to fetch Hallticket details and the batch size will be 1
**/
public class ASM_SemesterTimeTableBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('Select Id,Rve_Student__c, Rve_Student__r.SRN_Number__c,Rve_Exam_Notification__r.Logisys_TimeTable_fetch_Date__c from Rve_Exam_Application__c where Rve_Exam_Notification__r.Logisys_TimeTable_fetch_Date__c=TODAY AND Rve_Exam_Notification__r.Rve_Publish__c=TRUE AND Rve_Exam_Notification__r.RecordType.Name=\'Semester Notification\'' );
    }
    public void execute(Database.BatchableContext context, List<Rve_Exam_Application__c> scope) {
        System.debug('scope=> '+scope);
        List<Debug_Log__c> debuglogs= new List<Debug_Log__c>();
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        List<Rve_Exam_Application_Line_Item__c> lineItemToUpdate = new List<Rve_Exam_Application_Line_Item__c>();
        Map<string,Rve_Exam_Application_Line_Item__c> courseCodeApplicationLineItemMap = new Map<string,Rve_Exam_Application_Line_Item__c>();
        List<Rve_Exam_Application_Line_Item__c> examLineItems= [Select Id,Course_Code__c,Name,Rve_QP_Code__c, Rve_Semester__c,Rve_Exam_Application__r.Rve_Student__r.SRN_Number__c, Rve_Subject__c from Rve_Exam_Application_Line_Item__c where Rve_Exam_Application__c =:scope[0].Id];
          for(Rve_Exam_Application_Line_Item__c lineItem:examLineItems){
              system.debug('lineItem-->'+lineItem);
            courseCodeApplicationLineItemMap.put(lineItem.Course_Code__c,lineItem);
          }
        system.debug('Map-->'+courseCodeApplicationLineItemMap);
        If(courseCodeApplicationLineItemMap.keyset()!=NULL){
            Debug_Log__c dLog = new Debug_Log__c();
                dLog.Class_Name__c = 'ASM_SemesterTimeTableBatch';
                dLog.Status__c = 'Failure';
                dLog.Processing_API_Name__c = 'Getting Theory Hallticket from Logisys';
                dLog.Object_Name__c = 'Contact';
                dLog.No_of_Records__c = 1;
             reqWpr rWp = new reqWpr();
               rWp.regno=scope[0].Rve_Student__r.SRN_Number__c;
            String jsonBody =json.serialize(rWp);
            system.debug('jsonBody-->'+jsonBody);
               //dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_getTheoryTimeTable',jsonBody);
            HttpRequest hReq1 = LogisysAPIUtility.mapRequest('ASM_getPracticleTimeTable',jsonBody);
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            String response = hRsp+' ::: '+hRsp.getBody();
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
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
                    For(resdata reswrapper: rsp.data.resdata ){
                        system.debug('reswrapper-->'+courseCodeApplicationLineItemMap.get(reswrapper.subshort));
                        system.debug('course Id--->'+reswrapper.regno);
                        If(courseCodeApplicationLineItemMap.get(reswrapper.subshort)!=NULL){
                            Rve_Exam_Application_Line_Item__c lineItem= courseCodeApplicationLineItemMap.get(reswrapper.subshort);
                                lineItem.Rve_QP_Code__c=reswrapper.qpcode;
                                lineItem.Rve_Semester__c=reswrapper.sem;
                                string dateOfExam= reswrapper.doe;
                                Pattern datePattern = Pattern.compile('\\d{2}/\\d{2}/\\d{4}');
                                Matcher matcher = datePattern.matcher(dateOfExam);
                                system.debug('dates-->'+matcher);
                                if (matcher.find()) {
                                    String dateStr = matcher.group();
                                    List<String> dateParts = dateStr.split('/');
                                    Date startDate = Date.newInstance(Integer.ValueOf(dateParts[2]), Integer.ValueOf(dateParts[1]), Integer.ValueOf(dateParts[0]));
                                    lineItem.Date_Of_Examination__c=date.ValueOf(startDate);
                                    System.debug('Date: ' + dateStr);
                                }
                                
                                //lineItem.Date_Of_Examination__c=Date.ValueOf(dates[0]);
                                string session=reswrapper.session;
                                List<String> sessionParts = session.split(' to ');
                                if (sessionParts.size() == 2) {
                                 lineItem.Rve_Start_Time__c = getTimeFromString(sessionParts[0].trim()); // Get the start time
                                  System.debug('lineItem.Rve_Start_Time__c=> '+lineItem.Rve_Start_Time__c);
                                  lineItem.Rve_End_Time__c =  getTimeFromString(sessionParts[1].trim());
                                    System.debug('lineItem.Rve_End_Time__c=> '+lineItem.Rve_End_Time__c);

                                }
                                if (!lineItemToUpdate.contains(lineItem)) {
                                           lineItemToUpdate.add(lineItem);
                                         }
                        }
                    }
                  }
                  debuglogs.add(dLog);
                }
                    HttpResponse hRsp1 = http.send(hReq1);
                    String practicleresponse = hRsp1+' ::: '+hRsp1.getBody();
                 Debug_Log__c dLog1 = new Debug_Log__c();
                    dLog1.Class_Name__c = 'ASM_SemesterTimeTableBatch';
                    dLog1.Status__c = 'Failure';
                    dLog1.Processing_API_Name__c = 'Getting Practicle Hallticket from Logisys';
                    dLog1.Object_Name__c = 'Contact';
                    dLog1.No_of_Records__c = 1;
                    dLog1.Response__c = practicleresponse.abbreviate(MAX_RES_LOG_SIZE);
                    if(hRsp1.getStatusCode() == 200){
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(hRsp1.getBody());
                        String practicleStatus = (String) responseMap.get('status');
                        String resBody = hRsp1.getBody();
                        system.debug('resBody-->'+resBody);
                        system.debug('status-->'+practicleStatus);
                        dLog1.Status__c=practicleStatus;
                        If(practicleStatus=='success'){
                            rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
                            system.debug('rsp-->'+rsp.data);
                            system.debug('resData-->'+responseMap.get('data'));
                            For(resdata reswrapper: rsp.data.resdata ){
                                system.debug('reswrapper-->'+courseCodeApplicationLineItemMap.get(reswrapper.subshort));
                                system.debug('course Id--->'+reswrapper.regno);
                                If(courseCodeApplicationLineItemMap.get(reswrapper.subshort)!=NULL){
                                    Rve_Exam_Application_Line_Item__c lineItem= courseCodeApplicationLineItemMap.get(reswrapper.subshort);
                                        //lineItem.Rve_QP_Code__c=reswrapper.qpcode;
                                        lineItem.Rve_Semester__c=reswrapper.sem;
                                        lineItem.Rve_Batch__c=Integer.ValueOf(reswrapper.batch);
                                        string dateOfExam= reswrapper.doe;
                                        Pattern datePattern = Pattern.compile('\\d{2}/\\d{2}/\\d{4}');
                                        Matcher matcher = datePattern.matcher(dateOfExam);
                                        system.debug('dates-->'+matcher);
                                        if (matcher.find()) {
                                            String dateStr = matcher.group();
                                            List<String> dateParts = dateStr.split('/');
                                            Date startDate = Date.newInstance(Integer.ValueOf(dateParts[2]), Integer.ValueOf(dateParts[1]), Integer.ValueOf(dateParts[0]));
                                            lineItem.Date_Of_Examination__c=date.ValueOf(startDate);
                                            System.debug('Date: ' + dateStr);
                                        }
                                        
                                        //lineItem.Date_Of_Examination__c=Date.ValueOf(dates[0]);
                                        string session=reswrapper.session;
                                        List<String> sessionParts = session.split(' to ');
                                        if (sessionParts.size() == 2) {
                                         lineItem.Rve_Start_Time__c = getTimeFromString(sessionParts[0].trim()); // Get the start time
                                            System.debug('lineItem.Rve_Start_Time__c=> '+lineItem.Rve_Start_Time__c);

                                          lineItem.Rve_End_Time__c =  getTimeFromString(sessionParts[1].trim());
                                            System.debug('lineItem.Rve_End_Time__c=> '+lineItem.Rve_End_Time__c);

                                        }
                                        if (!lineItemToUpdate.contains(lineItem)) {
                                           lineItemToUpdate.add(lineItem);
                                         }
                                }
                            }
                        }
                    }
                      debuglogs.add(dLog1);
                    system.debug('lineItemToUpdate-->'+lineItemToUpdate);
                    If(lineItemToUpdate.size()>0){
                        Insert debuglogs;
                        update lineItemToUpdate;
                    }
        }
    }
    public void finish(Database.BatchableContext context) {
        
    }
    public Time getTimeFromString(String timeString) {
          // Parse the time string into hours, minutes, and optional seconds
            List<String> timeParts = timeString.split(':');
            system.debug('timeParts-->'+timeParts);
            Integer hours = Integer.valueOf(timeParts[0]);
            List<String> minutePart = timeParts[1].split(' ');
            Integer minutes = Integer.valueOf(minutePart[0]);
            system.debug('minutes-->'+minutes);
            //system.debug('minutes107-->'+Integer.valueOf(timeParts[1]));
            
            // Check if it's AM or PM and adjust hours accordingly
            if (timeString.contains('PM') && hours != 12) {
                hours += 12;
            } else if (timeString.contains('AM') && hours == 12) {
                hours = 0;
            }
            
            // Create the Time object
            Time timeObj = Time.newInstance(hours, minutes, 0, 0);
            return timeObj;
    }
    public class reqWpr{
        public String regno;
    }
          public class rspWpr{
              public String status{get;set;}
              public dataWpr data;
              public Integer error_code{get;set;}
        }
        public class resdata{
            public String sem{get;set;}
            public String examdate{get;set;}
            public String regno{get;set;}
            public String subshort{get;set;}
            public String qpcode{get;set;}
            public String doe{get;set;}
            public String session{get;set;}
            public String batch{get;set;}
            
        }
        public class dataWpr{
          public list<resdata> resdata{get;set;}
       }

}