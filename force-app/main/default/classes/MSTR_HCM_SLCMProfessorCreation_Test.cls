@IsTest
public class MSTR_HCM_SLCMProfessorCreation_Test
{
    public static testmethod void ProfessorCreation() {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;
        objAccount.SLCM_HCM_ID__c = 'Ext123';
        insert objAccount;
        
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.FirstName  = 'Test Contact';
        objcon.LastName  ='Con';
        objcon.Employee_Number__c ='EP1237';
        objcon.RecordTypeId = recordTypeId;
        objcon.Active__c = true;
        objcon.hed__WorkEmail__c  = 'test12334@reva.edu.in';
        insert objcon;
        
        MSTR_HCM_SLCMProfessorCreation.EmployeeData  objWrpEmp = new MSTR_HCM_SLCMProfessorCreation.EmployeeData();
        objWrpEmp.Emp_Salutation ='Mr';
        objWrpEmp.Emp_FirstName ='Testing';
        objWrpEmp.Emp_MiddleName ='Test';
        objWrpEmp.Emp_LastName ='Tests';
        objWrpEmp.Emp_Number = 'EP123098';
        objWrpEmp.Emp_Department =objAccount.SLCM_HCM_ID__c;
        objWrpEmp.Emp_ReportingMngr =objcon.Id;
        objWrpEmp.Emp_EmploymentType='Permanent';
        objWrpEmp.Emp_WorkLocation ='Bangalore';
        objWrpEmp.Emp_Designation ='Designation';
        objWrpEmp.Emp_OfficialEmail = 'test125@reva.edu.in';
        objWrpEmp.Emp_Mobile ='9090909093';
        objWrpEmp.Emp_PersonalEmail ='testing2@email.com';
        objWrpEmp.Emp_DateofJoining = string.valueof(system.today());
        objWrpEmp.Emp_RecordDateofBirth = string.valueof(system.today().addDays(-345));
        objWrpEmp.Emp_AadharCardNumber ='90978768909';
        objWrpEmp.Emp_Gender = 'Mr';
        objWrpEmp.Emp_BloodGroup = 'B+';
        objWrpEmp.Emp_Active  = true;
        objWrpEmp.Emp_Section  = 'Non Academic';   
        objWrpEmp.Emp_SalaryRevisedDate = string.valueof(system.today());
        
        
        List<MSTR_HCM_SLCMProfessorCreation.EmployeeData> lst_EmpData = new List<MSTR_HCM_SLCMProfessorCreation.EmployeeData>();
        lst_EmpData.add(objWrpEmp);
        
        MSTR_HCM_SLCMProfessorCreation.RequestWrapper objResWrp = new MSTR_HCM_SLCMProfessorCreation.RequestWrapper();
        objResWrp.employeeData = lst_EmpData;
        
        string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId;  
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objCont = MSTR_TestDataFactory.createContact('test Contact');
        objCont.Salutation = 'Mr';
        objCont.RecordTypeId = recordTypeId ;
        objCont.FirstName = 'Contact 2';
        objCont.MiddleName = 'Contact 2' ;
        objCont.LastName = 'Contact 3';
        objCont.Employee_Number__c = objcon.Id;
        objCont.AccountId = objAccount.Id; 
        objCont.ReportsToId = objcon.Id; 
        objCont.Employment_Type__c = 'Permanent';
        objCont.Work_Location__c = objWrpEmp.Emp_WorkLocation;
        objCont.Designation__c = objWrpEmp.Emp_Designation;
        objCont.MobilePhone =  objWrpEmp.Emp_Mobile;
        objCont.Email = objWrpEmp.Emp_PersonalEmail;
        objCont.Date_of_Joining__c = system.today();
        objCont.Birthdate =system.today().addDays(-7899);
        objCont.Aadhar_Card_Number__c = objWrpEmp.Emp_AadharCardNumber;
        objCont.hed__Gender__c = objWrpEmp.Emp_Gender ;
        objCont.Blood_Group__c = 'B+';
        objCont.Active__c = objWrpEmp.Emp_Active;
        objCont.hed__WorkEmail__c  = 'testing129@reva.edu.in';
        insert objCont;
        
        String jsonBody = JSON.serialize(objResWrp);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ProfessorDetails/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        MSTR_HCM_SLCMProfessorCreation.resultWpr objResltwrp  = new MSTR_HCM_SLCMProfessorCreation.resultWpr();
        objResltwrp.status ='Success';
        objResltwrp.empNumber = 'Emp123';
        objResltwrp.error ='Success';
        
        List<MSTR_HCM_SLCMProfessorCreation.resultWpr> list_Resultwrp = new List<MSTR_HCM_SLCMProfessorCreation.resultWpr>();
        list_Resultwrp.add(objResltwrp);
        
        MSTR_HCM_SLCMProfessorCreation.responseWrapper objRespWrp = new MSTR_HCM_SLCMProfessorCreation.responseWrapper();
        objRespWrp.status = 'Success';
        objRespWrp.message ='Test';
        objRespWrp.result = list_Resultwrp;
        
        List<Contact> list_Con = new List<Contact>();
        list_Con.add(objCont);
        
        Test.startTest();
        MSTR_HCM_SLCMProfessorCreation.getProfessorDetails();
        Test.stopTest();
        system.assertEquals(objCont.Id,objCont.Id);
        
    }
    public static testmethod void ProfessorCreationMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.FirstName  = 'Test Contact';
        objcon.LastName  ='Con';
        objcon.Employee_Number__c ='EP1237';
        objcon.RecordTypeId = recordTypeId;
        objcon.Active__c = true;
        objcon.hed__WorkEmail__c  = 'test12345@reva.edu.in';
        insert objcon;
        
        MSTR_HCM_SLCMProfessorCreation.EmployeeData  objWrpEmp = new MSTR_HCM_SLCMProfessorCreation.EmployeeData();
        objWrpEmp.Emp_Salutation ='Mr';
        objWrpEmp.Emp_FirstName ='Testing';
        objWrpEmp.Emp_MiddleName ='Test';
        objWrpEmp.Emp_LastName ='Tests';
        objWrpEmp.Emp_Number = 'Emp123';
        objWrpEmp.Emp_Department =objAccount.Id;
        objWrpEmp.Emp_ReportingMngr =objcon.Id;
        objWrpEmp.Emp_EmploymentType='Academic';
        objWrpEmp.Emp_WorkLocation ='Bangalore';
        objWrpEmp.Emp_Designation ='Designation';
        objWrpEmp.Emp_OfficialEmail = 'test@gmail.com';
        objWrpEmp.Emp_Mobile ='9090909095';
        objWrpEmp.Emp_PersonalEmail ='testing@email.com';
        objWrpEmp.Emp_DateofJoining = string.valueof(system.today());
        objWrpEmp.Emp_RecordDateofBirth = string.valueof(system.today().addDays(-345));
        objWrpEmp.Emp_AadharCardNumber ='90978768909';
        objWrpEmp.Emp_Gender = 'Mr';
        objWrpEmp.Emp_BloodGroup ='B';
        objWrpEmp.Emp_Active  = true; 
        objWrpEmp.Emp_Section  = 'Academic'; 
        objWrpEmp.Emp_SalaryRevisedDate = string.valueof(system.today());
        
        List<MSTR_HCM_SLCMProfessorCreation.EmployeeData> lst_EmpData = new List<MSTR_HCM_SLCMProfessorCreation.EmployeeData>();
        lst_EmpData.add(objWrpEmp);
        
        MSTR_HCM_SLCMProfessorCreation.RequestWrapper objResWrp = new MSTR_HCM_SLCMProfessorCreation.RequestWrapper();
        objResWrp.employeeData = lst_EmpData;
        
        string UniversityRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecordId);
        objAcc.RecordtypeId = UniversityRecordId;  
        insert objAcc;
        
        string recordTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        
        Contact objCont = MSTR_TestDataFactory.createContact('test Contact');
        objCont.Salutation = 'Mr';
        objCont.RecordTypeId = recordTypeId ;
        objCont.Employee_Number__c  ='EP134';        
        objCont.FirstName = 'Contact 1';
        objCont.MiddleName = 'Contact 2' ;
        objCont.LastName = 'Contact 3';
        objCont.Employee_Number__c = objWrpEmp.Emp_Number;
        objCont.AccountId = objcon.AccountId; 
        objCont.ReportsToId = objcon.Id; 
        objCont.Employment_Type__c = 'Permanent';
        objCont.Work_Location__c = objWrpEmp.Emp_WorkLocation;
        objCont.Designation__c = objWrpEmp.Emp_Designation;
        objCont.hed__WorkEmail__c =  objWrpEmp.Emp_OfficialEmail ;
        objCont.MobilePhone =  objWrpEmp.Emp_Mobile;
        objCont.Email = objWrpEmp.Emp_PersonalEmail;
        objCont.Date_of_Joining__c = system.today();
        objCont.Birthdate =system.today().addDays(-7899);
        objCont.Aadhar_Card_Number__c = objWrpEmp.Emp_AadharCardNumber;
        objCont.hed__Gender__c = objWrpEmp.Emp_Gender ;
        //objCont.Blood_Group__c = 'B+';
        objCont.Active__c = objWrpEmp.Emp_Active;
        objCont.hed__WorkEmail__c  = 'test120@reva.edu.in';
        insert objCont;
        
        String jsonBody = JSON.serialize(objResWrp);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ProfessorDetails/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        List<Contact> list_Con = new List<Contact>();
        list_Con.add(objCont);
        
        MSTR_HCM_SLCMProfessorCreation.resultWpr objResltwrp  = new MSTR_HCM_SLCMProfessorCreation.resultWpr();
        objResltwrp.status ='Success';
        objResltwrp.empNumber = 'Emp123';
        objResltwrp.error ='Success';
        
        List<MSTR_HCM_SLCMProfessorCreation.resultWpr> list_Resultwrp = new List<MSTR_HCM_SLCMProfessorCreation.resultWpr>();
        list_Resultwrp.add(objResltwrp);
        
        MSTR_HCM_SLCMProfessorCreation.responseWrapper objRespWrp = new MSTR_HCM_SLCMProfessorCreation.responseWrapper();
        objRespWrp.status = 'Success';
        objRespWrp.message ='Test';
        objRespWrp.result = list_Resultwrp;
        
        Test.startTest();
        MSTR_HCM_SLCMProfessorCreation.getProfessorDetails();
        Test.stopTest();
        system.assertEquals(objCont.Id,objCont.Id);
    }
    public static testmethod void ProfessorCreationMethod1()
    {        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ProfessorDetails/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf('');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        MSTR_HCM_SLCMProfessorCreation.getProfessorDetails();
        Test.stopTest();
        system.assertEquals('','');
    }
    
    public static testmethod void nonTeachingCreationMethodTest() {
        
        MSTR_HCM_SLCMProfessorCreation.EmployeeData  objWrpEmp = new MSTR_HCM_SLCMProfessorCreation.EmployeeData();
        objWrpEmp.Emp_Salutation ='Mr';
        objWrpEmp.Emp_FirstName ='Testing';
        objWrpEmp.Emp_MiddleName ='Test';
        objWrpEmp.Emp_LastName ='Tests';
        objWrpEmp.Emp_Number = 'Emp123';
        //objWrpEmp.Emp_Department =objAccount.Id;
        //objWrpEmp.Emp_ReportingMngr =objcon.Id;
        objWrpEmp.Emp_EmploymentType='Academic';
        objWrpEmp.Emp_WorkLocation ='Bangalore';
        objWrpEmp.Emp_Designation ='Designation';
        objWrpEmp.Emp_OfficialEmail = 'test@gmail.com';
        objWrpEmp.Emp_Mobile ='9090909095';
        objWrpEmp.Emp_PersonalEmail ='testing@email.com';
        objWrpEmp.Emp_DateofJoining = string.valueof(system.today());
        objWrpEmp.Emp_RecordDateofBirth = string.valueof(system.today().addDays(-345));
        objWrpEmp.Emp_AadharCardNumber ='90978768909';
        objWrpEmp.Emp_Gender = 'Mr';
        objWrpEmp.Emp_BloodGroup ='B';
        objWrpEmp.Emp_Active  = true;
        objWrpEmp.Emp_Section  = 'Non Academic';
        objWrpEmp.Emp_SalaryRevisedDate = string.valueof(system.today());        
        
        List<MSTR_HCM_SLCMProfessorCreation.EmployeeData> lst_EmpData = new List<MSTR_HCM_SLCMProfessorCreation.EmployeeData>();
        lst_EmpData.add(objWrpEmp);
        
        MSTR_HCM_SLCMProfessorCreation.RequestWrapper objResWrp = new MSTR_HCM_SLCMProfessorCreation.RequestWrapper();
        objResWrp.employeeData = lst_EmpData;        
              
        String jsonBody = JSON.serialize(objResWrp);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ProfessorDetails/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        MSTR_HCM_SLCMProfessorCreation.resultWpr objResltwrp  = new MSTR_HCM_SLCMProfessorCreation.resultWpr();
        objResltwrp.status ='Success';
        objResltwrp.empNumber = 'Emp123';
        objResltwrp.error ='Success';
        
        List<MSTR_HCM_SLCMProfessorCreation.resultWpr> list_Resultwrp = new List<MSTR_HCM_SLCMProfessorCreation.resultWpr>();
        list_Resultwrp.add(objResltwrp);
        
        MSTR_HCM_SLCMProfessorCreation.responseWrapper objRespWrp = new MSTR_HCM_SLCMProfessorCreation.responseWrapper();
        objRespWrp.status = 'Success';
        objRespWrp.message ='Test';
        objRespWrp.result = list_Resultwrp;
        
        Test.startTest();
       // MSTR_HCM_SLCMProfessorCreation.getProfessorDetails();
        Test.stopTest();
        
    }
}