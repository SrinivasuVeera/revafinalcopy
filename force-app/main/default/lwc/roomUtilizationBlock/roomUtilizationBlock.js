import { LightningElement, track } from 'lwc';
import getBlockSchoolRoomSummary from '@salesforce/apex/RoomUtilizationBlock.getBlockSchoolRoomSummary';
import getAvailableRoomsByBlock from '@salesforce/apex/RoomUtilizationBlock.getAvailableRoomsByBlock';
//import exportBlockSummaryData from '@salesforce/apex/RoomUtilizationBlock.exportBlockSummaryData';
import exportAllBlockData from '@salesforce/apex/RoomUtilizationBlock.exportAllBlockData';
import exportBlockData from '@salesforce/apex/RoomUtilizationBlock.exportBlockData';

import getUserProfileName from '@salesforce/apex/RoomUtilizationBlock.getUserProfileName';

export default class RoomBlockSummary extends LightningElement {
    @track showExportButton = false;
    @track blockSchoolData = [];
    @track selectedBlock = null;
    @track error;
    @track startDate;
    @track endDate;
    showDateFilters = false;
     popupStartDate;
     popupEndDate;

    @track showModal = false;
    @track availableRooms = [];
    @track selectedBlockName = '';
    @track blockOptions = [];
    @track selectedBlockFilter = 'All';
    @track selectedFloor = 'All';
    @track selectedRoom = 'All';
    @track allAvailableRooms = [];
    @track selectedSlot = 'All';

    get slotDropdownOptions() {

    return [
        { label: 'All',  value: 'All' },
        { label: 'Slot 1', value: '1' },
        { label: 'Slot 2', value: '2' },
        { label: 'Slot 4', value: '4' },
        { label: 'Slot 5', value: '5' },
        { label: 'Slot 7', value: '7' },
        { label: 'Slot 8', value: '8' },
        { label: 'Slot 9', value: '9' },
        {
            label: 'First Half (1,2,4,5)',
            value: 'FIRST_HALF'
        },
        {
            label: 'Second Half (7,8,9)',
            value: 'SECOND_HALF'
        }
    ];
}

 connectedCallback() {

    // Existing functionality
    this.fetchBlockSchoolData();

    // Profile check
    getUserProfileName()
    .then(result => {

        console.log(
            'Profile Name => ',
            result
        );

        if(
            result === 'System Administrator' ||
            result === 'Infra Admin'
        ) {

            this.showExportButton = true;

            console.log(
                'Button Visible'
            );
        }

    })
    .catch(error => {

        console.error(
            'Profile Error',
            error
        );
    });
}
       get blockDropdownOptions() {

           let options = [
            { label: 'All', value: 'All' }
            ];

          this.blockSchoolData.forEach(block => {
            options.push({
                label: block.Block,
                value: block.Block
              });
            });

             return options;
            }

    get floorDropdownOptions() {

    let options = [
        { label: 'All', value: 'All' }
    ];

    let filteredData = [...this.allAvailableRooms];

    // Block filter
    if (this.selectedBlockFilter !== 'All') {

        filteredData = filteredData.filter(
            room =>
                room.Block === this.selectedBlockFilter
        );
    }

    // Unique floors
    let uniqueFloors = [
        ...new Set(
            filteredData.map(
                room => room.Floor
            )
        )
    ];

    uniqueFloors.sort().forEach(floor => {

        if (floor) {

            options.push({
                label: floor,
                value: floor
            });
        }
    });

    return [...options];
}


    fetchBlockSchoolData() {
        getBlockSchoolRoomSummary({ selectedStartDate: this.startDate, selectedEndDate: this.endDate })
            .then(data => {
                const transformedData = data.map(block => {
                    const totalRooms = block.TotalRooms || 0;
                    const bookedRooms = block.BookedRooms || 0;
                    const availableRooms = totalRooms - bookedRooms;

                    const utilization = totalRooms > 0 ? (bookedRooms / totalRooms) * 100 : 0;
                    const formattedUtilization = utilization.toFixed(2);

                    const schools = (block.Schools || []).map(school => {
                        const sTotal = school.TotalRooms || 0;
                        const sBooked = school.BookedRooms || 0;
                        const sUtil = sTotal > 0 ? (sBooked / sTotal) * 100 : 0;
                        return {
                            SchoolName: school.SchoolName || 'Unnamed School',
                            TotalRooms: sTotal,
                            BookedRooms: sBooked,
                            Utilization: sUtil.toFixed(2),
                            UtilizationDash: `${sUtil.toFixed(2)}, 100`
                        };
                    });

                    return {
                        ...block,
                        expanded: false,
                        RoomUtilization: formattedUtilization,
                        RoomUtilizationDash: `${formattedUtilization}, 100`,
                        AvailableRooms: availableRooms,
                        Schools: schools
                    };
                });

                this.blockSchoolData = [...transformedData];
                this.selectedBlock = null;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                console.error('Error fetching block summary:', error);
            });
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.fetchBlockSchoolData();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.fetchBlockSchoolData();
    }

    toggleBlock(event) {
        const blockName = event.currentTarget.dataset.block;
        let selected = null;

        const updatedData = this.blockSchoolData.map(block => {
            const isExpanded = block.Block === blockName ? !block.expanded : false;
            if (isExpanded) {
                selected = block;
            }
            return {
                ...block,
                expanded: isExpanded
            };
        });

        this.blockSchoolData = [...updatedData];
        this.selectedBlock = selected;
    }
      handleExportAllBlocks() {
    exportAllBlockData({ startDate: this.startDate, endDate: this.endDate })
        .then(data => {
            this.downloadCSV(data, 'All_Block_Summary.csv');
        })
        .catch(error => {
            console.error('Export All Blocks failed:', error);
        });
}

handleExportSelectedBlock() {
    if (!this.selectedBlock) return;

    exportBlockData({
        blockName: this.selectedBlock.Block,
        startDate: this.startDate,
        endDate: this.endDate
    })
        .then(data => {
            this.downloadCSV(data, `${this.selectedBlock.Block}_Block_Details.csv`);
        })
        .catch(error => {
            console.error('Export Block failed:', error);
        });
}

    downloadCSV(data, fileName) {
    if (data && data.length > 0) {
        const headerKeys = Object.keys(data[0]);
        const csvRows = [];

        csvRows.push(headerKeys.join(','));
        data.forEach(row => {
            const values = headerKeys.map(key => `"${row[key] || ''}"`);
            csvRows.push(values.join(','));
        });

        const csvContent = csvRows.join('\n');
        const blob = new Blob([csvContent], { type: 'application/octet-stream' });
const url = URL.createObjectURL(blob);
const downloadLink = document.createElement('a');
downloadLink.href = url;
downloadLink.setAttribute('download', 'Block_Summary.csv');
document.body.appendChild(downloadLink);
downloadLink.click();
document.body.removeChild(downloadLink);
    }

    }

   

handleAvailableRoomsClick() {

    this.showModal = true;

    this.selectedBlockFilter = 'All';
    this.selectedFloor = 'All';
    this.selectedSlot = 'All';
    //this.selectedRoom = 'All';
    this.popupStartDate = this.startDate;
    this.popupEndDate = this.endDate;

    getAvailableRoomsByBlock({
        blockName: 'All',
        startDate: this.startDate,
        endDate: this.endDate
    })
    .then(data => {

        this.allAvailableRooms = [...data];

this.availableRooms = [...data];

console.log(
    'Available Rooms Data',
    JSON.stringify(this.availableRooms)
);
    })
    .catch(error => {

        console.error(error);
    });
}

handleBlockChange(event) {

    this.selectedBlockFilter = event.detail.value;
       this.filterAvailableRooms();
}
handleFloorChange(event) {

    this.selectedFloor = event.detail.value;
     
    this.filterAvailableRooms();
}

/*handleRoomChange(event) {

    this.selectedRoom = event.detail.value;
    this.filterAvailableRooms();
}*/

handleSlotChange(event) {

    this.selectedSlot = event.detail.value;

    this.filterAvailableRooms();
}

filterAvailableRooms() {

    let filteredData = [...this.allAvailableRooms];

    console.log('Before Filter', filteredData);

    // BLOCK FILTER
    if (
        this.selectedBlockFilter &&
        this.selectedBlockFilter !== 'All'
    ) {

        filteredData = filteredData.filter(
            room =>
                room.Block &&
                room.Block.trim() ===
                this.selectedBlockFilter.trim()
        );
    }

    // FLOOR FILTER
    if (
        this.selectedFloor &&
        this.selectedFloor !== 'All'
    ) {

        filteredData = filteredData.filter(
            room =>
                room.Floor &&
                room.Floor.trim() ===
                this.selectedFloor.trim()
        );
    }

    // SLOT FILTER
            if (this.selectedSlot) {

    filteredData = filteredData.filter(room => {

        let slots = [];

        if (room.AvailableSlots) {

            slots = room.AvailableSlots
                .split(',')
                .map(item => item.trim());
        }

        // ALL SLOTS
        if (this.selectedSlot === 'All') {

            return (
                slots.includes('1') &&
                slots.includes('2') &&
                slots.includes('4') &&
                slots.includes('5') &&
                slots.includes('7') &&
                slots.includes('8') &&
                slots.includes('9')
            );
        }

            // FIRST HALF
            if (
                this.selectedSlot ===
                'FIRST_HALF'
            ) {

                return (
                    slots.includes('1') &&
                    slots.includes('2') &&
                    slots.includes('4') &&
                    slots.includes('5')
                );
            }

            // SECOND HALF
            if (
                this.selectedSlot ===
                'SECOND_HALF'
            ) {

                return (
                    slots.includes('7') &&
                    slots.includes('8') &&
                    slots.includes('9')
                );
            }

            // SINGLE SLOT
            return slots.includes(
                this.selectedSlot.replace(
                    'Slot ',
                    ''
                )
            );
        });
    }

    console.log(
        'After Filter',
        filteredData
    );

    this.availableRooms = [...filteredData];
}

handleChangeDateClick() {

    this.showDateFilters =
        !this.showDateFilters;
}

handlePopupStartDate(event) {

    this.popupStartDate =
        event.target.value;
}

handlePopupEndDate(event) {

    this.popupEndDate =
        event.target.value;
}

handleDoneDateChange() {

    this.startDate =
        this.popupStartDate;

    this.endDate =
        this.popupEndDate;

    this.showDateFilters = false;

    this.loadAvailableRooms();
}

/*filterAvailableRooms() {

    let filteredData =
        [...this.allAvailableRooms];

    // Block Filter
    if(this.selectedBlockFilter !== 'All') {

        filteredData =
            filteredData.filter(
                room =>
                    room.Block ===
                    this.selectedBlockFilter
            );
    }

    // Floor Filter
    if(this.selectedFloor !== 'All') {

        filteredData =
            filteredData.filter(
                room =>
                    room.Floor ===
                    this.selectedFloor
            );
    }

    */


loadAvailableRooms() {

    getAvailableRoomsByBlock({
        blockName: this.selectedBlockFilter,
        startDate: this.startDate,
        endDate: this.endDate
    })
    .then(data => {

        this.availableRooms = data;
    })
    .catch(error => {

        console.error('Error fetching available rooms:', error);
    });
}

handleDownloadAvailableRooms() {

    try {

        if(
            !this.availableRooms ||
            this.availableRooms.length === 0
        ) {

            return;
        }

        let csvContent = '';

        // Header
        csvContent +=
            'Date,Block,Room Number,Room Type,Floor,School,School Head,Available Slots\n';

        // Data
        this.availableRooms.forEach(room => {

            csvContent +=
                `"${room.Date || ''}",` +
                `"${room.Block || ''}",` +
                `"${room.RoomNumber || ''}",` +
                `"${room.RoomType || ''}",` +
                `"${room.Floor || ''}",` +
                `"${room.SchoolName || ''}",` +
                `"${room.SchoolHead || ''}",` +
                `"${room.AvailableSlots || ''}"\n`;
        });

        // Create Blob
        const blob =
    new Blob(
        [csvContent],
        {
            type:
            'application/octet-stream'
        }
    );

        // Create URL
        const url =
    URL.createObjectURL(blob);

        // Create link
        const link =
            document.createElement('a');

        link.href = url;

        link.setAttribute(
            'download',
            'Available_Rooms.csv'
        );

        document.body.appendChild(link);

        link.click();

        document.body.removeChild(link);

        window.URL.revokeObjectURL(url);

    } catch(error) {

        console.error(
            'Download Error',
            error
        );
    }
}
    closeModal() {
        this.showModal = false;
        this.availableRooms = [];
    }

    
}