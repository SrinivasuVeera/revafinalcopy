@RestResource(UrlMapping='/studentresults/*')
global class ASM_ResultAPI {
    @Httppost
    global static void doPost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        mainResWpr response = new mainResWpr();
        
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_ResultAPI';
        dLog.Status__c = 'Success';
        dLog.Processing_API_Name__c = 'Student Final Results from Logisys';
        dLog.Object_Name__c = 'Result_Details__c';
        
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        
        String jsonBody = req.requestBody.toString().trim();
        dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
        Insert dLog;
        List<reqWpr> list_reqWpr = new List<reqWpr>();
        try{
            list_reqWpr = (List<reqWpr>) Json.deserialize(jsonBody, List<reqWpr>.class);
            response.status = 'failed';
            response.message = 'No data';
            if(list_reqWpr != null && !list_reqWpr.isEmpty()){
                List<hed__Term_Grade__c> list_Results = new List<hed__Term_Grade__c>();
                Map<String,hed__Term_Grade__c> map_SummaryData = new Map<String,hed__Term_Grade__c>();
                for(reqWpr rwp : list_reqWpr){
                    String summaryExtId = rwp.regno+'_'+rwp.sem;
                    if(map_SummaryData.get(summaryExtId) == null){
                        hed__Term_Grade__c rdSummary = new hed__Term_Grade__c();
                        rdSummary.External_ID__c = summaryExtId;
                        rdSummary.hed__Contact__r = new Contact(SRN_Number__c=rwp.regno);
                      //  rdSummary.School__c = rdSummary.hed__Contact__r.School__c;
                      //  rdSummary.Program__c = rdSummary.hed__Contact__r.Primary_Academic_Program__c;
                        rdSummary.Recent_Result_Updated_Date__c = System.today();
                        rdSummary.Remarks__c = rwp.remarks;
                        rdSummary.CGPA__c = rwp.cgpa;
                        rdSummary.SGPA__c = rwp.sgpa;
                        rdSummary.Passing_Criteria__c = rwp.passcriteria;
                        rdSummary.Examination_Month_Year__c = rwp.ExaminationMonthYear;
                        rdSummary.SRN_Number__c = rwp.regno;                         
                        map_SummaryData.put(rdSummary.External_ID__c,rdSummary);
                    }
                    
                    hed__Term_Grade__c rd = new hed__Term_Grade__c();
                    rd.Result_Summary__r = new hed__Term_Grade__c(External_ID__c = summaryExtId); 
					                  
                    rd.hed__Contact__r = new Contact(SRN_Number__c=rwp.regno);
                    //rd.School__c = rd.hed__Contact__r.School__c;
                   // rd.Program__c = rd.hed__Contact__r.Primary_Academic_Program__c;
                    String extId = rwp.regno+rwp.courseExternalId;
                    rd.hed__Course_Connection__r = new hed__Course_Enrollment__c(Logisys_External_Id__c = extId);
                    rd.Examination_Month_Year__c = rwp.ExaminationMonthYear;
                    rd.Secured_Internal_Marks__c = rwp.securedIAMarks;
                    rd.Secured_External_Marks__c = rwp.securedExternalMarks;
                    rd.No_of_Credits__c = rwp.credits;
                    rd.Grade_Points__c = rwp.gradepoint;
                    rd.Credit_Points__c = rwp.creditpoint;
                    rd.SRN_Number__c = rwp.regno;
                    rd.Course_Code__c = rwp.subcode;
                    rd.Course__r = new hed__Course__c(Course_External_ID__c=rwp.courseExternalId);
                    rd.Semester__c = rwp.SemName;
                    //rd.CGPA__c = rwp.cgpa;
                    //rd.SGPA__c = rwp.sgpa;
                    rd.Grade__c = rwp.grade; 
                    rd.hed__Result__c = rwp.Result;
                    //rd.Remarks__c = rwp.remarks;
                    rd.External_Id__c = extId;
                    rd.Recent_Result_Updated_Date__c = System.today();
                    list_Results.add(rd);
                }
                if(!map_SummaryData.isEmpty()) {
                    List<Database.upsertResult> ResultSummaryList = Database.Upsert(map_SummaryData.values(),hed__Term_Grade__c.External_Id__c,false); 
               
                }
                
                List<Database.upsertResult> termResultList =  new List<Database.upsertResult>();
                if(list_Results.size() > 0)  
                {
                    termResultList = Database.Upsert(list_Results,hed__Term_Grade__c.External_Id__c,false); 
                    
                   List<resWpr> list_resWpr = new List<resWpr>();
                    Integer failCount = 0;
                    for (integer i=0; i < termResultList.size(); i++) {
                        resWpr rsWpr = new resWpr();
                        rsWpr.regno = list_reqWpr[i].regno;
                        rsWpr.subcode = list_reqWpr[i].subcode;
                        rsWpr.sem = list_reqWpr[i].sem;
                        if (termResultList[i].isSuccess()) {
                            rsWpr.status = 'T';
                            rsWpr.msg = 'Successful';
                        }
                        else if (!termResultList[i].isSuccess()){
                            rsWpr.status = 'F';
                            rsWpr.msg = termResultList[i].getErrors()[0].getMessage();
                            failCount++;
                        }
                        list_resWpr.add(rsWpr);
                    } 
                    response.status = (failCount == 0) ? 'Success' : (failCount == list_reqWpr.size()) ? 'Failure' : 'Partial';
                    response.message = response.status;
                    response.data = list_resWpr;
                    
                   
                    dLog.Status__c = response.status;
                    dLog.Response__c = Json.serialize(response).abbreviate(MAX_RES_LOG_SIZE);
                    Update dLog;
                }
            }
        }catch(exception e){
            System.debug('@@==>> Exception: '+e.getMessage()+'. At: '+e.getStackTraceString()+ 'Line Number - '+e.getLineNumber());
            response.status = 'Failure';
            response.message = dLog.Error_Message__c;
            
            dLog.Status__c = 'Failure';
            dLog.Error_Message__c = e.getMessage()+'. At: '+e.getStackTraceString()+ 'Line Number - '+e.getLineNumber();
            dLog.Response__c = Json.serialize(response).abbreviate(MAX_RES_LOG_SIZE);
            if(dLog.Id != null) Update dLog;
            else Insert dLog;
        }
        res.responseBody = Blob.valueof(Json.serialize(response));
    }
    
    public class reqWpr{
        public String regno;
        public String subcode;
        public String sem;
        public String ExaminationMonthYear;
        public Decimal securedIAMarks;
        public Decimal securedExternalMarks;
        public Decimal credits;
        public Decimal gradepoint;
        public Decimal creditpoint;
        public Decimal cgpa;
        public Decimal sgpa;
        public String grade;
        public String Result;
        public String remarks;
        public String passcriteria;
        public String courseExternalId;
        Public String SemName;
    }
    
    public class mainResWpr{
        public String status;
        public String message;
        public List<resWpr> data;
    }
    
    public class resWpr{
        public String regno;
        public String subcode;
        public String sem;
        public String status;
        public String msg;
    }
}