public class REVA_CaseTrigger_Handler 
{
    public static void CaseAssignment(list<Case> lst_Case,map<id,Case> OldMap)
    {
        list<Case>  lst_updateCase=new list<case>();
        Set<Id> set_caseId = new Set<Id>();
        Id StudentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Request').getRecordTypeId();
        Id AlumniRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alumni Assist').getRecordTypeId();
        for(Case objCase : lst_Case) 
        {
            if((objCase.RecordTypeId == StudentRecordTypeId) || (objCase.RecordTypeId == AlumniRecordTypeId)) 
            {           	
                set_caseId.add(objCase.Id);           
            }
        }
        if(set_caseId.size()>0)
        {
                            Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.AssignmentRuleHeader.useDefaultRule = true;
                dmo.EmailHeader.triggerAutoResponseEmail = true;
                dmo.EmailHeader.triggerOtherEmail = true;
                dmo.EmailHeader.triggerUserEmail = true;
                for(Case objCase : [SELECT Id FROM Case WHERE Id IN: set_caseId])
                {
                        objCase.setOptions(dmo);
                        lst_updateCase.add(objCase);                   
                }
                if(lst_updateCase.size()>0)
                    update lst_updateCase;
        }
    }
}