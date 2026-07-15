({
    doInithelper : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getSemesterDetails");
        action.setParams({"str_TermId": component.get("v.recordId")});
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().strMessage == 'Success')
                    {
                        var resultData = response.getReturnValue();         
                        component.set("v.strTerm",resultData.objSemester.Name);
                        var responsedata = response.getReturnValue().lstProgEnroll;
                        if(responsedata.length >0)
                        {
                            component.set("v.listProgramEnrollments", responsedata);
                            component.set("v.Spinner",false);
                        }
                    }
                    else
                    {
                        this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                        component.set("v.Spinner",false);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
                else
                {
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                    component.set("v.Spinner",false);
                }
            }
            else
            {
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    generatedialogHelper: function(component, event, helper)
    {       
        component.set('v.showMovesemesters', true);
    },
    selectAllCheckboxHelper : function(component, event, helper)
    {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedEnrollRecords = [];
        var listOfEnrolls = component.get("v.listProgramEnrollments");
        // play a for loop on all records list 
        for (var i = 0; i < listOfEnrolls.length; i++) 
        {
            if (selectedHeaderCheck == true) 
            {
                listOfEnrolls[i].isChecked = true;
            } 
            else 
            {
                listOfEnrolls[i].isChecked = false;
            }
            updatedEnrollRecords.push(listOfEnrolls[i]);
        }
        component.set("v.listProgramEnrollments", updatedEnrollRecords);
    },
    selectCheckboxHlpr : function(component, event, helper)
    {
        var listOfEnrolls = component.get("v.listProgramEnrollments");
        var updatedEnrollRecords = [];
        for (var i = 0; i < listOfEnrolls.length; i++) 
        {
            if(listOfEnrolls[i].isChecked == true) 
            {
                updatedEnrollRecords.push(listOfEnrolls[i]);
            } 
        }
        if(listOfEnrolls.length == updatedEnrollRecords.length)
        {
            component.set("v.selectall", true);
        }
        else
        {
            component.set("v.selectall", false);
        }
    },
    confirmStudentsHelper : function(component, event, helper)
    {
        var studntwrp = component.get("v.listProgramEnrollments");
        var list_selected =[];
        var selectdedIds = [];
        for(var i=0;i<studntwrp.length;i++)
        {
            if(studntwrp[i].isChecked == true)
            {
                list_selected.push(studntwrp[i].objProgEnroll); 
                selectdedIds.push(studntwrp[i].objProgEnroll.Id);
            }
        }
        if(list_selected == 0)
        {
            this.showToast(component,'dismissible','Error','Please Select Atleast One Student to Promote..!','error');
        }
        else
        {  
            component.set("v.Spinner",true);
            var action = component.get("c.updatestudentTermMappings");
            
            action.setParams({
                "str_selectSemId": component.get("v.recordId"),
                "list_Enrollments": list_selected,
                "lstSelectedIds": selectdedIds
            });
            action.setCallback(this, function(response) 
            {	
                var state = response.getState();
                if(state === "SUCCESS")
                {
                    if(response.getReturnValue() != undefined)
                    {
                        if(response.getReturnValue().strMessage === 'Success')
                        {
                            this.showToast(component,'dismissible','Success','Students Promoted Successfully..!','success');
                            component.set("v.Spinner",false);
                            component.set('v.showMovesemesters', false);
                            $A.get("e.force:closeQuickAction").fire();
                        }
                        else
                        {
                            this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                        }
                    }
                    else
                    {
                        this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                    }
                }
                else
                {
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                }
                
            }); 
            $A.enqueueAction(action); 
        }
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
    },
})