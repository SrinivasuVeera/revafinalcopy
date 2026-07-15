public without sharing class  ApplicationListController {

     
    @AuraEnabled(cacheable=true)
    public static AdmissionApplicationsWrapper getAdmissionApplications(){
        try{
            
      String myApplicationsFilterId=[SELECT Id FROM LISTVIEW  WHERE DeveloperName='Applications_ListView_exposed_on_ApplicantSite' LIMIT 1].Id;
      String contactId=[SELECT ContactId FROM User WHERE Id=:userInfo.getUserId() Limit 1].ContactId; 
      List<hed__Application__c>applicationList=[SELECT Id,Name,Application_Number__c,hed__Application_Status__c,randa__Application_Review_Status__c FROM hed__Application__c WHERE hed__Applicant__c=:contactId LIMIT 1];
        if(applicationList.size() == 0) {
            throw new Reva_CustomException('No applications submitted for current user !');
        }
            return new AdmissionApplicationsWrapper(myApplicationsFilterId, applicationList);
        }
        catch(Exception e){
           throw new Reva_CustomException('An Errror Occured '+e.getMessage());
        }
     
    }
    
    
	public class AdmissionApplicationsWrapper {
        
  @AuraEnabled
    public String myApplicationsFilterId;

    @AuraEnabled
    public List<hed__Application__c> applicationList;

    //Constructor
    public AdmissionApplicationsWrapper(String filterId, List<hed__Application__c> appList) {
        this.myApplicationsFilterId = filterId;
        this.applicationList = appList;
    }
}
}