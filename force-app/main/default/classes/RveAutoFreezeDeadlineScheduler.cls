public class RveAutoFreezeDeadlineScheduler implements Schedulable {
    public void execute(SchedulableContext Sc)
    {
        RveAutoFreezeDeadlineBatch sch = new RveAutoFreezeDeadlineBatch();
        Database.executeBatch(sch,1);
    }

}