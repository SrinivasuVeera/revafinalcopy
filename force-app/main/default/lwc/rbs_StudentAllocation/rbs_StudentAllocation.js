import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

// Import Apex methods
import getCourseOfferingData from '@salesforce/apex/RBS_StudentAllocationController.displayCourseOfferingRecords';
import getRBSstudentsbySpcl from '@salesforce/apex/RBS_StudentAllocationController.getRBSstudentsbySpcl';
import createCourseConnections from '@salesforce/apex/RBS_StudentAllocationController.createCourseConnections';
import ActivateCourseOffering from '@salesforce/apex/RBS_StudentAllocationController.activateCourseOffering';

export default class Rbs_StudentAllocation extends LightningElement {
    @api recordId;
    isLoaded = false;

    @track isLoading = false;
    @track isModalOpen = false;
    @track showConfirmSubject = false;
    @track showCreateSubject = false;
    @track showCnfForConnection = false;


    @track courseOfferingData = [];
    @track mapCourseOfferingdata = {};
    @track rbsStudentData = [];

    termName = '';
    progPlanName = '';
    headerName = '';
    selectedCourseId = '';
    subjectDetailsMap = new Map();
    @track selectedStudents = [];
    allSelected = false;

    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (pageRef) {
            this.isLoading = true;
            this.recordId = pageRef.state?.recordId || null;
            if (this.recordId) {
                this.loadCourseData();
            }
        }
    }

    renderedCallback() {
        if (this.isLoaded) {
            return;
        }
        const STYLE = document.createElement("style")
        STYLE.innerText = `
            .uiModal--medium .modal-container {
                max-width: 85% ;
                max-height: 100% ;
                width: 100% !important;
                min-width: 480px;
                min-height: 480px;
            }
            .specialization-header {
                background-color: #f3f2f2;
                font-weight: bold;
            }
            .specialization-header td {
                padding-top: 0.75rem;
                padding-bottom: 0.75rem;
            }
        `;
        this.template.querySelector('lightning-card').appendChild(STYLE);
        this.isLoaded = true;
    }

    loadCourseData() {
        getCourseOfferingData({ termId: this.recordId })
            .then(result => {
                this.termName = result.termName || '';
                this.progPlanName = result.programPlanName || '';
                this.groupCourses(result.mapCourseOfferingdata || {});
            })
            .catch(error => {
                this.handleError('Error loading course data', error);
            });
        this.isLoading = false;
    }

    groupCourses(mapCourseOfferingdata) {
        this.mapCourseOfferingdata = mapCourseOfferingdata;
        if (!mapCourseOfferingdata || Object.keys(mapCourseOfferingdata).length === 0) {
            this.groupedCourses = [];
            return;
        }
        this.courseOfferingData = Object.entries(mapCourseOfferingdata).map(([key, courses]) => {
            const specializationName = courses?.[0]?.parentCourseOfferingName || 'Uncategorized';
            const specializationId = courses?.[0]?.specializationId || null;

            const coursesOfSpcl = courses.map(course => ({
                CourseOfferingId: course.courseOfferingId,
                Name: course.Name,
                specializationId: course.specializationId,
                courseName: course.courseName,
                active: course.active,
                assigned: course.assigned,
                parentCourseOfferingName: course.parentCourseOfferingName
            }));

            return {
                key: key,
                Specialization_Name: specializationName,
                specializationId: specializationId,
                courses: coursesOfSpcl
            };
        });

    }

    get hasCourseData() {
        return this.courseOfferingData && this.courseOfferingData.length > 0;
    }

    handleSpclClick(event) {
        event.preventDefault();
        const clickedSpecializationId = event.currentTarget.dataset.id;
        const specializationName = event.currentTarget.dataset.specializationName;
        this.headerName = specializationName;

        this.selectedCourseId = clickedSpecializationId;
        this.showCreateSubject = true;
    }

    handleCourseNo() {
        this.showCreateSubject = false;
        this.selectedCourseId = '';
    }

    handleCourseYes(event) {
        this.isLoading = true;
        const currentSelectedSpclId = event.currentTarget.dataset.id;
        this.showCreateSubject = false;

        if (!currentSelectedSpclId || !this.recordId) {
            this.handleError('Missing Specialization or Term ID.');
            this.isLoading = false;
            return;
        }

        getRBSstudentsbySpcl({ spclId: currentSelectedSpclId, termId: this.recordId })
            .then(result => {
                this.rbsStudentData = result.map((student, index) => ({
                    ...student,
                    checked: false,
                    index: index + 1
                }));
                this.selectedStudents = [];
                this.isModalOpen = true;
            })
            .catch(error => {
                this.handleError('Error loading elective details', error);
                console.warn('getElectiveCourseDetails may expect a CourseOfferingId instead of specializationId.');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }


    handleSelectAll(event) {
        const checked = event.target.checked;
        this.allSelected = checked;

        this.rbsStudentData = this.rbsStudentData.map(student => {
            student.checked = checked;
            return student;
        });
        this.selectedStudents = checked ? [...this.rbsStudentData] : [];
    }

    get isSaveButton() {
        return this.rbsStudentData.some(student => student.checked) ? false : true;
    }

    handleStudentSelect(event) {
        const contactId = event.target.dataset.id;
        const checked = event.target.checked;
        this.rbsStudentData = this.rbsStudentData.map(student => {
            if (student.contactId === contactId) {
                student.checked = checked;
            }
            return student;
        });

        if (checked) {
            const selected = this.rbsStudentData.find(s => s.contactId === contactId);
            if (selected && !this.selectedStudents.some(s => s.contactId === contactId)) {
                this.selectedStudents.push(selected);
            }
        } else {
            this.selectedStudents = this.selectedStudents.filter(s => s.contactId !== contactId);
            this.allSelected = false;
        }

        const allChecked = this.rbsStudentData.every(s => s.checked);
        this.allSelected = allChecked;
    }

    closeModal() {
        this.isModalOpen = false;
        this.resetModalData();
    }

    resetModalData() {
        this.headerName = '';
        this.allSelected = false;
        this.selectedCourseId = '';
    }

    saveCourseConnection() {
        this.closeModal();
        this.showCnfForConnection = true;
    }

    handleCourseCnfNo() {
        this.isModalOpen = true;
        this.showCnfForConnection = false;
    }

    async handleCourseCnfYes() {
        this.isLoading = true;
        const payload = JSON.stringify(this.selectedStudents);

        await createCourseConnections({ studentJson: payload, semId: this.recordId })
            .then(result => {
                this.isLoading = false;

                if (result === 'Success') {
                    this.showToast('Success', 'Course connections saved successfully.', 'success');
                    this.showCnfForConnection = false;
                    //window.location.reload();

                } else if (result === 'Partial') {
                    this.showToast('Partial Success', 'Some course connections were saved, but a few failed.', 'warning');
                    this.showCnfForConnection = false;
                    // window.location.reload();

                } else if (result === 'Failed') {
                    this.showCnfForConnection = false;
                    this.showToast('Error', 'Failed to create course connections/Course connection Already exist for this Student with same Course.', 'error');
                } else {
                    this.showToast('Unexpected Response', 'Unexpected response from server.', 'error');
                    this.showCnfForConnection = false;
                }
            })
            .catch(error => {
                console.error('Error creating course connections:', error);
                this.isLoading = false;
                this.showToast('Error', 'An error occurred while saving course connections.', 'error');
            });

    }

    async handleActiveSubject(event) {
        const index = event.target.dataset.index;
        const isActive = event.target.checked;
        const parentKey = event.target.dataset.parent;
        const courseId = event.target.dataset.courseId;

        try {
            const parent = this.courseOfferingData.find(item => item.key === parentKey);
            const course = parent?.courses?.[index];

            if (!course || !courseId) {
                throw new Error('Course not found for update');
            }

            const coursePayload = {
                courseOfferingId: courseId,
                Name: course.Name,
                courseName: course.courseName,
                active: isActive,
                assigned: course.assigned,
                parentCourseOfferingName: course.parentCourseOfferingName
            };

            const result = await ActivateCourseOffering({ strCourOffer: JSON.stringify(coursePayload) });
            if (result.strMessage == 'Success') {
                course.active = isActive;
                this.showToast('Success', 'Subject Activated/Deactivated Successfully..!', 'success');
            }
            else {
                this.showToast('Error', result.strMessage, 'error');
                event.target.checked = !isActive;
            }

        } catch (error) {
            this.handleError('Error updating subject status', error);
            event.target.checked = !isActive;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleError(title, error) {
        console.error(title, error);
        const message = error.body?.message || error.message || 'An unexpected error occurred';
        this.showToast('Error', `${title}: ${message}`, 'error');
    }
}