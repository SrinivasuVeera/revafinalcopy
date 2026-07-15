global class UpdateEligibleStudentBatch implements Database.Batchable<sObject>{
   // Instance variable, not static
    public Set<Id> ActiveProgramBatch;
    
    // Constructor
    global UpdateEligibleStudentBatch(Set<Id> ActiveProgramBatch) {
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
    
    global void execute(Database.BatchableContext BC, List<Contact> contacts)
    {
         List<contact>EligibleStudents = new List<contact>();
            List<Contact> listToUpdateEligible = new List<Contact>();
            
            try{
            
             //   System.debug('contacts=> '+contacts);
                System.debug('contacts=> '+contacts.size());
                Set<Id>ContactId = new set<ID>();
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
                            
                            for(Contact con: contacts)
                        {
                            ContactId.add(con.Id);
                        }
                
                List<Student_Fee__c>StudentFees = [Select Id,Contact__c,Contact__r.Total_average_current_sem_attendance__c,
                                                   Contact__r.Active_Semester__r.Term_Number__c,Fee_Year__c,Amount_Pending__c from Student_Fee__c 
                                                   where Contact__c In:ContactId];
              //  SYstem.debug('StudentFees=> '+StudentFees);
              //  SYstem.debug('StudentFees=> '+StudentFees.size());
                // Iterate through contacts
                Map<Id, Boolean> contactFeeCheckMap = new Map<Id, Boolean>();
                
                set<ID>ContactIds = new set<ID>();
                for (Student_Fee__c fee : StudentFees) {
                    Boolean allPendingAmountsZero = true;
                    // Check if any of the student fees records have pending amount greater than zero
                    if(fee.Fee_Year__c == semesterToYearMap.get(Integer.valueof(fee.Contact__r.Active_Semester__r.Term_Number__c)))
                    {
                     //   System.debug('Feecontact=> '+fee.contact__c);
                        if (!contactFeeCheckMap.containsKey(fee.Contact__c)) {
                            contactFeeCheckMap.put(fee.Contact__c, true);
                        }
                        
                        // Check if the amount pending is greater than zero
                        if (Integer.valueOf(fee.Amount_Pending__c) > 0) {
                            contactFeeCheckMap.put(fee.Contact__c, false);
                        }
                    }
                }
                
               // System.debug('contactFeeCheckMap=> '+contactFeeCheckMap);
                
                for (Student_Fee__c fee : StudentFees) {
                //    SYstem.debug('FeeContact=> '+fee.Contact__c+' '+fee.Contact__r.Total_average_current_sem_attendance__c);
                    if (contactFeeCheckMap.containsKey(fee.contact__c) 
                        && contactFeeCheckMap.get(fee.contact__c) != null 
                        && fee.Contact__r != null 
                        && fee.Contact__r.Total_average_current_sem_attendance__c >= 75) {
                            
                            ContactIds.add(fee.contact__c);
                        }
                    
                }
                
                EligibleStudents = [Select Id,name,SRN_Number__c,MobilePhone, Father__c, Father_Name__c, Father_Mobile_Number__c,
                                    Active_Semester__r.Name,Mother_Name__c,Mother_Mobile_Number__c,Guardian__r.Name,
                                    Guardian__r.MobilePhone
                                    from Contact where ID IN:ContactIds Order By SRN_Number__c ASC];
    
                System.debug('EligibleStudents=> '+EligibleStudents.size());
                
                 if (!eligibleStudents.isEmpty()) {
                for (Contact student : eligibleStudents) {
                    student.Checking_Eligibility_for_Exam__c = 'InEligible';
                    listToUpdateEligible.add(student);
                }
            }
            
            // Update only if there are ineligible students to update
            if (!listToUpdateEligible.isEmpty()) {
                update listToUpdateEligible;
            }
                
    }
        catch(Exception e){
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
            //   return new List<contact>();
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
    
}