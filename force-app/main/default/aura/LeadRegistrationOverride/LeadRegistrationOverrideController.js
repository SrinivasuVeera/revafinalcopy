({
    handleClose : function(component, event, helper) {       
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": "/lightning/o/Lead/list" });
        urlEvent.fire();
    }
})