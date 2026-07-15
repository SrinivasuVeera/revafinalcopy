({
	doInit : function(component, event, helper) 
    {
        helper.doInithelper(component, event, helper);	
	},
    generatedialog : function(component, event, helper) 
    {
        helper.generatedialogHelper(component, event, helper);
    },
    handleConfirmNo : function(component, event, helper)
    {
        component.set('v.showMovesemesters', false);        
    },
    handleConfirmYes : function(component, event, helper)
    {
        helper.confirmStudentsHelper(component, event, helper);
    },
    onclickCancel : function(component, event, helper)
    {
        $A.get("e.force:closeQuickAction").fire();
    },
    selectAllCheckbox : function(component, event, helper)
    {
        helper.selectAllCheckboxHelper(component, event, helper);
    },
    selectCheckbox : function(component, event, helper)
    {
        helper.selectCheckboxHlpr(component, event, helper);
    },
})