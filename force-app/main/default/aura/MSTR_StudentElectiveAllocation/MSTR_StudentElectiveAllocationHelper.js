({
    doInitHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var action = component.get("c.displayCourseOfferingRecords");	
        action.setParams({"TermId": component.get("v.recordId")});              
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();   
                    component.set("v.ProgPlanName", retVal.ProgramPlanName);
                    component.set("v.objTermName", retVal.TermName);    
                    component.set("v.lstCourseOfferingdata",retVal.lstCourseOffrData);                                      
                }
                component.set("v.Spinner", false);
            }
            else
            {
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
            
        });       
        $A.enqueueAction(action);	
    },
    getPreferenceHlpr : function(component, event, helper)
    {        
        var action = component.get("c.getPreference");
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                var PreferenceMap = [];
                var result = response.getReturnValue();
                
                for(var key in result) 
                {
                    PreferenceMap.push({
                        key: key, 
                        value: result[key]
                    });
                }
                component.set("v.MapPreference",PreferenceMap); 
            }
        });
        $A.enqueueAction(action);
    },
    getElectiveCourseDetailsHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);       
        var courseElectiveId = component.get("v.courseElectId");                
        var action = component.get("c.getElectiveCourses");
        action.setParams({
            "courseElectiveId": courseElectiveId,
            "TermId": component.get("v.recordId")
        });  
        action.setCallback(this, function(response)
        {
            var state = response.getState();                               
            if (state === "SUCCESS")
            {                       
                var preferenceVal = response.getReturnValue().map_subjects;  
                component.set("v.HeaderName",response.getReturnValue().HeaderName);
                var subjMap = [];
                for(var key in preferenceVal) 
                {
                    if(preferenceVal[key].lstStudPrefElect.length>0)
                    {
                        var batch = {
                            "value": preferenceVal[key],
                            "key": key
                        };
                        subjMap.push(batch);
                    }
                }                                          
                component.set("v.SubjectWrp", subjMap);  
                var subPicklist = response.getReturnValue().map_subjectPicklist;  
                var subjectPicklistMap = [];
                for(var key in subPicklist) 
                {
                    var sub = {
                        "value": subPicklist[key],
                        "key": key
                    };
                    subjectPicklistMap.push(sub);
                } 
                component.set("v.subjectDetailsMap", subjectPicklistMap);
                component.set("v.showCreateSubject", false);
                component.set("v.isModalOpen", true);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    selectAllCheckboxHlpr : function(component, event, helper)
    {
    	var selectedHeaderCheck = event.getSource().get("v.value");
        var subject = event.getSource().get("v.text");
        var subjectIndex = subject.split('_')[0];
        var subjectId = subject.split('_')[1];
        var subjectWrp = component.get("v.SubjectWrp");
        
        subjectWrp.forEach(function(item, subjectindex)
        {
            var subject = [];
            subject = item.value;
            var subId = item.key;
            if(subId == subjectId)
            {
                for(var i=0; i< subject.lstStudPrefElect.length; i++)
                {
                    if(selectedHeaderCheck == true)
                        subject.lstStudPrefElect[i].isChecked = true;
                    else
                        subject.lstStudPrefElect[i].isChecked = false;
                }
            }
        });
        component.set("v.SubjectWrp", subjectWrp);
    },
    saveCourseConnectionHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        component.set("v.showConfirmSubject", true);
        component.set("v.Spinner",false);
    },
    handleAllocateHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var subjectWrp = component.get("v.SubjectWrp");
        var studPreflLst = [];
        subjectWrp.forEach(function(item, index)
        {
            var lstStudPref = item.value.lstStudPrefElect;
            for(var i=0; i< lstStudPref.length; i++)
            {
                if(lstStudPref[i].isChecked)
                {
                    if((item.value.newSubjectId == undefined || item.value.newSubjectId == '')){}
                    else
                    {
                        var subId = item.value.newSubjectId.split('_')[0];
                        var courseCode = item.value.newSubjectId.split('_')[1];
                        lstStudPref[i].newSubject_Id = subId;
                        lstStudPref[i].newCourseOfferCode = courseCode;
                        studPreflLst.push(lstStudPref[i]);
                    }
                }
            }
        });
        
        if(studPreflLst.length > 0)
        {
            var action = component.get("c.createCourseConnection");
            action.setParams({
                "courseConn": JSON.stringify(studPreflLst),
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
                            $A.get('e.force:refreshView').fire();
                            this.showToast(component,'dismissible','Success','Student Elective Successfully Allocated..!','success');
                            this.doInitHlpr(component,event,helper); 
                            component.set("v.isModalOpen", false);
                            component.set("v.showConfirmSubject", false);
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
        else
        {
            this.doInitHlpr(component,event,helper);
            this.showToast(component,'dismissible','Success','Student Elective Successfully Allocated..!','success');
            setTimeout(function() 
            {
                component.set("v.isModalOpen", false);
                component.set("v.showConfirmSubject", false);
                component.set("v.Spinner",false);
            }, 1000);
        }
    },
    activeSubjectHlpr : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var index = event.getSource().get("v.name");
        var lstCourseOffer = component.get("v.lstCourseOfferingdata");
        
        /*if(lstCourseOffer[index].assigned == 0 || (lstCourseOffer[index].assigned == undefined || lstCourseOffer[index].assigned == ''))
        {
            this.showToast(component,'dismissible','Failed','No Students Assigned to Make Elective as Active..!','error');
            component.set("v.Spinner",false);
        }
        else
        {*/
            var action = component.get("c.ActivateCourseOffering");	
            action.setParams({
                "strCourOffer": JSON.stringify(lstCourseOffer[index])
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
                            this.showToast(component,'dismissible','Success','Subject Activated/Deactivated Successfully..!','success');
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
                } 
            });       
            $A.enqueueAction(action);
        //}
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