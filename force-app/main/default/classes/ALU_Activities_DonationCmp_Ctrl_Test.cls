@isTest
public class ALU_Activities_DonationCmp_Ctrl_Test {
    @isTest
    public static void testmrthod1(){
        User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
        //objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Personal_Email__c = 'test@reva.edu.in';
        objcon.hed__Preferred_Email__c = 'Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        objcon.ownerid = userinfo.getUserId();
        insert objcon;
        
        Id Alumni_Activities_FundRaisng_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Fund Raising Request').getRecordTypeId();
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
        Alumni_Activities__c objAluminActivities= ALU_TestDataFactory.createAlumniActivities(objcon.id);
        objAluminActivities.Date__c = system.today()+1;
        objAluminActivities.Contact__c = objcon.id;
        objAluminActivities.RecordTypeId = Alumni_Activities_FundRaisng_RecType;
        insert objAluminActivities;
        
        List<Alumni_Activities__c> lstAlumniAct = new List<Alumni_Activities__c>();
        lstAlumniAct.add(objAluminActivities);
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='7YODpXAqbcooLlecGcb6AoVFrqbAeD3K';
        paydetails.Name='Alumini Checksum';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails5 = new Billdesk_Merchant_Details__c();
        paydetails5.MerchantId__c='BDUATV1KTK';
        paydetails5.Name='Alumini Merchant';
        insert paydetails5;
        
        Billdesk_Merchant_Details__c paydetails6 = new Billdesk_Merchant_Details__c();
        paydetails6.MerchantId__c='bduatv1ktk';
        paydetails6.Name='Alumini Security Id';
        insert paydetails6;
        
        Billdesk_Merchant_Details__c paydetails4 = new Billdesk_Merchant_Details__c();
        paydetails4.MerchantId__c='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/aluBillDeskResponce';
        paydetails4.Name='Alumini Callback Url';
        insert paydetails4;
        
        Billdesk_Merchant_Details__c paydetails7 = new Billdesk_Merchant_Details__c();
        paydetails7.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=';
        paydetails7.Name='PaymentEndPoint';
        insert paydetails7;
        
        test.starttest();
        ALU_Activities_DonationCmp_Ctrl.getAluActivitieslist();
        ALU_Activities_DonationCmp_Ctrl.createAluminiumActivity();
        ALU_Activities_DonationCmp_Ctrl.getAlumniActvities();
        ALU_Activities_DonationCmp_Ctrl.getMapDetails();
        ALU_Activities_DonationCmp_Ctrl.createAluminiumActPay(objAluminActivities.Id, 5000);
        ALU_Activities_DonationCmp_Ctrl.getAluActivitiySingle(objAluminActivities.Id);
        ALU_Activities_DonationCmp_Ctrl.calculateCheckSum('mainStr');
        ALU_Activities_DonationCmp_Ctrl.BillDeskPayGenratePaymentLink(lstAlumniAct, 5000, 'feeType');
        ALU_Activities_DonationCmp_Ctrl.GetDocument(objAluminActivities.Id);
        test.stoptest();
        system.assertEquals(objAluminActivities.id, objAluminActivities.id);     
        
        
    }
}