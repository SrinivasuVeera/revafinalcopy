({
    doInitHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.displaySchools");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mapAccSchoolValues = [];
                var result = response.getReturnValue().mapAccSchool;
                for (var key in result) {
                    mapAccSchoolValues.push({ key: key, value: result[key] });
                }

                component.set("v.showProfSchool", response.getReturnValue().profSchool);
                component.set("v.showCourseAcross", response.getReturnValue().courseAcross);
                component.set("v.LoginuserAccount", response.getReturnValue().loginUserAccountName);
                component.set("v.MapSchoolName", mapAccSchoolValues);

                if (mapAccSchoolValues.length == 1) {
                    if (response.getReturnValue().profSchool == false) {
                        component.set("v.SelectedSchoolId", mapAccSchoolValues[0].key);
                        this.changeSchoolHlpr(component, event, helper);
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
    changeSchoolHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var SelAccSchoolId = component.get("v.SelectedSchoolId");
        var selectedCourse = component.get("v.showCourseAcross");
        component.set('v.SelectedProgramPlanId', null);
        component.set('v.SelectedProgramId', null);
        component.set('v.SelectedTermId', null);
        component.set("v.MapTermName", null);
        component.set("v.MapProgramPlanName", null);
        component.set("v.MapProgramName", null);
        component.set("v.List_CourseMain", []);
        if (!SelAccSchoolId) {
            component.set("v.Spinner", false);
            return;
        }
        var loginAcc = component.get("v.LoginuserAccount");
        var action = component.get("c.displayProgram");
        action.setParams({
            'accSchoolId': SelAccSchoolId,
            'selCourseAcross': selectedCourse,
            'loginAccountName': loginAcc
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mapAccProgramValues = [];
                var result = response.getReturnValue();
                for (var key in result) {
                    mapAccProgramValues.push({ key: key, value: result[key] });
                }
                component.set("v.MapProgramName", mapAccProgramValues);
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    changeProgramHlpr: function (component, event, helper) {


        component.set("v.Spinner", true);
        var SelAccProgramId = component.get("v.SelectedProgramId");
        component.set('v.SelectedProgramPlanId', null);
        component.set('v.SelectedTermId', null);
        component.set("v.MapTermName", null);
        component.set("v.MapProgramPlanName", null);
        component.set("v.List_CourseMain", []);

        if (!SelAccProgramId) {
            component.set("v.Spinner", false);
            return;
        }
        var selectedCourse = component.get("v.showCourseAcross");
        var loginAcc = component.get("v.LoginuserAccount");
        var action = component.get("c.displayProgramPlan");
        action.setParams({
            'accProgramId': SelAccProgramId,
            'selCourseAcross': selectedCourse,
            'loginAccountName': loginAcc
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mapAccProgramPlanValues = [];
                var result = response.getReturnValue();
                for (var key in result) {
                    mapAccProgramPlanValues.push({ key: key, value: result[key] });
                }
                component.set("v.MapProgramPlanName", mapAccProgramPlanValues);
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    changeProgramPlanHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var SelAccProgramPlanId = component.get("v.SelectedProgramPlanId");
        component.set('v.SelectedTermId', null);
        component.set("v.MapTermName", null);
        component.set("v.List_CourseMain", [])
        if (!SelAccProgramPlanId) {
            component.set("v.Spinner", false);
            return;
        }
        var selectedCourse = component.get("v.showCourseAcross");
        var loginAcc = component.get("v.LoginuserAccount");
        var action = component.get("c.displayTerm");
        action.setParams({
            'accProgramPlanId': SelAccProgramPlanId,
            'selCourseAcross': selectedCourse,
            'loginAccountName': loginAcc
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mapAccTermValues = [];
                var result = response.getReturnValue();
                for (var key in result) {
                    mapAccTermValues.push({ key: key, value: result[key] });
                }

                if (mapAccTermValues.length > 0) {
                    component.set("v.MapTermName", mapAccTermValues);
                }
                else {

                    this.showToast(component, 'dismissible', 'Warning', 'For the selected Program Batch, there are no active semesters /Preference Allowed Currently disabled by the Vertical Head. Go with any other Program batch for Preference', 'warning');
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
    changeTermHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.ProfPreference", false);
        var SelAccTermId = component.get("v.SelectedTermId");
        var CourseAccross = component.get("v.showCourseAcross");
        var LoginAccName = component.get("v.LoginuserAccount");
        var SelAccSchoolId = component.get("v.SelectedSchoolId");
        var action = component.get("c.displayCourseOfferingRecords");
        action.setParams({
            'accTermId': SelAccTermId,
            'selCourseAcross': CourseAccross,
            'loginAccountName': LoginAccName,
            'accSchoolId': SelAccSchoolId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                component.set("v.ProfPreference", response.getReturnValue().professorPreference);
                component.set("v.isSaveButtonDisabled", response.getReturnValue().professorPreference);
                if (response.getReturnValue() != undefined && response.getReturnValue().listMainCourse.length > 0) {


                    var retVal = response.getReturnValue();
                    component.set("v.showCourseOffTable", true);
                    component.set("v.lstHardCore", retVal.listHardCore);
                    // component.set("v.lstOpenElective", retVal.listOpenElective);
                    component.set("v.lstProfElective", retVal.listProfElective);
                    component.set("v.lstPractical", retVal.listPractical);
                    component.set("v.lstHcIntegrated", retVal.listHcIntegrated);
                    component.set("v.lstMandatory", retVal.listMandatory);
                    component.set("v.List_CourseMain", retVal.listMainCourse);

                    component.set("v.StrCourseOffCategory", retVal.lstCourseOffCategory);

                    //duplicate list
                    component.set("v.dulstHardCore", JSON.parse(JSON.stringify(retVal.listHardCore)));
                    component.set("v.dulstOpenElective", JSON.parse(JSON.stringify(retVal.listOpenElective)));
                    component.set("v.dulstProfElective", JSON.parse(JSON.stringify(retVal.listProfElective)));
                    component.set("v.dulstPractical", JSON.parse(JSON.stringify(retVal.listPractical)));
                    component.set("v.dulstHcIntegrated", JSON.parse(JSON.stringify(retVal.listHcIntegrated)));
                    component.set("v.dulstMandatory", JSON.parse(JSON.stringify(retVal.listMandatory)));


                    var profschool = component.get("v.showProfSchool");
                    var CourseSchool = component.get("v.showCourseAcross");
                    var courseCategory = component.get("v.StrCourseOffCategory");
                    if (profschool == true && CourseSchool == true) {
                        for (var i = 0; i < courseCategory.length; i++) {
                            if (courseCategory[i] == 'Hardcore Course')
                                component.set("v.HCourse", false);
                            else if (courseCategory[i] == 'Hardcore Integrated Course')
                                component.set("v.HICourse", false);
                            else if (courseCategory[i] == 'Practical/Term work')
                                component.set("v.PracTermwork", false);
                            else if (courseCategory[i] == 'Professional Elective')
                                component.set("v.ProfEle", false);
                            else if (courseCategory[i] == 'Open Elective')
                                component.set("v.OpenEle", false);
                            else if (courseCategory[i] == 'Mandatory Course')
                                component.set("v.ManCourse", false);
                        }

                    }
                    else if (profschool == false) {
                        component.set("v.HCourse", false);
                        component.set("v.HICourse", false);
                        component.set("v.PracTermwork", false);
                        component.set("v.ProfEle", false);
                        component.set("v.OpenEle", false);
                        component.set("v.ManCourse", false);
                    }

                    else {

                        component.set("v.HCourse", false);
                        component.set("v.HICourse", false);
                        component.set("v.PracTermwork", false);
                        component.set("v.ProfEle", false);
                        component.set("v.OpenEle", false);
                        component.set("v.ManCourse", false);

                    }
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
        var SelAccTermId = component.get("v.SelectedTermId");
        var CourseAccross = component.get("v.showCourseAcross");
        var LoginAccName = component.get("v.LoginuserAccount");
        var SelAccSchoolId = component.get("v.SelectedSchoolId");
        var action = component.get("c.displayCourseOffering");
        action.setParams({
            'accTermId': SelAccTermId,
            'selCourseAcross': CourseAccross,
            'loginAccountName': LoginAccName,
            'accSchoolId': SelAccSchoolId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var retVal = response.getReturnValue();
                    component.set("v.showCourseOffTable", true);
                    component.set("v.lstHardCore", retVal.listHardCore);
                    // component.set("v.lstOpenElective", retVal.listOpenElective);
                    component.set("v.lstProfElective", retVal.listProfElective);
                    component.set("v.lstPractical", retVal.listPractical);
                    component.set("v.lstHcIntegrated", retVal.listHcIntegrated);
                    component.set("v.lstMandatory", retVal.listMandatory);
                    component.set("v.List_CourseMain", retVal.listMainCourse);
                    component.set("v.StrCourseOffCategory", retVal.lstCourseOffCategory);

                    component.set("v.dulstHardCore", JSON.parse(JSON.stringify(retVal.listHardCore)));
                    component.set("v.dulstOpenElective", JSON.parse(JSON.stringify(retVal.listOpenElective)));
                    component.set("v.dulstProfElective", JSON.parse(JSON.stringify(retVal.listProfElective)));
                    component.set("v.dulstPractical", JSON.parse(JSON.stringify(retVal.listPractical)));
                    component.set("v.dulstHcIntegrated", JSON.parse(JSON.stringify(retVal.listHcIntegrated)));
                    component.set("v.dulstMandatory", JSON.parse(JSON.stringify(retVal.listMandatory)));

                    var profschool = component.get("v.showProfSchool");
                    var CourseSchool = component.get("v.showCourseAcross");
                    var courseCategory = component.get("v.StrCourseOffCategory");

                    if (profschool == true && CourseSchool == true) {
                        for (var i = 0; i < courseCategory.length; i++) {
                            if (courseCategory[i] == 'Hardcore Course')
                                component.set("v.HCourse", false);
                            else if (courseCategory[i] == 'Hardcore Integrated Course')
                                component.set("v.HICourse", false);
                            else if (courseCategory[i] == 'Practical/Term work')
                                component.set("v.PracTermwork", false);
                            else if (courseCategory[i] == 'Professional Elective')
                                component.set("v.ProfEle", false);
                            else if (courseCategory[i] == 'Open Elective')
                                component.set("v.OpenEle", false);
                            else if (courseCategory[i] == 'Mandatory Course')
                                component.set("v.ManCourse", false);
                        }

                    }
                    else if (profschool == false) {
                        component.set("v.HCourse", false);
                        component.set("v.HICourse", false);
                        component.set("v.PracTermwork", false);
                        component.set("v.ProfEle", false);
                        component.set("v.OpenEle", false);
                        component.set("v.ManCourse", false);
                    }
                    else {

                        component.set("v.HCourse", false);
                        component.set("v.HICourse", false);
                        component.set("v.PracTermwork", false);
                        component.set("v.ProfEle", false);
                        component.set("v.OpenEle", false);
                        component.set("v.ManCourse", false);

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

    changePreferenceHlpr: function (component, event, helper) {
        const source = event.getSource();
        const nameAttr = source.get("v.name");
        const selectedPrefValue = source.get("v.value");

        const [listName, indexStr] = nameAttr.split("__");
        const index = parseInt(indexStr, 10);

        if (!listName || isNaN(index)) {
            console.error(" Invalid name format for lightning:select");
            return;
        }

        const list = component.get("v." + listName);
        const backupList = component.get("v.du" + listName); // original list for restoring
        const selectedTermId = component.get("v.SelectedTermId");
        const profExisting = component.get("v.profExistingPreference");

        if (!Array.isArray(list) || index >= list.length) {
            console.error("List not found or index out of bounds");
            return;
        }

        const currentRow = list[index];
        const currentSubtypeRaw = currentRow.hed__Course__r.HardCore_Sub_Type__c || '';
        const courseId = currentRow.Course_ID__c;

        const currentSubtype = currentSubtypeRaw.includes('Theory') ? 'Theory' : 'Practical';


        if (!selectedPrefValue) {
            currentRow.Preference__c = '';
            component.set("v." + listName, list);
            return;
        }

        let hasPreferenceConflict = false;
        let hasSameCourseConflict = false;
        let allowMandatoryCourse = true;

        let mandGivenPrefs = ['1', '2', '3'];

        for (let i = 0; i < profExisting.length; i++) {
            const record = profExisting[i];

            const recordSubtype = record.subtype && record.subtype.includes('Theory') ? 'Theory' : 'Practical';
            const isSameSemester = String(record.semesterId).trim() === String(selectedTermId).trim();

            if (String(record.preference) === String(selectedPrefValue)

                && recordSubtype === currentSubtype
                && !isSameSemester
            ) {
                hasPreferenceConflict = true;
                break;
            }
            else if (record.courseId === courseId && !isSameSemester) {
                hasSameCourseConflict = true;
                break;
            }

            else if (mandGivenPrefs.includes(String(record.preference))
                && recordSubtype === currentSubtype
                && !isSameSemester && record.category === 'Mandatory Course' && listName === 'lstMandatory'
            ) {
                this.showToast(
                    component,
                    'dismissible',
                    'Restricted Preference for mandatory !!',
                    'Only One Mandatory Courses Preference Allow across semesters, You already selected preference 1, 2, or 3.',
                    'error'
                );

                currentRow.Preference__c = backupList[index].Preference__c || '';
                component.set("v." + listName, list);
                return;

            }
        }

        if (hasPreferenceConflict) {
            this.showToast(
                component,
                'dismissible',
                'Preference Exist!!',
                'The selected preference number with Theory/Practical/Project subtype already exists in another semester. Please choose a different preference.',
                'error'
            );

            currentRow.Preference__c = backupList[index].Preference__c || '';
            component.set("v." + listName, list);
            return;
        }

        if (hasSameCourseConflict) {
            this.showToast(
                component,
                'dismissible',
                'Duplicate Course Preference Found !!',
                'The same course (Course ID) is already selected in another semester. Please select a different course.',
                'error'
            );

            currentRow.Preference__c = backupList[index].Preference__c || '';
            component.set("v." + listName, list);
            return;
        }

        currentRow.Preference__c = selectedPrefValue;
        /*if(selectedPrefValue){
            currentRow.Number_of_Times_Course_Handled__c =
                currentRow.Number_of_Times_Course_Handled__c || 0;
        }else{
            currentRow.Number_of_Times_Course_Handled__c = null;
        }*/
        component.set("v." + listName, list);
    },


    ValidationHlpr: function (component, event, helper, Method) {
        var courseLists = [
        { label: 'Hardcore Courses', data: component.get("v.lstHardCore") },
        { label: 'Hardcore Integrated', data: component.get("v.lstHcIntegrated") },
        { label: 'Practical/Term Work', data: component.get("v.lstPractical") },
        { label: 'Professional Electives', data: component.get("v.lstProfElective") },
        { label: 'Mandatory Courses', data: component.get("v.lstMandatory") }
    ];

    for (var i = 0; i < courseLists.length; i++) {
        var list = courseLists[i].data;
        if (list) {
            for (var j = 0; j < list.length; j++) {
                var row = list[j];
                // If Preference is selected, 'Times Handled' MUST have a value
                if (row.Preference__c && (row.Number_of_Times_Course_Handled__c === undefined || 
                                          row.Number_of_Times_Course_Handled__c === null || 
                                          row.Number_of_Times_Course_Handled__c === '')) {
                    
                    this.showToast(component, 'dismissible', 'Required Field Missing', 
                                   'Please enter "No. of Times Course Handled" for the course: ' + row.hed__Course__r.Name, 
                                   'error');
                    
                    component.set("v.isSaveButtonDisabled", false);
                    component.set("v.Spinner", false);
                    return; // Stop the save process
                }
            }
        }
    }
        component.set("v.Spinner", true);
        component.set("v.isSaveButtonDisabled", true);
        
        var action = component.get("c.validationPreferences");
        action.setParams({
            'lstHardCourse': component.get("v.lstHardCore"),
            'lstHCIntegrated': component.get("v.lstHcIntegrated"),
            'lstPractical': component.get("v.lstPractical"),
            'lstOpenElective': component.get("v.lstOpenElective"),
            'lstProfElective': component.get("v.lstProfElective"),
            'lstMandatory': component.get("v.lstMandatory"),
            'mainLst': component.get("v.List_CourseMain")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {

                    if (response.getReturnValue().showsave == true) {
                        if (response.getReturnValue().hardDupErrmsg != null) {
                            var retVal = response.getReturnValue().hardDupErrmsg;
                            this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                        }
                        if (response.getReturnValue().mainErrmsg != null) {
                            var retVal = response.getReturnValue().mainErrmsg;
                            this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                        }
                    }
                    if (response.getReturnValue().showsave != true) {
                        if (Method == 'save')
                            this.SaveCourseOfferingHlpr(component, event, helper);
                        else if (Method == 'confirm')
                            this.SaveConfrimHlpr(component, event, helper);
                    }
                }
                component.set("v.isSaveButtonDisabled", false);
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.isSaveButtonDisabled", false);
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },

    SaveCourseOfferingHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);

        var profSchool = component.get("v.showProfSchool");
        var SelAccTermId = component.get("v.SelectedTermId");

        var action = component.get("c.createProfessorCourseRecords");
        action.setParams({
            'lstHc': component.get("v.lstHardCore"),
            'lstHcIntegrated': component.get("v.lstHcIntegrated"),
            'lstPract': component.get("v.lstPractical"),
            'lstOpenEle': component.get("v.lstOpenElective"),
            'lstProfel': component.get("v.lstProfElective"),
            'lstMandtry': component.get("v.lstMandatory"),
            'profPreference': false,
            'accTermId': SelAccTermId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();

                if (returnVal === 'SUCCESS') {
                    this.showToast(component, 'dismissible', 'Success', 'Course Preferences are saved successfully!', 'success');

                    // Reset filters
                    if (profSchool)
                        component.set("v.SelectedSchoolId", null);
                    component.set("v.SelectedProgramId", null);
                    component.set("v.SelectedProgramPlanId", null);
                    component.set("v.SelectedTermId", null);
                    component.set("v.List_CourseMain", []);
                    component.set("v.MapTermName", null);
                    component.set("v.MapProgramPlanName", null);
                    component.set("v.MapProgramName", null);

                    //Keep spinner ON and reload after 2 seconds
                    setTimeout(function () {
                        window.location.reload();
                    }, 2000);

                } else if (returnVal === 'No Slots Available') {
                    component.set("v.isSaveButtonDisabled", false);
                    this.showToast(component, 'dismissible', 'Error', 'No slots available for your Preference -1 selection.', 'error');
                } else if (returnVal.startsWith('ERROR')) {
                    component.set("v.isSaveButtonDisabled", false);
                    this.showToast(component, 'dismissible', 'Error', returnVal.replace('ERROR: ', ''), 'error');
                } else {
                    component.set("v.isSaveButtonDisabled", false);
                    this.showToast(component, 'dismissible', 'Info', returnVal, 'info');
                }

            } else {
                component.set("v.Spinner", false);
                component.set("v.isSaveButtonDisabled", false);
                var errors = response.getError();
                var message = errors && errors[0] && errors[0].message ? errors[0].message : 'Unknown error';
                this.showToast(component, 'dismissible', 'Error', message, 'error');
            }
        });


        $A.enqueueAction(action);
    },

    SaveConfrimHlpr: function (component, event, helper) {
        component.set("v.Spinner", true);
        var profSchool = component.get("v.showProfSchool");
        var CourseSchool = component.get("v.showCourseAcross");
        var SelAccTermId = component.get("v.SelectedTermId");
        var action = component.get("c.createProfessorCourseRecords");
        action.setParams({
            'lstHc': component.get("v.lstHardCore"),
            'lstHcIntegrated': component.get("v.lstHcIntegrated"),
            'lstPract': component.get("v.lstPractical"),
            'lstOpenEle': component.get("v.lstOpenElective"),
            'lstProfel': component.get("v.lstProfElective"),
            'lstMandtry': component.get("v.lstMandatory"),
            'profPreference': true,
            'accTermId': SelAccTermId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast(component, 'dismissible', 'success', 'Professor / Student Course Preference Confirmed Successfully..!', 'success');

                if (profSchool == true)
                    component.set("v.SelectedSchoolId", null);
                component.set('v.SelectedProgramId', null);
                component.set('v.SelectedProgramPlanId', null);
                component.set('v.SelectedTermId', null);
                component.set("v.Spinner", false);
                var lstCourse = [];
                component.set("v.List_CourseMain", lstCourse);
                component.set("v.MapTermName", null);
                component.set("v.MapProgramPlanName", null);
                component.set("v.MapProgramName", null);
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
                var theoryPreferences = [];
                var practicalPreferences = [];
                var result = response.getReturnValue();

                for (var key in result) {
                    var entry = { key: key, value: result[key] };
                    theoryPreferences.push(entry);

                    if (key === '1' || key === '2' || key === '3' || key === '4') {
                        practicalPreferences.push(entry);
                    }
                }

                component.set("v.PracticalPreferences", practicalPreferences);

                component.set("v.TheoryPreferences", theoryPreferences);

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