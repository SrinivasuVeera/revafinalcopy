@RestResource(urlMapping='/EPS2SRes/*')
//@RestResource(urlMapping='/EasyPayResponse/*')
global class FEE_EazyPayS2SResponse_API {
    static hed__Application__c appl;
    static list<hed__Application__c> applList;
    static boolean applPAF;
    @HttpPost
    global static void ReceivedData()
    {	
    //     final String APPLICATION_FEE_TYPE ='Application Fee';
    //     RestRequest req = RestContext.request;
    //     RestResponse res = RestContext.response;
    //     system.debug('++++request+++++'+req);
    //     system.debug('++++requestBody+++++'+req.requestBody.toString());
    //     Debug_Log__c dblog = new Debug_Log__c();
    //     string decode = '';
    //     string responseCode;
    //     string paymentMode;
    //     string referenceNo;
    //     string TrnId;
    //     string MandatoryParam;
    //     string StatusMsg;
    //     Map<String, Object> mp_out = new Map<String, Object>();
        
    //     try{
    //         String Key = EasyPay_Details__c.getValues('AES key').Value__c;
    //         string mainStr = req.requestBody.toString().replaceAll( '\\s+', '');
    //         System.debug('>>>> Key: ' + Key);
    //         System.debug('>>>> mainStr: ' + mainStr);
    //         if(!test.isRunningTest()){
    //             // This code will run on production for Decode function
    //            functions.Function accountFunction = functions.Function.get('EazyPayDecodeSb.decodefun');
    //            functions.FunctionInvocation invocation = accountFunction.invoke('{ "input" : "' +mainStr +'", "key" : "'+ key + '"}');
    //             mp_out = (Map<String, Object>) JSON.deserializeUntyped(invocation.getResponse()) ;
    //             decode  = String.valueof(mp_out.get('encodedStr')).unescapeHtml4();
                
    //             // This code will run on Sandbox for Decode Function
    //            /* functions.Function decryptFunction = functions.Function.get('Easypay.decodefun');
    //             functions.FunctionInvocation invokeDecode = decryptFunction.invoke('{ "input" : "' + mainStr + '", "key" : "' + key + '"}');
    //             System.debug('>>>> Decode Response: ' + invokeDecode);
    //             Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(invokeDecode.getResponse()) ;
    //             decode  = String.valueof(resp.get('encodedStr')).unescapeHtml4();
    //             system.debug('>>>> Decoded: ' + decode);*/
    //         }
    //         else{
    //             decode = '<XML><RT>Tran</RT><IcId>131966</IcId><TrnId>2301051634712</TrnId><PayMode>NET_BANKING</PayMode><TrnDate>2023-01-05 17:15:51</TrnDate>';
    //             decode += '<SettleDT>NA</SettleDT><Status>SUCCESS</Status><ResponseCode>E000</ResponseCode><InitiateDT>05-Jan-23</InitiateDT><TranAmt>60000</TranAmt>';
    //             decode += '<BaseAmt>60000</BaseAmt><ProcFees>0.00</ProcFees><STax>0.0</STax><M_SGST>0</M_SGST><M_CGST>0</M_CGST><M_UTGST>0</M_UTGST>';
    //             decode += '<M_STCESS>0</M_STCESS><M_CTCESS>0</M_CTCESS><M_IGST>0</M_IGST><GSTState>MH</GSTState><BillingState>AP</BillingState>';
    //             decode += '<Remarks>84757976~Subject to realization</Remarks><MandatoryParam>84757976&#124;45&#124;60000&#124;Jaya Prakash&#124;jaya@gmail.com&#124;5656565656&#124;84757976</MandatoryParam>';
    //             decode += '<OptionalParam>xyz&#124;xyz</OptionalParam><HashVal>6b6331eb9a5f86b12eb89d8ffa479d6ba423498c2b3b585e8a0b7fb55be5f0a006c039c486cabb31442d54b731d21b2ca758b41a7ac2ca0441d2ef6acc6d72f2</HashVal></XML>';
    //         }
    //         system.debug('+++++++++'+decode);
            
    //         Dom.Document doc = new Dom.Document();  
    //         doc.load(decode);  
    //         Dom.XMLNode rootElement = doc.getRootElement();
    //         for ( Dom.XMLNode child1 : rootElement.getChildElements() ) {
    //             if(child1.getName() == 'TrnId'){
    //                 TrnId = child1.getText();
    //             }
    //             if(child1.getName() == 'PayMode'){
    //                 paymentMode = child1.getText();
    //             }
    //             if(child1.getName() == 'ResponseCode'){
    //                 responseCode = child1.getText();
    //             }
    //             if(child1.getName() == 'MandatoryParam'){
    //                 MandatoryParam = child1.getText();
    //             }
    //         }
            
    //         system.debug('+++++++++'+TrnId);
    //         if(string.isNotBlank(TrnId)){
    //             system.debug('+++++++++'+MandatoryParam);
    //             string[] parameters = MandatoryParam.split('\\|');
    //             system.debug('+++++++++'+parameters);
    //             referenceNo = parameters[0];
    //             dblog.Payment_Reference_Id__c = referenceNo;
                
    //             Student_Payment__c stu = [SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
    //                                           Amount__c ,Razorpay_Signature__c,Payment_Mode_Type__c,Contact__r.Application_Fee_Paid__c,Contact__r.Primary_Academic_Program__r.name,
    //                                           Contact__r.Application_Number__c, contact__r.record_type_name__c,Contact__r.MobilePhone, Contact__r.Country_Code__c FROM Student_Payment__c WHERE Reference_Id__c =: referenceNo];
                    
    //                 if(stu.contact__r.record_type_name__c == 'Applicant'){
                        
    //                     list<hed__Application__c> applList = [Select Provisional_Admission_Fee_Paid__c, Application_Number__c from hed__Application__c
    //                                                 where Application_Number__c =: stu.Contact__r.Application_Number__c LIMIT 1];
    //                     if(applList.size() >0){
                            
    //                         applPAF = applList[0].Provisional_Admission_Fee_Paid__c;
                            
    //                         appl = applList[0];
    //                     }
    //                 }
    //             if(responseCode == 'E000' ){
    //                 stu.Payment_Status__c = 'Success'; 
    //                 StatusMsg = 'Transaction Success..!!';                   
    //             }
    //             else{
    //                 stu.Payment_Status__c = 'Failed'; 
    //                 StatusMsg = 'Transaction Failed..!!';
    //             }     
    //             stu.Transaction_ID__c = TrnId;
    //             stu.Mode_of_Payment__c = 'Online';
    //             stu.Payment_Date_Time__c = system.now();
    //             stu.Payment_Gateway__c = 'Eazypay';
    //             stu.Payment_Mode_Type__c = paymentMode;
    //             update stu;
                
               
    //             list<Student_Fee_Payment__c> lst_Studentfee = new list<Student_Fee_Payment__c>();
    //             for(Student_Fee_Payment__c objStuFeePayment : [Select Id,Name,Amount__c,Mode_of_Payment__c,Payment_Link_Id__c,SF_Transaction_ID__c,Student_Fee__c,Line_Item_Payment_Status__c,
    //                                                            Student_Payment__c,Transaction_Date_Time__c,Payment_Mode_Type__c from Student_Fee_Payment__c  where
    //                                                            Student_Payment__c =: stu.id])
    //             {
    //                 if(responseCode == 'E000'){
    //                     objStuFeePayment.Line_Item_Payment_Status__c = 'Success';
    //                 }    
    //                 else{ 
    //                     objStuFeePayment.Line_Item_Payment_Status__c = 'Failed'; 
    //                 }              
    //                     objStuFeePayment.SF_Transaction_ID__c = TrnId;
    //                     objStuFeePayment.Transaction_Date_Time__c = system.now();
    //                     objStuFeePayment.Payment_Mode_Type__c = paymentMode;
    //                     lst_Studentfee.add(objStuFeePayment);
    //             }
                
    //             update lst_Studentfee;
    //             dblog.Class_Name__c = 'FEE_EazyPayS2SResponse_API';
    //             dblog.Method_Name__c = 'updateStudentFee';
    //             dblog.Processing_API_Name__c = 'EasyPay';            
    //             dblog.Data_Received__c = decode;
    //             if(Payment_Gateway_Error_Msg__c.getValues('Eazypay-'+responseCode).Status__c == 'Success'){
    //                 dblog.Status__c = 'Success';
    //             }
    //             else{
    //                 dblog.Status__c = 'Failure';
    //             }
    //             insert dblog;
                
    //               if(stu.Payment_Status__c == 'Success' && stu.Fee_Type__c == APPLICATION_FEE_TYPE && stu.Contact__r.Application_Fee_Paid__c == false){
    //                     system.debug('Genearate Receipt');
    //                     //Passing the paymentId(Transaction_ID__C) - as the VisualFOrce is not able to retrieve the fields updated in this class.
    //                     //Hence we are passing them as parameters and using the values in the VF Controller (StudentPaymentController)
    //                     Id cvId = RegistrationFormUtility.generateReceipt(stu.Id, stu.Transaction_ID__C, stu.Payment_Gateway__c);
    //                     RegistrationFormUtility.sendReceipt(stu.Id, cvId); 
    //                 }  
                
    //             // Sending Receipt for 1st Year Provisional Admission Fee paid as True
    //                 if(applPAF == false && stu.Payment_Status__c == 'Success' && stu.Fee_Type__c != APPLICATION_FEE_TYPE){
    //                     system.debug('PAF method');
    //                     List<Student_Fee__c> sf = [select id, contact__c, fee_year__c from student_fee__c
    //                                                where contact__c =: stu.Contact__c AND Fee_year__c='1st Year']; 
    //                     if(!sf.isEmpty()){
                            
    //                         AdmissionsProcessUtility.generateOfflineReceipt(stu.Id,stu.Payment_Mode_Type__c,stu.Payment_Gateway__c,stu.Transaction_ID__c );
                            
    //                     } 
    //                 }
    //         }
    //     }
    //     catch(Exception Ex){
    //         system.debug('Catch++++++++'+string.valueof(ex));
    //         dblog.Class_Name__c = 'FEE_EazyPayS2SResponse_API';
    //         dblog.Method_Name__c = 'updateStudentFee';
    //         dblog.Processing_API_Name__c = 'EazyPay'; 
    //         if(string.isNotBlank(decode)){           
    //             dblog.Data_Received__c = decode;
    //         }
    //         else{
    //             dblog.Data_Received__c = req.requestBody.toString();
    //         }
    //         if(string.isNotBlank(responseCode)){
    //             if(Payment_Gateway_Error_Msg__c.getValues('Eazypay-'+responseCode).Status__c == 'Success'){
    //                 dblog.Status__c = 'Success';
    //             }
    //             else{
    //                 dblog.Status__c = 'Failure';
    //             }
    //         }
    //         else{
    //             dblog.Status__c = 'Failure';
    //         }
    //         upsert dblog;
    //     }
    }

}