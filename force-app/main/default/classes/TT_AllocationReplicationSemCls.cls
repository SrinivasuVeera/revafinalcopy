public without sharing class TT_AllocationReplicationSemCls  implements Database.Batchable<sObject>{
    public Id semesterId;
    public Set<Id> programIdSet = new Set<Id>();
    
    public TT_AllocationReplicationSemCls(Id semId){
        semesterId = semId;        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        // get Sections based on acadamic programs
        return database.getQueryLocator([SELECT Id, Name,hed__Parent_Term__r.Last_Replication_Date__c, hed__Parent_Term__r.hed__Start_Date__c,hed__Parent_Term__r.hed__End_Date__c,hed__Parent_Term__r.IA_1_Start_date__c,
                                         hed__Account__c,hed__Parent_Term__r.IA_1_End_date__c,hed__Parent_Term__r.IA_2_Start_date__c,hed__Parent_Term__r.IA_2_End_date__c 
                                         FROM hed__Term__c 
                                         WHERE RecordType.DeveloperName = 'Sections'
                                         AND hed__Parent_Term__r.Active__c = true
                                         AND hed__Parent_Term__c =: semesterId
                                        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<hed__Term__c> scope){
        hed__Term__c section = scope[0];
        Set<Id> courseId = new Set<Id>();
        Set<Id> offeringId = new Set<Id>();
        Map<Id, List<Id>> mp_UnitIds = new Map<Id, List<Id>>();
        Map<Id, String> mp_ProfIds = new Map<Id, String>();
        Map<Id, Integer> mp_CountOfCourse = new Map<Id, Integer>();
        List<hed__Course_Offering_Schedule__c> cosList = new List<hed__Course_Offering_Schedule__c>();
        Integer dateDiffCount  = section.hed__Parent_Term__r.hed__Start_Date__c.daysBetween(section.hed__Parent_Term__r.hed__End_Date__c);
        Map<String,List<hed__Course_Offering_Schedule__c>> dayAndCOSMap = new Map<String,List<hed__Course_Offering_Schedule__c>>();
        Set<Id> schIds= new Set<Id>();
        Id businessHrs = [select id,IsDefault,Name  from BusinessHours  WHERE Name = 'REVA Business Hours'].Id;
        for(hed__Course_Offering_Schedule__c updatedSch : [SELECT id,hed__End_Time__c,hed__Start_Time__c,hed__Time_Block__c,Batch_Group__c,Break__c,Display_Name__c,
                                                       hed__Monday__c, hed__Tuesday__c,hed__Wednesday__c,Section__c,hed__Course_Offering__c, hed__Course_Offering__r.Semester_Course_offering__c,
                                                       hed__Thursday__c, hed__Friday__c, hed__Saturday__c, hed__Sunday__c,hed__Facility__c,School_Head__c,Teaching_Method__c
                                                       FROM hed__Course_Offering_Schedule__c 
                                                       WHERE Section__c =: section.Id and Date__c = null and LastModifiedDate >: section.hed__Parent_Term__r.Last_Replication_Date__c])
        {
            schIds.add(updatedSch.Id);
        }
        if(schIds.size() > 0)
        DELETE [SELECT ID FROM hed__Course_Offering_Schedule__c WHERE Status__c = 'Scheduled' AND CO_Schedule_Parent__c in: schIds AND Date__c > TODAY];
        
        for(hed__Course_Offering_Schedule__c cosObj : [SELECT hed__Course_Offering__r.Semester_Course_offering__c,Actual_Topic__c,
                                                       Batch_Group__c,Break__c,Course_ID__c,Course_Offering_Section__c,
                                                       Course_Plan_Completed__c,CO_Schedule_Parent__c,Date__c,Display_Name__c,
                                                       Faculty_Course_Connection__c,Free_Slot__c,hed__Course_Offering__c,
                                                       hed__End_Time__c,hed__Facility__c,hed__Friday__c,hed__Monday__c,
                                                       hed__Saturday__c,hed__Start_Time__c,hed__Sunday__c,hed__Thursday__c,
                                                       hed__Time_Block__c,hed__Time_Block__r.hed__Educational_Institution__r.Parent.School_Head__c,hed__Tuesday__c,hed__Wednesday__c,IA_Date__c,Id,
                                                       Name,name__c,OwnerId,Planned_Topic__c,Professor__c,
                                                       Reason_for_not_completing__c,School_Head__c,Section__c,Slot__c,Status__c,
                                                       Teaching_Method__c
                                                       FROM hed__Course_Offering_Schedule__c 
                                                       WHERE Section__c =: section.Id and Date__c = null and LastModifiedDate >: section.hed__Parent_Term__r.Last_Replication_Date__c])
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
            offeringId.add(cosObj.hed__Course_Offering__c);
            mp_CountOfCourse.put(cosObj.hed__Course_Offering__r.Semester_Course_offering__c,0);
        }
        if(courseId.size() > 0 ) mp_UnitIds = getCoursePlanDetails(courseId);
        if(offeringId.size() > 0 ) mp_ProfIds = getProfDetails(offeringId);
        for(Integer i=0; i < dateDiffCount; i++){
            Date thedate = section.hed__Parent_Term__r.hed__Start_Date__c.addDays(i);
            DateTime dt = DateTime.newInstance(thedate, Time.newInstance(0, 0, 0, 0));
            
            String dayOfWeek = dt.format('EEEE');
            if((thedate >= section.hed__Parent_Term__r.IA_1_Start_date__c && thedate <= section.hed__Parent_Term__r.IA_1_End_date__c) ||
               (thedate >= section.hed__Parent_Term__r.IA_2_Start_date__c && thedate <= section.hed__Parent_Term__r.IA_2_End_date__c))
            {   
            }            
            else if((thedate > system.today() || section.hed__Parent_Term__r.Last_Replication_Date__c == null)  && dayAndCOSMap.get(dayOfWeek.toLowerCase()) != null) {
                for(hed__Course_Offering_Schedule__c cosObj :dayAndCOSMap.get(dayOfWeek.toLowerCase()) ){
                    DateTime dt1 = DateTime.newInstance(thedate, cosObj.hed__Start_Time__c);
                    system.debug(BusinessHours.isWithin(businessHrs, dt1));
                                 system.debug(dt1);
                    if(BusinessHours.isWithin(businessHrs, dt1)) {
                    hed__Course_Offering_Schedule__c cos = new hed__Course_Offering_Schedule__c();
                    cos =cosObj.clone(false,false,false,false);
                    cos.Id = null;
                    cos.Date__c =  thedate;
                    cos.Status__c = 'Scheduled';
                    cos.CO_Schedule_Parent__c = cosObj.Id;   
                    cos.School_Head__c = cosObj.hed__Time_Block__r.hed__Educational_Institution__r.Parent.School_Head__c;
                    Integer topicCount = mp_CountOfCourse.get(cosObj.hed__Course_Offering__r.Semester_Course_offering__c);
                    if(mp_ProfIds.get(cosObj.hed__Course_Offering__c) != null) {
                        system.debug( mp_ProfIds.get(cosObj.hed__Course_Offering__c));
                        cos.Faculty_Course_Connection__c = mp_ProfIds.get(cosObj.hed__Course_Offering__c).split('--')[1];
                        cos.OwnerId = mp_ProfIds.get(cosObj.hed__Course_Offering__c).split('--')[0];
                        cos.Professor__c =  mp_ProfIds.get(cosObj.hed__Course_Offering__c).split('--')[0];
                    }                      
                    if(mp_UnitIds.get(cosObj.hed__Course_Offering__r.Semester_Course_offering__c) != null &&
                    mp_UnitIds.get(cosObj.hed__Course_Offering__r.Semester_Course_offering__c).size() > topicCount ) {
                        cos.Planned_Topic__c = mp_UnitIds.get(cosObj.hed__Course_Offering__r.Semester_Course_offering__c)[topicCount];
                        mp_CountOfCourse.put(cosObj.hed__Course_Offering__r.Semester_Course_offering__c, topicCount+1); 
                    }
                    cosList.add(cos);
                    }
                }
            }            
        }        system.debug(cosList.size());
        If(!cosList.isEmpty())
            insert cosList;        
    }
    
    public void finish(Database.BatchableContext BC){system.debug('hi');
      hed__Term__c sem = [SELECT Id,Last_Replication_Date__c,Number_Of_Iterations__c FROM hed__Term__c WHERE Id =: semesterId];
        sem.Last_Replication_Date__c = system.today();
        if(sem.Number_Of_Iterations__c == null)  sem.Number_Of_Iterations__c = 1;
        else sem.Number_Of_Iterations__c += 1;
        update sem;
    }
    
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
    
    public Map<Id, String> getProfDetails(Set<Id> offerIds){
        Map<Id, String> mp_Prof = new Map<Id, String>();
        for(hed__Course_Enrollment__c con : [SELECT Id,hed__Contact__c,hed__Contact__r.OwnerId,hed__Course_Offering__c FROM hed__Course_Enrollment__c WHERE RecordType.Name = 'Faculty' and hed__Course_Offering__c != null and hed__Course_Offering__c in: offerIds ]) {
            mp_Prof.put(con.hed__Course_Offering__c, con.hed__Contact__r.OwnerId + '--' + con.Id);
        }
        return mp_Prof;
    }    
}