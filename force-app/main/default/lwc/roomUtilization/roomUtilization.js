import { LightningElement, wire, track } from 'lwc';
import getRoomUtilizationData from '@salesforce/apex/RoomUtilizationCalculator1.getRoomUtilizationData';
import getCurrentUserDepartment from '@salesforce/apex/RoomUtilizationCalculator1.getCurrentUserDepartment';
import getRoomSlotDetails from '@salesforce/apex/RoomUtilizationCalculator1.getRoomSlotDetails';
import getAvailableSlotsPerRoom from '@salesforce/apex/RoomUtilizationCalculator1.exportAvailableSlotData';
//import getAllUserDepartments from '@salesforce/apex/RoomUtilizationCalculator1.getAllUserDepartments';
import getAllUserDepartments from '@salesforce/apex/RoomUtilizationCalculator1.getAllUserDepartments';
export default class RoomUtilization extends LightningElement {
    @track roomData = [];
    @track selectedRoomNumber = null;
    @track selectedSlotType = '';
    @track selectedTimeRange = 'This Week';
    @track totalRooms = 0;
    @track bookedRooms = 0;
    @track availableRooms = 0;
    @track totalSlots = 0;
    @track roomBooked = 0;
    @track allottedSlots = 0;
    @track freeSlots = 0;
    @track slotPercentage =0;
    @track utilizationPercentage = 0;
    @track userDepartment = '';
    @track showSlotPopup = false;
    @track selectedSlotDetails = [];
    @track isLoading = false;
    @track departments = [];
    @track selectedDepartment = '';
    popupStyle = '';

    get timeRangeOptions() {
        return [
            { label: 'Last Week', value: 'Last Week' },
            { label: 'This Week', value: 'This Week' },
            { label: 'Next Week', value: 'Next Week' },
            { label: 'This Month', value: 'This Month' },
            { label: 'Last Month', value: 'Last Month' },
            { label: 'Next Month', value: 'Next Month' }
        ];
    }
    handleTimeRangeChange(event) {
        this.selectedTimeRange = event.detail.value; }
     handleDepartmentChange(event) {
       this.selectedDepartment = event.detail.value;
        }

      @wire(getCurrentUserDepartment)
         wiredUserDepartment({ error, data }) {
           if (data) {
             this.userDepartment = data;
             if (!this.selectedDepartment) {
            this.selectedDepartment = data;
             }
            } else if (error) {
           console.error('Error fetching user department:', error);
           this.userDepartment = 'Unknown';
        }
}
        connectedCallback() {
        getAllUserDepartments()
        .then(result => {
            this.departments = result.map(dep => ({ label: dep, value: dep }));
            if (!this.selectedDepartment && this.userDepartment) {
                this.selectedDepartment = this.userDepartment;
            }
        })
        .catch(error => {
            console.error('Error fetching departments:', error);
        });
      }

    @wire(getRoomUtilizationData, { timeRange: '$selectedTimeRange', userDepartment: '$selectedDepartment' })
    wiredRooms({ error, data }) {
        if (data) {
            let roomMap = new Map();
            let totalSlots = 0;
            let allottedSlots = 0;
            let totalRooms = 0;
            let bookedRooms = 0;

            data.forEach(room => {
                let roomNumber = room.roomNumber;
                let utilization = room.utilizationPercentage ? Math.round(room.utilizationPercentage) : 0;

                totalSlots += room.totalSlots || 0;
                allottedSlots += room.roomBooked || 0;

                if (!roomMap.has(roomNumber)) {
                    let availableSlots = (room.totalSlots || 0) - (room.roomBooked || 0); 
                    roomMap.set(roomNumber, {
                        ...room,
                        strokeDash: this.calculateStrokeDash(utilization),
                        isSelected: false,
                        showSlotPopup: false,
                        slotDetails: [],
                        availableSlots: availableSlots > 0 ? availableSlots : 0 
                    });
                    totalRooms++;
                    if (room.roomBooked > 0) {
                        bookedRooms++;
                        //allottedSlots += room.roomBooked;
                    }
                }
            });

            this.roomData = Array.from(roomMap.values());
            this.totalSlots = totalSlots;
            this.allottedSlots = allottedSlots;
            this.freeSlots = totalSlots - allottedSlots;
            this.slotPercentage = totalSlots > 0 ? Math.round((allottedSlots / totalSlots) * 100) : 0;
            this.totalRooms = totalRooms;
            this.bookedRooms = bookedRooms;
            this.availableRooms = totalRooms - bookedRooms;
            
            this.utilizationPercentage1 = totalRooms > 0 ? Math.round((bookedRooms / totalRooms) * 100) : 0;
            console.log("Total Slots:", totalSlots);
            console.log("Allotted Slots:", allottedSlots);
            console.log("Free Slots:", this.freeSlots);
            console.log("Slot Percentage:", this.slotPercentage);
        } else if (error) {
            console.error('Error fetching room utilization data:', error);
        }
    }
      
  
    handleRoomClick(event) {
        const roomId = event.currentTarget.dataset.id;
        if (this.selectedRoomNumber === roomId) {
            this.selectedRoomNumber = null;
            this.isLoading = false;
            this.roomData = this.roomData.map(room => ({
                ...room,
                isSelected: false
            }));
            return;
        }

        // Show spinner

        this.isLoading = true;
        this.selectedRoomNumber = roomId;
        this.roomData = this.roomData.map(room => ({
            ...room,
            isSelected: room.roomNumber === roomId,
            showSlotPopup: false
        }));
         // Fetch room slot details

         getRoomSlotDetails({ roomNumber: roomId, timeRange: this.selectedTimeRange,slotType: slotType, userDepartment: this.selectedDepartment  })
         .then(data => {
             this.selectedSlotDetails = Object.entries(data).map(([date, slots]) => ({
                 date: date,
                 slotText: slots.length > 0 ? `Slots: ${slots.join(', ')}` : 'No slots available'
             }));
         })

         .catch(error => {
             console.error('Error fetching slot details:', error);
             this.selectedSlotDetails = [{ date: '', slotText: 'Error loading slots' }];
         })
         .finally(() => {
             this.isLoading = false;
         });
    }

    get roomContainerClass() {
        return this.showSlotPopup ? 'slds-col slds-size_2-of-3' : 'slds-col slds-size_1-of-1';
    }

    handleSlotClick(event) {
        event.preventDefault();
        const roomId = event.currentTarget.dataset.roomid;
        const slotType = event.currentTarget.dataset.slottype;

        this.selectedRoomNumber = roomId;
        this.selectedSlotType = slotType;
        this.selectedSlotDetails = [];
        this.isLoading = true;
        console.log("Fetching slot details for Room:", roomId, "Slot Type:", slotType, "Department:", this.selectedDepartment);
        getRoomSlotDetails({ roomNumber: roomId, timeRange: this.selectedTimeRange, slotType: slotType,userDepartment: this.selectedDepartment })
            .then((data) => {
                if (data) {
                    this.selectedSlotDetails = Object.entries(data).map(([date, slots]) => ({
                        date: date,
                        slotText: slots.length > 0 ? `Slots: ${slots.join(', ')}` 
                        : (slotType === 'Booked' ? 'Slot: Not Booked' : 'Slot: Not Available')
                    }));
                } else {
                    this.selectedSlotDetails = [{ date: '', slotText: slotType === 'Booked' ? 'Slot: Not Booked' : 'Slot: Not Available' }];
                }
                this.showSlotPopup = true;
            })
            .catch((error) => {
                console.error('Error fetching slot details:', JSON.stringify(error));
                this.selectedSlotDetails = [{ date: '', slotText: 'Error loading slots' }];
            });

        // Position the popup dynamically
        this.positionPopup(event);
    }

    positionPopup(event) {
        const rect = event.currentTarget.getBoundingClientRect();
        let topPosition = rect.top + window.scrollY + 20;
        let leftPosition = rect.left + window.scrollX + 20;

        // Prevent overflow
        if (leftPosition + 300 > window.innerWidth) {
            leftPosition = window.innerWidth - 320; // Adjust to fit within the screen
        }
        if (topPosition + 200 > window.innerHeight) {
            topPosition = window.innerHeight - 220;
        }

        this.popupStyle = `position: absolute; top: ${topPosition}px; left: ${leftPosition}px; z-index: 1000; background: lightgreen; padding: 15px; border-radius: 10px; max-width: 300px; overflow: hidden;`;

        this.showSlotPopup = true;
    }

    calculateStrokeDash(utilization) {
        const maxStroke = 94;
        return `${(utilization / 100) * maxStroke} ${maxStroke}`;
    }

    handleCloseSlotPopup() {
        this.showSlotPopup = false;
    }
   
    handleAvailableSlotExportClick() {
        if (!this.selectedTimeRange || !this.selectedDepartment) {
            alert('Please select a time range and ensure user department is available.');
            return;
        }

        getAvailableSlotsPerRoom({
            timeRange: this.selectedTimeRange,
            userDepartment: this.selectedDepartment
        })
            .then(result => {
                if (result && result.length > 0) {
                    this.downloadCSVFromData(result);
                } else {
                    alert('No available slot data to export.');
                }
            })
            .catch(error => {
                if (error && error.body && error.body.message) {
                    console.error('Export Error:', error.body.message);
                } else {
                    console.error('Export Error:', JSON.stringify(error, null, 2));
                }
                alert('Failed to export available slot data.');
            });
    }

    downloadCSVFromData(data) {
        let csv = 'Room Number,Date,Available Slots,Block,Floor,Department\n';
        data.forEach(row => {
            const availableSlotsStr = row.availableSlots ? row.availableSlots.join(', ') : '';
            const block = row.block ?? '';
            const floor = row.floor ?? '';
            const department = this.selectedDepartment ?? '';
            csv += `${row.roomNumber},${row.date},"${availableSlotsStr}",${block},${floor},${department}\n`;
        });

         const encodedUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
         const downloadLink = document.createElement('a');
          downloadLink.setAttribute('href', encodedUri);
          downloadLink.setAttribute('download', 'Avaliable Slot Data.csv');
          document.body.appendChild(downloadLink);
          downloadLink.click();
          document.body.removeChild(downloadLink);
    }
    
}