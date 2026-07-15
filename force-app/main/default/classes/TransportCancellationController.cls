public without Sharing class TransportCancellationController {
 @AuraEnabled
    public static void createCancellationRecord(date cancellationDate, String cancellationReason,String pickupPoint, string revaTransport,string contactId,string srnNumber,Decimal finalFee, decimal uniFeePending,decimal transFeePending) {
       	system.debug('revaTransport>>'+ revaTransport);
        system.debug('pickupPpint>>'+ pickupPoint);
        system.debug('contactId>>'+ contactId);
        system.debug('srnNumber>>'+ srnNumber);
        system.debug('finalFee>>'+ finalFee);
        system.debug('cancellationDate>>'+ cancellationDate);
        system.debug('cancellationReason>>'+ cancellationReason);
        
         RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Transport_Cancellation' 
                             AND SObjectType = 'RTR_Reva_Transport_Request__c' LIMIT 1];
        
        RTR_Reva_Transport_Request__c cancellation = new RTR_Reva_Transport_Request__c();
            cancellation.RecordTypeId = rt.Id;
			cancellation.Cancellation_Date__c = cancellationDate;
            cancellation.RTR_Reason_For_Cancellation__c = cancellationReason;
            cancellation.RTR_Route_Pick_Up_Point__c = pickupPoint;
        	cancellation.RTR_Reva_Transport__c = revaTransport;
        	cancellation.RTR_Student__c = contactId;
        	cancellation.SRN_EmployeeID__c = srnNumber;
        	cancellation.Amount_to_be_Refunded__c = finalFee;
        	cancellation.Transportation_Fee_Pending__c = transFeePending;
        	cancellation.University_Fee_Pending__c = uniFeePending;
        	
        try{
         insert cancellation;
        system.debug('cancellation '+ cancellation);
           }
        catch(exception e){
            system.debug(e.getMessage());
        }
        system.debug('Inserted cancellation: ' + cancellation);

            // 3. Fetch related transport registration record
            Transport_Registeration__c tr = [
                SELECT Id, rtr_Status__c,Registration_Status__c 
                FROM Transport_Registeration__c 
                WHERE Contact__c = :contactId 
                order by CreatedDate DESC limit 1
            ];

            
            tr.Registration_Status__c = 'Cancellation Request Submitted';
            update tr;

            system.debug('Updated Transport Registration Status');
       
    }
     @AuraEnabled
    public static void createTransportRequest(String routePath, String pickupPoint, String reason, Date startDate,string contactId) {
        system.debug('routePath'+ routePath);
        system.debug('pickupPoint'+ pickupPoint);
        system.debug('reason'+ reason);
        system.debug('startDate'+ startDate);
        
        string routemaster;
        string routePickupPoint;
        string SRNNO;
        Decimal existingamount;
        string ContactIds;
        
        List<Transport_Registeration__c> trs = [
    	SELECT Id, Name, Contact__c, Route_Master__c,Registration_Status__c, Route_Pick_Up_Point__c, Contact__r.SRN_Number__c,Contact__r.Application_Number__c,Amount_Paid__c
    	FROM Transport_Registeration__c 
    	WHERE Contact__c = :contactId 
    	LIMIT 1 ];
        
        system.debug('Transport_Registeration__c' + trs);
        
     if (!trs.isEmpty()) {
    		routemaster = trs[0].Route_Master__c;
    		routePickupPoint = trs[0].Route_Pick_Up_Point__c;
    		SRNNO = trs[0].Contact__r.Application_Number__c;
         	existingamount = trs[0].Amount_Paid__c;
         	ContactIds = trs[0].Contact__c;
		} else {
    		throw new AuraHandledException('No transport registration found for contact Id: ' + contactId);
		}
		
		
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Route_Change_Request' 
                             AND SObjectType = 'RTR_Reva_Transport_Request__c' LIMIT 1];
        
        RTR_Reva_Transport_Request__c request = new RTR_Reva_Transport_Request__c();
        	
        	request.RecordTypeId = rt.Id;
        	request.New_Route_Master__c = routePath;
            request.New_Route_Pick_Up_Point__c = pickupPoint;
            request.Reason_for_route_change__c = reason;
            request.StartDate_routeChange__c = startDate;
        	request.SRN_EmployeeID__c = SRNNO;
        	request.Existing_Route_Master__c = routemaster;
            request.Existing_Pickup_Point__c = routePickupPoint;
        	request.Existing_Amount__c = existingamount;
        	request.RTRStudent_Faculty_NonFaculty__c = ContactIds;
                
        insert request;
        
        	Transport_Registeration__c trst = [
                SELECT Id, rtr_Status__c,Registration_Status__c 
                FROM Transport_Registeration__c 
                WHERE Contact__c = :contactId 
                order by CreatedDate DESC limit 1
            ];
        
        	trst.Registration_Status__c = 'Route Change Request Submitted';
            update trst;

            system.debug('Updated Transport Registration route change Status');
    }
    
     @AuraEnabled(cacheable=true)
    public static String getTransportPolicy() {
        // Query CMDT record by DeveloperName or Label
        	TransportPolicy_mdt__mdt policy = [
            SELECT Policy_Details_c__c 
            FROM 	TransportPolicy_mdt__mdt 
            WHERE DeveloperName = 'REVA_Route_Change_Policy' 
            LIMIT 1
        ];
        return policy.Policy_Details_c__c;
    }

@AuraEnabled(cacheable=true)
    public static Transport_Cancelletion__mdt getTransportcancelmdt() {
        // Query the custom metadata where Label is 'Days Deduction'
        List<Transport_Cancelletion__mdt> results = [
            SELECT Id, Label, Processing_Fee__c, Within_30_days__c, Within_60_days__c, Within_90_days__c
            FROM Transport_Cancelletion__mdt
            WHERE Label = 'Days Deduction'
            LIMIT 1
        ];

        if (!results.isEmpty()) {
            return results[0];
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static String getUserProfileName() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
}