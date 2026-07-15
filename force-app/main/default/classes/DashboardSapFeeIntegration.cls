public without sharing class DashboardSapFeeIntegration{   
    
     @AuraEnabled(cacheable=true)
    public static List<String> getDashboardData() {
        // Create a list to hold the JSON strings
        List<String> responseDataList = new List<String>();
        
        // Prepare the HTTP request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('dashboard_fees_data');
        String endpointURL = mdt.EndPointURL__c;
        
        request.setEndpoint(endpointURL);
        request.setMethod('POST');
        request.setBody('{}');
        request.setHeader('Content-Type', 'application/json');        
        request.setTimeout(120000);  

        try {
            // Send the HTTP request
            HttpResponse response = http.send(request);
            
            // Check if the response status is 200 (OK)
            if (response.getStatusCode() == 200) {
                // Parse the JSON response
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> responseData = (List<Object>) result.get('ResponseData');
                
                // Loop through the response data and serialize each item to a JSON string
                for (Object item : responseData) {
                    responseDataList.add(JSON.serialize(item));
                }
            } else {
                // Handle non-200 status codes
                throw new CalloutException('Failed to get a successful response. Status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            // Handle any exceptions
            throw new CalloutException('Error occurred while fetching data: ' + e.getMessage());
        }
        
        // Return the list of JSON strings
        return responseDataList;
    }
}