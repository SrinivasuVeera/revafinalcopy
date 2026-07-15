@istest
global class Fee_ReminderToMentors_Batch_Sch_Test {
    global static testmethod void Reminder()
    {
        Test.StartTest();
        Fee_ReminderToMentors_Batch_Sch bc = new Fee_ReminderToMentors_Batch_Sch();
        String sch = '0 0 * * * ?';
        String JobId = System.Schedule('Fee Reminder to mentors',sch,bc);
        Test.StopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }

}