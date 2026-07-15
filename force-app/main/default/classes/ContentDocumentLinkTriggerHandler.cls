public with sharing class ContentDocumentLinkTriggerHandler {
    
    public static final string APPLICANT = 'Applicant';
    
    //public static final string BRANDING = ''
    
    public  static void UpdateVisibility(List<ContentDocumentLink> contDocumentLinkList) {
        
        List<Id> contLinked = new List<Id>();
        Map<ID, ContentDocumentLink> contIdContDocLinkMap = new Map<ID, ContentDocumentLink>();

        for (ContentDocumentLink cont : contDocumentLinkList) { 
            String linkedCOntId = cont.LinkedEntityId;
            if (linkedCOntId.startsWith('003')) {
                contLinked.add(cont.LinkedEntityId);
                contIdContDocLinkMap.put(cont.LinkedEntityId, cont);
            } else if(linkedCOntId.startsWith('a47')) {
                cont.Visibility = 'AllUsers';               
            }
        }
        if (!contLinked.isEmpty()) {
            List<Contact> applicantList = [Select Id, Record_Type_Name__c from Contact where Id in : contLinked];
            for (Contact c : applicantList){
                if (c.Record_Type_Name__c == APPLICANT) {
                    contIdContDocLinkMap.get(c.Id).Visibility = 'AllUsers';
                }
            }
        }

    }
}