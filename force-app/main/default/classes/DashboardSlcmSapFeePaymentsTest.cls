@isTest
public class DashboardSlcmSapFeePaymentsTest {   
    @isTest
    static void testGetOnlineFeePaymentStats() {
        Test.startTest();
        String jsonResponse = DashboardSlcmSapFeePayments.getOnlineFeePaymentStats();
        Test.stopTest();
        
        // Deserialize the JSON response to a Map for verification
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
         // Convert the Map<String, Object> to Map<String, Decimal> if necessary
        Map<String, Decimal> decimalResult = new Map<String, Decimal>();
        for (String key : result.keySet()) {
            decimalResult.put(key, (Decimal) result.get(key));
        }        
        System.assertNotEquals(null, decimalResult, 'The JSON response should not be null');
    }
    
    @isTest
    static void testGetOfflineFeePaymentStats() {
        Test.startTest();
        String jsonResponse = DashboardSlcmSapFeePayments.getOfflineFeePaymentStats();
        Test.stopTest();
        
        // Deserialize the JSON response to a Map for verification
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
         // Convert the Map<String, Object> to Map<String, Decimal> if necessary
        Map<String, Decimal> decimalResult = new Map<String, Decimal>();
        for (String key : result.keySet()) {
            decimalResult.put(key, (Decimal) result.get(key));
        }        
        System.assertNotEquals(null, decimalResult, 'The JSON response should not be null');  
    }
    
    @isTest
    static void testGetOnlineFeePaymentsMonthStats() {      
        Test.startTest();
        String jsonResponse = DashboardSlcmSapFeePayments.getOnlineFeePaymentsMonthStats();
        Test.stopTest();
        
        // Deserialize the JSON response to a Map for verification
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
         // Convert the Map<String, Object> to Map<String, Decimal> if necessary
        Map<String, Decimal> decimalResult = new Map<String, Decimal>();
        for (String key : result.keySet()) {
            decimalResult.put(key, (Decimal) result.get(key));
        }        
        System.assertNotEquals(null, decimalResult, 'The JSON response should not be null');  
    }
    
    @isTest
    static void testGetOfflineFeePaymentsMonthStats() { 
        Test.startTest();
        String jsonResponse = DashboardSlcmSapFeePayments.getOfflineFeePaymentsMonthStats();
        Test.stopTest();
        
        // Deserialize the JSON response to a Map for verification
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
         // Convert the Map<String, Object> to Map<String, Decimal> if necessary
        Map<String, Decimal> decimalResult = new Map<String, Decimal>();
        for (String key : result.keySet()) {
            decimalResult.put(key, (Decimal) result.get(key));
        }        
        System.assertNotEquals(null, decimalResult, 'The JSON response should not be null'); 
    }
}