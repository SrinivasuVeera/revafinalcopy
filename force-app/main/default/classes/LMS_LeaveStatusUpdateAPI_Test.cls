@isTest
public class LMS_LeaveStatusUpdateAPI_Test 
{    
    public static testmethod void LeaveStatusUpdateAPI()
    {
        LMS_LeaveStatusUpdateAPI.LeaveStatus fmWrpr = new LMS_LeaveStatusUpdateAPI.LeaveStatus();
        fmWrpr.LeaveRecordId ='test';
        fmWrpr.LeaveStatus='Approved'; 
        
        list<LMS_LeaveStatusUpdateAPI.LeaveStatus> lst_wrap = new list<LMS_LeaveStatusUpdateAPI.LeaveStatus>();
        lst_wrap.add(fmWrpr);
        LMS_LeaveStatusUpdateAPI.WrapperStatus wrapr = new LMS_LeaveStatusUpdateAPI.WrapperStatus();
        wrapr.LeaveStatus =  lst_wrap;
        
        Leave_Request__c objLR = new Leave_Request__c();
        objLR.From_Date__c = system.today();
        objLR.To_Date__c = system.today()+2;
        objLR.Leave_Request_Status__c = 'Approved by Manager';
        objLR.HCM_Leave_Record_ID__c = 'test';            
        insert objLr;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String jsonBody = Json.serialize(wrapr);
        req.requestBody = Blob.valueof(jsonBody);
        req.requestURI = '/services/apexrest/UpdateStatusAPI/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();        
        LMS_LeaveStatusUpdateAPI.UpdateLeaveStatus();
        Test.stopTest();
        system.assertequals(objLR.HCM_Leave_Record_ID__c,'test');
    }    
}