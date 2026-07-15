global class StudentFeeNotifyBatchSchedule_HY_28P_NY implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    global Date currentDate, dt;
    global String CronExp, jobName;
    
    global List<String> contIdList = new List<String>();
    global Set<String> semProgramBatch = new Set<String>();    
    global List<String> contactRecordIds { get; set; }
    
    global StudentFeeNotifyBatchSchedule_HY_28P_NY(){}
    
    global StudentFeeNotifyBatchSchedule_HY_28P_NY(List<String> contactIds){
        this.contactRecordIds = contactIds;
    }
    
    String studentRecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Student').getRecordTypeId();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        
        String query = 'SELECT Id, hed__Start_Date__c, Program_Batch__c,'
                                       +' Term_Number__c, Days_Remaining_To_Start__c'
                                       +' FROM hed__term__c '
                                       +' WHERE hed__Start_Date__c != null'
                                       +' AND hed__Start_Date__c = NEXT_YEAR'
                                       +' AND (Term_Number__c = 3 OR Term_Number__c = 5 OR Term_Number__c = 7)';            						  

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
            +' AND (Active_Semester__r.Term_Number__c != 1 OR Active_Semester__r.Term_Number__c != 3 OR Active_Semester__r.Term_Number__c != 5 OR Active_Semester__r.Term_Number__c != 7)'
            +' AND Student_Status__c = \'Pursuing\'';
        
        List<Contact> contactList = Database.query(contactQuery);
        System.debug('contactList=> ' + contactList);
        System.debug('contactList SIZE=> ' + contactList.size());
        
        for(Contact cSem : contactList){
            currentDate = Date.Today();
            for(hed__term__c sem : semesters){
                if(cSem.Program_Batch__c == sem.Program_Batch__c){
                    if(currentDate.daysBetween(sem.hed__Start_Date__c) >100){
                        contIdList.add(cSem.Id);    
                        Datetime bufferTime = Datetime.now(); // Start with the current time
                        bufferTime = bufferTime.addMinutes(10);             
                        Date targetdate = sem.hed__Start_Date__c.adddays(-167);
                        CronExp ='0 ' + bufferTime.minute() + ' ' + bufferTime.hour() + ' ' + targetDate.day() + ' ' + targetDate.month() + ' ? ' + targetDate.year();
                    jobName = 'First Fee Reminder HY 28 days Prior_NextYr'+ ' # ' + system.now();
                    }
                }
            }
        }
        if(CronExp != null){
            System.schedule(jobName, CronExp, new StudentFeeNotifyBatchSchedule_HY_28P_NY(contIdList));
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('finish method of 28Days Prior Class_Next Year');
    }
    
    global void execute(SchedulableContext SC){
        //if(!Test.isRunningTest()){
            if(contactRecordIds != null && contactRecordIds.size() > 0){
                if (contactRecordIds.size() > 25) {
                    Integer batchSize = 20;
                    List<String> subList = new List<String>();
                    for (Integer i = 0; i < contactRecordIds.size(); i++) {
                        subList.add(contactRecordIds[i]);
                        if (subList.size() == batchSize || i == contactRecordIds.size() - 1) {
                            // Execute the batch with the sublist
                            Database.executeBatch(new StudentFeeNotificationBatch(subList));
                            // Clear the sublist for the next batch
                            subList.clear();
                        }
                    }
                }else{
                    Database.executeBatch(new StudentFeeNotificationBatch(contactRecordIds));
                }  
            }else{
               Database.executeBatch(new StudentFeeNotifyBatchSchedule_HY_28P_NY());        
           }
       // }
    }
    
    
}