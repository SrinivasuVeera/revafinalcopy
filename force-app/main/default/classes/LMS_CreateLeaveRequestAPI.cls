@RestResource(urlMapping='/CreateLeaveRequestAPI/*')
global class LMS_CreateLeaveRequestAPI 
{    
    @HttpPost
    global static list<FacultyScheduleWrp> CreateLeaveRequest()
    {
        FacultyScheduleWrp fwrap = new FacultyScheduleWrp();
        list<FacultyScheduleWrp> lst_fwrap = new list<FacultyScheduleWrp>();
        responseWrapper objResWrp = new responseWrapper();
        ResponseWrp objReqWrp = new ResponseWrp();
        string jsonbody;
        string EmpNo;
        
        list<Class_Adjustment__c> lst_ClsAdj  = new list<Class_Adjustment__c>();
        
        RestRequest  objResReq = RestContext.request;
        RestResponse objResResp =  RestContext.response;
        jsonbody = objResReq.requestBody.toString().trim();
        
        if(jsonbody != null)
        {
            string str_res =jsonbody ;
            string Etime;
            string Stime;
            
            str_res ='{'+'"FacultyScheduleWrp"'+':'+str_res+'}'; 
            objReqWrp= (ResponseWrp)system.JSON.deserialize(jsonbody,ResponseWrp.class);
            Leave_Request__c objLeave = new Leave_Request__c();
            for(FacultyScheduleWrp objfwrap : objReqWrp.schList)
            {
                if(objfwrap.CurEmpNo != null)
                {
                    EmpNo= objfwrap.CurEmpNo;
                }
            }
            Contact objCon  = new Contact();
            if(EmpNo != null)
            {               
                objCon = [Select id,Name,ReportsTo.OwnerId,OwnerId,Employee_Number__c from Contact where Employee_Number__c =: EmpNo];
            }  
            for(FacultyScheduleWrp objfwrap : objReqWrp.schList)
            {                 
                if(objfwrap.FromDate != null) objLeave.From_Date__c = objfwrap.FromDate;
                if(objfwrap.ToDate != null) objLeave.To_Date__c = objfwrap.ToDate;
                if(objfwrap.LeaveAppId != null) objLeave.HCM_Leave_Record_ID__c = objfwrap.LeaveAppId;
                objLeave.Leave_Request_Status__c='Submitted';
                if(objCon.ReportsTo.OwnerId != null) 
                    objLeave.Manager__c = objCon.ReportsTo.OwnerId;
                if(objfwrap.LeaveRes != null) objLeave.Leave_Reason__c = objfwrap.LeaveRes;
                if(objfwrap.TypeofLeave != null) objLeave.Leave_Type__c = objfwrap.TypeofLeave;
                if(objCon.OwnerId != null) objLeave.Ownerid = objCon.OwnerId; 
                
                Class_Adjustment__c objClsAdj = new Class_Adjustment__c();
                objClsAdj.Course_Offering_Schedule__c = objfwrap.schId;
                if(objfwrap.startendtime != null)
                {
                    Etime = String.valueOf(objfwrap.startendtime).substringAfterLast('-');
                    Stime = String.valueOf(objfwrap.startendtime).substringBeforeLast('-');
                }
                if(objfwrap.startendtime != null)  objClsAdj.End_time__c = Time.newInstance(integer.valueof(Etime.split(':')[0].trim()),integer.valueof(Etime.split(':')[1].trim()),0,0);
                if(objfwrap.startendtime != null)  objClsAdj.Start_time__c = Time.newInstance(integer.valueof(Stime.split(':')[0].trim()),integer.valueof(Stime.split(':')[1].trim()),0,0);
                if(objfwrap.FromDate != null) objClsAdj.From_Date__c = objfwrap.FromDate;
                if(objfwrap.ToDate != null)  objClsAdj.To_Date__c = objfwrap.ToDate;
                objClsAdj.Status__c='Submitted';
                if(objfwrap.TypeofLeave != null) objClsAdj.Leave_Type__c = objfwrap.TypeofLeave;
                if(objfwrap.selProfName != null)
                {
                    objClsAdj.Requested_Professor__c = objfwrap.selProfName.split('=>')[0];
                    objClsAdj.Requested_Course_Offering_Schedule__c = objfwrap.selProfName.split('=>')[1];
                }
                if(objCon.OwnerId != null) objClsAdj.Ownerid = objCon.OwnerId;
                lst_ClsAdj.add(objClsAdj);
            }
            if(objLeave!= null) insert objLeave;
            if(objLeave.id != null)
            {
                for(Class_Adjustment__c objAdj : lst_ClsAdj)
                {
                    objAdj.Leave_Request__c = objLeave.id;
                }
            }
            if(lst_ClsAdj.size()>0)  insert lst_ClsAdj;            
        }
        return  lst_fwrap;
    } 
    
    
    @HttpGet
    global static string GetLeaveRequest()
    {
        FacultyScheduleWrp fwrap = new FacultyScheduleWrp();
        list<FacultyScheduleWrp> lst_fwrap = new list<FacultyScheduleWrp>();
        responseWrapper objResWrp = new responseWrapper();
        GetRequest objReqWrp = new GetRequest();
        string jsonbody;
        
        list<Class_Adjustment__c> lst_ClsAdj  = new list<Class_Adjustment__c>();
        
        RestRequest  objResReq = RestContext.request;
        RestResponse objResResp =  RestContext.response;
        jsonbody = objResReq.requestBody.toString().trim();
        
        List<Class_Adjustment__c> lst_Adjustment = new List<Class_Adjustment__c>();
        if(jsonbody != null)
        {
            objReqWrp = (GetRequest)system.JSON.deserialize(jsonbody, GetRequest.class);
            lst_Adjustment = [select id,name,Status__c from Class_Adjustment__c where Leave_Request__r.HCM_Leave_Record_ID__c =: objReqWrp.LeaveRecordId];
        }        
        return JSON.serialize(lst_Adjustment);
    }
    
    global class ResponseWrp{
        public List<FacultyScheduleWrp> schList;
        public String status;
        public String message;
    } 
    global class responseWrapper
    {
        public String status;
        public String message;
        public List<resultWpr> list_result;
    }    
    global class resultWpr
    {
        public String status;
        public String empNumber;
        public String error;
    }
    global class FacultyScheduleWrp {        
        public Id  schId;
        public Date schDate; 
        public Decimal slotNum; 
        public String startendtime;
        public String courseName;
        public String sectionDet;
        public Id sectionId;
        public String LeaveAppId;
        public string  LeaveRes;
        public string  TypeofLeave;
        public Date  FromDate;
        public Date ToDate;
        public String courseId;
        public string CurEmpNo;
        public String selProfName;
        public List<ProfDetWrp> profDetails; 
    }  
    global class ProfDetWrp{ 
        public string profId;
        public string  ProfName;
        public string colorCode;
        public string ReqSchId; 
    }    
    global class GetRequest
    {
        public string leaveRecordId;
    }
}