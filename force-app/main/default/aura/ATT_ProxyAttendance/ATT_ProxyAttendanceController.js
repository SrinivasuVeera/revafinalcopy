({
    OnSave : function(component, event, helper) 
    {
        var dt = component.get("v.selectedFromDate");
        var seldate =  $A.localizationService.formatDate(dt, "yyyy-MM-dd");
        let formatfromDate = $A.localizationService.formatDate(dt, "MM-dd-yyyy,HH:mm:ss"); 
        component.set("v.selFromDate",formatfromDate);
        component.set("v.FromDatesel",seldate);
        var today;
        var selfromdate;
        if(seldate != null)
        {
            selfromdate = seldate;
            today = $A.localizationService.formatDate(new Date(),"yyyy-MM-dd");
        }
        if(selfromdate < today)
        {
            helper.showToast(component,'dismissible','Error','Do Not Select Previous From Date','error');              
        }
        
        var todate = component.get("v.selectedToDate");
        var selectedTodate;
        var seltodate =  $A.localizationService.formatDate(todate, "yyyy-MM-dd");
        var formatToDate = $A.localizationService.formatDate(todate, "MM-dd-yyyy,HH:mm:ss"); 
        component.set("v.selToDate",formatToDate);
        component.set("v.ToDatesel",seltodate);
        
        if(seltodate != null)
        {
            selectedTodate = seltodate;
        }
        if(selectedTodate < selfromdate)
        {
            helper.showToast(component,'dismissible','Error','Do Not Select Previous To Date','error');              
        }
        if(seldate >= today && selectedTodate >= seldate)
        {
            helper.validationhlpr(component, event, helper);
        }
    },    
    onchangeSrnNumber : function(component, event, helper) 
    {
        var SelSrnNumber = component.get("v.SelectedSrnNumber"); 
        if(SelSrnNumber != '' || SelSrnNumber != undefined)
        {
            helper.OnSearchhelper(component, event, helper); 
            component.set("v.Showsrn",true);
        }
    },
    closeAction :function(component, event, helper) 
    {
        component.set("v.SelectedSrnNumber",'');
        component.set("v.selectedFromDate",'');
        component.set("v.selectedToDate",'');
        component.set("v.selectedReason",'');
        var progEnroll =[];
        component.set("v.lst_ProgramEnrollment",progEnroll);
    },
})