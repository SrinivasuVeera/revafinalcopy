trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {

    if (Trigger.isinsert && Trigger.isbefore) {
        ContentDocumentLinkTriggerHandler.UpdateVisibility(Trigger.new);
    }

}