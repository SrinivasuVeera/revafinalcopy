public class UpdateOwnerFlowAction {
    @InvocableMethod(label='Update Owner' description='Batch contact owner update')
    public static void updateOwner(List<BulkContactUpdateCounselor.UpdateOwnerInput> input) {
        List<Id> recordIds = input[0].recordIds;
        Id newOwnerId = input[0].newOwnerId;
        
        
        BulkContactUpdateCounselor batch = new BulkContactUpdateCounselor(recordIds, newOwnerId);
        Database.executeBatch(batch);
    }
}