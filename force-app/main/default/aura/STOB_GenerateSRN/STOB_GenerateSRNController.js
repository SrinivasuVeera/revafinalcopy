({
    doInit : function(component, event, helper) 
    {
        helper.getStudTypeHlpr(component, event, helper);
        helper.getProgramPlanHlpr(component, event, helper);	
    },
    getEnrollmentDetails : function(component, event, helper) 
    {
        helper.getEnrollmentHlpr(component, event, helper);
    },
    handleChangeStudType : function(component, event, helper)
    {
        helper.handleStudTypeHlpr(component, event, helper);
    },
    generatedialogSRN : function(component, event, helper) 
    {
        component.set('v.showGRNGenerateDialog', true);
    },
    handlegenerateYes : function(component, event, helper)
    {
        helper.generateSRNNoHlpr(component, event, helper);
    },
    handlegenerateNo : function(component, event, helper)
    {
        console.log('No');
        component.set('v.showGRNGenerateDialog', false);        
    },
    displayPicklist : function(component, event, helper)
    {
        component.set("v.hidePicklist", false);
        component.set("v.disableSelection", false);
        var studentType;
        component.set("v.studentType", studentType);
    },
    closeQuickAction : function(component, event, helper)
    {
        $A.get("e.force:closeQuickAction").fire();
    }
})