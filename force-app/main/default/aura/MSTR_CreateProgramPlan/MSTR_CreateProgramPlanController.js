({
    doInit : function(component, event, helper) 
    {
        helper.getProgramTypeHlpr(component, event, helper);
        helper.doInitHlpr(component, event, helper);        
    },
    changeFaculty :function(component, event, helper) 
    {
        var acclist =[];
        component.set("v.List_Account",acclist);
        var progPlan =[];
        component.set("v.List_ProgramPlan",progPlan);
        component.set("v.SelectedProgramTypeId",'');
    },
    ChangeProgramPlan : function(component, event, helper) 
    {
        helper.ChangeProgramPlanHlpr(component, event, helper);
    },
    OnchangeStartDate : function(component, event, helper) 
    {
        helper.OnchangeStartDateHlpr(component, event, helper);
    }, 
    onchangeSelectDate : function(component, event, helper) 
    {        
        var index = event.getSource().get("v.name");
        var lstProgPlan = component.get("v.List_ProgramPlan");
        var dt = lstProgPlan[index].obj_ProgPlan.hed__Start_Date__c ;
        if(dt == null)
        {
            helper.showToast(component,'dismissible','Error','Please fill the Start Date','error');     
			component.set("v.HideSave",true);            
        }        
    }, 
    onchangeIntake : function(component, event, helper) 
    {
        var index = event.getSource().get("v.name");
        var lstProgPlan = component.get("v.List_ProgramPlan");
        var strIntake = lstProgPlan[index].obj_ProgPlan.Intake__c ;
        if(strIntake == null || strIntake =='')
        {
            helper.showToast(component,'dismissible','Error','Please fill all the Values','error'); 
            component.set("v.HideSave",true);
        }
        if(strIntake)
        {
            if(strIntake < 0)
            {
                helper.showToast(component,'dismissible','Error','Dont Select Negitive values','error'); 
                component.set("v.HideSave",true);
            }
        }
        if(strIntake != null && strIntake != '')
        {
            component.set("v.HideSave",false);
        }
    }, 
    onchangeIntakePerSec : function(component, event, helper) 
    {       
        var index = event.getSource().get("v.name");
        var lstProgPlan = component.get("v.List_ProgramPlan");
        var strIntakePerSec = lstProgPlan[index].obj_ProgPlan.Intake_Per_Section__c;
        if(strIntakePerSec == null || strIntakePerSec =='')
        {
            helper.showToast(component,'dismissible','Error','Please fill all the Values','error');
            component.set("v.HideSave",true);
        }
        if(strIntakePerSec)
        {
            if(strIntakePerSec < 0)
            {
                helper.showToast(component,'dismissible','Error','Dont Select Negitive values','error'); 
                component.set("v.HideSave",true);
            }
        }
        if(strIntakePerSec != null && strIntakePerSec != '')
        {
            component.set("v.HideSave",false);
        }
    }, 
    onchangePerSection : function(component, event, helper) 
    {        
        var index = event.getSource().get("v.name");  
        var lstProgPlan = component.get("v.List_ProgramPlan");
        var BatchPerSec = lstProgPlan[index].obj_ProgPlan.Batches_Per_Section__c;
        if(BatchPerSec == null || BatchPerSec =='')
        {
            helper.showToast(component,'dismissible','Error','Please fill all the Values','error');    
            component.set("v.HideSave",true);
        }
        if(BatchPerSec)
        {
            if(BatchPerSec < 0)
            {
                helper.showToast(component,'dismissible','Error','Dont Select Negitive values','error'); 
                component.set("v.HideSave",true);
            } 
        }
        if(BatchPerSec != null && BatchPerSec != '')
        {
            component.set("v.HideSave",false);
        }
    }, 
    selectAllCheckbox : function(component, event, helper)
    {
        helper.selectAllCheckboxHelper(component, event, helper);
    },
    NextAction : function(component, event, helper) 
    {
        helper.NextActionHlpr(component, event, helper); 
    },
    closeAction : function(component, event, helper) 
    {
        component.set("v.SelectedFacultyId",null);
        component.set("v.SelectedProgramTypeId",null);
        component.set("v.SelectedStDate",null);
        component.set("v.showNextTable",false);
        var progPlan =[];
        component.set("v.List_ProgramPlan",progPlan);
        component.set("v.hideparam",true);
    },
    OnSave : function(component, event, helper) 
    {
        var allRecords = component.get("v.List_ProgramPlan");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) 
        {
            if(allRecords[i].isChecked)
            {
                selectedRecords.push(allRecords[i].obj_ProgPlan);
            }
        }        
        if(selectedRecords.length == 0)
        {
            helper.showToast(component,'dismissible','Failed','Please Select Atleast One Record..!','error');
            component.set("v.Spinner",false);
            component.set("v.HideSave",true);
        }
        else
        {
            var Booleansave = component.get("v.HideSave");
            if(Booleansave == false)
            {
                component.set("v.isModalOpen", true); 
                component.set("v.List_NewProgramPlan",selectedRecords); 
            }
        }
    },
    OnPrevious :function(component, event, helper) 
    {        
        var progPlan =[];
        component.set("v.List_ProgramPlan",progPlan);
        component.set("v.showNextTable",true);
        component.set("v.hideparam",true);
    },
    closeModel: function(component, event, helper) 
    {  
        component.set("v.isModalOpen", false); 
    },
    submitDetails: function(component, event, helper) 
    {
        helper.ValidationHlpr(component, event, helper);
        component.set("v.isModalOpen", false);
    },
    
})