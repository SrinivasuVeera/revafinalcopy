({
    getUniversityHlprList: function(component, event, helper) {
        var action = component.get("c.getUniversityList");
        action.setParams({"nameStr": 'REVA University'});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var options = [];
                var items = result[0].split('##'); 
                options.push({value: items[0], label: items[1]});
                component.set("v.selectedUniversity", options[0].value);
                component.set("v.universityList", options);
                this.onChangeHelper(component, event, helper, 'university', result);
            } else {
                this.showToast("Error", response.getReturnValue(), "error");
            }
        });
        $A.enqueueAction(action);
    },
    
    onChangeHelper: function(component, event, helper, onchangeOf, univRes) {
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
    
    onProgramChangeHelper: function(component, event, helper) {
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
    validateExamNotification: function(component, event, helper, semesterId, iaType, callback) {
        var action = component.get("c.validateExamNotification");
        action.setParams({
            "semesterId": semesterId,
            "iaType": iaType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isValid = response.getReturnValue();
                callback(isValid);
            } else {
                callback(false);
            }
        });
        $A.enqueueAction(action);
    },
    
   downloadSelectedHallTickets: function(component, event, helper, semesterId, eligibility, studentIds, batchSize) {
    var action = component.get("c.saveBulkPdfAsFile");
    action.setParams({
        semesterId: semesterId,
        eligibility: eligibility,
        studentIds: studentIds,
        batchSize: batchSize || 40
    });

    action.setCallback(this, function(response) {
        component.set("v.isDownloading", false);
        component.set("v.isLoading", false);

        var state = response.getState();
        if (state === "SUCCESS") {
            var cvIds = response.getReturnValue();
            if (cvIds && cvIds.length > 0) {
                helper.downloadMultipleFiles(cvIds);
                helper.showToast(
                    "Success",
                    "Generated " + cvIds.length + " PDF" + 
                    (cvIds.length > 1 ? "s" : "") + 
                    " (" + batchSize + " students each)",
                    "success"
                );
            }
        } else {
            var err = response.getError();
            helper.showToast("Error", err && err[0] ? err[0].message : "Download failed", "error");
        }
    });
    $A.enqueueAction(action);
},
    downloadMultipleFiles: function(contentVersionIds) {
    contentVersionIds.forEach(function(cvId, index) {
        setTimeout(function() {
            var downloadUrl = '/sfc/servlet.shepherd/version/download/' + cvId + '?operationContext=S1';
            window.open(downloadUrl, '_blank');
        }, index * 500); // Stagger downloads to avoid popup blocking
    });
},
   
    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})