({
	doInit : function(component, event, helper) {
		helper.FetchRecordDetails(component, event, helper);	
	},
    closeModel: function(component, event, helper) 
    {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
	handleOnSubmit : function(component, event, helper)
    {
    	var blockMeet = component.get("v.blockMeeting");
        if(blockMeet){
        	helper.showToast(component, 'dismissible','Failed','Requested meeting time is blocked for the day.','error');
        }    
        else{
            var att = component.get("v.objAttendee");
            if(att.Send_Meeting_Invite__c){
            	helper.updateAppoinmentDetails(component, event, helper);   
            }   
            else{
            	helper.showToast(component, 'dismissible','Failed','Please Fill Required Field.','error');    
            }
        }
    }    
})