@RestResource(urlMapping='/GetClassAdjustment/*')
global class LMS_GetClassAdjestment 
{    
    @HttpPost
    global static list<ReqWrapper> GetLeaveRequest()
    {
        responseWrapper objResWrp = new responseWrapper();
        GetRequest objReqWrp = new GetRequest();
        string jsonbody;        
        list<Adjustmentwrapper> lst_ClsAdj  = new list<Adjustmentwrapper>();        
        RestRequest  objResReq = RestContext.request;
        RestResponse objResResp =  RestContext.response;
        jsonbody = objResReq.requestBody.toString().trim();        
        ReqWrapper reqwrap = new ReqWrapper();
        list<ReqWrapper> lst_reqwrap = new list<ReqWrapper>();
        if(jsonbody != null)
        {
            objReqWrp = (GetRequest)system.JSON.deserialize(jsonbody, GetRequest.class);
            for(Class_Adjustment__c objCls :[select id,Name,Status__c,Leave_Request__r.HCM_Leave_Record_ID__c,Leave_Request__c,
                                             Leave_Request__r.Name,Requested_Professor__c,Requested_Professor__r.Name,
                                             Leave_Request__r.Leave_Request_Status__c  from Class_Adjustment__c where
                                             Leave_Request__r.HCM_Leave_Record_ID__c =: objReqWrp.LeaveRecordId])
            {
                Adjustmentwrapper objwrap = new Adjustmentwrapper();
                objwrap.id = objCls.id;
                objwrap.Name = objCls.Name;
                objwrap.Status = objCls.Status__c;
                objwrap.LeaveReqName = objCls.Leave_Request__r.Name;
                objwrap.Hcmid = objCls.Leave_Request__r.HCM_Leave_Record_ID__c;
                objwrap.ReqProf = objCls.Requested_Professor__r.Name;  
                lst_ClsAdj.add(objwrap);
            }
            reqwrap.Details = lst_ClsAdj;
            lst_reqwrap.add(reqwrap);
        }        
        return lst_reqwrap;
    }
    global class GetRequest
    {
        public string leaveRecordId;
    }
    global class responseWrapper
    {
        public String status;
        public String message;        
    }
    global class ReqWrapper
    {
        @AuraEnabled public list<Adjustmentwrapper> Details{get;set;}
    }
    global class Adjustmentwrapper
    {
        public string id;
        public string Name;
        public string Status;
        public string LeaveReqName;
        public string Hcmid;
        public string ReqProf;
    }
}