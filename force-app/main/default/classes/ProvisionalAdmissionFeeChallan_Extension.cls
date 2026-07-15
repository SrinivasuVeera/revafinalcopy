public with sharing class ProvisionalAdmissionFeeChallan_Extension {
    private ApexPages.StandardController stdCtrl {get; set;}
    public string studentPaymentId {get; set;}
    public date today {get; set;}
    public string name {get; set;}
    public string currentUserProfileName {get; set;}
    public string currentUserName {get; set;}
    public string recordOwnerUsername {get; set;}
    public decimal tuitionTotalFee {get; set;}
    public decimal universityTotalFee {get; set;}
    public decimal universityPendingAmt {get; set;}
    public List<ProvisionalAdmissionFeeChallanWrapper> PAFList {get; set;}
    // Map<Id,Decimal> receiptMap {get;set;}
    Map<String,Student_Fee__c> StudentFeeMap {get;set;}
    // Map<String,Decimal> StudentFeeLocalAmountMap {get;set;}
    // Map<Id,Map<String,Decimal>> finalMap {get;set;}
    // Map<Id,String> yearMap {get;set;}

    public  ProvisionalAdmissionFeeChallan_Extension(ApexPages.StandardController stdController) {
        // system.debug('inside ProvisionalAdmissionFeeChallan_Extension');
        stdCtrl = stdController;
        PAFList = new List<ProvisionalAdmissionFeeChallanWrapper>();
        studentPaymentId = stdController.getId();
        tuitionTotalFee = 0;
        // receiptMap = new Map<Id,Decimal>();
        StudentFeeMap = new Map<String,Student_Fee__c>();
        // StudentFeeLocalAmountMap = new Map<String,Decimal>();
        // finalMap = new Map<Id,Map<String,Decimal>>();
        // yearMap = new Map<Id,String>();
        // universityTotalFee = 0;
        setupChallan();
    }

    // public void calc(Integer i,Student_Payment__c stpn){
    //     Map<String,Decimal> amountMap = new Map<String,Decimal>();
    //     if(this.StudentFeeLocalAmountMap.get('Tuition Fee 1st year') > 0){
    //         System.debug('inside 1st year');
    //         if(stpn.Amount__c <= this.StudentFeeLocalAmountMap.get('University Fee 1st year')){
    //             System.debug('inside if 1st year');
    //             amountMap.put('universityAmount',stpn.Amount__c);
    //             amountMap.put('tuitionAmount',0);
    //             // System.debug('amount map is '+amountMap);
    //             this.StudentFeeLocalAmountMap.put('University Fee 1st year',this.StudentFeeLocalAmountMap.get('University Fee 1st year') - stpn.Amount__c);
    //         } else if(stpn.Amount__c <= this.StudentFeeLocalAmountMap.get('Tuition Fee 1st year')){
    //             System.debug('inside else');
    //             amountMap.put('universityAmount',this.StudentFeeLocalAmountMap.get('University Fee 1st year'));
    //             amountMap.put('tuitionAmount',(stpn.Amount__c - this.StudentFeeLocalAmountMap.get('University Fee 1st year')) > this.StudentFeeLocalAmountMap.get('Tuition Fee 1st year') ? this.StudentFeeLocalAmountMap.get('Tuition Fee 1st year') : stpn.Amount__c - this.StudentFeeLocalAmountMap.get('University Fee 1st year'));
    //             this.StudentFeeLocalAmountMap.put('University Fee 1st year',(this.StudentFeeLocalAmountMap.get('University Fee 1st year') - stpn.Amount__c) > 0 ? (this.StudentFeeLocalAmountMap.get('University Fee 1st year') - stpn.Amount__c) : 0 );
    //             this.StudentFeeLocalAmountMap.put('Tuition Fee 1st year',(this.StudentFeeLocalAmountMap.get('Tuition Fee 1st year') - amountMap.get('tuitionAmount')) > 0 ? (this.StudentFeeLocalAmountMap.get('Tuition Fee 1st year') - amountMap.get('tuitionAmount')) : 0);
                
    //             System.debug('Student_Payment__c amount is '+stpn.Amount__c);
    //             System.debug('amount map is '+amountMap);
    //             System.debug('StudentFeeLocalAmountMap '+this.StudentFeeLocalAmountMap);
    //             yearMap.put(stpn.id,'1st Year');
    //         } else {
                
    //             if(stpn.Amount__c <= this.StudentFeeLocalAmountMap.get('University Fee 2nd year')){
    //                 System.debug('important area stpn amount if '+stpn.Amount__c);
    //                 amountMap.put('universityAmount',stpn.Amount__c);
    //                 amountMap.put('tuitionAmount',0);
    //                 System.debug('amount map is '+amountMap);
    //                 this.StudentFeeLocalAmountMap.put('University Fee 2nd year',this.StudentFeeLocalAmountMap.get('University Fee 2nd year') - stpn.Amount__c);
    //             } else {
    //                 amountMap.put('universityAmount',this.StudentFeeLocalAmountMap.get('University Fee 2nd year'));
    //                 amountMap.put('tuitionAmount',stpn.Amount__c - this.StudentFeeLocalAmountMap.get('University Fee 2nd year'));
    //                 System.debug('important area stpn amount else '+stpn.Amount__c);
    //                 System.debug('amount map is '+amountMap);
    //                 this.StudentFeeLocalAmountMap.put('University Fee 1st year',0);
    //                 this.StudentFeeLocalAmountMap.put('Tuition Fee 1st year',0);
    //             }
                
    //             yearMap.put(stpn.Id,'1st Year & 2nd Year');
    //             // System.debug('Student_Payment__c amount is '+stpn.Amount__c);
    //             // System.debug('amount map is '+amountMap);
    //             // System.debug('StudentFeeLocalAmountMap '+this.StudentFeeLocalAmountMap);
    //         }
    //     } else if(this.StudentFeeLocalAmountMap.get('Tuition Fee 2nd year') > 0){
    //         // System.debug('inside 2nd year');
    //         if(stpn.Amount__c <= this.StudentFeeLocalAmountMap.get('University Fee 2nd year')){
    //             System.debug('inside if 2nd year');
    //             if(this.StudentFeeLocalAmountMap.get('Tuition Fee 1st year') > 0){
    //                 System.debug('inside 2nd if 2nd year');
    //                 amountMap.put('universityAmount',0);
    //                 amountMap.put('tuitionAmount',stpn.Amount__c);

    //             } else {
    //                 System.debug('inside 2nd else 2nd year');
    //                 amountMap.put('universityAmount',stpn.Amount__c);
    //                 amountMap.put('tuitionAmount',0);
    //                 // System.debug('amount map is '+amountMap);
                    
    //             }
    //             this.StudentFeeLocalAmountMap.put('University Fee 2nd year',this.StudentFeeLocalAmountMap.get('University Fee 2nd year') - stpn.Amount__c);
                
    //         } else {
    //             System.debug('inside else');
    //             amountMap.put('universityAmount',this.StudentFeeLocalAmountMap.get('University Fee 2nd year'));
    //             amountMap.put('tuitionAmount',stpn.Amount__c - this.StudentFeeLocalAmountMap.get('University Fee 2nd year'));
    //             // System.debug('amount map is '+amountMap);
    //             this.StudentFeeLocalAmountMap.put('University Fee 2nd year',(this.StudentFeeLocalAmountMap.get('University Fee 2nd year') - stpn.Amount__c) > 0 ? (this.StudentFeeLocalAmountMap.get('University Fee 2nd year') - stpn.Amount__c) : 0 );
    //             this.StudentFeeLocalAmountMap.put('Tuition Fee 2nd year',(this.StudentFeeLocalAmountMap.get('Tuition Fee 2nd year') - amountMap.get('tuitionAmount')) > 0 ? (this.StudentFeeLocalAmountMap.get('Tuition Fee 2nd year') - amountMap.get('tuitionAmount')) : 0);
    //         }
            
    //     } else if(this.StudentFeeLocalAmountMap.get('Tuition Fee 3rd year') > 0){
    //         System.debug('inside 3rd year');
    //         if(stpn.Amount__c <= this.StudentFeeLocalAmountMap.get('University Fee 3rd year')){
    //             System.debug('inside if 3rd year');
    //             if(this.StudentFeeLocalAmountMap.get('Tuition Fee 2nd year') > 0){
    //                 System.debug('inside 2nd if 2nd year');
    //                 amountMap.put('universityAmount',0);
    //                 amountMap.put('tuitionAmount',stpn.Amount__c);

    //             } else {
    //                 System.debug('inside 2nd else 2nd year');
    //                 amountMap.put('universityAmount',stpn.Amount__c);
    //                 amountMap.put('tuitionAmount',0);
    //                 // System.debug('amount map is '+amountMap);
                    
    //             }
    //             this.StudentFeeLocalAmountMap.put('University Fee 3rd year',this.StudentFeeLocalAmountMap.get('University Fee 3rd year') - stpn.Amount__c);
    //         } else {
    //             System.debug('inside else');
    //             amountMap.put('universityAmount',this.StudentFeeLocalAmountMap.get('University Fee 3rd year'));
    //             amountMap.put('tuitionAmount',stpn.Amount__c - this.StudentFeeLocalAmountMap.get('University Fee 3rd year'));
    //             // System.debug('amount map is '+amountMap);
    //             this.StudentFeeLocalAmountMap.put('University Fee 3rd year',(this.StudentFeeLocalAmountMap.get('University Fee 3rd year') - stpn.Amount__c) > 0 ? (this.StudentFeeLocalAmountMap.get('University Fee 3rd year') - stpn.Amount__c) : 0 );
    //             this.StudentFeeLocalAmountMap.put('Tuition Fee 3rd year',(this.StudentFeeLocalAmountMap.get('Tuition Fee 3rd year') - amountMap.get('tuitionAmount')) > 0 ? (this.StudentFeeLocalAmountMap.get('Tuition Fee 3rd year') - amountMap.get('tuitionAmount')) : 0);
    //             System.debug('Student_Payment__c amount is '+stpn.Amount__c);
    //             System.debug('amount map is '+amountMap);
    //             System.debug('StudentFeeLocalAmountMap '+this.StudentFeeLocalAmountMap);
    //         }
    //     } else if(this.StudentFeeLocalAmountMap.get('Tuition Fee 4th year') > 0){
    //         System.debug('inside 4th year');
    //         if(stpn.Amount__c <= this.StudentFeeLocalAmountMap.get('University Fee 4th year')){
    //             System.debug('inside if 4th year');
    //             if(this.StudentFeeLocalAmountMap.get('Tuition Fee 3rd year') > 0){
    //                 System.debug('inside 2nd if 4th year');
    //                 amountMap.put('universityAmount',0);
    //                 amountMap.put('tuitionAmount',stpn.Amount__c);

    //             } else {
    //                 System.debug('inside 2nd else 4th year');
    //                 amountMap.put('universityAmount',stpn.Amount__c);
    //                 amountMap.put('tuitionAmount',0);
    //                 // System.debug('amount map is '+amountMap);
                    
    //             }
    //             // System.debug('amount map is '+amountMap);
    //             this.StudentFeeLocalAmountMap.put('University Fee 4th year',this.StudentFeeLocalAmountMap.get('University Fee 4th year') - stpn.Amount__c);
    //         } else {
    //             // System.debug('inside else');
    //             amountMap.put('universityAmount',this.StudentFeeLocalAmountMap.get('University Fee 4th year'));
    //             amountMap.put('tuitionAmount',stpn.Amount__c - this.StudentFeeLocalAmountMap.get('University Fee 4th year'));
    //             // System.debug('amount map is '+amountMap);
    //             this.StudentFeeLocalAmountMap.put('University Fee 4th year',(this.StudentFeeLocalAmountMap.get('University Fee 4th year') - stpn.Amount__c) > 0 ? (this.StudentFeeLocalAmountMap.get('University Fee 4th year') - stpn.Amount__c) : 0 );
    //             this.StudentFeeLocalAmountMap.put('Tuition Fee 4th year',(this.StudentFeeLocalAmountMap.get('Tuition Fee 4th year') - amountMap.get('tuitionAmount')) > 0 ? (this.StudentFeeLocalAmountMap.get('Tuition Fee 4th year') - amountMap.get('tuitionAmount')) : 0);
    //         }
    //     } else if(this.StudentFeeLocalAmountMap.get('Tuition Fee 5th year') > 0){
    //         System.debug('inside 5th year');
    //         if(stpn.Amount__c <= this.StudentFeeLocalAmountMap.get('University Fee 5th year')){
    //             System.debug('inside if 5th year');
    //             if(this.StudentFeeLocalAmountMap.get('Tuition Fee 4th year') > 0){
    //                 System.debug('inside 2nd if 5th year');
    //                 amountMap.put('universityAmount',0);
    //                 amountMap.put('tuitionAmount',stpn.Amount__c);

    //             } else {
    //                 System.debug('inside 2nd else 4th year');
    //                 amountMap.put('universityAmount',stpn.Amount__c);
    //                 amountMap.put('tuitionAmount',0);
    //                 // System.debug('amount map is '+amountMap);
                    
    //             }
    //             // System.debug('amount map is '+amountMap);
    //             this.StudentFeeLocalAmountMap.put('University Fee 5th year',this.StudentFeeLocalAmountMap.get('University Fee 5th year') - stpn.Amount__c);
    //         } else {
    //             // System.debug('inside else');
    //             amountMap.put('universityAmount',this.StudentFeeLocalAmountMap.get('University Fee 5th year'));
    //             amountMap.put('tuitionAmount',stpn.Amount__c - this.StudentFeeLocalAmountMap.get('University Fee 5th year'));
    //             // System.debug('amount map is '+amountMap);
    //             this.StudentFeeLocalAmountMap.put('University Fee 5th year',(this.StudentFeeLocalAmountMap.get('University Fee 5th year') - stpn.Amount__c) > 0 ? (this.StudentFeeLocalAmountMap.get('University Fee 5th year') - stpn.Amount__c) : 0 );
    //             this.StudentFeeLocalAmountMap.put('Tuition Fee 5th year',(this.StudentFeeLocalAmountMap.get('Tuition Fee 5th year') - amountMap.get('tuitionAmount')) > 0 ? (this.StudentFeeLocalAmountMap.get('Tuition Fee 5th year') - amountMap.get('tuitionAmount')) : 0);
    //         }
    //     }
    //     this.receiptMap.put(stpn.id,stpn.Amount__c);
    //     this.finalMap.put(stpn.id,amountMap);
    //     // System.debug(this.StudentFeeLocalAmountMap);
    // }

    public void setupChallan() {
        system.debug('inside setup challan');
         //******** For button on Student Payment ********* */
       /* Student_Payment__c studentPayment = [Select Id, Contact__c, Contact__r.Name, Amount__c, Application_Number__c, Offline_Receipt_Number__c, 
                                            Payment_Mode_Type__c, Contact__r.Program_Name__c From Student_Payment__c 
                                            Where Id = : stdCtrl.getId()];
            applicantName = studentPayment.Contact__r.Name;
            applicationNumber = studentPayment.Application_Number__c;
            program = studentPayment.Contact__r.Program_Name__c;
            modeOfPaymentType = studentPayment.Payment_Mode_Type__c;
            challanNo = studentPayment.Offline_Receipt_Number__c;
            totalPAFAmount = studentPayment.Amount__c;
            today = system.today();

        decimal provisionalAdmFee = [SELECT Provisional_Admission_Fee__c, Id, Contact__c, Fee_Type__c, Fee_Year__c FROM Student_Fee__c 
                                        WHERE Fee_Year__c = '1st Year' AND Fee_Type__c = 'University Fee' AND Contact__c = : studentPayment.Contact__c].Provisional_Admission_Fee__c;

        Student_Fee_Payment__c uniStuFeePaymentsRec = [Select Id, Payment_Mode_Type__c, Cheque_DD_Number__c,Cheque_DD_Date__c, Mode_of_Payment__c, Student_Fee__r.Name, 
                                                        Amount__c, Student_Fee__c, Student_Payment__c From Student_Fee_Payment__c 
                                                        Where Student_Payment__c = : studentPayment.Id AND Student_Fee__r.Name = 'University Fee 1st year'];
            universityPendingAmt = uniStuFeePaymentsRec.Amount__c;
            if (uniStuFeePaymentsRec.Payment_Mode_Type__c == 'Cheque / DD') {
                chequeDDNumber = uniStuFeePaymentsRec.Cheque_DD_Number__c;
                chequeDDDate = uniStuFeePaymentsRec.Cheque_DD_Date__c;
            }
        if (provisionalAdmFee > universityPendingAmt) {
            Student_Fee_Payment__c tutionStuFeePaymentsRec = [Select Id, Payment_Mode_Type__c, Cheque_DD_Number__c, Mode_of_Payment__c, Student_Fee__r.Name, 
                                                    Amount__c, Student_Fee__c, Student_Payment__c From Student_Fee_Payment__c 
                                                    Where Student_Payment__c = : studentPayment.Id AND Student_Fee__r.Name = 'Tuition Fee 1st year'];
                
            tuitionPendingAmt = tutionStuFeePaymentsRec.Amount__c;
        }
        system.debug('totalPAFAmount'+ totalPAFAmount);
        NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
        totalInWords = cls.convert(integer.valueOf(totalPAFAmount));
        name =[select id,Name,ContactId from User where id=:userinfo.getUserId()].Name; */

        //******** For button on Application ********* */
        String applicantId = [Select Id, Name, hed__Applicant__c From hed__Application__c Where ID = : stdCtrl.getId()].hed__Applicant__c;
        Contact applicant = [Select Id, Name,owner.name, Owner.username From Contact Where Id = : applicantId];
        Map<Id,Decimal> universityAmountMap = new Map<Id,Decimal>();
        Map<Id,Decimal> tuitionAmountMap = new Map<Id,Decimal>();
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        this.currentUserName = UserInfo.getUserName();
        this.recordOwnerUsername = applicant.Owner.Username;
        this.currentUserProfileName = PROFILE[0].Name;
        name =[select id,Name,ContactId from User where id=:userinfo.getUserId()].Name;
        today = system.today();

        
        // List<Student_Fee__c> stufeeList = [SELECT Provisional_Admission_Fee__c, Id, Contact__c, Fee_Type__c, Fee_Year__c FROM Student_Fee__c 
        //                                         WHERE Fee_Year__c = '1st Year' AND Fee_Type__c = 'University Fee' AND Contact__c = : applicant.Id];
        for(Student_Fee__c sf : [SELECT name, Amount__c, Provisional_Admission_Fee__c, Id, Contact__c, Fee_Type__c, Fee_Year__c FROM Student_Fee__c 
                                                WHERE Contact__c = : applicant.Id]){
            if(!sf.name.contains('Application Fee')){
                this.StudentFeeMap.put(sf.name,sf); 
                // this.StudentFeeLocalAmountMap.put(sf.name,sf.Amount__c);  
            }                          
        }
        // System.debug(this.StudentFeeAmountMap); 
        
      /*  Map<String,List<Student_Fee_Payment__c>> stfpMap = new Map<String,List<Student_Fee_Payment__c>>();
        // Map<String,List<Student_Fee_Payment__c>> stfpMap = new Map<String,List<Student_Fee_Payment__c>>();
        List<Student_Fee_Payment__c> stfpList = new List<Student_Fee_Payment__c>();
        Decimal localUniversityAmount = 0;
        Decimal localTuitionAmount = 0;
        for(Student_Fee_Payment__c stfp : [Select Id, Payment_Mode_Type__c, Cheque_DD_Number__c,Cheque_DD_Date__c, Mode_of_Payment__c, Student_Fee__r.Name, 
                                                        Amount__c, Student_Fee__c, Student_Payment__c, Student_Fee__r.contact__c, Student_Payment__r.contact__c From Student_Fee_Payment__c 
                                                        Where Student_Payment__r.contact__c =: applicant.Id AND Line_Item_Payment_Status__c = 'Pending']){
            if(stfpMap.get(stfp.Student_Fee__r.contact__c) == null){
                stfpList = new List<Student_Fee_Payment__c>();
                stfpList.add(stfp);
            }
            stfpMap.put(stfp.Student_Fee__r.Name,stfpList); 
            if(stfp.Student_Fee__r.Name.contains('university Fee')){
                localUniversityAmount += stfp.Amount__c;
            } else if(stfp.Student_Fee__r.Name.contains('tuition Fee')){
                localTuitionAmount += stfp.Amount__c;
            }
            System.debug('name ' + stfp.Student_Fee__r.Name + ' and the amount is --> '+ stfp.Amount__c);                                     
        }  
        
        System.debug(localTuitionAmount);  
        System.debug(stfpMap);      */                 
        List<Student_Payment__c> studentPaymentList = [Select Id, Contact__c, Contact__r.Name, Amount__c, Application_Number__c, Offline_Receipt_Number__c, 
                                            Payment_Mode_Type__c,ChequeDD_Number__c, ChequeDD_Date__c,Contact__r.Program_Name__c, Mode_of_Payment__c, Payment_Status__c, createdDate From Student_Payment__c 
                                            Where Contact__c = : applicantId and Payment_Status__c = 'Pending' and Mode_of_Payment__c != 'Online' order by createdDate asc];
        System.debug(studentPaymentList.size()); 
        if(studentPaymentList.size() > 0){
            /*Student_Fee_Payment__c uniStuFeePaymentsRec = [Select Id, Payment_Mode_Type__c, Cheque_DD_Number__c,Cheque_DD_Date__c, Mode_of_Payment__c, Student_Fee__r.Name, 
                                                Amount__c, Student_Fee__c, Student_Payment__c From Student_Fee_Payment__c 
                                                Where Student_Payment__c = : studentPaymentList[0].Id AND Student_Fee__r.Name = 'University Fee 1st year'];
            Student_Fee_Payment__c tutionStuFeePaymentsRec = [Select Id, Payment_Mode_Type__c, Cheque_DD_Number__c, Mode_of_Payment__c, Student_Fee__r.Name, 
                                                            Amount__c, Student_Fee__c, Student_Payment__c From Student_Fee_Payment__c 
                                                            Where Student_Payment__c = : studentPaymentList[0].Id AND Student_Fee__r.Name = 'Tuition Fee 1st year'];*/
        
            for(Student_Payment__c stp : studentPaymentList){
                 List<AggregateResult> aggregateResultsUF = [SELECT SUM(Amount__c) UniversitytotalAmount FROM Student_Fee_Payment__c where Student_Payment__c =: stp.Id and Student_Fee__r.Name Like '%University Fee%' ]; 
                     Decimal UniversitytotalAmount = (Decimal)aggregateResultsUF[0].get('UniversitytotalAmount');
                if(UniversitytotalAmount == null){
                    UniversitytotalAmount=0;
                }
                     List<AggregateResult> aggregateResultsTF = [SELECT SUM(Amount__c) TuitiontotalAmount FROM Student_Fee_Payment__c where Student_Payment__c =: stp.Id and Student_Fee__r.Name Like '%Tuition Fee%']; 
                     Decimal TuitiontotalAmount = (Decimal)aggregateResultsTF[0].get('TuitiontotalAmount');
                      if(TuitiontotalAmount == null){
                    TuitiontotalAmount=0;
                }
                 
             //   List<AggregateResult> aggregateResultsYear = [SELECT DISTINCT(Student_Fee__r.Name) FROM Student_Fee_Payment__c where Student_Payment__c =: stp.Id ]; 
          Set<String> uniqueStatusNames = new Set<String>();

        List<Student_Fee_Payment__c> studentFeePayments = [
            SELECT Student_Fee__r.Name
            FROM Student_Fee_Payment__c
            WHERE Student_Payment__c = :stp.Id
            AND (Student_Fee__r.Name LIKE '%1st Year%' OR Student_Fee__r.Name LIKE '%2nd Year%' OR Student_Fee__r.Name LIKE '%3rd Year%'OR Student_Fee__r.Name LIKE '%4th Year%'OR Student_Fee__r.Name LIKE '%5th Year%')
        ];
       Set<String> foundYears = new Set<String>();

    for (Student_Fee_Payment__c payment : studentFeePayments) {
    String statusName = payment.Student_Fee__r.Name;
    if ((statusName.contains('1st Year') && !foundYears.contains('1st Year')) || (statusName.contains('1st year') && !foundYears.contains('1st Year'))) {
        foundYears.add('1st Year');
    } else if ((statusName.contains('2nd Year') && !foundYears.contains('2nd Year')) || (statusName.contains('2nd year') && !foundYears.contains('2nd year'))) {
        foundYears.add('2nd Year');
    }else if ((statusName.contains('3rd Year') && !foundYears.contains('3rd Year')) || (statusName.contains('3rd year') && !foundYears.contains('3rd year'))) {
        foundYears.add('3rd Year');
    }else if ((statusName.contains('4th Year') && !foundYears.contains('4th Year')) || (statusName.contains('4th year') && !foundYears.contains('4th year'))) {
        foundYears.add('4th Year');
    }else if ((statusName.contains('5th Year') && !foundYears.contains('5th Year')) || (statusName.contains('5th year') && !foundYears.contains('5th year'))) {
        foundYears.add('5th Year');
    }
  }
        String concatenatedStatusNames = String.join(new List<String>(foundYears),',');
        // String concatenatedStatusNames = String.join(foundYears, ',');
        System.debug('Concatenated Status Names: ' + concatenatedStatusNames);
                        
                if(stp.Mode_of_Payment__c != 'Online'){
                    ProvisionalAdmissionFeeChallanWrapper pafChallan = new ProvisionalAdmissionFeeChallanWrapper();
                    pafChallan.applicantName = stp.Contact__r.Name;
                    pafChallan.applicationNumber = stp.Application_Number__c;
                    pafChallan.program = stp.Contact__r.Program_Name__c;
                    pafChallan.modeOfPaymentType = stp.Payment_Mode_Type__c;
                    pafChallan.challanNo = stp.Offline_Receipt_Number__c;
                    pafChallan.totalPAFAmount = stp.Amount__c;
                    pafChallan.universityFee=UniversitytotalAmount;
                    pafChallan.tuitionFee=TuitiontotalAmount;
                    pafChallan.yearWord=concatenatedStatusNames;
                    pafChallan.chequeDDNumber= stp.ChequeDD_Number__c;
                    pafChallan.chequeDDDate =  stp.ChequeDD_Date__c; 
                    // pafChallan.universityFee = (this.finalMap.get(stp.id)).get('universityAmount');
                    // pafChallan.tuitionFee = (this.finalMap.get(stp.id)).get('tuitionAmount');
                    // pafChallan.yearWord = this.yearMap.get(stp.id);
                    // System.debug(this.finalMap.get(stp.id).get('universityAmount'));
                    // if(stufeeList.size() > 0){
                    //     pafChallan.provisionalAdmFee = stufeeList[0].Provisional_Admission_Fee__c;
                    // }
                    // if(stfpMap.containsKey('University Fee 1st year')){
                    //     pafChallan.universityPendingAmt = (stfpMap.get('University Fee 1st year')).Amount__c;
                    //     if((stfpMap.get('University Fee 1st year')).Payment_Mode_Type__c == 'Cheque / DD'){
                    //         pafChallan.chequeDDNumber = (stfpMap.get('University Fee 1st year')).Cheque_DD_Number__c;
                    //         pafChallan.chequeDDDate = (stfpMap.get('University Fee 1st year')).Cheque_DD_Date__c;
                    //     }
                    //     if (pafChallan.provisionalAdmFee > pafChallan.universityPendingAmt) {
                    //         pafChallan.tuitionPendingAmt = (stfpMap.get('Tuition Fee 1st year')).Amount__c;
                    //     }
                    // }
                    NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
                    pafChallan.totalInWords = cls.convert(integer.valueOf(pafChallan.totalPAFAmount));
                    PAFList.add(pafChallan);
                }
                
            } 
        }
        //    system.debug(PAFList);
        // List<Student_Fee__c> stuFeesList = [SELECT Id, Name, Amount_Paid__c, Amount_Pending__c, Amount__c, Contact__c, Fee_Type__c, Scholarship__c, Fee_Name__c, Fee_Year__c, Fee_Master__c, Provisional_Admission_Fee__c  FROM Student_Fee__c WHERE Contact__c =: applicant.Id];

        // for(Student_Fee__c stf: stuFeesList){
        //     if(stf.Provisional_Admission_Fee__c > 0){
        //         if(stf.Name.contains('Tuition Fee')){
        //             this.tuitionTotalFee += stf.Amount_Pending__c;
        //         } else if(stf.Name.contains('University Fee')){
        //             this.universityTotalFee += stf.Amount_Pending__c;
        //         }
        //     }
        // }
        // this.tuitionTotalFee = localTuitionTotalFee;
        // this.universityTotalFee = localUniversityTotalFee;
    }


    public class ProvisionalAdmissionFeeChallanWrapper{
        @AuraEnabled public string challanNo{get;set;}
        @AuraEnabled public string applicantName{get;set;}
        @AuraEnabled public string applicationNumber{get;set;}
        @AuraEnabled public string program{get;set;}
        @AuraEnabled public Decimal tuitionPendingAmt{get;set;}
        @AuraEnabled public Decimal universityPendingAmt{get;set;}
        @AuraEnabled public Decimal totalPAFAmount{get;set;}   
        @AuraEnabled public Decimal provisionalAdmFee{get;set;}     
        @AuraEnabled public string totalInWords{get;set;}   
        @AuraEnabled public string modeOfPaymentType{get;set;}       
        @AuraEnabled public string chequeDDNumber{get;set;}     
        @AuraEnabled public Date chequeDDDate{get;set;}                
        @AuraEnabled public Decimal universityFee {get;set;}     
        @AuraEnabled public Decimal tuitionFee {get;set;} 
        @AuraEnabled public string yearWord {get;set;}             
    }
}