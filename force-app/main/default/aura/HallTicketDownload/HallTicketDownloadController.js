({
    init: function(component, event, helper) {        
        component.set("v.eligibilityList", [
            { label: "Eligible",    value: "Eligible" },
            { label: "Ineligible",  value: "Ineligible" }
        ]);
        component.set("v.iaTypeList", [
            { label: "IA 1",          value: "IA 1" },
            { label: "IA 2",          value: "IA 2" },
            { label: "Semester Exam", value: "Semester Exam" }
        ]);
        component.set("v.tableColumns", [
            { label: "S.No", fieldName: "serial", type: "number", initialWidth: 70},
            { label: "SRN",  fieldName: "SRN_Number__c", type: "text"},
            { label: "Name", fieldName: "Name", type: "text"}
        ]);
        
        helper.getUniversityHlprList(component, event, helper);
    },
    onUnivertyChange: function(component, event, helper) {
        helper.onChangeHelper(component, event, helper,'university','');
    },
    
    onFacultyChange: function(component, event, helper) {               
        component.set("v.selectedSchool", '');
        component.set("v.selectedProgram", '');
        component.set("v.selectedProgramBatch", '');
        component.set("v.selectedSemester", '');
        helper.onChangeHelper(component, event, helper, 'faculty', '');
    },
    
    onSchoolChange: function(component, event, helper) {
        component.set("v.selectedProgram", '');
        component.set("v.selectedProgramBatch", '');
        component.set("v.selectedSemester", '');
        helper.onChangeHelper(component, event, helper, 'school', '');
    },
    
    onProgramChange: function(component, event, helper) {
        component.set("v.selectedProgramBatch", '');
        component.set("v.selectedSemester", '');
        helper.onProgramChangeHelper(component, event, helper);
    },
    
    onProgramBatchChange: function(component, event, helper) {
        component.set("v.selectedSemester", '');
        helper.onProgramBatchChangeHelper(component, event, helper);
    },
    
    onSemesterChange: function(component, event, helper) {
        helper.onSemesterChangeHelper(component, event, helper);
    },
    toggleBatchMode: function(component, event, helper) {
    var isOn = event.getSource().get("v.checked");
    component.set("v.useCustomBatch", isOn);
    
    if (!isOn) {
        component.set("v.customBatchSize", 20); // Reset to default
    }
},

updateBatchSize: function(component, event, helper) {
    var value = event.getSource().get("v.value");
    if (value && value > 0) {
        component.set("v.customBatchSize", parseInt(value));
    }
},
    onNext: function(component, event, helper) {
        var semesterId   = component.get("v.selectedSemester");
        var eligibility  = component.get("v.selectedEligibility");
        var iaType       = component.get("v.selectedIAType");
        
        if (!semesterId || !eligibility || !iaType) {
            helper.showToast("Error", "Please select all required fields", "error");
            return;
        }
        
        component.set("v.isLoading", true);
        
        helper.validateExamNotification(component, event, helper,
                                        semesterId, iaType,
                                        function(isValid) {
                                            if (!isValid) {
                                                component.set("v.isLoading", false);
                                                helper.showToast("Error",
                                                                 "No valid exam notification found for the selected criteria",
                                                                 "error");
                                                return;
                                            }                                                                                       
                                            var action = component.get("c.getEligibleStudents");
                                            action.setParams({
                                                semesterId : semesterId,
                                                eligibility: eligibility
                                            });
                                            
                                            action.setCallback(this, function(resp) {
                                                component.set("v.isLoading", false);
                                                var state = resp.getState();
                                                if (state === "SUCCESS") {
                                                    var rows = resp.getReturnValue();
                                                    rows.forEach(function(r, i) { r.serial = i + 1; r.SRN_Number__c = r.SRN; delete r.SRN;});
                                                    component.set("v.studentList", rows);
                                                    component.set("v.filteredStudentList", rows);
                                                    component.set("v.showModal", true);
                                                } else {
                                                    helper.showToast("Error", resp.getError()[0].message, "error");
                                                }
                                            });
                                            $A.enqueueAction(action);
                                        });
    },
    doSearch: function(component, event, helper) {
        var searchKey = (component.get("v.searchKey") || "").trim();
        var allStudents = component.get("v.studentList") || [];
        var filtered = allStudents;
        
        if (searchKey) {
            var lowerKey = searchKey.toLowerCase();
            filtered = allStudents.filter(function(row) {
                var srn = (row.SRN_Number__c || "").toString().toLowerCase();
                return srn.includes(lowerKey);
            });
        }
        
        component.set("v.filteredStudentList", filtered);
        
        // Sync selection with visible rows
        var selected = component.get("v.selectedStudentIds") || [];
        var visibleIds = filtered.map(r => r.Id);
        var newSel = selected.filter(id => visibleIds.includes(id));
        component.set("v.selectedStudentIds", newSel);
        
        var table = component.find("studentTable");
        if (table) {
            table.set("v.selectedRows", newSel);
        }
    },
    closeModal: function(component, event, helper) {
        component.set("v.showModal", false);
        component.set("v.studentList", []);
    },
    handleRowSelection: function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var selectedIds = selectedRows.map(function(row) { return row.Id; });
        component.set("v.selectedStudentIds", selectedIds);
        var dt = component.find("studentTable");
        if (dt) {
            dt.set("v.selectedRows", selectedIds);
        }
    },       
    onDownloadSelected: function(component, event, helper) {
    var selectedIds = component.get("v.selectedStudentIds");
    if (!selectedIds || selectedIds.length === 0) {
        helper.showToast("Warning", "Please select at least one student", "warning");
        return;
    }

    var semesterId = component.get("v.selectedSemester");
    var eligibility = component.get("v.selectedEligibility");
    var useCustom = component.get("v.useCustomBatch");
    var batchSize = useCustom ? component.get("v.customBatchSize") : null;

    // Optional: Validate
    if (useCustom && (batchSize < 5 || batchSize > 100)) {
        helper.showToast("Error", "Batch size must be 5–100", "error");
        return;
    }

    component.set("v.isDownloading", true);
    component.set("v.isLoading", true);

    helper.downloadSelectedHallTickets(
        component, event, helper,
        semesterId, eligibility, selectedIds, batchSize
    );
},
    
    onCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})