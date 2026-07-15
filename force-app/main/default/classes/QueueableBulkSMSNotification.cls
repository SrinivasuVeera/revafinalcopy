public class QueueableBulkSMSNotification implements Queueable {
    List<Id> contactIds;
    public QueueableBulkSMSNotification(List<Id> ids) {
        this.contactIds = ids;
    }
    
    public void execute(QueueableContext context) {
        ReassignmentSendSMSANdWhatsapp.makeCalloutAsyncContact(contactIds);
    }
}