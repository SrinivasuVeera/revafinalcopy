global class SLCM_HCM_HstlReqRoomCancelCNFBatch_Sch implements schedulable{
    
    global void execute(SchedulableContext context) {
            
            SLCM_HCM_HstlReqRoomCancelCNFBatch batch = new SLCM_HCM_HstlReqRoomCancelCNFBatch();
            Database.executeBatch(batch);
            
      
            
        }

}