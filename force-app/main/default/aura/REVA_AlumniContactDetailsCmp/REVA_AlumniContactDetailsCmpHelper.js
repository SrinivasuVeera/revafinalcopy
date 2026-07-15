({
    getContactHelper  : function(component, event, helper) 
    {
        let action=component.get('c.fetchContact');
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS')
            {               
                component.set('v.ContactDetails',response.getReturnValue().con);
            }  
        });
        $A.enqueueAction(action);
    },
    doRedirectHelper : function (component, event, helper) {
        let RecrdId=event.getSource().get('v.name');        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": RecrdId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
})