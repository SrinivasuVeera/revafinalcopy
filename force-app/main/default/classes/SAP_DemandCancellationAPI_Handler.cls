public class SAP_DemandCancellationAPI_Handler implements Queueable, Database.AllowsCallouts {

    private List<Id> demandIds;

    public SAP_DemandCancellationAPI_Handler(List<Id> demandIds) {
        this.demandIds = demandIds;
    }

    public void execute(QueueableContext qc) {
        SAP_DemandCancellationAPI.DemandCancellation_APIMethod(demandIds);
    }

  
}