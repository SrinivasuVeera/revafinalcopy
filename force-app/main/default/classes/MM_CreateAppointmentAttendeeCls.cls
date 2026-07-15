public without sharing class MM_CreateAppointmentAttendeeCls{

    @AuraEnabled
    public static Wrapperclass getAttendeeRecord(string recordId){
    
        Wrapperclass wrpCls = new Wrapperclass();
        string currentUser = UserInfo.getUserId();
        user objUser = new user();
        
        for(user usr : [SELECT id,contactId FROM USER WHERE id =: currentUser]){
            objUser = usr;
        }
        
        string caseId = '';
        string professorId = '';
        string professorName = '';
                        
        for(CaseTeamMember cm : [SELECT id,ParentId,MemberId FROM CaseTeamMember WHERE MemberId =: objUser.contactId]){
          caseId = cm.ParentId;  
        }
        system.debug('++++++++++'+objUser);
        system.debug('++++++++++'+caseId);
        
        if(string.isNotBlank(caseId)){
            for(case objCase : [SELECT id,ContactId,Contact.Name,ownerId,owner.Name FROM Case WHERE id =: caseId]){
                professorId = objCase.ownerId;
                professorName = objCase.owner.Name;
            }
        }
        /*
        for(case objCase : [SELECT id,ContactId FROM CASE WHERE ContactId =: objUser.contactId]){
           caseId = objCase.id; 
        }
        */
                
        Id attendeeRtId = Schema.SObjectType.sfal__AppointmentAttendee__c.getRecordTypeInfosByName().get('AdvisingEvent').getRecordTypeId();
        sfal__Appointment__c app = [SELECT id,Name,sfal__StartDateTime__c,sfal__EndDateTime__c,Invitation_Sent_Successfully__c FROM sfal__Appointment__c WHERE id =: recordId];
        
     //   DateTime dT = app.sfal__StartDateTime__c;
        date myDate = Date.valueOf(app.sfal__StartDateTime__c);
       // Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
       // string myDate1 = myDate.format();
        system.debug('++++++++++'+app);
        system.debug('++++++++++'+professorId);
        system.debug('++++++++'+myDate);
      //  system.debug('++++++++++'+app.sfal__StartDateTime__c.format());
      //  system.debug('++++++++++'+app.sfal__EndDateTime__c.format());
        list<string> lstEvent = new list<string>();
        
        for(event evt : [SELECT id,ownerId,StartDateTime,EndDateTime FROM Event WHERE ownerId =: professorId AND 
                         Day_Only(StartDateTime) =: myDate]){
                       //  ((StartDateTime >=: app.sfal__StartDateTime__c AND StartDateTime <=: app.sfal__EndDateTime__c) OR 
                       //  (EndDateTime >=: app.sfal__StartDateTime__c AND EndDateTime <=: app.sfal__EndDateTime__c))]){
                       
            if((evt.StartDateTime >= app.sfal__StartDateTime__c && evt.StartDateTime <= app.sfal__EndDateTime__c) || 
                (evt.EndDateTime >= app.sfal__StartDateTime__c && evt.EndDateTime <= app.sfal__EndDateTime__c)) {
                
                     wrpCls.blockedMeeting = true;   
                }           
                
                
                Integer offset = UserInfo.getTimezone().getOffset(evt.StartDateTime);
                Datetime local = evt.StartDateTime.addSeconds(offset/1000);
                system.debug('++++local++'+local);
                
                Integer offset1 = UserInfo.getTimezone().getOffset(evt.EndDateTime);
                Datetime local1 = evt.EndDateTime.addSeconds(offset/1000);
                system.debug('++++local1++'+local1);
                         
            string str = evt.StartDateTime.format('h:mm');
            str = str +'-'+ evt.EndDateTime.format('h:mm');     
            system.debug('++++++'+evt);
            system.debug('+++Str+++'+str);            
            wrpCls.lstEvent.add(str);
        }
        
        system.debug('+++++++LstEvent+++'+wrpCls.lstEvent);
        
        sfal__AppointmentAttendee__c objApp = new sfal__AppointmentAttendee__c();
        objApp.RecordTypeId = attendeeRtId;
        if(!string.isblank(professorId))
        objApp.sfal__Attendee__c = professorId;
        if(!string.isblank(recordId))
        objApp.sfal__Appointment__c = recordId;
        if(!string.isblank(caseId))
        objApp.sfal__AdviseeRecord__c = caseId;
        objApp.Send_Meeting_Invite__c = false;
        wrpCls.objAttandee = objApp;
        wrpCls.invitationSent = app.Invitation_Sent_Successfully__c;
        wrpCls.professor = professorName;
        system.debug('++++++++++'+wrpCls.blockedMeeting);
        system.debug('+++++++objAttandee+++'+wrpCls.objAttandee);
        
        String namespace = 'sfal__';  
        string feildSet = 'AddAttendee';
      //  Wrapperclass wrp = new Wrapperclass();
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(namespace+'AppointmentAttendee__c');
        Schema.DescribeSObjectResult desSObjRslt = sObjType.getDescribe();       
       Schema.FieldSet fieldSetInformation = desSObjRslt.FieldSets.getMap().get(feildSet);
        for(Schema.FieldSetMember fieldSetMember : fieldSetInformation.getFields())
        {
            String FieldPath = String.valueOf(fieldSetMember.getFieldPath()); 
            WrapperFieldSetProperties wr=new WrapperFieldSetProperties();
            wr.isRequired=fieldSetMember.Required;
            wr.FieldSetName=feildSet;
            wr.wrpFieldPath=FieldPath;
            wrpCls.lstOfInfoFields.add(wr);
        }                
        return wrpCls;
    }
    
    @AuraEnabled
    public static string updateAppoinment(string recordId,sfal__AppointmentAttendee__c objAttandee){
        string ErrorMsg = 'Success';
        try{
            insert objAttandee;
            sfal__Appointment__c app = new sfal__Appointment__c();
            app.id = recordId;
            app.Invitation_Sent_Successfully__c = true;
            update app;
        }
        catch (Exception Ex){
            ErrorMsg = string.valueof(Ex);
        }                
        return ErrorMsg;
    }
    
    public class Wrapperclass
    {
        @AuraEnabled public sfal__AppointmentAttendee__c objAttandee = new sfal__AppointmentAttendee__c();
        @AuraEnabled public list<string> lstEvent = new list<string>();
        @AuraEnabled public boolean blockedMeeting;
        @AuraEnabled public boolean invitationSent;
        @AuraEnabled public string professor;
        @AuraEnabled public List<WrapperFieldSetProperties> lstOfFieldLabels = new List<WrapperFieldSetProperties>();
        @AuraEnabled public List<WrapperFieldSetProperties> lstOfInfoFields{get;set;}
       
        public Wrapperclass()
        {
            lstOfInfoFields=new list<WrapperFieldSetProperties>();
            blockedMeeting = false;
            invitationSent = false;
        }
    }
    
    public class WrapperFieldSetProperties
    {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
         @AuraEnabled
        public string FieldSetName{get;set;}
        @AuraEnabled
        public string wrpFieldPath{get;set;}
        @AuraEnabled
        public Boolean isRequired{get;set;}
    }


}