import { LightningElement, track, wire, api } from 'lwc';
import getRoomNumbers from '@salesforce/apex/rve_InvigilatorAssignmentController.getRoomNumbers';
import getProfessors from '@salesforce/apex/rve_InvigilatorAssignmentController.getProfessors';
import insertInvigilatorAssignments from '@salesforce/apex/rve_InvigilatorAssignmentController.insertInvigilatorAssignments';
import getExistingInvigilatorAssignments from '@salesforce/apex/rve_InvigilatorAssignmentController.getExistingInvigilatorAssignments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RveInvigilatorAssignment extends LightningElement {
    @track roomAssignments = [];
    @track professors = [];
    @api isShowModal;
    existedAssignment=false;
    roomIds = [];
    validationVal=false;
    professorIds = [];
    Actualdate;
    existingAssignmentsMap = {};
    connectedCallback() {
        this.fetchData();
    }

    fetchData() {
       getRoomNumbers()
    .then(result => {
        this.roomAssignments = result.map(roomNumber => {
           
            // Convert time from milliseconds to a Date object
            const examTimeUTC = new Date(roomNumber.Exam_Time__c);
            this.Actualdate = roomNumber.Exam_Time__c;
            
            // Convert UTC time to local time
            const examTimeLocal = new Date(examTimeUTC.getTime() + examTimeUTC.getTimezoneOffset() * 60000);

            // Get hours and minutes
            let hours = examTimeLocal.getHours();
            const minutes = examTimeLocal.getMinutes();

            // Determine AM/PM
            const meridiem = hours >= 12 ? 'PM' : 'AM';
            
            // Convert hours to 12-hour format
            hours = hours % 12;
            hours = hours ? hours : 12; // If hours is 0, set it to 12
            
            return {
                Room_Number__c: roomNumber.Room__c,
                selectedProfessor: '',
                Date: roomNumber.rve_Date_of_Exam__c,
                Shift: roomNumber.rveShift__c,
                Time: `${hours}:${minutes < 10 ? '0' : ''}${minutes} ${meridiem}`, // Format time as HH:MM AM/PM
                actualtime: roomNumber.Exam_Time__c,
                endtime: roomNumber.End_Time__c,
                roomId: roomNumber.Id
            };
        });
        this.roomIds = result.map(room => room.Id);
    })
    .catch(error => {
        // Handle error
    });

       getProfessors()
            .then(result => {
                this.professors = result.map(professor => {
                    return {
                        label: professor.Name,
                        value: professor.Id
                    };
                });
                this.professorIds = result.map(professor => professor.Id);
            })
            .catch(error => {
                // Handle error
            });

       
    }

     // Fetch existing assignments from the database
    getExistingProfessor(professor, date, shift,Time) {
    return getExistingInvigilatorAssignments({professors: professor, dates: date, shifts: shift, Times: Time})
        .then(result => {
            const retVal = result.length>0;
            //this.existedAssignment = retVal;
            return retVal;
        })
        .catch(error => {
            throw error; // re-throw the error to be caught by the caller
        });
}


     async handleProfessorChange(event) {
    const index = event.detail.indexval;
    const selectedProfessor = event.detail.selectedRecord;

    const existingAssignment = this.roomAssignments.find(assignment => 
        assignment.selectedProfessor === selectedProfessor &&
        assignment.Date === this.roomAssignments[index].Date &&
        assignment.Shift === this.roomAssignments[index].Shift &&
        assignment.actualtime === this.roomAssignments[index].actualtime 
    );

    const prof = selectedProfessor;//this.roomAssignments[index].selectedProfessor;
    const dateval = this.roomAssignments[   index].Date;
    const shiftval = this.roomAssignments[index].Shift;
    const timeval = this.roomAssignments[index].actualtime;

    if (existingAssignment) {
        this.validationVal=true;
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'This assignment already exists.',
            variant: 'error'
        });
        this.dispatchEvent(evt);

        this.roomAssignments[index].selectedProfessor = '';
    } else {
        this.validationVal=false;
        this.roomAssignments[index].selectedProfessor = selectedProfessor;


        try {
            const retVal2 = await this.getExistingProfessor(prof, dateval, shiftval, timeval );

            if (retVal2) {
                this.validationVal=true;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'This assignment already exists.',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }else{
               this.validationVal=false; 
            }
        } catch (error) {
        }
    }
}



    assignInvigilator() {
    let invigilatorAssignments = [];
    let duplicateFound = false;
    let conflictFound = false;

    // Check if any room assignments do not have a selected professor
    const unassignedRooms = this.roomAssignments.filter(record => record.selectedProfessor === '');


    if (unassignedRooms.length == this.roomAssignments.length) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Please select a professor for assignments.',
            variant: 'error'
        });
        this.dispatchEvent(evt);
        return; // Stop further execution
    }

    this.roomAssignments.forEach((record, index) => {
        if (record.selectedProfessor !== '') {
            invigilatorAssignments.push({
                rve_Professor__c: record.selectedProfessor,
                rve_Date__c: record.Date,
                rve_Shift__c: record.Shift,
                rve_Room_Allotment__c: record.roomId,
                rve_Exam_Time__c: record.actualtime,
                rve_Exam_End_Time__c: record.endtime,
                Name: record.Room_Number__c
            });
        }
    });

    invigilatorAssignments.forEach(newAssignment => {
        if (this.existingAssignmentsMap[newAssignment.rve_Room_Allotment__c]) {
            duplicateFound = true;
        }

        Object.values(this.existingAssignmentsMap).forEach(existingAssignment => {
            if (existingAssignment.rve_Professor__c === newAssignment.rve_Professor__c &&
                existingAssignment.rve_Date__c === newAssignment.rve_Date__c &&
                existingAssignment.rve_Shift__c === newAssignment.rve_Shift__c &&
                existingAssignment.rve_Exam_Time__c === newAssignment.rve_Exam_Time__c &&
                existingAssignment.rve_Room_Allotment__c === newAssignment.rve_Room_Allotment__c) {
                conflictFound = true;
            }
        });
    });

    if (duplicateFound) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Duplicate records found. Please remove duplicates.',
            variant: 'error'
        });
        this.dispatchEvent(evt);
    } else if (conflictFound) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Conflicting assignments found. Please assign different professors.',
            variant: 'error'
        });
        this.dispatchEvent(evt);
    } else {
        insertInvigilatorAssignments({ invigilatorAssigned: invigilatorAssignments })
            .then(result => {
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Records inserted successfully',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
                window.location.reload();
                this.hideModalBox();

            })
            .catch(error => {
                // Handle error
            });
    }
}


   

    hideModalBox() {
        this.isShowModal = false;
        this.progress();
    }
     progress() {
        const dataToPass = 'Data you want to pass';
        const event = new CustomEvent('passdata', { detail: { data: this.isShowModal } });
        this.dispatchEvent(event);
    }


   
}