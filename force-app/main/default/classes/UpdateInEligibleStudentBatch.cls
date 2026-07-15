global class UpdateInEligibleStudentBatch implements Database.Batchable<sObject>{
   // Instance variable, not static
    public Set<Id> ActiveProgramBatch;
    
    // Constructor
    global UpdateInEligibleStudentBatch(Set<Id> ActiveProgramBatch) {
        this.ActiveProgramBatch = ActiveProgramBatch;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Use Database.getQueryLocator for batchable query
        return Database.getQueryLocator([
            SELECT Id 
            FROM Contact
            WHERE Student_Status__c = 'Pursuing'
            AND Program_Batch__c IN :ActiveProgramBatch
            AND SRN_Number__c != null
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactsWithLowAttendance)
    {
        List<contact>IneligibleStudents = new List<contact>();
        List<Contact> listToUpdateinEligible = new List<Contact>();
        
        try{
            
            set<ID>ContactId = new set<ID>();
            
            for(Contact con: contactsWithLowAttendance)
            {
                ContactId.add(con.Id);
            }
            
            List<Student_Fee__c>StudentFees = [Select Id,Contact__c,Contact__r.Total_average_current_sem_attendance__c,
                                               Contact__r.Active_Semester__r.Term_Number__c,Fee_Year__c,Amount_Pending__c from Student_Fee__c 
                                               where Contact__c In:ContactId];
            
            Map<Integer, String> semesterToYearMap = new Map<Integer, String>{
                1 => '1st year',
                    2 => '1st year',
                    3 => '2nd year',
                    4 => '2nd year',
                    5 => '3rd year',
                    6 => '3rd year',
                    7 => '4th year',
                    8 => '4th year',
                    9 => '5th year',
                    10 => '5th year'
                    };
                        
                        set<ID>ContactIds = new set<ID>();
            
            for (Student_Fee__c fee : StudentFees) {
                Boolean allPendingAmountsZero = true;
                // Check if any of the student fees records have pending amount greater than zero
                if(fee.Fee_Year__c == semesterToYearMap.get(Integer.valueof(fee.Contact__r.Active_Semester__r.Term_Number__c)))
                {
                    if (fee.Amount_Pending__c > 0) {
                        ContactIds.add(fee.contact__c);
                    }
                    else if(fee.Amount_Pending__c == 0)
                    {
                        if(fee.Contact__r.Total_average_current_sem_attendance__c < 75)
                        {
                            ContactIds.add(fee.Contact__c);                              
                        }
                    }
                }
            }
            
            InEligibleStudents = [SELECT Id, Name, Program_Batch__r.Name, Primary_Academic_Program__r.Name, SRN_Number__c, Active_Semester__r.Name,
                                  MobilePhone, Father__c, Father_Name__c, Father_Mobile_Number__c,Mother_Name__c,Mother_Mobile_Number__c,Guardian__r.Name,Guardian__r.MobilePhone
                                  FROM Contact
                                  WHERE Id IN :ContactIds Order By SRN_Number__c ASC];
            
            System.debug('InEligibleStudents=> '+InEligibleStudents.size());
            
            if (!ineligibleStudents.isEmpty()) {
                for (Contact student : ineligibleStudents) {
                    student.Checking_Eligibility_for_Exam__c = 'InEligible';
                    listToUpdateinEligible.add(student);
                }
            }
            
            // Update only if there are ineligible students to update
            if (!listToUpdateinEligible.isEmpty()) {
                update listToUpdateinEligible;
            }
            // for(Contact conlist : InEligibleStudents) {
            //   //  System.debug('ineligible>>' + conlist.Name + '<<>>' + conlist.SRN_Number__c);
            // }
            
            
            //  return InEligibleStudents;
            
        }catch(Exception e){
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            //   return new List<contact>();
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
    
}