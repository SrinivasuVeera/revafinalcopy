global class SLCM_HCM_HstlReqRoomAllotCNFBatch_Sch implements schedulable{
    
    global void execute(SchedulableContext context) {
            SLCM_HCM_HstlReqRoomAllotCNFBatch batch = new SLCM_HCM_HstlReqRoomAllotCNFBatch();
            Database.executeBatch(batch,1);
            
        }

}