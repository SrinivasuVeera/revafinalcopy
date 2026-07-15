({
    doInitHelper : function(component, event, helper)
    {
        var action = component.get("c.getDocumentDetails");
        component.set("v.Spinner",true);
        action.setParams({"ContactId": component.get("v.recordId")});              
        action.setCallback(this, function(result) 
                           {
                               var state = result.getState();
                               if (state === "SUCCESS")
                               {
                                   component.set("v.Spinner",false);
                                   var resultData = result.getReturnValue();
                                   component.set("v.lstDocuments",resultData);                                   
                                   var datacheck = 0;
                                   for(var i=0; i<resultData.length; i++)
                                   {
                                       if(resultData[i].enableData == true) {
                                           datacheck = datacheck+1; 
                                       }
                                   }
                                   if(datacheck > 0) {
                                       component.set("v.showdata",true); 
                                   }
                               }
                           });
        $A.enqueueAction(action);		
    },
    getContactDetails: function(component, event, helper)
    {
        var action = component.get("c.getContactDetails");
        action.setParams({"ConId": component.get("v.recordId") });              
        action.setCallback(this, function(result) 
                           {
                               var state = result.getState();
                               if (state === "SUCCESS")  {
                                   var resultData = result.getReturnValue();                                   
                                   component.set("v.strStudentName", resultData.objCon.Name);  
                                   component.set("v.strProgramName", resultData.objCon.Program_Batch__r.Name); 
                               }
                           });
        $A.enqueueAction(action);	 
    },
    getVerfStatusHelper: function(component, event, helper) 
    {               
        var action = component.get("c.getverificationStatus");
        action.setCallback(this, function(response)  
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") {
                                   component.set("v.lstVerfStatus",response.getReturnValue());                                   
                               }
                           });
        $A.enqueueAction(action);	
    },
    onChangeVerificationStatusHelper: function(component, event, helper)
    {
        var verfchang = event.getSource().get("v.value"); 
        component.set("v.SelectedVerfStatus",verfchang); 
    },
    
    saveReturnHelper: function(component, event, helper,fromWhere)
    {
        
        var list_document = component.get("v.lstDocuments");
        var list_Updoc = [];
        for(var i=0;i<list_document.length;i++)
        {
            list_Updoc.push(list_document[i].objEducationHistory);
        }
        
        var errorCount = 0;
        var allReqFields = component.find('inputReq');
        /*var listverstatus =component.get("v.lstDocuments");
        var hardcopycount =0;
        for(var i= 0; i<listverstatus.length; i++)
        {
            if(listverstatus[i].objEducationHistory.hed__Verification_Status__c == 'Approved' && listverstatus[i].objEducationHistory.Received_Hardcopy__c == false)
            {
                hardcopycount =hardcopycount+1; 
            }
        }
        
        var listMandatory = component.get("v.lstDocuments");
        var srnmandatorycount = 0;
        
        for(var i= 0; i<listMandatory.length; i++)
        {
            if(listMandatory[i].objEducationHistory.hed__Verification_Status__c == 'Pending' && listMandatory[i].objEducationHistory.Mandatory_for_SRN_Generation__c == true)
            {
                srnmandatorycount =srnmandatorycount+1; 
            }
        }*/
        
        if(allReqFields)
        {
            if(allReqFields.length) 
            {
                var allValid = allReqFields.reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                if (!allValid) {
                    errorCount++;
                }
            }else{
                var allValid = allReqFields;
                if (!allValid.get('v.validity').valid) 
                {
                    errorCount++;
                }
            }
        }
        if(errorCount > 0)
        {
            this.showToast(component,'dismissible','Error','Fill all mandatory fields...!','error');
        }
        /* else if(hardcopycount > 0)
        {
            this.showToast(component,'dismissible','Error','HardCopy is mandatory on Approve...!','error');  
        }
            else if(srnmandatorycount > 0)
            {
                this.showToast(component,'dismissible','Error','Document Status is Pending...!','error'); 
            }*/
        else {
            
            var action = component.get("c.saveDocuments");
            action.setParams({"lst_EducationHistories": list_Updoc});
            action.setCallback(this, function(response) 
                               {	
                                   var state = response.getState();
                                   if(state === "SUCCESS")
                                   {
                                       if(response.getReturnValue() != undefined)
                                       {
                                           if(response.getReturnValue().strMsg === 'Success')
                                           {                                                       
                                               this.doInitHelper(component,event,helper);
                                               if(fromWhere != 'FileUpload')
                                               {
                                                   this.showToast(component,'dismissible','Success','Documents Verified Successfully..!','success');
                                                   $A.get("e.force:closeQuickAction").fire();
                                                   $A.get('e.force:refreshView').fire();
                                               }
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
    generatedialogHelper: function(component, event, helper)
    {       
        component.set('v.showConfirmDocuments', true);
    },
    confirmDocumentHelper: function(component, event, helper)
    {  
        var errorCount = 0;
        var allReqFields = component.find('inputReq');
        var liststatus =component.get("v.lstDocuments");
        var documentcount =0;
        
        for(var i=0;i<liststatus.length;i++)
        {
            if(liststatus[i].objEducationHistory.hed__Verification_Status__c == 'Approved' && liststatus[i].objEducationHistory.Received_Hardcopy__c == false)
            {
                documentcount = documentcount+1; 
            }
        } 
        
        var listCnfrmMndtry = component.get("v.lstDocuments");
        var srnconfirmcount = 0;
        
        for(var i= 0; i<listCnfrmMndtry.length; i++)
        {
            if(listCnfrmMndtry[i].objEducationHistory.hed__Verification_Status__c == 'Pending' && listCnfrmMndtry[i].objEducationHistory.Mandatory_for_SRN_Generation__c == true)
            {
                srnconfirmcount =srnconfirmcount+1; 
            }
        }
        
        if(allReqFields)
        {
            if(allReqFields.length) 
            {
                var allValid = allReqFields.reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                if (!allValid) {
                    errorCount++;
                }
            }else{
                var allValid = allReqFields;
                if (!allValid.get('v.validity').valid) 
                {
                    errorCount++;
                }
            }
        }
        if(errorCount > 0)
        {
            this.showToast(component,'dismissible','Error','Fill all mandatory fields..','error');
        }
        else if(documentcount > 0)
        {
            this.showToast(component,'dismissible','Error','HardCopy is mandatory on Approve...!','error'); 
        }
            else if(srnconfirmcount > 0)
            {
                this.showToast(component,'dismissible','Error','Document Status is Pending...!','error'); 
            }
                else
                {
                    component.set('v.showConfirmDocuments', false);
                    var list_document = component.get("v.lstDocuments");
                    var list_Updoc = [];
                    for(var i=0;i<list_document.length;i++)
                    {
                        list_Updoc.push(list_document[i].objEducationHistory);
                    }
                    var action = component.get("c.confirmDocuments");
                    action.setParams({"list_EdHis": list_Updoc});
                    action.setCallback(this, function(response) 
                                       {	
                                           var state = response.getState();
                                           if(state === "SUCCESS")
                                           {
                                               if(response.getReturnValue() != undefined)
                                               {
                                                   if(response.getReturnValue().strMessage === 'Success')
                                                   {
                                                       
                                                       this.showToast(component,'dismissible','Success','Documents Confirmed Successfully..!','success');
                                                       this.doInitHelper(component,event,helper);
                                                       $A.get("e.force:closeQuickAction").fire();
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
                }
    },
    DeleteFilesHelper : function(component, event, helper)
    {
        var filId = event.getSource().get("v.value");
        var action = component.get("c.getdeletefiledetais");
        action.setParams({"str_conprtId": filId });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {
                                       if(response.getReturnValue().strdeletefile === 'Success')
                                       {
                                           this.showToast(component,'dismissible','Success','Files Deleted Successfully..!','success');
                                           this.doInitHelper(component, event, helper);
                                           $A.get('e.force:refreshView').fire();                                             
                                       }
                                       else
                                       {
                                           this.showToast(component,'dismissible','Failed',response.getReturnValue().strdeletefile,'error');
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
    handleFileUploadHlpr : function(component, event, helper) 
    {       
        this.showToast(component,'dismissible','Success','Files Uploaded Successfully..!','success');  
        this.saveReturnHelper(component, event, helper,'FileUpload');
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