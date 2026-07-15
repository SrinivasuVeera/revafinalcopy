public class MSTR_StudentElectiveAllocation_Ctrl 
{
    @AuraEnabled
    public static CourseOfferingWrapper displayCourseOfferingRecords(String TermId)
    {
        CourseOfferingWrapper CourseOffWrap = new CourseOfferingWrapper();
        Set<string> set_String =new Set<string>();
        set_String.add('Open Elective');
        set_String.add('Professional Elective');
        Map<string,hed__Course_Offering__c> map_OECourseOffer = new Map<string,hed__Course_Offering__c>();
        Map<string,hed__Course_Offering__c> map_PECourseOffer = new Map<string,hed__Course_Offering__c>();
        List<CourseOfferingdata> lst_CourseOfferingdata = new List<CourseOfferingdata>();
        List<CourseOfferingdata> lstCourseOfferingdata = new List<CourseOfferingdata>();
        
        for(hed__Term__c objTerm : [select Id,Name,hed__Account__c,Program_Batch__c,Program_Batch__r.Name,RecordType.Name,Active__c 
                                    from hed__Term__c where RecordType.Name=:Utility.Term_Object_RecType_Term and Id =: TermId])
        {
            CourseOffWrap.ProgramPlanName = objTerm.Program_Batch__r.Name;
            CourseOffWrap.TermName = objTerm.Name;
        }
        
        for(hed__Course_Offering__c objCourseOff : [select Id, Name, Category__c, hed__Course__c, Parent_Course_Offering__r.Name,
                                                    hed__Course__r.Name, hed__Capacity__c, Credits__c, hed__Facility__c, 
                                                    Parent_Course_Offering__c, Preference__c, hed__Section_ID__c, Sequence__c, 
                                                    hed__Term__c, No_of_times_taught_in_last_3_years__c, Max_Professors_Per_Course__c,
                                                    Min_Professors_Per_Course__c, Assigned__c, Active__c, Student_Preference_1__c, 
                                                    Student_Preference_2__c, Student_Preference_3__c from hed__Course_Offering__c 
                                                    where hed__Term__c =: TermId AND Category__c IN:set_String 
                                                    ORDER BY Sequence__c])
        {
            CourseOfferingdata objCourse = new CourseOfferingdata();
            objCourse.CourseOfferingId = objCourseOff.Id;
            objCourse.Name = objCourseOff.Name;
            objCourse.Category = objCourseOff.Category__c;
            objCourse.hed_Course = objCourseOff.hed__Course__c;
            objCourse.ParentCourseOffering_Name = objCourseOff.Parent_Course_Offering__r.Name;
            objCourse.Course_Name = objCourseOff.hed__Course__r.Name;
            objCourse.hed_Capacity = objCourseOff.hed__Capacity__c;
            objCourse.hed_Facility = objCourseOff.hed__Facility__c;
            objCourse.Parent_Course_Offering = objCourseOff.Parent_Course_Offering__c;
            objCourse.hed_Section_ID = objCourseOff.hed__Section_ID__c;
            objCourse.hed_Term =  objCourseOff.hed__Term__c;
            objCourse.Student_Preference_1 = objCourseOff.Student_Preference_1__c;
            objCourse.Student_Preference_2 = objCourseOff.Student_Preference_2__c;
            objCourse.Student_Preference_3 = objCourseOff.Student_Preference_3__c;
            objCourse.active = objCourseOff.Active__c;
            if(objCourseOff.Parent_Course_Offering__c == Null)
            {
                lst_CourseOfferingdata.add(objCourse);
            }
            else
            {
                objCourse.assigned = objCourseOff.Assigned__c;
                if(CourseOffWrap.mapCourseOfferingdata.get(objCourse.ParentCourseOffering_Name) == Null)
                {
                    CourseOffWrap.mapCourseOfferingdata.put(objCourse.ParentCourseOffering_Name, new List<CourseOfferingdata>());
                }
                CourseOffWrap.mapCourseOfferingdata.get(objCourse.ParentCourseOffering_Name).add(objCourse);
            }
            
        }    

        for(CourseOfferingdata objCourse : lst_CourseOfferingdata)
        {
            lstCourseOfferingdata.add(objCourse);
            if(CourseOffWrap.mapCourseOfferingdata.get(objCourse.Name) != Null)
            {
                for(CourseOfferingdata objChildCourse : CourseOffWrap.mapCourseOfferingdata.get(objCourse.Name))
                {
                    lstCourseOfferingdata.add(objChildCourse);
                }
            }
        }
        
        CourseOffWrap.lstCourseOffrData = lstCourseOfferingdata;
        return CourseOffWrap;
    }
    
    @AuraEnabled
    public static preferenceWrapper getElectiveCourses(string courseElectiveId, string TermId) 
    { 
        Map<String, Set<String>> map_ElectStudMap = new Map<String, Set<String>>();
        Map<String, StudentPreferenceElectivs> map_ProfStudPrefMap = new Map<String, StudentPreferenceElectivs>();
        preferenceWrapper objPrefernec = new preferenceWrapper();
        set<Id> set_CourseOfferId = new set<Id>();
        Map<string,ElectiveSubjects> map_ElectiveSubjects = new Map<string,ElectiveSubjects>();
        List<StudentPreferenceElectivs> lst_StudPrefElects = new List<StudentPreferenceElectivs>();
        Integer count=0;
        Integer courseCount = 0;
        String courseConnStudRecType = Utility.CC_Stud_RecType;
        Id ccStudRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(courseConnStudRecType).getRecordTypeId();
        
        for(hed__Course_Offering__c objCourseOffer : [select Name, Id, Parent_Course_Offering__r.name, hed__Term__c, 
                                                      hed__Course__r.hed__Course_ID__c, hed__Course__r.Course_External_ID__c 
                                                      from hed__Course_Offering__c where 
                                                      Parent_Course_Offering__c =: courseElectiveId AND
                                                      hed__Term__c =: TermId])
        {          
            ElectiveSubjects objElectSubj = new ElectiveSubjects();            
            count = count + 1;
            objElectSubj.subjectsNo = string.Valueof(count);
            objElectSubj.subjectsId = objCourseOffer.Id;
            objElectSubj.subjectsName = objCourseOffer.Name;
            objPrefernec.HeaderName = objCourseOffer.Parent_Course_Offering__r.name;
            map_ElectiveSubjects.put(string.Valueof(objElectSubj.subjectsId),objElectSubj);
            objPrefernec.map_subjectPicklist.put(objCourseOffer.Id+'_'+objCourseOffer.hed__Course__r.Course_External_ID__c, objCourseOffer.Name);
            set_CourseOfferId.add(objCourseOffer.Id);
        }
        
        for(hed__Course_Enrollment__c objCourseConn : [Select Id, Name, hed__Contact__c, hed__Contact__r.SRN_Number__c,hed__Contact__r.Application_Number__c, 
                                                       hed__Contact__r.Name, hed__Course_Offering__c, hed__Program_Enrollment__c,
                                                       Section__c, Section__r.Name, hed__Contact__r.Active_Section__c, 
                                                       hed__Contact__r.Active_Section__r.Name, Preference_1__c,
                                                       Preference_2__c, Preference_3__c, hed__Course_Offering__r.Name,
                                                       hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                                                       hed__Course_Offering__r.hed__Course__r.Course_External_ID__c,
                                                       Semester_ID__c from hed__Course_Enrollment__c where 
                                                       hed__Contact__c != Null AND Semester_ID__c =: TermId 
                                                       AND hed__Course_Offering__c IN: set_CourseOfferId AND 
                                                       RecordtypeId =: ccStudRecTypeId 
                                                       ORDER BY hed__Contact__r.Name]) 
        {
            if(map_ElectiveSubjects.get(objCourseConn.hed__Course_Offering__c) != Null)
            {
                courseCount = courseCount +1;
                StudentPreferenceElectivs objStdPreference = new StudentPreferenceElectivs();
                objStdPreference.StudentPreferenceId = objCourseConn.Id;
                objStdPreference.CourseOfferingId = objCourseConn.hed__Course_Offering__c;
                objStdPreference.CourseOfferingCode = objCourseConn.hed__Course_Offering__r.hed__Course__r.Course_External_ID__c;
                objStdPreference.Contact_Id = objCourseConn.hed__Contact__c;
                objStdPreference.Contact_Name = objCourseConn.hed__Contact__r.Name;
                objStdPreference.TermId = objCourseConn.Section__c;
                objStdPreference.TermName = objCourseConn.Section__r.Name;
                objStdPreference.Section_Name = objCourseConn.hed__Contact__r.Active_Section__r.Name;
                objStdPreference.SectionId = objCourseConn.hed__Contact__r.Active_Section__c;
                objStdPreference.SRN_No = objCourseConn.hed__Contact__r.Application_Number__c;
                objStdPreference.Preference1 = objCourseConn.Preference_1__c;
                objStdPreference.Preference2 = objCourseConn.Preference_2__c;
                objStdPreference.Preference3 = objCourseConn.Preference_3__c;
                objStdPreference.ProgramEnrollId = objCourseConn.hed__Program_Enrollment__c;
                objStdPreference.SemesterId = objCourseConn.Semester_ID__c;
                map_ElectiveSubjects.get(objCourseConn.hed__Course_Offering__c).lstStudPrefElect.add(objStdPreference);
            }
        }
        
        if(courseCount == 0)
        {
            for(Professor_Student_Course_Preference__c objStdCoursePref : [Select Id, Course_Offering__c, Course_Offering__r.Name, Contact__c, 
                                                                           Contact__r.Name, Contact__r.SRN_Number__c,Contact__r.Application_Number__c,Contact__r.Active_Section__c,
                                                                           Contact__r.Active_Section__r.Name, Preference__c, Preference_No__c,
                                                                           Student_Preference__c, Semester__c, Semester__r.Name,
                                                                           Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                                                                           Course_Offering__r.hed__Course__r.Course_External_ID__c 
                                                                           from Professor_Student_Course_Preference__c where 
                                                                           Course_Offering__c IN: set_CourseOfferId AND 
                                                                           Student_Preference__c =:True AND Contact__c !=: NULL AND
                                                                           Semester__c =: TermId ORDER BY Preference__c, Contact__r.Name])
            {
                //Collecting Elective Id and Contact Ids
                if(map_ElectStudMap.get(objStdCoursePref.Course_Offering__c) == Null)
                {
                    map_ElectStudMap.put(objStdCoursePref.Course_Offering__c, new Set<String>());
                }
                map_ElectStudMap.get(objStdCoursePref.Course_Offering__c).add(objStdCoursePref.Contact__c);
                
                //Collecting Student Details and Preferencies in a map
                if(map_ProfStudPrefMap.get(objStdCoursePref.Contact__c) == Null)
                {
                    StudentPreferenceElectivs objStdPreference = new StudentPreferenceElectivs();
                    objStdPreference.StudentPreferenceId = objStdCoursePref.Id;
                    objStdPreference.Contact_Id = objStdCoursePref.Contact__c;
                    objStdPreference.Contact_Name = objStdCoursePref.Contact__r.Name;
                    objStdPreference.TermId = objStdCoursePref.Semester__c;
                    objStdPreference.TermName = objStdCoursePref.Semester__r.Name;
                    objStdPreference.Section_Name = objStdCoursePref.Contact__r.Active_Section__r.Name;
                    objStdPreference.SectionId = objStdCoursePref.Contact__r.Active_Section__c;
                    objStdPreference.SRN_No = objStdCoursePref.Contact__r.Application_Number__c;
                    if(objStdCoursePref.Preference__c == '1')
                    {
                        objStdPreference.Preference1 = objStdCoursePref.Course_Offering__r.Name;
                        objStdPreference.Preference1_Id = objStdCoursePref.Course_Offering__c;
                        objStdPreference.CourseOfferingId = objStdCoursePref.Course_Offering__c;
                        objStdPreference.CourseName = objStdCoursePref.Course_Offering__r.Name;
                        objStdPreference.CourseOfferingCode = objStdCoursePref.Course_Offering__r.hed__Course__r.Course_External_ID__c;
                    }
                    else if(objStdCoursePref.Preference__c == '2')
                    {
                        objStdPreference.Preference2 = objStdCoursePref.Course_Offering__r.Name;
                        objStdPreference.Preference2_Id = objStdCoursePref.Course_Offering__c;
                    }
                    else if(objStdCoursePref.Preference__c == '3')
                    {
                        objStdPreference.Preference3 = objStdCoursePref.Course_Offering__r.Name;
                        objStdPreference.Preference3_Id = objStdCoursePref.Course_Offering__c;
                    }
                    map_ProfStudPrefMap.put(objStdCoursePref.Contact__c, objStdPreference);
                }
                else if(map_ProfStudPrefMap.containsKey(objStdCoursePref.Contact__c))
                {
                    if(objStdCoursePref.Preference__c == '1')
                    {
                        map_ProfStudPrefMap.get(objStdCoursePref.Contact__c).Preference1 = objStdCoursePref.Course_Offering__r.Name;
                        map_ProfStudPrefMap.get(objStdCoursePref.Contact__c).Preference1_Id = objStdCoursePref.Course_Offering__c;
                        map_ProfStudPrefMap.get(objStdCoursePref.Contact__c).CourseOfferingId = objStdCoursePref.Course_Offering__c;
                        map_ProfStudPrefMap.get(objStdCoursePref.Contact__c).CourseName = objStdCoursePref.Course_Offering__r.Name;
                    }
                    else if(objStdCoursePref.Preference__c == '2')
                    {
                        map_ProfStudPrefMap.get(objStdCoursePref.Contact__c).Preference2 = objStdCoursePref.Course_Offering__r.Name;
                        map_ProfStudPrefMap.get(objStdCoursePref.Contact__c).Preference2_Id = objStdCoursePref.Course_Offering__c;
                    }
                    else if(objStdCoursePref.Preference__c == '3')
                    {
                        map_ProfStudPrefMap.get(objStdCoursePref.Contact__c).Preference3 = objStdCoursePref.Course_Offering__r.Name;
                        map_ProfStudPrefMap.get(objStdCoursePref.Contact__c).Preference3_Id = objStdCoursePref.Course_Offering__c;
                    }
                }
            }
            
            if(map_ElectStudMap.size() > 0)
            {
                Set<String> set_ContactIds = new Set<String>();
                Map<String, hed__Program_Enrollment__c> map_ProgrEnroll = new Map<String, hed__Program_Enrollment__c>();
                List<hed__Course_Enrollment__c> lstCourseConn = new List<hed__Course_Enrollment__c>();
                
                for(String electId : map_ElectStudMap.keyset())
                {
                    for(String contactIds : map_ElectStudMap.get(electId))
                    {
                        if(map_ProfStudPrefMap.get(contactIds) != Null)
                        {
                            if(map_ElectiveSubjects.get(electId) != Null &&
                               !set_ContactIds.contains(contactIds))
                            {
                                StudentPreferenceElectivs studePrefElective = new StudentPreferenceElectivs();
                                studePrefElective = map_ProfStudPrefMap.get(contactIds);
                                lst_StudPrefElects.add(studePrefElective);
                                set_ContactIds.add(studePrefElective.Contact_Id);
                            }
                        }
                    }
                }

                if(lst_StudPrefElects.size() > 0)
                {
                    for(hed__Program_Enrollment__c objProgEnroll : [Select Id, Name, hed__Contact__c, SRN_Number__c,hed__Contact__r.Application_Number__c from 
                                                                    hed__Program_Enrollment__c where Active__c= True AND
                                                                    hed__Contact__c IN: set_ContactIds])
                    {
                        map_ProgrEnroll.put(objProgEnroll.hed__Contact__c, objProgEnroll);
                    }
                    
                    for(StudentPreferenceElectivs objStudPrefElect : lst_StudPrefElects)
                    {
                        if(map_ProgrEnroll.get(objStudPrefElect.Contact_Id) != Null)
                        {
                            hed__Program_Enrollment__c objProgEnroll = map_ProgrEnroll.get(objStudPrefElect.Contact_Id);
                            hed__Course_Enrollment__c objCourseConn = new hed__Course_Enrollment__c();
                            objCourseConn.hed__Contact__c = objStudPrefElect.Contact_Id;
                            objCourseConn.hed__Course_Offering__c = objStudPrefElect.CourseOfferingId;
                            objCourseConn.hed__Program_Enrollment__c = objProgEnroll.Id;
                            objCourseConn.Section__c = objStudPrefElect.TermId;
                            objCourseConn.Preference_1__c = objStudPrefElect.Preference1;
                            objCourseConn.Preference_2__c = objStudPrefElect.Preference2;
                            objCourseConn.Preference_3__c = objStudPrefElect.Preference3;
                            objCourseConn.External_Id__c = objProgEnroll.hed__Contact__r.Application_Number__c+'_'+objStudPrefElect.CourseOfferingId;
                            objCourseConn.Logisys_External_Id__c = objProgEnroll.hed__Contact__r.Application_Number__c+''+objStudPrefElect.CourseOfferingCode;
                            objCourseConn.Semester_ID__c = objStudPrefElect.TermId;
                            objCourseConn.RecordTypeId = ccStudRecTypeId;
                            lstCourseConn.add(objCourseConn);
                        }
                    }
                    
                    if(lstCourseConn.size() >0)
                    {
                        Insert lstCourseConn;
                        for(hed__Course_Enrollment__c objCourseConn : [Select Id, Name, hed__Contact__c, hed__Contact__r.SRN_Number__c,hed__Contact__r.Application_Number__c, 
                                                                       hed__Contact__r.Name, hed__Course_Offering__c, hed__Program_Enrollment__c,
                                                                       Section__c, Section__r.Name, hed__Contact__r.Active_Section__c, 
                                                                       hed__Contact__r.Active_Section__r.Name, Preference_1__c,
                                                                       Preference_2__c, Preference_3__c, hed__Course_Offering__r.Name, Semester_ID__c,
                                                                       hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,
                                                                       hed__Course_Offering__r.hed__Course__r.Course_External_ID__c
                                                                       from hed__Course_Enrollment__c where hed__Contact__c IN: set_ContactIds 
                                                                       AND hed__Course_Offering__c IN: set_CourseOfferId AND 
                                                                       RecordtypeId =: ccStudRecTypeId ORDER BY hed__Contact__r.Name])
                        {
                            if(map_ElectiveSubjects.get(objCourseConn.hed__Course_Offering__c) != Null)
                            {
                                StudentPreferenceElectivs objStdPreference = new StudentPreferenceElectivs();
                                objStdPreference.StudentPreferenceId = objCourseConn.Id;
                                objStdPreference.CourseOfferingId = objCourseConn.hed__Course_Offering__c;
                                objStdPreference.CourseOfferingCode = objCourseConn.hed__Course_Offering__r.hed__Course__r.Course_External_ID__c;
                                objStdPreference.Contact_Id = objCourseConn.hed__Contact__c;
                                objStdPreference.Contact_Name = objCourseConn.hed__Contact__r.Name;
                                objStdPreference.TermId = objCourseConn.Section__c;
                                objStdPreference.TermName = objCourseConn.Section__r.Name;
                                objStdPreference.Section_Name = objCourseConn.hed__Contact__r.Active_Section__r.Name;
                                objStdPreference.SectionId = objCourseConn.hed__Contact__r.Active_Section__c;
                                objStdPreference.SRN_No = objCourseConn.hed__Contact__r.Application_Number__c;
                                objStdPreference.Preference1 = objCourseConn.Preference_1__c;
                                objStdPreference.Preference2 = objCourseConn.Preference_2__c;
                                objStdPreference.Preference3 = objCourseConn.Preference_3__c;
                                objStdPreference.ProgramEnrollId = objCourseConn.hed__Program_Enrollment__c;
                                objStdPreference.SemesterId = objCourseConn.Semester_ID__c;
                                map_ElectiveSubjects.get(objCourseConn.hed__Course_Offering__c).lstStudPrefElect.add(objStdPreference);
                            }
                        }
                    }
                }
            }
        }
        //System.debug('Student Details=='+lst_StudPrefElects);
        objPrefernec.map_subjects = map_ElectiveSubjects;
        return objPrefernec;
    }
    
    @AuraEnabled
    public static Map<String, String> getPreference() 
    {
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('hed__Course_Offering__c');
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get('Preference__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) 
        {
            mapPickListValues.put(objPickList.getValue(),objPickList.getLabel());
        }
        return mapPickListValues;
    }
    
    @AuraEnabled
    public static WrapperClass createCourseConnection(String courseConn)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        try
        {
            List<StudentPreferenceElectivs> lstProgEnrollNew = (List<StudentPreferenceElectivs>)JSON.deserialize(courseConn, List<StudentPreferenceElectivs>.class);
            String courseConnStudRecType = Utility.CC_Stud_RecType;
            Id ccStudRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(courseConnStudRecType).getRecordTypeId();
            Set<String> set_ContactIds = new Set<String>();
            Map<String, hed__Program_Enrollment__c> map_ProgrEnroll = new Map<String, hed__Program_Enrollment__c>();
            List<hed__Course_Enrollment__c> lstCourseConn = new List<hed__Course_Enrollment__c>();
            Set<String> set_ProgEnrollIds = new Set<String>();
            Set<String> set_oldSubjectIds = new Set<String>();
            List<Student_Semester_Mapping__c> lstUpdteStuSem = new List<Student_Semester_Mapping__c>();
            
            for(StudentPreferenceElectivs objStudPrefElect : lstProgEnrollNew)
            {
                hed__Course_Enrollment__c objCourseConn = new hed__Course_Enrollment__c();
                objCourseConn.Id = objStudPrefElect.StudentPreferenceId;
                objCourseConn.hed__Course_Offering__c = objStudPrefElect.newSubject_Id;
                objCourseConn.Section__c = objStudPrefElect.SemesterId;
                objCourseConn.External_Id__c = objStudPrefElect.SRN_No+'_'+objStudPrefElect.newSubject_Id;
                objCourseConn.Logisys_External_Id__c = objStudPrefElect.SRN_No+''+objStudPrefElect.newCourseOfferCode;
                lstCourseConn.add(objCourseConn);
                set_ProgEnrollIds.add(objStudPrefElect.ProgramEnrollId);
                set_oldSubjectIds.add(objStudPrefElect.CourseOfferingId);
            }
            
            if(!set_ProgEnrollIds.isEmpty() && !set_oldSubjectIds.isEmpty())
            {
                for(Student_Semester_Mapping__c objStudSem : [Select Id, Name, Active__c, End_Date__c, Start_Date__c from 
                                                              Student_Semester_Mapping__c where 
                                                              Course_Offering_ID__c IN: set_oldSubjectIds AND 
                                                              Program_Enrollment__c IN: set_ProgEnrollIds])
                {
                    if(objStudSem.Start_Date__c == System.today())
                        objStudSem.End_Date__c = System.today();
                    else    
                        objStudSem.End_Date__c = System.today().addDays(-1);
                    objStudSem.Active__c = false;
                    lstUpdteStuSem.add(objStudSem);
                }
            }
            
            if(lstUpdteStuSem.size() >0)
                update lstUpdteStuSem;
            
            if(lstCourseConn.size() > 0)
                update lstCourseConn;
            objWrapperClass.strMessage = 'Success'; 
        }
        Catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage();
        }
        return objWrapperClass;
    }
    
    @AuraEnabled
    public static WrapperClass ActivateCourseOffering(String strCourOffer)
    {
        WrapperClass objWrapperClass = new WrapperClass();
        try
        {
            CourseOfferingdata objCourseOfferWrp = (CourseOfferingdata)JSON.deserialize(strCourOffer, CourseOfferingdata.class);
            if(objCourseOfferWrp != Null)
            {
                hed__Course_Offering__c objCourseOff = new hed__Course_Offering__c();
                objCourseOff.Id = objCourseOfferWrp.CourseOfferingId;
                objCourseOff.Active__c = objCourseOfferWrp.active;
                update objCourseOff;
            }
            objWrapperClass.strMessage = 'Success'; 
        }
        Catch(Exception ex)
        {
            objWrapperClass.strMessage = 'Error: '+ex.getMessage();
        }
        return objWrapperClass;
    }
    
    public class CourseOfferingWrapper
    {
        @AuraEnabled public string ProgramPlanName{get;set;}
        @AuraEnabled public string TermName{get;set;}
        
        @AuraEnabled public map<string,string> map_PickValues{get;set;}
        @AuraEnabled public Map<String, List<CourseOfferingdata>> mapCourseOfferingdata {get; set;}
        @AuraEnabled public List<CourseOfferingdata> lstCourseOffrData{get;set;}
        @AuraEnabled public Map<String, String> map_SelectedCourseId {get; set;}
        
        public CourseOfferingWrapper()
        {
            mapCourseOfferingdata = new Map<String, List<CourseOfferingdata>>();
            lstCourseOffrData = new list<CourseOfferingdata>();            
            map_PickValues = new map<string,string>();
            map_SelectedCourseId = new Map<String, String>();
        }
    }
    
    public class CourseOfferingdata
    {
        @AuraEnabled public string CourseOfferingId {get;set;}
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public string Category {get;set;}
        @AuraEnabled public string hed_Course {get;set;}
        @AuraEnabled public string ParentCourseOffering_Name {get;set;}
        @AuraEnabled public string Course_Name {get;set;}
        @AuraEnabled public decimal hed_Capacity {get;set;}
        @AuraEnabled public string hed_Facility {get;set;}
        @AuraEnabled public string Parent_Course_Offering {get;set;}
        @AuraEnabled public string hed_Section_ID {get;set;}
        @AuraEnabled public string hed_Term {get;set;}  
        @AuraEnabled public decimal assigned {get;set;}  
        @AuraEnabled public boolean active {get;set;}  
        @AuraEnabled public decimal Student_Preference_1 {get;set;}
        @AuraEnabled public decimal Student_Preference_2 {get;set;}
        @AuraEnabled public decimal Student_Preference_3 {get;set;}
    }
    
    public class preferenceWrapper
    {
        @AuraEnabled public Map<String, ElectiveSubjects> map_subjects {get;set;}
        @AuraEnabled public Map<String, String> map_subjectPicklist {get;set;}
        @AuraEnabled public String HeaderName{get;set;} 
        
        public preferenceWrapper()
        {
            map_subjects = new Map<string,ElectiveSubjects>();
            map_subjectPicklist = new Map<String, String>();
        }
    }
    
    public class ElectiveSubjects
    {
        @AuraEnabled public string subjectsNo {get;set;}
        @AuraEnabled public string subjectsName{get;set;}         
        @AuraEnabled public string subjectsId{get;set;}
        @AuraEnabled public string newSubjectId{get;set;}
        @AuraEnabled public Integer totalRecords{get;set;}
        @AuraEnabled public List<StudentPreferenceElectivs> lstStudPrefElect {get;set;}
         
        public ElectiveSubjects()
        {
            lstStudPrefElect = new List<StudentPreferenceElectivs>();
            totalRecords = 0;             
        }
    }    
     
    public class StudentPreferenceElectivs
    {
        @AuraEnabled public string StudentPreferenceId {get;set;}
        @AuraEnabled public string CourseOfferingId {get;set;}
        @AuraEnabled public string CourseOfferingCode {get;set;}
        @AuraEnabled public string CourseName {get;set;}
        @AuraEnabled public string Contact_Id {get;set;}
        @AuraEnabled public string Contact_Name {get;set;}
        @AuraEnabled public string Section_Name {get;set;}
        @AuraEnabled public string SectionId {get;set;}
        @AuraEnabled public string SRN_No {get;set;}
        @AuraEnabled public string TermId {get;set;}
        @AuraEnabled public string TermName {get;set;}  
        @AuraEnabled public string Preference1 {get;set;}  
        @AuraEnabled public string Preference1_Id {get;set;}  
        @AuraEnabled public string Preference2 {get;set;}  
        @AuraEnabled public string Preference2_Id {get;set;}  
        @AuraEnabled public string Preference3 {get;set;}  
        @AuraEnabled public string Preference3_Id {get;set;} 
        @AuraEnabled public string newSubject_Id {get;set;} 
        @AuraEnabled public string newCourseOfferCode {get;set;}
        @AuraEnabled public string ProgramEnrollId {get;set;} 
        @AuraEnabled public string SemesterId {get;set;} 
        @AuraEnabled public Boolean isChecked {get; set;}
        public StudentPreferenceElectivs()
        {
            isChecked = false;
        }
    }
    
    public class WrapperClass
    {
        @AuraEnabled public String strMessage {get; set;}
    }
}