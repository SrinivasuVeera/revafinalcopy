/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
({
    doinit: function (component, event, helper) {
        //var action = component.get("c.getLoggedInUserProfile");
        var action = component.get("c.getLoggedInUserProfile");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var res = response.getReturnValue();
                if(res != undefined)
                {
                    component.set("v.nonTeachingStaff",res);
                    console.log('res==>',res);
                   // alert(res);
                }
            }
        });
        $A.enqueueAction(action);	
    },
})