public without sharing class TT_AllocationReplicationCls  implements Database.Batchable<sObject>{
    public Id facId;
    public Set<Id> programIdSet = new Set<Id>();
    
    public TT_AllocationReplicationCls(Id facultyId){
        facId = facultyId;
        //This query returns program records (Acadamic programs) as a child records
        for(Account acc: [SELECT Id, Name, (SELECT Id, Name FROM ChildAccounts) 
                          FROM account 
                          WHERE parentId =:facultyId])
        {
            if(acc.ChildAccounts.size()>0){
                for(account childAcc: acc.ChildAccounts) {
                    programIdSet.add(childAcc.Id);
                }  
            }         
        }
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        // get Sections based on acadamic programs
        return database.getQueryLocator([SELECT Id, Name,hed__Parent_Term__r.hed__Start_Date__c,hed__Parent_Term__r.hed__End_Date__c,hed__Parent_Term__r.IA_1_Start_date__c,
                                         hed__Account__c,hed__Parent_Term__r.IA_1_End_date__c,hed__Parent_Term__r.IA_2_Start_date__c,hed__Parent_Term__r.IA_2_End_date__c 
                                         FROM hed__Term__c 
                                         WHERE hed__Account__c IN :programIdSet
                                         AND RecordType.DeveloperName = 'Sections'
                                         AND hed__Parent_Term__r.Active__c = true
                                        ]);
    }
    public void execute(Database.BatchableContext BC, List<hed__Term__c> scope){
        hed__Term__c section = scope[0];
        Set<Id> courseId = new Set<Id>();
        Map<Id, List<Id>> mp_UnitIds = new Map<Id, List<Id>>();
        Map<Id, Integer> mp_CountOfCourse = new Map<Id, Integer>();
        List<hed__Course_Offering_Schedule__c> cosList = new List<hed__Course_Offering_Schedule__c>();
        Integer dateDiffCount  = section.hed__Parent_Term__r.hed__Start_Date__c.daysBetween(section.hed__Parent_Term__r.hed__End_Date__c);
        Map<String,List<hed__Course_Offering_Schedule__c>> dayAndCOSMap = new Map<String,List<hed__Course_Offering_Schedule__c>>();
        for(hed__Course_Offering_Schedule__c cosObj : [SELECT id,hed__End_Time__c,hed__Start_Time__c,hed__Time_Block__c,Batch_Group__c,Break__c,Display_Name__c,
                                                       hed__Monday__c, hed__Tuesday__c,hed__Wednesday__c,Section__c,hed__Course_Offering__c, hed__Course_Offering__r.Semester_Course_offering__c,
                                                       hed__Thursday__c, hed__Friday__c, hed__Saturday__c, hed__Sunday__c,hed__Facility__c,School_Head__c,Teaching_Method__c
                                                       FROM hed__Course_Offering_Schedule__c WHERE Section__c =: section.Id and Date__c = null ])
        {
            String keyStr = cosObj.hed__Monday__c ? 'monday' : 
            cosObj.hed__Tuesday__c ? 'tuesday' :
            cosObj.hed__Wednesday__c ? 'wednesday' :
            cosObj.hed__Thursday__c ? 'thursday' :
            cosObj.hed__Friday__c ? 'friday' : 
            cosObj.hed__Saturday__c ? 'saturday' : 
            cosObj.hed__Sunday__c ? 'sunday' : 'NONE';
            if(dayAndCOSMap.get(keyStr) == null)
                dayAndCOSMap.put(keyStr, new List<hed__Course_Offering_Schedule__c>{cosObj});			
            else
                dayAndCOSMap.get(keyStr).add(cosObj);	
            courseId.add(cosObj.hed__Course_Offering__r.Semester_Course_offering__c);  
            mp_CountOfCourse.put(cosObj.hed__Course_Offering__r.Semester_Course_offering__c,0);
        }
        if(courseId.size() > 0 ) mp_UnitIds = getCoursePlanDetails(courseId);
      
        for(Integer i=0; i < dateDiffCount; i++){
            Date thedate = section.hed__Parent_Term__r.hed__Start_Date__c.addDays(i);
            DateTime dt = DateTime.newInstance(thedate, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = dt.format('EEEE');
            
            if((thedate >= section.hed__Parent_Term__r.IA_1_Start_date__c && thedate <= section.hed__Parent_Term__r.IA_1_End_date__c) ||
               (thedate >= section.hed__Parent_Term__r.IA_2_Start_date__c && thedate <= section.hed__Parent_Term__r.IA_2_End_date__c))
            {   
            }            
            else if(dayAndCOSMap.get(dayOfWeek.toLowerCase()) != null) {
                for(hed__Course_Offering_Schedule__c cosObj :dayAndCOSMap.get(dayOfWeek.toLowerCase()) ){
                    hed__Course_Offering_Schedule__c cos = new hed__Course_Offering_Schedule__c();
                    cos =cosObj.clone(false,false,false,false);
                    cos.Id = null;
                    cos.Date__c =  thedate;
                    cos.Status__c = 'Scheduled';
                    cos.CO_Schedule_Parent__c = cosObj.Id;                    
                    Integer topicCount = mp_CountOfCourse.get(cosObj.hed__Course_Offering__r.Semester_Course_offering__c);
                  
                    if(mp_UnitIds.get(cosObj.hed__Course_Offering__r.Semester_Course_offering__c) != null &&
                    mp_UnitIds.get(cosObj.hed__Course_Offering__r.Semester_Course_offering__c).size() > topicCount ) {
                        cos.Planned_Topic__c = mp_UnitIds.get(cosObj.hed__Course_Offering__r.Semester_Course_offering__c)[topicCount];
                        mp_CountOfCourse.put(cosObj.hed__Course_Offering__r.Semester_Course_offering__c, topicCount+1); 
                    }
                    cosList.add(cos);
                }
            }
        }        
        If(!cosList.isEmpty())
            insert cosList;        
    }
    
    public void finish(Database.BatchableContext BC){ }
    
    public Map<Id, List<Id>> getCoursePlanDetails(Set<Id> courseIds){
        Map<Id, List<Id>> mp_Ids = new Map<Id, List<Id>>();
        List<Course_Plan_Unit__c> lst_Unit = [SELECT Id, Course_Offering__c, (SELECT Id FROM Course_Plan_Topics__r ORDER BY Sequence_No__c)
                                              FROM Course_Plan_Unit__c 
                                              WHERE Course_Offering__c in: courseIds
                                              ORDER BY Sequence_No__c];
        for(Course_Plan_Unit__c eachUnit : lst_Unit) {
            if(mp_Ids.get(eachUnit.Course_Offering__c) == null)
            mp_Ids.put(eachUnit.Course_Offering__c, new List<Id>());
            for(Course_Plan_Topic__c eachTopic : eachUnit.Course_Plan_Topics__r) {
                mp_Ids.get(eachUnit.Course_Offering__c).add(eachTopic.Id);
            }
        }
        return mp_Ids;
    }
}