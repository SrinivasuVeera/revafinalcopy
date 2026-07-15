trigger ContentDocumentVisiblity_Trigger on ContentDocumentLink (before insert)
{
    If(Trigger.IsBefore)
    {
        If(Trigger.Isinsert)
        {
            ContentDocumentVisiblity_Trigger_Handlr.ContentDocumentVisiblity(Trigger.New);
        }
    }
}