import { LightningElement, track,wire,api } from 'lwc';
import getSchedulesByEntryDate from '@salesforce/apex/ProfessorClassAdjustmentController.getSchedulesByEntryDate';
import getProfessorsBySameSection from '@salesforce/apex/ProfessorClassAdjustmentController.getProfessorsBySameSection';
import getProfessorsOtherSection from '@salesforce/apex/ProfessorClassAdjustmentController.getProfessorsOtherSection';
import getProfessorsEntireSchool from '@salesforce/apex/ProfessorClassAdjustmentController.getProfessorsEntireSchool';
import ClassAdjustmentInsert from '@salesforce/apex/ProfessorClassAdjustmentController.ClassAdjustmentInsert';
import getClassAdjustments from '@salesforce/apex/ProfessorClassAdjustmentController.getClassAdjustments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name';
export default class CourseOfferingSchedule extends LightningElement {
    @api recordId;
    @track selectedDate;
    @track endDate;
    @track schedules = [];
    @track error;
    @track currentUserUsername;
    @track currentUserUserProfileName;
    @track proceed = true;
    classAdjustments = [];
    @track message = true;
    columns = [
        { label: 'Class Adjustment Name', fieldName: 'name' },
        { label: 'Course Offering Section', fieldName: 'courseOfferingSchedule' },
        { label: 'Requested Professor', fieldName: 'professor' },
        { label: 'Course Offering Name', fieldName: 'courseOfferingName' },
        { label: 'Status', fieldName: 'status' },
    ];

    availabilityOptions = [
        { label: 'Same Section Available Professor', value: 'same_section' },
        { label: 'Other Section Available Professor', value: 'other_section' },
        { label: 'Entire School Available Professor', value: 'entire_school' }
    ];

    minDate = new Date().toISOString().split('T')[0];
    handleDateChange(event) {
        this.selectedDate = event.target.value;
         if (this.selectedDate < this.minDate) {
            this.showToast('Error', 'Start Date cannot be in the past.', 'error');
            this.selectedDate = null;
        }
    }

    handleEndDateChange(event){
        this.endDate = event.target.value;
        if (this.endDate < this.selectedDate) {
            this.showToast('Error', 'End Date cannot be before Start Date.', 'error');
            this.endDate = null;
        }
    }
 handleAvailabilityChange(event) {
        this.selectedAvailability = event.target.value;
    }
     showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    fetchSchedules() {
        console.log('fetchSchedules called');
        console.log('availabilityOptions:'+this.selectedAvailability);
        if (!this.selectedDate || !this.endDate) {
            this.error = 'Please select valid dates.';
            this.schedules = [];
            this.classAdjustments = [];
            return;
        }else if(!this.selectedAvailability){
            this.error = 'Please select Professor Type';
            this.schedules = [];
            this.classAdjustments = [];
            return;
        }
        this.message = false;
        this.error = null;
    
        getSchedulesByEntryDate({ scheduleDate: this.selectedDate, endDate: this.endDate, currentUserId: USER_ID })
            .then((result) => {
                // Initialize schedules
                this.schedules = result.map((schedule) => ({
                    ...schedule,
                    formattedStartTime: this.formatTime(schedule.hed__Start_Time__c),
                    formattedEndTime: this.formatTime(schedule.hed__End_Time__c),
                    professorOptions: [],
                    otherSectionProfessorOptions: [],
                    EntireSemisterProfessor: [],
                    selectedProfessor: null,    
                    selectedOtherSectionProfessor: null,
                    selectedEntireSemProfessor: null,
                    showProfessorOptions: false,
                    showOtherSectionOptions: false,
                    showEntireSemOptions: false,
                    category: schedule.hed__Course_Offering__r?.Category__c 
                }));
         
                const schedulePromises = this.schedules.map((schedule) => {
                    let startTime = schedule.hed__Start_Time__c;
                    let endTime = schedule.hed__End_Time__c;
    
                    if (typeof startTime === 'string') {
                        startTime = this.convertToApexTime(startTime); // Ensure proper conversion
                    }
    
                    if (typeof endTime === 'string') {
                        endTime = this.convertToApexTime(endTime); // Ensure proper conversion
                    }
    
                    // Fetch professors for the same section
                    const sameSectionPromise = getProfessorsBySameSection({
                        scheduleDate: this.selectedDate,
                        endDate: this.endDate,
                        currentUserId: USER_ID,
                        courseOfferingSection: schedule.Course_Offering_Section__c,
                        semisterId: schedule.Section__c,
                        startTime: startTime,
                        endTime: endTime,
                        courseId: schedule.Course_ID__c,
                    }).then((professorMap) => {
                        this.schedules = this.schedules.map((sch) => {
                            if (sch.Id === schedule.Id) {
                                sch.professorOptions = (professorMap[schedule.Course_Offering_Section__c] || []).map((professor) => ({
                                    label: professor.Name,
                                    value: professor.Id,
                                }));
                                // Show professor options if available
                               //sch.showProfessorOptions = sch.professorOptions.length > 0;
                            
                               console.log(' sch.category:'+ sch.category);
                               if (
                                (sch.category === 'Hardcore Course' ||
                                sch.category === 'Hardcore Integrated Course' ||
                                sch.category === 'Mandatory Course') && this.selectedAvailability === 'same_section'
                            ) {
                                sch.showProfessorOptions = sch.professorOptions.length > 0;
                                this.message = false;
                            } else {
                                sch.showProfessorOptions = false; // Explicitly hide options for other categories
                                this.message = true;
                            }
                            }
                            return sch;
                        });
                    });
    
                    // Fetch professors for other sections
                    const otherSectionPromise = getProfessorsOtherSection({
                        scheduleDate: this.selectedDate,
                        endDate: this.endDate,
                        currentUserId: USER_ID,
                        courseOfferingSection: schedule.Course_Offering_Section__c,
                        semisterId: schedule.Section__c,
                        startTime: startTime,
                        endTime: endTime,
                        courseId: schedule.Course_ID__c,
                    }).then((professorMap) => {
                        this.schedules = this.schedules.map((sch) => {
                            if (sch.Id === schedule.Id) {
                                sch.otherSectionProfessorOptions = (professorMap[schedule.Course_ID__c] || []).map((professor) => ({
                                    label: professor.Name,
                                    value: professor.Id,
                                }));
                               
                               // Show other section professor options if available
                               if ( //!sch.showProfessorOptions
                                 this.selectedAvailability === 'other_section' &&
                                (sch.category === 'Hardcore Course' ||
                                sch.category === 'Hardcore Integrated Course' ||
                                sch.category === 'Mandatory Course') 
                               ) {
                                sch.showOtherSectionOptions = sch.otherSectionProfessorOptions.length > 0;
                                //this.message = false;
                                } else {
                                    sch.showOtherSectionOptions = false; // Explicitly hide options for other categories
                                    this.message = true;
                                }

                            }
                            return sch;
                        });
                    });
    
                    // Fetch professors for entire semester
                    const EntireSemisterPromise = getProfessorsEntireSchool({
                        scheduleDate: this.selectedDate,
                        endDate: this.endDate,
                        currentUserId: USER_ID,
                        courseOfferingSection: schedule.Course_Offering_Section__c,
                        semisterId: schedule.Section__c,
                        startTime: startTime,
                        endTime: endTime,
                        courseId: schedule.Course_ID__c,
                        category: schedule.hed__Course_Offering__r?.Category__c 
                    }).then((professorMap) => {
                        this.schedules = this.schedules.map((sch) => {
                            if (sch.Id === schedule.Id) {
                                sch.EntireSemisterProfessor = (professorMap[schedule.School__c] || []).map((professor) => ({
                                    label: professor.Name,
                                    value: professor.Id,
                                }));
                                // Show entire semester professor options if available
                               if (!sch.showProfessorOptions && !sch.showOtherSectionOptions && this.selectedAvailability ==='entire_school' ) {
                                    sch.showEntireSemOptions = sch.EntireSemisterProfessor.length > 0;
                                    //this.message = false;
                               }else{
                                this.message = true;
                               }
                            }
                            return sch;
                        });
                    });
    
                    return Promise.all([sameSectionPromise, otherSectionPromise, EntireSemisterPromise]);
                });
    
                return Promise.all(schedulePromises);
            })
            .then(() => {
                // After schedules are fetched, fetch class adjustments
                this.fetchClassAdjustments();
            })
            .catch((error) => {
                console.error('Error fetching schedules:', error);
                this.error = 'Error fetching schedules: ' + error.body.message;
            });
    }
    
    fetchClassAdjustments() {
        getClassAdjustments({
            scheduleDate: this.selectedDate,
            endDate: this.endDate,
            currentUserId: USER_ID
        })
        .then((result) => {
            console.log('Class Adjustments:', result); // Check data
            this.classAdjustments = result.map(item => ({
                id: item.Id,
                name: item.Name,
                courseOfferingSchedule: item.Course_Offering_Schedule__r?.Course_Offering_Section__c,
                professor: item.Requested_Professor__r?.Name,
                courseOfferingName: item.Course_Offering_Schedule__r?.hed__Course_Offering__r?.Name,
                status: item.Status__c
            }));
        })
            .catch((error) => {
                console.error('Error fetching class adjustments:', error);
                this.error = 'Error fetching class adjustments: ' + error.body.message;
            });
    }   
    // Utility method to handle time strings
    convertToApexTime(timeString) {
        if (!timeString) {
            return null;
        }
        const [hours, minutes] = timeString.split(':');
        return Time.createInstance(parseInt(hours), parseInt(minutes), 0, 0); // Ensures the Time data type
    }
    

    handleProfessorChange(event) {
        const scheduleId = event.target.dataset.id;
        const selectedProfessor = event.detail.value;
    
        this.schedules = this.schedules.map((schedule) => {
            if (schedule.Id === scheduleId) {
                return { 
                    ...schedule, 
                    selectedProfessor, 
                    selectedOtherSectionProfessor: null // Reset other section professor
                };
            }
            return schedule;
        });
    
        this.proceed = false;
    }
    
    handleOtherSectionProfessorChange(event) {
    const scheduleId = event.target.dataset.id;
    const selectedOtherSectionProfessor = event.detail.value;

    this.schedules = this.schedules.map((schedule) => {
        if (schedule.Id === scheduleId) {
            return { 
                ...schedule, 
                selectedOtherSectionProfessor, 
                selectedProfessor: null // Reset same section professor
            };
        }
        return schedule;
    });

    this.proceed = false;
}

handleEntireSemProfessorChange(event) {
    const scheduleId = event.target.dataset.id;
    const selectedEntireSemProfessor  = event.detail.value;
    this.schedules = this.schedules.map((schedule) => {
        if (schedule.Id === scheduleId) {
            return { 
                ...schedule, 
                selectedEntireSemProfessor, 
                selectedProfessor: null ,
                selectedOtherSectionProfessor: null 
            };
        }
        return schedule;
    });

    this.proceed = false;
}

    formatTime(rawTime) {
        if (!rawTime) return '';
        const date = new Date(rawTime);
        const hours = date.getUTCHours().toString().padStart(2, '0');
        const minutes = date.getUTCMinutes().toString().padStart(2, '0');
        return `${hours}:${minutes}`;
    }

    SaveHandler() {
        console.log('SaveHandler called');
        const adjustments = this.schedules.map((schedule) => {
            let selectedProfessor = null;
            let selectType = '';
    
            // Determine the selected professor and type
            if (schedule.selectedProfessor) {
                selectedProfessor = schedule.selectedProfessor;
                selectType = 'Same Section';
            } else if (schedule.selectedOtherSectionProfessor) {
                selectedProfessor = schedule.selectedOtherSectionProfessor;
                selectType = 'Other Section';
            } else if (schedule.selectedEntireSemProfessor) {
                selectedProfessor = schedule.selectedEntireSemProfessor;
                selectType = 'Entire School';
            }
    
            return {
                professor: selectedProfessor,
                selectType: selectType,
                scheduleDate: this.selectedDate,
                toDate: this.endDate,
                courseOfferingScheduleId: schedule.Id,
                startTime: this.formatTime(schedule.hed__Start_Time__c),
                endTime: this.formatTime(schedule.hed__End_Time__c),
                currentUserId: USER_ID,
            };
        });
    
        console.log('Adjustments to save:', adjustments);
    
        ClassAdjustmentInsert({ adjustments: JSON.stringify(adjustments) })
            .then(() => {
                this.showToast('Success', 'Class adjustments inserted successfully.', 'success');
                location.reload();
            })
            .catch((error) => {
                console.error('Error saving adjustments:', error);
                this.showToast('Error', error.body.message, 'error');
            });
           
    }
    

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }


    @wire(getRecord, {
        recordId: USER_ID,
        fields: [Name, ProfileName]
    }) wireuser({
        error,
        data
    }) {if (data) {
        //this.ownerUsername = getFieldValue(data, OWNER_USERNAME_FIELD);
        this.currentUserUsername = data.fields.Name.value;
        this.currentUserUserProfileName = data.fields.Profile.value.fields.Name.value;

    }
       else if (error) {
            this.error = error ; 
         }
    }


    get hasSameSectionProfessors() {
    return this.schedules.some((schedule) => schedule.professorOptions && schedule.professorOptions.length > 0);
}

get hasOtherSectionProfessors() {
    return this.schedules.some((schedule) => schedule.otherSectionProfessorOptions && schedule.otherSectionProfessorOptions.length > 0);
}

    
}