/*
This API class is used to update the Leave Request status when Leave record is approved/rejected in empower HCM.

*/

@RestResource(urlMapping='/UpdateStatusAPI/*')
global class LMS_LeaveStatusUpdateAPI {
    
    @HttpPost
    global static string UpdateLeaveStatus()
    {       
        WrapperStatus objReqWrp = new WrapperStatus();
        RestRequest  objResReq = RestContext.request;
        RestResponse objResResp =  RestContext.response;
        string jsonbody = objResReq.requestBody.toString().trim();
        if(jsonbody != null)
        {
            objReqWrp = (WrapperStatus)system.JSON.deserialize(jsonbody, WrapperStatus.class);
            List<Leave_Request__c> lst_LeaveReq = new List<Leave_Request__c>();
            set<string> set_LeaveId = new set<string>();
            for(LeaveStatus objLeaveStatus : objReqWrp.LeaveStatus)
            {
                if(string.isNotBlank(objLeaveStatus.LeaveRecordId)) set_LeaveId.add(objLeaveStatus.LeaveRecordId);
            }
            map<string,Leave_Request__c> map_LeaveRequest = new  map<string,Leave_Request__c>();
            for(Leave_Request__c objLeave :  [select Id,Leave_Request_Status__c,HCM_Leave_Record_ID__c,Cancelled_By_Professor__c from Leave_Request__c 
                                              where HCM_Leave_Record_ID__c IN: set_LeaveId])
            {
                map_LeaveRequest.put(objLeave.HCM_Leave_Record_ID__c,objLeave);
            }
            
            for(LeaveStatus objLeaveStatus : objReqWrp.LeaveStatus)
            {
                if(string.isNotBlank(objLeaveStatus.LeaveRecordId) && string.isNotBlank(objLeaveStatus.LeaveStatus))
                {
                    if(map_LeaveRequest.containsKey(objLeaveStatus.LeaveRecordId))
                    {                    
                        if(objLeaveStatus.LeaveStatus == 'Approved')
                        {
                           map_LeaveRequest.get(objLeaveStatus.LeaveRecordId).Leave_Request_Status__c = 'Approved by Manager';
                           map_LeaveRequest.get(objLeaveStatus.LeaveRecordId).Cancelled_By_Professor__c = false;
                        }
                        if(objLeaveStatus.LeaveStatus == 'Rejected') 
                        {
                             map_LeaveRequest.get(objLeaveStatus.LeaveRecordId).Leave_Request_Status__c = 'Rejected by Manager';
                             map_LeaveRequest.get(objLeaveStatus.LeaveRecordId).Cancelled_By_Professor__c = false;
                        }
                        if(objLeaveStatus.LeaveStatus == 'Cancelled')
                        {
                           map_LeaveRequest.get(objLeaveStatus.LeaveRecordId).Leave_Request_Status__c = 'Cancelled';
                           map_LeaveRequest.get(objLeaveStatus.LeaveRecordId).Cancelled_By_Professor__c = false;
                        }   
                        if(objLeaveStatus.LeaveStatus == 'Rejected by Professor') 
                        {
                          map_LeaveRequest.get(objLeaveStatus.LeaveRecordId).Leave_Request_Status__c = 'Cancelled';
                          map_LeaveRequest.get(objLeaveStatus.LeaveRecordId).Cancelled_By_Professor__c = true;
                       } 
                    }
                }
            }
            if(map_LeaveRequest.size() > 0) update map_LeaveRequest.values();
        }
        return 'Success';
    }
    
    global class WrapperStatus
    {
        public List<LeaveStatus> LeaveStatus;
    }
    global class LeaveStatus
    {
        public string LeaveRecordId;
        public string LeaveStatus;
    }
}