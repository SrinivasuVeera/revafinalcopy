({
	getTermdetailsHelper: function(component, event,helper) 
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getTermDetails");
        action.setParams({'termId':component.get("v.recordId")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
            	if(response.getReturnValue() != undefined)
                {
                    var retVal = response.getReturnValue();  
                    console.log('MainWarp+++'+JSON.stringify(retVal));
                    component.set("v.objTerm",retVal);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
	getCourseOfferingDetails : function(component, event, helper) {
		component.set("v.Spinner",true);
        var action = component.get("c.getProgramPlan");
        action.setParams({'termId':component.get("v.recordId")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
         //   alert('++++'+state);
            if (state === "SUCCESS") 
            {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                                        
                    component.set("v.lstSection",retVal.lstSection);
                    component.set("v.listHardCore",retVal.listHardCore);
             //       alert(retVal.listHardCore);
             /*       
                    for(var i=0 ; i<retVal.listHardCore.length; i++ ){
                        for(var j=0 ; j<retVal.listHardCore[i].lstSection.length; j++){
                            
                            alert(retVal.listHardCore[i].lstSection[j].professorAssiened);
                        }    
                        
                    }
                 */   
                    component.set("v.listHcIntegrated",retVal.listHcIntegrated);
                    component.set("v.listPractical",retVal.listPractical);
                    component.set("v.listMandatory",retVal.listMandatory);
                    component.set("v.listOpenElective",retVal.listOpenElective);
                    component.set("v.listProfElective",retVal.listProfElective);
                    console.log('listProfElective+++'+JSON.stringify(retVal.listProfElective));
                   // console.log('listProfElective+++'+JSON.stringify(retVal.listProfElective));
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
	},
    getProfessorCourseOfferingDetails : function(component, event, helper, type) {
    	component.set("v.Spinner",true);    
        var idx = event.target.getAttribute('data-index');
      //  alert(idx);
        var courses;
        if(type == 'Hardcore Course'){
        	courses = component.get("v.listHardCore")[idx];    
        }
        if(type == 'Hardcore Integrated Course'){
            courses = component.get("v.listHcIntegrated")[idx]; 
        }
        if(type == 'Practical/Term Work'){
            courses = component.get("v.listPractical")[idx]; 
        }
        if(type == 'Mandatory Course'){
            courses = component.get("v.listMandatory")[idx]; 
        }
        if(type == 'Open Elective'){
            courses = component.get("v.listOpenElective")[idx]; 
        }
        if(type == 'Professional Elective'){
            var cc = component.get("v.listProfElective");
            courses = cc[0].lstCourse[idx];
         //   courses = component.get("v.listProfElective")[idx]; 
        }
     //   alert(JSON.stringify(courses));
        
        component.set("v.courseName",courses.courseName);
        component.set("v.courseId",courses.courseId);
       // alert('+++++'+type);
        var action = component.get("c.getPreferencesDetails");
        
        action.setParams({'termId':component.get("v.recordId"),
                          'courseId':courses.courseId,
                          'Category':type
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
         //   alert('+++++'+state);
         //   alert('+++++'+JSON.stringify(response.getError()));
            if (state === "SUCCESS") 
            {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                                        
                    component.set("v.listProfessors",retVal);
                    console.log('CourseOffer+++++'+JSON.stringify(retVal));
                    component.set("v.showSecondTable",true);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },   
    getProfessorAssignProcess : function(component, event, helper, type) {
        component.set("v.Spinner",true);    
        var idx = event.target.getAttribute('data-index');
      //  alert(idx);
        var courses;
        if(type == 'Hardcore Course'){
        	courses = component.get("v.listHardCore")[idx];    
        }
        if(type == 'Hardcore Integrated Course'){
            courses = component.get("v.listHcIntegrated")[idx]; 
        }
        if(type == 'Practical/Term Work'){
            courses = component.get("v.listPractical")[idx]; 
        }
        if(type == 'Mandatory Course'){
            courses = component.get("v.listMandatory")[idx]; 
        }
        if(type == 'Open Elective'){
            courses = component.get("v.listOpenElective")[idx]; 
        }
        if(type == 'Professional Elective'){
            courses = component.get("v.listProfElective")[idx]; 
        }
      //  alert(JSON.stringify(courses));
      //  alert('+++++'+courses.courseId);
        
       // component.set("v.courseName",courses.courseName);
      //  alert('+++++'+type);
        var action = component.get("c.getprofessorDetails");
        
        action.setParams({'termId':component.get("v.recordId"),
                          'courseId':courses.courseId,
                          'Category':type
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
           // alert('+++++--'+state);
           // alert('+++++--'+JSON.stringify(response.getError()));
            if (state === "SUCCESS") 
            {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                                        
                    component.set("v.listProfessorsAssign",retVal);
                    console.log('ProfAssignPross++++++'+JSON.stringify(retVal));
                    for(var i=0;i < retVal.length;i++){
                        var mapValues = [];
                        var result = retVal[i].mapProfessor;
                        for(var key in result){
                            mapValues.push({label: key,value: result[key]});
                        }
                        if(retVal[i].PreferenceCount == 1){
                        	component.set("v.Preferences1", mapValues);
                            component.set("v.primaryFaculty", retVal[i].primaryFaculty);
                        }
                        if(retVal[i].PreferenceCount == 2){
                        	component.set("v.Preferences2", mapValues);
                        }
                        if(retVal[i].PreferenceCount == 3){
                        	component.set("v.Preferences3", mapValues);
                        }
                        if(retVal[i].PreferenceCount == 4){
                        	component.set("v.Preferences4", mapValues);
                        }
                        if(retVal[i].PreferenceCount == 5){
                        	component.set("v.Preferences5", mapValues);
                        }
                        if(retVal[i].PreferenceCount == 6){
                        	component.set("v.Preferences6", mapValues);
                        }
                    }
                   // alert(JSON.stringify(retVal));
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },  
    getPraticalAssignProcess : function(component, event, helper, type) {
        component.set("v.Spinner",true);    
        var idx = event.target.getAttribute('data-index');
        var courses = component.get("v.listPractical")[idx];
        var action = component.get("c.getprofessorBatchDetails");
        console.log('RecordId++++++'+component.get("v.recordId"));
        
        action.setParams({'termId':component.get("v.recordId"),
                          'courseId':courses.courseId,
                          'Category':type
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
           // alert('+++++--'+state);
           // alert('+++++--'+JSON.stringify(response.getError()));
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                                        
                    component.set("v.listBatch",retVal);
                    console.log('listBatch+++'+JSON.stringify(retVal));
                    for(var j=0;j < retVal.length;j++){
                    for(var i=0;i < retVal[j].mainProffesors.length;i++){    
                        var mapValues = [];
                        var result = retVal[j].mainProffesors[i].mapProfessor;
                      //  alert(JSON.stringify(result));
                        for(var key in result){
                            mapValues.push({label: key,value: result[key]});
                        }
                        if(retVal[j].mainProffesors[i].PreferenceCount == 1){
                        	component.set("v.Preferences1", mapValues);
                            component.set("v.primaryFaculty", retVal[j].mainProffesors[i].primaryFaculty);
                        }
                        if(retVal[j].mainProffesors[i].PreferenceCount == 2){
                        	component.set("v.Preferences2", mapValues);
                        }
                        if(retVal[j].mainProffesors[i].PreferenceCount == 3){
                        	component.set("v.Preferences3", mapValues);
                        }
                        if(retVal[j].mainProffesors[i].PreferenceCount == 4){
                        	component.set("v.Preferences4", mapValues);
                        }
                        if(retVal[j].mainProffesors[i].PreferenceCount == 5){
                        	component.set("v.Preferences5", mapValues);
                        }
                        if(retVal[j].mainProffesors[i].PreferenceCount == 6){
                        	component.set("v.Preferences6", mapValues);
                        }
                    }    
                }    
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });   
        $A.enqueueAction(action);
    },    
    saveRecordHelper : function(component, event, helper){
        component.set("v.Spinner",true);
        var courseId = component.get("v.courseId");
        var prof = component.get("v.primaryFaculty");
        var con = component.get("v.isClickConfirm");
       // alert('+++++'+con);
        var action = component.get("c.saveProfessorDetails");        
        action.setParams({'termId':component.get("v.recordId"),
                          'courseId':courseId,
                          'primaryProfessor': prof,
                          'allCourses':component.get("v.listProfessorsAssign"),
                          'isConfirmrd':con
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
         //   alert('++++'+state);
            if (state === "SUCCESS") 
            {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                                        
                    component.set("v.lstSection",retVal.lstSection);
                    component.set("v.listHardCore",retVal.listHardCore);
             //       alert(retVal.listHardCore);
                    component.set("v.listHcIntegrated",retVal.listHcIntegrated);
                    component.set("v.listPractical",retVal.listPractical);
                    component.set("v.listMandatory",retVal.listMandatory);
                    component.set("v.listOpenElective",retVal.listOpenElective);
                    component.set("v.listProfElective",retVal.listProfElective);
                    component.set("v.showSecondTable",false); 
                    component.set("v.OpenTermPopup",false);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
    saveGroupRecordHelper : function(component, event, helper){
        component.set("v.Spinner",true);
        var courseId = component.get("v.courseId");
        var prof = component.get("v.primaryFaculty");
        var action = component.get("c.savePraticalDetails");  
        console.log('listBatch+++++++++++'+JSON.stringify(component.get("v.listBatch")));
        action.setParams({'termId':component.get("v.recordId"),
                          'courseId':courseId,
                          'primaryProfessor': prof,
                          'allGroups':component.get("v.listBatch"),
                          'isConfirmrd':component.get("v.isClickConfirm")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
         //   alert('++++'+state);
            if (state === "SUCCESS") 
            {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                                        
                    component.set("v.lstSection",retVal.lstSection);
                    component.set("v.listHardCore",retVal.listHardCore);
             //       alert(retVal.listHardCore);
                    component.set("v.listHcIntegrated",retVal.listHcIntegrated);
                    component.set("v.listPractical",retVal.listPractical);
                    component.set("v.listMandatory",retVal.listMandatory);
                    component.set("v.listOpenElective",retVal.listOpenElective);
                    component.set("v.listProfElective",retVal.listProfElective);
                    component.set("v.showSecondTable",false); 
                    component.set("v.OpenTermPopup",false);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
    getProElectiveProcess : function(component, event, helper, type) {
        component.set("v.Spinner",true);    
        var idx = event.target.getAttribute('data-index');
      //  var courses = component.get("v.listProfElective")[idx];
       var cc = component.get("v.listProfElective");
          var  courses = cc[0].lstCourse[idx];
        
        var action = component.get("c.getElectiveDetails");
        
        action.setParams({'termId':component.get("v.recordId"),
                          'courseId':courses.courseId,
                          'Category':type
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
          //  alert('+++++--'+state);
           // alert('+++++--'+JSON.stringify(response.getError()));
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                                        
                    component.set("v.lstElective",retVal);
                    console.log('getElectiveDetails++++'+JSON.stringify(retVal));
                    for(var j=0;j < retVal.length;j++){
                 //   for(var i=0;i < retVal[j].mainProffesors.length;i++){    
                        var mapValues = [];
                        var result = retVal[j].mapProfessor;
                      //  alert(JSON.stringify(result));
                        for(var key in result){
                            mapValues.push({label: key,value: result[key]});
                        }
                        if(retVal[j].PreferenceCount == 1){
                        	component.set("v.Preferences1", mapValues);
                            component.set("v.primaryFaculty", retVal[j].primaryFaculty);
                        }
                        if(retVal[j].PreferenceCount == 2){
                        	component.set("v.Preferences2", mapValues);
                        }
                        if(retVal[j].PreferenceCount == 3){
                        	component.set("v.Preferences3", mapValues);
                        }
                        if(retVal[j].PreferenceCount == 4){
                        	component.set("v.Preferences4", mapValues);
                        }
                        if(retVal[j].PreferenceCount == 5){
                        	component.set("v.Preferences5", mapValues);
                        }
                        if(retVal[j].PreferenceCount == 6){
                        	component.set("v.Preferences6", mapValues);
                        }
                   // }    
                }    
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });   
        $A.enqueueAction(action);
    },
    getGroupDetails : function(component, event, helper,type) {
		component.set("v.Spinner",true);
        var idx = event.target.getAttribute('data-index');
        var cc = component.get("v.listProfElective");
        var courses = cc[0].lstCourse[idx];        
        var action = component.get("c.getGroupLst");
        action.setParams({'termId':component.get("v.recordId"),
                          'courseId':courses.courseId,
                          'Category':type
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
         //   alert('++++'+state);
            if (state === "SUCCESS") 
            {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue(); 
                    console.log('Group+++++--'+JSON.stringify(retVal));
                    if(retVal.length > 0){
                       component.set("v.lstSection",retVal); 
                    }
                    else{
                        this.showToast(component,'dismissible','Failed','Group Not Found','error');
                        
                    }
                    
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
	},
    getTermSection : function(component, event, helper) {
		component.set("v.Spinner",true);
        var action = component.get("c.getSectionLst");
        action.setParams({'termId':component.get("v.recordId")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
         //   alert('++++'+state);
            if (state === "SUCCESS") 
            {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue(); 
                    console.log('Group+++++--'+JSON.stringify(retVal));
                    component.set("v.lstSection",retVal);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
	},
    saveProElectiveHelper : function(component, event, helper){
        component.set("v.Spinner",true);
        var courseId = component.get("v.courseId");
        var prof = component.get("v.primaryFaculty");
        var action = component.get("c.saveProElectiveDetails");  
        console.log('lstElective++++'+JSON.stringify(component.get("v.lstElective")));
        console.log('prof++++'+JSON.stringify(prof));
        action.setParams({'termId':component.get("v.recordId"),
                          'courseId':courseId,
                          'primaryProfessor': prof,
                          'allGroups':component.get("v.lstElective"),
                          'isConfirmrd':component.get("v.isClickConfirm")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();    
         //   alert('++++'+state);
            if (state === "SUCCESS") 
            {
            	if(response.getReturnValue() != undefined)
                {
                	var retVal = response.getReturnValue();                                        
                    component.set("v.lstSection",retVal.lstSection);
                    component.set("v.listHardCore",retVal.listHardCore);
             //       alert(retVal.listHardCore);
                    component.set("v.listHcIntegrated",retVal.listHcIntegrated);
                    component.set("v.listPractical",retVal.listPractical);
                    component.set("v.listMandatory",retVal.listMandatory);
                    component.set("v.listOpenElective",retVal.listOpenElective);
                    component.set("v.listProfElective",retVal.listProfElective);
                    component.set("v.showSecondTable",false); 
                    component.set("v.OpenTermPopup",false);
                    component.set("v.Spinner", false);
                }    
                component.set("v.Spinner", false); 
            }
            else{
                component.set("v.Spinner", false); 
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }  
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, mode, title, message, type)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2'
        });
        toastEvent.fire();
    }
})