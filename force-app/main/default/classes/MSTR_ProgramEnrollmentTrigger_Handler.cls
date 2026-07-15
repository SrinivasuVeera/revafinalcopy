public class MSTR_ProgramEnrollmentTrigger_Handler 
{
    public static void ProgramEnrollment(List<hed__Program_Enrollment__c> list_PrgmEnrol, Map<id, hed__Program_Enrollment__c> Map_oldPrgm)
    {        
        set<Id> set_ContIds = New set<Id>();       
        Map<id, Contact> Map_Con = New Map<id, Contact>();
        List<hed__Program_Enrollment__c> list_NewProgEnrol = New List<hed__Program_Enrollment__c>();
        
        for(hed__Program_Enrollment__c objPrgmEnrol : list_PrgmEnrol)
        {
            if(Map_oldPrgm != Null && objPrgmEnrol.Active__c == True)
            { 
                if((objPrgmEnrol.Batch__c != Null && Map_oldPrgm.get(objPrgmEnrol.id).Batch__c != objPrgmEnrol.Batch__c && objPrgmEnrol.hed__Contact__c != Null)
                   ||(objPrgmEnrol.Section__c != Null && Map_oldPrgm.get(objPrgmEnrol.id).Section__c != objPrgmEnrol.Section__c && objPrgmEnrol.hed__Contact__c != Null))
                {
                    set_ContIds.add(objPrgmEnrol.hed__Contact__c);
                    list_NewProgEnrol.add(objPrgmEnrol); 
                }
            } 
        }
        if(!set_ContIds.IsEmpty())
        {
            for(Contact objCon : [SELECT id, Active_Batch__c, Active_Section__c	FROM Contact WHERE Id IN: set_ContIds])
            {
                Map_Con.put(objCon.id,objCon);
            }
            for(hed__Program_Enrollment__c objPrgmEnrol : list_NewProgEnrol)
            {                
                if(Map_Con.get(objPrgmEnrol.hed__Contact__c) != Null)
                {  
                    Map_Con.get(objPrgmEnrol.hed__Contact__c).Active_Batch__c = objPrgmEnrol.Batch__c;
                    Map_Con.get(objPrgmEnrol.hed__Contact__c).Active_Section__c = objPrgmEnrol.Section__c;
                }
            }
        }
        if(Map_Con.size() > 0)
        {
            update Map_Con.values();
        }
    }
    
}