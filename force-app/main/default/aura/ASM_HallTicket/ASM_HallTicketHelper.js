({
    helperdoInit : function(component, event, helper) {
        
        var action = component.get("c.GetStudentDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {
                var retVal = response.getReturnValue();                
                component.set("v.SRNNumber",retVal.SRNNumber);
                 
                component.set("v.PendingServey",retVal.SurveyPending);
                component.set("v.lst_Attendance",retVal.AttendanceWrapper);
                component.set("v.lst_StudentFee",retVal.StudentFee);
                component.set("v.HallTicketEnabled",retVal.EnableHallTicket);
                component.set("v.lstSurveyPending",retVal.lstSurveyPending);
                
               // alert(JSON.stringify(retVal.StudentFee));
                 
            }
        });
        $A.enqueueAction(action);	
    },
    
    helperOpenUrl : function(component, event, helper) 
    {
        component.set("v.Spinner", true); 
        var action = component.get("c.DowloadHallTicket");
        action.setParams({'StudentSRN':component.get("v.SRNNumber")});
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();            
                               if (state === "SUCCESS") 
                               {                
                                   component.set("v.Spinner", false);
                                   var retVal = response.getReturnValue();  
                                  // alert(JSON.stringify(retVal));
                                   if(retVal.error == 'error')
                                   {
                                       this.showToast(component,'dismissible','Failed',retVal.message,'error'); 
                                   }
                                   else
                                   {
                                       window.open(retVal.url, '_blank');
                                   }                                   
                               }  
                               else
                               {
                                   var retVal = response.getReturnValue(); 
                                   this.showToast(component,'dismissible','Failed',retVal.message,'error'); 
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