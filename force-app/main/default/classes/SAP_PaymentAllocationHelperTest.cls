@isTest
public class SAP_PaymentAllocationHelperTest {
    // Helper method to create sample Student_Payment__c data
    public static List<Student_Payment__c> createTestPayments(Integer numPayments,Id contactid) {
        List<Student_Payment__c> payments = new List<Student_Payment__c>();
        for (Integer i = 0; i < numPayments; i++) {
            payments.add(new Student_Payment__c(
                Amount__c = 100.0,
                Contact__c = contactid, // Use a valid contact ID for testing
                Mode_of_Payment__c = 'Online',
                Payment_Status__c = 'Success',
                Payment_Date_Time__c = System.now(),
                Payment_Gateway__c = 'Billdesk',
                Payment_Mode_Type__c = 'Online',
                Description__c = 'Test Payment',
                SAP_Code__c = 'SAP' + i,
                Auto_Allocate__c = true,
                Demand_Number__c = null
            ));
        }
        insert payments;
        return payments;
    }
    
    // Helper method to create sample Student_Fee__c data
    public static List<Student_Fee__c> createTestFees(Integer numFees,Id contactid) {
        List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for (Integer i = 0; i < numFees; i++) {
            fees.add(new Student_Fee__c(
                Amount__c = 500.0,
                Amount_Paid__c = 0.0,
                Amount_Pending__c = 500.0,
                Fee_Type__c = 'Tuition Fee',
                Contact__c = contactid, // Use the same contact for simplicity
                Due_Date__c = System.today().addDays(i),
                Demand_Number__c = null,
                Cancelled__c = false,
                Display_No__c = 1
            ));
        }
        insert fees;
        return fees;
    }
    
    
    @isTest
    public static void Method1() {
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
        
        
        createTestFees(3,objCon.Id);
        
        SAP_PaymentAllocationHelper.handlePaymentAllocation(createTestPayments(3,objCon.id), new Map<Id, Student_Payment__c>());
    }
    @isTest
    public static void Method2() {
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
        
        
        List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for (Integer i = 0; i < 3; i++) {
            fees.add(new Student_Fee__c(
                Amount__c = 0,
                Amount_Paid__c =0,
                Amount_Pending__c = 500.0,
                Fee_Type__c = 'Tuition Fee',
                Contact__c = objCon.Id, // Use the same contact for simplicity
                Due_Date__c = System.today().addDays(i),
                Demand_Number__c = null,
                Cancelled__c = false,
                  Display_No__c = 1
            ));
        }
        insert fees;
        List<Student_Payment__c> payments = new List<Student_Payment__c>();
        for (Integer i = 0; i < 2; i++) {
            payments.add(new Student_Payment__c(
                Amount__c = 100.0,
                Contact__c = objCon.Id, // Use a valid contact ID for testing
                Mode_of_Payment__c = 'Online',
                Payment_Status__c = 'Success',
                Payment_Date_Time__c = System.now(),
                Payment_Gateway__c = 'Billdesk',
                Payment_Mode_Type__c = 'Online',
                Description__c = 'Test Payment',
                SAP_Code__c = 'SAP' + i,
                Auto_Allocate__c = true,
                Demand_Number__c = null
                
            ));
        }
        insert payments;
        
        SAP_PaymentAllocationHelper.handlePaymentAllocation(payments, new Map<Id, Student_Payment__c>());
    }
    
    
    @isTest
    public static void Method3() {
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
        
        
        List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for (Integer i = 0; i < 3; i++) {
            fees.add(new Student_Fee__c(
                Amount__c = 0,
                Amount_Paid__c =0,
                Amount_Pending__c = 500.0,
                Fee_Type__c = 'Tuition Fee',
                Contact__c = objCon.Id, // Use the same contact for simplicity
                Due_Date__c = System.today().addDays(i),
                Demand_Number__c = '1',
                Cancelled__c = false,
                  Display_No__c = 1
            ));
        }
        insert fees;
        List<Student_Payment__c> payments = new List<Student_Payment__c>();
        for (Integer i = 0; i < 2; i++) {
            payments.add(new Student_Payment__c(
                Amount__c = 100.0,
                Contact__c = objCon.Id, // Use a valid contact ID for testing
                Mode_of_Payment__c = 'Online',
                Payment_Status__c = 'Success',
                Payment_Date_Time__c = System.now(),
                Payment_Gateway__c = 'Billdesk',
                Payment_Mode_Type__c = 'Online',
                Description__c = 'Test Payment',
                SAP_Code__c = 'SAP' + i,
                Auto_Allocate__c = true,
                
                Demand_Number__c = '1'
            ));
        }
        insert payments;
        
        SAP_PaymentAllocationHelper.handlePaymentAllocation(payments, new Map<Id, Student_Payment__c>());
        //SAP_PaymentAllocationHelper.handleRefundedPayments(payments, new Map<Id, Student_Payment__c>());
    }
        @isTest
    public static void Method3one() {
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
          List<Student_Payment__c> payments = new List<Student_Payment__c>();
        for (Integer i = 0; i < 2; i++) {
            payments.add(new Student_Payment__c(
                Amount__c = 1000.0,
                Contact__c = objCon.Id, // Use a valid contact ID for testing
                Mode_of_Payment__c = 'Online',
                Payment_Status__c = 'Success',
                Payment_Date_Time__c = System.now(),
                Payment_Gateway__c = 'Billdesk',
                Payment_Mode_Type__c = 'Online',
                Description__c = 'Test Payment',
                SAP_Code__c = 'SAP' + i,
                Auto_Allocate__c = true,
                
                Demand_Number__c = '1'
            ));
        }
        insert payments;
        
        List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for (Integer i = 0; i < 3; i++) {
            fees.add(new Student_Fee__c(
                Amount__c = 1000,
                Amount_Paid__c =9,
                Amount_Pending__c = 1000,
                
                Fee_Type__c = 'Tuition Fee',
                Contact__c = objCon.Id, // Use the same contact for simplicity
                Due_Date__c = System.today().addDays(i),
                Demand_Number__c = '1',
                Cancelled__c = false,
                  Display_No__c = 1
            ));
        }
        insert fees;
        update fees;
      
        
        SAP_PaymentAllocationHelper.handlePaymentAllocation(payments, new Map<Id, Student_Payment__c>());
        //SAP_PaymentAllocationHelper.handleRefundedPayments(payments, new Map<Id, Student_Payment__c>());
    }
     @isTest
    public static void Method4() {
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
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        //objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        
      
        List<Student_Payment__c> payments = new List<Student_Payment__c>();
        for (Integer i = 0; i < 2; i++) {
            payments.add(new Student_Payment__c(
                Amount__c = 100.0,
                Contact__c = objCon.Id, // Use a valid contact ID for testing
                Mode_of_Payment__c = 'Online',
                Payment_Status__c = 'Success',
                Payment_Date_Time__c = System.now(),
                Payment_Gateway__c = 'Billdesk',
                Payment_Mode_Type__c = 'Online',
                Description__c = 'Test Payment',
                SAP_Code__c = 'SAP' + i,
                Auto_Allocate__c = true

            ));
        }
        insert payments;
        
          List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for (Integer i = 1; i < 2; i++) {
            fees.add(new Student_Fee__c(
                Amount__c = 10000,
                Amount_Paid__c =1000,
                Amount_Pending__c = 9000,
                Fee_Type__c = 'University Fee',
                Contact__c = objCon.Id, // Use the same contact for simplicity
                 Due_Date__c = System.today().addDays(30),
                Cancelled__c = false,
                  Display_No__c = i
              
            ));
        }
        insert fees;
                update fees;
        SAP_PaymentAllocationHelper.handlePaymentAllocation(payments, new Map<Id, Student_Payment__c>());
        //SAP_PaymentAllocationHelper.handleRefundedPayments(payments, new Map<Id, Student_Payment__c>());
    }
    
        @isTest
    public static void Method5() {
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
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        //objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        
      
        List<Student_Payment__c> payments = new List<Student_Payment__c>();
        for (Integer i = 0; i < 2; i++) {
            payments.add(new Student_Payment__c(
                Amount__c = 100.0,
                Contact__c = objCon.Id, // Use a valid contact ID for testing
                Mode_of_Payment__c = 'Online',
                Payment_Status__c = 'Success',
                Payment_Date_Time__c = System.now(),
                Payment_Gateway__c = 'Billdesk',
                Payment_Mode_Type__c = 'Online',
                Description__c = 'Test Payment',
                SAP_Code__c = 'SAP' + i,
                Auto_Allocate__c = true

            ));
        }
        insert payments;
        
          List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for (Integer i = 1; i < 2; i++) {
            fees.add(new Student_Fee__c(
                Amount__c = 100,
                Amount_Paid__c =9,
                Amount_Pending__c = 1000,
                Fee_Type__c = 'University Fee',
                Contact__c = objCon.Id, 
                 Due_Date__c = System.today().addDays(30),
                Cancelled__c = false,
                  Display_No__c = i
              
            ));
        }
        insert fees;
        update fees;
        
        SAP_PaymentAllocationHelper.handlePaymentAllocation(payments, new Map<Id, Student_Payment__c>());
        //SAP_PaymentAllocationHelper.handleRefundedPayments(payments, new Map<Id, Student_Payment__c>());
    }
    @isTest
    public static void Method6() {
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
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        //objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        
      
        List<Student_Payment__c> payments = new List<Student_Payment__c>();
        for (Integer i = 0; i < 2; i++) {
            payments.add(new Student_Payment__c(
                Amount__c = 100.0,
                Contact__c = objCon.Id, // Use a valid contact ID for testing
                Mode_of_Payment__c = 'Online',
                Payment_Status__c = 'Success',
                Payment_Date_Time__c = System.now(),
                Payment_Gateway__c = 'Billdesk',
                Payment_Mode_Type__c = 'Online',
                Description__c = 'Test Payment',
                SAP_Code__c = 'SAP' + i,
                Auto_Allocate__c = true

            ));
        }
        insert payments;
        
          List<Student_Fee__c> fees = new List<Student_Fee__c>();
        for (Integer i = 1; i < 2; i++) {
            fees.add(new Student_Fee__c(
                Amount__c = 1000,
                Amount_Paid__c =9,
                Amount_Pending__c = 1000,
                Fee_Type__c = 'University Fee',
                Contact__c = objCon.Id, 
                 Due_Date__c = System.today().addDays(30),
                Cancelled__c = false,
                  Display_No__c = i
              
            ));
        }
        insert fees;
        update fees;
        
        SAP_PaymentAllocationHelper.handlePaymentAllocation(payments, new Map<Id, Student_Payment__c>());
        //SAP_PaymentAllocationHelper.handleRefundedPayments(payments, new Map<Id, Student_Payment__c>());
    }
}