({
	onchangeDateHpr : function(component, event, helper) {
		component.set("v.Spinner", true);
        var action = component.get("c.getSchedule");
        action.setParams({'i_SelectedDate': component.get("v.selectedDat") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {                   
                    component.set("v.scheduleList",response.getReturnValue().schWrp);
                    component.set("v.todayDate", response.getReturnValue().sDate );
                    if(component.get("v.selectedDat") == undefined) component.set("v.selectedDat", response.getReturnValue().sDate );

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
    submitForApprovalHpr : function(component, event, helper) {
		component.set("v.Spinner", true);
        var selId = event.getSource().get("v.name");
        var action = component.get("c.postforApproval");
        action.setParams({'i_SelectedDate': component.get("v.selectedDat"),
                          'i_SelectedId' : selId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {      
                this.showToast(component,'dismissible','Success','Submitted successfully!!','success');
                if(response.getReturnValue() != undefined) {   
                    
                            component.set("v.scheduleList",response.getReturnValue().schWrp);
                    if(component.get("v.selectedDat") == undefined) component.set("v.selectedDat", response.getReturnValue().sDate );
               
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