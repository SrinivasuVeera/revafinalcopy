@isTest
public class ALU_Registr_Component_CMP_Ctrlr_Test {
    
    @isTest
    static void testMethod1(){
        Alumni_Registration__c objAl = new Alumni_Registration__c();
        objAl.Course_Pursued__c =  'mexch';
        objAl.DOB__c = system.today(); 
        objAl.Email__c='asdf123@gmail.com';
        objAl.Mobile__c = '9876543212'; 
        objAl.Marital_Status__c =  'Single';
        //objAl.Specialization__c = 'Specializa';
        //objAl.Year_of_Graduation__c =10;
        objAl.Gender__c = 'Male';
        objAl.Name = 'Test';
        objAl.Name__c ='Testing';
        objAl.Program__c = 'Master of Business Administration in Marketing';
        //objAl.Confirm_Validation__c = false;
        Insert objAl;
        
        Test.startTest();
        ALU_Registr_Component_CMP_Ctrlr.getPicklistOptions();
        ALU_Registr_Component_CMP_Ctrlr.createAlumniRegistration('Test', 'asdf123@gmail.com', '9848032919', Date.newInstance(1997, 01, 01), 'Single', 'B+', 'Male', '2017', 'SRNTEST', 
                                                                 'Master of Business Administration in Marketing', 'India (+91)');
        Test.stopTest();
        system.assertEquals(objAl.Id, objAl.Id);
    }
    @isTest
    static void testMethod2(){
        Alumni_Registration__c objAl = new Alumni_Registration__c();
        objAl.Course_Pursued__c =  'mexch';
        objAl.DOB__c = system.today(); 
        objAl.Email__c='asdf123@gmail.com';
        objAl.Mobile__c = '9876543212'; 
        objAl.Marital_Status__c =  'Single';
        //objAl.Specialization__c = 'Specializa';
        //objAl.Year_of_Graduation__c =10;
        objAl.Gender__c = 'Male';
        objAl.Name = 'Test';
        objAl.Name__c ='Testing';
        objAl.Program__c = 'Master of Business Administration in Marketing';
        //objAl.Confirm_Validation__c = false;
        Insert objAl;
        
        Test.startTest();
        ALU_Registr_Component_CMP_Ctrlr.getPicklistOptions();
        ALU_Registr_Component_CMP_Ctrlr.createAlumniRegistration('Test', 'test123@gmail.com', '9848032919', Date.newInstance(1997, 01, 01), 'Single', 'B+', 'Male', '2017', 'SRNTEST', 
                                                                 'Master of Business Administration in Marketing', 'India (+91)');
        Test.stopTest();
        system.assertEquals(objAl.Id, objAl.Id);
    }
    
}