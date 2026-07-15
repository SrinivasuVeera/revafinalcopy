@RestResource(urlMapping='/AdjustmentAPI')
global class SAP_AdjustmentAPI {
    @HttpPost
    global static List<ResponseData> paymentAdjustments(List<RequestData> adjustmentDataList) {
        List<ResponseData> responseAPIList = new List<ResponseData>();
        Map<String, Decimal> demandNegativeEntryAmount = new Map<String, Decimal>();
        Map<string,Decimal> demandAmountInnerMap = new Map<string,Decimal>();
        Map<string,Decimal> demandNegativeEntryAmountSCN2 = new Map<string,Decimal>();
        Map<string,Decimal> stdFeeNegativeEntryAmountSCN2 = new Map<string,Decimal>();
        Map<string,Decimal> stdPayNegativeEntryAmountSCN2 = new Map<string,Decimal>();
        Map<string,Decimal> negativeAmountEntrySCN2Map = new Map<string,Decimal>();
        Map<string,Decimal> demandAmountInnerMapSCN2 = new Map<string,Decimal>();
        Map<string,Decimal> stPayNegativeEntryAmountSCN3 = new Map<string,Decimal>();
        Map<string,Decimal> demandAmountInnerMapSCN3 = new Map<string,Decimal>();
        for (RequestData reqData : adjustmentDataList) {
            ResponseData response = new ResponseData();
            if (String.isBlank(reqData.Mode_of_Payment) && String.isBlank(reqData.Adjusted_DemandNo)) {
                response.DemandNo = reqData.Adjusted_DemandNo;
                response.SFDCRecordId = reqData.SFDCRecordId;
                response.StatusCode = 1;
                response.StatusMessage = 'Missing Mode of Payment';
                response.responseObject = null;
                response.ErrorMsg = 'Missing Mode of Payment';
                responseAPIList.add(response); 
            } else if (String.isBlank(reqData.Adjusted_DemandNo) && String.isBlank(reqData.SFDCRecordId)) {
                response.DemandNo = reqData.Adjusted_DemandNo;
                response.SFDCRecordId = reqData.SFDCRecordId;
                response.StatusCode = 1;
                response.StatusMessage = 'Missing Adjusted Demand Number or SFDC Record ID';
                response.responseObject = null;
                response.ErrorMsg = 'Missing Adjusted Demand Number or SFDC Record ID';
                responseAPIList.add(response);
            }  
            if (!String.isBlank(reqData.Adjusted_DemandNo)) { //&& !String.isBlank(reqData.Mode_of_Payment)) {
                
                demandNegativeEntryAmount.put(reqData.Adjusted_DemandNo, calculateTotalAmount(reqData.Payment));
                if(reqData.Payment != null && !reqData.Payment.isEmpty())
                {
                    
                    for(Payment pymnt:reqData.Payment)
                    {
                        demandAmountInnerMap.put(pymnt.Demand_Number,pymnt.Amount);
                    }
                }
            }
            if((!String.isBlank(reqData.Mode_of_Payment) && reqData.Mode_of_Payment =='Online') && !String.isBlank(reqData.SFDCRecordId) && String.isBlank(reqData.Adjusted_DemandNo )){
                
                stdFeeNegativeEntryAmountSCN2.put(reqData.SFDCRecordId, calculateTotalAmount(reqData.Payment));
                if(reqData.Payment != null && !reqData.Payment.isEmpty())
                {
                    
                    for(Payment pymnt:reqData.Payment)
                    {
                        
                        stdPayNegativeEntryAmountSCN2.put(pymnt.Demand_Number,pymnt.Amount);
                    }
                    
                }
            }
            if((!String.isBlank(reqData.Mode_of_Payment) && reqData.Mode_of_Payment =='Offline') && !String.isBlank(reqData.SFDCRecordId) && String.isBlank(reqData.Adjusted_DemandNo )){
                
                stPayNegativeEntryAmountSCN3.put(reqData.SFDCRecordId, calculateTotalAmount(reqData.Payment));
                if(reqData.Payment != null && !reqData.Payment.isEmpty())
                {
                    
                    for(Payment pymnt:reqData.Payment)
                    {
                        
                        demandAmountInnerMapSCN3.put(pymnt.Demand_Number,pymnt.Amount);
                    }
                }
            }
        }
        if(!demandNegativeEntryAmount.isEmpty()){
            responseAPIList.addAll(processStudentPaymentsNegativeEntrySCN1(demandNegativeEntryAmount, new List<ResponseData>()));
        }
        if(!demandAmountInnerMap.isEmpty()){
            responseAPIList.addALL(innerStudentPaymentsPostiveEntrySCN1(demandAmountInnerMap,  new List<ResponseData>()));
        }
        IF(!stdFeeNegativeEntryAmountSCN2.isEmpty()){
            responseAPIList.addAll(processStudentPaymentsNegativeEntrySCN2(stdFeeNegativeEntryAmountSCN2, new List<ResponseData>()));
        }
        if(!stdPayNegativeEntryAmountSCN2.isEmpty()){
            responseAPIList.addALL(innerStudentPaymentsPostiveEntrySCN2(stdPayNegativeEntryAmountSCN2,  new List<ResponseData>()));
        }
        IF(!stPayNegativeEntryAmountSCN3.isEmpty()){
            responseAPIList.addAll(processStudentPaymentsNegativeEntrySCN3(stPayNegativeEntryAmountSCN3, new List<ResponseData>()));
        }
        if(!demandAmountInnerMapSCN3.isEmpty()){
            responseAPIList.addALL(innerStudentPaymentsPostiveEntrySCN3(demandAmountInnerMapSCN3,  new List<ResponseData>()));
        }
        return responseAPIList;
    }
    public static List<ResponseData> processStudentPaymentsNegativeEntrySCN1(Map<String, Decimal> demandNegativeEntryAmount, List<ResponseData> responseAPIList) {
        try {
            if (!demandNegativeEntryAmount.isEmpty()) {
                List<Student_Payment__c> studentPaymentsToInsert = new List<Student_Payment__c>();
                List<Student_Fee_Payment__c> studentFeePaymentsToInsert = new List<Student_Fee_Payment__c>();
                Map<String, Student_Payment__c> demandNumberToStudentPaymentMap = new Map<String, Student_Payment__c>();
                Map<String, Id> demandNumberToStudentFeeIdMap = new Map<String, Id>();
                Map<String, Id> demandNumberToStudentPaymentIdMap = new Map<String, Id>();
                List<String> demandNumbers = new List<String>(demandNegativeEntryAmount.keySet());
                for (Integer i = 0; i < demandNumbers.size(); i++) {
                    String demandNumber = demandNumbers[i];
                    
                    Id studentFeeId = getStudentFeeIdForDemandNumber(demandNumber);
                    if (studentFeeId == null) {
                        handleFailedInsertion(responseAPIList, null, 'Payment', 'Record not found for demandNumber: ' + demandNumber);
                        continue; 
                    }
                    
                    Id contactId = getContactIdForDemandNumber(demandNumber);
                    demandNumberToStudentFeeIdMap.put(demandNumber, studentFeeId);
                    Student_Payment__c studentPayment = new Student_Payment__c(
                        Payment_Status__c = 'Adjusted',
                        Contact__c  =contactId,
                        Demand_Number__c  = demandNumber,
                        Amount__c = demandNegativeEntryAmount.get(demandNumber));
                    studentPaymentsToInsert.add(studentPayment);
                }
                List<Database.SaveResult> paymentSaveResults = Database.insert(studentPaymentsToInsert, false);
                List<String> demandNumbersList = new List<String>(demandNegativeEntryAmount.keySet());
                set<id>stdPaymentIdsinserted= new set<id>();
                for (Database.SaveResult sr : paymentSaveResults) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        
                        stdPaymentIdsinserted.add(sr.getId());
                    }
                    else{
                        handleFailedInsertion(responseAPIList, sr, 'Payment','Error');
                    }
                }
                Map<string,string> spDemandMap = getDemandNumberStdPayment(stdPaymentIdsinserted);
                for (Id paymentId : stdPaymentIdsinserted) {
                    ResponseData sResponse = new ResponseData(); 
                    sResponse.DemandNo = spDemandMap.get(paymentId);
                    sResponse.SFDCRecordId = paymentId;
                    sResponse.StatusCode = 0;
                    sResponse.StatusMessage = 'Success';
                    sResponse.responseObject = 'Data inserted successfully.' + '\'' + sResponse.DemandNo + '\'';
                    sResponse.ErrorMsg = null;
                    
                    demandNumberToStudentPaymentIdMap.put(sResponse.DemandNo ,paymentId);
                    demandNumberToStudentPaymentMap.put(sResponse.DemandNo ,getStudentPayment(paymentId));
                }
                for (Id paymentId : stdPaymentIdsinserted) {
                    String demandNumber =  spDemandMap.get(paymentId);
                    
                    Student_Payment__c studentPayment = demandNumberToStudentPaymentMap.get(demandNumber);
                    Id studentFeeId = demandNumberToStudentFeeIdMap.get(demandNumber);
                    
                    if(studentFeeId != null){
                        Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c(
                            Student_Fee__c = studentFeeId,
                            Amount__c = studentPayment.Amount__c,
                            Line_Item_Payment_Status__c = 'Adjusted',
                            Remarks__c = 'srands',
                            Adjustment__c = true,
                            Adjustment_Flag__c = 'Negative Entry',
                            Student_Payment__c = demandNumberToStudentPaymentIdMap.get(demandNumber));
                        studentFeePaymentsToInsert.add(studentFeePayment);
                    }
                }
                if (!studentFeePaymentsToInsert.isEmpty()) {
                    Database.SaveResult[] feePaymentSaveResults = Database.insert(studentFeePaymentsToInsert, false);
                    set<id>stdFEEPaymentIdsinserted= new set<id>();
                    for (Database.SaveResult sr : feePaymentSaveResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            
                            stdFEEPaymentIdsinserted.add(sr.getId());
                        }
                        else{
                            handleFailedInsertion(responseAPIList, sr, 'FeePayment','Error');
                        }
                    }
                    Map<String,String>  stdPaymentStdFeepaymentMap = getStdentPaymentsIdsfromStdFeePayment(stdFEEPaymentIdsinserted);
                    for (Id stdfeepaymentId : stdFEEPaymentIdsinserted) {
                        string paymentID = stdPaymentStdFeepaymentMap.get(stdfeepaymentId);
                        Student_Payment__c sp = getStudentPayment(paymentID);
                        ResponseData successResponse = new ResponseData();
                        successResponse.DemandNo = sp.Demand_Number__c;
                        successResponse.SFDCRecordId = stdfeepaymentId;
                        successResponse.StatusCode = 0;
                        successResponse.StatusMessage = 'Success';
                        successResponse.responseObject = 'Student Fee payment inserted  successfully.' + '\'' + successResponse.DemandNo + '\'';
                        successResponse.ErrorMsg = null;
                        responseAPIList.add(successResponse);
                    }
                }
            }
        } catch (Exception e) {
            
            ResponseData errorResponse = new ResponseData();
            errorResponse.StatusCode = 2;
            errorResponse.StatusMessage = 'Error processing student payments';
            errorResponse.ErrorMsg = e.getMessage();
            responseAPIList.add(errorResponse);
        }
        return  responseAPIList;
    }
    public static List<ResponseData> innerStudentPaymentsPostiveEntrySCN1(Map<String, Decimal> demandAmountInnerMap, List<ResponseData> responseAPIList) { 
        try {
            if (!demandAmountInnerMap.isEmpty()) {
                List<Student_Payment__c> studentPaymentsToInsert = new List<Student_Payment__c>();
                List<Student_Fee_Payment__c> studentFeePaymentsToInsert = new List<Student_Fee_Payment__c>();
                List<String> demandNumbers = new List<String>(demandAmountInnerMap.keySet());
                Map<String, Id> demandNumberToStudentFeeIdMap = new Map<String, Id>();
                Map<String, Id> demandNumberToStudentPaymentIdMap = new Map<String, Id>();
                Map<String, Student_Payment__c> demandNumberToStudentPaymentMap = new Map<String, Student_Payment__c>();
                for (Integer i = 0; i < demandNumbers.size(); i++) {
                    String demandNumber = demandNumbers[i];
                    Id studentFeeId = getStudentFeeIdForDemandNumber(demandNumber);
                    if (studentFeeId == null) {
                        handleFailedInsertion(responseAPIList, null, 'Payment', 'Record not found for demandNumber: ' + demandNumber);
                        continue; 
                    }
                    Id contactId = getContactIdForDemandNumber(demandNumber);
                    demandNumberToStudentFeeIdMap.put(demandNumber, studentFeeId);
                    Student_Payment__c studentPayment = new Student_Payment__c(
                        Payment_Status__c = 'Adjusted',
                        Contact__c  =contactId,
                        Demand_Number__c  = demandNumber,
                        Amount__c = demandAmountInnerMap.get(demandNumber));
                    studentPaymentsToInsert.add(studentPayment);
                }
                List<Database.SaveResult> paymentSaveResults = Database.insert(studentPaymentsToInsert, false);
                List<String> demandNumbersList = new List<String>(demandAmountInnerMap.keySet());
                set<id>stdPaymentIdsinserted= new set<id>();
                for (Database.SaveResult sr : paymentSaveResults) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                       
                        stdPaymentIdsinserted.add(sr.getId());
                    }
                    else{
                        handleFailedInsertion(responseAPIList, sr, 'Payment','Error');
                    }
                }
                Map<string,string> spDemandMap = getDemandNumberStdPayment(stdPaymentIdsinserted);
                for (Id paymentId : stdPaymentIdsinserted) {
                    ResponseData sResponse = new ResponseData(); 
                    sResponse.DemandNo = spDemandMap.get(paymentId);
                    sResponse.SFDCRecordId = paymentId;
                    sResponse.StatusCode = 0;
                    sResponse.StatusMessage = 'Success';
                    sResponse.responseObject = 'Data inserted successfully.' + '\'' + sResponse.DemandNo + '\'';
                    sResponse.ErrorMsg = null;
                    // responseAPIList.add(sResponse);
                    demandNumberToStudentPaymentIdMap.put(sResponse.DemandNo, paymentId);
                    demandNumberToStudentPaymentMap.put(sResponse.DemandNo,getStudentPayment(paymentId));
                }
                for (Id paymentId : stdPaymentIdsinserted) {
                    String demandNumber =  spDemandMap.get(paymentId);
                    
                    Student_Payment__c studentPayment = demandNumberToStudentPaymentMap.get(demandNumber);
                    Id studentFeeId = demandNumberToStudentFeeIdMap.get(demandNumber);
                    
                    if(studentFeeId != null){
                        Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c(
                            Student_Fee__c = studentFeeId,
                            Amount__c = studentPayment.Amount__c,
                            Line_Item_Payment_Status__c = 'Adjusted',
                            Remarks__c = 'sfeeinner',
                            Adjustment__c = true,
                            Adjustment_Flag__c = 'Positive Entry',
                            Student_Payment__c = demandNumberToStudentPaymentIdMap.get(demandNumber));
                        studentFeePaymentsToInsert.add(studentFeePayment);
                    }
                }
                if (!studentFeePaymentsToInsert.isEmpty()) {
                    Database.SaveResult[] feePaymentSaveResults = Database.insert(studentFeePaymentsToInsert, false);
                    set<id>stdFEEPaymentIdsinserted= new set<id>();
                    for (Database.SaveResult sr : feePaymentSaveResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                           
                            stdFEEPaymentIdsinserted.add(sr.getId());
                        }
                        else{
                            handleFailedInsertion(responseAPIList, sr, 'FeePayment','Error');
                        }
                    }
                    Map<String,String>  stdPaymentStdFeepaymentMap = getStdentPaymentsIdsfromStdFeePayment(stdFEEPaymentIdsinserted);
                    for (Id stdfeepaymentId : stdFEEPaymentIdsinserted) {
                        string paymentID = stdPaymentStdFeepaymentMap.get(stdfeepaymentId);
                        Student_Payment__c sp = getStudentPayment(paymentID);
                        ResponseData successResponse = new ResponseData();
                        successResponse.DemandNo = sp.Demand_Number__c;
                        successResponse.SFDCRecordId = stdfeepaymentId;
                        successResponse.StatusCode = 0;
                        successResponse.StatusMessage = 'Success';
                        successResponse.responseObject = 'Student Fee payment inserted  successfully.' + '\'' + successResponse.DemandNo + '\'';
                        successResponse.ErrorMsg = null;
                        responseAPIList.add(successResponse);
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            ResponseData errorResponse = new ResponseData();
            errorResponse.StatusCode = 3;
            errorResponse.StatusMessage = 'Error processing student payments innerloop';
            errorResponse.ErrorMsg = e.getMessage();
            responseAPIList.add(errorResponse);
        }
        return  responseAPIList;
    }
    public static List<ResponseData> processStudentPaymentsNegativeEntrySCN2(Map<String, Decimal> stdFeeNegativeEntryAmountSCN2, List<ResponseData> responseAPIList) {
        try {
            if (!stdFeeNegativeEntryAmountSCN2.isEmpty()) {
                List<Student_Payment__c> studentPaymentsToInsert = new List<Student_Payment__c>();
                List<Student_Fee_Payment__c> studentFeePaymentsToInsert = new List<Student_Fee_Payment__c>();
                Map<String, Student_Payment__c> stdFeeToStudentPaymentMap = new Map<String, Student_Payment__c>();
                Map<String, Id> demandNumberToStudentFeeIdMap = new Map<String, Id>();
                Map<String, Id> stdFeeToStudentPaymentIdMap = new Map<String, Id>();
                Map<String,String> SfeeIdContactIdMap = new Map<String,String>();
                List<String> sfdcSFPIDs = new List<String>(stdFeeNegativeEntryAmountSCN2.keySet());
                for (Integer i = 0; i < sfdcSFPIDs.size(); i++) {
                    String SFsfdcpayId = sfdcSFPIDs[i];
                    
                    Id studentFeeId = getStudentFeeIdBasedonStudentFeepaymentId(SFsfdcpayId);
                    if (studentFeeId == null) {
                        // Record does not exist for the current spId
                        handleFailedInsertion(responseAPIList, null, 'Payment', 'Record not found for SFsfdcpayId: ' + SFsfdcpayId);
                        continue; // Skip to the next iteration
                    }
                    
                        Id contactId = getContactIdForSFeeRecordId(studentFeeId);
                    //demandNumberToStudentFeeIdMap.put(demandNumber, studentFeeId);
                    Student_Payment__c studentPayment = new Student_Payment__c(
                        Payment_Status__c = 'Adjusted',
                        Contact__c  =contactId,
                        Amount__c = stdFeeNegativeEntryAmountSCN2.get(SFsfdcpayId));
                    SfeeIdContactIdMap.put(contactId,studentFeeId);
                    studentPaymentsToInsert.add(studentPayment);
                }
                List<Database.SaveResult> paymentSaveResults = Database.insert(studentPaymentsToInsert, false);               
                List<String> stdFeeIDList = new List<String>(stdFeeNegativeEntryAmountSCN2.keySet());               
                set<id>stdPaymentIdsinserted= new set<id>();
                for (Database.SaveResult sr : paymentSaveResults) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        
                        stdPaymentIdsinserted.add(sr.getId());
                    }
                    else{
                        handleFailedInsertion(responseAPIList, sr, 'Payment','Error');
                    }
                }
                Map<string,string> getContactsFromPaymens = getContactfromPayments(stdPaymentIdsinserted);
                for (Id paymentId : stdPaymentIdsinserted) {
                    string contId = getContactIdFromPaymentid(paymentId);
                    string StdfeeId = SfeeIdContactIdMap.get(contId);
                    Student_Payment__c stp = getStudentPayment(paymentId);
                    stdFeeToStudentPaymentIdMap.put(StdfeeId,paymentId );
                    stdFeeToStudentPaymentMap.put(StdfeeId,stp);
                    if(StdfeeId != null){
                        Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c(
                            Student_Fee__c = StdfeeId,
                            Amount__c = stp.Amount__c,
                            Line_Item_Payment_Status__c = 'Adjusted',
                            Remarks__c = 'srands',
                            Adjustment__c = true,
                            Adjustment_Flag__c = 'Negative Entry',
                            Student_Payment__c =stp.Id);
                        studentFeePaymentsToInsert.add(studentFeePayment);
                    }
                }
                if (!studentFeePaymentsToInsert.isEmpty()) {
                    Database.SaveResult[] feePaymentSaveResults = Database.insert(studentFeePaymentsToInsert, false);
                    set<id>stdFEEPaymentIdsinserted= new set<id>();
                    for (Database.SaveResult sr : feePaymentSaveResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
              
                            stdFEEPaymentIdsinserted.add(sr.getId());
                        }
                        else{
                            handleFailedInsertion(responseAPIList, sr, 'FeePayment','Error');
                        }
                    }
                    Map<String,String>  stdPaymentStdFeepaymentMap = getStdentPaymentsIdsfromStdFeePayment(stdFEEPaymentIdsinserted);
                    for (Id stdfeepaymentId : stdFEEPaymentIdsinserted) {
                        string paymentID = stdPaymentStdFeepaymentMap.get(stdfeepaymentId);
                        Student_Payment__c sp = getStudentPayment(paymentID);
                        ResponseData successResponse = new ResponseData();
                        successResponse.DemandNo = sp.Demand_Number__c;
                        successResponse.SFDCRecordId = stdfeepaymentId;
                        successResponse.StatusCode = 0;
                        successResponse.StatusMessage = 'Success';
                        successResponse.responseObject = 'Student Fee payment inserted  successfully.' + '\'' + successResponse.DemandNo + '\'';
                        successResponse.ErrorMsg = null;
                        responseAPIList.add(successResponse);
                    }
                }
            }
        } catch (Exception e) {
            
            ResponseData errorResponse = new ResponseData();
            errorResponse.StatusCode = 2;
            errorResponse.StatusMessage = 'Error processing student payments';
            errorResponse.ErrorMsg = e.getMessage();
            responseAPIList.add(errorResponse);
        }
        return  responseAPIList;
    }
    public static List<ResponseData> innerStudentPaymentsPostiveEntrySCN2(Map<String, Decimal> demandAmountInnerMapSCN2, List<ResponseData> responseAPIList) { 
        try {
            if (!demandAmountInnerMapSCN2.isEmpty()) {
                List<Student_Payment__c> studentPaymentsToInsert = new List<Student_Payment__c>();
                List<Student_Fee_Payment__c> studentFeePaymentsToInsert = new List<Student_Fee_Payment__c>();
                List<String> demandNumbers = new List<String>(demandAmountInnerMapSCN2.keySet());
                Map<String, Id> demandNumberToStudentFeeIdMap = new Map<String, Id>();
                Map<String, Id> demandNumberToStudentPaymentIdMap = new Map<String, Id>();
                Map<String, Student_Payment__c> demandNumberToStudentPaymentMap = new Map<String, Student_Payment__c>();
                for (Integer i = 0; i < demandNumbers.size(); i++) {
                    String demandNumber = demandNumbers[i];  
                    Id studentFeeId = getStudentFeeIdForDemandNumber(demandNumber);
                    if (studentFeeId == null) {  
                        handleFailedInsertion(responseAPIList, null, 'Payment', 'Record not found for demandNumber: ' + demandNumber);
                        continue; 
                    }
                    Id contactId = getContactIdForDemandNumber(demandNumber);
                    demandNumberToStudentFeeIdMap.put(demandNumber, studentFeeId);
                    Student_Payment__c studentPayment = new Student_Payment__c(
                        Payment_Status__c = 'Adjusted',
                        Contact__c  =contactId,
                        Demand_Number__c  = demandNumber,
                        Amount__c = demandAmountInnerMapSCN2.get(demandNumber));
                    studentPaymentsToInsert.add(studentPayment);
                }
                List<Database.SaveResult> paymentSaveResults = Database.insert(studentPaymentsToInsert, false);
                List<String> demandNumbersList = new List<String>(demandAmountInnerMapSCN2.keySet());
                set<id>stdPaymentIdsinserted= new set<id>();
                for (Database.SaveResult sr : paymentSaveResults) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        
                        stdPaymentIdsinserted.add(sr.getId());
                    }
                    else{
                        handleFailedInsertion(responseAPIList, sr, 'Payment','Error Insertion');
                    }
                }
                Map<string,string> spDemandMap = getDemandNumberStdPayment(stdPaymentIdsinserted);
                for (Id paymentId : stdPaymentIdsinserted) {
                    ResponseData sResponse = new ResponseData(); 
                    sResponse.DemandNo = spDemandMap.get(paymentId);
                    sResponse.SFDCRecordId = paymentId;
                    sResponse.StatusCode = 0;
                    sResponse.StatusMessage = 'Success';
                    sResponse.responseObject = 'Data inserted successfully.' + '\'' + sResponse.DemandNo + '\'';
                    sResponse.ErrorMsg = null;
                    // responseAPIList.add(sResponse);
                    demandNumberToStudentPaymentIdMap.put(sResponse.DemandNo, paymentId);
                    demandNumberToStudentPaymentMap.put(sResponse.DemandNo,getStudentPayment(paymentId));
                }
                for (Id paymentId : stdPaymentIdsinserted) {
                    String demandNumber =  spDemandMap.get(paymentId);
                    
                    Student_Payment__c studentPayment = demandNumberToStudentPaymentMap.get(demandNumber);
                    Id studentFeeId = demandNumberToStudentFeeIdMap.get(demandNumber);
                    
                    if(studentFeeId != null){
                        Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c(
                            Student_Fee__c = studentFeeId,
                            Amount__c = studentPayment.Amount__c,
                            Line_Item_Payment_Status__c = 'Adjusted',
                            Remarks__c = 'sfeeinner',
                            Adjustment__c = true,
                            Adjustment_Flag__c = 'Positive Entry',
                            Student_Payment__c = demandNumberToStudentPaymentIdMap.get(demandNumber));
                        studentFeePaymentsToInsert.add(studentFeePayment);
                    }
                }
                if (!studentFeePaymentsToInsert.isEmpty()) {
                    Database.SaveResult[] feePaymentSaveResults = Database.insert(studentFeePaymentsToInsert, false);
                    set<id>stdFEEPaymentIdsinserted= new set<id>();
                    for (Database.SaveResult sr : feePaymentSaveResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            
                            
                            stdFEEPaymentIdsinserted.add(sr.getId());
                        }
                        else{
                            handleFailedInsertion(responseAPIList, sr, 'FeePayment','Error');
                        }
                    }
                    Map<String,String>  stdPaymentStdFeepaymentMap = getStdentPaymentsIdsfromStdFeePayment(stdFEEPaymentIdsinserted);
                    for (Id stdfeepaymentId : stdFEEPaymentIdsinserted) {
                        string paymentID = stdPaymentStdFeepaymentMap.get(stdfeepaymentId);
                        Student_Payment__c sp = getStudentPayment(paymentID);
                        ResponseData successResponse = new ResponseData();
                        successResponse.DemandNo = sp.Demand_Number__c;
                        successResponse.SFDCRecordId = stdfeepaymentId;
                        successResponse.StatusCode = 0;
                        successResponse.StatusMessage = 'Success';
                        successResponse.responseObject = 'Student Fee payment inserted  successfully.' + '\'' + successResponse.DemandNo + '\'';
                        successResponse.ErrorMsg = null;
                        responseAPIList.add(successResponse);
                    }
                }
                
            }
            
            
        }
        catch (Exception e) {
            
            ResponseData errorResponse = new ResponseData();
            errorResponse.StatusCode = 3;
            errorResponse.StatusMessage = 'Error processing student payments innerloop';
            errorResponse.ErrorMsg = e.getMessage();
            responseAPIList.add(errorResponse);
        }
        
        return  responseAPIList;
    }
    
    public static List<ResponseData> innerStudentPaymentsPostiveEntrySCN3(Map<String, Decimal> demandAmountInnerMapSCN3, List<ResponseData> responseAPIList) { 
        try {
            if (!demandAmountInnerMapSCN3.isEmpty()) {
                List<Student_Payment__c> studentPaymentsToInsert = new List<Student_Payment__c>();
                List<Student_Fee_Payment__c> studentFeePaymentsToInsert = new List<Student_Fee_Payment__c>();
                List<String> demandNumbers = new List<String>(demandAmountInnerMapSCN3.keySet());
                Map<String, Id> demandNumberToStudentFeeIdMap = new Map<String, Id>();
                Map<String, Id> demandNumberToStudentPaymentIdMap = new Map<String, Id>();
                Map<String, Student_Payment__c> demandNumberToStudentPaymentMap = new Map<String, Student_Payment__c>();
                for (Integer i = 0; i < demandNumbers.size(); i++) {
                    
                    String demandNumber = demandNumbers[i];
                    
                    Id studentFeeId = getStudentFeeIdForDemandNumber(demandNumber);
                    if (studentFeeId == null) {
                        
                        handleFailedInsertion(responseAPIList, null, 'Payment', 'Record not found for demandNumber: ' + demandNumber);
                        continue; 
                    }
                    Id contactId = getContactIdForDemandNumber(demandNumber);
                    demandNumberToStudentFeeIdMap.put(demandNumber, studentFeeId);
                    Student_Payment__c studentPayment = new Student_Payment__c(
                        Payment_Status__c = 'Adjusted',
                        Contact__c  =contactId,
                        Demand_Number__c  = demandNumber,
                        Amount__c = demandAmountInnerMapSCN3.get(demandNumber));
                    studentPaymentsToInsert.add(studentPayment);
                }
                List<Database.SaveResult> paymentSaveResults = Database.insert(studentPaymentsToInsert, false);          
                List<String> demandNumbersList = new List<String>(demandAmountInnerMapSCN3.keySet());          
                set<id>stdPaymentIdsinserted= new set<id>();
                for (Database.SaveResult sr : paymentSaveResults) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                                         
                        stdPaymentIdsinserted.add(sr.getId());
                    }
                    else{
                        handleFailedInsertion(responseAPIList, sr, 'Payment','Error');
                    }   
                }
                Map<string,string> spDemandMap = getDemandNumberStdPayment(stdPaymentIdsinserted);
                for (Id paymentId : stdPaymentIdsinserted) {
                    ResponseData sResponse = new ResponseData(); 
                    sResponse.DemandNo = spDemandMap.get(paymentId);
                    sResponse.SFDCRecordId = paymentId;
                    sResponse.StatusCode = 0;
                    sResponse.StatusMessage = 'Success';
                    sResponse.responseObject = 'Data inserted successfully.' + '\'' + sResponse.DemandNo + '\'';
                    sResponse.ErrorMsg = null;
                    // responseAPIList.add(sResponse);
                    demandNumberToStudentPaymentIdMap.put(sResponse.DemandNo, paymentId);
                    demandNumberToStudentPaymentMap.put(sResponse.DemandNo,getStudentPayment(paymentId));
                }
                for (Id paymentId : stdPaymentIdsinserted) {
                    String demandNumber =  spDemandMap.get(paymentId);
                    
                    Student_Payment__c studentPayment = demandNumberToStudentPaymentMap.get(demandNumber);
                    Id studentFeeId = demandNumberToStudentFeeIdMap.get(demandNumber);
                    
                    if(studentFeeId != null){
                        Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c(
                            Student_Fee__c = studentFeeId,
                            Amount__c = studentPayment.Amount__c,
                            Line_Item_Payment_Status__c = 'Adjusted',
                            Remarks__c = 'sfeeinner',
                            Adjustment__c = true,
                            Adjustment_Flag__c = 'Positive Entry',
                            Student_Payment__c = demandNumberToStudentPaymentIdMap.get(demandNumber));
                        studentFeePaymentsToInsert.add(studentFeePayment);
                    }
                }
                if (!studentFeePaymentsToInsert.isEmpty()) {
                    Database.SaveResult[] feePaymentSaveResults = Database.insert(studentFeePaymentsToInsert, false);
                    set<id>stdFEEPaymentIdsinserted= new set<id>();
                    for (Database.SaveResult sr : feePaymentSaveResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            
                            stdFEEPaymentIdsinserted.add(sr.getId());
                        }
                        else{
                            handleFailedInsertion(responseAPIList, sr, 'FeePayment','Error');
                        }
                    }
                    Map<String,String>  stdPaymentStdFeepaymentMap = getStdentPaymentsIdsfromStdFeePayment(stdFEEPaymentIdsinserted);
                    for (Id stdfeepaymentId : stdFEEPaymentIdsinserted) {
                        string paymentID = stdPaymentStdFeepaymentMap.get(stdfeepaymentId);
                        Student_Payment__c sp = getStudentPayment(paymentID);
                        ResponseData successResponse = new ResponseData();
                        successResponse.DemandNo = sp.Demand_Number__c;
                        successResponse.SFDCRecordId = stdfeepaymentId;
                        successResponse.StatusCode = 0;
                        successResponse.StatusMessage = 'Success';
                        successResponse.responseObject = 'Student Fee payment inserted  successfully.' + '\'' + successResponse.DemandNo + '\'';
                        successResponse.ErrorMsg = null;
                        responseAPIList.add(successResponse);
                    }
                }
            }
        }
        catch (Exception e) {
            
            ResponseData errorResponse = new ResponseData();
            errorResponse.StatusCode = 3;
            errorResponse.StatusMessage = 'Error processing student payments innerloop';
            errorResponse.ErrorMsg = e.getMessage();
            responseAPIList.add(errorResponse);
        }
        return  responseAPIList;
    }
    public static List<ResponseData> processStudentPaymentsNegativeEntrySCN3(Map<String, Decimal> stPayNegativeEntryAmountSCN3, List<ResponseData> responseAPIList) {
        try {
           
            if (!stPayNegativeEntryAmountSCN3.isEmpty()) {
                List<Student_Payment__c> studentPaymentsToInsert = new List<Student_Payment__c>();
                List<Student_Fee_Payment__c> studentFeePaymentsToInsert = new List<Student_Fee_Payment__c>();
                List<String> sfdcSPIDs = new List<String>(stPayNegativeEntryAmountSCN3.keySet());
                List<Decimal> sfdcSPIDsVAlues = new List<Decimal>(stPayNegativeEntryAmountSCN3.Values());
                
                Map<String,String> SfeeIdContactIdMap = new Map<String,String>();
                Map<String, Student_Payment__c> stdFeeToStudentPaymentMap = new Map<String, Student_Payment__c>();
                Map<String, Id> stdFeeToStudentPaymentIdMap = new Map<String, Id>();
                Map<String, List<Student_Fee_Payment__c>> mapStuFeePaymns = new Map<String, List<Student_Fee_Payment__c>>();
                for(Student_Fee_Payment__c sfp:[SELECT Id, Name,Amount__c,Remarks__c,Line_Item_Payment_Status__c ,Student_Fee__c, Student_Payment__c,Student_Fee__r.Fee_Type__c,
                                                Student_Fee__r.contact__c FROM Student_Fee_Payment__c 
                                                WHERE Student_Payment__c IN:sfdcSPIDs  ORDER By CreatedDate DESC] )
                {
                    if(mapStuFeePaymns.containsKey(sfp.Student_Fee__r.contact__C)){
                        mapStuFeePaymns.get(sfp.Student_Fee__r.contact__c).add(sfp);
                    }
                    else{
                        mapStuFeePaymns.put(sfp.Student_Fee__r.contact__c,new list<Student_Fee_Payment__c>{sfp});
                    }
                }
                
                list<Student_Payment__c> sptoInsert = new list<Student_Payment__c>();
                Map<String,Decimal> spTotalAmount = new Map<String,Decimal>();
                for(Student_Payment__c sp:[SELECT ID,Contact__c FROM Student_Payment__c WHERE ID IN:sfdcSPIDs]){
                    
                    
                    if(mapStuFeePaymns.containsKey(sp.Contact__c)){
                        Student_Payment__c studentPayment = new Student_Payment__c();
                        studentPayment.Payment_Status__c = 'Adjusted';
                        studentPayment.Contact__c  = sp.Contact__c;
                        studentPayment.Amount__c = stPayNegativeEntryAmountSCN3.get(sp.Id);
                        spTotalAmount.put(sp.Contact__c,studentPayment.Amount__c);
                        sptoInsert.add(studentPayment);
                        
                    }
                }
                if(!sptoInsert.isEmpty()){
                    List<Database.SaveResult> paymentSaveResults1 = Database.insert(sptoInsert, false);
                 
                    set<id>stdPaymentIdsinserted1= new set<id>();
                    for (Database.SaveResult sr : paymentSaveResults1) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            
                            stdPaymentIdsinserted1.add(sr.getId());
                        }
                        else{
                            handleFailedInsertion(responseAPIList, sr, 'Payment','Error');
                        }
                    }
                             
                    list<Student_Fee_Payment__c> insertSfp = new list<Student_Fee_Payment__c>();
                    for (Student_Payment__c stdPay :[SELECT ID,Amount__c,Contact__c FROM Student_Payment__c WHERE ID IN:stdPaymentIdsinserted1] ) {
                        decimal paidAmount = stdPay.Amount__c;
                        if(mapStuFeePaymns.containsKey(stdPay.Contact__c )){
                            integer recSize = mapStuFeePaymns.get(stdPay.Contact__c).size();
                            integer count = 0;
                            for(Student_Fee_Payment__c sfp : mapStuFeePaymns.get(stdPay.Contact__c)){
                                
                                count = count + 1;
                                if(paidAmount > 0){
                                    
                                    if(sfp.Amount__c  > paidAmount && paidAmount > 0 && ((sfp.Amount__c  > 0 && recSize != count)|| recSize == count)){
                                       
                                        Student_Fee_Payment__c sfpnew = new Student_Fee_Payment__c();
                                        sfpnew.Amount__c =paidAmount;
                                        sfpnew.Student_Fee__c = sfp.Student_Fee__c;
                                        sfpnew.Line_Item_Payment_Status__c = 'Adjusted';
                                        sfpnew.Remarks__c = 'scn3 cond1';
                                        sfpnew.Adjustment_Flag__c = 'Negative Entry';
                                        sfpnew.Adjustment__c = true;
                                        sfpnew.Student_Payment__c =stdPay.Id;
                                        insertSfp.add(sfpnew);
                                        paidAmount = 0;
                                    }
                                    else if(sfp.Amount__c  < paidAmount && paidAmount > 0 && ((sfp.Amount__c  > 0 && recSize != count)|| recSize == count)){
                                        Student_Fee_Payment__c sfpnew = new Student_Fee_Payment__c();
                                        
                                        sfpnew.Student_Fee__c = sfp.Student_Fee__c;
                                        sfpnew.Amount__c = sfp.Amount__c;
                                        //sfpnew.Student_Fee__c = sfp.Student_Fee__c;
                                        sfpnew.Line_Item_Payment_Status__c = 'Adjusted';
                                        sfpnew.Remarks__c = 'scn3 cond2';
                                        sfpnew.Adjustment_Flag__c = 'Negative Entry';
                                        sfpnew.Adjustment__c = true;
                                        sfpnew.Student_Payment__c =stdPay.Id;
                                        paidAmount = paidAmount - sfp.Amount__c;
                                        
                                        insertSfp.add(sfpnew);
                                    }
                                    else if(sfp.Amount__c == paidAmount && paidAmount > 0 && ((sfp.Amount__c > 0 && recSize != count)|| recSize == count)){
                                        Student_Fee_Payment__c sfpnew = new Student_Fee_Payment__c();
                                        sfpnew.Amount__c = paidAmount;
                                        sfpnew.Student_Fee__c = sfp.Student_Fee__c;
                                        sfpnew.Line_Item_Payment_Status__c = 'Adjusted';
                                        sfpnew.Remarks__c = 'scn3 cond4';
                                        sfpnew.Adjustment_Flag__c = 'Negative Entry';
                                        sfpnew.Adjustment__c = true;
                                        sfpnew.Student_Payment__c =stdPay.Id;
                                        insertSfp.add(sfpnew);
                                        paidAmount = 0;
                                    }
                                }
                            }
                        }
                    }
                    if (!insertSfp.isEmpty()) {
                        Database.SaveResult[] feePaymentSaveResults = Database.insert(insertSfp, false);
                        set<id>stdFEEPaymentIdsinserted= new set<id>();
                        for (Database.SaveResult sr : feePaymentSaveResults) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                
                                stdFEEPaymentIdsinserted.add(sr.getId());
                            }
                            else{
                                handleFailedInsertion(responseAPIList, sr, 'FeePayment','Error');
                            }
                        }
                        Map<String,String>  stdPaymentStdFeepaymentMap = getStdentPaymentsIdsfromStdFeePayment(stdFEEPaymentIdsinserted);
                        for (Id stdfeepaymentId : stdFEEPaymentIdsinserted) {
                            string paymentID = stdPaymentStdFeepaymentMap.get(stdfeepaymentId);
                            Student_Payment__c sp = getStudentPayment(paymentID);
                            ResponseData successResponse = new ResponseData();
                            successResponse.DemandNo = sp.Demand_Number__c;
                            successResponse.SFDCRecordId = sp.Id;
                            successResponse.StatusCode = 0;
                            successResponse.StatusMessage = 'Success';
                            successResponse.responseObject = 'Payment Adjustment process completed successfully.' + '\'' + successResponse.DemandNo + '\'';
                            successResponse.ErrorMsg = null;
                            responseAPIList.add(successResponse);
                        }
                    }                
                }
                
            }
        }catch(Exception e){
            
            ResponseData errorResponse = new ResponseData();
            errorResponse.StatusCode = 2;
            errorResponse.StatusMessage = 'Error processing student payments';
            errorResponse.ErrorMsg = e.getMessage();
            responseAPIList.add(errorResponse);
        }
        return  responseAPIList;
    }
    private static Id getStudentFeeIdForDemandNumber(String demandNumber) {
        return [SELECT Id, Demand_Number__c FROM Student_Fee__c WHERE Demand_Number__c =:demandNumber].Id;
    }
    private static Id getContactIdForDemandNumber(String demandNumber) {
        return [SELECT Id, Demand_Number__c,Contact__c  FROM Student_Fee__c WHERE Demand_Number__c =:demandNumber].Contact__c ;
    }
    private static Id getStudentFeeIdBasedonStudentFeepaymentId(String stfpsfdcrecordId) {
        return [SELECT Id, Name, Student_Fee__c FROM Student_Fee_Payment__c WHERE ID =:stfpsfdcrecordId].Student_Fee__c ;
    }
    public static Id getStudentFeeIdBasedonStudentpaymentId(String stPaymentsfdcrecordId) {
        return [SELECT Id, Name, Student_Fee__c, Student_Payment__c,Student_Fee__r.Fee_Type__c FROM Student_Fee_Payment__c 
                WHERE Student_Payment__c =:stPaymentsfdcrecordId AND Student_Fee__r.Fee_Type__c != 'University Fee' ORDER By CreatedDate ].Student_Fee__c ;
    }
    public static Id getContactIdForSFeeRecordId(String sfeeRecordId) {
        return [SELECT Id, Demand_Number__c,Contact__c  FROM Student_Fee__c WHERE ID=:sfeeRecordId].Contact__c ;
    }
    public static Map<String,String> getDemandNumberStdPayment(Set<Id> StdPaymentIds){
        Map<String,String> stdPayDemandMap = new Map<String,String>();
        for(Student_Payment__c stp:[SELECT Id, Demand_Number__c FROM Student_Payment__c Where Id IN:StdPaymentIds]){
            stdPayDemandMap.put(stp.id,stp.Demand_Number__c);
        }
        return stdPayDemandMap;
    }
    public static Map<String,String> getContactfromPayments(Set<Id> StdPaymentIds){
        Map<String,String> stdPayDemandMap = new Map<String,String>();
        for(Student_Payment__c stp:[SELECT Id, Demand_Number__c,Contact__c  FROM Student_Payment__c Where Id IN:StdPaymentIds]){
            stdPayDemandMap.put(stp.Contact__c ,stp.id );
        }
        return stdPayDemandMap;
    }
    public static  Id getContactIdFromPaymentid(string paymentID){
        return [SELECT Id, Demand_Number__c,Amount__c,Contact__c FROM Student_Payment__c Where Id =:paymentId].Contact__c;
    }
    private static Student_Payment__c getStudentPayment(String paymentId) {
        return [SELECT Id, Demand_Number__c,Amount__c FROM Student_Payment__c Where Id =:paymentId];
    }

    public static Map<String,String> getStdentPaymentsIdsfromStdFeePayment(Set<Id> StdFeePaymentIds){
        Map<String,String> stdFeePayStdPayIdMap = new Map<String,String>();
        for(Student_Fee_Payment__c stp:[SELECT Id, Student_Payment__c  FROM Student_Fee_Payment__c  Where Id IN:StdFeePaymentIds]){
            stdFeePayStdPayIdMap.put(stp.id,stp.Student_Payment__c );
        }
        return stdFeePayStdPayIdMap;
    }
    private static void handleFailedInsertion(List<ResponseData> responseAPIList, Database.SaveResult sr, String recordType, String customMessage) {
        ResponseData errorResponse = new ResponseData();
        errorResponse.StatusCode = 1; 
        errorResponse.StatusMessage = 'Error inserting ' + recordType;
        errorResponse.ErrorMsg = sr != null ? sr.getErrors().toString() : customMessage;
        responseAPIList.add(errorResponse);
    }
    private static Decimal calculateTotalAmount(List<Payment> payments) {
        Decimal totalAmount = 0;
        for (Payment payment : payments) {
            totalAmount += payment.Amount;
        }
        return totalAmount;
    }
    global class Payment {
        public String Demand_Number;
        public Decimal Amount;
        public String Application_Number;
    }
    global class RequestData {
        public String Mode_of_Payment;
        public String Adjusted_DemandNo;
        public String SFDCRecordId;
        public List<Payment> Payment;
    }
    global class ResponseData {
        public String DemandNo;
        public Decimal StatusCode;
        public String StatusMessage;
        public String responseObject;
        public String ErrorMsg;
        public String SFDCRecordId;
    }
}