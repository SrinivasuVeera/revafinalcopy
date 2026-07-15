public class StudentHostelFeeRemainderSMSQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> studentIds;
    
    public StudentHostelFeeRemainderSMSQueueable(Set<Id> studentIds) {
        this.studentIds = studentIds;
    }

    public void execute(QueueableContext context) {
        StudentHostelFeeRemainderSMS.MainMethod(studentIds);
    }
}