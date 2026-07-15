// timeSlotComponent.js
import { LightningElement, track,wire,api } from 'lwc';
import fetchCustomMetadataMap from '@salesforce/apex/rewaTimeSlot.fetchCustomMetadataMap';
import fetchEventDetails from '@salesforce/apex/rewaCaseController.fetchEventDetails';
export default class TimeSlotComponent extends LightningElement {
    
    @track timeSlots = [];
    @track hideSlot=false;
    stringtimeSlot=[];
    @track selectedDate = '';
    minDate = new Date().toISOString().split('T')[0];
    currentDateTime = new Date().toISOString();
    @track selectedTimeSlot='';
    @track isSubmitButtonDisabled = true;
    @track showRewaBookEvent = false;
    @track showParentComponent = true;
    @track year='';
    @track month='';
    @track day='';
    @track starthours='';
    @track startminutes='';
    @track endhours='';
    selectDate='';
    formatDate='';
    @api selectContact='';
    @api selectedAppointmentType;


    handleDateChange(event) {
        this.selectedDate = event.target.value;
        this.stringtimeSlot = [];
        //this.isSubmitButtonDisabled = !this.selectedDate;
        this.updateSubmitButtonState();
        this.hideSlot=false;
        
    }
    updateSubmitButtonState() {
        const today = new Date().toISOString().split('T')[0];
        this.isSubmitButtonDisabled = this.selectedDate < today;
    }
    

    handleButtonClick() {
        this.hideSlot=true;
        // Call the Apex method to fetch all time slots
        fetchCustomMetadataMap()
        .then(result => {
            // Process the result here
            const hourToCMDTMap = result;
            // Flatten the map into an array for rendering in the UI
            this.timeSlots = [];
            for (const [hourKey, cmdtRecords] of Object.entries(hourToCMDTMap)) {
                this.timeSlots.push({ hourKey, cmdtRecords });
            }
            if(this.selectedDate != null){
                
                this.timeSlots.forEach(slot => {
                    const stringtimeSlot5 =this.stringtimeSlot.join(',');
                    var bookedslots = stringtimeSlot5.split(',');
                   // slot.disabled = this.stringtimeSlot.includes(slot.hourKey);
                    slot.disabled = false;
    
                    if (JSON.stringify(bookedslots) == '[""]') {
    // Handle case where bookedslots is an empty array
    
    slot.disabled = (this.doTimeSlotsOverlap1(slot.hourKey, this.selectedDate) || slot.disabled);
    
} else {

                    bookedslots.forEach(bookedSlot => {
                    
                    slot.disabled = ((this.doTimeSlotsOverlap(bookedSlot, slot.hourKey, this.selectedDate))||slot.disabled);
                    
                });
}
                });
            }
            else{

            }
        })
        .catch(error => {
            // Handle any errors here
            console.error('Error fetching time slots:', error);
        });

        
        
       
           
}
    

    // Handle custom box tile click
    handleTileClick(event) {

        this.selectedTimeSlot = event.currentTarget.dataset.timeslot;
        this.showRewaBookEvent = true;
        //this.showParentComponent = false;
        const selectedDate = this.selectedDate;
        const timeSlot = this.selectedTimeSlot; // Replace with your selected time slot
        const [startTime, endTime] = timeSlot.split(' - ');

        // Split the selectedDate into day, month, and year
        var dateParts = selectedDate.split("-");
         this.year = dateParts[0];
         this.month = dateParts[1];
         this.day = dateParts[2];

        // Split the startTime into hours and minutes

        var starttimeParts = startTime.split(":");
        var starttimeParts2 = starttimeParts[1].split(" ");
         this.starthours = parseInt(starttimeParts[0]);
         this.startminutes = parseInt(starttimeParts2[0]);
        
       // Adjust hours for PM if necessary

        if (startTime.includes("PM") && this.starthours < 12) {

            this.starthours += 12;
        }

        // Split the endTime into hours and minutes

        var endtimeParts = endTime.split(":");
        var endtimeParts2 = starttimeParts[1].split(" ")
         this.endhours = parseInt(endtimeParts[0]);
         this.endminutes = parseInt(endtimeParts2[0]);
        
       // Adjust hours for PM if necessary

        if (endTime.includes("PM") && this.endhours < 12) {

            this.endhours += 12;
        }


        // Remove the 'selected-input' class from all input elements
        const inputs = this.template.querySelectorAll('.custom-input-container');
        inputs.forEach(input => {
            input.classList.remove('selected-input');
        });

        // Add the 'selected-input' class to the clicked input element
        event.target.classList.add('selected-input');
    }

    handlegrandChildEvent(event) {
        this.messageReceived = event.detail;
    }

    @wire (fetchEventDetails,{ selectedDate: '$selectedDate' })
    
    fetchEventDetails({data,error}){
        if(data){
            const stringtimeSlots = []; // Initialize as an empty array

            data.forEach(event => {
                const startDateTime = event.StartDateTime;
                const endDateTime = event.EndDateTime;

                const formatTime = (dateTime) => {
                    const options = { hour: 'numeric',minute: 'numeric', hour12: true };
                    return new Intl.DateTimeFormat('en-US', options).format(new Date(dateTime));
                };
                
                // Create time slot strings
                const startTimeSlot = formatTime(startDateTime);
                const endTimeSlot = formatTime(endDateTime);
                // Split the time into hours and AM/PM
                const startTimeParts = startTimeSlot.split(' ');
                const endTimeParts = endTimeSlot.split(' ');
                
                // Remove the minutes from the hours
                const formattedStartTime = startTimeParts[0] + ' ' + startTimeParts[1];
                const formattedEndTime = endTimeParts[0] + ' ' + endTimeParts[1];
                
                // Create a string for the time slot
                //this.stringtimeSlot = `${formattedStartTime} - ${formattedEndTime}`;
                stringtimeSlots.push(`${formattedStartTime} - ${formattedEndTime}`); // Push into the array    
                this.stringtimeSlot = stringtimeSlots;          
        });
    }
        else if(error){
            console.log(error);
        }
    }

   // Function to check if two time slots overlap
    doTimeSlotsOverlap(slot1, slot2, selectedDate) {
    const [start1, end1] = slot1.split(' - ');
    const [start2, end2] = slot2.split(' - ');

    const convertToDateTime= (timeString) => {
        const [time, period] = timeString.split(' ');
    
        const [hours, minutes] = time.split(':').map(Number);
    
        let hours24 = hours;
        if (period.toLowerCase() === 'pm' && hours24 < 12) {
            hours24 += 12;
        } else if (period.toLowerCase() === 'am' && hours24 === 12) {
            hours24 = 0;
        }
    
        const date = new Date();
        date.setHours(hours24, minutes, 0, 0);
    
        return date;
    }

    const today = new Date();

const year = today.getFullYear();
const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
const day = String(today.getDate()).padStart(2, '0');

const formattedDate = `${year}-${month}-${day}`;

console.log("today---"+formattedDate);
//console.log("4 --->"+(formattedDate == currentDateTime));

    const currentDateTime = new Date();
    const startDateTime1 = convertToDateTime(start1);
    const endDateTime1 = convertToDateTime(end1);
    const startDateTime2 = convertToDateTime(start2);
    const endDateTime2 = convertToDateTime(end2);

    if(formattedDate == selectedDate){
    return ((startDateTime1 < endDateTime2 && startDateTime1 >= startDateTime2)||(endDateTime1 <= endDateTime2 && endDateTime1 > startDateTime2)||(startDateTime1 <= startDateTime2 && endDateTime1 >= endDateTime2)||(startDateTime2 <= currentDateTime));
    }

    else {
        return ((startDateTime1 < endDateTime2 && startDateTime1 >= startDateTime2)||(endDateTime1 <= endDateTime2 && endDateTime1 > startDateTime2)||(startDateTime1 <= startDateTime2 && endDateTime1 >= endDateTime2));
        }
}



 doTimeSlotsOverlap1( slot2, selectedDate) {
    //const [start1, end1] = slot1.split(' - ');
    const [start2, end2] = slot2.split(' - ');

    const convertToDateTime= (timeString) => {
        const [time, period] = timeString.split(' ');
    
        const [hours, minutes] = time.split(':').map(Number);
    
        let hours24 = hours;
        if (period.toLowerCase() === 'pm' && hours24 < 12) {
            hours24 += 12;
        } else if (period.toLowerCase() === 'am' && hours24 === 12) {
            hours24 = 0;
        }
    
        const date = new Date();
        date.setHours(hours24, minutes, 0, 0);
    
        return date;
    }

    const today = new Date();

const year = today.getFullYear();
const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are zero-based
const day = String(today.getDate()).padStart(2, '0');

const formattedDate = `${year}-${month}-${day}`;


    const currentDateTime = new Date();
    
    const startDateTime2 = convertToDateTime(start2);
    const endDateTime2 = convertToDateTime(end2);

    if(formattedDate == selectedDate){
    return ((startDateTime2 <= currentDateTime));
    }

    
}


}