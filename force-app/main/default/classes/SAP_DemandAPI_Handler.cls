public class SAP_DemandAPI_Handler implements Queueable,Database.AllowsCallouts {
    private List<Id> demandIds;
 
    // Constructor to accept demandIds
    public SAP_DemandAPI_Handler(List<Id> demandIds) {
        this.demandIds = demandIds;
    }
 
    // Execute method where API callout logic is performed
    public void execute(QueueableContext context) {
        SAP_DemandAPI.DemandCreationAPI(demandIds);
    }
  /*
    @future(callout=true)
    public static void createDemands() {
  
        SAP_DemandAPI.DemandCreationAPI(demandIds);
    }
    */
  
}