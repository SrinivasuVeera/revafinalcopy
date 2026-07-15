import { LightningElement, api, track, wire } from 'lwc';
import getTermDetails from '@salesforce/apex/MenteesAllocation_Ctrl.getTermDetails';
import { CurrentPageReference } from 'lightning/navigation';
import submitMenteeAllocation from '@salesforce/apex/MenteesAllocation_Ctrl.submitMenteeAllocation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const DATATABLE_COLUMNS = [
    { label: 'S.No', fieldName: 'sNo', type: 'number', initialWidth: 70, cellAttributes: { alignment: 'center' } },
    { label: 'Application Number', fieldName: 'applicationNumber', type: 'text' },
    { label: 'SRN Number', fieldName: 'Mentee_SRN__c', type: 'text' },
    { label: 'Mentee Name', fieldName: 'Name', type: 'text' },
    { label: 'Section', fieldName: 'section', type: 'text' },
    { label: 'Mentor Name', fieldName: 'professorName', type: 'text', wrapText: true },
];

export default class MenteesAllocationforMentor extends LightningElement {
    @api recordId;
    @track objTerm = {};
    @track menteesPerMentor = 0;
    @track totalUnassignedRecords;
    @track menteeGroups = [];
    @track professors = [];
    @track tableData = [];
    @track programBatchName = '';
    @track termName = '';
    @track isSubmitDisabled = true;
    @track remainingMentees = 0;    
    @track showConfirmationModal = false;
    @track professorOptions = [];
    @track schoolOptions = []; 
    @track selectedSchools = [];
    @track crossSchoolProfessors = [];
    @track currentStep = '1';
    @track confirmationTableData = [];
    @track finalProfessorOptions = [];
    @track professorMaxMentees = new Map(); 
    @track datatableColumns = DATATABLE_COLUMNS;
    @track selectedMentees = [];
    @track newProfessorIdForUpdate = '';
    @track showInlineEditPanel = false;

    get isStep1() {
        return this.currentStep === '1';
    }

    get isStep2() {
        return this.currentStep === '2';
    }

    get isAllocationActive() {
        return this.menteesPerMentor > 0;
    }
    get remainingMenteesZero() {
        return this.remainingMentees === 0;
    }
    get selectedRowsCount() {
        return this.selectedMentees.length;
    }
    get isFinalSubmitButtonDisabled() {
        return this.isSubmitDisabled || this.showInlineEditPanel;
    }
    get isAddRowDisabled() {
        const hasAvailableProfessor = this.professors.some(prof => {
            const isProfessorUsed = this.tableData.some(row => row.professor === prof.professor?.Id);
            const availableSlots = (prof.professor?.Max_Mentees__c || 0) - (prof.menteeCount || 0);
            return !isProfessorUsed && availableSlots > 0;
        }) || this.crossSchoolProfessors.some(prof => {
            const isProfessorUsed = this.tableData.some(row => row.crossSchoolProfessor === prof.professor?.Id);
            const availableSlots = (prof.professor?.Max_Mentees__c || 0) - (prof.menteeCount || 0);
            return !isProfessorUsed && availableSlots > 0;
        });
        return this.remainingMentees <= 0 || !hasAvailableProfessor;
    }

    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state?.recordId || null;
            console.log('Extracted recordId:', this.recordId);
            if (this.recordId) {
                this.fetchTermDetails();
            }
        }
    }

    connectedCallback() {
        this.validateSubmission();
    }

    fetchTermDetails() {
        const schoolsToSend = Array.isArray(this.selectedSchools) ? [...this.selectedSchools] : [];
        getTermDetails({ recId: this.recordId, menteesPerMentor: this.menteesPerMentor, selectedSchools: schoolsToSend })
            .then(result => {
                this.objTerm = result.objTerm || {};
                this.totalUnassignedRecords = result.totalUnassignedRecords;
                this.menteeGroups = result.menteeGroups;
                this.professors = result.professors;              
                this.programBatchName = this.objTerm?.Program_Batch__r?.Name || 'Unknown Program';
                this.termName = this.objTerm?.Name || 'Unknown Term'; 
                this.professorOptions = [{ label: 'None', value: '' }].concat(
                    this.professors.map(prof => ({
                        label: prof.professor?.Name,
                        value: prof.professor?.Id
                    }))
                );
                this.schoolOptions = result.schools.map(school => ({
                    label: school.Name,
                    value: school.Id
                }));
                this.crossSchoolProfessors = result.crossSchoolProfessors || [];
                console.log('Fetched crossSchoolProfessors:', JSON.stringify(this.crossSchoolProfessors));

                this.professorMaxMentees.clear();
                this.professors.forEach(prof => {
                    this.professorMaxMentees.set(prof.professor?.Id, prof.professor?.Max_Mentees__c || 0);
                });
                this.crossSchoolProfessors.forEach(prof => {
                    this.professorMaxMentees.set(prof.professor?.Id, prof.professor?.Max_Mentees__c || 0);
                });

                this.processProfessors();
                this.updateTableWithCrossSchool();
                this.validateTableData();
            })
            .catch(error => {
                console.error('Error fetching term details:', error);
                this.isSubmitDisabled = true;
            });
    } 

    handleSchoolChange(event) {
    if (this.isAllocationActive) {        
        this.selectedSchools = Array.isArray(event.detail) ? [...event.detail] : [];
        console.log('Selected Schools:', JSON.stringify(this.selectedSchools)); // Log as JSON to verify
        if (this.selectedSchools.length > 0) {
            this.fetchTermDetails();
        } else {
            this.crossSchoolProfessors = [];
            this.updateTableWithCrossSchool();
        }
    }
}

    processProfessors() {
        console.log('Before Sorting Professors:', JSON.stringify(this.professors));
        this.professors.sort((a, b) => {
            let availableSlotsA = (a.professor?.Max_Mentees__c || 0) - (a.menteeCount || 0);
            let availableSlotsB = (b.professor?.Max_Mentees__c || 0) - (b.menteeCount || 0);
           
            if (a.menteeCount === 0 && b.menteeCount === 0) {
                return a.professor.Name.localeCompare(b.professor.Name);
            }
            if (a.menteeCount === 0) return -1;
            if (b.menteeCount === 0) return 1;
            if (availableSlotsA !== availableSlotsB) {
                return availableSlotsB - availableSlotsA;
            }
            return a.professor.Name.localeCompare(b.professor.Name);
        });
      
        let tableData = [];
        let totalMentees = this.totalUnassignedRecords;
        let menteesPerMentor = this.menteesPerMentor;
        let totalAssigned = 0;
 
        for (let i = 0; i < this.professors.length; i++) {
            if (totalMentees <= 0) break; 
            let professor = this.professors[i];
            let professorName = professor.professor?.Name || '';
            let maxMentees = professor.professor?.Max_Mentees__c || 0;
            let assignedMentees = professor.menteeCount || 0;
            let availableSlots = maxMentees - assignedMentees;                
            let menteesAssigned = Math.min(menteesPerMentor, availableSlots, totalMentees);
            totalMentees -= menteesAssigned;
            totalAssigned += menteesAssigned;

            let newAssignedMentees = assignedMentees + menteesAssigned; 
            tableData.push({
                id: 'row-' + Date.now() + '-' + i,
                sNo: i + 1,
                totalMentees: menteesAssigned,
                professor: professor.professor?.Id || '',
                maxMentees: maxMentees,
                assignedMentees: newAssignedMentees,
                professorOptions: this.professorOptions,
                crossSchoolProfessor: '',
                crossSchoolProfessorName: '',
                crossSchoolProfessorOptions: [{ label: 'None', value: '' }].concat(
                    this.crossSchoolProfessors.map(prof => ({
                        label: prof.professor?.Name || 'Unknown',
                        value: prof.professor?.Id || ''
                    }))
                )   
            });
        }
 
        this.tableData = tableData;
        this.remainingMentees = this.totalUnassignedRecords - totalAssigned;
    } 

    updateTableWithCrossSchool() {
        this.tableData = this.tableData.map(row => ({
            ...row,
            crossSchoolProfessorOptions: [{ label: 'None', value: '' }].concat(
                this.crossSchoolProfessors.map(prof => ({
                    label: prof.professor?.Name || 'Unknown',
                    value: prof.professor?.Id || ''
                }))
            )
        }));
        console.log('Updated crossSchoolProfessorOptions:', JSON.stringify(this.tableData.map(row => row.crossSchoolProfessorOptions)));
    }

    handleCrossSchoolProfessorChange(event) {
        if (!this.isAllocationActive) {
            return;
        }
    
        const rowId = event.target.dataset.id;
        const selectedProfessorId = event.detail.value;
        const originalProfessorValue = this.tableData.find(row => row.id === rowId)?.crossSchoolProfessor;
    
        let updatedTableData = JSON.parse(JSON.stringify(this.tableData));
        let currentRow = updatedTableData.find(row => row.id === rowId);
    
        if (selectedProfessorId === '') {
            currentRow.crossSchoolProfessor = '';
            currentRow.crossSchoolProfessorName = '';
            const mainProfessor = this.professors.find(p => p.professor?.Id === currentRow.professor);
            if(mainProfessor) {
                currentRow.maxMentees = mainProfessor.professor?.Max_Mentees__c || 0;
                currentRow.assignedMentees = (mainProfessor.menteeCount || 0) + (currentRow.totalMentees || 0);
            }
            this.tableData = updatedTableData;
            this.validateTableData();
            return;
        }
    
        const isDuplicate = this.tableData.some(row => row.id !== rowId && (row.crossSchoolProfessor === selectedProfessorId || row.professor === selectedProfessorId));
        if (isDuplicate) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error', message: 'This professor is already assigned.', variant: 'error'
            }));
            event.target.value = originalProfessorValue || null;
            return;
        }
    
        const newProfessorDetails = this.crossSchoolProfessors.find(p => p.professor?.Id === selectedProfessorId);
        if (!newProfessorDetails) { return; }
    
        const menteesToAssignInRow = currentRow.totalMentees || 0;
        const professorMaxCapacity = newProfessorDetails.professor?.Max_Mentees__c || 0;
        const professorExistingMentees = newProfessorDetails.menteeCount || 0;
        const newTotalAssignedForProfessor = professorExistingMentees + menteesToAssignInRow;
    
        if (newTotalAssignedForProfessor > professorMaxCapacity) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Allocation Error',
                message: `Cannot assign. Professor's max capacity is ${professorMaxCapacity}, but this assignment would bring their total to ${newTotalAssignedForProfessor}.`,
                variant: 'error'               
            }));
            event.target.value = originalProfessorValue || null; 
            return;
        }
    
        currentRow.professor = ''; 
        currentRow.crossSchoolProfessor = selectedProfessorId;
        currentRow.crossSchoolProfessorName = newProfessorDetails.professor?.Name || '';
        currentRow.maxMentees = professorMaxCapacity;
        currentRow.assignedMentees = newTotalAssignedForProfessor;
    
        this.tableData = updatedTableData;
        const totalAssigned = this.tableData.reduce((sum, row) => sum + (row.totalMentees || 0), 0);
        this.remainingMentees = this.totalUnassignedRecords - totalAssigned;
        this.validateTableData();
    }    

    handleMenteeCountChange(event) {
        const newValue = parseInt(event.target.value, 10);    
        this.isSubmitDisabled = true;    
        
        if (!newValue || newValue <= 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter a number greater than 0',
                    variant: 'error'
                })
            );
            this.menteesPerMentor = 0;
            this.isSubmitDisabled = true;
            return;
        }        
        if (newValue > this.totalUnassignedRecords) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: `Number of mentees per mentor cannot exceed total unassigned mentees (${this.totalUnassignedRecords})`,
                    variant: 'error'
                })
            );
            this.menteesPerMentor = Math.min(this.totalUnassignedRecords, this.menteesPerMentor || 0);
            this.isSubmitDisabled = true;
            return;
        }    
        this.menteesPerMentor = newValue;
        this.remainingMentees = this.totalUnassignedRecords; 
        this.fetchTermDetails();
    }

    validateSubmission() {    
        if (!this.menteesPerMentor || 
            this.menteesPerMentor <= 0 || 
            this.menteesPerMentor > this.totalUnassignedRecords) {
            this.isSubmitDisabled = true;
            return;
        }
        
        if (!this.tableData || this.tableData.length === 0) {
            this.isSubmitDisabled = true;
            return;
        }    
        this.isSubmitDisabled = false;
    }

    handleAddRow() {
        if (this.remainingMentees <= 0) {
            return; 
        }
        const nextAvailableProfessor = this.professors.find(prof => {
            const isProfessorUsed = this.tableData.some(row => row.professor === prof.professor?.Id);
            const availableSlots = (prof.professor?.Max_Mentees__c || 0) - (prof.menteeCount || 0);
            return !isProfessorUsed && availableSlots > 0;
        }) || this.crossSchoolProfessors.find(prof => {
            const isProfessorUsed = this.tableData.some(row => row.crossSchoolProfessor === prof.professor?.Id);
            const availableSlots = (prof.professor?.Max_Mentees__c || 0) - (prof.menteeCount || 0);
            return !isProfessorUsed && availableSlots > 0;
        });

        if (!nextAvailableProfessor) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'No available professors found. Please select a professor manually.',
                    variant: 'warning'
                })
            );
            return;
        }
        const nextSNo = this.tableData.length + 1;
        const newId = 'row-' + Date.now();
        const professorId = nextAvailableProfessor.professor?.Id;
        const maxMentees = nextAvailableProfessor.professor?.Max_Mentees__c || 0;
        const assignedMentees = nextAvailableProfessor.menteeCount || 0;
        const availableSlots = maxMentees - assignedMentees;
        const menteesToAssign = Math.min(this.menteesPerMentor, availableSlots, this.remainingMentees);

        const newRow = {
            id: newId,
            sNo: nextSNo,
            professor: '',
            maxMentees: maxMentees,
            assignedMentees: assignedMentees + menteesToAssign,
            totalMentees: menteesToAssign,
            professorOptions: this.professorOptions,
            crossSchoolProfessor: professorId,
            crossSchoolProfessorName: professorId ? nextAvailableProfessor.professor?.Name : '',
            crossSchoolProfessorOptions: [{ label: 'None', value: '' }].concat(
                this.crossSchoolProfessors.map(prof => ({
                    label: prof.professor?.Name,
                    value: prof.professor?.Id
                }))
            )
        };

        this.tableData = [...this.tableData, newRow];
        this.remainingMentees -= menteesToAssign;
        this.validateTableData();
    }

    handleDeleteRow(event) {
        if (!this.isAllocationActive) {
            return;
        }
        const rowId = event.target.dataset.id;    
        this.tableData = this.tableData.filter(row => row.id !== rowId);
        
        let totalAssigned = this.tableData.reduce((sum, row) => sum + row.totalMentees, 0);
        this.remainingMentees = this.totalUnassignedRecords - totalAssigned;    
        this.tableData = this.tableData.map((row, index) => ({ ...row, sNo: index + 1 }));
    }

    handleProfessorChange(event) {
        if (!this.isAllocationActive) {
            return;
        }
        const rowId = event.target.dataset.id;
        const selectedProfessor = event.detail.value;
        const originalProfessorValue = this.tableData.find(row => row.id === rowId)?.professor;
    
        let updatedTableData = JSON.parse(JSON.stringify(this.tableData));
        let currentRow = updatedTableData.find(row => row.id === rowId);
    
        const isDuplicate = this.tableData.some(row => row.id !== rowId && (row.professor === selectedProfessor || row.crossSchoolProfessor === selectedProfessor));
        if (isDuplicate) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error', message: 'This professor is already assigned to another group.', variant: 'error'
            }));
            event.target.value = originalProfessorValue || null;
            return;
        }
    
        const newProfessorDetails = this.professors.find(prof => prof.professor.Id === selectedProfessor);
        if (!newProfessorDetails) { return; }
    
        const menteesToAssignInRow = currentRow.totalMentees || 0;
        const professorMaxCapacity = newProfessorDetails.professor.Max_Mentees__c || 0;
        const professorExistingMentees = newProfessorDetails.menteeCount || 0;
        const newTotalAssignedForProfessor = professorExistingMentees + menteesToAssignInRow;
    
        if (newTotalAssignedForProfessor > professorMaxCapacity) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Allocation Error',
                message: `Cannot assign. Professor's max capacity is ${professorMaxCapacity}, but this assignment would bring their total to ${newTotalAssignedForProfessor}.`,
                variant: 'error'                 
            }));
            event.target.value = originalProfessorValue || null;
            return;
        }
        
        currentRow.crossSchoolProfessor = '';
        currentRow.crossSchoolProfessorName = '';
        currentRow.professor = selectedProfessor;
        currentRow.maxMentees = professorMaxCapacity;
        currentRow.assignedMentees = newTotalAssignedForProfessor;
        
        this.tableData = updatedTableData;
        const totalAssigned = this.tableData.reduce((sum, row) => sum + (row.totalMentees || 0), 0);
        this.remainingMentees = this.totalUnassignedRecords - totalAssigned;
        this.validateTableData();
    }    

    validateTableData() {
        if (!this.tableData || this.tableData.length === 0) {
            this.isSubmitDisabled = true;
            console.warn('Validation failed: No table data');
            return;
        }
        const rowsWithMentees = this.tableData.filter(row => row.totalMentees > 0);

        if (rowsWithMentees.length === 0) {
            this.isSubmitDisabled = true;
            console.warn('Validation failed: No rows with mentees');
            return;
        }

        const professorCounts = new Map();
        for (const row of rowsWithMentees) {
            const professorId = row.professor || row.crossSchoolProfessor; 
            if (professorId) {
                if (professorCounts.has(professorId)) {
                    this.isSubmitDisabled = true;
                    console.warn('Validation failed: Duplicate professor found');
                    return;
                }
                professorCounts.set(professorId, true);
            }
        }

        if (rowsWithMentees.some(row => !(row.professor || row.crossSchoolProfessor))) {
            this.isSubmitDisabled = true;
            console.warn('Validation failed: Missing professor or cross-school professor in row with mentees');
            return;
        }

        console.log('Validating rows:', JSON.stringify(this.tableData));
        for (const row of this.tableData) {
            const professorDetails = (row.professor ? this.professors : this.crossSchoolProfessors).find(prof => prof.professor?.Id === (row.professor || row.crossSchoolProfessor));
            const initialAssignedMentees = professorDetails ? (professorDetails.menteeCount || 0) : 0;
            const newAssignedMentees = initialAssignedMentees + row.totalMentees;

            console.log(`Row ${row.sNo}: initialAssignedMentees=${initialAssignedMentees}, totalMentees=${row.totalMentees}, newAssignedMentees=${newAssignedMentees}, maxMentees=${row.maxMentees}, assignedMentees=${row.assignedMentees}`);

            if (newAssignedMentees > row.maxMentees) {
                this.isSubmitDisabled = true;
                console.warn(`Validation failed: Row ${row.sNo} has newAssignedMentees (${newAssignedMentees}) > maxMentees (${row.maxMentees})`);
                return;
            }

            if (row.totalMentees < 0 || row.assignedMentees < 0) {
                this.isSubmitDisabled = true;
                console.warn(`Validation failed: Row ${row.sNo} has negative values - totalMentees: ${row.totalMentees}, assignedMentees: ${row.assignedMentees}`);
                return;
            }
            if (row.assignedMentees !== newAssignedMentees) {
                console.warn(`Row ${row.sNo} synced: assignedMentees updated from ${row.assignedMentees} to ${newAssignedMentees}`);
                row.assignedMentees = newAssignedMentees;
            }
        }

        const totalAssigned = this.tableData.reduce((sum, row) => sum + (row.totalMentees || 0), 0);
        if (totalAssigned > this.totalUnassignedRecords) {
            this.isSubmitDisabled = true;
            console.warn('Validation failed: Total assigned mentees exceed totalUnassignedRecords - Total:', totalAssigned, 'Available:', this.totalUnassignedRecords);
            return;
        }

        this.isSubmitDisabled = false;
        console.log('Validation passed: Submit button enabled');
    }

    handleTotalMenteesChange(event) {
        if (!this.isAllocationActive || this.remainingMentees === 0) {
            console.warn('Editing not allowed: isAllocationActive=', this.isAllocationActive, 'remainingMentees=', this.remainingMentees);
            return;
        }

        const rowId = event.target.dataset.id;
        if (!rowId) {
            console.error('No row ID found in event.target.dataset');
            return;
        }

        const newTotalMentees = parseInt(event.target.value, 10) || 0;
        let updatedTableData = [...this.tableData];
        let currentRow = updatedTableData.find(row => row.id === rowId);

        if (!currentRow) {
            console.error('Row not found! Searched ID:', rowId, 'Available IDs:', updatedTableData.map(row => row.id));
            return;
        }
        const professorDetails = (currentRow.professor ? this.professors : this.crossSchoolProfessors).find(prof => prof.professor?.Id === (currentRow.professor || currentRow.crossSchoolProfessor));
        const initialAssignedMentees = professorDetails ? (professorDetails.menteeCount || 0) : currentRow.assignedMentees - currentRow.totalMentees;
        const newAssignedMentees = initialAssignedMentees + newTotalMentees;

        if (newAssignedMentees > currentRow.maxMentees) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: `Total assigned mentees (${newAssignedMentees}) cannot exceed professor's maximum capacity (${currentRow.maxMentees})`,
                    variant: 'error'
                })
            );
            this.isSubmitDisabled = true;
            console.warn(`Row ${currentRow.sNo} update blocked: newAssignedMentees (${newAssignedMentees}) > maxMentees (${currentRow.maxMentees})`);
            event.target.value = currentRow.totalMentees;
            return;
        }
        const totalAssignedBefore = updatedTableData.reduce((sum, row) => sum + (row.totalMentees || 0), 0);
        const proposedTotalAssigned = totalAssignedBefore - currentRow.totalMentees + newTotalMentees;
        if (proposedTotalAssigned > this.totalUnassignedRecords) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: `Total mentees assigned (${proposedTotalAssigned}) cannot exceed total unassigned mentees (${this.totalUnassignedRecords})`,
                    variant: 'error'
                })
            );
            this.isSubmitDisabled = true;
            console.warn('Update blocked: Total assigned exceeds totalUnassignedRecords');
            event.target.value = currentRow.totalMentees;
            return;
        }
        console.log(`Updating Row ${currentRow.sNo}: totalMentees=${newTotalMentees}, assignedMentees=${newAssignedMentees}`);
        currentRow.totalMentees = newTotalMentees;
        currentRow.assignedMentees = newAssignedMentees;

        this.tableData = updatedTableData;
        const totalAssigned = updatedTableData.reduce((sum, row) => sum + (row.totalMentees || 0), 0);
        this.remainingMentees = this.totalUnassignedRecords - totalAssigned;
        this.validateTableData();
    }

    handleSubmit() {
        if (this.remainingMentees > 0) {
            this.showConfirmationModal = true;
            return;
        }    
        this.processSubmission();
    }

    async processSubmission() {
        this.isSubmitDisabled = true;
        try {
            if (!this.tableData || this.tableData.length === 0) {
                throw new Error('No allocation data available');
            }

            if (!this.menteeGroups || this.menteeGroups.flat().length === 0) {
                throw new Error('No mentees available for allocation');
            }

            const allocations = new Map();
            let menteeIndex = 0;
            
            const allMenteeIds = this.menteeGroups.flat().map(mentee => mentee.hed__Contact__c);
            
            console.log('Starting allocation process...');
            console.log('Total mentees available:', allMenteeIds.length);
            console.log('Table data:', JSON.stringify(this.tableData, null, 2));

            const unassignedRows = this.tableData.filter(row => row.totalMentees > 0 && !(row.professor || row.crossSchoolProfessor));
            if (unassignedRows.length > 0) {
                throw new Error('Please select a professor or cross-school professor for all rows with mentees');
            }

            for (const row of this.tableData) {
                if (row.totalMentees > 0) {
                    const professorId = row.professor || row.crossSchoolProfessor;
                    if (menteeIndex + row.totalMentees > allMenteeIds.length) {
                        throw new Error('Not enough mentees available for allocation');
                    }

                    const professorMentees = allMenteeIds.slice(menteeIndex, menteeIndex + row.totalMentees);
                    menteeIndex += row.totalMentees;
                    
                    console.log(`Allocating ${professorMentees.length} mentees to professor ${professorId}`);
                    allocations.set(professorId, professorMentees);
                }
            }

            const allocationData = {};
            allocations.forEach((menteeIds, professorId) => {
                allocationData[professorId] = menteeIds;
            });

            await submitMenteeAllocation({
                termId: this.recordId,
                allocations: JSON.parse(JSON.stringify(allocationData))
            }).then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Mentee allocation completed successfully',
                        variant: 'success'
                    })
                );
                this.fetchTermDetails();
            }).catch(error => {
                throw new Error(error.body?.message || 'Error in Apex processing');
            });

        } catch (error) {
            console.error('Error in handleSubmit:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message || 'Error submitting mentee allocation',
                    variant: 'error'
                })
            );
            this.isSubmitDisabled = false;
        }
    }

    handleModalYes() {        
        this.prepareConfirmationData();
    }

    handleModalNo() {
        this.showConfirmationModal = false;
    }
    validateForNext() {      
      this.validateTableData();
    }

    handleNext() {       
        if (this.remainingMentees > 0) {
            this.showConfirmationModal = true;            
            return;
        }       
        this.prepareConfirmationData();
    }   
    handleBack() {
        this.currentStep = '1';
        
        this.confirmationTableData = [];
        this.finalProfessorOptions = [];
        this.selectedMentees = [];
        this.showInlineEditPanel = false;
    }
    prepareConfirmationData() {
        this.showConfirmationModal = false; 
        const validRows = this.tableData.filter(row => row.totalMentees > 0 && (row.professor || row.crossSchoolProfessor));
        if (validRows.length === 0) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'No mentees have been allocated.', variant: 'error' }));
            return;
        }
        const allProfessorsNameMap = new Map();
        [...this.professors, ...this.crossSchoolProfessors].forEach(p => {
            if (p.professor) {
                allProfessorsNameMap.set(p.professor.Id, p.professor.Name);
            }
        });
        let confirmationData = [];
        let sNo = 1;
        const allMentees = this.menteeGroups.flat();
        let menteeIndex = 0;

        validRows.forEach(row => {
            const professorId = row.professor || row.crossSchoolProfessor;
            const professorName = allProfessorsNameMap.get(professorId) || 'Unknown';
            for (let i = 0; i < row.totalMentees; i++) {
                if (menteeIndex < allMentees.length) {
                    const currentMentee = allMentees[menteeIndex];
                    confirmationData.push({
                        sNo: sNo++,
                        Mentee_SRN__c: currentMentee.hed__Contact__r?.SRN_Number__c, 
                        Name: currentMentee.hed__Contact__r?.Name,
                        ContactId: currentMentee.hed__Contact__c,
                        professorId: professorId,
                        professorName: professorName,
                        applicationNumber: currentMentee.hed__Contact__r?.Application_Number__c,
                        section: currentMentee.Section__r.Name
                    });
                    menteeIndex++;
                }
            }
        });
        this.confirmationTableData = confirmationData;
        const finalProfessorMap = new Map();
        this.confirmationTableData.forEach(mentee => {            
            if (!finalProfessorMap.has(mentee.professorId)) {
                finalProfessorMap.set(mentee.professorId, {
                    label: mentee.professorName,
                    value: mentee.professorId
                });
            }
        });
        
        this.finalProfessorOptions = Array.from(finalProfessorMap.values()).sort((a, b) => a.label.localeCompare(b.label));
        this.currentStep = '2'; 
        this.validateConfirmationData(); 
    }
    handleRowSelection(event) {
        this.selectedMentees = event.detail.selectedRows;
        this.showInlineEditPanel = this.selectedMentees.length > 0;
    }

    handleNewProfessorSelection(event) {
        this.newProfessorIdForUpdate = event.detail.value;
    }

    handleCancelInlineUpdate() {
        this.showInlineEditPanel = false;
        this.newProfessorIdForUpdate = '';
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.selectedMentees = [];
    }
    
    handleApplyInlineUpdate() {
        const newProfId = this.newProfessorIdForUpdate;
        if (!newProfId) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'Please select a new mentor to apply.', variant: 'error' }));
            return;
        }

        const selectedContactIds = this.selectedMentees.map(mentee => mentee.ContactId);
        
        const maxMenteesForNewProf = this.professorMaxMentees.get(newProfId) || 0;
        const existingMenteesCount = this.confirmationTableData.filter(
            mentee => mentee.professorId === newProfId && !selectedContactIds.includes(mentee.ContactId)
        ).length;
        const projectedTotal = existingMenteesCount + this.selectedMentees.length;

        if (projectedTotal > maxMenteesForNewProf) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Allocation Error',
                message: `Cannot re-assign. Mentor's max capacity is ${maxMenteesForNewProf}, but this change would assign them ${projectedTotal} mentees.`,
                variant: 'error',
            }));
            return;
        }

        const newProfessorName = this.finalProfessorOptions.find(opt => opt.value === newProfId)?.label;
        let updatedData = [...this.confirmationTableData];
        
        updatedData.forEach(mentee => {
            if (selectedContactIds.includes(mentee.ContactId)) {
                mentee.professorId = newProfId;
                mentee.professorName = newProfessorName;
            }
        });

        this.confirmationTableData = updatedData;
        this.handleCancelInlineUpdate(); 
        this.validateConfirmationData();
    }
   
    validateConfirmationData() {
        const professorAssignmentCount = new Map();
        this.confirmationTableData.forEach(mentee => {
            const professorId = mentee.professorId;
            professorAssignmentCount.set(professorId, (professorAssignmentCount.get(professorId) || 0) + 1);
        });

        let isValid = true;
        professorAssignmentCount.forEach((count, professorId) => {
            const maxMentees = this.professorMaxMentees.get(professorId) || 0;
            if (count > maxMentees) {
                isValid = false;
            }
        });

        this.isSubmitDisabled = !isValid;
    }
    handleConfirmationProfessorChange(event) {
        const srn = event.target.dataset.id;
        const newProfessorId = event.detail.value;

        let menteeToUpdate = this.confirmationTableData.find(m => m.Mentee_SRN__c === srn);
        if (menteeToUpdate) {
            menteeToUpdate.professorId = newProfessorId;
            this.validateConfirmationData(); 
        }
    }
    async handleFinalSubmit() {
        this.isSubmitDisabled = true;         
        try {           
            const allocations = new Map();
            this.confirmationTableData.forEach(mentee => {
                if (!allocations.has(mentee.professorId)) {
                    allocations.set(mentee.professorId, []);
                }
                allocations.get(mentee.professorId).push(mentee.ContactId);
            });

            const allocationDataForApex = {};
            allocations.forEach((value, key) => {
                allocationDataForApex[key] = value;
            });

            await submitMenteeAllocation({
                termId: this.recordId,
                allocationDataStr: JSON.stringify(allocationDataForApex)
            });

            this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: 'Mentee allocation completed successfully!', variant: 'success' }));            
            this.currentStep = '1';           
            this.selectedMentees = [];
            this.showInlineEditPanel = false;
            this.fetchTermDetails(); 

        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: error.body?.message || 'Error submitting allocation.', variant: 'error' }));
            this.isSubmitDisabled = false;
        }
    }
}