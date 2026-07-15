({
	doInitHpr : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action = component.get("c.fetchData");
        action.setParams({'iaType':component.get("v.iaType")});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS'){
                if(result.getReturnValue() != undefined){
                    var retVal = result.getReturnValue();
                    component.set("v.iaDataList",retVal.list_IAMarks);
                    component.set("v.iaDataListDetail",retVal.list_crsWpr);
                    component.set("v.semName",retVal.activeSem);
                    component.set("v.Spinner",false);
                }else{
                    component.set("v.Spinner",false);
                    this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                }
            }else{
                component.set("v.Spinner",false);
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2000'
        });
        toastEvent.fire();
    },
})