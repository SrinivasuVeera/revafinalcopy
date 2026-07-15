({
	doInit : function(component, event, helper) {
		helper.doInitHelper(component, event, helper);
	},
    handleSchoolChange : function(component, event, helper) {
		helper.getProgramDetails(component, event, helper);
	},
    handleProgramChange : function(component, event, helper) {
    	helper.ProgramChangeHelper(component, event, helper);    
    },
	submitButtonHandler : function(component, event, helper) {
        component.set("v.isModalOpen", true);
        component.set("v.isInsert", true);
    },
    cancelButtonHandler : function(component, event, helper) {
        var deletedIds = [];
        component.set("v.deletedRecordIds", deletedIds);
        component.set("v.isModalOpen", false);
    },
	selectAllCheckbox : function(component, event, helper)
    {
        helper.selectAllCheckboxHelper(component, event, helper);
    },
	RemoveFee:function(component, event, helper)
    {
        var allFee = component.get("v.objLateFee.lateFee");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
       // alert(index);
        var recordId = allFee[index].recordId;
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }    
        allFee.splice(index, 1);            
        component.set("v.objLateFee.lateFee", allFee);
    },
	AddFee:function(component, event, helper)
    {
        var allFee = component.get("v.objLateFee.lateFee");
        allFee.push({
            'FromDay':'',
            'totDay': '',
            'totAmount':'' 
        });
        component.set("v.objLateFee.lateFee", allFee);
    },
    updAddFee:function(component, event, helper)
    {
        var allFee = component.get("v.updatedLateFee.lateFee");
        allFee.push({
            'FromDay':'',
            'totDay': '',
            'totAmount':'' 
        });
        component.set("v.updatedLateFee.lateFee", allFee);
    },
    updRemoveFee:function(component, event, helper)
    {
        var allFee = component.get("v.updatedLateFee.lateFee");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
       // alert(index);
        var recordId = allFee[index].recordId;
      //  alert(recordId);
        if(recordId){
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }    
        allFee.splice(index, 1); 
       // console.log('=== Response ===='+JSON.stringify(allFee));
        component.set("v.updatedLateFee.lateFee", allFee);
    },
	updateFeeRecord:function(component, event, helper)
    {
        helper.updateFeeRecordHelper(component, event, helper);
    },
    saveButtonClick:function(component, event, helper)
    {
        var fee = component.get("v.objLateFee");
        
        if(fee.selectedMode && fee.selectedFeeType){
            if(fee.selectedMode == 'Date Range'){
                var checkAllFields = false;
                for (var i = 0; i < fee.lateFee.length; i++) {
                    if(fee.lateFee[i].FromDay && fee.lateFee[i].totDay && fee.lateFee[i].totAmount){
                    }
                    else{
                        checkAllFields = true;
                    }
                }    
                
                if(checkAllFields){
                	helper.showToast(component,"dismissible","Failed","Please Fill All Feilds","error");    
                }
                else{
                    helper.saveFeeRecordHelper(component, event, helper);
                }
            }
            if(fee.selectedMode == 'Daily Basis'){
                if(fee.totAmount && fee.totAmount > 0){
                   helper.saveFeeRecordHelper(component, event, helper); 
                }
                else{
                    helper.showToast(component,"dismissible","Failed","Please Fill Amount","error");    
                }
            }
        }
        else{
        	helper.showToast(component,"dismissible","Failed","Please Fill Fee Type and Fee Calculation Type","error");    
        }        
    },
    updateButtonClick : function(component, event, helper) {
        var fee = component.get("v.objLateFee");
        var udFee = component.get("v.updatedLateFee");
        
        if(udFee.selectedMode && fee.selectedFeeType){
            if(udFee.selectedMode == 'Date Range'){
                var checkAllFields = false;
                for (var i = 0; i < udFee.lateFee.length; i++) {
                    if(udFee.lateFee[i].FromDay && udFee.lateFee[i].totDay && udFee.lateFee[i].totAmount){
                    }
                    else{
                        checkAllFields = true;
                    }
                }    
                
                if(checkAllFields){
                	helper.showToast(component,"dismissible","Failed","Please Fill All Feilds","error");    
                }
                else{
                    helper.updateLateFeeHelper(component, event, helper);
                }
            }
            if(udFee.selectedMode == 'Daily Basis'){
                if(udFee.totAmount && udFee.totAmount > 0){
                   helper.updateLateFeeHelper(component, event, helper); 
                }
                else{
                    helper.showToast(component,"dismissible","Failed","Please Fill Amount","error");    
                }
            }
        }
        else{
            helper.showToast(component,"dismissible","Failed","Please Fill Fee Type and Fee Calculation Type","error");
        }
        
        
        
    //	helper.updateLateFeeHelper(component, event, helper);    
    }
    
})