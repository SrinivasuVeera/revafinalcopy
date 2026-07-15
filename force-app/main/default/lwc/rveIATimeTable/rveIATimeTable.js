import { LightningElement, track, api, wire } from 'lwc';
import searchProgramBatch from '@salesforce/apex/rveFacultyTimeTableController.searchProgramBatch';
import getActiveSemester from '@salesforce/apex/rveFacultyTimeTableController.getActiveSemester';
import getCourses from '@salesforce/apex/rveFacultyTimeTableController.getCourses';
import IAnotification from '@salesforce/apex/rveFacultyTimeTableController.IAnotification';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'

export default class RveIATimeTable extends NavigationMixin(LightningElement) {


    @track searchKey = '';
    @track recordsList;
    @api selectedRecordId;
    @api selectedValue;
    @track message;
    @track semesterOptions = [];
    @track value;
    courses;
    @track coursesDate=[];
    @track coursesEndTime = [];
    @track coursesStartTime = [];
    @ track defaultValue;
    @track examDatevalue;
    @track endtimeValue
    @track starttimeValue
    @ track isDisabled=true;
    currentDate;

    coursesDateDetails;
    coursesStartTimeDetails;
    coursesEndTimeDetails;


    onLeave(event) {
        setTimeout(() => {
            this.searchKey = "";
            this.recordsList = null;
        }, 300);
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        this.onSeletedRecordUpdate();
    }


    handleKeyChange(event) {
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        this.getLookupResult();
    }

    removeRecordOnLookup(event) {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.value = null;
        this.coursesDateDetails=null;
        this.coursesStartTimeDetails=null;
        this.coursesEndTimeDetails=null;
        this.defaultValue = null;
        //this.isDisabled = true;
        this.onSeletedRecordUpdate();
    }

    getLookupResult() {
        searchProgramBatch({ searchKey: this.searchKey })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
    }

    onSeletedRecordUpdate() {
        if (this.selectedRecordId && this.selectedValue) {
            const selectedProgram = this.recordsList.find(route => route.Id === this.selectedRecordId)
        }

        const passEventr = new CustomEvent('recordselection', {
            detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
        });
        this.dispatchEvent(passEventr);
    }

    @wire(getActiveSemester, { selectedValue: '$selectedRecordId' })
    wiredSemester({ data, error }) {
        if (data) {

            this.semesterOptions = data.map(hed__Term__c => ({
                label: hed__Term__c.Name,
                value: hed__Term__c.Id

            }));
        }

        if (error) {
        }
    }

    @wire(getCourses, { activeSemester: '$value' })
    wiredCourses({ data, error }) {
        if (data) {
            this.courses = data;
        }
        if (error) {
        }
    }
    handleChange(event) {
        this.value = event.target.value;
    }

    //defaultValue = 'None';
    get IAtypeOptions() {
        return [
            { label: 'IA 1', value: 'IA 1' },
            { label: 'IA 2', value: 'IA 2' }
           
        ];
    }

    handleIAType(event) {
        this.defaultValue = event.detail.value;
    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        const index = parseInt(event.target.dataset.index);
         this.examDatevalue = event.target.value;

        JSON.stringify(this.courses[index].hed__Course__r.Id);
        this.courseId = this.courses[index].hed__Course__r.Id;

        this.coursesName = this.courses[index].hed__Course__r.Name;
        let existingIndex = this.coursesDate.findIndex(item => item.index === index);
        if (existingIndex !== -1) {
              // Update the existing object at the found index
              this.coursesDate[existingIndex].examdate = this.examDatevalue;
         } else {
            this.coursesDate.push({
                index:index,
                recordIdvalue: this.courseId,
                courseName:this.coursesName,
                examdate: this.examDatevalue
            });
         }

        this.coursesDateDetails = JSON.stringify(this.coursesDate);
    }

    handleStartTimeChange(event){
    
        this.starttimeValue =  event.target.value 
        const index = parseInt(event.target.dataset.index);
       let existingIndex = this.coursesStartTime.findIndex(item => item.index === index);
        if (existingIndex !== -1) {
              // Update the existing object at the found index
              this.coursesDate[existingIndex].examdate = this.examDatevalue;
         } else {
            this.coursesStartTime.push({
                index:index,
                recordIdvalue: this.courseId,
                courseName:this.coursesName,
                starttime: this.starttimeValue
            })
         }
        this.coursesStartTimeDetails = JSON.stringify(this.coursesStartTime);

    }

    handleEndTimeChange(event){
       const index = event.target.dataset.index;
        this.endtimeValue = event.target.value 
        let existingIndex = this.coursesStartTime.findIndex(item => item.index === index);
        if (existingIndex !== -1) {
              // Update the existing object at the found index
              this.coursesDate[existingIndex].examdate = this.examDatevalue;
         } else {
            this.coursesEndTime.push({
                 index:index,
                recordIdvalue: this.courseId,
                courseName:this.coursesName,
                endtime: this.endtimeValue
            })
         }
        this.coursesEndTimeDetails = JSON.stringify(this.coursesEndTime);

    }

   get isButtonDisabled() {
    let isDisabled = true; // Initially set the button as disabled

    // Check if the lookup field is empty
    if (this.selectedRecordId == null || this.selectedValue == null) {
        return true;
    }
    const rows = this.template.querySelectorAll('tr'); // Selects all table rows
    const currentDate = new Date().toISOString().split('T')[0]; // Get current date

    // Iterate through each row
    for (let i = 0; i < rows.length; i++) {
        const inputs = rows[i].querySelectorAll('lightning-input'); // Selects all lightning-input elements within the row
        let startTime = null; // Initialize start time variable

        // Iterate through each input field in the row
        for (let j = 0; j < inputs.length; j++) {
            const input = inputs[j];

            // Check if any input field is empty
            if (!input.value) {
                this.isDisabled = true; // Keep the button disabled
                return isDisabled; // No need to check further, exit the loop
            } else {
                this.isDisabled = false; // Enable the button if all input fields are filled

                // Date Validation when checking for input value
                if (input.name === 'date') {
                    if (!input.value || input.value <= currentDate) {
                        // Prevent the user from selecting a previous date or if no value is present
                        input.setCustomValidity("Please select a future date.");
                        input.reportValidity();
                        return true; // Disable button if date is not a future date or no value is present
                    } else {
                        // Clear any previous validation message for date field
                        input.setCustomValidity("");
                    }
                }

                // Store the start time value
                if (input.name === 'startTime') {
                    startTime = input.value;
                }

                // End Time Validation when checking for input value
                if (input.name === 'endTime') {
                    const endTime = input.value;
                    
                    if (startTime && endTime && endTime < startTime) {
                        // Prevent the user from entering an end time earlier than start time
                        input.setCustomValidity("End time cannot be earlier than start time.");
                        input.reportValidity();
                        return true; // Disable button if end time is earlier than start time
                    } else {
                        // Clear any previous validation message for end time field
                        input.setCustomValidity("");
                    }
                }
            }
        }
    }

    return this.isDisabled;
}

    /* IA Notification and Exam Time Table Line Item Creation */
    handleSubmit() {
        IAnotification({
            notificationName: this.selectedValue,
            semesterActive: this.value,
            programBatch: this.selectedRecordId,
            Iatypevalue:this.defaultValue,
            examStartTime:this.coursesStartTimeDetails,
            examEndTime:this.coursesEndTimeDetails,
            examDate:this.coursesDateDetails
        }
        ).then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'IA TimeTable Created Successfully!!',
                    variant: 'success'

                })
            );

            //navigate to exam schedule time table
            this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Exam_Schedule_Time_Table'
            }
        })

        })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occurred While Creation of IA TimeTable',
                        variant: 'error'
                    })
                );
            }) 
    }   
}