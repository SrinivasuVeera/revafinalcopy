({
    doInit : function (component, event, helper) {        
        var url = window.location.href;
        var match = url.match(/Report\/([a-zA-Z0-9]{15,18})/);

        if (match && match[1]) {            
            component.set("v.isValidPage", true);
            var recId = match[1];
           
            window.setTimeout($A.getCallback(function() {
                var flow = component.find("flowData");
                if (flow) {
                    var inputVariables = [{
                        name : "recordId", 
                        type : "String",
                        value : recId
                    }];
                    flow.startFlow("Restricted_Folder", inputVariables); 
                }
            }), 100);
            
        } else {
            component.set("v.isValidPage", false);
        }
    },

    closeModal : function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})