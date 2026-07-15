import { LightningElement, api, track, wire } from 'lwc';
import getTermDetails from '@salesforce/apex/MSTR_ProfessorAllocationClsV1.getTermDetails';
import getProgramPlan from '@salesforce/apex/MSTR_ProfessorAllocationClsV1.getProgramPlan';
import getPreferencesDetailsTheory from '@salesforce/apex/MSTR_ProfessorAllocationClsV1.getPreferencesDetailsTheory';
import getPreferencesDetailsBatch from '@salesforce/apex/MSTR_ProfessorAllocationClsV1.getPreferencesDetailsBatch';
import getPreferencesDetailsGroup from '@salesforce/apex/MSTR_ProfessorAllocationClsV1.getPreferencesDetailsGroup';
import getProfessorPreferencesForCourse from '@salesforce/apex/MSTR_ProfessorAllocationClsV1.getProfessorPreferencesForCourse';
import saveProfessorPreferences from '@salesforce/apex/MSTR_ProfessorAllocationClsV1.saveProfessorPreferences';

import professorSubjectSecAllotment from '@salesforce/apex/ProfessorSubjectAllocationController.professorSubjectSecAllot';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

export default class AcProfessorSubjectAllocation extends LightningElement {
    @api recordId;
    @track spinner = false;
    @track displayRows = [];
    @track objTerm;
    @track listHardCore = [];
    @track listHcIntegrated = [];
    @track listPractical = [];
    @track listMandatory = [];
    @track listOpenElective = [];
    @track listProfElective = [];
    @track listProfessorsTheory = [];
    @track listProfessorsPrcticals = [];
    @track courseName;
    @track courseId;
    @track selectedCategoryType;
    @track termName;
    @track programPlanName;
    @track listOfTheorySections;
    @track listOfPractiSections;
    @track listProfessorsGroup;
    @track courseOfferingId;
    @track saveProfessorList;
    @track showConfirmation = false;
    @track isAllocationAllow = true;

    @track category;
    @track OpenTermPopup = false;
    @track isAllocationInSection = false;
    @track isSaveDisable = false;

    @track schoolId;
    @track contactFilter;
    @track isProfessorsMissing = false;

    showPreferencePopup = false;
    preferenceProfessors = [];
    selectedProfessorId;
    selectedProfIndex;
    selectedProfKey;

    closePreferencePopup() {
    this.showPreferencePopup = false;
    this.selectedProfessorId = null;
    this.selectedProfKey = null;

   }
   handlePreferenceSelect(event) {
    this.selectedProfessorId = event.target.value;
   } 

   openPreferencePopup(event) {

     this.selectedProfIndex = event.target.dataset.profindex;
     this.selectedProfKey = event.target.dataset.id;
        /*event.target.closest('tr')
        ?.querySelector('lightning-record-picker')
        ?.dataset.id;*/

     getProfessorPreferencesForCourse({
        semesterId: this.recordId,
        courseId: this.courseId
     })
     .then(result => {
        this.preferenceProfessors = result;
        this.showPreferencePopup = true;
     })
      .catch(error => {
         console.error(error);
       });
    }

handlePreferenceSubmit() {

    const professor = this.preferenceProfessors.find(
        p => p.professorId === this.selectedProfessorId
    );

    if (!professor) {
        this.showToast(
            'Error',
            'Please select a professor.',
            'error'
        );
        return;
    }

    // ================= THEORY =================

    if (this.selectedCategoryType === 'Theory') {

        this.listProfessorsTheory =
            this.listProfessorsTheory.map(pref => ({

                ...pref,

                sectionAssignments:
                    pref.sectionAssignments.map(sec => ({

                        ...sec,

                        professors:
                            sec.professors.map(prof => {

                                if (prof.key === this.selectedProfKey) {

                                    return {

                                        ...prof,

                                        professorId: professor.professorId,
                                        professorName: professor.professorName,
                                        prefrence: professor.preference,
                                        isProfessorIdEmpty: false
                                    };
                                }

                                return prof;

                            })

                    }))

            }));

        this.listProfessorsTheory = [...this.listProfessorsTheory];
    }

    // ================= PRACTICAL =================

    else if (this.selectedCategoryType === 'Practical') {

        this.listProfessorsPrcticals =
            this.listProfessorsPrcticals.map(pref => ({

                ...pref,

                sections:
                    pref.sections.map(sec => ({

                        ...sec,

                        batches:
                            sec.batches.map(batch => ({

                                ...batch,

                                professors:
                                    batch.professors.map(prof => {

                                        if (prof.key === this.selectedProfKey) {

                                            return {

                                                ...prof,

                                                professorId: professor.professorId,
                                                professorName: professor.professorName,
                                                prefrence: professor.preference,
                                                isProfessorIdEmpty: false
                                            };
                                        }

                                        return prof;

                                    })

                            }))

                    }))

            }));

        this.listProfessorsPrcticals = [...this.listProfessorsPrcticals];
    }

    // ================= GROUP =================

    else if (this.selectedCategoryType === 'Elective') {

        this.listProfessorsGroup =
            this.listProfessorsGroup.map(pref => ({

                ...pref,

                sectionAssignments:
                    pref.sectionAssignments.map(sec => ({

                        ...sec,

                        professors:
                            sec.professors.map(prof => {

                                if (prof.key === this.selectedProfKey) {

                                    return {

                                        ...prof,

                                        professorId: professor.professorId,
                                        professorName: professor.professorName,
                                        prefrence: professor.preference,
                                        isProfessorIdEmpty: false
                                    };
                                }

                                return prof;

                            }) 

                    }))

            }));

        this.listProfessorsGroup = [...this.listProfessorsGroup];
    }

    this.showPreferencePopup = false;
    this.selectedProfessorId = null;
}

    matchingInfo = {
        primaryField: { fieldPath: 'Name' },
        additionalFields: [{ fieldPath: 'Employee_Number__c' }],
    };

    displayInfo = {
        additionalFields: ['Employee_Number__c']
    }

    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (pageRef) {
            this.isLoading = true;
            this.recordId = pageRef.state?.recordId || null;
            if (this.recordId) {
                this.initializeData();
            }
        }
    }

    renderedCallback() {
        const STYLE = document.createElement("style")
        STYLE.innerText = `
            .uiModal--medium .modal-container {
            width: 75%;
            max-width: 100%;
            }
            `;
        this.template.querySelector('lightning-card').appendChild(STYLE);
    }

    handleClosePopup() {
        this.OpenTermPopup = false;
    }

    async handleHardcoreCourseClick(event) {
        this.showConfirmation = false;
        const index = event.target.dataset.index;
        const category = 'Hardcore Course';
        this.selectedCategoryType = 'Theory';


        this.setCommonState(category);
        await this.getProfessorCourseOfferingTheory(index, category);
    }

    async handleHardInteCourseClick(event) {
        this.showConfirmation = false;
        const index = event.target.dataset.index;
        const category = 'Hardcore Integrated Course';
        this.selectedCategoryType = 'Theory';


        this.setCommonState(category);
        await this.getProfessorCourseOfferingTheory(index, category);
    }

    async handlePracticalCourseClick(event) {
        this.showConfirmation = false;
        const index = event.target.dataset.index;
        const category = 'Practical/Term Work';
        this.selectedCategoryType = 'Practical';


        this.setCommonState(category);
        await this.getProfessorCourseOfferingPractical(index, category);
    }

    async handleMandatoryCourseClick(event) {
        this.showConfirmation = false;
        const index = event.target.dataset.index;
        const category = 'Mandatory Course';
        this.selectedCategoryType = 'Theory';


        this.setCommonState(category);
        await this.getProfessorCourseOfferingTheory(index, category);
    }
    async handleProEleCourseClick(event) {
        this.showConfirmation = false;
        const category = 'Professional Elective';
        const courseId = event.target.dataset.id;
        this.selectedCategoryType = 'Elective';
        this.setCommonState(category);
        await this.getProfessorCourseOfferingGroups(courseId, category);
    }


    setCommonState(category) {
        this.category = category;
        this.OpenTermPopup = true;
    }

    async initializeData() {
        this.spinner = true;
        try {
            const termResult = await getTermDetails({ termId: this.recordId });
            if (termResult) {
                this.objTerm = termResult;
                this.programPlanName = termResult.Program_Batch__r.Name;
                this.schoolId = termResult.Program_Batch__r.hed__Account__r.ParentId;
                this.termName = termResult.Name;
                this.isAllocationAllow = termResult.Approval_Status__c != 'Confirmed' || (termResult.Approval_Status__c == 'Confirmed' && termResult.Professors_Sections_Allotted__c == true);

                if (termResult.Approval_Status__c == 'Confirmed' && termResult.Professors_Sections_Allotted__c == true) {
                    this.isAllocationInSection = true;
                }
                else {
                    this.isAllocationInSection = false;
                }






            }

            this.contactFilter = {
                criteria: [
                    { fieldPath: "RecordType.Name", operator: "eq", value: "Professor" },
                    //{ fieldPath: "AccountId", operator: "eq", value: this.schoolId },
                    //{ fieldPath: "Professor_Across_Schools__c", operator: "eq", value: true }
                    { fieldPath: "Active__c", operator: "eq", value: true }
                ],
                filterLogic: '1 AND 2', 
                //filterLogic: '1 AND (2 OR 3)',
            };

            const planResult = await getProgramPlan({ termId: this.recordId });

            if (planResult) {
                this.listHardCore = planResult.listHardCore || [];
                this.listHcIntegrated = planResult.listHcIntegrated || [];
                this.listPractical = planResult.listPractical || [];
                this.listMandatory = planResult.listMandatory || [];
                this.listOpenElective = planResult.listOpenElective || [];

                this.listProfElective = planResult.listProfElective || [];

                let groupSet = new Set();
                this.listProfElective.forEach(parent => {
                    parent.lstCourse.forEach(course => {
                        (course.lstSection || []).forEach(section => {
                            if (section.groupName) {
                                groupSet.add('GROUP-' + section.groupName);
                            }
                        });
                    });
                });
                this.groupHeaders = Array.from(groupSet).sort();

                this.displayRows = this.listProfElective.map(parent => {
                    const courses = parent.lstCourse.filter(course => course && course.courseId && course.courseName);
                    return {
                        parentName: parent.parentCourseName,
                        parentId: parent.parentId,
                        lstCourses: courses.map(course => ({
                            ...course,
                            courseId: course.courseId,
                            courseName: course.courseName,
                        }))
                    };
                });

                this.colSpanCount = this.groupHeaders.length + 1;
            }
        } catch (error) {
            console.error('Initialization error', error);
            this.showToast('Error', error?.body?.message || error.message, 'error');
        } finally {
            this.spinner = false;
        }
    }

    async getProfessorCourseOfferingGroups(courseId, type) {
        this.listProfessorsGroup = [];
        this.listProfessorsPrcticals = false;
        this.listProfessorsTheory = false;
        this.spinner = true;
        let isInCatch = false;

        try {
            this.listProfElective.forEach(parent => {
                const course = parent.lstCourse.find(c => c.courseId === courseId);
                if (course) {
                    this.courseName = course.courseName;
                    this.courseId = course.courseId;
                    this.courseOfferingId = course.courseOfferId;
                }
            });

            const result = await getPreferencesDetailsGroup({
                termId: this.recordId,
                courseId: courseId,
                category: type
            });

            this.listProfessorsGroup = result.map(pref => {
                const groups = (pref.batchAssignments || []).map(group => {
                    const professors = (group.professorsForBatch || []).map((prof, profIndex) => {
                        const uniqueKey = `${group.batchId}-${prof.professorId || 'empty'}-${profIndex}`;
                        return {
                            key: uniqueKey,
                            proSerialNo: profIndex + 1,
                            professorId: prof.professorId || null,
                            isProfessorIdEmpty: prof.professorId ? false : true,
                            professorName: prof.professorName || '',
                            designation: prof.designation || '',
                            prefrence: prof.professorId ? prof.prefrence : '',
                            professorAssigned: prof.professorAssigned || false,
                            isPrimary: prof.isPrimary || false,

                        };
                    });
                    return {

                        groupId: group.batchId,
                        groupName: `GROUP - ${group.batchName}`,
                        sectionCode: group.batchName || '',
                        professors
                    };
                });

                return {
                    preferenceLabel: pref.preferenceLabel,
                    availableProfessors: (pref.availableProfessors || []).map(p => ({ label: p.Name, value: p.Id })),
                    sectionAssignments: groups,
                    isAutoAllocation: pref.preferenceLabel === 'Auto-Allocation',
                    isSectionLevelAllocationAllowed: pref.isSectionLevelAllocationAllowed
                };
            });

            // this.saveProfessorList = this.buildSaveWrapper('Elective');

        } catch (error) {
            isInCatch = true;
            console.error('Error fetching group preferences:', error);
            this.showToast('Error', error?.body?.message || error.message, 'error');
            this.OpenTermPopup = false;
        } finally {

            if (!this.listProfessorsGroup || this.listProfessorsGroup.length === 0 && !isInCatch) {
                this.showToast('Error', 'No Groups are found for this course', 'error');
                this.OpenTermPopup = false;
            }
            this.spinner = false;
        }
    }

    async getProfessorCourseOfferingTheory(index, type) {
        this.listProfessorsTheory = [];

        this.listProfessorsPrcticals = false;
        this.listProfessorsGroup = false;
        this.spinner = true;
        let isInCatch = false;

        try {
            const course = this.getCourseByType(index, type);
            this.courseName = course.courseName;
            this.courseId = course.courseId;
            this.courseOfferingId = course.courseOfferId;

            const result = await getPreferencesDetailsTheory({
                termId: this.recordId,
                courseId: course.courseId,
                category: type
            });

            this.listProfessorsTheory = result.map(pref => {
                const sections = (pref.batchAssignments || []).map(section => {
                    const professors = (section.professorsForBatch || []).map((prof, profIndex) => {
                        const uniqueKey = `${section.batchId}-${prof.professorId || 'empty'}-${profIndex}`;
                        return {
                            key: uniqueKey,
                            proSerialNo: profIndex + 1,
                            professorId: prof.professorId || null,
                            isProfessorIdEmpty: prof.professorId ? false : true,
                            professorName: prof.professorName || '',
                            designation: prof.designation || '',
                            prefrence: prof.professorId ? prof.prefrence : '',
                            professorAssigned: prof.professorAssigned || false,
                            isPrimary: prof.isPrimary || false,
                        };
                    });
                    return {
                        sectionId: section.batchId,
                        sectionName: `Section - ${section.batchName}`,
                        sectionCode: section.batchName || '',
                        professors
                    };
                });
                return {
                    preferenceLabel: pref.preferenceLabel,
                    availableProfessors: (pref.availableProfessors || []).map(p => ({ label: p.Name, value: p.Id })),
                    sectionAssignments: sections,
                    isAutoAllocation: pref.preferenceLabel === 'Auto-Allocation',
                    isSectionLevelAllocationAllowed: pref.isSectionLevelAllocationAllowed
                };
            });
        } catch (error) {
            isInCatch = true;
            console.error('Error fetching theory preferences:', error);
            this.showToast('Error', error?.body?.message || error.message, 'error');
            this.OpenTermPopup = false;
        } finally {
            if (!this.listProfessorsTheory || this.listProfessorsTheory.length === 0 && !isInCatch) {
                this.showToast('Error', 'No Sections are found for this course', 'error');
                this.OpenTermPopup = false;
            }
            this.spinner = false;
        }
    }

    async getProfessorCourseOfferingPractical(index, type) {
        this.listProfessorsPrcticals = [];
        this.listProfessorsTheory = false;
        this.listProfessorsGroup = false;
        this.spinner = true;

        let isInCatch = false;

        try {
            const course = this.getCourseByType(index, type);
            this.courseName = course.courseName;
            this.courseId = course.courseId;
            this.courseOfferingId = course.courseOfferId;

            const result = await getPreferencesDetailsBatch({
                termId: this.recordId,
                courseId: course.courseId,
                category: type
            });

            this.listProfessorsPrcticals = result.map(pref => {
                if (pref.isSectionLevelAllocationAllowed) {
                    const grouped = {};
                    pref.batchAssignments.forEach((batch, batchIndex) => {
                        const sectionName = `Section - ${batch.batchName.charAt(0)}`;
                        const sectionCode = batch.batchName.charAt(0) || '';

                        const batchNumber = `Batch-${batch.batchName.slice(1)}`;
                        const batchCode = batch.batchName.slice(1) || '';
                        if (!grouped[sectionName]) grouped[sectionName] = [];

                        const professors = (batch.professorsForBatch || []).map((prof, profIndex) => {
                            const uniqueKey = `${batch.batchId}-${prof.professorId || 'empty'}-${profIndex}`;
                            return {
                                key: uniqueKey,
                                proSerialNo: profIndex + 1,
                                designation: prof.designation || '',
                                professorName: prof.professorName || '',
                                professorId: prof.professorId || null,
                                isProfessorIdEmpty: prof.professorId ? false : true,
                                professorAssigned: prof.professorAssigned,
                                isPrimary: prof.isPrimary || false,
                                prefrence: prof.professorId ? prof.prefrence : '',
                                showBatch: profIndex === 0,
                            };
                        });

                        grouped[sectionName].push({
                            batchId: batch.batchId,
                            batchNumber,
                            batchCode,
                            sectionCode,
                            professors,
                            availableProfessors: (pref.availableProfessors || []).map(p => ({
                                label: p.Name,
                                value: p.Id
                            }))
                        });
                    });

                    const sections = Object.keys(grouped).map(sec => {
                        let totalRows = 0;
                        grouped[sec].forEach(b => { totalRows += b.professors.length; });
                        return {
                            sectionName: sec,
                            batches: grouped[sec].map((b, batchIndex) => ({
                                ...b,
                                professors: b.professors.map((p, profIndex) => ({
                                    ...p,
                                    showSection: batchIndex === 0 && profIndex === 0
                                }))
                            })),
                            rowspan: totalRows
                        };
                    });

                    return {
                        preferenceLabel: pref.preferenceLabel,
                        sections,
                        isAutoAllocation: pref.preferenceLabel === 'Auto-Allocation',
                        isSectionLevelAllocationAllowed: pref.isSectionLevelAllocationAllowed
                    };

                }
                else {
                    // ✅ Not approved semester logic with same structure
                    const grouped = {};
                    pref.batchAssignments.forEach((batch, batchIndex) => {
                        const sectionName = `Section - ${batch.batchName.charAt(0)}`;
                        const sectionCode = batch.batchName.charAt(0) || '';

                        const batchNumber = `Batch-${batch.batchName.slice(1)}`;
                        const batchCode = batch.batchName.slice(1) || '';
                        if (!grouped[sectionName]) grouped[sectionName] = [];

                        const professors = (batch.professorsForBatch || []).map((prof, profIndex) => ({
                            key: `${batch.batchId}-${prof.professorId || 'empty'}-${profIndex}`,
                            proSerialNo: profIndex + 1,
                            designation: prof.designation || '',
                            professorName: prof.professorName || '',
                            professorId: prof.professorId || null,
                            isProfessorIdEmpty: prof.professorId ? false : true,
                            professorAssigned: prof.professorAssigned || false,
                            isPrimary: prof.isPrimary || false,
                            prefrence: prof.prefrence || '',
                            showBatch: profIndex === 0,
                        }));

                        grouped[sectionName].push({
                            batchId: batch.batchId,
                            batchNumber,
                            sectionCode,
                            batchCode,
                            professors,
                            availableProfessors: (pref.availableProfessors || []).map(p => ({
                                label: p.Name,
                                value: p.Id
                            }))
                        });
                    });

                    const sections = Object.keys(grouped).map(sec => {
                        let totalRows = 0;
                        grouped[sec].forEach(b => { totalRows += b.professors.length; });
                        return {
                            sectionName: sec,
                            batches: grouped[sec].map((b, batchIndex) => ({
                                ...b,
                                professors: b.professors.map((p, profIndex) => ({
                                    ...p,
                                    showSection: batchIndex === 0 && profIndex === 0
                                }))
                            })),
                            rowspan: totalRows
                        };
                    });

                    return {
                        preferenceLabel: pref.preferenceLabel,
                        sections,
                        isAutoAllocation: pref.preferenceLabel === 'Auto-Allocation',
                        isSectionLevelAllocationAllowed: pref.isSectionLevelAllocationAllowed
                    };
                }
            });


        } catch (error) {
            isInCatch = true;
            console.error('Error fetching practical preferences:', error);
            this.showToast('Error', error?.body?.message || error.message, 'error');
            this.OpenTermPopup = false;
        } finally {
            if (!this.listProfessorsPrcticals || this.listProfessorsPrcticals.length === 0 && !isInCatch) {
                this.showToast('Error', 'No Batches/Sections  are found for this course', 'error');
                this.OpenTermPopup = false;
            }
            this.spinner = false;
        }
    }

    handleSave() {
        this.spinner = true;
        this.isSaveDisable = true;
        this.handleSaveAndConfirms();
    }
    handleSaveAndConfirms() {
        this.spinner = true;

        let batchSectionMap = new Map();
        let missingProfessorMessages = [];

        if (this.selectedCategoryType === 'Practical') {
            this.listProfessorsPrcticals.forEach(pref => {
                pref.sections.forEach(sec => {
                    sec.batches.forEach(batch => {
                        let batchStats = batchSectionMap.get(batch.batchId) || {
                            total: 0,
                            assigned: 0,
                            isPrimarry: 0,
                            sectionName: sec.sectionName,
                            batchNumber: batch.batchNumber
                        };


                        batch.professors.forEach(prof => {
                            batchStats.total++;
                            if (prof.professorId) {
                                batchStats.assigned++;
                                if (prof.isPrimary) {
                                    batchStats.isPrimarry++;
                                }
                            }
                        });

                        batchSectionMap.set(batch.batchId, batchStats);
                    });
                });
            });
        } else if (this.selectedCategoryType === 'Theory') {
            this.listProfessorsTheory.forEach(pref => {
                pref.sectionAssignments.forEach(sec => {
                    let sectionStats = batchSectionMap.get(sec.sectionId) || {
                        total: 0,
                        assigned: 0,
                        isPrimarry: 0,
                        sectionName: sec.sectionName
                    };


                    sec.professors.forEach(prof => {
                        sectionStats.total++;
                        if (prof.professorId) {
                            sectionStats.assigned++;
                            if (prof.isPrimary) {
                                sectionStats.isPrimarry++;
                            }

                        }
                    });

                    batchSectionMap.set(sec.sectionId, sectionStats);
                });
            });
        } else if (this.selectedCategoryType === 'Elective') {
            this.listProfessorsGroup.forEach(pref => {
                if (!pref.isSectionLevelAllocationAllowed) {
                    return;
                }

                pref.sectionAssignments.forEach(sec => {
                    let sectionStats = batchSectionMap.get(sec.groupId) || {
                        total: 0,
                        assigned: 0,
                        isPrimarry: 0,
                        groupName: sec.groupName
                    };


                    sec.professors.forEach(prof => {
                        sectionStats.total++;
                        if (prof.professorId) {
                            sectionStats.assigned++;
                            if (prof.isPrimary) {
                                sectionStats.isPrimarry++;
                            }
                        }
                    });

                    batchSectionMap.set(sec.groupId, sectionStats);
                });
            });
        }

        batchSectionMap.forEach((stats, id) => {
            if (stats.total > 0 && stats.assigned === 0) {
                let msg = '';
                if (this.selectedCategoryType === 'Practical') {
                    msg = `${stats.sectionName} In ${stats.batchNumber}`;
                } else if (this.selectedCategoryType === 'Theory') {
                    msg = `${stats.sectionName}`;
                } else if (this.selectedCategoryType === 'Elective') {
                    msg = `${stats.groupName}`;
                }

                missingProfessorMessages.push(
                    `Minimum 1 professor required for ${msg}. Please assign a professor.`
                );
            }

            else if (this.selectedCategoryType === 'Practical' && stats.assigned > 0 && stats.isPrimarry === 0) {
                missingProfessorMessages.push(
                    `Please assign one primary professor for ${stats.sectionName} In ${stats.batchNumber}.`
                );
            }
            else if (this.selectedCategoryType === 'Theory' && stats.assigned > 0 && stats.isPrimarry === 0) {
                missingProfessorMessages.push(
                    `Please assign one primary professor for ${stats.sectionName}.`
                );
            }
            else if (this.selectedCategoryType === 'Elective' && stats.assigned > 0 && stats.isPrimarry === 0) {
                missingProfessorMessages.push(
                    `Please assign one primary professor for ${stats.groupName}.`
                );
            }
        });




        if (missingProfessorMessages.length > 0) {
            this.showToast('Error', missingProfessorMessages[0], 'error');
            this.spinner = false;
            this.isSaveDisable = false;
            return;
        }

        let saveWrapper = this.buildSaveWrapper(this.selectedCategoryType);
        let isValidateData = this.validateProfessorAssignments(saveWrapper);

        if (isValidateData === false) {
            this.spinner = false;
            this.isSaveDisable = false;
            return;
        }

        saveProfessorPreferences({ saveWrapper })
            .then(result => {
                if (result && result.success) {
                    this.showToast('Success', result.message, 'success');
                    this.OpenTermPopup = false;
                    this.initializeData();
                } else {
                    this.showToast('Error', result ? result.message : 'Unknown error', 'error');
                }
                this.spinner = false;
                this.isSaveDisable = false;
            })
            .catch(error => {
                console.error('Error saving professor details:', error);
                this.showToast(
                    'Error',
                    (error.body && error.body.message) ? error.body.message : 'Failed to save professor details.',
                    'error'
                );
                this.spinner = false;
                this.isSaveDisable = false;
            });
    }

    validateProfessorAssignments(assignments) {
        let duplicateFound = false;
        let duplicateMessages = [];
        let sectionProfMap = new Map();
        let batchProfMap = new Map();

        assignments.forEach(row => {
            if (!row.professorId) {
                return;
            }

            let profId = row.professorId;

            if (row.sectionCode && !row.batchCode) {
                let sectionKey = row.sectionCode + '-' + profId;
                if (sectionProfMap.has(sectionKey)) {
                    duplicateFound = true;
                    duplicateMessages.push(
                        `Duplicate Professors assigned in Section ${row.sectionCode}`
                    );
                } else {
                    sectionProfMap.set(sectionKey, true);
                }
            }

            if (row.batchCode && row.sectionCode) {
                let batchKey = row.sectionCode + '-' + row.batchCode + '-' + profId;
                if (batchProfMap.has(batchKey)) {
                    duplicateFound = true;
                    duplicateMessages.push(
                        `Duplicate Professors assigned assigned in Batch ${row.batchCode} of Section ${row.sectionCode}`
                    );
                } else {
                    batchProfMap.set(batchKey, true);
                }
            }
        });

        if (duplicateFound) {
            this.showToast('Error', duplicateMessages.join('\n'), 'error');
            return false;
        }
        return true;
    }



    handleRecordChange(event) {
        const selectedRecordId = event.detail.recordId;
        const profKey = event.target.dataset.id;
        const profIndex = event.target.dataset.profIndex

        this.handleOnchangeData(selectedRecordId, profKey, profIndex, null);
    }


    handlePrimaryChange(event) {

        const profIndex = event.target.dataset.index;
        const isPrimary = event.target.checked;
        const profKey = event.target.dataset.id;

        this.handleOnchangeData(null, profKey, profIndex, isPrimary);
    }

    handleOnchangeData(selectedRecordId, profKey, profIndex, isPrimary) {

        let isDuplicate = false;
        if (this.selectedCategoryType === 'Practical') {
            this.listProfessorsPrcticals.forEach(pref => {
                pref.sections.forEach(sec => {
                    sec.batches.forEach(batch => {
                        batch.professors.forEach(prof => {
                            if (prof.professorId && prof.professorId === selectedRecordId && selectedRecordId != null) {
                                isDuplicate = true;
                            }
                        })
                    })
                })
            });

            this.listProfessorsPrcticals = this.listProfessorsPrcticals.map(pref => {
                return {
                    ...pref,
                    sections: pref.sections.map(sec => {
                        return {
                            ...sec,
                            batches: sec.batches.map(batch => {
                                return {
                                    ...batch,
                                    professors: batch.professors.map((prof, idx) => {
                                        const finalKey = pref.isSectionLevelAllocationAllowed ? profKey.split('-')[0] : profKey.split('-').slice(0, 5).join('-');;

                                        if (prof.key === profKey && idx == profIndex) {

                                            if (isPrimary != null) {
                                                if (prof.professorId == null && isPrimary == true) {
                                                    this.showToast('Alert!!', 'Please select professor first to mark as primary', 'warning');
                                                    return {
                                                        ...prof,
                                                        isPrimary: false,
                                                    };

                                                }
                                                return {
                                                    ...prof,
                                                    isPrimary: isPrimary,
                                                };
                                            }

                                            if (selectedRecordId) {
                                                return {
                                                    ...prof,
                                                    professorId: selectedRecordId,
                                                    isProfessorIdEmpty: false
                                                };
                                            }

                                            else {
                                                return {
                                                    ...prof,
                                                    professorId: null,
                                                    professorName: '',
                                                    professorAssigned: false,
                                                    isPrimary: false,
                                                    isProfessorIdEmpty: true,
                                                    prefrence: '',
                                                    designation: '',
                                                };
                                            }


                                        }

                                        else if (batch.batchId == finalKey) {
                                            if (isPrimary === true) {
                                                return {
                                                    ...prof,
                                                    isPrimary: prof.professorId ? false : prof.isPrimary,
                                                };
                                            }
                                        }
                                        return prof;
                                    })
                                };
                            })
                        };
                    })
                };
            });

            this.listProfessorsPrcticals = [...this.listProfessorsPrcticals];

        }


        else if (this.selectedCategoryType == 'Theory') {
            this.listProfessorsTheory.forEach(pref => {
                pref.sectionAssignments.forEach(sec => {
                    sec.professors.forEach(prof => {
                        if (prof.professorId && prof.professorId === selectedRecordId && selectedRecordId != null) {
                            isDuplicate = true;
                        }
                    });
                });
            });

            this.listProfessorsTheory = this.listProfessorsTheory.map(pref => {
                const newSections = pref.sectionAssignments.map(sec => {

                    let isEmptyProfChecked = false;
                    const newProfessors = sec.professors.map((prof, index) => {

                        const finalKey = pref.isSectionLevelAllocationAllowed
                            ? profKey.split('-')[0]
                            : profKey.split('-').slice(0, 3).join('-');


                        if (prof.key == profKey && index == profIndex) {

                            if (isPrimary != null) {
                                // 🔑 Block new primary if no professor selected
                                if (prof.professorId == null && isPrimary === true) {
                                    isEmptyProfChecked = true;
                                    this.showToast(
                                        'Alert!!',
                                        'Please select professor first to mark as primary',
                                        'warning'
                                    );
                                    return {
                                        ...prof,
                                        isPrimary: false,
                                    };




                                } else {
                                    return {
                                        ...prof,
                                        isPrimary: isPrimary,
                                    };
                                }
                            }

                            if (selectedRecordId) {
                                return {
                                    ...prof,
                                    professorId: selectedRecordId,
                                    isProfessorIdEmpty: false
                                };
                            } else {
                                return {
                                    ...prof,
                                    professorId: null,
                                    isProfessorIdEmpty: true,
                                    professorName: '',
                                    professorAssigned: false,
                                    isPrimary: false,
                                    prefrence: '',
                                    designation: '',
                                };
                            }
                        }
                        else if (sec.sectionId == finalKey) {
                            if (isPrimary === true) {
                                return {
                                    ...prof,
                                    isPrimary: prof.professorId ? false : prof.isPrimary,
                                };
                            }
                        }

                        return prof;
                    });

                    return { ...sec, professors: newProfessors };
                });

                return { ...pref, sectionAssignments: newSections };
            });

            this.listProfessorsTheory = [...this.listProfessorsTheory];
        }

        else if (this.selectedCategoryType == 'Elective') {
            this.listProfessorsGroup.forEach(pref => {
                pref.sectionAssignments.forEach(sec => {
                    sec.professors.forEach(prof => {
                        if (prof.professorId && prof.professorId === selectedRecordId && selectedRecordId != null) {
                            isDuplicate = true;
                        }
                    });
                });
            });

            this.listProfessorsGroup = this.listProfessorsGroup.map(pref => {
                const newSections = pref.sectionAssignments.map(sec => {

                    const newProfessors = sec.professors.map((prof, index) => {
                        const finalKey = pref.isSectionLevelAllocationAllowed ? profKey.split('-')[0] : profKey.split('-').slice(0, 3).join('-');
                        if (prof.key == profKey && index == profIndex) {
                            if (isPrimary != null) {
                                if (prof.professorId == null && isPrimary == true) {
                                    this.showToast('Alert!!', 'Please select professor first to mark as primary', 'warning');
                                    return {
                                        ...prof,
                                        isPrimary: false,
                                    };

                                }
                                return {
                                    ...prof,
                                    isPrimary: isPrimary,
                                };
                            }

                            if (selectedRecordId) {
                                return {
                                    ...prof,
                                    professorId: selectedRecordId,
                                    isProfessorIdEmpty: false
                                };
                            }

                            else {
                                return {
                                    ...prof,
                                    professorId: null,
                                    professorName: '',
                                    professorAssigned: false,
                                    isProfessorIdEmpty: true,
                                    isPrimary: false,
                                    prefrence: '',
                                    designation: '',
                                };
                            }
                        }
                        else if (sec.groupId == finalKey) {
                            if (isPrimary === true) {
                                return {
                                    ...prof,
                                    isPrimary: prof.professorId ? false : prof.isPrimary,
                                };
                            }
                        }
                        return prof;
                    });
                    return { ...sec, professors: newProfessors };
                });
                return { ...pref, sectionAssignments: newSections };
            });
            this.listProfessorsGroup = [...this.listProfessorsGroup];

        }

        if (isDuplicate) {
            this.showToast('Alert!!', 'Professor already assigned in another section/batch/group', 'warning');
        }
    }


    buildSaveWrapper(categoryType) {
        let saveWrapper = [];

        if (categoryType === 'Practical') {
            this.listProfessorsPrcticals.forEach(pref => {
                pref.sections.forEach(sec => {
                    sec.batches.forEach(batch => {
                        batch.professors
                            .forEach(prof => {
                                saveWrapper.push({
                                    batchId: pref.isSectionLevelAllocationAllowed ? batch.batchId : '',
                                    professorId: prof.professorId,
                                    courseOffId: this.courseOfferingId,
                                    courseId: this.courseId,
                                    termId: this.recordId,
                                    sectionId: '',
                                    sectionCode: batch.sectionCode,
                                    batchCode: batch.batchCode,
                                    isPrimary: prof.isPrimary,
                                    isSectionLevelAllocationAllowed: pref.isSectionLevelAllocationAllowed
                                });
                            });
                    });
                });
            });
        }



        else if (categoryType === 'Theory') {
            this.listProfessorsTheory.forEach(pref => {
                pref.sectionAssignments.forEach(sec => {
                    sec.professors.forEach(prof => {
                        // if (prof.professorId) {
                        saveWrapper.push({
                            sectionId: pref.isSectionLevelAllocationAllowed ? sec.sectionId : '',
                            professorId: prof.professorId,
                            courseOffId: this.courseOfferingId,
                            courseId: this.courseId,
                            termId: this.recordId,
                            batchId: '',
                            sectionCode: sec.sectionCode,
                            isPrimary: prof.isPrimary,
                            batchCode: '',
                            isApproved: pref.isSectionLevelAllocationAllowed
                        });
                        // }
                    });
                });
            });
        }

        else if (categoryType === 'Elective') {
            this.listProfessorsGroup.forEach(pref => {
                pref.sectionAssignments.forEach(sec => {
                    sec.professors.forEach(prof => {
                        // if (prof.professorId) {
                        saveWrapper.push({
                            sectionId: pref.isSectionLevelAllocationAllowed ? sec.groupId : '',
                            professorId: prof.professorId,
                            courseOffId: this.courseOfferingId,
                            courseId: this.courseId,
                            termId: this.recordId,
                            batchId: '',
                            sectionCode: sec.sectionCode,
                            isPrimary: prof.isPrimary,
                            batchCode: '',
                            isApproved: pref.isSectionLevelAllocationAllowed
                        });
                        // }
                    });
                });
            });
        }

        return saveWrapper;
    }


    getCourseByType(index, type) {
        switch (type) {
            case 'Hardcore Course': return this.listHardCore[index];
            case 'Hardcore Integrated Course': return this.listHcIntegrated[index];
            case 'Practical/Term Work': return this.listPractical[index];
            case 'Mandatory Course': return this.listMandatory[index];
            default: return null;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'dismissible'
        });
        this.dispatchEvent(event);
    }


    handleApproveAllocation() {
        this.spinner = true;
        this.isAllocationAllow = true;
        professorSubjectSecAllotment({ parentTermId: this.recordId })
            .then(result => {
                if (result && result.includes('Allocation completed')) {
                    this.showToast('Success', result, 'success');
                    this.initializeData();
                } else {
                    this.showToast('Error', result ? result : 'Unknown error', 'error');
                    this.isAllocationAllow = false;
                }
                this.spinner = false;
            })
            .catch(error => {
                console.error('Error approving allocation:', error);
                this.showToast(
                    'Error',
                    (error.body && error.body.message) ? error.body.message : 'Failed to approve allocation.',
                    'error'
                );
                this.spinner = false;
                this.isAllocationAllow = false;
            });
    }
}