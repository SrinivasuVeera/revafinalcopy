({
    doInitHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        var action = component.get("c.DisplayFacultyRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var mapAccFacultyValues = [];
                var result = response.getReturnValue();
                for(var key in result){
                    mapAccFacultyValues.push({key: key, value: result[key]});
                }
                component.set("v.MapFacultyName", mapAccFacultyValues);
                component.set("v.SelectedStDate",'');
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);	
    },
    ChangeProgramPlanHlpr : function(component, event, helper)
    {        
        var SelProgramType = component.get("v.SelectedProgramTypeId"); 
        var SelFacultyId = component.get("v.SelectedFacultyId");
        var action = component.get("c.DisplayAccount");
        action.setParams({'ProgramType':SelProgramType,
                          'FacultyId':SelFacultyId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    component.set("v.showAccountTable",true);
                    component.set("v.List_Account",response.getReturnValue());
                    component.set("v.SelectedStDate",'');
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
    OnchangeStartDateHlpr : function(component, event, helper)
    {        
        let dt = component.get("v.SelectedStDate");  
        let dtlength = dt.length;        
        if(dt.length == 4)
        {            
            dt = dt;
            var today = $A.localizationService.formatDate(new Date(), "yyyy");        
        }
        else
        {
            return;
        }
        
       /* if(dt < today)
        {
            this.showToast(component,'dismissible','Error','Do Not Select Previous Dates','error');              
            component.set("v.showNextTable",false);
        }*/
        //else
        {
            component.set("v.showNextTable",true);
        }
    },
    NextActionHlpr : function(component, event, helper)
    {       
        component.set("v.hideparam",false);
        var SelStDate = component.get("v.SelectedStDate");      
        var formatedDate = SelStDate+'-'+'07'+'-'+'01';         
        SelStDate = formatedDate;
        var listaccount = component.get("v.List_Account");
        var action = component.get("c.DisplayProgramPlan");
        action.setParams({'lst_acc':listaccount,'stdate' : SelStDate});
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    component.set("v.List_ProgramPlan",response.getReturnValue());
                    component.set("v.showNextTable",false);
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
    ValidationHlpr : function(component, event, helper)
    {  
        var listPrgPlan = component.get("v.List_NewProgramPlan");     
        var action = component.get("c.ExistingProgramPlan");
        action.setParams({'lst_programPlan':listPrgPlan});
        action.setCallback(this, function(response) {
            var state = response.getState();          
            if(state === "SUCCESS") 
            {                
                if(response.getReturnValue() != undefined && response.getReturnValue().Errmsg != null)
                {
                    //this.NextActionHlpr(component, event, helper);
                    var retVal = response.getReturnValue().Errmsg;
                    this.showToast(component,'dismissible','Failed',retVal,'error'); 
                }
                else
                {   
                    this.OnSaveHlpr(component, event, helper);                   
                }
                component.set("v.Spinner", false); 
            }
            else{
                //this.NextActionHlpr(component, event, helper);
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    OnSaveHlpr : function(component, event, helper)
    {  
        var listPrgPlan = component.get("v.List_NewProgramPlan");       
        var action = component.get("c.CreateProgramPlan");
        action.setParams({'lst_programPlan':listPrgPlan});
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if(state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                    if(response.getReturnValue().Errmsg === 'Success')
                    {
                        this.showToast(component,'dismissible','success','Program Batches Created Successfully','success');
                        component.set("v.SelectedFacultyId",null);
                        component.set("v.SelectedProgramTypeId",null); 
                        component.set("v.Spinner", false);
                        var progPlan =[];
                        component.set("v.List_ProgramPlan",progPlan); 
                        var acclist =[];
                        component.set("v.List_Account",acclist);
                        component.set("v.hideparam",true);
                    }
                    else
                    {
                        this.showToast(component,'dismissible','Failed',response.getReturnValue().Errmsg,'error');
                        component.set("v.Spinner",false);
                    }
                }
                else
                {
                    this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                    component.set("v.Spinner",false);
                }
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }  
        });       
        $A.enqueueAction(action);
    },
    getProgramTypeHlpr : function(component, event, helper)
    {        
        var action = component.get("c.getProgramType");
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if (state === "SUCCESS")
                               {
                                   var ProgTypeMap = [];
                                   var result = response.getReturnValue();
                                   
                                   for ( var key in result ) {
                                       ProgTypeMap.push({key: key, value: result[key]});
                                   }
                                   component.set("v.Map_ProgramType",ProgTypeMap); 
                               }
                               
                           });
        $A.enqueueAction(action);
    },
    selectAllCheckboxHelper : function(component, event, helper)
    {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedVisitsRecords = [];
        var listOfVisits = component.get("v.List_ProgramPlan");
        // play a for loop on all records list 
        for (var i = 0; i < listOfVisits.length; i++) 
        {
            if (selectedHeaderCheck == true) 
            {
                listOfVisits[i].isChecked = true;
                component.set("v.selectedCount", listOfVisits.length);
            } 
            else 
            {
                listOfVisits[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedVisitsRecords.push(listOfVisits[i]);
        }
        component.set("v.List_ProgramPlan", updatedVisitsRecords);
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