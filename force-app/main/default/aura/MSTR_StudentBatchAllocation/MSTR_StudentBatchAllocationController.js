({
	doInit : function(component, event, helper) 
    {
		helper.doInithelper(component, event, helper);	
	},
    termOnclick : function(component, event, helper)
    {
       component.set("v.isModalOpen", true); 
       helper.getBatchesDetailsHelper(component, event, helper);
    },
    saveStudentTermMapping : function(component, event, helper)
    {
         helper.saveStudentTermMappingHelper(component, event, helper);        
    },
    handleAllocateYes : function(component, event, helper)
    {
       //component.set("v.isModalOpen", false);
       helper.handleAllocateYesHelper(component, event, helper);
    },
    handleAllocateNo : function(component, event, helper)
    {
       component.set('v.showConfirmStudents', false);        
    },
    onChangeSelectedBatches : function(component, event, helper)
    {
       helper.onChangeSelectedBatchesHelper(component, event, helper); 
    },
    changeUnAssignBatches : function(component, event, helper)
    {
		helper.changeUnAssignBatchesHlpr(component, event, helper);        
    },
    closeModel: function(component, event, helper) 
    {      
        component.set("v.isModalOpen", false);
    },
})