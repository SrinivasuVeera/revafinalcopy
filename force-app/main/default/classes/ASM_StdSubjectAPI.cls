public class ASM_StdSubjectAPI {
    @InvocableMethod
    public static void sendStdSubject_future(List<Id> semesterIds){
        List<Debug_Log__c> debugLogs = sendStdSubject(semesterIds);
        insert debugLogs;
    }
    
    public static List<Debug_Log__c> sendStdSubject(List<Id> semesterIds){
        List<Debug_Log__c> debugLogs = new List<Debug_Log__c>();
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_StdSubjectAPI';
        dLog.Status__c = 'Failure'; // Default status
        dLog.Processing_API_Name__c = 'Student Subject Data to Logisys';
        dLog.Object_Name__c = 'hed__Course_Enrollment__c';
        String status = '';
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        
        try{
            Map<String,hed__Course_Enrollment__c> map_CCons = new Map<String,hed__Course_Enrollment__c>();
            List<reqWpr> list_reqWpr = new List<reqWpr>();
            String semname = [SELECT Id, Name FROM hed__Term__c WHERE Id IN :semesterIds LIMIT 1].Name;
            System.debug('Semname: ' + semname);
            Set<Id> set_conIds = new Set<Id>();
            Id RecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            List<hed__Course_Enrollment__c> enrollments = [SELECT Id,hed__Contact__c,hed__Contact__r.SRN_Number__c,hed__Contact__r.Student_status__c,hed__Contact__r.Name,hed__Contact__r.Program_Batch_Name__c,Program_Code__c,Program__c,Course_Code__c,
                                                           Logisys_Integration_message__c,Section__c,Section__r.hed__Parent_Term__c,Section__r.hed__Parent_Term__r.Name,
                                                           hed__Contact__r.Program_Batch__r.Program_Batch_Name__c,hed__Contact__r.Active_Semester__r.Name, 
                                                           Section__r.hed__Parent_Term__r.Term_Number__c,School__c, Semester_Number__c,hed__Course_Offering__r.hed__Course__r.Category__c,
                                                           hed__Course_Offering__c,hed__Course_Offering__r.hed__Course__r.Name
                                                           FROM hed__Course_Enrollment__c WHERE Semester__c =: semname AND Active_Connection__c = TRUE AND RecordTypeId =:RecTypeId
                                                           AND hed__Contact__r.Student_status__c = 'Pursuing' AND Push_Course_Connection_to_Logysis__c = FALSE];
            System.debug('Query Results: ' + enrollments.size() + ' records');            
            for(hed__Course_Enrollment__c con : enrollments) {
                set_conIds.add(con.Id);
                String result = '';
                if(!Test.isRunningTest()){
                    String inputString = con.hed__Contact__r.Program_Batch_Name__c;
                    if (inputString != null) {
                        Integer dashIndex = inputString.indexOf('-');
                        if (dashIndex != -1) {
                            result = inputString.substring(dashIndex + 1).trim();
                        }
                    }
                }
                map_CCons.put(con.Id,con);
                reqWpr rWp = new reqWpr();
                rWp.regno = String.isNotBlank(con.hed__Contact__r.SRN_Number__c) ? con.hed__Contact__r.SRN_Number__c : '';
                rWp.studname = String.isNotBlank(con.hed__Contact__r.Name) ? con.hed__Contact__r.Name : '';
                if(!Test.isRunningTest()){
                    rWp.degcode = String.isNotBlank(con.Program_Code__c) ? con.Program_Code__c+'-'+result : '';               
                }
                rWp.degname = String.isNotBlank(con.Program__c) ? con.Program__c : '';
                rWp.sem = (con.Section__c != null && con.Semester_Number__c != null) ? String.valueOf(con.Semester_Number__c) : '';
                rWp.semname = String.isNotBlank(con.hed__Contact__r.Active_Semester__r.Name) ? con.hed__Contact__r.Active_Semester__r.Name : '';
                rWp.subcode = String.isNotBlank(con.Course_Code__c) ? con.Course_Code__c : '';
                rWp.subname = (con.hed__Course_Offering__c != null) ? con.hed__Course_Offering__r.hed__Course__r.Name : '';
                rWp.coucat = String.isNotBlank(con.hed__Course_Offering__r.hed__Course__r.Category__c) ? con.hed__Course_Offering__r.hed__Course__r.Category__c : '';
                rWp.rtype = 'I';
                rWp.collname = con.School__c;
                rWp.collcode = con.School__c;
                rWp.logisysextid = con.Id;
                list_reqWpr.add(rWp);   
            }
            
            String jsonBody = JSON.serialize(list_reqWpr);
            System.debug('jsonBody length: ' + jsonBody.length());
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_StdSubjectAPI', jsonBody);
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            String response = hRsp + ' ::: ' + hRsp.getBody();
            System.debug('response length: ' + response.length());
            System.debug('response: ' + response);
            
            // Log handling
            if (response.length() > MAX_RES_LOG_SIZE || jsonBody.length() > MAX_REQ_LOG_SIZE) {
                Integer resChunkSize = MAX_RES_LOG_SIZE - 100;
                Integer reqChunkSize = MAX_REQ_LOG_SIZE - 100;
                
                Integer resParts = (Integer)Math.ceil((Decimal)response.length() / resChunkSize);
                Integer reqParts = (Integer)Math.ceil((Decimal)jsonBody.length() / reqChunkSize);
                Integer totalParts = Math.max(resParts, reqParts);
                
                for (Integer i = 0; i < totalParts; i++) {
                    Debug_Log__c chunkLog = dLog.clone(false, true, false, false);
                    
                    // Request part
                    Integer reqStartIdx = i * reqChunkSize;
                    Integer reqEndIdx   = Math.min(reqStartIdx + reqChunkSize, jsonBody.length());
                    if (reqStartIdx < jsonBody.length()) {
                        chunkLog.Request__c = 'Request Part ' + (i + 1) + ' of ' + reqParts + ': ' + 
                            jsonBody.substring(reqStartIdx, reqEndIdx);
                    } else {
                        chunkLog.Request__c = 'No Request content in this part';
                    }
                    
                    // Response part
                    Integer resStartIdx = i * resChunkSize;
                    Integer resEndIdx   = Math.min(resStartIdx + resChunkSize, response.length());
                    if (resStartIdx < response.length()) {
                        chunkLog.Response__c = 'Response Part ' + (i + 1) + ' of ' + resParts + ': ' + 
                            response.substring(resStartIdx, resEndIdx);
                    } else {
                        chunkLog.Response__c = 'No Response content in this part';
                    }
                    
                    debugLogs.add(chunkLog);
                }
            } else {
                dLog.Request__c = jsonBody;
                dLog.Response__c = response;
                dLog.No_of_Records__c = set_conIds.size();
                debugLogs.add(dLog);
            }
            
            
            if(hRsp.getStatusCode() == 200){
                String resBody = hRsp.getBody();
                rspWpr rsp = (rspWpr) JSON.deserialize(resBody, rspWpr.class);
                System.debug('Deserialized Response: ' + rsp);
                status = rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
                for(resdata rwp : rsp.data.resdata){
                    if(map_CCons.get(rwp.logisysextid) != null){
                        map_CCons.get(rwp.logisysextid).Logisys_Integration__c = (rwp.status == 'T') ? 'Yes' : 'No';
                        map_CCons.get(rwp.logisysextid).Logisys_Integration_message__c = rwp.msg;
                        if(rwp.status == 'T') {
                            map_CCons.get(rwp.logisysextid).Push_Course_Connection_to_Logysis__c = TRUE;
                        }
                    }
                }
                update map_CCons.values();
            } else {
                status = 'Failure';
            }
            
            for (Debug_Log__c log : debugLogs) {
                log.Status__c = status != '' ? status : 'Failure';
            }
            
        } catch(Exception e){
            System.debug('@@==>> Exception: '+e.getMessage()+'. At: '+e.getStackTraceString());
            for (Debug_Log__c log : debugLogs) {
                log.Status__c = status != '' ? status : 'Failure';
                log.Error_Message__c = e.getMessage() + '. At: ' + e.getStackTraceString();
            }
            if (debugLogs.isEmpty()) {
                dLog.Status__c = status != '' ? status : 'Failure';
                dLog.Error_Message__c = e.getMessage() + '. At: ' + e.getStackTraceString();
                debugLogs.add(dLog);
            }
        }
        return debugLogs.isEmpty() ? new List<Debug_Log__c>{dLog} : debugLogs;
    }
    
    public class reqWpr {
        public String regno;
        public String degcode;
        public String degname;
        public String sem;
        public String subcode;
        public String subname;
        public String semname;
        public String coucat;
        public String studname;
        public String rtype;
        public String collcode;
        public String collname;
        public String logisysextid;
    }
    
    public class rspWpr {
        public String status;
        public dataWpr data;
        public Integer error_code;
    }
    
    public class resdata {
        public String status {get;set;}
        public String msg {get;set;}
        public String logisysextid {get;set;}
    }
    
    public class dataWpr {
        public List<resdata> resdata {get;set;}
    }
}