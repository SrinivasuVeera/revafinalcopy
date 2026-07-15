/*********************************************
* This class to generate Json for Student Data
* And it'll send the same to Logisys API
* It's called from:
* ********************************************/

public class ASM_StdProfileAPI {
    @InvocableMethod(label='Get Student Ids' description='Returns the Debug Logs' category='Contact')
    Public static List<String> sendStdProfile_Invokable(List<List<contact>> lst_StdIds){
        Map<Id,String> map_DataChanges = new Map<Id,String>();
        Set<Id> set_Stdids = new set<Id>();
        Boolean isInsert = true;
        for(List<contact> conId : lst_StdIds){
            for(contact con : conId){
            map_DataChanges.put(con.Id,'No-No-No');
            set_Stdids.add(con.Id);
            }
        }
         Debug_Log__c dLog = sendStdProfiles(set_StdIds,map_DataChanges,isInsert);
        Insert dLog;
        List<string> status = new List<String>{dLog.Status__c} ;
             return status;
    }
    @future(callout=true)
    public static void sendStdProfile_future(Set<Id> set_StdIds, Map<Id,String> map_DataChanges, Boolean isInsert){
        Debug_Log__c dLog = sendStdProfiles(set_StdIds,map_DataChanges,isInsert);
        Insert dLog;
        
    }
    
    public static Debug_Log__c sendStdProfiles(Set<Id> set_StdIds, Map<Id,String> map_DataChanges, Boolean isInsert){
        Debug_Log__c dLog = new Debug_Log__c();
        dLog.Class_Name__c = 'ASM_StdProfileAPI';
        dLog.Status__c = 'Failure';
        dLog.Processing_API_Name__c = 'Student Profile Data to Logisys';
        dLog.Object_Name__c = 'Contact';
        dLog.No_of_Records__c = set_StdIds.size();
        string status='';
        Integer MAX_REQ_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Request__c.length;
        Integer MAX_RES_LOG_SIZE = Schema.SObjectType.Debug_Log__c.fields.Response__c.length;
        
        try{
            Map<String,Contact> map_Students = new Map<String,Contact>();
            List<reqWpr> list_reqWpr = new List<reqWpr>();
            
            for(Contact con : [SELECT Id,SRN_Number__c,hed__Gender__c,Caste_Logisys__c,MobilePhone,Email,Personal_Email__c,hed__Religion__c,Caste_Category__c,Aadhar_Card_Number__c,
                               Program_Batch_Name__c,Program_Code__c,Primary_Academic_Program__c,Primary_Academic_Program__r.Name,
                               School_Name__c,Active_Semester__c,Active_Semester__r.Name,Birthdate,
                               Active_Semester__r.Term_Number__c,File_Passport_Size_Photo__c,Logisys_Integration_message__c,
                               Admission_Session__c,Enrollment_Type__c,Name,Father_Guardian_Name__c,Mother_Name__c 
                               FROM Contact WHERE Id IN: set_StdIds])
            {
                map_Students.put(con.SRN_Number__c,con);
                String valueChanges = map_DataChanges.get(con.Id);
                
                String result = '';
                if(!test.isRunningtest()){
                String inputString = con.Program_Batch_Name__c;
                
                // Find the position of the first '-'
                Integer dashIndex = inputString.indexOf('-');
                
                // Extract the substring starting after the first '-'
                if (dashIndex != -1) {
                    result = inputString.substring(dashIndex + 1).trim(); // Trim to remove any leading spaces
                }
                }
                reqWpr rWp = new reqWpr();
                rWp.regno = String.isNotBlank(con.SRN_Number__c) ? con.SRN_Number__c : '';
                rWp.name = String.isNotBlank(con.Name) ? con.Name : '';
                rWp.fatname = String.isNotBlank(con.Father_Guardian_Name__c) ? con.Father_Guardian_Name__c : '';
                rWp.motname = String.isNotBlank(con.Mother_Name__c) ? con.Mother_Name__c : '';
                rWp.gender = String.isNotBlank(con.hed__Gender__c) ? con.hed__Gender__c : '';
                rWp.caste = String.isNotBlank(con.Caste_Logisys__c) ? con.Caste_Logisys__c : '';
                rWp.mob = String.isNotBlank(con.MobilePhone) ? con.MobilePhone : '';
                rWp.email = String.isNotBlank(con.Email) ? con.Email : '';
                rWp.personemail = String.isNotBlank(con.Personal_Email__c) ? con.Personal_Email__c : '';
                rWp.religion = String.isNotBlank(con.hed__Religion__c) ? con.hed__Religion__c : '';
                rWp.castecat = String.isNotBlank(con.Caste_Category__c) ? con.Caste_Category__c : '';
                rWp.aadhar = String.isNotBlank(con.Aadhar_Card_Number__c) ? con.Aadhar_Card_Number__c : '';
                if(!test.isRunningtest()){
                rWp.degcode = String.isNotBlank(con.Program_Code__c) ? con.Program_Code__c+'-'+result : '';
                System.debug('rwp.degcode=> '+rWp.degcode);
                }
                rWp.degname = String.isNotBlank(con.Primary_Academic_Program__c) ? con.Primary_Academic_Program__r.Name : '';
                rWp.collname = String.isNotBlank(con.School_Name__c) ? con.School_Name__c : '';
                rWp.collcode = String.isNotBlank(con.School_Name__c) ? con.School_Name__c : '';
                rWp.sem = String.isNotBlank(con.Active_Semester__c) ? String.valueof(con.Active_Semester__r.Term_Number__c) : '';
                rWp.namechange = valueChanges.split('-')[0];
                rWp.degchanmge = valueChanges.split('-')[1];
                rWp.collchange = valueChanges.split('-')[2];
                rWp.rtype = isInsert ? 'I' : 'U';
                rWp.ayear = String.isNotBlank(con.Admission_Session__c) ? con.Admission_Session__c : '';
                rWp.admtype = String.isNotBlank(con.Enrollment_Type__c) ? con.Enrollment_Type__c : '';
                String dob = con.Birthdate != null ? String.valueof(con.Birthdate.day()).leftpad(2,'0')+'/'+String.valueof(con.Birthdate.month()).leftpad(2,'0')+'/'+String.valueOf(con.Birthdate.year()) : '';
                rWp.dob = dob;
                rWp.StudentImage = con.File_Passport_Size_Photo__c;
                list_reqWpr.add(rwp);                        
            }
            String jsonBody = json.serialize(list_reqWpr);
            dLog.Request__c = jsonBody.abbreviate(MAX_REQ_LOG_SIZE);
            
            //Map Http Request
            HttpRequest hReq = LogisysAPIUtility.mapRequest('ASM_StdProfileAPI',jsonBody);
            
            //Send Request
            Http http = new Http();
            HttpResponse hRsp = http.send(hReq);
            
            String response = hRsp+' ::: '+hRsp.getBody();
            dLog.Response__c = response.abbreviate(MAX_RES_LOG_SIZE);
            if(hRsp.getStatusCode() == 200){
                String resBody = hRsp.getBody();
                rspWpr rsp = (rspWpr) Json.deserialize(resBody, rspWpr.class);
               status= rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
                if(isInsert){
                    for(resdata rwp : rsp.data.resdata){
                        if(map_Students.get(rwp.regno) != null){
                            map_Students.get(rwp.regno).Logisys_Integration__c = (rwp.status == 'T') ? 'Yes' : 'No';
                            map_Students.get(rwp.regno).Logisys_Integration_message__c = rwp.msg;
                        }
                    }
                    Utility.ContactOwnerUpdate = false;
                    Update map_Students.values();
                }
                dLog.Status__c = rsp.status == 'success' ? 'Success' : rsp.status == 'partial' ? 'Partial' : 'Failure';
            }
        }catch(exception e){
            System.debug('@@==>> Exception: '+e.getMessage()+'. At: '+e.getStackTraceString());
            If(status!=''){
                dLog.Status__c=status;
            }
            dLog.Error_Message__c = e.getMessage()+'. At: '+e.getStackTraceString();
        }
        return dLog;
    }
    
    public class reqWpr{
        public String degname;
        public String collcode;
        public String degcode;
        public String collname;
        public String email;
        public String sem;
        public String mob;
        public String namechange;
        public String caste;
        public String degchanmge;
        public String gender;
        public String collchange;
        public String motname;
        public String rtype;
        public String fatname;
        public String ayear;
        public String name;
        public String admtype;
        public String regno;
        public String dob;
        public String StudentImage;
        public string personemail;
        public string religion;
        public string castecat;
        public string aadhar;
    }
    
    public class rspWpr{
        public String status;
        public dataWpr data;
        public Integer error_code;
    }
    
    public class resdata{
        public String status{get;set;}
        public String msg{get;set;}
        public String regno{get;set;}
    }
    public class dataWpr{
        public list<resdata> resdata{get;set;}
    }
}