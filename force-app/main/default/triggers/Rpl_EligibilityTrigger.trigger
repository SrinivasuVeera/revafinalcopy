trigger Rpl_EligibilityTrigger on Rpl_Eligibility__c (After Insert, After update) {
    
    if (!Rpl_Recursive_Controller.isAlreadyExecuted) {        
        Rpl_Recursive_Controller.isAlreadyExecuted = true;
        System.debug('Rpl_Recursive_Controller.isAlreadyExecute Trigget' + Rpl_Recursive_Controller.isAlreadyExecuted);
        if(trigger.isAfter && trigger.isInsert){
            system.debug('inside Insert');
            RPL_EligibilityHandlerClass.getPlacementDriveId(trigger.new,null);
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            system.debug('inside Update');
            RPL_EligibilityHandlerClass.getPlacementDriveId(trigger.new,true); 
        }
    }
    
    
}