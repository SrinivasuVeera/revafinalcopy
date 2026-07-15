Public with sharing class MSTR_createPlanRequiementCls{

    @AuraEnabled
    public static hed__Program_Plan__c getProgramPlan(string planId){
        hed__Program_Plan__c pp = new hed__Program_Plan__c();
        pp = [SELECT id,Name,hed__Account__r.ParentId FROM hed__Program_Plan__c WHERE id =: planId];
        return pp;
    }

    @AuraEnabled
    public static string getpicklistFilterIds(string planId){
        hed__Program_Plan__c pp = new hed__Program_Plan__c();

        pp = [SELECT id,Name,hed__Account__r.ParentId FROM hed__Program_Plan__c WHERE id =: planId];

        string accIds = pp.hed__Account__r.ParentId+',';
        for(account acc : [SELECT id FROM Account WHERE parentId =: pp.hed__Account__r.ParentId]){
            accIds += acc.id + ',';
        }
        accIds = accIds.trim();
        if(accIds.endsWith(','))
        {
            accIds = accIds.subString(0, accIds.lastIndexOf(','));
        }
        return accIds;
    }

    @AuraEnabled
    public static list<termwrap> queryPlanRequirementCount(string planId){

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        list<termwrap> lstWrap = new list<termwrap>();
        for(hed__Term__c objterm : [SELECT id,Name,Course_Offering_Created__c,(SELECT id,hed__Category__c,hed__Plan_Requirement__c,Credits__c FROM Plan_Requirements__r
                                                                               WHERE hed__Category__c != Null) FROM hed__Term__c WHERE Program_Batch__c =: planId AND recordTypeId =: termRtId])
        {

            termwrap objWrap = new termwrap();
            objWrap.termName = objterm.Name;
            objWrap.termId = objterm.id;
            objWrap.courseCreated = objterm.Course_Offering_Created__c;
            for(hed__Plan_Requirement__c objPr : objterm.Plan_Requirements__r){
                if(objPr.hed__Category__c == 'Hardcore Course'){
                    objWrap.hardCoreCount += 1;
                }
                if(objPr.hed__Category__c == 'Open Elective' && string.isBlank(objPr.hed__Plan_Requirement__c)){
                    objWrap.oElectiveCount += 1;
                }
                if(objPr.hed__Category__c == 'Professional Elective' && string.isBlank(objPr.hed__Plan_Requirement__c)){
                    objWrap.pElectiveCount += 1;
                }
                if(objPr.hed__Category__c == 'Practical/Term Work'){
                    objWrap.praticalCount += 1;
                }
                if(objPr.hed__Category__c == 'Hardcore Integrated Course'){
                    objWrap.hcIntegratedCount += 1;
                }
                if(objPr.hed__Category__c == 'Mandatory Course'){
                    objWrap.mandatoryCount += 1;
                }
                if(objPr.hed__Category__c == 'RBS Specialization'){
                    objWrap.specializationCount += 1;
                }
                if(objPr.Credits__c != Null){
                    objWrap.totalCredit = objWrap.totalCredit + objPr.Credits__c;
                }
            }
            lstWrap.add(objWrap);
        }
        return lstWrap;
    }

    @AuraEnabled
    public static planRequirementwrap queryPlanRequirements(string termId){
        planRequirementwrap objPlans = new planRequirementwrap();
        objPlans.totalCredit = 0;
        string accountId ;
        set<string> prIds = new set<string>();

        hed__Term__c tt = new hed__Term__c();
        string accIds = '';
        tt = [SELECT id,Name,Program_Batch__r.hed__Account__r.ParentId FROM hed__Term__c WHERE id =: termId];

        for(account acc : [SELECT id FROM Account WHERE parentId =: tt.Program_Batch__r.hed__Account__r.ParentId]){
            accIds += acc.id + ',';
        }
        accIds = accIds.trim();
        if(accIds.endsWith(','))
        {
            accIds = accIds.subString(0, accIds.lastIndexOf(','));
        }


        for(hed__Term__c objterm : [SELECT id,Name,hed__Account__c,Program_Batch__r.hed__Account__r.ParentId,Program_Batch__r.hed__Account__r.Parent.ParentId,
                                    (SELECT id,hed__Category__c,hed__Course__c,hed__Course__r.Name,hed__Course__r.Offered_By_School__c,hed__Course__r.Approval_Required_by_School_Head__c,hed__Course__r.hed__Account__c,hed__Course__r.hed__Account__r.Name,
                                     Credits__c,Sequence__c,hed__Plan_Requirement__c,Semester__c,hed__Course__r.Offered_By_School__r.Name,Specialization__c,Specialization__r.Name
                                     FROM Plan_Requirements__r
                                     WHERE hed__Category__c != Null) FROM hed__Term__c WHERE id =: termId])
        {
            accountId = objterm.hed__Account__c;

            for(hed__Plan_Requirement__c objPr : objterm.Plan_Requirements__r){
                if(objPr.hed__Category__c == 'Hardcore Course'){
                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.Semester__c;
                    objHc.recordId = objPr.id;
                    objHc.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHc.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                   // objHc.Approval_Required_by_School_Head__c = objPr.hed__Course__r.Approval_Required_by_School_Head__c;
                    objHc.filter = 'Category__c = \'Hardcore Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objHc.accfilter='hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.Parent.ParentId + '\'';
                    if(objPr.Sequence__c != Null){
                        objHc.count = string.valueof(objPr.Sequence__c);
                    }
                    objPlans.listHardCore.add(objHc);
                    objPlans.totalCredit = objPlans.totalCredit + objPr.Credits__c;
                }
                if(objPr.hed__Category__c == 'Practical/Term Work'){
                    planLiwrap objPra = new planLiwrap();
                    objPra.courseId = objPr.hed__Course__c;
                    objPra.courseName = objPr.hed__Course__r.Name;
                    objPra.credits = objPr.Credits__c;
                    objPra.termId = objPr.Semester__c;
                    objPra.recordId = objPr.id;
                    objPra.filter = 'Category__c = \'Practical/Term Work\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objPra.accfilter='hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.Parent.ParentId + '\'';
                    objPra.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objPra.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objPra.count = string.valueof(objPr.Sequence__c);
                    }
                    objPlans.listPractical.add(objPra);
                    objPlans.totalCredit = objPlans.totalCredit + objPr.Credits__c;
                }
                if(objPr.hed__Category__c == 'Hardcore Integrated Course'){
                    planLiwrap objHci = new planLiwrap();
                    objHci.courseId = objPr.hed__Course__c;
                    objHci.courseName = objPr.hed__Course__r.Name;
                    objHci.credits = objPr.Credits__c;
                    objHci.termId = objPr.Semester__c;
                    objHci.recordId = objPr.id;
                    objHci.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHci.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    objHci.filter = 'Category__c = \'Hardcore Integrated Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objHci.accfilter='hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.Parent.ParentId + '\'';
                    if(objPr.Sequence__c != Null){
                        objHci.count = string.valueof(objPr.Sequence__c);
                    }
                    objPlans.listHcIntegrated.add(objHci);
                    objPlans.totalCredit = objPlans.totalCredit + objPr.Credits__c;
                }
                if(objPr.hed__Category__c == 'Mandatory Course'){
                    planLiwrap objMan = new planLiwrap();
                    objMan.courseId = objPr.hed__Course__c;
                    objMan.courseName = objPr.hed__Course__r.Name;
                    objMan.credits = objPr.Credits__c;
                    objMan.termId = objPr.Semester__c;
                    objMan.recordId = objPr.id;
                    objMan.filter = 'Category__c = \'Mandatory Course\' AND hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.ParentId + '\'';
                    objMan.accfilter='hed__Account__c = \''+objterm.Program_Batch__r.hed__Account__r.Parent.ParentId + '\'';
                    objMan.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objMan.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objMan.count = string.valueof(objPr.Sequence__c);
                    }
                    objPlans.listMandatory.add(objMan);
                    objPlans.totalCredit = objPlans.totalCredit + objPr.Credits__c;
                }

                if(objPr.hed__Plan_Requirement__c != Null){
                    prIds.add(objPr.hed__Plan_Requirement__c);
                }
            }
        }

        for(hed__Plan_Requirement__c pr : [SELECT id,Name,hed__Category__c,Credits__c,Semester__c,Semester__r.Program_Batch__r.hed__Account__r.ParentId,Semester__r.Program_Batch__r.hed__Account__r.Parent.ParentId,
                                           Sequence__c,Credit_Hours__c,Specialization__c,Specialization__r.Name,(SELECT id,hed__Category__c,hed__Course__c,hed__Course__r.Name,hed__Course__r.Offered_By_School__c,hed__Course__r.Offered_By_School__r.Name,
                                                        Credits__c,Credit_Hours__c,Sequence__c,hed__Plan_Requirement__c,Semester__c FROM hed__Plan_Requirements__r)
                                           FROM hed__Plan_Requirement__c WHERE id =: prIds])
        {
            if(pr.hed__Category__c == 'Open Elective'){
                openElectivewrap oew = new openElectivewrap();
                oew.parentId = pr.id;
                oew.Name = pr.Name;
                oew.credits = pr.Credits__c;
                oew.termId = pr.Semester__c;
                oew.recordId = pr.id;
                if(pr.Sequence__c != Null){
                    oew.count = string.valueof(pr.Sequence__c);
                }
                for(hed__Plan_Requirement__c objPr : pr.hed__Plan_Requirements__r){

                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.Semester__c;
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
                objPlans.listOpenElective.add(oew);
                objPlans.totalCredit = objPlans.totalCredit + Pr.Credits__c;
            }

            if(pr.hed__Category__c == 'Professional Elective'){
                profElectivewrap pew = new profElectivewrap();
                pew.parentId = pr.id;
                pew.Name = pr.Name;
                pew.credits = pr.Credits__c;
                pew.termId = pr.Semester__c;
                pew.recordId = pr.id;
                if(pr.Sequence__c != Null){
                    pew.count = string.valueof(pr.Sequence__c);
                }
                for(hed__Plan_Requirement__c objPr : pr.hed__Plan_Requirements__r){

                    planLiwrap objHc = new planLiwrap();
                    objHc.courseId = objPr.hed__Course__c;
                    objHc.courseName = objPr.hed__Course__r.Name;
                    objHc.credits = objPr.Credits__c;
                    objHc.termId = objPr.Semester__c;
                    objHc.recordId = objPr.id;
                    objHc.filter = 'Category__c = \'Professional Elective\' AND hed__Account__c IN: ';
                    objHc.accfilter='hed__Account__c IN:';
                    objHc.SchoolId = objPr.hed__Course__r.Offered_By_School__c;
                    objHc.schoolName = objPr.hed__Course__r.Offered_By_School__r.Name;
                    if(objPr.Sequence__c != Null){
                        objHc.count = string.valueof(objPr.Sequence__c);
                    }
                    pew.lstPlanLi.add(objHc);
                }
                objPlans.listProfElective.add(pew);
                objPlans.totalCredit = objPlans.totalCredit + Pr.Credits__c;
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
                        objMan.recordId = objPr.Id;
                        objMan.filter = 'Category__c = \'RBS Specialization\' AND Specialization__c = \'' + acc.Id + '\'';
                        objMan.SchoolId = objPr.hed__Course__r.hed__Account__c;
                        objMan.schoolName = objPr.hed__Course__r.hed__Account__r.Name;

                        if (objPr.Sequence__c != null) {
                            objMan.count = String.valueOf(objPr.Sequence__c);
                        }

                        rbs.lstPlanLi.add(objMan);
                        objPlans.totalCredit += objPr.Credits__c;
                    } else {
                        objMan.courseId = '';
                        objMan.courseName = '';
                        objMan.credits = 0;
                        objMan.termId = objPr.Semester__c;
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

            objPlans.lstSpcl.add(rbs);
        }


        return objPlans;

    }

    @AuraEnabled
    public static finalTermWrap savePlanRequiement(string planId,string termId,list<planLiwrap> lstHc,list<planLiwrap> lstHcIntegrated,
                                                   list<planLiwrap> lstPra,list<openElectivewrap> lstOe,
                                                   list<profElectivewrap> lstPe,list<planLiwrap> lstMandatory ,list<RbsSpclWrap> lstSpcl,list<string> deletedIds) {

    finalTermWrap fTerm = new finalTermWrap();
        fTerm.errMsg = 'Sucess';
        string schoolhead;
        string verticalhead;
        set<id> set_courseid = new set<id>();
        try
        {
            map<string,string> courseIds = new map<string,string>();
            map<Id,hed__Course__c> map_Course = new map<Id,hed__Course__c>();
            hed__Program_Plan__c objPrgPlan  = new hed__Program_Plan__c();
            if(planId != null)
            {
                objPrgPlan = [select id,Name,hed__Account__c,hed__Account__r.ParentId,hed__Account__r.Parent.School_Head__c,hed__Account__r.Parent.Vertical_Head__c,
                              hed__Account__r.School_Head__c,hed__Account__r.Vertical_Head__c from hed__Program_Plan__c where id =:planId];
                schoolhead = objPrgPlan.hed__Account__r.Parent.School_Head__c;
                verticalhead = objPrgPlan.hed__Account__r.Parent.Vertical_Head__c;
            }

            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

            hed__Term__c currTerm = [SELECT id,Name FROM hed__Term__c WHERE id =: termId];

            Set<String> spclCoSemKey = new Set<String>();

            for(hed__Term__c objterm : [SELECT id,Name,(SELECT id,Name,hed__Category__c,hed__Plan_Requirement__c,Specialization__c,hed__Course__c,Credit_Hours__c FROM Plan_Requirements__r
                                                        WHERE hed__Category__c != Null) FROM hed__Term__c WHERE Program_Batch__c =: planId
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

            for(planLiwrap hc : lstHc)
            {
                if(hc.courseId != null) set_courseid.add(hc.courseId);
                if(courseIds.containsKey(hc.courseId)){
                    fTerm.errMsg = 'The subject \''+hc.courseName+'\' already exists in Semester '+courseIds.get(hc.courseId) ;
                }
                else{
                    courseIds.put(hc.courseId,currTerm.Name);
                }
            }

            for(planLiwrap hc : lstHcIntegrated)
            {
                if(hc.courseId != null) set_courseid.add(hc.courseId);
                if(courseIds.containsKey(hc.courseId)){
                    fTerm.errMsg = 'The subject \''+hc.courseName+'\' already exists in Semester '+courseIds.get(hc.courseId) ;
                }
                else{
                    courseIds.put(hc.courseId,currTerm.Name);
                }
            }

            for(planLiwrap hc : lstPra)
            {
                if(hc.courseId != null) set_courseid.add(hc.courseId);
                if(courseIds.containsKey(hc.courseId)){
                    fTerm.errMsg = 'The subject \''+hc.courseName+'\' already exists in Semester '+courseIds.get(hc.courseId) ;
                }
                else{
                    courseIds.put(hc.courseId,currTerm.Name);
                }
            }

            for(planLiwrap hc : lstMandatory)
            {
                if(hc.courseId != null) set_courseid.add(hc.courseId);
                if(courseIds.containsKey(hc.courseId)){
                    fTerm.errMsg = 'The subject \''+hc.courseName+'\' already exists in Semester '+courseIds.get(hc.courseId) ;
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
                        fTerm.errMsg = 'The subject \''+oe.courseName+'\' already exists in Semester '+courseIds.get(oe.courseId) ;
                    }
                    else{
                        courseIds.put(oe.courseId,currTerm.Name);
                    }
                }
            }


            for(profElectivewrap objPe : lstPe){
                for(planLiwrap pe : objPe.lstPlanLi)
                {
                    if(pe.courseId != null) set_courseid.add(pe.courseId);
                    if(courseIds.containsKey(pe.courseId)){
                        fTerm.errMsg = 'The subject \''+pe.courseName+'\' already exists in Semester '+courseIds.get(pe.courseId) ;
                    }
                    else{
                        courseIds.put(pe.courseId,currTerm.Name);
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
                            fTerm.errMsg = 'The subject \''+oe.courseName+'\' already exists in Semester '+courseIds.get(oe.courseId) + 'With '+objOe.name +' Specialization';
                        }
                        else {
                            courseIds.put(oe.courseId,currTerm.Name);
                        }
                    }
                }
            }


            if(fTerm.errMsg == 'Sucess'){
                list<termwrap>  lstTerm = new  list<termwrap>();
                list<hed__Plan_Requirement__c> lstPr = new list<hed__Plan_Requirement__c>();

                if(set_courseid.size() >0)
               {
                   for(hed__Course__c objCourse : [select Id,Name,hed__Account__c,Offered_By_School__c,Approval_Required_by_School_Head__c,Credit_Hours__c from
                                                  hed__Course__c where id in: set_courseid])
                   {
                       map_Course.put(objCourse.id,objCourse);
                   }
               }

                /************************ Hardcore Course ******************************/
                for(planLiwrap hc : lstHc){
                    hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();
                    objPr.id = hc.recordId;
                    objPr.Name = 'test';
                    objPr.hed__Category__c = 'Hardcore Course';
                    objPr.hed__Course__c = hc.courseId;
                    objPr.Credits__c = hc.credits;
                    objPr.hed__Program_Plan__c = planId;
                    if(!string.isBlank(hc.count)) objPr.Sequence__c = decimal.valueof(hc.count);
                    objPr.Semester__c = hc.termId;
                    if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                    if(!string.isBlank(verticalhead)) objPr.Vertical_Head__c = verticalhead;
                    if(map_Course.get(hc.courseId) != null)
                    {
                       objPr.Offered_By_School__c = map_Course.get(hc.courseId).Offered_By_School__c;
                       objPr.Credit_Hours__c = map_Course.get(hc.courseId).Credit_Hours__c;
                       objPr.Approval_Required_by_School_Head__c = map_Course.get(hc.courseId).Approval_Required_by_School_Head__c;
                    }
                    lstPr.add(objPr);
                }
                /************************ Hardcore Integrated Course ******************************/
               for(planLiwrap hc : lstHcIntegrated){
                    hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();
                    objPr.id = hc.recordId;
                    objPr.Name = 'test';
                    objPr.hed__Category__c = 'Hardcore Integrated Course';
                    objPr.hed__Course__c = hc.courseId;
                    objPr.Credits__c = hc.credits;
                    objPr.hed__Program_Plan__c = planId;
                    if(!string.isBlank(hc.count)) objPr.Sequence__c = decimal.valueof(hc.count);
                    objPr.Semester__c = hc.termId;
                    if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                    if(!string.isBlank(verticalhead)) objPr.Vertical_Head__c = verticalhead;
                   if(map_Course.get(hc.courseId) != null)
                    {
                       objPr.Offered_By_School__c = map_Course.get(hc.courseId).Offered_By_School__c;
                       objPr.Credit_Hours__c = map_Course.get(hc.courseId).Credit_Hours__c;
                       objPr.Approval_Required_by_School_Head__c = map_Course.get(hc.courseId).Approval_Required_by_School_Head__c;
                    }
                    lstPr.add(objPr);
                }
                /************************ Practical/Term Work ******************************/
                for(planLiwrap hc : lstPra){
                    hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();
                    objPr.id = hc.recordId;
                    objPr.Name = 'test';
                    objPr.hed__Category__c = 'Practical/Term Work';
                    objPr.hed__Course__c = hc.courseId;
                    objPr.Credits__c = hc.credits;
                    objPr.hed__Program_Plan__c = planId;
                    if(!string.isBlank(hc.count)) objPr.Sequence__c = decimal.valueof(hc.count);
                    objPr.Semester__c = hc.termId;
                    if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                    if(!string.isBlank(verticalhead)) objPr.Vertical_Head__c = verticalhead;
                    if(map_Course.get(hc.courseId) != null)
                    {
                       objPr.Offered_By_School__c = map_Course.get(hc.courseId).Offered_By_School__c;
                       objPr.Credit_Hours__c = map_Course.get(hc.courseId).Credit_Hours__c;
                       objPr.Approval_Required_by_School_Head__c = map_Course.get(hc.courseId).Approval_Required_by_School_Head__c;
                    }
                    lstPr.add(objPr);
                }
                /************************ Mandatory Course ******************************/
                for(planLiwrap hc : lstMandatory){
                    hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();
                    objPr.id = hc.recordId;
                    objPr.Name = 'test';
                    objPr.hed__Category__c = 'Mandatory Course';
                    objPr.hed__Course__c = hc.courseId;
                    objPr.Credits__c = hc.credits;
                    objPr.hed__Program_Plan__c = planId;
                    if(!string.isBlank(hc.count)) objPr.Sequence__c = decimal.valueof(hc.count);
                    objPr.Semester__c = hc.termId;
                    if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                    if(!string.isBlank(verticalhead)) objPr.Vertical_Head__c = verticalhead;
                    if(map_Course.get(hc.courseId) != null)
                    {
                       objPr.Offered_By_School__c = map_Course.get(hc.courseId).Offered_By_School__c;
                       objPr.Credit_Hours__c = map_Course.get(hc.courseId).Credit_Hours__c;
                       objPr.Approval_Required_by_School_Head__c = map_Course.get(hc.courseId).Approval_Required_by_School_Head__c;
                    }
                    lstPr.add(objPr);
                }

                /************************ Open Elective ******************************/

                list<hed__Plan_Requirement__c> lstOeParent = new list<hed__Plan_Requirement__c>();
                //  list<openElectivewrap> opElect = new list<openElectivewrap>();
                //  if(lstOe != '[]'){
                //  opElect = (list<openElectivewrap>)JSON.deserialize(lstOe,list<openElectivewrap>.class);
                for(openElectivewrap objOe : lstOe){
                    hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();
                    objPr.id = objOe.recordId;
                    objPr.Name = objOe.Name;
                    objPr.hed__Category__c = 'Open Elective';
                    objPr.Credits__c = objOe.credits;
                    objPr.hed__Program_Plan__c = planId;
                    if(!string.isBlank(objOe.count)) objPr.Sequence__c = decimal.valueof(objOe.count);
                    objPr.Semester__c = objOe.termId;
                    if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                    if(!string.isBlank(verticalhead)) objPr.Vertical_Head__c = verticalhead;

                    lstOeParent.add(objPr);
                }
                //   }
                if(lstOeParent.size() > 0){
                    upsert lstOeParent;

                    map<string,string> mapParent = new map<string,string>();
                    for(hed__Plan_Requirement__c objPr : lstOeParent){
                        mapParent.put(objPr.Name,objPr.id);
                    }

                    for(openElectivewrap objOe : lstOe){
                        for(planLiwrap oe : objOe.lstPlanLi){
                            hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();
                            objPr.id = oe.recordId;
                            objPr.Name = 'test';
                            objPr.hed__Category__c = 'Open Elective';
                            objPr.hed__Course__c = oe.courseId;
                            objPr.Credits__c = oe.credits;
                            //  objPr.hed__Program_Plan__c = planId;
                            if(!string.isBlank(oe.count))  objPr.Sequence__c = decimal.valueof(oe.count);
                            objPr.Semester__c = oe.termId;
                            objPr.hed__Plan_Requirement__c = mapParent.get(objOe.Name);
                            if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                            if(!string.isBlank(verticalhead)) objPr.Vertical_Head__c = verticalhead;
                            if(map_Course.get(oe.courseId) != null)
                            {
                                objPr.Offered_By_School__c = map_Course.get(oe.courseId).Offered_By_School__c;
                                objPr.Credit_Hours__c = map_Course.get(oe.courseId).Credit_Hours__c;
                                objPr.Approval_Required_by_School_Head__c = map_Course.get(oe.courseId).Approval_Required_by_School_Head__c;
                            }
                            lstPr.add(objPr);
                        }
                    }
                }

               for(RbsSpclWrap objOe : lstSpcl){
                    for(planLiwrap oe : objOe.lstPlanLi){
                        hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();

                    if(oe.recordId !=null || oe.recordId !=''){
                        objPr.id = oe.recordId;
                    }else {
                        objPr.id = '';
                    }

                        objPr.Name = 'test';
                        objPr.hed__Category__c = 'RBS Specialization';
                        objPr.hed__Course__c = oe.courseId;
                        objPr.Specialization__c = objOe.parentId;
                        objPr.Credits__c = oe.credits;
                        objPr.hed__Program_Plan__c = planId;
                        if(!string.isBlank(oe.count))  {
                            objPr.Sequence__c = decimal.valueof(oe.count);
                        }
                        objPr.Semester__c = oe.termId;
                       // objPr.hed__Plan_Requirement__c = mapParent.get(objOe.Name);
                        if(!string.isBlank(schoolhead)) {
                            objPr.School_Head__c = schoolhead;
                        }
                        if(!string.isBlank(verticalhead)) {
                            objPr.Vertical_Head__c = verticalhead;
                        }
                        if(map_Course.get(oe.courseId) != null)
                        {
                            objPr.Offered_By_School__c = map_Course.get(oe.courseId).Offered_By_School__c;
                            objPr.Credit_Hours__c = map_Course.get(oe.courseId).Credit_Hours__c;
                            objPr.Approval_Required_by_School_Head__c = map_Course.get(oe.courseId).Approval_Required_by_School_Head__c;
                        }
                        lstPr.add(objPr);
                    }
                }

                /************************ Professional Elective ******************************/

                list<hed__Plan_Requirement__c> lstPeParent = new list<hed__Plan_Requirement__c>();
                //   list<profElectivewrap> proElect = new list<profElectivewrap>();
                //   if(lstPe != '[]'){
                //   proElect = (list<profElectivewrap>)JSON.deserialize(lstPe,list<profElectivewrap>.class);
                for(profElectivewrap objPe : lstPe){
                    hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();
                    objPr.id = objPe.recordId;
                    objPr.Name = objPe.Name;
                    objPr.hed__Category__c = 'Professional Elective';
                    objPr.Credits__c = objPe.credits;
                    objPr.hed__Program_Plan__c = planId;
                    if(!string.isBlank(objPe.count)) objPr.Sequence__c = decimal.valueof(objPe.count);
                    objPr.Semester__c = objPe.termId;
                    if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                    if(!string.isBlank(verticalhead)) objPr.Vertical_Head__c = verticalhead;
                    lstPeParent.add(objPr);
                }
                //   }
                if(lstPeParent.size() > 0){
                    upsert lstPeParent;

                    map<string,string> mapParent = new map<string,string>();
                    for(hed__Plan_Requirement__c objPr : lstPeParent){
                        mapParent.put(objPr.Name,objPr.id);
                    }

                    for(profElectivewrap objPe : lstPe){
                        for(planLiwrap pe : objPe.lstPlanLi){
                            hed__Plan_Requirement__c objPr = new hed__Plan_Requirement__c();
                            objPr.id = pe.recordId;
                            objPr.Name = 'test';
                            objPr.hed__Category__c = 'Professional Elective';
                            objPr.hed__Course__c = pe.courseId;
                            objPr.Credits__c = pe.credits;
                            //  objPr.hed__Program_Plan__c = planId;
                            if(!string.isBlank(pe.count)) objPr.Sequence__c = decimal.valueof(pe.count);
                            objPr.Semester__c = pe.termId;
                            objPr.hed__Plan_Requirement__c = mapParent.get(objPe.Name);
                            if(!string.isBlank(schoolhead)) objPr.School_Head__c = schoolhead;
                            if(!string.isBlank(verticalhead)) objPr.Vertical_Head__c = verticalhead;
                            if(map_Course.get(pe.courseId) != null)
                            {
                                objPr.Offered_By_School__c = map_Course.get(pe.courseId).Offered_By_School__c;
                                objPr.Credit_Hours__c = map_Course.get(pe.courseId).Credit_Hours__c;
                                objPr.Approval_Required_by_School_Head__c = map_Course.get(pe.courseId).Approval_Required_by_School_Head__c;
                            }
                            lstPr.add(objPr);
                        }
                    }
                }

                if(lstPr.size() > 0)
                {
                    //MSTR_PlanRequirementTrigger_Handler.RunSequence = true;
                    upsert lstPr;
                }

                if(deletedIds.size() > 0){
                    map<string,hed__Plan_Requirement__c> mapPr = new map<string,hed__Plan_Requirement__c>();
                    map<string,hed__Plan_Requirement__c> mapChild = new map<string,hed__Plan_Requirement__c>();
                    set<string> parentIds = new set<string>();
                    for(hed__Plan_Requirement__c pr : [SELECT id,hed__Category__c,hed__Plan_Requirement__c
                                                       FROM hed__Plan_Requirement__c WHERE id =: deletedIds]){



                                                           if(pr.hed__Category__c == 'Open Elective' || pr.hed__Category__c == 'Professional Elective'){

                                                               if(string.isBlank(pr.hed__Plan_Requirement__c)){
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
                        for(hed__Plan_Requirement__c pr : [SELECT id,hed__Category__c,hed__Plan_Requirement__c
                                                           FROM hed__Plan_Requirement__c WHERE hed__Plan_Requirement__c =: parentIds]){
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
                fTerm.lstTerm = queryPlanRequirementCount(planId);
            }
        }
        catch(Exception Ex){
            fTerm.errMsg = string.valueof(Ex);
        }
        return fTerm;
    }
     @AuraEnabled
    public static string getSchoolName(string AccschoolId)
    {
        Account objacc = [select id,Name from Account where id =:AccschoolId];
        return objacc.Name;
    }

    public class finalTermWrap{
        @AuraEnabled public string errMsg {get;set;}
        @AuraEnabled public list<termwrap> lstTerm {get;set;}
        public finalTermWrap(){
            lstTerm = new list<termwrap>();
        }
    }

    @AuraEnabled
    /**
     * @description Fetches the names of RBS Specializations.
     * @return A map where the key is the Account Id and the value is the Account Name.
     */
    public static Map<Id, String> fetchRBSSpecializationNames() {
        Map<Id, String> result = new Map<Id, String>();
        for (Account acc : [
            SELECT Id, Name
            FROM Account
            WHERE RecordType.DeveloperName = 'RBS_Specialization' WITH USER_MODE
        ]) {
            result.put(acc.Id, acc.Name);
        }
        return result;
    }

    public class termwrap{
        @AuraEnabled public string termId {get;set;}
        @AuraEnabled public string termName {get;set;}
        @AuraEnabled public boolean courseCreated {get;set;}
        @AuraEnabled public integer hardCoreCount {get;set;}
        @AuraEnabled public integer oElectiveCount {get;set;}
        @AuraEnabled public integer pElectiveCount {get;set;}
        @AuraEnabled public integer praticalCount {get;set;}
        @AuraEnabled public integer hcIntegratedCount {get;set;}
        @AuraEnabled public integer mandatoryCount {get;set;}
        @AuraEnabled public integer specializationCount {get;set;}
        @AuraEnabled public decimal totalCredit {get;set;}

        public termwrap(){
            hardCoreCount = 0;  oElectiveCount = 0; pElectiveCount = 0; praticalCount = 0;
            hcIntegratedCount = 0; mandatoryCount = 0; specializationCount = 0; totalCredit = 0;
        }
    }

    public class planRequirementwrap{

        @AuraEnabled public decimal totalCredit {get;set;}
        @AuraEnabled public list<planLiwrap> listHardCore {get;set;}
        @AuraEnabled public list<openElectivewrap> listOpenElective {get;set;}
        @AuraEnabled public list<profElectivewrap> listProfElective {get;set;}
        /**
         * @description Represents the list of RBS Specialization wrappers.
         */
        @AuraEnabled public list<RbsSpclWrap> lstSpcl {get;set;}
        @AuraEnabled public list<planLiwrap> listPractical {get;set;}
        @AuraEnabled public list<planLiwrap> listHcIntegrated {get;set;}
        @AuraEnabled public list<planLiwrap> listMandatory {get;set;}

        public planRequirementwrap(){
            listHardCore = new list<planLiwrap>();
            listOpenElective = new list<openElectivewrap>();
            listProfElective = new list<profElectivewrap>();
            lstSpcl = new list<RbsSpclWrap>();
            listPractical = new list<planLiwrap> ();
            listHcIntegrated = new list<planLiwrap>();
            listMandatory = new list<planLiwrap>();
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

    /**
     * @description Wrapper class for RBS Specialization.
     * Contains details about the specialization and its associated courses.
     */
    public class RbsSpclWrap{
        /**
         *  @description Represents the count of items or occurrences.
        */
        @AuraEnabled public string count {get;set;}

        /**
         * @description Represents the parent ID associated with the object.
         */
        @AuraEnabled public string parentId {get;set;}


        /**
         * @description Represents name of specalization.
         */
        @AuraEnabled public string name {get;set;}

        /**
         * @description Represents No of credits for rbs course
         */
        @AuraEnabled public decimal credits {get;set;}

         /**
         * @description Represents termId
         */
        @AuraEnabled public string termId {get;set;}

        /**
         * @description Represents list of child courses related to specalization
         */
        @AuraEnabled public list<planLiwrap> lstPlanLi {get;set;}

        /**
         * @description Represents recordId for Specl record
         */

        @AuraEnabled public string recordId {get;set;}


        /**
         * @description Constructor for the RbsSpclWrap class.
         * Initializes the list of plan line items.
         */
        public RbsSpclWrap(){
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