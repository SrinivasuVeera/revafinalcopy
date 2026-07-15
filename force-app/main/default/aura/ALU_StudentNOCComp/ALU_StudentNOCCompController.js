({
    doInit : function(component, event, helper) 
    {
        component.set("v.showNocForm",true);
    },
    OnchangeStudentPosition : function(component, event, helper)
    {
        helper.OnchngStdntPstHelper(component, event, helper);
    },
    OnchangePlacement : function(component, event, helper)
    {
        helper.OnchngPlacmntHelper(component, event, helper);
    },
    OnchangeCoaching : function(component, event, helper)
    {
        helper.OnCoachingHelper(component, event, helper); 
    },
    OnchangeStarted : function(component, event, helper)
    {
        helper.OnchangeStrtdfunctnHelper(component, event, helper);
    },
    saveContact : function(component, event, helper)
    {
        helper.savenewmainHelper(component, event, helper); 
    },
    filechange : function(component, event, helper) 
    {
        var filename = component.get('v.fileName');
        component.set("v.fileNameUploaded", filename.replace(/^.*\\/, ""));
    },
    onClickNoc : function(component, event, helper)
    {
        component.set("v.showStudentData",true);
        component.set("v.showNocForm",false);
        component.set("v.objCont.Placement__c",null);
        component.set("v.objCont.Company__c",null);
        component.set("v.objCont.Designation__c",null);
        component.set("v.objCont.Location__c",null);
        component.set("v.objCont.Date_of_Joining__c",null);
        component.set("v.objCont.Joining_REVA__c",null);
        component.set("v.objCont.Which_Program__c",null);        
        component.set("v.objCont.University_Name__c",null);
        component.set("v.objCont.Date_of_Joining_HS__c",null);
        component.set("v.objCont.Country_HS__c",null);
        component.set("v.objCont.Location_HS__c",null);
        component.set("v.objCont.Firm_Name__c",null);
        component.set("v.objCont.Started__c",null);
        component.set("v.objCont.Designation_SU__c",null);
        component.set("v.objCont.Location_SU__c",null);
        component.set("v.objCont.Type_of_Business__c",null);
        component.set("v.objCont.Location_B__c",null);
        component.set("v.objCont.Type_of_Job_Targeting__c",null);
        component.set("v.objCont.Coaching_required_from_REVA_University__c",null);
        component.set("v.fileNameUploaded",null);
        component.set("v.fileName",null);
        component.set("v.objCont.Position_of_Student__c",null);
        component.set("v.objCont.Others__c",null);
        component.set("v.PlacedCon",false);
        component.set("v.HigherStudiesCon",false);
        component.set("v.StartupEntrepreneurCon",false);
        component.set("v.FamilybusinessCon",false);
        component.set("v.GovtCon",false);
        component.set("v.OtherCon",false);
        helper.getstntPstnHelper(component, event, helper);
        helper.getPalcmntDetlsHelper(component, event, helper);
        helper.getJningDetlsHelper(component, event, helper);
        helper.getStrtedHelper(component, event, helper);
        helper.getCoachingHelper(component, event, helper);
        helper.doInitHelper(component, event, helper);  
    },
    CancelModel : function(component, event, helper)
    {
        component.set("v.showNocForm",true);  
        component.set("v.showStudentData",false);
        component.set("v.objCont.Placement__c",null);
        component.set("v.objCont.Company__c",null);
        component.set("v.objCont.Designation__c",null);
        component.set("v.objCont.Location__c",null);
        component.set("v.objCont.Date_of_Joining__c",null);
        component.set("v.objCont.Joining_REVA__c",null);
        component.set("v.objCont.Which_Program__c",null);        
        component.set("v.objCont.University_Name__c",null);
        component.set("v.objCont.Date_of_Joining_HS__c",null);
        component.set("v.objCont.Country_HS__c",null);
        component.set("v.objCont.Location_HS__c",null);
        component.set("v.objCont.Firm_Name__c",null);
        component.set("v.objCont.Started__c",null);
        component.set("v.objCont.Designation_SU__c",null);
        component.set("v.objCont.Location_SU__c",null);
        component.set("v.objCont.Type_of_Business__c",null);
        component.set("v.objCont.Location_B__c",null);
        component.set("v.objCont.Type_of_Job_Targeting__c",null);
        component.set("v.objCont.Coaching_required_from_REVA_University__c",null);
        component.set("v.fileNameUploaded",null);
        component.set("v.fileName",null);
        component.set("v.objCont.Others__c",null);
        component.set("v.objCont.Position_of_Student__c",null);
        component.set("v.PlacedCon",false);
        component.set("v.HigherStudiesCon",false);
        component.set("v.StartupEntrepreneurCon",false);
        component.set("v.FamilybusinessCon",false);
        component.set("v.GovtCon",false);
        component.set("v.OtherCon",false);
    }
    
})