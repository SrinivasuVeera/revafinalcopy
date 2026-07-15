({
	doInit : function(component, event, helper) {
        helper.doInitHpr(component, event, helper);
    },
    selectCon : function(component, event, helper) {
        var cConList = component.get("v.courseList");
        var index = event.getSource().get("v.name");
        
        component.set("v.selectedConId",cConList[index].Id);
        component.set("v.selectedCrsType",cConList[index].hed__Course_Offering__r.hed__Course__r.Course_Type_Logisys__c);
        
        var isReadOnly = false;
        var buttonLabel = event.getSource().get("v.label");
        
        if (buttonLabel === "View IA Marks") {
            isReadOnly = true; // Read-only mode for "View IA Marks"
        } else if (buttonLabel === "Enter IA Marks" || buttonLabel === "Edit IA Marks") {
            isReadOnly = false; // Editable mode for "Enter IA Marks" and "Edit IA Marks"
        }
        
        component.set("v.isReadOnly", isReadOnly);
        console.log('11=> ', component.get("v.selectedCrsType"));
        component.set("v.isSelected",true);
        console.log('13=> ', component.get("v.isSelected"));
 
    },
    goBack : function(component, event, helper) {
        component.set("v.selectedConId","");
        component.set("v.selectedCrsType","");
        component.set("v.isSelected",false);
    },
    handleRefEvent : function(component, event, helper) {
        helper.handleRefEventHpr(component, event, helper);
    },
    callFreezingService : function(component, event, helper) {
        helper.updateFreezingStatus(component, event, helper);
    },
    closeModal : function(component, event, helper) {
        component.set("v.isModalOpen",false);
        component.set("v.studentMarksList", []);
    },
    openModal: function(component, event, helper){
        var courseId = event.getSource().get("v.name"); // Get courseId from button name attribute
        component.set("v.selectedCourseId",courseId);
        component.set("v.isModalOpen",true);
        helper.fetchStudentMarks(component, helper);
    },
    downloadAsPDF: function(component, event, helper) {
        try {
            var courseId = event.getSource().get("v.name");
            component.set("v.selectedCourseId", courseId);
            
            if (!courseId) {
                throw new Error('Course ID is missing.');
            }

            // Construct the URL for the Visualforce page
            var vfPageUrl = '/apex/ProfListIAMarksPDF?courseId=' + encodeURIComponent(courseId);
            
            // Open the URL in a new window/tab to trigger the PDF download
            window.open(vfPageUrl, '_blank');

            helper.showToast(component, 'dismissible', 'Success', 'PDF download initiated.', 'success');
        } catch (error) {
            console.error('Error initiating PDF download:', error);
            helper.showToast(component, 'dismissible', 'Error', 'Failed to initiate PDF download: ' + error.message, 'error');
        }
    }
   
})