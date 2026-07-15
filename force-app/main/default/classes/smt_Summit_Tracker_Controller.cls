public without sharing class smt_Summit_Tracker_Controller {
     @AuraEnabled
    public static String createSummitTracker(String summitTrackerName, String schoolId, String batch, String category) {
        try {
            if (FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {                
                smt_Summit_Tracker__c smtTracker = new smt_Summit_Tracker__c(
                    Name = summitTrackerName, 
                    smt_School__c = schoolId,
                    smt_Year__c = Decimal.valueOf(batch),
                    Category__c = category
                );
                insert AS USER smtTracker;
                return smtTracker.Id;
            }
            else {
                throw new SecurityException('You do not have permission to create Summit Tracker records.');
            } 
        } catch (Exception e) {
            System.debug('Error :'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
   @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Particular__c> getSummitParticulars(String summitSectionId, String semester){
       if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
            FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) { 
                if(semester == 'Odd'){
                       return [SELECT Id, Name, smt_Achieved__c, smt_Target__c, smt_Target_Text__c, smt_Timeline__c, smt_Percentage_Achieved__c,
                        smt_Is_Evidence_Applicable__c ,smt_Is_Target_Applicable__c, smt_Evidence_To_Be_Attached__c, 
                        smt_Actual_Percentage_Achieved__c
                        FROM smt_Summit_Particular__c
                        WHERE (smt_Is_Evidence_Applicable__c = TRUE 
                               OR smt_Is_Target_Applicable__c =  TRUE) AND 
                               smt_Summit_Section__c=:summitSectionId AND 
                               (Name Like '%OS' OR Name Like '%Odd')
                        WITH USER_MODE
                        ORDER BY Name ASC];
                    
                }else{
                       return [SELECT Id, Name, smt_Achieved__c, smt_Target__c, smt_Target_Text__c, smt_Timeline__c, smt_Percentage_Achieved__c,
                        smt_Is_Evidence_Applicable__c ,smt_Is_Target_Applicable__c, smt_Evidence_To_Be_Attached__c, 
                        smt_Actual_Percentage_Achieved__c
                        FROM smt_Summit_Particular__c
                        WHERE (smt_Is_Evidence_Applicable__c = TRUE 
                               OR smt_Is_Target_Applicable__c =  TRUE)AND 
                               smt_Summit_Section__c=:summitSectionId AND 
                               (NOT Name LIKE '%OS') AND (NOT Name LIKE '%Odd')
                        WITH USER_MODE
                        ORDER BY Name ASC];
                }
             
            }else{
                return new List<smt_Summit_Particular__c>();
            } 
    }
    
    
    @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Particular__c> getAllSummitParticulars(String summitSectionId){
        if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
            FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {
                return [SELECT Id, Name, smt_Achieved__c, smt_Target_Text__c, smt_Timeline__c, 
                        smt_Percentage_Achieved__c,smt_Target__c,smt_Is_Evidence_Applicable__c ,
                        smt_Is_Target_Applicable__c, smt_Evidence_To_Be_Attached__c, 
                        smt_Actual_Percentage_Achieved__c
                        FROM smt_Summit_Particular__c
                        WHERE smt_Summit_Section__c=:summitSectionId
                        WITH USER_MODE
                        ORDER BY Name ASC
                       ];
           }
        else{
            return new List<smt_Summit_Particular__c>();
        } 
    }
    
    
    @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Tracker__c> getSummitTracker(String schoolId){
        if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
            FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) { 
                return [SELECT Id, Name, smt_Total_Weightage_Achieved__c, smt_Year__c 
                        FROM smt_Summit_Tracker__c
                        WHERE smt_Is_Active__c = TRUE AND smt_School__c =:schoolId 
                        WITH USER_MODE];
            }
        else{
            return new List<smt_Summit_Tracker__c>();
        } 
    }
    
   @AuraEnabled
    public static void updateSummitParticular(String jsonData){
        try{
            if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
                FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {  
                    JsonToUpdateSummitParticular obj = new JsonToUpdateSummitParticular();
                    obj = obj.parse(jsonData);
                    
                    smt_Summit_Particular__c particular = new smt_Summit_Particular__c(Id = obj.Id);
                    particular.smt_Achieved__c = isDecimal(obj.achievedValue) ? Decimal.valueOf(obj.achievedValue) : 0;
                    particular.smt_Evidence_To_Be_Attached__c = obj.evidenceValue;
                    
                    Update AS USER particular;
                }else{
                    throw new SecurityException('You do not have permission to Update Summit Particular records.');
                } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateAllSummitParticular(String jsonData){
        try{
            if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
                FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) { 
                    JsonToSummitParticular obj = new JsonToSummitParticular();
                    List<JsonToSummitParticular> summitParticulars = obj.parse(jsonData);
                    List<smt_Summit_Particular__c> summitParticularsToUpdate = new List<smt_Summit_Particular__c>();
                    
                    for(JsonToSummitParticular summitParticular : summitParticulars){
                        String timeLineString = summitParticular.timeLine.substring(0, 10); 
                        Date timeLine = Date.valueOf(timeLineString); 
                        smt_Summit_Particular__c particular = 
                            new smt_Summit_Particular__c(Id = summitParticular.summitParticularId);
                        particular.Name = summitParticular.summitParticularName;
                        particular.smt_Timeline__c = timeLine;
                        particular.smt_Target__c = summitParticular.target;
                        particular.smt_Target_Text__c = summitParticular.targetText;
                        particular.smt_Is_Evidence_Applicable__c = summitParticular.isEvidenceApplicable;
                        particular.smt_Is_Target_Applicable__c	= summitParticular.isTargetApplicable;
                        summitParticularsToUpdate.add(particular);
                    }
                    
                    
                    Update AS USER summitParticularsToUpdate;
                }else{
                    throw new SecurityException('You do not have permission to Update Summit Particular records.');
                } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Boolean isDecimal(String input) {
        try {
            Decimal decimalValue = Decimal.valueOf(input);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Summit_Section_Metadata__mdt> getSummitSectionsMetadata(){
        if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
            FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {
                return [SELECT Id, MasterLabel, smt_Weightage__c
                        FROM Summit_Section_Metadata__mdt 
                        WITH USER_MODE
                        ORDER BY MasterLabel ASC];
            }else{
                return new List<Summit_Section_Metadata__mdt>();
            }
        
    }    
    
   @AuraEnabled(cacheable = true)
    public static List<Summit_Particular__mdt> getSummitParticularsMetadata(String summitSectionLabel){
        if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
            FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {
                return [SELECT MasterLabel, Summit_Section__c, Id 
                        FROM Summit_Particular__mdt 
                        WHERE Summit_Section__r.MasterLabel =: summitSectionLabel 
                        WITH USER_MODE
                        ORDER BY MasterLabel ASC];
            }else{
                return new List<Summit_Particular__mdt>();
            }
    }
    
   @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Section__c> getSummitSectionRecords(String summitTrackerId){
        if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
            FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) { 
                return [ SELECT Id, Name, smt_Weightage__c, smt_Sum_Of_Percentage_Achieved__c, smt_Number_Of_Particulars__c, 
                        smt_Target_Achieved__c, smt_No_Of_Particulars_Without_Condition__c,
                        smt_Target_Achieved_With_Weightage__c
                        FROM smt_Summit_Section__c 
                        WHERE smt_Summit_Tracker__c =: summitTrackerId
                        ORDER BY Name ASC];
            }else{
                return new List<smt_Summit_Section__c>();
            } 
    }
    
     @AuraEnabled
    public static void createSummitSections(String jsonData, String summitTrackerId) {
        try {
            if (FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {
                List<smt_Summit_Section__c> sectionsToCreate = new List<smt_Summit_Section__c>();
                JsonToSummitSection obj = new JsonToSummitSection();
                List<JsonToSummitSection> summitSections = obj.parse(jsonData);
                System.debug(summitSections.size());
                
                // Iterate over each section data
                for (JsonToSummitSection summitSection : summitSections) {
                    smt_Summit_Section__c section = new smt_Summit_Section__c();
                    section.Name = summitSection.sectionName;
                    section.smt_Weightage__c = summitSection.weightage;
                    section.smt_Summit_Tracker__c = summitTrackerId;
                    
                    sectionsToCreate.add(section);
                }
                
                if (!sectionsToCreate.isEmpty()) {
                    insert AS USER sectionsToCreate;
                }
            }else{
                throw new SecurityException('You do not have permission to create Summit Section records.');
            } 
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Summit Section records: ' + e.getMessage());
        }
    }
    
     @AuraEnabled
    public static void createSummitParticular(String jsonData, String summitSectionId) {
        try {
            if (FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) { 
                List<smt_Summit_Particular__c> particularsToCreate = new List<smt_Summit_Particular__c>();
                JsonToSummitParticular obj = new JsonToSummitParticular();
                List<JsonToSummitParticular> summitParticulars = obj.parse(jsonData);
                
                for (JsonToSummitParticular summitParticular : summitParticulars) {
                    String timeLineString = summitParticular.timeLine.substring(0, 10); 
                    Date timeLine = Date.valueOf(timeLineString); 
                    smt_Summit_Particular__c particular = new smt_Summit_Particular__c();
                    particular.Name = summitParticular.summitParticularName;
                    particular.smt_Timeline__c = timeLine;
                    particular.smt_Target__c = summitParticular.target;
                    particular.smt_Target_Text__c = summitParticular.targetText;
              //      particular.smt_Is_Evidence_Applicable__c = summitParticular.isEvidenceApplicable;
              //      particular.smt_Is_Target_Applicable__c	= summitParticular.isTargetApplicable;
              		particular.smt_Is_Evidence_Applicable__c = true;		// default set to true for monthwise implementation
                    particular.smt_Is_Target_Applicable__c	= true;			// default set to true for monthwise implementation
                    particular.smt_Summit_Section__c = summitSectionId;
                    particularsToCreate.add(particular);
                }
                
                if (!particularsToCreate.isEmpty()) {
                    insert particularsToCreate;
                }
            }else{
                throw new SecurityException('You do not have permission to create Summit Particular records.');
            } 
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Summit Section records: ' + e.getMessage());
        }
    }
    
 
    /************************ Month wise implementation of particulars START **********************/  
    
    @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Particular__c> getAllSummitMonthWiseParticulars(String summitSectionId){
        
        if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
            FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) { 
                
       	 return [SELECT Id, Name, smt_Summit_Section__c, smt_Summit_Section__r.Name, 
                        	(SELECT Id, Name, smt_Achieved__c, smt_Target_Text__c, smt_Timeline__c, 
                                smt_Percentage_Achieved__c,smt_Target__c,smt_Is_Evidence_Applicable__c ,
                                smt_Is_Target_Applicable__c, smt_Evidence_To_Be_Attached__c, 
                                smt_Actual_Percentage_Achieved__c,smt_Summit_Section__c,smt_Comments__c  
                             	FROM Summit_Particular_Months__r) 
                        FROM smt_Summit_Particular__c 
                        WHERE smt_Summit_Section__c =: summitSectionId
                        WITH USER_MODE
                        ORDER BY Name ASC
                       ];
                 }
        else{
            return new List<smt_Summit_Particular__c>();
        } 
    }
    
    @AuraEnabled
    public static void createSummitParticularMonthly(String jsonData, String summitSectionId,String summitParticularId) {
        try {
            if (FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {
                List<smt_Summit_Particular_Month__c> particularsToCreate = new List<smt_Summit_Particular_Month__c>();
                JsonToSummitParticularMonthly obj = new JsonToSummitParticularMonthly();
                List<JsonToSummitParticularMonthly> summitParticulars = obj.parse(jsonData);
                
                for (JsonToSummitParticularMonthly summitParticular : summitParticulars) {
                    String timeLineString = summitParticular.timeLine.substring(0, 10); 
                    Date timeLine = Date.valueOf(timeLineString); 
                    smt_Summit_Particular_Month__c particular = new smt_Summit_Particular_Month__c();
                    particular.Name = summitParticular.Name;
                    particular.smt_Timeline__c = timeLine;                    
                    particular.smt_Target__c = isDecimal(summitParticular.target) ? Decimal.valueOf(summitParticular.target) : 0;                  
                    particular.smt_Target_Text__c = summitParticular.targetText;
                    particular.smt_Is_Evidence_Applicable__c = summitParticular.isEvidenceApplicable;
                    particular.smt_Is_Target_Applicable__c	= summitParticular.isTargetApplicable;
                    particular.smt_Summit_Section__c = summitSectionId;
                    particular.Summit_Particular__c = summitParticularId;
					particular.smt_Comments__c = summitParticular.commentText;                    
                    particularsToCreate.add(particular);                   
                }
                
                if (!particularsToCreate.isEmpty()) {
                    insert particularsToCreate;                 
                    updateSumTargetAchieved(summitSectionId, summitParticularId);
                }
            }else{
                throw new SecurityException('You do not have permission to create Summit Particular records.');
            }  
           
        } catch (Exception e) {
            throw new AuraHandledException('Error creating Summit Section records: ' + e.getMessage());
        }
    }   
 
    
    @AuraEnabled
    public static void updateAllSummitParticularMonthly(String jsonData){
        try{
            if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
                FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {  
            
                    JsonToSummitParticularMonthly obj = new JsonToSummitParticularMonthly();
                    List<JsonToSummitParticularMonthly> summitParticulars = obj.parse(jsonData);
                    List<smt_Summit_Particular_Month__c> summitParticularsToUpdate = new List<smt_Summit_Particular_Month__c>();              
            		String summitSectionId;
                    String summitParticularId;
            		Boolean allUpdatesSuccessful = true;
            		System.debug('Before Update JSON data : '+summitParticulars);
                    
                    for(JsonToSummitParticularMonthly summitParticular : summitParticulars){
                        String timeLineString = summitParticular.timeLine.substring(0, 10); 
                      	Date timeLine = Date.valueOf(timeLineString);                       
                        smt_Summit_Particular_Month__c particular =                            
                            new smt_Summit_Particular_Month__c(Id = summitParticular.id);
                        particular.Name = summitParticular.Name;
                        particular.smt_Timeline__c = timeLine;                   
                       	particular.smt_Target__c = isDecimal(summitParticular.target) ? Decimal.valueOf(summitParticular.target) : 0;
                        particular.smt_Target_Text__c = summitParticular.targetText;
                        particular.smt_Is_Evidence_Applicable__c = summitParticular.isEvidenceApplicable;
                        particular.smt_Is_Target_Applicable__c	= summitParticular.isTargetApplicable;	
                        particular.smt_Comments__c = summitParticular.commentText;
                        summitParticularsToUpdate.add(particular);                     
                        summitSectionId = summitParticular.summitSectionId;
                        summitParticularId = summitParticular.summitParticularId;
                    }                   
                    
                    // Update AS USER summitParticularsToUpdate;                  
            		
            		// Perform the update and capture the result using Database.update
                    Database.SaveResult[] updateResults = Database.update(summitParticularsToUpdate, false);
            	
                        for (Database.SaveResult result : updateResults) {
                            if (!result.isSuccess()) {
                                allUpdatesSuccessful = false;
                                System.debug('Error updating record in updateAllSummitParticularMonthly: ' + result.getErrors()[0].getMessage());
                            }
                        }            
                        if (allUpdatesSuccessful) {
                            updateSumTargetAchieved(summitSectionId, summitParticularId);
                        } else {
                            System.debug('In updateSumTargetAchieved () Some records failed to update.');
                        }
                 }else{
                    	throw new SecurityException('You do not have permission to Update Summit Particular records.');
                } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
   
    @AuraEnabled(cacheable = true)
    public static List<smt_Summit_Particular_Month__c> getMonthlySummitParticulars(String summitSectionId, String semester,String summitParticularId){        
        if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
            FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) { 
       			 return [SELECT Id, Name, smt_Achieved__c, smt_Target__c, smt_Target_Text__c, smt_Timeline__c, smt_Percentage_Achieved__c,
                        smt_Is_Evidence_Applicable__c ,smt_Is_Target_Applicable__c, smt_Evidence_To_Be_Attached__c, 
                        smt_Actual_Percentage_Achieved__c,smt_Comments__c
                        FROM smt_Summit_Particular_Month__c
                        WHERE (smt_Is_Evidence_Applicable__c = TRUE 
                               OR smt_Is_Target_Applicable__c =  TRUE)AND 
                               smt_Summit_Section__c=:summitSectionId AND Summit_Particular__c =: summitParticularId AND 
                               (NOT Name LIKE '%OS') AND (NOT Name LIKE '%Odd')
                        WITH USER_MODE
                        ORDER BY Name ASC];
                }else{
                return new List<smt_Summit_Particular_Month__c>();
         } 
    }
    
    @AuraEnabled
    public static void updateMonthlySummitParticular(String jsonData, String summitSectionId, String summitParticularId){
        try{
           if (FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
                FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) { 
                    JsonToUpdateSummitParticularMonthly obj = new JsonToUpdateSummitParticularMonthly();
                    obj = obj.parse(jsonData);
                    
                    smt_Summit_Particular_Month__c particular = new smt_Summit_Particular_Month__c(Id = obj.Id);
                    particular.smt_Achieved__c = isDecimal(obj.achievedValue) ? Decimal.valueOf(obj.achievedValue) : 0;
                    particular.smt_Evidence_To_Be_Attached__c = obj.evidenceValue;      
                    particular.smt_Comments__c = obj.commentText;
                    Update AS USER particular;  		
            		updateSumTargetAchieved(summitSectionId, summitParticularId);
               }else{
                    throw new SecurityException('You do not have permission to Update Summit Particular records.');
                }  
            
        } catch (Exception e) {            
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void updateSumTargetAchieved(String summitSectionId, String summitParticularId){
       		try {
                if(FeatureManagement.checkPermission('smt_Summit_Tracker_School_Head_Permission') ||
                	 FeatureManagement.checkPermission('smt_Summit_Tracker_Admin_Permission')) {                    
                       List<smt_Summit_Particular__c> targetParticularsToUpdate = new List<smt_Summit_Particular__c>();           
                       AggregateResult[] results = [SELECT SUM(smt_Achieved__c) totalAchieved, SUM(smt_Target__c) totalTarget FROM smt_Summit_Particular_Month__c WHERE Summit_Particular__c = :summitParticularId AND smt_Summit_Section__c =: summitSectionId];
                       Decimal totalAchieved = (Decimal)results[0].get('totalAchieved');
                       Decimal totalTarget = (Decimal)results[0].get('totalTarget');                      
                        if(totalAchieved > 0 || totalTarget > 0){
                            smt_Summit_Particular__c particular = [SELECT Id, smt_Target__c,smt_Achieved__c FROM smt_Summit_Particular__c WHERE Id = :summitParticularId AND smt_Summit_Section__c =: summitSectionId LIMIT 1];
                            particular.smt_Target__c = totalTarget;
                            particular.smt_Achieved__c = totalAchieved;               
                            targetParticularsToUpdate.add(particular);
                            Update targetParticularsToUpdate;                           
                        }
                    }else{
                        throw new SecurityException('You do not have permission to Update Summit Particular records.'); 
                     }           
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /************************ Month wise implementation of particulars END **********************/  
    
    /************************ Individual Summit implementation Start ************************/  
    
   /*  @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        return [
            SELECT Id, Name
            FROM Contact
            ORDER BY Name            
        ]; // LIMIT 100
    }
    
    public static String createIndividualTarget(List<IndividualTargetWrapper> individualTargetList) {
        
        List<smt_Summit_Particular_Individual__c> recordsToInsert = new List<smt_Summit_Particular_Individual__c>();
        
        List<String> schoolList = getAccountIdBasedOnSchoolName();        
        if(schoolList != null) {
            String schoolId = schoolList[0].split('##')[0];
            if(schoolId != null) {
            	List<smt_Summit_Tracker__c> smt_TrackerList = [SELECT smt_Year__c
                                                                FROM smt_Summit_Tracker__c
                                                                WHERE smt_School__c =: schoolId
                                                                AND smt_Is_Active__c = true 
                                                                ORDER BY smt_Year__c DESC LIMIT 1];
                Decimal currentSummitYear = smt_TrackerList[0].smt_Year__c;
                
                for(IndividualTargetWrapper wrapper : individualTargetList){
                    smt_Summit_Particular_Individual__c smt_Individual_record = new smt_Summit_Particular_Individual__c(
                    	Account__c = schoolId, 
                        Contact__c = wrapper.contactId, // dynamic
                        Summit_year__c = currentSummitYear, 
                        Month_Name__c = wrapper.monthName, // dynamic                       
                        Summit_Particular_Month__c = wrapper.monthId, // dynamic
                        Target__c = wrapper.target, // dynamic
                        Achieved__c = wrapper.achieved, // dynamic
                        Summit_Section__c = wrapper.sectionId, // dynamic
                        Summit_Particular__c = wrapper.particularId // dynamic
                    //    Team_Lead__c = wrapper.teamLeadContactId // formaula field
                    );
                     recordsToInsert.add(smt_Individual_record);
                }
                
                 if (!recordsToInsert.isEmpty()) {
                    // INSERT
                     insert recordsToInsert;
                 }                
            }
				            
        }
        else{
            throw new SecurityException('You do not have permission to Insert Summit Individual records.'); 
        }
        return '';
    }
    
    //@AuraEnabled(cacheable=true)
    public static List<String> getAccountIdBasedOnSchoolName() {
       User currentUser = [SELECT Department FROM User WHERE Id = :UserInfo.getUserId() AND Profile.Name = 'School Director' LIMIT 1];
            if (currentUser.Department != null) {
                List<String> schoolId = new List<String>();
                for (Account acc : [SELECT Id, Name FROM Account WHERE Name = :currentUser.Department LIMIT 1]) {
                    schoolId.add(acc.Id + '##' + acc.Name);
                }
                return schoolId;
            }
       return null;     
    }    */
    
    /************************ Individual Summit implementation End **************************/
    
    @AuraEnabled(cacheable=true)
     public static List<Account> searchAccounts(String searchKey, String departmentType) {
    
        if (String.isBlank(searchKey)) {
            return new List<Account>();
        }
    
       if (departmentType == 'NON_ACADEMIC') {
            return [
                SELECT Id, Name
                FROM Account
                WHERE Name LIKE :('%' + searchKey + '%')
                AND Parent.Name = 'Administrative Services'
                AND RecordType.Name = 'University Department'
                ORDER BY Name
                LIMIT 10
            ];
        } else {        
            
            // Query 1
            List<Account> result = [
                SELECT Id, Name
                FROM Account
                WHERE Name LIKE :('%' + searchKey + '%')
                AND Parent.Name != 'Administrative Services'
                AND RecordType.Name = 'University Department'
                ORDER BY Name
                LIMIT 10
            ];
            
            // If Query 1 returns records, return them
            if(!result.isEmpty()){
                return result;
            }
            
            // Query 2 (Executed only if Query 1 returns no rows)     
            
            List<String> allowedPrograms = new List<String>{
                'Bachelor of Science in Bioinformatics, Statistics and Computer Science',
                'Bachelor of Science in Mathematics, Statistics, and Computer Science',
                'Bachelor of Science in Physics, Mathematics, and Computer Science',
                'Bachelor of Science in-Physics, Chemistry, and Mathematics',
                'Bachelor of Science (Hons.) in Sports and Exercise Science'
            };
            
            result = [
                SELECT Id, Name
                FROM Account
                WHERE RecordType.Name = 'Academic Program'
                AND Parent.Name != 'Administrative Services'
                AND Name IN :allowedPrograms
                AND Name LIKE :('%' + searchKey + '%')
                ORDER BY Name
                LIMIT 10
            ];
            
            return result;
        }
     }  
        
    public class JsonToSummitSection {
        
        public Integer id;
        public String sectionName;
        public Integer weightage;
        
        
        public List<JsonToSummitSection> parse(String json) {
            return (List<JsonToSummitSection>) System.JSON.deserialize(json, List<JsonToSummitSection>.class);
        }
    }
    public class JsonToSummitParticular {
        
        public Integer id;
        public String summitParticularName;
        public String summitParticularId;
        public String timeline;
        public Integer target;
        public String targetText;
        public Boolean isTargetApplicable;
        public Boolean isEvidenceApplicable;
        
        
        public List<JsonToSummitParticular> parse(String json) {
            return (List<JsonToSummitParticular>) System.JSON.deserialize(json, List<JsonToSummitParticular>.class);
        }
    }
    
    public class JsonToSummitParticularMonthly {
        
        public String id;
        public String Name;
        public String summitParticularId;
        public String summitSectionId;
        public String timeline;
        public String target;
        public String targetText;
        public Boolean isTargetApplicable;
        public Boolean isEvidenceApplicable;
		public String commentText;        
        
        public List<JsonToSummitParticularMonthly> parse(String json) {
            return (List<JsonToSummitParticularMonthly>) System.JSON.deserialize(json, List<JsonToSummitParticularMonthly>.class);
        }
    }
    
    public class JsonToUpdateSummitParticular {
        
        public String id;
        public String achievedValue;
        public String evidenceValue;
        
        public JsonToUpdateSummitParticular parse(String json) {
            return (JsonToUpdateSummitParticular) System.JSON.deserialize(json, JsonToUpdateSummitParticular.class);
        }
    }
    
    public class JsonToUpdateSummitParticularMonthly {
        
        public String id;
        public String achievedValue;
        public String evidenceValue;
        public String commentText;
        
        public JsonToUpdateSummitParticularMonthly parse(String json) {
            return (JsonToUpdateSummitParticularMonthly) System.JSON.deserialize(json, JsonToUpdateSummitParticularMonthly.class);
        }
    }
    
   /* 
    public class IndividualTargetWrapper {
     //   @AuraEnabled public String accountId { get; set; }
     //   @AuraEnabled public Decimal summitYear { get; set; }
        @AuraEnabled public String contactId { get; set; }
        @AuraEnabled public String monthName { get; set; }
        @AuraEnabled public String monthId { get; set; }
        @AuraEnabled public Decimal target { get; set; }
        @AuraEnabled public Decimal achieved { get; set; }
   //     @AuraEnabled public String teamLeadContactId { get; set; }
        @AuraEnabled public String sectionId { get; set; }
        @AuraEnabled public String particularId { get; set; }        
    } 
*/
}