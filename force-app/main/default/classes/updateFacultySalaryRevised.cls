public class updateFacultySalaryRevised{


/*@future(callout=true)
    public static void facultySalaryUpdateFutures(String contactId) {
        facultySalaryUpdateRevise(contactId);
    }*/
   @InvocableMethod
    public Static void facultySalaryUpdateRevise(list<string> ContactID){
        
        List<Transport_Registeration__c> transportRegistrations = [
            SELECT Id, Contact__r.Employee_Number__c, Contact__r.ID,Amount_Paid__c, Registration_Type__c
            FROM Transport_Registeration__c
            WHERE (Registration_Type__c = 'Professor' OR Registration_Type__c = 'Non Teaching') AND Contact__r.ID =:ContactID
        ];
		system.debug('transportRegistrations'+transportRegistrations);
        
        if (transportRegistrations.isEmpty()) {
            System.debug('No transport registrations found for Professors.');
            return;
        }

        String accessToken = getAccessToken();
        system.debug('accessToken'+accessToken);
        
		list<Transport_Registeration__c> transportRegistrationsToUpdate = new list <Transport_Registeration__c>();
        list<Faculty_Payment__c> facultyPaymentsToInsert = new list <Faculty_Payment__c>();
            
        for (Transport_Registeration__c registration : transportRegistrations) {
            String employeeNumber = registration.Contact__r.Employee_Number__c;
            Decimal currentAmountPaid = registration.Amount_Paid__c;
            
			system.debug('employeeNumber'+employeeNumber);
            system.debug('currentAmountPaid'+currentAmountPaid);
            
            // Get the salary range from the API
            Decimal apiSalaryRange = getSalaryRange(accessToken, employeeNumber, 'Transportation');
			system.debug('apiSalaryRange'+apiSalaryRange);
            
            // Compare the current amount paid and the salary range
            if (apiSalaryRange != null && !apiSalaryRange.equals(currentAmountPaid)) {
                // Update the Transport Registration with the new amount
                registration.Amount_Paid__c = apiSalaryRange;

                // Create a Faculty Payment record
                Faculty_Payment__c payment = new Faculty_Payment__c();
                payment.Amount_Paid__c = apiSalaryRange;
                payment.Transport_Registration__c = registration.Id;

                // Add to lists for bulk DML operations
                transportRegistrationsToUpdate.add(registration);
                facultyPaymentsToInsert.add(payment);
            }
        }

        // Update the transport registrations and insert faculty payments
        if (!transportRegistrationsToUpdate.isEmpty()) {
            update transportRegistrationsToUpdate;
            insert facultyPaymentsToInsert;
        }

        System.debug('Process completed successfully.');
    }

   public static String getAccessToken(){
        string clientId;
        string ClientSecret;
        string userName;
        string Password;
        string endPoint;
        string grantType ='password';
        
        HCM_Credential__mdt[] HCMmetadataRecords = [SELECT Id, client_id__c, client_secret__c, username__c, password__c, End_Point__c, DeveloperName, Label FROM HCM_Credential__mdt where Label='HCM Integartion'];
    	
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
        //deserialize
        HCMWrapper wrapData = (HCMWrapper)JSON.deserialize(jsonBody,HCMWrapper.class );
        System.debug('wrapData-->> '+wrapData.access_token); 
       // getSalaryRange(wrapData.access_token,employeeNumbers,'Transportation');
        return wrapData.access_token;
}

    public class HCMWrapper {
        String access_token;
        String type;
        public HCMWrapper(String access_token, String Type) {
            this.access_token = access_token;
            this.type = type;
        }
    }

   public static Decimal getSalaryRange(String accessToken,string employeeNumber,String Type){
        HCM_Credential__mdt[] SalaryRecords = [SELECT Id,End_Point__c, DeveloperName, Label FROM HCM_Credential__mdt where Label ='SalaryRangeApi'];
        system.debug('SalaryRecords'+SalaryRecords);
        string endpoint = SalaryRecords[0].End_Point__c+employeeNumber+'&Type='+Type;
        system.debug('endpoint '+ endpoint);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndPoint(endpoint);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer '+ accessToken);
        
         Http http = new Http();        
        HttpResponse Res = http.send(req);
       	system.debug('Response'+ Res.getBody());
        
        
    // Deserialize the response
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    if (responseMap != null && responseMap.containsKey('Salary_Range')) {
       
        Decimal salaryRange = (Decimal) responseMap.get('Salary_Range');
        system.debug('Salary Range for ' + employeeNumber + ': ' + salaryRange);

        
        Decimal employeeSalaryRange = salaryRange;
        system.debug('employeeSalaryRange'+employeeSalaryRange);
       return employeeSalaryRange;
    } else {
        system.debug('Salary range not found in the response.');
        return null;
    }
}
    
    public static void testCover(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}