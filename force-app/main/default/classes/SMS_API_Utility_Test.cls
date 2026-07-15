@isTest 
public  class SMS_API_Utility_Test 
{
    public static testMethod void  SMS_API_Utlty()
    {
        SMS_API_Utility.shortMessageWrp shortMsg = New SMS_API_Utility.shortMessageWrp();
        shortMsg.message = 'TestMsg';
        shortMsg.recipient = 'TestRecp';
        shortMsg.dltContentId = 'DLTID001';
        
        List<SMS_API_Utility.shortMessageWrp> listshort = new List<SMS_API_Utility.shortMessageWrp>();
        listshort.add(shortMsg);
         
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        SMS_API_Utility.SendSMSOneToMany('Absent SMS- Parent',listshort);
        Test.stopTest();
    }
}