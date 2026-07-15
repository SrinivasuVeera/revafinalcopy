@isTest
public class FEE_BilldeskPendingPaymentUpdate_SchTest {

     public Static Testmethod Void STMtoProgmEnroll()
    {
        Test.startTest();
        FEE_BilldeskPendingPaymentUpdate_Sch proSch = new FEE_BilldeskPendingPaymentUpdate_Sch();
        String Sch = '0 0 * * * ?';
        system.schedule('FEE_BilldeskPendingPaymentUpdate_Sch',Sch, proSch);
        Test.stopTest(); 
    }  
}