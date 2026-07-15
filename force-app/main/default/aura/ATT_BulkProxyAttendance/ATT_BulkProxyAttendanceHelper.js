({
	saveProxyAttendHlpr : function(component, event, helper) 
    {
		component.set("v.Spinner",true);
        var errorCount = 0;
        var allReqFields = component.find('auraInputId');
        if(allReqFields)
        {
            if(allReqFields.length) 
            {
                var allValid = allReqFields.reduce(function (validSoFar, inputCmp) 
                {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                if (!allValid) 
                {
                    errorCount++;
                }
            }
            else
            {
                var allValid = allReqFields;
                if (!allValid.get('v.validity').valid) 
                {
                    errorCount++;
                }
            }
        }
        if(errorCount > 0)
        {
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Error','Fill all mandatory fields..','error');
        }
        else
        {
            var fromDate = component.get("v.selectedFromDate");
            var selFromDate =  $A.localizationService.formatDate(fromDate, "yyyy-MM-dd");
            let formatFromDate = $A.localizationService.formatDate(fromDate, "MM-dd-yyyy,HH:mm:ss"); 
            
            var toDate = component.get("v.selectedToDate");
            var selToDate =  $A.localizationService.formatDate(toDate, "yyyy-MM-dd");
            let formatToDate = $A.localizationService.formatDate(toDate, "MM-dd-yyyy,HH:mm:ss"); 
            
            component.set("v.Spinner",true);
            var action = component.get("c.CreateProxyAttendance");
            action.setParams({
                "fromDate": formatFromDate,
                "toDate": formatToDate,
                "srnNos": component.get("v.srnNos"),
                "strReason": component.get("v.reason")
            });
            action.setCallback(this, function(response)
            {
                var state = response.getState();
                if(state === "SUCCESS")
                {
                   if(response.getReturnValue() != undefined)
                    {
                        if(response.getReturnValue().strMessage === 'Success')
                        {
                            this.showToast(component,'dismissible','Success','Proxy Attendance Created Successfully..!','success');
                            $A.get('e.force:refreshView').fire();
                            this.clearValues(component, event, helper);
                            component.set("v.Spinner",false);
                        }
                        else
                        {
                            this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                            component.set("v.Spinner",false);
                        }
                    }
                    else
                    {
                        this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                        component.set("v.Spinner",false);
                    }
                }
                else
                {
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                    component.set("v.Spinner",false);
                }
            });
            $A.enqueueAction(action);
        }
	},
    clearValues : function(component, event, helper)
    {
        component.set("v.selectedFromDate",'');
        component.set("v.selectedToDate",'');
        component.set("v.srnNos",'');
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
})