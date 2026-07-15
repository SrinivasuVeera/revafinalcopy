global class StudentFeeNotifyBatchSchedule_FY implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    global Date currentDate;
    global static String jobName, CronExp;
    global static Integer i = 0;
    
    global static List<String> contIdList = new List<String>(); 
    global Set<String> semProgramBatch = new Set<String>();    
    global List<String> contactRecordIds { get; set; }
    
    global StudentFeeNotifyBatchSchedule_FY(){}
    
    global StudentFeeNotifyBatchSchedule_FY(List<String> contactIds){
        this.contactRecordIds = contactIds;
    }
    String studentRecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Student').getRecordTypeId();

    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        System.debug('start method FY');      
        
        String query = 'SELECT Id, hed__Start_Date__c, Program_Batch__c,'
                                       +' Term_Number__c, Days_Remaining_To_Start__c'
                                       +' FROM hed__term__c '
                                       +' WHERE hed__Start_Date__c != null'
                                       +' AND hed__Start_Date__c = THIS_YEAR AND hed__Start_Date__c = THIS_MONTH'
                                       +' AND Term_Number__c = 1 AND Days_Remaining_To_Start__c = 0';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<hed__term__c> semesters) {
        
        System.debug('execute method ' + semesters);
        for(hed__term__c sem : semesters){
            semProgramBatch.add(sem.Program_Batch__c);
        }
        
        String contactQuery = 'SELECT Id, Name, Program_Batch__c'
            +' FROM Contact'
            +' WHERE Program_Batch__c != null AND Program_Batch__c IN : semProgramBatch'
            +' AND RecordTypeId =: studentRecordTypeID AND Active__c = true'
            +' AND Student_Status__c = \'Pursuing\'';
        
        List<Contact> contactList = Database.query(contactQuery);
        
        System.debug('contactList=> ' + contactList);
        System.debug('contactList SIZE=> ' + contactList.size());
        
        for(Contact cont : contactList){
            currentDate = Date.Today();
            for(hed__term__c sem : semesters){
                if(sem.hed__Start_Date__c == currentDate){
                     contIdList.add(cont.Id);
                     CronExp = '0 10 9 ' + currentDate.day() + ' ' + currentDate.month() + ' ? ' + currentDate.year();
                     jobName = 'First Fee Reminder For First Year' + ' # ' + system.now();
                }
                
            }
        }
         System.debug('contIdList SIZE=> ' + contIdList.size());
        if(CronExp != null)
        	System.schedule(jobName, CronExp , new StudentFeeNotifyBatchSchedule_FY(contIdList));
        
    }
    
    global void finish(Database.BatchableContext bc) {
                System.debug('finish method FY');   
                System.debug('contIdList SIZE=> ' + contIdList.size());
    }  
        
    public void execute(SchedulableContext SC){
        if(!Test.isRunningTest()){
            Database.executeBatch(new StudentFeeNotifyBatchSchedule_FY());
            Database.executeBatch(new StudentFeeNotificationBatch(contactRecordIds)); 
        }
    }
}