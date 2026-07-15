global class PenaltyFeeLE_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        return Database.getQueryLocator([
            SELECT Id, Name, Student_Status__c, RecordTypeId, Program_Type__c, School_Name__c, Program_Batch_Name__c, Admission_Mode__c, Quota__c, Caste_Category__c, Active_Semester__r.hed__Start_Date__c,
            (SELECT Id, Name, Fee_Year__c, Fee_Type__c, Due_Date__c,Actual_Program_Fee__c, Session__c, Amount__c, Amount_Pending__c,Contact__r.Active_Semester__r.IA_1_Start_date__c,Contact__c,Program_Enrollment__r.hed__Program_Plan__c,Contact__r.Enrollment_Type__c
             FROM Student_Fees__r 
             WHERE Amount_Pending__c > 0 AND Fee_Type__c IN ('University Fee', 'Tuition Fee') and Fee_Year__c ='2nd Year') 
            FROM Contact 
            WHERE Student_Status__c = 'Pursuing' AND RecordTypeId = :ContactRecTypeId AND Primary_Academic_Program_Name__c !='Bachelor of Commerce Sanjaynagar' AND Enrollment_Type__c = 'Lateral Entry'
            AND (Admission_Mode__c NOT IN ('CET','DCET','PGCET') OR Quota__c !='Government Quota' OR Caste_Category__c NOT IN ('ST','SC'))
            //AND Id = '0035j00000rPKCdAAO'
            AND Active_Semester__r.hed__Start_Date__c != null AND Active_Semester__r.Active__c = true AND Active_Semester__r.Term_Number__c = 3           
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> ListCon) {
        List<Student_Fee__c> lst_UpStuFee = new List<Student_Fee__c>();
        List<Contact> contactsToUpdate = new List<Contact>();
        
        
        for(Contact con : ListCon)
        {
            try
            {
            Boolean paymentMade = True;
            Decimal Totalamount = 0;
            system.debug('Contact==='+con);
            Date startDate;
            Integer daysBetween = 0;
            string feeyear;
            Set<Id> set_BatchIds = new Set<Id>();
            map<id,list<hed__Term__c>> map_term = new map<id,list<hed__Term__c>>();
            for (hed__Program_Enrollment__c objProgEnroll : [SELECT Id, Active__c, hed__Program_Plan__c, hed__Contact__c FROM hed__Program_Enrollment__c 
                                                             WHERE hed__Contact__c = :con.Id AND Active__c = true
                                                            ]) {
                                                                set_BatchIds.add(objProgEnroll.hed__Program_Plan__c);
                                                            }
            Contact stud = [SELECT Id,Active_Semester__c,Active_Semester__r.IA_1_Start_date__c,Active_Semester__r.Term_Number__c from Contact WHERE Id =:con.Id LIMIT 1];
            if(stud !=null && stud.Active_Semester__c !=null && stud.Active_Semester__r.IA_1_Start_date__c !=null){
                startDate = stud.Active_Semester__r.IA_1_Start_date__c;
                daysBetween = startDate.daysBetween(Date.today());
                if(stud.Active_Semester__r.Term_Number__c == 3 || stud.Active_Semester__r.Term_Number__c == 4){
                    feeyear = '2nd Year'; 
                }
            }           
            if(!set_BatchIds.isEmpty())
            {
                for(hed__Term__c objTerm : [Select Id,Name,Active__c,hed__Start_Date__c,IA_1_Start_date__c,IA_2_Start_date__c,Program_Batch__c,Term_Number__c from hed__Term__c 
                                            where Program_Batch__c in: set_BatchIds and Term_Number__c =3])
                {
                    if(map_term.get(objTerm.Program_Batch__c) == null)
                    {
                        list<hed__Term__c> lst_term = new list<hed__Term__c>();
                        lst_term.add(objTerm);
                        map_term.put(objTerm.Program_Batch__c,lst_term);
                    }
                    else
                    {
                        map_term.get(objTerm.Program_Batch__c).add(objTerm);
                    }
                }
                for(Student_Fee__c objStu : con.Student_Fees__r)
                {
                    system.debug('fee list==='+objStu);                    
                    if(map_term.get(objStu.Program_Enrollment__r.hed__Program_Plan__c) != null)
                    {
                        System.debug('session');
                        List<String> strList = new list<String>();
                        if(objStu.Session__c != null)
                        {
                            strList = objStu.Session__c.split('');
                        }
                        for(hed__Term__c objTerm : map_term.get(objStu.Program_Enrollment__r.hed__Program_Plan__c))
                        {
                            if (!strList.isEmpty() && strList[0] == '2' && (objTerm.Term_Number__c == 3 || objTerm.Term_Number__c == 4) && objTerm.Active__c == true && objStu.Contact__r.Enrollment_Type__c == 'Lateral Entry') {
                                Totalamount += objStu.Amount_Pending__c;                                
                                system.debug('Totalamount2===' + Totalamount);                                                          
                                                
                            }
                        }
                    }
                }
                Set<Id> processedContactIds = new Set<Id>();
                Map<Id, Student_Fee__c> existingPenaltyMap = new Map<Id, Student_Fee__c>();         
                
                for (Student_Fee__c existingPenalty : [SELECT Id, Contact__c,Fee_Type__c,Due_Date__c, Amount_Pending__c, Actual_Program_Fee__c, Amount__c,Amount_Paid__c 
                                                       FROM Student_Fee__c WHERE Fee_Type__c =:'Penalty Fee' AND Contact__c =:con.id AND Fee_Year__c =:feeyear
                                                      ]) {
                                                          existingPenaltyMap.put(con.Id, existingPenalty);
                                                      }
                Student_Fee__c penaltyFee = existingPenaltyMap.get(con.Id);
                if (Totalamount > 0 || (penaltyFee !=null && penaltyFee.Amount_Pending__c > 0)) {
                    system.debug('TOTAL AMOUNT==='+Totalamount);
                    Decimal penaltyAmount = 0;
                    paymentMade = true; 
                    Integer daysWithinRange = daysBetween - 30;
                    system.debug('daysWithinRange==' + daysWithinRange);
                    system.debug('daysBetween==' + daysBetween);
                    system.debug('Totalamount===' + Totalamount);
                    Integer thisYear = Date.today().year();
                    // For days between 31 and 45
                    if (daysBetween > 0 && daysBetween <= 15) {
                        penaltyAmount = 1500;
                        Date dueDate1 = startDate;
                        if (existingPenaltyMap.containsKey(con.Id)) {
                            Student_Fee__c existingPenalty = existingPenaltyMap.get(con.Id);
                            if (existingPenalty.Amount__c < penaltyAmount) {
                                Decimal additionalPenalty = penaltyAmount - existingPenalty.Amount__c;
                                existingPenalty.Amount_Pending__c += additionalPenalty;
                                existingPenalty.Actual_Program_Fee__c += additionalPenalty;
                                existingPenalty.Amount__c += additionalPenalty;
                                lst_UpStuFee.add(existingPenalty);
                            }
                        }else {
                            Student_Fee__c objNewStuFee = new Student_Fee__c(
                                Name = 'Penalty Fee '+thisYear,
                                Fee_Type__c = 'Penalty Fee', 
                                Contact__c = con.Id,
                                Amount__c = penaltyAmount,
                                Due_Date__c = dueDate1,
                                Session__c = feeyear,
                                Fee_Year__c = feeyear,
                                Amount_Pending__c = penaltyAmount,
                                Actual_Program_Fee__c = penaltyAmount
                            );
                            lst_UpStuFee.add(objNewStuFee);
                        } 
                    }
                    // For days between 46 and 60
                    else if (daysBetween > 15 && daysBetween <= 30) {
                        penaltyAmount = 3000;
                        if (existingPenaltyMap.containsKey(con.Id)) {
                            Student_Fee__c existingPenalty = existingPenaltyMap.get(con.Id);
                            if (existingPenalty.Amount__c < penaltyAmount) {
                                Decimal additionalPenalty = penaltyAmount - existingPenalty.Amount__c;
                                existingPenalty.Amount_Pending__c += additionalPenalty;
                                existingPenalty.Actual_Program_Fee__c += additionalPenalty;
                                existingPenalty.Amount__c += additionalPenalty;
                                lst_UpStuFee.add(existingPenalty);
                            }
                        }
                       } 
                    
                    /* else if (daysBetween > 30) {
                        Contact conup = new Contact(
                            Id = con.Id,
                            Attendance_Blocked__c = true
                        );
                        contactsToUpdate.add(conup);
                    }  */                   
                }
                Boolean isTotalAmountPaid = Totalamount == 0;
                system.debug('boolean total amount==='+isTotalAmountPaid);
                Boolean isPenaltyPaid = !existingPenaltyMap.isEmpty() && existingPenaltyMap.get(con.Id).Amount_Pending__c == 0;
                
               if (isTotalAmountPaid && con.Attendance_Blocked__c == true) {
                    if (!existingPenaltyMap.isEmpty() && existingPenaltyMap.containsKey(con.Id)) {
                        Decimal pendingAmt = existingPenaltyMap.get(con.Id).Amount_Pending__c;
                        if (pendingAmt == 0) {                           
                            contactsToUpdate.add(new Contact(
                                Id = con.Id,
                                Attendance_Blocked__c = false
                            ));                           
                        }
                    }else {
                        contactsToUpdate.add(new Contact(
                            Id = con.Id,
                            Attendance_Blocked__c = false
                        ));
                    }                   
                }
            }
            } catch (Exception e){
                System.debug('Failed to process contact Id=' + con.Id + ', error: ' + e.getMessage());
            }
        }
        if (!lst_UpStuFee.isEmpty()) {
            try {
                upsert lst_UpStuFee;
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('Error on row ' + i + ': ' + e.getDmlMessage(i));
                }
                System.debug('DML exception: ' + e.getMessage());
            }
        }
        if (!contactsToUpdate.isEmpty()) {
            try {
                update contactsToUpdate;
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug('Error on row ' + i + ': ' + e.getDmlMessage(i));
                }
                System.debug('DML exception: ' + e.getMessage());
            }
        }       
        
        
        System.debug('records===' + lst_UpStuFee);
    }
    
    global void finish(Database.BatchableContext BC) {
        // Any cleanup or post-processing logic can be added here
    }
}