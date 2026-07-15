public class MM_TermTriggerHandler{
    
    public static void mentorMapping(list<hed__Term__c> lstTerm,map<id,hed__Term__c> oldMap){
        
        set<string> termIds = new set<string>();
        string rtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        string ccRtId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get('Student Section').getRecordTypeId();
        string caseRtMentorId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mentor').getRecordTypeId();
        string caseRtMenteeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mentee').getRecordTypeId();

        set<id> contactIds = new set<id>();
        
        for(hed__Term__c objTerm : lstTerm){
            if(objTerm.Confirm_Mentor_Mapping__c && objTerm.Confirm_Mentor_Mapping__c != oldMap.get(objTerm.id).Confirm_Mentor_Mapping__c && 
               objTerm.recordTypeId ==  rtId){
                   
                   termIds.add(objTerm.id);
                   
               }
        }
        List<hed__Term__c> termList = new List<hed__Term__c>();
        for(hed__Term__c objTermq : [SELECT id,(SELECT id,Program_Enrollment__c,Program_Enrollment__r.hed__Contact__c,Section__c,Program_Enrollment__r.hed__Contact__r.SRN_Number__c FROM Student_Term_Mappings1__r 
                                                WHERE recordTypeId =: ccRtId ORDER By Program_Enrollment__r.hed__Contact__r.Name ASC),
                                     (SELECT id,Contacts__c,Semester_Section__c FROM Faculties_Assigned__r) FROM hed__Term__c WHERE id =: termIds]){
                                         termList.add(objTermq);
                                         for(Student_Semester_Mapping__c objCc : objTermq.Student_Term_Mappings1__r){
                                             contactIds.add(objCc.Program_Enrollment__r.hed__Contact__c);   
                                         }
                                         for(Professors_Assigned__c objFaculty : objTermq.Faculties_Assigned__r){
                                             contactIds.add(objFaculty.Contacts__c);
                                         }
                                         system.debug('contactIds '+ contactIds);
                                         Map<id,id> mapconUserIds = new Map<id,id>();
                                         if(!contactIds.isempty()){
                                             List<user> users = [SELECT Id,ContactId FROM User WHERE contactId =: contactIds];
                                             system.debug('users '+users);
                                             for(user u:users){
                                                 mapconUserIds.put(u.contactId,u.Id);
                                             }
                                         }
                                         system.debug('mapconUserIds '+ mapconUserIds);
                                         if(termIds.size() > 0){
                                             
                                             list<hed__Term__c> lstBatchTerm = new list<hed__Term__c>();
                                             map<string,case> studentCase = new map<string,case>();
                                             map<string,case> FacultyCase = new map<string,case>();
                                             map<string,list<Student_Semester_Mapping__c>> mapStudent = new map<string,list<Student_Semester_Mapping__c>>();
                                             
                                             for(hed__Term__c objTerm : termList){
                                                 
                                                 //lstBatchTerm.add(objTerm);
                                                 
                                                 for(Student_Semester_Mapping__c objCc : objTerm.Student_Term_Mappings1__r){
                                                     
                                                     
                                                     string temp = objTerm.id + '-' + objCc.Program_Enrollment__r.hed__Contact__c;
                                                     
                                                     case objCase = new case();
                                                     objCase.RecordTypeId = caseRtMenteeId;
                                                     objCase.ContactId = objCc.Program_Enrollment__r.hed__Contact__c;
                                                     objCase.Subject = 'Mentor Allocated';
                                                     objCase.Status = 'Queued';
                                                     objCase.Origin = 'Email';
                                                     if(mapconUserIds.containskey(objCc.Program_Enrollment__r.hed__Contact__c)){
                                                         objCase.OwnerId = mapconUserIds.get(objCc.Program_Enrollment__r.hed__Contact__c);
                                                     }
                                                     studentCase.put(temp,objCase);
                                                     
                                                     if(mapStudent.containsKey(objTerm.id)){
                                                         mapStudent.get(objTerm.id).add(objCc);
                                                     }
                                                     else{
                                                         mapStudent.put(objTerm.id,new list<Student_Semester_Mapping__c>{objCc});
                                                     }
                                                 }
                                                 
                                                 for(Professors_Assigned__c objFaculty : objTerm.Faculties_Assigned__r){
                                                     
                                                     string temp = objTerm.id + '-' + objFaculty.Contacts__c;
                                                     case objCase = new case();                                                   
                                                     objCase.RecordTypeId = caseRtMentorId;
                                                     objCase.ContactId = objFaculty.Contacts__c;
                                                     objCase.Subject = 'Student Allocation';
                                                     objCase.Status = 'Queued';
                                                     objCase.Origin = 'Email';
                                                     if(mapconUserIds.containskey(objFaculty.Contacts__c)){
                                                         obJCase.OwnerId = mapconUserIds.get(objFaculty.Contacts__c);
                                                     }
                                                     FacultyCase.put(temp,objCase);
                                                 }
                                             }
                                             
                                             
                                             
                                             if(studentCase.values().size() > 0 && FacultyCase.values().size() > 0){
                                                 
                                                 system.debug('++++++++++++++'+studentCase.values().size());
                                                 system.debug('++++++++++++++'+FacultyCase.values().size());
                                                 insert studentCase.values();
                                                 insert FacultyCase.values();
                                                 system.debug('++++++++++++++'+studentCase.values());
                                                 system.debug('++++++++++++++'+FacultyCase.values());
                                                 CaseTeamRole role = [select Id from CaseTeamRole where Name = : 'Student Member' limit 1];
                                                 list<CaseTeamMember> listCaseMember = new list<CaseTeamMember>();
                                                 
                                                 for(hed__Term__c objTerm : termList){
                                                     // integer studentSize = objTerm.Course_Connections__r.size();
                                                     integer studentSize = mapStudent.get(objTerm.id).size();
                                                     integer facultySize = objTerm.Faculties_Assigned__r.size();
                                                     system.debug('++++++++++++++'+studentSize);
                                                     system.debug('++++++++++++++'+facultySize);
                                                     map<integer,integer> mapCount = new map<integer,integer>();
                                                     if(studentSize > 0 && facultySize > 0){
                                                         integer reminder = math.mod(studentSize,facultySize);
                                                         double divisionValue = studentSize/facultySize;
                                                         system.debug('++++++++++++++'+divisionValue);
                                                         system.debug('++++++++++++++'+reminder);
                                                         integer count = 0;
                                                         
                                                         for(Professors_Assigned__c objFaculty : objTerm.Faculties_Assigned__r){
                                                             
                                                             integer recordSize = count + integer.valueof(divisionValue);
                                                             if(reminder > 0){
                                                                 recordSize = recordSize + 1;
                                                                 reminder = reminder - 1;
                                                             }                                   
                                                             string temp = objTerm.id + '-' + objFaculty.Contacts__c;
                                                             // integer count = 0;
                                                             system.debug('++++++++++++++'+count);
                                                             
                                                             system.debug('++++++++++++++'+recordSize);
                                                             system.debug('++++++++++++++'+reminder);
                                                             // for(Student_Semester_Mapping__c objCc : mapStudent.get(objTerm.id)){
                                                             for(integer i = count;i<= recordSize-1; i++){
                                                                 //  if(count <= recordSize){
                                                                 //if(objCc.Program_Enrollment__r.hed__Contact__r.SRN_Number__c)
                                                                 
                                                                 Student_Semester_Mapping__c objCc = mapStudent.get(objTerm.id)[i];
                                                                 if(objCc.Program_Enrollment__r.hed__Contact__r.SRN_Number__c != null ||objCc.Program_Enrollment__r.hed__Contact__r.SRN_Number__c != ''){
                                                                     CaseTeamMember objmember = new CaseTeamMember();
                                                                     objmember.ParentId = FacultyCase.get(temp).id;
                                                                     objmember.MemberId = objCc.Program_Enrollment__r.hed__Contact__c;
                                                                     objmember.TeamRoleId = role.Id;
                                                                     listCaseMember.add(objmember);                        
                                                                     //  mapStudent.get(objTerm.id).remove(count);
                                                                     count = count + 1;
                                                                     
                                                                     //  break;
                                                                     //  }                                                        
                                                                 }
                                                                 
                                                             }
                                                             system.debug('++++++++++++++'+listCaseMember.size());
                                                         }
                                                     }
                                                 }
                                                 insert listCaseMember;
                                             } 
                                         }
                                         
                                     }
    }

    public static void professorSubjectAlloEnabled(list<hed__Term__c> lstTerm,map<id,hed__Term__c> oldMap){
        for(hed__Term__c term : lstTerm){
            if(term.Allow_Professors_for_Preferences__c != oldMap.get(term.id).Allow_Professors_for_Preferences__c ){
                term.Subject_Allocation_Enabled__c = !term.Allow_Professors_for_Preferences__c ;
            }

        }
    }
}