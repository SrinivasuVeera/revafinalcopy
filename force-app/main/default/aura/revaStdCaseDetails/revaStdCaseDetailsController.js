({
    doInit: function (component, event, helper) {
        var action = component.get("c.getAllCasesWithoutSubject");
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        action.setParams({ "userId": userId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.cases", response.getReturnValue());
                console.log('this is data>>>>' + JSON.stringify(response.getReturnValue()));
            } else {
                console.log("Error fetching cases: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    navigateToCase: function (component, event, helper) {
        var caseId = event.currentTarget.dataset.value;

        console.log("Clicked Case ID: " + caseId);

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": caseId,
            "slideDevName": "detail"
        });

        // Get the URL before navigation
        var url = navEvt.getParams().recordId
            ? '/lightning/r/Case/' + caseId + '/view'
            : '/lightning/o/Case/home';

        console.log("URL before navigating: " + url);

        navEvt.fire();
    }

})