global class SLCM_HCM_QuarterReqCancelCNFBatch_Sch implements schedulable {
     global void execute(SchedulableContext context) {
         
         SLCM_HCM_QuarterReqCancelCNFBatch batch = new SLCM_HCM_QuarterReqCancelCNFBatch();
            Database.executeBatch(batch);
            
        }

}