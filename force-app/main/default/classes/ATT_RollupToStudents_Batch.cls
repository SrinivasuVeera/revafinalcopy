public class ATT_RollupToStudents_Batch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM hed__Course_Offering__c WHERE Course_Offering_Active__c = true');
    }
    
    public void execute(Database.BatchableContext BC, List<hed__Course_Offering__c> scope){
        List<hed__Course_Enrollment__c> lst_ConForUpdate = new List<hed__Course_Enrollment__c>();
        Map<String, Integer> mp_AttCount = new Map<String, Integer>();
        Set<String> stuIds = new Set<String>();
        Integer classesCompleted = 0;
        List<hed__Attendance_Event__c> checkAtt = [SELECT Id FROM hed__Attendance_Event__c 
                                                   WHERE Course_Offering_Schedule__r.hed__Course_Offering__c =: scope[0].Id]; 
                                                   //and LastModifiedDate = TODAY LIMIT 10];
        if(checkAtt != null && checkAtt.size() > 0){
            Integer completedClasses = [SELECT Count() FROM hed__Course_Offering_Schedule__c
                                       WHERE hed__Course_Offering__c =:scope[0].Id and 
                                        Status__c in ('Completed / Attendance Marked', 'Locked')]; 
            
            AggregateResult[] groupedResults = [SELECT COUNT(Id) cnt,hed__Course_Connection__c conn,hed__Attendance_Type__c att  
                                                FROM hed__Attendance_Event__c  
                                                WHERE Course_Offering_Schedule__r.hed__Course_Offering__c =: scope[0].Id 
                                                GROUP BY hed__Course_Connection__c, hed__Attendance_Type__c
                                               ];
            for(AggregateResult eachStu : groupedResults) {
                mp_AttCount.put(String.valueof(eachStu.get('conn'))+String.valueof(eachStu.get('att')),Integer.valueof(eachStu.get('cnt'))); 
                stuIds.add(String.valueof(eachStu.get('conn')));
            }
            system.debug(stuIds);
            for(String eachStu : stuIds) {   
                Integer abs = mp_AttCount.get(eachStu+'Absent') == null? 0 : mp_AttCount.get(eachStu+'Absent');
                Integer pre = mp_AttCount.get(eachStu+'Present') == null? 0 : mp_AttCount.get(eachStu+'Present');
                if(eachStu != null){
                 lst_ConForUpdate.add(new hed__Course_Enrollment__c(Id = eachStu,
                                                                   Total_Classes_Attended__c = pre,
                                                                   Total_Classes_Completed__c = pre+abs));
                }     
            }
            if(lst_ConForUpdate.size() > 0) {
                update lst_ConForUpdate;
                update new hed__Course_Offering__c(Id=scope[0].Id, Total_Classes_Completed__c = completedClasses);
            }             
        }
  
    }
    
    public void finish(Database.BatchableContext BC){
    }
}