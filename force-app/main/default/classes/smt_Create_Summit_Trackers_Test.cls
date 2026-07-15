@isTest
private class smt_Create_Summit_Trackers_Test {
    @isTest
    static void testSetInputValues() {
        String objectName = 'Account';
        String recordTypeName = 'University Department';
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = sobjectType.getDescribe().getRecordTypeInfosByName();
        System.debug('Record types ' +recordTypeInfos );
        Schema.RecordTypeInfo recordTypeInfo = recordTypeInfos.get(recordTypeName);
        String recordTypeId = recordTypeInfo.getRecordTypeId();
        
        // Now you have the Record Type ID to use in your test class
        System.debug('Record Type ID for Account - University: ' + recordTypeId);
        
        // You can use recordTypeId in your test class for creating records with the specific Record Type ID
        
        Account acc = new Account(Name = 'School Of Biotechnology', RecordTypeId= recordTypeId);
        insert acc;
        
            List<List<String>> inputValues = new List<List<String>>();
        List<String> input = new List<String>();
        input.add('Test Summit Tracker');
        input.add('2024-01-01');
        input.add('2024-06-01');
        input.add('2024');
        inputValues.add(input);
        
        // Call the method under test
        Test.startTest();
        smt_Create_Summit_Trackers.setInputValues(inputValues);
        Test.stopTest();
    }
    
    
}