trigger Contact_Trigger on Contact (After Insert, After Update, before update) 
{
    HostelDisableTriggers__c disableTriggerSetting = HostelDisableTriggers__c.getInstance('Contact'); 
    if (disableTriggerSetting != null && disableTriggerSetting.IsRevaHostelRoomRequestTrigger__c) {
        // Trigger logic is disabled, so exit the trigger
        return;
    }
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        { 
            //Creaing a Professor or non teching user from contact
            MSTR_ContactTrigHndlr.createProfessorNonTeachingUser(Trigger.New); 
        }
        else if(Trigger.isUpdate && !System.isBatch())
        {
            //Updating a Professor or non teching user from contact
            MSTR_ContactTrigHndlr.updateProfNonTeacUser(Trigger.New, Trigger.oldMap); 
            MSTR_ContactTrigHndlr.updateHCMhostelEmpSalary(Trigger.New, Trigger.oldMap);         
            if(Utility.ContactOwnerUpdate == true) MSTR_ContactTrigHndlr.StudentUserCreation(Trigger.New, Trigger.oldMap);
            //  MSTR_ContactTrigHndlr.AlumniUserCreation(Trigger.New, Trigger.oldMap);
            ASM_ContactTrgHandler.studentsToLogisys(Trigger.New, Trigger.oldMap);
            Appl_ContactTriggerHandler.applicantUserCreation(Trigger.New,Trigger.oldMap); 
            
            ReassignmentSendSMSANdWhatsapp.handleOwnerChangeContact(Trigger.new, Trigger.oldMap);
            
        }
        
        
        if(Trigger.isUpdate && Trigger.isAfter && RecursiveTriggerHandler.isFirstTime)
        {
            list<id> studentIds = new List<id>();
            // Note: `Rpl_Is_Placement_Created__c` is not used in REVA UAT (related to SAP logic),
            // but exists in both CODEV and production with an unknown purpose.
            
            for(Contact objCon:Trigger.New)
            {
                //Boolean placementChanged = objCon.Rpl_Is_Placement_Created__c != Trigger.oldMap.get(objCon.Id).Rpl_Is_Placement_Created__c;
                Boolean applicationFeePaidNow = objCon.Application_Fee_Paid__c == true && Trigger.oldMap.get(objCon.Id).Application_Fee_Paid__c != true;
                if((!objCon.Rpl_Is_Placement_Created__c != Trigger.oldMap.get(objCon.id).Rpl_Is_Placement_Created__c && objCon.Push_to_SAP__c) || applicationFeePaidNow){
                    studentIds.add(objCon.Id);                    
                }
                // Uncomment the following block if only `Push_to_SAP__c` should be checked for SAP integration and remove above code block
                /*
                if(objCon.Push_to_SAP__c) {
                studentIds.add(objCon.Id);
                }
                */
            }
            
            // SAP Integration - code added by ePeople Team.
            // This aligns with production logic for SAP Student Master creation.
            if (!studentIds.isEmpty() && !System.isBatch())
                SAP_Student_Master_API.StudentMasterCreationMethod(studentIds); 
        
           // ASM_ContactTrgHandler.studentsToLogisys(Trigger.New, Trigger.oldMap);
        }       
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        
        Appl_ContactTriggerHandler.updateContactSource(Trigger.oldMap, Trigger.new);
        
    }
    
}