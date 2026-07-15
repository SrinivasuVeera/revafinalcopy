@isTest
public class ATT_ProxyAttendance_Ctrl_Test 
{
    public static testMethod Void ProxyMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ATT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.hed__Preferred_Email__c='Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';   
        insert objcon;
        
        hed__Program_Enrollment__c objProgEnrol =  ATT_TestDataFactory.createProgEnrollment(objCon.id, objAccount.Id);
        objProgEnrol.hed__Start_Date__c = system.today();
        objProgEnrol.hed__End_Date__c = system.today()+2;
        objProgEnrol.SRN_Number__c= 'Srn123';
        insert objProgEnrol;
        
        list<hed__Program_Enrollment__c> lst_progEnroll = new list<hed__Program_Enrollment__c>();
        lst_progEnroll.add(objProgEnrol);
        
        DateTime dt = Datetime.now();
        String strTimeInAMorPM = dt.format('MM-dd-yyyy,hh:mm:ss');    
        
        ATT_ProxyAttendance_Ctrl.ErrorWrapper wrap = new ATT_ProxyAttendance_Ctrl.ErrorWrapper();
        wrap.Errmsg ='success';
        
        Proxy_Attendance__c objproxy = ATT_TestDataFactory.CreateProxyAttendance(objCon.id);
        objproxy.Date_From__c = system.today()+2;
        objproxy.Date_To__c = system.today()+2;
        insert objproxy;
        
        test.starttest();
        ATT_ProxyAttendance_Ctrl.DisplayProgramEnrollment('Srn123');
        ATT_ProxyAttendance_Ctrl.ExistingProxyRecords(system.today()+2,system.today()+2,lst_progEnroll);
        ATT_ProxyAttendance_Ctrl.SaveProxyRecords(strTimeInAMorPM,strTimeInAMorPM,lst_progEnroll,'test reason');
        test.stoptest();
        system.assertequals(objproxy.Contact__c,objCon.id);        
    }
}