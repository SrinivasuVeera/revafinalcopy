public class TT_AllocationReplicationCtr {
    @InvocableMethod(label='Replication of Schedule Batch' )
    public static void replicateSchedule(List<ID> ids) {
        TT_AllocationReplicationSemCls cls = new TT_AllocationReplicationSemCls (ids[0]);
        Database.executeBatch(cls, 1);
    }
}