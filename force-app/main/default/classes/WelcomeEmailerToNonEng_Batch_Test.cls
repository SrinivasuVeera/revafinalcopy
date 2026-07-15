@Istest
global class WelcomeEmailerToNonEng_Batch_Test 
{
    global static TestMethod void Fee_DueDate()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = new Account();
        objAcc.Name = 'School of Applied Sciences';
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 =  new Account();
        objAccount1.Name = 'B. Tech in Civil Engineering';
        objAccount1.Program_Type__c = 'UG';
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = objAcc.id;
        insert objAccount1;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B. Tech in Civil Engineering (2025-2028)',
             hed__Start_Date__c = system.today().addyears(-5),
        hed__End_Date__c = system.today().addyears(+1),
           hed__Account__c = objAccount1.id
        );
        insert programBatch;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm.Program_Batch__c = programBatch.id;
        objTerm.hed__Start_Date__c = system.today()-1;
        objTerm.hed__End_Date__c = system.today()+30;
        objTerm.Term_Number__c =1;
        insert objTerm;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = new contact();
        objCon.FirstName = 'Venu';
        objCon.LastName = 'con';
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        //objCon.Program_Type__c = 'UG';
        //objCon.School__c =objAccount1.Id ;
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.School__c = objAcc.id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Quota__c='Management Quota';
        objCon.Email='testing1234@reva.edu.in';
         objCon.Personal_Email__c='naveen123978@gmail.com';
        objCon.hed__Preferred_Email__c='Personal Email';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objcon.Ready_to_be_Transitioned__c = true;
        objcon.Active_Semester__c = objTerm.id;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Program_Batch__c = programBatch.id;
        objCon.School__c=objAcc.id;
        objCon.Primary_Academic_Program__c = objAccount1.id;
        Insert objCon; 
        
        
                
        hed__Program_Enrollment__c objProgenroll = new hed__Program_Enrollment__c(); //
        objProgenroll.hed__Contact__c = objCon.Id;
        Insert objProgenroll;
       
        contentversion file = new contentversion();
        file.Title = 'PIC';
        //file.id = '068J4000000gbQIIAY';
        file.PathOnClient = 'PIC.pdf';
        file.VersionData = Blob.valueOf('This is a test PDF content');
        //file.VersionData ='/services/data/v61.0/sobjects/ContentVersion/0680T000001wNNWQA2/VersionData'; 
        insert file;
        
        Test.startTest();
        WelcomeEmailerToNonEng_Batch Batch = new WelcomeEmailerToNonEng_Batch();
        database.executeBatch(Batch);
        Test.stopTest();
        
    }
}