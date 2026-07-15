({
	doInit : function(component, event, helper) {
		helper.doInitHlpr(component, event, helper);
	},
    changeSchool : function(component, event, helper) {
        component.set("v.Spinner",true);
      //  alert(component.get("v.selectedSchool"));
        var action = component.get("c.getBranchDetail");
        action.setParams({
            "schoolId": component.get("v.branch.selectedSchool"),
            "type": component.get("v.branch.programType")
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
           // alert(state);
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue();
                var bmap = [];
                for(var key in result.branchPicklist)
                {
                    var val = {
                        "label": result.branchPicklist[key],
                        "value": key
                    };
                    bmap.push(val);
                }
                component.set("v.branchMap", bmap);
            }
            component.set("v.Spinner",false);
         });
        $A.enqueueAction(action);   
    },
	saveStudSection : function(component, event, helper) {
       component.set("v.Spinner",true);
        var action = component.get("c.getUpdateEnrollment");
        action.setParams({
            "wrp": component.get("v.branch")
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
           // alert(state);
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue();                
                component.set("v.branch.branchStatus", result.branchStatus);
                if(result.branchStatus == 'Submitted'){
                    component.set("v.approvalStatus",'Your Application has been Submitted');
                    component.set("v.disabled",true);
                }
                if(result.branchStatus == 'Approved'){
                    component.set("v.approvalStatus",'Your Application has been Approved');
                    component.set("v.disabled",true);
                }
            }
            component.set("v.Spinner",false);
         });
        $A.enqueueAction(action); 
    },
	cancelBtn : function(component, event, helper)
    {
    	$A.get("e.force:closeQuickAction").fire();    
    }    
})