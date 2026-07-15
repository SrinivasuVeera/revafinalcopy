public class ATT_LockOffereing_Schedule Implements Schedulable{
    
    public void execute(SchedulableContext sc)
    {
        courseOffSchStatusUpdate();
    }
    
    public void courseOffSchStatusUpdate()
    {
        List<hed__Course_Offering_Schedule__c> statusUpdateList = new List<hed__Course_Offering_Schedule__c>();
        statusUpdateList = [SELECT Id, Status__c FROM hed__Course_Offering_Schedule__c  WHERE Date__c != NULL AND Date__c < YESTERDAY AND (Status__c ='Scheduled' OR Status__c='Completed / Attendance Marked') LIMIT 10000];
        for(hed__Course_Offering_Schedule__c cosStatus : statusUpdateList)
        {
            cosStatus.Status__c = cosStatus.Status__c == 'Completed / Attendance Marked' ? 'Locked' : 'Class Not Conducted / Attendance Not Marked';
        }
        update statusUpdateList;
    }
}