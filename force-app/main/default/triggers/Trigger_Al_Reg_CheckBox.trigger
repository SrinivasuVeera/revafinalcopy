trigger Trigger_Al_Reg_CheckBox on Alumni_Registration__c(After Insert,After Update) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.IsInsert)
        {
          //  Trigger_Al_Reg_CheckBox_Handler.Alumni_Registration_User(Trigger.New);
        }
        if(Trigger.IsUpdate)
        {
            Trigger_Al_Reg_CheckBox_Handler.Alumni_Registration(Trigger.New, Trigger.oldMap);
        }
    }    
}