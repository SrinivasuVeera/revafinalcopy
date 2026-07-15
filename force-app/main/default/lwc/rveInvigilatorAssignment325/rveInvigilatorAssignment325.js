import { LightningElement,track,api } from 'lwc';
import getAllotmentDates from '@salesforce/apex/rveInvigilatorAssignment325Controller.getAllotmentDates';
import assignInvigilator from '@salesforce/apex/rveInvigilatorAssignment325Controller.assignInvigilator';
import createInvigilatorAssignments from '@salesforce/apex/rveInvigilatorAssignment325Controller.createInvigilatorAssignments';
import checkAllotments from '@salesforce/apex/rveInvigilatorAssignment325Controller.checkAllotments';
import checkExistingInvigilatorAssignment from '@salesforce/apex/rveInvigilatorAssignment325Controller.checkExistingInvigilatorAssignment';
import updateAllotment from '@salesforce/apex/rveInvigilatorAssignment325Controller.updateAllotment';
import checkExistingInvigilatorRecord from '@salesforce/apex/rveInvigilatorAssignment325Controller.checkExistingInvigilatorRecord';
import getSlots from '@salesforce/apex/rveInvigilatorAssignment325Controller.getSlots';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
export default class RveInvigilatorAssignment325 extends LightningElement {

IAType;
disableAllocation=false;
isAllocationEnable=false;
isCreateNew = false;
isUpdate = false;
objectApiName;
disableUpdate=false;
@track combinedMap = {};
disableProfessorSelection=false;
timeSlot;
isLoading = false; // 🔄 Spinner flag


@track IAOptions= [
    { label: 'IA1', value: 'IA 1' },
    { label: 'IA2', value: 'IA 2' }
];

@track session=[{label:'Morning',value:'Morning'},
                {label:'Afternoon',value:'Afternoon'}]; 
                

matchingInfos = {
Contact: {
additionalFields: [{ fieldPath: 'Name' }]
}
};

 contactFilter = {
     criteria: [
         {
            fieldPath: "Profile.Name",
             operator: "eq",  // or "equals"
             value: "Professor"
             /*fieldPath: "RecordType.Name",
             operator: "eq",  // or "equals"
             value: "Professor"*/
         }
     ]
 };

@track allotmentDates = [];
@track DateFound = false;
@track invigilatorRecords = [];

DateNotFound=false;
selectedDate;
selectedSession;
searchValue = '';
selectedSlots;

handleIATypeChange(event) {
    this.IAType = event.detail.value;
    
    getAllotmentDates({
        IAType: this.IAType
    })
    .then(res=>{
       
        if(res.length > 0){
            this.DateFound = true;
        
        this.allotmentDates = []; // Clear/reset the list

        for (let i = 0; i < res.length; i++) {
        let dateVal = res[i].rve_Date_of_Exam__c;

       // Convert to dd/mm/yyyy
        const dateObj = new Date(dateVal);
        const day = String(dateObj.getDate()).padStart(2, '0');
        const month = String(dateObj.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        const year = dateObj.getFullYear();
     
        // Store in a sortable format internally

        const sortableDate = `${year}/${month}/${day}`;
        const displayDate = `${day}/${month}/${year}`;

        if (!this.allotmentDates.some(date => date.value === sortableDate)) {
        this.allotmentDates.push({ label: displayDate, value: sortableDate });
        }

        // Sort properly by date
        this.allotmentDates.sort((a, b) => new Date(a.value) - new Date(b.value));

        // Convert back to DD/MM/YYYY after sorting
        this.allotmentDates.forEach(date => {
        const sortedDateObj = new Date(date.value);
        date.label = `${String(sortedDateObj.getDate()).padStart(2, '0')}/${String(sortedDateObj.getMonth() + 1).padStart(2, '0')}/${sortedDateObj.getFullYear()}`;
        });
    }
}
        else{
            this.DateNotFound = true;
        }
    })
}

handleDateChange(event){
  this.selectedDate = event.detail.value;
  if(this.selectedSession!=null)
  this.checkAllotments();   
}

handleSessionChange(event){

   this.selectedSession = event.detail.value;   

   if(this.selectedDate == undefined || this.selectedDate == null || this.selectedDate == ''){
        this.showToast('Error', 'Please Select Allotment Date', 'error');
        return;
    }   
    if(this.selectedSession == undefined || this.selectedSession == null || this.selectedSession == ''){
        this.showToast('Error', 'Please Select Session', 'error');
        return;
    }   
    if(this.IAType == undefined || this.IAType == null || this.IAType == ''){
        this.showToast('Error', 'Please Select IA Type', 'error');
        return;
    }

    let selectedDateObj = this.convertToDate(this.selectedDate);
    getSlots({
        IAType: this.IAType,
        AllotmentDate: selectedDateObj,
        Session: this.selectedSession
    })
    .then(res=>{
   
    this.selectedSlots = []; // Reset selected slots before populating new ones
    if(res == null || res == undefined || res.length == 0){
        this.showToast('Error', 'No Slots Available For The Selected Date and Session', 'error');
        this.selectedSlots = [];
        return;
    }
   

    for (let i = 0; i < res.length; i++) {
      
       this.selectedSlots.push({label:this.convertMillisecondsToTime(res[i]), value: this.convertMillisecondsToTime(res[i])});

    }

})
}

handleSlotsChange(event){

  this.timeSlot = event.detail.value;
  
  this.checkAllotments();
}

checkAllotments(){
    
    if(this.selectedDate == undefined || this.selectedDate == null || this.selectedDate == ''){
        this.showToast('Error', 'Please Select Allotment Date', 'error');
        return;
    }   
    if(this.selectedSession == undefined || this.selectedSession == null || this.selectedSession == ''){
        this.showToast('Error', 'Please Select Session', 'error');
        return;
    }   
    if(this.IAType == undefined || this.IAType == null || this.IAType == ''){
        this.showToast('Error', 'Please Select IA Type', 'error');
        return;
    }
    if(this.timeSlot == undefined || this.timeSlot == null || this.timeSlot == ''){
        this.showToast('Error', 'Please Select Time Slot', 'error');
    }

   
    let selectedDateObj = this.convertToDate(this.selectedDate);
    
    
    let examTime = this.formatTimeForApex(this.timeSlot);
    
        checkExistingInvigilatorAssignment({
        iaType: this.IAType,
        allotmentDate: selectedDateObj,
        session: this.selectedSession,
        examTime: examTime
    })
    .then(res=>{
       
        if(res.length > 0){
            this.invigilatorRecords=[];
            this.isAllocationEnable = true;
            this.objectApiName = 'User';
            this.isUpdate = true;
            this.isCreateNew = false;
            this.showToast('Success', 'Invigilator Assignments Already Exist For The Selected Date and Session.', 'success');
            let k=0;
           
            for(let i of res){
                const invigilation = {
                    sno:k+1,
                    Id:i.Id,
                    Name: i.Name,
                    rve_Exam_Time__c: this.convertMillisecondsToTime(i.rve_Exam_Time__c),
                    rve_Exam_End_Time__c: this.convertMillisecondsToTime(i.rve_Exam_End_Time__c),
                    rve_Professor__c: i.rve_Professor__c,
                    rve_Date__c: selectedDateObj,

                }
                this.invigilatorRecords.push(invigilation);
                k++;
            }
           
            this.disableAllocation = true
        }
        else if(res.length == 0){
      //  this.disableAllocation = false;
        this.isCreateNew = true;
        assignInvigilator({
        IAType: this.IAType,
        AllotmentDate: selectedDateObj,
        Session: this.selectedSession,
        ExamTime: examTime
    })
    .then(res=>{
        
        if(res.length == 0){
            this.invigilatorRecords = [];
            this.isAllocationEnable = false;
            this.showToast('Error', 'No Allotments Found For The Selected Date and Session', 'error');
        }
        if(res.length > 0){
            this.invigilatorRecords = [];
            this.objectApiName = 'User';
            this.isAllocationEnable = true;
            let k=0;
            for(let i of res){
                 if (i.contactMap) {
                     Object.entries(i.contactMap).forEach(([key, value]) => {
                this.combinedMap[key] = value; // Add or overwrite key-value pair
            });
        }
        
        const invigilation = {
                    sno:k+1,
                    Id:k,
                    Name: i.room,
                    rve_Professor__c: i.profId,
                    rve_Room_Allotment__c: i.allotmentId,
                    rve_Shift__c:this.selectedSession,
                    rve_Date__c: selectedDateObj,
                    rve_Exam_Time__c: this.convertMillisecondsToTime(i.examTime),
                    rve_Exam_End_Time__c: this.convertMillisecondsToTime(i.examEndTime),
                    roomName: i.room,
                    roomId: i.allotmentId,
                    isEditable: i.profId == null || i.profId == '' ? false : true
                }
                this.invigilatorRecords.push(invigilation);
                k++;
            }
        }
           
        })
        .catch(error=>{
        console.error('Error:', JSON.stringify(error));
          let errorMessage = 'Something went wrong';
        if (error && error.body && error.body.message) {
            errorMessage = error.body.message;
        } else if (typeof error.message === 'string') {
            errorMessage = error.message;
        }

        this.showToast('Error', errorMessage, 'error');
    })
        
    }
})
   .catch(error=>{
        console.error('Error:', JSON.stringify(error));
          let errorMessage = 'Something went wrong';
        if (error && error.body && error.body.message) {
            errorMessage = error.body.message;
        } else if (typeof error.message === 'string') {
            errorMessage = error.message;
        }

        this.showToast('Error', errorMessage, 'error');
    })
}

// This method formats the time string to a format compatible for Apex
formatTimeForApex(timeStr) {
    let [time, modifier] = timeStr.trim().split(' ');
    let [hours, minutes] = time.split(':').map(Number);

    if (modifier === 'PM' && hours !== 12) {
        hours += 12;
    }
    if (modifier === 'AM' && hours === 12) {
        hours = 0;
    }

    let hh = hours.toString().padStart(2, '0');
    let mm = minutes.toString().padStart(2, '0');

    return `${hh}:${mm}:00.000`; // Apex-compatible format
}

// This method converts milliseconds to a formatted time string in 12-hour format with AM/PM
convertMillisecondsToTime(ms) {
    let totalMinutes = Math.floor(ms / 60000); // 1 minute = 60000 ms
    let hours = Math.floor(totalMinutes / 60);
    let minutes = totalMinutes % 60;

    let period = hours >= 12 ? 'PM' : 'AM';
    let displayHour = hours % 12;
    displayHour = displayHour === 0 ? 12 : displayHour; // Handle midnight (0) and noon (12)

    let formattedMinutes = minutes.toString().padStart(2, '0');

    return `${displayHour}:${formattedMinutes} ${period}`;
}

// This method converts a date string in YYYY/MM/DD format to a Date object
convertToDate(dateStr) {
    const [year,month,day ] = dateStr.split('/');
    return new Date(`${year}-${month}-${day}`);
}

// This method handles the auto allocation of invigilators
handleAutoAllocation(){
   
    const missingProfessors = this.invigilatorRecords.filter(record => {
        return !record.rve_Professor__c || record.rve_Professor__c.trim() === '';
    });

    if (missingProfessors.length > 0) {
        this.showToast(
            'Error',
            'Please assign all professors before proceeding with auto allocation.',
            'error'
        );
        return;
     } 
this.isLoading = true; // Show spinner
this.disableAllocation = true; // Disable allocation button
    
 let recordsForApex = this.invigilatorRecords.map(record => {
        let temp = { ...record }; // clone the record
        delete temp.roomName;
        delete temp.roomId;
        delete temp.contactMap;
        delete temp.Id;
        temp.rve_Exam_Time__c = this.formatTimeForApex(temp.rve_Exam_Time__c);
        temp.rve_Exam_End_Time__c = this.formatTimeForApex(temp.rve_Exam_End_Time__c);
        return temp;
    });


          createInvigilatorAssignments({invigilatorList: recordsForApex,userContactMap: this.combinedMap})
          .then(res=>{
          if(res=="Invigilator Assignments created successfully"){
            this.showToast('Success', 'Invigilator Assignments Created Successfully', 'success');
            this.invigilatorRecords = []; // Clear the records after successful assignment    if(res == "Invigilator Assignments created successfully"){
            window.location.reload(); // Reload the page to reflect changes  
        }
    })
    .catch(error=>{
        console.error('Error:', error.message);
        this.showToast('Error', 'Error in Invigilator Assignment', error.message);
    })
}

handleRecordChange(event) {
   
    let professorid = event.detail.recordId;
    let recordId = event.target.dataset.id;
    let updatedRecords = [...this.invigilatorRecords];
   
    
    // Attempt getting index as a number
    let index = updatedRecords.findIndex(record => String(record.Id) === String(recordId));
   
    
    if (index !== -1 ) { //&& updatedRecords[index]
        // Prepare Apex expected parameters
        let apexExamTime = this.formatTimeForApex(this.timeSlot);
        let selectedDateObj = this.convertToDate(this.selectedDate);
        let endtime = String(this.formatTimeForApex(updatedRecords[index].rve_Exam_End_Time__c));
        // Clone and update the record
        let record = {
            ...updatedRecords[index],
            rve_Professor__c: professorid,
            rve_Exam_Time__c: apexExamTime
        };

        if (professorid != null && professorid !== '') {
            
            checkExistingInvigilatorRecord({ 
                profId: professorid, 
                examtime: apexExamTime, 
                examdate: selectedDateObj,
                recordid: recordId,
                examendtime: endtime,
            })
            .then(res => {
               
                if (res.toLowerCase().includes('already assigned')) {
                    this.showToast('Error', res, 'error');
                    record.rve_Professor__c = null;
                    this.disableUpdate = true;
                } else {
                    if(res.toLowerCase().includes('program batch')){
                        this.showToast('warning', res, 'warning');
                        record.rve_Professor__c = professorid;
                    }
                    this.disableUpdate = false;
                }
                
                // Convert exam time back to display format
                record.rve_Exam_Time__c = this.convertTimeFormat(record.rve_Exam_Time__c);
                 
                // Update invigilatorRecords array
                const newArray = [...this.invigilatorRecords];
                
                newArray[index] = record;
                this.invigilatorRecords = newArray;
                
            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));
                let errorMessage = 'Something went wrong';
                if (error && error.body && error.body.message) {
                    errorMessage = error.body.message;
                } else if (typeof error.message === 'string') {
                    errorMessage = error.message;
                }
                this.showToast('Error', errorMessage, 'error');
            });
        }
    } else {
        console.error('Record not found in InvigilatorRecords for Id:', recordId);
    }
}


handleUpdateInvigilatorAssignment(){
    this.isLoading = true; // Show spinner
    for (let i of this.invigilatorRecords){
        delete i.index;
        delete i.rve_Exam_Time__c;
        delete i.rve_Exam_End_Time__c;
     }
    
    updateAllotment({
        invigilatorList: this.invigilatorRecords
    })
    .then(res=>{
       
        if(res == "Invigilator updated successfully"){
            this.showToast('Success', 'Invigilator Assignments Updated Successfully', 'success');
            this.invigilatorRecords = []; // Clear the records after successful update
            window.location.reload(); // Reload the page to reflect changes
        }
    })
    .catch(error=>{
       
        this.showToast('Error', 'Error in Invigilator Assignment', error.message);
    })
}

showToast(title, message, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    this.dispatchEvent(evt);
}

convertTimeFormat(timeStr){

// Split the time string into components
let [hours, minutes] = timeStr.split(':');

// Convert hours to number for manipulation
hours = parseInt(hours, 10);

// Determine AM/PM
let period = hours >= 12 ? 'PM' : 'AM';

// Convert to 12-hour format
hours = hours % 12 || 12; // Convert 0 to 12 for 12 AM

// Pad hours if needed
//let formattedHours = hours.toString().padStart(2, '0');

let formattedTime = `${hours}:${minutes} ${period}`;
 // Output: "09:30 AM"
return formattedTime;
}
}