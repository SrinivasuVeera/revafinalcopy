({
	doInitHlpr : function(component, event, helper)
    {
		component.set("v.Spinner",true);
        var action = component.get("c.getTermAndElectiveDetails");
        action.setParams({
            "recordId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue();
                var courseDetails = response.getReturnValue().map_ElectiveWrp;
                var courseDetailMap = [];
                for(var key in courseDetails)
                {
                    var course = {
                        "value": courseDetails[key],
                        "key": key
                    };
                    courseDetailMap.push(course);
                }
                //alert('courseDetailMap=='+JSON.stringify(response.getReturnValue().map_ElectiveWrp));
                component.set("v.courseDetails", courseDetailMap);
                component.set("v.objTerm", result.objTerm);
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
	},
    subjectHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var courseDetails = component.get("v.courseDetails");
        var selectedRec = event.currentTarget.getAttribute("data-Id");
        var indexElect = selectedRec.split('_')[0];
        var indexSubject = selectedRec.split('_')[1];
        component.set("v.selectedSubjectId", courseDetails[indexElect].value[indexSubject].subjectID);
        component.set("v.selectedParentCourseId", courseDetails[indexElect].value[indexSubject].parentCourseId);
        component.set("v.selectedSubject", courseDetails[indexElect].value[indexSubject].subjectName);
        component.set("v.selectedTotalStud", courseDetails[indexElect].value[indexSubject].totlNoOfStudents);
        component.set("v.selectedCourseCode", courseDetails[indexElect].value[indexSubject].courseCode);
        //alert('Subject Id=='+component.get("v.selectedSubjectId"));
        var action = component.get("c.getExistingGroups");
        action.setParams({
            "subjectId": component.get("v.selectedSubjectId"),
            "recordId": component.get("v.recordId")
        });          
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().strMessage === 'Records Exists')
                    {
                        var count = 0;
                        var result = response.getReturnValue();
                        var groupDetails = response.getReturnValue().objGroupMainWrp.map_GroupWrp;
                        var groupDetailMap = [];
                        for(var key in groupDetails)
                        {
                            if(groupDetails[key].lstcourseCons.length>0)
                            {
                                var group = {
                                    "value": groupDetails[key],
                                    "key": key
                                };
                                groupDetailMap.push(group);
                            }
                        }
                        component.set("v.groupValues", response.getReturnValue().objGroupMainWrp.map_GroupDetails);
                        component.set("v.disableAllocateButton", false);
                        component.set("v.groupDetailMap", groupDetailMap);
                        if(groupDetailMap.length > 0)
                            component.set("v.selectedTab", groupDetailMap[0].value.groupNo);
                        var groupData = response.getReturnValue().objGroupMainWrp.map_Groups;
                        var groupDataMap = [];
                        for(var key in groupData)
                        {
                            var group = {
                                "value": groupData[key],
                                "key": key
                            };
                            groupDataMap.push(group);
                        }
                        component.set("v.groupsMap", groupDataMap);
                        component.set("v.lstUnassigned", response.getReturnValue().objGroupMainWrp.lstUnassigned);
                        component.set("v.recordExistModal", true);
                        component.set("v.disableCreateButton", true);
                        component.set("v.noOfGroups", response.getReturnValue().totalGroupRecords);
                        component.set("v.Spinner",false);
                    }
                    else
                    {
                        component.set("v.subjectModalOpen", true);
                        component.set("v.Spinner",false);
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
    createGroupsHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var errorCount = 0;
        var allReqFields = component.find('auraInputId');
        if(allReqFields)
        {
            if(allReqFields.length) 
            {
                var allValid = allReqFields.reduce(function (validSoFar, inputCmp) 
                {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                if (!allValid) 
                {
                    errorCount++;
                }
            }
            else
            {
                var allValid = allReqFields;
                if (!allValid.get('v.validity').valid) 
                {
                    errorCount++;
                }
            }
        }
        if(errorCount > 0)
        {
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Error','Fill all mandatory fields..','error');
        }
        else
        {
            var action = component.get("c.createElectiveGroups");
            action.setParams({
                "noOfGroup": component.get("v.noOfGroups"),
                "subjectId": component.get("v.selectedSubjectId"),
                "courseCode": component.get("v.selectedCourseCode"),
                "recordId": component.get("v.recordId")
            });          
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (state === "SUCCESS")
                {
                    if(response.getReturnValue() != undefined)
                    {
                        if(response.getReturnValue().strMessage === 'Success')
                        {
                            this.showToast(component,'dismissible','Success','Student Group Allocation Successfully Created..!','success');
                            component.set("v.disableAllocateButton", false);
                            component.set("v.disableCreateButton", true);
                            component.set("v.noOfStudPerGroup", null);
                            component.set("v.Spinner",false);
                        }
                        else
                        {
                            this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                            component.set("v.Spinner",false);
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
        }
    },
    showExistingGroupsHlpr : function(component, event, helper)
    {
        component.set("v.recordExistModal", false);
        component.set("v.subjectModalOpen", true);
    },
    deleteExistingGroupsHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var action = component.get("c.deleteExistingGroupAllocations");
        action.setParams({
            "subjectId": component.get("v.selectedSubjectId"),
            "recordId": component.get("v.recordId")
        });          
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().strMessage === 'Success')
                    {
                        this.showToast(component,'dismissible','Success','Existing Group Allocation Records Deleted Successfully..!','success');
                        component.set("v.subjectModalOpen", true);
                        component.set("v.disableCreateButton", false);
                        component.set("v.recordExistModal", false);
                        component.set("v.disableAllocateButton", true);
                        var groupDetailMap = [];
                        component.set("v.groupDetailMap", groupDetailMap);
                        component.set("v.lstUnassigned", groupDetailMap);
                        component.set("v.noOfGroups", null);
                        component.set("v.Spinner",false);
                    }
                    else
                    {
                        this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                        component.set("v.Spinner",false);
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
    allocateGroupsHlpr : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var errorCount = 0;
        var allReqFields = component.find('auraInputId');
        if(allReqFields)
        {
            if(allReqFields.length) 
            {
                var allValid = allReqFields.reduce(function (validSoFar, inputCmp) 
                {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                if (!allValid) 
                {
                    errorCount++;
                }
            }
            else
            {
                var allValid = allReqFields;
                if (!allValid.get('v.validity').valid) 
                {
                    errorCount++;
                }
            }
        }
        if(errorCount > 0)
        {
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Error','Fill all mandatory fields..','error');
        }
        else
        {
            var action = component.get("c.getGroupDetails");
            action.setParams({
                "subjectId": component.get("v.selectedSubjectId"),
                "recordId": component.get("v.recordId"),
                "totalStudGroup": component.get("v.noOfStudPerGroup")
            });          
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (state === "SUCCESS")
                {
                    var count = 0;
                    var result = response.getReturnValue();
                    var groupData = response.getReturnValue().map_Groups;
                    var groupDataMap = [];
                    for(var key in groupData)
                    {
                        var group = {
                            "value": groupData[key],
                            "key": key
                        };
                        groupDataMap.push(group);
                    }
                    component.set("v.groupsMap", groupDataMap);
                    //alert('GroupMap=='+JSON.stringify(component.get("v.groupsMap")))
                    component.set("v.groupValues", response.getReturnValue().map_GroupDetails);
                    var groupDetails = response.getReturnValue().map_GroupWrp;
                    var groupDetailMap = [];
                    for(var key in groupDetails)
                    {
                        var group = {
                            "value": groupDetails[key],
                            "key": key
                        };
                        groupDetailMap.push(group);
                    }
                    component.set("v.disableAllocateButton", true);
                    component.set("v.groupDetailMap", groupDetailMap);
                    //alert('groupDetailMap=='+JSON.stringify(component.get("v.groupDetailMap")));
                    component.set("v.selectedTab", groupDetailMap[0].value.groupNo);
                    component.set("v.lstUnassigned", response.getReturnValue().lstUnassigned);
                    component.set("v.disableCreateButton", true);
                    component.set("v.Spinner",false);
                }
                else
                {
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                    component.set("v.Spinner",false);
                }
            });
            $A.enqueueAction(action);
        }
    },
    changeGroupHlpr : function(component, event, helper)
    {
        var index = event.getSource().get("v.name");
        var Value = event.getSource().get("v.value");
        var groupIndex = index.split('_')[0];
        var studIndex = index.split('_')[1];
        var groupWrp = component.get("v.groupDetailMap");
        groupWrp[groupIndex].value.lstcourseCons[studIndex].groupId = groupWrp[Value-1].value.groupId;
        groupWrp[groupIndex].value.lstcourseCons[studIndex].groupName = groupWrp[Value-1].value.groupName;
        var oldSection = groupWrp[groupIndex].value.lstcourseCons[studIndex].oldGroupId;
        var newSection = groupWrp[groupIndex].value.lstcourseCons[studIndex].groupId;
        if(oldSection == undefined || oldSection == '')
        {}
        else
        {
            if(oldSection == newSection)
                groupWrp[groupIndex].value.lstcourseCons[studIndex].isChecked = false;
            else
                groupWrp[groupIndex].value.lstcourseCons[studIndex].isChecked = true;
        }
        component.set("v.groupDetailMap", groupWrp);
    },
    changeUnAssignGroupsHlpr : function(component, event, helper)
    {
        var index = event.getSource().get("v.name");
        var Value = event.getSource().get("v.value");
        var lstUnassigned = component.get("v.lstUnassigned");
        var termGroupDetails = component.get("v.groupValues");
        lstUnassigned[index].groupId = termGroupDetails[Value].Id;
        lstUnassigned[index].groupName = termGroupDetails[Value].Name;
        lstUnassigned[index].isChecked = true;
        component.set("v.lstUnassigned", lstUnassigned);
    },
    saveSTMGroupHlpr : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var lstcourseCons = [];
        var groupWrp = component.get("v.groupDetailMap");
        var lstUnassigned = component.get("v.lstUnassigned");
        //alert('groupWrp=='+JSON.stringify(groupWrp));
        groupWrp.forEach(function(item, index)
        {
            var courseConn = item.value.lstcourseCons;
            for(var i=0; i< courseConn.length; i++)
            {
                if(courseConn[i].isChecked)
                    lstcourseCons.push(courseConn[i]); 
            }
        });
        
        if(lstUnassigned.length >0)
        {
            for(var i=0; i< lstUnassigned.length; i++)
            {
                if(lstUnassigned[i].groupId == undefined || lstUnassigned[i].groupId == '')
                {}
                else
                {
                    lstcourseCons.push(lstUnassigned[i]);
                }
            }
        }
        if(lstcourseCons.length > 0)
        {
            component.set("v.saveModal", true);
            component.set("v.Spinner",false);
        }
        else
        {
			this.showToast(component,'dismissible','Failed','Please Change atleast one Student Group..!','error');            
            component.set("v.Spinner",false);
        }
    },
    assignGroupsHlpr : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var lstcourseCons = [];
        var groupWrp = component.get("v.groupDetailMap");
        var lstUnassigned = component.get("v.lstUnassigned");
        groupWrp.forEach(function(item, index)
        {
            var courseConn = item.value.lstcourseCons;
            for(var i=0; i< courseConn.length; i++)
            {
                if(courseConn[i].isChecked)
                    lstcourseCons.push(courseConn[i]); 
            }
        });
        
        if(lstUnassigned.length >0)
        {
            for(var i=0; i< lstUnassigned.length; i++)
            {
                if(lstUnassigned[i].groupId == undefined || lstUnassigned[i].groupId == '')
                {}
                else
                {
                    lstcourseCons.push(lstUnassigned[i]);
                }
            }
        }
        var action = component.get("c.createStudTermGroup");
        action.setParams({
            "strCourseCons": JSON.stringify(lstcourseCons)
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
                        this.showToast(component,'dismissible','Success','Student Group Successfully Allocated..!','success');
                        component.set("v.saveModal", false);  
                        component.set("v.subjectModalOpen", false);
                        component.set("v.disableCreateButton", false);
                        component.set("v.noOfGroups", null);
                        component.set("v.noOfStudPerGroup", null);
                        var groupDetailMap = [];
                        component.set("v.groupDetailMap", groupDetailMap);
                        component.set("v.lstUnassigned", groupDetailMap);
                        this.navigateToRecord(component, event, helper, component.get("v.recordId"));
                        component.set("v.Spinner",false);
                    }
                    else
                    {
                        this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                        component.set("v.Spinner",false);
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
    navigateToRecord : function (component, event, helper, recordId) 
    {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    }
})