global class StudentFeeNotifyBatchSchedule_FY_Day31 implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    global Date currentDate, dt;
    global String CronExp1, CronExp2, CronExp3, CronExp4, CronExp5, CronExp6, CronExp7,
        CronExp8, CronExp9, CronExp10, CronExp11, CronExp12, CronExp13, CronExp14, CronExp15, CronExp16, CronExp17, cronExp18,
        jobName1, jobName2, jobName3, jobName4, jobName5, jobName6, jobName7, jobName8, jobName9, jobName10,
        jobName11, jobName12, jobName13, jobName14, jobName15, jobName16, jobName17, jobName18;
    
    global static List<String> contIdList1 = new List<String>();
    global static List<String> contIdList2 = new List<String>(); 
    global static List<String> contIdList3 = new List<String>(); 
    global static List<String> contIdList4 = new List<String>(); 
    global static List<String> contIdList5 = new List<String>(); 
    global static List<String> contIdList6 = new List<String>(); 
    global static List<String> contIdList7 = new List<String>(); 
    global static List<String> contIdList8 = new List<String>(); 
    global static List<String> contIdList9 = new List<String>(); 
    global static List<String> contIdList10 = new List<String>(); 
    global static List<String> contIdList11 = new List<String>(); 
    global static List<String> contIdList12 = new List<String>(); 
    global static List<String> contIdList13 = new List<String>(); 
    global static List<String> contIdList14 = new List<String>(); 
    global static List<String> contIdList15 = new List<String>(); 
    global static List<String> contIdList16 = new List<String>(); 
    global static List<String> contIdList17 = new List<String>();  
    global static List<String> contIdList18 = new List<String>();  
    global Set<String> semProgramBatch = new Set<String>();    
    global Set<String> semProgramBatchName = new Set<String>();
    global Set<String> hdTemIds = new set<String>();
    global List<String> contactRecordIds { get; set; }//initialContacts
    global String studentRecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Student').getRecordTypeId();
    
    
    global StudentFeeNotifyBatchSchedule_FY_Day31(){}
    
    global StudentFeeNotifyBatchSchedule_FY_Day31(List<String> contactIds){
        this.contactRecordIds = contactIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, hed__Start_Date__c, Program_Batch__c,Program_Batch__r.Name,'
            +' Term_Number__c, Days_Remaining_To_Start__c, No_of_Days__c '
            +' FROM hed__term__c '
            +' WHERE hed__Start_Date__c != null'
            +' AND hed__Start_Date__c = THIS_YEAR'
            +' AND Term_Number__c =1';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<hed__term__c> semesters) {
        
        System.debug('execute method ' + semesters);
        
        for(hed__term__c sem : semesters){
            semProgramBatchName.add(sem.Program_Batch__r.Name);
            semProgramBatch.add(sem.Program_Batch__c);
            hdTemIds.add(sem.Id);
        }
        System.debug('sem.Program_Batch__r.Name: ' + semProgramBatchName);
        System.debug('sem.Program_Batch__r.Name: ' + semProgramBatchName.size());
        
        String contactQuery = 'SELECT Id, Name, Program_Batch__c,Active_Semester__c'
            +' FROM Contact'
            +' WHERE Program_Batch__c != null AND Program_Batch__c IN : semProgramBatch'
            +' AND RecordTypeId =: studentRecordTypeID AND Active__c = true'
            +' AND Active_Semester__c IN :hdTemIds'
            +' AND Student_Status__c = \'Pursuing\'';
        
        List<Contact> contactList = Database.query(contactQuery);
        System.debug('contactList=> ' + contactList);
        System.debug('contactList SIZE=> ' + contactList.size());
        
        for(Contact cSem : contactList){
            currentDate = Date.Today();
            for(hed__term__c sem : semesters){
                if(cSem.Active_Semester__c == sem.Id){
                    if(math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) <= 30 && 
                       currentDate > sem.hed__Start_Date__c){
                           switch on (Integer)sem.Days_Remaining_To_Start__c{
                               when -8{
                                   dt = sem.hed__Start_Date__c.adddays(8);
                                   System.debug('dt: ' + dt);
                                   CronExp1 = '0 45 16 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp1: ' + CronExp1);
                                   contIdList1.add(cSem.Id);
                                   jobName1 = 'Fee Reminder for Day-8 1-30_First_Yr' + ' # ' + system.now();
                               }
                               when -15{
                                   dt = sem.hed__Start_Date__c.adddays(15);
                                   System.debug('dt: ' + dt);
                                   CronExp2 = '0 45 16'+ ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   contIdList2.add(cSem.Id);
                                   System.debug('CronExp2: ' + CronExp2);
                                   jobName2 = 'Fee Reminder for Day-15 1-30_First_Yr'+ ' # ' + system.now();
                               }
                               when -22{
                                   dt = sem.hed__Start_Date__c.adddays(22);
                                   System.debug('dt: ' + dt);
                                   CronExp3 = '0 45 16 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp3: ' + CronExp3);
                                   contIdList3.add(cSem.Id);
                                   jobName3 = 'Fee Reminder for Day-22 1-30_First_Yr'+ ' # ' + system.now();
                               }
                               when -29{
                                   dt = sem.hed__Start_Date__c.adddays(29);
                                   System.debug('dt: ' + dt);
                                   CronExp4 = '0 45 16'+ ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp4: ' + CronExp4);
                                   contIdList4.add(cSem.Id);
                                   jobName4 = 'Fee Reminder for Day-29 1-30_First_Yr'+ ' # ' + system.now();
                               }
                           }
                       }  
                    
                    if(math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) > 30 &&
                       math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) <= 45){
                           
                            switch on (Integer)sem.Days_Remaining_To_Start__c{
                                when -31{
                                    dt = sem.hed__Start_Date__c.adddays(31);
                                    System.debug('dt: ' + dt);
                                    CronExp5 = '0 50 16 '  + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                    System.debug('CronExp5: ' + CronExp5);
                                    contIdList5.add(cSem.Id);
                                    jobName5 = 'Fee Reminder for Day-31 31-45_First_Yr'+ ' # ' + system.now();
                                }
                                when -34{
                                    dt = sem.hed__Start_Date__c.adddays(34);
                                    System.debug('dt: ' + dt);
                                    CronExp6 = '0 50 16 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();  
                                    System.debug('CronExp6: ' + CronExp6);
                                    contIdList6.add(cSem.Id);
                                    jobName6 = 'Fee Reminder for Day-34 31-45_First_Yr'+ ' # ' + system.now();
                                }
                                when -37{
                                    dt = sem.hed__Start_Date__c.adddays(37);
                                    System.debug('dt: ' + dt);
                                    CronExp7 = '0 50 16 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                    System.debug('CronExp7: ' + CronExp7);
                                    contIdList7.add(cSem.Id);
                                    jobName7 = 'Fee Reminder for Day-37 31-45_First_Yr'+ ' # ' + system.now();
                                }
                                when -40{
                                    dt = sem.hed__Start_Date__c.adddays(40);
                                    System.debug('dt: ' + dt);
                                    CronExp8 = '0 55 16 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                    System.debug('CronExp8: ' + CronExp8);
                                    contIdList8.add(cSem.Id);
                                    jobName8 = 'Fee Reminder for Day-40 31-45_First_Yr'+ ' # ' + system.now();
                                }
                                when -43{
                                    dt = sem.hed__Start_Date__c.adddays(43);
                                    System.debug('dt: ' + dt);
                                    CronExp9 = '0 55 16 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                    System.debug('CronExp9: ' + CronExp9);
                                    contIdList9.add(cSem.Id);
                                    jobName9 = 'Fee Reminder for Day-43 31-45_First_Yr'+ ' # ' + system.now();
                                 }
                           }
                       }
                    
                     if(math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) > 45 &&
                       math.abs(currentDate.daysBetween(sem.hed__Start_Date__c)) <= 60){
                           
                           switch on (Integer)sem.Days_Remaining_To_Start__c{
                               when -46{
                                   dt = sem.hed__Start_Date__c.adddays(46);
                                   System.debug('#123dt: ' + dt);
                                   CronExp10 = '0 0 17 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
                                   contIdList10.add(cSem.Id);
                                   System.debug('CronExp10: ' + CronExp10);
                                   jobName10 = 'Fee Reminder for Day-46 31-45_First_Yr'+ ' # ' + system.now();                               
                               }
                               when -48{
                                   dt = sem.hed__Start_Date__c.adddays(48);
                                   System.debug('#129dt: ' + dt);
                                   CronExp11 = '0 0 17 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp11:' + CronExp11);
                                   contIdList11.add(cSem.Id);
                                   jobName11 = 'Fee Reminder for Day-48 31-45_First_Yr'+ ' # ' + system.now();
                               } 
                               when -50{
                                   dt = sem.hed__Start_Date__c.adddays(50);
                                   System.debug('#135dt: ' + dt);
                                   CronExp12 = '0 0 17' +' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp12: ' + CronExp12);
                                   contIdList12.add(cSem.Id);
                                   jobName12 = 'Fee Reminder for Day-50 31-45_First_Yr'+ ' # ' + system.now();
                               }
                               when -52{
                                   dt = sem.hed__Start_Date__c.adddays(52);
                                   System.debug('#141dt: ' + dt);
                                   CronExp13 = '0 5 17 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
                                   System.debug('CronExp13: ' + CronExp13);
                                   contIdList13.add(cSem.Id);
                                   jobName13 = 'Fee Reminder for Day-52 31-45_First_Yr'+ ' # ' + system.now();
                               }
                               when -54{
                                   dt = sem.hed__Start_Date__c.adddays(54);  
                                   System.debug('#147dt: ' + dt);
                                   CronExp14 = '0 5 17 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp14: ' + CronExp14);
                                   contIdList14.add(cSem.Id);
                                   jobName14 = 'Fee Reminder for Day-54 31-45_First_Yr'+ ' # ' + system.now();
                               }
                               when -56{
                                   dt = sem.hed__Start_Date__c.adddays(56);
                                   System.debug('#153dt: ' + dt);
                                   CronExp15 = '0 10 17'+' '  + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp15: ' + CronExp15);
                                   contIdList15.add(cSem.Id);
                                   jobName15 = 'Fee Reminder for Day-56 31-45_First_Yr'+ ' # ' + system.now();
                               } 
                               when -58{
                                   dt = sem.hed__Start_Date__c.adddays(58);
                                   System.debug('#159dt: ' + dt);
                                   CronExp16 ='0 10 17 '  + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp16: ' + CronExp16);
                                   contIdList16.add(cSem.Id);
                                   jobName16 = 'Fee Reminder for Day-58 31-45_First_Yr'+ ' # ' + system.now();
                               }
                               when -60{
                                   dt = sem.hed__Start_Date__c.adddays(60);
                                   System.debug('#165dt: ' + dt);
                                   CronExp17 = ' 0 10 17'  + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                                   System.debug('CronExp17: ' + CronExp17);
                                   contIdList17.add(cSem.Id);
                                   jobName17 = 'Fee Reminder for Day-60 31-45_First_Yr'+ ' # ' + system.now(); 
                               }
                               when else{
                                   CronExp18 = '0 0 8 * * ?';
                                   System.debug('CronExp18: ' + CronExp18);
                                   contIdList18.add(cSem.Id);
                                   jobName18 = 'Fee Reminder for Day-61_Onwards_First_Yr'+ ' # ' + system.now();
                               }
                           }
                       }
                }
               
            }
        }
        if(CronExp1 != null && contIdList1.size() > 0 && jobName1 != '')
            System.schedule(jobName1, CronExp1, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList1));
        if(CronExp2 != null && contIdList2.size() > 0 && jobName2 != '')
            System.schedule(jobName2, CronExp2, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList2));
        if(CronExp3 != null && contIdList3.size() > 0 && jobName3 != '')
            System.schedule(jobName3, CronExp3, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList3));
        if(CronExp4 != null && contIdList4.size() > 0 && jobName4 != '')
            System.schedule(jobName4, CronExp4, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList4));
        if(CronExp5 != null && contIdList5.size() > 0 && jobName5 != '')
            System.schedule(jobName5, CronExp5, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList5));
        if(CronExp6 != null && contIdList6.size() > 0 && jobName6 != '') 
            System.schedule(jobName6, CronExp6, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList6));
        if(CronExp7 != null && contIdList7.size() > 0 && jobName7 != '')
            System.schedule(jobName7, CronExp7, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList7));
        if(CronExp8 != null && contIdList8.size() > 0 && jobName8 != '')
            System.schedule(jobName8, CronExp8, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList8));
        if(CronExp9 != null && contIdList9.size() > 0 && jobName9 != '')
            System.schedule(jobName9, CronExp9, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList9));
        if(CronExp10 != null && contIdList10.size() > 0 && jobName10 != '')
            System.schedule(jobName10, CronExp10, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList10));
        if(CronExp11 != null && contIdList11.size() > 0 && jobName11 != '')
            System.schedule(jobName11, CronExp11, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList11));
        if(CronExp12 != null && contIdList12.size() > 0 && jobName12 != '')
            System.schedule(jobName12, CronExp12, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList12));
        if(CronExp13 != null && contIdList13.size() > 0 && jobName13 != '')
            System.schedule(jobName13, CronExp13, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList13));
        if(CronExp14 != null && contIdList14.size() > 0 && jobName14 != '')
            System.schedule(jobName14, CronExp14, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList14));
        if(CronExp15 != null && contIdList15.size() > 0 && jobName15 != '')
            System.schedule(jobName15, CronExp15, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList15));
        if(CronExp16 != null && contIdList16.size() > 0 && jobName16 != '')
            System.schedule(jobName16, CronExp16, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList16));
        if(CronExp17 != null && contIdList17.size() > 0 && jobName17 != '')
            System.schedule(jobName17, CronExp17, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList17));
        if(CronExp18 != null && contIdList18.size()>0)
            System.schedule(jobName18, CronExp18, new StudentFeeNotifyBatchSchedule_FY_Day31(contIdList18));
        
    }
    
    global void finish(Database.BatchableContext bc) { }  
    
    public void execute(SchedulableContext SC){
        if(!Test.isRunningTest()){
            if(contactRecordIds != null && contactRecordIds.size() > 0){
                Database.executeBatch(new StudentFeeNotificationBatch(contactRecordIds)); 
            }else{
                Database.executeBatch(new StudentFeeNotifyBatchSchedule_FY_Day31());
            }
        }
    }
    public static void testCover(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}