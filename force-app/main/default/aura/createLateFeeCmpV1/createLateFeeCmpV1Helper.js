({
	doInitHelper: function(component, event, helper) {
		var action = component.get("c.getFeeTypeDetails");
    	action.setCallback(this, function(response) {
        var State = response.getState();
            if (State === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var feeTypeMap = [];
                    var feeCalculationMap = [];
                    var schoolMap = [];
                    var feeType = response.getReturnValue();
                    
                    for (var key in feeType.mapFeeTypePickVal) {
                        feeTypeMap.push({ value: feeType.mapFeeTypePickVal[key], key: key });
                    }
                    for (var key in feeType.mapFeeModePickVal) {
                        feeCalculationMap.push({ value: feeType.mapFeeModePickVal[key], key: key });
                    }
                    for (var key in feeType.mapSchoolPickVal) {
                        schoolMap.push({ value: feeType.mapSchoolPickVal[key], key: key });
                    }
                    component.set("v.feeTypeMap", feeTypeMap);
                    component.set("v.feeCalculationMap", feeCalculationMap);
                    component.set("v.mapSchools", schoolMap);
                    component.set("v.objLateFee", feeType);
                    component.set("v.showRecord", true);
                    
                } else {
                    this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
                }
            } else {
                this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
            }
       });
       $A.enqueueAction(action);    
	},
    getProgramDetails: function(component, event, helper) {
    var action = component.get("c.getProgramDetails");
    action.setParams({ schoolId: component.get("v.objLateFee.selectedSchool") });
    action.setCallback(this, function(response) {
      var State = response.getState();
      if (State === "SUCCESS") {
        //alert('=== Response ===='+JSON.stringify(response.getReturnValue()));
        if (response.getReturnValue() != undefined) {
          var mapValues = [];
          var pgm = response.getReturnValue();
          for (var key in pgm) {
            mapValues.push({ label: pgm[key], value: key });
          }  
          
          component.set("v.mapPrograms", mapValues);
        } else {
          this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
        }
      } else {
        this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
      }
    });
    $A.enqueueAction(action);
  },
  ProgramChangeHelper: function(component, event, helper) {
      var objFee = component.get("v.objLateFee");
    //  alert(JSON.stringify(objFee));
     // console.log('=== Response ===='+JSON.stringify(objFee));
      if(objFee.selectedSchool && objFee.selectedProgram && objFee.selectedFeeType && objFee.selectedMode){
           var action = component.get("c.getProgramBatchDetails");    
            action.setParams({ selectedFeeType: objFee.selectedFeeType,
                              selectedPgm : objFee.selectedProgram});
            action.setCallback(this, function(response) {
              var State = response.getState();
              if (State === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                  var pgm = response.getReturnValue();
                  component.set("v.prgBatchList", pgm);
                } else {
                  this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
                }
              } else {
                this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
              }
            });
            $A.enqueueAction(action);		    
          
      }
  }, 
  selectAllCheckboxHelper : function(component, event, helper){
        var selectedHeaderCheck =  event.getSource().get("v.value");
        var updatedBatchRecords = [];
        var listBatch = component.get("v.prgBatchList");
        for (var i = 0; i < listBatch.length; i++) {
            if (selectedHeaderCheck == true && listBatch[i].exRecord == false){
                listBatch[i].isChecked = true;
            } 
            else{
                listBatch[i].isChecked = false;
            }
            updatedBatchRecords.push(listBatch[i]);
        }
        component.set("v.prgBatchList", updatedBatchRecords);
  },  
  updateFeeRecordHelper : function(component, event, helper){  
      var objFee = component.get("v.objLateFee");      
      var lstBatch = component.get("v.prgBatchList");
      component.set("v.isInsert", false);
      var selectedItem = event.currentTarget;
      var index = selectedItem.dataset.record;
      var recordId = lstBatch[index].id;
      component.set("v.selectedBatchId",recordId);
      var action = component.get("c.selectUpdateLateFee");    
      action.setParams({ batchId: recordId,
                        feeType : objFee.selectedFeeType,
                        feeMode : objFee.selectedMode});
      action.setCallback(this, function(response) {
          var State = response.getState();
          if (State === "SUCCESS") {
              if (response.getReturnValue() != undefined) {
                  var pgm = response.getReturnValue();
                 // console.log('=== Response ===='+JSON.stringify(pgm));
                  var deletedIds = [];
                  component.set("v.deletedRecordIds", deletedIds);
                  component.set("v.updatedLateFee", pgm);
                  component.set("v.isModalOpen", true);
              } else {
                  this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
              }
          } else {
              this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
          }
      });
      $A.enqueueAction(action);
      
  },    
  saveFeeRecordHelper : function(component, event, helper){
      var objFee = component.get("v.objLateFee");
      var lstBatch = component.get("v.prgBatchList");
      var objbatch = component.get("v.selectedBatchId");
      var batchIds = [];
      for (var i = 0; i < lstBatch.length; i++) {
          if(lstBatch[i].isChecked){
              batchIds.push(lstBatch[i].id);
          }
      }    
    //  alert('test');
    //  alert(JSON.stringify(objFee.lateFee));
    //  alert(JSON.stringify(component.get("v.deletedRecordIds")));
      var action = component.get("c.insertLateFee");    
      action.setParams({ feeType : objFee.selectedFeeType,
                        feeMode : objFee.selectedMode,
                        deletedIds : component.get("v.deletedRecordIds"),
                        prgIds : objFee.selectedProgram,
                        lstSubFee : objFee.lateFee,
                        batchIds : batchIds,
                        isInsert : component.get("v.isInsert"),
                        totAmount : objFee.totAmount,
                        batchId : component.get("v.selectedBatchId")});
      
      action.setCallback(this, function(response) {
         // alert(action.getState());
          var State = response.getState();
        //  alert(state);
          if (State === "SUCCESS") {
              if (response.getReturnValue() != undefined) {
                  var msg = response.getReturnValue();
                 // alert(msg);
                  if(msg == 'Success'){
                      component.set("v.isModalOpen", false);
                      component.set("v.isInsert", false);
                      this.showToast(component,"dismissible","Success","Record Updated Sucessfully","Success");
                      $A.get('e.force:refreshView').fire();
                  }
                  else{
                      this.showToast(component,"dismissible","Failed","Record Update Failed","error");
                  }
              } else {
                  this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
              }
          } else {
              this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
          }
      });
      $A.enqueueAction(action);
  },
   updateLateFeeHelper : function(component, event, helper){
      var objFee = component.get("v.objLateFee");
      var objbatch = component.get("v.selectedBatchId");
    //   alert(objbatch);
      var action = component.get("c.UpdateLateFee");    
      action.setParams({batchId : objbatch, 
                        feeType : objFee.selectedFeeType,
                        feeMode : objFee.selectedMode,
                        mainRec : component.get("v.updatedLateFee")});
      
      action.setCallback(this, function(response) {
         // alert(action.getState());
          var State = response.getState();
        //  alert(state);
          if (State === "SUCCESS") {
              if (response.getReturnValue() != undefined) {
                  var msg = response.getReturnValue();
                 // alert(msg);
                  if(msg == 'Success'){
                      component.set("v.isModalOpen", false);
                      component.set("v.isInsert", false);
                      this.showToast(component,"dismissible","Success","Record Updated Sucessfully","Success");
                      $A.get('e.force:refreshView').fire();
                  }
                  else{
                      this.showToast(component,"dismissible","Failed","Record Update Failed","error");
                  }
              } else {
                  this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
              }
          } else {
              this.showToast(component,"dismissible","Failed",response.getError()[0].message,"error");
          }
      });
      $A.enqueueAction(action);
  },  
  showToast: function(component, mode, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      mode: mode,
      title: title,
      message: message,
      type: type,
      duration: "2"
    });
    toastEvent.fire();
  }  
})