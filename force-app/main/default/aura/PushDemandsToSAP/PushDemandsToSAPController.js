({
    doInit : function(component, event, helper) 
    {
        helper.getYearTypeHlpr(component, event, helper);   
         
    },
     //Select all contacts
    handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.progmEnrollmentLst");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact"); 
          
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
           
             var val = component.get("v.totalamountToBePushed");
             component.set('v.selectedAmount',val);
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
            component.set('v.selectedAmount',0);
        }
      
         
       
    },
    
    handleTabChange: function(component, event, helper) {
        var selectedTabId = event.getParam("id");
        component.set("v.selectedTab", selectedTabId);
    },
     
    handleSelectTobePushed : function(component, event, helper) {
        
       
       var tobepushed = component.get("v.progmEnrollmentLst");
       
        var totalamount = 0;  
        for(var i = 0;  i < tobepushed.length; i++)
        {
            if(tobepushed[i].Push_Check_Box__c == true)
            {
                var TutionFee = 0;
                var UniversityFee = 0;
                
                if(tobepushed[i].Tuition_Fee__c != null && tobepushed[i].Tuition_Fee__c != undefined) TutionFee = tobepushed[i].Tuition_Fee__c;
                if(tobepushed[i].University_Fee__c != null && tobepushed[i].University_Fee__c != undefined) UniversityFee = tobepushed[i].University_Fee__c;
                
                totalamount = totalamount + TutionFee+UniversityFee;
            }
            else
            {
                var TutionFee = 0;
                var UniversityFee = 0;
                
                               
                totalamount = totalamount + TutionFee+UniversityFee;
            }
        } 
        
        component.set('v.selectedAmount',totalamount);
    }, 
    //Process the selected contacts
    handleSelectedContacts : function(component, event, helper) {
         
        var selectedContacts = [];
        var checkvalue = component.find("checkContact");
         
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedContacts.push(checkvalue[i].get("v.text"));
                }
            }
        }
       
        console.log('selectedContacts-' + selectedContacts);
    },
    getEnrollmentDetails : function(component, event, helper) 
    {
        helper.getEnrollmentHlpr(component, event, helper);
    },
    pushToSAP : function(component, event, helper) 
    {
        component.set("v.showConfirmationModal", false);
        helper.pushToSAPHlpr(component, event, helper);
    },
    cancelQuick : function(component, event, helper) 
    {
         $A.get("e.force:closeQuickAction").fire();
    },
   showConfirmationModal: function(component, event, helper) {
        component.set("v.showConfirmationModal", true);
    },

    hideConfirmationDialog: function(component, event, helper) {
        component.set("v.showConfirmationModal", false);
    },

    
    
})