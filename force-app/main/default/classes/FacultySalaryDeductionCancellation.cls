public class FacultySalaryDeductionCancellation {

    @InvocableMethod(label='FacultySalaryDeductionCancellation')
	public static void transportCancel(list<String> recordId){
        
		string clientId;
        string ClientSecret;
        string userName;
        string Password;
        string endPoint;
        string grantType ='password';
        
		List<Transport_Registeration__c> transportRegistrations = [
            SELECT Id, Contact__r.Employee_Number__c, Amount_Paid__c, Registration_Type__c,rtr_Start_Date__c,Cancellation_Approved_Date__c,Cancellation_Request_Date__c,Reason_for_Cancellation__c
            FROM Transport_Registeration__c
            WHERE (Registration_Type__c = 'Professor' OR Registration_Type__c = 'Non Teaching')and id = :recordId
        ];

		system.debug('transportRegistrations'+transportRegistrations);
        
		HCM_Credential__mdt[] HCMmetadataRecords = [SELECT Id, client_id__c, client_secret__c, username__c, password__c,End_Point__c,DeveloperName, Label 
                                                    FROM HCM_Credential__mdt where Label='HCM Integartion'];

        
        system.debug('HCMmetadataRecords'+HCMmetadataRecords);
        
         for (HCM_Credential__mdt HCMdata : HCMmetadataRecords) {
    			clientId = HCMdata.client_id__c;
                ClientSecret = HCMdata.client_secret__c;
                userName = HCMdata.username__c;
                Password = HCMdata.password__c;
            	endPoint = HCMdata.End_Point__c;
            }
        

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(endPoint);
        req.setBody('username='+userName+
            '&password='+Password+
            '&grant_type='+grantType+
            '&client_id='+clientId+
            '&client_secret='+ClientSecret);
        
        Http http = new Http();        
        HttpResponse Res = http.send(req);
       	system.debug('Response'+ Res.getBody());
        	String jsonBody = Res.getBody();
        system.debug('jsonBody'+jsonBody);

		HCMWrapper wrapData = (HCMWrapper)JSON.deserialize(jsonBody,HCMWrapper.class );
        System.debug('wrapData-->> '+wrapData.access_token);

		List<Map<String, Object>> jsonPayload = new List<Map<String, Object>>();
        
        for (Transport_Registeration__c reg : transportRegistrations) {
            Map<String, Object> recordData = new Map<String, Object>();
            recordData.put('Employee_Number', reg.Contact__r.Employee_Number__c);
            recordData.put('Cancellation_Reason', String.valueOf(reg.Reason_for_Cancellation__c));
            recordData.put('Cancellation_Request_Date', String.valueOf(reg.Cancellation_Request_Date__c));
			recordData.put('Cancellation_Approved_Date', String.valueOf(reg.Cancellation_Approved_Date__c));
            //recordData.put('Amount', reg.Amount_Paid__c);
            recordData.put('Type','Transportation');
            recordData.put('SLCM_Record_Id', reg.Id);
            
            jsonPayload.add(recordData);
        }
        
        String jsonString = JSON.serialize(jsonPayload);
        system.debug('jsonString: ' + jsonString);

        // Make the POST request with JSON data

		HCM_Credential__mdt[] HCMmetadataRecordss = [SELECT Id,End_Point__c,DeveloperName, Label 
                                                    FROM HCM_Credential__mdt where Label='FacultySalaryDeductionCancel'];
        
        system.debug('HCMmetadataRecordss'+HCMmetadataRecordss);
        HttpRequest reqs = new HttpRequest();
        reqs.setMethod('POST');
        reqs.setHeader('Authorization','Bearer '+wrapData.access_token);
        reqs.setEndpoint(HCMmetadataRecordss[0].End_Point__c); // Your actual endpoint URL
        reqs.setHeader('Content-Type', 'application/json');
        reqs.setBody(jsonString);
		
        Http https = new Http();        
        HttpResponse resq = https.send(reqs);
        system.debug('resq'+resq);
        // Capture and handle the response
        system.debug('Response Status: ' + resq.getStatus());
        system.debug('Response Body: ' + resq.getBody());

        // Handle the response in case of success/failure (optional)
        if (res.getStatusCode() == 200) {
            system.debug('Success: ' + resq.getBody());
        } else {
            system.debug('Failed with status code: ' + resq.getStatusCode());
        }
    }

    

 public class HCMWrapper{
        string access_token;
        
        public HCMWrapper(string access_token){
            this.access_token = access_token;
            
        }
}
}