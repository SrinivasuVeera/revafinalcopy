({
    doInitHpr : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action = component.get("c.fetchData");
        action.setParams({'prfConId':component.get("v.profCrsConId"),
                          'iaType':component.get("v.iaType")});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS'){
                if(result.getReturnValue() != undefined){
                    var retVal = result.getReturnValue();
                    var stdlist = retVal.list_marksWpr;
                    console.log('stdlist=> ',stdlist);
                    stdlist.forEach(function(crs) {
                        if (crs.iaMark) {
                            // Initialize fields
                            crs.iaMark.AcknowledgedByStudent = false;
                            crs.iaMark.AcknowledgedByAdmin = false;
                            
                            if (crs.iaMark.Acknowledgment_Response__c === 'Acknowledged by Student') {
                                crs.iaMark.AcknowledgedByStudent = true;
                                component.set("v.AcknowledgedByStudent", true);
                                console.log('15', component.get("v.AcknowledgedByStudent"));
                            } 
                            else if (crs.iaMark.Acknowledgment_Response__c === 'Acknowledged By System') {
                                crs.iaMark.AcknowledgedByAdmin = true;
                                component.set("v.AcknowledgedByAdmin", true);
                                console.log('18', component.get("v.AcknowledgedByAdmin"));
                            }
                        }
                    });
                    component.set("v.studentList",stdlist);
                    console.log('studentlist=> '+JSON.stringify(component.get("v.studentList")));
                    component.set("v.crsConnection",retVal.mainCrsConn);
                    console.log("Main Course Connection:", retVal.mainCrsConn);
                    console.log('studentlist=> '+JSON.stringify(component.get("v.crsConnection")));
                    helper.calcTotalHpr(component, event, helper);
                    component.set("v.Spinner",false);
                    console.log('If Spinner Value: ', component.get("v.Spinner"));
                    
                }else{
                    component.set("v.Spinner",false);
                    console.log('first else Spinner Value: ', component.get("v.Spinner"));
                    
                    this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                }
            }else{
                component.set("v.Spinner",false);
                console.log('Spinner Value: ', component.get("v.Spinner"));
                
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    calcTotalHpr : function(component, event, helper) {
        var marksList = component.get("v.studentList");
        for(var i=0;i<marksList.length;i++){
            var iam = marksList[i];
            var theory = (iam.iaMark.Theory_Secured_Marks__c != -1 && iam.iaMark.Theory_Secured_Marks__c != undefined && iam.iaMark.Theory_Secured_Marks__c != '' && iam.iaMark.Theory_Secured_Marks__c != null) ? iam.iaMark.Theory_Secured_Marks__c : 0;
            var seminar = (iam.iaMark.Seminar_Secured_Marks__c != -1 && iam.iaMark.Seminar_Secured_Marks__c != undefined && iam.iaMark.Seminar_Secured_Marks__c != '' && iam.iaMark.Seminar_Secured_Marks__c != null) ? iam.iaMark.Seminar_Secured_Marks__c : 0;
            var quiz = (iam.iaMark.Quiz_Secured_marks__c != -1 && iam.iaMark.Quiz_Secured_marks__c != undefined && iam.iaMark.Quiz_Secured_marks__c != '' && iam.iaMark.Quiz_Secured_marks__c != null) ? iam.iaMark.Quiz_Secured_marks__c : 0;
            var practical = (iam.iaMark.Results_Secured_Marks__c != -1 && iam.iaMark.Results_Secured_Marks__c != undefined && iam.iaMark.Results_Secured_Marks__c != '' && iam.iaMark.Results_Secured_Marks__c != null) ? iam.iaMark.Results_Secured_Marks__c : 0;
            var project = (iam.iaMark.Continuous_Learning_Secured_Marks__c != -1 && iam.iaMark.Continuous_Learning_Secured_Marks__c != undefined && iam.iaMark.Continuous_Learning_Secured_Marks__c != '' && iam.iaMark.Continuous_Learning_Secured_Marks__c != null) ? iam.iaMark.Continuous_Learning_Secured_Marks__c : 0;
            var assignment = (iam.iaMark.Assignment_Secured_Marks__c != -1 && iam.iaMark.Assignment_Secured_Marks__c != undefined && iam.iaMark.Assignment_Secured_Marks__c != '' && iam.iaMark.Assignment_Secured_Marks__c != null) ? iam.iaMark.Assignment_Secured_Marks__c : 0;
            iam.iaMark.Total_Secured_Marks_New__c = parseFloat(theory)+parseFloat(seminar)+parseFloat(quiz)+parseFloat(practical)+parseFloat(project)+parseFloat(assignment);            
            iam.total = parseFloat(theory)+parseFloat(seminar)+parseFloat(quiz)+parseFloat(practical)+parseFloat(project)+parseFloat(assignment);
            // iam.iaMark.Course_Offering__c = iam.crsConn.Course_Offering_Section_ID__c;
        }
        component.set("v.studentList",marksList);
    },
    saveIaMarksHpr : function(component, event, helper) {
        component.set("v.Spinner",true);
        var errorCount = 0;
        var allReqFields = component.find('inputReq');
        if(allReqFields){
            if(allReqFields.length) {
                var allValid = allReqFields.reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                if (!allValid) {
                    errorCount++;
                }
            }else{
                var allValid = allReqFields;
                if (!allValid.get('v.validity').valid) {
                    errorCount++;
                }
            }
        }
        if(errorCount > 0){
            this.showToast(component,'dismissible','Error','Please check below messages..','error');
            component.set("v.Spinner",false);
        }else{
            var marksList = component.get("v.studentList");
            
            var finalList = [];
            for(var i=0;i<marksList.length;i++){
                var iam = marksList[i];
                if (iam.iaMark) {
                    // Remove the temporary fields
                    delete iam.iaMark.AcknowledgedByStudent;
                    delete iam.iaMark.AcknowledgedByAdmin;
                    
                    // Push cleaned object
                    finalList.push(iam.iaMark);
                }
            }
            
            if(finalList.length > 0){
                
                var action = component.get("c.saveData");
                action.setParams({'list_IaMarks':finalList,'iaType':component.get("v.iaType")});
                action.setCallback(this,function(result){
                    //alert(result.getState());
                    if(result.getState() === 'SUCCESS'){
                        this.showToast(component,'dismissible','Success','IA Marks updated succesfully','success');
                        component.set("v.Spinner",false);
                        helper.fireRefEvent(component, event, helper);
                    }else{
                        component.set("v.Spinner",false);
                        this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                    }
                });
                $A.enqueueAction(action);
            }else{
                this.showToast(component,'dismissible','Error','Enter marks for atleast one Student','error');
                component.set("v.Spinner",false);
            }
        }
    },
    fireRefEvent : function(component, event, helper) {
        var refreshEvt = component.getEvent("ASM_RefreshProfView");
        refreshEvt.setParams({"iaType": component.get("v.iaType")});
        refreshEvt.fire();
    },
    showToast : function(component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2000'
        });
        toastEvent.fire();
    },
})