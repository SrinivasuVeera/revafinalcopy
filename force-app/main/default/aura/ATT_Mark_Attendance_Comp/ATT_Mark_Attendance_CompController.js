({
	doInit : function(component, event, helper) {
		helper.getCosRecord(component,event,helper);
	},
   
    onChangeCheckBox : function(component, event, helper) {
        var allAttach = component.get("v.lstAttachment");
        var allSelect = component.find("allCheck").get("v.checked");
        for(var i=0;i<allAttach.length;i++){
            allAttach[i].checkBox = allSelect;
        }
        component.set("v.lstAttachment", allAttach);        
    },
    onChangeCheckBox1 : function(component, event, helper) {
        var allStudent = component.get("v.lstStudent");
        var allSelect = component.find("allCheck1").get("v.checked");
        for(var i=0;i<allStudent.length;i++){
           // allStudent[i].checkBox = allSelect;
           allStudent[i].checkBox = allStudent[i].attendanceBlocked ? false : allSelect;
        }
        component.set("v.lstStudent", allStudent);        
    },
	handleUploadFile : function(component, event, helper) {
    	var uploadedFiles = event.getParam("files"); 
        var fileName = uploadedFiles[0].name; 
        component.set("v.fileName", fileName);	
        helper.showToast(component, 'dismissible', 'Success','Attachment Uploaded..!!', 'success');    
    },
	closeAction : function(component, event, helper) 
    {
        if(component.get("v.i_scheduleId") == "" ) {
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }
        component.set("v.i_Close", false);  
    },
    onNext : function(component, event, helper){
        component.set("v.sectionOne", false);
        if(component.get("v.attadanceTaken") == 'Yes' || component.get("v.objCos.Status__c") == 'Locked')  
            helper.fetchPreviousAttendanceHepler(component,event,helper);
        else
            helper.getStudentRecord(component,event,helper);
    },
    onSave : function(component, event, helper){ 
        helper.onSaveHpr(component,event,helper);
    },
    fetchPreviousAttendance : function(component, event, helper){
        helper.fetchPreviousAttendanceHepler(component,event,helper);
    }
})