public class QueueableBulkLeadSMSNotification implements Queueable{
 List<Id> LeadIds;
    public QueueableBulkLeadSMSNotification(List<Id> ids) {
        this.LeadIds = ids;
    }
    
    public void execute(QueueableContext context) {
        ReassignmentSendSMSANdWhatsapp.makeCalloutAsyncLead(LeadIds);
    }
}