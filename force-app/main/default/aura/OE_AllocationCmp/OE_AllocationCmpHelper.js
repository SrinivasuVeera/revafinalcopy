({
    initHpr : function(component, event, helper, isChange) {
        component.set("v.Spinner", true);        
        var isEng = component.get("v.selectedFaculty") == 'Engineering' ? true : false;
        var action = component.get("c.fetchOEOfferings");
        action.setParams({'i_TermNumber': component.get("v.selectedSem"),
                          'i_Engineering' :  isEng
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {                   
                    component.set("v.courseList",response.getReturnValue().lst_Course);
                    if(isChange) component.set("v.options",response.getReturnValue().lst_SemsNumber);
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
    onSemChangeHpr : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.fetchOEOfferings");
        action.setParams({'i_TermNumber': component.get("v.selectedSem"),
                          'i_Engineering' :  isEng
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {                   
                    component.set("v.courseList",response.getReturnValue().lst_Course);
                    component.set("v.options",response.getReturnValue().lst_SemsNumber);
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
    editAllocationHpr : function(component, event, helper) {
        component.set("v.Spinner", true);
        var isEng = component.get("v.selectedFaculty") == 'Engineering' ? true : false;
        var action = component.get("c.getStudentPrefBySubj");
        action.setParams({'i_TermNumber': component.get("v.selectedSem"),
                          'i_Engineering' :  isEng
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {                   
                    component.set("v.studentsList",response.getReturnValue());
                    
                    component.set("v.openPopUp", true);  
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
    moveAllocationHpr : function(component, event, helper) {
        component.set("v.Spinner", true);
        var sectionInd = event.getSource().get("v.name");
        var stuList =  component.get("v.studentsList");
        var prefs = stuList[sectionInd].lst_StuPref;
        var toMove =[];
        for (let i = prefs.length-1; i >= 0; i--) {
            if(prefs[i].isSelected){
                toMove.push(prefs[i]);
                prefs.splice(i,1);
            }
        }
        stuList[component.get("v.selectedOEForMove")].lst_StuPref.push(...toMove);
        component.set("v.studentsList",stuList);
        component.set("v.Spinner", false);        
    },
    saveAllocationHpr : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.saveCourseConnection");
        action.setParams({'i_Students': JSON.stringify(component.get("v.studentsList"))});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {                   
                    
                    component.set("v.openPopUp", false);  
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
    fetchConnections : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.fetchexistingTerms");
        action.setParams({'i_Course': component.get("v.selectedCourse"),
                          'i_TermNumber': component.get("v.selectedSem")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {  
                    component.set("v.connectionList", response.getReturnValue().lst_Term); 
                    component.set("v.EnrolledStudentsCount",response.getReturnValue().enrolledStudents )
                    component.set("v.openPopUp", false);  
                    component.set("v.openGroupPopUp", true);
                    component.set("v.onNextTrue", false);
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
    onNextHpr : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.fetchConnectionGroups");
        action.setParams({'i_Course': component.get("v.selectedCourse"),
                          'i_TermNumber': component.get("v.selectedSem"),
                          'i_groupCount' : component.get("v.inputNoOfBatches")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {  
                    component.set("v.groupingList", response.getReturnValue());                      
                    component.set("v.openPopUp", false);  
                    component.set("v.openGroupPopUp", true);
                    component.set("v.onNextTrue", true);
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
    addNewGroupHpr :  function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.createTermGroups");
        var grpCnt = component.get("v.inputNoOfGroups");
        action.setParams({'i_Course': component.get("v.selectedCourse"),
                          'i_Count': grpCnt,
                          'i_TermNumber': component.get("v.selectedSem")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {  
                    component.set("v.connectionList", response.getReturnValue().lst_Term); 
                    component.set("v.EnrolledStudentsCount",response.getReturnValue().enrolledStudents )
                    component.set("v.openPopUp", false);  
                    component.set("v.openGroupPopUp", true);
                    component.set("v.onNextTrue", false);
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
    onDeleteGroupHpr  : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.deleteGroupCtr");
        action.setParams({'i_Course': component.get("v.selectedCourse"),
                          'i_TermNumber': component.get("v.selectedSem"),
                          'i_SelectedGroup' : event.getSource().get("v.name")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {  
                    component.set("v.connectionList", response.getReturnValue().lst_Term); 
                    component.set("v.EnrolledStudentsCount",response.getReturnValue().enrolledStudents )
                    component.set("v.openPopUp", false);  
                    component.set("v.openGroupPopUp", true);
                    component.set("v.onNextTrue", false);
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
    moveGroupAllocationHpr : function(component, event, helper) {
        component.set("v.Spinner", true);
        var sectionInd = event.getSource().get("v.name");
        var stuList =  component.get("v.groupingList");
        var prefs = stuList[sectionInd].lst_StuPref;
        var toMove =[];
        for (let i = prefs.length-1; i >= 0; i--) {
            if(prefs[i].isSelected){
                toMove.push(prefs[i]);
                prefs.splice(i,1);
            }
        }
        stuList[component.get("v.selectedOEForMove")].lst_StuPref.push(...toMove);
        component.set("v.groupingList",stuList);
        component.set("v.Spinner", false);        
    },
    saveGroupAllocationHpr : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.saveGroupChangeConnection");
        action.setParams({'i_Students': JSON.stringify(component.get("v.groupingList"))});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               	
                if(response.getReturnValue() != undefined) {                   
                    component.set("v.openGroupPopUp", false);
                    component.set("v.openPopUp", false);  
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