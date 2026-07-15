public with sharing class KnowlarityUtils {
    
    @AuraEnabled(cacheable=true)
    public static List<CallTarget> getCallList(String ownerId, String buttonType) {
      List<CallTarget> callTargetList = new List<CallTarget>();
      List<CallTarget> paidCallTargetList = new List<CallTarget>();
      List<CallTarget> unpaidCallTargetList = new List<CallTarget>();
      Id applicantRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();

      for (Lead l : [select id, name, Status, Applicant_Score__c from Lead 
                      where MobilePhone != null 
                        and IsConverted = FALSE and OwnerId =:ownerId 
                        and lastActivityDate = null 
                        order by Applicant_Score__c desc 
                        ]) {

        CallTarget ct = new CallTarget(l.Id, l.Name, l.getSObjectType().getDescribe().getName() , l.Applicant_Score__C, l.Status);
        callTargetList.add(ct);
      }

      for (Contact c : [select id, name, Application_Fee_Paid__c,Applicant_Score__c from Contact 
                        where OwnerId =:ownerId and recordTypeId =:applicantRecordTypeID order by Applicant_Score__c desc]) {
          String conStatus ='Unpaid';
          if(c.Application_Fee_Paid__c == true){
            conStatus = 'Paid';
            CallTarget ct = new CallTarget(c.Id, c.Name, c.getSObjectType().getDescribe().getName(), c.Applicant_Score__c, conStatus);
            paidCallTargetList.add(ct);
            callTargetList.add(ct);
          } else{
            CallTarget ct = new CallTarget(c.Id, c.Name, c.getSObjectType().getDescribe().getName(), c.Applicant_Score__c, conStatus);
            unpaidCallTargetList.add(ct);
            callTargetList.add(ct);
          }         
    }
      if(buttonType == 'Paid'){
        return paidCallTargetList;
      }else if (buttonType =='Unpaid'){
        return unPaidCallTargetList;
      }else
      return (callTargetList);
    }

    public class CallTarget {
      @AuraEnabled
      public Id recordId {get; set;}
      @AuraEnabled
      public String name {get; set;}
      @AuraEnabled
      public String objType {get; set;}
      @AuraEnabled
      public Decimal score {get; set;}
      @AuraEnabled 
      public String remarks {get; set;}

      public CallTarget(Id recordId, String name, String objType, Decimal score, String remarks) {
        this.recordId = recordId;
        this.name = name;
        this.objType = objType;
        this.score = score;
        this.remarks = remarks;
      }
    }
}