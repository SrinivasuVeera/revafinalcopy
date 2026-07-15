@isTest
public class SAP_StudentMaster_Batch_Handler_Test {
 @isTest
 public static  void SAP_Student()
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
        objcon.Provisional_Admission_Fee_Paid_Date__c = System.today();
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        objCon.Push_to_SAP__c = true;
        update objCon;
        
        hed__Program_Plan__c objProgramplan = new hed__Program_Plan__c();
        objProgramplan.Name = 'Btech';
        //objProgramplan.Record_ID__c = ProgramrecordTypeId;
        objProgramplan.hed__Account__c = objAcc.Id;
        Insert objProgramplan;
       
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
        List<id> list_Con = new List<id>();
        list_Con.add(objCon.id);
       //string parentRecordId = objCon.id;
         //string body ='{"Response":[{"SFDCRecordId": "'+ parentRecordId + '","statusCode"0,"statusMessage":"Success","SAPID":"C0035","responseObject":"CostCenter Is Created Successfully In Dimenssion 3, SAP Code C0035 created."},{{"SFDCRecordId": "'+ parentRecordId + '","statusCode":1,"statusMessage":"Success","SAPID":"C0036","responseObject":"CostCenter Is Created Successfully In Dimenssion 3, SAP Code C0036 created."}]}';
       // res.setBody('{"Response": [{"SFDCRecordId": "' + parentRecordId + '", "statusCode": 0, "SAPID": "SAP123", "responseObject": "Success"}]}');
	string parentRecordId = objCon.id;
	string body = '{"Response":[{"SFDCRecordId": "' + parentRecordId + '","statusCode": 0,"statusMessage": "Success","SAPID": "C0035","responseObject": "CostCenter Is Created Successfully In Dimension 3, SAP Code C0035 created."},{"SFDCRecordId": "' + parentRecordId + '","statusCode": 1,"statusMessage": "Success","SAPID": "C0036","responseObject": "CostCenter Is Created Successfully In Dimension 3, SAP Code C0036 created."}]}';

         //string body ='{"Response":[{"SFDCRecordId":"0031s0000176TPRAA2","statusCode":0,"statusMessage":"Success","SAPID":"C0035","responseObject":"CostCenter Is Created Successfully In Dimenssion 3, SAP Code C0035 created."},{"SFDCRecordId":"0031s0000176TPRAA2","statusCode":1,"statusMessage":"Success","SAPID":"C0036","responseObject":"CostCenter Is Created Successfully In Dimenssion 3, SAP Code C0036 created."}]}';
        MockJsonResponse.setJsonResponse(body);
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockJsonResponse());
        SAP_StudentMaster_Batch sh1 = new SAP_StudentMaster_Batch();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
      
        Test.stopTest();

        
    }
}