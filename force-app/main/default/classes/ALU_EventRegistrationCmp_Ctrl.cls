public class ALU_EventRegistrationCmp_Ctrl 
{
    //Display the List of Events
    @AuraEnabled
    public static list<EventsWrapperClass> getEventDetails()
    {
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
        list<EventsWrapperClass> objWrp= new list<EventsWrapperClass>();
        user objuser = [SELECT id, Name, ContactId FROM user WHERE id =: UserInfo.getUserId() AND IsActive =:true];
        
        for(Alumni_Activities__c objAlumActivities : [SELECT id, Event_Name__c, name, Details__c, Venue__c, RecordTypeId,Contact__c,  Date__c,
                                                      (Select id,name from Alumni_Event_Registrations__r where Contact__c=:objuser.ContactId) FROM Alumni_Activities__c
                                                      WHERE Date__c >=: system.today() and RecordTypeId =: Alumni_Activities_Event_RecType ])
        {
            EventsWrapperClass wrp=new EventsWrapperClass();
            wrp.AlumniId=objAlumActivities.Id;
            wrp.AlumniName=objAlumActivities.Event_Name__c;
            wrp.AlumniDate=objAlumActivities.Date__c;
            wrp.AlumniVenue=objAlumActivities.Venue__c;
            wrp.AlumniDetails=objAlumActivities.Details__c;
            if(objAlumActivities.Alumni_Event_Registrations__r.size()>0 )
                wrp.disable=true;
            objWrp.add(wrp); 
        }
        return objWrp;
    }
    
    //Registration Method
    @AuraEnabled
    public static RegisterWraper sibmitedRegistration(string str_RegtrId)
    {
        
        RegisterWraper objRegstwrap = new RegisterWraper();
        try
        {
            string str_ContIds;
            Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
            List<Alumni_Event_Registrations__c> lst_AlumEventRegstr = new List<Alumni_Event_Registrations__c>();
            List<Alumni_Event_Registrations__c> list_EvntReg = new List<Alumni_Event_Registrations__c>();
            for(user objuser : [SELECT id, Name, ContactId FROM user WHERE id =: UserInfo.getUserId()])
            {
                str_ContIds = objuser.ContactId;
            }
            for(Alumni_Activities__c objAlumActivites : [SELECT id, Name, Date__c, Details__c, Venue__c 
                                                         FROM Alumni_Activities__c WHERE id =: str_RegtrId and RecordTypeId =: Alumni_Activities_Event_RecType ])
            {
                Alumni_Event_Registrations__c objAlumEventReg = new Alumni_Event_Registrations__c();
                objAlumEventReg.Alumni_Activities_Event__c = str_RegtrId;
                objAlumEventReg.Contact__c = str_ContIds;
                objAlumEventReg.Description__c = objAlumActivites.Details__c;
                objAlumEventReg.Registration_Date_Time__c = system.now();
                lst_AlumEventRegstr.add(objAlumEventReg);
            }
            //system.debug('=== Event ===='+lst_AlumEventRegstr);
            if(!lst_AlumEventRegstr.isEmpty())
            {
                Insert lst_AlumEventRegstr;
            }
            for(Alumni_Event_Registrations__c objAlumEventRegr : [SELECT Id, Name FROM Alumni_Event_Registrations__c WHERE Alumni_Activities_Event__c =: str_RegtrId] )
            {
                list_EvntReg.add(objAlumEventRegr);  
            }
            //system.debug('===ListEventReges==='+ list_EvntReg);
            if(!list_EvntReg.IsEmpty())
            {
                objRegstwrap.Str_actvs = 'True';  
            }
            
            objRegstwrap.strMsg = 'Success';
            return objRegstwrap;
        }
        catch(Exception ex)
        {
            objRegstwrap.strMsg = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return objRegstwrap;
        }  
    }
    
    //Registration cancel Method
    @AuraEnabled
    public static RegisterCancleWraper cancleRegistration(string str_RegtrId)
    {
        RegisterCancleWraper RegCnclWrap = new RegisterCancleWraper();
        try
        {
            List<Alumni_Event_Registrations__c> lst_EventRegCancle = new List<Alumni_Event_Registrations__c>();
            set<Id> set_ActvityIds = new set<Id>();
            
            for(Alumni_Activities__c objAlmniActvites : [select Id,Name from Alumni_Activities__c where Id =: str_RegtrId])
            {
                set_ActvityIds.add(objAlmniActvites.Id);  
            }
            
            for(Alumni_Event_Registrations__c objAlumEventRegrCancle : [SELECT Id, Name, Contact__c,Alumni_Activities_Event__c  FROM Alumni_Event_Registrations__c WHERE
                                                                        Alumni_Activities_Event__c In : set_ActvityIds] )
            {
                lst_EventRegCancle.add(objAlumEventRegrCancle);
            }
            if(!lst_EventRegCancle.isEmpty())
            {
                Delete lst_EventRegCancle;
            }
            RegCnclWrap.strMsg = 'Success';
            return RegCnclWrap;
        }
        catch(Exception ex)
        {
            RegCnclWrap.strMsg = 'Error: '+ex.getMessage()+'. At'+ex.getStackTraceString();
            return RegCnclWrap;
        }  
        
    }
    
    // ContentDocument Link Preview Code 
    @AuraEnabled
    public static ContentDocWraper GetDocument(string alumActivityId)
    {
        system.debug('=====>>>'+alumActivityId);
        ContentDocWraper objContDoc = new ContentDocWraper();
        List<ContentDocumentLink> lst_Cont = New List<ContentDocumentLink>();
        List<Alumni_Activities__c> lst_AlumniAct = New List<Alumni_Activities__c>();
        for(ContentDocumentLink objContLink: [SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,ContentDocument.FileExtension,
                                              ContentDocument.CreatedDate, ContentDocument.ContentSize ,ContentDocument.Owner.Name
                                              FROM ContentDocumentLink WHERE LinkedEntityId =: alumActivityId order by ContentDocument.ContentModifiedDate desc limit 1])
        {
            objContDoc.ContDocIds = objContLink.ContentDocumentId;
        }
        system.debug('===='+objContDoc.ContDocIds);
        return objContDoc;
    }
    public class EventsWrapperClass
    {
        @AuraEnabled public List<Alumni_Activities__c> list_AlumniActivies{get;set;}
        @AuraEnabled public boolean disable;
        @AuraEnabled public String AlumniId;
        @AuraEnabled public string AlumniName;
        @AuraEnabled public date AlumniDate;
        @AuraEnabled public string AlumniVenue;
        @AuraEnabled public string AlumniDetails;
        @AuraEnabled public string AlumniContdocId;
        public EventsWrapperClass ()
        {
            list_AlumniActivies = new List<Alumni_Activities__c> ();
            disable=false;
        }
    }
    public class RegisterWraper
    {
        @AuraEnabled public string strMsg{get;set;}
        @AuraEnabled public string Str_actvs {get;set;}
    }
    public class RegisterCancleWraper
    {
        @AuraEnabled public string strMsg{get;set;}
    }
    public class ContentDocWraper 
    {
        @AuraEnabled public string ContDocIds{get;set;}
    }
    
}