import { LightningElement, track } from 'lwc';
import getBlocks from '@salesforce/apex/RoomBookingController.getBlocks';
import getFacilitiesByBlock from '@salesforce/apex/RoomBookingController.getFacilitiesByBlock';
import getBlockFacilityDetails from '@salesforce/apex/RoomBookingController.getBlockFacilityDetails';
import getFixedSlots from '@salesforce/apex/RoomBookingController.getFixedSlots';
import saveBookingAndCheck from '@salesforce/apex/RoomBookingController.saveBookingAndCheck';
import checkRoomStatus from '@salesforce/apex/RoomBookingController.checkRoomStatus';

export default class RoomBookingNonTeaching extends LightningElement {
  get today() {
    return new Date().toISOString().split('T')[0];
}
  // toggle
  @track isSingle = true;
  @track singleDate;
  @track startDate;
  @track endDate;

  // block & facilities
  @track blockOptions = [];
  @track selectedBlock;
  @track facilityOptions = [];
  @track selectedFacilities = [];
  @track selectedFacility = '';

  // slots
  @track slotOptions = [];
  @track selectedSlots = [];

  // slot timing mapping
  slotTimeMap = {
    '1': '8:30 - 9:30',
    '2': '9:30 - 10:30',
    '4': '10:50 - 11:50',
    '5': '11:50 - 12:50',
    '7': '01:30 - 02:30',
    '8': '02:30 - 03:30',
    '9': '03:30 - 04:30'
  };

  firstHalfSlots = ['1', '2', '4', '5'];
  secondHalfSlots = ['7', '8', '9'];

  // reason
  @track bookingReason = '';

  // popups
  @track showConflictPopup = false;
  @track showConfirmPopup = false;
  @track showSuccessPopup = false;
  @track showFacilityConflictPopup = false
  @track showErrorPopup = false;
  @track availabilityMessage;
  @track createdCount = 0;
  @track facilityCapacities = [];
  @track capacity = 0;
  @track showBlockPopup = false;
  @track blockFacilities = [];
  @track bookedSlotDetails = [];
  @track canOverride = false;
  @track showValidationPopup = true;

  
  // -------- lifecycle --------
  connectedCallback() {
    getBlocks()
      .then(data => {
        this.blockOptions = (data || []).map(b => ({ label: b, value: b }));
      })
      .catch(err => this.logError('getBlocks', err));

    getFixedSlots()
      .then(slots => {
        this.slotOptions = (slots || []).map(s => {
          const slotId = String(s);
          const time = this.slotTimeMap[slotId] || '';
          return {
            label: time ? `Slot ${slotId} (${time})` : `Slot ${slotId}`,
            value: slotId,
            checked: false
          };
        });
      })
      .catch(err => this.logError('getFixedSlots', err));
  }

  // -------- getters --------
  get singleVariant() { return this.isSingle ? 'brand' : 'neutral'; }
  get multiVariant() { return this.isSingle ? 'neutral' : 'brand'; }
  get disableBlockPopup() { return !this.selectedBlock; }
  get isFirstHalfChecked() { return this.firstHalfSlots.every(s => this.selectedSlots.includes(s)); }
  get isSecondHalfChecked() { return this.secondHalfSlots.every(s => this.selectedSlots.includes(s)); }

  // -------- toggle --------
  selectSingle() { this.isSingle = true; }
  selectMultiple() { this.isSingle = false; }

  // -------- handlers: dates --------
  /*handleSingleDate(e) { this.singleDate = e.target.value; }
  handleStartDate(e) { this.startDate = e.target.value; }
  handleEndDate(e) { this.endDate = e.target.value; }*/

  handleSingleDate(e) {
    const selectedDate = e.target.value;
    const today = this.today;

    if (selectedDate < today) {
        alert('Past dates are not allowed');
        this.singleDate = null;
        return;
    }

    this.singleDate = selectedDate;
  }

   handleStartDate(e) {
    const selectedDate = e.target.value;
    const today = this.today;

    if (selectedDate < today) {
        alert('Past dates are not allowed');
        this.startDate = null;
        return;
    }

    this.startDate = selectedDate;
   }

    handleEndDate(e) {
     const selectedDate = e.target.value;

     if (selectedDate < this.startDate) {
        alert('End Date cannot be less than Start Date');
        this.endDate = null;
        return;
     }

     this.endDate = selectedDate;
    }

  // -------- handlers: block / facilities --------
  handleBlockChange(e) {
    this.selectedBlock = e.detail.value;
    this.selectedFacilities = [];
    this.facilityOptions = [];
    if (this.selectedBlock) {
      getFacilitiesByBlock({ blockValue: this.selectedBlock })
        .then(data => {
          this.facilityOptions = (data || []).map(f => ({
            label: `${f.facilityName} (${f.roomNumber})`,
            value: f.facilityId
          }));
        })
        .catch(err => this.logError('getFacilitiesByBlock', err));
    }
  }

  handleFacilitySelect(e) {
    const facilityId = e.detail.value;
    const selected = this.facilityOptions.find(f => f.value === facilityId);

    if (selected && !this.selectedFacilities.find(f => f.value === facilityId)) {
      this.selectedFacilities = [
        ...this.selectedFacilities,
        { label: selected.label, value: selected.value, capacity: selected.capacity || 0 }
      ];
      this.capacity = selected.capacity || 0;
    }
    this.selectedFacility = '';
  }

  handleRemoveFacility(e) {
    const facilityId = e.detail.name;
    this.selectedFacilities = this.selectedFacilities.filter(f => f.value !== facilityId);
  }

  // -------- handlers: slots --------
  handleSlotChange(e) {
    const slotValue = e.target.dataset.id;
    const isChecked = e.target.checked;
    if (isChecked) {
      if (!this.selectedSlots.includes(slotValue)) {
        this.selectedSlots = [...this.selectedSlots, slotValue];
      }
    } else {
      this.selectedSlots = this.selectedSlots.filter(s => s !== slotValue);
    }
    this.slotOptions = this.slotOptions.map(opt =>
      opt.value === slotValue ? { ...opt, checked: isChecked } : opt
    );
  }

  handleFirstHalf(e) {
    const isChecked = e.target.checked;
    if (isChecked) {
      this.selectedSlots = Array.from(new Set([...this.selectedSlots, ...this.firstHalfSlots]));
    } else {
      this.selectedSlots = this.selectedSlots.filter(s => !this.firstHalfSlots.includes(s));
    }
    this.slotOptions = this.slotOptions.map(opt => ({
      ...opt,
      checked: isChecked ? (this.firstHalfSlots.includes(opt.value) || opt.checked) : (!this.firstHalfSlots.includes(opt.value) ? opt.checked : false)
    }));
  }

  handleSecondHalf(e) {
    const isChecked = e.target.checked;
    if (isChecked) {
      this.selectedSlots = Array.from(new Set([...this.selectedSlots, ...this.secondHalfSlots]));
    } else {
      this.selectedSlots = this.selectedSlots.filter(s => !this.secondHalfSlots.includes(s));
    }
    this.slotOptions = this.slotOptions.map(opt => ({
      ...opt,
      checked: isChecked ? (this.secondHalfSlots.includes(opt.value) || opt.checked) : (!this.secondHalfSlots.includes(opt.value) ? opt.checked : false)
    }));
  }

  handleReasonChange(e) { this.bookingReason = e.target.value; }

  // -------- validation --------
  validateInputs() {
    let sDate = this.isSingle ? this.singleDate : this.startDate;
    let eDate = this.isSingle ? this.singleDate : this.endDate;

    if (!this.selectedFacilities.length) {
      this.availabilityMessage = '⚠️ Please select at least one facility.';
      this.showValidationPopup = true;
      //this.showSuccessPopup = true;
      return false;
    }
    if (!sDate || !eDate) {
      this.availabilityMessage = '⚠️ Please select valid booking dates.';
      this.showValidationPopup = true;
      //this.showSuccessPopup = true;
      return false;
    }
    if (!this.selectedSlots.length) {
      this.availabilityMessage = '⚠️ Please select at least one slot.';
     this.showValidationPopup = true;
      //this.showSuccessPopup = true;
      return false;
    }
    if (!this.bookingReason) {
      this.availabilityMessage = '⚠️ Booking Reason is required.';
      //this.showSuccessPopup = true;
      this.showValidationPopup = true;
      return false;
    }
    return true;
  }
  closeValidation() {
  this.showValidationPopup = false;
}

 // NEXT
async check() {
  if (!this.validateInputs()) return;
 
  
  const sDate = this.isSingle ? this.singleDate : this.startDate;
  const eDate = this.isSingle ? this.singleDate : this.endDate;
  const facilityIds = this.selectedFacilities.map(f => f.value);

  try {
    const res = await checkRoomStatus({
      facilityIds,
      startDate: sDate,
      endDate: eDate,
      selectedSlots: this.selectedSlots,
      bookingReason: this.bookingReason,
      overrideBooking: false
    });

    

    // Defensive defaulting
    const bookedSlots = res.bookedSlots || [];
    console.log('Booked Slots:', bookedSlots); 

    // Split conflicts
    const fbConflicts = bookedSlots.filter(b => !b.scheduleId); 
     const coConflicts = bookedSlots.filter(b => b.scheduleId);
    console.log('fbConflicts:', fbConflicts);
    console.log('coConflicts:', coConflicts);

    // 1️⃣ Facility Booking conflict
    if (fbConflicts.length > 0) {
      this.bookedSlotDetails = [...fbConflicts];;
      this.showFacilityConflictPopup = true;
      this.showConflictPopup = false;
      this.showSuccessPopup = false;
      console.log('Facility conflict popup should show now:', this.bookedSlotDetails);
      return;
    }
    // 2️⃣ Course Offering conflict
    else if (coConflicts.length > 0) {
      this.bookedSlotDetails = coConflicts;
      const rawCaps = res.facilityCapacities || {};
      this.facilityCapacities = Object.entries(rawCaps).map(([key, value]) => ({ key, value }));
      this.canOverride = coConflicts.length > 0 && coConflicts[0].canOverride ? true : false;
      this.showConflictPopup = true;
      this.showFacilityConflictPopup = false;
      
      this.showSuccessPopup = false;
      return;
    }
    // 3️⃣ No Conflict → Success
    else {
      this.availabilityMessage = res.message || 'Room is Confirmed.';

      // reset + reassign for reactivity
      this.facilityCapacities = [];
      const rawCaps = res.facilityCapacities || {};
      this.facilityCapacities = Object.entries(rawCaps).map(([key, value]) => ({ key, value }));
      this.showFacilityConflictPopup = false;
      this.showConflictPopup = false;
      
      this.showSuccessPopup = true;
    }
    
  } catch (err) {
    this.availabilityMessage = this.extractError(err, 'Error while checking.');
    this.showErrorPopup = true;
    this.showFacilityConflictPopup = false;
      this.showConflictPopup = false;
      this.showSuccessPopup = false;
  }
}

// Success popup handlers
closeSuccess() { 
  this.showSuccessPopup = false; 
  this.facilityCapacities = []; 
}
handleSuccessOk() {
  this.showSuccessPopup = false;
  
  this.doSave(false); // save + send mails
}

// Save methods
confirmSave() { this.doSave(false); }
overrideSave() { this.showConflictPopup = false; this.doSave(true); }
doSave(override) {
  const sDate = this.isSingle ? this.singleDate : this.startDate;
  const eDate = this.isSingle ? this.singleDate : this.endDate;
  const facilityIds = this.selectedFacilities.map(f => f.value);
//this.resetpoup();
  saveBookingAndCheck({
    facilityIds,
    startDate: sDate,
    endDate: eDate,
    selectedSlots: this.selectedSlots,
    bookingReason: this.bookingReason,
    overrideBooking: override
  })
  .then(res => {
    this.availabilityMessage = res.message || this.availabilityMessage || 'Booking saved.';

    const rawCaps = res.facilityCapacities || {};
    this.facilityCapacities = Object.keys(rawCaps).length
      ? Object.entries(rawCaps).map(([key, value]) => ({ key, value }))
      : [];

    //this.showSuccessPopup = true;
  })
  .catch(err => {
    this.availabilityMessage = this.extractError(err, 'Error while saving.');
    this.showErrorPopup = true;
  });
}

// Popup Close
closeConflict() { this.showConflictPopup = false; }
closeFacilityConflict() { this.showFacilityConflictPopup = false; }
closeBlockPopup() { this.showBlockPopup = false; }
closeError() { this.showErrorPopup = false; }

get hasCapacities() {
  return Array.isArray(this.facilityCapacities) && this.facilityCapacities.length > 0;
}

 
  // -------- Block popup --------
  openBlockPopup() {
    if (!this.selectedBlock) return;
    getBlockFacilityDetails({ blockValue: this.selectedBlock })
      .then(data => {
        this.blockFacilities = data || [];
        this.showBlockPopup = true;
      })
      .catch(err => this.logError('getBlockFacilityDetails', err));
  }
  closeBlockPopup() { this.showBlockPopup = false; }

  // -------- Reset --------
  reset() {
    this.isSingle = true;
    this.singleDate = null;
    this.startDate = null;
    this.endDate = null;
    this.selectedBlock = null;
    this.facilityOptions = [];
    this.selectedFacilities = [];
    this.selectedFacility = '';
    this.selectedSlots = [];
    this.slotOptions = this.slotOptions.map(s => ({ ...s, checked: false }));
    this.bookingReason = '';
    this.showConflictPopup = false;
    this.showConfirmPopup = false;
    this.showSuccessPopup = false;
    this.availabilityMessage = null;
    this.createdCount = 0;
    this.blockFacilities = [];
    this.showBlockPopup = false;
    this.canOverride = false;
  }
 
  // resetpoup() {
  //   // Reset all popups
  //   this.showBlockPopup = false;
  //   this.showConflictPopup = false;
  //   this.showFacilityConflictPopup = false;
  //   this.showSuccessPopup = false;
  //   this.showErrorPopup = false;
  // } 
  // -------- Helpers --------
  logError(context, err) {
    console.error(`❌ ${context} error:`, JSON.stringify(err));
  }
  extractError(err, fallback) {
    if (err?.body?.message) return err.body.message;
    if (err?.message) return err.message;
    return fallback;
  }
}