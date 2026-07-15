public with sharing class RTR_RouteChangeRefund {
    
    public class TokenResponse {
        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String error;
        public String error_description;
        public String userName;
        public String Password;
        public String endPoint;
        
    }

	  // Class for fee details
    public class FeeDetail {
        public Decimal Total_Amount;
        public String SRNNumber;
        public String SFDCRecordId;
        public String Session;
        public Decimal Scholarship;
        public String SACCode;
        public Decimal Premium;
        public String Fee_Name;
        public String Due_date;
        public Decimal Concession;
        public String Application_Number;
        public Decimal Actual_Program_Fee;
    }
    
    public static String getAccessToken() {
        String accessToken = null;
        String userName;
    	String password;
    	String endPoint;
        string grantType ='password';
        
        Transport_Cancelletion__mdt[] TransportCancel = [SELECT Id,username__c, password__c, End_Point__c, DeveloperName, Label FROM Transport_Cancelletion__mdt where Label='getAccessToken'];
        
        for (Transport_Cancelletion__mdt TransMetaData : TransportCancel) {
    			userName = TransMetaData.username__c;
                Password = TransMetaData.password__c;
            	endPoint = TransMetaData.End_Point__c;
            	
            
            }
        
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            
            request.setEndpoint(endPoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            
            String body = ('username='+userName+
            '&password='+Password+
            '&grant_type='+grantType);
            request.setBody(body);
            
            
            HttpResponse response = http.send(request);
            
            
            if (response.getStatusCode() == 200) {
                TokenResponse tokenResp = (TokenResponse) JSON.deserialize(response.getBody(), TokenResponse.class);
                accessToken = tokenResp.access_token;
            } else {
                System.debug('Error response: ' + response.getBody());
            }
            
        } catch (Exception ex) {
            System.debug('Exception while getting access token: ' + ex.getMessage());
        }
        
        return accessToken;
    }
     // Method to post fee details
     @InvocableMethod(label='Create SAP Record For Route Change Refund')
    public static void postFeeDetailss(list<Id> recordId) {
        String token = getAccessToken();
       	
        if (String.isBlank(token)) {
            System.debug('Access token not retrieved. Aborting callout.');
            return;
        }
        List<RTR_Reva_Transport_Request__c> cancellationList = [
            SELECT Id, Name, RTRStudent_Faculty_NonFaculty__c, RecordType.Name, RouteChangeRefund__c,Amount_to_be_Refunded__c,RTRStudent_Faculty_NonFaculty__r.SRN_Number__c,RTRStudent_Faculty_NonFaculty__r.Application_Number__c, StartDate_routeChange__c
            FROM RTR_Reva_Transport_Request__c
            WHERE RTRStudent_Faculty_NonFaculty__c != null AND Id IN :recordId
            AND RecordType.Name = 'Route Change Request' 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        System.debug('cancellationList-->> '+cancellationList);
        
       String ConId = cancellationList[0].RTRStudent_Faculty_NonFaculty__c;
       String session;
       decimal amountPaid;
       Id feePaymentId;
       
        list<Student_Fee__c> studentfee = [select Id,Fee_Type__c,Session__c,Contact__c,RTR_Transport_Registration__r.Amount_Paid__c, (SELECT Id FROM Student_Fee_Payments__r LIMIT 1) from Student_Fee__c 
                                           where Fee_Type__c = 'Transportation Fee' AND  Contact__c= :ConId order by CreatedDate desc limit 1];
		System.debug('studentfee--> '+studentfee);
				session = studentfee[0].Session__c;
        		amountPaid = studentfee[0].RTR_Transport_Registration__r.Amount_Paid__c;
        		feePaymentId = studentfee[0].Student_Fee_Payments__r[0].Id;
        
        Transport_Cancelletion__mdt[] TransportCancelss = [SELECT Id,username__c, password__c, End_Point__c, DeveloperName, Label FROM Transport_Cancelletion__mdt where Label='Demand Cancellation API'];
        String endPoint;
        for (Transport_Cancelletion__mdt TransMetaData : TransportCancelss) {
            	endPoint = TransMetaData.End_Point__c;
            	
            
            }
         
        // Step 2: Iterate over the list and store values as needed
        for (RTR_Reva_Transport_Request__c req : cancellationList) {
            Decimal refundAmount = req.RouteChangeRefund__c;
            System.debug('Refund Amount: ' + refundAmount);
            date cancelDate = req.StartDate_routeChange__c;
            String formattedCancelDate = DateTime.newInstance(cancelDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
            system.debug('formattedCancelDate>> ' + formattedCancelDate);
            string SRNNumber = req.RTRStudent_Faculty_NonFaculty__r.SRN_Number__c;
            system.debug('SRNNumber ' + SRNNumber);
            string appNumber = req.RTRStudent_Faculty_NonFaculty__r.Application_Number__c ;
 
             try {
            // Prepare sample fee data
            FeeDetail fee = new FeeDetail();
            fee.Total_Amount = amountPaid;
            fee.SRNNumber = SRNNumber;
            fee.SFDCRecordId = feePaymentId;
            fee.Session = session;
            fee.Scholarship = 0.00;
            fee.SACCode = '00997163';
            fee.Premium = 0.00;
            fee.Fee_Name = 'Transportation Fee';
            fee.Due_date = formattedCancelDate;
            fee.Concession = 0.00;
            fee.Application_Number = appNumber;
            fee.Actual_Program_Fee = refundAmount;

            String payload = JSON.serialize(new List<FeeDetail>{fee});

            Http http = new Http();
            HttpRequest request = new HttpRequest();

            // Set endpoint (same Named Credential or raw URL)
            request.setEndpoint(endPoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + token);
            request.setBody(payload);

            HttpResponse response = http.send(request);

            System.debug('Status: ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());

        } catch (Exception ex) {
            System.debug('Fee Posting Exception: ' + ex.getMessage());
        }
        }

       
    }
}