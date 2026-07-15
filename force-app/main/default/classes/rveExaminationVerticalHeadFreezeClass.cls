public class rveExaminationVerticalHeadFreezeClass {

public class IAMarksWrapper{
    @AuraEnabled public string StudentSRN {get;set;}
    @AuraEnabled public string StudentName {get;set;}
    @AuraEnabled public string IA1Marks {get;set;}
    @AuraEnabled public string IA2Marks {get;set;}
    @AuraEnabled public string Marks {get;set;}
    public Boolean hasIA1Record { get; set; }
} 

@AuraEnabled(cacheable=true)
public static list<hed__Program_Plan__c> getRelatedProgramBatch(){
    String UserId = UserInfo.getUserId();
    return [Select id,name from hed__Program_Plan__c where ((hed__Account__r.parent.Examination_Vertical_Head__c =: UserId OR hed__Account__r.Examination_Vertical_Head__c =: UserId) or hed__Account__r.parent.School_Head__c=:UserId) AND Active__c=true];
}

@AuraEnabled
public static list<hed__term__c> getRelatedSemester(String ProgramBatch){
    return [Select id,name,Rve_SEE_Result_Date__c,ExamVHAcknowledged__c,IA_2_Result_Date__c,ExamVerticalHeadFreeze__c,SchoolDirectorFreeze__c from hed__term__c where Program_Batch__c =: ProgramBatch and Active__c=true];
}


@AuraEnabled
public static List<hed__Course_Enrollment__c> getCourseEnrollments(String SemesterID){
    try {
        List<hed__Course_Enrollment__c>CourseEnrollments = [Select id,hed__Course_Offering__c,hed__Course_Offering__r.Name,hed__Contact__r.Name,
                                                            section__r.hed__Parent_Term__r.IA_2_Result_Date__c,Acknowledged__c,section__r.Name,
                                                            section__r.hed__Parent_Term__r.ExamVerticalHeadFreeze__c,Section__r.hed__Parent_Term__r.hed__Parent_Term__r.ExamVerticalHeadFreeze__c,
                                                            hed__Course_Offering__r.hed__Course__c,hed__Course_Offering__r.hed__Course__r.Name,
                                                            hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,Section__r.hed__Parent_Term__r.SchoolDirectorFreeze__c,
                                                            RVE_Exam_Vertical_Head_Freeze__c,RVE_Professor_freeze__c,IA_Marks_Entry_Status__c
                                                            from hed__Course_Enrollment__c where (Section__r.hed__Parent_Term__c =: SemesterID
                                                                                                    or Section__r.hed__Parent_Term__r.hed__Parent_Term__c=:SemesterID)
                                                            and
                                                            recordtype.name='Faculty' AND hed__Course_Offering__r.hed__Course__r.No_of_IA_s__c !='0'];
        return CourseEnrollments;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

@AuraEnabled(cacheable=true)
public static List<IAMarksWrapper> getCourseWiseIAMarks(String CourseID){
    try {
        hed__Course_Enrollment__c courseEnrollment = [Select Id,hed__Course_Offering__c,Section__c from hed__Course_Enrollment__c where id =: CourseID];
        System.debug('CourseID=> '+CourseID);
        List<IAMarksWrapper> IAMarksList = new List<IAMarksWrapper>();
        Map<Id, Decimal> studentToTotalMarks = new Map<Id, Decimal>();
        
        for (IA_Marks__c mark : [
            SELECT Course_Connection__r.hed__Contact__c,Course_Connection__r.hed__Contact__r.Name,
            Total_Secured_Marks_New__c,SRN_Number__c,IA_Type__c
            FROM IA_Marks__c
            WHERE Course_Connection__r.hed__Course_Offering__c =: courseEnrollment.hed__Course_Offering__c
            AND Course_Connection__r.Section__c =: courseEnrollment.Section__c 
            AND Course_Connection__r.RecordType.Name = 'Student'
            AND IA_Type__c IN ('IA1', 'IA2') ORDER BY Course_Connection__r.hed__Contact__r.SRN_Number__c ASC  // Only IA1 and IA2
        ]) {
            System.debug('mark=> '+mark);
            Id studentId = mark.Course_Connection__r.hed__Contact__c;
            System.debug('StudentId=> '+studentId);
            Decimal existingMarks = studentToTotalMarks.containsKey(studentId) ? studentToTotalMarks.get(studentId) : 0;
            studentToTotalMarks.put(studentId, existingMarks + mark.Total_Secured_Marks_New__c);
        }
        
        Map<Id, IAMarksWrapper> studentToWrapper = new Map<Id, IAMarksWrapper>();
        
        for (IA_Marks__c mark : [
            SELECT Course_Connection__r.hed__Contact__c,
            Course_Connection__r.hed__Contact__r.Name,
            Total_Secured_Marks_New__c,
            SRN_Number__c,IA_Type__c
            FROM IA_Marks__c
            WHERE Course_Connection__r.hed__Course_Offering__c =: courseEnrollment.hed__Course_Offering__c
            AND Course_Connection__r.Section__c =: courseEnrollment.Section__c 
            AND Course_Connection__r.RecordType.Name = 'Student'
            AND IA_Type__c IN ('IA1', 'IA2') ORDER BY Course_Connection__r.hed__Contact__r.SRN_Number__c ASC
        ]) {
            Id studentId = mark.Course_Connection__r.hed__Contact__c;
            
            if (!studentToWrapper.containsKey(studentId)) {
                IAMarksWrapper newInstance = new IAMarksWrapper();
                newInstance.StudentSRN = mark.SRN_Number__c;
                newInstance.StudentName = mark.Course_Connection__r.hed__Contact__r.Name;
                newInstance.IA1Marks = '0'; // Initialize IA1 marks to 0
                newInstance.IA2Marks = '0';
                newInstance.Marks = '0'; // Initialize to 0
                newInstance.hasIA1Record = false;
                studentToWrapper.put(studentId, newInstance);
            }
            
            // Add marks
            IAMarksWrapper wrapper = studentToWrapper.get(studentId);
            Decimal markValue = mark.Total_Secured_Marks_New__c != null ? mark.Total_Secured_Marks_New__c : 0;
            if (mark.IA_Type__c == 'IA1') {
                wrapper.hasIA1Record = true; // Mark that an IA1 record exists
                Decimal existingIA1Marks = Decimal.valueOf(wrapper.IA1Marks);
                wrapper.IA1Marks = String.valueOf(existingIA1Marks + markValue);
            } else if (mark.IA_Type__c == 'IA2') {                   
                Decimal existingIA2Marks = Decimal.valueOf(wrapper.IA2Marks);
                wrapper.IA2Marks = String.valueOf(existingIA2Marks + markValue);
            }
            Decimal existingMarks = Decimal.valueOf(wrapper.Marks);
            wrapper.Marks = String.valueOf(existingMarks + markValue);
        }
        for (IAMarksWrapper wrapper : studentToWrapper.values()) {
            if (!wrapper.hasIA1Record) {
                wrapper.IA1Marks = 'NA'; // Set to NA if no IA1 record exists
            }
        }
        // Finally, assign all values to your IAMarksList
        IAMarksList = studentToWrapper.values();
        
        return IAMarksList;
        
    } catch (Exception e) {
        System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
        throw new AuraHandledException(e.getMessage());
    }
    
}

@AuraEnabled
public static string updateFacultyEligibility(String CourseOfferingID, Boolean status,String actionType){
    try {
        hed__Course_Enrollment__c courseConnection = [Select id,Rve_Exam_Vertical_Head_Freeze__c,Rve_Professor_freeze__c,Acknowledged__c from hed__Course_Enrollment__c where id =: CourseOfferingID]; 
        courseConnection.RVE_Professor_freeze__c = status;
        
        if(actionType == 'FREEZE'){
            courseConnection.Rve_Professor_freeze__c = status;            
        }
        else if (actionType == 'VERIFY'){
            courseConnection.RVE_Exam_Vertical_Head_Freeze__c = status;           
        }
        update courseConnection;
        return 'Success';
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

@AuraEnabled
public static String updateExamVerticalHeadStatusForSemester(String semId, String status) {
try {
    if (status == 'Freeze') {
        List<hed__Course_Enrollment__c> courseEnrollments = [SELECT Id, RVE_Exam_Vertical_Head_Freeze__c, IA_Marks_Entry_Status__c, Rve_Professor_freeze__c
                                                            FROM hed__Course_Enrollment__c
                                                            WHERE (Section__r.hed__Parent_Term__r.hed__Parent_Term__c = :semId 
                                                                    OR Section__r.hed__Parent_Term__c = :semId)
                                                            AND RecordType.Name = 'Faculty'];

    /*    for (hed__Course_Enrollment__c ce : courseEnrollments) {
            // Error if locked and professor froze but head hasn't verified
            if (ce.IA_Marks_Entry_Status__c == 'Locked' && ce.Rve_Professor_freeze__c == true && ce.RVE_Exam_Vertical_Head_Freeze__c == false) {
                return 'ERROR: Please verify all Locked records where Professor has Frozen marks before freezing the semester.';
            }
        } */
    }

    hed__term__c semester = [SELECT Id,ExamVHAcknowledged__c, ExamVerticalHeadFreeze__c FROM hed__term__c WHERE Id = :semId LIMIT 1];
    semester.ExamVerticalHeadFreeze__c = (status == 'Freeze');
    semester.ExamVHAcknowledged__c = 'Verified By Exam Veritical Head';
    update semester;

    return 'Success';
} catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
}
}
@AuraEnabled
public static String toggleSemesterFreeze(String semId, String fieldName, Boolean status) {
    try {
        hed__term__c sem = [SELECT Id,SchoolDirectorAcknowledged__c, ExamVerticalHeadFreeze__c, SchoolDirectorFreeze__c FROM hed__term__c WHERE Id = :semId LIMIT 1];
        
        if (fieldName == 'SchoolDirector') {
            sem.SchoolDirectorFreeze__c = status;
            sem.SchoolDirectorAcknowledged__c = 'Frozen By School Director';
        } else if (fieldName == 'EVH') {
            sem.ExamVerticalHeadFreeze__c = status;
        }
        
        update sem;
        return 'Success';
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
/*
@AuraEnabled
public static string updateSemFreezingStatus(String SemId){
    try {
        System.debug('SemId=> '+SemId);
        /*
        List<hed__Course_Enrollment__c> CourseEnrollments = [Select id,RVE_Exam_Vertical_Head_Freeze__c,RVE_Professor_freeze__c from hed__Course_Enrollment__c where hed__Course_Offering__r.hed__Term__r.hed__Parent_Term__c =: SemId];
        if(!CourseEnrollments.isEmpty()){
        for(hed__Course_Enrollment__c CO : CourseEnrollments){
        CO.RVE_Professor_freeze__c = true;
        }
        update CourseEnrollments;
        } */ /*
        hed__term__c Semester = [Select id,ExamVerticalHeadFreeze__c,SchoolDirectorFreeze__c from hed__term__c where id =: SemId];
        if(Semester !=null && Semester.ExamVerticalHeadFreeze__c == true){
            Semester.SchoolDirectorFreeze__c = true;
            update Semester;
            return 'Success';
        }else {
            return 'Error: Semester not found or Exam Vertical Head not frozen';
        }
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
} */
@AuraEnabled
public static String bulkUpdateVerification(List<Id> recordIds, Boolean status) {
try {
    List<hed__Course_Enrollment__c> records = [SELECT Id FROM hed__Course_Enrollment__c WHERE Id IN :recordIds];
    for(hed__Course_Enrollment__c r : records) {
        r.RVE_Exam_Vertical_Head_Freeze__c = status;
    }
    update records;
    return 'Success';
} catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
}
}
@AuraEnabled
public static Map<String, Object> getSemesterIAMarks(String semesterId) {
    try { 
        
        Map<String, Object> result = new Map<String, Object>();
        Set<String> courseCodes = new Set<String>();
        Map<String, String> courseCodeToName = new Map<String, String>();
        Map<String, List<String>> courseCodeToCharacters = new Map<String, List<String>>();
        Map<Id, String> courseOfferingToCode = new Map<Id, String>();
        Map<Id, StudentIAMarksWrapper> studentToWrapper = new Map<Id, StudentIAMarksWrapper>();
        hed__Term__c semestername = [SELECT Id, Name FROM hed__Term__c WHERE Id = :semesterId LIMIT 1];
        
        List<hed__Course_Enrollment__c> studentEnrollments = [SELECT Id, SRN_Number__c, Course_Code__c, hed__Course_Offering__c, Section__c,
                                                                hed__Contact__c, hed__Contact__r.Name,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Course_Offering__r.hed__Course__r.Name
                                                                FROM hed__Course_Enrollment__c WHERE Semester__c = :semestername.Name AND RecordType.Name = 'Student' AND Active_Connection__c = true
                                                                AND SRN_Number__c != null ORDER BY SRN_Number__c ASC];
        
        for (hed__Course_Enrollment__c enrollment : studentEnrollments) {            
            if (enrollment.hed__Course_Offering__c == null || 
                enrollment.hed__Course_Offering__r.hed__Course__c == null || 
                enrollment.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c == null) {
                    System.debug('Warning: Missing course data for enrollment ' + enrollment.Id);
                    continue; // Skip this enrollment if course data is missing
                }
            
            String courseCode = enrollment.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c;
            if (String.isNotBlank(courseCode)) {
                courseCodes.add(courseCode);
                String courseName = enrollment.hed__Course_Offering__r.hed__Course__r.Name != null ? 
                    enrollment.hed__Course_Offering__r.hed__Course__r.Name : 'Unknown Course';
                courseCodeToName.put(courseCode, courseName);
                List<String> characters = courseCode.split('');
                courseCodeToCharacters.put(courseCode, characters);
                courseOfferingToCode.put(enrollment.hed__Course_Offering__c, courseCode);
            } else {
                System.debug('Warning: Course code is blank for enrollment ' + enrollment.Id);
            }
            
            // Initialize the wrapper for each student
            Id studentId = enrollment.hed__Contact__c;
            if (studentId != null && !studentToWrapper.containsKey(studentId)) {
                StudentIAMarksWrapper wrapper = new StudentIAMarksWrapper();
                wrapper.srnNumber = enrollment.SRN_Number__c;
                wrapper.studentName = enrollment.hed__Contact__r.Name != null ? 
                    enrollment.hed__Contact__r.Name : 'Unknown Student';
                studentToWrapper.put(studentId, wrapper);
            }
        }
        
        // Convert course codes to a sorted list for consistent column ordering
        List<String> sortedCourseCodes = new List<String>(courseCodes);
        sortedCourseCodes.sort();
        
        for (IA_Marks__c mark : [SELECT Course_Connection__r.hed__Contact__c, Course_Connection__r.hed__Contact__r.Name,Total_Secured_Marks_New__c, SRN_Number__c, IA_Type__c,
                                    Course_Connection__r.hed__Course_Offering__c FROM IA_Marks__c WHERE Course_Connection__r.hed__Course_Offering__c IN :courseOfferingToCode.keySet()
                                    AND Course_Connection__r.RecordType.Name = 'Student' AND IA_Type__c IN ('IA1', 'IA2') ORDER BY Course_Connection__r.hed__Contact__r.SRN_Number__c ASC]) 
        {            
            Id studentId = mark.Course_Connection__r.hed__Contact__c;
            String courseCode = courseOfferingToCode.get(mark.Course_Connection__r.hed__Course_Offering__c);
            
            if (studentId != null && studentToWrapper.containsKey(studentId) && String.isNotBlank(courseCode)) {
                StudentIAMarksWrapper wrapper = studentToWrapper.get(studentId);
                Decimal markValue = mark.Total_Secured_Marks_New__c != null ? mark.Total_Secured_Marks_New__c : 0;
                
                Decimal existingMarks = 0;
                String existingMarksStr = wrapper.courseCodeToTotalMarks.get(courseCode);
                if (String.isNotBlank(existingMarksStr)) {
                    try {
                        existingMarks = Decimal.valueOf(existingMarksStr);
                    } catch (Exception e) {
                        System.debug('Error converting marks for course ' + courseCode + ': ' + e.getMessage());
                        existingMarks = 0;
                    }
                }
                wrapper.courseCodeToTotalMarks.put(courseCode, String.valueOf(existingMarks + markValue));
            }
        }
        
        Integer index = 1;
        List<StudentIAMarksWrapper> studentList = new List<StudentIAMarksWrapper>();        
        for (StudentIAMarksWrapper wrapper : studentToWrapper.values()) {
            for (String courseCode : sortedCourseCodes) {
                if (!wrapper.courseCodeToTotalMarks.containsKey(courseCode)) {
                    wrapper.courseCodeToTotalMarks.put(courseCode, 'N/A');
                }
            }
            wrapper.index = index++;
            studentList.add(wrapper);
        }
        hed__Term__c semester = [SELECT Id, Name FROM hed__Term__c WHERE Id = :semesterId LIMIT 1];
        
        result.put('students', studentList);
        result.put('courseCodes', sortedCourseCodes);
        result.put('courseCodeToName', courseCodeToName);
        result.put('courseCodeToCharacters', courseCodeToCharacters);
        result.put('semesterName', semester.Name != null ? semester.Name : 'Unknown Semester');
        
        System.debug('Returning result: ' + result);
        return result;
    } catch (Exception e) {
        System.debug('Exception in getSemesterIAMarks: Line ' + e.getLineNumber() + ', Message: ' + e.getMessage());
        throw new AuraHandledException('Error in generating IA Marks report: ' + e.getMessage());
    }
}  
public List<StudentIAMarksWrapper> students { get; set; }
public List<String> courseCodes { get; set; }
public Map<String, String> courseCodeToName { get; set; }
public Map<String, List<String>> courseCodeToCharacters { get; set; }
public String semesterName { get; set; }

// Constructor for the Visualforce page
public rveExaminationVerticalHeadFreezeClass() {
    String semesterId = ApexPages.currentPage().getParameters().get('semesterId');
    if (String.isNotBlank(semesterId)) {
        Map<String, Object> result = getSemesterIAMarks(semesterId);
        students = (List<StudentIAMarksWrapper>) result.get('students');
        courseCodes = (List<String>) result.get('courseCodes');
        courseCodeToName = (Map<String, String>) result.get('courseCodeToName');
        courseCodeToCharacters = (Map<String, List<String>>) result.get('courseCodeToCharacters');
        semesterName = (String) result.get('semesterName');
    }
}
public class StudentIAMarksWrapper {
    public String srnNumber { get; set; }
    public String studentName { get; set; }
    public Map<String, String> courseCodeToTotalMarks { get; set; } // Maps course code to total marks (IA1 + IA2)
    public Integer index { get; set; }
    
    public StudentIAMarksWrapper() {
        courseCodeToTotalMarks = new Map<String, String>();
    }
}

@AuraEnabled
public static String updateStatus(Id courseEnrollmentId, String newStatus) {
    try {
        hed__Course_Enrollment__c ce = [SELECT Id, IA_Marks_Entry_Status__c FROM hed__Course_Enrollment__c WHERE Id = :courseEnrollmentId LIMIT 1];
        ce.IA_Marks_Entry_Status__c = newStatus;
        update ce;
        return 'Success';
    } catch (Exception e) {
        return 'Error: ' + e.getMessage();
    }
}


/*  @AuraEnabled
public static string updateFacultyEligibilityToFreeze(String CourseOfferingID){
try {
hed__Course_Offering__c CourseOffering = [Select id,RVE_Professor_freeze__c from hed__Course_Offering__c where id =: CourseOfferingID];
CourseOffering.RVE_Professor_freeze__c = true;
update CourseOffering;
return 'Success';
} catch (Exception e) {
throw new AuraHandledException(e.getMessage());
}
}*/


}