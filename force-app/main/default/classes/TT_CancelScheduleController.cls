public class TT_CancelScheduleController {
	@AuraEnabled
    public static List<String> getUniversityList(String nameStr){
        List<String> universityList =  new List<String>();
        Map<String, String> defult = new Map<String, String>();
        for(Account acc:[select id, Name from account where recordtype.developername = 'Educational_Institution' and name =:nameStr limit 1 ]){
            universityList.add( acc.Id+'##'+acc.Name);
        }
        if(FeatureManagement.checkPermission('Cancel_Schedule_Freeze_School')) {
           defult =  TT_CancelScheduleController.getDefaultValues();            
            universityList.add(defult.get('faculty'));
            universityList.add(defult.get('school'));
        }
        return universityList;
    }
    
    
    @AuraEnabled
    public static List<String> getAccountBasedOnParentIdList(Id parentId){
        List<String> facultyList =  new List<String>();
        for(Account acc:[select id, Name from account where parentId =:parentId]){
            facultyList.add(acc.Id+'##'+acc.Name);
        }
        return facultyList;
    }
    
    
    
    @AuraEnabled
    public static List<String> getProgramBatchList(Id programId){
        List<String> programBatchList =  new List<String>();
        for(hed__Program_Plan__c pp:[select id, Name from hed__Program_Plan__c where hed__Account__c =:programId]){
            programBatchList.add(pp.Id+'##'+pp.Name);
        }
        return programBatchList;
    }
    
    @AuraEnabled
    public static List<String> getSemesterList(Id programBId){
        List<String> semesterList =  new List<String>();
        for(hed__Term__c sem:[select id, Name from hed__Term__c where Program_Batch__c =:programBId]){
            semesterList.add(sem.Id+'##'+sem.Name);
        }
        return semesterList;
    }
    
    @AuraEnabled
    public static List<String> getSectionList(Id semesterId){
        List<String> sectionList =  new List<String>();
        for(hed__Term__c pp:[select id, Name from hed__Term__c where hed__Parent_Term__c =:semesterId and Recordtype.name='Sections']){
            sectionList.add(pp.Id+'##'+pp.Name);
        }
        return sectionList;
    }
    
    @AuraEnabled
    public static String onCancelSchedule(String cancelId, String cancelLevel, DateTime startDateTime, DateTime endDateTime, String reason){
       Date startDate = (startDateTime != null) ? date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day()) : null;
       Time startTime = (startDateTime != null) ? Time.newInstance(startDateTime.hour(), startDateTime.minute(), startDateTime.second(), 0) : null;
       Date endDate = (endDateTime != null) ? date.newinstance(endDateTime.year(), endDateTime.month(), endDateTime.day()) : null;
       Time endTime = (endDateTime != null) ? Time.newInstance(endDateTime.hour(), endDateTime.minute(), endDateTime.second(), 0) : null;
        
       String queryStr = 'SELECT Id,  Date__c, hed__End_Time__c, hed__Start_Time__c, hed__Course_Offering__c, School_head__r.name, Batch_Group__c,'+
           				 'CO_Schedule_Parent__c, Section__r.name, Status__c FROM hed__Course_Offering_Schedule__c where Date__c >='+String.valueOf(startDate)+
           				 ' and Date__c <= '+String.valueOf(endDate);
        
        if(CancelLevel == 'faculty') {
            queryStr += ' and hed__Course_Offering__r.hed__Term__r.hed__Account__r.parent.parentId  =\''+cancelId+'\'';
        }
        else if(CancelLevel == 'school') {
            queryStr += ' and hed__Course_Offering__r.hed__Term__r.hed__Account__r.parentId  =\''+cancelId+'\'';
        }
        else if(CancelLevel == 'program'){
            queryStr += ' and hed__Course_Offering__r.hed__Term__r.hed__Account__c  =\''+cancelId+'\'';
        }
        else if(CancelLevel == 'programBatch'){
            queryStr += ' and Section__r.hed__Parent_Term__r.Program_Batch__c  =\''+cancelId+'\'';
        }
        else if(CancelLevel == 'semester'){
            queryStr += ' and Section__r.hed__Parent_Term__c  =\''+cancelId+'\'';
        }
        else if(CancelLevel == 'section'){
            queryStr += ' and Section__c =\''+cancelId+'\'';
        }system.debug(queryStr);
        List<hed__Course_Offering_Schedule__c> cosList = new List<hed__Course_Offering_Schedule__c>();
        for(hed__Course_Offering_Schedule__c cos :dataBase.query(queryStr) ){
            if(cos.hed__Start_Time__c >= startTime && cos.hed__End_Time__c <= endTime){
                cos.Status__c = 'Cancelled';
                cosList.add(cos);
            }
                
        }
        if(!cosList.isEmpty()){
            try{
                update cosList;
            }
            catch(exception ex){
                throw new AuraException(ex.getMessage());
            }
        }
        Integer sizeOfRecords = cosList.size();
        
        if(sizeOfRecords > 0)
        {
            string Str_StartDateTime =  startDateTime.format('dd-MM-YYYY h:mm a');
            string Str_endDateTime =  endDateTime.format('dd-MM-YYYY h:mm a');
            system.debug('Reason===='+reason);
            TT_SendSMSWhenClassCancelled_Batch bc = new TT_SendSMSWhenClassCancelled_Batch(CancelLevel,cancelId,Str_StartDateTime,Str_endDateTime,reason);
            DataBase.executeBatch(bc,50);
        }
        return sizeOfRecords == 0 ? 'No class schedules found' :sizeOfRecords+' no of classes have been successfully Cancelled';
    }
	
    public static Map<String, String> getDefaultValues(){
        Map<String, String> returnVal = new Map<String, String>();
        List<String> sectionList =  new List<String>();
        try{
        Contact c = [SELECT id, AccountId,Account.Name,Account.ParentId, Account.Parent.Name from Contact Where OwnerId =: UserInfo.getUserId() limit 1];
        returnVal.put('school',c.AccountId +'##'+ c.Account.Name);
        returnVal.put('faculty',c.Account.ParentId +'##'+ c.Account.Parent.Name);
        }
        catch(Exception e) {
            system.debug('No Contacts exists');
        }
        return returnVal;
    }
    
}