public without sharing class POLetter_Extension 
{
    private ApexPages.StandardController stdCtrl {get; set;}
    public string applicationId {get; set;}
    public string firstYearAnnualFee {get; set;}
    public String secondYearAnnualFee {get; set;}
    public String thirdYearAnnualFee {get; set;}
    public String fourthYearAnnualFee {get; set;}
    public String fifthYearAnnualFee {get; set;}
    public String totalAnnualFee {get; set;}
    public string firstYearScholarship {get; set;}
    public String secondYearScholarship {get; set;}
    public String thirdYearScholarship {get; set;}
    public String fourthYearScholarship {get; set;}
    public String fifthYearScholarship {get; set;}
    public String totalScholarship {get; set;}
    public string firstYearConcession {get; set;}
    public String secondYearConcession {get; set;}
    public String thirdYearConcession {get; set;}
    public String fourthYearConcession {get; set;}
    public String fifthYearConcession {get; set;}
    public String totalConcession {get; set;}
    public String firstYearBalance {get; set;}
    public String secondYearBalance {get; set;}
    public String thirdYearBalance {get; set;}
    public String fourthYearBalance {get; set;}
    public String fifthYearBalance {get; set;}
    public String totalBalance {get; set;}
    public String firstPayment {get; set;}
    public String SecondPayment {get; set;}
    public String ThirdPayment {get; set;}
    public String fourthPayment {get; set;}
    public String fifthPayment {get; set;}
    public String totalPAFFee {get; set;}
    public Decimal num {get; set;}
    public string words {get;set;}
    public Boolean PAFStatus {get; set;}
    public Datetime transactionDateTime { get; set; }
    
    //public Integer year {get; set;}
    //public List<Contact> contact {get; set;}
    //public List<hed__Application__c> application {get; set;}
    public Integer firstYearFeeRecordSize {get; set;}
    public Integer secondYearFeeRecordSize {get; set;}
    public Integer thirdYearFeeRecordSize {get; set;}
    public Integer fourthYearFeeRecordSize {get; set;}
    public Integer fifthYearFeeRecordSize {get; set;}
    public String applicationStatus {get; set;}
    public String concessionStatus {get; set;}
    public String concessionFirstYear {get; set;}
    public String concessionsecondYear {get; set;}
    public String concessionthirdYear {get; set;}
    public String concessionfourthYear {get; set;}
    public String concessionfifthYear {get; set;}
    public String schoolApplied {get; set;}
    public String applicationNumber {get; set;}
    public String programApplied {get; set;}
    public String scholarshipCategory {get; set;}
    public Boolean isForeigner { get; set; }
    

    
    public POLetter_Extension (ApexPages.StandardController stdController){
        stdCtrl = stdController;
        applicationId = stdController.getId();
       // setupApplication();
        // Fetch Citizenship
        hed__Application__c app = [
            SELECT Id,hed__Applicant__c,hed__Applicant__r.country__c,hed__Applicant__r.Select_Category__c
            FROM hed__Application__c 
            WHERE Id = :applicationId
        ];

        if(app.hed__Applicant__r.Select_Category__c == 'Foreign Nationals'
          ||
        (
            app.hed__Applicant__r.Select_Category__c == 'Indian (SAARC)'
            &&
            app.hed__Applicant__r.Country__c != 'India'
        )
          ){
            isForeigner = true;
        } else {
            isForeigner = false;
        }
        //setupApplication();
        setupApplication();
    }
    

    public void setupApplication(){
        String universityFeeType = 'University Fee';
        String tutionFeeType = 'Tuition Fee';
        string applicationFee = 'Application Fee';
        string firstYear = '1st Year';
        string secondYear = '2nd Year';
        string thirdYear = '3rd Year' ;
        string fourthYear = '4th Year';
        string fifthYear = '5th Year';
        Decimal firstYearAnnualFeeFirst;
        Decimal firstYearScholarshipFirst;
        Decimal firstYearConcessionFirst;
        Decimal firstPaymentPaf;
        Decimal SecondPaymentPaf;
        Decimal ThirdPaymentPaf;
        Decimal fourthPaymentPaf;
        Decimal fifthPaymentPaf;
        Decimal secondYearAnnualFeeSecond;
        Decimal secondYearScholarshipSecond;
        Decimal secondYearConcessionSecond;
        Decimal thirdYearAnnualFeeThird;
        Decimal thirdYearConcessionThird;
        Decimal thirdYearScholarshipThird;
        Decimal fourthYearAnnualFeeFourth;
        Decimal fourthYearScholarshipFourth;
        Decimal fourthYearConcessionFourth;
        Decimal fifthYearAnnualFeeFifth;
        Decimal fifthYearScholarshipFifth;
        Decimal fifthYearConcessionFifth;
        Decimal totalAnnualFeeTot;
        Decimal totalScholarshipTot;
        Decimal totalConcessionTot;
         Decimal totalPAFTot;
        Decimal firstYearBalance1; 
        Decimal secondYearBalance1;
        Decimal thirdYearBalance1; 
        Decimal fourthYearBalance1; 
        Decimal fifthYearBalance1; 
        Decimal totalBalance1;
        Decimal concessionFirstYearFirst;
        Decimal concessionsecondYearSecond;
        Decimal concessionthirdYearThird;
    	Decimal concessionfourthYearFourth;
    	Decimal concessionfifthYearFifth;
        
        hed__Application__c application = [SELECT Id, hed__Applicant__c,First_Payment_Date__c, hed__Application_Status__c, Concession_Status__c, Concession_1st_Year__c, 
                                                Concession_2nd_Year__c, Concession_3rd_Year__c, Concession_4th_Year__c, Concession_5th_Year__c, School__c, 
                                                Application_Number__c, hed__Applying_To__r.Name,Provisional_Admission_Fee_Paid__c, hed_Scholarship__r.Category__c,hed__Applying_To__r.No_of_Years__c
                                                FROM hed__Application__c Where id = : stdCtrl.getId()];
        Contact contact = [SELECT Id, Name, Email,Phone FROM Contact WHERE Id = : application.hed__Applicant__c]; 
        //System.debug('contact --> '+contact.Id);
        List<Student_Payment__c> studentPymtList = [SELECT Id, Name, Amount__c, Fee_Type__c, Payment_Date_Time__c, Payment_Status__c, Transaction_Date_Time__c, Transaction_Status__c, Contact__c
        FROM Student_Payment__c WHERE Contact__c = :contact.Id AND (Fee_Type__c LIKE '%Tuition Fee%' OR Fee_Type__c like '%University Fee%') AND Payment_Status__c = 'Success'
        ORDER BY CreatedDate desc
        ];
        //System.debug('studentPymt --> '+studentPymtList);
        if (!studentPymtList.isEmpty() && application.Provisional_Admission_Fee_Paid__c == true) {
            //System.debug('inside if --> setting date value '+studentPymtList[0].Payment_Date_Time__c);
            transactionDateTime = studentPymtList[0].Payment_Date_Time__c;
        }else if (application.Provisional_Admission_Fee_Paid__c == true ) {
            transactionDateTime = application.First_Payment_Date__c;
        } else {
            // Handle the case where no related records are found
            //System.debug('inside else --> setting null value ');
            transactionDateTime = null; // Or set a default value
        }
      
        
            applicationStatus = application.hed__Application_Status__c;
            concessionStatus = application.Concession_Status__c;
            concessionFirstYearFirst = application.Concession_1st_Year__c;
            if (concessionFirstYearFirst == null) {
                concessionFirstYearFirst = 0;
            }
            concessionsecondYearSecond = application.Concession_2nd_Year__c;
            concessionthirdYearThird = application.Concession_3rd_Year__c;
            concessionfourthYearFourth = application.Concession_4th_Year__c;
            //system.debug('concessionfourthYearFourth '+concessionfourthYearFourth);
            concessionfifthYearFifth = application.Concession_5th_Year__c;
        	concessionFirstYear = String.valueOf(concessionFirstYearFirst.format());
        	concessionsecondYear = String.valueOf(concessionsecondYearSecond.format());
        	concessionthirdYear = String.valueOf(concessionthirdYearThird.format());
        	concessionfourthYear = String.valueOf(concessionfourthYearFourth.format());
            //system.debug('concessionfourthYear '+concessionfourthYear);
        	concessionfifthYear = String.valueOf(concessionfifthYearFifth.format());
            PAFStatus = application.Provisional_Admission_Fee_Paid__c;
            schoolApplied = application.School__c;
            applicationNumber = application.Application_Number__c;
            programApplied = application.hed__Applying_To__r.Name;
            scholarshipCategory = application.hed_Scholarship__r.Category__c;
            num = application.hed__Applying_To__r.No_of_Years__c;
            //system.debug('num' +num);
            NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
            Words = cls.convert(integer.valueOf(num));
            //system.debug('Words' +Words);
            
        
        AggregateResult firstYearFeeResult = [SELECT SUM(Actual_Program_Fee__c)firstYeartotalProgramFee, COUNT(ID)firstYearnoOfRec, SUM(Premium__c)firstYeartotalPremium, 
                                             SUM(Scholarship__c)firstYeartotalScholarship, SUM(Concession__c)firstYeartotalConcession
                                             FROM Student_Fee__c WHERE Fee_Year__c = : firstYear AND Contact__c = : contact.Id];
        firstYearFeeRecordSize = (Integer)firstYearFeeResult.get('firstYearnoOfRec');                   
            if(firstYearFeeRecordSize > 0)
            {
                firstYearAnnualFeeFirst = ((Decimal)firstYearFeeResult.get('firstYeartotalProgramFee') != null ? (Decimal)firstYearFeeResult.get('firstYeartotalProgramFee') : 0) 
                                   + ((Decimal)firstYearFeeResult.get('firstYeartotalPremium') != null ? (Decimal)firstYearFeeResult.get('firstYeartotalPremium') : 0);
                firstYearScholarshipFirst = (Decimal)firstYearFeeResult.get('firstYeartotalScholarship');
                firstYearConcessionFirst = concessionFirstYearFirst;
                firstYearAnnualFee = String.valueOf(firstYearAnnualFeeFirst.format());
                firstYearScholarship = String.valueOf(firstYearScholarshipFirst.format());
                firstYearConcession = String.valueOf(firstYearConcessionFirst.format());
            }
            else 
            {
                firstYearAnnualFeeFirst = 0;
                firstYearAnnualFee =  String.valueOf(firstYearAnnualFeeFirst.format());
                firstYearScholarshipFirst = 0;
                firstYearScholarship =  String.valueOf(firstYearScholarshipFirst.format());
                firstYearConcessionFirst = 0;
                firstYearConcession =  String.valueOf(firstYearConcessionFirst.format());
            }
            Student_Fee__c[] provAdmStuFeeRecs = [SELECT Provisional_Admission_Fee__c FROM Student_Fee__c 
                            WHERE Fee_Year__c=:firstYear AND Fee_Type__c = : universityFeeType AND Contact__c = : contact.Id limit 1];
        
            Decimal provisionalAddFee;
            if(provAdmStuFeeRecs.size() !=0 )  provisionalAddFee = provAdmStuFeeRecs[0].Provisional_Admission_Fee__c;
            if(provisionalAddFee==Null) {
                firstPaymentPaf = 0;
                firstPayment = String.valueOf(firstPaymentPaf.format());
                System.debug('inside if firstPayment'+firstPayment);
            } 
            else  {
                firstPaymentPaf = provisionalAddFee;
                firstPayment = String.valueOf(firstPaymentPaf.format());
                System.debug('inside else firstPayment'+firstPayment);
            }
        
           Student_Fee__c[] provAdmStuFeeRecSec = [SELECT Provisional_Admission_Fee__c FROM Student_Fee__c 
                            WHERE Fee_Year__c=:secondYear AND Fee_Type__c = : universityFeeType AND Contact__c = : contact.Id limit 1];
        
            Decimal provisionalAddFee2;
            if(provAdmStuFeeRecSec.size() !=0 )  provisionalAddFee2 = provAdmStuFeeRecSec[0].Provisional_Admission_Fee__c;
            if(provisionalAddFee2==Null)  {
                SecondPaymentPaf = 0;
                SecondPayment = String.valueOf(SecondPaymentPaf.format());
                System.debug('inside if SecondPayment'+SecondPayment);
              } 
            else {
                SecondPaymentPaf = provisionalAddFee2;
                SecondPayment = String.valueOf(SecondPaymentPaf.format());
                System.debug('inside else SecondPayment'+SecondPayment);
            }
          Student_Fee__c[] provAdmStuFeeRecThird = [SELECT Provisional_Admission_Fee__c FROM Student_Fee__c 
                            WHERE Fee_Year__c=:thirdYear AND Fee_Type__c = : universityFeeType AND Contact__c = : contact.Id limit 1];
        
            Decimal provisionalAddFee3;
            if(provAdmStuFeeRecThird.size() !=0 )  provisionalAddFee3 = provAdmStuFeeRecThird[0].Provisional_Admission_Fee__c;
            if(provisionalAddFee3==Null)  {
                ThirdPaymentPaf = 0;
                ThirdPayment = String.valueOf(ThirdPaymentPaf.format());
              } 
            else {
                ThirdPaymentPaf = provisionalAddFee3;
               ThirdPayment = String.valueOf(ThirdPaymentPaf.format());
            }
       Student_Fee__c[] provAdmStuFeeRecFourth = [SELECT Provisional_Admission_Fee__c FROM Student_Fee__c 
                            WHERE Fee_Year__c=:fourthYear AND Fee_Type__c = : universityFeeType AND Contact__c = : contact.Id limit 1];
        
            Decimal provisionalAddFee4;
            if(provAdmStuFeeRecFourth.size() !=0 )  provisionalAddFee4 = provAdmStuFeeRecFourth[0].Provisional_Admission_Fee__c;
            if(provisionalAddFee4==Null)  {
                fourthPaymentPaf = 0;
                fourthPayment = String.valueOf(fourthPaymentPaf.format());
              } 
            else {
                fourthPaymentPaf = provisionalAddFee4;
               fourthPayment = String.valueOf(fourthPaymentPaf.format());
            }
        Student_Fee__c[] provAdmStuFeeRecfifth = [SELECT Provisional_Admission_Fee__c FROM Student_Fee__c 
                            WHERE Fee_Year__c=:fifthYear AND Fee_Type__c = : universityFeeType AND Contact__c = : contact.Id limit 1];
        
            Decimal provisionalAddFee5;
            if(provAdmStuFeeRecfifth.size() !=0 )  provisionalAddFee5 = provAdmStuFeeRecfifth[0].Provisional_Admission_Fee__c;
            if(provisionalAddFee5==Null)  {
                fifthPaymentPaf = 0;
                fifthPayment = String.valueOf(fifthPaymentPaf.format());
              } 
            else {
                fifthPaymentPaf = provisionalAddFee5;
               fifthPayment = String.valueOf(fifthPaymentPaf.format());
            }
        
        AggregateResult  secondYearFeeResult = [SELECT SUM(Actual_Program_Fee__c)secondYeartotalProgramFee, COUNT(ID)secondYearnoOfRec, SUM(Premium__c)secondYeartotalPremium, 
                                                SUM(Scholarship__c)secondYeartotalScholarship, SUM(Concession__c)secondYeartotalConcession 
                                                FROM Student_Fee__c WHERE Fee_Year__c = : secondYear AND Contact__c = : contact.Id];
            //System.debug('agregate result is -->'+secondYearFeeResult);
            secondYearFeeRecordSize = (Integer)secondYearFeeResult.get('secondYearnoOfRec');                    
            if(secondYearFeeRecordSize > 0) {
                secondYearAnnualFeeSecond = ((Decimal)secondYearFeeResult.get('secondYeartotalProgramFee') != null ? (Decimal)secondYearFeeResult.get('secondYeartotalProgramFee') : 0) + 
                        ((Decimal)secondYearFeeResult.get('secondYeartotalPremium') != null ? (Decimal)secondYearFeeResult.get('secondYeartotalPremium') : 0);
                secondYearScholarshipSecond = (Decimal)secondYearFeeResult.get('secondYeartotalScholarship');
                secondYearConcessionSecond = concessionsecondYearSecond;
                secondYearAnnualFee = String.valueOf(secondYearAnnualFeeSecond.format());
                secondYearScholarship = String.valueOf(secondYearScholarshipSecond.format());
                secondYearConcession = String.valueOf(secondYearConcessionSecond.format());
            } 
            else 
            {
                secondYearAnnualFeeSecond = 0;
                secondYearAnnualFee =  String.valueOf(secondYearAnnualFeeSecond.format());
                secondYearScholarshipSecond = 0;
                secondYearScholarship =  String.valueOf(secondYearScholarshipSecond.format());
                secondYearConcessionSecond = 0;
                secondYearConcession =  String.valueOf(secondYearScholarshipSecond.format());
            }
        AggregateResult  thirdYearFeeResult = [SELECT SUM(Actual_Program_Fee__c)thirdYeartotalProgramFee, COUNT(ID)thirdYearNoOfRec, SUM(Premium__c)thirdYeartotalPremium, 
                                                SUM(Scholarship__c)thirdYeartotalScholarship, SUM(Concession__c)thirdYeartotalConcession 
                                                FROM Student_Fee__c WHERE Fee_Year__c = : thirdYear AND Contact__c = : contact.Id];
            thirdYearFeeRecordSize = (Integer)thirdYearFeeResult.get('thirdYearNoOfRec');                  
            if(thirdYearFeeRecordSize > 0)
            {
                thirdYearAnnualFeeThird = ((Decimal)thirdYearFeeResult.get('thirdYeartotalProgramFee') != null ? (Decimal)thirdYearFeeResult.get('thirdYeartotalProgramFee') : 0) 
                                        + ((Decimal)thirdYearFeeResult.get('thirdYeartotalPremium') != null ? (Decimal)thirdYearFeeResult.get('thirdYeartotalPremium') : 0);
                thirdYearScholarshipThird = (Decimal)thirdYearFeeResult.get('thirdYeartotalScholarship');
                thirdYearConcessionThird =concessionthirdYearThird ;
                thirdYearAnnualFee = String.valueOf(thirdYearAnnualFeeThird.format());
                thirdYearScholarship = String.valueOf(thirdYearScholarshipThird.format());
                thirdYearConcession = String.valueOf(thirdYearConcessionThird.format());
            }
            else 
            {
                thirdYearAnnualFeeThird = 0;
                thirdYearAnnualFee =  String.valueOf(thirdYearAnnualFeeThird.format());
                thirdYearScholarshipThird = 0;
                thirdYearScholarship =  String.valueOf(thirdYearScholarshipThird.format());
                thirdYearConcessionThird = 0;
                thirdYearConcession =  String.valueOf(thirdYearConcessionThird.format());

            }
        AggregateResult fourthYearFeeResult = [SELECT SUM(Actual_Program_Fee__c)fourthYeartotalProgramFee, COUNT(ID)fourthYearNoOfRec, SUM(Premium__c)fourthYeartotalPremium, 
                                                SUM(Scholarship__c)fourthYeartotalScholarship, SUM(Concession__c)fourthYeartotalConcession 
                                                FROM Student_Fee__c WHERE Fee_Year__c = : fourthYear AND Contact__c = : contact.Id];
            fourthYearFeeRecordSize = (Integer)fourthYearFeeResult.get('fourthYearNoOfRec');                   
            if(fourthYearFeeRecordSize > 0) 
            {
                fourthYearAnnualFeeFourth = ((Decimal)fourthYearFeeResult.get('fourthYeartotalProgramFee') != null ? (Decimal)fourthYearFeeResult.get('fourthYeartotalProgramFee') : 0) 
                                        + ((Decimal)fourthYearFeeResult.get('fourthYeartotalPremium') != null ? (Decimal)fourthYearFeeResult.get('fourthYeartotalPremium') : 0);
                fourthYearScholarshipFourth = (Decimal)fourthYearFeeResult.get('fourthYeartotalScholarship');
                fourthYearConcessionFourth = concessionfourthYearFourth;
                fourthYearAnnualFee = String.valueOf(fourthYearAnnualFeeFourth.format());
                fourthYearScholarship = String.valueOf(fourthYearScholarshipFourth.format());
                fourthYearConcession = String.valueOf(fourthYearConcessionFourth.format());
            }
            else 
            {
                fourthYearAnnualFeeFourth = 0;
                fourthYearAnnualFee = String.valueOf(fourthYearAnnualFeeFourth.format());
                fourthYearScholarshipFourth = 0;
                fourthYearScholarship = String.valueOf(fourthYearScholarshipFourth.format());
                fourthYearConcessionFourth = 0;
                fourthYearConcession = String.valueOf(fourthYearConcessionFourth.format());
            }
        AggregateResult fifthYearFeeResult = [SELECT SUM(Actual_Program_Fee__c)fifthYeartotalProgramFee, COUNT(ID)fifthYearNoOfRec, SUM(Premium__c)fifthYeartotalPremium, 
                                                SUM(Scholarship__c)fifthYeartotalScholarship, SUM(Concession__c)fifthYeartotalConcession 
                                                FROM Student_Fee__c WHERE Fee_Year__c = : fifthYear AND Contact__c = : contact.Id];
            fifthYearFeeRecordSize = (Integer)fifthYearFeeResult.get('fifthYearNoOfRec');                   
            if(fifthYearFeeRecordSize > 0) 
            {
                fifthYearAnnualFeeFifth = ((Decimal)fifthYearFeeResult.get('fifthYeartotalProgramFee') != null ? (Decimal)fifthYearFeeResult.get('fifthYeartotalProgramFee') : 0)
                                         + ((Decimal)fifthYearFeeResult.get('fifthYeartotalPremium') != null ? (Decimal)fifthYearFeeResult.get('fifthYeartotalPremium') : 0);
                fifthYearScholarshipFifth = (Decimal)fifthYearFeeResult.get('fifthYeartotalScholarship');
                fifthYearConcessionFifth = concessionfifthYearFifth;
                fifthYearAnnualFee = String.valueOf(fifthYearAnnualFeeFifth.format());
                fifthYearScholarship = String.valueOf(fifthYearScholarshipFifth.format());
                fifthYearConcession = String.valueOf(fifthYearConcessionFifth.format());
            } 
            else 
            {
                fifthYearAnnualFeeFifth = 0;
                fifthYearAnnualFee =  String.valueOf(fifthYearAnnualFeeFifth.format());
                fifthYearScholarshipFifth = 0;
                fifthYearScholarship = String.valueOf(fifthYearScholarshipFifth.format());
                fifthYearConcessionFifth = 0;
                fifthYearConcession = String.valueOf(fifthYearConcessionFifth.format());
            }
            
        
        // For Foreign Nationals same scholarship should apply for all years
             // if(isForeigner){

        Decimal foreignScholarship = firstYearScholarshipFirst != null 
            ? firstYearScholarshipFirst 
            : 0;

    // Apply scholarship only if annual fee exists
    if(secondYearAnnualFeeSecond > 0){
        secondYearScholarshipSecond = foreignScholarship;
        secondYearScholarship = String.valueOf(secondYearScholarshipSecond.format());
    }

    if(thirdYearAnnualFeeThird > 0){
        thirdYearScholarshipThird = foreignScholarship;
        thirdYearScholarship = String.valueOf(thirdYearScholarshipThird.format());
    }

    if(fourthYearAnnualFeeFourth > 0){
        fourthYearScholarshipFourth = foreignScholarship;
        fourthYearScholarship = String.valueOf(fourthYearScholarshipFourth.format());
    }

    if(fifthYearAnnualFeeFifth > 0){
        fifthYearScholarshipFifth = foreignScholarship;
        fifthYearScholarship = String.valueOf(fifthYearScholarshipFifth.format());
     }
 // }
        
        totalAnnualFeeTot = firstYearAnnualFeeFirst + secondYearAnnualFeeSecond + thirdYearAnnualFeeThird + fourthYearAnnualFeeFourth + fifthYearAnnualFeeFifth;
        totalScholarshipTot= firstYearScholarshipFirst + secondYearScholarshipSecond + thirdYearScholarshipThird + fourthYearScholarshipFourth + fifthYearScholarshipFifth;
        totalConcessionTot = firstYearConcessionFirst + secondYearConcessionSecond + thirdYearConcessionThird + fourthYearConcessionFourth + fifthYearConcessionFifth;
        totalPAFTot = firstPaymentPaf + SecondPaymentPaf + ThirdPaymentPaf + fourthPaymentPaf + fifthPaymentPaf;
        totalAnnualFee = String.valueOf(totalAnnualFeeTot.format());
        totalScholarship = String.valueOf(totalScholarshipTot.format());
        totalConcession = String.valueOf(totalConcessionTot.format());
        totalPAFFee = String.valueOf(totalPAFTot.format());
        
        firstYearBalance1 = firstYearAnnualFeeFirst - firstPaymentPaf - firstYearScholarshipFirst - firstYearConcessionFirst;
        secondYearBalance1 = secondYearAnnualFeeSecond -SecondPaymentPaf- secondYearScholarshipSecond - secondYearConcessionSecond;
        thirdYearBalance1= thirdYearAnnualFeeThird - ThirdPaymentPaf- thirdYearScholarshipThird - thirdYearConcessionThird;
        fourthYearBalance1 = fourthYearAnnualFeeFourth - fourthPaymentPaf -fourthYearScholarshipFourth - fourthYearConcessionFourth;
        fifthYearBalance1 = fifthYearAnnualFeeFifth - fifthPaymentPaf- fifthYearScholarshipFifth - fifthYearConcessionFifth;
        totalBalance1 = totalAnnualFeeTot - totalPAFTot - totalScholarshipTot - totalConcessionTot;  
        firstYearBalance  = String.valueOf(firstYearBalance1.format());
        secondYearBalance = String.valueOf(secondYearBalance1.format());
        thirdYearBalance = String.valueOf(thirdYearBalance1.format());
        fourthYearBalance = String.valueOf(fourthYearBalance1.format());
        fifthYearBalance = String.valueOf(fifthYearBalance1.format());
        totalBalance = String.valueOf(totalBalance1.format());
    }   
   
}