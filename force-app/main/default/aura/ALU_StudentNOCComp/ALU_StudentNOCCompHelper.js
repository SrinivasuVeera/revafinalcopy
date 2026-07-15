({
    doInitHelper : function(component, event, helper) 
    {
        var action = component.get("c.getStntResltDetails");
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               if(State === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {                                         
                                       component.set("v.listFeestudents",response.getReturnValue().list_StudentFee);
                                       component.set("v.listResults",response.getReturnValue().list_Results);
                                       component.set("v.listUpdateCon",response.getReturnValue().list_Con);
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
    
    OnchngStdntPstHelper : function(component, event, helper) 
    {
        var stdntval = event.getSource().get("v.value"); 
        component.set("v.SelectedPosition",stdntval);
        
        component.set("v.objCont.Placement__c",null);
        component.set("v.objCont.Company__c",null);
        component.set("v.objCont.Designation__c",null);
        component.set("v.objCont.Location__c",null);
        component.set("v.objCont.Date_of_Joining__c",null);
        component.set("v.objCont.Joining_REVA__c",null);
        component.set("v.objCont.Which_Program__c",null);        
        component.set("v.objCont.University_Name__c",null);
        component.set("v.objCont.Date_of_Joining_HS__c",null);
        component.set("v.objCont.Country_HS__c",null);
        component.set("v.objCont.Location_HS__c",null);
        component.set("v.objCont.Firm_Name__c",null);
        component.set("v.objCont.Started__c",null);
        component.set("v.objCont.Designation_SU__c",null);
        component.set("v.objCont.Location_SU__c",null);
        component.set("v.objCont.Type_of_Business__c",null);
        component.set("v.objCont.Location_B__c",null);
        component.set("v.objCont.Type_of_Job_Targeting__c",null);
        component.set("v.objCont.Coaching_required_from_REVA_University__c",null);
        component.set("v.fileNameUploaded",null);
        component.set("v.fileName",null);
        component.set("v.objCont.Others__c",null);
        
        if(stdntval == "Placement Details")
        {
            component.set("v.PlacedCon",true);
            component.set("v.HigherStudiesCon",false);
            component.set("v.StartupEntrepreneurCon",false);
            component.set("v.FamilybusinessCon",false);
            component.set("v.GovtCon",false);
            component.set("v.OtherCon",false);
        }
        else if(stdntval == "Higher Studies")
        {
            component.set("v.PlacedCon",false);
            component.set("v.HigherStudiesCon",true);
            component.set("v.StartupEntrepreneurCon",false);
            component.set("v.FamilybusinessCon",false);
            component.set("v.GovtCon",false);
            component.set("v.OtherCon",false);           
        }
            else if(stdntval == "Startup/Entrepreneur")
            {
                component.set("v.PlacedCon",false);
                component.set("v.HigherStudiesCon",false);
                component.set("v.StartupEntrepreneurCon",true);
                component.set("v.FamilybusinessCon",false);
                component.set("v.GovtCon",false);
                component.set("v.OtherCon",false);           
            }
                else if(stdntval == "Looking into the family business")
                {
                    component.set("v.PlacedCon",false);
                    component.set("v.HigherStudiesCon",false);
                    component.set("v.StartupEntrepreneurCon",false);
                    component.set("v.FamilybusinessCon",true);
                    component.set("v.GovtCon",false);
                    component.set("v.OtherCon",false);           
                }  
                    else if(stdntval == "Civil services/ Government job")
                    {
                        component.set("v.PlacedCon",false);
                        component.set("v.HigherStudiesCon",false);
                        component.set("v.StartupEntrepreneurCon",false);
                        component.set("v.FamilybusinessCon",false);
                        component.set("v.GovtCon",true);
                        component.set("v.OtherCon",false);           
                    } 
                        else if(stdntval == "Other")
                        {
                            component.set("v.PlacedCon",false);
                            component.set("v.HigherStudiesCon",false);
                            component.set("v.StartupEntrepreneurCon",false);
                            component.set("v.FamilybusinessCon",false);
                            component.set("v.GovtCon",false);
                            component.set("v.OtherCon",true);           
                        } 
                            else if(stdntval == "" )
                            {
                                component.set("v.PlacedCon",false);
                                component.set("v.HigherStudiesCon",false);
                                component.set("v.StartupEntrepreneurCon",false);
                                component.set("v.FamilybusinessCon",false);
                                component.set("v.GovtCon",false);
                                component.set("v.OtherCon",false);     
                            }
    },
    
    getstntPstnHelper : function(component, event, helper) 
    {
        var action = component.get("c.getStudentPositionDetails");
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var fieldMap = [];
                                   for(var key in result)
                                   {
                                       fieldMap.push({key: key, value: result[key]});
                                   }
                                   component.set("v.MapStudentPosition", fieldMap);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getPalcmntDetlsHelper : function(component, event, helper) 
    {
        var action = component.get("c.getPalcementDetails");
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var fieldMap = [];
                                   for(var key in result)
                                   {
                                       fieldMap.push({key: key, value: result[key]});
                                   }
                                   component.set("v.MapPlacement", fieldMap);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getJningDetlsHelper : function(component, event, helper) 
    {
        var action = component.get("c.getJoiningReva");
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var fieldMap = [];
                                   for(var key in result)
                                   {
                                       fieldMap.push({key: key, value: result[key]});
                                   }
                                   component.set("v.MapJngReva", fieldMap);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getStrtedHelper : function(component, event, helper) 
    {
        var action = component.get("c.getStarted");
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var fieldMap = [];
                                   for(var key in result)
                                   {
                                       fieldMap.push({key: key, value: result[key]});
                                   }
                                   component.set("v.MapStarted", fieldMap);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    getCoachingHelper : function(component, event, helper) 
    {
        var action = component.get("c.getCoaching");
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var result = response.getReturnValue();
                                   var fieldMap = [];
                                   for(var key in result)
                                   {
                                       fieldMap.push({key: key, value: result[key]});
                                   }
                                   component.set("v.MapCoaching", fieldMap);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    OnchngPlacmntHelper : function(component, event, helper)
    {
        var stdntval = event.getSource().get("v.value"); 
        component.set("v.SelectedPlcment",stdntval); 
    },
    
    OnCoachingHelper : function(component, event, helper)
    {
        var chng = event.getSource().get("v.value");
        component.set("v.SelectedCoaching",chng); 
    },
    
    OnchangeStrtdfunctnHelper : function(component, event, helper)
    {
        var strd = event.getSource().get("v.value");
        component.set("v.SelectedStrtd",strd); 
    },
    
    savenewmainHelper : function(component, event, helper)
    {
        var filename = component.get('v.fileName');
        
        if(filename != undefined)
        {
            var files = component.find('fileId').get("v.files");
            
            if (files && files.length > 0) 
            {
                var file = files[0];
                var reader = new FileReader();
                reader.onload = $A.getCallback(function() 
                                               {
                                                   var dataURL = reader.result;
                                                   var base64 = 'base64,';
                                                   var dataStart = dataURL.indexOf(base64) + base64.length;
                                                   dataURL = dataURL.substring(dataStart);
                                                   helper.SaveContactDetailsHelper(component, event, helper, dataURL, component.get("v.fileName"));
                                               });
                reader.readAsDataURL(file);
            } 
            else 
            {
                helper.SaveContactDetailsHelper(component, event, helper, '', '');
            }
        }
        else
        {
            helper.SaveContactDetailsHelper(component, event, helper, '', ''); 
        }
    },
    
    SaveContactDetailsHelper : function(component, event, helper, file, fileName)
    {
        var action = component.get("c.saveContacts");
        
        action.setParams({"str_Pos": component.get("v.objCont.Position_of_Student__c"),
                          "str_plc": component.get("v.objCont.Placement__c"),
                          "str_Cmp": component.get("v.objCont.Company__c"),
                          "str_Desig" : component.get("v.objCont.Designation__c"),
                          "str_loc" : component.get("v.objCont.Location__c"),
                          "dt_doj" : component.get("v.objCont.Date_of_Joining__c"),
                          "str_jngrv" : component.get("v.objCont.Joining_REVA__c"),
                          "str_prgm": component.get("v.objCont.Which_Program__c"),
                          "str_unvrst": component.get("v.objCont.University_Name__c"),
                          "dt_dhs": component.get("v.objCont.Date_of_Joining_HS__c"),
                          "str_cnths": component.get("v.objCont.Country_HS__c"),
                          "str_lochs" : component.get("v.objCont.Location_HS__c"),
                          "str_frname": component.get("v.objCont.Firm_Name__c"),
                          "str_strted": component.get("v.objCont.Started__c"),
                          "str_desgsu": component.get("v.objCont.Designation_SU__c"),
                          "str_locsu": component.get("v.objCont.Location_SU__c"),
                          "str_typbs": component.get("v.objCont.Type_of_Business__c"),
                          "str_locb": component.get("v.objCont.Location_B__c"),
                          "str_typjtrgt": component.get("v.objCont.Type_of_Job_Targeting__c"),
                          "str_chng": component.get("v.objCont.Coaching_required_from_REVA_University__c"),
                          "file": file,
                          "fileName": fileName,
                          "str_Othr":component.get("v.objCont.Others__c")
                         });
        
        action.setCallback(this, function(response) 
                           {	
                               var state = response.getState();
                               
                               if(state === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {
                                       if(response.getReturnValue().str_Message === 'Success')
                                       {
                                           this.showToast(component,'dismissible','Success','Students NOC Form Updated Successfully','success');
                                           //this.doInitHelper(component, event, helper);
                                           component.set("v.showStudentData",false);
        								   component.set("v.showNocForm",true);
                                           $A.get('e.force:refreshView').fire();
                                           
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