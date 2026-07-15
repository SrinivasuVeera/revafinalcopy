public with sharing class MSTR_StudentElectiveGroupAllocation_Ctrl 
{
    @AuraEnabled
    public Static DetailsWrp getTermAndElectiveDetails(String recordId)
    {
        DetailsWrp objDetailsWrp = new DetailsWrp();
        for(hed__Term__c objTerm : [Select Id, Name, Program_Batch__c, Program_Batch__r.Name from hed__Term__c 
                                    where Id =: recordId])
        {
            objDetailsWrp.objTerm = objTerm;
        }
        
        for(hed__Course_Offering__c objCourseOffr : [Select Id, Name, Category__c, hed__Course__c, hed__Term__c,
                                                     hed__Course__r.Name, Parent_Course_Offering__r.Name, 
                                                     Parent_Course_Offering__c, Assigned__c from hed__Course_Offering__c 
                                                     where hed__Term__c =: recordId AND Parent_Course_Offering__r.Name != Null
                                                     AND Category__c IN ('Professional Elective','Open Elective')
                                                     AND Active__c =: True AND Assigned__c > 0
                                                     ORDER BY Parent_Course_Offering__r.Name])
        {
            ElectiveWrp objElectWrp = new ElectiveWrp();
            objElectWrp.parentCourseName = objCourseOffr.Parent_Course_Offering__r.Name;
            objElectWrp.parentCourseId = objCourseOffr.Parent_Course_Offering__c;
            objElectWrp.subjectName = objCourseOffr.Name;
            objElectWrp.subjectID = objCourseOffr.Id;
            objElectWrp.courseCode = objCourseOffr.hed__Course__r.Name;
            objElectWrp.totlNoOfStudents = Integer.valueOf(objCourseOffr.Assigned__c);
            if(objDetailsWrp.map_ElectiveWrp.get(objElectWrp.parentCourseName) == Null)
            {
                objDetailsWrp.map_ElectiveWrp.put(objElectWrp.parentCourseName, new List<ElectiveWrp>());
            }
            objDetailsWrp.map_ElectiveWrp.get(objElectWrp.parentCourseName).add(objElectWrp);
        }
        //System.debug('objDetailsWrp.map_ElectiveWrp=='+objDetailsWrp.map_ElectiveWrp);
        return objDetailsWrp;
    }
    
    @AuraEnabled
    public static WrapperClass createElectiveGroups(Integer noOfGroup, String subjectId, String courseCode, String recordId)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        hed__Term__c objTerm = new hed__Term__c();
        objTerm = [Select Id, Name, hed__Account__c from hed__Term__c where Id =: recordId];
        String recTypeName = Utility.Term_RecType_Group;
        String recTypeId = Schema.getGlobalDescribe().get('hed__Term__c').getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        List<hed__Term__c> lstGroups = new List<hed__Term__c>();
        try
        {
            for(Integer i=0; i< noOfGroup; i++)
            {
                String groupAlpha = String.fromCharArray( new List<integer> { 65 + i} );
                hed__Term__c objGroup = new hed__Term__c();
                objGroup.RecordTypeId = recTypeId;
                objGroup.hed__Account__c = objTerm.hed__Account__c;
                objGroup.Name = courseCode+'-'+groupAlpha; //objTerm.Name+'-'+courseCode+'-'+groupAlpha;
                objGroup.Course_Offering__c = subjectId;
                objGroup.hed__Parent_Term__c = recordId;
                objGroup.Group_Number__c = i+1;
                lstGroups.add(objGroup);
            }
            if(lstGroups.size() >0)
                Insert lstGroups;
            objWrapperClass.strMessage = 'Success';
        }
        Catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage();
        }
        return objWrapperClass;
    }
    
    @AuraEnabled 
    public static WrapperClass deleteExistingGroupAllocations(String subjectId, String recordId)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        String recTypeName = Utility.Term_RecType_Group;
        
        List<hed__Term__c> lstGroupAllocation = new List<hed__Term__c>();
        Set<String> set_GroupIds = new Set<String>();
        try
        {
            for(hed__Term__c objGroup : [Select Id from hed__Term__c where Course_Offering__c =:subjectId 
                                         AND hed__Parent_Term__c=:recordId AND RecordType.Name=:recTypeName])
            {
                set_GroupIds.add(objGroup.Id);
                lstGroupAllocation.add(objGroup);
            }
            
            if(!set_GroupIds.isEmpty())
            {
                List<Student_Semester_Mapping__c> lstStudMap = new List<Student_Semester_Mapping__c>();
                lstStudMap = [Select Id from Student_Semester_Mapping__c where Student_Group__c IN: set_GroupIds];
                if(lstStudMap.size() > 0)
                    delete lstStudMap;
            }
            
            if(lstGroupAllocation.size() > 0)
                Delete lstGroupAllocation;
            objWrapperClass.strMessage = 'Success';
        }
        Catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage();
        }
        return objWrapperClass;
    }
    
    @AuraEnabled 
    public static WrapperClass getExistingGroups(String subjectId, String recordId)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        List<hed__Term__c> lstGroupAllocation = new List<hed__Term__c>();
        String recTypeName = Utility.Term_RecType_Group;
        Set<Id> set_GroupIds = new Set<Id>();
        Set<Id> set_ProgEnrollId = new Set<Id>();
        Integer count = 0; 
        for (hed__Term__c objGroup : [Select Id, Name, Group_Number__c from hed__Term__c where RecordType.Name=:recTypeName
                                      AND Course_Offering__c =:subjectId AND hed__Parent_Term__c=:recordId])
        {
            GroupWrapperClass objGrpWrp = new GroupWrapperClass();
            objGrpWrp.groupNo = String.valueOf(objGroup.Group_Number__c);
            objGrpWrp.groupName = objGroup.Name;
            objGrpWrp.groupId = objGroup.Id;
            objWrapperClass.objGroupMainWrp.map_GroupWrp.put(objGrpWrp.groupNo, objGrpWrp);
            objWrapperClass.objGroupMainWrp.map_Groups.put(objGrpWrp.groupNo, objGrpWrp.groupName);
            objWrapperClass.objGroupMainWrp.map_GroupDetails.put(String.valueOf(objGroup.Group_Number__c), objGroup);
            set_GroupIds.add(objGroup.Id);
        }
        
        if(!set_GroupIds.isEmpty())
        {
            for(Student_Semester_Mapping__c objSTMGroup : [Select Id, Name, Program_Enrollment__c, Student_Group__c,
                                                           Program_Enrollment__r.Name, Program_Enrollment__r.SRN_Number__c,
                                                           Program_Enrollment__r.Section__c, Student_Group__r.Course_Offering__c, 
                                                           Student_Group__r.Course_Offering__r.Name, Student_Group_Number__c,
                                                           Program_Enrollment__r.Section__r.Name, Student_Group__r.Name,
                                                           Program_Enrollment__r.hed__Contact__c, Program_Enrollment__r.hed__Program_Plan__c, 
                                                           Program_Enrollment__r.hed__Contact__r.Name, Program_Enrollment__r.Semester__c, 
                                                           Program_Enrollment__r.Semester__r.Name, Course_Offering_ID__c from 
                                                           Student_Semester_Mapping__c where Student_Group__c IN: set_GroupIds AND 
                                                           Student_Group__r.Course_Offering__c =: subjectId ORDER BY 
                                                           Program_Enrollment__r.SRN_Number__c ASC])
            {
                courseConnectionWrp objCourseConnection = new courseConnectionWrp();
                objCourseConnection.isChecked = false;
                objCourseConnection.contactId = objSTMGroup.Program_Enrollment__r.hed__Contact__c;
                objCourseConnection.contactName = objSTMGroup.Program_Enrollment__r.hed__Contact__r.Name;
                objCourseConnection.progEnrollId = objSTMGroup.Program_Enrollment__c;
                objCourseConnection.progEnrollName = objSTMGroup.Program_Enrollment__r.Name;
                objCourseConnection.srnNumber = objSTMGroup.Program_Enrollment__r.SRN_Number__c;
                objCourseConnection.sectionId = objSTMGroup.Program_Enrollment__r.Section__c;
                objCourseConnection.sectionName = objSTMGroup.Program_Enrollment__r.Section__r.Name;
                objCourseConnection.progPlanId = objSTMGroup.Program_Enrollment__r.hed__Program_Plan__c;
                objCourseConnection.semesterId = objSTMGroup.Program_Enrollment__r.Semester__c;
                objCourseConnection.semesterName = objSTMGroup.Program_Enrollment__r.Semester__r.Name;
                objCourseConnection.subjectId = objSTMGroup.Student_Group__r.Course_Offering__c;
                objCourseConnection.subjectName = objSTMGroup.Student_Group__r.Course_Offering__r.Name;
                //objCourseConnection.courseOfferId = objSTMGroup.Course_Offering_ID__c;
                
                String strKey = String.valueOf(objSTMGroup.Student_Group_Number__c);
                if(objWrapperClass.objGroupMainWrp.map_GroupWrp.get(strKey) != Null)
                {
                    objCourseConnection.groupId = objWrapperClass.objGroupMainWrp.map_GroupWrp.get(strKey).groupId;
                    objCourseConnection.oldGroupId = objWrapperClass.objGroupMainWrp.map_GroupWrp.get(strKey).groupId;
                    objCourseConnection.groupName = objWrapperClass.objGroupMainWrp.map_GroupWrp.get(strKey).groupName;
                    objCourseConnection.groupNo = objWrapperClass.objGroupMainWrp.map_GroupWrp.get(strKey).groupNo;
                    objWrapperClass.objGroupMainWrp.map_GroupWrp.get(strKey).lstcourseCons.add(objCourseConnection);
                    set_ProgEnrollId.add(objSTMGroup.Program_Enrollment__c);
                }
            }
        }

        if(!set_ProgEnrollId.isEmpty())
        {
            for(hed__Course_Enrollment__c objCourseConn : [Select Id, Name, Section__c, Section__r.Name, hed__Program_Enrollment__c,
                                                           hed__Program_Enrollment__r.Name, hed__Program_Enrollment__r.SRN_Number__c,
                                                           hed__Program_Enrollment__r.hed__Contact__r.Name, Section__r.hed__Parent_Term__c,
                                                           hed__Program_Enrollment__r.hed__Contact__c, Section__r.hed__Parent_Term__r.Name,  
                                                           Section__r.hed__Parent_Term__r.Program_Batch__c, hed__Course_Offering__c,
                                                           hed__Course_Offering__r.Name, hed__Program_Enrollment__r.Section__c,
                                                           hed__Program_Enrollment__r.Section__r.Name from 
                                                           hed__Course_Enrollment__c where Section__c =:recordId AND 
                                                           hed__Course_Offering__c=:subjectId AND 
                                                           hed__Program_Enrollment__c Not IN : set_ProgEnrollId 
                                                           ORDER BY hed__Program_Enrollment__r.SRN_Number__c ASC])
            {
                courseConnectionWrp objCourseConnection = getCourseConnectionData(objCourseConn);
                objWrapperClass.objGroupMainWrp.lstUnassigned.add(objCourseConnection);
            }
        }
        //if(count == 0)
            //objWrapperClass.objGroupMainWrp.lstUnassigned.clear();
        
        if(objWrapperClass.objGroupMainWrp.map_GroupWrp.size() > 0)
        {
            objWrapperClass.strMessage = 'Records Exists';
            objWrapperClass.totalGroupRecords = objWrapperClass.objGroupMainWrp.map_GroupWrp.size();
        }
        else
            objWrapperClass.strMessage = 'Failure';
        return objWrapperClass;
    }
    
    @AuraEnabled 
    public static GroupMainWrp getGroupDetails(String subjectId, String recordId, Integer totalStudGroup)
    {
        GroupMainWrp objGroupMainWrp = new GroupMainWrp();
        List<hed__Term__c> lstGroupAllocation = new List<hed__Term__c>();
        String recTypeName = Utility.Term_RecType_Group;
        
        for (hed__Term__c objGroup : [Select Id, Name, Group_Number__c from hed__Term__c where RecordType.Name=:recTypeName
                                      AND Course_Offering__c =:subjectId AND hed__Parent_Term__c=:recordId])
        {
            GroupWrapperClass objGrpWrp = new GroupWrapperClass();
            objGrpWrp.groupNo = String.valueOf(objGroup.Group_Number__c);
            objGrpWrp.groupName = objGroup.Name;
            objGrpWrp.groupId = objGroup.Id;
            objGroupMainWrp.map_GroupWrp.put(objGrpWrp.groupNo, objGrpWrp);
            objGroupMainWrp.map_Groups.put(objGrpWrp.groupNo, objGrpWrp.groupName);
            objGroupMainWrp.map_GroupDetails.put(String.valueOf(objGroup.Group_Number__c), objGroup);
        }
        
        Integer maxSize = totalStudGroup;
        Integer studentNo = 1;
        Integer groupNo = 1;
        
        for(hed__Course_Enrollment__c objCourseConn : [Select Id, Name, hed__Program_Enrollment__r.Section__c, 
                                                       Section__c, Section__r.Name, hed__Program_Enrollment__c,
                                                       hed__Program_Enrollment__r.Section__r.Name, Section__r.hed__Parent_Term__c,
                                                       hed__Program_Enrollment__r.Name, hed__Program_Enrollment__r.SRN_Number__c,
                                                       hed__Program_Enrollment__r.hed__Contact__r.Name,
                                                       hed__Program_Enrollment__r.hed__Contact__c, Section__r.hed__Parent_Term__r.Name,  
                                                       Section__r.hed__Parent_Term__r.Program_Batch__c, hed__Course_Offering__c,
                                                       hed__Course_Offering__r.Name from hed__Course_Enrollment__c where
                                                       Semester_ID__c =:recordId AND hed__Course_Offering__c=:subjectId 
                                                       ORDER BY hed__Program_Enrollment__r.SRN_Number__c ASC])
        {
            Integer key = (studentNo <= (groupNo*maxSize)) ? groupNo : groupNo+1;
            groupNo = key;
            courseConnectionWrp objCourseConnection = getCourseConnectionData(objCourseConn);
            String strKey = String.valueOf(key);
            if(objGroupMainWrp.map_GroupWrp.get(strKey) != Null)
            {
                objGroupMainWrp.map_GroupWrp.get(strKey).totalRecords = objGroupMainWrp.map_GroupWrp.get(strKey).totalRecords + 1;
                objCourseConnection.isChecked = true;
                objCourseConnection.groupId = objGroupMainWrp.map_GroupWrp.get(strKey).groupId;
                objCourseConnection.groupName = objGroupMainWrp.map_GroupWrp.get(strKey).groupName;
                objCourseConnection.groupNo = objGroupMainWrp.map_GroupWrp.get(strKey).groupNo;
                objGroupMainWrp.map_GroupWrp.get(strKey).lstcourseCons.add(objCourseConnection);
            }
            else
            {
                objGroupMainWrp.lstUnassigned.add(objCourseConnection);
                objGroupMainWrp.totalUnassignedRecords = objGroupMainWrp.totalUnassignedRecords +1;
            }
            studentNo++;
        }
        return objGroupMainWrp;
    }
    
    @AuraEnabled
    public static WrapperClass createStudTermGroup(String strCourseCons)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        try
        {
            Set<String> set_ProgramEnrollIds = new Set<String>();
            Set<String> set_OldSTMs = new Set<String>();
            List<Student_Semester_Mapping__c> lstStudTermMap = new List<Student_Semester_Mapping__c>();
            List<courseConnectionWrp> lstcourseConn= (List<courseConnectionWrp>)JSON.deserialize(strCourseCons, List<courseConnectionWrp>.class);
            String recTypeName = Utility.STM_RecType_Group;
            String recTypeId = Schema.getGlobalDescribe().get('Student_Semester_Mapping__c').getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
            
            for(courseConnectionWrp objcourseConn : lstcourseConn)
            {
                Student_Semester_Mapping__c objStudTermMap = new Student_Semester_Mapping__c();
                objStudTermMap.Active__c = true;
                objStudTermMap.Program_Enrollment__c = objcourseConn.progEnrollId;
                set_ProgramEnrollIds.add(objcourseConn.progEnrollId);
                if(String.isNotBlank(objcourseConn.oldGroupId) && objcourseConn.oldGroupId != objcourseConn.groupId)
                    set_OldSTMs.add(objcourseConn.oldGroupId);
                objStudTermMap.Student_Group__c = objcourseConn.groupId;
                objStudTermMap.Start_Date__c = System.today();
                objStudTermMap.Name = objcourseConn.contactName+'-'+objcourseConn.groupName;
                objStudTermMap.RecordTypeId = recTypeId;
                objStudTermMap.Course_Offering_ID__c = objcourseConn.subjectId;
                objStudTermMap.External_Id__c = objcourseConn.progEnrollId+'_'+objcourseConn.groupId+'_'+System.now();
                lstStudTermMap.add(objStudTermMap);
            }
            
            if(!set_ProgramEnrollIds.isEmpty() && !set_OldSTMs.isEmpty())
            {
                Delete [Select Id from Student_Semester_Mapping__c where Student_Group__c IN: set_OldSTMs
                        AND Program_Enrollment__c IN: set_ProgramEnrollIds];
            }

            if(lstStudTermMap.size() >0)
            {
                Set<Id> setSTMIds = new Set<Id>();
                Database.UpsertResult[] lstResult = Database.upsert(lstStudTermMap, Student_Semester_Mapping__c.External_Id__c, True);
                for(Integer i = 0; i <lstResult.size(); i++)
                {
                    if(lstResult[i].isSuccess())
                    {
                        setSTMIds.add(lstResult[i].Id);
                    }
                }
                if(!setSTMIds.isEmpty())
                {
                    Database.executeBatch(new MSTR_CreateCourseConnection_Batch(setSTMIds));
                }
            }
            
            objWrapperClass.strMessage = 'Success'; 
        }
        Catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage();
        }
        return objWrapperClass;
    }
    
    public static courseConnectionWrp getCourseConnectionData(hed__Course_Enrollment__c objCourseConn)
    {
        courseConnectionWrp objCourseConnection = new courseConnectionWrp();
        objCourseConnection.contactId = objCourseConn.hed__Program_Enrollment__r.hed__Contact__c;
        objCourseConnection.contactName = objCourseConn.hed__Program_Enrollment__r.hed__Contact__r.Name;
        objCourseConnection.progEnrollId = objCourseConn.hed__Program_Enrollment__c;
        objCourseConnection.progEnrollName = objCourseConn.hed__Program_Enrollment__r.Name;
        objCourseConnection.srnNumber = objCourseConn.hed__Program_Enrollment__r.SRN_Number__c;
        objCourseConnection.sectionId = objCourseConn.hed__Program_Enrollment__r.Section__c;
        objCourseConnection.sectionName = objCourseConn.hed__Program_Enrollment__r.Section__r.Name;
        objCourseConnection.progPlanId = objCourseConn.Section__r.hed__Parent_Term__r.Program_Batch__c;
        objCourseConnection.semesterId = objCourseConn.Section__r.hed__Parent_Term__c;
        objCourseConnection.semesterName = objCourseConn.Section__r.hed__Parent_Term__r.Name;
        objCourseConnection.subjectId = objCourseConn.hed__Course_Offering__c;
        objCourseConnection.subjectName = objCourseConn.hed__Course_Offering__r.Name;
        objCourseConnection.courseOfferId = objCourseConn.Id;
        return objCourseConnection;
    }
    
    public class DetailsWrp
    {
        @AuraEnabled public hed__Term__c objTerm {get; set;}
        @AuraEnabled public Map<String, List<ElectiveWrp>> map_ElectiveWrp {get; set;}
        public DetailsWrp()
        {
            objTerm = new hed__Term__c();
            map_ElectiveWrp = new Map<String, List<ElectiveWrp>>();
        }
    }
    
    public class ElectiveWrp
    {
        @AuraEnabled public String parentCourseName {get; set;}
        @AuraEnabled public String parentCourseId {get; set;}
        @AuraEnabled public String courseCode {get; set;}
        @AuraEnabled public String subjectName {get; set;}
        @AuraEnabled public String subjectID {get; set;}
        @AuraEnabled public Integer totlNoOfStudents {get; set;}
    }
    
    public class WrapperClass
    {
        @AuraEnabled public String strMessage {get; set;}
        @AuraEnabled public Integer totalGroupRecords {get; set;}
        @AuraEnabled public GroupMainWrp objGroupMainWrp {get; set;}
        public WrapperClass()
        {
            objGroupMainWrp = new GroupMainWrp();
        }
    }
    
    public class GroupMainWrp
    {
        @AuraEnabled public Map<String, GroupWrapperClass> map_GroupWrp {get; set;}
        @AuraEnabled public Map<String, String> map_Groups {get; set;}
        @AuraEnabled public Map<String, hed__Term__c> map_GroupDetails {get; set;}
        @AuraEnabled public List<courseConnectionWrp> lstUnassigned {get; set;}
        @AuraEnabled public Integer totalUnassignedRecords {get; set;}
        public GroupMainWrp()
        {
            map_GroupWrp = new Map<String, GroupWrapperClass>();
            lstUnassigned = new List<courseConnectionWrp>();
            map_GroupDetails = new Map<String, hed__Term__c>();
            map_Groups = new Map<String, String>();
            totalUnassignedRecords = 0;
        }
    }
    
    public class GroupWrapperClass
    {
        @AuraEnabled public String groupNo {get; set;}
        @AuraEnabled public String groupName {get; set;}
        @AuraEnabled public String groupId {get; set;}
        @AuraEnabled public Integer totalRecords {get; set;}
        @AuraEnabled public List<courseConnectionWrp> lstcourseCons {get; set;}
        public GroupWrapperClass()
        {
            totalRecords = 0;
            lstcourseCons = new List<courseConnectionWrp>();
        }
    } 
    
    public class courseConnectionWrp
    {
        @AuraEnabled public Boolean isChecked {get; set;}
        @AuraEnabled public String contactId {get; set;}
        @AuraEnabled public String contactName {get; set;}
        @AuraEnabled public String progEnrollId {get; set;}
        @AuraEnabled public String progEnrollName {get; set;}
        @AuraEnabled public String srnNumber {get; set;}
        @AuraEnabled public String sectionId {get; set;}
        @AuraEnabled public String sectionName {get; set;}
        @AuraEnabled public String progPlanId {get; set;}
        @AuraEnabled public String groupId {get; set;}
        @AuraEnabled public String oldGroupId {get; set;}
        @AuraEnabled public String groupName {get; set;}
        @AuraEnabled public String groupNo {get; set;}
        @AuraEnabled public String semesterId {get; set;}
        @AuraEnabled public String semesterName {get; set;}
        @AuraEnabled public String subjectId {get; set;}
        @AuraEnabled public String subjectName {get; set;}
        @AuraEnabled public String courseOfferId {get; set;}
        public courseConnectionWrp()
        {
            isChecked = false;
        }   
    }
}