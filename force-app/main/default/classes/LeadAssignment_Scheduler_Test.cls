@isTest
public class LeadAssignment_Scheduler_Test {
    public static testMethod void ScheduleLeadAssignment_Test() 
    {    
        //Fetching Contact recordTypeId 
        id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        id accUniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        id accAcademicProgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        List<GroupMember> counselors = [SELECT GroupId, UserOrGroupId, Group.Name 
                        FROM GroupMember 
                        WHERE Group.DeveloperName = 'Admission_Counselor' 
                        ORDER BY UserOrGroupId ];

        Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
        accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;

        Account accHousehold = new Account();
        accHousehold.Name = '23150200014 - mahesh contact';
        accHousehold.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        insert accHousehold;
        
        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        insert accRecPhd;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'Ph.D in Commerce-(2023-2031)';
        programBatch.hed__Account__c = accRecPhd.Id;
        insert programBatch;

        Fee_Master__c feeProgramType = new Fee_Master__c();
        feeProgramType.Program_Name_Display__c = 'Ph.D in Management Studies';
        feeProgramType.Fee_Type__c = 'Application Fee';
        feeProgramType.Program_Batch__c = programBatch.Id;
        insert feeProgramType;
        
        //Adding all record into the collection
        List<sObject> recCollection = new List<sObject>();
        //New Lead creation
        Lead leadRec = new Lead();
        leadRec.FirstName = 'Test First Name';
        leadRec.LastName = 'Test Last Name';
        leadRec.Company = 'Stratos';
        leadRec.MobilePhone = '+91-9535768042';
        leadRec.Assigned__c = False;
        recCollection.add(leadRec);

        Lead leadRecWithOwner = new Lead();
        leadRecWithOwner.FirstName = 'TestOwner First Name';
        leadRecWithOwner.LastName = 'TestOwner Last Name';
        leadRecWithOwner.Company = 'Stratos';
        leadRecWithOwner.MobilePhone = '+91-9535768042';
        leadRecWithOwner.Assigned__c = False;
        leadRecWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(leadRecWithOwner);

        Lead leadRecForeigner = new Lead();
        leadRecForeigner.FirstName = 'Foreigner First Name';
        leadRecForeigner.LastName = 'Foreigner Last Name';
        leadRecForeigner.Company = 'Foreigner';
        leadRecForeigner.MobilePhone = '+91-9535768042';
        leadRecForeigner.Assigned__c = False;
        leadRecForeigner.Category__c = 'Foreign Nationals';
        recCollection.add(leadRecForeigner);

        Lead leadRecForeignerWithOwner = new Lead();
        leadRecForeignerWithOwner.FirstName = 'Foreigner First Name';
        leadRecForeignerWithOwner.LastName = 'Foreigner With Owner Last Name';
        leadRecForeignerWithOwner.Company = 'Foreigner With Owner';
        leadRecForeignerWithOwner.MobilePhone = '+91-9535768042';
        leadRecForeignerWithOwner.Assigned__c = False;
        leadRecForeignerWithOwner.Category__c = 'Foreign Nationals';
        leadRecForeignerWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(leadRecForeignerWithOwner); 

        Lead leadRecPerformingArts = new Lead();
        leadRecPerformingArts.FirstName = 'PerformingArts First Name';
        leadRecPerformingArts.LastName = 'PerformingArts Last Name';
        leadRecPerformingArts.Company = 'PerformingArts';
        leadRecPerformingArts.MobilePhone = '+91-9535768042';
        leadRecPerformingArts.Assigned__c = False;
        leadRecPerformingArts.School__c = 'School of Performing Arts and Indic Studies';
        recCollection.add(leadRecPerformingArts);

        Lead leadRecPerformingArtsWithOwner = new Lead();
        leadRecPerformingArtsWithOwner.FirstName = 'PerformingArts First Name';
        leadRecPerformingArtsWithOwner.LastName = 'PerformingArts Last Name';
        leadRecPerformingArtsWithOwner.Company = 'PerformingArts';
        leadRecPerformingArtsWithOwner.MobilePhone = '+91-9535768042';
        leadRecPerformingArtsWithOwner.Assigned__c = False;
        leadRecPerformingArtsWithOwner.School__c = 'School of Performing Arts and Indic Studies';
        leadRecPerformingArtsWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(leadRecPerformingArtsWithOwner);

        Lead leadPhd = new Lead();
        leadPhd.FirstName = 'Ph.D First Name';
        leadPhd.LastName = 'Ph.D Last Name';
        leadPhd.Company = 'Phd';
        leadPhd.MobilePhone = '+91-9535768042';
        leadPhd.Assigned__c = False;
        leadPhd.Program_Name_Display__c = 'Ph.D in Management Studies';
        recCollection.add(leadPhd);

        Lead leadPhdWithOwner = new Lead();
        leadPhdWithOwner.FirstName = 'Ph.D First Name';
        leadPhdWithOwner.LastName = 'Ph.D Last Name';
        leadPhdWithOwner.Company = 'Phd';
        leadPhdWithOwner.MobilePhone = '+91-9535768042';
        leadPhdWithOwner.Assigned__c = False;
        leadPhdWithOwner.Program_Name_Display__c = 'Ph.D in Management Studies';
        leadPhdWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(leadPhdWithOwner);
        
        //New Contact creation
        
        Contact conWithOwner = new Contact();   
        conWithOwner.FirstName = 'Test First Name';
        conWithOwner.LastName = 'Test Last Name';
        conWithOwner.MobilePhone = '+91-9535768042';
        conWithOwner.RecordTypeId  = conRecTypeId;
        conWithOwner.Assigned__c = False;
        conWithOwner.Select_Category__c = 'Karnataka';
        conWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(conWithOwner);
        
        Contact conForeigner = new Contact();   
        conForeigner.FirstName = 'Foreigner First Name';
        conForeigner.LastName = 'Foreigner Last Name';
        conForeigner.MobilePhone = '+91-9535768042';
        conForeigner.RecordTypeId  = conRecTypeId;
        conForeigner.Assigned__c = False;
        conForeigner.Select_Category__c = 'Foreign Nationals';
        recCollection.add(conForeigner);

        Contact conForeignerWithOwner = new Contact();   
        conForeignerWithOwner.FirstName = 'Foreigner With Owner First Name';
        conForeignerWithOwner.LastName = 'Foreigner With Owner Last Name';
        conForeignerWithOwner.MobilePhone = '+91-9535768042';
        conForeignerWithOwner.RecordTypeId  = conRecTypeId;
        conForeignerWithOwner.Assigned__c = False;
        conForeignerWithOwner.Select_Category__c = 'Foreign Nationals';
        conForeignerWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(conForeignerWithOwner);

        Contact conPerformingArts = new Contact();   
        conPerformingArts.FirstName = 'Performing Arts First Name';
        conPerformingArts.LastName = 'Performing Arts Last Name';
        conPerformingArts.MobilePhone = '+91-9535768042';
        conPerformingArts.RecordTypeId  = conRecTypeId;
        conPerformingArts.Assigned__c = False;
        conPerformingArts.School__c = accRecPerformingArts.Id;
        recCollection.add(conPerformingArts);

        Contact conPerformingArtsWithOwner = new Contact();   
        conPerformingArtsWithOwner.FirstName = 'Performing Arts First Name';
        conPerformingArtsWithOwner.LastName = 'Performing Arts Last Name';
        conPerformingArtsWithOwner.MobilePhone = '+91-9535768042';
        conPerformingArtsWithOwner.RecordTypeId  = conRecTypeId;
        conPerformingArtsWithOwner.Assigned__c = False;
        conPerformingArtsWithOwner.School__c = accRecPerformingArts.Id;
        conPerformingArtsWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(conPerformingArtsWithOwner);

        Contact conPhd = new Contact();   
        conPhd.FirstName = 'Ph.d First Name';
        conPhd.LastName = 'Ph.d Last Name';
        conPhd.MobilePhone = '+91-9535768042';
        conPhd.RecordTypeId  = conRecTypeId;
        conPhd.Assigned__c = False;
        conPhd.Primary_Academic_Program__c = accRecPhd.Id;
        recCollection.add(conPhd);

        Contact conPhdwithOwner = new Contact();   
        conPhdwithOwner.FirstName = 'Ph.d First Name';
        conPhdwithOwner.LastName = 'Ph.d Last Name';
        conPhdwithOwner.MobilePhone = '+91-9535768042';
        conPhdwithOwner.RecordTypeId  = conRecTypeId;
        conPhdwithOwner.Assigned__c = False;
        conPhdwithOwner.Primary_Academic_Program__c = accRecPhd.Id;
        conPhdwithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        recCollection.add(conPhdwithOwner);
        
       Contact con = new Contact();
        con.FirstName = 'Test First Name';
        con.LastName = 'Test Last NAme';
        con.MobilePhone = '+91-9535768042';
        con.Assigned__c = False;
        con.RecordTypeId  = conRecTypeId;
        recCollection.add(con);
        
        insert recCollection;
        
        //Modifying createdDate from today to yesterday
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(leadRec.Id, yesterday);
        Test.setCreatedDate(con.Id, yesterday);
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',  '0 0 0 ? * * *', new LeadAssignment_Scheduler());
         String jobId1 = System.schedule('ScheduleApexClassTest1',  '0 0 0 ? * * *', new AdmissionLeadAssignment_Scheduler());
        Test.stopTest();
        
        Integer expectedNumOfRecords = [SELECT COUNT() FROM Lead WHERE Assigned__c = false];
        System.assertEquals(8, expectedNumOfRecords);
        Integer numOfRecords = [SELECT COUNT() FROM Lead WHERE Assigned__c = true];
        System.assertEquals(0, numOfRecords);
    }
}