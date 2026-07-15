public class UpdateLeadOwnerFlowAction {
   /* @InvocableMethod(label='Update Lead Owner' description='Batch lead owner update')
    public static void updateLeadOwner(List<BulkLeadUpdateCounselor.UpdateOwnerInput> input) {
        List<Id> recordIds = input[0].recordIds;
        Id newOwnerId = input[0].newOwnerId;
        
        
        BulkLeadUpdateCounselor batch = new BulkLeadUpdateCounselor(recordIds, newOwnerId);
        Database.executeBatch(batch);
}}*/
  @InvocableMethod(label='Update Lead Owner' description='Update lead owner')
    public static void updateLeadOwner(List<BulkLeadUpdateCounselor.UpdateOwnerInput> input) {
        
        if(input == null || input.isEmpty()) return;

        List<Id> recordIds = input[0].recordIds;
        Id newOwnerId = input[0].newOwnerId;

        if(recordIds == null || recordIds.isEmpty() || newOwnerId == null) return;

        List<Lead> leadsToUpdate = new List<Lead>();

        for(Id recId : recordIds){
            leadsToUpdate.add(new Lead(
                Id = recId,
                OwnerId = newOwnerId
            ));
        }

        Database.update(leadsToUpdate, false);
    }
}