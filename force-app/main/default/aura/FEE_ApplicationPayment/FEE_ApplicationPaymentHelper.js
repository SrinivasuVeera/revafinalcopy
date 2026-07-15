({
    
    getURLParameterValue: function() {
    
        var queryString = window.location.search.substring(1);
        // console.log('js file ');
        // console.log(queryString);
        var paramValue = {};
        queryString.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        // console.log('js file ');
        // console.log(paramValue);
        return paramValue;
      },
      
    
    doInitHelper : function(component, event, helper) 
    {
        //var userId = $A.get("$SObjectType.CurrentUser.Id");
        //alert(userId);

        var urlParams = helper.getURLParameterValue();
        var contactId = urlParams.contactId;
        var isPAF = urlParams.isPAF ? true : false;
        var stupayId = urlParams.stupayid;
        
        //AddedbyRajashekar20thsept2024
        var isFromGuest = urlParams.isGuest;
        if(isFromGuest == "true"){
            component.set("v.isGuest",true);
            console.log('booleanval==> ',component.get("v.isGuest"));
        }
        //endshere
       
        //AddedbyRajashekar9thOct2024
        var ispenaltyfee = urlParams.isPenaltyFee;
        if(ispenaltyfee == "true"){
            component.set("v.isPenaltyFee",true);
            console.log('booleanval==> ',component.get("v.isPenaltyFee"));
        }
        //endshere
        
        console.log('inside doinit helper isPAF '+ isPAF);
        if(contactId!==undefined)
        {
        component.set("v.FlowConId",contactId);
        }
        if(stupayId!==undefined)
        {
        component.set("v.StuPayId",stupayId);
        }
        if(isPAF == true){
            component.set("v.isAdmissionFee", false);  
            component.set("v.isPAF", true);    
        } else {
            component.set("v.isAdmissionFee", true);  
            component.set("v.isPAF", false); 
        }
        component.set("v.Spinner", true);
        var varFlowConId =  component.get("v.FlowConId");
        var varStuPayId =  component.get("v.StuPayId");

        if(varFlowConId !== "")
        {
            var action = component.get("c.displayApplicantFeeRecords");
            
            action.setParams({
            "flowConId": varFlowConId,
            "isPAF" : isPAF,
            "stupayId" : varStuPayId
           
        });
            action.setCallback(this, function(response) {
               
            var state = response.getState();
               
            if (state === "SUCCESS") 
            {
                console.log('inside if');    
                if(response.getReturnValue() !== undefined)
                {
                   
                    var retVal = response.getReturnValue();
                    if(retVal.isPAF == true){
                        component.set("v.DirectOnlineFeePayment",retVal.DirectLinkPayment);
                    } else {
                        component.set("v.lstPendingFee",retVal.lst_CheckboxWrap);
                        component.set("v.isPUCContact", retVal.isPUCContact);
                        console.log('Contact PUC check retrieved Raj==>',retVal.isPUCContact);
                        console.log('Stu fee recs retrieved Raj==>',retVal.lst_CheckboxWrap);
                        component.set("v.lstPaidFee",retVal.lst_StuPaidDetails);
                        component.set("v.lstStuPaymentFee",retVal.lst_StuPaymentDetails);
                        component.set("v.totalRecordsCount",retVal.lst_CheckboxWrap.length);
                        component.set("v.Studentname",retVal.objStuname);
                        component.set("v.AppNumber",retVal.objAppNumber);
                        component.set("v.SrnNumber",retVal.objSrnNumber);
                    }
                    component.set("v.Spinner", false); 
                }
            }
            else{             
                console.log('inside else');    
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
            
        });        
            $A.enqueueAction(action);
        }    
        	
    },
    
    onPayNowHlpr: function(component)
    {
        component.set("v.Spinner", true);
        var selId =  component.get("v.SelectedRecId");
        var varFlowConId =  component.get("v.FlowConId");
        if(varFlowConId !== undefined)
        {
            var action = component.get("c.fetchApplicantFeeRecords");
           
            action.setParams({
            "strSelId": selId,
            "flowConId": varFlowConId
            });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() !== undefined)
                {
                    var mapPayment = [];
                    var result = response.getReturnValue().map_PaymentGateway;
                    // eslint-disable-next-line guard-for-in
                    for(var key in result){
                        mapPayment.push({key: key, value: result[key]});
                    }    
                    component.set("v.openModel",true);
                    component.set("v.PaymentMap", mapPayment);
                    component.set("v.lstStuFeePayment",response.getReturnValue().lst_StuFeePayment);
                    component.set("v.feetypestudent",response.getReturnValue().StuFeeType);
                    component.set("v.InstallMentNo",response.getReturnValue().NoOfInstallments);
                    component.set("v.EnteredAmount",response.getReturnValue().PendingAmount); 
                    component.set("v.Spinner", false); 
                }
            }
            else {                 
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
        });
			$A.enqueueAction(action);
        }
        
    },
   
    onPayPAFNowHlpr: function(component)
    {
        component.set("v.Spinner", true);
        // var selId =  component.get("v.SelectedRecId");
        var varFlowConId =  component.get("v.FlowConId");
        if(varFlowConId !== undefined)
        {
            var action = component.get("c.fetchProvisionalAdmissionFeeRecords");
           
            action.setParams({
            // "strSelId": selId,
            "flowConId": varFlowConId
            });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                // console.log('inside if 145'); 
                if(response.getReturnValue() !== undefined)
                {
                    var mapPayment = [];
                    var result = response.getReturnValue().map_PaymentGateway;
                    // eslint-disable-next-line guard-for-in
                    // console.log('result is -->');
                    // console.log(result);
                    for(var key in result){
                        mapPayment.push({key: key, value: result[key]});
                    }    
                    component.set("v.openModel",true);
                    component.set("v.PaymentMap", mapPayment);
                    component.set("v.lstStuFeePayment",response.getReturnValue().lst_StuFeePayment);
                    // component.set("v.feetypestudent",response.getReturnValue().StuFeeType);
                    // component.set("v.InstallMentNo",response.getReturnValue().NoOfInstallments);
                    // component.set("v.EnteredAmount",response.getReturnValue().PendingAmount); 
                    component.set("v.Spinner", false); 
                }
            }
            else {    
                // console.log('inside if');              
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
        });
			$A.enqueueAction(action);
        }
        
    },
    rezorPayGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.Spinner", true);
        var varFlowConId =  component.get("v.FlowConId");
        if(varFlowConId !== undefined)
        {
        var action = component.get("c.razorPayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType,
            "flowConId": varFlowConId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {	console.log('111');
                if(response.getReturnValue() !== undefined)
                {console.log('222');
                    if(response.getReturnValue().statusCode === 200){
                       console.log('inside status');
                        window.open(response.getReturnValue().short_url,"_self");
                    }
                    else {   
                        console.log('else');
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
        }	 
    },
    
    billDeskGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.ModelSpinner", true); 
        var action = component.get("c.BillDeskPayGenratePaymentLink");
        console.log('xx'+action);
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {	console.log('cc'+state);
                if(response.getReturnValue() !== undefined)
                {console.log('cc'+response.getReturnValue().statusCode);
                    if(response.getReturnValue().statusCode === 200){
                        
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

    billDeskGeneratePAFPaymentLink : function(component, event, helper) //,stuFees,payamount,feeType 
    {      
        console.log('inside billDeskGeneratePAFPaymentLink calling');  

        component.set("v.ModelSpinner", true); 
        var varFlowConId =  component.get("v.FlowConId");
        var varStuPayId =  component.get("v.StuPayId");
        console.log('varFlowConId id '+varFlowConId);
        console.log('stupay id '+varStuPayId);

        var action = component.get("c.BillDeskPayGenratePAFPaymentLink");
        console.log('xx'+action);
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            // "lst_StuFeeDeatils": stuFees,
            // "PartialAmount":payamount,
            // "feeType":feeType
            "flowConId": varFlowConId,
            "stuPayId" : varStuPayId
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {	console.log('cc'+state);
             	console.log('RETURN VALUE=====' + JSON.stringify(response.getReturnValue()))
                if(response.getReturnValue() !== undefined)
                {console.log('cc'+response.getReturnValue().statusCode);
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

    EasyPayGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {        
        component.set("v.ModelSpinner", true); 
        var varFlowConId =  component.get("v.FlowConId");
        if(varFlowConId !== undefined)
        {
        var action = component.get("c.easypayGenratePaymentLink");
       // alert('=====>>>'+JSON.stringify(stuFees));
     
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType,
            "flowConId":varFlowConId
        });
           
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() !== undefined)
                {
                    if(response.getReturnValue().statusCode === 200){
                        window.open(response.getReturnValue().short_url,"_self");
                       //window.open("https://www.google.com/","_self");
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
        }        	 
    }, 

    EasyPayGeneratePAFPaymentLink : function(component, event, helper) //,stuFees,payamount,feeType
    {        
        component.set("v.ModelSpinner", true); 
        var varFlowConId =  component.get("v.FlowConId");
        if(varFlowConId !== undefined)
        {
        var action = component.get("c.easypayGenratePAFPaymentLink");
       // alert('=====>>>'+JSON.stringify(stuFees));
     
        action.setParams({
            // "lst_StuFeeDeatils": stuFees,
            // "PartialAmount":payamount,
            // "feeType":feeType,
            "flowConId":varFlowConId
        });
           
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() !== undefined)
                {
                    if(response.getReturnValue().statusCode === 200){
                        window.open(response.getReturnValue().short_url,"_self");
                       //window.open("https://www.google.com/","_self");
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
        }        	 
    }, 

        paytmGeneratePaymentLink : function(component, event, helper,stuFees,payamount,feeType) 
    {   
       
        component.set("v.ModelSpinner", true); 
       
        //var varFlowConId =  component.get("v.FlowConId");
      //console.log('ooooo'+varFlowConId);
      
        //if(varFlowConId != undefined)
        //{
             
        //alert('=====>>>'+JSON.stringify(stuFees));
        var action = component.get("c.PaytmGeneratePaymentLink");
      	// alert('=====>>>'+JSON.stringify(stuFees));
            
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount":payamount,
            "feeType":feeType,
           // "flowConId": varFlowConId
            
        });
            
            
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state == "SUCCESS") 
            {console.log('cc'+state);
                if(response.getReturnValue() != undefined)
                { console.log('cc'+response.getReturnValue().statusCode);
                    if(response.getReturnValue().statusCode == 200){
                        
                        var retVal = response.getReturnValue();
                        
                       // var payUrl = 'https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?mid='+retVal.id+'&orderId='+retVal.status;
                        component.set("v.paytmUrl", retVal.short_url);
                        
                        component.set("v.paytmResponse", retVal);
                        
                        component.set("v.paytmConfirm", true);
                        
                        component.set("v.openModel", false);
                        
                      //  component.set("v.openMultiModel", false);
                        
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
       // }
        $A.enqueueAction(action);	 
    }, 

    paytmGeneratePAFPaymentLink : function(component, event, helper)  //,stuFees,payamount,feeType
    {   
       
        component.set("v.ModelSpinner", true); 
       
        var varFlowConId =  component.get("v.FlowConId");
        var varStuPayId =  component.get("v.StuPayId");
        console.log('stupay id '+varStuPayId);
      //console.log('ooooo'+varFlowConId);
      
        if(varFlowConId != undefined)
        {
             
        //alert('=====>>>'+JSON.stringify(stuFees));
        console.log('before calling paytmGeneratePAFPaymentLink --> 368 '+varFlowConId);
        var action = component.get("c.paytmGeneratePAFPaymentLink");
      	// alert('=====>>>'+JSON.stringify(stuFees));
            
        action.setParams({
            // "lst_StuFeeDeatils": stuFees,
            // "PartialAmount":payamount,
            // "feeType":feeType,
           "flowConId": varFlowConId,
           "stuPayId" : varStuPayId
            
        });
            
        console.log('LINE NUMBER 380');  
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('after calling paytmGeneratePAFPaymentLink setCallback --> 383');
            if (state == "SUCCESS") 
            {
                console.log('inside if line 384'+state);
                if(response.getReturnValue() != undefined)
                { 
                    console.log('cc'+response.getReturnValue().statusCode);
                    console.log(response);
                    if(response.getReturnValue().statusCode == 200){
                        
                        var retVal = response.getReturnValue();
                        
                       // var payUrl = 'https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?mid='+retVal.id+'&orderId='+retVal.status;
                        component.set("v.paytmUrl", retVal.short_url);
                        
                        component.set("v.paytmResponse", retVal);
                        
                        component.set("v.paytmConfirm", true);
                        
                        component.set("v.openModel", false);
                        
                      //  component.set("v.openMultiModel", false);
                        
                    }
                    else {   
                        
                        helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else{
                console.log('inside else line 412'+state);
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
            $A.enqueueAction(action);
       }
        	 
    }, 

    rezorPayGeneratePAFPaymentLink : function(component, event, helper)  //,stuFees,payamount,feeType
    {        
        component.set("v.Spinner", true);
        var varFlowConId =  component.get("v.FlowConId");
        var varStuPayId =  component.get("v.StuPayId");
        console.log('before calling razorPayGenratePAFPaymentLink --> 428 '+varFlowConId);
        if(varFlowConId !== undefined)
        {
        var action = component.get("c.razorPayGenratePAFPaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            // "lst_StuFeeDeatils": stuFees,
            // "PartialAmount":payamount,
            // "feeType":feeType,
            "flowConId": varFlowConId,
            "stuPayId" : varStuPayId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {	console.log('111');
                if(response.getReturnValue() !== undefined)
                {console.log('222');
                    if(response.getReturnValue().statusCode === 200){
                       console.log('inside status');
                        window.open(response.getReturnValue().short_url,"_self");
                    }
                    else {   
                        console.log('else');
                        helper.showToast(component,'dismissible','Failed','Payment Link Generation Failed','error');
                        component.set("v.Spinner", false);
                    }
                }
            }
            else{
                console.log('inside else 458');
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
           $A.enqueueAction(action);
        }       	 
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
    }
})