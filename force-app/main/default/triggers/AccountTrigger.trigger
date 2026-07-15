trigger AccountTrigger on Account (After insert,After update,Before delete) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        System.debug('Trigger: Insert');
        AccountEmailHelper.handleInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        System.debug('Trigger: Update');
        AccountEmailHelper.handleUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isDelete) {
        System.debug('Trigger: Delete');
        AccountEmailHelper.handleDelete(Trigger.old);
    }
    if(Trigger.isAfter && Trigger.isInsert  && RecursiveTriggerHandler.isFirstTime)
    {
        List<Id> FacultyIds = new List<id>();
        List<Id> SchoolIds = new List<id>();
        List<Id> ProgramIds = new List<id>();
        for(Account objAcc:Trigger.new)
        {
            system.debug('objAcc.RecordType.Id ==> '+objAcc.RecordTypeId );
            Id FacultyrecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution).getRecordTypeId();           
            system.debug('FacultyrecordTypeId ==> '+FacultyrecordTypeId ) ;
            Id SchoolrecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            system.debug('SchoolrecordTypeId==>'+SchoolrecordTypeId);
            Id ProgramrecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
            system.debug('ProgramrecordTypeId==>'+ProgramrecordTypeId);
            if(objAcc.RecordTypeId == FacultyrecordTypeId && objAcc.ParentId != null)
            {
                system.debug('Entering into FaccIds');
                FacultyIds.add(objAcc.Id);
            }
            if(objAcc.RecordTypeId == SchoolrecordTypeId)
            {
                system.debug('Entering into SchoolIds');
                SchoolIds.add(objAcc.Id);
            }
            if(objAcc.RecordTypeId ==ProgramrecordTypeId)
            {
                ProgramIds.add(objAcc.Id);
            }
        }
        system.debug('FacultyIds  '+FacultyIds);
        system.debug('SchoolIds  '+SchoolIds);
        system.debug('ProgramIds  '+ProgramIds);

        if (!facultyIds.isEmpty()) {
            System.enqueueJob(new SAPAPIQueueableHandler.FacultyMasterCreationQueueable(facultyIds));
        }
        if (!schoolIds.isEmpty()) {
            System.enqueueJob(new SAPAPIQueueableHandler.SchoolMasterCreationQueueable(schoolIds));
        }
        if (!programIds.isEmpty()) {
            System.enqueueJob(new SAPAPIQueueableHandler.ProgramMasterCreationQueueable(programIds));
        }
        
    }
    if(Trigger.isAfter && Trigger.isUpdate  && RecursiveTriggerHandler.isFirstTime)
    {
        List<Id> FacultyIds = new List<id>();
        List<Id> SchoolIds = new List<id>();
        List<Id> ProgramIds = new List<id>();
        for(Account objAcc:Trigger.new)
        {
            Account oldobjAcc = Trigger.oldMap.get(objAcc.Id);
            system.debug('objAcc.RecordType.Id ==> '+objAcc.RecordTypeId );
            Id FacultyrecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution).getRecordTypeId();           
            system.debug('FacultyrecordTypeId ==> '+FacultyrecordTypeId ) ;
            Id SchoolrecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            system.debug('SchoolrecordTypeId==>'+SchoolrecordTypeId);
            Id ProgramrecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
            system.debug('ProgramrecordTypeId==>'+ProgramrecordTypeId);
            if(objAcc.RecordTypeId == FacultyrecordTypeId && objAcc.ParentId != null && objAcc.Push_to_SAP__c!=oldobjAcc.Push_to_SAP__c && objAcc.Push_to_SAP__c ==true)
            {
                system.debug('Entering into FaccIds');
                FacultyIds.add(objAcc.Id);
            }
            if(objAcc.RecordTypeId == SchoolrecordTypeId && objAcc.Push_to_SAP__c!=oldobjAcc.Push_to_SAP__c && objAcc.Push_to_SAP__c ==true)
            {
                system.debug('Entering into SchoolIds');
                SchoolIds.add(objAcc.Id);
            }
            if(objAcc.RecordTypeId ==ProgramrecordTypeId && objAcc.Push_to_SAP__c!=oldobjAcc.Push_to_SAP__c && objAcc.Push_to_SAP__c ==true)
            {
                ProgramIds.add(objAcc.Id);
            }
        }
        system.debug('FacultyIds  '+FacultyIds);
        system.debug('SchoolIds  '+SchoolIds);
        system.debug('ProgramIds  '+ProgramIds);

        if (!facultyIds.isEmpty()) {
            System.enqueueJob(new SAPAPIQueueableHandler.FacultyMasterCreationQueueable(facultyIds));
        }
        if (!schoolIds.isEmpty()) {
            System.enqueueJob(new SAPAPIQueueableHandler.SchoolMasterCreationQueueable(schoolIds));
        }
        if (!programIds.isEmpty()) {
            System.enqueueJob(new SAPAPIQueueableHandler.ProgramMasterCreationQueueable(programIds));
        }
    }
}