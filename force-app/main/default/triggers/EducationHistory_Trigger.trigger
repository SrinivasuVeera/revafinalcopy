trigger EducationHistory_Trigger on hed__Education_History__c (after update,After Insert )
{    
    if(Trigger.isAfter && Trigger.IsInsert)
    {        
        NPF_DocumentCreationUsingURL.CreateFile(trigger.new);       
    }  
    if(Trigger.isAfter && Trigger.IsUpdate)
    {        
        STOB_EducationHistory_Handler.updatePrgmEnrlmtStatus(trigger.new,trigger.oldmap);       
    }        
}