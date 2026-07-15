({
    
    fetchSchedule: function(component) {
        var action = component.get('c.getTimeTableRecords');
        action.setParams({
            "selectedCourse": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                                console.log('Fetch Schedule Result:', result);
                console.log('result',result);
                
               // return;
                
                
                // Set dayAndTime for faculty details
                result.lst_Faculties.forEach(function(faculty) {
                      console.log('faculty:', faculty);
                    console.log("Day/Time for faculty details: ", result.lst_Faculties);
                    
                    var facultySchedule = result.lst_Sch.find(function(schedule) {
                        return schedule.dayName === faculty.dayTime;
                         console.log("schedule dayName in faculty:  ", schedule.dayName);
                    });
                     faculty.dayAndTime = faculty.dayAndTime;
                    //if (facultySchedule) {
                      //  faculty.dayAndTime = facultySchedule.dayAndTime;
                    //} else {
                      //  faculty.dayAndTime = ''; // Set to an appropriate default value or leave it empty
                    //}
                });
                
               
                 console.log('result',result);
                
                component.set("v.ScheduleWrpList", result.lst_Sch);
                component.set("v.schoolName", result.schoolName);
                component.set("v.programName", result.programName);
                component.set("v.semName", result.semesterName);
                component.set("v.secName", result.secName);
                component.set("v.acaYear", result.acdYear);
                component.set("v.timeSlot", result.lst_TimeSlot);
                console.log('ScheduleWrpList:', result.lst_Sch);
                console.log('School Name:', result.schoolName);
                console.log('Program Name:', result.programName);
                console.log('Semester Name:', result.semesterName);
                console.log('Section Name:', result.secName);
                console.log('Academic Year:', result.acdYear);
                console.log('Time Slot:', result.lst_TimeSlot);
                var courseMap = {};
                result.lst_Faculties.forEach(function(faculty) {
                    var courseName = faculty.coursename;
                    var courseCode = faculty.courseCode;
                    if (!courseMap[courseCode]) {
                        courseMap[courseCode] = courseName;
                    }
                });
                var uniqueCourseNames = Object.values(courseMap);
                component.set("v.courseNames", uniqueCourseNames);
                                console.log('Unique Course Names:', uniqueCourseNames);
                var facilityMap = {};
                result.lst_Faculties.forEach(function(faculty) {
                    var key = faculty.courseCode;
                    if (!facilityMap[key]) {
                        facilityMap[key] = faculty.facilityName;
                    } else {
                        facilityMap[key] += " / " + faculty.facilityName;
                    }
                });
                var courseFacilityList = [];
                for (var code in facilityMap) {
                    if (facilityMap.hasOwnProperty(code)) {
                        courseFacilityList.push({
                            courseCode: code,
                            facilityName: facilityMap[code]
                        });
                    }
                }
                component.set("v.facilityNames", courseFacilityList);
                                console.log('Facility Names:', courseFacilityList);
                component.set("v.allCourseDetails", result.lst_Faculties);
               // this.updateDayAndTime(component, result.lst_Sch);
                // this.updateDayAndTime(component, result.lst_Faculties);
                
                let slotMap = component.get("v.slotMap") ;
                console.log("Dslot:v.slotMap ", component.get("v.slotMap"));
                //let  lst_Faculties = result.lst_Faculties;
                /*for (var res of lst_Faculties) {
                     console.log("Dslot: Faculty Course Code", res.courseCode);
                    console.log("Dslot: Slot Map Value", slotMap[res.courseCode]);
                    let timeString = slotMap[res.courseCode];
                    if(timeString) {
                        
                        timeString = timeString.replaceAll(':00.000Z', '');
                        res['dayAndTime'] = timeString;
                        
                    }
    
                }*/
                let timePeriodMap = {};
                result.lst_TimeSlot.forEach(function(record) {
                    timePeriodMap[record.sTime] = record.sTime + '-' + record.eTime;
                })
                /*let recordMap = {};
                let opsList = [];
                 result.lst_Faculties.forEach(function(record) {
                      let isSkip = false;
                    result.lst_Sch.forEach(function(schedule) {
                       
                         schedule.lst_Slots.forEach(function(slot, index) {
                             let name = schedule.dayName + '-' + record.courseCode+ '-' + slot.slotname;
                             console.log('name',name);
                             if(!isSkip && record.courseCode  == slot.courseNames && opsList.indexOf(name) <= -1) {
                                 let timeString = slot.slotname.replaceAll(':00.000Z', '');
                                 record.dayAndTime = schedule.dayName + ' ' + timePeriodMap[timeString] || timeString;
                                 opsList.push(name);
                                 isSkip = true;
                             }
                         });
                    });
                    
                });*/
                console.log("Dslot:result ",result);
                console.log("Dslot:result11 ",JSON.parse(JSON.stringify(result.lst_Faculties)));
                component.set("v.profs", JSON.parse(JSON.stringify(result.lst_Faculties)));
                this.processSchedule(component);
            } else {
                console.error('Failed to retrieve data.');
            }
        });
        $A.enqueueAction(action);
    },
   updateDayAndTime: function(component, list) {
    let slotMap = {};
    console.log('slotMap:', slotMap);
    list.forEach(function(item) {
        var dayAndTime = item.dayAndTime;
        console.log('dayAndTime:', dayAndTime);
        item.lst_Slots.forEach(function(slot) {
            slot.dayAndTime = dayAndTime; // Use dayAndTime directly
            console.log('slot.dayAndTime:::', slot.dayAndTime);
            slotMap[slot.courseNames] = slot.slotname;
        });
        console.log("Day/Time:slotMap ", slotMap);
        console.log("Day: ", item.dayName);
        console.log("Start Time: ", item.lst_Slots[0].slotname);
        console.log("End Time: ", item.lst_Slots[item.lst_Slots.length - 1].slotname);
        console.log("Table Details after updating day and time: ", item.lst_Slots);
    });

    component.set("v.slotMap", slotMap);
    component.set("v.ScheduleWrpList", list);
},

    
    fetchUniqueCourseNames: function(component) {
        var action = component.get('c.getDistinctCourseNames');
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var uniqueCourseNames = response.getReturnValue();
                component.set("v.courseNames", uniqueCourseNames);
            } else {
                console.error('Failed to retrieve unique course names.');
            }
        });
        $A.enqueueAction(action);
    },
    filterRows: function(component, selectedCourseName) {
        var allCourseRows = component.get("v.allCourseDetails");
        var filteredCourseDetails = allCourseRows.filter(function(courseDetail) {
            return courseDetail.coursename === selectedCourseName;
        });	
        
        // Set dayAndTime for filtered rows
        filteredCourseDetails.forEach(function(courseDetail) {
            var schedule = '';
            
            component.get("v.timeSlot").map(function(item) {
                if (courseDetail.dayAndTime === item.sTime) {
                    schedule = item.day+': '+ item.sTime + '-' + item.eTime;
                }
            });
            
            if (schedule) {
                courseDetail.dayAndTime = schedule;
            }
        });
        
        component.set("v.profs", filteredCourseDetails);
        console.log("Day/Time for filtered rows: ", JSON.stringify(filteredCourseDetails));
        console.log("197: v.profs: ", component.get("v.profs"));
 setTimeout(function() {
        console.log("197: v.profs after setTimeout: ", component.get("v.profs"));
        try {
            console.log("197: JSON.stringify v.profs after setTimeout: ", JSON.stringify(component.get("v.profs")));
        } catch (e) {
            console.error("Error stringifying v.profs: ", e);
        }
    }, 1000); 
        var courseTable = component.find("courseTable");
        if (filteredCourseDetails.length > 0) {
            $A.util.addClass(courseTable, "slds-show");
            $A.util.removeClass(courseTable, "slds-hide");
        } else {
            $A.util.addClass(courseTable, "slds-hide");
            $A.util.removeClass(courseTable, "slds-show");
        }
    },
    processSchedule: function(component) {
        // Get the list of schedule objects from the Aura attribute
        var scheduleWrapperList = component.get("v.ScheduleWrpList");

        scheduleWrapperList.forEach(day => {
            const slots = day.lst_Slots;
            slots.forEach((slot, index) => {
              // Set sTime to the current slot's time
              slot.sTime = this.formatTime(slot.slotname.substring(0, 5)); // Extract hours and minutes
        
              // Set eTime to the next slot's time, or add an hour if it's the last slot
              if (index < slots.length - 1) {
                slot.eTime = this.formatTime(slots[index + 1].slotname.substring(0, 5)); // Extract hours and minutes
              } else {
                // Add one hour if it's the last slot
                const [hours, minutes] = slot.slotname.substring(0, 5).split(':').map(Number);
                const newHours = (hours + 1) % 24; // Handle hour overflow
                slot.eTime = `${newHours < 10 ? '0' : ''}${newHours}:${minutes < 10 ? '0' : ''}${minutes}`;
              }
            });
          });
        
        // Set the modified list back to the attribute
        component.set("v.ScheduleWrpList", scheduleWrapperList);
    },
        
    formatTime: function(timeString) {
        // Parse the time string directly
        const [hours, minutes] = timeString.split(':').map(Number);
        const formattedHours = hours < 10 ? `0${hours}` : hours;
        const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes;
        return `${formattedHours}:${formattedMinutes}`;
    },

     generateDateOptions: function(component) {
        let today = new Date();
        let options = [];

        // Generate dates for the next 7 days (customize this range as needed)
        for (let i = 0; i < 7; i++) {
            let futureDate = new Date();
            futureDate.setDate(today.getDate() + i);

            // Format date as "25th Sep (Monday)"
            let formattedDate = this.formatDateWithDay(futureDate);

            // Add option to the list
            options.push({
                label: formattedDate,  // Display date with day in the dropdown
                value: formattedDate // Store date in YYYY-MM-DD format
            });
        }

        // Set the date options in the component
        component.set("v.dateOptions", options);
    },

    // Format date to "25th Sep (Monday)"
    formatDateWithDay: function(date) {
        let options = { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric' };
        let dateString = date.toLocaleDateString('en-US', options);
        return dateString;
    },
        
    getScheduleData: function(component) {
        // Sample data for the schedule (you can retrieve this from Apex)
        const data = [
            {
                startTime: '08:30 AM',
                endTime: '09:15 AM',
                subject: 'Math',
                teacher: 'Pythagoras',
                color: '#F0DBC8' // Red
            },
            {
                startTime: '09:30 AM',
                endTime: '10:15 AM',
                subject: 'Physics',
                teacher: 'Nikola Tesla',
                color: '#F0DBC8' // Orange
            },
            {
                startTime: '10:30 AM',
                endTime: '11:15 AM',
                subject: 'Geography',
                teacher: 'Fernand Magellan',
                color: '#F0DBC8' // Yellow
            },
            {
                startTime: '11:30 AM',
                endTime: '12:15 PM',
                subject: 'Chemistry',
                teacher: 'Dmitriy Mendeleev',
                color: '#F0DBC8' // Green
            },
            {
                startTime: '12:30 PM',
                endTime: '01:15 PM',
                subject: 'Biology',
                teacher: 'Charles Darwin',
                color: '#F0DBC8' // Blue
            },
            {
                startTime: '01:30 PM',
                endTime: '02:15 PM',
                subject: 'Math',
                teacher: 'Pythagoras',
                color: '#F0DBC8' // Dark blue
            },
            {
                startTime: '02:30 PM',
                endTime: '03:15 PM',
                subject: 'Physics',
                teacher: 'Nikola Tesla',
                color: '#F0DBC8' // Purple
            },
            {
                startTime: '03:30 PM',
                endTime: '04:15 PM',
                subject: 'Geography',
                teacher: 'Fernand Magellan',
                color: '#F0DBC8' // Gray
            }
        ];
        
        component.set("v.scheduleData", data);
    }
});