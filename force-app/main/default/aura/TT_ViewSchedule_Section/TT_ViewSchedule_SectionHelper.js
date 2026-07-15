({
	fetchSchedule : function(component, event, helper) {
		var action = component.get('c.getTimeTableRecords');        
        action.setParams({
            "i_SectionId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.schoolName",result.schoolName);
                component.set("v.programName",result.programName);                
                component.set("v.semName",result.semesterName);
                component.set("v.secName",result.secName);
                component.set("v.acaYear",result.acdYear);                
                component.set("v.ScheduleWrpList",result.lst_Sch);
                component.set("v.timeSlot", result.lst_TimeSlot);
                component.set("v.profs", result.lst_Faculties);
            }
        });
        
        $A.enqueueAction(action);
	},
})