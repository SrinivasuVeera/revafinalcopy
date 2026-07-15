public class ContentDocumentVisiblity_Trigger_Handlr 
{
    public static Void ContentDocumentVisiblity(List <ContentDocumentLink> listAct)
    {
        set<Id> set_parent = new set<Id>();
        set<Id> set_AluWithRecType = new set<Id>();
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
        Id Alumni_Activities_Event_RecType1 = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Fund Raising Request').getRecordTypeId();
        
        for(ContentDocumentLink objCd :listAct)
        {
            if(objCd.LinkedEntityId != null && string.valueOF(objCd.LinkedEntityId.getsobjecttype())==  'Alumni_Activities__c')
                set_parent.add(objCd.LinkedEntityId);
        }
        if(set_parent.size()>0)
        {
            for(Alumni_Activities__c objAlumActivities : [SELECT id,Event_Name__c,name,Details__c,Venue__c,RecordTypeId,Contact__c,Date__c
                                                          FROM Alumni_Activities__c
                                                          WHERE Id In: set_parent  and (RecordTypeId =: Alumni_Activities_Event_RecType or RecordTypeId =: Alumni_Activities_Event_RecType1)])
            {
                set_AluWithRecType.add(objAlumActivities.id);
            }
            for(ContentDocumentLink objCd :listAct)
            {
                if(objCd.LinkedEntityId != null && string.valueOF(objCd.LinkedEntityId.getsobjecttype())==  'Alumni_Activities__c'
                   && set_AluWithRecType.contains(objCd.LinkedEntityId))
                    objCd.Visibility = 'AllUsers';
            }
        }       
    }
}