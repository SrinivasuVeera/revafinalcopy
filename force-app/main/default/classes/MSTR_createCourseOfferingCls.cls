Public with sharing class MSTR_createCourseOfferingCls{

    @AuraEnabled
    public static termMainWarp getTermDetails(string termId)
    {
        termMainWarp termWrp = new termMainWarp();
        string accId = '';
        string parentAccId = '';
        list<hed__Term__c> lst_updateTerm = new list<hed__Term__c>();
        list<hed__Course_Offering__c> lst_Course = new list<hed__Course_Offering__c>();

        for(hed__Term__c objTerm : [SELECT id,Name,hed__Account__c,Program_Batch__r.hed__Account__r.ParentId,Course_Offering_Update__c,
                                    Program_Batch__r.hed__Account__r.Parent.ParentId,hed__Start_Date__c,
                                    hed__End_Date__c,Course_Offering_Created__c,Sent_for_Approval__c FROM hed__Term__c WHERE id =: termId])
        {
            hed__Term__c NewTerm = new hed__Term__c();
            termWrp.objTerm = objTerm;
            accId = objTerm.Program_Batch__r.hed__Account__r.ParentId;
            parentAccId = objTerm.Program_Batch__r.hed__Account__r.Parent.ParentId;
            NewTerm.Id =objTerm.id;
            NewTerm.Course_Offering_Update__c =false;
            lst_updateTerm.add(NewTerm);
        }
        for(hed__Course_Offering__c objCourse : [SELECT id,Name,Course_Offering_Updated__c,hed__Term__c FROM hed__Course_Offering__c
                                                 WHERE  hed__Term__c =: termId])
        {
            hed__Course_Offering__c objNewCourse = new hed__Course_Offering__c();
            objNewCourse.id = objCourse.id;
            objNewCourse.Course_Offering_Updated__c = false;
            lst_Course.add(objNewCourse);
        }
        for(hed__Course__c course : [SELECT id,Name,Category__c,hed__Course_ID__c,Credit_Hours__c FROM hed__Course__c WHERE hed__Account__c =: accId  AND
                                     Category__c !=: Null])
        {

            if(course.Category__c == 'Hardcore Course'){
                termWrp.hcCoursePl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
            }
            if(course.Category__c == 'Hardcore Integrated Course'){
                termWrp.hcIntegratedPl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
            }
            if(course.Category__c == 'Practical/Term Work'){
                termWrp.pratialPl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
            }
            if(course.Category__c == 'Open Elective'){
                termWrp.oElectivePl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
            }
            if(course.Category__c == 'Professional Elective'){
                termWrp.pElectivePl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
            }
           if(course.Category__c == 'RBS Specialization'){
                termWrp.rbsSpclPl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
            }
            if(course.Category__c == 'Mandatory Course'){
                termWrp.MandatoryPl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
            }
        }
        set<string> parentIds = new set<string>();
        for(account acc : [SELECT id,parentId FROM Account WHERE parentId =: accId WITH USER_MODE]){ // rbs
            parentIds.add(acc.id);
        }
        for(hed__Course__c course : [SELECT id,Name,Category__c,hed__Course_ID__c,Credit_Hours__c FROM hed__Course__c WHERE hed__Account__c =: parentIds AND
                                     (Category__c =: 'Open Elective' OR Category__c =: 'Professional Elective')]){
                                         if(course.Category__c == 'Open Elective'){
                                             termWrp.oElectivePl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
                                         }
                                         if(course.Category__c == 'Professional Elective'){
                                             termWrp.pElectivePl.put(course.id,course.Name+'-'+course.hed__Course_ID__c);
                                         }
                                     }

        string accIds = termWrp.objTerm.Program_Batch__r.hed__Account__r.ParentId+',';
        for(account acc : [SELECT id FROM Account WHERE parentId =: termWrp.objTerm.Program_Batch__r.hed__Account__r.Parent.ParentId]){
            accIds += acc.id + ',';
        }
        accIds = accIds.trim();
        if(accIds.endsWith(','))
        {
            accIds = accIds.subString(0, accIds.lastIndexOf(','));
        }
        if(lst_updateTerm.size()>0) update lst_updateTerm;
        if(lst_Course.size()>0) update lst_Course;
        termWrp.filterIds = accIds;
        return termWrp;
    }
    @AuraEnabled
    public static courseMainWarp getPlanRequirement(string termId)
    {
        courseMainWarp objWarp = new courseMainWarp();
        objWarp.totalCredit = 0;
        set<string> prIds = new set<string>();

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        for(hed__Term__c objTerm : [SELECT id,Name,hed__Account__c,Program_Batch__r.hed__Account__r.ParentId,
                                    hed__Start_Date__c,hed__End_Date__c,Course_Offering_Created__c,
                                    (SELECT id,hed__Category__c,hed__Course__c,hed__Course__r.Name,hed__Course__r.Offered_By_School__c,Credit_Hours__c,
                                     hed__Course__r.Offered_By_School__r.Name,Credits__c,Sequence__c,hed__Plan_Requirement__c,Semester__c,Specialization__c,Specialization__r.Name
                                     FROM Plan_Requirements__r
                                     WHERE hed__Category__c != Null) FROM hed__Term__c WHERE id =: termId])
        {

            for(hed__Plan_Requirement__c objPr : objterm.Plan_Requirements__r){
                if(objPr.hed__Category__c == 'Hardcore Course'){
                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.Semester__c;
                    //  objHc.recordId = '';
                    objHc.filter = 'Category__c = \'Hardcore Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objHc.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHc.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHc.count = string.valueof(objPr.Sequence__c);
                    }
                    objWarp.listHardCore.add(objHc);
                    objWarp.totalCredit = objWarp.totalCredit + objPr.Credits__c;
                }
                if(objPr.hed__Category__c == 'Practical/Term Work'){
                    planLiwrap objPra = new planLiwrap();
                    objPra.courseId = objPr.hed__Course__c;
                    objPra.courseName = objPr.hed__Course__r.Name;
                    objPra.credits = objPr.Credits__c;
                    objPra.termId = objPr.Semester__c;
                    //  objPra.recordId = '';
                    objPra.filter = 'Category__c = \'Practical/Term Work\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objPra.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objPra.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objPra.count = string.valueof(objPr.Sequence__c);
                    }
                    objWarp.listPractical.add(objPra);
                    objWarp.totalCredit = objWarp.totalCredit + objPr.Credits__c;
                }
                if(objPr.hed__Category__c == 'Hardcore Integrated Course'){
                    planLiwrap objHci = new planLiwrap();
                    objHci.courseId = objPr.hed__Course__c;
                    objHci.courseName = objPr.hed__Course__r.Name;
                    objHci.credits = objPr.Credits__c;
                    objHci.termId = objPr.Semester__c;
                    //  objHci.recordId = '';
                    objHci.filter = 'Category__c = \'Hardcore Integrated Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objHci.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHci.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHci.count = string.valueof(objPr.Sequence__c);
                    }
                    objWarp.listHcIntegrated.add(objHci);
                    objWarp.totalCredit = objWarp.totalCredit + objPr.Credits__c;
                }
                if(objPr.hed__Category__c == 'Mandatory Course'){
                    planLiwrap objMan = new planLiwrap();
                    objMan.courseId = objPr.hed__Course__c;
                    objMan.courseName = objPr.hed__Course__r.Name;
                    objMan.credits = objPr.Credits__c;
                    objMan.termId = objPr.Semester__c;
                    objMan.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objMan.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    //  objMan.recordId = '';
                    objMan.filter = 'Category__c = \'Mandatory Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    if(objPr.Sequence__c != Null){
                        objMan.count = string.valueof(objPr.Sequence__c);
                    }
                    objWarp.listMandatory.add(objMan);
                    objWarp.totalCredit = objWarp.totalCredit + objPr.Credits__c;
                }

                if(objPr.hed__Plan_Requirement__c != Null){
                    prIds.add(objPr.hed__Plan_Requirement__c);
                }
            }
        }

        for(hed__Plan_Requirement__c pr : [SELECT id,Name,hed__Category__c,Credits__c,Semester__c,Semester__r.Program_Batch__r.hed__Account__r.ParentId,Credit_Hours__c,
                                           Sequence__c,(SELECT id,hed__Category__c,hed__Course__c,hed__Course__r.Name,hed__Course__r.Offered_By_School__c,hed__Course__r.Offered_By_School__r.Name,
                                                        Credits__c,Sequence__c,hed__Plan_Requirement__c,Semester__c,Credit_Hours__c FROM hed__Plan_Requirements__r)
                                           FROM hed__Plan_Requirement__c WHERE id =: prIds])
        {
            if(pr.hed__Category__c == 'Open Elective'){
                openElectivewrap oew = new openElectivewrap();
                oew.parentId = pr.id;
                oew.Name = pr.Name;
                oew.credits = pr.Credits__c;
                oew.termId = pr.Semester__c;
                // oew.recordId = '';
                if(pr.Sequence__c != Null){
                    oew.count = string.valueof(pr.Sequence__c);
                }
                for(hed__Plan_Requirement__c objPr : pr.hed__Plan_Requirements__r){

                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.Semester__c;
                    // objHc.recordId = '';
                    objHc.filter = 'Category__c = \'Open Elective\' AND hed__Account__c = \''+pr.Semester__r.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objHc.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHc.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHc.count = string.valueof(objPr.Sequence__c);
                    }
                    oew.lstPlanLi.add(objHc);
                }
                objWarp.listOpenElective.add(oew);
                objWarp.totalCredit = objWarp.totalCredit + Pr.Credits__c;
            }

            if(pr.hed__Category__c == 'Professional Elective'){
                profElectivewrap pew = new profElectivewrap();
                pew.parentId = pr.id;
                pew.Name = pr.Name;
                pew.credits = pr.Credits__c;
                pew.termId = pr.Semester__c;
                //  pew.recordId = '';
                if(pr.Sequence__c != Null){
                    pew.count = string.valueof(pr.Sequence__c);
                }
                for(hed__Plan_Requirement__c objPr : pr.hed__Plan_Requirements__r){

                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.Semester__c;
                    //   objHc.recordId = '';
                    objHc.filter = 'Category__c = \'Professional Elective\' AND hed__Account__c = \''+pr.Semester__r.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objHc.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHc.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHc.count = string.valueof(objPr.Sequence__c);
                    }
                    pew.lstPlanLi.add(objHc);
                }
                objWarp.listProfElective.add(pew);
                objWarp.totalCredit = objWarp.totalCredit + Pr.Credits__c;
            }

        }

         List<Account> spclLi = [ SELECT Id, Name ,(SELECT id,Name,hed__Category__c,Credits__c,Semester__c,Semester__r.Program_Batch__r.hed__Account__r.ParentId,Semester__r.Program_Batch__r.hed__Account__r.Parent.ParentId,
                                Sequence__c,Credit_Hours__c,Specialization__c,Specialization__r.Name,hed__Course__c,hed__Course__r.Name,hed__Course__r.hed__Account__r.Name,hed__Course__r.hed__Account__c
                                FROM Specialization__r WHERE Semester__c  =: termId) FROM Account  WHERE RecordType.DeveloperName = 'RBS_Specialization' WITH USER_MODE];

         for (Account acc : spclLi) {
            RbsSpclWrap rbs = new RbsSpclWrap();
            rbs.parentId = acc.Id;
            rbs.name = acc.Name;

            Boolean hasSpecializations = acc.Specialization__r != null && !acc.Specialization__r.isEmpty();

            if (hasSpecializations) {
                for (hed__Plan_Requirement__c objPr : acc.Specialization__r) {
                    planLiwrap objMan = new planLiwrap();  // FIX: fresh object each time

                    if (objPr.hed__Category__c == 'RBS Specialization') {
                        objMan.courseId = objPr.hed__Course__c;
                        objMan.courseName = objPr.hed__Course__r.Name;
                        objMan.credits = objPr.Credits__c;
                        objMan.termId = objPr.Semester__c;
                        //objMan.recordId = objPr.Id;
                        objMan.filter = 'Category__c = \'RBS Specialization\' AND Specialization__c = \'' + acc.Id + '\'';
                        objMan.SchoolId = objPr.hed__Course__r.hed__Account__c;
                        objMan.schoolName = objPr.hed__Course__r.hed__Account__r.Name;

                        if (objPr.Sequence__c != null) {
                            objMan.count = String.valueOf(objPr.Sequence__c);
                        }

                        rbs.lstPlanLi.add(objMan);
                        //objWarp.totalCredit += objPr.Credits__c;
                        objWarp.totalCredit = objWarp.totalCredit + objPr.Credits__c;
                    } else {
                        objMan.courseId = '';
                        objMan.courseName = '';
                        objMan.credits = 0;
                        objMan.termId = objPr.Semester__c;
                        objMan.filter = 'Category__c = \'RBS Specialization\' AND Specialization__c = \'' + acc.Id + '\'';
                        rbs.lstPlanLi.add(objMan);
                        objWarp.totalCredit = objWarp.totalCredit + objPr.Credits__c;
                    }
                }
            } else {
                // No Specializations — add empty one with filter and termId only
                planLiwrap objMan = new planLiwrap();  // Still need new instance
                objMan.courseId = '';
                objMan.courseName = '';
                objMan.credits = 0;
                objMan.termId = termId;
                objMan.filter = 'Category__c = \'RBS Specialization\' AND Specialization__c = \'' + acc.Id + '\'';

                rbs.lstPlanLi.add(objMan);
                //objWarp.totalCredit = objWarp.totalCredit + objPr.Credits__c;
            }

            objWarp.lstSpcl.add(rbs);
        }
        return objWarp;
    }

    @AuraEnabled
    public static courseMainWarp getcourseOffering(string termId)
    {
        courseMainWarp objWarp = new courseMainWarp();
        set<string> prIds = new set<string>();

        for(hed__Term__c objTerm : [SELECT id,Name,Program_Batch__r.hed__Account__r.ParentId,Program_Batch__r.hed__Account__r.Parent.ParentId,(SELECT id,Category__c,hed__Course__c,Credits__c,Credit_Hours__c,
                                                                                                                                               Sequence__c,hed__Course__r.Name,hed__Term__c,Parent_Course_Offering__c,hed__Course__r.Offered_By_School__c,hed__Course__r.Offered_By_School__r.Name,
                                                                                                                                               Specialization__c,Specialization__r.Name
                                                                                                                                               FROM hed__Course_Offerings__r) FROM hed__Term__c WHERE id =: termId])
        {

            for(hed__Course_Offering__c objPr : objterm.hed__Course_Offerings__r){

                if(objPr.Category__c == 'Hardcore Course'){
                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.hed__Term__c;
                    objHc.recordId = objPr.id;
                    objHc.filter = 'Category__c = \'Hardcore Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objHc.accfilter='hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.Parent.ParentId + '\'';
                    objHc.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHc.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHc.count = string.valueof(objPr.Sequence__c);
                    }
                    objWarp.listHardCore.add(objHc);
                }
                if(objPr.Category__c == 'Practical/Term Work'){
                    planLiwrap objPra = new planLiwrap();
                    objPra.courseId = objPr.hed__Course__c;
                    objPra.courseName = objPr.hed__Course__r.Name;
                    objPra.credits = objPr.Credits__c;
                    objPra.termId = objPr.hed__Term__c;
                    objPra.recordId = objPr.id;
                    objPra.filter = 'Category__c = \'Practical/Term Work\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objPra.accfilter='hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.Parent.ParentId + '\'';
                    objPra.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objPra.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objPra.count = string.valueof(objPr.Sequence__c);
                    }
                    objWarp.listPractical.add(objPra);
                }
                if(objPr.Category__c == 'Hardcore Integrated Course'){
                    planLiwrap objHci = new planLiwrap();
                    objHci.courseId = objPr.hed__Course__c;
                    objHci.courseName = objPr.hed__Course__r.Name;
                    objHci.credits = objPr.Credits__c;
                    objHci.termId = objPr.hed__Term__c;
                    objHci.recordId = objPr.id;
                    objHci.filter = 'Category__c = \'Hardcore Integrated Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objHci.accfilter='hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.Parent.ParentId + '\'';
                    objHci.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHci.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHci.count = string.valueof(objPr.Sequence__c);
                    }
                    objWarp.listHcIntegrated.add(objHci);
                }
                if(objPr.Category__c == 'Mandatory Course'){
                    planLiwrap objMan = new planLiwrap();
                    objMan.courseId = objPr.hed__Course__c;
                    objMan.courseName = objPr.hed__Course__r.Name;
                    objMan.credits = objPr.Credits__c;
                    objMan.termId = objPr.hed__Term__c;
                    objMan.recordId = objPr.id;
                    objMan.filter = 'Category__c = \'Mandatory Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objMan.accfilter='hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.Parent.ParentId + '\'';
                    objMan.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objMan.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objMan.count = string.valueof(objPr.Sequence__c);
                    }
                    objWarp.listMandatory.add(objMan);
                }

                if(objPr.Parent_Course_Offering__c != Null){
                    prIds.add(objPr.Parent_Course_Offering__c);
                }

            }

        }

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        for(hed__Course_Offering__c pr : [SELECT id,Name,Category__c,hed__Course__c,Credits__c,
                                          Sequence__c,hed__Course__r.Name,hed__Term__c,Parent_Course_Offering__c,Trigger_Approval__c,Credit_Hours__c,
                                          (SELECT id,Name,Category__c,hed__Course__c,Credits__c,hed__Course__r.Offered_By_School__c,hed__Course__r.Offered_By_School__r.Name,
                                           Sequence__c,hed__Course__r.Name,hed__Term__c,Parent_Course_Offering__c
                                           FROM Course_Offerings__r WHERE hed__Term__c =: termId) FROM hed__Course_Offering__c WHERE hed__Term__c =: termId AND hed__Term__r.recordTypeId =: termRtId AND
                                          Parent_Course_Offering__c =: Null AND (Category__c =: 'Open Elective' OR Category__c =: 'Professional Elective')])
        {
            if(pr.Category__c == 'Open Elective'){
                openElectivewrap oew = new openElectivewrap();
                oew.parentId = pr.id;
                oew.Name = pr.Name;
                oew.credits = pr.Credits__c;
                oew.termId = pr.hed__Term__c;
                oew.recordId = pr.id;
                if(pr.Sequence__c != Null){
                    oew.count = string.valueof(pr.Sequence__c);
                }
                for(hed__Course_Offering__c objPr : pr.Course_Offerings__r){

                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.hed__Term__c;
                    objHc.recordId = objPr.id;
                    objHc.filter = 'Category__c = \'Open Elective\' AND hed__Account__c IN: ';
                    objHc.accfilter='hed__Account__c IN: ';
                    objHc.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHc.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHc.count = string.valueof(objPr.Sequence__c);
                    }
                    oew.lstPlanLi.add(objHc);
                }
                objWarp.listOpenElective.add(oew);
            }

            if(pr.Category__c == 'Professional Elective'){
                profElectivewrap pew = new profElectivewrap();
                pew.parentId = pr.id;
                pew.Name = pr.Name;
                pew.credits = pr.Credits__c;
                pew.termId = pr.hed__Term__c;
                pew.recordId = pr.id;
                if(pr.Sequence__c != Null){
                    pew.count = string.valueof(pr.Sequence__c);
                }
                for(hed__Course_Offering__c objPr : pr.Course_Offerings__r){

                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.hed__Term__c;
                    objHc.recordId = objPr.id;
                    objHc.filter = 'Category__c = \'Professional Elective\' AND hed__Account__c IN: ';
                    objHc.accfilter='hed__Account__c IN: ';
                    objHc.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHc.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHc.count = string.valueof(objPr.Sequence__c);
                    }
                    pew.lstPlanLi.add(objHc);
                }
                objWarp.listProfElective.add(pew);
            }

        }
         List<Account> spclLi = [ SELECT Id, Name ,(SELECT id,Name,Category__c,hed__Course__c,Credits__c,hed__Course__r.Offered_By_School__c,hed__Course__r.Offered_By_School__r.Name,
                            Sequence__c,hed__Course__r.Name,hed__Term__c,Parent_Course_Offering__c ,hed__Term__r.recordTypeId
                            FROM Specializations__r WHERE hed__Term__c =: termId AND hed__Term__r.recordTypeId =: termRtId) FROM Account  WHERE RecordType.DeveloperName = 'RBS_Specialization' WITH USER_MODE];

         for (Account acc : spclLi) {
            RbsSpclWrap rbs = new RbsSpclWrap();
            rbs.parentId = acc.Id;
            rbs.name = acc.Name;


            Boolean hasSpecializations = acc.Specializations__r != null && !acc.Specializations__r.isEmpty();

            if (hasSpecializations) {
                for (hed__Course_Offering__c objPr : acc.Specializations__r) {
                    planLiwrap objMan = new planLiwrap();  // FIX: fresh object each time

                    if (objPr.Category__c == 'RBS Specialization') {
                        objMan.courseId = objPr.hed__Course__c;
                        objMan.courseName = objPr.hed__Course__r.Name;
                        objMan.credits = objPr.Credits__c;
                        objMan.termId = objPr.hed__Term__c;
                        objMan.recordId = objPr.Id;
                        objMan.filter = 'Category__c = \'RBS Specialization\' AND Specialization__c = \'' + acc.Id + '\'';
                        objMan.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                        objMan.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;

                        if (objPr.Sequence__c != null) {
                            objMan.count = String.valueOf(objPr.Sequence__c);
                        }

                        rbs.lstPlanLi.add(objMan);
                    } else {
                        objMan.courseId = '';
                        objMan.courseName = '';
                        objMan.credits = 0;
                        objMan.termId = objPr.hed__Term__c;
                        objMan.filter = 'Category__c = \'RBS Specialization\' AND Specialization__c = \'' + acc.Id + '\'';
                        rbs.lstPlanLi.add(objMan);
                    }
                }
            } else {
                // No Specializations — add empty one with filter and termId only
                planLiwrap objMan = new planLiwrap();  // Still need new instance
                objMan.courseId = '';
                objMan.courseName = '';
                objMan.credits = 0;
                objMan.termId = termId;
                objMan.filter = 'Category__c = \'RBS Specialization\' AND Specialization__c = \'' + acc.Id + '\'';

                rbs.lstPlanLi.add(objMan);
            }


            objWarp.lstSpcl.add(rbs);
        }

        return objWarp;
    }

    @AuraEnabled
    public static string savePlanRequiement(string termId,
                                            list<planLiwrap> lstHc,
                                            list<planLiwrap> lstHcIntegrated,
                                            list<planLiwrap> lstPra,
                                            list<openElectivewrap> lstOe,
                                            list<profElectivewrap> lstPe,
                                            list<planLiwrap> lstMandatory,
                                            list<RbsSpclWrap> lstSpcl ,
                                            list<string> deletedIds,
                                            boolean type,
                                            Boolean Approval)
    {
        string ErrMsg = 'Success';
        try{

            map<string,string> courseIds = new map<string,string>();
            string schoolhead;
            string VericalHead;
            set<id> set_courseid = new set<id>();
            map<Id,hed__Course__c> map_Course = new map<Id,hed__Course__c>();

            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

            hed__Term__c currTerm = [SELECT id,Name,Program_Batch__c,hed__Account__c,hed__Account__r.ParentId,hed__Account__r.Parent.School_Head__c,hed__Account__r.Parent.Vertical_Head__c,
                                     Course_Offering_Update__c,hed__Account__r.School_Head__c,hed__Account__r.Vertical_Head__c,Course_Offering_Created__c FROM hed__Term__c WHERE id =: termId];
            schoolhead = currTerm.hed__Account__r.Parent.School_Head__c;
            VericalHead = currTerm.hed__Account__r.Parent.Vertical_Head__c;

            Set<String> spclCoSemKey = new Set<String>();
            map<string,hed__Term__c> mapTerm = new map<string,hed__Term__c>();
            mapTerm.put(termId,new hed__Term__c(id=termId,Total_Course_Offering_credits__c=0));

            if(!currTerm.Course_Offering_Created__c){
                for(hed__Term__c objterm : [SELECT id,Name,Course_Offering_Update__c,(SELECT id,Name,hed__Category__c,hed__Plan_Requirement__c,hed__Course__c,Specialization__c FROM Plan_Requirements__r
                                                            WHERE hed__Category__c != Null) FROM hed__Term__c WHERE Program_Batch__c =: currTerm.Program_Batch__c
                                            AND recordTypeId =: termRtId AND id !=: termId])
                {

                    for(hed__Plan_Requirement__c pr : objterm.Plan_Requirements__r){
                        if(pr.hed__Category__c == 'Hardcore Course' || pr.hed__Category__c == 'Practical/Term Work' ||
                           pr.hed__Category__c == 'Hardcore Integrated Course' || pr.hed__Category__c == 'Mandatory Course'){
                               courseIds.put(pr.hed__Course__c,objterm.Name);
                           }
                        if((pr.hed__Category__c == 'Open Elective' && string.isNotBlank(pr.hed__Plan_Requirement__c)) ||
                           (pr.hed__Category__c == 'Professional Elective' && string.isNotBlank(pr.hed__Plan_Requirement__c))){
                               courseIds.put(pr.hed__Course__c,objterm.Name);
                           }
                        if(pr.hed__Category__c == 'RBS Specialization' && string.isNotBlank(pr.Specialization__c)){
                        courseIds.put(pr.hed__Course__c,objterm.Name);
                        spclCoSemKey.add(pr.hed__Course__c+'-'+pr.Specialization__c+'-'+objterm.Id);

                        }
                    }
                }
            }
            else{
                for(hed__Course_Offering__c pr : [SELECT id,Name,Category__c,hed__Course__c,Credits__c,Trigger_Approval__c,Credit_Hours__c,hed__Term__r.Id,
                                                  Sequence__c,hed__Course__r.Name,hed__Term__c,hed__Term__r.Name,Parent_Course_Offering__c,Specialization__c
                                                  FROM hed__Course_Offering__c
                                                  WHERE hed__Term__r.Program_Batch__c =: currTerm.Program_Batch__c AND
                                                  hed__Term__c !=: termId AND hed__Term__r.recordTypeId =: termRtId ]){

                                                      if(pr.Category__c == 'Hardcore Course' || pr.Category__c == 'Practical/Term Work' ||
                                                         pr.Category__c == 'Hardcore Integrated Course' || pr.Category__c == 'Mandatory Course' || pr.Category__c=='RBS Specialization'){
                                                             courseIds.put(pr.hed__Course__c,pr.hed__Term__r.Name);
                                                         }
                                                      if((pr.Category__c == 'Open Elective' && string.isNotBlank(pr.Parent_Course_Offering__c)) ||
                                                         (pr.Category__c == 'Professional Elective' && string.isNotBlank(pr.Parent_Course_Offering__c))){
                                                             courseIds.put(pr.hed__Course__c,pr.hed__Term__r.Name);

                                                         }
                                                        if(pr.Category__c == 'RBS Specialization' && string.isNotBlank(pr.Specialization__c)){
                                                            courseIds.put(pr.hed__Course__c,pr.hed__Term__r.Name);
                                                            spclCoSemKey.add(pr.hed__Course__c+'-'+pr.Specialization__c+'-'+pr.hed__Term__r.Id);

                                                           }

                                                  }

            }


            for(planLiwrap hc : lstHc)
            {
                if(hc.courseId != null) set_courseid.add(hc.courseId);
                if(courseIds.containsKey(hc.courseId)){
                    ErrMsg = 'The subject \''+hc.courseName+'\' already exists in Semester'+courseIds.get(hc.courseId) ;
                }
                else{
                    courseIds.put(hc.courseId,currTerm.Name);
                }
            }

            for(planLiwrap hc : lstHcIntegrated)
            {
                if(hc.courseId != null) set_courseid.add(hc.courseId);
                if(courseIds.containsKey(hc.courseId)){
                    ErrMsg = 'The subject \''+hc.courseName+'\' already exists in Semester'+courseIds.get(hc.courseId) ;
                }
                else{
                    courseIds.put(hc.courseId,currTerm.Name);
                }
            }

            for(planLiwrap hc : lstPra)
            {
                if(hc.courseId != null) set_courseid.add(hc.courseId);
                if(courseIds.containsKey(hc.courseId)){
                    ErrMsg = 'The subject \''+hc.courseName+'\' already exists in Semester'+courseIds.get(hc.courseId) ;
                }
                else{
                    courseIds.put(hc.courseId,currTerm.Name);
                }
            }

            for(planLiwrap hc : lstMandatory)
            {
                if(hc.courseId != null) set_courseid.add(hc.courseId);
                if(courseIds.containsKey(hc.courseId)){
                    ErrMsg = 'The subject \''+hc.courseName+'\' already exists in Semester'+courseIds.get(hc.courseId) ;
                }
                else{
                    courseIds.put(hc.courseId,currTerm.Name);
                }
            }

            for(openElectivewrap objOe : lstOe)
            {
                for(planLiwrap oe : objOe.lstPlanLi)
                {
                    if(oe.courseId != null) set_courseid.add(oe.courseId);
                    if(courseIds.containsKey(oe.courseId)){
                        ErrMsg = 'The subject \''+oe.courseName+'\' already exists in Semester'+courseIds.get(oe.courseId) ;
                    }
                    else{
                        courseIds.put(oe.courseId,currTerm.Name);
                    }
                }
            }
            for(RbsSpclWrap objOe : lstSpcl)
            {
                for(planLiwrap oe : objOe.lstPlanLi)
                {
                    if(oe.courseId != null) {
                        set_courseid.add(oe.courseId);
                        String spCoSemkey = String.valueOf(oe.courseId) + '-' +String.valueOf(objOe.parentId) + '-' + String.valueOf(currTerm.Id);
                        if(courseIds.containsKey(oe.courseId) && !spclCoSemKey.isEmpty() && spclCoSemKey.contains(spCoSemkey)){
                            ErrMsg = 'The subject \''+oe.courseName+'\' already exists in Semester '+courseIds.get(oe.courseId) + 'With '+objOe.name +' SSpecialization';
                        }
                        else {
                            courseIds.put(oe.courseId,currTerm.Name);
                        }
                    }
                }
            }

            for(profElectivewrap objPe : lstPe){
                for(planLiwrap pe : objPe.lstPlanLi)
                {
                    if(pe.courseId != null) set_courseid.add(pe.courseId);
                    if(courseIds.containsKey(pe.courseId)){
                        ErrMsg = 'The subject \''+pe.courseName+'\' already exists in Semester'+courseIds.get(pe.courseId) ;
                    }
                    else{
                        courseIds.put(pe.courseId,currTerm.Name);
                    }
                }
            }


            if(ErrMsg == 'Success'){
                hed__Term__c objTerm = new hed__Term__c();
                for(hed__Term__c Term : [SELECT id,Name,hed__Account__c,Program_Batch__r.hed__Account__r.ParentId,hed__Start_Date__c,Course_Offering_Update__c,
                                         hed__End_Date__c,Course_Offering_Created__c FROM hed__Term__c WHERE id =: termId]){
                                             objTerm = Term;
                                         }

                list<hed__Course_Offering__c> lstcourses = new list<hed__Course_Offering__c>();
                if(set_courseid.size() >0)
                {
                    for(hed__Course__c objCourse : [select Id,Name,hed__Account__c,Offered_By_School__c,Approval_Required_by_School_Head__c,Credit_Hours__c,
                                                    Max_No_of_Professors__c,Min_No_of_Professors__c from hed__Course__c where id in: set_courseid])
                    {
                        map_Course.put(objCourse.id,objCourse);
                    }
                }

                 /************************ RBS Course ******************************/

               for(RbsSpclWrap objOe : lstSpcl){
                    for(planLiwrap rbs : objOe.lstPlanLi){
                    hed__Course_Offering__c objCr = new hed__Course_Offering__c();

                    if(rbs.recordId !=null || rbs.recordId !=''){
                        objCr.id = rbs.recordId;
                    }else {
                        objCr.id = '';
                    }
                    objCr.Name = rbs.courseName;
                    objCr.Category__c = 'RBS Specialization';
                    objCr.hed__Course__c = rbs.courseId;
                    objCr.Credits__c = rbs.credits;
                    objCr.Specialization__c = objOe.parentId;
                    objCr.hed__Term__c = termId;
                    if(!string.isBlank(rbs.count)){
                      objCr.Sequence__c = decimal.valueof(rbs.count);
                    }

                    objCr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                    objCr.hed__End_Date__c = objTerm.hed__End_Date__c;
                    objCr.Course_Offering_Updated__c = true;
                    if(!string.isBlank(schoolhead)) {
                        objCr.School_Head__c = schoolhead;
                    }
                    if(!string.isBlank(VericalHead)){
                         objCr.Vertical_Head__c = VericalHead;
                    }
                    if(map_Course.get(rbs.courseId) != null)
                    {
                        objCr.Offered_By_School__c = map_Course.get(rbs.courseId).Offered_By_School__c;
                        objCr.Approval_Required_by_School_Head__c = map_Course.get(rbs.courseId).Approval_Required_by_School_Head__c;
                        objCr.Max_Professors_Per_Course__c = map_Course.get(rbs.courseId).Max_No_of_Professors__c;
                        objCr.Min_Professors_Per_Course__c = map_Course.get(rbs.courseId).Min_No_of_Professors__c;
                        objCr.Credit_Hours__c = map_Course.get(rbs.courseId).Credit_Hours__c;
                    }
                    objCr.Trigger_Approval__c = Approval;
                    objCr.Active__c = true;
                    lstcourses.add(objCr);
                    mapTerm.get(termId).Total_Course_Offering_credits__c += objCr.Credits__c;
                }
            }
                /************************ Hardcore Course ******************************/
                for(planLiwrap hc : lstHc){
                    hed__Course_Offering__c objCr = new hed__Course_Offering__c();
                    objCr.id = hc.recordId;
                    objCr.Name = hc.courseName;
                    objCr.Category__c = 'Hardcore Course';
                    objCr.hed__Course__c = hc.courseId;
                    objCr.Credits__c = hc.credits;
                    objCr.hed__Term__c = termId;
                    if(!string.isBlank(hc.count)) objCr.Sequence__c = decimal.valueof(hc.count);
                    objCr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                    objCr.hed__End_Date__c = objTerm.hed__End_Date__c;
                    objCr.Course_Offering_Updated__c = true;
                    if(!string.isBlank(schoolhead)) objCr.School_Head__c = schoolhead;
                    if(!string.isBlank(VericalHead)) objCr.Vertical_Head__c = VericalHead;
                    if(map_Course.get(hc.courseId) != null)
                    {
                        objCr.Offered_By_School__c = map_Course.get(hc.courseId).Offered_By_School__c;
                        objCr.Approval_Required_by_School_Head__c = map_Course.get(hc.courseId).Approval_Required_by_School_Head__c;
                        objCr.Max_Professors_Per_Course__c = map_Course.get(hc.courseId).Max_No_of_Professors__c;
                        objCr.Min_Professors_Per_Course__c = map_Course.get(hc.courseId).Min_No_of_Professors__c;
                        objCr.Credit_Hours__c = map_Course.get(hc.courseId).Credit_Hours__c;
                    }
                    objCr.Trigger_Approval__c = Approval;
                    objCr.Active__c = true;
                    lstcourses.add(objCr);
                    mapTerm.get(termId).Total_Course_Offering_credits__c += objCr.Credits__c;
                }
                /************************ Hardcore Integrated Course ******************************/
                for(planLiwrap hc : lstHcIntegrated){
                    hed__Course_Offering__c objCr = new hed__Course_Offering__c();
                    objCr.id = hc.recordId;
                    objCr.Name = hc.courseName;
                    objCr.Category__c = 'Hardcore Integrated Course';
                    objCr.hed__Course__c = hc.courseId;
                    objCr.Credits__c = hc.credits;
                    objCr.hed__Term__c = termId;
                    objCr.Course_Offering_Updated__c = true;
                    if(!string.isBlank(hc.count)) objCr.Sequence__c = decimal.valueof(hc.count);
                    objCr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                    objCr.hed__End_Date__c = objTerm.hed__End_Date__c;
                    mapTerm.get(termId).Total_Course_Offering_credits__c += objCr.Credits__c;
                    if(!string.isBlank(schoolhead)) objCr.School_Head__c = schoolhead;
                    if(!string.isBlank(VericalHead)) objCr.Vertical_Head__c = VericalHead;
                    if(map_Course.get(hc.courseId) != null)
                    {
                        objCr.Offered_By_School__c = map_Course.get(hc.courseId).Offered_By_School__c;
                        objCr.Approval_Required_by_School_Head__c = map_Course.get(hc.courseId).Approval_Required_by_School_Head__c;
                        objCr.Max_Professors_Per_Course__c = map_Course.get(hc.courseId).Max_No_of_Professors__c;
                        objCr.Min_Professors_Per_Course__c = map_Course.get(hc.courseId).Min_No_of_Professors__c;
                        objCr.Credit_Hours__c = map_Course.get(hc.courseId).Credit_Hours__c;
                    }
                    objCr.Trigger_Approval__c = Approval;
                    objCr.Active__c = true;
                    lstcourses.add(objCr);
                }
                /************************ Practical/Term Work ******************************/
                for(planLiwrap hc : lstPra){
                    hed__Course_Offering__c objCr = new hed__Course_Offering__c();
                    objCr.id = hc.recordId;
                    objCr.Name = hc.courseName;
                    objCr.Category__c = 'Practical/Term Work';
                    objCr.hed__Course__c = hc.courseId;
                    objCr.Credits__c = hc.credits;
                    objCr.hed__Term__c = termId;
                    objCr.Course_Offering_Updated__c = true;
                    if(!string.isBlank(hc.count)) objCr.Sequence__c = decimal.valueof(hc.count);
                    objCr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                    objCr.hed__End_Date__c = objTerm.hed__End_Date__c;
                    if(!string.isBlank(schoolhead)) objCr.School_Head__c = schoolhead;
                    if(!string.isBlank(VericalHead)) objCr.Vertical_Head__c = VericalHead;
                    mapTerm.get(termId).Total_Course_Offering_credits__c += objCr.Credits__c;
                    if(map_Course.get(hc.courseId) != null)
                    {
                        objCr.Offered_By_School__c = map_Course.get(hc.courseId).Offered_By_School__c;
                        objCr.Approval_Required_by_School_Head__c = map_Course.get(hc.courseId).Approval_Required_by_School_Head__c;
                        objCr.Max_Professors_Per_Course__c = map_Course.get(hc.courseId).Max_No_of_Professors__c;
                        objCr.Min_Professors_Per_Course__c = map_Course.get(hc.courseId).Min_No_of_Professors__c;
                        objCr.Credit_Hours__c = map_Course.get(hc.courseId).Credit_Hours__c;
                    }
                    objCr.Active__c = true;
                    objCr.Trigger_Approval__c = Approval;
                    lstcourses.add(objCr);
                }
                /************************ Mandatory Course ******************************/
                for(planLiwrap hc : lstMandatory){
                    hed__Course_Offering__c objCr = new hed__Course_Offering__c();
                    objCr.id = hc.recordId;
                    objCr.Name = hc.courseName;
                    objCr.Category__c = 'Mandatory Course';
                    objCr.hed__Course__c = hc.courseId;
                    objCr.Credits__c = hc.credits;
                    objCr.hed__Term__c = termId;
                    objCr.Course_Offering_Updated__c = true;
                    if(!string.isBlank(hc.count)) objCr.Sequence__c = decimal.valueof(hc.count);
                    objCr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                    objCr.hed__End_Date__c = objTerm.hed__End_Date__c;
                    if(!string.isBlank(schoolhead)) objCr.School_Head__c = schoolhead;
                    if(!string.isBlank(VericalHead)) objCr.Vertical_Head__c = VericalHead;
                    mapTerm.get(termId).Total_Course_Offering_credits__c += objCr.Credits__c;
                    if(map_Course.get(hc.courseId) != null)
                    {
                        objCr.Offered_By_School__c = map_Course.get(hc.courseId).Offered_By_School__c;
                        objCr.Approval_Required_by_School_Head__c = map_Course.get(hc.courseId).Approval_Required_by_School_Head__c;
                        objCr.Max_Professors_Per_Course__c = map_Course.get(hc.courseId).Max_No_of_Professors__c;
                        objCr.Min_Professors_Per_Course__c = map_Course.get(hc.courseId).Min_No_of_Professors__c;
                        objCr.Credit_Hours__c = map_Course.get(hc.courseId).Credit_Hours__c;
                    }
                    objCr.Active__c = true;
                    objCr.Trigger_Approval__c = Approval;
                    lstcourses.add(objCr);
                }
                /************************ Open Elective ******************************/
                list<hed__Course_Offering__c> lstOpParent = new list<hed__Course_Offering__c>();

                for(openElectivewrap objOe : lstOe){
                    hed__Course_Offering__c objPr = new hed__Course_Offering__c();
                    objPr.id = objOe.recordId;
                    objPr.Name = objOe.Name;
                    objPr.Category__c = 'Open Elective';
                    objPr.Credits__c = objOe.credits;
                    objPr.hed__Term__c = termId;
                    objPr.Course_Offering_Updated__c = true;
                    if(!string.isBlank(objOe.count)) objPr.Sequence__c = decimal.valueof(objOe.count);
                    objPr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                    objPr.hed__End_Date__c = objTerm.hed__End_Date__c;
                    if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                    if(!string.isBlank(VericalHead)) objPr.Vertical_Head__c = VericalHead;
                    objPr.hed__Course__c = label.MSTR_Open_Elective_Course_Id;
                    objPr.Trigger_Approval__c = Approval;
                    lstOpParent.add(objPr);
                    mapTerm.get(termId).Total_Course_Offering_credits__c += objPr.Credits__c;
                }
                if(lstOpParent.size() > 0){
                    upsert lstOpParent;
                    map<string,string> mapParent = new map<string,string>();
                    for(hed__Course_Offering__c objPr : lstOpParent){
                        mapParent.put(objPr.Name,objPr.id);
                    }

                    for(openElectivewrap objOe : lstOe){
                        for(planLiwrap oe : objOe.lstPlanLi){
                            hed__Course_Offering__c objPr = new hed__Course_Offering__c();
                            objPr.id = oe.recordId;
                            objPr.Name = oe.courseName;
                            objPr.Category__c = 'Open Elective';
                            objPr.hed__Course__c = oe.courseId;
                            objPr.Course_Offering_Updated__c = true;
                            if(!string.isBlank(oe.count)) objPr.Sequence__c = decimal.valueof(oe.count);
                            objPr.hed__Term__c = termId;
                            objPr.Parent_Course_Offering__c = mapParent.get(objOe.Name);
                            objPr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                            objPr.hed__End_Date__c = objTerm.hed__End_Date__c;
                            objPr.Credits__c = oe.credits;
                            if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                            if(!string.isBlank(VericalHead)) objPr.Vertical_Head__c = VericalHead;
                            if(map_Course.get(oe.courseId) != null)
                            {
                                objPr.Offered_By_School__c = map_Course.get(oe.courseId).Offered_By_School__c;
                                objPr.Approval_Required_by_School_Head__c = map_Course.get(oe.courseId).Approval_Required_by_School_Head__c;
                                objPr.Max_Professors_Per_Course__c = map_Course.get(oe.courseId).Max_No_of_Professors__c;
                                objPr.Min_Professors_Per_Course__c = map_Course.get(oe.courseId).Min_No_of_Professors__c;
                                objPr.Credit_Hours__c = map_Course.get(oe.courseId).Credit_Hours__c;
                            }
                            objPr.Trigger_Approval__c = Approval;
                            lstcourses.add(objPr);
                        }
                    }
                }
                /************************ Professional Elective ******************************/
                list<hed__Course_Offering__c> lstProParent = new list<hed__Course_Offering__c>();
                for(profElectivewrap objOe : lstPe){
                    hed__Course_Offering__c objPr = new hed__Course_Offering__c();
                    objPr.id = objOe.recordId;
                    objPr.Name = objOe.Name;
                    objPr.Category__c = 'Professional Elective';
                    objPr.Credits__c = objOe.credits;
                    objPr.hed__Term__c = termId;
                    if(!string.isBlank(objOe.count)) objPr.Sequence__c = decimal.valueof(objOe.count);
                    objPr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                    objPr.hed__End_Date__c = objTerm.hed__End_Date__c;
                    objPr.hed__Course__c = label.MSTR_Professional_Elective_Course_Id;
                    if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                    if(!string.isBlank(VericalHead)) objPr.Vertical_Head__c = VericalHead;
                    objPr.Trigger_Approval__c = Approval;
                    objPr.Course_Offering_Updated__c = true;
                    lstProParent.add(objPr);
                    mapTerm.get(termId).Total_Course_Offering_credits__c += objPr.Credits__c;
                }
                if(lstProParent.size() > 0){
                    upsert lstProParent;
                    map<string,string> mapParent = new map<string,string>();
                    for(hed__Course_Offering__c objPr : lstProParent){
                        mapParent.put(objPr.Name,objPr.id);
                    }

                    for(profElectivewrap objOe : lstPe){
                        for(planLiwrap oe : objOe.lstPlanLi){
                            hed__Course_Offering__c objPr = new hed__Course_Offering__c();
                            objPr.id = oe.recordId;
                            objPr.Name = oe.courseName;
                            objPr.Category__c = 'Professional Elective';
                            objPr.hed__Course__c = oe.courseId;
                            if(!string.isBlank(oe.count)) objPr.Sequence__c = decimal.valueof(oe.count);
                            objPr.Parent_Course_Offering__c = mapParent.get(objOe.Name);
                            objPr.hed__Start_Date__c = objTerm.hed__Start_Date__c;
                            objPr.hed__End_Date__c = objTerm.hed__End_Date__c;
                            objPr.hed__Term__c = termId;
                            objPr.Credits__c = oe.credits;
                            objPr.Course_Offering_Updated__c = true;
                            if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                            if(!string.isBlank(VericalHead)) objPr.Vertical_Head__c = VericalHead;
                            if(map_Course.get(oe.courseId) != null)
                            {
                                objPr.Offered_By_School__c = map_Course.get(oe.courseId).Offered_By_School__c;
                                objPr.Approval_Required_by_School_Head__c = map_Course.get(oe.courseId).Approval_Required_by_School_Head__c;
                                objPr.Max_Professors_Per_Course__c = map_Course.get(oe.courseId).Max_No_of_Professors__c;
                                objPr.Min_Professors_Per_Course__c = map_Course.get(oe.courseId).Min_No_of_Professors__c;
                                objPr.Credit_Hours__c = map_Course.get(oe.courseId).Credit_Hours__c;
                            }
                            objPr.Trigger_Approval__c = Approval;
                            lstcourses.add(objPr);
                        }
                    }
                }
                if(lstcourses.size() > 0)
                {
                   // MSTR_CourseOfferingTrigger_Handler.RunCourseSequence = true;
                    upsert lstcourses;
                }

                if(mapTerm.values().size() > 0){
                    update mapTerm.values();
                }

                if(deletedIds.size() > 0){
                    map<string,hed__Course_Offering__c> mapPr = new map<string,hed__Course_Offering__c>();
                    map<string,hed__Course_Offering__c> mapChild = new map<string,hed__Course_Offering__c>();
                    set<string> parentIds = new set<string>();
                    for(hed__Course_Offering__c pr : [SELECT id,Category__c,Parent_Course_Offering__c
                                                      FROM hed__Course_Offering__c WHERE id =: deletedIds]){

                                                          if(pr.Category__c == 'Open Elective' || pr.Category__c == 'Professional Elective'){

                                                              if(string.isBlank(pr.Parent_Course_Offering__c)){
                                                                  parentIds.add(pr.id);
                                                                  mapPr.put(pr.id,pr);
                                                              }
                                                              else{
                                                                  mapChild.put(pr.id,pr);
                                                              }
                                                          }
                                                          else{
                                                              mapChild.put(pr.id,pr);
                                                          }
                                                      }

                    if(parentIds.size() > 0){
                        for(hed__Course_Offering__c pr : [SELECT id,Category__c,Parent_Course_Offering__c
                                                          FROM hed__Course_Offering__c WHERE Parent_Course_Offering__c =: parentIds]){
                                                              if(!mapChild.containsKey(pr.id)){
                                                                  mapChild.put(pr.id,pr);
                                                              }
                                                          }
                    }
                    if(mapChild.values().size() > 0){
                        delete mapChild.values();
                    }
                    if(mapPr.values().size() > 0){
                        delete mapPr.values();
                    }
                }
                objTerm.Course_Offering_Created__c = true;
                objTerm.Course_Offering_Update__c =true;
                if(type){
                    objTerm.Sent_for_Approval__c = true;
                }
                update objTerm;
            }
        }
        catch(exception Ex){
            ErrMsg = string.valueof(Ex);
        }
        return ErrMsg;
    }
    @AuraEnabled
    public static string getSchoolName(string AccschoolId)
    {
        Account objacc = [select id,Name from Account where id =:AccschoolId];
        return objacc.Name;
    }
    public class termMainWarp
    {
        @AuraEnabled public hed__Term__c objTerm {get;set;}
        @AuraEnabled public map<string,string> hcCoursePl {get;set;}
        @AuraEnabled public map<string,string> hcIntegratedPl {get;set;}
        @AuraEnabled public map<string,string> pratialPl {get;set;}
        @AuraEnabled public map<string,string> oElectivePl {get;set;}
        @AuraEnabled public map<string,string> pElectivePl {get;set;}
        @AuraEnabled public map<string,string> rbsSpclPl {get;set;}
        @AuraEnabled public map<string,string> MandatoryPl {get;set;}
        @AuraEnabled public string filterIds {get;set;}

        public termMainWarp(){
            objTerm = new hed__Term__c();
            hcCoursePl = new map<string,string>();
            hcIntegratedPl = new map<string,string>();
            pratialPl = new map<string,string>();
            oElectivePl = new map<string,string>();
            pElectivePl = new map<string,string>();
            rbsSpclPl = new map<string,string>();
            MandatoryPl = new map<string,string>();

        }
    }

    public class courseMainWarp{
        @AuraEnabled public list<planLiwrap> listHardCore {get;set;}
        @AuraEnabled public list<openElectivewrap> listOpenElective {get;set;}
        @AuraEnabled public list<profElectivewrap> listProfElective {get;set;}
        @AuraEnabled public list<RbsSpclWrap> lstSpcl {get;set;}
        @AuraEnabled public list<planLiwrap> listPractical {get;set;}
        @AuraEnabled public list<planLiwrap> listHcIntegrated {get;set;}
        @AuraEnabled public list<planLiwrap> listMandatory {get;set;}
        // @AuraEnabled public list<planLiwrap> listRbs {get;set;}
        @AuraEnabled public decimal totalCredit {get;set;}

        public courseMainWarp(){
            listHardCore = new list<planLiwrap>();
            listOpenElective = new list<openElectivewrap>();
            listProfElective = new list<profElectivewrap>();
            lstSpcl = new list<RbsSpclWrap>();
            listPractical = new list<planLiwrap> ();
            listHcIntegrated = new list<planLiwrap>();
            listMandatory = new list<planLiwrap>();
            // listRbs = new list<planLiwrap>();
        }
    }

    public class openElectivewrap{

        @AuraEnabled public string count {get;set;}
        @AuraEnabled public string parentId {get;set;}
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public decimal credits {get;set;}
        @AuraEnabled public string termId {get;set;}
        @AuraEnabled public list<planLiwrap> lstPlanLi {get;set;}
        @AuraEnabled public string recordId {get;set;}
        public openElectivewrap(){
            lstPlanLi = new list<planLiwrap>();
        }
    }
    public class profElectivewrap{
        @AuraEnabled public string count {get;set;}
        @AuraEnabled public string parentId {get;set;}
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public decimal credits {get;set;}
        @AuraEnabled public string termId {get;set;}
        @AuraEnabled public list<planLiwrap> lstPlanLi {get;set;}
        @AuraEnabled public string recordId {get;set;}
        public profElectivewrap(){
            lstPlanLi = new list<planLiwrap>();
        }
    }

    /**
     * @description Wrapper class for RBS Specialization.
     * This class holds details about RBS specialization courses, including their IDs, names, credits, and associated plans.
     */
    public class RbsSpclWrap{
         /**
         * @description Represents the count of items or sequence number.
         */
        @AuraEnabled public string count {get;set;}
        /**
         * @description Represents the parent ID associated with the RBS specialization.
         */
        @AuraEnabled public string parentId {get;set;}

        /**
         * @description Represents the name associated with the RBS specialization.
         */
        @AuraEnabled public string name {get;set;}

         /**
         * @description Represents the credits associated with the course or specialization.
         */
        @AuraEnabled public decimal credits {get;set;}
          /**
         * @description Represents the term ID associated with the course or specialization.
         */
        @AuraEnabled public string termId {get;set;}

        /**
         * @description Represents the list of plan line items associated with the RBS specialization.
         */
        @AuraEnabled public list<planLiwrap> lstPlanLi {get;set;}

         /**
         * @description Represents the record ID associated with the course or specialization.
         */
        @AuraEnabled public string recordId {get;set;}

        /**
         * @description Constructor for the RbsSpclWrap class.
         * Initializes the list of plan line items associated with the RBS specialization.
         */
        public RbsSpclWrap(){
            lstPlanLi = new list<planLiwrap>();
        }
    }

    public class planLiwrap{
        @AuraEnabled public string count {get;set;}
        @AuraEnabled public string subCount {get;set;}
        @AuraEnabled public string courseId {get;set;}
        @AuraEnabled public string courseName {get;set;}
        @AuraEnabled public decimal credits {get;set;}
        @AuraEnabled public string termId {get;set;}
        @AuraEnabled public string recordId {get;set;}
        @AuraEnabled public string filter {get;set;}
        @AuraEnabled public string accfilter {get;set;}
        @AuraEnabled public string SchoolId {get;set;}
        @AuraEnabled public string schoolName {get;set;}
        @AuraEnabled public string parentId {get;set;}
    }


}