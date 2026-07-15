({
    getTermDetailHlp: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getTermDetails");
        //component.get("v.recordId")
        // var recId = 'a0P0w000003vefz';
        action.setParams({
            'termId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var retVal = response.getReturnValue();
                    component.set("v.objTerm", retVal.objTerm);
                    component.set("v.filterIds", retVal.filterIds);
                    var isApproval = retVal.objTerm.Sent_for_Approval__c;
                    var mapValues = [];
                    var result = retVal.hcCoursePl;
                    for (var key in result) {
                        mapValues.push({ label: result[key], value: key });
                    }
                    //  alert(JSON.stringify(result));
                    component.set("v.mapHardCorePl", mapValues);

                    var mapValues = [];
                    var result = retVal.hcIntegratedPl;
                    for (var key in result) {
                        mapValues.push({ key: key, value: result[key] });
                    }
                    component.set("v.mapHcIntegratedPl", mapValues);

                    var mapValues = [];
                    var result = retVal.pratialPl;
                    for (var key in result) {
                        mapValues.push({ key: key, value: result[key] });
                    }
                    component.set("v.mapPracticalPl", mapValues);

                    var mapValues = [];
                    var result = retVal.MandatoryPl;
                    for (var key in result) {
                        mapValues.push({ key: key, value: result[key] });
                    }
                    component.set("v.mapMandatoryPl", mapValues);


                    var mapValues = [];
                    var result = retVal.spclPl;
                    for (var key in result) {
                        mapValues.push({ key: key, value: result[key] });
                    }
                    component.set("v.spclPl", mapValues);

                    var mapValues = [];
                    var result = retVal.oElectivePl;
                    for (var key in result) {
                        mapValues.push({ key: key, value: result[key] });
                    }
                    component.set("v.mapoElectivePl", mapValues);

                    var mapValues = [];
                    var result = retVal.pElectivePl;
                    for (var key in result) {
                        mapValues.push({ key: key, value: result[key] });
                    }
                    component.set("v.mappElectivePl", mapValues);


                    // alert(retVal.objTerm.Course_Offering_Created__c);
                    if (retVal.objTerm.Course_Offering_Created__c) {
                        this.getCourseDetailHelper(component, event, helper, isApproval);
                    }
                    else {
                        this.getPlanDetailHelper(component, event, helper);
                    }


                    component.set("v.Spinner", false);
                }
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', result.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    getPlanDetailHelper: function (component, event, helper) {
        component.set("v.Spinner", true);
        //  var recId = 'a0P0w000003vefz';
        var action = component.get("c.getPlanRequirement");
        action.setParams({
            'termId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var retVal = response.getReturnValue();
                    component.set("v.lstHardCore", retVal.listHardCore);
                    //  alert(JSON.stringify(retVal.listOpenElective));
                    component.set("v.lstoElective", retVal.listOpenElective);
                    component.set("v.lstpElective", retVal.listProfElective);
                    component.set("v.lstPractical", retVal.listPractical);
                    component.set("v.lstHcIntegrated", retVal.listHcIntegrated);
                    component.set("v.lstMandatory", retVal.listMandatory);
                    component.set("v.lstSpcl", retVal.lstSpcl);
                    component.set("v.totalCredit", retVal.totalCredit);
                    component.set("v.Spinner", false);
                    this.calculateCreditHelper(component, event, helper);
                }
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', result.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    getCourseDetailHelper: function (component, event, helper, isApproval) {
        component.set("v.Spinner", true);
        // var recId = 'a0P0w000003vefz';
        var action = component.get("c.getcourseOffering");
        action.setParams({
            'termId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var retVal = response.getReturnValue();

                    if (isApproval) {
                        // Filter only specializations with at least one child having courseId and courseName
                        let filteredSpcl = [];

                        for (let spcl of retVal.lstSpcl) {
                            let validPlans = spcl.lstPlanLi.filter(plan => plan.courseId && plan.courseName);

                            if (validPlans.length > 0) {
                                // Reassign filtered children before pushing
                                spcl.lstPlanLi = validPlans;
                                filteredSpcl.push(spcl);
                            }
                        }

                        component.set("v.lstSpcl", filteredSpcl);
                    }
                    else {
                        component.set("v.lstSpcl", retVal.lstSpcl);
                    }
                    component.set("v.lstHardCore", retVal.listHardCore);
                    //  alert(JSON.stringify(retVal.listOpenElective));
                    component.set("v.lstoElective", retVal.listOpenElective);
                    component.set("v.lstpElective", retVal.listProfElective);
                    component.set("v.lstPractical", retVal.listPractical);
                    component.set("v.lstHcIntegrated", retVal.listHcIntegrated);
                    component.set("v.lstMandatory", retVal.listMandatory);
                    component.set("v.lstSpcl", retVal.lstSpcl);
                    this.calculateCreditHelper(component, event, helper);
                    component.set("v.Spinner", false);
                }
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', result.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },

    addHardCoreRecordHelper: function (component, event, helper) {
        var hcore = component.get("v.lstHardCore");
        var termId = component.get("v.objTerm").id;
        var hcoreSize = hcore.length + 1;
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Hardcore Course' AND hed__Account__c = '" + program.Program_Batch__r.hed__Account__r.ParentId + "'";
        hcore.push({
            'courseId': '',
            'courseName': '',
            'credits': '',
            'count': hcoreSize,
            'subCount': '',
            'termId': termId,
            'filter': filter
        });
        component.set("v.lstHardCore", hcore);
    },
    RemoveHardCoreRecordHelper: function (component, event, helper) {
        var hcore = component.get("v.lstHardCore");
        //var selectedItem = event.currentTarget;
        //var index = selectedItem.dataset.record;
        //var recordId = hcore[index].recordId;
        var index = event.getSource().get("v.name");
        var recordId = hcore[index].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        hcore.splice(index, 1);
        for (var i = 0; i < hcore.length; i++) {
            hcore[i].count = i + 1;
        }
        component.set("v.lstHardCore", hcore);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    addHcIntegratedRecordHelper: function (component, event, helper) {
        var hcore = component.get("v.lstHcIntegrated");
        var termId = component.get("v.objTerm").id;
        var hcoreSize = hcore.length + 1;
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Hardcore Integrated Course' AND hed__Account__c = '" + program.Program_Batch__r.hed__Account__r.ParentId + "'";
        hcore.push({
            'courseId': '',
            'courseName': '',
            'credits': '',
            'count': hcoreSize,
            'subCount': '',
            'termId': termId,
            'filter': filter
        });
        component.set("v.lstHcIntegrated", hcore);

    },
    RemoveHcIntegratedRecordHelper: function (component, event, helper) {
        var hcore = component.get("v.lstHcIntegrated");
        /*var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = hcore[index].recordId;*/
        var index = event.getSource().get("v.name");
        var recordId = hcore[index].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        hcore.splice(index, 1);
        for (var i = 0; i < hcore.length; i++) {
            hcore[i].count = i + 1;
        }
        component.set("v.lstHcIntegrated", hcore);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    addMandatoryRecordHelper: function (component, event, helper) {
        var hcore = component.get("v.lstMandatory");
        var termId = component.get("v.objTerm").id;
        var hcoreSize = hcore.length + 1;
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Mandatory Course' AND hed__Account__c = '" + program.Program_Batch__r.hed__Account__r.ParentId + "'";
        hcore.push({
            'courseId': '',
            'courseName': '',
            'credits': '',
            'count': hcoreSize,
            'subCount': '',
            'termId': termId,
            'filter': filter
        });
        component.set("v.lstMandatory", hcore);

    },
    RemoveMandatoryRecordHelper: function (component, event, helper) {
        var hcore = component.get("v.lstMandatory");
        /*var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = hcore[index].recordId;*/
        var index = event.getSource().get("v.name");
        var recordId = hcore[index].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        // alert(hcore);
        hcore.splice(index, 1);
        for (var i = 0; i < hcore.length; i++) {
            hcore[i].count = i + 1;
        }
        component.set("v.lstMandatory", hcore);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    addopenElectiveRecordHelper: function (component, event, helper) {
        var oEle = component.get("v.lstoElective");
        var oEleSize = oEle.length + 1;
        var oEleName = 'OPEN ELECTIVES' + oEleSize;
        var termId = component.get("v.objTerm").id;
        // var accIds = component.get("v.filterIds");
        //var filter = "Category__c = 'Open Elective' AND hed__Account__c IN:";
        var filter = "Id IN(Select Course__c from Department_For_OE_course__c WHERE  Course__r.Category__c = 'Open Elective'  AND Department__c IN:";
        oEle.push({
            'credits': '0', 'lstPlanLi': [{ 'courseId': '', 'courseName': '', 'credits': '0', 'termId': termId, 'filter': filter }],
            'Name': oEleName, 'parentId': '', 'count': oEleSize, 'termId': termId
        });
        component.set("v.lstoElective", oEle);

    },
    RemoveopenElectiveHelper: function (component, event, helper) {
        var oEle = component.get("v.lstoElective");
        /*var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = oEle[index].recordId;*/
        var index = event.getSource().get("v.name");
        var recordId = oEle[index].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEle.splice(index, 1);
        var oEleName = 'OPEN ELECTIVES';
        for (var i = 0; i < oEle.length; i++) {
            oEle[i].count = i + 1;
            var oeSize = i + 1;
            oEle[i].Name = oEleName + oeSize;
            oEle[i].parentId = '';
            if (!oEle[i].credits) {
                oEle[i].credits = '';
            }
            for (var j = 0; j < oEle[i].lstPlanLi.length; j++) {
                if (!oEle[i].lstPlanLi[j].count) {
                    oEle[i].lstPlanLi[j].count = '';
                }
                if (!oEle[i].lstPlanLi[j].credits) {
                    oEle[i].lstPlanLi[j].credits = '0';
                }
                if (!oEle[i].lstPlanLi[j].courseId) {
                    oEle[i].lstPlanLi[j].courseId = '';
                }
                if (!oEle[i].lstPlanLi[j].courseName) {
                    oEle[i].lstPlanLi[j].courseName = '';
                }
            }
        }
        component.set("v.lstoElective", oEle);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    addopenElectiveLiRecHelper: function (component, event, helper) {
        var oEle = component.get("v.lstoElective");
        var index = event.getSource().get("v.name");//value
        var oEleLi = component.get("v.lstoElective")[index].lstPlanLi;
        var termId = component.get("v.objTerm").id;
        //   var accIds = component.get("v.filterIds");
        // var filter = "Category__c = 'Open Elective' AND hed__Account__c IN:";
        var filter = "Id IN(Select Course__c from Department_For_OE_course__c WHERE  Course__r.Category__c = 'Open Elective'  AND Department__c IN:";
        oEleLi.push({ 'courseId': '', 'courseName': '', 'credits': '0', 'termId': termId, 'filter': filter });
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstoElective", oEle);
    },
    RemoveopenElectiveLiHelper: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        //var index1 = selectedItem.dataset.record;
        //var index = event.target.id;
        var indexlst = event.getSource().get("v.name").split(',');
        var index1 = indexlst[1];
        var index = indexlst[0];

        var oEle = component.get("v.lstoElective");
        var oEleLi = component.get("v.lstoElective")[index].lstPlanLi;
        var recordId = oEleLi[index1].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEleLi.splice(index1, 1);
        //  alert(oEleLi);
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstoElective", oEle);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    addProElectiveRecordHelper: function (component, event, helper) {
        var oEle = component.get("v.lstpElective");
        var oEleSize = oEle.length + 1;
        var oEleName = 'PROFESSIONAL ELECTIVES' + oEleSize;
        var termId = component.get("v.objTerm").id;
        var program = component.get("v.objTerm");//program
        var filter = "Category__c = 'Professional Elective' AND hed__Account__c = '" + program.Program_Batch__r.hed__Account__r.ParentId + "'";
        oEle.push({
            'credits': '0', 'lstPlanLi': [{ 'courseId': '', 'courseName': '', 'credits': '0', 'termId': termId, 'filter': filter }],
            'Name': oEleName, 'parentId': '', 'count': oEleSize, 'termId': termId
        });
        component.set("v.lstpElective", oEle);

    },
    RemoveProElectiveHelper: function (component, event, helper) {
        var oEle = component.get("v.lstpElective");
        /*var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = oEle[index].recordId;*/
        var index = event.getSource().get("v.name");
        var recordId = oEle[index].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEle.splice(index, 1);
        var oEleName = 'Professional ELECTIVES';
        for (var i = 0; i < oEle.length; i++) {
            oEle[i].count = i + 1;
            var oeSize = i + 1;
            oEle[i].Name = oEleName + oeSize;
            oEle[i].parentId = '';
            if (!oEle[i].credits) {
                oEle[i].credits = '';
            }
            for (var j = 0; j < oEle[i].lstPlanLi.length; j++) {
                if (!oEle[i].lstPlanLi[j].count) {
                    oEle[i].lstPlanLi[j].count = '';
                }
                if (!oEle[i].lstPlanLi[j].credits) {
                    oEle[i].lstPlanLi[j].credits = '0';
                }
                if (!oEle[i].lstPlanLi[j].courseId) {
                    oEle[i].lstPlanLi[j].courseId = '';
                }
                if (!oEle[i].lstPlanLi[j].courseName) {
                    oEle[i].lstPlanLi[j].courseName = '';
                }
            }
        }
        component.set("v.lstpElective", oEle);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    addsSpclLiRecRecHelper: function (component, event, helper) {
        var oEle = component.get("v.lstSpcl");
        var index = event.getSource().get("v.name");
        var parantId = oEle[index].parentId;
        var oEleLi = oEle[index].lstPlanLi;
        var termId = component.get("v.termId");
        var program = component.get("v.program");

        var filter = "Category__c = 'RBS Specialization' AND Specialization__c = '" + parantId + "'";

        oEleLi.push({
            'courseId': '',
            'courseName': '',
            'credits': '0',
            'termId': termId,
            'filter': filter
        });

        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstSpcl", oEle);
    },
    RemoveSpclLiHelper: function (component, event, helper) {
        //var selectedItem = event.currentTarget;
        var indexlst = event.getSource().get("v.name").split(',');
        var index1 = indexlst[1];
        var index = indexlst[0];
        var oEle = component.get("v.lstSpcl");
        var oEleLi = component.get("v.lstSpcl")[index].lstPlanLi;
        var recordId = oEleLi[index1].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEleLi.splice(index1, 1);
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstSpcl", oEle);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    RemoveSpclLiHelper1: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        var spclList = component.get("v.lstSpcl");
        var planLiList = spclList[index].lstPlanLi;

        var firstItem = planLiList[0];
        var parentId = spclList[index].parentId;

        // Track deleted record
        if (firstItem.recordId) {
            var deletedIds = component.get("v.deletedRecordIds") || [];
            deletedIds.push(firstItem.recordId);
            component.set("v.deletedRecordIds", deletedIds);
        }

        var filter = "Category__c = 'RBS Specialization' AND Specialization__c = '" + parentId + "'";

        // Create new empty row
        var emptyRow = {
            courseId: '',
            courseName: '',
            credits: 0,
            termId: firstItem.termId,
            filter: filter,
        };

        // Replace entire lstPlanLi array to force reactivity
        var newPlanLiList = [emptyRow];
        spclList[index].lstPlanLi = newPlanLiList;

        component.set("v.lstSpcl", spclList);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    addProElectiveLiRecHelper: function (component, event, helper) {
        var oEle = component.get("v.lstpElective");
        var index = event.getSource().get("v.name");
        var oEleLi = component.get("v.lstpElective")[index].lstPlanLi;
        var termId = component.get("v.objTerm").id;
        /*var program = component.get("v.program");*/
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Professional Elective' AND hed__Account__c = '" + program.Program_Batch__r.hed__Account__r.ParentId + "'";
        // var filter = "Category__c = 'Professional Elective' AND hed__Account__c IN:";
        oEleLi.push({ 'courseId': '', 'courseName': '', 'credits': '0', 'termId': termId, 'filter': filter });
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstpElective", oEle);
    },
    RemoveProElectiveLiHelper: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        /* var index1 = selectedItem.dataset.record;
         var index = event.target.id;*/
        var indexlst = event.getSource().get("v.name").split(',');
        var index1 = indexlst[1];
        var index = indexlst[0];
        var oEle = component.get("v.lstpElective");
        var oEleLi = component.get("v.lstpElective")[index].lstPlanLi;
        var recordId = oEleLi[index1].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        oEleLi.splice(index1, 1);
        oEle[index].lstPlanLi = oEleLi;
        component.set("v.lstpElective", oEle);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    addPraticalRecordHelper: function (component, event, helper) {
        var hcore = component.get("v.lstPractical");
        var termId = component.get("v.objTerm").id;
        var hcoreSize = hcore.length + 1;
        var program = component.get("v.objTerm");
        var filter = "Category__c = 'Practical/Term Work' AND hed__Account__c = '" + program.Program_Batch__r.hed__Account__r.ParentId + "'";
        hcore.push({
            'courseId': '',
            'courseName': '',
            'credits': '',
            'count': hcoreSize,
            'subCount': '',
            'termId': termId,
            'filter': filter
        });
        component.set("v.lstPractical", hcore);
    },
    RemovePraticalHelper: function (component, event, helper) {
        var hcore = component.get("v.lstPractical");
        /*var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var recordId = hcore[index].recordId;*/
        var index = event.getSource().get("v.name");
        var recordId = hcore[index].recordId;
        if (recordId) {
            var deletIds = component.get("v.deletedRecordIds");
            deletIds.push(recordId);
            component.set("v.deletedRecordIds", deletIds);
        }
        hcore.splice(index, 1);
        for (var i = 0; i < hcore.length; i++) {
            hcore[i].count = i + 1;
        }
        component.set("v.lstPractical", hcore);
        component.set("v.valueChanged", !component.get("v.valueChanged"));
    },
    saveRecordHelper: function (component, event, helper, boolType, IsAppType) {
        component.set("v.Spinner", true);
        let lstSpcl = component.get("v.lstSpcl");

        // Loop through each specialization group
        for (let i = 0; i < lstSpcl.length; i++) {
            let spcl = lstSpcl[i];

            // Filter out plan list items where courseId is null, empty, or undefined
            if (spcl.lstPlanLi && Array.isArray(spcl.lstPlanLi)) {
                spcl.lstPlanLi = spcl.lstPlanLi.filter(item => item.courseId && item.courseId.trim() !== '');
            }
        }
        var action = component.get("c.savePlanRequiement");
        action.setParams({
            'termId': component.get("v.recordId"),
            'lstHc': component.get("v.lstHardCore"),
            'lstHcIntegrated': component.get("v.lstHcIntegrated"),
            'lstPra': component.get("v.lstPractical"),
            'lstOe': component.get("v.lstoElective"),
            'lstPe': component.get("v.lstpElective"),
            'lstMandatory': component.get("v.lstMandatory"),
            'lstSpcl': lstSpcl,
            'deletedIds': component.get("v.deletedRecordIds"),
            'type': boolType,
            'Approval': IsAppType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //  alert(JSON.stringify(response.getError()));
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var retVal = response.getReturnValue();
                    if (retVal == 'Success') {
                        this.showToast(component, 'dismissible', 'Success', 'Course Offering Records Updated Sucessfully', 'success');
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }
                    else {
                        this.showToast(component, 'dismissible', 'Failed', retVal, 'error');
                    }
                    component.set("v.Spinner", false);
                }
                component.set("v.Spinner", false);
            }
            else {
                component.set("v.Spinner", false);
                this.showToast(component, 'dismissible', 'Failed', result.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    calculateCreditHelper: function (component, event, helper) {
        var tc = 0;
        var hc = component.get("v.lstHardCore");
        for (var i = 0; i < hc.length; i++) {
            if (hc[i].credits) {
                tc = tc + parseInt(hc[i].credits);
            }
            if (hc[i].SchoolId != null && hc[i].schoolName == undefined) {
                this.getSchoolHelper(component, event, helper, hc[i].SchoolId, 'Hardcore Courses');
            }
        }
        var hi = component.get("v.lstHcIntegrated");
        for (var i = 0; i < hi.length; i++) {
            if (hi[i].credits) {
                tc = tc + parseInt(hi[i].credits);
            }
            if (hi[i].SchoolId != null && hi[i].schoolName == undefined) {
                this.getSchoolHelper(component, event, helper, hi[i].SchoolId, 'Hardcore Integrated Courses');
            }
        }
        var pra = component.get("v.lstPractical");
        for (var i = 0; i < pra.length; i++) {
            if (pra[i].credits) {
                tc = tc + parseInt(pra[i].credits);
            }
            if (pra[i].SchoolId != null && pra[i].schoolName == undefined) {
                this.getSchoolHelper(component, event, helper, pra[i].SchoolId, 'Practical/Term Work');
            }
        }
        var mna = component.get("v.lstMandatory");
        for (var i = 0; i < mna.length; i++) {
            if (mna[i].credits) {
                tc = tc + parseInt(mna[i].credits);
            }
            if (mna[i].SchoolId != null && mna[i].schoolName == undefined) {
                this.getSchoolHelper(component, event, helper, mna[i].SchoolId, 'Mandatory Courses');
            }
        }
        var oe = component.get("v.lstoElective");
        for (var i = 0; i < oe.length; i++) {
            if (oe[i].credits) {
                tc = tc + parseInt(oe[i].credits);
            }
            for (var j = 0; j < oe[i].lstPlanLi.length; j++) {
                if (oe[i].lstPlanLi[j].SchoolId != null && oe[i].lstPlanLi[j].schoolName == undefined) {
                    this.getSchoolHelper(component, event, helper, oe[i].lstPlanLi[j].SchoolId, 'Open Electives');
                }
                if (oe[i].lstPlanLi[j].credits) {
                    tc = tc + parseInt(oe[i].lstPlanLi[j].credits);
                }
            }
            /*  if(oe[i].SchoolId != null && oe[i].schoolName == undefined)
              {
                  this.getSchoolHelper(component, event,helper,oe[i].SchoolId,'Open Electives');
              }*/
        }
        var pe = component.get("v.lstpElective");
        for (var i = 0; i < pe.length; i++) {
            if (pe[i].credits) {
                tc = tc + parseInt(pe[i].credits);
            }
            for (var j = 0; j < pe[i].lstPlanLi.length; j++) {
                if (pe[i].lstPlanLi[j].SchoolId != null && pe[i].lstPlanLi[j].schoolName == undefined) {
                    this.getSchoolHelper(component, event, helper, pe[i].lstPlanLi[j].SchoolId, 'Professional Electives');
                }
                if (pe[i].lstPlanLi[j].credits) {
                    tc = tc + parseInt(pe[i].lstPlanLi[j].credits);
                }
            }
            /*if(pe[i].SchoolId != null && pe[i].schoolName == undefined)
            {
                this.getSchoolHelper(component, event,helper,pe[i].SchoolId,'Professional Electives');
            }*/
        }
        var pe = component.get("v.lstSpcl");
        for (var i = 0; i < pe.length; i++) {
            if (pe[i].credits) {
                tc = tc + parseInt(pe[i].credits);
            }
            for (var j = 0; j < pe[i].lstPlanLi.length; j++) {
                if (pe[i].lstPlanLi[j].SchoolId != null && pe[i].lstPlanLi[j].schoolName == undefined) {
                    this.getSchoolHelper(component, event, helper, pe[i].lstPlanLi[j].SchoolId, 'RBS Specialization');
                }
                if (pe[i].lstPlanLi[j].credits) {
                    tc = tc + parseInt(pe[i].lstPlanLi[j].credits);
                }
            }
        }

        component.set("v.totalCredit", tc);
    },
    getSchoolHelper: function (component, event, helper, AccountSchoolId, category) {
        component.set("v.Spinner", true);
        var action = component.get("c.getSchoolName");
        action.setParams({
            'AccschoolId': AccountSchoolId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != undefined) {
                    var accname = response.getReturnValue();
                    if (category == 'Hardcore Courses') {
                        var hc = component.get("v.lstHardCore");
                        for (var i = 0; i < hc.length; i++) {
                            if (hc[i].SchoolId == AccountSchoolId) {
                                hc[i].schoolName = accname;
                            }
                        }
                        component.set("v.lstHardCore", hc);
                    }
                    if (category == 'Hardcore Integrated Courses') {
                        var hi = component.get("v.lstHcIntegrated");
                        for (var i = 0; i < hi.length; i++) {
                            if (hi[i].SchoolId == AccountSchoolId) {
                                hi[i].schoolName = accname;
                            }
                        }
                        component.set("v.lstHcIntegrated", hi);
                    }
                    if (category == 'Practical/Term Work') {
                        var pra = component.get("v.lstPractical");
                        for (var i = 0; i < pra.length; i++) {
                            if (pra[i].SchoolId == AccountSchoolId) {
                                pra[i].schoolName = accname;
                            }
                        }
                        component.set("v.lstPractical", pra);
                    }
                    if (category == 'Mandatory Courses') {
                        var mna = component.get("v.lstMandatory");
                        for (var i = 0; i < mna.length; i++) {
                            if (mna[i].SchoolId == AccountSchoolId) {
                                mna[i].schoolName = accname;
                            }
                        }
                        component.set("v.lstMandatory", mna);
                    }
                    if (category == 'Open Electives') {
                        var oe = component.get("v.lstoElective");
                        for (var i = 0; i < oe.length; i++) {
                            for (var j = 0; j < oe[i].lstPlanLi.length; j++) {
                                //alert('===oe[i].lstPlanLi[j].SchoolId=='+oe[i].lstPlanLi[j].SchoolId);
                                if (oe[i].lstPlanLi[j].SchoolId == AccountSchoolId) {
                                    oe[i].lstPlanLi[j].schoolName = accname;
                                }
                            }
                            /*if(oe[i].SchoolId == AccountSchoolId){
                                oe[i].schoolName =  accname;
                            }*/
                        }
                        component.set("v.lstoElective", oe);
                    }
                    if (category == 'Professional Electives') {
                        var pe = component.get("v.lstpElective");
                        for (var i = 0; i < pe.length; i++) {
                            for (var j = 0; j < pe[i].lstPlanLi.length; j++) {
                                if (pe[i].lstPlanLi[j].SchoolId == AccountSchoolId) {
                                    pe[i].lstPlanLi[j].schoolName = accname;
                                }
                            }

                            /*if(pe[i].SchoolId == AccountSchoolId){
                                pe[i].schoolName =  accname;
                            }*/
                        }
                        component.set("v.lstpElective", pe);
                    }
                    if (category == 'RBS Specialization') {
                        var oe = component.get("v.lstSpcl");
                        for (var i = 0; i < oe.length; i++) {
                            for (var j = 0; j < oe[i].lstPlanLi.length; j++) {
                                //alert('===oe[i].lstPlanLi[j].SchoolId=='+oe[i].lstPlanLi[j].SchoolId);
                                if (oe[i].lstPlanLi[j].SchoolId == AccountSchoolId) {
                                    oe[i].lstPlanLi[j].schoolName = accname;
                                }
                            }

                        }
                        component.set("v.lstSpcl", oe);
                    }
                    component.set("v.Spinner", false);
                }
                component.set("v.Spinner", false);
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