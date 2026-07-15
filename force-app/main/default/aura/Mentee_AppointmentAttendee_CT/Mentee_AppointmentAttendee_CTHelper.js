({
    doInitHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var action = component.get("c.getCaseTeamMembers");
        action.setParams({'appId':component.get("v.recordId")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();
                    var mapuserValues = [];
                    var result = response.getReturnValue().map_user;
                    for(var key in result){
                        mapuserValues.push({key: key, value: result[key]});
                    }
                    
                    component.set("v.MapUser",mapuserValues);
                    component.set("v.appointment",retVal.objAppointment);
                    component.set("v.Spinner", false); 
                }
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                } 
            }
        });
        $A.enqueueAction(action);               
    },
    validationhlpr :function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var selecteduser = component.get("v.UserId");
        var selcetedcheckbox = component.get("v.selcheckbox");
        var action = component.get("c.ValidationAttendee");
        action.setParams({'appId':component.get("v.recordId"),
                          'userid':selecteduser,
                          'sendmeating':selcetedcheckbox
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {      
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().ErrMessage != null)
                    {
                        var retVal = response.getReturnValue().ErrMessage;
                        this.showToast(component,'dismissible','Failed',retVal,'error');
                    }
                    else
                    {
                        this.onsavehlpr(component, event, helper);
                    }                    
                }
                component.set("v.Spinner", false); 
            }    
            else
            {
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }   
        });
        $A.enqueueAction(action); 
    },
    onsavehlpr: function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var selecteduser = component.get("v.UserId");
        var selcetedcheckbox = component.get("v.selcheckbox");
        var action = component.get("c.SaveAttendee");
        action.setParams({'appId':component.get("v.recordId"),
                          'userid':selecteduser,
                          'sendmeating':selcetedcheckbox
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().ErrMessage =='Success')
                    {
                        this.showToast(component,'dismissible','success','Appointmnet Attendee Created Succesfully..!','success');
                        component.set("v.selcheckbox",false);
                        component.set("v.UserId",null); 
                        component.set("v.Spinner", false);
                        //$A.get('e.force:refreshView').fire();
                    }
                    else
                    {
                        component.set("v.Spinner", false); 
                        this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                    }
                }
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                } 
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