({
	doInit : function(component, event, helper) 
    {
        helper.getPreferenceHlpr(component, event, helper);    
        helper.DisplayCourseOfferingRecHlpr(component, event, helper);              
    },
     OnSave :function(component, event, helper) 
    {   
        helper.OnSaveHlpr(component, event, helper,'save'); 
    },
    OnSaveConfirm :function(component, event, helper) 
    {   
        helper.OnSaveHlpr(component, event, helper,'update'); 
    },
    SaveConfrimAction: function(component, event, helper) 
    {   
        helper.OnSaveHlpr(component, event, helper,'confirm'); 
    },
    closeAction :function(component, event, helper)
    {
        $A.get("e.force:refreshView").fire();
    },
    handleSpclCredits : function(component, event, helper){

        component.set("v.totalCredit",component.get("v.totalCredit")+ event.getParam('spclcredits'));
    }
})