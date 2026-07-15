@isTest
public class SAP_ProgramBatchMasterCreationAPI_Test 
{
    public static testmethod void SAP_ProgramBatch()
    {
        string houseHoldRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = new Account();
        objAcc.Name  = 'Testing';
        objAcc.Recordtypeid = houseHoldRecType;
        Insert objAcc;
     
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id ProgramrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Contact objCon = new Contact();
        objCon.LastName = 'testing';
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        //objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        objCon.Push_to_SAP__c = true;
        update objCon;
        
        hed__Program_Plan__c objProgramplan = new hed__Program_Plan__c();
        objProgramplan.Name = 'Btech';
        //objProgramplan.Record_ID__c = ProgramrecordTypeId;
        objProgramplan.hed__Account__c = objAcc.Id;
        objProgramplan.Push_to_SAP__c = false;
        Insert objProgramplan;
        objProgramplan.Push_to_SAP__c = true;
        Update objProgramplan;
       
        SAPSLCMIntegrationURL__mdt mdt = SAPSLCMIntegrationURL__mdt.getInstance('Program_Batch_Creation');
        
        SAP_ProgramBatchMasterCreationAPI.RequestBodyWrapper rqstbodywrap = new SAP_ProgramBatchMasterCreationAPI.RequestBodyWrapper();
        rqstbodywrap.ProgramSAPCODE = 'test';
        rqstbodywrap.Active = true;
        rqstbodywrap.End_Date = system.today();
        rqstbodywrap.Intake = 25000;
        rqstbodywrap.Number_of_Years = '2years';
        rqstbodywrap.Name = 'sap';
        rqstbodywrap.FullName = 'SAP_REVA';
        rqstbodywrap.SAPId = 'SAP10223';
        rqstbodywrap.Start_Date = system.today();
        rqstbodywrap.Total_Number_Of_Lateral_Students = '60';
        rqstbodywrap.Total_Number_Of_Regular_Students = '25';
        rqstbodywrap.SFDCRecordId = '0011s00001lkJ0yAAE';
        
        
        SAP_ProgramBatchMasterCreationAPI.ResponseWrapper reswrap = new SAP_ProgramBatchMasterCreationAPI.ResponseWrapper();
        reswrap.SFDCRecordId = '0011s00001lkJ0yAAE';
        reswrap.statusCode = 0;
        reswrap.statusMessage = 'success';
        reswrap.SAPID = 'SAP2014';
        reswrap.responseObject = 'costCenter is Created Successfully In Dimenssion 1, SAP Code A00136 created';
        
          List< SAP_ProgramBatchMasterCreationAPI.RequestBodyWrapper> RequestBodyWrapperList = new List< SAP_ProgramBatchMasterCreationAPI.RequestBodyWrapper>();
        RequestBodyWrapperList.add(rqstbodywrap);
        List<SAP_ProgramBatchMasterCreationAPI.ResponseWrapper> lst_Res = new List<SAP_ProgramBatchMasterCreationAPI.ResponseWrapper>();
        lst_Res.add(reswrap);
        
        SAP_ProgramBatchMasterCreationAPI.OuterResponseWrapper outwrap = new SAP_ProgramBatchMasterCreationAPI.OuterResponseWrapper();
        outwrap.Response= lst_Res;
        
        system.debug('outwrap '+outwrap);
        List<id> list_prog = new List<id>();
        list_prog.add(objProgramplan.id);
        
       
         string body ='{"Response":[{"SFDCRecordId":"a0K1s000008iej3EAA","statusCode":0,"statusMessage":"Success","SAPID":"C0035","responseObject":"CostCenter Is Created Successfully In Dimenssion 3, SAP Code C0035 created."},{"SFDCRecordId":"a0K1s000008iej3EAA","statusCode":1,"statusMessage":"Success","SAPID":"C0036","responseObject":"CostCenter Is Created Successfully In Dimenssion 3, SAP Code C0036 created."}]}';
        MockJsonResponse.setJsonResponse(body);
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockJsonResponse());
        SAP_ProgramBatchMasterCreationAPI.ProgramBatchMasterCreationMethod(list_prog);
        Test.stopTest();

        
    }
    
    
}