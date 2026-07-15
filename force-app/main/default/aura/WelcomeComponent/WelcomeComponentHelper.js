({
    // =========================================
    // LOAD USER
    // Entry : Id userId
    // Set : 
    // - USER currentUser 	: USER record of id :userId
    // ==================================================
    loadUser : function(component, userId) {
        var action = component.get("c.getHierarchy");
        if (userId) action.setParams({ userid : userId });
        component.set("v.displayLoader",true); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.currentUser", response.getReturnValue().selectedUser);
                var dpt = response.getReturnValue().selectedUser.physicalDeliveryOfficeName__c;
                var firstName = response.getReturnValue().selectedUser.FirstName;
                var lastName =  response.getReturnValue().selectedUser.LastName;
                //Enhancement to populate backgroundimagepath - July 9, 2016
                var staticResourceDateTimeStamp = response.getReturnValue().staticResourceDateTimeStamp[0].SystemModstamp;
                var staticResourceTimeStamp = new Date(staticResourceDateTimeStamp).getTime();
                var backgroundResourceId = staticResourceTimeStamp;
                //End enhancement

                switch(dpt){
                    //set background image based on Office Location
                    case "San Francisco": 
						//construct static resource path : /resource/<timestamp>/<name>/<path>
                        //component.set("v.profileDepartmentImg", '/resource/'+backgroundResourceId+'/welcomeProfileBackground/_demo-banner-SF.jpg');
                        component.set("v.profileDepartmentImg", '/resource/'+staticResourceTimeStamp+'/welcomeProfileBackground/_demo-banner-SF.jpg');
                    break;  
                    case "Tokyo": 
                        component.set("v.profileDepartmentImg", '/resource/'+staticResourceTimeStamp+'/welcomeProfileBackground/_demo-banner-tokyo.jpg');
                    break;  
                    case "Sydney": 
                        component.set("v.profileDepartmentImg", '/resource/'+staticResourceTimeStamp+'/welcomeProfileBackground/_demo-banner-sydney.jpg');
                    break;
                    default:
                        component.set("v.profileDepartmentImg", '/resource/'+staticResourceTimeStamp+'/welcomeProfileBackground/_Reva.jpg');
                        break;
                }

                //set greeting
                var timeOfDay = new Date();
                //var partOfDay = "Night";
                var partOfDay = "Evening";
                //get weekday
                var weekday = new Array(7);
                weekday[0]=  "Sunday";
                weekday[1] = "Monday";
                weekday[2] = "Tuesday";
                weekday[3] = "Wednesday";
                weekday[4] = "Thursday";
                weekday[5] = "Friday";
                weekday[6] = "Saturday";
                var day = weekday[timeOfDay.getDay()];
                //get month
                var month = new Array();
                month[0] = "January";
                month[1] = "February";
                month[2] = "March";
                month[3] = "April";
                month[4] = "May";
                month[5] = "June";
                month[6] = "July";
                month[7] = "August";
                month[8] = "September";
                month[9] = "October";
                month[10] = "November";
                month[11] = "December";
                var theMonth = month[timeOfDay.getMonth()];
                //get year
                var year = timeOfDay.getFullYear();
                //get date
                var date = timeOfDay.getDate();
                var hourOfDay = timeOfDay.getHours();
                if(hourOfDay >= 5 && hourOfDay < 12){
                    partOfDay = "Morning";
                } else if (hourOfDay >= 12 && hourOfDay < 17){
                    partOfDay = "Afternoon";
                } else if (hourOfDay >= 5 && hourOfDay < 20){
                    partOfDay = "Evening";
                }
                component.set("v.partOfDayGreeting", 'Good '+partOfDay+',<br/>'+(firstName ? firstName+' '+lastName+'!' : lastName+'!'));
                component.set("v.today",day+', '+theMonth+' '+date);
                component.set("v.displayLoader",false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

})