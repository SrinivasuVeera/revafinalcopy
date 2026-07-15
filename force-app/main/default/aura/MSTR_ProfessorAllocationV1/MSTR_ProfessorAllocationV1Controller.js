({
	doInit : function(component, event, helper) {
        helper.getTermdetailsHelper(component,event,helper);
		helper.getCourseOfferingDetails(component,event,helper);
	},
    hardCoreProfessorDetail : function(component, event, helper) {
        helper.getGroupDetails(component, event, helper,'Hardcore Course');
        helper.getProfessorCourseOfferingDetails(component, event, helper,'Hardcore Course');
        helper.getProfessorAssignProcess(component, event, helper,'Hardcore Course');
        component.set("v.category",'Hardcore Course');
        component.set("v.tableView",'default');
        component.set("v.OpenTermPopup",true);
        component.set("v.isClickConfirm",false);
    },
    hardCoreIntProfessorDetail : function(component, event, helper) {
        helper.getGroupDetails(component, event, helper,'Hardcore Integrated Course');
        helper.getProfessorCourseOfferingDetails(component, event, helper,'Hardcore Integrated Course');
        helper.getProfessorAssignProcess(component, event, helper,'Hardcore Integrated Course');
        component.set("v.category",'Hardcore Integrated Course');
        component.set("v.OpenTermPopup",true);
        component.set("v.tableView",'default');
        component.set("v.isClickConfirm",false);
    },
    praticalProfessorDetail : function(component, event, helper) {
        helper.getGroupDetails(component, event, helper,'Practical/Term Work');
        helper.getProfessorCourseOfferingDetails(component, event, helper,'Practical/Term Work');
        helper.getPraticalAssignProcess(component, event, helper,'Practical/Term Work');
        component.set("v.category",'Practical/Term Work');
        component.set("v.OpenTermPopup",true);
        component.set("v.tableView",'Practical');
        component.set("v.isClickConfirm",false);
    },
    manditoryProfessorDetail : function(component, event, helper) {
        helper.getGroupDetails(component, event, helper,'Mandatory Course');
        helper.getProfessorCourseOfferingDetails(component, event, helper,'Mandatory Course');
        helper.getProfessorAssignProcess(component, event, helper,'Mandatory Course');
        component.set("v.category",'Mandatory Course');
        component.set("v.OpenTermPopup",true);
        component.set("v.tableView",'default');
        component.set("v.isClickConfirm",false);
    },
    opElectiveProfessorDetail : function(component, event, helper) {
        helper.getProfessorCourseOfferingDetails(component, event, helper,'Open Elective');
        helper.getProfessorAssignProcess(component, event, helper,'Open Elective');
        component.set("v.category",'Open Elective');
        component.set("v.OpenTermPopup",true);
        component.set("v.tableView",'opElective');
        component.set("v.isClickConfirm",false);
    },
    profElectiveProfessorDetail : function(component, event, helper) {
        helper.getGroupDetails(component, event, helper,'Professional Elective');
        helper.getProfessorCourseOfferingDetails(component, event, helper,'Professional Elective');
        helper.getProElectiveProcess(component, event, helper,'Professional Elective');        
        component.set("v.category",'Professional Elective');
        component.set("v.OpenTermPopup",true);
        component.set("v.tableView",'prElective');
        component.set("v.isClickConfirm",false);
    },    
    CloseTermPopup:function(component, event, helper) 
    {
        helper.getTermSection(component, event, helper);
        component.set("v.OpenTermPopup",false);
        component.set("v.showSecondTable",false);        
    },
    saveConfirmButton: function(component, event, helper) {
       component.set("v.isClickConfirm",true); 
       // alert('++++++Test');
      // this.saveButton(component, event, helper);
        var action = component.get('c.saveButton');
        $A.enqueueAction(action); 
    },    
    saveButton: function(component, event, helper) {
        var category = component.get("v.tableView");
       // alert('++++++Test1');        
        if(category == 'default'){
            var errMsg = 'Success';
            var lstPrf = component.get("v.listProfessorsAssign");
            var primary = component.get("v.primaryFaculty");            
            var arr = [];
            var isMatch = false;
            
            for(var i=0;i<lstPrf.length;i++){
                for(var j=0;j<lstPrf[i].lstPreferences.length;j++){
                   
                    if(lstPrf[i].lstPreferences[j].professorId){
                        if(lstPrf[i].orderCount == '1' && primary){
                            if(lstPrf[i].lstPreferences[j].professorId == primary){
                                isMatch = true;    
                            }
                        } 
                        var str = lstPrf[i].lstPreferences[j].professorId + '-' + lstPrf[i].lstPreferences[j].section;
                        
                        if(arr.includes(str)){
                            errMsg = "Professor More than One time allocated on '"+ lstPrf[i].lstPreferences[j].section +"' Section";
                        }   
                        else{
                            arr.push(str) ;   
                        }
                    }                
                }
            }    
            
            if(primary){
                if(!isMatch){
                   // errMsg = "Quality Circle Head Not Match..!!";
                   errMsg = "Only Primary Professors should be selected as a Quality Circle Head";
                }
            }
            else{
                errMsg = "Please selecte Quality Circle Head";
                
            }
            
            if(errMsg == 'Success'){
                helper.saveRecordHelper(component, event, helper);
            }   
            else{
                helper.showToast(component,'dismissible','Failed',errMsg,'error');
            }
        }
        if(category == 'Practical'){
            var errMsg = 'Success';
            var lstPrf = component.get("v.listBatch");
            var primary = component.get("v.primaryFaculty");
            var arr = [];
            
            for(var h=0;h<lstPrf.length;h++){
                var isMatch = false;
                for(var i=0;i<lstPrf[h].mainProffesors.length;i++){
                    for(var j=0;j<lstPrf[h].mainProffesors[i].lstPreferences.length;j++){
                       
                        if(lstPrf[h].mainProffesors[i].lstPreferences[j].professorId){
                            if(lstPrf[h].mainProffesors[i].orderCount == '1' && primary){
                                if(lstPrf[h].mainProffesors[i].lstPreferences[j].professorId == primary){
                                    isMatch = true;    
                                }
                            } 
                            var str = lstPrf[h].mainProffesors[i].lstPreferences[j].professorId + '-' + lstPrf[h].mainProffesors[i].lstPreferences[j].section +'-'+ lstPrf[h].mainProffesors[i].lstPreferences[j].groupId;
                           // alert(str);
                            if(arr.includes(str)){
                                errMsg = "Professor More than One time allocated on '"+ lstPrf[h].mainProffesors[i].lstPreferences[j].section +"' Section";
                            }   
                            else{
                                arr.push(str) ;   
                            }
                        }                
                    }
                }    
            }
            
            if(primary){
                if(!isMatch){
                   errMsg = "Only Primary Professors should be selected as a Quality Circle Head";
                }
            }
            else{
                errMsg = "Please selecte Quality Circle Head";
                
            }
            
            if(errMsg == 'Success'){
                helper.saveGroupRecordHelper(component, event, helper);
            }   
            else{
                helper.showToast(component,'dismissible','Failed',errMsg,'error');
            }    
        }
        if(category == 'prElective'){
            var primary = component.get("v.primaryFaculty");
            var errMsg = 'Success';
            var lstPrf = component.get("v.lstElective");
            var isMatch = false;
            console.log('+++++--'+JSON.stringify(component.get("v.lstElective")));
            
            for(var i=0;i<lstPrf.length;i++){
                for(var j=0;j<lstPrf[i].mainProffesors.length;j++){
                    if(lstPrf[i].orderCount == '1' && primary){
                        if(lstPrf[i].mainProffesors[j].professorId == primary){
                            isMatch = true;    
                        }
                    }
                }
            }   
            
            if(primary){
                if(!isMatch){
                   errMsg = "Only Primary Professors should be selected as a Quality Circle Head";
                }
            }
            else{
                errMsg = "Please selecte Quality Circle Head";
                
            }
            
            if(errMsg == 'Success'){
                helper.saveProElectiveHelper(component, event, helper);
            }   
            else{
                helper.showToast(component,'dismissible','Failed',errMsg,'error');
            }
            
            
            
        }    
    }
})