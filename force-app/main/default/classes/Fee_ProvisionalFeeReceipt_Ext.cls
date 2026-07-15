global class Fee_ProvisionalFeeReceipt_Ext {
    
    global Student_Payment__c studentPayment {get;set;}
    global list<Student_Fee_Payment__c> studentFeePayments {get;set;}
    global Decimal total {get;set;}
    global string receiptNo {get;set;}
    global string totalInWords {get;set;}
    global string feeYear {get;set;}
    global string chequeNumber {get;set;}
    
    global void viewTheReceipt(){
        try
        {
            studentPayment = new Student_Payment__c();
            studentFeePayments = new list<Student_Fee_Payment__c>();
            total = 0;
            string studentPaymentId = Apexpages.currentPage().getParameters().get('id');
            string transactionId = ApexPages.CurrentPage().getparameters().get('transactionId');
            string paymentGateway = ApexPages.CurrentPage().getparameters().get('paymentGateway');
            string paymentModeType = ApexPages.CurrentPage().getparameters().get('paymentModeType');
          
            for(Student_Payment__c objstu : [Select Id, Name, Online_Receipt_Number1__c, Offline_Receipt_Number__c, Mode_of_Payment__c , Contact__r.Name, Contact__r.Primary_Academic_Program__r.name, Payment_Date_Time__c,
                                             Contact__r.Application_Number__c, Payment_Gateway__c, Payment_Mode_Type__c, Transaction_ID__c, Payment_Status__c, Receipt_Generated_by__c, Receipt_Generated_on__c
                                             from Student_Payment__c where id = : studentPaymentId]){
                                                
                         studentPayment = objstu;
                         studentPayment.Transaction_ID__c = transactionId;
                         studentPayment.Payment_Gateway__c = paymentGateway;
                         studentPayment.Payment_Mode_Type__c = paymentModeType; 
                         studentPayment.Payment_Status__c = 'Success';
                                                
                       }
            if(studentPayment.Online_Receipt_Number1__c != null){
                receiptNo = studentPayment.Online_Receipt_Number1__c;
            }
            else{
                receiptNo = studentPayment.Offline_Receipt_Number__c; 
            }
            for(Student_Fee_Payment__c objstudentFeePayments:[Select Id, Name, Amount__c, Student_Fee__r.name, Student_Fee__r.Fee_Year__c,Cheque_DD_Number__c from Student_Fee_Payment__c 
                                                              where Student_Payment__c = : studentPaymentId]){
                                                                  
                              studentFeePayments.add(objstudentFeePayments);
                                                                  
                              if(objstudentFeePayments.Amount__c != null)
                                  total = total + objstudentFeePayments.Amount__c;
                     }
            
            Student_Fee_Payment__c sf = [Select Id, Name, Amount__c, Student_Fee__r.name,Student_Fee__r.Fee_Year__c,Cheque_DD_Number__c from Student_Fee_Payment__c 
                                         where Student_Payment__c = : studentPaymentId
                                         limit 1];
           
            feeYear = sf.Student_Fee__r.Fee_Year__c;
            chequeNumber = sf.Cheque_DD_Number__c ;
            
            NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
            totalInWords = cls.convert(integer.valueOf(total));
        }catch(exception ex){
            
        }
    }
}