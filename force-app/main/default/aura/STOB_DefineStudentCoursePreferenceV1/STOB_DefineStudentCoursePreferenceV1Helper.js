({
    DisplayCourseOfferingRecHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.DisplayCourseOfferingRecords");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isRBSSchool", response.getReturnValue().isRBSSchool);
                if (response.getReturnValue() != undefined && response.getReturnValue().listMainCourse.length > 0) {

                    var retVal = response.getReturnValue();
                    component.set("v.Termname", retVal.objTermname);
                    component.set("v.lstHardCore", retVal.listHardCore);
                    component.set("v.lstoElective", retVal.listOpenElective);
                    component.set("v.lstpElective", retVal.listProfElective);
                    component.set("v.lstPractical", retVal.listPractical);
                    component.set("v.lstHcIntegrated", retVal.listHcIntegrated);
                    component.set("v.lstMandatory", retVal.listMandatory);
                    component.set("v.List_CourseMain", retVal.listMainCourse);
                    component.set("v.StuPreference", retVal.StudentPreference);
                    component.set("v.totalCredit", retVal.totalCredit);

                    component.set("v.ShowConfirm", true);
                    component.set("v.ErrMessage", retVal.ErrmsgMain);
                }
                else {
                    this.DisplayCourseOfferingHlpr(component, event, helper);
                }
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }

        });
        $A.enqueueAction(action);
    },
    DisplayCourseOfferingHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.DisplayCourseOffering");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var retVal = response.getReturnValue();
                    component.set("v.Termname", retVal.objTermname);
                    component.set("v.lstHardCore", retVal.listHardCore);
                    component.set("v.lstoElective", retVal.listOpenElective);
                    component.set("v.lstpElective", retVal.listProfElective);
                    component.set("v.lstPractical", retVal.listPractical);
                    component.set("v.lstHcIntegrated", retVal.listHcIntegrated);
                    component.set("v.lstMandatory", retVal.listMandatory);
                    component.set("v.List_CourseMain", retVal.listMainCourse);
                    component.set("v.totalCredit", retVal.totalCredit);
                    component.set("v.ErrMessage", retVal.ErrmsgMain);
                }
                //component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }

        });
        $A.enqueueAction(action);
    },
    OnSaveHlpr: function (component, event, helper, Method) {
        component.set("v.Spinner", true);
        var action = component.get("c.ValidationPreferences");
        action.setParams({
            'lstOpenElective': component.get("v.lstoElective"),
            'lstProfElective': component.get("v.lstpElective")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    if (response.getReturnValue().showsave == true) {
                        if (response.getReturnValue().OpenElectiveErrmsg != null) {
                            var retVal = response.getReturnValue().OpenElectiveErrmsg;
                            this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                        }
                        if (response.getReturnValue().OpenDupPreference != null) {
                            var retVal = response.getReturnValue().OpenDupPreference;
                            this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                        }
                        if (response.getReturnValue().ProfElectiveErrmsg != null) {
                            var retVal = response.getReturnValue().ProfElectiveErrmsg;
                            this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                        }
                        if (response.getReturnValue().PrefDupPreference != null) {
                            var retVal = response.getReturnValue().PrefDupPreference;
                            this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                        }
                        if (response.getReturnValue().CountOpenPrefErrmsg != null) {
                            var retVal = response.getReturnValue().CountOpenPrefErrmsg;
                            this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                        }
                    }
                    if (response.getReturnValue().showsave != true) {
                        if (Method == 'save')
                            this.SaveHlpr(component, event, helper);
                        else if (Method == 'update')
                            this.OnSaveUpdateHlpr(component, event, helper);
                        else if (Method == 'confirm')
                            this.OnSaveConfirmHlpr(component, event, helper);
                    }
                }
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    SaveHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.SaveStudentCourseprefernce");
        action.setParams({
            'lstOpenEle': component.get("v.lstoElective"),
            'lstProfel': component.get("v.lstpElective"),
            'StuPreference': false
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast(component, 'dismissible', 'success', ' Professor / Student Course Preference created Successfully..!', 'success');
                /*var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://revadev-revastudentportaldev.cs75.force.com/s/"
                });*/
                urlEvent.fire();
                component.set("v.ShowConfirm", true);
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    OnSaveUpdateHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.SaveStudentCourseprefernce");
        action.setParams({
            'lstOpenEle': component.get("v.lstoElective"),
            'lstProfel': component.get("v.lstpElective"),
            'StuPreference': false
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast(component, 'dismissible', 'success', ' Professor / Student Course Preference Updated Successfully..!', 'success');
                var urlEvent = $A.get("e.force:navigateToURL");
                /*urlEvent.setParams({
                    "url": "https://revadev-revastudentportaldev.cs75.force.com/s/"
                });*/
                urlEvent.fire();
                $A.get("e.force:refreshView").fire();
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    OnSaveConfirmHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.SaveStudentCourseprefernce");
        action.setParams({
            'lstOpenEle': component.get("v.lstoElective"),
            'lstProfel': component.get("v.lstpElective"),
            'StuPreference': true
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast(component, 'dismissible', 'success', ' Professor / Student Course Preference Confirmed Successfully..!', 'success');
                var urlEvent = $A.get("e.force:navigateToURL");
                /*urlEvent.setParams({
                    "url": "https://revadev-revastudentportaldev.cs75.force.com/s/"
                });*/
                // urlEvent.fire();*/
                $A.get("e.force:refreshView").fire();
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    getPreferenceHlpr: function (component, event, helper) {
        var action = component.get("c.getPreference");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var PreferenceMap = [];
                var result = response.getReturnValue();
                for (var key in result) {
                    PreferenceMap.push({ key: key, value: result[key] });
                }
                component.set("v.MapPreference", PreferenceMap);
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function (component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration": '2'
        });
        toastEvent.fire();
    }
})