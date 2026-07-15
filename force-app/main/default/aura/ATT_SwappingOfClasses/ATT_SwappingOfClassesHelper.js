({
    doInitHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        var action = component.get("c.DisplaySemesterRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var mapSemesterValues = [];
                var result = response.getReturnValue();
                for(var key in result){
                    mapSemesterValues.push({key: key, value: result[key]});
                }
                component.set("v.MapSemester", mapSemesterValues);
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);	
    },
    changeSemesterHelper : function(component, event, helper)
    {
        var SelSemester = component.get("v.SelectedSemesterId");
        if(SelSemester != null && SelSemester != undefined && SelSemester != '')
        {
            var action = component.get("c.DisplayCourseOffering");
            action.setParams({'SemesterId':SelSemester});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {                
                    var mapCourseOffValues = [];
                    var result = response.getReturnValue();
                    for(var key in result){
                        mapCourseOffValues.push({key: key, value: result[key]});
                    }
                    component.set("v.MapCourseOffering", mapCourseOffValues);
                    component.set("v.Spinner", false); 
                }
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }  
            });
        }
        $A.enqueueAction(action);
    },
    changeCourseOfferingHelper : function(component, event, helper)
    {
        var SelSemester = component.get("v.SelectedSemesterId"); 
        var Selcourseid = component.get("v.SeleCourseOffId");
        if(Selcourseid != null && Selcourseid != undefined && Selcourseid != '' && SelSemester != null && SelSemester != undefined && SelSemester != '')
        {
            var action = component.get("c.DisplaySwappingRecords");
            action.setParams({'SemesterId':SelSemester,
                              'CourseSchid':Selcourseid});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {                
                    var mapSwapValues = [];
                    var result = response.getReturnValue();
                    for(var key in result){
                        mapSwapValues.push({key: key, value: result[key]});
                    }
                    component.set("v.MapFutureSemester", mapSwapValues);
                    component.set("v.Spinner", false); 
                }
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }  
            });
        }
        $A.enqueueAction(action);
    },
    OnsaveHlpr : function(component, event, helper)
    {
        var SelSemester = component.get("v.SeleCourseOffId"); 
        var SwapId = component.get("v.SwapCourseOffId"); 
        if(SelSemester != null && SelSemester != '' && SelSemester != undefined && SwapId != null && SwapId != '' && SwapId != undefined)
        {
            var action = component.get("c.SavingSwappingRecords");
            action.setParams({'FromId':SelSemester,
                              'ToId' :SwapId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    if(response.getReturnValue() != undefined && response.getReturnValue() != '')
                    {
                        this.showToast(component,'Success','Success',response.getReturnValue(),'success');
                        component.set("v.SeleCourseOffId",''); 
                        component.set("v.SwapCourseOffId",'');
                        component.set("v.SelectedSemesterId",'');
                        component.set("v.Spinner", false); 
                    }
                    else
                    { 
                        this.showToast(component,'Success','Success',response.getReturnValue(),'success');
                        component.set("v.Spinner", false); 
                    }
                    component.set("v.Spinner", false); 
                }
                else{
                    component.set("v.Spinner", false); 
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }  
            });
        }
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