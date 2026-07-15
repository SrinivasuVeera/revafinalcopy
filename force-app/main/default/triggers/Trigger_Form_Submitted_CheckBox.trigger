trigger Trigger_Form_Submitted_CheckBox on Contact (After Insert,After Update) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.IsInsert)
        {
            Trigger_Form_Submitted_CheckBox_Handler.Form_Submitted_User(Trigger.New);
        }
        if(Trigger.IsUpdate)
        {
             Trigger_Form_Submitted_CheckBox_Handler.Form_Submitted_Contact(Trigger.New, Trigger.oldMap);
        }
    }
}