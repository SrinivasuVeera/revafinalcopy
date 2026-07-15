({
    doInitHelper: function (component, event, helper) {
        component.set("v.Spinner", true);
        var tclassComplete = 0;
        var tAtt = 0;
        var tPercen = 0;
        var action = component.get('c.DisplayAttendance');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result != undefined) {

                    component.set("v.ProgName", result.ProgramName);
                    component.set("v.SemNo", result.SemesterNo);
                    component.set("v.SecName", result.SectionName);
                    component.set("v.BatchRecType", result.BatchRecName);
                    component.set("v.GroupRecType", result.GroupRecName);

                    var MapProfValues = [];
                    var presult = result.map_Faculty;
                    for (var key in presult) {
                        MapProfValues.push({ key: key, value: presult[key] });
                    }
                    component.set("v.MapFaculty", MapProfValues);
                    for (var i = 0; i < MapProfValues.length; i++) {
                        if (MapProfValues[i].value.TotalClassCom != null)
                            tclassComplete = tclassComplete + MapProfValues[i].value.TotalClassCom;
                        if (MapProfValues[i].value.TotalClassAtt != null)
                            tAtt = tAtt + MapProfValues[i].value.TotalClassAtt;
                        if (MapProfValues[i].value.TotalPercentage != null)
                            tPercen = tPercen + MapProfValues[i].value.TotalPercentage;
                    }
                    component.set("v.TCompleted", tclassComplete);
                    component.set("v.TAttended", tAtt);
                    try {
                        var tc = component.get("v.TCompleted");
                        var tA = component.get("v.TAttended");
                        var tp = tA / tc * 100;
                        component.set("v.TPercentage", tp);
                    } catch (err) {
                        alert(err);
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