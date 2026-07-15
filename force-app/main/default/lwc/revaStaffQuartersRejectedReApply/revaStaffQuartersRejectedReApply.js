import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import USER_ID from '@salesforce/user/Id';
import updateRejectedQuaterReq from '@salesforce/apex/RevaStaffQuartersRequestAndAllotment.updateRejectedQuaterReq';

export default class RevaStaffQuartersRejectedReApply extends LightningElement {
    @api isReApplyFormOpen;
    @track roomType;
    @track joiningDate;
    @track disableQuarters = true;
    @api requestId;
    roomTypeValues;
    profileName;
    boolSpinner = false;
  

    teachingStaffPicklistValues = [{ label: '1 BHK', value: '1 BHK' }, { label: '2 BHK', value: '2 BHK' }];

    nonTeachingStaffPicklistValues = [{ label: '1 BHK', value: '1 BHK' }, { label: '2 BHK', value: '2 BHK' }];
    schoolDirectorStaffPicklistValues = [{ label: '2 BHK', value: '2 BHK' }, { label: '3 BHK', value: '3 BHK' }];

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILE_NAME_FIELD]
    })
    fetchUserProfile({ data, error }) {
        if (data) {
            console.log(JSON.stringify(data));
            this.profileName = data.fields.Profile.displayValue;
       
            console.log('PROFILE NAME  ' + JSON.stringify(this.profileName));
            if (this.profileName === 'Professor') {
                this.roomTypeValues = this.teachingStaffPicklistValues;
            } else if (this.profileName === 'Non Teaching Profile') {
                this.roomTypeValues = this.nonTeachingStaffPicklistValues;
            }
            else if (this.profileName === 'School Director') {
                this.roomTypeValues = this.schoolDirectorStaffPicklistValues;
            }
            else {
                this.roomTypeValues = this.teachingStaffPicklistValues;
            }
        }
    }


    closeModal(event) {
        console.log('closemodel---');

        this.dispatchEvent(new CustomEvent('closepopup', {
            detail: {
                isCloseReApply: true
            }
        }))
    }

    handleRoomType(event) {
        this.roomType = event.detail.value;
    }

    get disableQuarters() {
        return !this.roomType;
    }
    handleJoiningDateChange(event) {
        console.log('joining date ---' + event.target.value);

        const selectedDate = new Date(event.target.value);
        console.log('selectedDate ---' + selectedDate);
        const today = new Date();
        console.log('today ---' + today);
        if (selectedDate < today) {
            console.log('today - noyt--');
          
            this.showToast('Error', 'Joining date cannot be in the past or toady date.', 'error');
            this.joiningDate = null; // Reset the joining date
            this.disableQuarters = true;
        } else {
            console.log('today - above--');
            this.joiningDate = event.target.value;
            this.disableQuarters = false;
        }
    }

    async updateExistingRequest(event) {
        if (this.joiningDate != null && this.roomType != null) {
            this.boolSpinner = true;

            try {
                const objResult = await updateRejectedQuaterReq({ roomType: this.roomType, joiningDate: this.joiningDate ,requestId :this.requestId});
                console.log('result ' + JSON.stringify(objResult));
                if (objResult && objResult.isError) {
                    this.showToast('Error', objResult.errorMessage, 'error');
                }
                if (objResult && objResult.isSuccess) {

                    this.event1 = setTimeout(() => {
                        this.showToast('Success', objResult.successMessage, 'success');
                        window.location.reload();
                        
                    }, 6000);

                    //window.location.reload();
                    
                }

            } catch (error) {

            }
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}