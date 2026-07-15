global class SLCM_HCM_QuarterReqRoomAllotCNFBatch_Sch implements schedulable {
    
     global void execute(SchedulableContext context) {
         SLCM_HCM_QuarterReqRoomAllotCNFBatch batch = new SLCM_HCM_QuarterReqRoomAllotCNFBatch();
            Database.executeBatch(batch);
            
        }
}