@isTest
public class MM_TestDataFactory_Test 
{
    public static testMethod Void TestDatMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAccount = MM_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        Contact objCon = MM_TestDataFactory.createContact('Test');
        case objcase = MM_TestDataFactory.createCase('Queued','Email');
        event objevent =  MM_TestDataFactory.CreateEvent(userinfo.getuserid(),'',system.now(),system.now());
        CaseTeamMember objcaseTeam = MM_TestDataFactory.CreateCaseMember();
        sfal__Appointment__c objapp = MM_TestDataFactory.createAppointment(system.now(),system.now());
        sfal__AppointmentAttendee__c objappAtt = MM_TestDataFactory.CreaetAppAttendance(objapp.id);
     }
}