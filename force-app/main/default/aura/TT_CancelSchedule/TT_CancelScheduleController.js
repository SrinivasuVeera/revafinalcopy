({
	onInit : function(component, event, helper) {
		helper.getUniversityHlprList(component, event, helper);
	},
    
    onUnivertyChange : function(component, event, helper) {
		helper.onChangeHelper(component, event, helper,'university','');
	},
    
    onFacultyChange : function(component, event, helper) {
        component.set("v.selectedSchool",'');
        component.set("v.selectedProgram",'');
        component.set("v.selectedProgramBatch",'');
        component.set("v.selectedSemester",'');
        component.set("v.selectedSection",'');
		helper.onChangeHelper(component, event, helper,'faculty','');
        
	},
    
    onSchoolChange : function(component, event, helper) {
        component.set("v.selectedProgram",'');
        component.set("v.selectedProgramBatch",'');
        component.set("v.selectedSemester",'');
        component.set("v.selectedSection",'');
		helper.onChangeHelper(component, event, helper,'school','');
	},
    
    onProgramChange : function(component, event, helper){
        component.set("v.selectedProgramBatch",'');
        component.set("v.selectedSemester",'');
        component.set("v.selectedSection",'');
        helper.onProgramChangeHelper(component, event, helper);
    },
    
    onProgramBatchChange : function(component, event, helper){
        component.set("v.selectedSemester",'');
        component.set("v.selectedSection",'');
        helper.onProgramBatchChangeHelper(component, event, helper);
    },
    
    onSemesterChange : function(component, event, helper){
        component.set("v.selectedSection",'');
        helper.onSemesterChangeHelper(component, event, helper);
    },
    
    onConfirm : function(component, event, helper){
        helper.onConfirmHelper(component, event, helper);
    }
})