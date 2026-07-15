/*********************************************************************************
 * @description       : Test data for Test classes
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 24-01-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
*********************************************************************************/

@isTest
public class RPL_TestDataFactory {
    
    /*********************************************************
     * This method is test data for create Account object
     *********************************************************/
     public static Account createAccount(Boolean doInsert)
    {   
        Id academicProgramRecordId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        system.debug('academicProgramRecordId--------------'+academicProgramRecordId);
        Account acc = new Account();
        acc.RecordTypeId = academicProgramRecordId;
        system.debug('***************'+acc);
        acc.Name = 'B.Tech in Computer Science and Information Technology';
        acc.Display_Name_Program__c = 'B.Tech in Computer Science and Information Technology';
        acc.Program_Alias__c = 'BT-CSIT';
        acc.Program_Type__c = 'UG';
        
        if(doInsert)
        {
            system.debug('beforeInsert***************'+acc);
            insert acc;
            
        }
        return acc;
    }
    
    /*********************************************************
     * This method is test data for create contact object
     *********************************************************/
     public static Contact createParentContact(Boolean doInsert)
    {  //Parent
        
       //child Contact Creation
       Id childId = createContact(true).Id;
        
        //Parent Id
        Id parentId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = parentId;
        con.FirstName = 'Father-01';        
        con.LastName = 'Contact';
        con.hed__Gender__c = 'Male';
        con.Birthdate = Date.today();
        con.ReportsToId = childId;
        //con.Father_Name__c = 'test-father';
        //con.Mother_Name__c = 'test-mother';
        con.Personal_Email__c = 'test@example.com';
        con.hed__WorkEmail__c = 'test@gmail.com';
        con.SRN_Number__c = 'SRN123';
        con.MobilePhone = '1234567890';
        if(doInsert)
        {
            insert con;
        }
        return con;
    }
    
    
    /*********************************************************
     * This method is test data for create contact object
     *********************************************************/
     public static Contact createContact(Boolean doInsert)
    {
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.Primary_Academic_Program__c = createAccount(True).Id;
        con.LastName = 'Contact';
        con.hed__Gender__c = 'Male';
        con.Birthdate = Date.today();
        //con.Mother_Name__c = createParentContact(true).Id;
        //con.Mother_Name__c = 'test-mother';
        con.Personal_Email__c = 'test@example.com';
        //con.hed__WorkEmail__c = 'test@gmail.com';
        con.SRN_Number__c = 'SRN123';
        con.MobilePhone = '1234567890';
        if(doInsert)
        {
            insert con;
        }
        return con;
    }
    
    /*********************************************************
     * This method is test data for create Rpl_Student_Registration__c object
     *********************************************************/
     public static Rpl_Student_Registration__c createStudentRegistration(Boolean doInsert, Id contactId)
    {
        Rpl_Student_Registration__c std = new Rpl_Student_Registration__c();
        std.Name = 'Test Data1';
        std.Rpl_Personal_Mail_ID__c = 'test@gmail.com';
        std.Rpl_Interested_in_placement__c = 'yes';
        std.Rpl_University_Mail_ID__c = '123123123@reva.edu.in';
        std.Contact__c = contactId;
        std.Rpl_Is_Blocked__c = true;
        if(doInsert)
        {
            insert std;
        }
        return std;
    }
    
    /*********************************************************
     * This method is test data for create Reva Placement object
     *********************************************************/
     public static Rpl_Reva_Placement__c createRevaPlacement(Boolean doInsert)
    {
        Date startDate = date.today();
        Date endDate = Date.newInstance(2026, 2, 17);
        Rpl_Reva_Placement__c rpl = new Rpl_Reva_Placement__c();
        rpl.Rpl_Registration_Start_Date__c = startDate;
        rpl.Rpl_Registration_End_Date__c = endDate;
        rpl.Name = 'Test Reva Placement-01';
        rpl.Rpl_Active__c = true;
        rpl.Rpl_Academic_Program__c = 'BT-CSIT';
        if(doInsert)
        {
            insert rpl;
        }
        return rpl;
    }
        
     /*********************************************************
     * This method is test data for create Company object
     *********************************************************/
        public static Rpl_Company__c createCompany(Boolean doInsert) {
            Rpl_Company__c com = new Rpl_Company__c();
            com.Name = 'Tesla';
            if(doInsert)
                {
                    insert com;
                    }
            return com;
            }
     
     /*********************************************************
     * This method is test data for create Placement object
     *********************************************************/
         public static Rpl_Placement_Drive__c createPlacement(Boolean doInsert, Id revaPlacementId, Id companyId){
             Date startDate = Date.newInstance(2024, 1,11);
             Date endDate = Date.newInstance(2026, 2, 17);
             Date endDate1 = Date.newInstance(2026, 2, 19);
             
             Rpl_Placement_Drive__c plc = new Rpl_Placement_Drive__c();
             plc.Name = 'test Name';
             plc.Reva_Placement__c = revaPlacementId;
             plc.Rpl_Company_Name__c = companyId;
             plc.Rpl_Event_End_Date__c = endDate;
             plc.Rpl_Event_Date_Time__c = endDate1;
             if(doInsert)
                {
                    insert plc;
                    }
            return plc;
            }
    
    
    /*********************************************************
     * This method is test data for create Rpl_Interview__c object
     *********************************************************/
         public static Rpl_Interview__c createInterview(Boolean doInsert, Id placementDriveId){
             Rpl_Interview__c stdIntview = new Rpl_Interview__c();
             stdIntview.Placement_Drive__c = placementDriveId;
             stdIntview.Name = 'Test Result 1';
             stdIntview.Rpl_Round_Number__c = 1;
             
             if(doInsert)
                {
                    insert stdIntview;
                    }
            return stdIntview;
            }
}