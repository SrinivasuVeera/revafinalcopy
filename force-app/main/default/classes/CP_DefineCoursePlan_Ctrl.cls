public with sharing class CP_DefineCoursePlan_Ctrl 
{
    @AuraEnabled
    public static WrapSaveCourseOffering savelastCourses(string str_selectedcourse,string str_course)
    {
        WrapSaveCourseOffering objWrpsave = new WrapSaveCourseOffering();
        set<Id> set_CourseOffIds = new set<Id>();
        set<Id> set_CourseunitsIds = new set<Id>();
        string str_courseOff;
        string str_seltdcourse;
        List<Course_Plan_Unit__c> lst_courseplanunits = new List<Course_Plan_Unit__c>();
        objWrpsave.lst_rtrnPlanunits = new List<Course_Plan_Unit__c>();
        try
        {
            for(hed__Course_Offering__c objCourseoff :[select Id,Name from hed__Course_Offering__c where Id =: str_selectedcourse])
            {
                set_CourseOffIds.add(objCourseoff.Id);  
            }
            for(hed__Course_Offering__c objCourseplanunit :[select Id,Name,hed__Course__c from hed__Course_Offering__c where Id =: str_course ])
            {
                str_courseOff = objCourseplanunit.Id;
                str_seltdcourse = objCourseplanunit.hed__Course__c;
            }
            decimal maxsequence;
            for(AggregateResult objAgg : [select Max(Sequence_No__c) maxseq from Course_Plan_Unit__c where Course_Offering__c = : str_courseOff])
            {
                maxsequence = (decimal)objAgg.get('maxseq'); 
            }
            decimal IntUnit;
            if(maxsequence != null)
              IntUnit =maxsequence;
            else
                IntUnit = 0;
            for(Course_Plan_Unit__c objCourseplanunit :[select Id,Name,Old_unit_ID__c,Sequence_No__c,(select Id,Name,Old_Unit_ID__c,Old_Topic_ID__c,Course_Plan_Unit__c from Course_Plan_Topics__r)Course_Offering__c,Course__c from Course_Plan_Unit__c 
                                                        where Course_Offering__c IN : set_CourseOffIds])
            {
                objWrpsave.lst_rtrnPlanunits.add(objCourseplanunit);
                set_CourseunitsIds.add(objCourseplanunit.Old_unit_ID__c);
                Course_Plan_Unit__c objCrseunit = new Course_Plan_Unit__c();
                objCrseunit.Old_unit_ID__c = objCourseplanunit.Id;
                objCrseunit.Course_Offering__c = str_courseOff;
                objCrseunit.Course__c = str_seltdcourse;
                objCrseunit.Name = objCourseplanunit.Name;
                IntUnit = IntUnit +1;
                objCrseunit.Sequence_No__c = IntUnit;
                lst_courseplanunits.add(objCrseunit);
            }
            if(!lst_courseplanunits.IsEmpty())
            {
                Database.Upsert(lst_courseplanunits, Course_Plan_Unit__c.Old_Unit_ID__c);
            }   
            objWrpsave.strMessage = 'Success';
            return objWrpsave;
        }
        catch(Exception ex)
        {
            objWrpsave.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objWrpsave;
        }            
    }
    
    @AuraEnabled
    public static WrapgetlastCourseOfferings getlastCourseOfferings(string str_CourseOfferingId)
    {
        WrapgetlastCourseOfferings objWrpOffrings = new WrapgetlastCourseOfferings();
        set<Id> set_CourseIds = new set<Id>();
        set<Id> set_SemesterIds = new set<Id>();
        set<DateTime> set_Coursedates = new set<DateTime>();
        objWrpOffrings.map_CourseOfferings = new Map<Id,string>();
        for(hed__Course_Offering__c objCourseOff :[select Id,Name,hed__Term__c,hed__Course__c,CreatedDate from hed__Course_Offering__c where Id =: str_CourseOfferingId])
        {
            set_CourseIds.add(objCourseOff.hed__Course__c);
            set_Coursedates.add(objCourseOff.CreatedDate);
            if(string.IsNotBlank(objCourseOff.hed__Term__c)) set_SemesterIds.add(objCourseOff.hed__Term__c);
        }
        
        if(!set_CourseIds.IsEmpty())
        {
            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
            
            for(hed__Course_Offering__c objCourseOff :[select Id,Name,hed__Course__c,hed__Term__c,hed__Term__r.Name,hed__Term__r.recordTypeId from hed__Course_Offering__c 
                                                       where (hed__Course__c IN: set_CourseIds and Id !=: str_CourseOfferingId and CreatedDate <=: set_Coursedates and hed__Term__r.recordTypeId =: termRtId)  Limit 5])
            {
                objWrpOffrings.map_CourseOfferings.put(objCourseOff.Id,objCourseOff.Name+' - '+objCourseOff.hed__Term__r.Name);  
            }
        }
        return objWrpOffrings;
        
    }
    @AuraEnabled
    public static WrapcourseOffering getCourseOfferdetails(string str_courseId)
    {
        WrapcourseOffering objWrpcourse = new WrapcourseOffering();
        objWrpcourse.objcourseOffering = new hed__Course_Offering__c();
        objWrpcourse.objSemester = new hed__Term__c();
        //objWrpcourse.objParentSemester = new hed__Term__c();
        objWrpcourse.objcourseOffering = [select Id,Name,hed__Term__c,hed__Term__r.Name from hed__Course_Offering__c where Id =: str_courseId];
        if(objWrpcourse.objcourseOffering.hed__Term__c != null)
        {
          objWrpcourse.objSemester = [select Id,Name,hed__Parent_Term__c,Program_Batch__r.Name,Program_Batch__c from hed__Term__c where Id =:objWrpcourse.objcourseOffering.hed__Term__c];
        }
        //system.debug('======= WrpCourse ======'+objWrpcourse);
        return objWrpcourse;
    }
    
    @AuraEnabled
    public static WrapCourseUnits getCourseplanunits(string str_courseoffering)
    {
        WrapCourseUnits objWrpunits = new WrapCourseUnits();
        objWrpunits.lst_courseunits = new List<Course_Plan_Unit__c>();
        objWrpunits.lst_courseunits = new List<Course_Plan_Unit__c>([select Id,Name,(SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.CreatedDate, ContentDocument.ContentSize 
                                                                                     ,ContentDocument.Owner.Name FROM ContentDocumentLinks),Course_Offering__c from Course_Plan_Unit__c where Course_Offering__c =: str_courseoffering Order by Sequence_No__c]);
        return objWrpunits;      
    }
    
    @AuraEnabled
    public static WrapDeleteCoursePlanUnit deleteCoursePlanUnits(string str_courseplanunit)
    {
        WrapDeleteCoursePlanUnit objwrp = new WrapDeleteCoursePlanUnit();
        set<Id> set_crplIds = new set<Id>();
        List<Course_Plan_Unit__c> list_coursepln = new List<Course_Plan_Unit__c>();
        List<Course_Plan_Topic__c> list_courseTopics = new List<Course_Plan_Topic__c>();
        try{
            for(Course_Plan_Unit__c objCourseplanunit :[select Id,(SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.CreatedDate, ContentDocument.ContentSize 
                                                                   ,ContentDocument.Owner.Name FROM ContentDocumentLinks),Name from Course_Plan_Unit__c where Id =: str_courseplanunit])
            {
                set_crplIds.add(objCourseplanunit.Id);
                list_coursepln.add(objCourseplanunit);  
            }
            for(Course_Plan_Topic__c objCourseplantopic :[select Id,Name,(SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.CreatedDate, ContentDocument.ContentSize 
                                                                          ,ContentDocument.Owner.Name FROM ContentDocumentLinks),Course_Plan_Unit__c from Course_Plan_Topic__c where Course_Plan_Unit__c In :set_crplIds])
            {
                list_courseTopics.add(objCourseplantopic);  
            }
            if(!list_coursepln.IsEmpty())
            {
                delete list_coursepln;
            }
            if(!list_courseTopics.IsEmpty())
            {
                delete list_courseTopics;
            }
            objwrp.strMessage = 'Success';
            return objwrp;
        }
        catch(Exception ex)
        {
            objwrp.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objwrp;
        }            
    }
    
    @AuraEnabled
    public static WrapDeleteCoursePlanTopics deleteCoursePlanTopics(string str_crsetopics)
    {
        WrapDeleteCoursePlanTopics objWrptopics = new WrapDeleteCoursePlanTopics();
        List<Course_Plan_Topic__c> list_courseTopics = new List<Course_Plan_Topic__c>();
        try
        {
            for(Course_Plan_Topic__c objCourseplantopic :[select Id,Name,(SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.CreatedDate, ContentDocument.ContentSize 
                                                                          ,ContentDocument.Owner.Name FROM ContentDocumentLinks),Course_Plan_Unit__c from Course_Plan_Topic__c where Id =: str_crsetopics])
            {
                list_courseTopics.add(objCourseplantopic);  
            }
            if(!list_courseTopics.IsEmpty())
            {
                delete list_courseTopics;
            }
            objWrptopics.strMessage = 'Success';
            return objWrptopics;           
        }
        catch(Exception ex)
        {
            objWrptopics.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objWrptopics;
        }  
    }
    
    @AuraEnabled 
    public static WrapDeleteUnitsDoc deleteUnitsDoc(string str_file)
    {
        WrapDeleteUnitsDoc objWrpdelte = new WrapDeleteUnitsDoc();
        set<Id> set_condcIds = new set<Id>();
        list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();
        try
        {     
            for(ContentDocument  objContentLink :[select Id,FileType,Title from ContentDocument where Id =: str_file ])
            {
                lstCntDocsToDelete.add(objContentLink);  
            }
            if(!lstCntDocsToDelete.IsEmpty())
            {
                delete lstCntDocsToDelete;
            }
            objWrpdelte.strMessage = 'Success';
            return objWrpdelte;           
        }
        catch(Exception ex)
        {
            objWrpdelte.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objWrpdelte;
        }         
    }
    
    @AuraEnabled 
    public static WrapDeleteTopicsDoc deleteTopicsDoc(string str_file)
    {
        WrapDeleteTopicsDoc objWrpdelte = new WrapDeleteTopicsDoc();
        set<Id> set_condcIds = new set<Id>();
        list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();
        try
        {     
            for(ContentDocument  objContentLink :[select Id,Title,FileType
                                                      from ContentDocument where Id =: str_file])
            {
                lstCntDocsToDelete.add(objContentLink);  
            }
            if(!lstCntDocsToDelete.IsEmpty())
            {
                delete lstCntDocsToDelete;
            }
            objWrpdelte.strMessage = 'Success';
            return objWrpdelte;           
        }
        catch(Exception ex)
        {
            objWrpdelte.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objWrpdelte;
        }         
    }
    
    @AuraEnabled
    public static WrapCourseMain getCourseOfferingUnitsDetails(string str_CourseId)
    {
        WrapCourseMain objWrpCourse = new WrapCourseMain();
        set<Id> set_CrsePlanIds = new set<Id>();       
        Map<string,wrapcourse> map_Coursewrp = new Map<string,wrapcourse>();
        
        for(Course_Plan_Unit__c objCourseUnit :[select Id,Name,Course_Offering__c from Course_Plan_Unit__c where 
                                                Course_Offering__c =: str_CourseId])
        {
            wrapcourse objwrpcourseunit = new wrapcourse(); 
            objwrpcourseunit.coursePlanId = objCourseUnit.Id;
            objwrpcourseunit.courseplanunit = objCourseUnit.Name;
            objWrpCourse.map_Coursewrp.put(objwrpcourseunit.coursePlanId, objwrpcourseunit);
        }
        for(Course_Plan_Topic__c objCourseTopic :[select Id,Name,(SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.CreatedDate, ContentDocument.ContentSize 
                                                                          ,ContentDocument.Owner.Name FROM ContentDocumentLinks),Course_Plan_Unit__c from Course_Plan_Topic__c where
                                                  Course_Plan_Unit__c In : objWrpCourse.map_Coursewrp.keyset() order by Sequence_No__c])
        {
            string strkey = objCourseTopic.Course_Plan_Unit__c;
            WrapCoursetopics objWrpTopic = getCourseTopicsDetails(objCourseTopic);
            
            if(objWrpCourse.map_Coursewrp.get(strkey) != null)
            {
                objWrpTopic.topicname = objCourseTopic.Name;
                objWrpTopic.topicId = objCourseTopic.Id;
                objWrpTopic.courseunit = objCourseTopic.Course_Plan_Unit__c;
                if(objCourseTopic.ContentDocumentLinks.size() > 0)
                {
                   objWrpTopic.fileexists = true; 
                }
                objWrpCourse.map_Coursewrp.get(strkey).lst_WrapCourses.add(objWrpTopic);  
            }           
        }
        return objWrpCourse;
        
    }
    
    @AuraEnabled
    public static WrapSaveCourseTopics saveCourseTopics(string str_courseTopics)
    {
        WrapSaveCourseTopics objWrptopics = new WrapSaveCourseTopics();
        List<WrapCoursetopics> list_course = (List<WrapCoursetopics>)JSON.deserialize(str_courseTopics, List<WrapCoursetopics>.class);
        system.debug('===== Course wrap ===='+list_course);
        system.debug('===== Course wrap size ===='+list_course.size());
        set<Id> set_UnitsIds = new set<Id>();
        List<Course_Plan_Topic__c> lst_Topic = new List<Course_Plan_Topic__c>();
        List<Course_Plan_Topic__c> list_Topics = new List<Course_Plan_Topic__c>();
        try
        {
            for(WrapCoursetopics objPlantopics : list_course)
            {
                Course_Plan_Topic__c objTopic = new Course_Plan_Topic__c();
                objTopic.Course_Plan_Unit__c = objPlantopics.courseunit;
                objTopic.Name = objPlantopics.topicname;
                if(string.IsnotBlank(objPlantopics.topicId))
                    objTopic.Id = objPlantopics.topicId;
                list_Topics.add(objTopic);  
            }
           system.debug('==== Topics ======='+list_Topics);
            system.debug('==== topics size ======'+list_Topics.size());
            if(!list_Topics.IsEmpty())
            {
                Database.Upsert(list_Topics, Course_Plan_Topic__c.Id);
            }
            decimal topicsequence;
           
            objWrptopics.strMessage = 'Success';
            return objWrptopics; 
        }
        catch(Exception ex)
        {
            objWrptopics.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objWrptopics;
        }  
    }
    
    @AuraEnabled 
    public static WrapSaveCourseOfferingUnits savecoursunits(string CourseOfferId,List<Course_Plan_Unit__c> lst_planunits)
    {
        WrapSaveCourseOfferingUnits objWrpunits = new WrapSaveCourseOfferingUnits();
        string str_courseId;
        List<Course_Plan_Unit__c> lst_Courseplan = new List<Course_Plan_Unit__c>();
        try
        {
            for(hed__Course_Offering__c objCourseOffering :[select Id,Name,hed__Course__c from hed__Course_Offering__c 
                                                            where Id =: CourseOfferId])
            {
                str_courseId = objCourseOffering.hed__Course__c;
            }
            if(!lst_planunits.IsEmpty())
            {
                Integer unitcount =0;
                for(Course_Plan_Unit__c objPlan : lst_planunits)
                {
                    unitcount = unitcount +1;
                    objPlan.Sequence_No__c = unitcount;
                    objPlan.Course_Offering__c = CourseOfferId;
                    objPlan.Course__c = str_courseId;
                    lst_Courseplan.add(objPlan);   
                }
                
            }
            
            if(!lst_Courseplan.IsEmpty())
            {
                upsert lst_Courseplan;    
            }
            objWrpunits.strMessage = 'Success';
            return objWrpunits;
        }
        catch(Exception ex)
        {
            objWrpunits.strMessage = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objWrpunits;
        }  
    }
    
    @AuraEnabled
    public static WrapGetTopicsDocumentsAfterdelete getTopicsDocaftrDlt(string str_seltopicId)    
    {
        WrapGetTopicsDocumentsAfterdelete objWrpdlt = new WrapGetTopicsDocumentsAfterdelete();
        set<Id> set_documentIds = new set<Id>();
        
        for(ContentDocumentLink objContentdoumentlink :[select Id,ContentDocument.Title,ContentDocumentId,LinkedEntityId
                                         from ContentDocumentLink where 
                                         LinkedEntityId =: str_seltopicId])
        {
          set_documentIds.add(objContentdoumentlink.ContentDocumentId);  
        }
        
        objWrpdlt.list_contentversions = new List<ContentDocument>();
        objWrpdlt.list_contentversions =[select Id,Title,FileType
                                         from ContentDocument where 
                                         Id In : set_documentIds];
        return objWrpdlt;
        
    }
    
    @AuraEnabled
    public static WrapGetUnitsDocumentsAfterdelete getUnitsDocAftrDlt(string str_selplanunitId)
    {
        WrapGetUnitsDocumentsAfterdelete objWrpdlt = new WrapGetUnitsDocumentsAfterdelete();
        set<Id> set_documentIds = new set<Id>();
        
        for(ContentDocumentLink objContentdoumentlink :[select Id,ContentDocument.Title,ContentDocumentId,LinkedEntityId
                                         from ContentDocumentLink where 
                                         LinkedEntityId =: str_selplanunitId])
        {
          set_documentIds.add(objContentdoumentlink.ContentDocumentId);  
        }
        
        objWrpdlt.list_ContentDocuments = new List<ContentDocument>();
        objWrpdlt.list_ContentDocuments =[select Id,Title,FileType
                                         from ContentDocument where 
                                         Id In : set_documentIds];
        return objWrpdlt;
    }
    
    @AuraEnabled
    public static WrapPlanUnitDocuments getSelectedUnitsDocument(string str_slplanId)
    {
        WrapPlanUnitDocuments objWrpdoc = new WrapPlanUnitDocuments();
        set<Id> set_documentIds = new set<Id>();
        
        for(ContentDocumentLink objContentdoumentlink :[select Id,ContentDocument.Title,ContentDocumentId,LinkedEntityId
                                         from ContentDocumentLink where 
                                         LinkedEntityId =: str_slplanId])
        {
          set_documentIds.add(objContentdoumentlink.ContentDocumentId);  
        }
        
        objWrpdoc.list_contentdocuments = new List<ContentDocument>();
        objWrpdoc.list_contentdocuments =[SELECT Id,Title,FileType FROM ContentDocument WHERE Id IN: set_documentIds];
        return objWrpdoc;        
    }
    
    @AuraEnabled
    public static WrapPlanTopicDocuments getSelectedTopicsDocument(string str_slctdtopicId)
    {
        WrapPlanTopicDocuments objWrpdoc = new WrapPlanTopicDocuments();
        set<Id> set_doucmentsIds = new set<Id>();
        
          for(ContentDocumentLink objContentdoumentlink :[select Id,ContentDocument.Title,ContentDocumentId,LinkedEntityId
                                         from ContentDocumentLink where 
                                         LinkedEntityId =: str_slctdtopicId])
        {
            set_doucmentsIds.add(objContentdoumentlink.ContentDocumentId);  
        }
        
        
        objWrpdoc.list_contentversions = new List<ContentDocument>();
        objWrpdoc.list_contentversions =[SELECT Id,Title,FileType FROM ContentDocument WHERE Id IN: set_doucmentsIds];
        return objWrpdoc;        
    }
    
    
    public static WrapCoursetopics getCourseTopicsDetails(Course_Plan_Topic__c objCoursetp)
    {
           
        WrapCoursetopics objWrptopic = new WrapCoursetopics();
        objWrptopic.topicname = objCoursetp.Name;
        objWrptopic.topicId = objCoursetp.Id;
        objWrptopic.courseunit = objCoursetp.Course_Plan_Unit__c;
        return objWrptopic;
    }
    
    public class WrapCourseMain
    {
        @AuraEnabled public Map<string,wrapcourse> map_Coursewrp{get;set;}
        @AuraEnabled public Map<string,string> map_courses{get;set;}
        
        public WrapCourseMain()
        {
            map_Coursewrp = new Map<string,wrapcourse>();
            map_courses = new Map<string,string>();            
        }
    }
    
    Public class WrapDeleteCoursePlanUnit
    {
        @AuraEnabled public String strMessage{get; set;}
    }
    
    public class WrapDeleteUnitsDoc
    {
        @AuraEnabled public String strMessage{get;set;}
    }
    
    public class WrapDeleteTopicsDoc
    {
        @AuraEnabled public String strMessage{get;set;}
    }
    
    public class WrapPlanTopicDocuments
    {
        @AuraEnabled public List<ContentDocument> list_contentversions{get;set;}   
    }
    
    public class WrapGetTopicsDocumentsAfterdelete
    {
        @AuraEnabled public List<ContentDocument> list_contentversions{get;set;} 
    }
    
    public class WrapGetUnitsDocumentsAfterdelete
    {
        @AuraEnabled public List<ContentDocument> list_ContentDocuments{get;set;} 
    }
    
    Public class WrapDeleteCoursePlanTopics
    {
        @AuraEnabled public String strMessage{get; set;}
    }
    
    public class WrapSaveCourseOffering
    {
        @AuraEnabled public String strMessage{get; set;}  
        @AuraEnabled public List<Course_Plan_Unit__c> lst_rtrnPlanunits {get;set;}
    }
    
    public class wrapcourse
    {
        @AuraEnabled public Id coursePlanId{get;set;}
        @AuraEnabled public string courseplanunit{get;set;}
        @AuraEnabled public List<WrapCoursetopics> lst_WrapCourses{get;set;} 
        @AuraEnabled public List<Course_Plan_Topic__c> list_CourseplanTopic{get;set;}
        
        public wrapcourse()
        {
            lst_WrapCourses = new List<WrapCoursetopics>();
            list_CourseplanTopic = new List<Course_Plan_Topic__c>();
        }
    }
    
    public class WrapCoursetopics
    {
        @AuraEnabled public string topicname{get;set;}
        @AuraEnabled public string topicId{get;set;}
        @AuraEnabled public Id courseunit{get;set;}
        @AuraEnabled public boolean fileexists{get;set;}
    }
    
    public class WrapcourseOffering
    {
        @AuraEnabled public hed__Course_Offering__c objcourseOffering{get;set;}  
        @AuraEnabled public hed__Term__c objSemester{get;set;}
        //@AuraEnabled public hed__Term__c objParentSemester{get;set;}
    }
    
    public class WrapCourseUnits
    {
        @AuraEnabled public List<Course_Plan_Unit__c> lst_courseunits{get;set;}
    }
    
    public class WrapPlanUnitDocuments
    {
        @AuraEnabled public List<ContentDocument> list_contentdocuments{get;set;}
    }
    
    public class WrapSaveCourseOfferingUnits
    {
        @AuraEnabled public String strMessage {get; set;}
    }
    
    public class WrapSaveCourseTopics
    {
        @AuraEnabled public string strMessage {get;set;}
    }
    
    public class WrapgetlastCourseOfferings
    {
        @AuraEnabled public Map<Id,string> map_CourseOfferings {get;set;} 
    }
}