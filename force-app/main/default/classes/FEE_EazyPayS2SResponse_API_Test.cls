@IsTest
public class FEE_EazyPayS2SResponse_API_Test {
    public static testmethod void EazyPayResponse(){
    
        EasyPay_Details__c easypaydetails = new EasyPay_Details__c();
        easypaydetails.Value__c ='1311140119601518';
        easypaydetails.name ='AES key';
        insert easypaydetails;
        
        Payment_Gateway_Error_Msg__c objpayGateway = new Payment_Gateway_Error_Msg__c();
        objpayGateway.Error_Msg__c ='Success';
        objpayGateway.Name='Eazypay-E000';
        objpayGateway.Status__c ='Success';
        insert objpayGateway;
    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee');        //'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Eazypay';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='84757976';
      //  objStuPayment.Payment_Link_Id__c = 'plink_KlkrGKBqAUFbTD';
        //objStuPayment.Mode_of_Payment__c = 'Online';
        
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '84757976';
    //    objStuFeePay.Payment_Link_Id__c ='plink_KlkrGKBqAUFbTD';
        insert objStuFeePay;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EPS2SRes'; 
        req.httpMethod = 'POST';
        string JSONbody = 'vhFxy8YKG0HlGpPZ4YMSokWuch1JbPvf3B45RVUSbwSU39pty2Rn2QPAJOMSLCYpsdQp6mZoCos9';
        JSONbody += '8BHdUCw0YmXJ+cExFa9vuxcNeO2tlPfgkOJOuY7208yqM3lwCNiATx9pJQMri2aIcxUNT8IceIWv';
        JSONbody += 'xs8flkU0gKO3UYY0GlgZIquuDgOcTKfxdQR2eDWbi3rmIrT3lBnJTUU6eNYDPKc3Cgl9B7YlyQyd';
        JSONbody += 'ox/kTN4XDIzYPKWF1+NLPKGbotByjalnWGuhYJ9447uB3h7NnPCIhmfw+F4uPiIA1A8lcmhWVY4R';
        JSONbody += 'TLSoiyZxaeCSChmf1Bw1WMRMr+a45FT5/QKT6SnC7vnXiqlUfHrXzEXvVrtcRdMIgcp0C1QFYZWJ';
        JSONbody += '8nk+TsDYJ55naybmhPiUrqhGgsf7l8rE6j7E4yrKYnGfpIWQkQS6LnmIIvrfNd37eC2hpf3X/qXq';
        JSONbody += 'It7y1Kz4aPCzay/VtPzbxCrRszT9wqUCAyIORWJuER7fdHPBSdl7WR5MRztPho2AXiPMaRaKSxWv';
        JSONbody += 'TM1zn6DT//FVH83sbzAjf9IhuL5r56seDFtWqaeqKMJDJCk6g5x/LMYPo7NydysZSkhg06pvA5hN';
        JSONbody += '0WIYKf38z4BUIWxyM2V/JxI5ezDRUbXdlcxHwcsdWJWP1241UXouD2fvRBiNePDg3D6oQMFyt/GT';
        JSONbody += 'e0jL7oSBi7VzVPiv3w1xDGWJx9Vb1b5Cl1VSaDMVLdubkF1mUzsRVR2+qpbXY+arhbyRA4ydlII0';
        JSONbody += 'Mw4coEqP4Gf/DumOkK6JcPC0Qe0Sf+6QTGic5+fGtjNli3wHpA8KGo16lI5cbl9P7/Dcs0cK/wiY';
        JSONbody += 'VFkFRTslHb9RAZPfRS9lNbf+bTlsglLQI1HPMFT+9aWbzMd9OktJWiglDNgHjme2PR+kFyE4s+6q';
        JSONbody += 'mfCTeuFXCBLNqCGxlfKiyXgKpc2XVgIco3djTSHOzSbxWyJOAVcx16FlVhAbpVpZhs+P3CbiFoqu';
        JSONbody += 'F7f7qzfbB/JFTA/M3Cch2w52TND1PkBSBHA/rdRGMrmdLB7MBOBTdXdTbqDHN3V6zndcy7Or546u';
        JSONbody += 'J6KJ5qQH1um3IFKOYw+XqIvT/HxkT+spHoBaxJNGlNfqMB3Cluq/xRTknGpmBGR+KBA=';
        
        req.requestBody =  Blob.valueOf(JSONbody);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        FEE_EazyPayS2SResponse_API.ReceivedData();
        Test.stopTest();
    }
    public static testmethod void EazyPayResponse1(){
        EasyPay_Details__c easypaydetails = new EasyPay_Details__c();
        easypaydetails.Value__c ='1311140119601518';
        easypaydetails.name ='AES key';
        insert easypaydetails;
        
        Payment_Gateway_Error_Msg__c objpayGateway = new Payment_Gateway_Error_Msg__c();
        objpayGateway.Error_Msg__c ='Success';
        objpayGateway.Name='Eazypay-E000';
        objpayGateway.Status__c ='Success';
        insert objpayGateway;
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/EPS2SRes'; 
        req.httpMethod = 'POST';
        string JSONbody = 'vhFxy8YKG0HlGpPZ4YMSokWuch1JbPvf3B45RVUSbwSU39pty2Rn2QPAJOMSLCYpsdQp6mZoCos9';
        JSONbody += '8BHdUCw0YmXJ+cExFa9vuxcNeO2tlPfgkOJOuY7208yqM3lwCNiATx9pJQMri2aIcxUNT8IceIWv';
        JSONbody += 'xs8flkU0gKO3UYY0GlgZIquuDgOcTKfxdQR2eDWbi3rmIrT3lBnJTUU6eNYDPKc3Cgl9B7YlyQyd';
        JSONbody += 'ox/kTN4XDIzYPKWF1+NLPKGbotByjalnWGuhYJ9447uB3h7NnPCIhmfw+F4uPiIA1A8lcmhWVY4R';
        JSONbody += 'TLSoiyZxaeCSChmf1Bw1WMRMr+a45FT5/QKT6SnC7vnXiqlUfHrXzEXvVrtcRdMIgcp0C1QFYZWJ';
        JSONbody += '8nk+TsDYJ55naybmhPiUrqhGgsf7l8rE6j7E4yrKYnGfpIWQkQS6LnmIIvrfNd37eC2hpf3X/qXq';
        JSONbody += 'It7y1Kz4aPCzay/VtPzbxCrRszT9wqUCAyIORWJuER7fdHPBSdl7WR5MRztPho2AXiPMaRaKSxWv';
        JSONbody += 'TM1zn6DT//FVH83sbzAjf9IhuL5r56seDFtWqaeqKMJDJCk6g5x/LMYPo7NydysZSkhg06pvA5hN';
        JSONbody += '0WIYKf38z4BUIWxyM2V/JxI5ezDRUbXdlcxHwcsdWJWP1241UXouD2fvRBiNePDg3D6oQMFyt/GT';
        JSONbody += 'e0jL7oSBi7VzVPiv3w1xDGWJx9Vb1b5Cl1VSaDMVLdubkF1mUzsRVR2+qpbXY+arhbyRA4ydlII0';
        JSONbody += 'Mw4coEqP4Gf/DumOkK6JcPC0Qe0Sf+6QTGic5+fGtjNli3wHpA8KGo16lI5cbl9P7/Dcs0cK/wiY';
        JSONbody += 'VFkFRTslHb9RAZPfRS9lNbf+bTlsglLQI1HPMFT+9aWbzMd9OktJWiglDNgHjme2PR+kFyE4s+6q';
        JSONbody += 'mfCTeuFXCBLNqCGxlfKiyXgKpc2XVgIco3djTSHOzSbxWyJOAVcx16FlVhAbpVpZhs+P3CbiFoqu';
        JSONbody += 'F7f7qzfbB/JFTA/M3Cch2w52TND1PkBSBHA/rdRGMrmdLB7MBOBTdXdTbqDHN3V6zndcy7Or546u';
        JSONbody += 'J6KJ5qQH1um3IFKOYw+XqIvT/HxkT+spHoBaxJNGlNfqMB3Cluq/xRTknGpmBGR+KBA=';
        
        req.requestBody =  Blob.valueOf(JSONbody);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        FEE_EazyPayS2SResponse_API.ReceivedData();
        Test.stopTest();
    }
}