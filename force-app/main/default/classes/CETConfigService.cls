@JsonAccess(serializable='always')
global with sharing class CETConfigService implements Callable {

    global Object call(String action, Map<String, Object> args) {

        Map<String, Object> input =
            (Map<String, Object>) args.get('input');
        Map<String, Object> output =
            (Map<String, Object>) args.get('output');
        Map<String, Object> options =
            (Map<String, Object>) args.get('options');

        return invokeMethod(action, input, output, options);
    }

    private Object invokeMethod(String methodName,
                                Map<String,Object> input,
                                Map<String,Object> output,
                                Map<String,Object> options) {

        CET_config__mdt cfg = [
            SELECT Enable_REVA_CET__c, Start_Date__c, End_Date__c
            FROM CET_config__mdt
            LIMIT 1
        ];

        Map<String,Object> data = new Map<String,Object>();
        data.put('Enable_REVA_CET__c', cfg.Enable_REVA_CET__c);
        data.put('Start_Date__c', cfg.Start_Date__c);
        data.put('End_Date__c', cfg.End_Date__c);

        output.put('result', data);

        return output;
    }
}