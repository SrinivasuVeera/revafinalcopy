public class ASM_ProgramMasterFomSfAPI {
    
    @InvocableMethod
    public static void sendProgramDetails_future(list<Id> ProgramBatchIds){
        Debug_Log__c dLog = sendProgramDetails(ProgramBatchIds);
        Insert dLog;
         
    }
    
    public static Debug_Log__c sendProgramDetails(list<Id>ProgramBatchIds){
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_ProgramMasterFomSfAPI';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Program Master Data to Logisys';
        dLog.Object_Name__c = 'hed__Program_Plan__c';
        string status='';
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        try{
            
            System.debug('ProgramBatchIds=> '+ProgramBatchIds);
            
            List<hed__Program_Plan__c>AllProgramList = [SELECT Id, Name,No_of_Semesters__c, Program_Batch_Name__c, hed__Account__r.Name,hed__Account__r.Program_Code__c,
                                                        (SELECT Id,Name, Term_Number__c,hed__Start_Date__c FROM Terms__r where Active__c=true) FROM hed__Program_Plan__c WHERE Id IN:ProgramBatchIds];
            
            System.debug('AllProgramList=> '+AllProgramList.size());
            
            List<hed__Plan_Requirement__c>Syllabuslist = [SELECT id,name,Semester__r.name,Semester__r.Term_Number__c,Semester__r.Program_Batch__r.Program_Batch_Name__c,
                                                          Semester__r.Program_Batch__r.hed__Account__r.name,Semester__c from hed__Plan_Requirement__c  where Semester__r.Active__c
                                                          = true AND Semester__r.Program_Batch__c IN:ProgramBatchIds];
            
            // Map to store Program Batch ID and Active Semester Start Year
            Map<Id, String> programBatchStartYearMap = new Map<Id, String>();
            
            // Iterate through the Program Plans and extract the active start year
            for (hed__Program_Plan__c programPlan : allProgramList) {

              // Find the position of the first '-'
              Integer dashIndex = programPlan.name.indexOf('-');
              
              // Extract the substring starting after the first '-'
              String result = '';
              if (dashIndex != -1) {
                  result = programPlan.name.substring(dashIndex + 1).trim(); // Trim to remove any leading spaces
              }
              
                    // Add to the map with Program Plan ID as the key and active start year as the value
                    programBatchStartYearMap.put(programPlan.Id, result);
                }
            
            Map<Id,Integer>SemesterWithSyllabus = new Map<Id,Integer>();
            
            if(Syllabuslist.size()>0)
            {
                for(hed__Plan_Requirement__c Syllabus : Syllabuslist)
                {
                    if(!SemesterWithSyllabus.containskey(Syllabus.Semester__c))
                    {
                        SemesterWithSyllabus.put(Syllabus.Semester__c,1);
                    }
                    else{
                        SemesterWithSyllabus.put(Syllabus.Semester__c,SemesterWithSyllabus.get(Syllabus.Semester__c)+1);
                    }
                }
            }
            
            System.debug('SemesterWithSyllabus=> '+SemesterWithSyllabus);
            
            
            list<reqWpr>Reqlist = new list<reqWpr>();
            if(Syllabuslist.size()>0)
            {
                for(hed__Program_Plan__c ProgramBatch : AllProgramList)
                {
                    System.debug('ProgramBatch.Terms__r[0].Id=> '+ProgramBatch.Terms__r[0].Id);
                    reqWpr APIBody = new reqWpr();
                    APIBody.degcode = ProgramBatch.hed__Account__r.Program_Code__c+'-'+programBatchStartYearMap.get(ProgramBatch.Id);
                    System.debug('DegCOde=> '+APIBody.degcode);
                    APIBody.degname = ProgramBatch.hed__Account__r.Name;
                    //APIBody.sem = String.valueOf(ProgramBatch.Terms__r[0].Term_Number__c);
                    //APIBody.totsub = String.valueOf(SemesterWithSyllabus.get(ProgramBatch.Terms__r[0].Id));
                    APIBody.noofsem = String.valueOf(ProgramBatch.No_of_Semesters__c);
                    APIBody.semname = ProgramBatch.Terms__r[0].Name;
                    APIBody.rtype = 'I';
                    Reqlist.add(APIBody);
                }
            }
            
            String JsonBody = JSON.serialize(Reqlist);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
            
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_ProgramMasterFomSfAPI',jsonBody);
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            
            String response = hRsp+' ::: '+hRsp.getBody();
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
            
            if(hRsp.getStatusCode() == 200){
                String resBody = hRsp.getBody();
                rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
                status= rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
                
                System.debug('ResponseCode=> '+hRsp.getstatuscode());
                System.debug('ResponseBody=> '+hRsp.getBody());
                dLog.Status__c = rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
            }
            
        }
        catch(Exception e)
        {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            If(status!=''){
                dLog.Status__c=status;
            }
            dLog.Error_Message__c=e.getMessage()+'. At: '+e.getStackTraceString();
        }
        return dLog;
    }
    
    public class reqWpr{
        //public String sem;
        public String degname;
        public String degcode;
        public String rtype;
        //public String totsub;
        public string noofsem;
        public string semname;
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
    }
    public class dataWpr{
        public list<resdata> resdata{get;set;}
    }
}