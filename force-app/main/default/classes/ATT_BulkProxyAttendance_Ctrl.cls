public with sharing class ATT_BulkProxyAttendance_Ctrl 
{
    @AuraEnabled 
    public static Wrapper CreateProxyAttendance(String fromDate, String toDate, String srnNos, String strReason)
    {
        Wrapper objWrapper = new Wrapper();
        List<Proxy_Attendance__c> lst_ProxyAttendnces = new List<Proxy_Attendance__c>();
        List<string> lst_fromdate = new List<string>();
        List<string> lst_todate = new List<string>();
        List<string> lst_SRNNos = new List<string>();
        lst_fromdate.addAll(fromDate.split(','));
        lst_todate.addAll(toDate.split(','));
        lst_SRNNos.addAll(srnNos.split(','));

        try
        {
            if(lst_SRNNos.size()>0)
            {
                for(Integer i = 0; i<lst_SRNNos.size(); i++)
                {
                    DateTime newFromDate = datetime.newInstance(integer.valueof(lst_fromdate[0].split('-')[2]), integer.valueof(lst_fromdate[0].split('-')[0]), integer.valueof(lst_fromdate[0].split('-')[1]),
                                                                       integer.valueof(lst_fromdate[1].split(':')[0]), integer.valueof(lst_fromdate[1].split(':')[1]), integer.valueof(lst_fromdate[1].split(':')[2]));
                    DateTime newToDate = datetime.newInstance(integer.valueof(lst_todate[0].split('-')[2]), integer.valueof(lst_todate[0].split('-')[0]), integer.valueof(lst_todate[0].split('-')[1]),
                                                                     integer.valueof(lst_todate[1].split(':')[0]), integer.valueof(lst_todate[1].split(':')[1]), integer.valueof(lst_todate[1].split(':')[2]));
                    
                    Proxy_Attendance__c objProxyAttend = new Proxy_Attendance__c();
                    objProxyAttend.Date_From__c = newFromDate;
                    objProxyAttend.Date_To__c = newToDate;
                    objProxyAttend.Contact__r = new Contact(SRN_Number__c = lst_SRNNos[i]);
                    objProxyAttend.Reason__c = strReason;
                    objProxyAttend.External_ID__c = lst_SRNNos[i]+'_'+fromDate+'_'+toDate;
                    lst_ProxyAttendnces.add(objProxyAttend);
                }
                if(lst_ProxyAttendnces.size() >0)
                    upsert lst_ProxyAttendnces Proxy_Attendance__c.External_ID__c;
                objWrapper.strMessage = 'Success';
            }
            else
                objWrapper.strMessage = 'Error';
        }
        catch(Exception ex)
        {
            objWrapper.strMessage = ex.getMessage();
        }
        return objWrapper;
    }
    
    public class Wrapper
    {
        @AuraEnabled public String strMessage {get; set;}
    }
}