({
	doInit : function(component, event, helper) 
    {
	     helper.doInitHelper(component, event, helper);	
	},
    view : function(component, event, helper) 
    {
	     helper.viewHelper(component, event, helper);	
	},
    closeModel : function(component, event, helper) 
    {
         component.set("v.openModel", false);
    }
})