@isTest
public class ReassignmentAndEscalation_Batch_Test {

    //Post deployment steps
    //1.Required atleast one counselor user in public group.

    @TestSetup
    static void createTestData() {
        List < GroupMember > counselors = [SELECT GroupId, UserOrGroupId, Group.Name
            FROM GroupMember
            WHERE Group.DeveloperName = 'Admission_Counselor'
            ORDER BY UserOrGroupId
        ];

        id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId(); //Fetching Applicant recordTypeId from Contact
        id accUniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId(); //Fetching University Department recordTypeId from Account
        id accAcademicProgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId(); //Fetching Academic program recordTypeId from account
        id accHouseholdAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();

        //new account  creation
        List < Account > accRecCollection = new List < Account > ();

        Account accRecPerformingArts = new Account();
        accRecPerformingArts.Name = 'School of Performing Arts and Indic Studies';
        accRecPerformingArts.RecordTypeId = accUniversityRecTypeId;
        insert accRecPerformingArts;

        Account accRecPhd = new Account();
        accRecPhd.Name = 'Ph.D in Management Studies';
        accRecPhd.RecordTypeId = accAcademicProgRecTypeId;
        accRecPhd.Program_Type__c = 'Ph.D';
        accRecCollection.add(accRecPhd);
        insert accRecCollection;

        Account accRec = new Account();
        accRec.Name = 'School of Applied Sciences';
        accRec.RecordTypeId = accAcademicProgRecTypeId;
        accRec.Program_Type__c = 'UG';
        insert accRec;

        Account houseHoldAccount = new Account();
        houseHoldAccount.Name = 'houseHoldAccount';
        houseHoldAccount.Program_Type__c = 'UG';
        houseHoldAccount.RecordTypeId = accHouseholdAccountRecTypeId;
        insert houseHoldAccount;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'Ph.D in Commerce-(2023-2031)';
        programBatch.hed__Account__c = accRecPhd.Id;
        insert programBatch;



        Fee_Master__c feeProgramType = new Fee_Master__c();

        feeProgramType.Program_Name_Display__c = 'Ph.D in Management Studies';
        feeProgramType.Fee_Type__c = 'Application Fee';
        feeProgramType.Program_Batch__c = programBatch.Id;
        insert feeProgramType;



        //Get required hours for Reassignment and Escalation.
        Integer reqHoursForReassignment = (Integer)[Select Time__c From Batch_Config__mdt Where DeveloperName = 'Lead_Reassignment_Time_in_hours'
            Limit 1].Time__c;
        Integer reqHoursForEscalation = (Integer)[Select Time__c From Batch_Config__mdt Where DeveloperName = 'Lead_Escalation_Notification_Time_in_hrs'
            Limit 1].Time__c;

        //New Lead creation.
        Lead leadWithCounselor = new Lead();
        leadWithCounselor.OwnerId = counselors[0].UserOrGroupId;
        leadWithCounselor.FirstName = 'Test';
        leadWithCounselor.LastName = 'Lead Counselor 1';
        leadWithCounselor.Company = 'TestCompany';
        leadWithCounselor.Program_Name_Display__c = 'MBA';
        leadWithCounselor.Category__c = 'Karnataka';
        leadWithCounselor.Assigned_Users__c = counselors[0].UserOrGroupId;
        leadWithCounselor.Assigned__c = true;
        leadWithCounselor.Status = 'Unverified';
        leadWithCounselor.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + reqHoursForReassignment));
        leadWithCounselor.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation + reqHoursForEscalation));
        insert leadWithCounselor;
        leadWithCounselor.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + reqHoursForReassignment));
        update leadWithCounselor;

        //reset nextindex value 
        Lead leadWithFinalCounselor = new Lead();
        leadWithFinalCounselor.OwnerId = counselors[counselors.size() - 1].UserOrGroupId;
        leadWithFinalCounselor.FirstName = 'Test';
        leadWithFinalCounselor.LastName = 'Lead1';
        leadWithFinalCounselor.Company = 'TestCompany';
        leadWithFinalCounselor.Status = 'Unqualified';
        leadWithFinalCounselor.Program_Name_Display__c = 'MBA';
        leadWithFinalCounselor.Category__c = 'Karnataka';
        leadWithFinalCounselor.School__c = 'REVA Business School';
        leadWithFinalCounselor.Assigned_Users__c = counselors[counselors.size() - 1].UserOrGroupId;
        leadWithFinalCounselor.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        leadWithFinalCounselor.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation + 10));
        insert leadWithFinalCounselor;
        leadWithCounselor.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        update leadWithFinalCounselor;

        //assigned users count greater then counselors list count
        Lead leadWithAllCounselors = new Lead();
        leadWithAllCounselors.FirstName = 'Test';
        leadWithAllCounselors.LastName = 'Lead1';
        leadWithAllCounselors.Company = 'TestCompany';
        leadWithAllCounselors.Status = 'Unqualified';
        leadWithAllCounselors.Program_Name_Display__c = 'MBA';
        leadWithAllCounselors.Category__c = 'Karnataka';
        leadWithAllCounselors.School__c = 'REVA Business School';
        //to check length of the assigned users
        leadWithAllCounselors.Assigned_Users__c = counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId;
        leadWithAllCounselors.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        leadWithAllCounselors.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation + 10));
        insert leadWithAllCounselors;
        leadWithAllCounselors.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        update leadWithAllCounselors;

        //default owner not in public group 
        Lead leadWithoutDefOwner = new Lead();
        leadWithoutDefOwner.FirstName = 'Test';
        leadWithoutDefOwner.LastName = 'Lead1';
        leadWithoutDefOwner.Company = 'TestCompany';
        leadWithoutDefOwner.Status = 'Unqualified';
        leadWithoutDefOwner.Program_Name_Display__c = 'MBA';
        leadWithoutDefOwner.Category__c = 'Karnataka';
        leadWithoutDefOwner.School__c = 'REVA Business School';
        leadWithoutDefOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        leadWithoutDefOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        leadWithoutDefOwner.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation + 10));
        insert leadWithoutDefOwner;
        leadWithoutDefOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        update leadWithoutDefOwner;

        //last escalation date is null
        Lead leadWithoutEscDate = new Lead();
        leadWithoutEscDate.FirstName = 'Test';
        leadWithoutEscDate.LastName = 'Lead1';
        leadWithoutEscDate.Company = 'TestCompany';
        leadWithoutEscDate.Status = 'Unqualified';
        leadWithoutEscDate.Program_Name_Display__c = 'MBA';
        leadWithoutEscDate.Category__c = 'Karnataka';
        leadWithoutEscDate.School__c = 'REVA Business School';
        leadWithoutEscDate.Assigned_Users__c = counselors[0].UserOrGroupId;
        leadWithoutEscDate.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        insert leadWithoutEscDate;
        leadWithoutEscDate.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        update leadWithoutEscDate;

        //Create Contact
        Contact conWithOwner = new Contact();
        conWithOwner.FirstName = 'Test First Name';
        conWithOwner.LastName = 'Test Last Name';
        conWithOwner.MobilePhone = '+91-9535768042';
        conWithOwner.RecordTypeId = conRecTypeId;
        conWithOwner.Assigned__c = False;
        conWithOwner.Accountid = houseHoldAccount.id;
        conWithOwner.Select_Category__c = 'Karnataka';
        conWithOwner.Application_Fee_Paid__c = False;
        conWithOwner.Assigned_Users__c = counselors[0].UserOrGroupId;
        conWithOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        conWithOwner.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation + 10));
        insert conWithOwner;
        conWithOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        update conWithOwner;

        //default owner is not in public group.
        Contact conWithoutDefOwner = new Contact();
        conWithoutDefOwner.FirstName = 'Test First Name';
        conWithoutDefOwner.LastName = 'Test Last Name';
        conWithoutDefOwner.MobilePhone = '+91-9535768042';
        conWithoutDefOwner.RecordTypeId = conRecTypeId;
        conWithoutDefOwner.Assigned__c = False;
        conWithoutDefOwner.Accountid = houseHoldAccount.id;
        conWithoutDefOwner.Select_Category__c = 'Karnataka';
        conWithoutDefOwner.Application_Fee_Paid__c = False;
        //to check length of the assigned users
        conWithoutDefOwner.Assigned_Users__c = userinfo.getUserId() + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId;
        conWithoutDefOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        conWithoutDefOwner.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation + 10));
        insert conWithoutDefOwner;
        conWithoutDefOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        update conWithoutDefOwner;

        //assigned users count greater then counselors list count
        Contact conWithAllAssOwners = new Contact();
        conWithAllAssOwners.FirstName = 'Test First Name';
        conWithAllAssOwners.LastName = 'Test Last Name';
        conWithAllAssOwners.MobilePhone = '+91-9535768042';
        conWithAllAssOwners.RecordTypeId = conRecTypeId;
        conWithAllAssOwners.Assigned__c = False;
        conWithAllAssOwners.Accountid = houseHoldAccount.id;
        conWithAllAssOwners.Select_Category__c = 'Karnataka';
        conWithAllAssOwners.Application_Fee_Paid__c = False;
        //to check length of the assigned users
        conWithAllAssOwners.Assigned_Users__c = counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId + ',' + counselors[0].UserOrGroupId;
        conWithAllAssOwners.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        conWithAllAssOwners.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation + 10));
        insert conWithAllAssOwners;
        conWithAllAssOwners.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        update conWithAllAssOwners;

        //reset nextindex value 
        Contact conWithLastOwner = new Contact();
        conWithLastOwner.FirstName = 'Test First Name';
        conWithLastOwner.OwnerId = counselors[counselors.size() - 1].UserOrGroupId;
        conWithLastOwner.LastName = 'Test Last Name';
        conWithLastOwner.MobilePhone = '+91-9535768042';
        conWithLastOwner.RecordTypeId = conRecTypeId;
        conWithLastOwner.Assigned__c = False;
        conWithLastOwner.Accountid = houseHoldAccount.id;
        conWithLastOwner.Select_Category__c = 'Karnataka';
        conWithLastOwner.Application_Fee_Paid__c = False;
        conWithLastOwner.Assigned_Users__c = counselors[counselors.size() - 1].UserOrGroupId;
        conWithLastOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        conWithLastOwner.Last_Escalation_Date__c = datetime.now().addhours(-(reqHoursForEscalation + 10));
        insert conWithLastOwner;
        conWithLastOwner.Last_Assigned_Date__c = datetime.now().addhours(-(reqHoursForReassignment + 10));
        update conWithLastOwner;


        //New Chatter Feed creation.
        FeedItem toNotifyUser = new FeedItem();
        toNotifyUser.ParentId = counselors[0].UserOrGroupId;
        toNotifyUser.Body = 'Hello,This post is for testing purpose.';
        insert toNotifyUser;


    }

    @isTest static void test() {

        List < GroupMember > counselors = [SELECT GroupId, UserOrGroupId, Group.Name FROM GroupMember WHERE Group.DeveloperName = 'Admission_Counselor'
            ORDER BY UserOrGroupId
        ];
        String firstCounselor = counselors[0].UserOrGroupId;
        String secondCounselor = counselors[1].UserOrGroupId;
        Lead beforeOwnerChangeLead = [SELECT Id, OwnerId FROM Lead WHERE LastName = 'Lead Counselor 1'
            limit 1
        ];

        Test.startTest();
        ReassignmentAndEscalation_Batch batchTest = new ReassignmentAndEscalation_Batch();
        Id batchId = Database.executeBatch(batchTest);
        system.schedule('Reassignment and Escalation', '0 0 0 * * ? *', new ReassignmentAndEscalation_Batch());
        Test.stopTest();

        Lead afterOwnerChangedLead = [SELECT OwnerId FROM Lead WHERE Id =: beforeOwnerChangeLead.Id limit 1];

        system.assertEquals(afterOwnerChangedLead.OwnerId, secondCounselor);

    }

}