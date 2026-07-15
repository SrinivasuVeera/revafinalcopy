public class MM_TestDataFactory 
{    
    public static Account CreateAccount(string str_accName,String RecTypeId)
    {
        Account objAccount = new Account();
        objAccount.Name = str_accName;
        objAccount.RecordTypeId =  RecTypeId;
        return objAccount;
    }
    
    public static Contact createContact(string str_lastName)
    {
        Contact objContact = new Contact();
        objContact.LastName = str_lastName;
        return objContact;
    }
    public static Case createCase(string caseStatus,string caseOrigin)
    {
        case objcase = new case();
        objcase.Status = caseStatus;
        objcase.Origin = caseOrigin;
        return objcase;
    }
    public static event CreateEvent(string userid,string strSubject,datetime stdate,datetime enddate)
    {
         event objEvent = new event();
         objEvent.OwnerId = userid;
         objEvent.StartDateTime = stdate;
         objEvent.Subject = strSubject;
         objEvent.EndDateTime = enddate;
         return objEvent;
    }  
    public static CaseTeamMember CreateCaseMember()
    {
         CaseTeamMember objcasemember = new CaseTeamMember();
         return objcasemember;
    }  
    public static sfal__Appointment__c createAppointment(Datetime Stdate,Datetime enddate)
    {
      sfal__Appointment__c objApp = new sfal__Appointment__c();
      objApp.sfal__EndDateTime__c = enddate;
      objApp.sfal__StartDateTime__c = Stdate;
      return objApp;
    }  
    public static sfal__AppointmentAttendee__c CreaetAppAttendance(string appid)
    {
        sfal__AppointmentAttendee__c objAppAtt = new sfal__AppointmentAttendee__c();
        objAppAtt.sfal__Appointment__c = appid;
        return objAppAtt;
    }    
}