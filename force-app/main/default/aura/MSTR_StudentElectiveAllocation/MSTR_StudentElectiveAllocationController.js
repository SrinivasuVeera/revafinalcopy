({
    doInit : function(component, event, helper) 
    {
        helper.getPreferenceHlpr(component,event,helper);
        helper.doInitHlpr(component,event,helper);        
    },
    ElectiveOnclick : function(component, event, helper)
    {
        component.set("v.showCreateSubject", true);
        var courseElectiveId = event.currentTarget.getAttribute("data-Id"); 
        component.set("v.courseElectId", courseElectiveId);
    },
    handleCourseNo : function(component, event, helper)
    {
        component.set("v.showCreateSubject", false);
    },
    handleCourseYes  : function(component, event, helper)
    {
        helper.getElectiveCourseDetailsHlpr(component, event, helper);
    },
    closeModel: function(component, event, helper) 
    {      
        component.set("v.isModalOpen", false);
    },
    selectAllCheckbox : function(component, event, helper)
    {
        helper.selectAllCheckboxHlpr(component, event, helper);
    },
    saveCourseConnection : function(component, event, helper)
    {
        helper.saveCourseConnectionHlpr(component, event, helper);
    },
    handleAllocateYes : function(component, event, helper)
    {
        helper.handleAllocateHlpr(component, event, helper);
    },
    handleAllocateNo : function(component, event, helper)
    {
        component.set("v.showConfirmSubject", false);
    },
    activeSubject : function(component, event, helper)
    {
        helper.activeSubjectHlpr(component, event, helper);
    }
})