public class Trigger_Al_Reg_CheckBox_Handler 
{
    public static Void Alumni_Registration(List<Alumni_Registration__c>Al_List, Map<Id,Alumni_Registration__c>oldMap)
    {
        Set<Id> Set_Al_Id = new Set<Id>();
        List<Account> lst_Acc = new List<Account>();
        List<Contact> lst_Con = new List<Contact>();
        id ConRecId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        id AccRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        For(Alumni_Registration__c obj_Alu : Al_List)
        {
            If(oldMap != null && (oldMap.get(obj_Alu.Id).Confirm_Validation__c !=obj_Alu.Confirm_Validation__c && obj_Alu.Confirm_Validation__c))
            {
                Set_Al_Id.add(obj_Alu.Id);
            } 
        }
        system.debug('=====Set_Al_Id======'+Set_Al_Id);
        
        if(Set_Al_Id.size()>0)
        {
            for(Alumni_Registration__c obj_Alu:[Select id,Name__c,Gender__c,Name,
                                                Specialization__c,Marital_Status__c,Mobile__c,OwnerId,
                                                Email__c,DOB__c,Course_Pursued__c,Blood_Group__c,Country_Code__c,Program__c,Year_of_Graduation__c
                                                from Alumni_Registration__c where id IN:Set_Al_Id])
            {
                
                Account Acc = new Account();
                Contact Obj_Con = new Contact();
                
                Acc.Name= obj_Alu.Name__c + ' Alumni Household Account';
                Acc.RecordTypeId =AccRecId1;
                Acc.OwnerId = obj_Alu.OwnerId;
                lst_Acc.add(Acc);
                
                Obj_Con.AccountId =Acc.id;
                Obj_Con.RecordTypeId = ConRecId1; 
                Obj_Con.SRN_No__c = obj_Alu.Name;
                Obj_Con.Blood_Group__c = obj_Alu.Blood_Group__c;
                Obj_Con.Course_Pursued__c =  obj_Alu.Course_Pursued__c;
                Obj_Con.Birthdate = obj_Alu.DOB__c; 
                Obj_Con.Email=obj_Alu.Email__c;
                Obj_Con.MobilePhone = obj_Alu.Mobile__c;    
                Obj_Con.Marital_Status__c = obj_Alu.Marital_Status__c;
                Obj_Con.Specialization__c = obj_Alu.Specialization__c;
                Obj_Con.School_Department__c = obj_Alu.Specialization__c;
                Obj_Con.Year_Of_Graduation__c = String.valueof(obj_Alu.Year_of_Graduation__c);
                Obj_Con.hed__Gender__c=obj_Alu.Gender__c;
                Obj_Con.LastName = obj_Alu.Name__c;
                Obj_Con.Program__c = String.valueof(obj_Alu.Program__c);
                Obj_Con.Personal_Email__c = obj_Alu.Email__c;
                Obj_Con.hed__Preferred_Email__c = 'Personal Email';
                Obj_Con.Upload_Image__c = true;
                Obj_Con.Country_Code_Alumni__c = obj_Alu.Country_Code__c;
                
                 system.debug('====Obj_Con==='+obj_Alu.Email__c);
                 system.debug('====Obj_Con==='+obj_Alu.Name__c);
                lst_Con.add(Obj_Con);
            }
            if(lst_Acc.size()>0)
                insert lst_Acc;
            if(lst_Con.size()>0)
            {
                lst_Con[0].AccountId=lst_Acc[0].id;
                insert lst_Con;
            }
        }
    }   
}
/*public static void Alumni_Registration_User(List<Alumni_Registration__c> lst_AlReg)
{
//Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
Set<Id> set_ContactIds = new Set<Id>();
List<User> lst_Con_User = new List<User>();
Id profileId = [SELECT Id FROM Profile WHERE Name =: Label.Alumni_Portal_Profile_Value Limit 1].Id;

For(Alumni_Registration__c obj_Al : lst_AlReg)
{
if(obj_Al.Confirm_Validation__c)
{
set_ContactIds.add(obj_Al.Id);
}
}
if(set_ContactIds.size()>0)
{
for(Alumni_Registration__c obj_Alu:[Select id,Name__c,Gender__c,Year_of_Graduation__c,
Specialization__c,Marital_Status__c,Mobile__c,
Email__c,DOB__c,Course_Pursued__c,Blood_Group__c
from Alumni_Registration__c where id IN:set_ContactIds])

{ 
if(!Test.isRunningTest())
{
User objUser = new User();
objUser.LastName = obj_Alu.Name__c;

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
objUser.Email = obj_Alu.Email__c;
objUser.Username = obj_Alu.Email__c;
objUser.TimeZoneSidKey = 'GMT';
objUser.LanguageLocaleKey = 'en_US';
objUser.EmailEncodingKey = 'UTF-8';
objUser.LocaleSidKey = 'en_US';
objUser.IsActive = true;
objUser.FederationIdentifier = obj_Alu.Email__c;
objUser.ProfileId = profileId;
objUser.ContactId= obj_Alu.id;
objUser.CommunityNickname = obj_Alu.Name+System.currentTimeMillis();
lst_Con_User.add(objUser);
}
}
if(lst_Con_User.size()>0)
{
insert lst_Con_User;
}
}
}*/