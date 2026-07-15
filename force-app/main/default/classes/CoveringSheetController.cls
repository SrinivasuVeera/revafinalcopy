public with sharing class CoveringSheetController {

    public Contact con {get;set;}
    public hed__Education_History__c education {get;set;}
    public hed__Application__c applicationRec {get;set;}
    public List<Student_Fee__c> fees {get;set;}
    public Date firstPaymentDate {get;set;}
    public Decimal feeStructure {get;set;}
    public Decimal pafAmount {get;set;}
    public String pafDisplay {get;set;}
    
    public Decimal firstYearFee {get;set;}
    public Decimal secondYearFee {get;set;}
    public Decimal thirdYearFee {get;set;}
    public Decimal fourthYearFee {get;set;}
    public Decimal fifthYearFee {get;set;}
    public Decimal scholarshipAmount {get;set;}
    public String feeWaiverDisplay {get;set;}
    public String scholarshipDisplay {get;set;}

    public String getFormattedDate(){

    if(applicationRec == null ||
       applicationRec.First_Payment_Date__c == null){

        return '';
    }

    Date d = applicationRec.First_Payment_Date__c;

    String day = String.valueOf(d.day()).leftPad(2,'0');
    String month = String.valueOf(d.month()).leftPad(2,'0');
    String year = String.valueOf(d.year());

    return day + '/' + month + '/' + year;
}
    
    public String getDisplayPercentage(){

      if(education == null){
         return '';
          }

      if(String.isBlank(education.Percentage__c) ||
         education.Percentage__c == '0' ||
         education.Percentage__c == '0.0' ||
         education.Percentage__c == '0.00'){

         return education.hed__Status__c;
       }

       return education.Percentage__c + '%';

    }
    
    public String getDisplayState(){

      if(!String.isBlank(con.State__c)){
          return con.State__c;
        }

      if(con.hed__Current_Address__r != null &&
        !String.isBlank(con.hed__Current_Address__r.hed__MailingState__c)){

         return con.hed__Current_Address__r.hed__MailingState__c;
       }

        return '';
    }
    public String getDisplayBoard(){

    if(education == null){
        return '';
    }

    if(education.Board__c == 'Other'&&
       !String.isBlank(education.Board_Others__c)){

        return education.Board_Others__c;
    }

    return education.Board__c;
}
    
    public CoveringSheetController() {
 
        Id contactId = ApexPages.currentPage().getParameters().get('id');

        if(contactId == null){
            return;
        }

        List<Contact> conList = [
            SELECT Id,Name,Program_Batch__r.Name,Email,MobilePhone,Admission_Mode__c,State__c,
                   Application_Number__c,Referral_Type__c,Referrer_Name__c,Referral_Code__c,
                   hed__Current_Address__r.hed__MailingState__c 
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        if(!conList.isEmpty()){
            con = conList[0];
        }

        List<hed__Application__c> appList = [
            SELECT Id,
                   hed__Applicant__c,First_Payment_Date__c,
                   hed_Scholarship__r.Category__c,
                   hed_Scholarship__r.Sub_Category__c,
                   hed_Scholarship__r.Discount_Percent__c,
                   hed_Scholarship__r.Discount_Amount__c
            FROM hed__Application__c
            WHERE hed__Applicant__c = :contactId
            LIMIT 1
        ];

        if(!appList.isEmpty()){
            applicationRec = appList[0];
        }

        List<hed__Education_History__c> eduList = [
            SELECT Id, Board__c,hed__Status__c,Board_Others__c,
                   Percentage__c,Type_of_Course__c
            FROM hed__Education_History__c
            WHERE hed__Contact__c = :contactId
           ];
        
          hed__Education_History__c ugRec;
          hed__Education_History__c twelfthRec;
          hed__Education_History__c diplomaRec;
          hed__Education_History__c tenthRec;

  for(hed__Education_History__c edu : eduList){
     System.debug('Course Type = ' + edu.Type_of_Course__c);
      if(edu.Type_of_Course__c == 'UG'){
        ugRec = edu;
     }
     else if(edu.Type_of_Course__c == '12th'){
         twelfthRec = edu;
     }
     else if(edu.Type_of_Course__c == 'Diploma'){
        diplomaRec = edu;
     }
     else if(edu.Type_of_Course__c == '10th'){
        tenthRec = edu;
     }
    }
     
     if(ugRec != null){
        education = ugRec;
        }
     else if(twelfthRec != null){
       education = twelfthRec;
     }
    else if(diplomaRec != null){
     education = diplomaRec;
    }
    else if(tenthRec != null){
     education = tenthRec;
    }

        fees = [SELECT Id,Fee_Type__c, Fee_Year__c,Actual_Program_Fee__c,Scholarship__c,Scholarship_Categories__c,Scholarship_Sub_Category__c,
                   Concession__c,Calculated_Total_Amount__c,Provisional_Admission_Fee__c,Tuition_Premium__c,Amount_Paid__c
               FROM Student_Fee__c
               WHERE Contact__c = :contactId
               AND Fee_Type__c != 'Application Fee'];

          calculateFees();
      }

    public void calculateFees(){

    Decimal totalConcession = 0;
    Decimal totalAmountPaid = 0;

    feeStructure = 0;
    pafAmount = 0;

    String scholarshipYear = '';
    String scholarshipCategory = '';
    String scholarshipSubCategory = '';

    Decimal totalScholarshipAmount = 0;

    firstYearFee = 0;
    secondYearFee = 0;
    thirdYearFee = 0;
    fourthYearFee = 0;
    fifthYearFee = 0;

    Decimal universityPAF = 0;
    Decimal tuitionPAF = 0;

    for(Student_Fee__c sf : fees){

        // Fee Structure
        if(sf.Fee_Year__c == '1st Year' &&
           (sf.Fee_Type__c == 'Tuition Fee' ||
            sf.Fee_Type__c == 'University Fee')){

            if(sf.Tuition_Premium__c != null){
                feeStructure += sf.Tuition_Premium__c;
            }

            // Paid Amount
            if(sf.Amount_Paid__c != null){
                totalAmountPaid += sf.Amount_Paid__c;
            }

            // Scholarship
            if(sf.Scholarship__c != null &&
               sf.Scholarship__c > 0){

                totalScholarshipAmount += sf.Scholarship__c;

                if(String.isBlank(scholarshipYear)){
                    scholarshipYear = sf.Fee_Year__c;
                }

                if(String.isBlank(scholarshipCategory)){
                    scholarshipCategory =
                        sf.Scholarship_Categories__c;
                }

                if(String.isBlank(scholarshipSubCategory)){
                    scholarshipSubCategory =
                        sf.Scholarship_Sub_Category__c;
                }
            }
        }

        // PAF Logic
        if(sf.Fee_Year__c == '1st Year'){

            if(sf.Fee_Type__c == 'University Fee' &&
               sf.Provisional_Admission_Fee__c != null){

                universityPAF =
                    sf.Provisional_Admission_Fee__c;
            }

            if(sf.Fee_Type__c == 'Tuition Fee' &&
               sf.Provisional_Admission_Fee__c != null){

                tuitionPAF =
                    sf.Provisional_Admission_Fee__c;
            }
        }

        // Fee Waiver
        if(sf.Concession__c != null){
            totalConcession += sf.Concession__c;
        }

        // Finalized Fee

        if(sf.Fee_Year__c == '1st Year' &&
           sf.Calculated_Total_Amount__c != null){

            firstYearFee += sf.Calculated_Total_Amount__c;
        }

        if(sf.Fee_Year__c == '2nd Year' &&
           sf.Calculated_Total_Amount__c != null){

            secondYearFee += sf.Calculated_Total_Amount__c;
        }

        if(sf.Fee_Year__c == '3rd Year' &&
           sf.Calculated_Total_Amount__c != null){

            thirdYearFee += sf.Calculated_Total_Amount__c;
        }

        if(sf.Fee_Year__c == '4th Year' &&
           sf.Calculated_Total_Amount__c != null){

            fourthYearFee += sf.Calculated_Total_Amount__c;
        }

        if(sf.Fee_Year__c == '5th Year' &&
           sf.Calculated_Total_Amount__c != null){

            fifthYearFee += sf.Calculated_Total_Amount__c;
        }
    }

    // PAF Calculation

    if(universityPAF > 0){
        pafAmount = universityPAF;
    }
    else{
        pafAmount = tuitionPAF;
    }

    // PAF Display

    pafDisplay =
        String.valueOf(pafAmount) +
        ' (Paid Amount : ' +
        String.valueOf(totalAmountPaid) +
        ')';

    // Scholarship Display

    /*if(applicationRec != null &&
       applicationRec.hed_Scholarship__r != null){

        scholarshipDisplay =
            'Category : ' +
            applicationRec.hed_Scholarship__r.Category__c +

            ' | Sub Category : ' +
            applicationRec.hed_Scholarship__r.Sub_Category__c +

            ' | Discount % : ' +
            String.valueOf(
                applicationRec.hed_Scholarship__r.Discount_Percent__c
            ) +

            '% | Amount : ' +
            String.valueOf(totalScholarshipAmount) +

            ' (' + scholarshipYear + ')';
    }
    else*/ if(totalScholarshipAmount > 0){

        scholarshipDisplay =
            'Category : ' +
            scholarshipCategory +

            ' | Sub Category : ' +
            scholarshipSubCategory +

            ' | Amount : ' +
            String.valueOf(totalScholarshipAmount) +

            ' (' + scholarshipYear + ')';
    }
    else{

        scholarshipDisplay = 'N/A';
    }

    // Fee Waiver Display

    feeWaiverDisplay =
        totalConcession > 0
        ? String.valueOf(totalConcession)
        : 'N/A';
}
    
    
}