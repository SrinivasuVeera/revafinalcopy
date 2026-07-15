public class ASM_CourseMasterFomSfAPI {
    @InvocableMethod
    public static void sendCourseDetails_future(list<Id> semesterIds){
        Debug_Log__c dLog = sendCourseDetails(semesterIds);
        Insert dLog;
    }	
    
    public static Debug_Log__c sendCourseDetails(list<Id>semesterIds){
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_CourseMasterFomSfAPI';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Course Master Data to Logisys';
        dLog.Object_Name__c = 'hed__Course__c';
        String status_API ='';
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        try{
            
            System.debug('semesterIds=> '+semesterIds);
            
            List<hed__Plan_Requirement__c>syllabusList = [SELECT id ,name,hed__Course__r.rve_OldCourseCode__c,Semester__r.No_of_Courses_Per_Student__c,Semester__r.Program_Batch__r.hed__Account__r.Program_Code__c,
                                                        Semester__r.name,Semester__r.Term_Number__c, hed__Course__r.Name,Semester__r.Program_Batch__r.name,/*hed__Course__r.Maximum_Internal_Marks_Logisys__c*/
                                                        hed__Course__r.hed__Course_ID__c, hed__Course__r.Credits__c,hed__Course__r.Lcoursetype__c,hed__Course__r.Lsubtype__c,hed__Course__r.Lmandatory__c,
                                                        hed__Course__r.L_T_P__c, hed__Course__r.HardCore_Sub_Type__c,hed__Course__r.Course_External_ID__c,hed__Course__r.SEE_Conducted_Marks__c,hed__Course__r.Maximum_External_Marks__c, 
                                                        hed__Course__r.Theory_Maximum_Marks__c, hed__Course__r.Seminar_Maximum_Marks__c,hed__Course__r.Maximum_Internal_Marks_Logisys1__c,
                                                        hed__Course__r.Quiz_Maximum_Marks__c, hed__Course__r.Category__c,hed__Course__r.Total_Maximum_Marks_IA_External__c from hed__Plan_Requirement__c  
                                                        WHERE Semester__c IN:semesterIds and hed__Course__c != null AND hed__Course__r.Total_Maximum_Marks_IA_External__c > 0];
            
            System.debug('syllabusList=> '+syllabusList.size());

            Map<string,hed__Plan_Requirement__c> mapSyllabus = new Map<String,hed__Plan_Requirement__c>();
            list<reqWpr>Reqlist = new list<reqWpr>();
            if(Syllabuslist.size()>0)
            {
                for(hed__Plan_Requirement__c slist : syllabusList)
                {
                    String inputString = slist.Semester__r.Program_Batch__r.name;

                     // Find the position of the first '-'
                     Integer dashIndex = inputString.indexOf('-');

                    // Extract the substring starting after the first '-'
                    String result = '';
                    if (dashIndex != -1) {
                     result = inputString.substring(dashIndex + 1).trim(); // Trim to remove any leading spaces
                   }
                    mapSyllabus.put(slist.hed__Course__r.Name,slist);
                    reqWpr APIBody = new reqWpr();
                    APIBody.degcode = slist.Semester__r.Program_Batch__r.hed__Account__r.Program_Code__c+'-'+result;
                    System.debug('APIBody.degcode'+ APIBody.degcode);
                    APIBody.sem = String.valueOf(slist.Semester__r.Term_Number__c);
                    APIBody.subcode =slist.hed__Course__r.hed__Course_ID__c;
                    APIBody.subname =slist.hed__Course__r.Name;
                    //APIBody.subshort=slist.hed__Course__r.Name;
                    APIBody.credit=String.valueOf(slist.hed__Course__r.Credits__c);
                    APIBody.ltp= slist.hed__Course__r.L_T_P__c;
                    //APIBody.subtype=slist.hed__Course__r.HardCore_Sub_Type__c;
                 //   APIBody.iamaxmarks=String.valueOf(slist.hed__Course__r.Theory_Maximum_Marks__c + slist.hed__Course__r.Seminar_Maximum_Marks__c + slist.hed__Course__r.Quiz_Maximum_Marks__c);
                    APIBody.iamaxmarks=String.valueOf(slist.hed__Course__r.Maximum_Internal_Marks_Logisys1__c);
                    //APIBody.oldsubcode=slist.hed__Course__r.rve_OldCourseCode__c!=null?slist.hed__Course__r.rve_OldCourseCode__c:slist.hed__Course__r.hed__Course_ID__c;
                    //APIBody.category=slist.hed__Course__r.Category__c;
                    APIBody.exsubcode=slist.hed__Course__r.Course_External_ID__c;
                    APIBody.rtype = 'I';
                    APIBody.lcoursetype=slist.hed__Course__r.Lcoursetype__c;
                    APIBody.lman=slist.hed__Course__r.Lmandatory__c;
                    APIBody.lsubtype=slist.hed__Course__r.Lsubtype__c;
                    APIBody.totalmarks=slist.hed__Course__r.Total_Maximum_Marks_IA_External__c;
                    APIBody.noofcourses=slist.Semester__r.No_of_Courses_Per_Student__c;
                    APIBody.SEE_Conducted_Marks =slist.hed__Course__r.SEE_Conducted_Marks__c; 
                    APIBody.External_Marks =slist.hed__Course__r.Maximum_External_Marks__c;
                    Reqlist.add(APIBody);
                }
            }
            
            String JsonBody = JSON.serialize(Reqlist);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
            
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_CourseMasterFomSfAPI',jsonBody);
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            
            String response = hRsp+' ::: '+hRsp.getBody();
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
            
            if(hRsp.getStatusCode() == 200){
                String resBody = hRsp.getBody();
                try {
                    Map<String, Object> responseMap = (Map<String, Object>) Json.deserializeUntyped(resBody);
                    Integer errorCode = (Integer) responseMap.get('error_code');
                    String status = (String) responseMap.get('status');
                    String data = (String) responseMap.get('data');
                    if (errorCode != null && errorCode == -1) {
                        System.debug('Error: ' + data);
                        // handle the error, e.g. send a notification or log the error
                        for(string syllabus : mapSyllabus.keyset()){
                            mapSyllabus.get(syllabus).Logisys_Integration__c='No';
                            mapSyllabus.get(syllabus).Logisys_Integration_message__c=data;
                        }
                    } else {
                        rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
                        status_API = rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
                        system.debug('entered into else');
                        // rest of the code
                        for(resdata rwp : rsp.data.resdata){
                            if(mapSyllabus.get(rwp.logisysextid) != null){
                                mapSyllabus.get(rwp.logisysextid).Logisys_Integration__c = (rwp.status == 'T') ? 'Yes' : 'No';
                                mapSyllabus.get(rwp.logisysextid).Logisys_Integration_message__c = rwp.msg;
                            }
                       }
                    }
                     Update mapSyllabus.values();
                } catch (JsonException e) {
                    System.debug('Error deserializing response: ' + e.getMessage());
                    If(status_API!=''){
                      dLog.Status__c = status_API;
                    }
                   dLog.Error_Message__c = e.getMessage()+'. At: '+e.getStackTraceString();
                    // handle the error, e.g. send a notification or log the error
                }
            
            }
        }
        catch(Exception e)
        {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
        }
        return dLog;
    }
  /*  public static String buildOrderedJson(List<reqWpr> reqList) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartArray();

    for (reqWpr r : reqList) {
        gen.writeStartObject();

        gen.writeStringField('subname', r.subname);
        gen.writeStringField('subcode', r.subcode);
        gen.writeStringField('sem', r.sem);
        gen.writeStringField('rtype', r.rtype);
        gen.writeNumberField('noofcourses', r.noofcourses);

        gen.writeStringField('ltp', r.ltp);
        gen.writeStringField('credit', r.credit);
        gen.writeStringField('lsubtype', r.lsubtype);
        gen.writeStringField('lman', r.lman);
        gen.writeStringField('lcoursetype', r.lcoursetype);
        gen.writeStringField('iamaxmarks', r.iamaxmarks);
        gen.writeNumberField('SEEConductedMarks', r.SEEConductedMarks);
        gen.writeNumberField('ExternalMarks', r.ExternalMarks);
        gen.writeNumberField('totalmarks', r.totalmarks);
        gen.writeStringField('exsubcode', r.exsubcode);
        gen.writeStringField('degcode', r.degcode);
        gen.writeEndObject();
    }

    gen.writeEndArray();
    return gen.getAsString();
} */

    public class reqWpr{
        
        public String degcode;
        public String sem;
        public String subcode;
        public String exsubcode;
        public String subname;
        //public string subshort;
        public string credit;
        public string ltp;
        //public string subtype;
        public string iamaxmarks;
        //public string oldsubcode;
        //public string category;
        public String rtype;
        public String lcoursetype;
        public String lman;
        public String lsubtype;
        public Decimal totalmarks;
        public Decimal noofcourses;
        public Decimal SEE_Conducted_Marks;
        public Decimal External_Marks;
  
    }
    
    public class rspWpr{
        public String status;
        public dataWpr data;
        public Integer error_code;
    }
    
    public class resdata{
        public String status{get;set;}
        public String msg{get;set;}
        public String regno;
        public String degcode;
        public String subcode;
        public String iatype;
        Public String logisysextid{get;set;}
       
    }
    public class dataWpr{
        public list<resdata> resdata{get;set;}
    }
}