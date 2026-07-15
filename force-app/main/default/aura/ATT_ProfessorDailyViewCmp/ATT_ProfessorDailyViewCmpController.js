({
	doInit : function(component, event, helper) {       
       helper.onchangeDateHpr(component, event, helper);
	},
    refreshView : function(component, event, helper) {       
       if(!component.get("v.showAttCmp")) helper.onchangeDateHpr(component, event, helper);
	},
    onchangeDate : function(component, event, helper) {
        if(component.get("v.selectedDat") > component.get("v.todayDate")) {  
            component.set("v.hideActions", false);            
        }
        else component.set("v.hideActions", true); 
        helper.onchangeDateHpr(component, event, helper);		
	},
    markAtt : function(component, event, helper) {
        var selId = event.getSource().get("v.name");
        component.set("v.selectedSchedule", selId);
        component.set("v.showAttCmp", true);
        component.set("v.showReadOnly", false);
    },
    submitForApproval   : function(component, event, helper) {
		helper.submitForApprovalHpr(component, event, helper);
	},
    completedView : function(component, event, helper) {
        var selId = event.getSource().get("v.name");
        component.set("v.selectedSchedule", selId);
        component.set("v.showAttCmp", true);
    	component.set("v.showReadOnly", true);
    },
})