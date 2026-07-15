public class OE_AllocationCtr {
    
    @AuraEnabled
    public static MainCourseWrp  fetchOEOfferings(String i_TermNumber, boolean i_Engineering){
        MainCourseWrp w = new MainCourseWrp();system.debug(i_TermNumber);
        List<CourseListWrp> wrp = new List<CourseListWrp>();
        List<SemsList> lst_TermNumber = new List<SemsList>();
        Set<Id> set_OEIds = new Set<Id>();
        Set<String> set_TermNumber = new Set<String>();
        Set<String> set_CourseIds = new Set<String>();
        Map<String, Integer> mp_PrefCount = new Map<String, Integer>(); 
        //get all Course Offering of type OE Course-->category
        String query = 'SELECT Id,Name,Offered_By_School__r.Name, Offered_By_School__c,hed__Course__c,hed__Course__r.name,hed__Course__r.Max_Students__c,hed__Term__r.Term_Number__c  FROM hed__Course_Offering__c';
        query += ' WHERE Parent_Course_Offering__c != null  and  Course_Offering_Active__c  = true and Category__c = \'Open Elective\' and Offered_By_School__c != null and Semester_Record_Type__c = \'Semester\'';
        query += i_Engineering ? ' and hed__Term__r.Faculty__c = \'Faculty of Engineering & Technology\'' : ' and hed__Term__r.Faculty__c != \'Faculty of Engineering & Technology\'';
        query += String.IsNotBlank(i_TermNumber) && i_TermNumber != 'All' ? ' and hed__Term__r.Term_Number__c = ' + i_TermNumber   : '';
        query += ' order by hed__Course__c'; system.debug(query);
        for(hed__Course_Offering__c eachOE : Database.query(query)){
            set_OEIds.add(eachOE.Id);   
            if(!set_CourseIds.contains(eachOE.hed__Course__r.name)) {
                set_CourseIds.add(eachOE.hed__Course__r.name);
                wrp.add(new CourseListWrp(eachOE.hed__Course__r.name, eachOE.Offered_By_School__r.Name, eachOE.Name, eachOE.hed__Course__r.Max_Students__c, eachOE.hed__Course__c , String.valueof(eachOE.hed__Term__r.Term_Number__c)));
            }
        }
        for(AggregateResult ag : [SELECT Course_Offering__r.hed__Course__r.name courseId, count(Id) stuCount, Preference__c pref
                                  FROM Professor_Student_Course_Preference__c 
                                  WHERE Course_Offering__c in: set_OEIds 
                                  group by Course_Offering__r.hed__Course__r.name, Preference__c])
        {
            mp_PrefCount.put(ag.get('courseId') + '-'+ ag.get('pref'), Integer.valueof(ag.get('stuCount')) );
        }
        for(CourseListWrp eachwrp : wrp) {            
            if(!set_TermNumber.contains(eachwrp.semNum)){
                set_TermNumber.add(eachwrp.semNum);
                if(eachwrp.semNum != null) lst_TermNumber.add(new SemsList(eachwrp.semNum,eachwrp.semNum));
            } 
            eachWrp.pref1 = mp_PrefCount.get(eachWrp.courseName + '-'+ '1');
            eachWrp.pref2 = mp_PrefCount.get(eachWrp.courseName + '-'+ '2');
            eachWrp.pref3 = mp_PrefCount.get(eachWrp.courseName + '-'+ '3');
        }
        w.lst_SemsNumber = lst_TermNumber;
        w.lst_Course = wrp;
        return w;
    }
    
    @AuraEnabled
    public static List<AllOEStudentPrefWrp>  getStudentPrefBySubj(String i_TermNumber, boolean i_Engineering){
        List<AllOEStudentPrefWrp> w = new List<AllOEStudentPrefWrp> ();        
        List<StudentPrefListWrp> lst_Prfs = new List<StudentPrefListWrp>();
        List<StudentPrefListWrp> lst_unAllocatedPrfs = new List<StudentPrefListWrp>();
        Map<String, String> map_StuPref = new Map<String, String>();
        Set<String> set_CourseSem = new Set<String>();
        Set<Id> set_ContactsIds = new Set<Id>();
        Set<String> set_OENames = new Set<String>();
        Integer serialNumber = 0;
        Decimal selectedTerm = Decimal.valueof(i_TermNumber);
        String currentCourse;
        Id currentId;
        Integer count = 0;
        String query = 'SELECT Id,hed__Course__c,hed__Course__r.Max_Students__c,hed__Course__r.Name,hed__Course__r.hed__Course_ID__c,(SELECT Id,Contact__c,Course_Offering__r.Course_ID__c,Course_Offering__r.hed__Course__c,Is_Cource_Connection_Created__c,Contact__r.Name,Contact__r.SRN_Number__c,Semester__r.Name,Preference__c FROM Professor_Student_Course_prefernces__r  order by Createddate, Is_Cource_Connection_Created__c desc) ';
        query += ' FROM hed__Course_Offering__c WHERE Parent_Course_Offering__c != null and Course_Offering_Active__c  = true and Category__c = \'Open Elective\' and hed__Term__r.Term_Number__c =: selectedTerm and Semester_Record_Type__c = \'Semester\'';
        query += i_Engineering ? ' and hed__Term__r.Faculty__c = \'Faculty of Engineering & Technology\'' : ' and hed__Term__r.Faculty__c != \'Faculty of Engineering & Technology\'';
        query += ' order by hed__Course__c'; 
        List<hed__Course_Offering__c> lst_CourseOffering = Database.query(query);
        for(hed__Course_Offering__c eachOE : lst_CourseOffering){
            count += 1;           
            if(currentCourse == null) {
                currentCourse = eachOE.hed__Course__r.Name;
                currentId = eachOE.hed__Course__c; 
                set_CourseSem.add(eachOE.hed__Course__c);
            }
            if(currentCourse != eachOE.hed__Course__r.Name) {
                set_OENames.add(currentCourse);
                w.add(new AllOEStudentPrefWrp(currentId, currentCourse,lst_Prfs,set_CourseSem));
                currentCourse = eachOE.hed__Course__r.Name;
                currentId = eachOE.hed__Course__c;     
                 set_CourseSem = new Set<String>();
                
                lst_Prfs = new List<StudentPrefListWrp>();
                serialNumber = 0;
            }
            for(Professor_Student_Course_Preference__c eachPref :eachOE.Professor_Student_Course_prefernces__r){   
                if(eachPref.Preference__c == '1') {
                    set_ContactsIds.add(eachPref.Contact__c);
                    
                    if(lst_Prfs.size() < eachOE.hed__Course__r.Max_Students__c || eachPref.Is_Cource_Connection_Created__c){
                        serialNumber += 1; 
                        lst_Prfs.add(new StudentPrefListWrp(false, eachPref.Is_Cource_Connection_Created__c, eachPref.Id,eachPref.Contact__c, serialNumber, eachPref.Contact__r.Name, eachPref.Contact__r.SRN_Number__c, eachPref.Semester__r.Name,eachOE.hed__Course__c ));
                    }
                    else {
                        lst_unAllocatedPrfs.add(new StudentPrefListWrp(true, eachPref.Is_Cource_Connection_Created__c, eachPref.Id,eachPref.Contact__c, serialNumber, eachPref.Contact__r.Name, eachPref.Contact__r.SRN_Number__c, eachPref.Semester__r.Name, eachOE.hed__Course__c ));
                    }                    
                }
                map_StuPref.put(eachPref.Contact__c + '-' + eachPref.Preference__c, eachPref.Course_Offering__r.Course_ID__c);
            } 
            set_CourseSem.add(eachOE.hed__Course__c);
            if(count == lst_CourseOffering.size()) {
                set_OENames.add( eachOE.hed__Course__r.Name);
                w.add(new AllOEStudentPrefWrp(currentId, currentCourse,lst_Prfs, set_CourseSem));
                set_CourseSem = new Set<String>();
                lst_Prfs = new List<StudentPrefListWrp>();
                serialNumber = 0;
            }
        }
        
        //No Preference from Students    
        String facquery  = 'SELECT ID,hed__Contact__r.Name,Semester__r.Name, hed__Contact__r.SRN_Number__c  FROM hed__Program_Enrollment__c WHERE  hed__Contact__c NOT IN: set_ContactsIds and Semester__r.Term_Number__c =: selectedTerm  ';
        facquery += i_Engineering ? ' and Semester__r.Faculty__c = \'Faculty of Engineering & Technology\'' :  ' and Semester__r.Faculty__c != \'Faculty of Engineering & Technology\'';
        
        for(hed__Program_Enrollment__c eachEnroll : Database.query(facquery)){
            serialNumber += 1;
            lst_Prfs.add(new StudentPrefListWrp(true, false, null,eachEnroll.hed__Contact__c, serialNumber, eachEnroll.hed__Contact__r.Name, eachEnroll.hed__Contact__r.SRN_Number__c, eachEnroll.Semester__r.Name, null ));
        }
        w.add(new AllOEStudentPrefWrp('Unallocated', 'Unallocated  With Preference',lst_unAllocatedPrfs, null));        
        w.add(new AllOEStudentPrefWrp('Unallocated', 'Unallocated  Without Preference',lst_Prfs, null));
        set_OENames.add( 'Unallocated  With Preference');
        
        for(AllOEStudentPrefWrp eachW : w) {
            List<EachOEoptionWrp> opt = new List<EachOEoptionWrp>();
            Integer cnt = 0;
            for(string nam : set_OENames){  
                if(nam != eachW.courseName) {
                    opt.add(new EachOEoptionWrp(String.valueof(cnt),nam));
                    
                }
                cnt += 1;
            }
            
            for(StudentPrefListWrp stu : eachW.lst_StuPref) {
                if(map_StuPref.get(stu.conId+'-'+'1') != null)
                    stu.Pref1 = map_StuPref.get(stu.conId+'-'+'1');
                if(map_StuPref.get(stu.conId+'-'+'2') != null)
                    stu.Pref2 = map_StuPref.get(stu.conId+'-'+'2');
                if(map_StuPref.get(stu.conId+'-'+'3') != null)
                    stu.Pref3 = map_StuPref.get(stu.conId+'-'+'3');
            }
            eachW.lst_options = opt;
        }
        return w;
    }    
    
    @AuraEnabled
    public static String saveCourseConnection(String  i_Students){
         Id stuRecordTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<hed__Course_Enrollment__c> lst_ConnToCreate = new List<hed__Course_Enrollment__c>();
        List<Professor_Student_Course_Preference__c> lst_PrefsToUpdate = new List<Professor_Student_Course_Preference__c>();
        String statusVal;        
        Map<Id, Id> mp_SemCon = new Map<Id, Id>();
        Map<Id, Id> mp_ConPro = new Map<Id, Id>();
        Map<String, Id> mp_CourseSem = new Map<String, Id>();
        Set<Id> set_StuIds = new Set<Id>();
        Set<String> set_CourseId = new Set<String>();
        
        List<AllOEStudentPrefWrp> lst_Stus = (List<AllOEStudentPrefWrp>) System.JSON.deserialize(i_Students, List<AllOEStudentPrefWrp>.class);
        for(AllOEStudentPrefWrp eachWrp : lst_Stus) {
            if(eachWrp.courseId != 'Unallocated') {
                if(eachWrp.set_CourseSem != null) set_CourseId.addall(eachWrp.set_CourseSem);
                for(StudentPrefListWrp stu : eachWrp.lst_StuPref) {
                    set_StuIds.add(stu.conId);
                    if(stu.prefId != null) lst_PrefsToUpdate.add(new Professor_Student_Course_Preference__c(Id=stu.prefId, Is_Cource_Connection_Created__c=true));
                }                
            }
        }
        if(set_StuIds.size() > 0 ) {
            for(hed__Program_Enrollment__c en : [SELECT Id,Semester__c,hed__Contact__c  FROM hed__Program_Enrollment__c WHERE Active__c = true and hed__Contact__c IN: set_StuIds]){
                mp_SemCon.put(en.hed__Contact__c, en.Semester__c);
                mp_ConPro.put(en.hed__Contact__c, en.Id);
            }
            for(hed__Course_Offering__c off : [SELECT Id, hed__Course__c,hed__Term__c FROM hed__Course_Offering__c WHERE hed__Term__c IN: mp_SemCon.values() and Course_Offering_Active__c  = true and hed__Course__c IN: set_CourseId and Semester_Record_Type__c = 'Semester']){
                mp_CourseSem.put(off.hed__Term__c+'-'+ off.hed__Course__c , off.Id);
                system.debug(off.hed__Term__c+'-'+ off.hed__Course__c);
            }
        }
        for(AllOEStudentPrefWrp eachWrp : lst_Stus) {
            if(eachWrp.courseId != 'Unallocated') {
                for(StudentPrefListWrp stu : eachWrp.lst_StuPref) {
                    if(!stu.hideInput){
                        Id courseId;
                        if(mp_SemCon.get(stu.conId) != null) {
                            system.debug(eachWrp.set_CourseSem);
                            system.debug(mp_SemCon.get(stu.conId));
                            
                            for(String eachCor : eachWrp.set_CourseSem) {
                                system.debug(mp_SemCon.get(stu.conId) +'-'+ eachCor);
                                system.debug(mp_CourseSem.get(mp_SemCon.get(stu.conId) +'-'+ eachCor));
                                if(courseId == null) courseId = mp_CourseSem.get(mp_SemCon.get(stu.conId) +'-'+ eachCor);
                            }
                        }
                        lst_ConnToCreate.add(new hed__Course_Enrollment__c(RecordTypeId= stuRecordTypeId,hed__Contact__c = stu.conId, 
                                                                           hed__Program_Enrollment__c = mp_ConPro.get(stu.conId),
                                                                           hed__Course_Offering__c = courseId,
                                                                           Section__c = mp_SemCon.get(stu.conId)));
                    }
                }
            }
        }
        insert lst_ConnToCreate;
        if(lst_PrefsToUpdate.size() > 0 ) update lst_PrefsToUpdate;    
        
        return 'success';
    }
    
    
    @AuraEnabled
    public static MainTermWrp  fetchexistingTerms(String i_Course,String i_TermNumber){	
        MainTermWrp mainWrp = new MainTermWrp();
        List<TermWrp> w = new List<TermWrp>();
        Set<Id> set_SemIds = new Set<Id>();
        Set<Id> set_off = new Set<Id>();
        Integer totalStu  = 0;
        Decimal termNum = Decimal.valueof(i_TermNumber);
        //get all offering
        for(hed__Course_Offering__c eachOff :[SELECT Id,Name,Offered_By_School__r.Name, Offered_By_School__c,hed__Course__c,hed__Course__r.Max_Students__c,
                                              hed__Term__r.Term_Number__c,hed__Term__c                                             
                                              FROM hed__Course_Offering__c
                                              WHERE Course_Offering_Active__c  = true and Semester_Record_Type__c = 'Semester' and 
                                              Category__c = 'Open Elective' and hed__Course__r.Name =: i_Course and hed__Term__r.Term_Number__c =: termNum])
            
        {
            set_off.add(eachOff.Id);
            set_SemIds.add(eachOff.hed__Term__c); 
            if(mainWrp.maxPerGroup == null) mainWrp.maxPerGroup = Integer.valueof(eachOff.hed__Course__r.Max_Students__c);
        }
        
        system.debug(set_SemIds);
        Map<String, Integer> mp_Groups = new Map<String,Integer>();
        mp_Groups.put('UnAllocated', 0);
        for(hed__Term__c eachTerm : [SELECT Name, CreatedDate,Recordtype.DeveloperName,
                                     (SELECT Id,hed__Contact__r.Name, hed__Contact__c,Program__c, hed__Contact__r.SRN_Number__c FROM Course_Connections__r WHERE hed__Course_Offering__c in: set_off and RecordType.Name ='Student')
                                     FROM hed__Term__c 
                                     WHERE Id in: set_SemIds or ( Course_Offering__c in: set_off and hed__Parent_Term__c in: set_SemIds)])
        {
            if(eachTerm.Course_Connections__r != null) totalStu += eachTerm.Course_Connections__r.size();
            if(eachTerm.Recordtype.DeveloperName == 'Group_Allocation'){
                Integer count = 0;
                if(eachTerm.Course_Connections__r != null) count = eachTerm.Course_Connections__r.size();
                if(mp_Groups.get(eachTerm.Name) == null) mp_Groups.put(eachTerm.Name, 0);
                count = eachTerm.Course_Connections__r != null ? mp_Groups.get(eachTerm.Name) + eachTerm.Course_Connections__r.size() : mp_Groups.get(eachTerm.Name);
                mp_Groups.put(eachTerm.Name, count);                
            }
            else {
                Integer count = 0;
                count = eachTerm.Course_Connections__r != null  ? mp_Groups.get('UnAllocated') + eachTerm.Course_Connections__r.size() : mp_Groups.get('UnAllocated');
                mp_Groups.put('UnAllocated', count);                
            }
            
        }
        for(String key : mp_Groups.keyset()){
            w.add(new TermWrp(key, null, mp_Groups.get(key)));
        }
        mainWrp.enrolledStudents = totalStu; 
        system.debug(w.size());
        mainWrp.lst_Term = w;
        return mainWrp;
    }
    
    @AuraEnabled
    public static MainTermWrp  createTermGroups(String i_Course, Integer i_Count, String i_TermNumber){
        List<hed__Term__c> lst_TermToCreate = new List<hed__Term__c>();
        Integer count = 0;
        String groupChar = 'A';
        Decimal termNum = Decimal.valueof(i_TermNumber);
        Id devRecordTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByDeveloperName().get('Group_Allocation').getRecordTypeId();
        
        for(hed__Course_Offering__c eachOff :[SELECT Id,Name,Offered_By_School__r.Name, Offered_By_School__c,hed__Course__c,hed__Course__r.Max_Students__c,hed__Course__r.Name,
                                              hed__Term__r.Term_Number__c,hed__Term__c,hed__Term__r.Program_Batch__r.hed__Account__c                                          
                                              FROM hed__Course_Offering__c
                                              WHERE Course_Offering_Active__c  = true and  hed__Term__r.Term_Number__c =: termNum and
                                              Category__c = 'Open Elective' and hed__Course__r.Name =: i_Course and Semester_Record_Type__c = 'Semester'
                                              order by hed__Course__c])
        {
            groupChar = 'A';
            for(Integer i = 1; i <= i_Count;i++) {
                lst_TermToCreate.add(new hed__Term__c(Course_Offering__c = eachOff.Id,
                                                      hed__Account__c = eachOff.hed__Term__r.Program_Batch__r.hed__Account__c ,
                                                      Group_Number__c = i,
                                                      Name =eachOff.hed__Course__r.Name +'-'+  groupChar,
                                                      RecordTypeId = devRecordTypeId,
                                                      hed__Parent_Term__c = eachOff.hed__Term__c));
                groupChar = getNextChar(groupChar);
            }            
            
        }
        if(lst_TermToCreate.size() > 0) insert lst_TermToCreate;
        return fetchexistingTerms(i_Course,i_TermNumber);
    }
    
    
    @AuraEnabled
    public static MainTermWrp  deleteGroupCtr(String i_Course,String i_TermNumber, String i_SelectedGroup){	
        List<hed__Course_Enrollment__c> lst_EnrollToUpdate = new List<hed__Course_Enrollment__c>();
        List<hed__Term__c> lst_ToDeleteGroup = new List<hed__Term__c>();
        Set<Id> set_SemIds = new Set<Id>();        
        Set<Id> set_off = new Set<Id>();        
        Decimal termNum = Decimal.valueof(i_TermNumber);
        
        //get all offering
        for(hed__Course_Offering__c eachOff :[SELECT Id,Name,Offered_By_School__r.Name, Offered_By_School__c,hed__Course__c,hed__Course__r.Max_Students__c,
                                              hed__Term__r.Term_Number__c,hed__Term__c                                             
                                              FROM hed__Course_Offering__c
                                              WHERE Course_Offering_Active__c  = true and Semester_Record_Type__c = 'Semester' and 
                                              Category__c = 'Open Elective' and hed__Course__r.Name =: i_Course and hed__Term__r.Term_Number__c =: termNum])
            
        {
            set_off.add(eachOff.Id);
            set_SemIds.add(eachOff.hed__Term__c); 
        }
        for(hed__Term__c eachTerm : [SELECT Name, CreatedDate,Recordtype.DeveloperName,hed__Parent_Term__c,
                                     (SELECT Id,hed__Contact__r.Name, hed__Contact__c,Program__c, hed__Contact__r.SRN_Number__c FROM Course_Connections__r WHERE hed__Course_Offering__c in: set_off)
                                     FROM hed__Term__c 
                                     WHERE  Course_Offering__c in: set_off and hed__Parent_Term__c in: set_SemIds and Name =: i_SelectedGroup])
        {
            for(hed__Course_Enrollment__c eachConn : eachTerm.Course_Connections__r) {               
                lst_EnrollToUpdate.add(new hed__Course_Enrollment__c(Id = eachConn.Id, Section__c = eachTerm.hed__Parent_Term__c));
            }
            lst_ToDeleteGroup.add(new hed__Term__c(Id=eachTerm.Id));
        }
        if(lst_EnrollToUpdate.size() > 0 ) update lst_EnrollToUpdate;
        if(lst_ToDeleteGroup.size() > 0 ) delete lst_ToDeleteGroup;
        return fetchexistingTerms(i_Course, i_TermNumber);
    }
    
    
    
    @AuraEnabled
    public static List<AllOEStudentPrefWrp>  fetchConnectionGroups(String i_Course, String i_TermNumber, Integer i_groupCount){	
        List<AllOEStudentPrefWrp> w = new List<AllOEStudentPrefWrp> ();        
        List<StudentPrefListWrp> lst_Prfs = new List<StudentPrefListWrp>();
        Set<Id> set_SemIds = new Set<Id>();
        Set<String> set_OENames = new Set<String>();
        Map<String, Integer> mp_OEIndex = new Map<String, Integer>();
        Set<Id> set_off = new Set<Id>();
        //get all offerin
        //get all offering
        String termName = '';
        Decimal termNum = Decimal.valueof(i_TermNumber);
        Map<String, List<StudentPrefListWrp>> mp_Prfs = new Map<String, List<StudentPrefListWrp>>();
        for(hed__Course_Offering__c eachOff :[SELECT Id,Name,Offered_By_School__r.Name, Offered_By_School__c,hed__Course__c,hed__Course__r.Max_Students__c,
                                              hed__Term__r.Term_Number__c,hed__Term__c                                             
                                               FROM hed__Course_Offering__c
                                              WHERE Course_Offering_Active__c  = true and Semester_Record_Type__c = 'Semester' and 
                                              Category__c = 'Open Elective' and hed__Course__r.Name =: i_Course and hed__Term__r.Term_Number__c =: termNum])
            
        {
            set_off.add(eachOff.Id);
            set_SemIds.add(eachOff.hed__Term__c); 
        }
        Map<String, Id> mp_TermMap = new Map<String, Id>();
      	Set<String> set_Terms = new Set<String>();
        for(hed__Term__c eachTerm : [SELECT id, Name,Recordtype.DeveloperName, Course_Offering__c,hed__Parent_Term__c FROM hed__Term__c
                                    WHERE (Id in: set_SemIds or hed__Parent_Term__c in: set_SemIds) and Course_Offering__r.hed__Course__r.Name=:i_Course ]) 
        {
            String tName = eachTerm.RecordType.DeveloperName == 'Group_Allocation' ? eachTerm.Name : 'Unallocated';
            set_Terms.add(tName);
            set_OENames.add(tName);
        }
        
        for(hed__Course_Enrollment__c eachEnroll : [SELECT Id,Section__c,Section__r.Name, Section__r.CreatedDate,Section__r.Recordtype.DeveloperName,Section__r.hed__Parent_Term__c,
                                                    hed__Contact__r.Name, hed__Contact__c,Program__c, hed__Contact__r.SRN_Number__c 
                                                    FROM 
                                                    	hed__Course_Enrollment__c 
                                                    WHERE 
                                                        hed__Course_Offering__c in: set_off and (Section__c in: set_SemIds or 
                                                        Section__r.hed__Parent_Term__c in: set_SemIds) and RecordType.Name = 'Student'
                                                    order by  hed__Contact__r.SRN_Number__c DESC
                                                   ])
        {
            Id parentTermId = eachEnroll.Section__r.RecordType.DeveloperName == 'Group_Allocation' ? eachEnroll.Section__r.hed__Parent_Term__c : eachEnroll.Section__c;
            termName = eachEnroll.Section__r.RecordType.DeveloperName == 'Group_Allocation' ? eachEnroll.Section__r.Name : 'Unallocated';
            set_OENames.add(termName);
            mp_TermMap.put(termName,parentTermId);              
            StudentPrefListWrp stuRec = new StudentPrefListWrp(false,parentTermId, eachEnroll.Id,eachEnroll.hed__Contact__c, null, eachEnroll.hed__Contact__r.Name, eachEnroll.hed__Contact__r.SRN_Number__c, eachEnroll.Section__r.Name);
            if(mp_Prfs.get(termName) == null) {
                mp_Prfs.put(termName, new List<StudentPrefListWrp>());
            }
            mp_Prfs.get(termName).add(stuRec);            
        }  
        
        List<StudentPrefListWrp> lst_AllUnAllocated = new  List<StudentPrefListWrp>();
        if(mp_Prfs.get('Unallocated') != null ) lst_AllUnAllocated = mp_Prfs.get('Unallocated');
        Integer indexVal = 0;
        for(String key : set_Terms) {  
            if(mp_Prfs.get(key) == null || mp_Prfs.get(key).size() == 0){
                List<StudentPrefListWrp> lst_Temp = new List<StudentPrefListWrp>();
                for (Integer i = (lst_AllUnAllocated.size()-1) ; i>= 0 ; i--){
                    if(lst_Temp.size() < i_groupCount) {
                        lst_Temp.add(lst_AllUnAllocated[i]);                    
                        lst_AllUnAllocated.remove(i);
                    }
                }
                if(key != 'Unallocated')  {          
                    w.add(new AllOEStudentPrefWrp(mp_TermMap.get(key), key, lst_Temp, null));
                    mp_OEIndex.put(key, indexVal);
                    indexVal++;
                }
            }
            else if(key != 'Unallocated') {
                w.add(new AllOEStudentPrefWrp(mp_TermMap.get(key), key, mp_Prfs.get(key), null));
                mp_OEIndex.put(key, indexVal);
                indexVal++;
            } 
        }
        if(lst_AllUnAllocated.size() > 0 ) {
            w.add(new AllOEStudentPrefWrp('Unallocated', 'Unallocated',lst_AllUnAllocated , null));
            mp_OEIndex.put('Unallocated', indexVal);
        }
        
        
        set_OENames.add( 'Unallocated'); 
        for(AllOEStudentPrefWrp eachW : w) {
            List<EachOEoptionWrp> opt = new List<EachOEoptionWrp>();
            Integer cnt = 0;
            for(string nam : set_OENames){  
                if(nam != eachW.courseName) {
                    opt.add(new EachOEoptionWrp(String.valueof(mp_OEIndex.get(nam)),nam));
                    
                }
                cnt += 1;
            }
            eachW.lst_options = opt;
        }
        return w;
    }
    
    
    @AuraEnabled
    public static String saveGroupChangeConnection(String  i_Students, String i_Course){
        List<hed__Course_Enrollment__c> lst_ConnToCreate = new List<hed__Course_Enrollment__c>();
        List<Professor_Student_Course_Preference__c> lst_PrefsToUpdate = new List<Professor_Student_Course_Preference__c>();
        String statusVal;        
        Map<Id, Id> mp_SemCon = new Map<Id, Id>();
        Map<String, Id> mp_StuSem = new Map<String, Id>();
        Map<String, Id> mp_CourseSem = new Map<String, Id>();
        Set<Id> set_TermIds = new Set<Id>();
        Set<Id> set_CourseId = new Set<Id>();
        Set<Id> set_StuIds = new Set<Id>();
        
        List<AllOEStudentPrefWrp> lst_Stus = (List<AllOEStudentPrefWrp>) System.JSON.deserialize(i_Students, List<AllOEStudentPrefWrp>.class);
        
        for(AllOEStudentPrefWrp eachWrp : lst_Stus) {           
            for(StudentPrefListWrp stu : eachWrp.lst_StuPref) {
                set_TermIds.add(stu.termId);               
            }         
        }
        
        if(set_TermIds.size() > 0 ) {
            for(hed__Term__c term : [SELECT Id, Name,hed__Parent_Term__c FROM hed__Term__c WHERE hed__Parent_Term__c IN: set_TermIds]){
                mp_StuSem.put(term.hed__Parent_Term__c+'-'+ term.Name , term.Id);
                system.debug(term.hed__Parent_Term__c+'-'+ term.Name);
            }
        }
        String secId;
        for(AllOEStudentPrefWrp eachWrp : lst_Stus) {
            for(StudentPrefListWrp stu : eachWrp.lst_StuPref) {  
                system.debug(eachWrp.courseName);
                system.debug(mp_StuSem.get(eachWrp.courseId  +'-'+eachWrp.courseName));
                secId = eachWrp.courseName == 'Unallocated' ? stu.termId : mp_StuSem.get(stu.termId  +'-'+eachWrp.courseName);
                system.debug(mp_StuSem.get(eachWrp.courseId  +'-'+eachWrp.courseName));
                lst_ConnToCreate.add(new hed__Course_Enrollment__c(Id=stu.connectionId, 
                                                                   Section__c= secId));
            }                
            
        }
        if(lst_ConnToCreate.size() > 0 ) update lst_ConnToCreate; 
        return 'success';
    }
    
    public static String getNextChar(String oldChar) {
        String key = 'ABCDEFGHIJKLMNOPQRSTUVWXYZAabcdefghijklmnopqrstuvwxyza';
        Integer index = key.indexOfChar(oldChar.charAt(0));
        return index == -1? null: key.substring(index+1, index+2);
    } 
    
    
    public class MainCourseWrp{
        @AuraEnabled public List<CourseListWrp> lst_Course {get;set;}
        @AuraEnabled public List<SemsList> lst_SemsNumber {get;set;}        
    }
    
    public class MainTermWrp{
        @AuraEnabled public List<TermWrp> lst_Term {get;set;}
        @AuraEnabled public Integer maxPerGroup {get;set;} 
        @AuraEnabled public Integer enrolledStudents {get;set;}          
    } 
    public class TermWrp{
        @AuraEnabled public String termName {get;set;}
        @AuraEnabled public Integer noEnrolled {get;set;}  
        @AuraEnabled public String CreatedBy {get;set;}         
        public TermWrp(String termName, String CreatedBy, Integer noEnrolled) {
            this.termName = termName;
            this.CreatedBy = CreatedBy;
            this.noEnrolled = noEnrolled;
        }
    } 
    
    public class CourseListWrp{
        @AuraEnabled public String school {get;set;}
        @AuraEnabled public String subjName {get;set;} 
        @AuraEnabled public Decimal maxStudents {get;set;} 
        @AuraEnabled public Integer pref1 {get;set;} 
        @AuraEnabled public Integer pref2 {get;set;} 
        @AuraEnabled public Integer pref3 {get;set;} 
        @AuraEnabled public String courseName {get;set;} 
        @AuraEnabled public String courseId {get;set;} 
        @AuraEnabled public String semNum {get;set;} 
        public CourseListWrp(String courseName, String school, String subjName, Decimal maxStudents,String courseId, String semNum){
            this.school = school;
            this.courseName = courseName;
            this.subjName = subjName;
            this.maxStudents = maxStudents;
            this.courseId = courseId;
            this.semNum = semNum;            
        }
    }
    
    public class AllOEStudentPrefWrp {
        @AuraEnabled public String courseId {get;set;}
        @AuraEnabled public String courseName {get;set;}
        @AuraEnabled public Set<String>  set_CourseSem {get;set;}
        @AuraEnabled public List<StudentPrefListWrp> lst_StuPref {get;set;}   
        @AuraEnabled public List<EachOEoptionWrp> lst_options {get;set;}   
        public AllOEStudentPrefWrp(String  courseId,String courseName, List<StudentPrefListWrp> lst_StuPref, Set<String>  set_CourseSem){
            this.courseId = courseId;
            this.courseName = courseName;
            this.lst_StuPref = lst_StuPref;
            this.lst_options = new List<EachOEoptionWrp> ();
            this.set_CourseSem = new Set<String>();
            this.set_CourseSem  = set_CourseSem;
        }        
    }
    
    public class EachOEoptionWrp {
        @AuraEnabled public String key {get;set;}
        @AuraEnabled public String value {get;set;}
        public EachOEoptionWrp(String key, String value) {
            this.key = key;
            this.value = value;
        }
    }
    public class StudentPrefListWrp{
        @AuraEnabled public boolean isSelected {get;set;}
        @AuraEnabled public boolean hideInput {get;set;}
        @AuraEnabled public Id prefId {get;set;}
        @AuraEnabled public String pref1 {get;set;}
        @AuraEnabled public String pref2 {get;set;}
        @AuraEnabled public String pref3 {get;set;}
        @AuraEnabled public Id termId {get;set;}
        @AuraEnabled public String connectionId {get;set;}
        @AuraEnabled public Id conId {get;set;}
        @AuraEnabled public Integer sNo {get;set;}
        @AuraEnabled public String studentName {get;set;}
        @AuraEnabled public String srnNumber {get;set;} 
        @AuraEnabled public String sectionName {get;set;} 
        @AuraEnabled public String courseIdPref {get;set;} 
        public StudentPrefListWrp(boolean isSelected,boolean hideInput, Id prefId, Id conId, Integer sNo, String studentName, String srnNumber, String sectionName, String courseIdPref){
            this.isSelected = isSelected;
            this.hideInput = hideInput;
            this.prefId = prefId;
            this.conId =conId;
            this.sNo = sNo;
            this.studentName = studentName;
            this.srnNumber = srnNumber;
            this.sectionName = sectionName;
            this.courseIdPref = courseIdPref;
        }
        public StudentPrefListWrp(boolean isSelected,Id termId,String connectionId, Id conId, Integer sNo, String studentName, String srnNumber, String sectionName){
            this.isSelected = isSelected;
            this.termId = termId;
            this.connectionId = connectionId;
            this.conId =conId;
            this.sNo = sNo;
            this.studentName = studentName;
            this.srnNumber = srnNumber;
            this.sectionName = sectionName;
        }
    }
    
    public class SemsList{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        public SemsList(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}