({
	onchangeDateHpr : function(component, event, helper) {
		component.set("v.Spinner", true);
        var action = component.get("c.getSchedule");
        action.setParams({'i_SelectedDate': component.get("v.selectedDat") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {                   
                    component.set("v.scheduleList",response.getReturnValue());
                    //if(component.get("v.selectedDat") == undefined) component.set("v.selectedDat", response.getReturnValue().sDate );
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
})