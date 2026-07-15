({
    doInitHelper : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        var action = component.get("c.DisplayStudentFeeRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                console.log('response.getReturnValue()', response.getReturnValue());
                if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();
                    component.set("v.lstPendingFee",retVal.lst_CheckboxWrap);
                    
                    //AddebyRajashekar09Aug2024
                    if(response.getReturnValue().lst_CheckboxWrap.length != 0){
                       component.set("v.SplitOnContact",response.getReturnValue().lst_CheckboxWrap[0].ObjStuFeeDeatils.Contact__r.Split_Booking_Fee__c);
                       console.log('stufeepayrecs1==>',retVal.lst_CheckboxWrap); 
                    }
                    //endshere
                    
                    component.set("v.lstPaidFee",retVal.lst_StuPaidDetails);
                    component.set("v.lstStuPaymentFee",retVal.lst_StuPaymentDetails);
                    component.set("v.totalRecordsCount",retVal.lst_CheckboxWrap.length);
                    component.set("v.Studentname",retVal.objStuname);
                    component.set("v.AppNumber",retVal.objAppNumber);
                    component.set("v.SrnNumber",retVal.objSrnNumber);
                    component.set("v.Spinner", false); 
                    component.set("v.totalStuAmount",retVal.TotalAmount);
                    component.set("v.totalStuPenAmount",retVal.TotalPendingAmount);
                    component.set("v.totalStuPaidAmount",retVal.TotalPaidAmount);
                    if(retVal.lst_CheckboxWrap != null){
                       retVal.lst_CheckboxWrap.forEach(function(fee) {
                    if (fee.ObjStuFeeDeatils.Name.toLowerCase().includes('caution') && fee.Amount_Pending__c !=0) {
                        console.log('Name--'+fee.ObjStuFeeDeatils.Name);
                         component.set('v.checkCautionFee', true); 
                        //isChecked = true;
                    } else {
                        component.set('v.checkCautionFee', false); 
                       // fee.isChecked = false;
                    }
                     //checkfor hostelpenaltyfee added 01-07-2024
                        /* if (fee.ObjStuFeeDeatils.Name.toLowerCase().includes('hostel penalty')) {
                                console.log('Name--' + fee.ObjStuFeeDeatils.Name);
                                component.set('v.checkHostelPenaltyFee', true);
                            } else {
                                component.set('v.checkHostelPenaltyFee', false);
                            }*/
                }); 
                    }
                
                }
            }
            else{                 
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
            
        });       
        $A.enqueueAction(action);  
    },
    makePaymentHlpr: function(component, event, helper)
    {
        console.log('inside make payment helper');
        component.set("v.Spinner", true);
        var selctId = component.get("v.SelectedRecId");        
        var action = component.get("c.singleRecordCheckLateFee");
        action.setParams({
            "feeId": selctId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                console.log('inside make payment helper if 1');
                var retVal = response.getReturnValue();
                if(retVal == 'Success'){
                    console.log('inside make payment helper if 2');
                    this.VlaidationHlpr(component, event, helper);
                }
                else{
                    component.set("v.Spinner",false);
                    this.showToast(component,'dismissible','Failed',retVal,'error');
                }
            } 
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },    
    VlaidationHlpr: function(component, event, helper)
    {
        console.log('inside validation helper');
        component.set("v.Spinner", true); 
        var selid =  component.get("v.SelectedRecId");
        var seldate =  component.get("v.SelectedDueDate");
        var selconatctid = component.get("v.SelectedConId");
        if(seldate != undefined)
        {
            console.log('inside validation helper inside if 1');
            var action = component.get("c.ValidationDate");
            action.setParams({
                "strSelid":selid,
                "selduedate":seldate,
                "Conid":selconatctid
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    console.log('inside validation helper inside if 2');
                    if(response.getReturnValue() != undefined)
                    {
                        console.log('inside If 1');
                        if(response.getReturnValue().DateError != null)
                        {
                            var retVal = response.getReturnValue().DateError;
                            this.showToast(component,'dismissible','Failed',retVal,'error');
                        }
                        else 
                        {
                            helper.onPayNowHlpr(component, event, helper);
                        }    
                    }
                    component.set("v.Spinner", false);  
                }
                else {                 
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }
            });
            $A.enqueueAction(action);
            console.log('inside If');
        }
        else
        {
            console.log('inside validation helper inside last else');
            helper.onPayNowHlpr(component, event, helper);
        }
    },
    fetchGQEMI : function(component, contactId, feeList, mode) {
    var action = component.get("c.getGrayQuestEmiAmount");
    action.setParams({ 
        "contactId": contactId,
        "selectedFees": feeList,
        "mode": mode
    });
    action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
            component.set("v.gqEmiAmount", response.getReturnValue());
        }
    });
    $A.enqueueAction(action);
	},
    onPayNowHlpr: function(component, event, helper)
    {
        var selid =  component.get("v.SelectedRecId");
        console.log("selid", selid);
        var action = component.get("c.FetchFeeRecords");
        action.setParams({
            "strSelid": selid
        });
        action.setCallback(this, function(response) {
            console.log('response--------->'+JSON.stringify(response.getReturnValue()));
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    var mapPayment = [];
                    var result = response.getReturnValue().map_PaymentGateway;
                    console.log('result----->'+JSON.stringify(result));
                    for(var key in result){
                        mapPayment.push({key: key, value: result[key]});
                    }    
                    component.set("v.openModel",true);
                    var resData = response.getReturnValue();
					this.fetchGQEMI(component, resData.lst_StuFeePayment[0].Contact__c, resData.lst_StuFeePayment, 'single');
                    component.set("v.PaymentMap", mapPayment);
                    component.set("v.lstStuFeePayment",response.getReturnValue().lst_StuFeePayment);
                    component.set("v.lstStuPaymtRec",response.getReturnValue().lst_StuFeePayment[0].Student_Fee_Payments__r);
                   
                    console.log('studentFeeRec==>',component.get("v.lstStuFeePayment"));
                    console.log('studentPayementRec==>',component.get("v.lstStuPaymtRec"));
                    
                    component.set("v.feetypestudent",response.getReturnValue().StuFeeType);
                    component.set("v.InstallMentNo",response.getReturnValue().NoOfInstallments);
                    component.set("v.NumberofInstallmentsPaid",response.getReturnValue().lst_StuFeePayment[0].Paid_Installments__c);
                    component.set("v.paymentType",response.getReturnValue().StuFeeType);
                    console.log('payment type --->'+response.getReturnValue().StuFeeType);
                    //AddebyRajashkear01Aug2024
                    component.set("v.SplitOnContact",response.getReturnValue().lst_StuFeePayment[0].Contact__r.Split_Booking_Fee__c);
                    //endshere
                    
                    
                    console.log('numberOFInstallments'+response.getReturnValue().lst_StuFeePayment[0].Paid_Installments__c);
                    
                    
                    /***********************workingone*/
                       if(response.getReturnValue().lst_StuFeePayment[0].Paid_Installments__c == 0 && response.getReturnValue().lst_StuFeePayment[0].Payment_Type__c == 'Partial Payment'){// srija added for the no of splitations
                    if(response.getReturnValue().lst_StuFeePayment[0].Premium_Room__c == true && response.getReturnValue().lst_StuFeePayment[0].Payment_Type__c == 'Partial Payment' && response.getReturnValue().lst_StuFeePayment[0].Number_of_Installments__c==5){
                         var withPremiumValue = $A.get("$Label.c.WithPremium");
                        component.set("v.EnteredAmount",withPremiumValue);
                    }else if(response.getReturnValue().lst_StuFeePayment[0].Premium_Room__c == false && response.getReturnValue().lst_StuFeePayment[0].Payment_Type__c == 'Partial Payment' && response.getReturnValue().lst_StuFeePayment[0].Number_of_Installments__c==5){
                         var withoutPremiumValue = $A.get("$Label.c.WithoutPremium");
                        component.set("v.EnteredAmount",withoutPremiumValue);
                    }
                       }else{
                         component.set("v.EnteredAmount",response.getReturnValue().PendingAmount); //existing line
                    }
                    component.set("v.Spinner", false);  //existing line
                     console.log('Installment no-->'+component.get("v.InstallMentNo"));
                    
                }
                    /************************/
                   
                    
                }
                else {                 
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }
            });
            $A.enqueueAction(action);
        },
    VlaidationMultiHlpr: function(component, event, helper)
        {
            component.set("v.Spinner", true); 
            var totalRecamount =0;            
            var selcRecords = component.get("v.MultiSelectList");
            var selRecList =[];
            for(var i=0;i<selcRecords.length;i++)
            {
                selRecList.push(selcRecords[i].ObjStuFeeDeatils);
                if(selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c != null)
                {
                    totalRecamount = totalRecamount + selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c ;
                }
            }
            //component.set("v.totalAmount",totalRecamount);            
            component.set("v.SelectedRecLst",selRecList);
            var action = component.get("c.ValidateMultiPayments");
            action.setParams({
                "lst_StuIds": selRecList
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    if(response.getReturnValue() != undefined)
                    {
                        if(response.getReturnValue().DateError != null)
                        {
                            var retVal = response.getReturnValue().DateError;
                            this.showToast(component,'dismissible','Failed',retVal,'error');
                        }
                        if(response.getReturnValue().DateError == null)
                        {
                            helper.MultipayHlpr(component, event, helper);                        
                        }    
                    }
                    component.set("v.Spinner", false);  
                }
                else {                 
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }
            });
            $A.enqueueAction(action);        
        },
    MultipayHlpr :function(component, event, helper)
        {
            component.set("v.Spinner", true); 
            var totalRecamount =0;            
            var selcRecords = component.get("v.MultiSelectList");
            var selRecList =[];
            var pendingAmounts = 0;
            for(var i=0;i<selcRecords.length;i++)
            {
                selRecList.push(selcRecords[i].ObjStuFeeDeatils);
                if(selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c != null)
                {
                    totalRecamount = totalRecamount + selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c ;
                }
                if (selcRecords[i].ObjStuFeeDeatils.Fee_Type__c === 'Tuition Fee') {
                selcRecords[i].ObjStuFeeDeatils.editable = true;
                pendingAmounts += selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c ;
                
                } else {
                    selcRecords[i].ObjStuFeeDeatils.editable = false;
                } 
            }
            component.set("v.pendingAmounts", pendingAmounts);
            component.set("v.totalAmount",totalRecamount);            
            component.set("v.SelectedRecLst",selRecList);
            var action = component.get("c.MultiStduentFeeRecords");
            console.log('selRecList1===>',selRecList);
            action.setParams({
                "lst_StuIds": selRecList
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    if(response.getReturnValue() != undefined)
                    {
                        var mapPayment = [];
                        var result = response.getReturnValue().map_PaymentGateway;
                        for(var key in result){
                            mapPayment.push({key: key, value: result[key]});
                        }   
                        component.set("v.openMultiModel",true); 
                        var resData = response.getReturnValue();
                        var feeList = resData.lst_StuFeePayment; 
                        var contactId = feeList[0].Contact__c;
                        
                        this.fetchGQEMI(component, contactId, feeList, 'multi');
                        component.set("v.MultiPaymentMap", mapPayment);
                        component.set("v.lstMultipleRecords",response.getReturnValue().lst_StuFeePayment);
                       //AddebyRajashekar
                        if(response.getReturnValue().lst_StuFeePayment.length != 0){
                            component.set("v.SplitOnContact",response.getReturnValue().lst_StuFeePayment[0].Contact__r.Split_Booking_Fee__c);
                            console.log('selRecList2==>',response.getReturnValue().lst_StuFeePayment);
                            console.log('selRecList3==>',component.get("v.MultiSelectList"));
                        }
                        //endshere
                        component.set("v.ErrMessage",response.getReturnValue().Errmsg);
                        component.set("v.Spinner", false); 
                    }
                }
                else{                 
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }
            });
            $A.enqueueAction(action);
        },
    grayQuestGeneratePaymentLink : function(component, event, helper, stuFees, payamount, feeType) {  
    console.log('@@@ Helper: Generating GrayQuest Link for ' + feeType);
    component.set("v.ModelSpinner", true); 

    var cleanFees = [];
    if(feeType == 'single') {        
        cleanFees = JSON.parse(JSON.stringify(stuFees));
    } else {
        cleanFees = JSON.parse(JSON.stringify(stuFees));
    }

    var action = component.get("c.grayQuestGenerateLink");
    action.setParams({
        "lst_StuFeeDeatils": cleanFees,
        "PartialAmount": payamount,
        "feeType": feeType            
    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        console.log('@@@ GrayQuest Apex State: ' + state);

        if (state === "SUCCESS") {
            var retVal = response.getReturnValue();
            console.log('@@@ GrayQuest Response: ', JSON.stringify(retVal));

            if(retVal && retVal.data && retVal.data.redirection_url) {
                console.log('@@@ Redirecting to portal...');
                window.open(retVal.data.redirection_url, "_self");
            } else {                        
                var msg = (retVal && retVal.message) ? retVal.message : "Redirection URL not received.";
                this.showToast(component, 'dismissible', 'Failed', 'GrayQuest Error: ' + msg, 'error');
                component.set("v.ModelSpinner", false);
            }
        } else {            
            var errors = response.getError();
            var message = "Unknown error";
            if (errors && errors[0] && errors[0].message) {
                message = errors[0].message;
            }
            console.log('@@@ Apex Error: ' + message);
            this.showToast(component, 'dismissible', 'Failed', message, 'error');
            component.set("v.ModelSpinner", false); 
        }  
    });
    
    $A.enqueueAction(action);   
	},
    rezorPayGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
        {        
            component.set("v.Spinner", true); 
            var action = component.get("c.razorPayGenratePaymentLink");
            //alert('=====>>>'+JSON.stringify(stuFees));
            action.setParams({
                "lst_StuFeeDeatils": stuFees,
                "PartialAmount":payamount,
                "feeType":feeType            
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    if(response.getReturnValue() != undefined)
                    {
                        if(response.getReturnValue().statusCode == 200){
                            window.open(response.getReturnValue().short_url,"_self");
                        }
                        else {                        
                            helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                            component.set("v.Spinner", false);
                        }
                    }
                }
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }  
            });
            $A.enqueueAction(action);   
        },
    billDeskGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType,RecId) 
        {        
            console.log('test PayNow 3.0 - ');
            console.log('StuFeePaymentId===>',RecId);
            component.set("v.ModelSpinner", true); 
            
            console.log('test PayNow 3.0 - ');
            
            var action = component.get("c.BillDeskPayGenratePaymentLink");
            //alert('=====>>>'+JSON.stringify(stuFees));
            action.setParams({
                "lst_StuFeeDeatils": stuFees,
                "PartialAmount":payamount,
                "feeType":feeType,
                "stuFeePayRecId":RecId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('test PayNow 3.1.0 - ',state);
                if (state === "SUCCESS") 
                {
                    console.log('test PayNow 3.1 - ');
                    if(response.getReturnValue() != undefined)
                    {
                        console.log('test PayNow 3.2 -+ ');
                        if(response.getReturnValue().statusCode == 200){
                            console.log(response.getReturnValue().short_url+'377');
                            const redirectUrl = response.getReturnValue().short_url.replace(/\|/g, '%7C');
                            console.log("redirect Url:"+redirectUrl);
                            window.open(redirectUrl,"_self");
                        }
                        else {   
                            console.log('test PayNow 3.3 - ');
                            helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                            component.set("v.ModelSpinner", false);
                        }
                    }
                }
                else{
                    component.set("v.Spinner", false);
                    console.log('response');
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }  
            });
            $A.enqueueAction(action);   
        },
            EasyPayGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
        {        
            component.set("v.ModelSpinner", true); 
            var action = component.get("c.easypayGenratePaymentLink");
            //alert('=====>>>'+JSON.stringify(stuFees));
            action.setParams({
                "lst_StuFeeDeatils": stuFees,
                "PartialAmount":payamount,
                "feeType":feeType
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    if(response.getReturnValue() != undefined)
                    {
                        if(response.getReturnValue().statusCode == 200){
                            window.open(response.getReturnValue().short_url,"_self");
                        }
                        else {                        
                            helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                            component.set("v.ModelSpinner", false);
                        }
                    }
                }
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }  
            });
            $A.enqueueAction(action);   
        },   
            paytmGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
        {        
            component.set("v.ModelSpinner", true); 
            var action = component.get("c.PaytmGenratePaymentLink");
            //alert('=====>>>'+JSON.stringify(stuFees));
            action.setParams({
                "lst_StuFeeDeatils": stuFees,
                "PartialAmount":payamount,
                "feeType":feeType
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                // alert('+++++++++'+state);
                if (state === "SUCCESS") 
                {
                    
                    if(response.getReturnValue() != undefined)
                    {
                        //  alert('+++++++++'+response.getReturnValue().statusCode);
                        if(response.getReturnValue().statusCode == 200){
                            var retVal = response.getReturnValue();
                            // var payUrl = 'https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?mid='+retVal.id+'&orderId='+retVal.status;
                            component.set("v.paytmUrl", retVal.short_url);
                            component.set("v.paytmResponse", retVal);
                            component.set("v.paytmConfirm", true);
                            component.set("v.openModel", false);
                            component.set("v.openMultiModel", false);
                            //  alert('+++++++++'+JSON.stringify(retVal));
                            //  component.find("paymentForm").getElement().submit();
                            //  this.paytmRedirect(component, event, helper);
                        }
                        else {                        
                            helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                            component.set("v.ModelSpinner", false);
                        }
                    }
                }
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }  
            });
            $A.enqueueAction(action);   
        },
       
    multiSelectOnChange : function(component, event, helper,isCheck,indxVal) 
        {
            console.log('coming');
            var lstFeePending = component.get("v.lstPendingFee");
            var recId = lstFeePending[indxVal].ObjStuFeeDeatils.Id;
            var action = component.get("c.multiRecordCheckLateFee");
            action.setParams({
                "feeId": recId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    var retVal = response.getReturnValue();
                    if(retVal.length == 1){                    
                        var selRecList =[];
                        for(var i = 0; i < lstFeePending.length; i++)
                        {
                            if(lstFeePending[i].ObjStuFeeDeatils.Id == retVal[0]){
                                if(isCheck){
                                    lstFeePending[i].isChecked = true;
                                }
                                else{
                                    lstFeePending[i].isChecked = false;
                                }
                            }
                            selRecList.push(lstFeePending[i]);
                        }    
                        component.set("v.lstPendingFee",selRecList);
                    } 
                } 
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }  
            });
            $A.enqueueAction(action);
        },    
        showToast : function(component, mode, title, message, type)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": mode,
                "title": title,
                "message": message,
                "type": type,
                "duration":'2'
            });
            toastEvent.fire();
        },
         
         DisplayWarning : function(component, mode, title, message, type)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": mode,
                "title": title,
                "message": message,
                "type": type,
                "duration":'2'
            });
            toastEvent.fire();
            var url = window.location.href;
            window.location.href = url;
        }
    
    })