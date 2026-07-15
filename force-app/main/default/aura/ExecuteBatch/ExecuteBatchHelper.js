({
    OnClickHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        var action = component.get("c.ExecuteBatchClass");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    var msg = response.getReturnValue();
                    this.showToast(component,'dismissible',msg.Message,response.getReturnValue(),'success');                                                     
                    component.set("v.Spinner", false); 
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