/**
 * @description This class is responsible for managing professor course preferences.
 * @author Devender Jadala
 * @date 2025-08-02
 */
public with sharing class MSTR_DefineProfessorCourseV1_Ctrl
{

    /**
     * @description Retrieves and displays the schools associated with the logged-in user.
     * @return A SchoolWrapper object containing school details.
     */
    @AuraEnabled
    public static SchoolWrapper displaySchools()
    {
        SchoolWrapper schWrap = new SchoolWrapper();
        string accSchoolName;
        User usr =[select Id,Name,Email ,ContactId from User where Id =:userinfo.getUserId() WITH USER_MODE ];
        if(usr.Id != null)
        {
            for(Contact objCon : [select Id,LastName,Email,OwnerId,Accountid,Account.Name,Account.RecordType.Name,Professor_Across_Schools__c
                                  from Contact Where Email =: usr.Email and
                                  Account.RecordType.Name =: Utility.Acc_RecType_University_Department WITH USER_MODE])
            {
                if(objCon.Professor_Across_Schools__c == true)
                {
                    schWrap.profSchool = true;
                    schWrap.mapAccSchool.put(objCon.AccountId,objCon.Account.Name);
                    accSchoolName = objCon.Account.Name;
                    schWrap.loginUserAccountName = objCon.Account.Name;
                }
                else
                {
                    schWrap.mapAccSchool.put(objCon.AccountId,objCon.Account.Name);
                    schWrap.loginUserAccountName = objCon.Account.Name;
                }
            }
            if(schWrap.profSchool == true)
            {
                list<hed__Course_Offering__c> lstCourseOff = new list<hed__Course_Offering__c>();
                lstCourseOff = [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Course_Across_the_School__c,School__c,School_ID__c,hed__Course__r.Name,Course_ID__c,  Credits__c,hed__Term__c,Offered_By_School__c,Offered_By_School__r.Name,
                                 hed__Term__r.Active__c,Approval_Required_by_School_Head__c,  hed__Term__r.Allow_Professors_for_Preferences__c from hed__Course_Offering__c where
                                hed__Term__r.Allow_Professors_for_Preferences__c =:true and hed__Course__r.Course_Across_the_School__c=: true WITH USER_MODE order by Sequence__c ];
                for(hed__Course_Offering__c objCourseOff : lstCourseOff )
                {
                    // if(objCourseOff.Offered_By_School__r.Name == AccSchoolName)
                    // {
                        schWrap.mapAccSchool.put(objCourseOff.School_ID__c,objCourseOff.School__c);
                        schWrap.courseAcross = objCourseOff.hed__Course__r.Course_Across_the_School__c;
                    // }
                }
            }
        }
        return schWrap;
    }

    /**
     * @description Retrieves and displays the academic programs for a given school.
     * @param accSchoolId The ID of the school account.
     * @param selCourseAcross Indicates if courses across schools should be considered.
     * @param loginAccountName The name of the logged-in user's account.
     * @return A map of program IDs and their corresponding names.
     */
    @AuraEnabled
    public static Map<Id,String> displayProgram(String accSchoolId,boolean selCourseAcross,string loginAccountName)
    {
        Map<Id,String> mapAccProgram = new Map<Id,String>();
       // SchoolWrapper schWrap = new SchoolWrapper();

        if(selCourseAcross == true)
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,hed__Course__c,hed__Course__r.Course_Across_the_School__c,hed__Course__r.Name,hed__Term__c,Offered_By_School__c,School_ID__c,
                                                        Offered_By_School__r.Name,hed__Term__r.Active__c, hed__Term__r.Allow_Professors_for_Preferences__c,Approval_Required_by_School_Head__c,Program__c,hed__Term__r.Program_Batch__c,Course_ID__c,
                                                        hed__Term__r.Program_Batch__r.hed__Account__c,hed__Term__r.Program_Batch__r.hed__Account__r.RecordType.Name,hed__Term__r.Program_Batch__r.hed__Account__r.Name
                                                        from hed__Course_Offering__c where  Offered_By_School__c =: accSchoolId AND hed__Term__r.Allow_Professors_for_Preferences__c =:true
                                                         WITH USER_MODE order by Sequence__c])
            {
                //if(objCourseOff.Offered_By_School__r.Name ==accSchoolId)
                mapAccProgram.put(objCourseOff.hed__Term__r.Program_Batch__r.hed__Account__c,objCourseOff.hed__Term__r.Program_Batch__r.hed__Account__r.Name);
            }
        }
        else
        {
            Set<Id> programIdsWithEnabledTerms = new Set<Id>();
            for(hed__Term__c term : [SELECT hed__Account__c 
                                     FROM hed__Term__c 
                                     WHERE Allow_Professors_for_Preferences__c = true 
                                     WITH USER_MODE]) {
                if(term.hed__Account__c != null) {
                    programIdsWithEnabledTerms.add(term.hed__Account__c);
                }
            }
            for(Account objAcc : [select Id,Name,RecordType.Name,Parentid,Sequence__c from Account Where
                                  RecordType.Name = :Utility.Acc_RecType_Academic_Program and Parentid =:accSchoolId 
                                  AND Id IN :programIdsWithEnabledTerms 
                                  WITH USER_MODE order by Sequence__c])
            {
                mapAccProgram.put(objAcc.Id,objAcc.Name);
            }
        }
        return mapAccProgram;
    }

    /**
     * @description Retrieves and displays the program plans for a given academic program.
     * @param accProgramId The ID of the academic program account.
     * @param selCourseAcross Indicates if courses across schools should be considered.
     * @param loginAccountName The name of the logged-in user's account.
     * @return A map of program plan IDs and their corresponding names.
     */
    @AuraEnabled
    public static Map<Id,String> displayProgramPlan(string accProgramId,boolean selCourseAcross,string loginAccountName)
    {
        Map<Id,String> mapAccProgramPlan = new Map<Id,String>();
        set<id> setProgBatchid =new set<id>();

        if(selCourseAcross == true)
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,hed__Course__c,hed__Course__r.Course_Across_the_School__c,hed__Course__r.Name,hed__Term__c,Offered_By_School__c,Course_ID__c,
                                                        Offered_By_School__r.Name,hed__Term__r.Active__c,hed__Term__r.Allow_Professors_for_Preferences__c ,Approval_Required_by_School_Head__c,Program__c,hed__Term__r.Program_Batch__c,hed__Term__r.Program_Batch__r.hed__Start_Date__c,
                                                        hed__Term__r.Program_Batch__r.hed__Account__c,hed__Term__r.Program_Batch__r.Name,hed__Term__r.hed__Account__c,Program_batch_ID__c,hed__Term__r.Program_Batch__r.hed__End_Date__c
                                                        from hed__Course_Offering__c where hed__Term__r.Program_Batch__r.hed__Account__c =: accProgramId
                                                        and hed__Term__r.Allow_Professors_for_Preferences__c =:true WITH USER_MODE order by hed__Term__r.Program_Batch__r.hed__Start_Date__c])
            {
                setProgBatchid.add(objCourseOff.hed__Term__r.Program_Batch__c);
                // mapAccProgramPlan.put(objCourseOff.hed__Term__r.Program_Batch__c,objCourseOff.hed__Term__r.Program_Batch__r.Name);
            }
            if(setProgBatchid.size()>0)
            {
                for(hed__Course_Offering__c objCourseOff : [select Id,Name,hed__Course__c,hed__Course__r.Course_Across_the_School__c,hed__Course__r.Name,hed__Term__c,Offered_By_School__c,Course_ID__c,
                                                            Offered_By_School__r.Name,hed__Term__r.Active__c,hed__Term__r.Allow_Professors_for_Preferences__c ,Approval_Required_by_School_Head__c,Program__c,hed__Term__r.Program_Batch__c,hed__Term__r.Program_Batch__r.hed__Start_Date__c,
                                                            hed__Term__r.Program_Batch__r.hed__Account__c,hed__Term__r.Program_Batch__r.Name,hed__Term__r.hed__Account__c,Program_batch_ID__c,hed__Term__r.Program_Batch__r.hed__End_Date__c
                                                            from hed__Course_Offering__c where Program_batch_ID__c in: setProgBatchid and
                                                            hed__Term__r.Allow_Professors_for_Preferences__c =:true WITH USER_MODE order by hed__Term__r.Program_Batch__r.hed__Start_Date__c])
                {
                    mapAccProgramPlan.put(objCourseOff.hed__Term__r.Program_Batch__c,objCourseOff.hed__Term__r.Program_Batch__r.Name);
                }
            }
        }
        else
        {
            Set<Id> programIdsWithEnabledTerms = new Set<Id>();
            for(hed__Term__c term : [SELECT Program_Batch__c 
                                     FROM hed__Term__c 
                                     WHERE Allow_Professors_for_Preferences__c = true 
                                     WITH USER_MODE]) {
                if(term.Program_Batch__c != null) {
                    programIdsWithEnabledTerms.add(term.Program_Batch__c);
                }
            }
            for(hed__Program_Plan__c objProgramPlan : [select Id,Name,hed__Account__c,hed__Start_Date__c from hed__Program_Plan__c where
                                                       hed__Account__c =:accProgramId AND Id IN :programIdsWithEnabledTerms and Active__c =: true  WITH USER_MODE order by hed__Start_Date__c])
            {
                mapAccProgramPlan.put(objProgramPlan.Id,objProgramPlan.Name);
            }
        }
        return mapAccProgramPlan;
    }

    /**
     * @description Retrieves and displays the terms for a given program plan.
     * @param accProgramPlanId The ID of the academic program plan.
     * @param selCourseAcross Indicates if courses across schools should be considered.
     * @param loginAccountName The name of the logged-in user's account.
     * @return A map of term IDs and their corresponding names.
     */
    @AuraEnabled
    public static Map<Id,String> displayTerm(string accProgramPlanId,boolean selCourseAcross,string loginAccountName)
    {
        Map<Id,String> mapAccTerm = new Map<Id,String>();
        //SchoolWrapper schWrap = new SchoolWrapper();
        if(selCourseAcross == true)
        {
            //set<id>  set_Termid = new set<id>();
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,hed__Course__c,hed__Course__r.Course_Across_the_School__c,hed__Course__r.Name,hed__Term__c,Offered_By_School__c,hed__Term__r.Name,
                                                        Offered_By_School__r.Name,hed__Term__r.Active__c,hed__Term__r.Allow_Professors_for_Preferences__c ,Approval_Required_by_School_Head__c,Program__c,hed__Term__r.Program_Batch__c,Course_ID__c,
                                                        hed__Term__r.Program_Batch__r.hed__Account__c,hed__Term__r.Program_Batch__r.Name,hed__Term__r.RecordType.Name,hed__Term__r.Approval_Status__c
                                                        from hed__Course_Offering__c where hed__Term__r.Program_Batch__c =: accProgramPlanId and hed__Term__r.RecordType.Name =:Utility.Term_Object_RecType_Term and
                                                         hed__Term__r.Allow_Professors_for_Preferences__c =:true  and hed__Course__r.Course_Across_the_School__c =: true  WITH USER_MODE
                                                         order by hed__Term__r.Name])
            {
                mapAccTerm.put(objCourseOff.hed__Term__c,objCourseOff.hed__Term__r.Name);

            }
        }
        else
        {

            for(hed__Term__c objTerm : [select Id,Name,hed__Account__c,Program_Batch__c,RecordType.Name,Active__c,Approval_Status__c from hed__Term__c where
                                        Program_Batch__c =:accProgramPlanId and RecordType.Name=:Utility.Term_Object_RecType_Term  and Allow_Professors_for_Preferences__c = true  WITH USER_MODE order by Name])
            {
                mapAccTerm.put(objTerm.Id,objTerm.Name);
            }
        }
        return mapAccTerm;
    }


    /**
     * @description Retrieves and displays course offering records based on the provided term, school, and user preferences.
     * @param accTermId The ID of the academic term.
     * @param selCourseAcross Indicates if courses across schools should be considered.
     * @param loginAccountName The name of the logged-in user's account.
     * @param accSchoolId The ID of the school account.
     * @return A CourseOfferingWrapper object containing course offering details.
     */
    @AuraEnabled
    public static CourseOfferingWrapper displayCourseOfferingRecords(string accTermId,boolean selCourseAcross,string loginAccountName,string accSchoolId)
    {
        CourseOfferingWrapper wrapCourseOff = new CourseOfferingWrapper();
        set<id> setCourseIds  = new set<id>();
        set<string> setAccIds = new set<string>();
        set<string> setCategory = new set<string>();
        wrapCourseOff.professorPreference = false ;
        if(accSchoolId != null)
        {
            for(Account objAcc : [select Id,Name,RecordType.Name,Parentid,Sequence__c,Parent.Name from Account Where
                                  RecordType.Name = :Utility.Acc_RecType_Academic_Program and Parentid =:accSchoolId  WITH USER_MODE order by Sequence__c])
            {
                if(objAcc.Parent.Name == loginAccountName) {
                    setAccIds.add(objAcc.Parent.Name);
                }
            }
        }
        list<hed__Course_Offering__c> lstCourseOffering = new list<hed__Course_Offering__c>();
        map<id,Professor_Student_Course_Preference__c> mapProfstudent= new map<id,Professor_Student_Course_Preference__c>();
        User usr =[select Id,Name,ContactId from User where Id =:userinfo.getUserId() WITH USER_MODE];
        if(usr.Id != null)
        {
            Contact objCon =[select Id,OwnerId,Account.RecordType.Name from Contact Where OwnerId =: usr.Id and Account.RecordType.Name =: Utility.Acc_RecType_University_Department WITH USER_MODE];


            for(Professor_Student_Course_Preference__c objProfStu : [select Id,Name,Contact__c,Course_Offering__c,Preference__c,Professor__c,
                                                                     Professor_Preference__c,Semester__c,Course_Offering__r.Category__c,Course_ID__c,Number_of_Times_Course_Handled__c
                                                                     from Professor_Student_Course_Preference__c where Semester__c =:accTermId
                                                                     and Course_Offering__c !=: null and Professor__c =: objCon.id WITH USER_MODE])
            {
                if(objProfStu.Course_Offering__c != null)
                {
                    setCourseIds.add(objProfStu.Course_Offering__c);
                    mapProfstudent.put(objProfStu.Course_Offering__c,objProfStu);
                    //wrapCourseOff.professorPreference = objProfStu.Professor_Preference__c;
                    setCategory.add(objProfStu.Course_Offering__r.Category__c+'-'+objProfStu.Course_ID__c);
                }
            }

            for (Professor_Student_Course_Preference__c objProfStu1 : [
                                                            SELECT Id, Name, Contact__c, Course_Offering__c, Preference__c, Professor__c,
                                                                Professor_Preference__c, Semester__c, Course_Offering__r.Category__c, Course_ID__c,Number_of_Times_Course_Handled__c
                                                            FROM Professor_Student_Course_Preference__c
                                                            WHERE  Semester__r.Allow_Professors_for_Preferences__c = true
                                                            AND Course_Offering__c != null
                                                            AND Professor__c = :objCon.Id WITH USER_MODE]) {
                if (objProfStu1.Course_Offering__c != null && objProfStu1.Professor_Preference__c == true  ) {
                    wrapCourseOff.professorPreference = objProfStu1.Professor_Preference__c;
                }
          }


        }
        if(setCourseIds.size()>0)
        {
            set<string> setCourseIdValid=new  set<string>();
            if(setAccIds.size() >0)
            {
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Course__r.HardCore_Sub_Type__c,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c,Offered_By_School__c,Number_of_Times_Course_Handled__c
                                                   from hed__Course_Offering__c where hed__Term__c =:accTermId and Id in: setCourseIds and  hed__Term__r.Allow_Professors_for_Preferences__c = true
                                                   WITH USER_MODE order by Sequence__c])
                {
                    if(!setCourseIdValid.contains(cour.Course_ID__c))
                    {
                        setCourseIdValid.add(cour.Course_ID__c);
                        lstCourseOffering.add(cour);
                    }
                }
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Course__r.HardCore_Sub_Type__c,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c,Offered_By_School__c,Active__c,Number_of_Times_Course_Handled__c
                                                   from hed__Course_Offering__c where hed__Term__c =:accTermId AND Active__c = true AND Credits__c >= 1.0
                                                   and   Category__c not in: setCategory and  hed__Term__r.Allow_Professors_for_Preferences__c = true WITH USER_MODE
                                                   order by Sequence__c])
                {
                    if(!setCourseIdValid.contains(cour.Course_ID__c))
                    {
                        setCourseIdValid.add(cour.Course_ID__c);
                        lstCourseOffering.add(cour);
                    }
                }
            }
            else if(selCourseAcross == true)
            {
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c ,hed__Course__r.HardCore_Sub_Type__c,Offered_By_School__c,Number_of_Times_Course_Handled__c
                                                   from hed__Course_Offering__c where hed__Term__c =:accTermId and Id in: setCourseIds
                                                   and hed__Course__r.Course_Across_the_School__c =: true
                                                   and hed__Term__r.Allow_Professors_for_Preferences__c = true WITH USER_MODE order by Sequence__c])
                {
                    if(!setCourseIdValid.contains(cour.Course_ID__c))
                    {
                        setCourseIdValid.add(cour.Course_ID__c);
                        lstCourseOffering.add(cour);
                    }
                }
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c ,hed__Course__r.HardCore_Sub_Type__c,Offered_By_School__c,Active__c,Number_of_Times_Course_Handled__c
                                                   from hed__Course_Offering__c where hed__Term__c =:accTermId AND Active__c = true AND Credits__c >= 1.0
                                                   and hed__Course__r.Course_Across_the_School__c =: true and Category__c not in: setCategory
                                                   and hed__Term__r.Allow_Professors_for_Preferences__c = true WITH USER_MODE order by Sequence__c])
                {
                    if(!setCourseIdValid.contains(cour.Course_ID__c))
                    {
                        setCourseIdValid.add(cour.Course_ID__c);
                        lstCourseOffering.add(cour);
                    }
                }
            }
            else
            {
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c ,hed__Course__r.HardCore_Sub_Type__c,Offered_By_School__c,Active__c,Number_of_Times_Course_Handled__c
                                                   from hed__Course_Offering__c where hed__Term__c =:accTermId and hed__Term__r.Allow_Professors_for_Preferences__c = true
                                                   AND Active__c = true AND Credits__c >= 1.0
                                                   and Id in: setCourseIds WITH USER_MODE  order by Sequence__c])
                {
                    if(!setCourseIdValid.contains(cour.Course_ID__c))
                    {
                        setCourseIdValid.add(cour.Course_ID__c);
                        lstCourseOffering.add(cour);
                    }
                }
                for(hed__Course_Offering__c cour: [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,
                                                   hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c ,Max_Professors_Per_Course__c,Min_Professors_Per_Course__c,
                                                   hed__Course__r.Course_Across_the_School__c,Course_ID__c ,hed__Course__r.HardCore_Sub_Type__c,Offered_By_School__c,Active__c,Number_of_Times_Course_Handled__c
                                                   from hed__Course_Offering__c where hed__Term__c =:accTermId and hed__Term__r.Allow_Professors_for_Preferences__c = true
                                                   AND Active__c = true AND Credits__c >= 1.0
                                                   and Category__c not in: setCategory WITH USER_MODE order by Sequence__c])
                {
                    if(!setCourseIdValid.contains(cour.Course_ID__c))
                    {
                        setCourseIdValid.add(cour.Course_ID__c);
                        lstCourseOffering.add(cour);
                    }
                }
            }
            for(hed__Course_Offering__c objCourseOff : lstCourseOffering)
            {
                //objCourseOff.Number_of_Times_Course_Handled__c = 0;
                if(objCourseOff.Category__c != null){
                    wrapCourseOff.lstCourseOffCategory.add(objCourseOff.Category__c);
                    }
                if(objCourseOff.hed__Course__r.Course_Across_the_School__c != null){
                    wrapCourseOff.courseAcross = objCourseOff.hed__Course__r.Course_Across_the_School__c;
                    }
                if(objCourseOff.Category__c == 'Hardcore Course')
                {
                    if(mapProfstudent.ContainsKey(objCourseOff.id)) {
                        objCourseOff.Preference__c = mapProfstudent.get(objCourseOff.id).Preference__c;
                        objCourseOff.Number_of_Times_Course_Handled__c = mapProfstudent.get(objCourseOff.id).Number_of_Times_Course_Handled__c;
                    }
                    wrapCourseOff.listHardCore.add(objCourseOff);

                }
                if(objCourseOff.Category__c == 'Hardcore Integrated Course')
                {
                    if(mapProfstudent.ContainsKey(objCourseOff.id)) {
                        objCourseOff.Preference__c = mapProfstudent.get(objCourseOff.id).Preference__c;
                        objCourseOff.Number_of_Times_Course_Handled__c = mapProfstudent.get(objCourseOff.id).Number_of_Times_Course_Handled__c;
                    }
                    wrapCourseOff.listHcIntegrated.add(objCourseOff);

                }
                if(objCourseOff.Category__c == 'Practical/Term work')
                {
                    if(mapProfstudent.ContainsKey(objCourseOff.id)) {
                        objCourseOff.Preference__c = mapProfstudent.get(objCourseOff.id).Preference__c;
                        objCourseOff.Number_of_Times_Course_Handled__c = mapProfstudent.get(objCourseOff.id).Number_of_Times_Course_Handled__c;
                    }
                    wrapCourseOff.listPractical.add(objCourseOff);

                }
                if(objCourseOff.Category__c == 'Professional Elective' && objCourseOff.Parent_Course_Offering__c != null)
                {
                    if(mapProfstudent.ContainsKey(objCourseOff.id) ) {
                        objCourseOff.Preference__c = mapProfstudent.get(objCourseOff.id).Preference__c;
                        objCourseOff.Number_of_Times_Course_Handled__c = mapProfstudent.get(objCourseOff.id).Number_of_Times_Course_Handled__c;
                    }
                    wrapCourseOff.listProfElective.add(objCourseOff);

                }
                // if(objCourseOff.Category__c == 'Open Elective')
                // {
                //     if(mapProfstudent.get(objCourseOff.id) !=null)
                //         objCourseOff.Preference__c = mapProfstudent.get(objCourseOff.id).Preference__c;
                //     wrapCourseOff.listOpenElective.add(objCourseOff);
                // }
                if(objCourseOff.Category__c == 'Mandatory Course')
                {
                    if(mapProfstudent.ContainsKey(objCourseOff.id)) {
                    objCourseOff.Preference__c = mapProfstudent.get(objCourseOff.id).Preference__c;
                        objCourseOff.Number_of_Times_Course_Handled__c = mapProfstudent.get(objCourseOff.id).Number_of_Times_Course_Handled__c;
                    }
                    wrapCourseOff.listMandatory.add(objCourseOff);

                }
                wrapCourseOff.listMainCourse.add(objCourseOff);
            }
        }
        return wrapCourseOff;
    }


    /**
     * @description Retrieves and displays course offering records based on the provided term, school, and user preferences.
     * @param accTermId The ID of the academic term.
     * @param selCourseAcross Indicates if courses across schools should be considered.
     * @param loginAccountName The name of the logged-in user's account.
     * @param accSchoolId The ID of the school account.
     * @return A CourseOfferingWrapper object containing course offering details.
     */
    @AuraEnabled
    public static CourseOfferingWrapper displayCourseOffering(string accTermId,boolean selCourseAcross,string loginAccountName,string accSchoolId)
    {
        CourseOfferingWrapper wrapCourseOff = new CourseOfferingWrapper();
        set<string> setAccIds = new set<string>();
        set<string> setCourseIdValid=new  set<string>();
        if(accSchoolId != null)
        {
            for(Account objAcc : [select Id,Name,RecordType.Name,Parentid,Sequence__c,Parent.Name from Account Where
                                  RecordType.Name = :Utility.Acc_RecType_Academic_Program and Parentid =:accSchoolId WITH USER_MODE order by Sequence__c])
            {
                if(objAcc.Parent.Name == loginAccountName)  {
                    setAccIds.add(objAcc.Parent.Name);
                }
            }
        }
        if(setAccIds.size() >0)
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,Max_Professors_Per_Course__c,
                                                        Min_Professors_Per_Course__c,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,Offered_By_School__c,Offered_By_School__r.Name,
                                                        hed__Course__r.Course_Across_the_School__c,Course_ID__c ,hed__Course__r.HardCore_Sub_Type__c,Active__c,Number_of_Times_Course_Handled__c
                                                        from hed__Course_Offering__c where hed__Term__c =:accTermId
                                                        and hed__Term__r.Allow_Professors_for_Preferences__c = true AND Active__c = true AND Credits__c >= 1.0 WITH USER_MODE order by Sequence__c])
            {
                if(!setCourseIdValid.contains(objCourseOff.Course_ID__c))
                {
                    setCourseIdValid.add(objCourseOff.Course_ID__c);
                    //objCourseOff.Number_of_Times_Course_Handled__c = 0; 
                    wrapCourseOff.listMainCourse.add(objCourseOff);
                    if(objCourseOff.Category__c != null)
                    {
                        wrapCourseOff.lstCourseOffCategory.add(objCourseOff.Category__c);
                    }
                    //wrapCourseOff.courseOffCategory = objCourseOff.Category__c;
                    wrapCourseOff.courseAcross = objCourseOff.hed__Course__r.Course_Across_the_School__c;
                    if(objCourseOff.Category__c == 'Hardcore Course')  {
                    wrapCourseOff.listHardCore.add(objCourseOff);
                    }
                    if(objCourseOff.Category__c == 'Hardcore Integrated Course') {
                    wrapCourseOff.listHcIntegrated.add(objCourseOff);
                    }
                    if(objCourseOff.Category__c == 'Practical/Term work')  {
                    wrapCourseOff.listPractical.add(objCourseOff);
                    }

                    if(objCourseOff.Category__c == 'Professional Elective' && objCourseOff.Parent_Course_Offering__c != null)  {
                    wrapCourseOff.listProfElective.add(objCourseOff);
                    }
                   // if(objCourseOff.Category__c == 'Open Elective') wrapCourseOff.listOpenElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Mandatory Course') {
                         wrapCourseOff.listMandatory.add(objCourseOff);
                    }
                }
            }
        }
        else if(selCourseAcross == true)
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,Max_Professors_Per_Course__c,
                                                        Min_Professors_Per_Course__c,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,Offered_By_School__c,Offered_By_School__r.Name,
                                                        hed__Course__r.Course_Across_the_School__c,Course_ID__c ,hed__Course__r.HardCore_Sub_Type__c,Active__c,Number_of_Times_Course_Handled__c
                                                        from hed__Course_Offering__c where hed__Term__c =:accTermId
                                                        and hed__Course__r.Course_Across_the_School__c =: true and hed__Term__r.Allow_Professors_for_Preferences__c = true AND Active__c = true AND Credits__c >= 1.0 WITH USER_MODE order by Sequence__c])
            {
                if(!setCourseIdValid.contains(objCourseOff.Course_ID__c))
                {
                    setCourseIdValid.add(objCourseOff.Course_ID__c);
                    //objCourseOff.Number_of_Times_Course_Handled__c = 0;
                    wrapCourseOff.listMainCourse.add(objCourseOff);
                    if(objCourseOff.Category__c != null){
                        wrapCourseOff.lstCourseOffCategory.add(objCourseOff.Category__c);
                    }

                    //wrapCourseOff.courseOffCategory = objCourseOff.Category__c;
                    wrapCourseOff.courseAcross = objCourseOff.hed__Course__r.Course_Across_the_School__c;
                    if(objCourseOff.Category__c == 'Hardcore Course')  {
                    wrapCourseOff.listHardCore.add(objCourseOff);
                    }
                    if(objCourseOff.Category__c == 'Hardcore Integrated Course') {
                        wrapCourseOff.listHcIntegrated.add(objCourseOff);
                    }
                    if(objCourseOff.Category__c == 'Practical/Term work') {
                        wrapCourseOff.listPractical.add(objCourseOff);
                    }
                    if(objCourseOff.Category__c == 'Professional Elective' && objCourseOff.Parent_Course_Offering__c != null) {
                         wrapCourseOff.listProfElective.add(objCourseOff);
                    }
                    //if(objCourseOff.Category__c == 'Open Elective') wrapCourseOff.listOpenElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Mandatory Course') {
                         wrapCourseOff.listMandatory.add(objCourseOff);
                    }
                }
            }
        }
        else
        {
            for(hed__Course_Offering__c objCourseOff : [select Id,Name,Category__c,hed__Course__c,hed__Course__r.Name,hed__Capacity__c,Credits__c,hed__Facility__c,Parent_Course_Offering__c,Preference__c,Max_Professors_Per_Course__c,
                                                        Min_Professors_Per_Course__c,hed__Section_ID__c,Sequence__c,hed__Term__c,No_of_times_taught_in_last_3_years__c,Offered_By_School__c,Offered_By_School__r.Name,
                                                        hed__Course__r.Course_Across_the_School__c,Course_ID__c ,hed__Course__r.HardCore_Sub_Type__c,Active__c,Number_of_Times_Course_Handled__c
                                                        from hed__Course_Offering__c where hed__Term__c =:accTermId and hed__Term__r.Allow_Professors_for_Preferences__c = true AND Active__c = true AND Credits__c >= 1.0 WITH USER_MODE order by Sequence__c])
            {
                if(!setCourseIdValid.contains(objCourseOff.Course_ID__c))
                {
                    setCourseIdValid.add(objCourseOff.Course_ID__c);
                    //objCourseOff.Number_of_Times_Course_Handled__c = 0;
                    wrapCourseOff.listMainCourse.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Hardcore Course')
                    {
                         wrapCourseOff.listHardCore.add(objCourseOff);
                    }
                    if(objCourseOff.Category__c == 'Hardcore Integrated Course')
                    {
                        wrapCourseOff.listHcIntegrated.add(objCourseOff);
                    }
                    if(objCourseOff.Category__c == 'Practical/Term work')
                    {
                        wrapCourseOff.listPractical.add(objCourseOff);
                    }
                    if(objCourseOff.Category__c == 'Professional Elective' && objCourseOff.Parent_Course_Offering__c != null)
                    {
                        wrapCourseOff.listProfElective.add(objCourseOff);
                    }
                    //if(objCourseOff.Category__c == 'Open Elective') wrapCourseOff.listOpenElective.add(objCourseOff);
                    if(objCourseOff.Category__c == 'Mandatory Course')
                    {
                         wrapCourseOff.listMandatory.add(objCourseOff);
                    }
                }
            }
        }
        return wrapCourseOff;
    }


    /**
     * @description Validates the preferences for course offerings to ensure no duplicates and proper selection.
     * @param lstHardCourse List of hardcore course offerings.
     * @param lstHCIntegrated List of hardcore integrated course offerings.
     * @param lstPractical List of practical course offerings.
     * @param lstOpenElective List of open elective course offerings.
     * @param lstProfElective List of professional elective course offerings.
     * @param lstMandatory List of mandatory course offerings.
     * @param mainLst Main list of course offerings.
     * @return An ErrorWrapper object containing validation results and error messages.
     */
    @AuraEnabled
    public static ErrorWrapper validationPreferences(
        List<hed__Course_Offering__c> lstHardCourse,
        List<hed__Course_Offering__c> lstHCIntegrated,
        List<hed__Course_Offering__c> lstPractical,
        List<hed__Course_Offering__c> lstOpenElective,
        List<hed__Course_Offering__c> lstProfElective,
        List<hed__Course_Offering__c> lstMandatory,
        List<hed__Course_Offering__c> mainLst
    ) {
        ErrorWrapper wrapErr = new ErrorWrapper();
        Boolean hasAnyPreference = false;
        Set<String> theoryPrefs = new Set<String>();
        Set<String> practicalPrefs = new Set<String>();

        for (hed__Course_Offering__c obj : lstHardCourse) {
            if (String.isBlank(obj.Parent_Course_Offering__c) && String.isNotBlank(obj.Preference__c)) {
                hasAnyPreference = true;
                if (theoryPrefs.contains(obj.Preference__c)) {
                    wrapErr.mainErrmsg = 'This Preference - ' + obj.Preference__c + ' has already been chosen for one of the Theory Courses';
                    wrapErr.showsave = true;
                    return wrapErr;
                }
                theoryPrefs.add(obj.Preference__c);
                wrapErr.lstPreference.add(obj.Preference__c);
                wrapErr.lstCourseName.add('Hardcore Course');
            }
        }

        for (hed__Course_Offering__c obj : lstHCIntegrated) {
            if (String.isBlank(obj.Parent_Course_Offering__c) && String.isNotBlank(obj.Preference__c)) {
                hasAnyPreference = true;
                if (theoryPrefs.contains(obj.Preference__c)) {
                    wrapErr.mainErrmsg = 'This Preference - ' + obj.Preference__c + ' has already been chosen for one of the Theory Courses';
                    wrapErr.showsave = true;
                    return wrapErr;
                }
                theoryPrefs.add(obj.Preference__c);
                wrapErr.lstPreference.add(obj.Preference__c);
                wrapErr.lstCourseName.add('Hardcore Integrated Courses');
            }
        }

        for (hed__Course_Offering__c obj : lstPractical) {
            if (String.isBlank(obj.Parent_Course_Offering__c) && String.isNotBlank(obj.Preference__c)) {
                hasAnyPreference = true;
                if (practicalPrefs.contains(obj.Preference__c)) {
                    wrapErr.mainErrmsg = 'This Preference - ' + obj.Preference__c + ' has already been chosen for one of the Practical Courses';
                    wrapErr.showsave = true;
                    return wrapErr;
                }
                practicalPrefs.add(obj.Preference__c);
                wrapErr.lstPracticalPreference.add(obj.Preference__c);
                wrapErr.lstCourseName.add('Practical / Term Work');
            }
        }

        // for (hed__Course_Offering__c obj : lstOpenElective) {
        //     if (String.isNotBlank(obj.Parent_Course_Offering__c) && String.isNotBlank(obj.Preference__c)) {
        //         hasAnyPreference = true;
        //         if (theoryPrefs.contains(obj.Preference__c)) {
        //             wrapErr.mainErrmsg = 'This Preference - ' + obj.Preference__c + ' has already been chosen for one of the Theory Courses';
        //             wrapErr.showsave = true;
        //             return wrapErr;
        //         }
        //         theoryPrefs.add(obj.Preference__c);
        //         wrapErr.lstPreference.add(obj.Preference__c);
        //         wrapErr.lstCourseName.add('Open Electives');
        //     }
        // }

        for (hed__Course_Offering__c obj : lstProfElective) {
            if (String.isNotBlank(obj.Parent_Course_Offering__c) && String.isNotBlank(obj.Preference__c)) {
                hasAnyPreference = true;
                if (theoryPrefs.contains(obj.Preference__c)) {
                    wrapErr.mainErrmsg = 'This Preference - ' + obj.Preference__c + ' has already been chosen for one of the Theory Courses';
                    wrapErr.showsave = true;
                    return wrapErr;
                }
                theoryPrefs.add(obj.Preference__c);
                wrapErr.lstPreference.add(obj.Preference__c);
                wrapErr.lstCourseName.add('Professional Electives');
            }
        }
        List<String> mandGivenPrefs = new List<String>();

        for (hed__Course_Offering__c obj : lstMandatory) {
            if (String.isBlank(obj.Parent_Course_Offering__c) && String.isNotBlank(obj.Preference__c)) {
                mandGivenPrefs.add(obj.Preference__c.trim());
                hasAnyPreference = true;
                if (theoryPrefs.contains(obj.Preference__c)) {
                    wrapErr.mainErrmsg = 'This Preference - ' + obj.Preference__c + ' has already been chosen for one of the Theory Courses';
                    wrapErr.showsave = true;
                    return wrapErr;
                }
                theoryPrefs.add(obj.Preference__c);
                wrapErr.lstPreference.add(obj.Preference__c);
                wrapErr.lstCourseName.add('Mandatory Courses');
            }
        }



        if (mandGivenPrefs.size() > 1) {
            Set<String> limitedPrefs = new Set<String>{ '1', '2', '3' };
            for (String p : mandGivenPrefs) {
                if (limitedPrefs.contains(p)) {
                    wrapErr.mainErrmsg ='Only one Mandatory course can have a preference of 1, 2, or 3. '
    + 'Currently, a course already has preference \'' + p + '\'. '
    + 'Please remove remaining Mandatory course preferences to save.';
                    wrapErr.showsave = true;
                    return wrapErr;
                }
            }
        }

        // if (!hasAnyPreference) {
        //     wrapErr.hardDupErrmsg = 'Please select at least one Preference for Practical or Theory Course';
        //     wrapErr.showsave = true;
        //     return wrapErr;
        // }

        return wrapErr;
    }


    @AuraEnabled
    /**
     * @description Creates or updates professor course records based on preferences.
     * @param lstHc List of hardcore course offerings.
     * @param lstHcIntegrated List of hardcore integrated course offerings.
     * @param lstPract List of practical course offerings.
     * @param lstOpenEle List of open elective course offerings.
     * @param lstProfel List of professional elective course offerings.
     * @param lstMandtry List of mandatory course offerings.
     * @param profPreference Indicates if professor preferences are enabled.
     * @param accTermId The ID of the academic term.
     * @return A string indicating the result of the operation (e.g., "SUCCESS" or an error message).
     */
    public static String createProfessorCourseRecords(
    List<hed__Course_Offering__c> lstHc,
    List<hed__Course_Offering__c> lstHcIntegrated,
    List<hed__Course_Offering__c> lstPract,
    List<hed__Course_Offering__c> lstOpenEle,
    List<hed__Course_Offering__c> lstProfel,
    List<hed__Course_Offering__c> lstMandtry,
    Boolean profPreference,
    String accTermId
) {
    // 1) Resolve current professor (Contact)
    User currentUser = [
        SELECT Id, Email, ContactId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH USER_MODE
    ];
    Contact con = [
        SELECT Id
        FROM Contact
        WHERE Email = :currentUser.Email
          AND Account.RecordType.Name = :Utility.Acc_RecType_University_Department
        WITH USER_MODE
        LIMIT 1
    ];

    // 2) Collect all incoming offerings and filter to those with Preference set
    List<hed__Course_Offering__c> allCourses = new List<hed__Course_Offering__c>();
    allCourses.addAll(lstHc);
    allCourses.addAll(lstHcIntegrated);
    allCourses.addAll(lstPract);
    allCourses.addAll(lstOpenEle);
    allCourses.addAll(lstProfel);
    allCourses.addAll(lstMandtry);

    List<hed__Course_Offering__c> preferencedCourses = new List<hed__Course_Offering__c>();
    Set<String> courseIds = new Set<String>();
    for (hed__Course_Offering__c c : allCourses) {
        if (String.isNotBlank(c.Preference__c) && c.Course_ID__c != null) {
            preferencedCourses.add(c);
            courseIds.add(c.Course_ID__c);
        }
    }

    // 3) Map available offerings by (Course_ID__c + School) within the same term
    Map<String, List<hed__Course_Offering__c>> courseMap = new Map<String, List<hed__Course_Offering__c>>();
    for (hed__Course_Offering__c co : [
        SELECT Id, Remaining_Professor_Preference_1_Slots__c,Number_of_Times_Course_Handled__c,
               Preference__c, hed__Term__c, Course_ID__c, Offered_By_School__c, Name
        FROM hed__Course_Offering__c
        WHERE Course_ID__c IN :courseIds
          AND hed__Term__c = :accTermId
        WITH USER_MODE
    ]) {
        String baseKey = co.Course_ID__c + '-' + co.Offered_By_School__c;
        if (!courseMap.containsKey(baseKey)) {
            courseMap.put(baseKey, new List<hed__Course_Offering__c>());
        }
        courseMap.get(baseKey).add(co);
    }

    // 4) Existing preferences (now keyed with Preference__c to keep Pref-1, Pref-2 distinct)
    Map<String, Professor_Student_Course_Preference__c> existingPrefs = new Map<String, Professor_Student_Course_Preference__c>();
    for (Professor_Student_Course_Preference__c p : [
        SELECT Id,
               Course_Offering__c,Number_of_Times_Course_Handled__c,
               Course_Offering__r.Course_ID__c,
               Course_Offering__r.Offered_By_School__c,
               Preference__c
        FROM Professor_Student_Course_Preference__c
        WHERE Professor__c = :con.Id
          AND Semester__c = :accTermId
        WITH USER_MODE
    ]) {
        String key = p.Course_Offering__r.Course_ID__c + '-' +
                     p.Course_Offering__r.Offered_By_School__c + '-' +
                     con.Id + '-' +
                     p.Preference__c;
        existingPrefs.put(key, p);
    }

    List<Professor_Student_Course_Preference__c> toUpsert = new List<Professor_Student_Course_Preference__c>();
    List<Professor_Student_Course_Preference__c> toDelete = new List<Professor_Student_Course_Preference__c>();
    Set<String> incomingKeys = new Set<String>();

    // 5) Build upserts
    for (hed__Course_Offering__c inCourse : preferencedCourses) {
        String baseKey = inCourse.Course_ID__c + '-' + inCourse.Offered_By_School__c;
        String key     = baseKey + '-' + con.Id + '-' + inCourse.Preference__c;
        incomingKeys.add(key);

        List<hed__Course_Offering__c> offers = courseMap.get(baseKey);
        if (offers == null || offers.isEmpty()) {
            continue; // No active offering in this term
        }

        hed__Course_Offering__c offer = offers[0];

        // Only block Pref-1 when assigning new and slots are exhausted
        Boolean isChangingToPref1 = (inCourse.Preference__c == '1') &&
                                    (!existingPrefs.containsKey(key) ||
                                     existingPrefs.get(key).Preference__c != '1');
        if (isChangingToPref1 && offer.Remaining_Professor_Preference_1_Slots__c == 0) {
            return 'No Slots Available';
        }

        Professor_Student_Course_Preference__c pref =
            existingPrefs.containsKey(key) ? existingPrefs.get(key)
            : new Professor_Student_Course_Preference__c();

        pref.Course_Offering__c        = offer.Id;
        pref.Preference__c             = inCourse.Preference__c;
        pref.Professor__c              = con.Id;
        pref.Name                      = inCourse.Name;
        pref.Semester__c               = accTermId;
        pref.Professor_Preference__c   = profPreference;
        pref.Number_of_Times_Course_Handled__c = (inCourse.Number_of_Times_Course_Handled__c == null) 
                                             ? 0 : inCourse.Number_of_Times_Course_Handled__c;

        toUpsert.add(pref);
    }

    // 6) Delete stale preferences
    for (String existingKey : existingPrefs.keySet()) {
        if (!incomingKeys.contains(existingKey)) {
            toDelete.add(existingPrefs.get(existingKey));
        }
    }

    // 7) DML with permission checks
    try {
        if (!toUpsert.isEmpty()) {
            if (Schema.sObjectType.Professor_Student_Course_Preference__c.isCreateable() &&
                Schema.sObjectType.Professor_Student_Course_Preference__c.isUpdateable()) {
                upsert toUpsert;
            } else {
                throw new SecurityException('Insufficient permissions to create or update Professor_Student_Course_Preference__c records.');
            }
        }
        if (!toDelete.isEmpty()) {
            if (Schema.sObjectType.Professor_Student_Course_Preference__c.isDeletable()) {
                delete toDelete;
            } else {
                throw new SecurityException('Insufficient permissions to delete Professor_Student_Course_Preference__c records.');
            }
        }
        return 'SUCCESS';
    } catch (DmlException dmle) {
        return 'ERROR: ' + dmle.getMessage();
    }
}




    @AuraEnabled
    /**
     * @description Retrieves the picklist values for the 'Preference__c' field in the 'hed__Course_Offering__c' object.
     * @return A map of picklist values where the key is the value and the value is the label.
     */
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
    /**
     * @description Wrapper class to organize and manage course offering details.
     */
    public class CourseOfferingWrapper
    {
        /**
         * @description List of hardcore course offerings.
         */
        @AuraEnabled public list<hed__Course_Offering__c> listHardCore {get;set;}

        /**
         * @description List of open elective course offerings.
         */
        @AuraEnabled public list<hed__Course_Offering__c> listOpenElective {get;set;}

        /**
         * @description List of professional elective course offerings.
         */
        @AuraEnabled public list<hed__Course_Offering__c> listProfElective {get;set;}

        /**
         * @description List of practical course offerings.
         */
        @AuraEnabled public list<hed__Course_Offering__c> listPractical {get;set;}

        /**
         * @description List of hardcore integrated course offerings.
         */
        @AuraEnabled public list<hed__Course_Offering__c> listHcIntegrated {get;set;}

        /**
         * @description List of mandatory course offerings.
         */
        @AuraEnabled public list<hed__Course_Offering__c> listMandatory {get;set;}

        /**
         * @description List of all main course offerings.
         */
        @AuraEnabled public list<hed__Course_Offering__c> listMainCourse {get;set;}

        /**
         * @description Indicates if professor preferences are enabled.
         */
        @AuraEnabled public Boolean professorPreference {get;set;}

        /**
         * @description List of course offering categories.
         */
        @AuraEnabled public list<string> lstCourseOffCategory{get;set;}

        /**
         * @description Indicates if the course is offered across schools.
         */
        @AuraEnabled public Boolean courseAcross{get;set;}

        /**
         * @description Constructor for the CourseOfferingWrapper class.
         * Initializes all lists and default values.
         */
        public CourseOfferingWrapper(){
            listHardCore = new list<hed__Course_Offering__c>();
            listOpenElective = new list<hed__Course_Offering__c>();
            listProfElective = new list<hed__Course_Offering__c>();
            listPractical = new list<hed__Course_Offering__c> ();
            listHcIntegrated = new list<hed__Course_Offering__c>();
            listMandatory = new list<hed__Course_Offering__c>();
            listMainCourse =new list<hed__Course_Offering__c>();
            courseAcross = false;
            lstCourseOffCategory = new list<string>();
        }
    }
    /**
     * @description Wrapper class to organize and manage school-related details.
     */
    public class SchoolWrapper
    {
        /**
         * @description Map of school account IDs to their names.
         */
        @AuraEnabled public Map<Id,String> mapAccSchool{get;set;}

        /**
         * @description Indicates if the professor is associated with multiple schools.
         */
        @AuraEnabled public boolean profSchool {get;set;}

        /**
         * @description Indicates if courses are offered across schools.
         */
        @AuraEnabled public Boolean courseAcross{get;set;}

        /**
         * @description The category of the course offering.
         */
        @AuraEnabled public string courseOffCategory{get;set;}

        /**
         * @description The name of the logged-in user's account.
         */
        @AuraEnabled public string loginUserAccountName{get;set;}

        /**
         * @description Constructor for the SchoolWrapper class.
         * Initializes the map of school accounts and default values.
         */
        public SchoolWrapper()
        {
            mapAccSchool = new Map<Id,String>();
            profSchool = false;
            courseAcross = false;
        }
    }
    /**
     * @description Wrapper class to handle and manage error details for course preferences.
     */
    public class ErrorWrapper
    {
        /**
         * @description Error message for duplicate hardcore preferences.
         */
        @AuraEnabled public string hardDupErrmsg {get;set;}

        /**
         * @description Main error message for validation issues.
         */
        @AuraEnabled public string mainErrmsg {get;set;}

        /**
         * @description Indicates whether the save button should be shown.
         */
        @AuraEnabled public boolean showsave {get;set;}

        /**
         * @description Error message for main preference validation.
         */
        @AuraEnabled public string mainPrefErrMsg {get;set;}

        /**
         * @description List of preferences for theory courses.
         */
        @AuraEnabled public list<String> lstPreference{get;set;}

        /**
         * @description List of preferences for practical courses.
         */
        @AuraEnabled public list<String> lstPracticalPreference{get;set;}

        /**
         * @description List of course names associated with preferences.
         */
        @AuraEnabled public list<String> lstCourseName{get;set;}

        /**
         * @description Constructor for the ErrorWrapper class.
         * Initializes lists and default values.
         */
        public ErrorWrapper()
        {
            lstPreference =  new list<String>();
            lstPracticalPreference =  new list<String>();
            lstCourseName = new list<String>();
        }
    }
}