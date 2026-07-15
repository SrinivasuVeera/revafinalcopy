({
    doInit: function(component, event, helper) 
    {  
        helper.getVerfStatusHelper(component, event, helper);
        helper.doInitHelper(component, event, helper); 
        helper.getContactDetails(component, event, helper);       
    },
    onChangeVerificationStatus: function(component, event, helper)
    {
        helper.onChangeVerificationStatusHelper(component, event, helper);         
    },
    generatedialog : function(component, event, helper) 
    {
        helper.generatedialogHelper(component, event, helper);
    },
    handleConfirmYes : function(component, event, helper)
    {
        helper.confirmDocumentHelper(component, event, helper);
    },
    handleConfirmNo : function(component, event, helper)
    {
        component.set('v.showConfirmDocuments', false);        
    },
    saveReturn: function(component, event, helper)
    {
      helper.saveReturnHelper(component, event, helper,'');  
    },
    handleFileUpload : function (component, event, helper) 
    {             
        helper.handleFileUploadHlpr(component, event, helper);
    },
    CancelDocument: function(component, event, helper)
    {
        $A.get("e.force:closeQuickAction").fire();  
    },
    getSelected : function(component,event,helper)
    {          
        component.set("v.hasModalOpen" , true);
        component.set("v.selectedDocumentId" , event.currentTarget.getAttribute("data-Id"));        
    },
    deleteFiles : function(component, event, helper)
    {
      helper.DeleteFilesHelper(component, event, helper);  
    },
    closeModelf : function(component, event, helper) 
    {          
        component.set("v.hasModalOpen", false);
        component.set("v.selectedDocumentId" , null);          
    }
})