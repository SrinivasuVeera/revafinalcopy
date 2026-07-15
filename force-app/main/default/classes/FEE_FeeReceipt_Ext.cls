public with sharing class FEE_FeeReceipt_Ext
{
    public Student_Payment__c stupay{get;set;}
    public list<Student_Fee_Payment__c> StuFee{get;set;}
    public Decimal Total{get;set;}
    public string ReceiptNo{get;set;}
    public string TotalInWords{get;set;}
    public FEE_FeeReceipt_Ext(ApexPages.StandardController controller)
    {
        
        try
        {
            stupay= new Student_Payment__c();
            StuFee=new list<Student_Fee_Payment__c>();
            Total=0;
            string pageId=Apexpages.currentPage().getParameters().get('Id');
            
            for(Student_Payment__c objstu:[Select Id,name,Online_Receipt_Number1__c,Offline_Receipt_Number__c,Mode_of_Payment__c 
                                           from Student_Payment__c where id=:pageid])
            {
                stupay= objstu;
            }  
            if(stupay.Online_Receipt_Number1__c !=null)
                ReceiptNo=stupay.Online_Receipt_Number1__c;
            else
                ReceiptNo=stupay.Offline_Receipt_Number__c; 
            
            for(Student_Fee_Payment__c objstufee:[Select Id,Name,Amount__c,Student_Fee__r.name from Student_Fee_Payment__c 
                                                  where Student_Payment__c=:pageId
                                                  AND Line_Item_Payment_Status__c='Success'])
            {
                StuFee.add(objstufee);
                if(objstufee.Amount__c != null)
                    Total=Total+objstufee.Amount__c;
            }
            
            NumbersToWordsConversionClass cls=new NumbersToWordsConversionClass();
            TotalInWords=cls.convert(integer.valueOf(Total));
        }catch(exception ex)
        {
        }
    }
}