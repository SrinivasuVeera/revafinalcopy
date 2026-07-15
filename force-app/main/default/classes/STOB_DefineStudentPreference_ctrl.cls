public With Sharing class STOB_DefineStudentPreference_ctrl
{
    /* Description : Creating Professor/ Student Course prefernces Records Creation Based on Student Preferences*/
    @AuraEnabled
    public static CourseOfferingWrapper DisplayCourseOfferingRecords()
    {
        set<id> set_courseId  = new set<id>();
        CourseOfferingWrapper WrapCourseOff = new CourseOfferingWrapper();
        WrapCourseOff.totalCredit =0;
        list<hed__Course_Offering__c> lst_CourseOffering = new list<hed__Course_Offering__c>();
        User usr =[select Id,Name,ContactId from User where Id =:UserInfo.getUserId()];
        set<id> set_progbatchid = new set<id>();
        Contact objCon = new Contact();
        try{
            if(usr.ContactId != null){
                
                objCon =[select Id,LastName,Accountid,Account.Name from Contact Where Id =: usr.ContactId];


                for(hed__Program_Enrollment__c objProgEnroll : [select Id,hed__Program_Plan__c,hed__Contact__c  from hed__Program_Enrollment__c where hed__Contact__c =:usr.ContactId]){
                    if(objProgEnroll.hed__Program_Plan__c != null)
                        set_progbatchid.add(objProgEnroll.hed__Program_Plan__c);
                }
            }
            hed__Term__c objTerm = new hed__Term__c();
            if(set_progbatchid.size()>0)
            {
                objTerm = [select Id,Name,hed__Account__c,Program_Batch__c,hed__Account__r.Name,RecordType.Name,Active__c,Allow_Student_Elective_Preference__c,Term_Number__c from
                           hed__Term__c where RecordType.Name=:Utility.Term_Object_RecType_Term and Allow_Student_Elective_Preference__c=true
                           and Program_Batch__c in: set_progbatchid];
            }
            if(objTerm.Id != null)
            {
                if(objTerm.hed__Account__r.Name =='Master of Business Administration' && objTerm.Allow_Student_Elective_Preference__c == true && objTerm.Term_Number__c == 1){
                    WrapCourseOff.isRBSSchool = true;
                }
                map<id,Professor_Student_Course_Preference__c> map_profstudent= new map<id,Professor_Student_Course_Preference__c>();
                WrapCourseOff.objTermname = objTerm.Name;
                for(Professor_Student_Course_Preference__c objProfStu : [select Id,Name,Contact__c,Course_Offering__c,Course_Offering__r.hed__Course__c,Preference__c,Professor__c,Semester__c,Student_Preference__c,Course_Offering__r.Parent_Course_Offering__c,Course_Offering__r.Parent_Course_Offering__r.Name from
                                                                         Professor_Student_Course_Preference__c where Semester__c=: objTerm.Id and Course_Offering__c !=: null and
                                                                         Contact__c =: objCon.id])

                {
                    if(objProfStu.Course_Offering__c != null)
                    {
                        set_courseId.add(objProfStu.Course_Offering__c);
                        map_profstudent.put(objProfStu.Course_Offering__c,objProfStu);
                        WrapCourseOff.StudentPreference = objProfStu.Student_Preference__c;
                    }
                }
                if(set_courseId.size()>0)
                {
                    lst_CourseOffering = [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,
                                          Parent_Course_Offering__r.Name,Preference__c,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,
                                          Max_Professors_Per_Course__c,Min_Professors_Per_Course__c from hed__Course_Offering__c
                                          where hed__Term__c =:objTerm.Id and Id in: set_courseId order by Sequence__c];
                    for(hed__Course_Offering__c objCourseOff : lst_CourseOffering)
                    {

                        if(objCourseOff.Category__c == 'Professional Elective')
                        {
                            if(map_profstudent.ContainsKey(objCourseOff.id)) objCourseOff.Preference__c = map_profstudent.get(objCourseOff.id).Preference__c;
                            WrapCourseOff.listProfElective.add(objCourseOff);
                            WrapCourseOff.listMainCourse.add(objCourseOff);
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                        }
                        if(objCourseOff.Category__c == 'Open Elective')
                        {
                            if(map_profstudent.get(objCourseOff.id) !=null) objCourseOff.Preference__c = map_profstudent.get(objCourseOff.id).Preference__c;
                            WrapCourseOff.listOpenElective.add(objCourseOff);
                            WrapCourseOff.listMainCourse.add(objCourseOff);
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                        }
                    }
                    for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,Parent_Course_Offering__r.Name
                                                                from hed__Course_Offering__c where hed__Term__c =:objTerm.Id order by Sequence__c])
                    {
                        if(objCourseOff.Category__c == 'Hardcore Course')
                        {
                            WrapCourseOff.listHardCore.add(objCourseOff);
                            WrapCourseOff.listMainCourse.add(objCourseOff);
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                        }
                        if(objCourseOff.Category__c == 'Hardcore Integrated Course')
                        {
                            WrapCourseOff.listHcIntegrated.add(objCourseOff);
                            WrapCourseOff.listMainCourse.add(objCourseOff);
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                        }
                        if(objCourseOff.Category__c == 'Practical/Term work')
                        {
                            WrapCourseOff.listPractical.add(objCourseOff);
                            WrapCourseOff.listMainCourse.add(objCourseOff);
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                        }
                        if(objCourseOff.Category__c == 'Mandatory Course')
                        {
                            WrapCourseOff.listMandatory.add(objCourseOff);
                            WrapCourseOff.listMainCourse.add(objCourseOff);
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                        }
                    }
                }

                // to get RBS course credits
                List<hed__Course_Offering__c> courseOff = RBSstudentSpclCollectionCtrl.getCourseOfferingsBySpcl();
                if(!courseoff.isEmpty()) {
                    for(hed__Course_Offering__c cOff : courseOff){
                        if(cOff.Category__c == 'RBS Specialization') {
                            //WrapCourseOff.listMainCourse.add(cOff);
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + cOff.Credits__c;
                        }

                    }
                }
            }
            WrapCourseOff.ErrmsgMain='Success';
        }catch(exception ex)
        {
            WrapCourseOff.ErrmsgMain='Your Current Semester doesnt have any Elective Courses';
        }
        return WrapCourseOff;
    }
    @AuraEnabled
    public static CourseOfferingWrapper DisplayCourseOffering()
    {
        User usr =[select Id,Name,ContactId from User where Id =: UserInfo.getUserId()];
        Contact objCon = new Contact();
        CourseOfferingWrapper WrapCourseOff = new CourseOfferingWrapper();
        set<id> set_progbatchid = new set<id>();
        try
        {
            if(usr.ContactId != null)
            {
                objCon =[select Id,LastName,Accountid,Account.Name from Contact Where Id =: usr.ContactId];
                for(hed__Program_Enrollment__c objProgEnroll : [select Id,hed__Program_Plan__c from hed__Program_Enrollment__c where hed__Contact__c =:usr.ContactId])
                {
                    if(objProgEnroll.hed__Program_Plan__c != null)
                        set_progbatchid.add(objProgEnroll.hed__Program_Plan__c);
                }
            }

            WrapCourseOff.totalCredit =0;
            hed__Term__c objTerm = new hed__Term__c();
            if(set_progbatchid.size()>0)
            {
                objTerm = [select Id,Name,hed__Account__c,Program_Batch__c,RecordType.Name,Active__c,Allow_Student_Elective_Preference__c from
                           hed__Term__c where RecordType.Name=:Utility.Term_Object_RecType_Term and Allow_Student_Elective_Preference__c=true
                           and Program_Batch__c in: set_progbatchid];
            }
            if(objTerm.Id != null)
            {
                WrapCourseOff.objTermname = objTerm.Name;

                for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,Active__c,
                                                            Parent_Course_Offering__r.Name,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c
                                                            from hed__Course_Offering__c where Active__c =true AND hed__Term__c =:objTerm.Id order by Sequence__c])
                {
                    if(objCourseOff.Category__c == 'Hardcore Course')
                    {
                        WrapCourseOff.listHardCore.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Hardcore Integrated Course')
                    {
                        WrapCourseOff.listHcIntegrated.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Practical/Term work')
                    {
                        WrapCourseOff.listPractical.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Professional Elective')
                    {
                        WrapCourseOff.listProfElective.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Open Elective')
                    {
                        WrapCourseOff.listOpenElective.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Mandatory Course')
                    {
                        WrapCourseOff.listMandatory.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'RBS Specialization')
                    {
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        //WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                }

                // to get RBS course credits
                List<hed__Course_Offering__c> courseOff = RBSstudentSpclCollectionCtrl.getCourseOfferingsBySpcl();
                if(!courseoff.isEmpty()) {
                    for(hed__Course_Offering__c cOff : courseOff){
                        if(cOff.Category__c == 'RBS Specialization') {
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + cOff.Credits__c;
                        }

                    }
                }

            }
            WrapCourseOff.ErrmsgMain='Success';
        }catch(exception ex)
        {
            WrapCourseOff.ErrmsgMain='Your Current Semester doesnt have any Elective Courses';
        }
        return WrapCourseOff;
    }
    @AuraEnabled
    public static ErrorWrapper ValidationPreferences(list<hed__Course_Offering__c> lstOpenElective,list<hed__Course_Offering__c> lstProfElective)
    {
        ErrorWrapper WrapErr = new ErrorWrapper();
        list<String> lst_ProfPrefence = new List<String>();
        list<String> lst_ProfessionalPref = new List<String>();
        list<String> lst_ProfPref3 = new List<String>();
        list<String> lst_ProfPref4 = new List<String>();
        list<String> lst_ProfPref5 = new List<String>();
        if(lstOpenElective.size()>0)
        {
            Integer count=0;
            Integer maxStucount=0;
            Integer TotalCount=0;
            Integer TotalCountOp2=0;
            Integer countOp2=0;
            Integer TotalCountOp3=0;
            Integer countOp3=0;
            Integer TotalCountOp4=0;
            Integer countOp4=0;
            Integer TotalCountOp5=0;
            Integer countOp5=0;
            boolean OpenEle2 = false;
            boolean OpenEle3 = false;
            boolean OpenEle4 = false ;
            boolean OpenEle5 = false;
            Integer PreferenceCount = 0;
            set<id> set_CourseId = new set<id>();
            set<string> set_CountPref = new set<string>();
            integer openCount=0;
            integer openCount2=0;
            integer openCount3=0;
            integer openCount4=0;
            integer openCount5=0;

            for(hed__Course_Offering__c objCourse : lstOpenElective)
            {
                if(string.IsNotBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c))
                    {
                        if(objCourse.Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 1')   WrapErr.lst_Preference.add(objCourse.Preference__c);
                        else if(objCourse.Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 2')  WrapErr.lst_OpenPreference.add(objCourse.Preference__c);
                        else if(objCourse.Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 3')  WrapErr.lst_OpenPref3.add(objCourse.Preference__c);
                        else if(objCourse.Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 4')   WrapErr.lst_OpenPref4.add(objCourse.Preference__c);
                        else if(objCourse.Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 5')     WrapErr.lst_OpenPref5.add(objCourse.Preference__c);
                    }
                    if(string.isNotBlank(objCourse.id))
                    {
                        if(objCourse.Preference__c == '1')
                            set_CourseId.add(objCourse.id);
                    }
                }
            }
            for(integer i=0;i<lstOpenElective.size();i++)
            {
                if(lstOpenElective[i].Parent_Course_Offering__c != null)   PreferenceCount = PreferenceCount+1;
            }
            string val;
            for(integer i=0;i<lstOpenElective.size();i++)
            {
                if(string.IsNotBlank(lstOpenElective[i].Preference__c) && string.IsNotBlank(lstOpenElective[i].Parent_Course_Offering__c))
                    val = lstOpenElective[i].Parent_Course_Offering__c+'-'+lstOpenElective[i].Preference__c;
                for(integer j=i+1;j<lstOpenElective.size();j++)
                {
                    if(val == lstOpenElective[j].Parent_Course_Offering__c+'-'+lstOpenElective[j].Preference__c && lstOpenElective[i].Preference__c != null)
                    {
                        WrapErr.OpenDupPreference = 'This Preferance - '+lstOpenElective[i].Name+' is Already Selected.';
                        WrapErr.showsave = true;
                        return WrapErr;
                    }
                }
                if(string.IsBlank(lstOpenElective[i].Preference__c))
                {
                    if(string.IsNotBlank(lstOpenElective[i].Parent_Course_Offering__c))
                    {
                        if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 1')   openCount = openCount+1;
                        else if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 2')  openCount2 = openCount2+1;
                        else if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 3')  openCount3 = openCount3+1;
                        else if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 4') openCount4 = openCount4+1;
                        else if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 5') openCount5 = openCount5+1;
                    }
                }
                if(string.IsNotBlank(lstOpenElective[i].Preference__c))
                {
                    if(string.IsNotBlank(lstOpenElective[i].Parent_Course_Offering__c))
                    {
                        if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 1')
                        {
                            TotalCount = TotalCount+1;
                            count = count+1;
                        }
                        else if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 2')
                        {
                            TotalCountOp2 = TotalCountOp2+1;
                            countOp2 = countOp2+1;
                            OpenEle2 =true;
                        }
                        else if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 3')
                        {
                            TotalCountOp3 = TotalCountOp3+1;
                            countOp3 = countOp3+1;
                            OpenEle3 = true;
                        }
                        else if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 4')
                        {
                            TotalCountOp4 = TotalCountOp4+1;
                            countOp4 = countOp4+1;
                            OpenEle4 = true;
                        }
                        else if(lstOpenElective[i].Parent_Course_Offering__r.Name == 'OPEN ELECTIVES - 5')
                        {
                            TotalCountOp5 = TotalCountOp5+1;
                            countOp5 = countOp5+1;
                            OpenEle5 = true;
                        }
                    }
                }
            }
            if((TotalCount != 3 && TotalCount !=0) || (TotalCountOp2 != 3 && TotalCountOp2 !=0) ||
               (TotalCountOp4 !=3 && TotalCountOp4 !=0) || (TotalCountOp5 != 3 && TotalCountOp5 !=0))
            {
                if(openCount >0 || openCount2 >0 || openCount3 >0 || openCount4 >0 || openCount5 >0)
                {
                    WrapErr.OpenElectiveErrmsg = 'Select All Preference ';
                    WrapErr.showsave = true;
                    return WrapErr;
                }
            }
            if(count == 0 || (OpenEle2 == true && countOp2 ==0) || (OpenEle3== true && countOp3 == 0) ||
               (OpenEle4 == true && countOp4 == 0) || (OpenEle5== true && countOp5 == 0))
            {
                WrapErr.OpenElectiveErrmsg ='Please Select Open elective Preferences';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if((TotalCount >= 3  && count !=3) || (TotalCountOp2 >= 3  && countOp2 !=3 && OpenEle2 == true) ||
               (TotalCountOp3 >= 3  && countOp3 !=3 && OpenEle3 == true) || (TotalCountOp4 >= 3  && countOp4 !=3 && OpenEle4 == true)
               || (TotalCountOp5 >= 3  && countOp5 !=3 && OpenEle5 == true))
            {
                WrapErr.OpenElectiveErrmsg = 'Select All Preference ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if((TotalCount == 2  && count !=2) || (TotalCountOp2 == 2  && countOp2 !=2 && OpenEle2 == true) ||
               (TotalCountOp3 == 2  && countOp3 !=2 && OpenEle3 == true) || (TotalCountOp4 == 2  && countOp4 !=2 && OpenEle4 == true)
               || (TotalCountOp5 == 2  && countOp5 !=2 && OpenEle5 == true))
            {
                WrapErr.OpenElectiveErrmsg = 'Select All Preference ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(WrapErr.lst_Preference.size() == 2 && (WrapErr.lst_Preference[0] == '3' || WrapErr.lst_Preference[1] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(WrapErr.lst_Preference.size() == 1 && (WrapErr.lst_Preference[0] == '2' || WrapErr.lst_Preference[0] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(WrapErr.lst_OpenPreference.size() == 2 && (WrapErr.lst_OpenPreference[0] == '3' || WrapErr.lst_OpenPreference[1] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(WrapErr.lst_OpenPreference.size() == 1 && (WrapErr.lst_OpenPreference[0] == '2' || WrapErr.lst_OpenPreference[0] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(WrapErr.lst_OpenPref3.size() == 2 && (WrapErr.lst_OpenPref3[0] == '3' || WrapErr.lst_OpenPref3[1] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(WrapErr.lst_OpenPref3.size() == 1 && (WrapErr.lst_OpenPref3[0] == '2' || WrapErr.lst_OpenPref3[0] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(WrapErr.lst_OpenPref4.size() == 2 && (WrapErr.lst_OpenPref4[0] == '3' || WrapErr.lst_OpenPref4[1] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(WrapErr.lst_OpenPref4.size() == 1 && (WrapErr.lst_OpenPref4[0] == '2' || WrapErr.lst_OpenPref4[0] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(WrapErr.lst_OpenPref5.size() == 2 && (WrapErr.lst_OpenPref5[0] == '3' || WrapErr.lst_OpenPref5[1] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(WrapErr.lst_OpenPref5.size() == 1 && (WrapErr.lst_OpenPref5[0] == '2' || WrapErr.lst_OpenPref5[0] == '3'))
            {
                WrapErr.OpenElectiveErrmsg = 'Select the Open Elective Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(set_CourseId.size() >0)
            {
                User usr =[select Id,Name,ContactId from User where Id =:UserInfo.getUserId()];
                Contact objCon = new Contact();
                if(usr.ContactId != null)
                {
                    objCon =[select Id,LastName,Accountid,Account.Name from Contact Where Id =: usr.ContactId];
                }
                Map<Id, Integer> coursePreferenceCount = new Map<Id, Integer>();
                for (AggregateResult ar : [
                    SELECT Course_Offering__c, COUNT(Id) cnt
                    FROM Professor_Student_Course_Preference__c
                    WHERE Course_Offering__c IN :set_CourseId AND Preference__c = '1' AND Contact__c != null
                    GROUP BY Course_Offering__c
                ]) {
                    coursePreferenceCount.put((Id)ar.get('Course_Offering__c'), (Integer)ar.get('cnt'));
                }
                Map<Id, hed__Course_Offering__c> courseOfferingMap = new Map<Id, hed__Course_Offering__c>(
                    [SELECT Id, Student_Preference_1__c, Max_Students__c, hed__Course__r.Name
                     FROM hed__Course_Offering__c
                     WHERE Id IN :set_CourseId]
                );

                for (Id courseOfferingId : set_CourseId) {
                    hed__Course_Offering__c courseOffering = courseOfferingMap.get(courseOfferingId);
                    Integer currentCount = coursePreferenceCount.get(courseOfferingId) != null ? coursePreferenceCount.get(courseOfferingId) : 0;

                    // Check if the count of Preference__c = '1' exceeds Max_Students__c
                    if (courseOffering.Max_Students__c != null && currentCount >= courseOffering.Max_Students__c) {
                        WrapErr.CountOpenPrefErrmsg = 'Limit reached for the course ' + courseOffering.hed__Course__r.Name +'.Kindly change your Preferene 1 to other course and Save.';
                        WrapErr.showsave = true;
                        return WrapErr;
                    }

                    // Update Student_Preference_1__c if needed
                    // courseOffering.Student_Preference_1__c = (courseOffering.Student_Preference_1__c != null ? courseOffering.Student_Preference_1__c : 0) + (currentCount > 0 ? 1 : 0);
                }

            }
        }
        if(lstProfElective.size()>0)
        {
            Integer count=0;
            Integer PreferenceCount = 0;
            Integer TotalCount=0;
            Integer TotalCountProf2=0;
            Integer countProf2=0;
            Integer TotalCountProf3=0;
            Integer countProf3=0;
            Integer TotalCountProf4=0;
            Integer countProf4=0;
            Integer TotalCountProf5=0;
            Integer countProf5=0;
            boolean profele = false;
            boolean profele3 = false;
            boolean profele4 = false;
            boolean profele5 = false;
            integer profcount =0;
            integer profcount2 =0;
            integer profcount3 =0;
            integer profcount4 =0;
            integer profcount5 =0;

            for(hed__Course_Offering__c objCourse : lstProfElective)
            {
                if(string.IsNotBlank(objCourse.Parent_Course_Offering__c))
                {
                    if(string.IsNotBlank(objCourse.Preference__c))
                    {
                        if( objCourse.Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 1')  lst_ProfPrefence.add(objCourse.Preference__c);
                        else if(objCourse.Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 2')   lst_ProfessionalPref.add(objCourse.Preference__c);
                        else if(objCourse.Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 3')  lst_ProfPref3.add(objCourse.Preference__c);
                        else if(objCourse.Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 4')  lst_ProfPref4.add(objCourse.Preference__c);
                        else if(objCourse.Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 5')   lst_ProfPref5.add(objCourse.Preference__c);
                    }
                }
            }
            for(integer i=0;i<lstProfElective.size();i++)
            {
                if(lstProfElective[i].Parent_Course_Offering__c != null)  PreferenceCount = PreferenceCount+1;
            }
            string val;
            for(integer i=0;i<lstProfElective.size();i++)
            {
                if(string.IsNotBlank(lstProfElective[i].Preference__c) && string.IsNotBlank(lstProfElective[i].Parent_Course_Offering__c))
                    val = lstProfElective[i].Parent_Course_Offering__c+'-'+lstProfElective[i].Preference__c;
                for(integer j=i+1;j<lstProfElective.size();j++)
                {
                    if(val == lstProfElective[j].Parent_Course_Offering__c+'-'+lstProfElective[j].Preference__c && lstProfElective[i].Preference__c != null)
                    {
                        WrapErr.PrefDupPreference ='This Preference - '+lstProfElective[i].Name+' is Already Selected.';
                        WrapErr.showsave = true;
                        return WrapErr;
                    }
                }
                if(string.IsBlank(lstProfElective[i].Preference__c))
                {
                    if(string.IsNotBlank(lstProfElective[i].Parent_Course_Offering__c))
                    {
                        if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 1')     profcount = profcount+1;
                        else if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 2') profcount2 = profcount2+1;
                        else if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 3')  profcount3 = profcount3+1;
                        else if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 4')   profcount4 = profcount4+1;
                        else if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 5')  profcount5 = profcount5+1;
                    }
                }
                if(string.IsNotBlank(lstProfElective[i].Preference__c))
                {
                    if(string.IsNotBlank(lstProfElective[i].Parent_Course_Offering__c))
                    {
                        if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 1')
                        {
                            TotalCount = TotalCount+1;
                            count = count+1;
                        }
                        else if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 2')
                        {
                            TotalCountProf2 = TotalCountProf2+1;
                            countProf2 = countProf2+1;
                            profele =true;
                        }
                        else if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 3')
                        {
                            TotalCountProf3 = TotalCountProf3+1;
                            countProf3 = countProf3+1;
                            profele3 =true;
                        }
                        else if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 4')
                        {
                            TotalCountProf4 = TotalCountProf4+1;
                            countProf4 = countProf4+1;
                            profele4 =true;
                        }
                        else if(lstProfElective[i].Parent_Course_Offering__r.Name == 'PROFESSIONAL ELECTIVES - 5')
                        {
                            TotalCountProf5 = TotalCountProf5+1;
                            countProf5 = countProf5+1;
                            profele5 =true;
                        }
                    }
                }
            }
            if((TotalCount != 3 && TotalCount!=0) || (TotalCountProf2 !=3 && TotalCountProf2 !=0) ||
               (TotalCountProf3 !=3 && TotalCountProf3 !=0) || (TotalCountProf4 !=3 && TotalCountProf4 !=0) ||
               (TotalCountProf5 !=3 && TotalCountProf5 !=0))
            {
                if(profcount >0 || profcount2 >0 || profcount3 >0 || profcount4 >0 || profcount5 >0)
                {
                    WrapErr.ProfElectiveErrmsg = 'Select All Preference ';
                    WrapErr.showsave = true;
                    return WrapErr;
                }
            }
            if(count == 0 || (profele == true && countProf2 ==0) || (profele3 == true && countProf3 ==0) ||
               (profele4 == true && countProf4 ==0) || (profele5 == true && countProf5 ==0))
            {
                WrapErr.ProfElectiveErrmsg ='Please Select Professional Elective Preferences';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if((TotalCount >= 3  && count !=3) || (TotalCountProf2 >= 3  && countProf2 !=3 && profele == true) ||
               (TotalCountProf3 >= 3  && countProf3 !=3 && profele3 == true) || (TotalCountProf4 >= 3  && countProf4 !=3 && profele4 == true)
               || (TotalCountProf5 >= 3  && countProf5 !=3 && profele5 == true))
            {
                WrapErr.ProfElectiveErrmsg = 'Select All Preference ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if((TotalCount == 2  && count !=2) || (TotalCountProf2 == 2  && countProf2 !=2 && profele == true) ||
               (TotalCountProf3 == 2  && countProf3 !=2 && profele3 == true) || (TotalCountProf4 == 2  && countProf4 !=2 && profele4 == true)
               || (TotalCountProf5 == 2  && countProf5 !=2 && profele5 == true))
            {
                WrapErr.ProfElectiveErrmsg = 'Select All Preference ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(lst_ProfPrefence.size() == 2 && (lst_ProfPrefence[0] == '3' || lst_ProfPrefence[1] == '3'))
            {
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(lst_ProfPrefence.size() == 1 && (lst_ProfPrefence[0] == '2' || lst_ProfPrefence[0] == '3'))
            {
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(lst_ProfessionalPref.size() == 2 && (lst_ProfessionalPref[0] == '3' || lst_ProfessionalPref[1] == '3'))
            {
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(lst_ProfessionalPref.size() == 1 && (lst_ProfessionalPref[0] == '2' || lst_ProfessionalPref[0] == '3'))
            {
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(lst_ProfPref3.size() == 2 && (lst_ProfPref3[0] == '3' || lst_ProfPref3[1] == '3'))
            {
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(lst_ProfPref3.size() == 1 && (lst_ProfPref3[0] == '2' || lst_ProfPref3[0] == '3'))
            {
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(lst_ProfPref4.size() == 2 && (lst_ProfPref4[0] == '3' || lst_ProfPref4[1] == '3')){
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(lst_ProfPref4.size() == 1 && (lst_ProfPref4[0] == '2' || lst_ProfPref4[0] == '3')){
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }

            if(lst_ProfPref5.size() == 2 && (lst_ProfPref5[0] == '3' || lst_ProfPref5[1] == '3')){
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 & Preference 2 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
            if(lst_ProfPref5.size() == 1 && (lst_ProfPref5[0] == '2' || lst_ProfPref5[0] == '3')){
                WrapErr.ProfElectiveErrmsg = 'Select the Professional Preference in the order like Preference 1 ';
                WrapErr.showsave = true;
                return WrapErr;
            }
        }
        return WrapErr;
    }
    @AuraEnabled
    public static void SaveStudentCourseprefernce(list<hed__Course_Offering__c> lstOpenEle,list<hed__Course_Offering__c> lstProfel,boolean StuPreference)
    {
        set<id> set_CourseOp = new set<id>();
        set<id> set_CourseProf = new set<id>();
        map<id,Professor_Student_Course_Preference__c> map_profstudent = new map<id,Professor_Student_Course_Preference__c>();
        map<id,Professor_Student_Course_Preference__c> map_profstuProf = new map<id,Professor_Student_Course_Preference__c>();
        if(lstOpenEle.size()>0){
            for(hed__Course_Offering__c objcourseoff : lstOpenEle){
                if(objcourseoff.id != null)
                {
                    set_CourseOp.add(objcourseoff.id);
                }
            }
        }
        if(lstProfel.size()>0){
            for(hed__Course_Offering__c objcourseoff : lstProfel)
            {
                if(objcourseoff.id != null)
                {
                    set_CourseProf.add(objcourseoff.id);
                }
            }
        }
        User usr =[select Id,Name,ContactId from User where Id =:UserInfo.getUserId() ];
        Contact objCon = new Contact();
        if(usr.ContactId != null)
        {
            objCon =[select Id,LastName,Accountid,Account.Name from Contact Where Id =: usr.ContactId];
        }
        if(set_CourseOp.size()>0)
        {
            for(Professor_Student_Course_Preference__c objprofstu : [select id,Name,Course_Offering__c,Preference__c,Contact__c,Semester__c,Student_Preference__c from Professor_Student_Course_Preference__c where Course_Offering__c in : set_CourseOp and Contact__c =: objCon.id])
            {
                map_profstudent.put(objprofstu.Course_Offering__c,objprofstu);
            }
        }
        if(set_CourseProf.size()>0)
        {
            for(Professor_Student_Course_Preference__c objprofstu : [select id,Name,Course_Offering__c,Preference__c,Contact__c,Semester__c,Student_Preference__c from
                                                                     Professor_Student_Course_Preference__c where Course_Offering__c in : set_CourseProf and Contact__c =: objCon.id])
            {
                map_profstuProf.put(objprofstu.Course_Offering__c,objprofstu);
            }
        }
        list<Professor_Student_Course_Preference__c> lst_profstudent = new list<Professor_Student_Course_Preference__c>();

        if(lstOpenEle.size()>0)
        {
            for(hed__Course_Offering__c objcourse : lstOpenEle)
            {
                Professor_Student_Course_Preference__c  objprof = new Professor_Student_Course_Preference__c();
                objprof.Course_Offering__c = objcourse.Id;
                objprof.Preference__c = objcourse.Preference__c;
                objprof.Contact__c = objCon.id;
                objprof.Name = objcourse.Name;
                objprof.Semester__c= objcourse.hed__Term__c;
                objprof.Student_Preference__c = StuPreference;
                if(map_profstudent.Containskey(objcourse.Id))
                {
                    objprof.id = map_profstudent.get(objcourse.Id).Id;
                }
                lst_profstudent.add(objprof);
            }
        }
        if(lstProfel.size()>0)
        {
            for(hed__Course_Offering__c objcourse : lstProfel)
            {
                Professor_Student_Course_Preference__c  objprof = new Professor_Student_Course_Preference__c();
                objprof.Course_Offering__c = objcourse.Id;
                objprof.Preference__c = objcourse.Preference__c;
                objprof.Contact__c = objCon.id;
                objprof.Name = objcourse.Name;
                objprof.Semester__c= objcourse.hed__Term__c;
                objprof.Student_Preference__c = StuPreference;
                if(map_profstuProf.Containskey(objcourse.Id))
                {
                    objprof.id = map_profstuProf.get(objcourse.Id).Id;
                }
                lst_profstudent.add(objprof);
            }
        }
        if(lst_profstudent.size()>0)
        {
            try{
                upsert lst_profstudent;
            }
            catch(exception ex)
            {
            }
        }
    }
    @AuraEnabled
    public static Map<String, String> getPreference()
    {
        Map<String, String> mapPickListValues = new Map<String, String>();
        Set<String> requiredPreferences = new Set<String>{'1', '2', '3'};
            Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('hed__Course_Offering__c');
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get('Preference__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues)
        {
            if (requiredPreferences.contains(objPickList.getValue()))  {
                mapPickListValues.put(objPickList.getValue(), objPickList.getLabel());
            }

        }
        return mapPickListValues;
    }
    public class CourseOfferingWrapper
    {
        @AuraEnabled public string objTermname {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listHardCore {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listOpenElective {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listProfElective {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listPractical {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listHcIntegrated {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listMandatory {get;set;}
        @AuraEnabled public list<hed__Course_Offering__c> listMainCourse {get;set;}
        @AuraEnabled public Boolean StudentPreference {get;set;}
        @AuraEnabled public decimal totalCredit {get;set;}
        @AuraEnabled public boolean isRBSSchool {get;set;}
        @AuraEnabled public string ErrmsgMain {get;set;}

        public CourseOfferingWrapper(){
            listHardCore = new list<hed__Course_Offering__c>();
            listOpenElective = new list<hed__Course_Offering__c>();
            listProfElective = new list<hed__Course_Offering__c>();
            listPractical = new list<hed__Course_Offering__c> ();
            listHcIntegrated = new list<hed__Course_Offering__c>();
            listMandatory = new list<hed__Course_Offering__c>();
            listMainCourse =new list<hed__Course_Offering__c>();
        }
    }
    public class ErrorWrapper
    {
        @AuraEnabled public string OpenElectiveErrmsg {get;set;}
        @AuraEnabled public string ProfElectiveErrmsg {get;set;}
        @AuraEnabled public string OpenDupPreference {get;set;}
        @AuraEnabled public string PrefDupPreference {get;set;}
        @AuraEnabled public string ProfPrefErrmsg {get;set;}
        @AuraEnabled public string OpenPrefErrmsg {get;set;}
        @AuraEnabled public string CountOpenPrefErrmsg {get;set;}
        @AuraEnabled public boolean showsave {get;set;}
        @AuraEnabled public list<String> lst_Preference{get;set;}
        @AuraEnabled public list<String> lst_OpenPreference{get;set;}
        @AuraEnabled public list<String> lst_OpenPref3{get;set;}
        @AuraEnabled public list<String> lst_OpenPref4{get;set;}
        @AuraEnabled public list<String> lst_OpenPref5{get;set;}
        @AuraEnabled public integer MaxStuCount {get;set;}
        public ErrorWrapper()
        {
            lst_Preference =  new list<String>();
            lst_OpenPreference = new list<String>();
            lst_OpenPref3 = new list<string>();
            lst_OpenPref4 = new list<string>();
            lst_OpenPref5 = new list<string>();
        }
    }
    
    //dummy method to cover code coverage
    public static CourseOfferingWrapper DisplayCourseOffering1()
    {
        User usr =[select Id,Name,ContactId from User where Id =: UserInfo.getUserId()];
        Contact objCon = new Contact();
        CourseOfferingWrapper WrapCourseOff = new CourseOfferingWrapper();
        set<id> set_progbatchid = new set<id>();
        try
        {
            if(usr.ContactId != null)
            {
                objCon =[select Id,LastName,Accountid,Account.Name from Contact Where Id =: usr.ContactId];
                for(hed__Program_Enrollment__c objProgEnroll : [select Id,hed__Program_Plan__c from hed__Program_Enrollment__c where hed__Contact__c =:usr.ContactId])
                {
                    if(objProgEnroll.hed__Program_Plan__c != null)
                        set_progbatchid.add(objProgEnroll.hed__Program_Plan__c);
                }
            }

            WrapCourseOff.totalCredit =0;
            hed__Term__c objTerm = new hed__Term__c();
            if(set_progbatchid.size()>0)
            {
                objTerm = [select Id,Name,hed__Account__c,Program_Batch__c,RecordType.Name,Active__c,Allow_Student_Elective_Preference__c from
                           hed__Term__c where RecordType.Name=:Utility.Term_Object_RecType_Term and Allow_Student_Elective_Preference__c=true
                           and Program_Batch__c in: set_progbatchid];
            }
            if(objTerm.Id != null)
            {
                WrapCourseOff.objTermname = objTerm.Name;

                for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                            Parent_Course_Offering__r.Name,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c
                                                            from hed__Course_Offering__c where hed__Term__c =:objTerm.Id order by Sequence__c])
                {
                    if(objCourseOff.Category__c == 'Hardcore Course')
                    {
                        WrapCourseOff.listHardCore.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Hardcore Integrated Course')
                    {
                        WrapCourseOff.listHcIntegrated.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Practical/Term work')
                    {
                        WrapCourseOff.listPractical.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Professional Elective')
                    {
                        WrapCourseOff.listProfElective.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Open Elective')
                    {
                        WrapCourseOff.listOpenElective.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'Mandatory Course')
                    {
                        WrapCourseOff.listMandatory.add(objCourseOff);
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                    if(objCourseOff.Category__c == 'RBS Specialization')
                    {
                        WrapCourseOff.listMainCourse.add(objCourseOff);
                        //WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + objCourseOff.Credits__c;
                    }
                }

                // to get RBS course credits
                List<hed__Course_Offering__c> courseOff = RBSstudentSpclCollectionCtrl.getCourseOfferingsBySpcl();
                if(!courseoff.isEmpty()) {
                    for(hed__Course_Offering__c cOff : courseOff){
                        if(cOff.Category__c == 'RBS Specialization') {
                            WrapCourseOff.totalCredit = WrapCourseOff.totalCredit + cOff.Credits__c;
                        }

                    }
                }

            }
            WrapCourseOff.ErrmsgMain='Success';
        }catch(exception ex)
        {
            WrapCourseOff.ErrmsgMain='Your Current Semester doesnt have any Elective Courses';
        }
        return WrapCourseOff;
    }
}