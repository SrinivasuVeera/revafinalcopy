({
	FetchRecordDetails : function(component, event, helper)
    {
       // alert('++++'+feildSetName);
        var action = component.get("c.getAttendeeRecord");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
           // alert('+++++'+state);
            if (state === 'SUCCESS') 
            {
                if(response.getReturnValue()!=undefined)
                {
                    var results= response.getReturnValue();
                    
                  //  component.set("v.lst_AllFieldsets",results.lstOfInfoFields);                                        
                    component.set("v.lstMeeting",results.lstEvent); 
                    component.set("v.blockMeeting",results.blockedMeeting);                     
                    component.set("v.inviteSent",results.invitationSent);                   
                    component.set("v.professor",results.professor);
                   // console.log('+++++'+JSON.stringify(results.objAttandee));
                    component.set("v.objAttendee",results.objAttandee);  
                  //  alert('+++++'+JSON.stringify(component.get("v.lst_AllFieldsets")));
                }
            }
        });
        $A.enqueueAction(action);		
	},
    updateAppoinmentDetails : function(component, event, helper)
    {            
        var att = component.get("v.objAttendee");
        var check = component.find("allCheck");
      //  console.log('+++check+++',check);
      //  console.log('+++check+++',component.find("allCheck").get("v.value"));
      //  console.log('+++att+++',att.Send_Meeting_Invite__c);
        var action = component.get("c.updateAppoinment"); 
        action.setParams({
            recordId: component.get("v.recordId"),
            objAttandee:att
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
         //   alert('+++++'+state);
            if (state === 'SUCCESS') 
            {
                if(response.getReturnValue()!=undefined)
                {
                    var results= response.getReturnValue();
                    if(results == 'Success'){
                    	component.set("v.inviteSent",true); 
                        var message='Appoinment Attendee Added.'; 
                        helper.showToast(component, 'dismissible','Success',message,'success');
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }  
                    else{
                        component.set("v.inviteSent",false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },    
    showToast : function(component, mode, title, message, type)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2'
        });
        toastEvent.fire();
    }
})