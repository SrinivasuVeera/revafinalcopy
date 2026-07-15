public with sharing class ATT_StudentAttendance_Ctrl 
{
    @AuraEnabled(cacheable=true)
    public static StudentWrapper DisplayAttendance()
    {
        StudentWrapper swrap = new StudentWrapper();
        set<id> set_conid = new set<id>();
        set<String> set_Sectionids = new set<String>();
        Set<String> set_OfferingIds = new Set<String>();
        User usr =[select Id,Name,ContactId from User where Id =:userinfo.getUserId()];
        //usr.ContactId = '0030w00000qFcbKAAS';
         string ContactId;
        if(usr.ContactId != null)
        {            
            Contact objcont =[select Id,Name,Recordtype.Name,ReportsToId from Contact where id=: usr.ContactId];
            if(objcont.Recordtype.Name == utility.Contact_RecType_Student) ContactId =objcont.id;
            else if(objcont.Recordtype.Name == utility.Contact_RecType_Parent) ContactId =objcont.ReportsToId;
            
            Contact objCon = [select Id,LastName,Program_Batch__c,Program_Batch__r.Name,RecordType.Name,Active_Section__c,Active_Section__r.Section_Name__c,
                              Active_Semester__c,Active_Semester__r.Term_Number__c from Contact 
                              Where id =: ContactId and RecordType.Name =: Utility.Contact_RecType_Student];
            if(objCon.Program_Batch__r.Name != null)
            swrap.ProgramName = objCon.Program_Batch__r.Name;
            swrap.ProgramBatchId = objCon.Program_Batch__c;
            swrap.ActiveSemester = objCon.Active_Semester__c;
            if(objCon.Active_Semester__r.Term_Number__c != null)
                swrap.SemesterNo = string.valueof(objCon.Active_Semester__r.Term_Number__c);
            if(objCon.Active_Section__r.Section_Name__c != null)
                swrap.SectionName = objCon.Active_Section__r.Section_Name__c;            
            swrap.BatchRecName = utility.Term_Object_RecType_Batches;
            swrap.GroupRecName =utility.Term_RecType_Group;
            swrap.map_Faculty = new map<id,FacultyMapWrapper>();
            for(hed__Course_Enrollment__c eachConn : [SELECT Id,hed__Course_Offering__c,Feedback_on_course__c,Feedback_on_faculty__c, hed__Course_Offering__r.Category__c,Section__c,hed__Course_Offering__r.Name,
                                                      Course_Code__c,Total_Classes_Attended__c,Total_Classes_Completed__c,Classes_Attended__c,Section__r.Recordtype.Name,
                                                      Section__r.Batch_Number__c,Section__r.Group_Number__c,Section__r.Name
                                                      FROM hed__Course_Enrollment__c WHERE Active_Connection__c = true and hed__Contact__c =: objCon.Id]) 
            {
                if(eachConn.hed__Course_Offering__c != null) set_OfferingIds.add(eachConn.hed__Course_Offering__c);
                if(eachConn.Section__c != null) set_Sectionids.add(eachConn.Section__c);
                FacultyMapWrapper fwrap = new FacultyMapWrapper();
                fwrap.CourseConnectionId = eachConn.Id;
                fwrap.CourseOfferingId = eachConn.hed__Course_Offering__c;
                fwrap.FeedbackCourse = eachConn.Feedback_on_course__c;
                fwrap.FeedbackFaculty = eachConn.Feedback_on_faculty__c;
                fwrap.courseCode = eachConn.Course_Code__c;
                fwrap.sectionId = eachConn.Section__c;
                fwrap.Category = eachConn.hed__Course_Offering__r.Category__c;
                fwrap.CourseOfferingName = eachConn.hed__Course_Offering__r.Name;
                fwrap.BatchNumber = eachConn.Section__r.Batch_Number__c;
                fwrap.GroupNume = eachConn.Section__r.Name.substringAfterLast('-');
                fwrap.TotalClassCom = eachConn.Total_Classes_Completed__c;
                fwrap.TotalClassAtt = eachConn.Total_Classes_Attended__c;
                fwrap.TotalPercentage = eachConn.Classes_Attended__c;
                fwrap.RecType = eachConn.Section__r.Recordtype.Name;
                swrap.map_Faculty.put(eachConn.hed__Course_Offering__c,fwrap);
            }
            if(set_OfferingIds.size() >0 && set_Sectionids.size()>0)
            {
                Id facRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
                for(hed__Course_Enrollment__c eachConn : [SELECT Id,Course_Code__c,hed__Course_Offering__r.Name,hed__Contact__r.Name,Section__c,
                                                          hed__Course_Offering__r.Category__c FROM hed__Course_Enrollment__c
                                                          where RecordTypeId =: facRecordTypeId and hed__Course_Offering__c in: set_OfferingIds 
                                                          and Section__c in: set_Sectionids]) 
                {
                    for(string str: swrap.map_Faculty.keyset())
                    {
                        swrap.map_Faculty.get(eachConn.hed__Course_Offering__c).facultyName = eachConn.hed__Contact__r.Name;
                    }
                }
            }
        }
        return swrap;
    }
    
    Public class StudentWrapper
    {
        @AuraEnabled public string ProgramName{get;set;}
        @AuraEnabled public string ProgramBatchId{get;set;}
        @AuraEnabled public string ActiveSemester{get;set;}
        @AuraEnabled public string SemesterNo{get;set;}
        @AuraEnabled public string SectionName{get;set;}        
        @AuraEnabled public string BatchRecName{get;set;}
        @AuraEnabled public string GroupRecName{get;set;}
        @AuraEnabled public map<Id,FacultyMapWrapper> map_Faculty{get;set;}
    }
    public class FacultyMapWrapper
    {
        @AuraEnabled public String CourseConnectionId {get;set;}
        @AuraEnabled public String CourseOfferingId {get;set;}
        @AuraEnabled public Boolean FeedbackCourse {get;set;}
        @AuraEnabled public Boolean FeedbackFaculty {get;set;}
        @AuraEnabled public String  courseCode {get;set;}
        @AuraEnabled public string  sectionId {get;set;}
        @AuraEnabled public String  facultyName {get;set;}
        @AuraEnabled public String  CourseOfferingName {get;set;}
        @AuraEnabled public String  Category {get;set;}
        @AuraEnabled public decimal  BatchNumber {get;set;}
        @AuraEnabled public string  GroupNume {get;set;}
        @AuraEnabled public decimal  TotalClassCom {get;set;}
        @AuraEnabled public decimal  TotalClassAtt {get;set;}
        @AuraEnabled public decimal  TotalPercentage {get;set;}
        @AuraEnabled public string  RecType {get;set;}
    }
}