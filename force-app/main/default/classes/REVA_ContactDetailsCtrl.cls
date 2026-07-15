public with Sharing class REVA_ContactDetailsCtrl 
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
            if(objcon.Recordtype.Name == utility.Contact_RecType_Student) ContactId =objcon.id;
            else if(objcon.Recordtype.Name == utility.Contact_RecType_Parent) ContactId =objcon.ReportsToId;
        }
        if(ContactId != null)
        {
            wrp.Con= [Select Name,Id,File_Passport_Size_Photo__c,MobilePhone,Application_Number__c,hed__WorkEmail__c,
                      Student_Image__c,Primary_Academic_Program__r.name,Program_Batch__r.Name,Account.name,SRN_Number__c,
                      School__r.Name
                      from Contact where id=: ContactId];
        }
        wrp.FeeId=[Select Id from Student_Fee__c Limit 1].Id;
        wrp.SupportId=[Select Id from Professor_Student_Course_Preference__c limit 1].Id;
        // wrp.MentoringId=[Select Id from CaseRelatedIssue Limit 1].Id;
        return wrp;
    }
    public class wrapperCls
    {
        @AuraEnabled public Contact con{get;set;}
        @AuraEnabled public string FeeId{get;set;}
        @AuraEnabled public string SupportId{get;set;}
        @AuraEnabled public string MentoringId{get;set;}
    }
}