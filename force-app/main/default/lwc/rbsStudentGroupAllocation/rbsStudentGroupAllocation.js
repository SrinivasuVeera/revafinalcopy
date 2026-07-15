import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

import getTermAndRBSCourseDetails from '@salesforce/apex/RBSstudentGroupAllocation_Ctrl.getTermAndRBSCourseDetails';
import getExistingGroups from '@salesforce/apex/RBSstudentGroupAllocation_Ctrl.getExistingGroups';
import createRBSGroups from '@salesforce/apex/RBSstudentGroupAllocation_Ctrl.createRBSGroups';
import getGroupDetails from '@salesforce/apex/RBSstudentGroupAllocation_Ctrl.getGroupDetails';
import deleteExistingGroupAllocations from '@salesforce/apex/RBSstudentGroupAllocation_Ctrl.deleteExistingGroupAllocations';
import createStudTermGroup from '@salesforce/apex/RBSstudentGroupAllocation_Ctrl.createStudTermGroupRBS';

export default class RbsStudentGroupAllocation extends LightningElement {
    @api recordId;

    @track hasGroupOrUnassigned = false;
    @track isLoading = false;
    @track saveModal = false;
    @track objTerm;
    @track courseDetails = [];

    @track programName = '';
    @track termName = '';

    @track groupDetailMap = [];
    @track groupsMap = [];
    @track groupValues = {};

    @track selectedTab;
    @track disableCreateButton = false;
    @track disableAllocateButton = true;

    @track recordExistModal = false;
    @track subjectModalOpen = false;

    @track selectedSubjectId;
    @track selectedParentCourseId;
    @track selectedSubject;
    @track selectedTotalStud;
    @track selectedCourseCode;
    @track noOfGroups;

    @track noOfStudPerGroup;
    @track lstUnassigned = [];


    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state?.recordId || null;
            if (this.recordId) {
                this.loadTermDetails();
            }
        }
    }
    loadTermDetails() {
        this.isLoading = true;
        getTermAndRBSCourseDetails({ recordId: this.recordId })
            .then(result => {
                const courseDetailsRaw = result.mapElectiveWrp;
                const courseDetailMap = [];

                let indexElect = 0;
                for (const key in courseDetailsRaw) {
                    const subjects = courseDetailsRaw[key].map((subject, indexSub) => {
                        return {
                            ...subject,
                            dataId: `${indexElect}_${indexSub}`
                        };
                    });

                    courseDetailMap.push({
                        key: key,
                        value: subjects
                    });

                    indexElect++;
                }

                this.courseDetails = courseDetailMap;
                this.objTerm = result.objTerm;
                this.programName = result.objTerm?.Program_Batch__r?.Name || '';
                this.termName = result.objTerm?.Name || '';
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Failed to load data', this.extractErrorMessage(error), 'error');
            });
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
        `;
        this.template.querySelector('lightning-card').appendChild(STYLE);
        this.isLoaded = true;
    }

    closeSubjectModel() {
        this.subjectModalOpen = false;
        this.disableCreateButton = false;
        this.noOfGroups = null;
        this.noOfStudPerGroup = null;
        this.groupDetailMap = [];
        this.lstUnassigned = [];
    }

    handleSubjectClick(event) {
        const indexElect = event.currentTarget.dataset.elect;
        const indexSub = event.currentTarget.dataset.sub;

        const subject = this.courseDetails[indexElect].value[indexSub];

        this.selectedSubjectId = subject.subjectID;
        this.selectedParentCourseId = subject.parentCourseId;
        this.selectedSubject = subject.subjectName;
        this.selectedTotalStud = subject.totlNoOfStudents;
        this.selectedCourseCode = subject.courseCode;

        getExistingGroups({
            subjectId: this.selectedSubjectId,
            recordId: this.recordId
        })
            .then(result => {
                if (result?.strMessage === 'Records Exists') {
                    const groupWrapper = result.objGroupMainWrp?.mapGroupWrp || {};
                    this.groupDetailMap = Object.entries(groupWrapper)
                        .map(([key, group], groupIndex) => {
                            // Deduplicate lstcourseCons
                            const uniqueStudentMap = new Map();

                            group.lstcourseCons.forEach(student => {
                                const uniqueKey = `${student.srnNumber}_${student.ContactId}_${student.progEnrollId}_${student.subjectId}`;
                                if (!uniqueStudentMap.has(uniqueKey)) {
                                    uniqueStudentMap.set(uniqueKey, student);
                                }
                            });
                            const groupsMap = [
                                ...Object.keys(result.objGroupMainWrp.mapGroups).map(key => ({
                                    label: result.objGroupMainWrp.mapGroups[key],
                                    value: key
                                }))
                            ];
                            // Get only unique students
                            const uniqueStudents = Array.from(uniqueStudentMap.values()).map((student, index) => ({
                                ...student,
                                serialNumber: index + 1,
                                comboName: `${groupIndex}_${index}`,
                                groupName: group.groupName,
                                studentGroupOption: groupsMap,
                            }));

                            return {
                                key,
                                label: `${group.groupName} (${uniqueStudents.length})`,
                                value: {
                                    ...group,
                                    lstcourseCons: uniqueStudents
                                }
                            };
                        });


                    const groupData = result.objGroupMainWrp.mapGroups;
                    this.groupsMap1 = [
                        { label: '--None--', value: '' },
                        ...Object.keys(groupData).map(key => ({
                            label: groupData[key],
                            value: key
                        }))
                    ];
                    this.groupValues = result.objGroupMainWrp.mapGroupDetails;
                    this.disableAllocateButton = false;
                    this.selectedTab = this.groupDetailMap.length > 0 ? this.groupDetailMap[0].value.groupNo : null;
                    //this.lstUnassigned = result.objGroupMainWrp.lstUnassigned;

                    this.lstUnassigned = result.objGroupMainWrp.lstUnassigned.map((item, index) => {
                        return {
                            ...item,
                            sNo: index + 1, // Assign index starting from 1
                            unAssigenedgroupOptions: this.groupsMap1
                        };
                    });

                    this.recordExistModal = true;
                    this.disableCreateButton = true;
                    this.noOfGroups = result.totalGroupRecords;
                    this.hasGroupOrUnassigned = true;
                } else {
                    this.subjectModalOpen = true;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Error fetching groups', this.extractErrorMessage(error), 'error');
                this.isLoading = false;
            });
    }
    handleInputChange(event) {
        const name = event.target.name;
        const value = event.target.value;

        if (name === 'NoOfGroups') {
            this.noOfGroups = value;
        } else if (name === 'NoOfStudents') {
            this.noOfStudPerGroup = value;
        }
    }

    cancelSubjectModal() {
        this.noOfStudPerGroup = null;
        this.subjectModalOpen = false;
    }
    createGroups() {
        this.isLoading = true;
        let errorCount = 0;

        const inputs = this.template.querySelectorAll('[data-id="groupInput"]');
        if (inputs && inputs.length > 0) {
            inputs.forEach(input => {
                input.reportValidity();
                if (!input.checkValidity()) {
                    errorCount++;
                }
            });
        }

        if (errorCount > 0) {
            this.isLoading = false;
            this.showToast('Error', 'Fill all mandatory fields.', 'error');
            return;
        }

        createRBSGroups({
            noOfGroup: this.noOfGroups,
            subjectId: this.selectedSubjectId,
            courseCode: this.selectedCourseCode,
            recordId: this.recordId
        })
            .then(result => {
                if (result?.strMessage === 'Success') {
                    this.showToast('Success', 'Student group allocation successfully created..!', 'success');
                    this.disableAllocateButton = false;
                    this.disableCreateButton = true;
                    this.noOfStudPerGroup = null;
                    // window.location.reload();
                } else {
                    this.showToast('Failed', result?.strMessage || 'Something went wrong.', 'error');
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Failed', this.extractErrorMessage(error), 'error');
                this.isLoading = false;
            });
    }

    allocateGroups() {
        this.isLoading = true;
        let errorCount = 0;

        // Validate inputs
        const inputs = this.template.querySelectorAll('[data-id="groupInput"]');
        if (inputs && inputs.length > 0) {
            inputs.forEach(input => {
                input.reportValidity();
                if (!input.checkValidity()) {
                    errorCount++;
                }
            });
        }

        if (errorCount > 0) {
            this.isLoading = false;
            this.showToast('Error', 'Fill all mandatory fields.', 'error');
            return;
        }
        getGroupDetails({
            subjectId: this.selectedSubjectId,
            recordId: this.recordId,
            totalStudGroup: this.noOfStudPerGroup
        })
            .then(response => {
                const groupDataRaw = response.mapGroups;
                const groupDetailsRaw = response.mapGroupWrp;
                this.groupValues = response.mapGroupDetails;

                this.groupDetailMap = Object.entries(response.mapGroupWrp)
                    .map(([key, group], groupIndex) => {
                        const uniqueStudentMap = new Map();

                        group.lstcourseCons.forEach(student => {
                            const uniqueKey = `${student.srnNumber}_${student.ContactId}_${student.progEnrollId}_${student.subjectId}`;
                            if (!uniqueStudentMap.has(uniqueKey)) {
                                uniqueStudentMap.set(uniqueKey, student);
                            }
                        });

                        const groupsMap = [
                            ...Object.keys(groupDataRaw).map(key => ({
                                label: groupDataRaw[key],
                                value: key
                            }))
                        ];

                        const uniqueStudents = Array.from(uniqueStudentMap.values()).map((student, index) => ({
                            ...student,
                            serialNumber: index + 1,
                            comboName: `${groupIndex}_${index}`,
                            groupName: group.groupName,
                            studentGroupOption: groupsMap,
                        }));



                        return {
                            key,
                            label: `${group.groupName} (${uniqueStudents.length})`,
                            value: {
                                ...group,
                                lstcourseCons: uniqueStudents,

                            }
                        };
                    });


                this.selectedTab = this.groupDetailMap.length > 0 ? this.groupDetailMap[0].value.groupNo : null;

                const groupsMap1 = [
                    { label: '--None--', value: '' },
                    ...Object.keys(groupDataRaw).map(key => ({
                        label: groupDataRaw[key],
                        value: key
                    }))
                ];
                this.lstUnassigned = response.lstUnassigned.map((item, index) => {
                    return {
                        ...item,
                        sNo: index + 1,// Assign index starting from 1
                        unAssigenedgroupOptions: groupsMap1
                    };
                });

                if ((this.lstUnassigned && this.lstUnassigned.length > 0) || (this.groupDetailMap && this.groupDetailMap.length > 0)) {
                    this.hasGroupOrUnassigned = true;
                }
                this.disableAllocateButton = true;
                this.disableCreateButton = true;
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Failed', this.extractErrorMessage(error), 'error');
                this.isLoading = false;
            });
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    extractErrorMessage(error) {
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        } else if (typeof error.body?.message === 'string') {
            return error.body.message;
        }
        return error.message || 'Unknown error';
    }

    deleteExistingGroups() {
        this.isLoading = true;

        deleteExistingGroupAllocations({
            subjectId: this.selectedSubjectId,
            recordId: this.recordId
        })
            .then(result => {
                if (result?.strMessage === 'Success') {
                    this.showToast('Success', 'Existing group allocation records deleted successfully..!', 'success');

                    this.subjectModalOpen = true;
                    this.disableCreateButton = false;
                    this.recordExistModal = false;
                    this.disableAllocateButton = true;

                    this.groupDetailMap = [];
                    this.lstUnassigned = [];
                    this.noOfGroups = null;
                } else {
                    this.showToast('Failed', result?.strMessage || 'Unexpected error occurred.', 'error');
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Failed', this.extractErrorMessage(error), 'error');
                this.isLoading = false;
            });
    }
    get unassignedTabLabel() {
        return `Unassigned (${this.lstUnassigned.length})`;
    }

    showExistingGroups() {
        this.recordExistModal = false;
        this.subjectModalOpen = true;
    }

    handleUnassignedGroupChange(event) {
        const selectedGroupId = event.detail.value;
        const studentIndex = event.target.name;
        let lstUnassigned = [...this.lstUnassigned];

        // If a group is selected (non-blank)
        if (selectedGroupId) {
            const selectedGroup = this.groupValues[selectedGroupId];
            if (!selectedGroup) return;

            lstUnassigned[studentIndex].groupId = selectedGroup.Id;
            lstUnassigned[studentIndex].groupName = selectedGroup.Name;
            lstUnassigned[studentIndex].isChecked = true;
        } else {
            // Blank value selected – reset the group assignment
            lstUnassigned[studentIndex].groupId = null;
            lstUnassigned[studentIndex].groupName = null;
            lstUnassigned[studentIndex].isChecked = false;
        }

        this.lstUnassigned = lstUnassigned;

    }

    handleGroupChange(event) {
        try {
            const index = event.target.name;
            const selectedGroupNo = event.detail.value;

            const [groupIndexStr, studentIndexStr] = index.split('_');
            const groupIndex = parseInt(groupIndexStr, 10);
            const studentIndex = parseInt(studentIndexStr, 10);

            let groupWrp = JSON.parse(JSON.stringify(this.groupDetailMap));

            if (
                isNaN(groupIndex) || isNaN(studentIndex) ||
                !groupWrp[groupIndex] ||
                !groupWrp[groupIndex].value.lstcourseCons[studentIndex]
            ) {
                this.showToast('Error', 'Invalid group/student selection', 'error');
                return;
            }

            const student = groupWrp[groupIndex].value.lstcourseCons[studentIndex];

            const selectedGroup = groupWrp.find(
                (group) => group.value.groupNo === selectedGroupNo
            );

            if (!selectedGroup) {
                this.showToast('Error', 'Selected group not found', 'error');
                return;
            }

            student.groupId = selectedGroup.value.groupId;
            student.groupName = selectedGroup.value.groupName;

            const oldSection = student.oldGroupId;
            const newSection = student.groupId;
            if (!this.disableAllocateButton) {
                student.isChecked = oldSection && oldSection !== newSection;
            }


            this.groupDetailMap = groupWrp;

        } catch (error) {
            console.error('handleGroupChange error:', error);
            this.showToast('Error', 'Unexpected error during group selection', 'error');
        }
    }


    saveSTMGroup() {
        this.isLoading = true;
        let lstcourseCons = [];
        this.saveModal = false;

        if (this.groupDetailMap && this.groupDetailMap.length > 0) {
            this.groupDetailMap.forEach(group => {
                if (group.value && group.value.lstcourseCons) {
                    group.value.lstcourseCons.forEach(student => {
                        if (student.isChecked) {
                            lstcourseCons.push(student);
                        }
                    });
                }
            });
        }

        if (this.lstUnassigned && this.lstUnassigned.length > 0) {
            this.lstUnassigned.forEach(student => {
                if (student.groupId) {
                    lstcourseCons.push(student);
                }
            });
        }

        if (lstcourseCons.length > 0) {
            this.saveModal = true;
            this.hasGroupOrUnassigned = false;
        } else {
            this.showToast('Failed', 'Please change at least one student group..!', 'error');
        }

        this.isLoading = false;
    }
    cancelAssignGroup() {
        this.saveModal = false;
        this.hasGroupOrUnassigned = true;
    }

    assignGroups() {
        this.isLoading = true;

        let lstcourseCons = [];
        this.groupDetailMap.forEach(item => {
            const courseConn = item.value.lstcourseCons;
            courseConn.forEach(student => {
                if (student.isChecked) {
                    lstcourseCons.push(student);
                }
            });
        });

        const unAssignedenrolementids = [];
        if (this.lstUnassigned && this.lstUnassigned.length > 0) {
            this.lstUnassigned.forEach(student => {
                if (student.groupId) {
                    lstcourseCons.push(student);
                }
                else if (student.progEnrollId) {
                    unAssignedenrolementids.push(student.progEnrollId);
                }
            });
        }
        createStudTermGroup({
            strCourseCons: JSON.stringify(lstcourseCons),
            isExistDelete: true,
            unAssignEnrolement: JSON.stringify(unAssignedenrolementids)
        })
            .then(result => {
                if (result?.strMessage === 'Success') {
                    this.showToast('Success', 'Student group successfully allocated..!', 'success');
                    this.saveModal = false;
                    this.subjectModalOpen = false;
                    this.disableCreateButton = false;
                    this.noOfGroups = null;
                    this.noOfStudPerGroup = null;
                    this.groupDetailMap = [];
                    this.lstUnassigned = [];
                    // window.location.reload();

                } else {
                    this.showToast('Failed', result?.strMessage || 'Unknown error', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                this.showToast('Failed', error.body?.message || 'Unknown error', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    closeSubjectCnfModel() {
        this.recordExistModal = false;
    }


}