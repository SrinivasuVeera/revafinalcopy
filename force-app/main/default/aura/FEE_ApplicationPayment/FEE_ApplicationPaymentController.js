({
    doInit : function(component, event, helper) 
    {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);        
        helper.doInitHelper(component, event, helper);	
    },
    
   

    closeModel: function(component) 
    {      
        component.set("v.openModel", false);
        component.set( "v.paytmConfirm", false);
    },
    onPayNow : function(component, event, helper)
    {
        component.set("v.Spinner", true); 
        var index = event.getSource().get("v.name");
        var selectLstFee =[];
        var lstFeePending = component.get("v.lstPendingFee");
        selectLstFee.push(lstFeePending);
        
        var selid = lstFeePending[index].ObjStuFeeDeatils.Id;
        var seldate =lstFeePending[index].ObjStuFeeDeatils.Due_Date__c;
        var selContactid =lstFeePending[index].ObjStuFeeDeatils.Contact__c;
        component.set("v.SelectedRecId",selid);
        component.set("v.SelectedDueDate",seldate);
        component.set("v.SelectedConId",selContactid);
        helper.onPayNowHlpr(component, event, helper);
    },
    onPayPAFNow : function(component, event, helper)
    {
        component.set("v.Spinner", true); 
        // var index = event.getSource().get("v.name");
        // var selectLstFee =[];
        // var lstFeePending = component.get("v.lstPendingFee");
        // selectLstFee.push(lstFeePending);
        
        // var selid = lstFeePending[index].ObjStuFeeDeatils.Id;
        // var seldate =lstFeePending[index].ObjStuFeeDeatils.Due_Date__c;
        // var selContactid =lstFeePending[index].ObjStuFeeDeatils.Contact__c;
        // component.set("v.SelectedRecId",selid);
        // component.set("v.SelectedDueDate",seldate);
        // component.set("v.SelectedConId",selContactid);
        helper.onPayPAFNowHlpr(component, event, helper);
    },
    AfterPaynow : function(component, event, helper)
    {
        console.log('inside after pay now');
        component.set("v.ModelSpinner", true);
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var paymap = component.get("v.PaymentMap");
        // eslint-disable-next-line guard-for-in
        console.log('paymap '+paymap);
        for (var key in paymap) 
        {            
            if(paymap[key].key === 'RazorPay')
                mapRazorpay = paymap[key].key;
            if(paymap[key].key === 'PayTM')
                mapPaytm = paymap[key].key;
            if(paymap[key].key === 'EazyPay')
                mapEasypay = paymap[key].key;            
            if(paymap[key].key === 'BillDesk')
                mapBilldesk = paymap[key].key;
        }
        var rate_value;
        
        if(mapRazorpay === 'RazorPay')
        { 
            if(document.getElementById('radio-66').checked) 
            {
                rate_value = document.getElementById('radio-66').value;
            }
        }
        if(mapPaytm === 'PayTM')
        { 
            if(document.getElementById('radio-67').checked) {
                rate_value = document.getElementById('radio-67').value;
            }
        }
        if(mapEasypay === 'EazyPay')
        { 
            if(document.getElementById('radio-68').checked) {
                rate_value = document.getElementById('radio-68').value;
            }
        }
        if(mapBilldesk === 'BillDesk')
        {        
            if (document.getElementById('radio-65').checked) {
                rate_value = document.getElementById('radio-65').value;
            }
        }
        var EnteredAmount = component.get("v.EnteredAmount");
        var TotalPayamount ;        
        if(rate_value === null || rate_value==='' || rate_value ==='undefined')
        {
            helper.showToast(component,'dismissible','Failed','Please Select Paymnet Gateway','error');
            component.set("v.ModelSpinner", false);             
        }
        else
        {
            var feepayment = component.get("v.lstStuFeePayment");
            for(var i=0;i<feepayment.length;i++)
            {
                TotalPayamount = feepayment[i].Amount_Pending__c;
                if(EnteredAmount >feepayment[i].Amount_Pending__c)
                {
                    helper.showToast(component,'dismissible','Failed','Please Enter Correct Amount','error'); 
                    component.set("v.ModelSpinner", false); 
                }
            }
            if(rate_value === 'RazorPay')
            {
                if(EnteredAmount !== null || EnteredAmount !== '')
                {                    
                    helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                    component.set("v.ModelSpinner", false);
                }
                else
                {
                    helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                    component.set("v.ModelSpinner", false);
                }
            }
            
            if(rate_value === 'BillDesk')
            {console.log('ss'+rate_value);
                if(EnteredAmount !== null || EnteredAmount !== '')
                {                    
                    helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                    component.set("v.ModelSpinner", false);
                }
                else
                {                     
                    helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                    component.set("v.ModelSpinner", false);
                }
            } 
            if(rate_value === 'EazyPay')
                {
                    
                    if(EnteredAmount != null || EnteredAmount !== '')
                    { 
                        
                        helper.EasyPayGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                        component.set("v.ModelSpinner", false);

                    }
                    else
                    {  
                        
                        helper.EasyPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                        component.set("v.ModelSpinner", false);
                        
                    }
                }
            
            if(rate_value === 'PayTM')
                {
                    
                    if(EnteredAmount !== null || EnteredAmount !== '')
                    {     
                        helper.paytmGeneratePaymentLink(component, event, helper,feepayment,EnteredAmount,'single');
                      
                        component.set("v.ModelSpinner", false);
                       component.set("v.DisablePayNow",false);
                    }
                    else
                    {        
                        helper.paytmGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                        component.set("v.ModelSpinner", false);
                       component.set("v.DisablePayNow",false);
                    }
                        
                    
                }
        }
    },

    AfterPAFPaynow : function(component, event, helper)
    {
        console.log('inside AfterPAFPaynow --> 183');
        component.set("v.ModelSpinner", true);
        var mapBilldesk;
        var mapRazorpay;
        var mapEasypay;
        var mapPaytm;
        var paymap = component.get("v.PaymentMap");
        // eslint-disable-next-line guard-for-in
        for (var key in paymap) 
        {            
            if(paymap[key].key === 'RazorPay')
                mapRazorpay = paymap[key].key;
            if(paymap[key].key === 'PayTM')
                mapPaytm = paymap[key].key;
            if(paymap[key].key === 'EazyPay')
                mapEasypay = paymap[key].key;            
            if(paymap[key].key === 'BillDesk')
                mapBilldesk = paymap[key].key;
        }
        var rate_value;
        
        if(mapRazorpay === 'RazorPay')
        { 
            if(document.getElementById('radio-66PAF').checked) 
            {
                rate_value = document.getElementById('radio-66PAF').value;
            }
        }
        if(mapPaytm === 'PayTM')
        { 
            if(document.getElementById('radio-67PAF').checked) {
                rate_value = document.getElementById('radio-67PAF').value;
                console.log('inside setting value rate_value --> 215 '+rate_value);
            }
        }
        if(mapEasypay === 'EazyPay')
        { 
            if(document.getElementById('radio-68PAF').checked) {
                rate_value = document.getElementById('radio-68PAF').value;
            }
        }
        if(mapBilldesk === 'BillDesk')
        {        
            if (document.getElementById('radio-65PAF').checked) {
                rate_value = document.getElementById('radio-65PAF').value;
            }
        }
        var EnteredAmount = component.get("v.EnteredAmount");
        var TotalPayamount ;        
        if(rate_value === null || rate_value==='' || rate_value ==='undefined')
        {
            helper.showToast(component,'dismissible','Failed','Please Select Paymnet Gateway','error');
            component.set("v.ModelSpinner", false);             
        }
        else
        {
            var feepayment = component.get("v.lstStuFeePayment");
            // for(var i=0;i<feepayment.length;i++)
            // {
            //     TotalPayamount = feepayment[i].Amount_Pending__c;
            //     if(EnteredAmount >feepayment[i].Amount_Pending__c)
            //     {
            //         helper.showToast(component,'dismissible','Failed','Please Enter Correct Amount','error'); 
            //         component.set("v.ModelSpinner", false); 
            //     }
            // }
            if(rate_value === 'RazorPay')
            {
                // if(EnteredAmount !== null || EnteredAmount !== '')
                // { 
                    console.log('inside 253');                   
                    helper.rezorPayGeneratePAFPaymentLink(component, event, helper);//,feepayment,EnteredAmount,'single'
                    component.set("v.ModelSpinner", false);
                // }
                // else
                // {
                //     helper.rezorPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                //     component.set("v.ModelSpinner", false);
                // }
            }
            
            if(rate_value === 'BillDesk')
            {console.log('ss'+rate_value);
                // if(EnteredAmount !== null || EnteredAmount !== '')
                // {                    
                    helper.billDeskGeneratePAFPaymentLink(component, event, helper);//,feepayment,EnteredAmount,'single'
                    component.set("v.ModelSpinner", false);
                // }
                // else
                // {                     
                //     helper.billDeskGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');
                //     component.set("v.ModelSpinner", false);
                // }
            } 
            if(rate_value === 'EazyPay')
                {
                    
                    // if(EnteredAmount != null || EnteredAmount !== '')
                    // { 
                        
                        helper.EasyPayGeneratePAFPaymentLink(component, event, helper);//,feepayment,EnteredAmount,'single'
                        component.set("v.ModelSpinner", false);

                    // }
                    // else
                    // {  
                        
                    //     helper.EasyPayGeneratePaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                    //     component.set("v.ModelSpinner", false);
                        
                    // }
                }
            
            if(rate_value === 'PayTM')
                {
                    
                    // if(EnteredAmount !== null || EnteredAmount !== '')
                    // {     
                        console.log('inside 300');
                        helper.paytmGeneratePAFPaymentLink(component, event, helper); //,feepayment,EnteredAmount,'single'
                      
                        component.set("v.ModelSpinner", false);
                       component.set("v.DisablePayNow",false);
                    // }
                    // else
                    // {        
                    //     helper.paytmGeneratePAFPaymentLink(component, event, helper,feepayment,TotalPayamount,'single');  
                    //     component.set("v.ModelSpinner", false);
                    //    component.set("v.DisablePayNow",false);
                    // }
                        
                    
                }
        }
    },
    paytmRedirect : function(component) {
        component.find("paymentForm").getElement().submit();
    },
     
   
    
})