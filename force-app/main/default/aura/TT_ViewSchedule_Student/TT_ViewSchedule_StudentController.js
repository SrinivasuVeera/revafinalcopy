({
        doInit: function(component, event, helper) {
            let deviceType;

           // Check the window width to determine the device type
        if (window.innerWidth <= 768) {
            deviceType = 'mobile';
        } else {
            deviceType = 'desktop';
        }

        component.set("v.deviceType", deviceType);
            // console.log("Controller - doInit");
            helper.fetchUniqueCourseNames(component);
            helper.fetchSchedule(component);
            helper.generateDateOptions(component);
            helper.getScheduleData(component);
            let isVisible = component.get("v.isVisible");
            component.set("v.isVisible", !isVisible);

        },
  
    convertToDate: function(component, event, helper,timeStr) {
    const [time, period] = timeStr.split(' ');
    let [hour, minute] = time.split(':');
    hour = parseInt(hour, 10);
    minute = parseInt(minute, 10);
    
    if (period === 'PM' && hour < 12) {
        hour += 12; // Convert PM hour to 24-hour format
    } else if (period === 'AM' && hour === 12) {
        hour = 0; // Midnight case
    }

    const date = new Date();
    date.setHours(hour, minute, 0); // Set hours and minutes
    return date;
},


    
        handleDateChange: function(component, event, helper) {
        component.set("v.openMobile",true);
    let selectedDay = event.getSource().get("v.value");
    // console.log('Sekectedday', selectedDay);
    
    // Extract the day from the selected value (e.g., "Monday")
    let day = selectedDay.split(",")[0];
    // console.log('day', day);
    
    // Fetch the full list of courses (assuming it's stored in an attribute called "v.courseList")
    let courseList = component.get("v.profs");
    // Log the raw data directly without concatenation
    // console.log('21=> courseList: ', courseList);
    
    // Attempt to stringify the data for a structured view
    try {
        // console.log('21=> JSON.stringify courseList: ', JSON.stringify(courseList));
    } catch (e) {
        console.error('Error stringifying courseList: ', e);
    }

    // Filter the courses based on the selected day
    let filteredCourses = courseList.filter(course => {
        return course.dayAndTime.toLowerCase().includes(day.toLowerCase());
    });

    // console.log('Filtered Records => ', filteredCourses);

    // Use a Set to filter unique records by courseCode
    let uniqueCourseCodes = new Set();
    let uniqueFilteredCourses = filteredCourses.filter(course => {
        // Check if the courseCode already exists in the Set
        if (!uniqueCourseCodes.has(course.courseCode)) {
            // If not, add the courseCode to the Set and keep this course
            uniqueCourseCodes.add(course.courseCode);
            return true;
        }
        // If the courseCode is already in the Set, filter it out
        return false;
    });

    // console.log('Unique Filtered Records => ', uniqueFilteredCourses);

    let finallist = []; // Ensure finallist is initialized

uniqueFilteredCourses.forEach(course => {
    let timeMatch = course.dayAndTime.match(/\(([^)]+)\)/); // Matches content within parentheses
    // console.log('timematch=> ', timeMatch);

    if (timeMatch) {
        let timeRange = timeMatch[1].trim(); // Get the matched string and trim whitespace
        let times = timeRange.split('-').map(t => t.trim()); // Split and trim spaces
        // console.log('times=> ', times);

        if (times.length === 2) {
            const tempstartTime = times[0]; // "09:25"
            const tempendTime = times[1]; // "10:20"
            let startTime = "";
            let endTime = "";

            try {
                let [hour, minute] = tempstartTime.split(':');
                hour = parseInt(hour, 10);
                let period = hour >= 12 ? 'PM' : 'AM';
                hour = hour % 12 || 12; // convert 0 hour to 12
                startTime = `${String(hour).padStart(2, '0')}:${minute} ${period}`;
                // console.log('startTime=> ', startTime);
            } catch (e) {
                console.error('Error processing startTime: ', e);
            }

            try {
                let [hour, minute] = tempendTime.split(':');
                hour = parseInt(hour, 10);
                let period = hour >= 12 ? 'PM' : 'AM';
                hour = hour % 12 || 12; // convert 0 hour to 12
                endTime = `${String(hour).padStart(2, '0')}:${minute} ${period}`;
                // console.log('endTime=> ', endTime);
            } catch (e) {
                console.error('Error processing endTime: ', e);
            }

            // Only push if both startTime and endTime have been set
            if (startTime && endTime) {
                try {
                    const record = {
                        courseCode: course.courseCode,
                        coursename: course.coursename,
                        coursoffsch: course.coursoffsch,
                        startTime: startTime || '09:45 AM', // Fallback if undefined
                        endTime: endTime || '09:45 AM'
                    };
                    // console.log('record=> ', record);
                    finallist.push(record); // Add the new record to the final list
                } catch (e) {
                    console.error('Error stringifying finalist: ', e);
                }
            } else {
                console.error("Start or end time is not defined for course:", course);
            }
        } else {
            console.error("Time range format is incorrect:", times); // Log if format is unexpected
        }
    } else {
        console.error("No time match found in dayAndTime:", course.dayAndTime); // Log if time is not found
    }
});

component.set("v.courseData",finallist);
// Log the final list to check the output
// console.log("Final List:", finallist);
//// console.log("Final List (JSON):", JSON.stringify(finallist, null, 2));

    // Sort finallist based on startTime
finallist.sort((a, b) => {
    const startA = a.startTime;
    const startB = b.startTime;
    const timeTo24Hour = (timeStr) => {
        let [time, period] = timeStr.split(' ');
        let [hour, minute] = time.split(':').map(num => parseInt(num, 10));
        
        if (period === 'PM' && hour < 12) {
            hour += 12; // Convert PM hour to 24-hour format
        } else if (period === 'AM' && hour === 12) {
            hour = 0; // Midnight case
        }

        return hour * 60 + minute; // Convert time to total minutes for comparison
    };

    // Compare start times in total minutes
    return timeTo24Hour(startA) - timeTo24Hour(startB);
});
// console.log("Sorted List:", finallist);


    // console.log('Updated Course List: ', JSON.stringify(finallist, null, 2));

    // Set the filtered list to an attribute (e.g., "v.filteredCourseList")
    component.set('v.filteredCourseList', filteredCourses);
    // console.log("FilerRecords=> " + component.get("v.filteredCourseList"));

    const selectedDate = event.getParam('value');
    component.set("v.selectedDate", selectedDate);
},

handleCourseSelection: function(component, event, helper) {
    // console.log("Controller - handleCourseSelection");
    var selectedCourseName = event.getSource().get("v.value");
    // console.log("Selected Course: ", selectedCourseName);
    component.set("v.selectedCourseName", selectedCourseName);
    
    if (selectedCourseName) {
        helper.filterRows(component, selectedCourseName);
    } else {
        var courseTable = component.find("courseTable");
        $A.util.addClass(courseTable, "slds-hide");
        $A.util.removeClass(courseTable, "slds-show");
    }
},

        
    })