public with sharing class ATT_ProxyAttendance_Ctrl 
{
    @AuraEnabled
    public static list<hed__Program_Enrollment__c> DisplayProgramEnrollment(string SrnNumber)
    {   
        list<hed__Program_Enrollment__c> lst_ProgEnrollment = new list<hed__Program_Enrollment__c>();        
        if(!string.isblank(SrnNumber))
        {
            for(hed__Program_Enrollment__c objProgEnrollment : [select Id,Name,SRN_Number__c,hed__Account__c,hed__Account__r.Name,hed__Program_Plan__c,
                                                                hed__Program_Plan__r.Name,Semester__c,Semester__r.Name,Batch__c,Batch__r.Name,Section__c,
                                                                Section__r.Name,hed__Contact__c from hed__Program_Enrollment__c where SRN_Number__c =:SrnNumber])
            {
                lst_ProgEnrollment.add(objProgEnrollment);
            }
        }
        return lst_ProgEnrollment;
    } 
    @AuraEnabled
    public static ErrorWrapper ExistingProxyRecords(date SelFromDate,date selTodate,list<hed__Program_Enrollment__c> lst_progEnroll)
    {
        ErrorWrapper WrapErr = new ErrorWrapper();
        if(SelFromDate != null && selTodate != null)
        {
            for(Proxy_Attendance__c objProxy :[select id,name,Date_From__c,Date_To__c,Contact__c from Proxy_Attendance__c where DAY_ONLY(Date_From__c)=:SelFromDate and
                                               DAY_ONLY(Date_To__c) =: selTodate and Contact__c=: lst_progEnroll[0].hed__Contact__c])
            {
                WrapErr.Errmsg='The Proxy Attendance '+ objProxy.Name +' Already Exists';
                break;
            }           
        }       
        return WrapErr;
    }
    @AuraEnabled
    public static string SaveProxyRecords(string SelFromDate,string selTodate,list<hed__Program_Enrollment__c> lst_progEnroll,string Reason)
    {
        list<Proxy_Attendance__c> lst_Proxy = new list<Proxy_Attendance__c>();
        list<string> lst_fromdate =new list<string>();
        lst_fromdate.addAll(SelFromDate.split(','));
         list<string> lst_todate =new list<string>();
        lst_todate.addAll(selTodate.split(','));
         string Errmsg;
        if(SelFromDate != null && selTodate != null)
        {
            Proxy_Attendance__c objProxy = new Proxy_Attendance__c();
           
            objProxy.Date_From__c = datetime.newInstance(integer.valueof(lst_fromdate[0].split('-')[2]), integer.valueof(lst_fromdate[0].split('-')[0]), integer.valueof(lst_fromdate[0].split('-')[1]),
                             integer.valueof(lst_fromdate[1].split(':')[0]), integer.valueof(lst_fromdate[1].split(':')[1]), integer.valueof(lst_fromdate[1].split(':')[2]));
            
            objProxy.Date_To__c =   datetime.newInstance(integer.valueof(lst_todate[0].split('-')[2]), integer.valueof(lst_todate[0].split('-')[0]), integer.valueof(lst_todate[0].split('-')[1]),
                             integer.valueof(lst_todate[1].split(':')[0]), integer.valueof(lst_todate[1].split(':')[1]), integer.valueof(lst_todate[1].split(':')[2]));
            objProxy.Contact__c = lst_progEnroll[0].hed__Contact__c;
            if(Reason != null) objProxy.Reason__c = Reason;
            lst_Proxy.add(objProxy);
        }
        if(lst_Proxy.size()>0)
        {
            try
            {
                insert lst_Proxy;
                Errmsg='Success';
            }
            catch(exception ex)
            {
                Errmsg=ex.getMessage();
            }
        }
        return Errmsg;
    }
    public class ErrorWrapper
    {
        @AuraEnabled Public string Errmsg{get;set;}
    }
}