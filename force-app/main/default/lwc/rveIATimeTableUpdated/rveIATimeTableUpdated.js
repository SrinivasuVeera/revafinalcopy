import { LightningElement,track,api,wire } from 'lwc';
import searchProgramBatch from '@salesforce/apex/rveFacultyTimeTableController.searchProgramBatch';
import getActiveSemester from '@salesforce/apex/rveFacultyTimeTableController.getActiveSemester';
import getCourses from '@salesforce/apex/rveFacultyTimeTableController.getCourses';
import IATimeTableCreation from '@salesforce/apex/rveFacultyTimeTableController.IATimeTableCreation';
import getSemesterIADates from '@salesforce/apex/rveFacultyTimeTableController.getSemesterWithIADates';
import getExistingIATimeTable from '@salesforce/apex/rveFacultyTimeTableController.getExistingIATimeTable';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'
export default class RveIATimeTableUpdated extends NavigationMixin(LightningElement) {

@track searchKey = '';
@track recordsList;
@api selectedRecordId;
@api selectedValue;
@track message;
@track semesterOptions = [];
@track value;
@track courses=[];
@track coursesDate=[];
@track coursesEndTime = [];
@track coursesStartTime = [];
@ track defaultValue;
@track examDatevalue;
@track endtimeValue
@track starttimeValue
@ track isDisabled=true;
@track activeSemesterValue;
currentDate;
@track iaDates = {
    start : null,
    end   : null
};
_existingLoaded = false;
_pendingLoad = false; 

get IAtypeOptions() {
    return [
        { label: 'IA 1', value: 'IA 1' },
        { label: 'IA 2', value: 'IA 2' }
        
    ];
}
get iaLabelStart() {
return `${this.defaultValue} Start Date`;
}
get iaLabelEnd() {
    return `${this.defaultValue} End Date`;
}

handleIAType(event) {
    this.defaultValue = event.detail.value;
    this.courses = []; 
    this._existingLoaded = false;
    this.pendingLoad = true; 
    this.iaDates = { start:null, end:null };
    const tempValue = this.value; 
this.activeSemesterValue = null;
setTimeout(() => {
    this.activeSemesterValue = tempValue;
}, 1);
    
    if (this.value && this.defaultValue) {
    getSemesterIADates({ semesterId: this.value })
        .then(res => {
            const key = this.defaultValue === 'IA 1' ? 'ia1' : 'ia2';
            this.iaDates.start = res[`${key}Start`];
            this.iaDates.end   = res[`${key}End`];
        })
        .catch(err => console.error(err));
    }         
}

removeRecordOnLookup(event) {
    this.searchKey = "";
    this.selectedValue = null;
    this.selectedRecordId = null;
    this.recordsList = null;
    this.value = null;
    this.courses = [];
    this.defaultValue = null;
    this._existingLoaded = false;
    this.iaDates = { start:null, end:null };
    this.onSeletedRecordUpdate();
}

handleChange(event) {
    this.value = event.target.value;
        this.activeSemesterValue = this.value; 
    this.pendingLoad = true;
}

handleKeyChange(event) {
    const searchKey = event.target.value;
    this.searchKey = searchKey;
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

onRecordSelection(event) {
    this.selectedRecordId = event.target.dataset.key;
    this.selectedValue    = event.target.dataset.name;
    this.searchKey        = "";
    this.value            = null;      
    this.courses          = [];        
    this.defaultValue     = null;
    this._existingLoaded  = false;    
    this.iaDates = { start:null, end:null };
    const passEvent = new CustomEvent('recordselection', {
        detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
    });
    this.dispatchEvent(passEvent);
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

@wire(getCourses, { activeSemester: '$activeSemesterValue' })
wiredCourses({ data, error }) {
    if (data) {
        this.courses = [];
        let k=0;
        for(let i of data)
            {
                const courseInstance = {
                index:k,
                Id: null, 
                CourseId: i.hed__Course__c,
                CourseIdName : i.hed__Course__r.hed__Course_ID__c,
                CourseName: i.hed__Course__r.Name,
                ExamDate: null,
                StartTime:null,
                EndTime:null                    
                }
                k++;
                this.courses.push(courseInstance);
                this.pendingLoad = true; 
            }                
    }
    if (error) {
        
    }
}
        
renderedCallback() {
    if (this._pendingLoad && !this._existingDataLoaded) {
        requestAnimationFrame(() => {                
            if (this.selectedRecordId && this.value && this.defaultValue && this.courses.length > 0) {
                this._existingDataLoaded = true;
                this.loadExistingIATimeTable();
                this._pendingLoad = false;
            }
        });
    }
}

set pendingLoad(value) {
    this._pendingLoad = value;       
    if (value && this.selectedRecordId && this.selectedValue && this.value && this.defaultValue && this.courses.length > 0) {
        this._existingDataLoaded = false;
    }
}

loadExistingIATimeTable() {
    if (!this.selectedValue || !this.value || !this.selectedRecordId || !this.defaultValue || this.courses.length === 0) {
        return;
    }

    getExistingIATimeTable({
        notificationName: this.selectedValue,
        semesterId: this.value,
        programBatch: this.selectedRecordId,
        iaType: this.defaultValue
    })
    .then(result => {
        console.log('Existing IA Time Table:', JSON.stringify(result));

        if (!result || result.length === 0) {
            console.log('No existing timetable found.');
            return;
        }
        let existingMap = {};
        result.forEach(item => {
            existingMap[item.Course__c] = item;
        });
        const today = new Date().toISOString().split('T')[0];
        this.courses = this.courses.map(course => {
            let match = existingMap[course.CourseId];
            if (match) {
                const createdDate = match.CreatedDate.split('T')[0];
                const isCreatedToday = createdDate === today;
                return {
                    ...course,
                    Id: match.Id, 
                    ExamDate: match.hed_Date__c,
                    StartTime: this.formatTime(match.hed_Start_Time__c),
                    EndTime: this.formatTime(match.hed_End_Time__c),
                    isExisting: true,
                    isEditLocked: isCreatedToday 
                };
            }
            return course;
        });

        console.log('Courses after merge:', JSON.stringify(this.courses));
    })
    .catch(error => {
        console.error('Error loading existing IA timetable:', error);
    });
}

formatTime(timeVal) {
    if (timeVal === null || timeVal === undefined) return null;
    if (typeof timeVal === "number") {
        let ms = timeVal;
        let totalSeconds = Math.floor(ms / 1000);
        let hours = Math.floor(totalSeconds / 3600);
        let minutes = Math.floor((totalSeconds % 3600) / 60);
        let seconds = totalSeconds % 60;
        return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    }
    if (typeof timeVal === "string") {
        return timeVal.substring(0, 8); 
    }

    return null;
}

handleStartTimeChange(event){
    const fieldValue = event.target.value;
    const index = parseInt(event.target.dataset.index);        
    this.courses = this.courses.map(e => {
        if(e.index === index) {
            return { ...e, StartTime: fieldValue };
        }
        return e;
    });
}

handleEndTimeChange(event){
    const target= event.target;
    const fieldValue = event.target.value;
    const index = parseInt(event.target.dataset.index);
    
    if(fieldValue < this.courses[index].StartTime)
    {
        event.target.value = this.courses[index].StartTime;
        target.setCustomValidity("End time cannot be earlier than start time.");
        target.reportValidity();
    }
    else if(this.courses[index].StartTime == null){
        
        event.target.setCustomValidity("Please select start time.");
        event.target.reportValidity();
    }
    else{
        event.target.setCustomValidity("");       
        this.courses = this.courses.map(e => {
            if(e.index === index) {
                return { ...e, EndTime: fieldValue };
            }
            return e;
        });
    }
}

handleInputChange(event) {
const target = event.target;
const fieldValue = event.target.value;
const index = parseInt(event.target.dataset.index);
const currentDate = new Date().toISOString().split('T')[0];    
let errorMessage = '';
if (!fieldValue || fieldValue <= currentDate) {
    errorMessage = "Please select a future date.";
}    
else if (this.iaDates.start && this.iaDates.end) {
    const iaStart = this.iaDates.start;
    const iaEnd = this.iaDates.end;

    if (fieldValue < iaStart || fieldValue > iaEnd) {
        errorMessage = `Exam Date must be between ${iaStart} and ${iaEnd} (${this.defaultValue} range).`;
    }
}
if (errorMessage) {
    target.setCustomValidity(errorMessage);
    target.reportValidity();       
} else {       
    target.setCustomValidity("");
    target.reportValidity();
    this.courses = this.courses.map(e => {
        if(e.index === index) {                
            return { ...e, ExamDate: fieldValue };
        }
        return e;
    });
}
}
handleSubmit(event){
event.preventDefault();
let isDataPresent = false;
let hasPartialData = false;

if(this.defaultValue != undefined )
{
    for(let i of this.courses) {
        const hasDate = i.ExamDate != null;
        const hasStartTime = i.StartTime != null;
        const hasEndTime = i.EndTime != null;
        if (hasDate && hasStartTime && hasEndTime) {
            isDataPresent = true;
        }
        const isFilled = hasDate || hasStartTime || hasEndTime;
        const isBlank  = !hasDate || !hasStartTime || !hasEndTime;

        if (isFilled && isBlank) {
            hasPartialData = true;
            break; 
        }
    }
    
    if (hasPartialData) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please complete all three fields (Date, Start Time, End Time) for each row or leave all three fields blank.',
                variant: 'error'
            })
        );
        return; 
    }        
    if(isDataPresent)
        {
            let TimeTableData = this.courses.filter(course => 
                !(course.ExamDate == null && course.StartTime == null && course.EndTime == null)
            );

            let TimeTableDataApex = JSON.stringify(TimeTableData);
            console.log('TimeTableDataApex (filtered): '+TimeTableDataApex);
            IATimeTableCreation({
                notificationName: this.selectedValue,
                semesterActive: this.value,
                programBatch: this.selectedRecordId,
                TimeTableData:TimeTableDataApex,
                Iatypevalue:this.defaultValue
            })
            .then(res=>{
                if(res=='success') {
                        this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: 'IA TimeTable Updated/Created Successfully!', variant: 'success'}));
                        this[NavigationMixin.Navigate]({ type: 'standard__navItemPage', attributes: { apiName: 'Exam_Schedule_Time_Table'}});
                } else {
                    this.showtoast('Something went wrong......');
                }
            })
            .catch(error => {
                console.error('Apex Error:', error);
                this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'Error Occurred While Creation/Update of IA TimeTable: ' + (error.body.message || error.message), variant: 'error' }));
            }) 
        }
    else{
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please provide Date, Start Time, and End Time for at least one course.',
                variant: 'error'
            })
        );
    }
}
else{
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: 'Please Select IA Type',
            variant: 'error'
        })
    );
}
}

showtoast(message){
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        })
    );
}
}