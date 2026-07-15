({
	doInit : function(component, event, helper) 
    {
        helper.doInitHelper(component, event, helper);
	},
    OnchangeprogBatches : function(component, event, helper) 
    {
       helper.OnchangeProgbtchhelper(component, event, helper);
    },
    OnchangeSemester : function(component, event, helper) 
    {
       helper.OnchangeSemshelper(component, event, helper);  
    },
    SaveStudents : function(component, event, helper) 
    {
       helper.SaveStudentsHelper(component, event, helper); 
    },
    OnchangeEligibilityType : function(component, event, helper)
    {
      var elgble = event.getSource().get("v.value");
      component.set("v.selectedelgtyp",elgble);
      helper.OnchangeEligibilityTypeHelper(component, event, helper);  
    },
    selectAllCheckbox : function(component, event, helper)
    {
        helper.selectAllCheckboxHelper(component, event, helper);
    },
    
})