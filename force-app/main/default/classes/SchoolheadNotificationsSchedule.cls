public class SchoolheadNotificationsSchedule  implements Schedulable
{
    public void execute(SchedulableContext sc) 
    {
        //  Instantiate batch class 
        SchoolheadNotificationsBatch autoUpdate = new SchoolheadNotificationsBatch();
        Database.Executebatch(autoUpdate,200);
    }
}