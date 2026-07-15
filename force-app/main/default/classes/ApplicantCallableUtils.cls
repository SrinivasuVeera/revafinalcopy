public with sharing class ApplicantCallableUtils implements Callable {
    //https://help.salesforce.com/s/articleView?id=sf.os_callable_implementations.htm&type=5
    
    Object getApplicantContactId(Map<String, Object> args) {
      Map<String, Object> input = (Map<String, Object>)args.get('input');
      String applicationId = (String)input.get('applicationId');
        
	  Id profileId=userinfo.getProfileId();
	  String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
      //Get Output map from arguments
      Map<String, Object> output = (Map<String, Object>)args.get('output');

      if (applicationId != null && (profileName=='Counselor' || profileName =='System Administrator' || profileName == 'RO Profile') ) {
        hed__Application__c app = [select hed__Applicant__c from hed__Application__c where id = :applicationId ];

        output.put('contactId', app.hed__Applicant__c);
      } else {
        List<User> siteUser = [select id, ContactId from user where Id = :UserInfo.getUserId() ];
                
        output.put('contactId', siteUser[0].ContactId);
      }
        
      return output;
    }
    
    Object getCETApplicationNumber(Map<String, Object> args) {
      Map<String, Object> input = (Map<String, Object>)args.get('input');
      String programType = (String)input.get('programType');
      string admissionMode = (String)input.get('admissionMode');
      String cetApplicationNumber = RegistrationProcessUtility.getCETApplicationNumber(programType, admissionMode);

      //Get Output map from arguments
      Map<String, Object> output = (Map<String, Object>)args.get('output');
      
      output.put('cetApplicationNumber', cetApplicationNumber);
      
      return output;
    }

    Object createFeeRecordsForCETApplicant(Map<String, Object> args) {
      Map<String, Object> input = (Map<String, Object>)args.get('input');
      String contactId = (String)input.get('contactId');
      
      String result = GovtQuotaAdmissionsUtility.createFeeRecordsForCETApplicant(contactId);

      //Get Output map from arguments
      Map<String, Object> output = (Map<String, Object>)args.get('output');
      
      output.put('createFeeRecsResult', result);
      
      return output;
    }
    
    // Dispatch actual methods
    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'getApplicantContactId' {
                return this.getApplicantContactId(args);
            }
            when 'getCETApplicationNumber' {
              return this.getCETApplicationNumber(args);
            }
            when 'createFeeRecordsForCETApplicant' {
              return this.createFeeRecordsForCETApplicant(args);
            }
            when else {
                system.debug('Method not implemented');
                Map<String,Object> output = New Map<String,Object>();
                return output;
            }
        }
    }
}