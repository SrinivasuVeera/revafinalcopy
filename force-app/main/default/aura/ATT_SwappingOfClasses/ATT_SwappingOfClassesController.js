({
    doInit : function(component, event, helper) 
    {
        helper.doInitHlpr(component, event, helper);		
    },
    changeSemester : function(component, event, helper) 
    {
        helper.changeSemesterHelper(component, event, helper);        
    },
    changeCourseOffering : function(component, event, helper) 
    {
        helper.changeCourseOfferingHelper(component, event, helper);  
    },
    Onsave : function(component, event, helper) 
    {
        helper.OnsaveHlpr(component, event, helper);
    },
    closeAction : function(component, event, helper) 
    {
        component.set("v.SeleCourseOffId",''); 
        component.set("v.SwapCourseOffId",'');
        component.set("v.SelectedSemesterId",'');
    }    
})