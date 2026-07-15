/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 07-01-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
({
    doInit: function (component, event, helper) {
        var action = component.get("c.isGuestUser");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isGuest", response.getReturnValue());

            } else {
                console.error("Failed with state: " + state);
                console.log('Response', JSON.stringify(response));

            }
        });
        $A.enqueueAction(action);
    },


})