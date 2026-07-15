@IsTest
public class CETConfigServiceTest {

    @IsTest
    static void testCallableMethod() {

        // Prepare input maps (OmniStudio format)
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };

        // Instantiate class
        CETConfigService service = new CETConfigService();

        Test.startTest();
        Object result = service.call('getCETConfig', args);
        Test.stopTest();

        // Validate response
        System.assertNotEquals(null, result);

        Map<String, Object> resultMap = (Map<String, Object>) result;
        System.assert(resultMap.containsKey('result'));

        Map<String, Object> data =
            (Map<String, Object>) resultMap.get('result');

        System.assert(data.containsKey('Enable_REVA_CET__c'));
        System.assert(data.containsKey('Start_Date__c'));
        System.assert(data.containsKey('End_Date__c'));
    }
}