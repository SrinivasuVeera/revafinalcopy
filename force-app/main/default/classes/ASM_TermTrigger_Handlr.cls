public class ASM_TermTrigger_Handlr 
{
    //This Method is Used for pushing the IA Marks Manually
	public static void PushIAMarksToLogisys(List<hed__Term__c> lstSemester, Map<Id, hed__Term__c> oldMap)
    { 
        String secRecType = Utility.Term_Object_RecType_Sections;
        Set<Id> set_SectionIds = new Set<Id>();
        for(hed__Term__c objSemseter : lstSemester)
        {
            String recTypeName = Schema.SObjectType.hed__Term__c.getRecordTypeInfosById().get(objSemseter.RecordTypeId).getName();
            if(oldMap != Null && secRecType == recTypeName && objSemseter.Push_to_Logisys__c
              && oldMap.get(objSemseter.Id).Push_to_Logisys__c != objSemseter.Push_to_Logisys__c)
            {
                set_SectionIds.add(objSemseter.Id);
            }
        }
        
        if(!set_SectionIds.isEmpty())
        {
            Set<Id> set_IAMarksIds = new Set<Id>();
        	for(IA_Marks__c objIAMarks : [Select Id from IA_Marks__c where Active_Section__c IN: set_SectionIds
                                         AND Logisys_Integration__c != 'Yes'])
            {
                set_IAMarksIds.add(objIAMarks.Id);
            }
            
            if(!set_IAMarksIds.isEmpty())
            {
                ASM_IAMarksFomSfAPI.sendIAMarks_future(set_IAMarksIds, 'I');
            }
        }
    }
}