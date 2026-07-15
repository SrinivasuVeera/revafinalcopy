import { LightningElement, wire, track } from 'lwc';
import getExamScheduleItems from '@salesforce/apex/rveFacultyTimeTableController.getExamScheduleItems';
import updateExamScheduleItems from '@salesforce/apex/rveFacultyTimeTableController.updategetExamScheduleItems';
import getIAExamTimeTable from '@salesforce/apex/rveFacultyTimeTableController.getIAExamTimeTable';
import getSemesterIADates from '@salesforce/apex/rveFacultyTimeTableController.getSemesterWithIADates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ExamScheduleDisplay extends LightningElement {
    @track examScheduleItems=[];
    isEditing = false;
    @track showData = false;
    co;
    feedata = [];
    courseData;
    studentContacts;
    examtimetabledata;
    @track lineItemData;
    enrollProgramBatchId;
    activeSemester;
    ProgramBatchId;
    activeSemesterId;
    @track courseId;
    @track coursesName;
    @track courses;
    @track timeOptions = [];
    @track coursesDate = [];
    @track coursesStartTime = [];
    @track coursesEndTime = [];
    @track coursesEndTimeDetails;
    @track coursesStartTimeDetails;
    @track coursesDateDetails=[];
    @track courseData=[]
    fiterdata = [];
    isEdit = true;
    wiredResult;
     @track iaDates = { 
        start: null,
        end: null
    };
    currentSemesterId = null;
    currentIAtype = null;

     @wire(getExamScheduleItems)
    wiredExamSchedule(result) {

        this.wiredResult = result;
        if (result.data) {
            this.examScheduleItems = []; 
            let k = 0; 
             const today = new Date().toISOString().split('T')[0];            
           
            if (result.data.length > 0) {
                const firstItem = result.data[0]; 
                this.currentSemesterId = firstItem.Reva_Exam_Notification__r.Rve_Semester__c;
                this.currentIAtype = firstItem.Reva_Exam_Notification__r.hed_IA_Type__c;
            }            
            for (let i of result.data) {
                const createdDate = i.CreatedDate ? i.CreatedDate.split('T')[0] : null;
                const isCreatedToday = createdDate === today;
                        
                const course = {
                    index: k,
                    Id:i.Id,
                    hed_Start_Time__c: this.formatTime(i.hed_Start_Time__c),
                    hed_End_Time__c: this.formatTime(i.hed_End_Time__c),
                    startTimePreviousValue:this.formatTime(i.hed_Start_Time__c),
                    EndTimePreviousValue:this.formatTime(i.hed_End_Time__c),
                    hed_Date__c:i.hed_Date__c,
                    DatePreviousValue:i.hed_Date__c,
                    CourseId: i.Course__r.hed__Course_ID__c,
                    Name: i.Name,
                    IaType:i.Reva_Exam_Notification__r.hed_IA_Type__c,
                    isEditLocked: isCreatedToday
                };
                
                const courseExists = this.examScheduleItems.some(item => item.Id === course.Id);
                if (!courseExists) {
                    this.examScheduleItems.push(course);
                    k++; 
                }
            }
            
            if (this.currentSemesterId && this.currentIAtype) {
                getSemesterIADates({ semesterId: this.currentSemesterId })
                    .then(res => {
                        const key = this.currentIAtype === 'IA 1' ? 'ia1' : 'ia2';
                        this.iaDates.start = res[`${key}Start`];
                        this.iaDates.end   = res[`${key}End`];
                    })
                    .catch(err => console.error('Error fetching IA dates:', err));
            }
            if (this.examScheduleItems.length === 0) {
                this.isEdit = true;
            }
            else {
                this.isEdit = false;
            }

        } else if (result.error) {
            console.error('Error fetching exam schedule items:', result.error);
        }
    }

    @wire(getIAExamTimeTable)
    getIAExamTimeTables({ data, error }) {
        if (data) {
            this.examtimetabledata = data;

                let k = 0;
             for (let i of this.examtimetabledata) {

                        const course = {
                            index: k,
                            Id:i.Id,
                            hed_Start_Time__c: this.formatTime(i.hed_Start_Time__c),
                            hed_End_Time__c: this.formatTime(i.hed_End_Time__c),
                            startTimePreviousValue:this.formatTime(i.hed_Start_Time__c),
                            EndTimePreviousValue:this.formatTime(i.hed_End_Time__c),
                            hed_Date__c:i.hed_Date__c,
                            DatePreviousValue:i.hed_Date__c,
                            CourseId: i.Course__r.hed__Course_ID__c,
                            Name: i.Name,
                            IaType:i.Reva_Exam_Notification__r.hed_IA_Type__c
                        };
                        k++;
                        this.courseData.push(course);
                    }
                }

                if (this.courseData != null && this.courseData.length > 0) {
                    this.showData = true;

                }
                else {
                    this.showData = false;
                }
        }

    connectedCallback() {        
        this.initializeTimeOptions();
    }

    // Format time for dropdown in "12:45:00 AM" format
    formatTimeForDropdown(hours, minutes) {
        const period = hours < 12 ? 'AM' : 'PM';
        const formattedHours = hours % 12 || 12; // Convert 0 to 12
        const formattedMinutes = String(minutes).padStart(2, '0');
        return `${formattedHours}:${formattedMinutes}:00 ${period}`;
    }
    initializeTimeOptions() {
        for (let hours = 0; hours < 24; hours++) {
            for (let minutes = 0; minutes < 60; minutes += 15) {
                const formattedTime = this.formatTimeForDropdown(hours, minutes);
                this.timeOptions.push({ label: formattedTime, value: formattedTime });
            }
        }
    }

    handleEditClick() {
        this.isEditing = true;
    }

    handleSaveClick() {

    
                let updatedtimelineitem = [];

                for(let i of this.examScheduleItems)
                    {
                        if(i.hed_Date__c!=null && i.hed_Start_Time__c!=null && i.hed_End_Time__c!=null)
                        {
                        const newInstance = {
                            Id:i.Id,
                            StartTime:i.hed_Start_Time__c,
                            EndTime:i.hed_End_Time__c,
                            LineItemDate:i.hed_Date__c
                        }
                        updatedtimelineitem.push(newInstance);
                        }
                        else{
                            this.dispatchEvent(
                              new ShowToastEvent({
                              title: 'Success',
                              message: 'Please provide value for required fields',
                              variant: 'success'

                            })
                );
                        }
            
                    }

                if(updatedtimelineitem.length>0)
                {

                let SerializedTimeTableItem = JSON.stringify(updatedtimelineitem);
                console.log('SerializedTimeTableItem=> '+SerializedTimeTableItem);
                updateExamScheduleItems({JsonString:SerializedTimeTableItem})
                .then(result => {                
                console.log('Update successful:', result);

                this.isEditing = false;
                this.refreshData();

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'TimeTable Updated Successfully!!',
                        variant: 'success'

                    })
                );

                for(let i of this.examScheduleItems)
                    {
                        i.startTimePreviousValue = i.hed_Start_Time__c;
                        i.EndTimePreviousValue = i.hed_End_Time__c;
                        i.DatePreviousValue = i.hed_Date__c;
                    }

            }).catch(error => {               
                console.error('Error updating exam schedule items:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occurred While Updation of TimeTable',
                        variant: 'error'
                    })
                );
            });
                }

            
    }

    parseTime(timeStr) {
        const timeParts = timeStr.match(/(\d+):(\d+):(\d+) (AM|PM)/);
        if (!timeParts) {
            throw new Error('Invalid time format');
        }
        let [_, hours, minutes, seconds, period] = timeParts;
        hours = parseInt(hours, 10);
        minutes = parseInt(minutes, 10);
        seconds = parseInt(seconds, 10);
    
        if (period === 'PM' && hours < 12) {
            hours += 12;
        }
        if (period === 'AM' && hours === 12) {
            hours = 0;
        }
    
        const date = new Date();
        date.setHours(hours, minutes, seconds, 0);
    
        return date;
    }

    get isButtonDisabled() {
        let isDisabled = true; // Initially set the button as disabled
    
        const rows = this.template.querySelectorAll('tr'); // Select all table rows
        const currentDate = new Date().toISOString().split('T')[0]; // Get current date
    
        for (let i = 0; i < rows.length; i++) {
            const inputs = rows[i].querySelectorAll('lightning-input, lightning-combobox'); // Select all input and combobox elements within the row
            let startTime = null;
            let endTime = null;
            let date = null;
    
            for (let j = 0; j < inputs.length; j++) {
                const input = inputs[j];
    
                if (!input.value) {
                    return true; 
                } else {                  
                    if (input.name === 'date') {
                        date = input.value;
                        if (!input.value || input.value <= currentDate) {
                            input.setCustomValidity("Please select a future date.");
                            input.reportValidity();
                            return true; 
                        } else {
                            input.setCustomValidity("");
                        }
                    }
    
                    if (input.name === 'hed_Start_Time__c') {
                        startTime = input.value;
                    }
                    if (input.name === 'hed_End_Time__c') {
                        endTime = input.value;
                    }
                }
            
            if (startTime && endTime) {
                const startDateTime = this.parseTime(startTime);
                const endDateTime = this.parseTime(endTime);
    
                if (endDateTime < startDateTime) {                
                    input.setCustomValidity("End time cannot be earlier than start time.");
                    input.reportValidity();
                    return true; 
                } else {                 
                    input.setCustomValidity("");
                }
            }
        }
        }
    
        return false; 
    }

    refreshData() {
        console.log('refreshDataCalled');
        return refreshApex(this.wiredResult);

    }

    handleCancelClick() {       
        this.isEditing = false;
        if(this.examScheduleItems.length>0){
          for(let i of this.examScheduleItems)
            {
                console.log('StartTime=> '+i.hed_Start_Time__c+' PreviousValue=> '+i.startTimePreviousValue);
                console.log('EndTime=> '+i.hed_End_Time__c+' PreviousValue=> '+i.EndTimePreviousValue);
                console.log('Date=> '+i.hed_Date__c+' PreviousValue=> '+i.DatePreviousValue);
                i.hed_Start_Time__c = i.startTimePreviousValue!=null?i.startTimePreviousValue:i.hed_Start_Time__c;
                i.hed_End_Time__c = i.EndTimePreviousValue!=null?i.EndTimePreviousValue:i.hed_End_Time__c;
                i.hed_Date__c = i.DatePreviousValue!=null?i.DatePreviousValue:i.hed_Date__c;
            }
        }
       //  this.refreshData();
        // this.wiredExamSchedule({data: this.examScheduleItems });
    }

    formatTime(milliseconds) {
        const date = new Date(milliseconds);
       
        const istOffset = 5 * 60 * 60 * 1000 + 30 * 60 * 1000;
        const istTime = new Date(date.getTime() - istOffset);
        const options = { timeZone: 'Asia/Kolkata', hour12: true };
        const formattedTime = istTime.toLocaleTimeString('en-US', options);

        return formattedTime;
    }
   
    
    handleDateChange(event) {
        const target = event.target;
        const value = event.target.value;
        const index = parseInt(event.target.dataset.index);
        const currentDate = new Date().toISOString().split('T')[0];
        let errorMessage = '';
        if (!value || value <= currentDate) {
            errorMessage = "Exam Date must be a future date.";
        }
        else if (this.iaDates.start && this.iaDates.end) {
            const iaStart = this.iaDates.start;
            const iaEnd = this.iaDates.end;

            if (value < iaStart || value > iaEnd) {
                errorMessage = `Exam Date must be between ${iaStart} and ${iaEnd}.`;
            }
        }

        if (errorMessage) {
            target.setCustomValidity(errorMessage);
            target.reportValidity();           
        } else {
            target.setCustomValidity("");
            target.reportValidity();
            this.examScheduleItems.forEach(e => {
                if(e.index == index) {
                    if(e.DatePreviousValue==null) {
                        e.DatePreviousValue = e.hed_Date__c;
                    }
                    e.hed_Date__c = value;
                    console.log('Date=> '+e.hed_Date__c+' PreviousValue=> '+e.DatePreviousValue)
                }
            });
        }
    }

    handleStartTimeChange(event) {
        let value = event.target.value;
        let index = parseInt(event.target.dataset.index);

        this.examScheduleItems.forEach(e => {
        if(e.index == index) {
            if(e.startTimePreviousValue==null)
                {
                    e.startTimePreviousValue = e.hed_Start_Time__c;

                }
            e.hed_Start_Time__c = value;

        }
        })
    }

    handleEndTimeChange(event) {

        const value = event.target.value;
        const index = parseInt(event.target.dataset.index);

        this.examScheduleItems.forEach(e => {
        if(e.index == index) {
            if(e.EndTimePreviousValue==null)
                {
                    e.EndTimePreviousValue = e.hed_End_Time__c;

                }
            e.hed_End_Time__c = value;
        }
        })
    }
}