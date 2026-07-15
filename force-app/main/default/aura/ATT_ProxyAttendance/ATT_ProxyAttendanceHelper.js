({
    OnSearchhelper: function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var selsrnNumber = component.get("v.SelectedSrnNumber"); 
        var action = component.get("c.DisplayProgramEnrollment");
        action.setParams({'SrnNumber':selsrnNumber});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {               	
                if(response.getReturnValue() != undefined)
                {                   
                    component.set("v.lst_ProgramEnrollment",response.getReturnValue());
                }
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            } 
        });
        $A.enqueueAction(action);
    },
    validationhlpr:function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var Fromdt = component.get("v.FromDatesel");
        var lstProgram =  component.get("v.lst_ProgramEnrollment");
        var todate = component.get("v.ToDatesel");       
        var action = component.get("c.ExistingProxyRecords");
        action.setParams({'SelFromDate':Fromdt,
                          'selTodate':todate,
                          'lst_progEnroll':lstProgram});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {  
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().Errmsg != null)
                    {
                        var retVal = response.getReturnValue().Errmsg;
                        this.showToast(component,'dismissible','Failed',retVal,'error'); 
                        component.set("v.Spinner", false);
                    }
                    else
                    {
                        helper.OnSaveHelper(component, event, helper);
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
    
    OnSaveHelper : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var Fromdt = component.get("v.selFromDate");
        var lstProgram =  component.get("v.lst_ProgramEnrollment");
        var todate = component.get("v.selToDate");
        var action = component.get("c.SaveProxyRecords");
        action.setParams({'SelFromDate':Fromdt,
                          'selTodate':todate,
                          'lst_progEnroll':lstProgram,
                          'Reason':component.get("v.selectedReason")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {  
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue()=== 'Success')
                    {                        
                        this.showToast(component,'dismissible','success','Proxy Attendances Created Successfully','success');
                        component.set("v.SelectedSrnNumber",''); 
                        var progEnroll =[];
                        component.set("v.lst_ProgramEnrollment",progEnroll);
                        component.set("v.Showsrn",false);
                        component.set("v.Spinner",false);
                        component.set("v.selectedFromDate",null); 
                        component.set("v.selectedToDate",null); 
                    }
                    else
                    {
                        this.showToast(component,'dismissible','Failed',response.getReturnValue(),'error');
                        component.set("v.Spinner",false);
                    }
                }
                else
                {
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                    component.set("v.Spinner",false);
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
    }
})