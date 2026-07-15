public class ALU_SummaryRollUpCmp_Ctrl 
{
    @AuraEnabled
    public static UserwrapperClass getMethod1()
    {
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
        Id Alumni_Activities_Achievements_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Achievements').getRecordTypeId();
        Id Alumni_Activities_Job_Posting_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Job Posting').getRecordTypeId();
        Id Alumni_Activities_Job_Seeking_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Job Seeking').getRecordTypeId();
        Id Alumni_Activities_Fund_Raising_Request_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Fund Raising Request').getRecordTypeId();
        UserwrapperClass objuserWraper = new UserwrapperClass();
        objuserWraper.lst_User = [SELECT id, Name, Profile.Name, ProfileId FROM user WHERE Profile.Name =: 'Alumni Portal'  AND IsActive =:true];
        objuserWraper.headermsg='Alumni Information';
        
        objuserWraper.userCount=objuserWraper.lst_User.size();
        objuserWraper.totalAchievers=0;
        objuserWraper.totalFutureEvents =0;
        objuserWraper.totalLiveEvents =0;
        objuserWraper.totalJobOpenings =0;
        objuserWraper.totalJobRequirements =0;
        objuserWraper.totalActivities=0;
        for(Alumni_Activities__c objAluActive : [SELECT id, Event_Name__c, Date__c, Approved_by_Admin__c, RecordTypeId  From Alumni_Activities__c])
        {
            if(objAluActive.RecordTypeId == Alumni_Activities_Achievements_RecType && objAluActive.Approved_by_Admin__c == true )
            {
                objuserWraper.totalAchievers = objuserWraper.totalAchievers+1;
            }
            if(objAluActive.RecordTypeId == Alumni_Activities_Event_RecType && objAluActive.Date__c >=  system.today() && objAluActive.Approved_by_Admin__c == true )
            {
                objuserWraper.totalFutureEvents = objuserWraper.totalFutureEvents+1;
            }
            if(objAluActive.RecordTypeId == Alumni_Activities_Event_RecType && objAluActive.Date__c == system.today() && objAluActive.Approved_by_Admin__c == true  )
            {
                objuserWraper.totalLiveEvents = objuserWraper.totalLiveEvents+1;
            }
            if(objAluActive.RecordTypeId == Alumni_Activities_Job_Posting_RecType && objAluActive.Approved_by_Admin__c == true )
            {
                objuserWraper.totalJobOpenings = objuserWraper.totalJobOpenings+1;
            }
            if(objAluActive.RecordTypeId == Alumni_Activities_Job_Seeking_RecType && objAluActive.Approved_by_Admin__c == true )
            {
                objuserWraper.totalJobRequirements = objuserWraper.totalJobRequirements+1;
            }
            if(objAluActive.RecordTypeId == Alumni_Activities_Fund_Raising_Request_RecType && objAluActive.Approved_by_Admin__c == true )
            {
                objuserWraper.totalActivities = objuserWraper.totalActivities+1;
            }
        }
        objuserWraper.totalNumberMemberRegsted =0;
        for(Alumni_Event_Registrations__c objEventRegst : [SELECT id,Registration_Date_Time__c,Alumni_Activities_Event__c, Alumni_Activities_Event__r.Date__c FROM Alumni_Event_Registrations__c ])
        {
            if(objEventRegst.Alumni_Activities_Event__r.Date__c == system.today())
            {
                objuserWraper.totalNumberMemberRegsted = objuserWraper.totalNumberMemberRegsted+1;
            }
        }
        objuserWraper.totalNumberofPaymets =0;
        objuserWraper.totalAmount =0;
         for(Alumni_Payments__c objEventRegst : [SELECT id, Amount__c FROM Alumni_Payments__c WHERE Payment_Status__c = 'Success' ])
        {
            if(objEventRegst.Amount__c != null)
            {
                objuserWraper.totalNumberofPaymets = objuserWraper.totalNumberofPaymets+1;
                objuserWraper.totalAmount += objEventRegst.Amount__c;
            }
        }
        return objuserWraper;
    }
    
    public class UserwrapperClass
    {
        @auraEnabled public List<user> lst_User{get;set;}
        @auraEnabled public integer userCount{get;set;}
        @auraEnabled public string headermsg{get;set;}
        //@AuraEnabled public List<Alumni_Activities__c> lst_AluActiv{get;set;}
        @AuraEnabled public integer totalAchievers{get;set;}
        @AuraEnabled public integer totalFutureEvents{get;set;}
        @AuraEnabled public integer totalLiveEvents{get;set;}
        @AuraEnabled public integer totalJobOpenings{get;set;}
        @AuraEnabled public integer totalJobRequirements{get;set;}
        @AuraEnabled public integer totalActivities{get;set;}
        //@AuraEnabled public List<Alumni_Event_Registrations__c> lst_AluEventRegestrd{get;set;}
        @AuraEnabled public integer totalNumberMemberRegsted{get;set;}
        //@AuraEnabled public List<Alumni_Payments__c> lst_AluPayments{get;set;}
        @AuraEnabled public integer totalNumberofPaymets{get;set;}
        @AuraEnabled public Decimal totalAmount{get;set;}
    }
    
}