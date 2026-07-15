public class ProgramPlanHandler 
{
    public static void updateProgramPlanName(List<hed__Program_Plan__c> lst_ProPlan,map<id,hed__Program_Plan__c> map_ProgPlan)
    {
        for(hed__Program_Plan__c objPlan : lst_ProPlan)
        {
            if(map_ProgPlan == null && objPlan.Name != null) 
                objPlan.Program_Batch_Name_Unique__c = objPlan.Name;
            else if(map_ProgPlan != null &&  map_ProgPlan.get(objPlan.id).Name != objPlan.Name && objPlan.Name != null)          
                objPlan.Program_Batch_Name_Unique__c = objPlan.Name;
        }
    }
}