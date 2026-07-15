public class ASM_CrsConnTrgHandler 
{
    public static void rollupCounttoCourseOffer(list<hed__Course_Enrollment__c> lst_CourseRec,map<id,hed__Course_Enrollment__c> OldMap){
        Id stdRecTypeId = Schema.getGlobalDescribe().get('hed__Course_Enrollment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Set<Id> set_CourseEnIds = new Set<Id>();
        Map<Id,hed__Course_Offering__c> map_CourseValues = new Map<Id,hed__Course_Offering__c>();
        for(hed__Course_Enrollment__c cse : lst_CourseRec){
            if(cse.Course_Offering_Section_ID__c != Null && cse.RecordTypeId == stdRecTypeId && ((OldMap == null)
              || (OldMap != null && cse.Course_Offering_Section_ID__c != OldMap.get(cse.Id).Course_Offering_Section_ID__c))){
                set_CourseEnIds.add(cse.Course_Offering_Section_ID__c);
                  if(OldMap != null && OldMap.get(cse.Id).Course_Offering_Section_ID__c !=null)
                      set_CourseEnIds.add(OldMap.get(cse.Id).Course_Offering_Section_ID__c);
            }
        }
        if(!set_CourseEnIds.isEmpty()){
            for(Id crsId : set_CourseEnIds){
                map_CourseValues.put(crsId,new hed__Course_Offering__c(Id=crsId,No_of_Students__c=0));
            }
            for(hed__Course_Enrollment__c cse : [Select Id,Course_Offering_Section_ID__c FROM hed__Course_Enrollment__c WHERE Course_Offering_Section_ID__c IN : set_CourseEnIds AND RecordTypeId =: stdRecTypeId]){
                map_CourseValues.get(cse.Course_Offering_Section_ID__c).No_of_Students__c=map_CourseValues.get(cse.Course_Offering_Section_ID__c).No_of_Students__c+1; 
            }
            Update map_CourseValues.Values();
        }
    }
    
    public static void sendToLogisysUpdate(List<hed__Course_Enrollment__c> list_CCons, Map<Id,hed__Course_Enrollment__c> map_OldCCons){
        Set<Id> set_CConIds = new Set<Id>();
        for(hed__Course_Enrollment__c con : list_CCons){
            if(map_OldCCons != Null && con.Course_Offering_Section_ID__c != Null &&
               map_OldCCons.get(con.Id).Course_Offering_Section_ID__c != con.Course_Offering_Section_ID__c 
               && con.Logisys_Integration__c == 'Yes'){
                   set_CConIds.add(con.Id);
               }
        } 
       /* if(!set_CConIds.isEmpty()){
            ASM_StdSubjectAPI.sendStdSubject_future(set_CConIds,'U');
        } */
    }
    public static void sendToLogisysDelete(List<hed__Course_Enrollment__c> list_CCons){
        Set<Id> set_CConIds = new Set<Id>();
        for(hed__Course_Enrollment__c con : list_CCons){
            if(con.Logisys_Integration__c == 'Yes'){
                set_CConIds.add(con.Id);
            }
        } 
       /* if(!set_CConIds.isEmpty()){
            ASM_StdSubjectAPI.sendStdSubject_future(set_CConIds,'D');
        } */
    } 
}