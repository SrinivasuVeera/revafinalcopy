/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 05-29-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
({
    // doInitHelper : function(component, event, helper) 
    // {
    //     component.set("v.Spinner", true); 
    //     var action = component.get("c.displayApplicantFeeRecords");
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") 
    //         {
    //             if(response.getReturnValue() != undefined)
    //             {
    //                 var retVal = response.getReturnValue();
    //                 console.log("11",retVal);
    //                 component.set("v.lstPendingFee",retVal.lst_CheckboxWrap);
    //                 //console.log('111 Test',v.lstPendingFee);
    //                 component.set("v.lstPaidFee",retVal.lst_StuPaidDetails);
    //                 component.set("v.lstStuPaymentFee",retVal.lst_StuPaymentDetails);
    //                 component.set("v.totalRecordsCount",retVal.lst_CheckboxWrap.length);
    //                 component.set("v.Studentname",retVal.objStuname);
    //                 component.set("v.AppNumber",retVal.objAppNumber);
    //                 component.set("v.lstProvisionalAdmissionFee",retVal.ProvisionalAdmissionFee);
    //                 component.set("v.SrnNumber",retVal.objSrnNumber);
    //                 component.set("v.Spinner", false); 
    //                 component.set("v.totalStuAmount",retVal.TotalAmount);
    //                 console.log('1111',retVal.TotalAmount)
    //                 component.set("v.totalStuPenAmount",retVal.TotalPendingAmount);
    //                 component.set("v.totalStuPaidAmount",retVal.TotalPaidAmount);
    //             }

    //         }
    //         else{                 
    //             component.set("v.Spinner", false); 
    //             this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
    //         }  

    //     });       
    //     $A.enqueueAction(action);	
    // },
    VlaidationHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var selid = component.get("v.SelectedRecId");
        var seldate = component.get("v.SelectedDueDate");
        var SelectedConId = component.get("v.SelectedConId");
        if (seldate != undefined) {
            var action = component.get("c.ValidationDate");
            action.setParams({
                "strSelid": selid,
                "selduedate": seldate,
                "Conid": SelectedConId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue() != undefined) {
                        if (response.getReturnValue().DateError != null) {
                            var retVal = response.getReturnValue().DateError;
                            this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                        }
                        else {
                            helper.onPayNowHlpr(component, event, helper);
                        }
                    }
                    component.set("v.Spinner", false);
                }
                else {
                    component.set("v.Spinner", false);
                    this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
                }
            });
            $A.enqueueAction(action);
        }
        else {
            helper.onPayNowHlpr(component, event, helper);
        }
    },
    onPayNowHlpr: function (component, event, helper) {
        var selid = component.get("v.SelectedRecId");
        var action = component.get("c.fetchApplicationFeeRecords");
        action.setParams({
            "strSelid": selid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var mapPayment = [];
                    var result = response.getReturnValue().map_PaymentGateway;
                    for (var key in result) {
                        mapPayment.push({ key: key, value: result[key] });
                    }
                    component.set("v.openModel", true);
                    component.set("v.PaymentMap", mapPayment);
                    component.set("v.lstStuFeePayment", response.getReturnValue().lst_StuFeePayment);
                    component.set("v.feetypestudent", response.getReturnValue().StuFeeType);
                    component.set("v.InstallMentNo", response.getReturnValue().NoOfInstallments);
                    component.set("v.EnteredAmount", response.getReturnValue().PendingAmount);
                    var amount = response.getReturnValue().PendingAmount;
					this.fetchGQEmiAmount(component, amount);
                    component.set("v.Spinner", false);
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    // VlaidationMultiHlpr: function(component, event, helper)
    // {
    //     component.set("v.Spinner", true); 
    //     var totalRecamount =0;            
    //     var selcRecords = component.get("v.MultiSelectList");
    //     var selRecList =[];
    //     for(var i=0;i<selcRecords.length;i++)
    //     {
    //         selRecList.push(selcRecords[i].ObjStuFeeDeatils);
    //         if(selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c != null)
    //         {
    //             console.log('amount pending=> ', selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c);
    //             totalRecamount = totalRecamount + selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c ;
    //             console.log('amount pending1 => ', totalRecamount);
    //         }
    //     }
    //     component.set("v.totalAmount",totalRecamount);            
    //     component.set("v.SelectedRecLst",selRecList);
    //     var action = component.get("c.ValidateMultiPayments");
    //     action.setParams({
    //         "lst_StuIds": selRecList
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") 
    //         {
    //             if(response.getReturnValue() != undefined)
    //             {
    //                 if(response.getReturnValue().DateError != null)
    //                 {
    //                     var retVal = response.getReturnValue().DateError;
    //                     this.showToast(component,'dismissible','Failed',retVal,'error');
    //                 }
    //                 if(response.getReturnValue().DateError == null)
    //                 {
    //                     helper.MultipayHlpr(component, event, helper);                        
    //                 }    
    //             }
    //             component.set("v.Spinner", false);  
    //         }
    //         else {                 
    //             component.set("v.Spinner", false); 
    //             this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
    //         }
    //     });
    //     $A.enqueueAction(action);        
    // },
    MultipayHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var totalRecamount = 0;
        var selcRecords = component.get("v.MultiSelectList");//MultiSelectList //lstPendingFee
        var selRecList = [];
        for (var i = 0; i < selcRecords.length; i++) {

            if (selcRecords[i].isChecked) {
                selRecList.push(selcRecords[i].ObjStuFeeDeatils);
                if (selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c != null) {
                    totalRecamount = totalRecamount + selcRecords[i].ObjStuFeeDeatils.Amount_Pending__c;
                }
            }

        }
        component.set("v.totalAmount", totalRecamount);
        component.set("v.SelectedRecLst", selRecList);
        var action = component.get("c.MultiStduentFeeRecords");
        action.setParams({
            "lst_StuIds": selRecList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var mapPayment = [];
                    var result = response.getReturnValue().map_PaymentGateway;
                    for (var key in result) {
                        mapPayment.push({ key: key, value: result[key] });
                    }
                    component.set("v.openMultiModel", true);
                    component.set("v.MultiPaymentMap", mapPayment);
                    component.set("v.lstMultipleRecords", response.getReturnValue().lst_StuFeePayment);
                    component.set("v.ErrMessage", response.getReturnValue().Errmsg);
                    component.set("v.Spinner", false);
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    razorpayGeneratePaymentLink: function (component, event, helper, stuFees, payamount, feeType) {
        component.set("v.Spinner", true);
        var action = component.get("c.razorpayGeneratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount": payamount,
            "feeType": feeType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    if (response.getReturnValue().statusCode == 200) {
                        window.open(response.getReturnValue().short_url, "_self");
                    }
                    else {
                        helper.showToast(component, 'dismissible', 'Failed', 'Payment Link Generation Failed', 'error');
                        component.set("v.Spinner", false);
                    }
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    billDeskGeneratePaymentLink: function (component, event, helper, stuFees, payamount, feeType) {
        component.set("v.ModelSpinner", true);
        var action = component.get("c.BillDeskPayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount": payamount,
            "feeType": feeType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response ', response.getReturnValue());
                console.log('status ', response.getReturnValue().statusCode);

                if (response.getReturnValue() != undefined) {
                    console.log('response ', response.getReturnValue());
                    console.log('status ', response.getReturnValue().statusCode);

                    if (response.getReturnValue().statusCode == 200) {
                        window.open(response.getReturnValue().short_url, "_self");
                    }
                    else {
                        helper.showToast(component, 'dismissible', 'Failed', 'Payment Link Generation Failed', 'error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    grayQuestGeneratePaymentLink : function(component, event, helper, stuFees, payamount, feeType) {  
        console.log('@@@Calling GQ helper with records');
    component.set("v.ModelSpinner", true); 

    // Convert Proxy records to clean JSON objects
    var cleanFees = JSON.parse(JSON.stringify(stuFees));

    var action = component.get("c.grayQuestGenerateLink"); 
    action.setParams({
        "lst_StuPaymentDetails": cleanFees,
        "PartialAmount": payamount,
        "feeType": feeType            
    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var retVal = response.getReturnValue();
            if(retVal && retVal.data && retVal.data.redirection_url){
                window.open(retVal.data.redirection_url, "_self");
            } else {                        
                this.showToast(component, 'dismissible', 'Failed', 'Redirection URL not found', 'error');
                component.set("v.ModelSpinner", false);
            }
        } else {
            var message = response.getError()[0].message;
            this.showToast(component, 'dismissible', 'Failed', message, 'error');
            component.set("v.ModelSpinner", false);
        }  
    });
    $A.enqueueAction(action);   
},
    paytmGeneratePaymentLink: function (component, event, helper, stuFees, payamount, feeType) {
        //  debugger;

        component.set("v.ModelSpinner", true);
        //    debugger;
        // var varFlowConId =  component.get("v.FlowConId");
        //  console.log('ooooo'+varFlowConId);

        //  if(varFlowConId !== undefined)
        //   {
        //    debugger;  
        //alert('=====>>>'+JSON.stringify(stuFees));
        var action = component.get("c.PaytmGeneratePaymentLink");
        // console.log('ttttttttt'+action);
        //alert('=====>>>'+JSON.stringify(stuFees));

        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount": payamount,
            "feeType": feeType,
            //"flowConId": varFlowConId

        });


        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                // console.log('hhhhhhh'+state);
                if (response.getReturnValue() !== undefined) {
                    // console.log('mmmmmmmmmmm'+response.getReturnValue());
                    if (response.getReturnValue().statusCode === 200) {
                        // console.log('gggggggggg'+response.getReturnValue().statusCode);
                        var retVal = response.getReturnValue();
                        // console.log('aaaaaaaaa'+retVal);
                        // var payUrl = 'https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?mid='+retVal.id+'&orderId='+retVal.status;
                        component.set("v.paytmUrl", retVal.short_url);

                        component.set("v.paytmResponse", retVal);

                        component.set("v.paytmConfirm", true);

                        component.set("v.openModel", false);

                        component.set("v.openMultiModel", false);
                        console.log('inside line 323');
                    }
                    else {

                        helper.showToast(component, 'dismissible', 'Failed', 'Payment Link Generation Failed', 'error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else {

                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        //  }
        $A.enqueueAction(action);
    },
    EasyPayGeneratePaymentLink: function (component, event, helper, stuFees, payamount, feeType) {
        component.set("v.ModelSpinner", true);
        var action = component.get("c.easypayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "lst_StuFeeDeatils": stuFees,
            "PartialAmount": payamount,
            "feeType": feeType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    if (response.getReturnValue().statusCode == 200) {
                        window.open(response.getReturnValue().short_url, "_self");
                    }
                    else {
                        helper.showToast(component, 'dismissible', 'Failed', 'Payment Link Generation Failed', 'error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration": '2'
        });
        toastEvent.fire();
    },





    doInitHelper: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.displayUpdatedApplicantFeeRecords");
        // console.log('after setting spinner as true');
        action.setCallback(this, function (response) {
            var state = response.getState();
            // console.log('inside response');
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    // console.log('inside settting success response');
                    var retVal = response.getReturnValue();
                    component.set("v.stuFeePayPendingList", retVal.stuFeePayPendingWrap);
                    component.set("v.stuFeePayPaidList", retVal.stuFeePayPaidWrap);
                    component.set("v.lstProvisionalAdmissionFee", retVal.ProvisionalAdmissionFee);
                    component.set("v.Spinner", false);
                    // console.log("11",retVal);
                    // component.set("v.lstPendingFee", retVal.lst_CheckboxWrap);
                    component.set("v.lstPendingFee", retVal.lst_StuPaymentDetails);
                    console.log('Pending Student Fee Records Here', component.get("v.lstPendingFee"));
                    // component.set("v.lstPaidFee",retVal.lst_StuPaidDetails);
                    component.set("v.lstStuPaymentFee", retVal.lst_StuPaymentDetails);
                    component.set("v.lstStuPaymentPaidFee", retVal.stuPayPaidDetails);
                    component.set("v.totalRecordsCount", retVal.lst_StuPaymentDetails.length);
                    // component.set("v.Studentname",retVal.objStuname);
                    // component.set("v.AppNumber",retVal.objAppNumber);
                    // component.set("v.lstProvisionalAdmissionFee",retVal.ProvisionalAdmissionFee);
                    // component.set("v.SrnNumber",retVal.objSrnNumber);
                    // component.set("v.Spinner", false); 
                    // component.set("v.totalStuAmount",retVal.TotalAmount);
                    // console.log('1111',retVal.TotalAmount)
                    // component.set("v.totalStuPenAmount",retVal.TotalPendingAmount);
                    // component.set("v.totalStuPaidAmount",retVal.TotalPaidAmount);
                }

            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }

        });
        $A.enqueueAction(action);
    },

    VlaidationUpdatedMultiHlpr: function (component, event, helper) {
        // console.log('inside VlaidationUpdatedMultiHlpr');
        component.set("v.Spinner", true);
        var totalRecamount = 0;
        var selcRecords = component.get("v.lstPendingFee");//lstStuPaymentFee
        var SelectedConId = component.get("v.SelectedConId");
        // var selcRecords = component.get("v.MultiSelectList");
        console.log('inside VlaidationUpdatedMultiHlpr');
        console.log(selcRecords);
        console.log('SelectedConId helper 447' + SelectedConId);
        var selRecList = [];
        for (var i = 0; i < selcRecords.length; i++) {
            if (selcRecords[i].isChecked) {
                console.log('Is Checked', selcRecords[i].isChecked);
                selRecList.push(selcRecords[i]);
                // if(selcRecords[i].ObjStuFeePayDetails.Amount__c != null)
                // {
                totalRecamount = totalRecamount + selcRecords[i].Amount__c;
                // }
            }
            // selRecList.push(selcRecords[i].ObjStuFeePayDetails);
            // if(selcRecords[i].ObjStuFeePayDetails.Amount__c != null)
            // {
            // console.log('amount pending=> ', selcRecords[i].ObjStuFeePayDetails.Amount__c);
            //totalRecamount = totalRecamount + selcRecords[i].Amount__c;
            // console.log('amount pending1 => ', totalRecamount);
            // }
        }
        console.log('before assigning total amount ' + totalRecamount);
        component.set("v.totalAmount", totalRecamount);
        component.set("v.SelectedRecLst", selRecList);
        var action = component.get("c.ValidateUpdatedMultiPayments");
        action.setParams({
            "lst_StuIds": selRecList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('inside called ValidateUpdatedMultiPayments ' + state);
            // console.log(response);
            if (state === "SUCCESS") {
                // if(response.getReturnValue() != undefined)
                // {
                if (response.getReturnValue().DateError != null) {
                    var retVal = response.getReturnValue().DateError;
                    this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                }
                if (response.getReturnValue().DateError == null) {
                    console.log('inside before calling MultipayUpdatedHlpr');
                    helper.MultipayUpdatedHlpr(component, event, helper);
                }
                // }
                component.set("v.Spinner", false);
                console.log('inside 478');
            }
            else {
                component.set("v.Spinner", false);
                console.log('inside 481');
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    fetchGQEmiAmount : function(component, amount) {
        if(!amount || amount <= 0) return;
        
        var action = component.get("c.getGrayQuestEmiAmount");
        action.setParams({ "loanAmount": amount });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.gqEmiAmount", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    MultipayUpdatedHlpr: function (component, event, helper) {
        console.log('inside MultipayUpdatedHlpr');
        component.set("v.Spinner", true);
        var totalRecamount = 0;
        // var selcRecords = component.get("v.MultiSelectList");
        var selcRecords = component.get("v.lstPendingFee");//lstStuPaymentFee
        var selRecList = [];
        for (var i = 0; i < selcRecords.length; i++) {
            if (selcRecords[i].isChecked) {
                console.log('Is Checked', selcRecords[i].isChecked);
                selRecList.push(selcRecords[i]);
                // if(selcRecords[i].ObjStuFeePayDetails.Amount__c != null)
                // {
                totalRecamount = totalRecamount + selcRecords[i].Amount__c;
                // }
                if (selcRecords[i].Fee_Type__c === 'Transport Fee') {
                        console.log('Inside Transport fee');  
                        component.set("v.hideTransportFeeTemplate", false);
                }
                else{
                    component.set("v.hideTransportFeeTemplate", true);
                }
            }

        }
        component.set("v.totalAmount", totalRecamount);
        component.set("v.SelectedRecLst", selRecList);
        this.fetchGQEmiAmount(component, totalRecamount);
        console.log('before calling MultiUpdatedStduentFeePayRecords current data');
        console.log('Selected Record List', JSON.stringify(selRecList));
        var action = component.get("c.MultiUpdatedStduentFeePayRecords");
        action.setParams({
            "lst_StuFeePayIds": selRecList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log('inside MultiUpdatedStduentFeePayRecords call back '+state);
                // console.log('inside MultiUpdatedStduentFeePayRecords call back ');
                // console.log(response.getReturnValue());
                if (response.getReturnValue() != undefined) {
                    // console.log('inside MultiUpdatedStduentFeePayRecords 514 ');
                    var mapPayment = [];
                    var result = response.getReturnValue().map_PaymentGateway;
                    for (var key in result) {
                        mapPayment.push({ key: key, value: result[key] });
                    }
                    component.set("v.openMultiModel", true);
                    component.set("v.MultiPaymentMap", mapPayment);
                    component.set("v.lstMultipleRecords", response.getReturnValue().lst_StuFeePayment);
                    component.set("v.stuFeePayPendingList", response.getReturnValue().stuFeePayList);
                    component.set("v.ErrMessage", response.getReturnValue().Errmsg);
                    component.set("v.SelectedConId", response.getReturnValue().conId);
                    component.set("v.Spinner", false);
                    var openMultiModel = component.get("v.openMultiModel");
                    // console.log('inside MultiUpdatedStduentFeePayRecords 526 openMultiModel value is '+openMultiModel);
                    // console.log('ErrMessage is '+response.getReturnValue().Errmsg);
                    // console.log('inside 534 '+response.getReturnValue().conId);
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
                console.log('inside else 536');
            }
        });
        $A.enqueueAction(action);
    },



    PaytmUpdatedGeneratePaymentLink: function (component, event, helper, conId, payamount, feeType) {
        //  debugger;
        console.log('inside PaytmUpdatedGeneratePaymentLink helper ' + conId);
        component.set("v.ModelSpinner", true);
        // var SelectedConId =  component.get("v.SelectedConId");
        // console.log('ooooo'+SelectedConId);
        //    debugger;
        // var varFlowConId =  component.get("v.FlowConId");
        //  console.log('ooooo'+varFlowConId);

        //  if(varFlowConId !== undefined)
        //   {
        //    debugger;  
        //alert('=====>>>'+JSON.stringify(stuFees));
        var action = component.get("c.PaytmUpdatedGeneratePaymentLink");
        // console.log('ttttttttt'+action);
        //alert('=====>>>'+JSON.stringify(stuFees));

        action.setParams({
            "contactId": conId,
            "PartialAmount": payamount,
            "feeType": feeType,
            //"flowConId": varFlowConId

        });
        console.log('PaytmUpdatedGeneratePaymentLink outside ');
        // console.log(stuFees);
        // console.log(payamount);
        // console.log(feeType);
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('PaytmUpdatedGeneratePaymentLink ' + state);
            if (state === "SUCCESS") {
                console.log('hhhhhhh' + state);
                if (response.getReturnValue() !== undefined) {
                    console.log('mmmmmmmmmmm' + response.getReturnValue());
                    if (response.getReturnValue().statusCode === 200) {
                        console.log('gggggggggg' + response.getReturnValue().statusCode);
                        var retVal = response.getReturnValue();
                        console.log('aaaaaaaaa' + retVal);
                        // var payUrl = 'https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?mid='+retVal.id+'&orderId='+retVal.status;
                        component.set("v.paytmUrl", retVal.short_url);

                        component.set("v.paytmResponse", retVal);

                        component.set("v.paytmConfirm", true);

                        component.set("v.openModel", false);

                        component.set("v.openMultiModel", false);
                        console.log('inside line 596');
                    }
                    else {

                        helper.showToast(component, 'dismissible', 'Failed', 'Payment Link Generation Failed', 'error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else {

                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        //  }
        $A.enqueueAction(action);
    },

    EasyPayUpdatedGeneratePaymentLink: function (component, event, helper, conId, payamount, feeType) {
        component.set("v.ModelSpinner", true);
        var action = component.get("c.easypayUpdatedGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        action.setParams({
            "contactId": conId,
            "PartialAmount": payamount,
            "feeType": feeType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    if (response.getReturnValue().statusCode == 200) {
                        window.open(response.getReturnValue().short_url, "_self");
                    }
                    else {
                        helper.showToast(component, 'dismissible', 'Failed', 'Payment Link Generation Failed', 'error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },

    billDeskUpdatedGeneratePaymentLink: function (component, event, helper, conId, payamount, feeType) {
        component.set("v.ModelSpinner", true);
        var action = component.get("c.BillDeskUpdatedPayGenratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
        //ModifiedbyRajshekar
        var checkedStuRecords = component.get("v.CheckedlstPendingFee");
        action.setParams({
            "contactId": conId,
            "PartialAmount": payamount,
            "feeType": feeType,
            "selectedStuPayrecs":checkedStuRecords
        });
        //endshere
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state--'+state);
             console.log('response.getReturnValue()--'+response.getReturnValue());
            console.log('(response.getReturnValue().statusCode--'+response.getReturnValue().statusCode);
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    // console.log('response ', response.getReturnValue());
                    if (response.getReturnValue().statusCode == 200) {
                        window.open(response.getReturnValue().short_url, "_self");
                    }
                    else {
                        helper.showToast(component, 'dismissible', 'Failed', 'Payment Link Generation Failed', 'error');
                        component.set("v.ModelSpinner", false);
                    }
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },

    razorpayUpdatedGeneratePaymentLink: function (component, event, helper, conId, payamount, feeType) {
        component.set("v.Spinner", true);
        var action = component.get("c.razorpayUpdatedGeneratePaymentLink");
        //alert('=====>>>'+JSON.stringify(stuFees));
         var checkedStuRecords = component.get("v.CheckedlstPendingFee");
        action.setParams({
            "contactId": conId,
            "PartialAmount": payamount,
            "feeType": feeType,
             "selectedStuPayrecs":checkedStuRecords
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    if (response.getReturnValue().statusCode == 200) {
                        window.open(response.getReturnValue().short_url, "_self");
                    }
                    else {
                        helper.showToast(component, 'dismissible', 'Failed', 'Payment Link Generation Failed', 'error');
                        component.set("v.Spinner", false);
                    }
                }
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
})