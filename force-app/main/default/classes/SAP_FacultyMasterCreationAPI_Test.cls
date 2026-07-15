@isTest
public class SAP_FacultyMasterCreationAPI_Test 
{
    public static testmethod void SAP_Faculty()
    {
        //User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id FacultyrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution).getRecordTypeId();
        Id ProgramrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Id SchoolrecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        
        
        Account objAcc = new Account();
        objAcc.RecordTypeId = AccountRecTypeId;
        objAcc.SAP_Name__c = 'FCA';
        objAcc.SAP_ID__c = '1024514';
        objAcc.Name = 'Testing';
        
        insert objAcc;
        
        Account objAcc1 = new Account();
        objAcc1.RecordTypeId = AccountRecTypeId;
        objAcc1.ParentId= objAcc.id;
        objAcc1.Name = 'chatter';
        insert objAcc1;
        
        objAcc1.Push_to_SAP__c = true;
        update objAcc1;
        
        Account objAcc2 = new Account();
        objAcc2.RecordTypeId = FacultyrecordTypeId;
        objAcc2.ParentId= objAcc.id;
        objAcc2.Name = 'chatter';
        insert objAcc2;
        
        Account objAcc3 = new Account();
        objAcc3.RecordTypeId = ProgramrecordTypeId;
        objAcc3.ParentId= objAcc.id;
        objAcc3.Name = 'chatter';
        insert objAcc3;
        
         Account objAcc4 = new Account();
        objAcc4.RecordTypeId = SchoolrecordTypeId;
        objAcc4.ParentId= objAcc.id; 
        objAcc4.Name = 'chatter';
        insert objAcc4;
        update objAcc4;
        
        SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Faculty_Master_Creation');
        
        SAP_FacultyMasterCreationAPI.RequestBodyWrapper rqstbodywrap = new SAP_FacultyMasterCreationAPI.RequestBodyWrapper();
        rqstbodywrap.Name = 'test';
        rqstbodywrap.SFDCRecordId = '0011s00001lkJ0yAAE';
        rqstbodywrap.FullName = 'Faculty of Architecture';
        rqstbodywrap.SAPID = '';
        
        SAP_FacultyMasterCreationAPI.ResponseWrapper reswrap = new SAP_FacultyMasterCreationAPI.ResponseWrapper();
        reswrap.SFDCRecordId = '0011s00001lkJ0yAAE';
        reswrap.statusCode = 200;
        reswrap.statusMessage = 'success';
        reswrap.SAPID = 'SAP2014';
        reswrap.responseObject = 'costCenter is Created Successfully In Dimenssion 1, SAP Code A00136 created';
        
          List< SAP_FacultyMasterCreationAPI.RequestBodyWrapper> RequestBodyWrapperList = new List< SAP_FacultyMasterCreationAPI.RequestBodyWrapper>();
        RequestBodyWrapperList.add(rqstbodywrap);
        List<SAP_FacultyMasterCreationAPI.ResponseWrapper> lst_Res = new List<SAP_FacultyMasterCreationAPI.ResponseWrapper>();
        lst_Res.add(reswrap);
        
        SAP_FacultyMasterCreationAPI.OuterResponseWrapper outwrap = new SAP_FacultyMasterCreationAPI.OuterResponseWrapper();
        outwrap.Response= lst_Res;
        
        system.debug('outwrap '+outwrap);
        List<id> list_Acc = new List<id>();
        list_Acc.add(objAcc1.id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SAP_MasterCreationAPICalloutMock());
        SAP_FacultyMasterCreationAPI.FacultyMasterCreationMethod(list_Acc);
        Test.stopTest();
       
    }
 
}