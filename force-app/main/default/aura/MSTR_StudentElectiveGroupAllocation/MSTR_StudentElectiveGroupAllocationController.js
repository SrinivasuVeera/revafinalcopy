({
	doInit : function(component, event, helper) 
    {
		helper.doInitHlpr(component, event, helper);
	},
    subjectOnClick : function(component, event, helper)
    {
        helper.subjectHlpr(component, event, helper);
    },
    createGroups : function(component, event, helper)
    {
		helper.createGroupsHlpr(component, event, helper);        
    },
    closeSubjectModel : function(component, event, helper) 
    {      
        component.set("v.subjectModalOpen", false);
        component.set("v.disableCreateButton", false);
        component.set("v.noOfGroups", null);
        component.set("v.noOfStudPerGroup", null);
        var groupDetailMap = [];
        component.set("v.groupDetailMap", groupDetailMap);
        component.set("v.lstUnassigned", groupDetailMap);
    },
    showExistingGroups : function(component, event, helper)
    {
        helper.showExistingGroupsHlpr(component, event, helper);
    },
    deleteExistingGroups : function(component, event, helper)
    {
        helper.deleteExistingGroupsHlpr(component, event, helper);
    },
    allocateGroups : function(component, event, helper)
    {
        helper.allocateGroupsHlpr(component, event, helper);
    },
    changeGroup : function(component, event, helper)
    {
        helper.changeGroupHlpr(component, event, helper);
    },
    changeUnAssignGroups : function(component, event, helper)
    {
        //alert('inside');
		helper.changeUnAssignGroupsHlpr(component, event, helper);        
    },
    saveStudGroup : function(component, event, helper)
    {
        helper.saveStudGroupHlpr(component, event, helper);
    },
    assignGroups : function(component, event, helper)
    {
        helper.assignGroupsHlpr(component, event, helper);
    },
    cancelAssignGroup : function(component, event, helper)
    {
        component.set("v.saveModal", false);        
    },
    cancelSubjectModal : function(component, event, helper)
    {
        component.set("v.noOfStudPerGroup", null);
        component.set("v.subjectModalOpen", false);        
    },
    saveSTMGroup : function(component, event, helper)
    {
        //component.set("v.openModel", true);
        helper.saveSTMGroupHlpr(component, event, helper);
    },
})