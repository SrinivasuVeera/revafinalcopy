public without Sharing class ASM_UpdateCourseConnectionBatch implements Database.Batchable<sObject>,Database.Stateful,System.Schedulable
{
    public void execute(System.SchedulableContext sc){
        ASM_UpdateCourseConnectionBatch bh = new ASM_UpdateCourseConnectionBatch();
        Database.executeBatch(bh);
    }
   
    public Database.QueryLocator start(Database.BatchableContext BC){
        date todayDt = system.today();
        //system.debug('+++++'+todayDt);
        String query = 'SELECT id,Name,Section__c,hed__Course_Offering__c,hed__Course_Offering__r.Name,Active_Section_ID__c,Section_change_date__c,';
        query += 'Course_Offering_Section_ID__c,Course_Category__c FROM hed__Course_Enrollment__c WHERE Section_change_date__c =: todayDt AND Active_Section_ID__c != Null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<hed__Course_Enrollment__c> scope){
        //system.debug('+++++'+scope);
        //system.debug('+++++'+scope.size());
        string sectionRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        set<string> sectionIds = new set<string>();
        set<string> courseNames = new set<string>();
        list<hed__Course_Enrollment__c> lstCC = new list<hed__Course_Enrollment__c>();
       
        for(hed__Course_Enrollment__c co : scope){
            courseNames.add(co.Active_Section_ID__c+co.hed__Course_Offering__r.Name);
            sectionIds.add(co.Active_Section_ID__c);
        }
        //system.debug('+++++'+courseNames);
        map<string,hed__Course_Offering__c> mapCo = new map<string,hed__Course_Offering__c>();
        for(hed__Course_Offering__c co : [SELECT id,Name,hed__Term__c,hed__Course__c,hed__Course__r.Name,Category__c,Course_Offering_Category__c FROM hed__Course_Offering__c
                                          WHERE Course_Offering_Category__c =: courseNames AND hed__Term__c =: sectionIds]){
            mapCo.put(String.valueOf(co.hed__Term__c).substring(0, 15)+co.Name,co);            
        }
        //system.debug('+++++'+mapCo.keyset());
        for(hed__Course_Enrollment__c co : scope){
            if(mapCo.containsKey(co.Active_Section_ID__c+co.hed__Course_Offering__r.Name)){
                co.Course_Offering_Section_ID__c = mapCo.get(co.Active_Section_ID__c+co.hed__Course_Offering__r.Name).id;
                lstCC.add(co);
            }
        }
        //system.debug('+++++'+lstCC.size());
        if(lstCC.size() > 0){
            update lstCC;
        }
        
       
    }
   
    public void finish(Database.BatchableContext BC){
    BatchClass_Utility.sendBatchClassFailureMail('Assessment Module', BC.getJobId(), 'Update Course Connection','Course Connection');
    }
}