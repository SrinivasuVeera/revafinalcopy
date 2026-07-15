public with sharing class GovtQuotaAdmissionsUtility {
  private static final string APPLICATION_FEE = 'Appliction Fee';
  private static final String TUITION_FEE = 'Tuition Fee'; 
  private static final String UNIVERSITY_FEE = 'University Fee';
  private static final String[] YEARS = new String[]{'1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'};
  private static final Integer DAYS_TO_PAY_1ST_YEAR_FEE = 20;
  private static final Integer FIRST_YEAR_UNIVERSITY_FEE_INDEX = 0;
  private static final Integer FIRST_YEAR_TUITION_FEE_INDEX = 1;
  private static String currentEnrolmentYear;
  private static List<Date> dueDates;

  public static String createFeeRecordsForCETApplicant(String contactId) {
    String message = 'Success';
    Decimal keaPaidAmount = 0;
    Map<String,Student_Fee__c> stufeeAvailableMap = new Map<String,Student_Fee__c>();
    try {
      List<Student_Fee__c> sfRecsToCreate = new List<Student_Fee__c>();

      //Get required contact information
      Contact c = [SELECT Id, Program_Batch__c, Program_Batch__r.Number_of_Years__c,
                          Father_Email_ID__c, Father_Mobile_Number__c, Mother_Email_ID__c, 
                          Mother_Mobile_Number__c, Email, MobilePhone,
                          Select_Category__c, Admission_Mode__c, 
                          Fee_Paid_at_KEA__c, Fee_Paid_at_University__c, CET_COMEDK_Number__c, 
                          Program_Type__c, Type__c, Application_Number__c //These three may be removed
                     FROM Contact
                    WHERE Id = :contactId];
  
      String applicantCategory = c.Select_Category__c;
      Integer numberOfYears = (Integer)c.Program_Batch__r.Number_of_Years__c;
      
      if ( applicantCategory == 'Karnataka' || applicantCategory == 'Non-Karnataka') {
        applicantCategory = 'Indian (SAARC)';
      }
      
      calcDueDates(numberOfYears);
      FeeInformation fi = getFeeInformation(c.Program_Batch__c, applicantCategory, c.Admission_Mode__c);
  
      Decimal tfAmountPendingY1;
      Decimal ufAmountPendingY1;
      
      System.debug('>>> Fee paid at KEA: ' + c.Fee_Paid_at_KEA__c + ', Amount to pay at REVA: ' + c.Fee_Paid_at_University__c);
      if (c.Fee_Paid_at_University__c <= fi.universityFee) {
        tfAmountPendingY1 = 0;
        ufAmountPendingY1 = c.Fee_Paid_at_University__c;
      } 
        else {
        tfAmountPendingY1 = c.Fee_Paid_at_University__c - fi.universityFee;
        ufAmountPendingY1 = fi.universityFee;
      }
      system.debug(fi);
      System.debug('TF Pending Y1: ' + tfAmountPendingY1 + ', UF Pending Y1: ' + ufAmountPendingY1);
       if(c.Admission_Mode__c == 'DCET'){
            for (Integer i = 1; i < numberOfYears; i++) {
        Student_Fee__c tf = getInitializedSFRec(c, i);
        Student_Fee__c uf = getInitializedSFRec(c, i);
  		
        //Set Tuition Fee fields
        tf.Name = TUITION_FEE + ' ' + YEARS[i];
        tf.Fee_Type__c = TUITION_FEE;
        tf.Fee_Year__c = YEARS[i];
        tf.Display_No__c = (2 * i) + 2;
        tf.Due_Date__c = dueDates[i];
        tf.Fee_Master__c = fi.pgmFeeId;
        tf.Fee_Payment_Criteria__c = fi.tuitionFeePaymentCriteriaId;
        tf.Number_of_Installments__c = fi.tfNoOfInstallments;
        tf.Actual_Program_Fee__c = i < (numberOfYears - 1) ? fi.tuitionFee : fi.finalYearTuitionFee;
        tf.Amount__c = tf.Actual_Program_Fee__c; //tuition fee
        tf.Provisional_Admission_Fee__c = i == 1 ? c.Fee_Paid_at_University__c : 0; //Set on both TF & UF 1st Year records
        tf.Amount_Pending__c =  i == 1 ? tfAmountPendingY1 : tf.Amount__c;
        tf.Amount_Paid__c = i == 1 ? c.Fee_Paid_at_KEA__c : 0;
  
        sfRecsToCreate.add(tf);
  
        //Set University Fee fields
        uf.Name = UNIVERSITY_FEE + ' ' + YEARS[i];
        uf.Fee_Type__c = UNIVERSITY_FEE;
        uf.Fee_Year__c = YEARS[i];
        uf.Display_No__c = (2 * i) + 1;
        uf.Due_Date__c = dueDates[i];
        uf.Fee_Master__c = fi.universityFeeId;
        uf.Fee_Payment_Criteria__c = fi.universityFeePaymentCriteriaId;
        uf.Number_of_Installments__c = fi.ufNoOfInstallments;
        uf.Actual_Program_Fee__c = fi.universityFee;
        uf.Amount__c = uf.Actual_Program_Fee__c; //university fee
        uf.Provisional_Admission_Fee__c = i == 1 ? c.Fee_Paid_at_University__c : 0; //Set on both TF & UF 1st Year records
        uf.Amount_Pending__c =  i == 1 ? ufAmountPendingY1 : uf.Amount__c;
        
        sfRecsToCreate.add(uf);
      }
        }
        else {
      for (Integer i = 0; i < numberOfYears; i++) {
        Student_Fee__c tf = getInitializedSFRec(c, i);
        Student_Fee__c uf = getInitializedSFRec(c, i);
  		
        //Set Tuition Fee fields
        tf.Name = TUITION_FEE + ' ' + YEARS[i];
        tf.Fee_Type__c = TUITION_FEE;
        tf.Fee_Year__c = YEARS[i];
        tf.Display_No__c = (2 * i) + 2;
        tf.Due_Date__c = dueDates[i];
        tf.Fee_Master__c = fi.pgmFeeId;
        tf.Fee_Payment_Criteria__c = fi.tuitionFeePaymentCriteriaId;
        tf.Number_of_Installments__c = fi.tfNoOfInstallments;
        tf.Actual_Program_Fee__c = i < (numberOfYears - 1) ? fi.tuitionFee : fi.finalYearTuitionFee;
        tf.Amount__c = tf.Actual_Program_Fee__c; //tuition fee
        tf.Provisional_Admission_Fee__c = i == 0 ? c.Fee_Paid_at_University__c : 0; //Set on both TF & UF 1st Year records
        tf.Amount_Pending__c =  i == 0 ? tfAmountPendingY1 : tf.Amount__c;
        tf.Amount_Paid__c = i == 0 ? c.Fee_Paid_at_KEA__c : 0;
  
        sfRecsToCreate.add(tf);
  
        //Set University Fee fields
        uf.Name = UNIVERSITY_FEE + ' ' + YEARS[i];
        uf.Fee_Type__c = UNIVERSITY_FEE;
        uf.Fee_Year__c = YEARS[i];
        uf.Display_No__c = (2 * i) + 1;
        uf.Due_Date__c = dueDates[i];
        uf.Fee_Master__c = fi.universityFeeId;
        uf.Fee_Payment_Criteria__c = fi.universityFeePaymentCriteriaId;
        uf.Number_of_Installments__c = fi.ufNoOfInstallments;
        uf.Actual_Program_Fee__c = fi.universityFee;
        uf.Amount__c = uf.Actual_Program_Fee__c; //university fee
        uf.Provisional_Admission_Fee__c = i == 0 ? c.Fee_Paid_at_University__c : 0; //Set on both TF & UF 1st Year records
        uf.Amount_Pending__c =  i == 0 ? ufAmountPendingY1 : uf.Amount__c;
        
        sfRecsToCreate.add(uf);
      }
        }
        
      insert (sfRecsToCreate);
  
      //Create student payment and student fee payment records for fee paid at KEA
      Student_Payment__c sp = new Student_Payment__c(
        Payment_Date_Time__c = Datetime.now(),
        Contact__c = c.Id,
        Mode_of_payment__c = 'Offline',
        Fee_Type__c	= 'Tuition Fee', 
        Payment_Status__c	= 'Success',
        Payment_Mode_Type__c = 'Paid at KEA',
        Transaction_ID__c	= c.CET_COMEDK_Number__c,  //CET Enrollment ID here
        Amount__c	= c.Fee_Paid_at_KEA__c,
        Description__c = 'Fee paid at CET/COMEDK Cell'
      );
      insert (sp);
      
      keaPaidAmount = c.Fee_Paid_at_KEA__c;
     
      for(Student_Fee__c stufee : [SELECT name, Amount_Paid__c, Actual_Program_Fee__c, Amount_Pending__c, Amount__c, Provisional_Admission_Fee__c, Id, Contact__c, Fee_Type__c, Fee_Year__c FROM Student_Fee__c WHERE Contact__c = :contactId and Fee_Type__c != 'Application Fee']){
        stufeeAvailableMap.put(stufee.Name.toLowerCase(),stufee); 
      }
      if(stufeeAvailableMap.get('university fee 1st year') != null){
        if(keaPaidAmount > (stufeeAvailableMap.get('university fee 1st year')).Amount__c){
          
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('university fee 1st year').Amount__c, stufeeAvailableMap.get('university fee 1st year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('university fee 1st year').Amount__c;
          System.debug('inside creating university 1st year keaPaidAmount '+keaPaidAmount);
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('university fee 1st year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
          System.debug('inside creating university 1st year keaPaidAmount '+keaPaidAmount);
        }
        if(keaPaidAmount > 0){
          if(keaPaidAmount > (stufeeAvailableMap.get('tuition fee 1st year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('tuition fee 1st year').Amount__c, stufeeAvailableMap.get('tuition fee 1st year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('tuition fee 1st year').Amount__c;
          System.debug('inside creating tuition 1st year keaPaidAmount '+keaPaidAmount);
          } else {
            insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('tuition fee 1st year').Id,c.CET_COMEDK_Number__c);
            keaPaidAmount = 0;
            System.debug('inside creating tuition 1st year keaPaidAmount '+keaPaidAmount);
          }
        }
      }
      if(keaPaidAmount > 0 && stufeeAvailableMap.get('university fee 2nd year') != null){
        if(keaPaidAmount > (stufeeAvailableMap.get('university fee 2nd year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('university fee 2nd year').Amount__c, stufeeAvailableMap.get('university fee 2nd year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('university fee 2nd year').Amount__c;
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('university fee 2nd year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
        }
        if(keaPaidAmount > 0 && keaPaidAmount > (stufeeAvailableMap.get('tuition fee 2nd year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('tuition fee 2nd year').Amount__c, stufeeAvailableMap.get('tuition fee 2nd year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('tuition fee 2nd year').Amount__c;
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('tuition fee 2nd year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
        }
      }
      if(keaPaidAmount > 0 && stufeeAvailableMap.get('university fee 3rd year') != null){
        if(keaPaidAmount > (stufeeAvailableMap.get('university fee 3rd year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('university fee 3rd year').Amount__c, stufeeAvailableMap.get('university fee 3rd year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('university fee 3rd year').Amount__c;
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('university fee 3rd year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
        }
        if(keaPaidAmount > 0 && keaPaidAmount > (stufeeAvailableMap.get('tuition fee 3rd year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('tuition fee 3rd year').Amount__c, stufeeAvailableMap.get('tuition fee 3rd year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('tuition fee 3rd year').Amount__c;
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('tuition fee 3rd year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
        }
      }
      if(keaPaidAmount > 0 && stufeeAvailableMap.get('university fee 4th year') != null){
        if(keaPaidAmount > (stufeeAvailableMap.get('university fee 4th year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('university fee 4th year').Amount__c, stufeeAvailableMap.get('university fee 4th year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('university fee 4th year').Amount__c;
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('university fee 4th year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
        }
        if(keaPaidAmount > 0 && keaPaidAmount > (stufeeAvailableMap.get('tuition fee 4th year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('tuition fee 4th year').Amount__c, stufeeAvailableMap.get('tuition fee 4th year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('tuition fee 4th year').Amount__c;
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('tuition fee 4th year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
        }
      }
      if(keaPaidAmount > 0 && stufeeAvailableMap.get('university fee 5th year') != null){
        if(keaPaidAmount > (stufeeAvailableMap.get('university fee 5th year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('university fee 5th year').Amount__c, stufeeAvailableMap.get('university fee 5th year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('university fee 5th year').Amount__c;
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('university fee 5th year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
        }
        if(keaPaidAmount > 0 && keaPaidAmount > (stufeeAvailableMap.get('tuition fee 5th year')).Amount__c){
          insertGovtStuFeePayment(sp, stufeeAvailableMap.get('tuition fee 5th year').Amount__c, stufeeAvailableMap.get('tuition fee 5th year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount -= stufeeAvailableMap.get('tuition fee 5th year').Amount__c;
        } else {
          insertGovtStuFeePayment(sp, keaPaidAmount, stufeeAvailableMap.get('tuition fee 5th year').Id,c.CET_COMEDK_Number__c);
          keaPaidAmount = 0;
        }
      }
      System.debug('inside final  keaPaidAmount '+keaPaidAmount);
    } catch(Exception e) {
      message = 'Error. Exception Message: ' + e.getMessage();
        system.debug('message'+ message);
    }
    return (message);
  }

  private static void calcDueDates(Integer numberOfYears) {
    currentEnrolmentYear = AdmissionsProcessUtility.getCurrentEnrolmentYear();
    dueDates = new List<Date>();

    Integer curYearInt = Integer.valueOf(currentEnrolmentYear);

    //Add first year due date
    dueDates.add(Date.today().addDays(DAYS_TO_PAY_1ST_YEAR_FEE));

    for (Integer i = 1; i < numberOfYears; i++) {
      dueDates.add(Date.newInstance(curYearInt + i, 7, 1));
    }
    System.debug(dueDates);
  }

  Public static Student_Fee__c getInitializedSFRec(Contact c, Integer idx) {
    return new Student_Fee__c(
      Contact__c = c.Id,
      Student_Mobile_Number__c = c.MobilePhone,
      Student_Personal_Email__c = c.Email,
      Father_Email_ID__c = c.Father_Email_ID__c,
      Father_Mobile_Number__c = c.Father_Mobile_Number__c,
      Mother_Email_ID__c = c.Mother_Email_ID__c,
      Mother_Mobile_Number__c = c.Mother_Mobile_Number__c,
      Concession__c = 0,
      Premium__c = 0,
      Scholarship__c = 0,
      Amount_Paid__c = 0,
      Fee_Year__c = YEARS[idx], 
      Academic_Fee__c = true
    );
  }

  private static FeeInformation getFeeInformation(Id programBatchId, String applicantCategory, String admissionQuota) {
    FeeInformation fi = new FeeInformation();
    System.debug('>>> Program Batch: ' + programBatchId + ', Applicant Category: ' + applicantCategory + 
                  ', Quota: ' + admissionQuota + ', Enrolment Year: ' + currentEnrolmentYear);
    for (Fee_Master__c fm: [SELECT Fee_Type__c, Fee_Amount__c, Id
                              FROM Fee_Master__c 
                             WHERE Program_Batch__c = :programBatchId and 
                                   Applicant_Category__c = :applicantCategory and 
                                   Fee_Type__c != :APPLICATION_FEE and 
                                   Quota__c = :admissionQuota and
                                   Enrolment_Year__c = :currentEnrolmentYear]) {
                                      
      if (fm.Fee_Type__c == 'University Fee') {
        fi.universityFee = fm.Fee_Amount__c;
        fi.universityFeeId = fm.Id;
      } 
      else if (fm.Fee_Type__c == 'Program Fee') {
        fi.programFee = fm.Fee_Amount__c;
        fi.pgmFeeId = fm.Id;
      } 
   else if (fm.Fee_Type__c == 'Final Year Special Fee') {
        fi.finalYearProgramFee = fm.Fee_Amount__c;
      }
    }
    fi.tuitionFee = fi.programFee - fi.universityFee;
    if (fi.finalYearProgramFee != 0) {
      fi.finalYearTuitionFee = fi.finalYearProgramFee - fi.universityFee;
    } else {
      fi.finalYearTuitionFee = fi.programFee - fi.universityFee;
    }

    for (Fee_Payment_Criteria__c fpc : [SELECT Id, Name, Fee_Type__c, Maximum_Number_of_Installments__c 
                                          FROM Fee_Payment_Criteria__c 
                                         WHERE Fee_Type__c = :TUITION_FEE or 
                                               Fee_Type__c = :UNIVERSITY_FEE]) {
      if (fpc.Fee_Type__c == TUITION_FEE) {
        fi.tuitionFeePaymentCriteriaId = fpc.Id;
        fi.tfNoOfInstallments = fpc.Maximum_Number_of_Installments__c;
      } else if (fpc.Fee_Type__c == UNIVERSITY_FEE) {
        fi.universityFeePaymentCriteriaId = fpc.Id;
        fi.ufNoOfInstallments = fpc.Maximum_Number_of_Installments__c;
      }
    }

    return fi;
  }

  class FeeInformation {
    Decimal universityFee {get; set;}
    Decimal programFee {get; set;}
    Decimal finalYearProgramFee {get; set;}
    Decimal tuitionFee {get; set;}
    Decimal finalYearTuitionFee {get; set;}
    Id pgmFeeId {get; set;}
    Id universityFeeId {get; set;}
    Decimal tfNoOfInstallments {get; set;}
    Decimal ufNoOfInstallments {get; set;}
    Id tuitionFeePaymentCriteriaId {get; set;}
    Id universityFeePaymentCriteriaId {get; set;}

    FeeInformation() {
      this.finalYearProgramFee = 0;
    }
  }

  public static void insertGovtStuFeePayment(Student_Payment__c stupay, Decimal amount, Id stufeeId,String comedkNumber){
    Student_Fee_Payment__c stufeePayUpdated = new Student_Fee_Payment__c();
    stufeePayUpdated.Amount__c = amount;
    stufeePayUpdated.Student_Payment__c = stupay.Id;
    stufeePayUpdated.Student_Fee__c = stufeeId;
    stufeePayUpdated.Mode_of_Payment__c = 'Offline';
    stufeePayUpdated.Line_Item_Payment_Status__c = 'Success';
    stufeePayUpdated.Payment_Mode_Type__c = 'Paid at KEA';
    stufeePayUpdated.SF_Transaction_ID__c	= comedkNumber;
    stufeePayUpdated.Transaction_Date_Time__c = Datetime.now();
    insert stufeePayUpdated;
}
}