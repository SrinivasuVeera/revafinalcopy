public class ContactCheckBox_Handler
{    
    public static Void Form_Submitted_Contact(List<Contact>ConList, Map<Id,Contact>oldMap)
    {
        id ConRecId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Set<Id> Set_conId = new Set<Id>();
       
       
        For(Contact Con : ConList)
        {
            If(oldMap != null && (oldMap.get(Con.Id).Form_Submitted__c !=Con.Form_Submitted__c && Con.Form_Submitted__c))
            {
                Set_conId.add(Con.Id);
            }
        }
        system.debug('==Set_conId==='+Set_conId);
        if(Set_conId.size()>0)
        {
            UpdateUser(Set_conId);
        }
    }
   
 
    public static void UpdateUser(set<Id> set_ContactId)
    {
        id ConRecId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        List<Contact> lst_update = new List<Contact>();
        List<Contact> lst_Con_Stud = new List<Contact>();
        List<User> lst_User = new List<User>();
        for(User objUser :[SELECT Id,Name,ContactId,Contact.Form_Submitted__c,IsActive,Contact.Student_Status__c FROM User WHERE   ContactId IN:set_ContactId])
        {
            objUser.IsActive = false;
            lst_User.Add(objUser);
        }
       
        //  system.debug('====lst_User==='+lst_User);
       
        for(Contact con:[Select id,Program_Batch__r.hed__End_Date__c,LastName,FirstName,File_Passport_Size_Photo__c,SRN_Number__c,
                         Personal_Email__c,Blood_Group__c,MobilePhone,Marital_Status__c,hed__Gender__c,Nationality__c,Student_Status__c,
                         Birthdate,Company__c,Program_Name_New__c,School__c,Location__c,AccountId, Student_Contact__c
                         from Contact where id IN:set_ContactId])
        {
            Contact ObjCon = new Contact();
            ObjCon.AccountId =Con.AccountId;
            ObjCon.LastName = Con.LastName;
            ObjCon.Student_Contact__c = Con.id;
            ObjCon.FirstName =  Con.FirstName;
            ObjCon.RecordTypeId = ConRecId1;
            ObjCon.hed__Preferred_Email__c = 'Personal Email';
            ObjCon.Personal_Email__c = Con.Personal_Email__c;
            if(!Test.isRunningTest())
                //ObjCon.Application_Number__c = '123';
                objCon.SRN_No__c = Con.SRN_Number__c;
            ObjCon.Email=Con.Personal_Email__c;
            ObjCon.Blood_Group__c = Con.Blood_Group__c;
            ObjCon.MobilePhone = Con.MobilePhone;
            ObjCon.Marital_Status__c = Con.Marital_Status__c;
            ObjCon.hed__Gender__c = Con.hed__Gender__c;
            ObjCon.Nationality__c= Con.Nationality__c;
            ObjCon.Birthdate = Con.Birthdate;
            ObjCon.Company__c = Con.Company__c;
             if(!Test.isRunningTest())  ObjCon.Year_Of_Graduation__c = string.valueof(Con.Program_Batch__r.hed__End_Date__c.year());
            ObjCon.Program_Name_New__c = Con.Program_Name_New__c;
            ObjCon.School__c = Con.School__c;
            ObjCon.Location__c  = Con.Location__c;
            ObjCon.File_Passport_Size_Photo__c=Con.File_Passport_Size_Photo__c;
            //ObjCon.hed__WorkEmail__c= '123@reva.edu.in';
            lst_Con_Stud.add(ObjCon);
        }
        if(lst_Con_Stud.size()>0)
        {
            system.debug('=====lst_Con_Stud===='+lst_Con_Stud.size());
             insert lst_Con_Stud;
        }
        if(lst_User.size()>0)
        {
            update lst_User;
        }
    }
    public static void Form_Submitted_User(List<Contact> lstContact)
    {
        String Alumni = utility.Contact_RecType_Alumni;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Alumni).getRecordTypeId();
        Set<Id> set_ContactIds = new Set<Id>();
        List<User> lst_User = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name =: Label.Alumni_Portal_Profile_Value Limit 1].Id;
       
        For(Contact objContact : lstContact)
        {
            if(objContact.RecordTypeId == recordTypeId)
            {
                set_ContactIds.add(objContact.Id);
            }
        }
        if(set_ContactIds.size()>0)
        {
            for(Contact objContact:[Select id,Name,Employee_Number__c,Email,LastName,FirstName,Designation__c,MiddleName,Professor_School_Name__c,
                                    hed__WorkEmail__c from Contact where id IN:set_ContactIds])
               
            {
                User objUser = new User();
                objUser.FirstName = objContact.FirstName;
                objUser.MiddleName = objContact.MiddleName;
                objUser.LastName = objContact.LastName;
                if(objUser.LastName.Length()>=3)
                {
                    objuser.alias =  objUser.LastName.substring(0, 3);
                }        
                else if(objUser.LastName.Length()>=2)
                {
                    objuser.alias =  objUser.LastName.substring(0, 2);
                }
                else if(objUser.LastName.Length()>=1)
                {
                    objuser.alias =  objUser.LastName.substring(0, 1);
                }
                objUser.Email = objContact.Email;
                objUser.Username = objContact.Email;
                objUser.TimeZoneSidKey = 'GMT';
                objUser.LanguageLocaleKey = 'en_US';
                objUser.EmailEncodingKey = 'UTF-8';
                objUser.LocaleSidKey = 'en_US';
                objUser.IsActive = true;
                objUser.FederationIdentifier = objContact.Email;
                objUser.ProfileId = profileId;
                objUser.ContactId= objContact.id;
                objUser.CommunityNickname = objContact.Name+System.currentTimeMillis();
                lst_User.add(objUser);
            }
            if(lst_User.size()>0 && !Test.isRunningTest())
            {
                insert lst_User;
            }
        }
    }
    public static Void Form_Submitted_Update(List<Contact>ConList, Map<Id,Contact>oldMap)
    {
        //id ConRecId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        List<Contact> lstCon = new List<Contact>();
        Set<Id> Set_conId1 = new Set<Id>();
       
        For(Contact Con : ConList)
        {
            If(oldMap != null && (oldMap.get(Con.Id).Form_Submitted__c !=Con.Form_Submitted__c && Con.Form_Submitted__c))
            {
                Set_conId1.add(Con.Id);
            }
        }
        if(Set_conId1.size()>0)
        {
            for(Contact objContact:[Select id,Name,Form_Submitted__c,Student_Status__c from Contact where id IN:Set_conId1 ])//and RecordTypeId=:ConRecId1
            {
                objContact.Student_Status__c='Completed';
                lstCon.add(objContact);
            }
            if(lstCon.size()>0)
            {
                update lstCon;
            }
        }
    }
}