public class LMS_ClassAdjustmentTriggerHandler 
{
    public static void updateClassAdjustment(List<Class_Adjustment__c> lst_ClsAdj,Map<Id,Class_Adjustment__c> map_OldClsAdj)
    {
      /*  set<string> set_LeaveId = new set<string>();
        string StrLeaveIds;
        integer count;
        string StrStatus ='Approved';
        for(Class_Adjustment__c objCls : lst_ClsAdj)
        {
            if(objCls.Leave_Request__c != null && map_OldClsAdj.get(objCls.Id).Status__c != objCls.Status__c)
                set_LeaveId.add(objCls.Leave_Request__c);
        }
        if(set_LeaveId.size() >0)
        {
            for(Leave_Request__c objLeave : [select id,name,HCM_Leave_Record_ID__c,(select id,name,Status__c from Class_Adjustments__r) 
                                             from Leave_Request__c where id in:set_LeaveId])
            {
                StrLeaveIds = objLeave.HCM_Leave_Record_ID__c;
                for(Class_Adjustment__c objCls : objLeave.Class_Adjustments__r)
                {
                    count = objLeave.Class_Adjustments__r.size();
                    if(objCls.Status__c != 'Approved')
                        StrStatus = objCls.Status__c;
                }
            }
            if(StrStatus == 'Approved')
            {
                LMS_ClassAdjustmentTriggerHandler.LeaveUpdateStatus(StrLeaveIds,StrStatus);
            }
            else if(StrStatus == 'Rejected')
            {
                LMS_ClassAdjustmentTriggerHandler.LeaveUpdateStatus(StrLeaveIds,StrStatus);
            }
        }
    }
    @future(callout=true)
    public static void LeaveUpdateStatus(string StrLeaveIds,String strStatus)
    { 
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('LeaveId', StrLeaveIds);
        gen.writeStringField('LeaveStatus', strStatus);
        gen.writeEndObject();
        String finalBody = gen.getAsString();
        
        accessTokenRespWrp objDeResp = new accessTokenRespWrp();
        objDeResp = ReturnAccessToken();
       
        String endPoint = objDeResp.instance_url+'/services/apexrest/ApprovalRecords';        
        Http http = new Http();
        HttpRequest hReq = new HttpRequest();
        hReq.setHeader('Authorization','Bearer ' + objDeResp.access_token);
        hReq.setTimeout(120000);
        hReq.setEndpoint(endPoint);
        hReq.setBody(finalBody); 
        hReq.setHeader('Content-Type', 'application/json');
        hReq.setMethod('POST');
        HttpResponse hRes = http.send(hReq);
        hRes = http.send(hReq);
        string str_res = hRes.getBody();
         
         if(!String.IsBlank(hRes.getBody()))
            {
                responseWpr response = new responseWpr();
                response = (responseWpr)Json.deserialize(hRes.getBody(),responseWpr.class);
            }
    }
    public static accessTokenRespWrp ReturnAccessToken()
    {
        Access_Token_Generation_Details__mdt objAccessToken= getAuthorizationDetails();
        
        Http h = new Http();
        HttpRequest objReq = new HttpRequest();
        objReq.setBody('grant_type=password' +
               '&client_id=' + objAccessToken.Client_Id__c +
               '&client_secret=' + objAccessToken.Client_Secret__c +
               '&username=' + EncodingUtil.urlEncode(objAccessToken.Username__c, 'UTF-8') +
               '&password=' + EncodingUtil.urlEncode(objAccessToken.Password__c, 'UTF-8'));
        objReq.setMethod('POST');
        objReq.setEndpoint(objAccessToken.URL__c+'/services/oauth2/token');
        HttpResponse objRes = h.send(objReq);
        accessTokenRespWrp objDeResp = (accessTokenRespWrp)JSON.deserialize(objRes.getBody(),accessTokenRespWrp.class);
        return objDeResp;
    }
    public static Access_Token_Generation_Details__mdt getAuthorizationDetails()
    {
        return Access_Token_Generation_Details__mdt.getInstance('HCM_Details');
    } 
    public class accessTokenRespWrp 
    {
        public String id;
        public String access_token;
        public String instance_url;
    }   
    public class responseWpr
    {
        public string empleaveid;*/
    }
}