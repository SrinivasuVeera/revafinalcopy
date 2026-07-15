import { LightningElement, track, wire } from 'lwc';
    import getInvigilatorAssignments from '@salesforce/apex/rve_InvigilatorAssignmentEdit.getInvigilatorAssignments';
    import updateProfessor from '@salesforce/apex/rve_InvigilatorAssignmentEdit.updateProfessor';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import ShowToastEvent
    import { refreshApex } from '@salesforce/apex'; // Import refreshApex to refresh the component data




    export default class RveInvigilatorAssignmentEdit extends LightningElement {
        @track roomAssignments = [];
        isModalOpen = false; // Track whether the modal is open
        selectedAssignmentId; // Track the assignment ID being edited

        connectedCallback() {
            this.fetchData();
        }

        fetchData() {
            getInvigilatorAssignments()
                .then(result => {
                    this.roomAssignments = result.map(roomassig => {
                        // Convert time from milliseconds to a Date object
                        const examTimeUTC = new Date(roomassig.rve_Exam_Time__c);

                        // Convert UTC time to local time
                        const examTimeLocal = new Date(examTimeUTC.getTime() + examTimeUTC.getTimezoneOffset() * 60000);

                        // Get hours and minutes
                        let hours = examTimeLocal.getHours();const minutes = examTimeLocal.getMinutes();

                        // Determine AM/PM
                        const meridiem = hours >= 12 ? 'PM' : 'AM';

                        // Convert hours to 12-hour format
                        hours = hours % 12;
                        hours = hours ? hours : 12; // If hours is 0, set it to 12

                        return {
                            Room: roomassig.Name,
                            selectedProfessor: roomassig.rve_Professor__r.Name,
                            Date: roomassig.rve_Date__c,
                            Shift: roomassig.rve_Shift__c,
                            Time: `${hours}:${minutes < 10 ? '0' : ''}${minutes} ${meridiem}`,
                            actualtime: roomassig.rve_Exam_Time__c,
                            Id: roomassig.Id,
                            isEditMode: false
                        };

                    });
 
                })
                .catch();
        }

        handleEditClick(event) {
            const assignmentId = event.target.dataset.id;
            this.selectedAssignmentId = assignmentId; // Storing the assignmentId
            this.setEditMode(assignmentId, true);
        }

    handleSaveClick(event) {
        
            const assignmentId = event.target.dataset.id;
            const selectedProfessorId = this.selectedProfessor;

            updateProfessor({ assignmentId: assignmentId, professorId: selectedProfessorId })
                .then(() => {
                   
                    this.showToast('Success', 'Professor updated successfully', 'success');
                     window.location.reload();
                // return refreshApex(this.roomAssignments); // Refresh the component data
                
                })
                .catch(error => {
                    console.error('Error updating professor:', error);
                    this.showToast('Error', 'Failed to update professor', 'error');
                })
                .finally(() => {
                    this.setEditMode(assignmentId, false);
                });
        }

        setEditMode(assignmentId, isEditMode) {
            this.roomAssignments = this.roomAssignments.map(assignment => {
                if (assignment.Id === assignmentId) {
                    assignment.isEditMode = isEditMode;
                } else {
                    assignment.isEditMode = false;
                }
                return assignment;
            });
        }

 async handleProfessorChange(event) {

    const index = event.detail.indexval;
    const selectedRecordName = event.detail.selectedRecordName;
   
    const selectedProfessorId = event.detail.selectedRecord;
    const assignmentId = this.selectedAssignmentId; // Accessing stored assignmentId

    this.selectedProfessor = selectedProfessorId;


    // Check if there is an existing assignment with the same date, shift, time, and professor
    const existingAssignment = this.roomAssignments.find(assignment => 
   
        assignment.selectedProfessor === selectedRecordName &&
        assignment.Date === this.roomAssignments[index].Date &&
        assignment.Shift === this.roomAssignments[index].Shift &&
        assignment.Time === this.roomAssignments[index].Time 
    );
       
    if (existingAssignment) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'This assignment already exists.',
            variant: 'error'
        });
        this.dispatchEvent(evt);

        // Reset selected professor to prevent assignment
        this.selectedProfessor = '';
    } else {
        // Perform logic to handle the professor change for the selected assignment
     
        // Close the modal after handling the professor change
        this.isModalOpen = false;
    }
}


        showToast(title, message, variant) {
            const evt = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            });
            this.dispatchEvent(evt);
        }
    }