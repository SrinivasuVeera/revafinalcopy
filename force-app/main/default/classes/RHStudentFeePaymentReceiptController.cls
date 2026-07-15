public class RHStudentFeePaymentReceiptController {
    public List<PaymentInfo> receiptInfoList { get; private set; }
    
    public RHStudentFeePaymentReceiptController() {
        receiptInfoList = new List<PaymentInfo>();
        
        // Retrieve parameters from the current page
        String paymentId = ApexPages.currentPage().getParameters().get('paymentId');
        system.debug('paymentId:'+paymentId);
        if (paymentId != null) {
            // Query the payment record
            Student_Fee_Payment__c payment = [SELECT Id, Amount__c,Student_Fee__r.Contact__r.Name, 
                                              Student_Fee__r.Contact__r.Active_Semester__r.name,
                                              Student_Fee__r.Contact__r.Program_Batch__r.name,
                                              Mode_of_Payment__c,Student_Fee__r.Payment_Type__c,
                                              Transaction_Date_Time__c, Line_Item_Payment_Status__c 
                                              FROM Student_Fee_Payment__c WHERE Id = :paymentId LIMIT 1];
            
            if (payment != null) {
                // Convert payment amount to words
                NumberTOWordConvertion numberToWordConverter = new NumberTOWordConvertion();
                String amountInWords = numberToWordConverter.getNumberTOWordConvertion(payment.Amount__c);
                receiptInfoList.add(new PaymentInfo('Payment Amount (In Words)', amountInWords)); 
                // Add payment information to the list
                receiptInfoList.add(new PaymentInfo('Payment Amount', String.valueOf(payment.Amount__c)));
                /********************************************************************************************/
                Datetime adjustedDateTime = payment.Transaction_Date_Time__c.addHours(5).addMinutes(30);
                
                // Format the adjusted datetime
                String transactionDateTime = adjustedDateTime.format('dd/MM/yyyy, h:mm a');
                receiptInfoList.add(new PaymentInfo('Transaction Date', transactionDateTime));
                // receiptInfoList.add(new PaymentInfo('Transaction Date', String.valueOf(payment.Transaction_Date_Time__c)));
                /****************************************************************************************************/
                receiptInfoList.add(new PaymentInfo('Payment Status', String.valueOf(payment.Line_Item_Payment_Status__c)));
                receiptInfoList.add(new PaymentInfo('Student Name', String.valueOf(payment.Student_Fee__r.Contact__r.Name)));
                receiptInfoList.add(new PaymentInfo('Course', String.valueOf(payment.Student_Fee__r.Contact__r.Program_Batch__r.name)));
                receiptInfoList.add(new PaymentInfo('Year of Study', String.valueOf(payment.Student_Fee__r.Contact__r.Active_Semester__r.name)));
                receiptInfoList.add(new PaymentInfo('Payment Mode', String.valueOf(payment.Mode_of_Payment__c)));
                receiptInfoList.add(new PaymentInfo('Payment Type', String.valueOf(payment.Student_Fee__r.Payment_Type__c)));
                // Add more fields as needed
                
                // You can also add related objects' fields here
            }
        }
    }
    
    // Wrapper class to hold payment information
    public class PaymentInfo {
        public String field { get; private set; }
        public String value { get; private set; }
        
        public PaymentInfo(String field, String value) {
            this.field = field;
            this.value = value;
        }
    }
}