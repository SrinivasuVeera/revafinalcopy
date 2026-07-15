({
    doInit : function(component, event, helper) {    
        helper.initHpr(component, event, helper, true);
    },
    onSemChange : function(component, event, helper) { 
        
        helper.initHpr(component, event, helper, false);
    },
    facultChange : function(component, event, helper) { 
        component.set("v.options", []);
        component.set("v.selectedSem",'All');
        helper.initHpr(component, event, helper, true);
    },
    editAllocation : function(component, event, helper){
        helper.editAllocationHpr(component, event, helper);
    },
    moveAllocation : function(component, event, helper){
        helper.moveAllocationHpr(component, event, helper);
    },
    moveGroupAllocation : function(component, event, helper){
        helper.moveGroupAllocationHpr(component, event, helper);
    },
    selectedTab : function(component, event, helper){
        component.set("v.selectedOEForMove","---None---");
    },
    onDeleteGroup : function(component, event, helper) { 
        helper.onDeleteGroupHpr(component, event, helper);
    },
    courseClickedCtr :  function(component, event, helper) { 
        component.set("v.selectedCourse", event.getSource().get("v.name"));
        helper.fetchConnections(component, event, helper);
    },
    closeAction : function(component, event, helper){
        component.set("v.openPopUp", false);  
        component.set("v.openGroupPopUp", false);
    },
    onAllocate : function(component, event, helper){
        helper.saveAllocationHpr(component, event, helper);
    },
    onNext : function(component, event, helper){
        helper.onNextHpr(component, event, helper);
    },
    onFinalSave : function(component, event, helper){
        helper.saveGroupAllocationHpr(component, event, helper);
    },
    addNewGroup : function(component, event, helper){
        helper.addNewGroupHpr(component, event, helper);
    },
})