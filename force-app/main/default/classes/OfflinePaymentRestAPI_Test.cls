@isTest
public class OfflinePaymentRestAPI_Test {
 @isTest
    public static  void SAP_Offline(){
        string houseHoldRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = new Account();
        objAcc.Name  = 'Testing';
        objAcc.Recordtypeid = houseHoldRecType;
        Insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id ProgramrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Contact objCon = new Contact();
        objCon.LastName = 'testing';
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        //objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        
         Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Due_Date__c = system.today().addDays(-1);
      
        Insert objStudentFee;
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee';
        
        insert objStuPayment;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StudentPaymentOfflineAPI'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        /* OfflinePaymentRestAPI.PaymentData wrprdata = new OfflinePaymentRestAPI.PaymentData();
wrprdata.Contact = '';*/
        
        // Assuming you have the Contact Id and other relevant data
        OfflinePaymentRestAPI.PaymentData wrprdata = new OfflinePaymentRestAPI.PaymentData();
        wrprdata.Contact = objCon.Id; 
        
        wrprdata.Offline_Receipt_Number = '2023001'; 
        wrprdata.Amount = 1000.00; 
        wrprdata.Mode_of_Payment = 'Offline'; 
        wrprdata.Payment_Date_Time = Datetime.now();
      
        wrprdata.SFDCRecordID = objStuPayment.Id; 
        wrprdata.Demand_Number = 'D2023-001'; 
        wrprdata.Payment_Status = 'Success'; 
        wrprdata.Payment_Mode_Type = 'Offline'; 
        wrprdata.Cheque_DD_Number = '123456'; 
         Date todayDate = Date.today();
        
        String formattedDate= String.valueOf(todayDate.year()) + '-' + String.valueOf(todayDate.month()).leftPad(2, '0') + '-' + String.valueOf(todayDate.day()).leftPad(2, '0');
        wrprdata.Cheque_DD_Date =  formattedDate;
        wrprdata.Cheque_DD_Realisation_Date = formattedDate;
       
        wrprdata.Cheque_DD_Realisation_Date =formattedDate;
        wrprdata.Cheque_Bank_Name = 'ABC Bank'; 
        wrprdata.SAP_Code = 'SAP123'; 
        //wrprdata.PaymentStatus = 'Success'; 
        
        List<OfflinePaymentRestAPI.PaymentData> lst_offPdata = new List<OfflinePaymentRestAPI.PaymentData>();    
        lst_offPdata.add(wrprdata);
        list<Student_Payment__c> lst_Std_Pay = new list<Student_Payment__c>();
        lst_Std_Pay.add(objStuPayment);
        Test.startTest();
        OfflinePaymentRestAPI.createOrUpdateStudentPayments(lst_offPdata);
        Test.stopTest();  
    }
    @isTest
    public static  void SAP_Offline2(){
        string houseHoldRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = new Account();
        objAcc.Name  = 'Testing';
        objAcc.Recordtypeid = houseHoldRecType;
        Insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id ProgramrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Contact objCon = new Contact();
        objCon.LastName = 'testing';
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        //objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
          Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2000000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Due_Date__c = null;
      
        Insert objStudentFee;
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        insert objStuPayment;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StudentPaymentOfflineAPI'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        /* OfflinePaymentRestAPI.PaymentData wrprdata = new OfflinePaymentRestAPI.PaymentData();
wrprdata.Contact = '';*/
        
        // Assuming you have the Contact Id and other relevant data
        OfflinePaymentRestAPI.PaymentData wrprdata = new OfflinePaymentRestAPI.PaymentData();
        wrprdata.Contact = objCon.Id; 
        
        wrprdata.Offline_Receipt_Number = '2023001'; 
        wrprdata.Amount = 1000.00; 
        wrprdata.Mode_of_Payment = 'Offline'; 
        wrprdata.Payment_Date_Time = Datetime.now();
      
        wrprdata.SFDCRecordID = objStuPayment.Id; 
        wrprdata.Demand_Number = 'D2023-001'; 
        wrprdata.Payment_Status = 'Success'; 
        wrprdata.Payment_Mode_Type = 'Offline'; 
        wrprdata.Cheque_DD_Number = '123456'; 
         Date todayDate = Date.today();
        
        String formattedDate= String.valueOf(todayDate.year()) + '-' + String.valueOf(todayDate.month()).leftPad(2, '0') + '-' + String.valueOf(todayDate.day()).leftPad(2, '0');
        wrprdata.Cheque_DD_Date = formattedDate;
        wrprdata.Cheque_DD_Realisation_Date =formattedDate;
       
        wrprdata.Cheque_DD_Realisation_Date = formattedDate;
        wrprdata.Cheque_Bank_Name = 'ABC Bank'; 
        wrprdata.SAP_Code = ''; 
        //wrprdata.PaymentStatus = 'Success'; 
        
        List<OfflinePaymentRestAPI.PaymentData> lst_offPdata = new List<OfflinePaymentRestAPI.PaymentData>();    
        lst_offPdata.add(wrprdata);
        list<Student_Payment__c> lst_Std_Pay = new list<Student_Payment__c>();
        lst_Std_Pay.add(objStuPayment);
        Test.startTest();
        OfflinePaymentRestAPI.createOrUpdateStudentPayments(lst_offPdata);
        Test.stopTest();  
    }
     @isTest
    public static  void SAP_Offline3(){
        string houseHoldRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = new Account();
        objAcc.Name  = 'Testing';
        objAcc.Recordtypeid = houseHoldRecType;
        Insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id ProgramrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Contact objCon = new Contact();
        objCon.LastName = 'testing';
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        //objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
          Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=2000000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Due_Date__c = null;
      
        Insert objStudentFee;
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Amount__c = 2000;
        insert objStuPayment;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StudentPaymentOfflineAPI'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        /* OfflinePaymentRestAPI.PaymentData wrprdata = new OfflinePaymentRestAPI.PaymentData();
wrprdata.Contact = '';*/
        
        // Assuming you have the Contact Id and other relevant data
        OfflinePaymentRestAPI.PaymentData wrprdata = new OfflinePaymentRestAPI.PaymentData();
        wrprdata.Contact = objCon.Id; 
        
        wrprdata.Offline_Receipt_Number = '2023001'; 
        wrprdata.Amount = 1000.00; 
        wrprdata.Mode_of_Payment = 'Offline'; 
        wrprdata.Payment_Date_Time = Datetime.now();
      
        wrprdata.SFDCRecordID = objStuPayment.Id; 
        wrprdata.Demand_Number = 'D2023-001'; 
        wrprdata.Payment_Status = 'Success'; 
        wrprdata.Payment_Mode_Type = 'Offline'; 
        wrprdata.Cheque_DD_Number = '123456'; 
         Date todayDate = Date.today();
        
        String formattedDate= String.valueOf(todayDate.year()) + '-' + String.valueOf(todayDate.month()).leftPad(2, '0') + '-' + String.valueOf(todayDate.day()).leftPad(2, '0');
        wrprdata.Cheque_DD_Date =  formattedDate;
        wrprdata.Cheque_DD_Realisation_Date = formattedDate;
       
        wrprdata.Cheque_DD_Realisation_Date =formattedDate;
        wrprdata.Cheque_Bank_Name = 'ABC Bank'; 
        wrprdata.SAP_Code = 'SAP123'; 
        //wrprdata.PaymentStatus = 'Success'; 
        
        List<OfflinePaymentRestAPI.PaymentData> lst_offPdata = new List<OfflinePaymentRestAPI.PaymentData>();    
        lst_offPdata.add(wrprdata);
        list<Student_Payment__c> lst_Std_Pay = new list<Student_Payment__c>();
        lst_Std_Pay.add(objStuPayment);
        Test.startTest();
        OfflinePaymentRestAPI.createOrUpdateStudentPayments(lst_offPdata);
        Test.stopTest();  
    }
     @isTest
    public static  void SAP_Offline4(){
        string houseHoldRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = new Account();
        objAcc.Name  = 'Testing';
        objAcc.Recordtypeid = houseHoldRecType;
        Insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id ProgramrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Contact objCon = new Contact();
        objCon.LastName = 'testing';
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        //objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
          Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
        Insert objFeeCriteria;
        Student_Fee__c objStudentFee = ASM_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 2000000;
        objStudentFee.Amount_Pending__c=2000000;
        objStudentFee.Amount_Paid__c=1000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;  
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Due_Date__c = null;
      
        Insert objStudentFee;
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Amount__c = 2000;
        insert objStuPayment;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/StudentPaymentOfflineAPI'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        
        /* OfflinePaymentRestAPI.PaymentData wrprdata = new OfflinePaymentRestAPI.PaymentData();
wrprdata.Contact = '';*/
        
        // Assuming you have the Contact Id and other relevant data
        OfflinePaymentRestAPI.PaymentData wrprdata = new OfflinePaymentRestAPI.PaymentData();
        wrprdata.Contact = objCon.Id; 
        
        wrprdata.Offline_Receipt_Number = '2023001'; 
        wrprdata.Amount = 1000.00; 
        wrprdata.Mode_of_Payment = 'Offline'; 
        wrprdata.Payment_Date_Time = Datetime.now();
      
        wrprdata.SFDCRecordID = objStuPayment.Id; 
        wrprdata.Demand_Number = 'D2023-001'; 
        wrprdata.Payment_Status = 'Success'; 
        wrprdata.Payment_Mode_Type = 'Offline'; 
        wrprdata.Cheque_DD_Number = '123456'; 
         Date todayDate = Date.today();
        
        String formattedDate= String.valueOf(todayDate.year()) + '-' + String.valueOf(todayDate.month()).leftPad(2, '0') + '-' + String.valueOf(todayDate.day()).leftPad(2, '0');
        wrprdata.Cheque_DD_Date = formattedDate;
        wrprdata.Cheque_DD_Realisation_Date = formattedDate;
       
        wrprdata.Cheque_DD_Realisation_Date =formattedDate;
        wrprdata.Cheque_Bank_Name = 'ABC Bank'; 
        wrprdata.SAP_Code = 'SAP123'; 
        //wrprdata.PaymentStatus = 'Success'; 
        
        List<OfflinePaymentRestAPI.PaymentData> lst_offPdata = new List<OfflinePaymentRestAPI.PaymentData>();    
        lst_offPdata.add(wrprdata);
        list<Student_Payment__c> lst_Std_Pay = new list<Student_Payment__c>();
        lst_Std_Pay.add(objStuPayment);
        Test.startTest();
        OfflinePaymentRestAPI.createOrUpdateStudentPayments(lst_offPdata);
        Test.stopTest();  
    }
}