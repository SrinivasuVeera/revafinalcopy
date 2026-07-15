({
	doInit : function(component, event, helper) 
    {
		helper.doInitHlpr(component, event, helper);
	},
    getSectionDetails : function(component, event, helper)
    {
        helper.getSectionDetailHlpr(component, event, helper);
    },
    selectAllCheckbox : function(component, event, helper)
    {
        helper.selectAllHlpr(component, event, helper);
    },
    clearDetails : function(component, event, helper)
    {
        component.set("v.disableInputs", false);
        var sectionMap = [];
        var allocationType;
        component.set("v.termSections", sectionMap);
        component.set("v.objTerm", sectionMap);
        component.set("v.sectionWrp", sectionMap);
        component.set("v.allocations", sectionMap);
        component.set("v.lstUnassigned", sectionMap);
        component.set("v.allocationType", allocationType);
        helper.getTermHlpr(component, event, helper);
    },
    saveStudSection : function(component, event, helper)
    {
        //component.set("v.openModel", true);
        helper.saveStudSectionHlpr(component, event, helper);
    },
    studPerSection : function(component, event, helper)
    {
        helper.studPerSectionHlpr(component, event, helper);
    },
    changeSection : function(component, event, helper)
    {
        helper.changeSectionHlpr(component, event, helper);
    },
    changeUnAssignSection : function(component, event, helper)
    {
		helper.changeUnAssignSectionHlpr(component, event, helper);        
    },
    assignSections : function(component, event, helper)
    {
        helper.assignSectionsHlpr(component, event, helper);
    },
    cancelAssignSection : function(component, event, helper)
    {
        component.set("v.openModel", false);        
    },
    cancelStudSection : function(component, event, helper)
    {
    	$A.get("e.force:closeQuickAction").fire();    
    }
})