import { LightningElement, wire, track,api } from 'lwc';
import getRoomDetails from '@salesforce/apex/rve_InvigilatorAttendenceController.getRoomDetails';
import getRoomQRAttendance from '@salesforce/apex/rve_InvigilatorAttendenceController.getRoomQRAttendance';
import getRoomQRAttendanceDetails from '@salesforce/apex/rve_InvigilatorAttendenceController.getRoomQRAttendanceDetails';
import getProgramBatchTimetableMap from '@salesforce/apex/rve_InvigilatorAttendenceController.getProgramBatchTimetableMap';
import getCustomSettings from '@salesforce/apex/rve_InvigilatorAttendenceController.getCustomSettings';
import insertAttendenceEvent from '@salesforce/apex/rve_InvigilatorAttendenceController.insertAttendenceEvent';
import updateAttendanceCheckbox from '@salesforce/apex/rve_InvigilatorAttendenceController.updateAttendanceCheckbox';
import timeconvertion from '@salesforce/apex/rve_InvigilatorAttendenceController.timeconvertion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
 
export default class AttendanceComponent extends LightningElement {
    @track contactlist = [];
    @track hasRecords=false;
    Settingval;
    @api examdate;
    @api roomname;
    @api shift;
    @api starttime;
    @api endtime;
    @api millisecendtime;
    @api millisecstarttime;
    @api invigilatorrecordid;
    @api qrattendancestatus;
    programBatchTimetableMap;
    @track mapData= {};
     @track mapDataconnection= [];
     @track contactCourseConnectionIdMap;
    attendanceRecords = [];
    attendanceMap;
    roomIds = []; // Array to hold room Ids
    userId = USER_ID;
 
        get processedList() {
        return this.contactlist.map(batchItem => {
            const courseName = this.mapData?.[batchItem.batchName] || 'N/A';
            return { ...batchItem, courseName };
        });
    }   

    @wire(getCustomSettings)
    wiredgetCustomSettings({ error, data }) {
        if (data) {
            this.Settingval = data;

        } else if (error) {
        }
    }
    


    @wire(getRoomDetails, { examdate: '$examdate', shift: '$shift', roomname: '$roomname' , starttime: '$starttime' , endtime: '$endtime'})

    wiredRoomDetails({ error, data }) {
        try{
        if (data) { 
            if (data.length > 0) {
                console.log('Data=> '+JSON.stringify(data));
                this.hasRecords=true
                console.log('data=> '+this.hasRecords);
                // invoke QR attendance 
                // this.loadAttendance();
                this.handleFetchDetails(data); 
                console.log('Status :::'+this.qrattendancestatus);     
                this.getQRAttendanceStatus();    
                console.log('Logged In User Id: ' + this.userId);    
            }
        }
        else {
               // this.hasRecords = false;
                // Handle error
            }
        }
        catch(error){
            console.error('Else part',error.message);

        }
    }
 
    // @wire(getRoomQRAttendance, {
    //         examdate: '$examdate',
    //         roomname: '$roomname',
    //         starttime: '$starttime',
    //         endtime: '$endtime'
    //     })
    //     wiredQRAttendance({ data, error }) {         
    //         if (data) {
    //             // Convert Map<String, Boolean> (returned as plain JS object) to array for rendering
    //             this.attendanceRecords = Object.entries(data).map(([srn, attendanceType]) => ({
    //                 srn,
    //                 attendanceType
    //              //   attendanceLabel: attendanceType ? 'Present' : 'Absent',
    //             //    badgeClass: attendanceType ? 'slds-badge slds-theme_success' : 'slds-badge slds-theme_error'
    //             }));
    //           //  this.error = undefined;
    //           console.log('attendanceRecords ===> ', JSON.stringify(this.attendanceRecords));
    //         } else if (error) {
    //          //   this.error = error?.body?.message || 'An unexpected error occurred.';
    //             this.attendanceRecords = [];
    //         }
    //         // this.isLoading = false;
    //     }

    @wire(getProgramBatchTimetableMap, { examdate: '$examdate', shift: '$shift', roomname: '$roomname' , starttime: '$starttime' , endtime: '$endtime'})

    wiredProgramBatchTimetableMap({ error, data }) {
        {
        if (data) {
             console.log('data**',JSON.stringify(data));

            this.programBatchTimetableMap = data;
            this.contactCourseConnectionIdMap = data.contactCourseConnectionIdMap;            
            this.programBatchCourseNameMap = data.programBatchCourseNameMap;
             console.log('this.programBatchCourseNameMap**',this.programBatchCourseNameMap);
             // eslint-disable-next-line vars-on-top
             for (var key in this.programBatchCourseNameMap) {
                   this.mapData[key] = this.programBatchCourseNameMap[key];
              }
            // eslint-disable-next-line vars-on-top, no-redeclare
            for(var key in this.contactCourseConnectionIdMap){
                this.mapDataconnection.push({value:this.contactCourseConnectionIdMap[key], key:key});
            }
            // Process the map data as needed
        } else if (error) {
            console.error('error=> '+error.message);
        }
    }
    }
 
// Handle changes in attendance checkbox
handleAttendanceChange(event) {
    const batchIndex = event.target.dataset.batchIndex;
    const contactIndex = event.target.dataset.contactIndex;
    const checked = event.target.checked;
 
    this.contactlist[batchIndex].contacts[contactIndex].Attendancecheckbox = checked;
 
}

// Handle changes in Malpracticesattendance checkbox
handlemalpracticesChange(event) {
    const batchIndex = event.target.dataset.batchIndex;
    const contactIndex = event.target.dataset.contactIndex;
    const Malpracticeschecked = event.target.checked;
 
    this.contactlist[batchIndex].contacts[contactIndex].malpracticescheckbox = Malpracticeschecked;

}
 
 
// Handle changes in description input
handleDescriptionChange(event) {
    const batchIndex = event.target.dataset.batchIndex;
    const contactIndex = event.target.dataset.contactIndex;
    const description = event.target.value;
 
    this.contactlist[batchIndex].contacts[contactIndex].description = description;
 
} 
 
async saveAttendance(event) {    
     
            
      let attendanceEvent = [];
    // Create a new Date object representing the current date and time
    const currentDate = new Date();
     // Get only the date portion in "YYYY-MM-DD" format
    const formattedDate = currentDate.toLocaleDateString('en-US');
        const options = { timeZone: 'Asia/Kolkata', year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' };
      //  const formattedDate = currentDate.toLocaleString('en-IN', options);
    //  console.log('date >>>', JSON.stringify(formattedDate)); 


    this.contactlist.forEach(batchItem => {
        batchItem.contacts.forEach(contact => {
            // console.log('0');

         // Find the corresponding connection ID from mapDataconnection
            let courseConnectionId = null;
            for (let key in this.contactCourseConnectionIdMap) {
                if (key === contact.contactid) {
                    courseConnectionId = this.contactCourseConnectionIdMap[contact.contactid];
                    // console.log('course connection Id >>>', courseConnectionId);
                    break;
                }               
            }

            attendanceEvent.push({
                
                hed_IA_Remarks__c: contact.description,
                hed__Contact__c: contact.contactid,
                hed__Date__c: formattedDate,
                hed__Attendance_Type__c: contact.Attendancecheckbox ? 'Present' : 'Absent',
                hed_Malpractice__c: contact.malpracticescheckbox,
                hed__Start_Time__c: this.millisecstarttime,
                hed__End_Time__c: this.millisecendtime,
                rve_Room_Number__c: this.roomname,
                hed__Course_Connection__c: courseConnectionId, // Add course connection ID
                Exam_Attendance__c: true
                
            });
        });
    });

        // console.log('6');
        // console.log('attendance>>>', JSON.stringify(attendanceEvent));

        const action = event.target.dataset.action;

        if (attendanceEvent.length > 0) {
            // console.log('1');
            // , actionType : action, examDate : formattedDate, startTime : this.millisecstarttime, endTime:  
                insertAttendenceEvent({ attendance: attendanceEvent })
                    .then(result => {
        
                        // Show success toast message
                        const evt = new ShowToastEvent({
                            title: 'Success!',
                            message: 'Records inserted successfully',
                            variant: 'success'
                        });
                        this.dispatchEvent(evt);
                    //  location.reload();
        
                    })
                    .catch(error => {
                        console.log('ERROR : An error occured while inserting / updating records '+error);
                    });

                    console.log('this.invigilatorrecordid'+this.invigilatorrecordid);
                    if(this.invigilatorrecordid != null){
                        // console.log('2');
                                updateAttendanceCheckbox({ recordId: this.invigilatorrecordid })
                            .then(result => {
                                location.reload();

                            })
                            .catch(error => {
                                    // Handle error
                            });
                    }                
                     
        }
}

    loadAttendance() {
        console.log('Calling Apex with params:',
        JSON.stringify({
            examdate: this.examdate,
            roomname: this.roomname,
            starttime: this.starttime,
            endtime: this.endtime
        })
    );

        getRoomQRAttendance({
            examdate: this.examdate,
            roomname: this.roomname,
            starttime: this.starttime,
            endtime: this.endtime
        })
        .then(data => {
            this.attendanceRecords = Object.entries(data).map(([srn, attendanceType]) => ({
                srn,
                attendanceType
            }));
            console.log('attendanceRecords ===> ', JSON.stringify(this.attendanceRecords));
        })
        .catch(error => {
            console.error(error);
        });
    }   

    // handleFetchDetails() {
    //     // Format the times before sending to Apex
    //     const formattedStart = this.formatTimeForApex(this.starttime);
    //     const formattedEnd = this.formatTimeForApex(this.endtime);

    //     getRoomQRAttendanceDetails({
    //         examdate: this.examdate,
    //         roomname: this.roomname,
    //         starttime: formattedStart,
    //         endtime: formattedEnd
    //     })
    //     .then((result) => {
    //         this.attendanceMap = result;
    //       //  this.error = undefined;
    //         console.log('Result from Apex1:', result);
    //     })
    //     .catch((error) => {
    //      //   this.error = error;
    //         this.attendanceMap = undefined;
    //         console.error('Error calling Apex:', error);
    //     });
    // }

    formatTimeForApex(timeStr) {
    if (!timeStr) return null;
    
        // Parse the "2:00:00 PM" string
        const dateObj = new Date("1970-01-01 " + timeStr);
        
        // Get 24-hour format: "14:00"
        const hours = String(dateObj.getHours()).padStart(2, '0');
        const minutes = String(dateObj.getMinutes()).padStart(2, '0');
        
        return `${hours}:${minutes}`; 
    }

    handleFetchDetails(data) {
        const formattedStart = this.formatTimeForApex(this.starttime);
        const formattedEnd = this.formatTimeForApex(this.endtime);

        getRoomQRAttendanceDetails({
            examdate: this.examdate,
            roomname: this.roomname,
            starttime: formattedStart,
            endtime: formattedEnd
        })
        .then(result => {
            this.attendanceMap = result;
            console.log('Result from Apex1:', result);
            console.log('attendance Map Data :'+this.attendanceMap['R25EF154']);
            // Extract grouped contacts from Data
            const groupedContacts = {};
                try{
                    data.forEach(contact => {
                    //  console.log('ProgramBatch=> ', contact.Program_Batch__r ? contact.Program_Batch__r.Name : 'No Program Batch');
                            if (contact.Program_Batch__r && contact.Program_Batch__r.Name) {

                                if (!groupedContacts[contact.Program_Batch__r.Name]) {
                                    groupedContacts[contact.Program_Batch__r.Name] = [];
                                }
                                groupedContacts[contact.Program_Batch__r.Name].push({
                                    SRNNo: contact.SRN_Number__c,
                                    cname: contact.Name,
                                    Attendancecheckbox: true,
                                    malpracticescheckbox: false,
                                    description: '',
                                    contactid: contact.Id,
                                    QRAttendanceCheckbox:this.attendanceMap[contact.SRN_Number__c]
                                });
                        }
                    });
                    this.contactlist = Object.keys(groupedContacts).map(batchName => ({
                        batchName: batchName,
                        contacts: groupedContacts[batchName]
                    }));
                }
                catch(error){
                  console.error('Inside Inner try',error.message);
                }

                //console.log('contacts=> '+JSON.stringify(this.contactlist));
                //console.log('contactsize=> '+this.contactlist.length);

                this.roomIds = data.map(contact => contact.Id); // Populate room Ids array  

        })
        .catch(error => {
            console.error('Final Error Check:', error.body.message);
        });
    }

    getQRAttendanceStatus(){
        console.log('qrattendancestatus : '+this.qrattendancestatus);
        return this.qrattendancestatus;
    }   

}