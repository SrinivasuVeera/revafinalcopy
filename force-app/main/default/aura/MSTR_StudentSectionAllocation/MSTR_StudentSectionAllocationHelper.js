({
	doInitHlpr : function(component, event, helper) 
    {
		//this.getAllocationHlpr(component, event, helper);
        this.getTermHlpr(component, event, helper);
	},
    /*getAllocationHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getAllocations");
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
               var result = response.getReturnValue();
                var allocationMap = [];
                for(var key in result)
                {
                    var visit = {
                        "label": result[key],
                        "value": key
                    };
                    allocationMap.push(visit);
                }
                component.set("v.allocations", allocationMap);
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
    },*/
    getTermHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getTermDetails");
        action.setParams({
            "recId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue();
                //Allocation Picklist
                var allocations = response.getReturnValue().map_allocations;
                //alert('Unassigned=='+JSON.stringify(response.getReturnValue().lstUnassigned));
                var allocationMap = [];
                for(var key in allocations)
                {
                    var allocation = {
                        "label": allocations[key],
                        "value": key
                    };
                    allocationMap.push(allocation);
                }
                component.set("v.allocations", allocationMap);
                //Section Picklist
                var sections = response.getReturnValue().map_Sections;
                var sectionsMap = [];
                for(var key in sections)
                {
                    var section = {
                        "label": sections[key],
                        "value": key
                    };
                    sectionsMap.push(section);
                }
                component.set("v.termSections", sectionsMap);
                var termSections = response.getReturnValue().map_TermSections;
                component.set("v.termSectionDetails", response.getReturnValue().map_TermSections);
                var students = response.getReturnValue().objSectionWrp.map_SectionWrp;
                var studentMap = [];
                for(var key in students)
                {
                    if(students[key].lstProgEnroll.length > 0) 
                    {
                        var student = {
                            "value": students[key],
                            "key": key
                        };
                        studentMap.push(student);
                    }
                }
                component.set("v.sectionWrp", studentMap);
                if(studentMap.length >0)
                    component.set("v.selectedTab", studentMap[0].value.sectionNo);
                component.set("v.lstUnassigned", response.getReturnValue().lstUnassigned);
                component.set("v.unassignedSize", response.getReturnValue().totalUnassignedRecords);
                component.set("v.objTerm", result.objTerm);
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    getSectionDetailHlpr : function(component, event, helper) 
    {
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
            component.set("v.Spinner",true);
            var action = component.get("c.getSectionAndStudents");
            action.setParams({
                "objTrm": component.get("v.objTerm"),
                "AllocationType": component.get("v.allocationType")
            });
            action.setCallback(this, function(response)
            {
                var state = response.getState();
                if(state === "SUCCESS")
                {
                    var result = response.getReturnValue();
                    var sections = response.getReturnValue().map_SectionWrp;
                    var sectionMap = [];
                    for(var key in sections)
                    {
                        var section = {
                            "value": sections[key],
                            "key": key
                        };
                        sectionMap.push(section);
                    }
                    component.set("v.sectionWrp", sectionMap);
                    component.set("v.lstUnassigned", response.getReturnValue().lstUnassigned);
                    if(response.getReturnValue().lstUnassigned.length > 0)
                    {
                        try
                        {
                            var tabLabel =component.find("tabId").get("v.label");
                            tabLabel[0].set("v.value", "Unassigned ("+response.getReturnValue().totalUnassignedRecords+")");
                        }
                        catch(err)
                        {
                            component.set("v.unassignedSize", response.getReturnValue().totalUnassignedRecords);
                        }
                    }
					component.set("v.selectedTab", sectionMap[0].value.sectionNo);
                    component.set("v.disableInputs", true);
                    component.set("v.Spinner",false);
                }
            });
            $A.enqueueAction(action);
        }
    },
    selectAllHlpr : function(component, event, helper)
    {
        var selectedText = event.getSource().get("v.text");
        var selectedValue = event.getSource().get("v.value");
        var sectionWrp = component.get("v.sectionWrp");
        var studDetails = sectionWrp[selectedText];
        var selectedrec;
        sectionWrp.forEach(function(item, index)
        {
            var section = [];
            section = item.value;
            if(item.key == selectedText)
            {
                for(var i=0; i< section.lstProgEnroll.length; i++)
                {
                    section.lstProgEnroll[i].isChecked = true;
                }
            }
            sectionWrp.set(item.key, section);
        });
		component.set("v.sectionWrp", sectionWrp);        
    },
    changeSectionHlpr : function(component, event, helper)
    {
        var index = event.getSource().get("v.name");
        var Value = event.getSource().get("v.value");
        var sectionIndex = index.split('_')[0];
        var studIndex = index.split('_')[1];
        var sectionWrp = component.get("v.sectionWrp");
        sectionWrp[sectionIndex].value.lstProgEnroll[studIndex].sectionId = sectionWrp[Value-1].value.sectionId;
        sectionWrp[sectionIndex].value.lstProgEnroll[studIndex].sectionName = sectionWrp[Value-1].value.sectName;
        var oldSection = sectionWrp[sectionIndex].value.lstProgEnroll[studIndex].oldSectionId;
        var newSection = sectionWrp[sectionIndex].value.lstProgEnroll[studIndex].sectionId;
        if(oldSection == undefined || oldSection == '')
        {}
        else
        {
            if(oldSection == newSection)
                sectionWrp[sectionIndex].value.lstProgEnroll[studIndex].isChecked = false;
            else
                sectionWrp[sectionIndex].value.lstProgEnroll[studIndex].isChecked = true;
        }
        component.set("v.sectionWrp", sectionWrp);
    },
    changeUnAssignSectionHlpr : function(component, event, helper)
    {
        var index = event.getSource().get("v.name");
        var Value = event.getSource().get("v.value");
        var lstUnassigned = component.get("v.lstUnassigned");
        var termSectionDetails = component.get("v.termSectionDetails");
        lstUnassigned[index].sectionId = termSectionDetails[Value].Id;
        lstUnassigned[index].sectionName = termSectionDetails[Value].Name;
        lstUnassigned[index].isChecked = true;
        component.set("v.lstUnassigned", lstUnassigned);
    },
    saveStudSectionHlpr : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var progEnrollLst = [];
        var sectionWrp = component.get("v.sectionWrp");
        var lstUnassigned = component.get("v.lstUnassigned");
        sectionWrp.forEach(function(item, index)
        {
            var progEnroll = item.value.lstProgEnroll;
            for(var i=0; i< progEnroll.length; i++)
            {
                if(progEnroll[i].isChecked)
                    progEnrollLst.push(progEnroll[i]); 
            }
        });
        
        if(lstUnassigned.length >0)
        {
            for(var i=0; i< lstUnassigned.length; i++)
            {
                if(lstUnassigned[i].sectionId == undefined || lstUnassigned[i].sectionId == '')
                {}
                else
                {
                    progEnrollLst.push(lstUnassigned[i]);
                }
            }
        }
        if(progEnrollLst.length > 0)
        {
            component.set("v.openModel", true);
            component.set("v.Spinner",false);
        }
        else
        {
			this.showToast(component,'dismissible','Failed','Please Change atleast one Student Section..!','error');            
            component.set("v.Spinner",false);
        }
        
    },
    assignSectionsHlpr : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var progEnrollLst = [];
        var sectionWrp = component.get("v.sectionWrp");
        var lstUnassigned = component.get("v.lstUnassigned");
        sectionWrp.forEach(function(item, index)
        {
            var progEnroll = item.value.lstProgEnroll;
            for(var i=0; i< progEnroll.length; i++)
            {
                if(progEnroll[i].isChecked)
                    progEnrollLst.push(progEnroll[i]); 
            }
        });
        
        if(lstUnassigned.length >0)
        {
            for(var i=0; i< lstUnassigned.length; i++)
            {
                if(lstUnassigned[i].sectionId == undefined || lstUnassigned[i].sectionId == '')
                {}
                else
                {
                    progEnrollLst.push(lstUnassigned[i]);
                }
            }
        }
        var action = component.get("c.createStudTermSection");
        action.setParams({
            "strProgrmEnroll": JSON.stringify(progEnrollLst),
            "objTrm": component.get("v.objTerm"),
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
                        this.showToast(component,'dismissible','Success','Student Section Successfully Allocated..!','success');
                        $A.get("e.force:closeQuickAction").fire();
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
    studPerSectionHlpr : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var studPerSection = component.get("v.objTerm.Actual_Students_Per_Section__c");
        var noOfStudEnroll = component.get("v.objTerm.Program_Plan__r.Number_of_Students_Enrolled__c");
        var noOfSection = component.get("v.objTerm.No_Of_Sections__c");
        if(studPerSection > noOfStudEnroll || studPerSection < noOfSection)
        {
            this.showToast(component,'dismissible','Failed','Student per Section can not be greater than Total No. of Students Enrolled/lesser than No. of Sections..!','error');
            component.set("v.objTerm.Actual_Students_Per_Section__c", null);
        }
        component.set("v.Spinner",false);
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