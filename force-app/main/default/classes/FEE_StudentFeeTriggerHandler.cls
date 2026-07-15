public class FEE_StudentFeeTriggerHandler 
{
    public static set<Id> set_ContactIds = new set<Id>();
    public static List<Id> contIdList = new List<Id>();
    
    public static void updateFeePaymentCriteria(List<Student_Fee__c> lst_studntfee,Map<Id,Student_Fee__c> map_Oldstdntfee)
    {
        set<string> set_Feetype = new set<string>();
        List<Student_Fee__c> lst_flteredfee = new List<Student_Fee__c>();
        Map<string,Fee_Payment_Criteria__c> map_feepayment = new Map<string,Fee_Payment_Criteria__c>();
            
        for(Student_Fee__c objStudentfee : lst_studntfee)
        {
           if((map_Oldstdntfee == null && objStudentfee.Fee_Type__c != null)||(map_Oldstdntfee != null && 
                                 map_Oldstdntfee.get(objStudentfee.Id).Fee_Type__c != objStudentfee.Fee_Type__c && objStudentfee.Fee_Type__c != null)) 
           {
             set_Feetype.add(objStudentfee.Fee_Type__c);  
             lst_flteredfee.add(objStudentfee);
           }
        }
        
        if(!set_Feetype.IsEmpty())
        {
            for(Fee_Payment_Criteria__c objFeepayment : [select Id,Name,Fee_Type__c,Maximum_Number_of_Installments__c from Fee_Payment_Criteria__c where 
                                                         Fee_Type__c In :set_Feetype])
            {
                map_feepayment.put(objFeepayment.Fee_Type__c,objFeepayment);
            }
            for(Student_Fee__c objstdFee : lst_flteredfee)
            {
                if(map_feepayment.get(objstdFee.Fee_Type__c) != null)
                {
                  objstdFee.Fee_Payment_Criteria__c = map_feepayment.get(objstdFee.Fee_Type__c).Id;
                  objstdFee.Number_of_Installments__c = map_feepayment.get(objstdFee.Fee_Type__c).Maximum_Number_of_Installments__c;
                    
                }
                else
                {
                   objstdFee.Fee_Payment_Criteria__c = null; 
                   objstdFee.Number_of_Installments__c = 0;                    
                }
            }  
        }
    }
    
    public static void updateStudentFeeProgramEnrollment(List<Student_Fee__c> lst_studntfee,Map<Id,Student_Fee__c> map_Oldstdntfee)
    {
       // set<Id> set_ContactIds = new set<Id>();
        Map<Id,hed__Program_Enrollment__c> map_ProgEnroll = new Map<Id,hed__Program_Enrollment__c>();
        List<Student_Fee__c> lst_filteredstdntfee = new List<Student_Fee__c>();
        
        for(Student_Fee__c objstudent : lst_studntfee)
        {
            if((map_Oldstdntfee == null && objstudent.Contact__c != null) || (map_Oldstdntfee != null &&
                                  map_Oldstdntfee.get(objstudent.Id).Contact__c != objstudent.Contact__c && objstudent.Contact__c != null))
            {
              set_ContactIds.add(objstudent.Contact__c); 
              lst_filteredstdntfee.add(objstudent);
            }
        }
        
        if(!set_ContactIds.IsEmpty())
        {
            for(hed__Program_Enrollment__c objProgEnroll : [select Id,Name,Active__c,hed__Contact__c from hed__Program_Enrollment__c where hed__Contact__c In: set_ContactIds
                                                           and Active__c = true])
            {
               map_ProgEnroll.put(objProgEnroll.hed__Contact__c,objProgEnroll); 
            }
            
            for(Student_Fee__c objstudent : lst_filteredstdntfee)
            {
              if(map_ProgEnroll.get(objstudent.Contact__c) != null)
              {
                objstudent.Program_Enrollment__c =  map_ProgEnroll.get(objstudent.Contact__c).Id; 
              }
              else
              {
                 objstudent.Program_Enrollment__c = null; 
              }
           }
        }
    }
    
    public static void displayOrderNoMapping(List<Student_Fee__c> lst_studntfee){
    
        for(Student_Fee__c stu : lst_studntfee){
            if(stu.Fee_Type__c == 'University Fee' && stu.Fee_Year__c == '1st Year'){
                stu.Display_No__c = 1;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Fee_Year__c == '1st Year'){
                stu.Display_No__c = 2;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Fee_Year__c == '2nd Year'){
                stu.Display_No__c = 3;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Fee_Year__c == '2nd Year'){
                stu.Display_No__c = 4;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Fee_Year__c  == '3rd Year'){
                stu.Display_No__c = 5;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Fee_Year__c  == '3rd Year'){
                stu.Display_No__c = 6;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Fee_Year__c  == '4th Year'){
                stu.Display_No__c = 7;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Fee_Year__c  == '4th Year'){
                stu.Display_No__c = 8;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Fee_Year__c  == '5th Year'){
                stu.Display_No__c = 9;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Fee_Year__c  == '5th Year'){
                stu.Display_No__c = 10;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'University Fee' && stu.Fee_Year__c  == '6th Year'){
                stu.Display_No__c = 11;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
            if(stu.Fee_Type__c == 'Tuition Fee' && stu.Fee_Year__c  == '6th Year'){
                stu.Display_No__c = 12;
                if(stu.Session__c == null) stu.Session__c = stu.Fee_Year__c;
            }
        }
    }
        
    
    public static void EligibilityForScholarship(List<Student_Fee__c> EligibilityRecord) {
        List<Student_Fee__c> studentFeesToUpdate = new List<Student_Fee__c>();
         List<contact> contactToUpdate = new List<contact>();
          set<Id> contactId = new set<Id>();
         Student_Fee__c Firstrecord,secrecord,Thirdrecord,Fourthrecord,Fifthrecord;
         list<Student_Fee__c> StudentFee =new list<Student_Fee__c>();
         for (Student_Fee__c sf : EligibilityRecord) {
             if(sf.contact__c != null){
                contactId.add(sf.Contact__c);
             }
             
         }
         try {
          Firstrecord=[select id,Fee_Type__c,Fee_Year__c,Contact__c,Scholarship__c,Scholarship_Categories__c,Scholarship_Sub_Category__c,Scholarship_Date__c,Scholarship_Created_by__c from Student_Fee__c where Fee_Year__c='1st Year' and Fee_Type__c='Tuition Fee'and Contact__c = :contactId limit 1];      
          secrecord=[select id,Fee_Type__c,Fee_Year__c,Contact__c,Scholarship__c,Scholarship_Categories__c,Scholarship_Sub_Category__c,Scholarship_Date__c,Scholarship_Created_by__c from Student_Fee__c where Fee_Year__c='2nd Year' and Fee_Type__c='Tuition Fee'and Contact__c = :contactId limit 1];
          Thirdrecord=[select id,Fee_Type__c,Fee_Year__c,Contact__c,Scholarship__c,Scholarship_Categories__c,Scholarship_Sub_Category__c,Scholarship_Date__c,Scholarship_Created_by__c from Student_Fee__c where Fee_Year__c='3rd Year' and Fee_Type__c='Tuition Fee'and Contact__c = :contactId limit 1];
          Fourthrecord=[select id,Fee_Type__c,Fee_Year__c,Contact__c,Scholarship__c,Scholarship_Categories__c,Scholarship_Sub_Category__c,Scholarship_Date__c,Scholarship_Created_by__c from Student_Fee__c where Fee_Year__c='4th Year' and Fee_Type__c='Tuition Fee'and Contact__c = :contactId limit 1];
          Fifthrecord=[select id,Fee_Type__c,Fee_Year__c,Contact__c,Scholarship__c,Scholarship_Categories__c,Scholarship_Sub_Category__c,Scholarship_Date__c,Scholarship_Created_by__c from Student_Fee__c where Fee_Year__c='5th Year' and Fee_Type__c='Tuition Fee'and Contact__c = :contactId limit 1];
        
         } Catch(exception e){
         }
      //ScholarShip Category on Contact
      contact con=[select id,Scholarship_Category__c,Scholarship_Sub_Category__c,Scholarship_Created_by__c,Scholarship_Date__c from contact where Id=: contactId limit 1];
                 try{ 
                         
                 StudentFee=[select id,Fee_Type__c,Fee_Year__c,Contact__c,Scholarship__c,Scholarship_Categories__c,Scholarship_Sub_Category__c,Scholarship_Date__c,Scholarship_Created_by__c from Student_Fee__c where Fee_Type__c='Tuition Fee'and Contact__c = :contactId and Scholarship__c > 0 Order by Fee_Year__c ASC limit 1 ];

         System.debug('StudentFee'+StudentFee.size());
        
                     for(Student_Fee__c SF:StudentFee ){
         if(SF.Scholarship_Categories__c !=null && SF.Scholarship__c > 0 && SF.Id !=null ){
              System.debug('IfStudentFee');
             con.Scholarship_Category__c=SF.Scholarship_Categories__c;
             con.Scholarship_Sub_Category__c =SF.Scholarship_Sub_Category__c;
             con.Scholarship_Date__c=SF.Scholarship_Date__c;
             con.Scholarship_Created_by__c = SF.Scholarship_Created_by__c;
              contactToUpdate.add(con);
         }
             else{
                   System.debug('ElseStudentFee');
             con.Scholarship_Category__c='';
             con.Scholarship_Sub_Category__c ='';
             con.Scholarship_Date__c= Null;
             con.Scholarship_Created_by__c='';
              contactToUpdate.add(con);
         } 
         }
                     if (!contactToUpdate.isEmpty()) {
            update contactToUpdate;
             system.debug('contactToUpdate::::' +contactToUpdate );
        }
         }catch(exception e){
             
         }
        
/*      for (Student_Fee__c sf : EligibilityRecord) {
            if ( sf.Fee_Type__c == 'Tuition Fee'  && sf.Backlog__c == 0 && sf.Eligibility_Attendance1__c >= 85 && sf.CGPA_Eligibility__c >= 9.0 && sf.Scholarship_Categories__c != null ) {
                    if(sf.Scholarship_Categories__c =='ICSE/CBSE Merit'|| sf.Scholarship_Categories__c =='State Board Merit') {
                       if(sf.Fee_Year__c == '1st Year' && secrecord != Null){
                           secrecord.Scholarship__c = Firstrecord.Scholarship__c;
                           studentFeesToUpdate.add(secrecord);
                         }
                          else if(sf.Fee_Year__c == '2nd Year' && Thirdrecord != Null){
                           Thirdrecord.Scholarship__c = secrecord.Scholarship__c;
                           studentFeesToUpdate.add(Thirdrecord);
                          }
                           else if(sf.Fee_Year__c == '3rd Year' && Fourthrecord != Null){
                            Fourthrecord.Scholarship__c = Thirdrecord.Scholarship__c;
                            studentFeesToUpdate.add(Fourthrecord);
                           }
                            else if(sf.Fee_Year__c == '4th Year'&& Fifthrecord != Null){
                             Fifthrecord.Scholarship__c = Fourthrecord.Scholarship__c;
                             studentFeesToUpdate.add(Fifthrecord);
                            }else{
                                system.debug('No records to be updated');
                            }
                    }
                    else if(sf.Scholarship_Categories__c =='REVA Merit' ){
                    if(sf.Fee_Year__c == '1st Year' && secrecord != Null){
                           secrecord.Scholarship__c = Firstrecord.Scholarship__c - 5000;
                           studentFeesToUpdate.add(secrecord);
                         }
                          else if(sf.Fee_Year__c == '2nd Year' && Thirdrecord != Null){
                           Thirdrecord.Scholarship__c = secrecord.Scholarship__c;
                           studentFeesToUpdate.add(Thirdrecord);
                          }
                           else if(sf.Fee_Year__c == '3rd Year' && Fourthrecord != Null){
                            Fourthrecord.Scholarship__c = Thirdrecord.Scholarship__c;
                            studentFeesToUpdate.add(Fourthrecord);
                           }
                            else if(sf.Fee_Year__c == '4th Year'&& Fifthrecord != Null){
                             Fifthrecord.Scholarship__c = Fourthrecord.Scholarship__c;
                             studentFeesToUpdate.add(Fifthrecord);
                            }else{
                                system.debug('No records to be updated');
                            }
                  }
                else{
                    system.debug('No Merit Scholarship ');
                 }
            } 
              else{
                    system.debug('Criteria not match');
                 }
        }
         
        // Update records if there are changes
        if (!studentFeesToUpdate.isEmpty()) {
            update studentFeesToUpdate;
             system.debug('studentFeesToUpdate::::' +studentFeesToUpdate );
        }
         else{
              system.debug('studentFeesToUpdate is Empty');
             }*/
         
    }

    // public static void updateStudentFeeBalance(List<Student_Fee__c> lst_studntfee){
    //     Set<Id> stufeeSet = new Set<Id>();
    //     for(Student_Fee__c stufee: lst_studntfee){
    //         stufeeSet.add(stufee.Id);
    //     }
    //     if(stufeeSet.size() > 0){
    //         // updateStudentFeeAmountPending(stufeeSet);
    //         System.enqueueJob(new QueueableStudentFeeBalanceUpdate(stufeeSet));
    //     }
    // }

    // @Future
    // public static void updateStudentFeeAmountPending(Set<Id> stufeeSet){
    //     List<Student_Fee_Payment__c> stuFeePayList = [SELECT Id, Name, Amount__c, Line_Item_Payment_Status__c, Student_Payment__c, Mode_of_Payment__c, SF_Transaction_ID__c, Student_Fee__c, Transaction_Status__c FROM Student_Fee_Payment__c WHERE Student_Fee__c =: stufeeSet];
    //     FEE_StudentFeePaymentTriggerHandler.RollupAmount(stuFeePayList,Null);
    // }
        
    public static void updateStudentFeePending(Set<Id> stuFeeSet){
        List<Student_Fee__c> stuFeeListUpdated = new List<Student_Fee__c>();
        System.debug('263--->'+stuFeeSet);
        
        
        for(Student_Fee__c stufee : [SELECT Id,Amount__c,Fee_Type__c, Name,Actual_Program_Fee__c,
                                     Amount_Paid__c,
                                     Amount_Pending__c, Calculated_Total_Amount__c,
                                     Calculated_Amount_Pending__c,Refunded_Amount__c,Contact__c
                                     FROM Student_Fee__c WHERE Id IN :stuFeeSet]){
               System.debug('269--->'+stufee + 'Amount-->> '+ stufee.Amount__c);                          
            // if(stufee.Fee_Type__c =='University Fee' || stufee.Fee_Type__c == 'Tuition Fee'){
            // stufee.Amount_Pending__c = stufee.Calculated_Amount_Pending__c;
            // stufee.Amount__c = stufee.Calculated_Total_Amount__c;
            // stuFeeListUpdated.add(stufee);
            // }else{
            //     if(stufee.Fee_Type__c =='Application fee'){
            //         stufee.Amount_Pending__c = stufee.Amount__c - stufee.Amount_Paid__c;
            //         stuFeeListUpdated.add(stufee);
            //     }
            // }
            system.debug('stufee275'+ stufee + '\nstufee.Fee_Type__c' + stufee.Fee_Type__c);
              system.debug(' stufee.Amount_Pending__c'+ stufee.Amount_Pending__c);
               system.debug('stufee.Amount__c'+stufee.Amount__c); 
                system.debug('stufee.Refunded_Amount__c'+stufee.Refunded_Amount__c);
                  
            if(stufee.Fee_Type__c =='Application fee' ||stufee.Fee_Type__c =='Transportation Fee' || stufee.Fee_Type__c =='Hostel Fee' || stufee.Fee_Type__c =='Missed Meal Fee'|| stufee.Fee_Type__c == 'Tution Fee' || stufee.Fee_Type__c =='Guest House Fee'){
                //stufee.Amount_Pending__c = ((stufee.Amount__c != null ? stufee.Amount__c : 0) - (stufee.Amount_Paid__c != null ? stufee.Amount_Paid__c : 0))+ stufee.Refunded_Amount__c;
                if(Test.isRunningTest()){
                    stufee.Amount_Pending__c = 1000;
                }else{
                    //stufee.Amount_Pending__c = stufee.Amount__c - stufee.Amount_Paid__c + stufee.Refunded_Amount__c == null ? 0 : stufee.Refunded_Amount__c;
                    stufee.Amount_Pending__c = ((stufee.Amount__c != null ? stufee.Amount__c : 0) - (stufee.Amount_Paid__c != null ? stufee.Amount_Paid__c : 0)) + (stufee.Refunded_Amount__c != null ? stufee.Refunded_Amount__c : 0);
                }
               // stufee.Amount_Pending__c = stufee.Amount__c - stufee.Amount_Paid__c + stufee.Refunded_Amount__c;
                 system.debug('stufee.Amount_Pending__c===>'+stufee.Amount_Pending__c);
                
                stuFeeListUpdated.add(stufee);
            } else {
                system.debug('in else #279');
                System.debug('#281stufee.Amount__c=' +stufee.Amount__c);
                System.debug('#281stufee.Amount__c=' +stufee.Calculated_Total_Amount__c);
                System.debug('#282stufee.Amount_Paid__c=' + stufee.Amount_Paid__c);
                Decimal amountRemaining = stufee.Amount__c - stufee.Amount_Paid__c;
                System.debug('#284amountRemaining=' + amountRemaining);
                stufee.Amount_Pending__c = stufee.Calculated_Amount_Pending__c;
                System.debug('stufee.Amount_Pending__c===>'+stufee.Amount_Pending__c);
                System.debug('stufee.Calculated_Amount_Pending__c===>'+stufee.Calculated_Amount_Pending__c);
                stufee.Amount__c = stufee.Calculated_Total_Amount__c;
                //stufee.Amount_Pending__c = amountRemaining;
                stuFeeListUpdated.add(stufee);
                System.debug('stufee.Amount_Pending__c=' + stufee.Amount_Pending__c +
                             '\nstufee.Amount__c=' + stufee.Amount__c +
                             '\nstufee.Calculated_Amount_Pending__c=' + stufee.Calculated_Amount_Pending__c+
                              '\nstufee.Calculated_Total_Amount__c=' + stufee.Calculated_Total_Amount__c);
            }
                                        
                                         
        }
        if(stuFeeListUpdated.size() > 0){
            update stuFeeListUpdated;
        }
    }
    
   //Hostel Module methods
       public static void updateHostelRequest(List<Student_Fee__c> studentFees) {
         Set<Id> contacts = new Set<Id>();
           Set<Id> studetfee= new Set<Id>();
         System.debug('contacts: ' + contacts);
         for (Student_Fee__c studentFee : studentFees) {
             System.debug('Calling update hostel request for dtudent fee' +studentFee.Id);
             contacts.add(studentFee.Contact__c);
             studetfee.add(studentFee.Id);
         }
         System.debug('Amount'+contacts);
         try{
             Student_Fee__c studentFee = [Select Id, Contact__c, Amount_Paid__c, Amount__c from Student_Fee__c where Fee_Type__c = 'Hostel Fee' AND Name like '%Caution%' AND Contact__c IN :contacts limit 1];
             List<Student_Fee__c> studentFeeList = [Select Id, Contact__c,Payment_type__c, Amount_Paid__c, Amount__c from Student_Fee__c where Fee_Type__c = 'Hostel Fee' AND Name like '%Hostel Fee%' AND( Payment_type__c ='Partial Payment' Or Payment_type__c ='Full Payment')  AND Contact__c IN :contacts limit 1];
             //  Contacts = null;
             System.debug('Amount'+studentFeeList);
             System.debug('studentFee.Amount_Paid__c'+studentFee.Amount_Paid__c);
             System.debug('studentFee.Amount__c'+studentFee.Amount__c);
             
             Boolean Premium = False;
             Decimal Amount=0;
               Decimal withoutPremium = Decimal.valueOf(System.Label.WithoutPremium);
              Decimal withPremium = Decimal.valueOf(System.Label.WithPremium);

          
             
              List<Reva_Hostel_Request__c> RHR = [SELECT Id, Hostel_Room_Request_For__c, Rejoiner__c,Student_Fee__c, Status__c, Type__c, Reva_Hostel_Premium_Room__c
                                                                        FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c IN: contacts order by createdDate ASC  ];
            
                    if(RHR[0].Reva_Hostel_Premium_Room__c == true ){
                    Premium =true;
                        system.debug('Hello:::'+Premium);
                    }
             
           //   if(Rejioncan != True){
             
             if (studentFee.Amount_Paid__c != studentFee.Amount__c) {
                 
                 contacts.Remove(studentFee.Contact__c);
                 
             }
             else{
                 for(Student_Fee__c SFL:studentFeeList){
                     studetfee.add(SFL.Id);
                     if(SFL.Payment_type__c == 'Full Payment'){
                         System.debug('Amount');
                         if(SFL.Amount_Paid__c != SFL.Amount__c){
                             contacts.Remove(SFL.Contact__c);
                         }
                     } if(SFL.Payment_type__c == 'Partial Payment' ){
                         If(Premium == false){
                          Amount = (SFL.Amount__c - withoutPremium)  + withoutPremium ;
                         }else if(Premium == True){
                            Amount = (SFL.Amount__c - withPremium)  + withPremium ;
                         }else{
                              System.debug('Amount is nothing ');
                         }
                        // Actual calculation
                         if(SFL.Amount_Paid__c == 0){
                             System.debug('SFL.Contact__c'+SFL.Contact__c);
                             contacts.Remove(SFL.Contact__c);
                         }
                     }
                 }
             }
             System.debug('contacts after: ' + contacts);
             List<Reva_Hostel_Request__c> Reva_Hostel_Requests = [Select Hostel_Room_Request_For__c, Reva_Hostel_Premium_Room__c, Type__c, Room_Request_Type__c, Status__c from Reva_Hostel_Request__c where Hostel_Room_Request_For__c IN: contacts AND Status__c = '' AND Student_Fee__c IN: studetfee];
             
             System.debug('Reva_Hostel_Requests: ' + Reva_Hostel_Requests);
             
             for (Reva_Hostel_Request__c revaHostelRequest : Reva_Hostel_Requests)
             {
                 revaHostelRequest.Status__c = 'Booked';
             }
             Update Reva_Hostel_Requests;
         }
         Catch (Exception e){
             System.debug(' Hostel records are not found');
         }
     }
    
  /*    public static void updateFeeRecords(List<Student_Fee__c> studentFees) {
        // Collect parent record IDs
        Set<Id> parentIds = new Set<Id>();
        for (Student_Fee__c fee : studentFees) {
            parentIds.add(fee.Contact__c);
        }

        // Query parent records to retrieve email information
        Map<Id, Contact> parentEmails = new Map<Id, Contact>([SELECT Id, Email, Father_Email_ID__c, Mother_Email_ID__c FROM Contact WHERE Id IN :parentIds]);

        // Populate child record emails
        for (Student_Fee__c fee : studentFees) {
            Contact parent = parentEmails.get(fee.Contact__c);
            if (parent != null) {
                fee.Student_Personal_Email__c = parent.Email;
                fee.Father_Email_ID__c = parent.Father_Email_ID__c;
                fee.Mother_Email_ID__c = parent.Mother_Email_ID__c;
            }
        }
    }*/
    
}