({
    getYearTypeHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getProgramPlans");
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   var result = response.getReturnValue();
                                   var items = [];
                                   for (var i = 0; i < result.length; i++) 
                                   {
                                       var item = {
                                           "label": result[i],
                                           "value": result[i]
                                       };
                                       items.push(item);
                                   }
                                   component.set("v.yearOptions", items);
                                   component.set("v.Spinner",false);
                               }
                               else
                               {
                                   component.set("v.Spinner",false);
                               }
                           });
        $A.enqueueAction(action);
    },
    getEnrollmentHlpr : function(component, event, helper)
    { 
         component.set('v.totalamountToBePushed',0);
        component.set('v.totalamountPushedSAP',0);
        component.set('v.selectedAmount',0);
         
        // alert('feeYear '+component.get("v.studentType"))
        component.set("v.Spinner",true);
        var feYearvar =  component.get("v.studentType");
        component.set("v.feeYearVar",feYearvar);
        var feYearvar2 =  component.get("v.feeYearVar");
      //  alert('feYearvar2==>'+feYearvar2)
        var action = component.get("c.getProgEnrollNoGRN");
        action.setParams({
            "recId": component.get("v.recordId"),
            "feeYear": component.get("v.studentType")
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   var result = response.getReturnValue().lstPrgEnroll;
                                   var resultPushedSap = response.getReturnValue().lstPrgEnrollPushedSap;
                                   if(result.length > 0)
                                   {
                                       component.set("v.progmEnrollmentLst", result);
                                       component.set("v.confStudSRNLst", resultPushedSap);
                                       var totalamount = 0;  
                                       for(var i = 0;  i < result.length; i++)
                                       {
                                           var TutionFee = 0;
                                           var UniversityFee = 0;
                                          
                                           if(result[i].Tuition_Fee__c != null && result[i].Tuition_Fee__c != undefined) TutionFee = result[i].Tuition_Fee__c;
                                           if(result[i].University_Fee__c != null && result[i].University_Fee__c != undefined) UniversityFee = result[i].University_Fee__c;
                                       		
                                           totalamount = totalamount + TutionFee+UniversityFee;
                                       } 
                                       
                                       component.set('v.totalamountToBePushed',totalamount);
                                       
                                       
                                       var totalamountPushedToSAP = 0;  
                                       for(var i = 0;  i < resultPushedSap.length; i++)
                                       {
                                           var TutionFee = 0;
                                           var UniversityFee = 0;
                                          
                                           if(resultPushedSap[i].Tuition_Fee__c != null && resultPushedSap[i].Tuition_Fee__c != undefined) TutionFee = resultPushedSap[i].Tuition_Fee__c;
                                           if(resultPushedSap[i].University_Fee__c != null && resultPushedSap[i].University_Fee__c != undefined) UniversityFee = resultPushedSap[i].University_Fee__c;
                                       		
                                           totalamountPushedToSAP = totalamountPushedToSAP + TutionFee+UniversityFee;
                                       }                                     
                                       component.set('v.totalamountPushedSAP',totalamountPushedToSAP);
                                   }
                                   else
                                   {
                                       component.set("v.progmEnrollmentLst", result);
                                       component.set("v.confStudSRNLst", resultPushedSap);
                                       var totalamount = 0;                                       
                                       for(var i = 0;  i < resultPushedSap.length; i++)
                                       {
                                           var TutionFee = 0;
                                           var UniversityFee = 0;
                                          
                                           if(resultPushedSap[i].Tuition_Fee__c != null && resultPushedSap[i].Tuition_Fee__c != undefined) TutionFee = resultPushedSap[i].Tuition_Fee__c;
                                           if(resultPushedSap[i].University_Fee__c != null && resultPushedSap[i].University_Fee__c != undefined) UniversityFee = resultPushedSap[i].University_Fee__c;
                                       		
                                           totalamount = totalamount + TutionFee+UniversityFee;
                                       }                                     
                                       component.set('v.totalamountPushedSAP',totalamount);
                                       
                                       
                                       var totalamountTobePushed = 0;                                       
                                       for(var i = 0;  i < result.length; i++)
                                       {
                                           var TutionFee = 0;
                                           var UniversityFee = 0;
                                           
                                           if(result[i].Tuition_Fee__c != null && result[i].Tuition_Fee__c != undefined) TutionFee = result[i].Tuition_Fee__c;
                                           if(result[i].University_Fee__c != null && result[i].University_Fee__c != undefined) UniversityFee = result[i].University_Fee__c;
                                           totalamountTobePushed = totalamountTobePushed + TutionFee+UniversityFee;
                                       }                                     
                                       component.set('v.totalamountToBePushed',totalamountTobePushed);
                                   }
                                   
                                   component.set("v.Spinner",false);
                               }
                           });
        $A.enqueueAction(action);
    },
    getEnrollmentHlpr2 : function(component, event, helper)
    { 
       // alert('enetering 2');
        // alert('feeYear '+component.get("v.studentType"))
        component.set("v.Spinner",true);
        var feYearvar =  component.get("v.feeYearVar");
        
       // alert('feYearvar '+feYearvar)
        component.set("v.studentType",feYearvar);
        var action = component.get("c.getProgEnrollNoGRN");
        action.setParams({
            "recId": component.get("v.recordId"),
            "feeYear": component.get("v.studentType")
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   var result = response.getReturnValue().lstPrgEnroll;
                                   var resultPushedSap = response.getReturnValue().lstPrgEnrollPushedSap;
                                   if(result.length > 0)
                                   {
                                       component.set("v.progmEnrollmentLst", result);
                                       component.set("v.confStudSRNLst", resultPushedSap);
                                       
                                       
                                   }
                                   else
                                   {
                                       component.set("v.progmEnrollmentLst", result);
                                       component.set("v.confStudSRNLst", resultPushedSap);
                                       
                                       
                                   }
                                   
                                   component.set("v.Spinner",false);
                               }
                           });
        $A.enqueueAction(action);
    },
    pushToSAPHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var selectedEnrollments = component.get("v.progmEnrollmentLst").filter(function(enrollment) {
            return enrollment.Push_Check_Box__c === true;
        });
        
        if (selectedEnrollments.length === 0) {
            this.showToast(component, 'sticky', 'Error', 'Select at least one record', 'error');
            component.set('v.Spinner', false);
            
            return;
        }
        var action = component.get("c.PushDemandsToSAP");
        action.setParams({
            "recId": component.get("v.recordId"),
            "lstPrgEnroll": component.get("v.progmEnrollmentLst"),
            "feeYear": component.get("v.studentType")
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   var result = response.getReturnValue();
                                   component.set("v.progmEnrollmentLst", null);
                                   component.set("v.confStudSRNLst", null);
                                   component.set("v.studentType", null);
                                   this.getYearTypeHlpr(component, event, helper);
                                   component.set("v.showProgressBar", true);
                                   this.getPrcsPercentageHelper(component, event, helper);
                                   
                                   component.set("v.Spinner",false);
                               }
                           });
        component.set("v.Spinner",false);
        $A.enqueueAction(action);
    },
    
    getPrcsPercentageHelper : function(component, event, helper)
    {  
        //component.set("v.showProcessBar", false);
        
        var interval = setInterval($A.getCallback(function () {
            var jobStatus = component.get("c.getProcessPercentage");
            if(jobStatus != null)
            {
                jobStatus.setCallback(this, function(jobStatusResponse){
                    var state = jobStatus.getState();
                    if (state === "SUCCESS"){
                        var job = jobStatusResponse.getReturnValue();
                        //alert('=== Job ===='+JSON.stringify(job));
                        
                        component.set("v.processedcount",job.AsyncJob_New.JobItemsProcessed);
                        component.set("v.totalcount",job.AsyncJob_New.TotalJobItems);
                        
                        /*alert('==== ProcessedCount ==='+component.get("v.processedcount"));
                                    alert('==== TotalCount ==='+component.get("v.totalcount"));*/
                            var processedPercent = 0;
                            if(job.AsyncJob_New.JobItemsProcessed != 0)
                            {
                                processedPercent = (job.AsyncJob_New.JobItemsProcessed/job.AsyncJob_New.TotalJobItems) * 100;
                            }
                            var progress = component.get('v.progress');
                            /*component.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                            if(progress === 100)
                            {
                                
                                
                                component.set('v.showProgressBar',false);
                                //$A.get('e.force:refreshView').fire();
                                //$A.get("e.force:closeQuickAction").fire();
                                
                            }*/
                        if (progress === 100) {
                            clearInterval(interval);
                            component.set('v.showProgressBar', false);
                            
                            // Call the enrollment helper method here
                            helper.getEnrollmentHlpr2(component, event, helper);
                            
                            // Any other actions you want to perform when progress reaches 100
                        } else {
                            component.set('v.progress', processedPercent);
                        }

                        }
                    });
                    $A.enqueueAction(jobStatus);
                }
            }), 2000);
        },
        showToast : function(component, mode, title, message, type){
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