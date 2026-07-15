public class ACM_StudentAcademics_Ctrl 
{
    @AuraEnabled
    public static StudentWrapper DisplayAttendance()
    {
        StudentWrapper swrap = new StudentWrapper();
        Set<String> set_OfferingIds = new Set<String>();
        Set<Id> set_Ids = new Set<Id>();
        Set<Id> set_BatchIds = new Set<Id>();
        User usr =[select Id,Name,ContactId from User where Id =:userinfo.getUserId()];
        date dt = system.today();
        if(usr.ContactId != null)
        {            
            Contact objCon = [select Id,LastName,Program_Batch__c,Program_Batch__r.Name,RecordType.Name,Active_Section__c,Active_Section__r.Section_Name__c,
                              Active_Semester__c,Active_Semester__r.Term_Number__c from Contact 
                              Where id =: usr.ContactId and RecordType.Name =: Utility.Contact_RecType_Student];
            if(objCon.Program_Batch__r.Name != null)
                swrap.ProgramName = objCon.Program_Batch__r.Name;
            if(objCon.Active_Semester__r.Term_Number__c != null)
                swrap.SemesterNo = string.valueof(objCon.Active_Semester__r.Term_Number__c);
            if(objCon.Active_Section__r.Section_Name__c != null)
                swrap.SectionName = objCon.Active_Section__r.Section_Name__c;
            swrap.lst_sch = new list<hed__Course_Offering_Schedule__c>();
            for(hed__Course_Enrollment__c eachConn : [SELECT Id, hed__Course_Offering__c,hed__Course_Offering__r.Category__c,Section__c FROM hed__Course_Enrollment__c 
                                                      WHERE Active_Connection__c = true and hed__Contact__c =: objCon.id])
            {
                if(eachConn.hed__Course_Offering__c!= null) set_OfferingIds.add(eachConn.hed__Course_Offering__c); 
                if(eachConn.hed__Course_Offering__r.Category__c =='Hardcore Course' || eachConn.hed__Course_Offering__r.Category__c =='Hardcore Integrated Course'
                   || eachConn.hed__Course_Offering__r.Category__c =='Mandatory Course')
                {
                    if(eachConn.Section__c!= null) set_Ids.add(eachConn.Section__c);
                }
                if(eachConn.hed__Course_Offering__r.Category__c =='Practical/Term work' || eachConn.hed__Course_Offering__r.Category__c =='Professional Elective'
                   || eachConn.hed__Course_Offering__r.Category__c =='Open Elective')
                {
                    if(eachConn.Section__c!= null) set_BatchIds.add(eachConn.Section__c);
                }                
            }
            set_Ids.add(null); 
            set_BatchIds.add(null);
            if(set_OfferingIds.size()>0)
            {
                for(hed__Course_Offering_Schedule__c cosObj : [SELECT Id,hed__Start_Time__c,hed__End_Time__c,hed__Course_Offering__c,Status__c,Batch_Group__c,
                                                               hed__Course_Offering__r.Name,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,Professor__r.Name,
                                                               Display_Name__c,hed__Course_Offering__r.Category__c,Course_ID__c,Professor__c,Section__c
                                                               FROM hed__Course_Offering_Schedule__c WHERE Date__c =: dt and 
                                                               ((Section__c in: set_Ids and Batch_Group__c in: set_BatchIds and hed__Course_Offering__c in:set_OfferingIds)
                                                                or (Section__c in: set_Ids and hed__Course_Offering__c = null and Batch_Group__c = null and
                                                                    (hed__Course_Offering__c !=null or Display_Name__c != null)))
                                                               Order by hed__Start_Time__c ASC])
                {
                    swrap.lst_sch.add(cosObj);
                }
            }
        }
        return swrap;
    }
    @AuraEnabled
    public static PlanWrapper DisplayPlanTopic(string CourSchid)
    {
        PlanWrapper planWrap = new PlanWrapper();
        planWrap.lst_file = new list<ContentDocumentLink>(); 
        set<id> set_planid = new set<id>();
        set<id> set_ActualTopicid = new set<id>();
        for(hed__Course_Offering_Schedule__c objsch : [select id,Name,Actual_Topic__c,Planned_Topic__c,Actual_Topic__r.Name,Planned_Topic__r.Name
                                                       from hed__Course_Offering_Schedule__c where id =: CourSchid])
        {
            if(objsch.Actual_Topic__c != null)
            {
                set_ActualTopicid.add(objsch.Actual_Topic__c);
                planWrap.ActualTopicName = objsch.Actual_Topic__r.Name;
            }
            if(objsch.Planned_Topic__c !=null)
            {
                set_planid.add(objsch.Planned_Topic__c);            
                planWrap.PlannedTopicName = objsch.Planned_Topic__r.Name;
            }
        }
        if(set_ActualTopicid.size()>0 || set_planid.size()>0)
        {
            for(ContentDocumentLink objConDoc : [SELECT Id, LinkedEntityId,ContentDocumentId,Visibility,IsDeleted,ShareType,ContentDocument.Title,
                                                 ContentDocument.createdDate,ContentDocument.FileType FROM ContentDocumentLink
                                                 WHERE (LinkedEntityId in:set_planid or LinkedEntityId in:set_ActualTopicid)])
            {
                planWrap.lst_file.add(objConDoc);
            }
        }
        return planWrap;
    }   
    Public class StudentWrapper
    {
        @AuraEnabled public string ProgramName{get;set;}
        @AuraEnabled public string SemesterNo{get;set;}
        @AuraEnabled public string SectionName{get;set;}
        @AuraEnabled public list<hed__Course_Offering_Schedule__c> lst_sch{get;set;} 
    }
    public class PlanWrapper
    {
        @AuraEnabled public string ActualTopicName{get;set;}
        @AuraEnabled public string PlannedTopicName{get;set;}
        @AuraEnabled public list<ContentDocumentLink> lst_file{get;set;}
    }
}