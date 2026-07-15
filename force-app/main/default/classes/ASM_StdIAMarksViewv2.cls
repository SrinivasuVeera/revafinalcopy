public without sharing class ASM_StdIAMarksViewv2 {
    @AuraEnabled
    public static dataWpr fetchData(String iaType,Id semesterId) {
        
        User cUser = [SELECT Id, ContactId, Contact.Active_Semester__c, Contact.Active_Semester__r.Name 
                      FROM User WHERE Id = :UserInfo.getUserId()]; 
        System.debug('cUser=> ' + cUser);
        System.debug('user contactId-->' + cUser.ContactId);
        
        dataWpr dWpr = new dataWpr();
        String contactId = cUser.ContactId;
        System.debug('the contact ####' + contactId);
        
        if (contactId != null) {
            // Query the Contact and related Student Fee records
            Contact con = [SELECT Id, Name, RecordType.Name, Active_Semester__c, Active_Semester__r.Name,Program_Batch__c,Program_Batch_Name__c, 
                           Current_Year__c, ReportsToId, ReportsTo.Active_Semester__r.Name,
                           (SELECT Id, Name, Fee_Year__c, Amount_Pending__c 
                            FROM Student_Fees__r) 
                           FROM Contact 
                           WHERE Id = :contactId 
                           LIMIT 1];
            
            system.debug('Contact retrieved: ' + con);
            if (semesterId == null) {
            	semesterId = con.Active_Semester__c;
        	}
            dWpr.isActiveSemester = (semesterId == con.Active_Semester__c);
            
            List<hed__Term__c > semesters = [SELECT Id,Name,Term_Number__c FROM hed__Term__c 
                            WHERE Program_Batch__c = :con.Program_Batch__c ORDER BY Term_Number__c];
            
            // Check if there are any related Student Fee records
           /* if (con.Student_Fees__r != null && !con.Student_Fees__r.isEmpty()) {
                Student_Fee__c studentFee = con.Student_Fees__r[0];
                system.debug('Student Fee Record: ' + JSON.serialize(studentFee));
                // Check if the Fee Year matches the Contact's Current Year and if the amount pending is not zero
                if (studentFee.Fee_Year__c == con.Current_Year__c && studentFee.Amount_Pending__c!= 0) {
                    return new dataWpr();
                }
            } else {
                system.debug('No Student Fee records found for this contact.');
            } */
            // Determine whether the user is a student or a parent
            if (con.RecordType.Name == utility.Contact_RecType_Student && con.Active_Semester__c != null) {
                contactId = con.Id;
                dWpr.activeSemesterId = con.Active_Semester__c;
                dWpr.activeSem = con.Active_Semester__r != null ? con.Active_Semester__r.Name : null;
                dWpr.semesters = semesters;
            } else if (con.RecordType.Name == utility.Contact_RecType_Parent) {
                contactId = con.ReportsToId;
                dWpr.activeSem = con.ReportsTo != null && con.ReportsTo.Active_Semester__r != null ? con.ReportsTo.Active_Semester__r.Name : null;
            }
            System.debug('Final contactId for IA Marks retrieval: ' + contactId);
            dWpr.list_IAMarks = new List<IA_Marks__c>();
            Map<String, crsWpr> map_Data = new Map<String, crsWpr>();
            
            if (String.isNotBlank(iaType)) {
                Decimal totalIAMarks = 0;
                for (IA_Marks__c iam : [SELECT Id,Total_Secured_Marks_New__c,Assignment_Secured_Marks__c,
                                        Course_Connection__r.Active_Connection__c,
                                        Course_Offering__r.hed__Course__r.Name,
                                        Course_Offering__r.hed__Course__r.Maximum_Internal_Marks__c,
                                        Theory_Secured_Marks__c, Seminar_Secured_Marks__c, Quiz_Secured_marks__c,
                                        Analysis_and_Synthesis_Secured_Marks__c, Continuous_Learning_Secured_Marks__c,
                                        Ethical_Attitude_Secured_Marks__c, Independent_Learning_Secured_Marks__c,
                                        Literature_Survey_Secured_Marks__c, Selection_of_Topic_Secured_Marks__c,
                                        Oral_Presentation_Secured_Marks__c, Report_Writing_Secured_Marks__c, Course_Type__c,
                                        Knowledge_of_Exercise_Secured_Marks__c, Execution_of_Exercise_Secured_Marks__c,
                                        Description_of_Experiment_Secured_Mark__c, Viva_Voce_Practical_Secured_Marks__c,
                                        Punctuality_Secured_Marks__c, Results_Secured_Marks__c, Course_Connection__c,
                                        Course_Offering__r.hed__Course__r.Seminar_Maximum_Marks__c,
                                        Course_Offering__r.hed__Course__r.Quiz_Maximum_Marks__c,
                                        Course_Offering__r.hed__Course__r.Theory_Maximum_Marks__c,
                                        Course_Offering__r.hed__Course__r.Analysis_and_Synthesis_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Literature_Survey_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Ethical_Attitude_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Independent_Learning_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Oral_Presentation_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Report_Writing_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Continuous_Learning_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Selection_of_Topic_Max_marks__c,
                                        Course_Offering__r.hed__Course__r.Knowledge_of_Exercise_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Execution_of_Exercise_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Description_of_Experiment_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Viva_Voce_Practical_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Punctuality_Max_Marks__c,
                                        Course_Offering__r.hed__Course__r.Results_Max_Marks__c,
                                        Acknowledgment_Response__c,Semester__r.IA_2_Result_Date__c,
                                        Course_Connection__r.Total_IA_Marks__c
                                        // Course_Connection__r.hed__Course_Enrollment__r.Total_IA_Marks__c
                                        FROM IA_Marks__c 
                                        WHERE IA_Type__c = :iaType
                                        AND Course_Connection__r.hed__Contact__c = :contactId
                                        //AND Course_Connection__r.Active_Connection__c = true
                                        AND Course_Connection__r.RecordType.Name = 'Student'
                                        AND Semester__c = :semesterId
                                        AND (Semester__r.IA_1_Result_date__c <= :System.today() 
                                             OR Semester__r.IA_2_Result_Date__c <= :System.today())]) {  
                                                 
                                                 dWpr.list_IAMarks.add(iam);
                                                 /***************Newly added to get total IA MArks************************/                       
                                                 /* if (iam.Course_Connection__r != null) {
dWpr.totalIAMarks = iam.Course_Connection__r.Total_IA_Marks__c;
}  */
                                                 if (iam.Course_Connection__r != null && iam.Course_Connection__r.Total_IA_Marks__c != null) {
                                                     totalIAMarks += iam.Course_Connection__r.Total_IA_Marks__c;
                                                 }
                                                 /*********************************/
                                                 if (map_Data.containsKey(iam.Course_Type__c)) {
                                                     map_Data.get(iam.Course_Type__c).list_IAMarks.add(iam);
                                                 } else {
                                                     crsWpr cWpr = new crsWpr();
                                                     cWpr.crsType = iam.Course_Type__c;
                                                     cWpr.list_IAMarks = new List<IA_Marks__c>();
                                                     cWpr.list_IAMarks.add(iam);
                                                     map_Data.put(iam.Course_Type__c, cWpr);
                                                 }
                                             }
                dWpr.totalIAMarks = totalIAMarks;
            }
            dWpr.list_crsWpr = map_Data.values();
            return dWpr;
            
        }
        return dWpr; // Return an empty dataWpr object if no contactId is found
    }
    
    /*************************Newly added by veera to Acknowledge Student Marks******************************************/
    /**
 * @description Updates the acknowledgment status and response for a single IA_Marks__c record.
 *              Sets the Acknowledged__c field to true and updates the Acknowledgment_Response__c field with the provided response.
 * @param recordId The ID of the IA_Marks__c record to update.
 * @param response The acknowledgment response to set on the record.
 * @throws AuraHandledException If the user lacks permissions to read or update the IA_Marks__c object or its fields, or if the record is not found.
 */
@AuraEnabled
    public static void updateAcknowledgment(Id recordId, String response) {
        IA_Marks__c mark = [SELECT Id, Acknowledged__c, Acknowledgment_Response__c FROM IA_Marks__c WHERE Id = :recordId LIMIT 1];
        mark.Acknowledged__c = true;
        mark.Acknowledgment_Response__c = response;
        update mark;
    }
    
    
    /***********************************Editing Ended here********************************************************************************/
    public class dataWpr {
        @AuraEnabled public String activeSem { get; set; }
        @AuraEnabled public List<hed__Term__c> semesters;
        @AuraEnabled public Id activeSemesterId;
        @AuraEnabled public Boolean isActiveSemester;
        @AuraEnabled public List<IA_Marks__c> list_IAMarks { get; set; }
        @AuraEnabled public List<crsWpr> list_crsWpr { get; set; }
        @AuraEnabled public Decimal totalIAMarks { get; set; }
    }
    
    public class crsWpr {
        @AuraEnabled public String crsType { get; set; }
        @AuraEnabled public List<IA_Marks__c> list_IAMarks { get; set; }
    }
}