import { LightningElement,track,api,wire } from 'lwc';
import getProgramBatch from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.getRelatedProgramBatch';
import getSemester from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.getRelatedSemester';
import getCourseEnrollments from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.getCourseEnrollments';
import updateFacultyEligibility from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.updateFacultyEligibility';
import updateExamVerticalHeadStatusForSemester from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.updateExamVerticalHeadStatusForSemester';
import FreezeExaminationVerticalHead from '@salesforce/label/c.FreezeExaminationVerticalHead';
import updateStatus from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.updateStatus';
import bulkUpdateVerification from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.bulkUpdateVerification';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RveExaminationVerticalHeadFreezing extends LightningElement {

    // Array for Handling the Program Batch, Semester and Course Options
    @track ProgramOption = [];
    @track SemesterOption = [];
    @track CourseOption = [];
   
    // Variables for Handling the UI States and Modal Dialogs
    Buttonlabel;
    EnableCourse=false;
    DisableCourse;
    EnableSemester=false;
    DisableSemester;
    isShowModal;
    course;
    selectedSemester; // Hold the selected semester ID
    isAllFreezed=true;
    isFreezeUnfreezenable=true // For Enabling/Disabling the Freeze/UnFreeze Button Course Wise
    isFreezeDisable=false; // For Enabling/Disabling the Freeze Semester Button
    isShowModalFreeze = false;
    buttonVariant;
    buttonlabel;
    CourseOfferingID;
    isShowModalFreezeSemester = false;
    isShowModalUnFreezeSemester = false;
    question; // For Showing the Question in the Freeze/UnFreeze Modal
    freezeIAMarksLabel = FreezeExaminationVerticalHead; // Custom Label for Freeze Examination Vertical Head
    @track lastVerifiedBatchIds = []; 
    isPastGlobalDeadline = false;
    

    // For retrieving the program batch options based on Exam Vertical Lookup in School
    @wire(getProgramBatch)
    wiredProgramBatch({error,data}){
        if(data){
            console.log('Program Batch Data: ', data);
            for(let key in data){
                let tempArray = [...this.ProgramOption]; // Clone the existing array
                tempArray.push({ label: data[key].Name, value: data[key].Id });
                this.ProgramOption = tempArray; // Assign a new reference
            }
        }
        else if(error){
            console.error('Error: '+error.message);
        }
    }

    get statusOptions() {
    return [
        { label: 'Open', value: 'Open' },
       // { label: 'Locked', value: 'Locked' },        
        { label: 'Not Entered', value: 'Not Entered' }
    ];
    }

    // Retrieving the Semesters Based on Selected Program Batch
    getSemester(event){
        this.SemesterOption = []; // Reset the SemesterOption array for clear the previous values
        this.CourseOption = [] // Reset the CourseOption array for clear the previous values
        this.EnableCourse = false; // For Enabling the Course Dropdown
        this.DisableCourse = false; 
        this.EnableSemester = false;
        this.DisableSemester = false;
        this.selectedSemester = '';
        getSemester({
            ProgramBatch: event.target.value
        })
        .then(res=>{
            this.EnableSemester = res.length>0?true:false; // If records found, enable the Semester Dropdown
            this.DisableSemester = res.length === 0 ? true : false; // If records not found, disable the Semester Dropdown
            if(res.length>0){
            for(let key in res){
            let tempArray = [...this.SemesterOption]; // Clone the existing array
            tempArray.push({ label: res[key].Name, value: res[key].Id });
            this.SemesterOption = tempArray; // Assign a new reference
            }
        }
        })
        .catch(error=>{
            console.error('Error: '+error.message);
        })
    }   
   getCourseWithProfessors(event) {
    const semesterId = event.target.value;
    this.CourseOption = [];
    this.DisableCourse = false;
    this.EnableCourse = false;
    this.selectedSemester = semesterId;
    this.isPastGlobalDeadline = false; 

    if (!semesterId) return;

    getCourseEnrollments({ SemesterID: semesterId })
        .then(res => {
            if (!res || res.length === 0) {
                this.EnableCourse = false;
                this.DisableCourse = true;
                return;
            }

            const today = new Date();
            today.setHours(0, 0, 0, 0); 
            const daysToAdd = parseInt(this.freezeIAMarksLabel, 10) || 0;
            
            const firstRecord = res[0];
            const parentTerm = firstRecord.Section__r?.hed__Parent_Term__r || {};
            const grandParentTerm = parentTerm.hed__Parent_Term__r || {};
            const isDirectorFrozen = parentTerm.SchoolDirectorFreeze__c || false;
            const isSemesterFrozenNow = parentTerm.ExamVerticalHeadFreeze__c || 
                                        grandParentTerm.ExamVerticalHeadFreeze__c || false;
            
            if (parentTerm.IA_2_Result_Date__c) {
                const globalDeadline = new Date(parentTerm.IA_2_Result_Date__c);
                globalDeadline.setDate(globalDeadline.getDate() + daysToAdd);
                this.isPastGlobalDeadline = today > globalDeadline;
            }

            this.CourseOption = res.map((record, index) => {
                let deadlineFormatted = 'N/A';
                const rowResultDate = record.Section__r?.hed__Parent_Term__r?.IA_2_Result_Date__c;
                
                if (rowResultDate) {
                    const d = new Date(rowResultDate);
                    d.setDate(d.getDate() + daysToAdd);
                    deadlineFormatted = `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
                }

                const profFreeze = !!(record.rve_Professor_Freeze__c || record.RVE_Professor_freeze__c);
                const headVerify = !!(record.rve_Exam_Vertical_Head_Freeze__c || record.RVE_Exam_Vertical_Head_Freeze__c);                
                const statusVal = record.IA_Marks_Entry_Status__c || 'Not Entered';
                const isRowLocked = isDirectorFrozen || (this.isPastGlobalDeadline && isSemesterFrozenNow);

                return {
                    index: index + 1,
                    id: record.Id,
                    faculty: record.hed__Contact__r?.Name || 'N/A',
                    course: record.hed__Course_Offering__r?.hed__Course__r?.Name || 'N/A',
                    coursecode: record.hed__Course_Offering__r?.hed__Course__r?.hed__Course_ID__c || 'N/A',
                    status: statusVal,
                    lastdate: deadlineFormatted,
                    isEditable: (statusVal === 'Not Entered' && 
                                 !this.isPastGlobalDeadline && 
                                 !isDirectorFrozen && 
                                 !isSemesterFrozenNow),
                    profFreeze: profFreeze,
                    headVerify: headVerify,
                    professorAcknowledged: profFreeze,
                    examVerticalHeadAcknowledged: headVerify,
                    freezeLabel: isDirectorFrozen ? 'Locked by Director' : (profFreeze ? 'UnFreeze IA Marks' : 'Freeze IA Marks'),
                    verifyLabel: isDirectorFrozen ? 'Locked by Director' : (headVerify ? 'Unverify IA Marks' : 'Verify IA Marks'),
                    freezeVariant: profFreeze ? 'success' : 'brand',
                    verifyVariant: headVerify ? 'success' : 'brand',
                    freezeDisabled: isDirectorFrozen || isRowLocked || headVerify,
                    verifyDisabled: isDirectorFrozen || isRowLocked || !profFreeze
                };
            });

            this.isFreezeDisable = isSemesterFrozenNow || isDirectorFrozen;
            this.isFreezeUnfreezenable = (!isSemesterFrozenNow || this.isPastGlobalDeadline || isDirectorFrozen);

            this.EnableCourse = true;
            this.DisableCourse = false;
        })
        .catch(error => {
            console.error('Error:', error);
            this.showToast('Error loading data', 'error');
        });
}
   handleVerifyAll() {
    let batchIds = this.CourseOption
        .filter(item => item.status === 'Locked' && item.profFreeze && !item.headVerify)
        .map(item => item.id);

    if (batchIds.length === 0) {
        this.showToast('No eligible records to verify.', 'info');
        return;
    }

    bulkUpdateVerification({ recordIds: batchIds, status: true })
    .then(result => {
        if(result === 'Success') {
            this.lastVerifiedBatchIds = batchIds; 
            this.showToast('Verification IA Marks successfully', 'success');
            this.refreshLocalData(batchIds, 'VERIFY', true);
        }
    });
}

handleUnverifyAll() {
    if (this.lastVerifiedBatchIds.length === 0) {
        this.showToast('No records were verified in the current session batch.', 'info');
        return;
    }

    bulkUpdateVerification({ recordIds: this.lastVerifiedBatchIds, status: false })
    .then(result => {
        if(result === 'Success') {
            this.showToast('Unverification IA Marks successfully', 'success');
            this.refreshLocalData(this.lastVerifiedBatchIds, 'VERIFY', false);
            this.lastVerifiedBatchIds = []; 
        }
    });
}
handleAction(event) {
    const recordId = event.target.dataset.id;
    const action = event.target.dataset.action; 
    const status = event.target.dataset.status === 'true';
    const newStatus = !status;

    updateFacultyEligibility({ CourseOfferingID: recordId, actionType: action, status: newStatus })
    .then(res => {
        if (res === 'Success') {
            let successMessage = '';
            if (action === 'FREEZE') {
                successMessage = newStatus ? 'Freeze IA Marks successfully' : 'Unfreeze IA Marks successfully';
            } else if (action === 'VERIFY') {
                successMessage = newStatus 
                    ? 'Verification successfully done by exam vertical head' 
                    : 'Unverification successfully done by exam vertical head';
            }
            this.showToast(successMessage, 'success');
            this.CourseOption = this.CourseOption.map(item => {
                if (item.id === recordId) {
                    if (action === 'FREEZE') {
                        item.profFreeze = newStatus;
                        item.freezeLabel = newStatus ? 'UnFreeze IA Marks' : 'Freeze IA Marks';
                        item.freezeVariant = newStatus ? 'success' : 'brand';
                        item.professorAcknowledged = newStatus;
                       // item.verifyDisabled = !newStatus;
                        // Enable/Disable Verify button based on this change
                        item.verifyDisabled = !newStatus || item.isPastLastDate;
                    } else {
                        item.headVerify = newStatus;
                        item.verifyLabel = newStatus ? 'Unverify IA Marks' : 'Verify IA Marks';
                        item.verifyVariant = newStatus ? 'success' : 'brand';
                        item.examVerticalHeadAcknowledged = newStatus;
                        //item.freezeDisabled = !newStatus;
                        // Disable Freeze button if Head Verifies
                        item.freezeDisabled = newStatus || item.isPastLastDate;
                    }
                }
                return item;
            });
        }
    });
}
refreshLocalData(ids, action, status) {
    this.CourseOption = this.CourseOption.map(item => {
        if (ids.includes(item.id)) {
            if (action === 'FREEZE') {
                item.profFreeze = status;
                item.freezeLabel = status ? 'UnFreeze IA Marks' : 'Freeze IA Marks';
                item.freezeVariant = status ? 'success' : 'brand';
                item.professorAcknowledged = status;
                item.verifyDisabled = !status || item.isPastDeadline;
            } else if (action === 'VERIFY') {
                item.headVerify = status;
                item.verifyLabel = status ? 'Unverify IA Marks' : 'Verify IA Marks';
                item.verifyVariant = status ? 'success' : 'brand';
                item.examVerticalHeadAcknowledged = status;
                item.freezeDisabled = status || item.isPastDeadline; // Disable freeze if head verified
            }
        }
        return item;
    });
}
    downloadAsPDF() {
    // console.log('Selected Semester in downloadAsPDF: ' + this.selectedSemester);
    if (this.selectedSemester) {
        const vfPageUrl = `/apex/SemesterIAMarksPDF?semesterId=${this.selectedSemester}`;
        window.open(vfPageUrl, '_blank');
    } else {
        this.showToast('Please select a semester first.', 'error');
    }
    }

    handleViewMarks(event){
        this.course = event.target.dataset.id;
        this.isShowModal = true;
    }

    hideModalBox(){
        this.isShowModal = false;
    }

    hideModalBox2(){
        this.isShowModalFreeze = false;
    }

    // For Hiding the Modal Box for Freeze Semester
    hideModalFreeze(){
        this.isShowModalFreezeSemester = false;
    }

    // For Hiding the Modal Box for UnFreeze Semester
    hideModalUnFreeze(){
        this.isShowModalUnFreezeSemester = false;
    }

    // For Opening the Modal Box for Freeze Semester
    openModalFreeze(){
        this.isShowModalFreezeSemester = true;
    }

    // For Opening the Modal Box for UnFreeze Semester
    openModalUnFreeze(){
        this.isShowModalUnFreezeSemester = true;
    }

    openModal2(event){
        if(event.target.label === 'UnFreeze IA Marks'){
           this.question = 'Are you sure you want to UnFreeze IA Marks?';
        }
        else{
            this.question = 'Are you sure you want to Freeze IA Marks?';
        }
        this.CourseOfferingID = event.target.dataset.id;
        // console.log('CourseOfferingID: ', this.CourseOfferingID);
        this.isShowModalFreeze = true;
        this.buttonlabel = event.target.label;
    }   

    handleFreezeUnfreeze(event) {
    this.isShowModalFreeze = false;
    const isUnfreeze = this.buttonlabel === 'UnFreeze IA Marks';
    const statusValue = !isUnfreeze; // true if freeze, false if unfreeze
    updateFacultyEligibility({
        CourseOfferingID: this.CourseOfferingID,
        actionType: 'FREEZE',
        status: statusValue
    })
    .then(res => {
        if (res === 'Success') {
            this.CourseOption = this.CourseOption.map(course => {
                if (course.id === this.CourseOfferingID) {                   
                    course.profFreeze = statusValue;
                    course.professorAcknowledged = statusValue; 
                    course.freezeLabel = statusValue ? 'UnFreeze IA Marks' : 'Freeze IA Marks';
                    course.freezeVariant = statusValue ? 'success' : 'brand';
                    course.verifyDisabled = !statusValue || course.isPastDeadline;
                }
                return course;
            });
            this.showToast('Updated Successfully', 'success');
        }
    })
    .catch(error => {
        console.error('Error: ', JSON.stringify(error));
        this.showToast('An unexpected error occurred.', error.message); 
    });
}
    handleFreezeSemester() {
    this.isShowModalFreezeSemester = false;
    if (!this.selectedSemester) return;
    const hasUnverifiedLockedRows = this.CourseOption.some(item => 
        item.status === 'Locked' && (item.professorAcknowledged === false || item.examVerticalHeadAcknowledged === false)
    );

    if (hasUnverifiedLockedRows) {
        this.showToast('Cannot freeze: Some Locked courses are not verified.', 'error');
        return;
    }

    updateExamVerticalHeadStatusForSemester({ semId: this.selectedSemester, status: 'Freeze' })
    .then(res => {
        if (res === 'Success') {
            this.isFreezeDisable = true;
            this.isFreezeUnfreezenable = this.isPastGlobalDeadline; 

            this.CourseOption = this.CourseOption.map(item => {
                return {
                    ...item,
                    isEditable: false,
                    freezeDisabled: true,
                    verifyDisabled: true,
                    freezeLabel: this.isPastGlobalDeadline ? 'Closed (Deadline)' : 'UnFreeze IA Marks',
                    verifyLabel: this.isPastGlobalDeadline ? 'Closed (Deadline)' : 'Unverify IA Marks'
                };
            });

            this.showToast('Semester frozen successfully.', 'success');
        }
    })
    .catch(error => { console.error(error); });
}
handleUnFreezeSemester() {
    this.isShowModalUnFreezeSemester = false;
    if (!this.selectedSemester) return;

    updateExamVerticalHeadStatusForSemester({ semId: this.selectedSemester, status: 'UnFreeze' })
    .then(res => {
        if (res === 'Success') {
            this.isFreezeDisable = false; 
            this.isFreezeUnfreezenable = true; 

            this.CourseOption = this.CourseOption.map(item => {
                return {
                    ...item,
                    isEditable: (item.status === 'Not Entered' && !this.isPastGlobalDeadline),
                    freezeDisabled: item.headVerify, // only disable if head verified
                    verifyDisabled: !item.profFreeze, // only disable if prof hasn't frozen
                    freezeLabel: item.profFreeze ? 'UnFreeze IA Marks' : 'Freeze IA Marks',
                    verifyLabel: item.headVerify ? 'Unverify IA Marks' : 'Verify IA Marks'
                };
            });

            this.showToast('Semester unfrozen successfully.', 'success');
        }
    })
    .catch(error => { console.error(error); });
}

showToast(msg,variant){
    const evt = new ShowToastEvent({
    title: 'Status',
    message: msg,
    variant: variant,
    mode: 'dismissable'
});
this.dispatchEvent(evt);
}

 handleStatusChange(event) {
    const updatedId = event.target.dataset.id;
    const newValue = event.detail.value;
   // console.log('course id----',updatedId);

    updateStatus({ courseEnrollmentId: updatedId, newStatus: newValue })
        .then(result => {
            if (result === 'Success') {
                this.CourseOption = this.CourseOption.map(entry => {
                    if (entry.id === updatedId) {
                        return { 
                            ...entry, 
                            status: newValue,
                            isEditable: newValue === 'Not Entered' 
                        };
                    }
                    return entry;
                });

                this.showToast('Status updated successfully', 'success');
            } else {
                this.showToast(result, 'error');
            }
        })
        .catch(error => {
            console.error('Update failed', error);
            this.showToast('Error updating record', 'error');
        });
}



}