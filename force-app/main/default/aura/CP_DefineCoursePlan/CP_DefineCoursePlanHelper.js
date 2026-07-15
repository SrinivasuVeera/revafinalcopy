({
    savelastcoursedetails: function(component, event, helper)
    {
        var action = component.get("c.savelastCourses");
        action.setParams({"str_selectedcourse":component.get("v.SelectedCourseOff"),"str_course":component.get("v.recordId")});
        action.setCallback(this, function(response) 
                           {	
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {
                                       if(response.getReturnValue().lst_rtrnPlanunits.length == 0)
                                       {
                                           this.showToast(component,'dismissible','Error','Course Plan Units does not Exists for the Selected Course offering....!','error');
                                       }
                                       else if(response.getReturnValue().strMessage === 'Success')
                                       {
                                           this.showToast(component,'dismissible','Success','Course Plan Units Successfully Created..!','success');
                                           helper.getcourseplanDetails(component, event, helper);
                                           component.set("v.showCoursePlanunits", false);
                                           component.set("v.crseOffId",null);
                                           $A.get('e.force:refreshView').fire();
                                       }
                                           else
                                           {
                                               this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                                           }
                                   }
                                   else
                                   {
                                       this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                   }
                               }
                               else
                               {
                                   this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                               }
                               
                           }); 
        $A.enqueueAction(action);
        
    },
    getLast5CourseOfferingDetails: function(component, event, helper)
    {
        var action = component.get("c.getlastCourseOfferings");
        action.setParams({"str_CourseOfferingId": component.get("v.recordId") });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var mapValues = [];
                                   var courseoffers = response.getReturnValue().map_CourseOfferings;
                                   for( var key in courseoffers)
                                   {
                                       mapValues.push({value:courseoffers[key], key:key});
                                   }
                                   component.set("v.MapCourseOffer",mapValues);                                  
                               }
                           });
        $A.enqueueAction(action);
    },
    onchangeCourseHelper: function(component, event, helper)
    {
        var cmps = event.getSource().get("v.value"); 
        component.set("v.SelectedCourseOff",cmps);  
    },
    getCourseOffrDetails: function(component, event, helper)
    {
        var action = component.get("c.getCourseOfferdetails");
        action.setParams({"str_courseId": component.get("v.recordId") });              
        action.setCallback(this, function(result) 
                           {
                               var state = result.getState();
                               if (state === "SUCCESS")  
                               {
                                   if(result.getReturnValue() != undefined)
                                   { 
                                       var resultData = result.getReturnValue(); 
                                       component.set("v.strcourseoffer", resultData.objcourseOffering.Name);  
                                       component.set("v.strsemstr", resultData.objcourseOffering.hed__Term__r.Name);
                                       component.set("v.strbatch", resultData.objSemester.Program_Batch__r.Name); 
                                   }
                                   else
                                   {
                                     this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                                   }
                                   
                               }
                               else
                               {
                                   this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                               }
                           });
        $A.enqueueAction(action);	 
    },
    getcourseplanDetails: function(component, event, helper)
    {
        var action = component.get("c.getCourseplanunits");
        component.set("v.Spinner",true);
        action.setParams({"str_courseoffering":component.get("v.recordId")});
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               if(State === "SUCCESS")
                               {
									if(response.getReturnValue() != undefined)
                                    {                                   
                                       component.set("v.courseplanlist", response.getReturnValue().lst_courseunits); 
                                       component.set("v.Spinner",false);
                                    }
                                   else
                                   {
                                     this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                   }
                               }
                               else
                               {
                                   this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                               }
                           });
        $A.enqueueAction(action);
    },
    onclickAddunitsDocHelper: function(component, event, helper)
    {
        var selectedplanId = event.currentTarget.getAttribute("data-Id");
        component.set("v.slctPlnunit",selectedplanId);
        var action = component.get("c.getSelectedUnitsDocument");
        component.set("v.Spinner",true);
        action.setParams({"str_slplanId": selectedplanId});
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               if(State === "SUCCESS")
                               {
                                   component.set("v.Spinner",false);
                                   component.set("v.selectedUnitsFiles", response.getReturnValue().list_contentdocuments); 
                               }
                           });
        $A.enqueueAction(action);
        
    },
    onclickAddTopicsDocHelper: function(component, event, helper)
    {
        var selectedtopicId = event.currentTarget.getAttribute("data-Id");
        component.set("v.slctPlntopics",selectedtopicId);
        
        var action = component.get("c.getSelectedTopicsDocument");
        component.set("v.Spinner",true);
        action.setParams({"str_slctdtopicId": selectedtopicId});
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               if(State === "SUCCESS")
                               {
                                   component.set("v.Spinner",false);
                                   component.set("v.selectedTopicsFiles", response.getReturnValue().list_contentversions); 
                               }
                           });
        $A.enqueueAction(action);
    },
    getTopicDocafterdeleteHelper: function(component, event, helper)
    {
        var selecteddoctopicId = component.get("v.slctPlntopics");
        
        var action = component.get("c.getTopicsDocaftrDlt");
        component.set("v.Spinner",true);
        action.setParams({"str_seltopicId": selecteddoctopicId});
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               
                               if(State === "SUCCESS")
                               {
                                   component.set("v.Spinner",false);
                                   component.set("v.selectedTopicsFiles", response.getReturnValue().list_contentversions); 
                               }
                           });
        $A.enqueueAction(action);
    },
    getPlanUnitsDocafterdeleteHelper: function(component, event, helper)
    {
        var selectedunitsId = component.get("v.slctPlnunit");
        
        var action = component.get("c.getUnitsDocAftrDlt");
        component.set("v.Spinner",true);
        action.setParams({"str_selplanunitId": selectedunitsId});
        action.setCallback(this,function(response)
                           {
                               var State = response.getState();
                               if(State === "SUCCESS")
                               {
                                   component.set("v.Spinner",false);
                                   component.set("v.selectedUnitsFiles", response.getReturnValue().list_ContentDocuments); 
                               }
                           });
        $A.enqueueAction(action);
    },
    getCourseUnitsOnclickHelper: function(component, event, helper)
    {          
        var openmodal =  component.set("v.isModalOpen",true);
        
        var action = component.get("c.getCourseOfferingUnitsDetails");
        component.set("v.Spinner",true);
        action.setParams({"str_CourseId": component.get("v.recordId")});
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   component.set("v.Spinner",false);
                                   var result = response.getReturnValue();                                  
                                   var courses = response.getReturnValue().map_Coursewrp;
                                   var courseMap = [];
                                   for(var key in courses)
                                   {
                                       var course = {
                                           "value": courses[key],
                                           "key": key
                                       };
                                       courseMap.push(course);
                                   }
                                   component.set("v.courseunitWrp", courseMap);
                                   //component.set("v.selectedTab", courseMap[0].value.coursePlanId);                                 
                               }
                           });
        $A.enqueueAction(action);
    },
    addCourseplanUnitsHelper: function(component, event, helper) 
    {
        var listcourseplanunit = component.get("v.courseplanlist");
        
        var courseofferingid = component.get("v.recordId");
        listcourseplanunit.push({
            'sobjectType': 'Course_Plan_Unit__c',
            'Name': '',
            'Course_Offering__c': courseofferingid
        });
        component.set("v.courseplanlist", listcourseplanunit);
    },
    addCrseplanTopicsHelper: function(component, event, helper) 
    {
        var courseunitselected = event.getSource().get("v.value");
        var crseIndex = event.getSource().get("v.name");
        
        var plnwrp = component.get("v.courseunitWrp");
        plnwrp[crseIndex].value.lst_WrapCourses.push({
            'topicId':'',
            'topicname': '',
            'courseunit': courseunitselected
        });    
        
        component.set("v.courseunitWrp", plnwrp);
    },
    savecoureplanunitsHelper: function(component, event, helper)
    {
        var action = component.get("c.savecoursunits");
        var listcourseplanubits = component.get("v.courseplanlist");
        var unitname =0;
        var enterunitname =0;
        
        for(var i=0; i<listcourseplanubits.length ;i++)
        {
            for(var j=0; j<listcourseplanubits.length ;j++)
            {                 
                if(listcourseplanubits[j].Name.toLowerCase() == listcourseplanubits[i].Name.toLowerCase() && i != j)
                {       
                    unitname = unitname+1;  
                } 
            }
            
        }
        
        for(var i=0; i<listcourseplanubits.length ;i++)
        {
            if(listcourseplanubits[i].Name == "")
            {
                enterunitname = enterunitname+1;  
            }
        }
        
        if(unitname > 0)
        {
            this.showToast(component,'dismissible','Error','Plan Unit Already Exists with Same Name(Duplicate Unit Names).....!','error');
        }
        else if(enterunitname > 0)
        {
            this.showToast(component,'dismissible','Error','Please fill the Course plan Unit Name.....!','error');  
        }
            else 
            {
                action.setParams({"CourseOfferId":component.get("v.recordId"),"lst_planunits": component.get("v.courseplanlist")});
                action.setCallback(this, function(response) 
                                   {	
                                       var state = response.getState();
                                       if(state === "SUCCESS")
                                       {
                                           if(response.getReturnValue() != undefined)
                                           {
                                               if(response.getReturnValue().strMessage === 'Success')
                                               {
                                                   this.showToast(component,'dismissible','Success','Course Plan Units Successfully Created..!','success');
                                                   helper.getcourseplanDetails(component, event, helper);
                                                   $A.get('e.force:refreshView').fire();
                                               }
                                               else
                                               {
                                                   this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                                               }
                                           }
                                           else
                                           {
                                               this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                           }
                                       }
                                       else
                                       {
                                           this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                       }
                                       
                                   }); 
                $A.enqueueAction(action);
            } 
    },
    savecoureTopicsHelper: function(component, event, helper)
    {
        var updateTopicsList = [];
        var topicwrp = component.get("v.courseunitWrp");
        var topicname = 0;
        var topicnameenter =0;
        
        topicwrp.forEach(function(item, index)
                         {
                             var crsetoplist = item.value.lst_WrapCourses;
                             //alert('=== Course list ===='+JSON.stringify(crsetoplist));
                             for(var i=0;i<crsetoplist.length;i++)
                             {
                                 //alert('===== Topics lists i ====='+crsetoplist[i].topicname.toLowerCase());
                                 for(var j=0; j<crsetoplist.length ;j++)
                                 {
                                     //alert('===== Topics lists j ====='+crsetoplist[j].topicname.toLowerCase());
                                     if(crsetoplist[j].topicname.toLowerCase() == crsetoplist[i].topicname.toLowerCase() && i != j)
                                     {                            
                                         topicname = topicname+1;  
                                     }      
                                 }
                             }
                         });
        
        topicwrp.forEach(function(item, index)
                         {
                             var crsetopunitlist = item.value.lst_WrapCourses;
                             for(var i=0;i<crsetopunitlist.length;i++)
                             {
                                 if(crsetopunitlist[i].topicname == "")
                                 {                            
                                     topicnameenter = topicnameenter+1;  
                                 }      
                             }
                         });
        
        if(topicname > 0)
        {
            this.showToast(component,'dismissible','Error','Plan Topic Already Exists with Same Name (Duplicate Topic Names).....!','error');
        }
        else if(topicnameenter > 0)
        {
            this.showToast(component,'dismissible','Error','Please fill the Course Plan Topic Name.....!','error');
        }
            else
            {
                topicwrp.forEach(function(item, index)
                                 {
                                     var crsetopicslist = item.value.lst_WrapCourses;
                                     for(var i=0;i<crsetopicslist.length;i++)
                                     {
                                         updateTopicsList.push(crsetopicslist[i]); 
                                     }
                                 });
                
                
                var action = component.get("c.saveCourseTopics");
                action.setParams({"str_courseTopics": JSON.stringify(updateTopicsList)});
                action.setCallback(this, function(response) 
                                   {	
                                       var state = response.getState();
                                       if(state === "SUCCESS")
                                       {
                                           if(response.getReturnValue() != undefined)
                                           {
                                               if(response.getReturnValue().strMessage === 'Success')
                                               {
                                                   this.showToast(component,'dismissible','Success','Course Plan Topics Successfully Created..!','success');
                                                   this.getCourseUnitsOnclickHelper(component,event,helper);
                                                   //var selid = component.get("v.seleTabId"); 
                                                   //$A.get('e.force:refreshView').fire();                                                                                   
                                                   //component.set("v.selectedTab",selid);
                                               }
                                               else
                                               {
                                                   this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                                               }
                                           }
                                           else
                                           {
                                               this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                           }
                                       }
                                       else
                                       {
                                           this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                       }
                                       
                                   }); 
                $A.enqueueAction(action); 
            }
    },
    handleFileUploadHlpr : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        this.showToast(component,'dismissible','Success','Files Uploaded Successfully..!','success');
        component.set("v.Spinner",false);
    },
    handleTopicsFileUploadHelper: function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        this.showToast(component,'dismissible','Success','Files Uploaded Successfully..!','success');
        component.set("v.Spinner",false);
    },
    dltPlanUnitsDocsHlpr: function(component, event, helper)
    {
        var dltflid = event.getSource().get("v.value");
        
        var action = component.get("c.deleteUnitsDoc");
        action.setParams({"str_file": dltflid});
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {
                                       if(response.getReturnValue().strMessage === 'Success')
                                       {
                                           this.showToast(component,'dismissible','Success','Course Plan Units Documents Deleted Successfully..!','success');                                       
                                           this.getPlanUnitsDocafterdeleteHelper(component, event ,helper);
                                       }
                                       else
                                       {
                                           this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                                       }
                                   }
                                   else
                                   {
                                       this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                   }
                               }
                               else
                               {
                                   this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                               }
                           });
        $A.enqueueAction(action);
    },
    dltPlantopicsdocumentsHlpr: function(component, event, helper)
    {
        var dlttopicflid = event.getSource().get("v.value");
        
        var action = component.get("c.deleteTopicsDoc");
        action.setParams({"str_file": dlttopicflid});
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS")
                               {
                                   if(response.getReturnValue() != undefined)
                                   {
                                       if(response.getReturnValue().strMessage === 'Success')
                                       {
                                           
                                           this.showToast(component,'dismissible','Success','Course Plan Topics Documents Deleted Successfully..!','success');
                                           this.getTopicDocafterdeleteHelper(component, event, helper);
                                       }
                                       else
                                       {
                                           this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                                       }
                                   }
                                   else
                                   {
                                       this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                   }
                               }
                               else
                               {
                                   this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                               }
                           });
        $A.enqueueAction(action);
        
    },
    deleteCoursePlanUnitsHelper : function(component, event, helper)
    {
        var lstdeleteplans = component.get("v.courseplanlist");
        var planid = event.getSource().get("v.value");
        
        if(planid == "" || planid == undefined)
        {
            var index = event.getSource().get("v.name"); 
            lstdeleteplans.splice(index, 1);
            component.set("v.courseplanlist",lstdeleteplans);
        }
        else
        {
            var action = component.get("c.deleteCoursePlanUnits");
            action.setParams({"str_courseplanunit": planid});
            action.setCallback(this, function(response)
                               {
                                   var state = response.getState();
                                   if(state === "SUCCESS")
                                   {
                                       if(response.getReturnValue() != undefined)
                                       {
                                           if(response.getReturnValue().strMessage === 'Success')
                                           {
                                               this.showToast(component,'dismissible','Success','Course Plan Units Deleted Successfully..!','success');
                                               this.getcourseplanDetails(component, event, helper);
                                               $A.get('e.force:refreshView').fire();                                             
                                           }
                                           else
                                           {
                                               this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                                           }
                                       }
                                       else
                                       {
                                           this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                       }
                                   }
                                   else
                                   {
                                       this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                   }
                               });
            $A.enqueueAction(action);
        }  
    },
    deletecrseplanTopicsHelper: function(component, event, helper)
    {
        
        var topicid = event.getSource().get("v.value");
        var listcourseplantopics = [];
        var plnwrp = component.get("v.courseunitWrp"); 
        var courseindex = event.getSource().get("v.name");
        var topicIndex = courseindex.split('_')[0];
        var planIndex = courseindex.split('_')[1];
        
        if(topicid == "" || topicid == undefined)
        {
            plnwrp[planIndex].value.lst_WrapCourses.splice(topicIndex, 1);
            component.set("v.courseunitWrp",plnwrp);
        }
        else
        {
            var action = component.get("c.deleteCoursePlanTopics");
            action.setParams({"str_crsetopics": topicid});
            action.setCallback(this, function(response)
                               {
                                   var state = response.getState();
                                   if(state === "SUCCESS")
                                   {
                                       if(response.getReturnValue() != undefined)
                                       {
                                           if(response.getReturnValue().strMessage === 'Success')
                                           {
                                               this.showToast(component,'dismissible','Success','Course Plan Topics Deleted Successfully..!','success');
                                               this.getCourseUnitsOnclickHelper(component, event ,helper);
                                               $A.get('e.force:refreshView').fire();                                             
                                           }
                                           else
                                           {
                                               this.showToast(component,'dismissible','Failed',response.getReturnValue().strMessage,'error');
                                           }
                                       }
                                       else
                                       {
                                           this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                       }
                                   }
                                   else
                                   {
                                       this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
                                   }
                               });
            $A.enqueueAction(action);
        }          
    },
    showToast : function(component, mode, title, message, type) 
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'0.5'
        });
        toastEvent.fire();
    },
})