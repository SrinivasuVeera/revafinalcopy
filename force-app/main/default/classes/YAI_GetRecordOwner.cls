@RestResource(urlMapping='/getRecordOwner')
global class YAI_GetRecordOwner {
     @HttpPost
    global static YAI_Wrapper.APIResponse getRecordOwner() {
        
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response; 
        YAI_Wrapper.APIResponse apiResponse = new YAI_Wrapper.APIResponse();
        YAI_Wrapper.APIRequest apiRequest = new YAI_Wrapper.APIRequest();
        
        String jsonException;
        String SobjectType;
        String applicationStatus;
        
        //retrieve the requestBody and deserialize the json
        String jsonString = restRequest.requestBody.toString();
        try{
            apiRequest = (YAI_Wrapper.APIRequest) JSON.deserialize(jsonString, YAI_Wrapper.APIRequest.class);
        }
        catch(exception ex){
            jsonException = String.valueOf(ex.getTypeName());
            
        }        
        system.debug(apiRequest);
        Id leadOrContactId    = apiRequest.leadOrContactId;
        string recordId = string.valueOf(leadOrContactId);
        List<Sobject> existingObject = new List<Sobject>();
        Profile counselorProfile = [Select Id, Name from Profile where Name = 'Counselor'];
        List<User> counselors = [Select Id, Name,Email, Manager.Name, ManagerId from User 
                                 where ProfileId =:counselorProfile.Id and isActive = true];
        Set<Id> counselorIds = new Set<Id>();
        map<id,string> counselorsEmail = new map<id,string>();
        map<id,string> counselorsName = new map<id,string>();
    for (User counselor : counselors) {
        counselorIds.add(counselor.Id);
        counselorsEmail.put(counselor.Id , counselor.email);
        counselorsName.put(counselor.Id ,counselor.Name);
    }
        try{
            try{
                
                Contact con = [Select Id, Name, record_type_name__c,ownerId from Contact where Id=:leadOrContactId Limit 1];
                existingObject.add(con);
                if(con.record_type_name__c == 'Applicant'){
                    
                   if (counselorIds.contains(con.OwnerId)){
                        apiResponse.email = counselorsEmail.get(con.OwnerId);
                       apiResponse.name = counselorsName.get(con.OwnerId);
                       apiResponse.status ='Assigned';
                       apiResponse.found = true;
                    }
                    else{
                       apiResponse.status =' Not Assigned'; 
                        apiResponse.found = false;
                    }
                }
                
                System.debug('Contact'+existingObject);
            }
            catch (Exception ex){
                system.debug(ex.getMessage());
            }
            if(existingObject.isEmpty()){
                
                Lead lead = [Select id,Name,status,ownerId from Lead where Id=:leadOrContactId Limit 1];
                System.debug('Lead'+lead);
                existingObject.add(lead);
                 if (counselorIds.contains(lead.OwnerId)){
                        apiResponse.email = counselorsEmail.get(lead.OwnerId);
                        apiResponse.name = counselorsName.get(lead.OwnerId);
                       apiResponse.status ='Assigned';
                     apiResponse.found = true;
                    }
                    else{
                       apiResponse.status =' Not Assigned';
                        apiResponse.found = false;
                    }
                System.debug('Lead'+existingObject);
            }else{
                system.debug('No Found');
                
            } 
        }
        catch(exception ex){
            system.debug(ex.getMessage());
        }
        restResponse.statusCode = 200;
        return apiResponse;
    }
}