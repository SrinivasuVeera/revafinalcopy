({
	doInit : function(component, event, helper) {
		helper.getTermDetailHlp(component,event,helper);
	},
        addHardCoreRecord : function(component, event, helper) {
       helper.addHardCoreRecordHelper(component,event,helper); 
    },
	RemoveHardCoreRecord : function(component, event, helper) {
       helper.RemoveHardCoreRecordHelper(component,event,helper); 
    },
    
    addHcIntegratedRecord : function(component, event, helper) {
       helper.addHcIntegratedRecordHelper(component,event,helper); 
    },
	RemoveHcIntegratedRecord : function(component, event, helper) {
       helper.RemoveHcIntegratedRecordHelper(component,event,helper); 
    },
    addMandatoryRecord : function(component, event, helper) {
       helper.addMandatoryRecordHelper(component,event,helper); 
    },
	RemoveMandatoryRecord : function(component, event, helper) {
       helper.RemoveMandatoryRecordHelper(component,event,helper); 
    },
    
	addopenElectiveRecord : function(component, event, helper) {
       helper.addopenElectiveRecordHelper(component,event,helper); 
    },
	RemoveopenElective : function(component, event, helper) {
       helper.RemoveopenElectiveHelper(component,event,helper); 
    },
	addopenElectiveLiRec : function(component, event, helper) {
       helper.addopenElectiveLiRecHelper(component,event,helper); 
    },
	RemoveopenElectiveLi : function(component, event, helper) {
       helper.RemoveopenElectiveLiHelper(component,event,helper); 
    },
	addProElectiveRecord : function(component, event, helper) {
       helper.addProElectiveRecordHelper(component,event,helper); 
    },
	RemoveProElective : function(component, event, helper) {
       helper.RemoveProElectiveHelper(component,event,helper); 
    },
	addProElectiveLiRec : function(component, event, helper) {
       helper.addProElectiveLiRecHelper(component,event,helper); 
    },
	RemoveProElectiveLi : function(component, event, helper) {
       helper.RemoveProElectiveLiHelper(component,event,helper); 
    },
	addPracticalRecord : function(component, event, helper) {
       helper.addPraticalRecordHelper(component,event,helper); 
    },
	RemovePractical : function(component, event, helper) {
       helper.RemovePraticalHelper(component,event,helper); 
    },
    calculateCredit : function(component, event, helper) {
       helper.calculateCreditHelper(component,event,helper); 
    },
    saveRecord : function(component, event, helper) {
        var errMsg = 'Success';
		var hc = component.get("v.lstHardCore");
        var arr = [];
        for(var i=0;i<hc.length;i++){ 
			if(hc[i].count == '' || hc[i].courseId == '' || hc[i].credits == '' || 
			   hc[i].count == undefined || hc[i].courseId == undefined || hc[i].credits == undefined){
				
				errMsg = 'Please Fill All Values..!!'
			}
            else{                
                if(arr.includes(hc[i].courseId)){
                    errMsg = "The subject '"+ hc[i].courseName +"' already exists in this term";
                }
                else{
                	arr.push(hc[i].courseId);
                }    
            }
		}
		
		var hi = component.get("v.lstHcIntegrated");
        arr = [];
        for(var i=0;i < hi.length;i++){ 
			if(hi[i].count == '' || hi[i].courseId == '' || hi[i].credits == '' || 
			   hi[i].count == undefined || hi[i].courseId == undefined || hi[i].credits == undefined){
				
				errMsg = 'Please Fill All Values..!!'
			}
            else{                
                if(arr.includes(hi[i].courseId)){
                    errMsg = "The subject '"+ hi[i].courseName +"' already exists in this term";
                }
                else{
                	arr.push(hi[i].courseId);
                }    
            }
		}
		
		var pra = component.get("v.lstPractical");
        arr = [];
        for(var i=0;i < pra.length;i++){ 
			if(pra[i].count == '' || pra[i].courseId == '' || pra[i].credits == '' || 
			   pra[i].count == undefined || pra[i].courseId == undefined || pra[i].credits == undefined){
				
				errMsg = 'Please Fill All Values..!!'
			}
            else{                
                if(arr.includes(pra[i].courseId)){
                    errMsg = "The subject '"+ pra[i].courseName +"' already exists in this term";
                }
                else{
                	arr.push(pra[i].courseId);
                }    
            }
		}
		
		var mnt = component.get("v.lstMandatory");
        arr = [];
        for(var i=0;i < mnt.length;i++){ 
			if(mnt[i].count == '' || mnt[i].courseId == '' || mnt[i].credits == '' || 
			   mnt[i].count == undefined || mnt[i].courseId == undefined || mnt[i].credits == undefined){
				
				errMsg = 'Please Fill All Values..!!'
			}
            else{                
                if(arr.includes(mnt[i].courseId)){
                    errMsg = "The subject '"+ mnt[i].courseName +"' already exists in this term";
                }
                else{
                	arr.push(mnt[i].courseId);
                }    
            }
		}
		
		var oe = component.get("v.lstoElective");
        arr = [];
        for(var i=0;i < oe.length;i++){ 
			if(oe[i].count == '' || oe[i].count == undefined ||
			   oe[i].credits == '' || oe[i].credits == undefined){
				errMsg = 'Please Fill All Values..!!'
		   }
			for(var j=0;j < oe[i].lstPlanLi.length;j++){ 
				if(oe[i].lstPlanLi[j].count == '' || oe[i].lstPlanLi[j].courseId == '' || 
				   oe[i].lstPlanLi[j].count == undefined || oe[i].lstPlanLi[j].courseId == undefined){
					
					errMsg = 'Please Fill All Values..!!'
				}
                else{                
                    if(arr.includes(oe[i].lstPlanLi[j].courseId)){
                        errMsg = "The subject '"+oe[i].lstPlanLi[j].courseName+"' already exists in this term";
                    }
                    else{
                        arr.push(oe[i].lstPlanLi[j].courseId);
                    }    
                }
			}
		}
		
		var pl = component.get("v.lstpElective");
        arr = [];
        for(var i=0;i < pl.length;i++){ 
			if(pl[i].count == '' || pl[i].count == undefined ||
			   pl[i].credits == '' || pl[i].credits == undefined){
				errMsg = 'Please Fill All Values..!!'
		   }
			for(var j=0;j < pl[i].lstPlanLi.length;j++){ 
				if(pl[i].lstPlanLi[j].count == '' || pl[i].lstPlanLi[j].courseId == '' || 
				   pl[i].lstPlanLi[j].count == undefined || pl[i].lstPlanLi[j].courseId == undefined){
					
					errMsg = 'Please Fill All Values..!!'
				}
                else{                
                    if(arr.includes(pl[i].lstPlanLi[j].courseId)){
                        errMsg = "The subject '"+pl[i].lstPlanLi[j].courseName+"' already exists in this term";
                    }
                    else{
                        arr.push(pl[i].lstPlanLi[j].courseId);
                    }    
                }
			}
		}
        if(errMsg == 'Success'){
            var bool = false;
    		helper.saveRecordHelper(component,event,helper,bool);    
        }   
        else{
            helper.showToast(component,'dismissible','Failed',errMsg,'error');
        }    
	},
    saveandSubmitRecord : function(component, event, helper) {
        var errMsg = 'Success';
		var hc = component.get("v.lstHardCore");
        var arr = [];
        for(var i=0;i<hc.length;i++){ 
			if(hc[i].count == '' || hc[i].courseId == '' || hc[i].credits == '' || 
			   hc[i].count == undefined || hc[i].courseId == undefined || hc[i].credits == undefined){
				
				errMsg = 'Please Fill All Values..!!'
			}
            else{                
                if(arr.includes(hc[i].courseId)){
                    errMsg = "The subject '"+ hc[i].courseName +"' already exists in this term";
                }
                else{
                	arr.push(hc[i].courseId);
                }    
            }
		}
		
		var hi = component.get("v.lstHcIntegrated");
        arr = [];
        for(var i=0;i < hi.length;i++){ 
			if(hi[i].count == '' || hi[i].courseId == '' || hi[i].credits == '' || 
			   hi[i].count == undefined || hi[i].courseId == undefined || hi[i].credits == undefined){
				
				errMsg = 'Please Fill All Values..!!'
			}
            else{                
                if(arr.includes(hi[i].courseId)){
                    errMsg = "The subject '"+ hi[i].courseName +"' already exists in this term";
                }
                else{
                	arr.push(hi[i].courseId);
                }    
            }
		}
		
		var pra = component.get("v.lstPractical");
        arr = [];
        for(var i=0;i < pra.length;i++){ 
			if(pra[i].count == '' || pra[i].courseId == '' || pra[i].credits == '' || 
			   pra[i].count == undefined || pra[i].courseId == undefined || pra[i].credits == undefined){
				
				errMsg = 'Please Fill All Values..!!'
			}
            else{                
                if(arr.includes(pra[i].courseId)){
                    errMsg = "The subject '"+ pra[i].courseName +"' already exists in this term";
                }
                else{
                	arr.push(pra[i].courseId);
                }    
            }
		}
		
		var mnt = component.get("v.lstMandatory");
        arr = [];
        for(var i=0;i < mnt.length;i++){ 
			if(mnt[i].count == '' || mnt[i].courseId == '' || mnt[i].credits == '' || 
			   mnt[i].count == undefined || mnt[i].courseId == undefined || mnt[i].credits == undefined){
				
				errMsg = 'Please Fill All Values..!!'
			}
            else{                
                if(arr.includes(mnt[i].courseId)){
                    errMsg = "The subject '"+ mnt[i].courseName +"' already exists in this term";
                }
                else{
                	arr.push(mnt[i].courseId);
                }    
            }
		}
		
		var oe = component.get("v.lstoElective");
        arr = [];
        for(var i=0;i < oe.length;i++){ 
			if(oe[i].count == '' || oe[i].count == undefined ||
			   oe[i].credits == '' || oe[i].credits == undefined){
				errMsg = 'Please Fill All Values..!!'
		   }
			for(var j=0;j < oe[i].lstPlanLi.length;j++){ 
				if(oe[i].lstPlanLi[j].count == '' || oe[i].lstPlanLi[j].courseId == '' || 
				   oe[i].lstPlanLi[j].count == undefined || oe[i].lstPlanLi[j].courseId == undefined){
					
					errMsg = 'Please Fill All Values..!!'
				}
                else{                
                    if(arr.includes(oe[i].lstPlanLi[j].courseId)){
                        errMsg = "The subject '"+ oe[i].lstPlanLi[j].courseName +"' already exists in this term";
                    }
                    else{
                        arr.push(oe[i].lstPlanLi[j].courseId);
                    }    
                }
			}
		}
		
		var pl = component.get("v.lstpElective");
        arr = [];
        for(var i=0;i < pl.length;i++){ 
			if(pl[i].count == '' || pl[i].count == undefined ||
			   pl[i].credits == '' || pl[i].credits == undefined){
				errMsg = 'Please Fill All Values..!!'
		   }
			for(var j=0;j < pl[i].lstPlanLi.length;j++){ 
				if(pl[i].lstPlanLi[j].count == '' || pl[i].lstPlanLi[j].courseId == '' || 
				   pl[i].lstPlanLi[j].count == undefined || pl[i].lstPlanLi[j].courseId == undefined){
					
					errMsg = 'Please Fill All Values..!!'
				}
                else{                
                    if(arr.includes(pl[i].lstPlanLi[j].courseId)){
                        errMsg = "The subject '"+ pl[i].lstPlanLi[j].courseName +"' already exists in this term";
                    }
                    else{
                        arr.push(pl[i].lstPlanLi[j].courseId);
                    }    
                }
			}
		}
        if(errMsg == 'Success'){
            var bool = true;
    		helper.saveRecordHelper(component,event,helper,bool);    
        }   
        else{
            helper.showToast(component,'dismissible','Failed',errMsg,'error');
        }    
	},
	closeAction : function(component, event, helper) 
    {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
      //	component.set("v.showPPTable",false);  
    }
})