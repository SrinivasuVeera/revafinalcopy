({
    doInit: function(component, event, helper) 
    {
        component.set("v.PlanunitsAddFile",true);
        component.set("v.topicsAddfiles",false);
        helper.getcourseplanDetails(component, event, helper);
        helper.getLast5CourseOfferingDetails(component, event, helper);
        helper.getCourseOffrDetails(component, event, helper);
    },
    onclickNext: function(component, event, helper)
    {       
        component.set('v.showCoursePlanunits', true);
    },
    handleCreateYes : function(component, event, helper)
    {
        helper.savelastcoursedetails(component, event, helper);
    },
    handleCreateNo : function(component, event, helper)
    {
        component.set('v.showCoursePlanunits', false);        
    },
    onchangecourseOff :function(component, event, helper)
    {
        helper.onchangeCourseHelper(component, event, helper);
    },
    addCoursePlanUnits: function(component, event, helper) 
    {
        helper.addCourseplanUnitsHelper(component, event, helper);
    },
    addCrsePlanTopics: function(component, event, helper) 
    {
        helper.addCrseplanTopicsHelper(component, event, helper);
    },
    saveandAddTopics: function(component, event, helper) 
    {
        component.set("v.topicsAddfiles",true);
        helper.getCourseUnitsOnclickHelper(component,event,helper);
    },
    saveAddTopics: function(component, event, helper)
    {
        helper.savecoureTopicsHelper(component, event, helper); 
    },
    saveunitsandAttachments: function(component, event, helper)
    {         
        helper.savecoureplanunitsHelper(component, event, helper);   
    },
    onclickAddunitsDoc: function(component, event, helper) 
    {       
        component.set("v.PlanunitsAddFile",false);        
        component.set("v.isunitsModalOpen",true);
        helper.onclickAddunitsDocHelper(component, event, helper);
    },
    handleBack : function(component, event, helper) 
    {       
        component.set("v.PlanunitsAddFile",true);        
        component.set("v.isunitsModalOpen",false);
        helper.getcourseplanDetails(component, event, helper);

    },
    handleBackTopics : function(component, event, helper)
    {
      component.set("v.topicsAddfiles",true);
      component.set("v.istopicsModalOpen",false); 
      component.set("v.PlanunitsAddFile",false);
      helper.getCourseUnitsOnclickHelper(component, event, helper);
    },
    onclickAddTopicsDoc: function(component, event, helper)
    {
        component.set("v.PlanunitsAddFile",false);
        component.set("v.istopicsModalOpen",true);
        component.set("v.topicsAddfiles",false);
        helper.onclickAddTopicsDocHelper(component, event, helper);  
    },
    displayDoc: function(component, event, helper) 
    {
         var rec_id = event.currentTarget.getAttribute("data-Id");  
         var openPreview = $A.get('e.lightning:openFiles');
        openPreview.fire({
            recordIds: [rec_id]
        });
        $A.enqueueAction(action); 
    },
    displayTopicsDoc: function(component, event, helper)
    {
        var rec_id = event.currentTarget.getAttribute("data-Id");  
         var openPreview = $A.get('e.lightning:openFiles');
        openPreview.fire({
            recordIds: [rec_id]
        });
        $A.enqueueAction(action);      
    },
    handleFileUpload: function(component, event, helper)
    {
        helper.handleFileUploadHlpr(component, event, helper);
        helper.getPlanUnitsDocafterdeleteHelper(component, event ,helper);
        $A.get('e.force:refreshView').fire(); 
    },
    handleTopicsFileUpload: function(component, event, helper)
    {
        helper.handleTopicsFileUploadHelper(component, event, helper);
        helper.getTopicDocafterdeleteHelper(component, event, helper);
        $A.get('e.force:refreshView').fire();      
    },
    dltPlanUnitsDocs: function(component, event, helper)
    {
        helper.dltPlanUnitsDocsHlpr(component, event, helper);
    },
    dltPlantopicsdocuments: function(component, event, helper)
    {
        helper.dltPlantopicsdocumentsHlpr(component, event, helper); 
    },
    deletecoursePlanUnits: function(component, event, helper) 
    {
        helper.deleteCoursePlanUnitsHelper(component, event, helper);
    },
    deletecoursePlanTopics: function(component, event, helper)
    {
        helper.deletecrseplanTopicsHelper(component, event, helper);
    },
    cancelUnits: function(component, event, helper)
    {
        $A.get("e.force:closeQuickAction").fire();  
    },
    CancelTopics : function(component, event, helper) 
    {  
        component.set("v.isModalOpen", false);
        component.set("v.PlanunitsAddFile",true);                      
    },
    closeModelunits: function(component, event, helper)
    {
        component.set("v.isunitsModalOpen", false); 
    },
    closeModeltopics: function(component, event, helper)
    {
        component.set("v.istopicsModalOpen", false);   
    },
    closeModel : function(component, event, helper) 
    {          
        component.set("v.isModalOpen", false);
    },
    closeModelftopics: function(component, event, helper)
    {
        component.set("v.hasModalOpenTopics", false);
        component.set("v.selectedTopicsDocumentId", null);  
    },
    closeModelfunits : function(component, event, helper) 
    {          
        component.set("v.hasModalOpenUnits", false);
        component.set("v.selectedUnitsDocumentId" , null);          
    },
     tabSelected: function(component,event,helper)
    {
        var selected = component.get("v.selectedTab");
        component.set("v.seleTabId",selected);        
    },
     
    
})