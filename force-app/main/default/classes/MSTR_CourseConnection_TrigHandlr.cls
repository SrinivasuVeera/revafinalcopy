public class MSTR_CourseConnection_TrigHandlr 
{
    //This Method Used for Counting the Total Number of Students Under the particular Subject 
    public static void RollupCourseConnection(List<hed__Course_Enrollment__c> lst_Cour_Enroll, Map<Id,hed__Course_Enrollment__c> oldMap)
    {
        Set<Id> set_Course_Id = new Set<Id>();
        Map<Id, hed__Course_Offering__c> Map_Course_Off = new Map<Id, hed__Course_Offering__c>();
        system.debug('course connection new data::'+lst_Cour_Enroll);
        system.debug('course connection old data::'+oldMap);
        
        Id StudentRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        for(hed__Course_Enrollment__c  Enroll : lst_Cour_Enroll)
        {
            if(Enroll.hed__Course_Offering__c != null  && Enroll.RecordTypeId == StudentRecTypeId )
            {
                set_Course_Id.Add(Enroll.hed__Course_Offering__c);
            }
            if(oldMap != Null && Enroll.hed__Course_Offering__c != null && Enroll.RecordTypeId == StudentRecTypeId 
               && oldMap.get(Enroll.Id).hed__Course_Offering__c != Enroll.hed__Course_Offering__c)
            {
                system.debug('Course_Offering entry::'+oldMap.get(Enroll.id).hed__Course_Offering__c);
                set_Course_Id.Add(oldMap.get(Enroll.id).hed__Course_Offering__c);
            }
        }
        system.debug('Course_Offering id::'+set_Course_Id);
        if(!set_Course_Id.isEmpty())
        {
            for(Id OfferId : set_Course_Id)
            {
               system.debug('OfferId New::'+OfferId);
                Map_Course_Off.put(OfferId, new hed__Course_Offering__c(Id = OfferId,Assigned__c = 0));
            }
            for(hed__Course_Enrollment__c Cour_Enroll :[Select Id,hed__Course_Offering__c from hed__Course_Enrollment__c where hed__Course_Offering__c  In : set_Course_Id])
            {
                if(Map_Course_Off.get(Cour_Enroll.hed__Course_Offering__c) != null)
                {
                    system.debug('Assigned'+Map_Course_Off.get(Cour_Enroll.hed__Course_Offering__c).Assigned__c);
                    Map_Course_Off.get(Cour_Enroll.hed__Course_Offering__c).Assigned__c+=1;
                }
            }
               
            if(Map_Course_Off.size() > 0)
                system.debug('Key Values Of courseOffering Map::'+Map_Course_Off.values());
                update Map_Course_Off.values();
            
        }
    } 
    
    //This method used for Deleteing the Student Semester Mapping Records whenever Subject is changed for Student
    public static void DeleteStudentSemester(List<hed__Course_Enrollment__c> lstCourConn, Map<Id, hed__Course_Enrollment__c> oldMap)
    {
        Set<Id> set_OldCourseConnIds  = new Set<Id>();
        Set<Id> set_ProgEnrollIds  = new Set<Id>();
        
        for(hed__Course_Enrollment__c objCourseConn : lstCourConn)
        {
            if(oldMap != Null && objCourseConn.hed__Course_Offering__c != Null 
               && oldMap.get(objCourseConn.Id).hed__Course_Offering__c != objCourseConn.hed__Course_Offering__c
               && oldMap.get(objCourseConn.Id).hed__Course_Offering__c != Null 
               && objCourseConn.hed__Program_Enrollment__c != Null)
            {
                set_ProgEnrollIds.add(objCourseConn.hed__Program_Enrollment__c);
                set_OldCourseConnIds.add(oldMap.get(objCourseConn.Id).hed__Course_Offering__c);
            }
        }
        
        if(!set_ProgEnrollIds.isEmpty() && !set_OldCourseConnIds.isEmpty())
        {       
            List<Student_Semester_Mapping__c> lstStudSem = new List<Student_Semester_Mapping__c>();
            lstStudSem = [Select Id from Student_Semester_Mapping__c where Program_Enrollment__c IN: set_ProgEnrollIds
                          AND Course_Offering_ID__c IN: set_OldCourseConnIds];

            if(lstStudSem.size() > 0)
                Delete lstStudSem;
        }
    }
}