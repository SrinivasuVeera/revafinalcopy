// revaEventHallBooking.js
import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import BASE_PATH from '@salesforce/label/c.NonTeachingFacultyEventURL';

// Apex methods (kept exactly as you requested)
//import saveFacilityRequest from "@salesforce/apex/revaFacilityRequestBookingController.saveFacilityRequest";
import validateAndSaveFacility from "@salesforce/apex/revaFacilityRequestBookingController.validateAndSaveFacility";
import getAllBuildings from "@salesforce/apex/revaFacilityRequestBookingController.getAllBuildings";
import getFloorsByBuilding from "@salesforce/apex/revaFacilityRequestBookingController.getFloorsByBuilding";
import getRoomsByFloor from "@salesforce/apex/revaFacilityRequestBookingController.getRoomsByFloor";
import getAllFacilities from "@salesforce/apex/revaFacilityRequestBookingController.getAllFacilities";
import getTimeValues from "@salesforce/apex/revaFacilityRequestBookingController.getTimeValues";
import getEventFacilities from "@salesforce/apex/revaFacilityRequestBookingController.getEventFacilities";
import getLabFacilities from "@salesforce/apex/revaFacilityRequestBookingController.getLabFacilities";
import getCourseScedules from "@salesforce/apex/revaFacilityRequestBookingController.getCourseScedules";
import getAllTimeSlots from "@salesforce/apex/revaFacilityRequestBookingController.getAllTimeSlots";
import getAminities from "@salesforce/apex/revaFacilityRequestBookingController.getAminities";
import getAdditionalAmenities from "@salesforce/apex/revaFacilityRequestBookingController.getAdditionalAmenities";

export default class RevaEventHallBooking extends NavigationMixin(LightningElement) {
  // --- reactive state ---
  @track recordId;
  @track selectedBuildingName = null;
  @track selectedFacilityName = null;
  @track selectedFacilityType = 'Event Venues';
  @track selectedRoomName = null; // floor
  @track selectedRoomNum = null; // room number
  @track selectedStartDate = null;
  @track selectedEndDate = null;
  @track selectedStartTime = null;
  @track selectedEndTime = null;
  @track bookingReason = null;
  @track numberOfAttendees = null;
  @track isLoading = false;
  @track timeOptions = [];
  @track startTimeOptions = [];
  @track endtimeOptions = [];
  @track filteredStartTimeSlots = [];
  @track filteredEndTimeSlots = [];
  @track facilityNameOptions = [];
  @track facilityEventTypeOptions = [];
  @track facilityBuildingNameOptions = [];
  @track facilityFloorOptions = [];
  @track facilityRoomNumOptions = [];
  @track facilityCapacityOption = [];
  @track additionalAmenitiesOptions = [];
  @track additionalAmenitiesOptions2 = [];
  @track buildingOptions = [];
  @track rows = [];
  @track selectedValues = [];
  @track selectedValues2 = [];
  @track existingBookings = []; // for modal
  @track showConflictModal = false;
  @track capacity = 0;
  @track isCapacity = false;
  @track IAExamHall = false;
  @track eventValue = 'Event Venues';
  @track additionalFacility2 = 'NA';
  @track quantityOfAdditionalAmenities = 'NA';
  @track descriptions = '';
  @track facilityId = [];
  @api isDisabled = false;
  showCancellation = true;   
  showBooking = false;

  label = { basepath: BASE_PATH };

  // Set default facility type
//selectedFacilityType = 'Event Venues';
isfacilityTpe = true;
handleNewBooking() {
    this.showCancellation = false;
    this.showBooking = true;
}

handleBack() {
    this.showBooking = false;
    this.showCancellation = true;
}

/*handleBookingSaved() {
    this.showBooking = false;
    this.showCancellation = true;
}*/

// ------------------- Lifecycle -------------------
async connectedCallback() {
    // one default row
    this.rows = [{ 
        id: 1, 
        additionalFacility2: '', 
        quantity: '', 
        additionalFacilityWithQuantity: '' 
    }];

    // get recordId from URL
    const urlParams = new URLSearchParams(window.location.search);
    this.recordId = urlParams.get("recordId");

    // loading initial data
    this.isLoading = true;
    try {
        await Promise.all([
            this.loadBuildings(),
            this.getEventFacilities(),
            this.getLabFacilities(),
            this.getCourseScedules(),
            this.getTimeDetails(),
            this.getEndTimeSlots(),
            this.getAdditionalAmenities()
        ]);

        // --- AUTO SELECT "Event Venues" ---
        this.selectedFacilityType = 'Event Venues';
        this.isfacilityTpe = true;

        // Load facilities for Event Venues by default
        await this.loadFacilities('Event Venues', null, null, null);

        // time slots
        this.filteredStartTimeSlots = this.timeOptions;
        this.filteredEndTimeSlots = this.timeOptions;

    } catch (e) {
        console.error('connectedCallback error', e);
    } finally {
        this.isLoading = false;
    }
}


  // ------------------- Utility helpers -------------------
  formatTime(timeVal) {
    if (!timeVal) return '';
    if (typeof timeVal === 'number') {
      const date = new Date(timeVal);
      let hours = date.getUTCHours();
      const minutes = date.getUTCMinutes();
      let ampm = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12;
      hours = hours ? hours : 12;
      return `${hours.toString().padStart(2, "0")}:${minutes.toString().padStart(2, "0")} ${ampm}`;
    }
    try {
      const parts = ('' + timeVal).split(':');
      let h = parseInt(parts[0], 10);
      const m = parseInt(parts[1] || '0', 10);
      let ampm = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      h = h ? h : 12;
      return `${h.toString().padStart(2, "0")}:${m.toString().padStart(2, "0")} ${ampm}`;
    } catch (e) {
      return '' + timeVal;
    }
  }

  convertToMinutes(timeStr) {
    if (!timeStr) return null;
    let [time, period] = timeStr.split(' ');
    if (!period) period = '';
    let [hours, minutes] = time.split(':').map(Number);
    if (period.toUpperCase() === 'PM' && hours !== 12) hours += 12;
    if (period.toUpperCase() === 'AM' && hours === 12) hours = 0;
    return hours * 60 + (minutes || 0);
  }

  get computedPlaceholder() {
    return this.capacity ? (Array.isArray(this.capacity) ? this.capacity[0] : this.capacity) : '';
  }

  // Generic safe stringify for debugging
  safeStringify(obj) {
    try {
      return JSON.stringify(obj);
    } catch (e) {
      return String(obj);
    }
  }

  // ------------------- Show toast -------------------
  showToast(title, message, variant = 'info') {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  // ------------------- Apex-backed loaders -------------------
  async loadBuildings() {
    try {
      const res = await getAllBuildings();
      this.buildingOptions = Array.isArray(res) ? res.map(b => ({ label: b, value: b })) : [];
    } catch (err) {
      console.error('Error loading buildings', err);
      this.buildingOptions = [];
    }
  }

  async getTimeDetails() {
    try {
      const res = await getTimeValues();
      this.timeOptions = Array.isArray(res) ? res.map(t => ({ label: t.Name, value: t.Name })) : [];
    } catch (err) {
      console.error('Error getTimeDetails', err);
      this.timeOptions = [];
    }
  }

  async getEndTimeSlots() {
    try {
      const res = await getAllTimeSlots();
      if (Array.isArray(res)) {
        this.endtimeOptions = res.map((item) => ({ label: this.formatTime(item.End_Time__c), value: item.Id }));
        this.startTimeOptions = res.map((item) => ({ label: this.formatTime(item.Start_Time__c), value: item.Id }));
      } else {
        this.endtimeOptions = [];
        this.startTimeOptions = [];
      }
    } catch (err) {
      console.error('Error getEndTimeSlots', err);
    }
  }

  async loadFacilities(facilityType, buildingName, floorNumber, facilityName) {
    try {
      const res = await getAllFacilities({
        facilityType: facilityType || 'Event Venues',
        buildingName: buildingName || '',
        floorNumber: floorNumber || '',
        facilityName: facilityName || ''
      });
      if (!Array.isArray(res)) return;

      // Building list
      if (facilityType && !buildingName && !floorNumber && !facilityName) {
        const blocks = res.map(f => ({ label: f.Block__c || 'NA', value: f.Block__c || 'NA' }));
        this.facilityBuildingNameOptions = Array.from(new Set(blocks.map(JSON.stringify))).map(JSON.parse);
      }

      // Floor list
      if (facilityType && buildingName && !floorNumber) {
        const floors = res.map(f => ({ label: f.Floor__c || 'NA', value: f.Floor__c || 'NA'}));
        this.facilityFloorOptions = Array.from(new Set(floors.map(JSON.stringify))).map(JSON.parse);
      }

      // Rooms & facility names
      if (facilityType && buildingName && floorNumber && !facilityName) {
        const rooms = res.map(f => ({ label: f.Room__c || 'NA', value: f.Room__c || 'NA' }));
        this.facilityRoomNumOptions = Array.from(new Set(rooms.map(JSON.stringify))).map(JSON.parse);

        const names = res.map(f => ({ id: f.Id, label: f.Name || 'NA', value: f.Name || 'NA', capacity: f.hed__Capacity__c || 0 }));
        this.facilityNameOptions = Array.from(new Set(names.map(JSON.stringify))).map(JSON.parse);
      }
     /* Rooms & facility names
if (facilityType && buildingName && floorNumber && !facilityName) {

    // --- ROOM OPTIONS ---
    const rooms = res.map(f => ({
        label: f.Room__c || 'NA',
        value: f.Room__c || 'NA'
    }));
    this.facilityRoomNumOptions = Array.from(new Set(rooms.map(JSON.stringify))).map(JSON.parse);

    // --- FACILITY NAME OPTIONS ---
    const names = res.map(f => ({
        id: f.Id,
        label: f.Name || 'NA',
        value: f.Name || 'NA',
        capacity: f.hed__Capacity__c || 0
    }));
    this.facilityNameOptions = Array.from(new Set(names.map(JSON.stringify))).map(JSON.parse);

    // --- AUTO SELECT FACILITY NAME IF ONLY ONE MATCHES THE ROOM ---
    if (this.selectedRoomNum) {
        const filteredForRoom = this.facilityNameOptions.filter(
            n => n.value && n.value !== 'NA'
        );

        if (filteredForRoom.length === 1) {
            this.selectedFacilityName = filteredForRoom[0].value;
            this.facilityId = [filteredForRoom[0].id];
        }
    }
}*/


      // If specific facilityName filter used
      if (facilityType && buildingName && floorNumber && facilityName) {
        const facilityNameData = res.map(f => ({ id: f.Id, label: f.Name || 'NA', value: f.Name || 'NA', capacity: f.hed__Capacity__c || 0 }));
        const uniq = Array.from(new Set(facilityNameData.map(JSON.stringify))).map(JSON.parse);
        this.facilityNameOptions = uniq;
        this.facilityId = uniq.filter(f => f.id).map(f => f.id);
        if (uniq.length > 0) this.capacity = [uniq[0].capacity];
      }

      // Capacity options fallback
      const capacityOptions = res.map((f) => ({ label: f.hed__Capacity__c || 0, value: f.hed__Capacity__c || 0 }));
      this.facilityCapacityOption = Array.from(new Set(capacityOptions.map(JSON.stringify))).map(JSON.parse);
      this.capacity = this.facilityCapacityOption.map(e => e.label) || 0;
    } catch (err) {
      console.error('Error in loadFacilities', err);
    }
  }

  async getEventFacilities() {
    try {
      const res = await getEventFacilities();
      if (Array.isArray(res)) {
        const responseData = res.map(f => ({ label: f.hed__Facility_Type__c || 'NA', value: f.hed__Facility_Type__c || 'NA' }));
        this.facilityEventTypeOptions = Array.from(new Set(responseData.map(JSON.stringify))).map(JSON.parse);
      }
    } catch (err) {
      console.error('getEventFacilities', err);
    }
  }

  async getLabFacilities() {
    try {
      const res = await getLabFacilities({ accountId: this.recordId });
      if (Array.isArray(res)) {
        const responseData = res.map(f => ({ label: f.hed__Facility_Type__c || 'NA', value: f.hed__Facility_Type__c || 'NA' }));
        this.facilityLabTypeOptions = Array.from(new Set(responseData.map(JSON.stringify))).map(JSON.parse);
      }
    } catch (err) {
      console.error('getLabFacilities', err);
    }
  }

  async getAminities(facilityId, selectedBuildingName, selectedRoomName, selectedRoomNum) {
    try {
      const idToSend = Array.isArray(facilityId) ? facilityId[0] : facilityId;
      const res = await getAminities({ facilityId: idToSend, Block: selectedBuildingName, Floor: selectedRoomName, Room: selectedRoomNum });
      const aminityData = (res || []).map(a => ({ label: a.Item_Name__c || 'No aminities available', value: a.Item_Name__c || 'No aminities available' }));
      this.additionalAmenitiesOptions = aminityData.length ? aminityData : [{ label: 'No aminities are available for the selected facility', value: 'Others' }];
    } catch (err) {
      console.error('getAminities', err);
      this.additionalAmenitiesOptions = [{ label: 'No aminities are available for the selected facility', value: 'Others' }];
    }
  }

  async getAdditionalAmenities() {
    try {
      const res = await getAdditionalAmenities();
      this.additionalAmenitiesOptions2 = (res || []).length ? (res.map(i => ({ label: i.Name__c || 'No amenities available', value: i.Name__c || 'No amenities available' }))) : [{ label: 'No amenities available', value: 'Others' }];
    } catch (err) {
      console.error('getAdditionalAmenities', err);
      this.additionalAmenitiesOptions2 = [{ label: 'No amenities available', value: 'Others' }];
    }
  }

  async getCourseScedules() {
    try {
      const res = await getCourseScedules({ recordId: this.recordId });
      if (Array.isArray(res) && res.length > 0) {
        const e = res[0];
        this.courseStartTime = this.formatTime(e.hed__Start_Time__c);
        this.courseEndTime = this.formatTime(e.hed__End_Time__c);
        this.courseDate = e.Date__c;
      }
    } catch (err) {
      console.error('getCourseScedules', err);
    }
  }

  get hasConflicts() {
        return this.existingBookings && this.existingBookings.length > 0;
    }

  // ------------------- UI handlers -------------------
  async handleChange(event) {
    const { name, value, dataset } = event.target;
    const rowId = dataset ? dataset.id : undefined;
    try {
      switch (name) {
        case "facilityType":
          this.selectedFacilityType = value;
          this.selectedBuildingName = null;
          this.selectedRoomName = null;
          this.selectedFacilityName = null;
          this.isfacilityTpe = value === "Event Venues";
          await this.loadFacilities(value, null, null, null);
          break;

        case "buildingNameName":
          this.selectedBuildingName = value;
          this.selectedRoomName = undefined;
          this.selectedRoomNum = undefined;
          this.selectedFacilityName = null;
          this.facilityRoomNumOptions = [];
          await this.loadFloors(value);
          await this.loadFacilities(this.selectedFacilityType || this.eventValue, value, null, null);
          break;

        case "floorNumber":
          this.selectedRoomName = value;
          this.selectedFacilityName = null;
          this.selectedRoomNum = undefined;
          this.facilityRoomNumOptions = [];
          await this.loadRooms(this.selectedBuildingName, value);
          await this.loadFacilities(this.selectedFacilityType || this.eventValue, this.selectedBuildingName, value, null);
          break;

        /*case "roomNum":
          this.selectedRoomNum = value;
          this.selectedFacilityName = null;
          await this.loadFacilities(this.selectedFacilityType || this.eventValue, this.selectedBuildingName, this.selectedRoomName, null);
          await this.getAminities(this.facilityId, this.selectedBuildingName, this.selectedRoomName, this.selectedRoomNum);
          await this.getAdditionalAmenities();
          break;

        case "facilityName":
          this.selectedFacilityName = value;
          this.isCapacity = true;
          {
            const found = this.facilityNameOptions && this.facilityNameOptions.find(f => f.value === value);
            if (found && found.id) this.facilityId = [found.id];
          }
          break;*/
          case "roomNum":
    this.selectedRoomNum = value;

    // Reset facility
    this.selectedFacilityName = null;
    this.facilityId = null;

    // Load facility names for selected room
    await this.loadFacilities(
        this.selectedFacilityType || this.eventValue,
        this.selectedBuildingName,
        this.selectedRoomName,
        null
    );

    // Auto-load amenities
    await this.getAminities(
        this.facilityId,
        this.selectedBuildingName,
        this.selectedRoomName,
        this.selectedRoomNum
    );
    await this.getAdditionalAmenities();
    break;


case "facilityName":
    this.selectedFacilityName = value;
    this.isCapacity = true;

    // Find Facility Id
    const found = this.facilityNameOptions?.find(f => f.value === value);
    if (found && found.id) {
        this.facilityId = [found.id];
    }
    break;


        case "startdate":
          if (new Date(value) < new Date().setHours(0, 0, 0, 0)) {
            this.showToast('Error', 'Start date cannot be in the past.', 'error');
            this.selectedStartDate = null;
          } else if (this.selectedEndDate && new Date(value) > new Date(this.selectedEndDate).setHours(0,0,0,0)) {
            this.showToast('Error', 'Start date cannot be after end date.', 'error');
            this.selectedStartDate = null;
          } else {
            this.selectedStartDate = value;
          }
          break;

        case "enddate":
          if (new Date(value) < new Date().setHours(0, 0, 0, 0)) {
            this.showToast('Error', 'End date cannot be in the past.', 'error');
            this.selectedEndDate = null;
          } else if (this.selectedStartDate && new Date(value) < new Date(this.selectedStartDate).setHours(0,0,0,0)) {
            this.showToast('Error', 'End date cannot be before start date.', 'error');
            this.selectedEndDate = null;
          } else {
            this.selectedEndDate = value;
          }
          break;

        case "startTime":
          {
            const totalStartTimeMinutes = this.convertToMinutes(value);
            if (this.selectedStartDate && (new Date(this.selectedStartDate).setHours(0,0,0,0) === (new Date()).setHours(0,0,0,0))) {
              const now = new Date(); const currentMinutes = now.getHours()*60 + now.getMinutes();
              if (totalStartTimeMinutes < currentMinutes) {
                this.showToast('Error','Start time cannot be in the past.','error');
                this.selectedStartTime = null; break;
              }
            }
            if (this.selectedStartDate === this.selectedEndDate && this.selectedEndTime) {
              if (value === this.selectedEndTime) {
                this.showToast('Error','Start time cannot be the same as end time.','error'); this.selectedStartTime = null; break;
              } else if (this.convertToMinutes(value) > this.convertToMinutes(this.selectedEndTime)) {
                this.showToast('Error','Start time should not be greater than the end time.','error'); this.selectedStartTime = null; break;
              }
            }
            this.selectedStartTime = value;
          }
          break;

        case "endTime":
          {
            const endTimeMinutes = this.convertToMinutes(value);
            const startTimeMinutes = this.convertToMinutes(this.selectedStartTime);
            if (this.selectedStartDate === this.selectedEndDate && this.selectedStartTime) {
              if (value === this.selectedStartTime) {
                this.showToast('Error','End time cannot be same as start time.','error'); this.selectedEndTime = null; break;
              } else if (startTimeMinutes && endTimeMinutes < startTimeMinutes) {
                this.showToast('Error','End time should not be less than start time.','error'); this.selectedEndTime = null; break;
              }
            }
            this.selectedEndTime = value;
          }
          break;

        case "Reason":
          this.bookingReason = value;
          break;

        case "Attendees":
          // Regular expression to check if the string contains only digits
          const isEntirelyNumeric = /^\d+$/.test(value);
          const parsedAttendees = parseInt(value, 10);          
          if (!value) {            
            // Allow them to clear out the field without throwing an error immediately
            this.numberOfAttendees = null;
            this.showToast('Error', 'Please enter a valid whole number of attendees (minimum 1).', 'error');
          } else if (!isEntirelyNumeric || isNaN(parsedAttendees) || parsedAttendees < 1) {
            this.showToast('Error', 'Please enter a valid whole number of attendees (minimum 1).', 'error');
            this.numberOfAttendees = null; // Clear the invalid value
          }else {
            this.numberOfAttendees = parsedAttendees;
          }          
          break;  

        case "additionalFacility":
          this.additionalFacility = value;
          if (!this.selectedValues.includes(value)) this.selectedValues = [...this.selectedValues, value];
          if (value === 'Others') this.isAmenitiesRequired = true;
          break;

        case "additionalFacility2":
        case "quantity":
          this.updateRow(rowId, { [name]: value });
          break;

        case "quantityOfAdditionalAmenities":
          this.quantityOfAdditionalAmenities = value;
          break;

        case "Others":
          this.descriptions = value;
          break;

        case "Capacity":
          this.capacity = value;
          break;

        case "iaExamHall":
          this.selectedFacilityType = 'Event Venues';
          this.IAExamHall = true;
          break;

        default:
          break;
      }
    } catch (err) {
      console.error('handleChange error', err);
    } finally {
      this.updateAdditionalFacilityString();
      if (this.selectedStartDate && this.selectedEndDate && this.selectedEndTime && this.selectedStartTime) this.isDisabled = false;
    }
  }

  handleChange2(event) {
    // kept for compatibility - identical behavior to updateRow via dataset.id
    const { name, value, dataset } = event.target;
    const rowId = dataset ? dataset.id : undefined;
    this.updateRow(rowId, { [name]: value });
  }

  handleRemove(event) {
    const valueToRemove = event.currentTarget.dataset.value;
    this.selectedValues = this.selectedValues.filter(v => v !== valueToRemove);
  }

  handleRemove2(event) {
    const valueToRemove = event.currentTarget.dataset.value;
    this.selectedValues2 = this.selectedValues2.filter(v => v !== valueToRemove);
  }

  addRow() {
    const newId = this.rows.length ? Math.max(...this.rows.map(r => r.id)) + 1 : 1;
    this.rows = [...this.rows, { id: newId, additionalFacility2: '', quantity: '', additionalFacilityWithQuantity: '' }];
  }

  deleteRow(event) {
    const index = event.currentTarget.dataset.index;
    this.rows = this.rows.filter((r, idx) => idx != index);
    this.updateAdditionalFacilityString();
  }

  updateRow(rowId, updatedFields) {
    this.rows = this.rows.map(row => {
      if (row.id == rowId) {
        const updatedRow = { ...row, ...updatedFields };
        if (updatedRow.additionalFacility2 && updatedRow.quantity) {
          updatedRow.additionalFacilityWithQuantity = `${updatedRow.additionalFacility2} - ${updatedRow.quantity}`;
        } else {
          updatedRow.additionalFacilityWithQuantity = updatedRow.additionalFacilityWithQuantity || '';
        }
        return updatedRow;
      }
      return row;
    });
    this.updateAdditionalFacilityString();
  }

  updateAdditionalFacilityString() {
    const formatted = this.rows
      .filter(r => r.additionalFacilityWithQuantity && r.additionalFacilityWithQuantity.trim() !== '')
      .map(r => r.additionalFacilityWithQuantity)
      .join(', ');
    this.additionalFacility2 = formatted && formatted.trim() !== '' ? formatted : 'NA';
    this.quantityOfAdditionalAmenities = this.rows.filter(r => r.quantity && r.quantity.toString().trim() !== '').map(r => r.quantity).join(',');
  }

  // ------------------- Conflict modal actions -------------------
  handleSelectOther() {
    this.showConflictModal = false;
    // Let user pick other facility — no navigation here
  }

  closeConflictModal() {
    this.showConflictModal = false;
  }

  // ------------------- Main save (robust) -------------------
  async handleSave() {
    this.isLoading = true;

    // small helper to normalize raw apex responses (Proxy -> plain)
    const normalizeResponse = (raw) => {
      let res = {};
      try {
        if (!raw) return {};
        if (typeof raw === 'string') return { status: raw };
        // try JSON clone (works for plain object)
        try {
          res = JSON.parse(JSON.stringify(raw));
        } catch (e) {
          // Proxy/circular: pick common keys manually
          res.status = raw.status ?? raw['status'] ?? raw.Status ?? raw['Status'];
          res.message = raw.message ?? raw['message'] ?? raw.Message ?? raw['Message'];
          res.conflicts = raw.conflicts ?? raw['conflicts'] ?? [];
        }
      } catch (e) {
        res = { status: undefined, message: String(raw) };
      }
      return res;
    };

    try {
      // basic validations
      if (!this.selectedStartDate || !this.selectedEndDate || !this.selectedStartTime || !this.selectedEndTime) {
        this.showToast('Error', 'Please select start & end dates and times.', 'error');
        return;
      }
      if (!this.selectedBuildingName || !this.selectedRoomName || !this.selectedRoomNum) {
        this.showToast('Error', 'Please select building, floor and room.', 'error');
        return;
      }
      if (!this.selectedFacilityName) {
        this.showToast('Error', 'Please select a facility.', 'error');
        return;
      }
      if(!this.numberOfAttendees){
        this.showToast('Error', 'Please enter Number Of Attendees.', 'error');
        return;
      }
      if(!this.bookingReason){
        this.showToast('Error', 'Please enter Reason For Booking.', 'error');
        return;
      }


      // build payload matching Apex wrapper
      const payload = {
        buildingName: this.selectedBuildingName,
        facilityName: this.selectedFacilityName || this.facilityName || this.selectedFacilityType || this.eventValue || '',
        facilityType: this.IAExamHall === true ? 'IA Exam Hall' : (this.selectedFacilityType || this.facilityTypes || this.eventValue || ''),
        floorNumber: this.selectedRoomName,
        roomNumber: this.selectedRoomNum,
        startDate: this.selectedStartDate || this.courseDate,
        endDate: this.selectedEndDate || this.courseDate,
        startTime: this.selectedStartTime || this.courseStartTime,
        endTime: this.selectedEndTime || this.courseEndTime,
        facilityReason: this.bookingReason || 'NA',
        attendeesNumber : this.numberOfAttendees || 0,
        additionalFacility: this.selectedValues?.length ? this.selectedValues.join(', ') : 'NA',
        additionalFacility2: this.additionalFacility2 || 'NA',
        capacity: Array.isArray(this.capacity) ? (this.capacity[0] || 0) : (this.capacity || 0),
        quantityOfAdditionalAmenities: this.quantityOfAdditionalAmenities || 'NA',
        description: this.descriptions || 'NA',
        IAExamhall: !!this.IAExamHall,
        facilityId: (this.facilityId && this.facilityId.length > 0) ? this.facilityId[0] : null
      };

      console.log('Payload →', JSON.stringify(payload));

      // call apex
      const raw = await validateAndSaveFacility({ selectedFields: JSON.stringify(payload) });
      console.log('Raw Apex response:', raw);

      const res = normalizeResponse(raw);
      console.log('Normalized response:', res);

      const status = (res.status && typeof res.status === 'string') ? res.status.trim().toLowerCase() : (typeof res === 'string' ? res.toLowerCase() : '');
      const message = res.message || res.msg || '';

      if (status === 'conflict') {
        // Apex returns conflicts array
        this.existingBookings = Array.isArray(res.conflicts) ? res.conflicts.map(c => ({
          recordId: c.recordId || c.recordID || c.id || c.Id,
          facilityName: c.facilityName || c.facility || '',
          startDate: c.startDate || '',
          endDate: c.endDate || '',
          startTime: c.startTime || '',
          endTime: c.endTime || '',
          requesterName: c.requesterName || '',
          requesterPhone: c.requesterPhone || ''
        })) : [];
        this.showConflictModal = true;
        //this.showToast('Warning', message || 'Selected slot conflicts with existing bookings.', 'warning');
        return;
      }

      if (status === 'booked') {
        this.showToast('Warning', message || 'Slot already booked.', 'warning');
        return;
      }

      if (status === 'success') {
        this.showToast('Success', message || 'Facility booked successfully.', 'success');
        this.showCancellation = true;   
        this.showBooking = false;
        //this.cancelFromSave = true;
        /*try { this.handleCancelClick(); } catch (e) { console.warn('handleCancelClick error', e); }
        const lightningUrl = '/lightning/n/Event_Hall_Booking_Details';
        this[NavigationMixin.Navigate]({
        type: "standard__navItemPage",
        attributes: {
            url: lightningUrl
        }
    });*/
    //this.dispatchEvent(new CustomEvent('handleBookingSaved'));
        return;
      }

      // fallback for different-case statuses
      if (res.status === 'CONFLICT' || res.status === 'Conflict') {
        this.existingBookings = res.conflicts || [];
        this.showConflictModal = true;
       // this.showToast('Warning', res.message || 'Selected slot conflicts with existing bookings.', 'warning');
        return;
      }
      if (res.status === 'Success' || res.status === 'SUCCESS') {
        this.showToast('Success', res.message || 'Facility booked successfully.', 'success');
        this.cancelFromSave = true;
        try { this.handleCancelClick(); } catch (e) {}
        return;
      }

      // unknown response
      console.warn('Unexpected response from server', res);
      this.showToast('Error', message || 'Unexpected server response. Check console for details.', 'error');

    } catch (err) {
      // robust error extraction
      console.error('Save error (caught):', err);
      let userMsg = 'Unknown error';
      try {
        if (err?.body?.message) userMsg = err.body.message;
        else if (Array.isArray(err) && err[0]?.message) userMsg = err[0].message;
        else if (err?.message) userMsg = err.message;
        else userMsg = this.safeStringify(err);
      } catch (e) {
        userMsg = this.safeStringify(err);
      }
      this.showToast('Error', 'Error saving booking: ' + userMsg, 'error');
    } finally {
      this.isLoading = false;
    }
  }

  // ------------------- Cancel / navigation -------------------
  handleCancelClick() {
    // reset fields to base state
    this.selectedBuildingName = null;
    this.selectedFacilityName = null;
    this.selectedFacilityType = null;
    this.selectedRoomName = null;
    this.selectedRoomNum = null;
    this.selectedStartDate = null;
    this.selectedEndDate = null;
    this.selectedStartTime = null;
    this.selectedEndTime = null;
    this.bookingReason = null;
    this.numberOfAttendees = null;
    this.additionalFacility = null;
    this.filteredEndTimeSlots = [];
    this.filteredStartTimeSlots = [];
    this.facilityNameOptions = [];
    this.facilityEventTypeOptions = [];
    this.facilityBuildingNameOptions = [];
    this.facilityFloorOptions = [];
    this.facilityRoomNumOptions = [];
    this.facilityCapacityOption = [];
    this.rows = [{ id: 1, additionalFacility2: '', quantity: '', additionalFacilityWithQuantity: '' }];
    this.selectedValues = [];
    this.selectedValues2 = [];
    this.additionalFacility2 = 'NA';
    this.quantityOfAdditionalAmenities = 'NA';
    this.descriptions = '';

    // navigate back or to record
    if (this.recordId) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.recordId,
          objectApiName: "hed__Course_Offering_Schedule__c",
          actionName: "view",
        },
      });
    } else {
      if (window.location.pathname.includes('/s/')) {
        const basePath = this.label.basepath;
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: { url: basePath }
        });
      } else {
        // fallback: navigate to newly created record page is not possible here without id
        // just reset UI
        // Optionally navigate to a nav item if you prefer
      }
    }
  }

  // small helper for loadFloors / loadRooms
  async loadFloors(buildingName) {
    try {
      if (!buildingName) { this.facilityFloorOptions = []; return; }
      const res = await getFloorsByBuilding({ buildingName });
      this.facilityFloorOptions = (res || []).map(f => ({ label: f, value: f }));
    } catch (err) { console.error('loadFloors', err); this.facilityFloorOptions = []; }
  }

  async loadRooms(buildingName, floorNumber) {
    try {
      if (!buildingName || !floorNumber) { this.facilityRoomNumOptions = []; return; }
      const res = await getRoomsByFloor({ buildingName, floorNumber });
      this.facilityRoomNumOptions = (res || []).map(r => ({ label: r, value: r }));
    } catch (err) { console.error('loadRooms', err); this.facilityRoomNumOptions = []; }
  }
}