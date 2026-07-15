({
    getUniversityHlprList : function(component, event, helper) {
        var action = component.get("c.getUniversityList");
        action.setParams({
            "nameStr": 'REVA University'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var options = [];
                var items = result[0].split('##'); 
                options.push({value:items[0],label:items[1]});
                component.set("v.selectedUniversity",options[0].value)
                component.set("v.universityList",options);
                this.onChangeHelper(component, event, helper,'university', result);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error",
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    onChangeHelper : function(component, event, helper, onchangeOf, univRes) {
        if(univRes != undefined && univRes.length > 1) {
            component.set("v.freeSch", true);
            var options1 = [];  
            var items1 = univRes[1].split('##');            
            options1.push({value:items1[0],label:items1[1], selected : true}); 
            component.set("v.selectedFaculty",items1[0]);            
            component.set("v.facultyList",options1);
            
            var options = [];                      
            var items = univRes[2].split('##');
            options.push({value:items[0],label:items[1], selected : true});
            component.set("v.schoolList",options);
            component.set("v.selectedSchool",items[0]);
            helper.onChangeHelper(component, event, helper,'school');
        }
        else {
            var action = component.get("c.getAccountBasedOnParentIdList");
            action.setParams({
                "parentId": onchangeOf == 'university' ? component.get("v.selectedUniversity") : 
                onchangeOf == 'faculty' ? component.get("v.selectedFaculty") :
                onchangeOf == 'school' ? component.get("v.selectedSchool") : null
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var options = [];
                    result.forEach(function(item){
                        var items = item.split('##');
                        options.push({value:items[0],label:items[1]});
                    })
                    if(onchangeOf == 'university')
                        component.set("v.facultyList",options);
                    else if(onchangeOf == 'faculty')
                        component.set("v.schoolList",options);
                        else if(onchangeOf == 'school')
                            component.set("v.programList",options);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error",
                        "message": response.getReturnValue()
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    onProgramChangeHelper : function(component, event, helper) {
        var action = component.get("c.getProgramBatchList");
        action.setParams({
            "programId": component.get("v.selectedProgram")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var options = [];
                result.forEach(function(item){
                    var items = item.split('##');
                    options.push({value:items[0],label:items[1]});
                })
                component.set("v.programBatchList",options);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error",
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    onProgramBatchChangeHelper : function(component, event, helper) {
        var action = component.get("c.getSemesterList");
        action.setParams({
            "programBId": component.get("v.selectedProgramBatch")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var options = [];
                result.forEach(function(item){
                    var items = item.split('##');
                    options.push({value:items[0],label:items[1]});
                })
                component.set("v.semesterList",options);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error",
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    onSemesterChangeHelper : function(component, event, helper) {
        var action = component.get("c.getSectionList");
        action.setParams({
            "semesterId": component.get("v.selectedSemester")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var options = [];
                result.forEach(function(item){
                    var items = item.split('##');
                    options.push({value:items[0],label:items[1]});
                })
                component.set("v.sectionList",options);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error",
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    onConfirmHelper : function(component, event, helper) {
        console.log('*** onConfirmHelper started ***');
        if(component.get("v.startDate") == null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": 'Start Date should not be empty'
            });
            toastEvent.fire();
        }
        else if(component.get("v.endDate") == null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error",
                "message": 'Start Date should not be empty'
            });
            toastEvent.fire();
        }
            else{
                var action = component.get("c.onCancelSchedule");
                var university = component.get("v.selectedUniversity");
                var facultyId = component.get("v.selectedFaculty");
                var schoolId = component.get("v.selectedSchool");
                var programId = component.get("v.selectedProgram");
                var programBatchId = component.get("v.selectedProgramBatch");
                var semesterId = component.get("v.selectedSemester");
                var sectionId = component.get("v.selectedSection");
                var reason = component.get("v.reason");
                console.log('Selected Section: ' + sectionId);
                console.log('Reason: ' + reason);
                var cancelId ='';
                var cancelLevel = '';
                if(sectionId !=null && sectionId!='')
                {
                    cancelId = sectionId;
                    cancelLevel = 'section';
                }
                else if(semesterId !=null && semesterId !='')
                {
                    cancelId = semesterId;
                    cancelLevel = 'semester';
                }
                    else if(programBatchId !=null && programBatchId !='')
                    {
                        cancelId = programBatchId;
                        cancelLevel = 'programBatch';
                    }
                        else if(programId !=null && programId !=''){
                            cancelId = programId;
                            cancelLevel = 'program';
                        }
                            else if(schoolId !=null && schoolId !=''){
                                cancelId = schoolId;
                                cancelLevel = 'school';
                            }
                                else if(facultyId !=null && facultyId !=''){
                                    cancelId = facultyId;
                                    cancelLevel = 'faculty';
                                }
                                    else{
                                        cancelId = component.get("v.selectedUniversity");
                                        cancelLevel = 'university';
                                    }
                
                action.setParams({
                    "cancelId": cancelId,
                    "cancelLevel" : cancelLevel,
                    "startDateTime" : component.get("v.startDate"),
                    "endDateTime" : component.get("v.endDate"),
                    "reason" : reason
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "success",
                            "message":result
                        });
                        toastEvent.fire();
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "error",
                            "message": response.getReturnValue()
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            }            
         console.log('*** onConfirmHelper finished ***'); 
    },
})