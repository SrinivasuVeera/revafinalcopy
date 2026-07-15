public class ASM_ContactTrgHandler {
    public static void studentsToLogisys(List<Contact> list_Cons, Map<Id,Contact> map_OldCons){
        Set<Id> set_StdIds = new Set<Id>();
        Map<Id,String> map_DataChanges = new Map<Id,String>();
        for(Contact con : list_Cons){
            if(String.isNotBlank(con.SRN_Number__c) && con.Logisys_Integration__c == 'Yes' && map_OldCons.get(con.Id).Logisys_Integration__c == 'Yes'){
                set_StdIds.add(con.Id);
                Contact oCon = map_OldCons.get(con.Id);
                String nameChg = (con.Name != oCon.Name) ? 'Yes' : 'No';
                String degChg = (con.Program_Batch__c != oCon.Program_Batch__c) ? 'Yes' : 'No';
                String colChg = (con.School__c != oCon.School__c) ? 'Yes' : 'No';
                map_DataChanges.put(con.Id,nameChg+'-'+degChg+'-'+colChg);
            }
        }
        if(!set_StdIds.isEmpty()){
            ASM_StdProfileAPI.sendStdProfile_future(set_StdIds,map_DataChanges,false);
        }
    }
}