public class REVA_AlumniContactDetailsCtrl 
{
    @AuraEnabled
    public static wrapperCls fetchContact()
    {
        wrapperCls wrp=new wrapperCls();
        string ContactId;
        User u = [SELECT id,ContactId FROM User WHERE id=:userInfo.getUserId()];
        if(u.ContactId != null)
        {
            Contact objcon = new Contact();
            objcon =[select Id,Name,Recordtype.Name,ReportsToId from Contact where id=: u.ContactId];
            if(objcon.Recordtype.Name == utility.Contact_RecType_Alumni) ContactId =objcon.id;
        }
        if(ContactId != null)
        {
            wrp.Con= [Select Name,Id,MobilePhone,Email,SRN_No__c,Blood_Group__c,Marital_Status__c,hed__Gender__c,Program__c,Year_Of_Graduation__c,Company__c
                      
                      from Contact where id=: ContactId];
        }
        return wrp;
    }
    public class wrapperCls
    {
        @AuraEnabled public Contact con{get;set;}

    }
}