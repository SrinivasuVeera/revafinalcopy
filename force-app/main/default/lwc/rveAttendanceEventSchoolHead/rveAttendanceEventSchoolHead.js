import { LightningElement, wire, track,api } from 'lwc';
import insertAttendenceEvent from '@salesforce/apex/rve_InvigilatorAttendenceController.insertAttendenceEvent';
import updateAttendanceCheckbox from '@salesforce/apex/rve_InvigilatorAttendenceController.updateAttendanceCheckbox';
import updateRecords from '@salesforce/apex/rveAttendanceEventHandler.updateRecords';
import checkInvigilatorAssignment from '@salesforce/apex/rveAttendanceEventHandler.checkInvigilatorAssignment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class RveAttendanceEventSchoolHead extends LightningElement {
    @track contactlist = [];
    Settingval;
    @api examdate;
    @api roomname;
    @api shift;
    @api starttime;
    @api endtime;
    @api millisecendtime;
    @api millisecstarttime;
    @api invigilatorrecordid;
    @track checkStudents = false
    @track Attendancelist = [];
    @track hasRecords=false;
    @track date;
    @track displayedRecords = []; // Records to be displayed on the current page
    @track pageNumber = 0; // Current page number
    pageSize = 10; 
    checkStudents;
    @track Allrecords=[]
    @track totalPages;
    @track RoomNo;
    @track StartTime;
    @track AttendanceDate;
    @track EnableAttendanceList=true;
    @track showToastMessage=false;

 
    roomIds = []; // Array to hold room Ids
 
 
    wiredRoomDetails(ContactDetails) {

        if (ContactDetails) { 
            if (ContactDetails.length > 0) {
                this.hasRecords = true;
       
                const groupedContacts = {};
                ContactDetails.forEach(contact => {
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
                        rve_Room_Number__c: this.RoomNo

                    });
 
                });
                this.contactlist = Object.keys(groupedContacts).map(batchName => ({
                    batchName: batchName,
                    contacts: groupedContacts[batchName]
                }));
 
            this.roomIds = ContactDetails.map(contact => contact.Id); // Populate room Ids array
            }
            else {
                this.hasRecords = false;
                // Handle error
            }
        }
    }
 
// Handle changes in attendance checkbox
handleAttendanceChange1(event) {
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
 
 
async saveAttendance() {

      let attendanceEvent = [];
 
    // Create a new Date object representing the current date and time
    const currentDate = new Date();
 
    // Get only the date portion in "YYYY-MM-DD" format
    const formattedDate = currentDate.toLocaleDateString('en-US');

    // console.log('formattedDate=> '+formattedDate);
    // console.log('contactlist=> '+JSON.stringify(this.contactlist));

    this.contactlist.forEach(batchItem => {
        batchItem.contacts.forEach(contact => {
 
// console.log('desc=> '+contact.description+' Id=> '+contact.contactid+' checkbox=> '+contact.Attendancecheckbox);
// console.log('mal=> '+contact.malpracticescheckbox+' start=> '+this.millisecstarttime+' end=> '+this.millisecendtime)
 //console.log('course=> '+courseConnectionId);
            attendanceEvent.push({
                hed_IA_Remarks__c: contact.description,
                hed__Contact__c: contact.contactid,
                hed__Date__c: formattedDate,
                hed__Attendance_Type__c: contact.Attendancecheckbox ? 'Present' : 'Absent',
                hed_Malpractice__c: contact.malpracticescheckbox ,
                hed__Start_Time__c: this.millisecstarttime,
                hed__End_Time__c: this.millisecendtime,
                rve_Room_Number__c: this.RoomNo,
           //     hed__Course_Connection__c: courseConnectionId, // Add course connection ID
                Exam_Attendance__c: true// Add course connection ID
            });
        });
    });
 
     console.log('attendanceEvent=> '+JSON.stringify(attendanceEvent))
 
    if (attendanceEvent.length > 0) {
        insertAttendenceEvent({ attendance: attendanceEvent })
            .then(result => {
 
              //  if(result == 'Success'){
                // Show success toast message
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Records inserted successfully',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
                // location.reload
                // }
 
            })
            .catch(error => {
                console.error('ErrorName=> '+error.name+' Error=> '+error.message);
            });
 
            console.log('InvigilatorRecordId=> '+this.invigilatorrecordid);
            if(this.invigilatorrecordid != null){
                updateAttendanceCheckbox({ recordId: this.invigilatorrecordid })
                .then(result => {
               /*      const customEvent = new CustomEvent('passvalue', {
                          detail: inputValue
                     });
                      this.dispatchEvent(customEvent);
  */
                    })
            .catch(error => {
                console.error('ErrorName=> '+error.name+' Error=> '+error.message);
            });
            }
        }
    }
// Update Starts from Here /////////////////////////////////////////////////////////////////////////////////



roomIds = []; // Array to hold room Ids

picklistOptions =[ 
    { label: 'Present', value: 'Present' },
    { label: 'Absent', value: 'Absent' }
    
];

 handleRoomNo(event){
    this.RoomNo = event.target.value;
 }

 DateWiseAttendance(event){
    this.AttendanceDate = event.target.value;
 }

 handleStartTime(event){
    this.StartTime = event.target.value;
    if(this.RoomNo!=null && this.StartTime!=null && this.AttendanceDate!=null)
    this.EnableAttendanceList = false
 }

 async handleProfessorChange(event) {
    const index = event.detail.indexval;
    this.professorId = event.detail.selectedRecord;
 }
 

 Search(event){
   let dateObject = new Date(this.AttendanceDate);

// Format the date as required (YYYY-MM-DD)
   let formattedDate = dateObject.toISOString().split('T')[0];
   checkInvigilatorAssignment({
    RoomNo:this.RoomNo,
    AttendanceDate:formattedDate,
    AttendanceTime:this.StartTime,
    ProfessorId:this.professorId
   })
   .then(res=>{
  
    this.invigilatorrecordid = res.InvigilatorRecordId;
    this.millisecstarttime = res.StartTime;
    this.millisecendtime = res.EndTime;
    if(res.AttendanceList.length>0)
    {

        this.Attendancelist=[]
        this.Allrecords = []
        let Attendances = JSON.parse(JSON.stringify(res.AttendanceList));
        this.totalPages = Math.ceil(res.AttendanceList.length / this.pageSize);
    
        let k=0;
        if(res.AttendanceList.length>0)
        {
            this.checkStudents = true
        for(let i of Attendances)
        {
            let Arrival;
           
                let hours = Math.floor(i.hed__Start_Time__c / (1000 * 60 * 60)).toString().padStart(2, '0');
                let minutes = Math.floor((i.hed__Start_Time__c % (1000 * 60 * 60)) / (1000 * 60)).toString().padStart(2, '0');
           //let seconds = Math.floor((i.hed__Start_Time__c % (1000 * 60)) / 1000);
    
             Arrival = hours+':'+minutes
             if(hours>12)
             {
                 Arrival = hours+':'+minutes+' pm'
             }
             else if(hours<12){
                 Arrival = hours+':'+minutes+' am'
             }
             else{
                Arrival = ''
            }

            k++
            const Attendance = {
                index:k,
                Id:i.Id,
                SRN:i.hed__Contact__r.SRN_Number__c,
                Name:i.hed__Contact__r.Name,
                hed__Attendance_Type__c:i.hed__Attendance_Type__c,
                hed__Start_Time__c:Arrival,
                hed_IA_Remarks__c:i.hed_IA_Remarks__c
            } 
             this.Allrecords.push(Attendance);
    
        }
        const start = this.pageNumber * this.pageSize;
        const end = start + this.pageSize;
        this.Attendancelist = this.Allrecords.slice(start, end);

    }
    else{
        this.checkStudents = false
    }
}
else{
    this.wiredRoomDetails(res.ContactList)
}
})
 }

   
get isFirstPage() {
    return this.pageNumber === 0;
}

get isLastPage() {
    return this.totalPages > 0 && this.pageNumber === this.totalPages - 1;
}

get currentPage() {
    return this.pageNumber + 1;
}

previousPage() {
    if (!this.isFirstPage) {
        this.pageNumber--;
        this.updateDisplayedRecords();
    }
}

nextPage() {
    if (this.totalPages > 0 && !this.isLastPage) {
        this.pageNumber++;
        this.updateDisplayedRecords();
    }
}

updateDisplayedRecords() {

    const start = this.pageNumber * this.pageSize;
    const end = start + this.pageSize;
    this.Attendancelist = this.Allrecords.slice(start, end);

}

handleAttendanceChange(event) {
    const Attendance = event.target.value;
            const index = event.target.dataset.id;
            this.Attendancelist.forEach(e => {
                if(e.index == index) {
                            e.hed__Attendance_Type__c = Attendance;
                }
            });
}

handleArrivalTimeChange(event) {
    const Arrival = event.target.value;
            const index = event.target.dataset.id;
            this.Attendancelist.forEach(e => {
                if(e.index == index) {
                            e.hed__Start_Time__c = Arrival;
                }
            });
        
}
handleIARemarksChange(event) {
    const IARemarks = event.target.value;
            const index = event.target.dataset.id;
            this.Attendancelist.forEach(e => {
                if(e.index == index) {
                            e.hed_IA_Remarks__c = IARemarks;
                }
            });
         
}
submit(event) {
    for (let i of this.Attendancelist) {
        // Replacing 'am' or 'pm' with the appropriate format
        i.hed__Start_Time__c = i.hed__Start_Time__c.replace(' am', ":00.000");
        i.hed__Start_Time__c = i.hed__Start_Time__c.replace(' pm', ":00.000");
    }

    updateRecords({ Attendancelist: this.Attendancelist })
        .then(result => {
            if (result === 'success') {
                // Show success toast message
                this.showToast('Success!', 'Records Updated Successfully', 'success');

                // Hold the toast for 10 seconds before hiding it (optional for custom implementation)
                this.showToastMessage = true;  // Optional if you have a custom toast mechanism
                setTimeout(() => {
                    this.showToastMessage = false;
                }, 10000);

                // Reload the page after success
                window.location.reload();
            } else {
                // Show error toast message if unexpected response
                this.showToast('Error', 'Unexpected response: ' + result, 'error');
            }
        })
        .catch(error => {
            // Show error toast message in case of exception
            let errorMessage = (error && error.body && error.body.message) ? error.body.message : 'Unknown error';
            this.showToast('Error', 'An error occurred: ' + errorMessage, 'error');
        });
}

showToast(title, message, variant) {
    const toastEvent = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(toastEvent);
}
}