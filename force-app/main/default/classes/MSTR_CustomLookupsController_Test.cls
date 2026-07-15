@isTest
public class MSTR_CustomLookupsController_Test 
{
    static testMethod void testLookupField() 
    {
        lead led = new lead();
        led.LastName = 'Test';
        led.company = 'Test';
        led.status = 'New';
        insert led;
        List<string> returnFields = new List<string> {'LastName'};
        MSTR_CustomLookupsController.getObjectDetails('Lead');
        MSTR_CustomLookupsController.GetRecentRecords('Lead', returnFields, 5);
        MSTR_CustomLookupsController.SearchRecords('Lead', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z');
        MSTR_CustomLookupsController.GetRecord('Lead', returnFields, led.Id);
        system.assertequals(led.Id,led.Id);
    }
    static testMethod void testLookupField1() 
    {
        lead led = new lead();
        led.LastName = 'Test';
        led.company = 'Test';
        led.status = 'New';
        insert led;
        List<string> returnFields = new List<string> {'LastName'};
        MSTR_CustomLookupsController.getObjectDetails('Lead');
        MSTR_CustomLookupsController.GetRecentRecords('Lead', null, 5);
        MSTR_CustomLookupsController.SearchRecords('Lead', null, null, '', 'Name', 'ASC', 0, 'CreatedDate > 2001-01-01T00:00:01Z');
        MSTR_CustomLookupsController.GetRecord('Lead', null, led.Id);
        system.assertequals(led.Id,led.Id);
    }
}