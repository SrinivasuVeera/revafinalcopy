/*public without sharing class ASM_StdResultListView {
    @AuraEnabled
    public static List<hed__Term_Grade__c> fetchData() {
        // Fetch the current user and their contact
        User currentUser = [SELECT Id, ContactId, Contact.Active_Semester__c, Contact.Active_Semester__r.Name 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId()];
        
        String contactId;
        Contact contactRecord;
        Integer labelDate = Integer.valueOf(System.Label.SEE_Results_schedule_time);
        Date actualDate = System.today().addDays(labelDate);
        
        // Fetch the contact record based on the user's contact ID
        contactRecord = [SELECT Id, Name, RecordType.Name, ReportsToId, Current_Year__c, 
                         (SELECT Id, Name, Fee_Year__c, Amount_Pending__c 
                          FROM Student_Fees__r 
                         ) 
                         FROM Contact 
                         WHERE Id = :currentUser.ContactId 
                         LIMIT 1];
        if (contactRecord.RecordType.Name == utility.Contact_RecType_Student) {
            contactId = contactRecord.Id;
        } else if (contactRecord.RecordType.Name == utility.Contact_RecType_Parent) {
            contactId = contactRecord.ReportsToId;
        }
        
        if (contactRecord.Student_Fees__r != null && !contactRecord.Student_Fees__r.isEmpty()) {
            system.debug('student fee records###'+contactRecord.Student_Fees__r);
            for (Student_Fee__c fee : contactRecord.Student_Fees__r) {
                System.debug('Fee Year: ' + fee.Fee_Year__c);
                system.debug('pending amount'+fee.Amount_Pending__c);
                
                if (fee.Fee_Year__c == contactRecord.Current_Year__c && fee.Amount_Pending__c != 0) {
                    return new List<hed__Term_Grade__c>();
                }
            }
        }
        
        return [SELECT Id, Recent_Result_Updated_Date__c, hed__Term__c, hed__Term__r.Name, 
                Total_Maximum_Marks_Semester__c, Total_Secured_Marks_Semester__c, Examination_Month_Year__c
                ,Course__r.Name,Course__r.Course_Type_Logisys__c,Course__r.Total_Maximum_Marks_IA_External__c
                FROM hed__Term_Grade__c 
                WHERE hed__Contact__c = :contactId 
                AND Result_Summary__c = null  
                AND hed__Term__r.Rve_SEE_Result_Date__c <= :actualDate 
                ORDER BY hed__Term__r.Term_Number__c ASC];
    }
}
*/


public without sharing class ASM_StdResultListView {
	@AuraEnabled
    public static List<hed__Term_Grade__c> fetchData(){
        User cUser = [SELECT Id,ContactId,Contact.Active_Semester__c,Contact.Active_Semester__r.Name FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('cUser=> '+cUser);
        string ContactId;
        Contact objcon = new Contact();
        Integer labledate = integer.valueof(System.Label.SEE_Results_schedule_time);
        date actualdate = System.today().addDays(labledate);
        System.debug('actualdate=> '+actualdate);
        objcon =[select Id,Name,Recordtype.Name,ReportsToId from Contact where id=: cUser.ContactId];
        System.debug('objcon=> '+objcon);        
        if(objcon.Recordtype.Name == utility.Contact_RecType_Student) ContactId =objcon.id;
        else if(objcon.Recordtype.Name == utility.Contact_RecType_Parent) ContactId =objcon.ReportsToId;
        return [SELECT Id,Recent_Result_Updated_Date__c,hed__Term__c,hed__Term__r.Name,Total_Maximum_Marks_Semester__c,
                Total_Secured_Marks_Semester__c,Examination_Month_Year__c FROM hed__Term_Grade__c 
                WHERE hed__Contact__c =: ContactId AND Result_Summary__c = null  AND hed__Term__r.Rve_SEE_Result_Date__c <=: actualdate   ORDER BY hed__Term__r.Term_Number__c ASC];
    }
}