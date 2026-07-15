({
    doInitHpr : function(component, event, helper) {
        component.set("v.Spinner",true);
        let today = new Date().toISOString().split('T')[0];
        
        component.set("v.todayDate", today);
        console.log('Today\'s Date (YYYY-MM-DD):', today);
        console.log('Attribute v.todayDate value:', component.get("v.todayDate"));
        var action = component.get("c.fetchData");
        if(component.get("v.selectedIAtype")=='IA2'){
            component.set("v.isIA2",true)
        }
        else{
            component.set("v.isIA2",false)
            
        }
        console.log('IAType=>'+component.get("v.isIA2"));
        action.setParams({'iaType':component.get("v.selectedIAtype")});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS'){
                if(result.getReturnValue() != undefined){
                    var retVal = result.getReturnValue();
                    var courseList = retVal.list_CrsCons;
                    
                    // Add 10 days to IA_End_Date__c for each course
                    courseList.forEach(function(crs) {
                        crs.facultycheck = crs.rve_Professor_Freeze__c;
                        if (crs.IA2_Result_Date__c) {
                            let iaEndDate = new Date(crs.IA2_Result_Date__c);
                            iaEndDate.setDate(iaEndDate.getDate() + 6); // Add 10 days
                            crs.IA_Allowed_End_Date__c = formatToDDMMYYYY(iaEndDate); // Format as 'YYYY-MM-DD'
                            crs.IA_Allowed_End_Date_Comparable = iaEndDate.toISOString().split('T')[0];
                            //console.log('IA_Allowed_End_Date_Comparable==',crs.IA_Allowed_End_Date_Comparable);
                        } else {
                            crs.IA_Allowed_End_Date__c = null; // Handle missing dates gracefully
                        }
                        if (crs.IA2_Result_Date__c) {
                            let resultDate = new Date(crs.IA2_Result_Date__c);
                            crs.IA2_Result_Date__c_Formatted = formatToDDMMYYYY(resultDate); // Add formatted date as a new property
                        } else {
                            crs.IA2_Result_Date__c_Formatted = null;
                        }
                    });
                    
                    function formatToDDMMYYYY(date) {
                        let day = String(date.getDate()).padStart(2, '0'); // Pad day to 2 digits
                        let month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
                        let year = date.getFullYear();
                        return `${day}-${month}-${year}`;
                    }
                    
                    console.log("Updated Course List: ", courseList);
                    component.set("v.isAllowed",retVal.isAllowed);
                    component.set("v.errorMessage",retVal.message);
                    component.set("v.courseList",courseList);
                    component.set("v.LastDate",retVal.LastAllowedDate);
                    console.log("LastAllowedDate: ", retVal.LastAllowedDate);
                    console.log("LastAllowedDate: ", retVal.LastAllowedDate);
                    
                    component.set("v.Spinner",false);
                    
                    // ✅ Call Second Apex Method
                    var action2 = component.get("c.checkFreezingStatus"); 
                    action2.setParams({ 'iaType': component.get("v.selectedIAtype") }); // Pass parameters if needed
                    
                    action2.setCallback(this, function(result2) {
                        if (result2.getState() === 'SUCCESS') {
                            console.log("Second Apex Call Success: ", result2.getReturnValue());
                            component.set("v.isFreezed",result2.getReturnValue());
                            component.set("v.freezeProfessor",result2.getReturnValue());
                            console.log("isFreezed: ", component.get("v.isFreezed"));
                        } else {
                            console.error("Error in Second Apex Call: ", result2.getError()[0].message);
                            this.showToast(component, 'dismissible', 'Failed', result2.getError()[0].message, 'error');
                        }
                        component.set("v.Spinner", false);
                    });
                    
                    $A.enqueueAction(action2);
                }
            } else {
                /* console.error("Error in First Apex Call: ", result1.getError()[0].message);
         this.showToast(component, 'dismissible', 'Failed', result1.getError()[0].message, 'error');*/
         component.set("v.Spinner", false);
     }
        });
        $A.enqueueAction(action);
    },
    handleRefEventHpr : function(component, event, helper) {
        //alert(event.getParam("iaType"));
        component.set("v.selectedIAtype",event.getParam("iaType"));
        component.set("v.selectedConId","");
        component.set("v.selectedCrsType","");
        component.set("v.isSelected",false);
        helper.doInitHpr(component, event, helper);
    },
    showToast : function(component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2000'
        });
        toastEvent.fire();
    },
    
    updateFreezingStatus : function(component, event, helper) {
        console.log("Selected Course Offering ID: ", component.get("v.selectedCourseId"));
        //  let value = event.target.value;
        var action = component.get("c.updateFreezingStatus"); 
        console.log("Apex Method Retrieved: ", action);
        var courseconId = component.get("v.selectedCourseId");
        
        action.setParams({ 'CourseOfferingID': component.get("v.selectedCourseId") }); // Pass parameters if needed
        
        action.setCallback(this, function(result2) {
            var state = result2.getState();
            console.log("Apex Response State: ", state);
            
            if (result2.getState() === 'SUCCESS') {
                console.log("Apex Call Success: ", result2.getReturnValue());
                var updatedCourseList = [];
                var courselist = component.get("v.courseList");
                console.log('113=> '+JSON.stringify(courselist));
                for (var i = 0; i < courselist.length; i++) {
                    var crs = courselist[i];
                    var newCrs = {}; // Manual clone
                    
                    for (var key in crs) {
                        if (crs.hasOwnProperty(key)) {
                            newCrs[key] = crs[key];
                        }
                    }
                    
                    if (crs.Id === component.get("v.selectedCourseId")) {
                        newCrs.facultycheck = true;
                    }
                    
                    updatedCourseList.push(newCrs);
                }
                
                component.set("v.courseList", updatedCourseList);
                
                console.log('updatedlist=> '+JSON.stringify(component.get("v.courseList")));
                component.set("v.freezeProfessor",true);
                component.set("v.isFreezed",true);
                component.set("v.isModalOpen",false);
                this.showToast(component, 'dismissible', 'Status', 'Faculty Frozen IA Marks Successfully', 'success');
                console.log("status: ", component.get("v.freezeProfessor"));
            } else {
                console.error("Error in Apex Call: ", result2.getError()[0].message);
                this.showToast(component, 'dismissible', 'Failed', result2.getError()[0].message, 'error');
            }
            //  component.set("v.Spinner", false);
        });
        
        
        $A.enqueueAction(action);
        
        
    },
    fetchStudentMarks: function(component, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getCourseWiseIAMarks");
        action.setParams({
            "CourseID": component.get("v.selectedCourseId")
        });
        action.setCallback(this, function(response) {
            component.set("v.Spinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var studentMarks = response.getReturnValue();
                // Transform the data to match the table structure
                var transformedData = [];
                studentMarks.forEach(function(mark, index) {
                    transformedData.push({
                        slNo: index + 1,
                        srnNumber: mark.StudentSRN,
                        studentName: mark.StudentName,
                        ia1Marks: mark.IA1Marks || 0,
                        ia2Marks: mark.IA2Marks || 0,
                        totalMarks: mark.Marks
                    });
                });
                component.set("v.studentMarksList", transformedData);
            } else {
                this.showToast(component, 'dismissible', 'Failed', 'Error fetching student marks: ' + response.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action);
    },
    markFreeze : function(component, event, helper) {
        component.set("isMarkFreeze",true);
        component.set("isModalOpen",false);
    }
})