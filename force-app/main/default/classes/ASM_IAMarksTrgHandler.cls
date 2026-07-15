public class ASM_IAMarksTrgHandler
{
    public static Boolean rollupCountUpdate = true;
    public static void rollupCounttoCourseOf(List<IA_Marks__c> list_IAMarksRec, Map<Id,IA_Marks__c> map_IAmsOld){
        Map<Id,hed__Course_Offering__c> map_CourseValues = new Map<Id,hed__Course_Offering__c>();
        Set<Id> set_CourseIds = new Set<Id>();
        for(IA_Marks__c iam : list_IAMarksRec){
            if(iam.Course_Offering__c != Null && 
               ((map_IAmsOld == null && iam.IA_Marks_Update_Satus__c != '') 
                || ((map_IAmsOld != null && iam.IA_Marks_Update_Satus__c != map_IAmsOld.get(iam.Id).IA_Marks_Update_Satus__c))))
            {
                set_CourseIds.add(iam.Course_Offering__c);
                if(map_IAmsOld != null && map_IAmsOld.get(iam.Id).Course_Offering__c != null) set_CourseIds.add(map_IAmsOld.get(iam.Id).Course_Offering__c);
            }
        }
        if(!set_CourseIds.isEmpty()){
            for(Id corid : set_CourseIds){
                map_CourseValues.put(corid, new hed__Course_Offering__c(Id=corid,No_of_Students_IA_Marks_Updated__c=0,No_of_Partial_IA_Update_Students__c=0,No_of_Students_IA_2_Marks_Updated__c=0));
            }
            for(IA_Marks__c iam : [SELECT Id,Course_Offering__c,IA_Marks_Update_Satus__c,IA_Type__c FROM IA_Marks__c 
                                   WHERE Course_Offering__c IN : set_CourseIds AND 
                                   (IA_Marks_Update_Satus__c = 'Completed' OR IA_Marks_Update_Satus__c = 'In Progress')])
            {
                if(iam.IA_Marks_Update_Satus__c == 'Completed' && iam.IA_Type__c == 'IA1') map_CourseValues.get(iam.Course_Offering__c).No_of_Students_IA_Marks_Updated__c++;
                if(iam.IA_Marks_Update_Satus__c == 'Completed' && iam.IA_Type__c == 'IA2') map_CourseValues.get(iam.Course_Offering__c).No_of_Students_IA_2_Marks_Updated__c++;
                if(iam.IA_Marks_Update_Satus__c == 'In Progress') map_CourseValues.get(iam.Course_Offering__c).No_of_Partial_IA_Update_Students__c++;
            }
            if(rollupCountUpdate == True)
                Update map_CourseValues.Values();
        }
    }
    
    //This method is used Rolluping the Total Students Pushed to Logisys based on IA
    public static void rollupStudentPushedToLogisys(List<IA_Marks__c> listIAMarks, Map<Id,IA_Marks__c> oldMap)
    {
        Set<Id> set_CourseOffIds = new Set<Id>();
        Map<Id,hed__Course_Offering__c> map_CourseOffers = new Map<Id,hed__Course_Offering__c>();
        for(IA_Marks__c objIAMarks : listIAMarks)
        {
            if(objIAMarks.Course_Offering__c != Null && ((oldMap == Null && objIAMarks.Logisys_Integration__c == 'Yes')
              || (oldMap != Null && objIAMarks.Logisys_Integration__c == 'Yes' && 
                 (oldMap.get(objIAMarks.Id).Logisys_Integration__c != objIAMarks.Logisys_Integration__c || 
                 oldMap.get(objIAMarks.Id).Course_Offering__c != objIAMarks.Course_Offering__c))))
            {
                set_CourseOffIds.add(objIAMarks.Course_Offering__c);
                if(oldMap != Null && oldMap.get(objIAMarks.Id).Course_Offering__c != Null)
                    set_CourseOffIds.add(oldMap.get(objIAMarks.Id).Course_Offering__c);
            }
        }
        
        if(!set_CourseOffIds.isEmpty())
        {
            for(Id corOfferId : set_CourseOffIds)
            {
                map_CourseOffers.put(corOfferId, new hed__Course_Offering__c(Id = corOfferId, IA_1_Marks_Synced_to_Logisys__c = 0,
                                                                            IA_2_Marks_Synced_to_Logisys__c = 0));
            }
            
            for(IA_Marks__c objIAMarks : [Select Id, Course_Offering__c, Logisys_Integration__c, IA_Type__c
                                          from IA_Marks__c where Course_Offering__c IN: set_CourseOffIds
                                          AND Logisys_Integration__c = 'Yes' And IA_Type__c != Null])
            {
                if(map_CourseOffers.get(objIAMarks.Course_Offering__c) != Null)
                {
                    if(objIAMarks.IA_Type__c == 'IA1') map_CourseOffers.get(objIAMarks.Course_Offering__c).IA_1_Marks_Synced_to_Logisys__c++;
                    if(objIAMarks.IA_Type__c == 'IA2') map_CourseOffers.get(objIAMarks.Course_Offering__c).IA_2_Marks_Synced_to_Logisys__c++;
                }
            }
            update map_CourseOffers.values();
        }
    }
    
    //this method is used for decativating the push to logisys field at section level whenever IA Marks logisys Integration Failed
    public static void UncheckPushToLogisys(List<IA_Marks__c> listIAMarks, Map<Id,IA_Marks__c> oldMap)
    { 
        Map<Id, hed__Term__c> map_Sections = new Map<Id, hed__Term__c>();
        Map<Id, hed__Term__c> map_Semsters = new Map<Id, hed__Term__c>();
        for(IA_Marks__c objIAMarks : listIAMarks)
        {
            if(oldMap != null && objIAMarks.Logisys_Integration__c =='No')
            {
                if(map_Sections.get(objIAMarks.Active_Section__c) == Null)
                {
                    map_Sections.put(objIAMarks.Active_Section__c, new hed__Term__c(Id =objIAMarks.Active_Section__c));
                }
                map_Sections.get(objIAMarks.Active_Section__c).Push_to_Logisys__c = false;
                
                if(map_Semsters.get(objIAMarks.Active_Semester_Record_ID__c) == Null)
                {
                    map_Semsters.put(objIAMarks.Active_Semester_Record_ID__c, new hed__Term__c(Id =objIAMarks.Active_Semester_Record_ID__c));
                }
                map_Semsters.get(objIAMarks.Active_Semester_Record_ID__c).Push_to_Logisys__c = false;
            }
        }
        if(!map_Sections.isEmpty()) 
            update map_Sections.values();
        if(!map_Semsters.isEmpty())
            update map_Semsters.values();
    }
}