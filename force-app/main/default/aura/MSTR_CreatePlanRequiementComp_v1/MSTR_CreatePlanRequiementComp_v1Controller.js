({
    doInit: function (component, event, helper) {
        helper.getPlanRequestCountHelper(component, event, helper);
        helper.getPlandetailsHelper(component, event, helper);
        helper.getPicklistFilterHelper(component, event, helper);
    },
    showPlanRequirement: function (component, event, helper) {
        helper.showPlanRequirementHelper(component, event, helper);
    },
    addHardCoreRecord: function (component, event, helper) {
        helper.addHardCoreRecordHelper(component, event, helper);
    },
    RemoveHardCoreRecord: function (component, event, helper) {
        helper.RemoveHardCoreRecordHelper(component, event, helper);
    },

    addHcIntegratedRecord: function (component, event, helper) {
        helper.addHcIntegratedRecordHelper(component, event, helper);
    },
    RemoveHcIntegratedRecord: function (component, event, helper) {
        helper.RemoveHcIntegratedRecordHelper(component, event, helper);
    },
    addMandatoryRecord: function (component, event, helper) {
        helper.addMandatoryRecordHelper(component, event, helper);
    },
    RemoveMandatoryRecord: function (component, event, helper) {
        helper.RemoveMandatoryRecordHelper(component, event, helper);
    },

    addopenElectiveRecord: function (component, event, helper) {
        helper.addopenElectiveRecordHelper(component, event, helper);
    },
    RemoveopenElective: function (component, event, helper) {
        helper.RemoveopenElectiveHelper(component, event, helper);
    },
    addopenElectiveLiRec: function (component, event, helper) {
        helper.addopenElectiveLiRecHelper(component, event, helper);
    },
    RemoveopenElectiveLi: function (component, event, helper) {
        helper.RemoveopenElectiveLiHelper(component, event, helper);
    },
    addProElectiveRecord: function (component, event, helper) {
        helper.addProElectiveRecordHelper(component, event, helper);
    },
    RemoveProElective: function (component, event, helper) {
        helper.RemoveProElectiveHelper(component, event, helper);
    },
    addProElectiveLiRec: function (component, event, helper) {
        helper.addProElectiveLiRecHelper(component, event, helper);
    },
    RemoveProElectiveLi: function (component, event, helper) {
        helper.RemoveProElectiveLiHelper(component, event, helper);
    },
    RemoveSpclLi: function (component, event, helper) {
        helper.RemoveSpclLiHelper(component, event, helper);
    },
    RemoveSpclLi1: function (component, event, helper) {
        helper.RemoveSpclLiHelper1(component, event, helper);
    },
    addsSpclLiRec: function (component, event, helper) {
        helper.addsSpclLiRecRecHelper(component, event, helper);
    },
    addPracticalRecord: function (component, event, helper) {
        helper.addPraticalRecordHelper(component, event, helper);
    },
    RemovePractical: function (component, event, helper) {
        helper.RemovePraticalHelper(component, event, helper);
    },
    calculateCredit: function (component, event, helper) {
        helper.calculateCreditHelper(component, event, helper);
    },
    closeAction: function (component, event, helper) {
        //  $A.get("e.force:closeQuickAction").fire();
        //  $A.get('e.force:refreshView').fire();
        component.set("v.showPPTable", false);
        component.set("v.Spinner", false);
    },
    saveRecord: function (component, event, helper) {
        var errMsg = 'Success';
        var hc = component.get("v.lstHardCore");
        var arr = [];
        for (var i = 0; i < hc.length; i++) {
            if (hc[i].courseId == '' || hc[i].credits == '' ||
                hc[i].courseId == undefined || hc[i].credits == undefined) {

                errMsg = 'Please Fill All Values..!!'
            }
            else {
                if (arr.length == 0) {
                    arr.push(hc[i].courseId);
                }
                else {
                    if (arr.includes(hc[i].courseId)) {
                        errMsg = 'The subject ' + hc[i].courseName + ' already exists in this Semester';
                    }
                    else {
                        arr.push(hc[i].courseId);
                    }

                }
            }
        }

        var hi = component.get("v.lstHcIntegrated");
        arr = [];
        for (var i = 0; i < hi.length; i++) {
            if (hi[i].courseId == '' || hi[i].credits == '' ||
                hi[i].courseId == undefined || hi[i].credits == undefined) {

                errMsg = 'Please Fill All Values..!!'
            }
            else {
                if (arr.length == 0) {
                    arr.push(hi[i].courseId);
                }
                else {
                    if (arr.includes(hi[i].courseId)) {
                        errMsg = 'The subject ' + hi[i].courseName + ' already exists in this Semester';
                    }
                    else {
                        arr.push(hi[i].courseId);
                    }

                }
            }
        }

        var pra = component.get("v.lstPractical");
        arr = [];
        for (var i = 0; i < pra.length; i++) {
            if (pra[i].courseId == '' || pra[i].credits == '' ||
                pra[i].courseId == undefined || pra[i].credits == undefined) {

                errMsg = 'Please Fill All Values..!!'
            }
            else {
                if (arr.length == 0) {
                    arr.push(pra[i].courseId);
                }
                else {
                    if (arr.includes(pra[i].courseId)) {
                        errMsg = 'The subject ' + pra[i].courseName + ' already exists in this Semester';
                    }
                    else {
                        arr.push(pra[i].courseId);
                    }

                }
            }
        }

        var mnt = component.get("v.lstMandatory");
        arr = [];
        for (var i = 0; i < mnt.length; i++) {
            /*if(mnt[i].courseId == '' || mnt[i].credits == '' ||
               mnt[i].courseId == undefined || mnt[i].credits == undefined){

                errMsg = 'Please Fill All Values..!!'
            }*/
            if (mnt[i].courseId == '' || mnt[i].courseId == undefined) {
                errMsg = 'Please Fill All Values..!!'
            }
            else {
                if (arr.length == 0) {
                    arr.push(mnt[i].courseId);
                }
                else {
                    if (arr.includes(mnt[i].courseId)) {
                        errMsg = 'The subject ' + mnt[i].courseName + ' already exists in this Semester';
                    }
                    else {
                        arr.push(mnt[i].courseId);
                    }

                }
            }
        }

        var oe = component.get("v.lstoElective");
        arr = [];
        for (var i = 0; i < oe.length; i++) {
            /*if(oe[i].credits == '' || oe[i].credits == undefined){
                errMsg = 'Please Fill All Values..!!'
           }*/
            for (var j = 0; j < oe[i].lstPlanLi.length; j++) {
                if (oe[i].lstPlanLi[j].courseId == '' || oe[i].lstPlanLi[j].courseId == undefined) {

                    errMsg = 'Please Fill All Values..!!'
                }
                if (oe[i].lstPlanLi[j].credits == '' || oe[i].lstPlanLi[j].credits == undefined) {
                    errMsg = 'Please Fill All Values..!!'
                }
                else {
                    if (arr.length == 0) {
                        arr.push(oe[i].lstPlanLi[j].courseId);
                    }
                    else {
                        if (arr.includes(oe[i].lstPlanLi[j].courseId)) {
                            errMsg = 'The subject ' + oe[i].lstPlanLi[j].courseName + ' already exists in this Semester';
                        }
                        else {
                            arr.push(oe[i].lstPlanLi[j].courseId);
                        }

                    }
                }

            }
        }
        var oe = component.get("v.lstSpcl");
        var arr = [];

        for (var i = 0; i < oe.length; i++) {
            for (var j = 0; j < oe[i].lstPlanLi.length; j++) {
                var courseId = oe[i].lstPlanLi[j].courseId;
                var spclName = oe[i].name;
                var courseName = oe[i].lstPlanLi[j].courseName;
                if (!courseId) {
                    continue;
                }
                if (arr.includes(courseId)) {
                    errMsg = 'The subject "' + courseName + '" is selected in this "' + spclName + '" Specialization /semester.';
                    break;
                } else {
                    arr.push(courseId);
                }
            }
        }

        var pl = component.get("v.lstpElective");
        arr = [];
        for (var i = 0; i < pl.length; i++) {
            /*if(pl[i].credits == '' || pl[i].credits == undefined){
                errMsg = 'Please Fill All Values..!!'
           }*/
            for (var j = 0; j < pl[i].lstPlanLi.length; j++) {
                if (pl[i].lstPlanLi[j].courseId == '' || pl[i].lstPlanLi[j].courseId == undefined) {

                    errMsg = 'Please Fill All Values..!!'
                }
                if (pl[i].lstPlanLi[j].credits == '' || pl[i].lstPlanLi[j].credits == undefined) {
                    errMsg = 'Please Fill All Values..!!'
                }
                else {
                    if (arr.length == 0) {
                        arr.push(pl[i].lstPlanLi[j].courseId);
                    }
                    else {
                        if (arr.includes(pl[i].lstPlanLi[j].courseId)) {
                            errMsg = 'The subject ' + pl[i].lstPlanLi[j].courseName + ' already exists in this Semester';
                        }
                        else {
                            arr.push(pl[i].lstPlanLi[j].courseId);
                        }

                    }
                }
            }
        }
        if (errMsg == 'Success') {
            helper.saveRecordHelper(component, event, helper);
        }
        else {
            helper.showToast(component, 'dismissible', 'Failed', errMsg, 'error');
        }
    }
})