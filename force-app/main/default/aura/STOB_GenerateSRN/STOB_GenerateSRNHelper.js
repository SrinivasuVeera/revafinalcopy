({
	getStudTypeHlpr : function(component, event, helper) 
    {
		component.set("v.Spinner",true);
        var action = component.get("c.getStudentType");
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue();
                var items = [];
                for (var i = 0; i < result.length; i++) 
                {
                    var item = {
                        "label": result[i],
                        "value": result[i]
                    };
                    items.push(item);
                }
                component.set("v.studTypeOptions", items);
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
	},
    getEnrollmentHlpr : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getProgEnrollNoGRN");
        action.setParams({
            "studentType" : component.get("v.studentType"),
            "objProgmPlan" : component.get("v.objProgPlan")
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue().lstPrgEnroll;
                if(result.length > 0)
                {
                    component.set("v.progmEnrollmentLst", result);
                    component.set("v.hideConfirmBtn", true);
                    //component.set("v.disableSelection", true);
                }
                else
                {
                    component.set("v.progmEnrollmentLst", result);
                    component.set("v.hideConfirmBtn", true);
                    component.set("v.hideStudPicklist", false);
                }
                this.gneratedSRNHlpr(component, event, helper);
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    getProgramPlanHlpr : function(component, event, helper) 
    {
		component.set("v.Spinner",true);
		var action = component.get("c.getProgramPlanDetails");
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue();
                component.set("v.objProgPlan", result);
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
	},
    handleStudTypeHlpr : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var errorCount = 0;
        var errorStudType = document.getElementById("errorStudType");
        if(component.get("v.studentType") == undefined || component.get("v.studentType") == '')
        {
            component.set("v.Spinner",false);
            errorStudType.style.display = 'block';
            errorCount ++;
        }
        else
        {
            errorStudType.style.display = 'none';
        }
        if(errorCount > 0)
        {
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Error','Fill all mandatory fields..','error');
        }
        else
        {
            this.toBeGeneratedHlpr(component, event, helper);
            //this.gneratedSRNHlpr(component, event, helper);
            component.set("v.hideConfirmBtn", false);
            component.set("v.disableSelection", true);
        }
    },
    toBeGeneratedHlpr : function(component, event, helper)
    {
        var action = component.get("c.getProgramEnrollment");
        action.setParams({
            "studentType" : component.get("v.studentType"),
            "objProgmPlan" : component.get("v.objProgPlan"),
            "lstProgEnroll" : component.get("v.progmEnrollmentLst")
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue().lstPrgEnroll;
                component.set("v.progmEnrollmentLst", result);
                if(result.length > 0)
                {
                    component.set("v.hideStudPicklist", true);
                }
                else
                    component.set("v.hideStudPicklist", false);
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    gneratedSRNHlpr : function(component, event, helper)
    {
        var action = component.get("c.generatedSRN");
        action.setParams({
            "studentType" : component.get("v.studentType"),
            "objProgmPlan" : component.get("v.objProgPlan")
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue().lstGenPrgEnroll;
                component.set("v.confStudSRNLst", result);
                if(result.length > 0)
                {
                    component.set("v.hideSRNPicklist", true);
                }
                else
                    component.set("v.hideSRNPicklist", false);
                
                var hideStudPlist = component.get("v.hideStudPicklist");
                var hideSRNPlist = component.get("v.hideSRNPicklist");
                if((hideStudPlist || !hideSRNPlist) || (!hideStudPlist || hideSRNPlist)
                  || (hideStudPlist || hideSRNPlist))
                    component.set("v.hidePicklist", true);
                else
                    component.set("v.hidePicklist", false);
                
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    generateSRNNoHlpr : function(component, event, helper)
    {
        component.set('v.showGRNGenerateDialog', false);
        component.set("v.Spinner",true);
        var totalRegular = 0;
        var totalTransRegular = 0;
        var lstPrgEnroll = component.get("v.progmEnrollmentLst");
        
        if(component.get("v.studentType") == 'Regular Entry')
        {
            for(var i = 0; i<lstPrgEnroll.length; i++)
            {
                if(lstPrgEnroll[i].University_Transferred_Student__c)
                   totalTransRegular = totalTransRegular + 1
                else
                   totalRegular = totalRegular + 1; 
            }
        }
        var action = component.get("c.updatePrgEnrollement");
        action.setParams({
            "lstPrgEnroll": component.get("v.progmEnrollmentLst"),
            "objProgmPlan" : component.get("v.objProgPlan"),
            "studentType" : component.get("v.studentType"),
            "totalRegStud" : totalRegular,
            "totalUnivTransStud" : totalTransRegular
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
                        this.showToast(component,'dismissible','Success','Successfully Generated SRN..!','success');
                        $A.get('e.force:refreshView').fire();
                        this.getEnrollmentHlpr(component, event, helper);
                        this.gneratedSRNHlpr(component, event, helper);
                        //alert('To Be Generated=='+JSON.stringify(component.set("v.progmEnrollmentLst")));
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