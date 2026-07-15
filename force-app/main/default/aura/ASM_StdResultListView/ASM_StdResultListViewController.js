({
	doInit : function(component, event, helper) {
        helper.doInitHpr(component, event, helper);
    },
    selectResult : function(component, event, helper) {
        var resList = component.get("v.resultList");
        var index = event.getSource().get("v.name");
        
        component.set("v.selectedId",resList[index].Id);
        component.set("v.semName",resList[index].hed__Term__r.Name);
        component.set("v.isSelected",true);
    },
    goBack : function(component, event, helper) {
        component.set("v.selectedId","");
        component.set("v.semName","");
        component.set("v.isSelected",false);
    },
})