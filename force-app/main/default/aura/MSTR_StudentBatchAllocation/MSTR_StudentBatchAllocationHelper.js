({
    doInithelper : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getTermDetails");
        action.setParams({"termId": component.get("v.recordId")});              
        action.setCallback(this, function(result) 
        {
            var state = result.getState();
            if (state === "SUCCESS")
            {
                var resultData = result.getReturnValue();
                //alert('==== Result ====='+JSON.stringify(resultData));                                                                
                component.set("v.lstSecterms",resultData.lst_SemTerms);
                component.set("v.strTerm",resultData.objSemTerm.Name);
                component.set("v.strprogram",resultData.objSemTerm.Program_Batch__r.Name);
                component.set("v.Spinner",false);
            }	
            else
            {
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);		
    },
    getBatchesDetailsHelper : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var btchselected = event.currentTarget.getAttribute("data-Id");
        var SectionName = event.currentTarget.getAttribute("data-value");
        component.set("v.selectedSection",SectionName);
        
        var action = component.get("c.getStudentMappingDetails");
        action.setParams({
            "str_TermId": btchselected
        });
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state === "SUCCESS")
            {
                var result = response.getReturnValue();
                var batches = response.getReturnValue().map_BatchWrp;
                var batchMap = [];
                for(var key in batches)
                {
                    var batch = {
                            "value": batches[key],
                            "key": key
                        };
                        batchMap.push(batch);
                }
                component.set("v.batchWrp", batchMap);
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
                component.set("v.selectedTab", batchMap[0].value.batchNo);
                var bacthes  = response.getReturnValue().map_Batches;
                var batchesMap = [];
                for(var key in bacthes)
                {
                    var btch = {
                        "label": bacthes[key],
                        "value": key
                    };
                    batchesMap.push(btch);
                }
                component.set("v.MapMovetoBatches", batchesMap);
                component.set("v.batcheDetails", response.getReturnValue().map_BatcheDetails);
                component.set("v.Spinner",false);
            }
            {
                component.set("v.Spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    handleAllocateYesHelper : function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var stdntList = [];
        var btchWrp = component.get("v.batchWrp");
        var lstUnassigned = component.get("v.lstUnassigned");
        btchWrp.forEach(function(item, index)
        {
            var studentMappinglist = item.value.lst_studentmap;
            for(var i=0; i< studentMappinglist.length; i++)
            {
                if(studentMappinglist[i].isChecked)
                    stdntList.push(studentMappinglist[i]); 
            }
        });
        
        if(lstUnassigned.length >0)
        {
            for(var i=0; i< lstUnassigned.length; i++)
            {
                if(lstUnassigned[i].batchId == undefined || lstUnassigned[i].batchId == '')
                {}
                else
                {
                    stdntList.push(lstUnassigned[i]);
                }
            }
        }
        
        var action = component.get("c.saveStudentTerms");
        action.setParams({
            "strStudntTerms": JSON.stringify(stdntList),
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
                        this.showToast(component,'dismissible','Success','Student Batches Successfully Allocated..!','success');
                        //this.doInithelper(component, event, helper);
                        component.set('v.showConfirmStudents', false);
                        component.set('v.isModalOpen', false);
                        this.navigateToRecord(component, event, helper, component.get("v.recordId"));
                        //$A.get('e.force:refreshView').fire();
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
    onChangeSelectedBatchesHelper : function(component, event, helper)
    {
        var index = event.getSource().get("v.name");
        var Value = event.getSource().get("v.value");
        var batchIndex = index.split('_')[0];
        var studIndex = index.split('_')[1];
        var bthWrp = component.get("v.batchWrp");
        bthWrp[batchIndex].value.lst_studentmap[studIndex].batchId = bthWrp[Value-1].value.btchId;
        bthWrp[batchIndex].value.lst_studentmap[studIndex].btchName = bthWrp[Value-1].value.btchName;
        var oldBatch = bthWrp[batchIndex].value.lst_studentmap[studIndex].oldBatchId;
        var newBatch = bthWrp[batchIndex].value.lst_studentmap[studIndex].batchId;
        if(oldBatch == undefined || oldBatch == '')
        {}
        else
        {
            if(oldBatch == newBatch)
                bthWrp[batchIndex].value.lst_studentmap[studIndex].isChecked = false;
            else
                bthWrp[batchIndex].value.lst_studentmap[studIndex].isChecked = true;
        }
        component.set("v.batchWrp", bthWrp);        
    },
    saveStudentTermMappingHelper: function(component, event, helper)
    {       
        component.set("v.Spinner",true);
        var stdntList = [];
        var btchWrp = component.get("v.batchWrp");
        var lstUnassigned = component.get("v.lstUnassigned");
        btchWrp.forEach(function(item, index)
        {
            var studentMappinglist = item.value.lst_studentmap;
            for(var i=0; i< studentMappinglist.length; i++)
            {
                if(studentMappinglist[i].isChecked)
                    stdntList.push(studentMappinglist[i]); 
            }
        });
        //alert('lstUnassigned=='+JSON.stringify(lstUnassigned));
        if(lstUnassigned.length >0)
        {
            for(var i=0; i< lstUnassigned.length; i++)
            {
                if(lstUnassigned[i].batchId == undefined || lstUnassigned[i].batchId == '')
                {}
                else
                {
                    stdntList.push(lstUnassigned[i]);
                }
            }
        }
        //alert('===== List -======='+JSON.stringify(stdntList));
        
        if(stdntList.length > 0)
        {
            component.set('v.showConfirmStudents', true);
            component.set("v.Spinner",false);
        }
        else
        {
			this.showToast(component,'dismissible','Failed','Please Change atleast one Student Batch..!','error');            
            component.set("v.Spinner",false);
        }
    },
    changeUnAssignBatchesHlpr : function(component, event, helper)
    {
        var index = event.getSource().get("v.name");
        var Value = event.getSource().get("v.value");
        var lstUnassigned = component.get("v.lstUnassigned");
        var termBatchDetails = component.get("v.batcheDetails");
        lstUnassigned[index].batchId = termBatchDetails[Value].Id;
        lstUnassigned[index].batchName = termBatchDetails[Value].Name;
        lstUnassigned[index].isChecked = true;
        component.set("v.lstUnassigned", lstUnassigned);
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