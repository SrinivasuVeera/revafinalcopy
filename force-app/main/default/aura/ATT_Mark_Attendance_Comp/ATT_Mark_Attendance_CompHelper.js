({
    getCosRecord : function(component, event, helper) {
        component.set("v.Spinner",true);
        var recId = component.get("v.i_scheduleId") == "" ? component.get("v.recordId") : component.get("v.i_scheduleId");
        var action = component.get("c.getCOSDetails");
        action.setParams({'cosId': recId});
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                if(response.getReturnValue() != undefined) {
                    var returnValues =  response.getReturnValue();
                    var retVal = returnValues.cosRec;  
                    component.set("v.objCos",retVal);   
                    
                    component.set("v.techingMethod",retVal.Teaching_Method__c );
                    component.set("v.courseCompleted",retVal.Course_Plan_Completed__c );
                    component.set("v.courseNotCompleted", retVal.Reason_for_not_completing__c);
                    const DTms = retVal.hed__Start_Time__c;            
                    const DTdate = new Date();
                    DTdate.setHours(0,0,0,DTms);
                    const DTtime = $A.localizationService.formatTime(DTdate); //DTtime Format: HH:mm:ss a
                    const DTmeridiem = DTtime.split(' ')[1]; //AM or PM string
                    const [DThours, DTminutes, DTseconds] = DTtime.split(' ')[0].split(':');
                    const formattedDTtime = DThours+':'+DTminutes+' '+DTmeridiem; //formattedDTtime Format: HH:mm a
                    component.set("v.objCos.hed__Start_Time__c", formattedDTtime);
                    
                    const ATms = retVal.hed__End_Time__c;
                    const ATdate = new Date();
                    ATdate.setHours(0,0,0,ATms);
                    const ATtime = $A.localizationService.formatTime(ATdate); //ATtime Format: HH:mm:ss a
                    const ATmeridiem = ATtime.split(' ')[1]; //AM or PM string
                    const [AThours, ATminutes, ATseconds] = ATtime.split(' ')[0].split(':');
                    const formattedATtime = AThours+':'+ATminutes+' '+ATmeridiem; //formattedATtime Format: HH:mm a
                    component.set("v.objCos.hed__End_Time__c", formattedATtime);   
                    
                    var temp = 
                        //'Mark Attendance for '+retVal.Section__r.hed__Parent_Term__r.Program_Batch__r.Name +
                        //' of '+
                        retVal.Section__r.Name 
                    //+' of '+retVal.Section__r.hed__Parent_Term__r.Name;   
                   
                    var retAtt = returnValues.lst_Att; 
                    component.set("v.lstAttachment",retAtt);
                    component.set("v.mainTitle", temp);
                    component.set("v.Spinner", false);
                    component.set("v.existingSubject",response.getReturnValue().preCOSId);
                    
                   
                    component.set("v.plannedTopic", returnValues.pTopic);
                    component.set("v.actualTopic", returnValues.aTopic);
                                                      
                }    
                component.set("v.Spinner", false);                 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
    getAttachmentRecord : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action = component.get("c.getAttachment");
        var recId = component.get("v.i_scheduleId") == "" ? component.get("v.recordId") : component.get("v.i_scheduleId");
       
        action.setParams({'cosId':recId
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                if(response.getReturnValue() != undefined){
                    var retVal = response.getReturnValue();  
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
    getStudentRecord : function(component, event, helper) {
        component.set("v.Spinner",true);
        var recId = component.get("v.i_scheduleId") == "" ? component.get("v.recordId") : component.get("v.i_scheduleId");

        var action = component.get("c.getStudentDetails");
        action.setParams({'cosId': recId
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();  
                    component.set("v.lstStudent",retVal);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
    onSaveHpr : function(component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.disableSave", true);
        if(component.find('fuploader') != undefined) {
        var varfiles = component.find('fuploader').get("v.files");
        var file = varpfiles[0];
        var reader = new FileReader();
        reader.onload = $A.getCallback(function() {
            var dataURL = reader.result;
            var base64 = 'base64,';
            var dataStart = dataURL.indexOf(base64) + base64.length;
            dataURL = dataURL.substring(dataStart);
            this.onSaveHpr1(component, event, helper, dataURL);
        });
        reader.readAsDataURL(file);
        }
        else this.onSaveHpr1(component, event, helper, '');
        
    },
   	onSaveHpr1 : function(component, event, helper,dataURL){
        var recId = component.get("v.i_scheduleId") == "" ? component.get("v.recordId") : component.get("v.i_scheduleId");

        var action = component.get("c.saveAttendance");
        action.setParams({'i_CosId' : recId,
                          'i_teachingMethodStr':component.get("v.techingMethod"),
                          'i_isCoursePlanComplete':component.get("v.courseCompleted"),
                          'i_reasonStr':component.get("v.courseNotCompleted"),
                          'i_StuRec' : component.get("v.lstStudent"),
                          'fileName': component.get("v.fileName"),
                          'dataURL' :dataURL,
                          'i_Topic' : component.get("v.objCos.Actual_Topic__c")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();  
                if(component.get("v.i_scheduleId") == "" ) {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                }
                component.set("v.i_Close", false);
                component.set("v.Spinner", false);
                
                 this.showToast(component,'dismissible','Sucess','Attendance saved sucesfully!!','success');
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
             component.set("v.disableSave", false);
        });
        $A.enqueueAction(action);   
    },
    fetchPreviousAttendanceHepler : function(component,event,helper){
        component.set("v.Spinner", true); 
        var cloneVar = true;
        var recId = component.get("v.i_scheduleId") == "" ? component.get("v.recordId") : component.get("v.i_scheduleId");
        var cloneFromId = '';
        if(component.get("v.attadanceTaken") == 'Yes') {
            cloneVar = true;
            cloneFromId = component.get("v.existingSubject");
        }        
        else if(component.get("v.objCos.Status__c") == 'Locked'){
            cloneVar = false;    
            cloneFromId = recId;
        }
        var action = component.get("c.getpreviousDetails");
        action.setParams({
            'cloneFrom' : cloneFromId,
            'cloneRequired' : cloneVar,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();  
                    component.set("v.lstStudent",retVal);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
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
    }
})