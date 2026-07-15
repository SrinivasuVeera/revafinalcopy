public class ASM_StudentResultView {
    @AuraEnabled
    public static dataWpr fetchData(String summaryId){
        User cUser = [SELECT Id,ContactId,Contact.Active_Semester__c,Contact.Active_Semester__r.Name FROM User WHERE Id =: UserInfo.getUserId()];
        dataWpr dWpr = new dataWpr();
        dWpr.summaryRec = [SELECT Id,Remarks__c,CGPA__c,SGPA__c,Passing_Criteria__c,Examination_Month_Year__c FROM hed__Term_Grade__c WHERE Id =: summaryId];
        dWpr.list_Results = new List<hed__Term_Grade__c>();
        for(hed__Term_Grade__c tg : [SELECT Id,Secured_External_Marks__c,Secured_Internal_Marks__c,Examination_Month_Year__c,
                                     Recent_Result_Updated_Date__c,hed__Result__c,No_of_Credits__c,Course__r.hed__Course_ID__c,
                                     Maximum_Marks_Course_Level__c,Total_Secured_Marks_Course_Level__c,Grade_Points__c,Grade__c, 
                                     Credit_Points__c,CGPA__c,Course__c,Course__r.Name,Course__r.Course_Type_Logisys__c, 
                                     Course__r.Total_Maximum_Marks_IA_External__c,Total_Secured_Marks_Course__c FROM hed__Term_Grade__c
                                     WHERE Result_Summary__c =: summaryId ORDER BY Course__r.Course_Type_Logisys__c DESC
                                    ])
        {
            dWpr.list_Results.add(tg);
        }
        return dWpr;
    }
    
    /******************************Added by veera 12052025*************************************************/
    /*  @AuraEnabled
public static dataWpr fetchStudentResults() {
dataWpr dWpr = new dataWpr();
dWpr.list_Results = new List<hed__Term_Grade__c>();

try {
System.debug('Fetching student results...');

// Get logged-in user's contact and active semester
User cUser = [SELECT Id, ContactId, Contact.Active_Semester__c,Contact.Program_Type__c,
Contact.Active_Semester__r.Term_Number__c,Contact.Program_Batch__c
FROM User 
WHERE Id = :UserInfo.getUserId() 
LIMIT 1];
Integer previousTermNumber = Integer.Valueof(cUser.Contact.Active_Semester__r.Term_Number__c)- 1;
System.debug('User Info: ' + JSON.serialize(cUser));

hed__term__c resultSemester =[select id from hed__term__c where Term_Number__c=: previousTermNumber and Program_Batch__c=:cUser.Contact.Program_Batch__c];

if (cUser.Contact.Active_Semester__c != null) {
System.debug('Active Semester Found: ' + cUser.Contact.Active_Semester__c);

// Fetch the list of results for the active semester
dWpr.list_Results = [SELECT Id, Secured_External_Marks__c, Secured_Internal_Marks__c, No_of_Credits__c,Grade_Points__c, 
Examination_Month_Year__c, Grade__c, CGPA__c, SGPA__c,Credit_Points__c,
Total_Secured_Marks_Course__c, Course__r.Name, Course__r.hed__Course_ID__c,hed__Term__r.Rve_SEE_Result_Date__c, 
Course__r.Total_Maximum_Marks_IA_External__c,hed__Result__c,AppliedForRevaluation__c, AppliedForPhotoCopy__c,
Fee_Paid_For_Photocopy__c,Fee_Paid_For_Revaluation__c,Photocopy_Uploaded__c
FROM hed__Term_Grade__c  
// WHERE hed__Term__c = :cUser.Contact.Active_Semester__c  
WHERE hed__Term__c = :resultSemester.Id
AND  Course__r.Revaluation_Photocopy_is_Required__c = true
AND Course__c!=''
ORDER BY Course__r.Course_Type_Logisys__c DESC];

System.debug('Fetched Results: ' + JSON.serialize(dWpr.list_Results));
} else {
System.debug('No active semester found.');
}
// Include Program Type in the response
dWpr.programType = cUser.Contact.Program_Type__c;
System.debug('Program Type: ' + dWpr.programType);
return dWpr;
} catch (Exception e) {
System.debug('Error fetching results: ' + e.getMessage());
throw new AuraHandledException('Error fetching student results: ' + e.getMessage());
}
}*/
    
    @AuraEnabled
    public static dataWpr fetchStudentResults() {
        dataWpr dWpr = new dataWpr();
        dWpr.list_Results = new List<hed__Term_Grade__c>();
        
        try {
            User cUser = [
                SELECT Id, ContactId,
                Contact.Program_Batch__c,
                Contact.Program_Type__c,
                Contact.Active_Semester__c,
                Contact.Active_Semester__r.Term_Number__c
                FROM User 
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            
            Contact student = cUser.Contact;
            if (student == null || student.Program_Batch__c == null || 
                student.Active_Semester__c == null || student.Active_Semester__r.Term_Number__c == null) {
                    throw new AuraHandledException('Missing academic information.');
                }
            
            Integer currentTermNumber = Integer.valueOf(student.Active_Semester__r.Term_Number__c);
            Id programBatchId = student.Program_Batch__c;
            Id activeSemesterId = student.Active_Semester__c;
            Id resultSemesterId;
            
            // Total terms in the program
            AggregateResult[] termCountResult = [
                SELECT COUNT(Id) total
                FROM hed__Term__c
                WHERE Program_Batch__c = :programBatchId
            ];
            Integer totalTermsInBatch = (Integer) termCountResult[0].get('total');
            
            System.debug('Current Term Number: ' + currentTermNumber + ', Total Terms: ' + totalTermsInBatch);
            
            if (currentTermNumber == 1) {
                return dWpr; // No previous results
            }
            
            // Default: use previous term
            Integer prevTerm = currentTermNumber - 1;
            List<hed__Term__c> prevTerms = [
                SELECT Id 
                FROM hed__Term__c
                WHERE Program_Batch__c = :programBatchId
                AND Term_Number__c = :prevTerm
                LIMIT 1
            ];
            
            // Check if current semester (final) has result records
            Boolean finalSemResultsAvailable = false;
            if (currentTermNumber == totalTermsInBatch) {
                List<hed__Term_Grade__c> finalTermGrades = [
                    SELECT Id
                    FROM hed__Term_Grade__c
                    WHERE hed__Term__c = :activeSemesterId
                    LIMIT 1
                ];
                finalSemResultsAvailable = !finalTermGrades.isEmpty();
            }
            
            // Final logic to pick term for result
            if (finalSemResultsAvailable) {
                resultSemesterId = activeSemesterId;
                System.debug('Final semester results available: showing final term.');
            } else if (!prevTerms.isEmpty()) {
                resultSemesterId = prevTerms[0].Id;
                System.debug('Showing previous term results.');
            } else {
                resultSemesterId = activeSemesterId;
                System.debug('Fallback to current term (previous not found).');
            }
            
            // Fetch result records
            dWpr.list_Results = [
                SELECT Id, Secured_External_Marks__c, Secured_Internal_Marks__c, No_of_Credits__c, Grade_Points__c,
                Examination_Month_Year__c, Grade__c, CGPA__c, SGPA__c, Credit_Points__c,
                Total_Secured_Marks_Course__c, Course__r.Name, Course__r.hed__Course_ID__c, 
                hed__Term__r.Rve_SEE_Result_Date__c, Course__r.Total_Maximum_Marks_IA_External__c,
                hed__Result__c, AppliedForRevaluation__c, AppliedForPhotoCopy__c,Revaluation_End_Date__c, Photocopy_End_Date__c,
                Fee_Paid_For_Photocopy__c, Fee_Paid_For_Revaluation__c, Photocopy_Uploaded__c,Results_Announced_Date__c
                FROM hed__Term_Grade__c
                WHERE hed__Term__c = :resultSemesterId
                AND Course__r.Revaluation_Photocopy_is_Required__c = true
                AND Course__c != null
                ORDER BY Course__r.Course_Type_Logisys__c DESC
            ];
            
            dWpr.programType = student.Program_Type__c;
            return dWpr;
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Unable to fetch results. ' + e.getMessage());
        }
    }
    
    
    /*******************************chnages ended here**********************************************/
    
    public class dataWpr{
        //@AuraEnabled public String selectedSem{get;set;}
        @AuraEnabled public hed__Term_Grade__c summaryRec{get;set;}
        @AuraEnabled public List<hed__Term_Grade__c> list_Results{get;set;}
        @AuraEnabled public String programType;
    }
}