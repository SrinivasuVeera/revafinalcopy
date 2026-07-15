global class TT_SendSMSWhenClassCancelled_Batch  implements Database.Batchable<sObject>, Database.AllowsCallouts 
{
    string str_level;
    string DateTime_From;
    string DateTime_To;
    string StartTime;
    string endTime;
    string str_CancellationId;
    string str_reason;
    public TT_SendSMSWhenClassCancelled_Batch(string level,string cancelId, string FromDate, string  ToDate, String reason)
    {         
        str_level = level;
        DateTime_From = FromDate;
        DateTime_To = ToDate;     
        str_CancellationId = cancelId;
        str_reason = reason;
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {       
        system.debug('===str_level=>>>'+str_level);
        system.debug('==str_CancellationId==>>>'+str_CancellationId);
        string query;
        string status = 'Pursuing';
        string recordTypename = 'Student';
        if(str_level == 'university') {
            query = 'select id,Name, Email,MobilePhone from contact where  Student_Status__c =: status and recordtype.developername =: recordTypename and MobilePhone != null and University_ID__c =: str_CancellationId';
        }
        if(str_level == 'faculty') {
            query = 'select id,Name, Email,MobilePhone from contact where  Student_Status__c =: status and recordtype.developername =: recordTypename and MobilePhone != null and Faculty_ID__c =: str_CancellationId';
        }
        else if(str_level == 'school')
        {
            query = 'select id,Name, Email,MobilePhone from contact where  Student_Status__c =: status and recordtype.developername =: recordTypename and MobilePhone != null and school__c =: str_CancellationId';
        }
        else if(str_level == 'programBatch')
        {
            query = 'select id,Name, Email,MobilePhone from contact where  Student_Status__c =: status and recordtype.developername =: recordTypename and MobilePhone != null and Program_Batch__c =: str_CancellationId';
        }
        else if(str_level == 'semester')
        {
            query = 'select id,Name, Email,MobilePhone from contact where  Student_Status__c =: status and recordtype.developername =: recordTypename and MobilePhone != null and Active_Semester__c =: str_CancellationId';
        }
        else if(str_level == 'section')
        {
            query = 'select id,Name, Email,MobilePhone from contact where  Student_Status__c =: status and recordtype.developername =: recordTypename and MobilePhone != null and Active_Section__c =: str_CancellationId';
        }
         system.debug('===query'+query);
        return database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext Bc, List<contact> lst_contact) //hed__Course_Enrollment__c
    {
         
        List<SMS_API_Utility.shortMessageWrp> lstShortMsg = new List<SMS_API_Utility.shortMessageWrp>();
        for(contact objContact : lst_contact)
        {
            DateTime dt = System.today();
            String dateOutput = dt.format('dd-MM-yyyy');
            SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
            objShortMsg.message = 'Dear Student, Please be informed that your classes will be cancelled from '+ 
                DateTime_From   +' to '+ DateTime_To + ' due to '+ str_reason + '. Regards, REVA University';
            objShortMsg.recipient = '+91'+objContact.MobilePhone; //'+918971961912'; //
            lstShortMsg.add(objShortMsg);
        }
        
        system.debug('===>>>>'+lst_contact);
       /* set<Id> set_ContactIds = new set<Id>();
        for(contact objContact : lst_contact)
        {
            set_ContactIds.add(objContact.Id);
        }
        map<string,contact> map_ParentObject = new map<string,contact>();
        for(contact objContact : [select Id,ReportsTo.Active_Section__c,mobilePhone,Name,ReportsToId from contact 
                                  where mobilePhone !=: null and ReportsToId IN: set_ContactIds])
        {
            DateTime dt = System.today();
            String dateOutput = dt.format('dd-MM-yyyy');
            SMS_API_Utility.shortMessageWrp objShortMsg = new SMS_API_Utility.shortMessageWrp();
            objShortMsg.message = 'Dear '+ objContact.Name +' pleased to inform you that the classes will be cancelled on '+ 
                dateOutput   +' from '+ DateTime_From + ' to '+ DateTime_To + '. REVA University';
            objShortMsg.recipient = '+918971961912'; //'+91'+objContact.MobilePhone; //
            lstShortMsg.add(objShortMsg);
        }        
        */
        System.debug('lstShortMsg=='+lstShortMsg.size());
        if(lstShortMsg.size() >0)
        {
            //Map Http Request
            HttpRequest hReq = SMS_API_Utility.SendSMSOneToMany('Class Cancelled', lstShortMsg);             
            //Send Request
            //Http http = new Http();
           // HttpResponse hRsp = http.send(hReq);
            //System.debug('Response Code=='+ hRsp.getStatusCode());
           // System.debug('Response Body=='+ hRsp.getBody());
        }
    }
    global void finish(DataBase.BatchableContext bc)
    {
        
    }
}