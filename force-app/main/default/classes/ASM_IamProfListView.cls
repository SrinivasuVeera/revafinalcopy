public class ASM_IamProfListView {
    @AuraEnabled
    public static profDtWpr fetchData(String iaType){
        profDtWpr dWpr = new profDtWpr();
        dWpr.isAllowed = true;
        dWpr.message = '';
        dWpr.list_CrsCons = new List<hed__Course_Enrollment__c>();
        Contact cont = [SELECT Id FROM Contact WHERE OwnerId =: UserInfo.getUserId() LIMIT 1];
        Id facId = cont.Id;
        Date dt = System.today();
        Set<String> set_FirstCrs = new Set<String>();
        set_FirstCrs.add('Theory');
        set_FirstCrs.add('Project');
        for(hed__Course_Enrollment__c con : [SELECT Id,Name,hed__Course_Offering__c,hed__Course_Offering__r.hed__Course__c,RVE_Professor_freeze__c,
                                             hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c,hed__Course_Offering__r.hed__Course__r.No_of_IA_s__c,
                                             hed__Course_Offering__r.hed__Term__r.hed__Parent_Term__r.Name,Semester_Name__c,
                                             hed__Course_Offering__r.hed__Course__r.Name,Section__c,Section__r.Active__c,
                                             hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c,Program__c,
                                             School__c,Semester__c,Section_Batch_Group__c,IA1_Start_Date__c,IA1_End_Date__c,
                                             IA2_Start_Date__c,IA2_End_Date__c,IA2_Result_Date__c,IA_Marks_Entry_Status__c
                                             FROM hed__Course_Enrollment__c WHERE hed__Contact__c =: facId //='0030w00000qRo2EAAS'
                                             AND ((hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c IN: set_FirstCrs AND Section__r.hed__Parent_Term__r.Active__c = true) 
                                                  OR (hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c = 'Practical' AND Section__r.hed__Parent_Term__r.hed__Parent_Term__r.Active__c = true))
                                             AND RecordType.Name = 'Faculty'])
        {
            System.debug('con=> '+con);
             String noOfIAs = con.hed__Course_Offering__r.hed__Course__r.No_of_IA_s__c;
            if (noOfIAs == '1') {
                if (iaType == 'IA1') {
                    continue;
                }           
                if (iaType == 'IA2' && dt > con.IA2_End_Date__c && dt < con.IA2_End_Date__c.addDays(20) && con.hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c == false) {
                    System.debug('33=> Condition Satisfied');
                    dWpr.list_CrsCons.add(con);
                }
            } 
            else if (noOfIAs == '2') {            
                if(((iaType == 'IA1' && dt > con.IA1_End_Date__c) || (iaType == 'IA2' && dt > con.IA2_End_Date__c)) && (dt < con.IA2_End_Date__c.addDays(20) && con.hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c == false)){
                    dWpr.list_CrsCons.add(con);
                }
            }
        }
        if(dWpr.list_CrsCons.isEmpty()){
            dWpr.isAllowed = false;
            dWpr.message = iaType+' marks entry not allowed at this moment';
        }
        return dWpr;
    }
       
    @AuraEnabled
    public static profDtWpr fetchDataSchoolDirector(String iaType){
        profDtWpr dWpr = new profDtWpr();
        dWpr.isAllowed = true;
        dWpr.message = '';
        dWpr.list_CrsCons = new List<hed__Course_Enrollment__c>();
        Contact cont = [SELECT Id FROM Contact WHERE OwnerId =: UserInfo.getUserId() LIMIT 1];
        System.debug('cont=> '+cont);
        Id facId = cont.Id;
        Date dt = System.today();
        Set<String> set_FirstCrs = new Set<String>();
        set_FirstCrs.add('Theory');
        set_FirstCrs.add('Project');
        for(hed__Course_Enrollment__c con : [SELECT Id,Name,hed__Course_Offering__c,hed__Course_Offering__r.hed__Course__c,
                                             hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c,hed__Course_Offering__r.hed__Course__r.No_of_IA_s__c,
                                             hed__Course_Offering__r.hed__Term__r.hed__Parent_Term__r.Name,hed__Course_Offering__r.Acknowledged__c,
                                             hed__Course_Offering__r.hed__Course__r.Name,Section__c,Section__r.Active__c,
                                             hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c,Program__c,
                                             School__c,Semester__c,Section_Batch_Group__c,IA1_Start_Date__c,IA1_End_Date__c,
                                             IA2_Start_Date__c,IA2_End_Date__c,IA_Marks_Entry_Status__c
                                             FROM hed__Course_Enrollment__c WHERE 
                                              ((hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c IN: set_FirstCrs AND Section__r.hed__Parent_Term__r.Active__c = true) 
                                                  OR (hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c = 'Practical' AND Section__r.hed__Parent_Term__r.hed__Parent_Term__r.Active__c = true))
                                               AND RecordType.Name = 'Faculty'])
        {
            System.debug('con=> '+con);
             String noOfIAs = con.hed__Course_Offering__r.hed__Course__r.No_of_IA_s__c;
            if (noOfIAs == '1') {
                if (iaType == 'IA1') {
                    continue;
                }           
                if (iaType == 'IA2' && dt > con.IA2_End_Date__c && dt < con.IA2_End_Date__c.addDays(9) && con.hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c == false) {
                    System.debug('33=> Condition Satisfied');
                    dWpr.list_CrsCons.add(con);
                }
            } 
            else if (noOfIAs == '2') {            
                if(((iaType == 'IA1' && dt > con.IA2_End_Date__c) || (iaType == 'IA2' && dt > con.IA2_End_Date__c)) && (dt < con.IA2_End_Date__c.addDays(9) && con.hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c == false)){
                    dWpr.list_CrsCons.add(con);
                }
            }
        }
        if(dWpr.list_CrsCons.isEmpty()){
            dWpr.isAllowed = false;
            dWpr.message = iaType+' marks entry not allowed at this moment';
        }
        return dWpr;
    }
    
    

    @AuraEnabled
    public static boolean checkFreezingStatus(String iaType){
       
        Contact cont = [SELECT Id FROM Contact WHERE OwnerId =: UserInfo.getUserId() LIMIT 1];
        Id facId = cont.Id;
        Date dt = System.today();
        Set<String> set_FirstCrs = new Set<String>();
        set_FirstCrs.add('Theory');
        set_FirstCrs.add('Project');
        List<hed__Course_Enrollment__c> con = [SELECT Id,Name,hed__Course_Offering__c,hed__Course_Offering__r.hed__Course__c,
                                             hed__Course_Offering__r.hed__Term__r.Push_to_Logisys__c,hed__Course_Offering__r.hed__Course__r.No_of_IA_s__c,
                                             hed__Course_Offering__r.hed__Term__r.hed__Parent_Term__r.Name,
                                             hed__Course_Offering__r.hed__Course__r.Name,Section__c,Section__r.Active__c,
                                             hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c,Program__c,
                                             School__c,Semester__c,Section_Batch_Group__c,IA1_Start_Date__c,IA1_End_Date__c,
                                             IA2_Start_Date__c,IA2_End_Date__c
                                             FROM hed__Course_Enrollment__c WHERE hed__Contact__c =: facId //='0030w00000qRo2EAAS'
                                             AND ((hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c IN: set_FirstCrs AND Section__r.hed__Parent_Term__r.Active__c = true) 
                                                  OR (hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c = 'Practical' AND Section__r.hed__Parent_Term__r.hed__Parent_Term__r.Active__c = true))
                                             AND RecordType.Name = 'Faculty' AND RVE_Professor_freeze__c=true
                                            /* and (Section__r.hed__Parent_Term__r.SchoolDirectorFreeze__c=true or Section__r.SchoolDirectorFreeze__c=true*/];

        if(con.size()>0){   
          return true;
        }
        else{
            return false;
        }

    }

    @AuraEnabled
    public static string updateFreezingStatus(String CourseOfferingID){
        System.debug('CourseOfferingID=> '+CourseOfferingID);
        try{
        hed__Course_Enrollment__c CourseOffering = [Select Id,RVE_Professor_freeze__c from hed__Course_Enrollment__c where Id=:CourseOfferingID];
        CourseOffering.RVE_Professor_freeze__c = true;
        CourseOffering.Acknowledged__c = 'Frozen by Faculty';
        update CourseOffering;
        return 'success';
        }
        catch(Exception e){
            System.debug('Exception=> '+e.getMessage());
            throw new AuraHAndledException(e.getMessage());
        }
        
    }
@AuraEnabled
    public static List<IAMarksWrapper> getCourseWiseIAMarks(String CourseID) {
        try {
            hed__Course_Enrollment__c courseEnrollment = [SELECT Id,Course_Code__c, hed__Course_Offering__c, Section__c 
                                                          FROM hed__Course_Enrollment__c 
                                                          WHERE Id = :CourseID];
            System.debug('CourseID=> ' + CourseID);
            List<IAMarksWrapper> IAMarksList = new List<IAMarksWrapper>();
            
            // Map to store IA1 and IA2 marks separately for each student
            Map<Id, IAMarksWrapper> studentToWrapper = new Map<Id, IAMarksWrapper>();
            
            for (IA_Marks__c mark : [
                SELECT Course_Connection__r.hed__Contact__c, Course_Connection__r.hed__Contact__r.Name,
                       Total_Secured_Marks_New__c, SRN_Number__c, IA_Type__c
                FROM IA_Marks__c
                WHERE Course_Connection__r.hed__Course_Offering__c = :courseEnrollment.hed__Course_Offering__c
                      AND Course_Connection__r.Section__c = :courseEnrollment.Section__c 
                      AND Course_Connection__r.RecordType.Name = 'Student'
                      AND IA_Type__c IN ('IA1', 'IA2') 
                ORDER BY Course_Connection__r.hed__Contact__r.SRN_Number__c ASC]) {
                System.debug('mark=> ' + mark);
                Id studentId = mark.Course_Connection__r.hed__Contact__c;
                System.debug('StudentId=> ' + studentId);
                
                if (!studentToWrapper.containsKey(studentId)) {
                    IAMarksWrapper newInstance = new IAMarksWrapper();
                    newInstance.StudentSRN = mark.SRN_Number__c;
                    newInstance.StudentName = mark.Course_Connection__r.hed__Contact__r.Name;
                    newInstance.IA1Marks = 'N/A'; // Default to N/A
                    newInstance.IA2Marks = 'N/A'; // Default to N/A
                    newInstance.Marks = '0'; // Initialize total marks
                    studentToWrapper.put(studentId, newInstance);
                }
                
                // Add marks based on IA type
                IAMarksWrapper wrapper = studentToWrapper.get(studentId);
                Decimal markValue = mark.Total_Secured_Marks_New__c != null ? mark.Total_Secured_Marks_New__c : 0;
                if (mark.IA_Type__c == 'IA1') {
                    wrapper.IA1Marks = String.valueOf(markValue);
                } else if (mark.IA_Type__c == 'IA2') {
                    wrapper.IA2Marks = String.valueOf(markValue);
                }
                // Update total marks (only if both IA1 and IA2 are available)
                Decimal ia1Value = wrapper.IA1Marks != 'N/A' ? Decimal.valueOf(wrapper.IA1Marks) : 0;
                Decimal ia2Value = wrapper.IA2Marks != 'N/A' ? Decimal.valueOf(wrapper.IA2Marks) : 0;
                wrapper.Marks = String.valueOf(ia1Value + ia2Value);
            }
            
            // Add any students who might not have IA marks
            for (hed__Course_Enrollment__c studentConn : [
                SELECT Id, hed__Contact__c, hed__Contact__r.Name, hed__Contact__r.SRN_Number__c
                FROM hed__Course_Enrollment__c
                WHERE hed__Course_Offering__c = :courseEnrollment.hed__Course_Offering__c
                      AND Section__c = :courseEnrollment.Section__c 
                      AND RecordType.Name = 'Student'
                ORDER BY hed__Contact__r.SRN_Number__c ASC]) {
                Id studentId = studentConn.hed__Contact__c;
                if (!studentToWrapper.containsKey(studentId)) {
                    IAMarksWrapper newInstance = new IAMarksWrapper();
                    newInstance.StudentSRN = studentConn.hed__Contact__r.SRN_Number__c;
                    newInstance.StudentName = studentConn.hed__Contact__r.Name;
                    newInstance.IA1Marks = 'N/A'; // Default to N/A
                    newInstance.IA2Marks = 'N/A'; // Default to N/A
                    newInstance.Marks = '0';
                    studentToWrapper.put(studentId, newInstance);
                }
            }
            
            IAMarksList = studentToWrapper.values();            
            return IAMarksList;
            
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
 public List<PDFMarksWrapper> studentMarks { get; set; }
    public String courseName { get; set; }
    public String courseID { get; set; }
    public String sectionName { get; set; }
    public String courseDisplay { get; set; }

    public ASM_IamProfListView() {
        String courseId = ApexPages.currentPage().getParameters().get('courseId');
        if (String.isNotBlank(courseId)) {
            List<IAMarksWrapper> marksList = getCourseWiseIAMarks(courseId);
            hed__Course_Enrollment__c courseEnrollment = [SELECT Id,Course_Code__c,hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c,hed__Course_Offering__r.hed__Course__r.Name, Section__r.Name 
                                                          FROM hed__Course_Enrollment__c 
                                                          WHERE Id = :courseId LIMIT 1];
            system.debug('course id==='+courseEnrollment);
            studentMarks = new List<PDFMarksWrapper>();
            Integer slNo = 1;
            for (IAMarksWrapper mark : marksList) {
                PDFMarksWrapper wrapper = new PDFMarksWrapper();
                wrapper.serialNumber = String.valueOf(slNo++);
                wrapper.studentName = mark.StudentName;
                wrapper.srnNumber = mark.StudentSRN;
                wrapper.ia1Marks = mark.IA1Marks;
                wrapper.ia2Marks = mark.IA2Marks;
                wrapper.totalMarks = mark.Marks;
                studentMarks.add(wrapper);
            }
            courseDisplay = courseEnrollment.hed__Course_Offering__r.hed__Course__r.Name;
            courseName = courseEnrollment.hed__Course_Offering__r.hed__Course__r.hed__Course_ID__c;
            //courseID = courseEnrollment.hed__Course_Offering__r.hed__Course__r.Name;
            system.debug('id===='+courseID);
            sectionName = courseEnrollment.Section__r.Name;
        }
    }    
    public class profDtWpr{
        @AuraEnabled public Boolean isAllowed{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public List<hed__Course_Enrollment__c> list_CrsCons{get;set;}
    }    
    public class IAMarksWrapper {
        @AuraEnabled public String StudentSRN { get; set; }
        @AuraEnabled public String StudentName { get; set; }
        @AuraEnabled public String IA1Marks { get; set; }
        @AuraEnabled public String IA2Marks { get; set; }
        @AuraEnabled public String Marks { get; set; }
    }
    public class PDFMarksWrapper {
        public String serialNumber { get; set; }
        public String studentName { get; set; }
        public String srnNumber { get; set; }
        public String ia1Marks { get; set; }
        public String ia2Marks { get; set; }
        public String totalMarks { get; set; }
    }
}