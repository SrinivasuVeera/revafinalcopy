public class MissedMealScheduleFlow implements Schedulable{
    /*MissedMealScheduleFlow sch = new MissedMealScheduleFlow();
System.schedule('Missed meal checking- I', '0 59 * * * ? ' , sch);
System.schedule('Missed meal checking- II', '0 59 * * * ? ' , sch);
System.schedule('Missed meal checking- III', '0 59 * * * ? ' , sch);
System.schedule('Missed meal checking- IV', '0 59 * * * ? ' , sch);
*/
    public void execute(SchedulableContext sc) {
        Flow.Interview.Update_Missed_Meals_REVA_Hostel flow = new Flow.Interview.Update_Missed_Meals_REVA_Hostel(new Map<String, Object>());
        flow.start();
    }
}