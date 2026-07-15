trigger Contact_Trigger_CheckBox on Contact (After Insert,After Update) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.IsInsert)
        {
            ContactCheckBox_Handler.Form_Submitted_User(Trigger.New);
        }
        if(Trigger.IsUpdate)
        {
            ContactCheckBox_Handler.Form_Submitted_Contact(Trigger.New, Trigger.oldMap);
            ContactCheckBox_Handler.Form_Submitted_Update(Trigger.New, Trigger.oldMap);
        }
    }
}