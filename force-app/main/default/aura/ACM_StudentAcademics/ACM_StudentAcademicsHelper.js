({
    doInitHelper : function(component, event, helper)
    {
        component.set("v.Spinner", true); 
        var action = component.get('c.DisplayAttendance'); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS')
            {
                var result = response.getReturnValue();
                if(result != undefined)
                {
                    component.set("v.ProgName",result.ProgramName);
                    component.set("v.SemNo",result.SemesterNo);
                    component.set("v.SecName",result.SectionName);
                    component.set("v.lst_CouSch",result.lst_sch); 
                }
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });        
        $A.enqueueAction(action);
    },
    viewHelper : function(component, event, helper)
    {
        var index = event.currentTarget.getAttribute("data-value");
        var presult = component.get("v.lst_CouSch");
        var selid = presult[index].Id;
        component.set("v.openModel",true);
        var action = component.get('c.DisplayPlanTopic'); 
        action.setParams({
            "CourSchid": selid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS')
            {
                var result = response.getReturnValue();
                if(result != undefined)
                {
                    component.set("v.AtopicName",result.ActualTopicName);
                    component.set("v.PtopicName",result.PlannedTopicName);
                    component.set("v.lst_Files",result.lst_file);
                }
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
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