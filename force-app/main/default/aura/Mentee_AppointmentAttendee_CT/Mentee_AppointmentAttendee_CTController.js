({
	doInit : function(component, event, helper) 
    {
        helper.doInitHlpr(component, event, helper);
        component.set("v.selcheckbox",false);
        component.set("v.UserId",null);
    },
    changeUser : function(component, event, helper) 
    {
        var SelecteduserId = component.get("v.SelUserId");
        component.set("v.UserId",SelecteduserId);
        //alert('===SelecteduserId==='+SelecteduserId);
    },
    closeModel: function(component, event, helper) 
    {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    onsave :  function(component, event, helper) 
    {
        var SelecteduserId = component.get("v.UserId");
        var selectedCheck = component.get("v.selcheckbox");
        if(selectedCheck == false)
        {
            helper.showToast(component,'dismissible','Failed','Please Select Send Meeting Invite..!','error');
        }
        else if(selectedCheck == true)
        {
            helper.validationhlpr(component,event,helper);
        }
    },
    onCheck :function(component, event, helper) 
    {
        var boxPack = component.find('checkid').get('v.checked');
        component.set("v.selcheckbox",boxPack);
    }
})