({
    doInitHelper : function(component, event, helper) 
    {
        var action = component.get("c.getProgramBatchDetails");
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               if(State === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {   
                                       var mapValues = [];
                                       var programbtch = response.getReturnValue().map_Prgmbtch;
                                       for ( var key in programbtch ) 
                                       {
                                           mapValues.push({value:programbtch[key], key:key});
                                       }
                                       component.set("v.MapProgbtch", mapValues);
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
    },
    OnchangeProgbtchhelper : function(component, event, helper) 
    {
        var prog = event.getSource().get("v.value"); 
        component.set("v.selectedProgbtch",prog);  
        component.set("v.inelgtyp",null);
        var listprogs = []; 
        component.set("v.listStudents",listprogs);
        
        var action = component.get("c.getSemesterDetails");
        action.setParams({"str_selprgId": prog})
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               if(State === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {   
                                       var mapValues = [];
                                       var semster = response.getReturnValue().map_Semster;
                                       for ( var key in semster ) 
                                       {
                                           mapValues.push({value:semster[key], key:key});
                                       }
                                       component.set("v.MapSemester", mapValues);
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
    },
    
    OnchangeSemshelper : function(component, event, helper) 
    {
        var Sems = event.getSource().get("v.value"); 
        component.set("v.selectedSem",Sems);
        component.set("v.inelgtyp",null);
    },
    
    selectAllCheckboxHelper : function(component, event, helper)
    {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedEnrollRecords = [];
        var listOfStudnts = component.get("v.listStudents");
        // play a for loop on all records list 
        for (var i = 0; i < listOfStudnts.length; i++) 
        {
            if (selectedHeaderCheck == true) 
            {
                listOfStudnts[i].objProgEnrlmnt.Issue_Hall_Ticket__c = true;
                component.set("v.selectedCount", listOfStudnts.length);
            } 
            else 
            {
                listOfStudnts[i].objProgEnrlmnt.Issue_Hall_Ticket__c = false;
                component.set("v.selectedCount", 0);
            }
            updatedEnrollRecords.push(listOfStudnts[i]);
        }
        component.set("v.listStudents", updatedEnrollRecords);
        
    },
    
    OnchangeEligibilityTypeHelper : function(component, event, helper)
    {
        //alert('=== Semester ===='+component.get("v.selectedSem"));
        var action = component.get("c.getStudentDetails");
        component.set("v.Spinner",true);
        action.setParams({"str_selSemId": component.get("v.selectedSem"),
                          "str_selectedEligbl": component.get("v.selectedelgtyp")});
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               if(State === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {   
                                       var responsedata = response.getReturnValue();
                                       /*alert('==== Response Data ====='+JSON.stringify(responsedata));
                                       alert('==== Response Data length ====='+response.getReturnValue().length);
                                       /*if(response.getReturnValue().length == 0)
                                       {
                                           alert('==== Enter If =====');
                                           this.showToast(component,'dismissible','Error','No Students Exists for the selected Semester....!','error');   
                                       }
                                       else
                                       {
                                           alert('==== Else ====');*/
                                           component.set("v.listStudents",responsedata);
                                           component.set("v.Spinner",false);  
                                       //}
                                       
                                   }
                                   else
                                   {
                                       component.set("v.Spinner",false);
                                       this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                   }
                               }
                               else
                               {
                                   component.set("v.Spinner",false);
                                   this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                               }
                           });
        $A.enqueueAction(action); 
        
    },
    
    SaveStudentsHelper : function(component, event, helper)
    {
        var list_Students = component.get("v.listStudents");
        var list_Enroll = [];
        
        for(var i=0;i<list_Students.length;i++)
        {
            if(list_Students[i].objProgEnrlmnt.Issue_Hall_Ticket__c == true)
            {
                list_Enroll.push(list_Students[i].objProgEnrlmnt);  
            }
            
        }
        
        //alert('==== Enrollments ====='+list_Enroll.length);
        var action = component.get("c.saveStudentsDetails");
        
        action.setParams({list_WrapProgs : list_Enroll});
        action.setCallback(this, function(response) 
                           {	
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {
                                       if(response.getReturnValue().strMessage === 'Success')
                                       {
                                           component.set("v.Spinner",true);
                                           this.showToast(component,'dismissible','Success','Allowed Students Successfully..!','success');
                                           component.set("v.Semester", null);
                                           component.set("v.Progbatch",null);
                                           component.set("v.inelgtyp",null);
                                           component.set("v.Spinner",false);
                                           
                                       }
                                       else
                                       {
                                           component.set("v.Spinner",false);
                                           this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                                       }
                                   }
                                   else
                                   {
                                       component.set("v.Spinner",false);
                                       this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                   }
                               }
                               else
                               {
                                   component.set("v.Spinner",false);
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
            "duration":'0.5'
        });
        toastEvent.fire();
    },
})