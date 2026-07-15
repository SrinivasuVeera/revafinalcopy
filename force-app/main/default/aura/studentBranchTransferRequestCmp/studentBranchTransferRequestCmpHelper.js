({
    doInitHlpr:function(component, event, helper){
		component.set("v.Spinner",true);
        var action = component.get("c.getRecordDetail");
        action.setCallback(this, function(response)
        {
            var state = response.getState();
           // alert(state);
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue();
    			component.set("v.branch", result);
               // alert(JSON.stringify(result));
    			var smap = [];
                for(var key in result.schoolPicklist)
                {
                    var val = {
                        "label": result.schoolPicklist[key],
                        "value": key
                    };
                    smap.push(val);
                }
                component.set("v.schoolMap", smap);
                
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
                
			//	alert(result.ErrorMsg);
				                
                component.set("v.ErrorMsg",result.ErrorMsg);
                if(result.branchStatus == 'Submitted'){
                    component.set("v.approvalStatus",'Your Application has been Submitted');
                    component.set("v.disabled",true);
                }
                if(result.branchStatus == 'Approved'){
                    component.set("v.approvalStatus",'Your Application has been Approved');
                    component.set("v.disabled",true);
                }
                if(result.ErrorMsg != 'Success'){
                	component.set("v.disabled",true);
                }    
            }
            component.set("v.Spinner",false);
        });
        $A.enqueueAction(action);
	}    
})