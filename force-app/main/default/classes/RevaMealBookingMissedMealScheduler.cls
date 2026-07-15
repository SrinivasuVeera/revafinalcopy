public class RevaMealBookingMissedMealScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Enqueue the Queueable job
        System.enqueueJob(new RevaMealBookingMissedMealQueueable());
    }
}