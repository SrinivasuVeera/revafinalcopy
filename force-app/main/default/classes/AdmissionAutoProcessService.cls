public with sharing class AdmissionAutoProcessService {
 // StudentPaymentTrigger also modified  push that class also 
 // AdmissionAutoProcessBatch apex batch class 
 // AdmissionAutoProcessScheduler batch 
    public static void processApplications() {

        List<hed__Application__c> applications = [
            SELECT Id,
                   hed__Applicant__c,
                   hed__Applying_To__c,
                   hed__Application_Status__c,
                   Fee_Structure_Defined__c, hed__Applicant__r.Program_Batch__r.Name
            FROM hed__Application__c
            WHERE hed__Application_Status__c = 'In Review'
        ];

        if(applications.isEmpty()){
            System.debug('No Applications Found');
            return;
        }

        for(hed__Application__c app : applications){

            try{

                processApplication(app);

            }catch(Exception ex){

                System.debug('Automation Failed : '+ex.getMessage());

            }

        }

    }

    public  static void processApplication(hed__Application__c app){

        System.debug('Processing : '+app.Id);

        if(!validateFeeMaster(app)){
            System.debug('Fee Master Not Active');
            return;
        }

        app.hed__Application_Status__c = 'Interested';

        update app;

        createStudentFee(app);

        generatePayment(app);

    }

  
    private static Boolean validateFeeMaster(hed__Application__c app){

    Contact con = [
        SELECT Id,
               Program_Batch__c,
               Select_Category__c
        FROM Contact
        WHERE Id = :app.hed__Applicant__c
        LIMIT 1
    ];

    // Map Contact Category to Fee Master Category
    String feeMasterCategory = con.Select_Category__c;

    if(feeMasterCategory == 'Karnataka'
        || feeMasterCategory == 'Non-Karnataka'
        || feeMasterCategory == 'Indian (SAARC)'){

        feeMasterCategory = 'Indian (SAARC)';
    }
    else if(feeMasterCategory == 'Non-Resident Indian(NRI)'){

        feeMasterCategory = 'Non-Resident Indian(NRI)';
    }
    else if(feeMasterCategory == 'Foreign Nationals'){

        feeMasterCategory = 'Foreign Nationals';
    }

    List<Fee_Master__c> feeMasters = [
        SELECT Id,
               Fee_Type__c,
               Applicant_Category__c,
               IsActive__c
        FROM Fee_Master__c
        WHERE Program_Batch__c = :con.Program_Batch__c
        AND Fee_Type__c = 'Application Fee'
        AND Applicant_Category__c = :feeMasterCategory
        AND IsActive__c = true
        LIMIT 1
    ];
    System.debug('Contact Category       : ' + con.Select_Category__c);
    System.debug('Fee Master Category    : ' + feeMasterCategory);
    System.debug('Program Batch          : ' + con.Program_Batch__c);
    System.debug('Application Fee Active : ' + feeMasters.size());
   
    return !feeMasters.isEmpty();
   }

 
    private static void createStudentFee(hed__Application__c app) {

    Contact con = [SELECT Id,Program_Batch__c,Email,MobilePhone,Father_Email_ID__c, Mother_Email_ID__c, Father_Mobile_Number__c,
        Mother_Mobile_Number__c,Program_Batch__r.hed__Start_Date__c,Select_Category__c,Application_Number__c
        FROM Contact
        WHERE Id = :app.hed__Applicant__c
        LIMIT 1
    ];
        String feeMasterCategory = con.Select_Category__c;

     if(feeMasterCategory == 'Karnataka'
       || feeMasterCategory == 'Non-Karnataka'
       || feeMasterCategory == 'Indian (SAARC)'){

        feeMasterCategory = 'Indian (SAARC)';
      }
    else if(feeMasterCategory == 'Non-Resident Indian(NRI)'){

     feeMasterCategory = 'Non-Resident Indian(NRI)';
    }
   else if(feeMasterCategory == 'Foreign Nationals'){

      feeMasterCategory = 'Foreign Nationals';
    }

   System.debug('Contact Category      : ' + con.Select_Category__c);
   System.debug('Fee Master Category   : ' + feeMasterCategory);

    Integer countFee = [SELECT COUNT() FROM Student_Fee__c WHERE Contact__c = :con.Id and Fee_Type__c != 'Application Fee'];

    if(countFee > 0){
        System.debug('Student Fee already exists');
        return;
    }

    List<Fee_Master__c> feeMasters = [
        SELECT Id,Fee_Type__c,Fee_Amount__c,Applicant_Category__c,Premium_Amount__c,
               Program_Batch__r.Number_of_Years__c, Program_Batch__r.hed__Account__r.Program_Type__c
        FROM Fee_Master__c
        WHERE Program_Batch__c = :con.Program_Batch__c
        AND Fee_Type__c IN ('Program Fee','University Fee')
        AND Applicant_Category__c = :feeMasterCategory
    ];

    List<Student_Fee__c> fees = new List<Student_Fee__c>();

    Integer displayNo = 1;

    Decimal totalProgramFee = 0;
    Decimal universityFee = 0;

    // Read Program Fee & University Fee once
    for(Fee_Master__c fm : feeMasters){
        if(fm.Fee_Type__c == 'Program Fee'){
            totalProgramFee = fm.Fee_Amount__c;
        }
        else if(fm.Fee_Type__c == 'University Fee'){
            universityFee = fm.Fee_Amount__c;
        }
    }

    for(Fee_Master__c fm : feeMasters){

        Integer years = Integer.valueOf(fm.Program_Batch__r.Number_of_Years__c);

        for(Integer i=1;i<=years;i++){

            Student_Fee__c sf = new Student_Fee__c();

            sf.Contact__c = con.Id;
            sf.Fee_Master__c = fm.Id;

            /* Fee Type */

            String feeType = fm.Fee_Type__c;

            if(feeType == 'Program Fee'){
                feeType = 'Tuition Fee';
            }

            /* Fee Year */

            String feeYear;

            if(i == 1){
                feeYear = '1st Year';
            }
            else if(i == 2){
                feeYear = '2nd Year';
            }
            else if(i == 3){
                feeYear = '3rd Year';
            }
            else if(i == 4){
                feeYear = '4th Year';
            }
            else{
                feeYear = '5th Year';
            }

            sf.Fee_Type__c = feeType;
            sf.Name = feeType + ' ' + feeYear;
            sf.Fee_Year__c = feeYear;

            /* Due Date */

            Date dueDate = con.Program_Batch__r.hed__Start_Date__c;

            if(dueDate != null){
                dueDate = dueDate.addYears(i - 1);
            }

            sf.Due_Date__c  = dueDate;
            sf.Display_No__c = displayNo++;
            sf.Amount_Paid__c = 0;

            /* Amount */

            Decimal feeAmount;

            if(fm.Fee_Type__c == 'Program Fee'){
                feeAmount = totalProgramFee - universityFee;
            }
            else{
                feeAmount = universityFee;
            }

                sf.Amount__c = feeAmount;
                sf.Amount_Pending__c = feeAmount;
                sf.Actual_Program_Fee__c = feeAmount;
                sf.Student_Personal_Email__c= con.Email;
                sf.Student_Mobile_Number__c = con.MobilePhone;
                sf.Father_Email_ID__c = con.Father_Email_ID__c;
                sf.Mother_Email_ID__c = con.Mother_Email_ID__c;
                sf.Father_Mobile_Number__c = con.Father_Mobile_Number__c;
                sf.Mother_Mobile_Number__c = con.Mother_Mobile_Number__c;
                sf.Premium__c = fm.Premium_Amount__c == null ? 0 : fm.Premium_Amount__c;
                sf.Scholarship__c = 0;
                sf.Concession__c = 0;
             if(i == 1){
                 sf.Provisional_Admission_Fee__c = totalProgramFee / 2;
             }
             else{
                 sf.Provisional_Admission_Fee__c = 0; 
             }

             fees.add(sf);
         }
     }

    System.debug('Fee Masters Found : ' + feeMasters.size());

    if(!fees.isEmpty()){

        insert fees;

        update new hed__Application__c(
            Id = app.Id,
            Fee_Structure_Defined__c = true
        );

        System.debug('Student Fees Created Successfully');
    }
}

   private static void generatePayment(hed__Application__c app){

    Contact con = [SELECT Id,Name,Application_Number__c,Email,OwnerId FROM Contact
                   WHERE Id = :app.hed__Applicant__c LIMIT 1];

     List<Student_Fee__c> fees = [SELECT Id,Name,Fee_Type__c,Fee_Year__c,Provisional_Admission_Fee__c
                                  FROM Student_Fee__c
                                  WHERE Contact__c = :con.Id
                                 AND Fee_Year__c = '1st Year' 
                                 AND Provisional_Admission_Fee__c > 0
                                 AND Fee_Type__c = 'University Fee'
                                  ];
    
        if(fees.isEmpty()){
            System.debug('No Student Fee records found.');
            return;
         } 
  Decimal amount = fees[0].Provisional_Admission_Fee__c;
    AdmissionsProcessUtility.UtilityResponse response =
        AdmissionsProcessUtility.generateChallanNumber()[0];

    Student_Payment__c payment = new Student_Payment__c();

    payment.Contact__c = con.Id;
    payment.Amount__c = amount;
    payment.Mode_of_Payment__c = 'Online';
    payment.Payment_Status__c = 'Pending';
    payment.Fee_Type__c = 'University Fee, Tuition Fee'; 
    payment.Payment_Date_Time__c = System.today();

    insert payment;

    System.debug('Student Payment Created : ' + payment.Id);
       
// Generate Payment URL Automatically

     String domain = '';

     List<Domain> domainList = [SELECT Domain FROM Domain
                           WHERE HttpsOption = 'CommunityAlt'
                           LIMIT 1
                            ];

    if(!domainList.isEmpty()){
        domain = 'https://' + domainList[0].Domain;
      }

   String paymentLink =
      domain +
       '/Admissions/s/payment-page?contactId=' + payment.Contact__c +
       '&isPAF=true' +
       '&stupayid=' + payment.Id;

/* Store Link */

  payment.Pending_Payment_Link__c = paymentLink;

    update payment;

   System.debug('Payment Link : ' + paymentLink);
   System.debug('Student Payment Created : ' + payment.Id);

   }
    
    public static void handleDeletedPayments(List<Student_Payment__c> deletedPayments){

    Set<Id> contactIds = new Set<Id>();

    for(Student_Payment__c sp : deletedPayments){
        if(sp.Contact__c != null){
            contactIds.add(sp.Contact__c);
        }
    }

    if(contactIds.isEmpty()){
        return;
    }

    // Contacts that still have pending payments
    Set<Id> contactsWithPendingPayments = new Set<Id>();

    for(Student_Payment__c sp : [
        SELECT Contact__c
        FROM Student_Payment__c
        WHERE Contact__c IN :contactIds
        AND Payment_Status__c = 'Pending'
        AND Fee_Type__c = 'University Fee, Tuition Fee'
    ]){
        contactsWithPendingPayments.add(sp.Contact__c);
    }

    List<hed__Application__c> appsToUpdate = new List<hed__Application__c>();

    for(hed__Application__c app : [SELECT Id,hed__Applicant__c,
               hed__Application_Status__c,Offline_Payment_Initiated__c
               FROM hed__Application__c
               WHERE hed__Applicant__c IN :contactIds
            ]){

        // No pending payment remains
        if(!contactsWithPendingPayments.contains(app.hed__Applicant__c)){

            app.hed__Application_Status__c = 'Interested';
         
            appsToUpdate.add(app);
        }
    }

    if(!appsToUpdate.isEmpty()){
        if(!Test.isRunningTest()){
        update appsToUpdate;
        }}
}

}