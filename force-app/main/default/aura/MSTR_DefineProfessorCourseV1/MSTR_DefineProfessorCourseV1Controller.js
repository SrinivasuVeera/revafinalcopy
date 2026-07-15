({
    doInit: function (component, event, helper) {
        helper.doInitHlpr(component, event, helper);
    },
    changeSchool: function (component, event, helper) {
        var schoolProf = component.get("v.showProfSchool");
        helper.changeSchoolHlpr(component, event, helper);

    },
    changeProgram: function (component, event, helper) {
        helper.changeProgramHlpr(component, event, helper);
        // component.set("v.ProfPreference", false);
    },

    handleExistingPreferences: function (component, event, helper) {

        component.set("v.profExistingPreference", event.getParam("data"));


    },
    changePreference: function (component, event, helper) {
        helper.changePreferenceHlpr(component, event, helper);
    },
    changeProgramPlan: function (component, event, helper) {
        helper.changeProgramPlanHlpr(component, event, helper);
        //component.set("v.ProfPreference", false);
    },
    changeTerm: function (component, event, helper) {
        helper.getPreferenceHlpr(component, event, helper);
        helper.changeTermHlpr(component, event, helper);
    },

    SaveCourseOffering: function (component, event, helper) {
        helper.ValidationHlpr(component, event, helper, 'save');
    },
    SaveConfrimAction: function (component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    closeAction: function (component, event, helper) {
        var profSchool = component.get("v.showProfSchool");
        if (profSchool == true)
            component.set("v.SelectedSchoolId", null);
        component.set('v.SelectedProgramId', null);
        component.set('v.SelectedProgramPlanId', null);
        component.set('v.SelectedTermId', null);
        var lstCourse = [];
        component.set("v.List_CourseMain", lstCourse);
        component.set("v.List_CourseMain", lstCourse);
        component.set("v.MapTermName", null);
        component.set("v.MapProgramPlanName", null);
        component.set("v.MapProgramName", null);
    },
    closeModel: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    submitDetails: function (component, event, helper) {
        component.set("v.isModalOpen", false);
        helper.ValidationHlpr(component, event, helper, 'confirm');
        //helper.SaveConfrimHlpr(component, event, helper);
    },
})