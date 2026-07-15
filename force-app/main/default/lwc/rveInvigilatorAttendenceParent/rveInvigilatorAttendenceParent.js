import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchInvigilatorDetails from '@salesforce/apex/rveInvigilatorAttendenceParent.fetchInvigilatorDetails';

export default class RveInvigilatorAttendanceParent extends LightningElement {
    @track invigilatorAssignments = [];
    @track Selected = false;
    @track hasRecords=true;
    Shifts;
    Timevaluefromlwc;
    add2HoursString;
    minus30MinutesString;
    selectedAssignment;
   
    

    @wire(fetchInvigilatorDetails)
    wiredInvigilatorAssignments({ error, data }) {
        if (data) {
            let k = 0;
            if (data.length > 0) {
                console.log('data=> '+JSON.stringify(data));
                for (let invigilator of data) {

                    k++;
                    // convert the start time from milliseconts to salesforce standard time
                     let hours1 = Math.floor(invigilator.rve_Exam_Time__c / (1000 * 60 * 60));
                        let minutes1 = Math.floor((invigilator.rve_Exam_Time__c % (1000 * 60 * 60)) / (1000 * 60));
                        let seconds1 = Math.floor((invigilator.rve_Exam_Time__c % (1000 * 60)) / 1000);
                   
                        // Add leading zeros if necessary
                        hours1 = (hours1 < 10) ? "0" + hours1 : hours1;
                        minutes1 = (minutes1 < 10) ? "0" + minutes1 : minutes1;
                        seconds1 = (seconds1 < 10) ? "0" + seconds1 : seconds1;
                   
                        // Add AM or PM based on hours
                        let ampm1 = (hours1 >= 12) ? "PM" : "AM";
                        hours1 = (hours1 % 12 === 0) ? 12 : hours1 % 12; // Convert 0 to 12 for 12-hour format
                   
                        // Construct the formatted time string
                        let formattedStartTime = hours1 + ":" + minutes1 + ":" + seconds1 + " " + ampm1;



                         // convert the endtime from milliseconts to salesforce standard time
                        let hours = Math.floor(invigilator.rve_Exam_End_Time__c / (1000 * 60 * 60));
                        let minutes = Math.floor((invigilator.rve_Exam_End_Time__c % (1000 * 60 * 60)) / (1000 * 60));
                        let seconds = Math.floor((invigilator.rve_Exam_End_Time__c % (1000 * 60)) / 1000);
                   
                        // Add leading zeros if necessary
                        hours = (hours < 10) ? "0" + hours : hours;
                        minutes = (minutes < 10) ? "0" + minutes : minutes;
                        seconds = (seconds < 10) ? "0" + seconds : seconds;
                   
                        // Add AM or PM based on hours
                        let ampm = (hours >= 12) ? "PM" : "AM";
                        hours = (hours % 12 === 0) ? 12 : hours % 12; // Convert 0 to 12 for 12-hour format
                   
                        // Construct the formatted time string
                        let formattedEndTime = hours + ":" + minutes + ":" + seconds + " " + ampm;
                        let attendanceType = invigilator.QR_Attendance_Update__c ? 'QR Attendance' : 'Manual Attendance';
                    const invigilatorassign = {
                        index: k,
                        id: invigilator.Id,
                        name: invigilator.Name,
                        rve_Shift__c: invigilator.rve_Shift__c,
                        rve_Date__c: invigilator.rve_Date__c,
                        starttime: formattedStartTime,
                        endtime: formattedEndTime,
                        attendancecheckbox: invigilator.rve_Attendance_Submitted__c,
                        millisecstarttime :invigilator.rve_Exam_Time__c,
                        millisecendtime : invigilator.rve_Exam_End_Time__c,
                        AttendanceMarkedType : attendanceType,
                        QRAttendanceStatus : invigilator.QR_Attendance_Update__c
                    };
                    this.invigilatorAssignments.push(invigilatorassign);
                    
                   
                    }
            } else {
                console.log(this.hasRecords);
            }
        } else if (error) {
                            this.hasRecords = false;

        }
    }

    ConvertToTimeFormat(Data){
         let hours = Math.floor(Data / (1000 * 60 * 60));
                        let minutes = Math.floor((Data % (1000 * 60 * 60)) / (1000 * 60));
                        let seconds = Math.floor((Data % (1000 * 60)) / 1000);
                   
                        // Add leading zeros if necessary
                        hours = (hours < 10) ? "0" + hours : hours;
                        minutes = (minutes < 10) ? "0" + minutes : minutes;
                        seconds = (seconds < 10) ? "0" + seconds : seconds;
                   
                        // Add AM or PM based on hours
                        let ampm = (hours >= 12) ? "PM" : "AM";
                        hours = (hours % 12 === 0) ? 12 : hours % 12; // Convert 0 to 12 for 12-hour format
                   
                        // Construct the formatted time string
                        let formattedTime = hours + ":" + minutes + ":" + seconds + " " + ampm;
                        return formattedTime;
    }

    handleCancel() {
        // Reset the selected values and hide the "Cancel" button
        this.selectedRecordId = '';
        this.selectedSchoolName = '';
        this.Selected = false;
    }

    handleView(event) {
      
    this.Selected = true;
    const index = event.target.dataset.id;

    // Find the selected assignment
    this.selectedAssignment = this.invigilatorAssignments.find(assignment => assignment.index == index);
    console.log('this.selectedAssignment=> '+JSON.stringify(this.selectedAssignment));
     if (this.selectedAssignment.attendancecheckbox) {
            // Attendance already submitted, show toast message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Attendance is already submitted.',
                    variant: 'error'
                })
            );
        } else {
            console.log('In Else=> '+this.Selected)
            // Allow to submit attendance
            this.Selected = true;
            console.log('Selected=> '+this.Selected);
        }

  
}
}