@Istest
public class Trigger_Al_Reg_CheckBox_Handler_Test 
{
    
    public static testmethod void Alumni_Registration()
    {
        Account objAcc = new Account();
        objAcc.Name = 'str_accName1';
        insert objAcc;

        Alumni_Registration__c objAl = new Alumni_Registration__c();
        objAl.Course_Pursued__c =  'mexch';
        objAl.DOB__c = system.today(); 
        objAl.Email__c='asdf123@gmail.com';
        objAl.Mobile__c = '9876543212'; 
        objAl.Marital_Status__c =  'Single';
        objAl.Specialization__c = 'Specializa';
        objAl.Year_of_Graduation__c ='2021';
        objAl.Gender__c = 'Male';
        objAl.Name = 'Test';
        objAl.Name__c ='Testing';
        ObjAl.Program__c = 'Diploma in HR Analytics';
        objAl.Confirm_Validation__c = false;
        Insert objAl;
        
        List<Alumni_Registration__c> lstAl = new List<Alumni_Registration__c>();
        lstAl.add(objAl);
        
        Map<Id, Alumni_Registration__c> oldMap = new Map<Id, Alumni_Registration__c>();
        oldMap.put(objAl.Id,objAl);
         
        objAl.Confirm_Validation__c = true;
        update objAl;
        
        test.startTest();
        Trigger_Al_Reg_CheckBox_Handler.Alumni_Registration(lstAl, oldMap);
        test.stopTest();
    }
}