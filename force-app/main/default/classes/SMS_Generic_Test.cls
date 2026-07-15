@isTest
private class SMS_Generic_Test {
    
    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMocks_Test());
        String smsType = 'OTP';
        String smsTypes = 'Application_Number';
        String unicode='false';
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        List<String> requriedVariables = New List<String>{'1234','REVA','10 Minutes'}; 
        HttpResponse res = SMS_Generic.sendSMS(smsType,'918951419170',requriedVariables);
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = '{"transactionId":14981545366,"state":"SUBMIT_ACCEPTED","description":"Message submitted successfully","pdu":1,"corelationId":null}';
        String expectedValue = '{"transactionId":14981545366,"state":"SUBMIT_ACCEPTED","description":"Message submitted successfully","pdu":1,"corelationId":null}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMocks_Test());
            
        List<String> requriedVariablesAN = New List<String>{'1234'}; 
            HttpResponse resAN = SMS_Generic.sendSMS(smsTypes,'918951419170',requriedVariablesAN);
        
        // Verify response received contains fake values
        String contentTypeAN = resAN.getHeader('Content-Type');
        System.assert(contentTypeAN == 'application/json');
        String actualValueAN = '{"transactionId":14981787465,"state":"SUBMIT_ACCEPTED","description":"Message submitted successfully","pdu":1,"corelationId":null}';
        String expectedValueAN = '{"transactionId":14981787465,"state":"SUBMIT_ACCEPTED","description":"Message submitted successfully","pdu":1,"corelationId":null}';
        System.assertEquals(actualValueAN, expectedValueAN);
        System.assertEquals(200, resAN.getStatusCode());
    
       
            // Set mock callout class 
            
    }
}