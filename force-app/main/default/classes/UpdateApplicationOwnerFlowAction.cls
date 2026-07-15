public class UpdateApplicationOwnerFlowAction {
    @InvocableMethod(label='Update Application Owner' description='Batch Appliation owner update')
    public static void updateOwner(List<BulkApplicationUpdateCounselor.UpdateOwnerInput> input) {
        List<Id> recordIds = input[0].recordIds;
        Id newOwnerId = input[0].newOwnerId;
        
        
        BulkApplicationUpdateCounselor batch = new BulkApplicationUpdateCounselor(recordIds, newOwnerId);
        Database.executeBatch(batch);
    }
}