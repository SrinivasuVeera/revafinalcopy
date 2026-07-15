@isTest
public class ALU_BilldeskResponse_API_Test{
    public static testMethod Void BilldeskMethod(){    
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
        
         Alumni_Payments__c objAluPayments = ALU_TestDataFactory.createPayments(objcon.id);
        objAluPayments.Amount__c = 2000;
        objAluPayments.Reference_Id__c = '1572332335';
        objAluPayments.Payment_Status__c ='Payment Link Created';
        insert objAluPayments;
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        paydetails.Name='Alumini Home Url';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Alumini Checksum';
        insert paydetails2; 
        
        test.starttest();
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        ALU_BilldeskResponse_API res = new ALU_BilldeskResponse_API();
        res.BilldeskRespon();
        test.stoptest();
        system.assertequals('1572332335',objAluPayments.Reference_Id__c);
    }
    
    public static testMethod Void BilldeskMethod1(){    
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
        
         Alumni_Payments__c objAluPayments = ALU_TestDataFactory.createPayments(objcon.id);
        objAluPayments.Amount__c = 2000;
        objAluPayments.Reference_Id__c = '1572332335';
        objAluPayments.Payment_Status__c ='Payment Link Created';
        insert objAluPayments;
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        paydetails.Name='Alumini Home Url';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Alumini Checksum';
        insert paydetails2; 
        
        test.starttest();
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        ALU_BilldeskResponse_API res = new ALU_BilldeskResponse_API();
        res.BilldeskRespon();
        test.stoptest();
        system.assertequals('1572332335',objAluPayments.Reference_Id__c);
    }
    public static testMethod Void BilldeskMethod2(){    
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
        
         Alumni_Payments__c objAluPayments = ALU_TestDataFactory.createPayments(objcon.id);
        objAluPayments.Amount__c = 2000;
        objAluPayments.Reference_Id__c = '1572332335';
        objAluPayments.Payment_Status__c ='Payment Link Created';
        insert objAluPayments;
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        paydetails.Name='Alumini Home Url';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Alumini Checksum';
        insert paydetails2; 
        
        test.starttest();
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0100|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        ALU_BilldeskResponse_API res = new ALU_BilldeskResponse_API();
        res.BilldeskRespon();
        test.stoptest();
        system.assertequals('1572332335',objAluPayments.Reference_Id__c);
    }
}