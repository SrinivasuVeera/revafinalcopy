import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import getBookingRecord from "@salesforce/apex/RevaHostelLeaveRequestController.getRecord";
import REVA_MEAL_BOOKING from '@salesforce/schema/Reva_Meal_Booking__c';
import BOOKING_STATUS from '@salesforce/schema/REVA_Hostel_Leave_Request__c.Status__c';
import IMAGES from "@salesforce/resourceUrl/revaIcons";
import getContactImage from '@salesforce/apex/getMealBookingRecord.getContactImage';


const fields = [BOOKING_STATUS];
export default class HostelLeaveActiveQRCode extends LightningElement {
 @api recordId;
    objectApiName = REVA_MEAL_BOOKING;
    @track timeStamp = new Date().getTime();
    @track urlQRCode;
    @track mealBookingStatus;

    @track bookingForName;
    @track bookingForEmail;
    @track bookingForPhone;
    @track bookingForPhoto;
    // Flag to track whether the wire service has been invoked
    wireServiceInvoked = false;

    @wire(getRecord, {
        recordId: { recordId: '$recordId', fields}//'a351e000000Gw5gAAC'
    })


     connectedCallback() {
        this.intervalId = setInterval(() => {
            this.reloadData();
        }, 30000); // 30 seconds in milliseconds
        console.log('recordIDddReload', this.recordId);
        this.getFiles();
        this.fetchRecord();
        if (!this.wireServiceInvoked) {
            this.getMealBookingRecord({ data: null, error: null });
        }
    }

    getMealBookingRecord({ data, error }) {
        console.log('recordIdQR '+this.recordId);
        console.log('fieldsQR '+JSON.stringify(fields));
        console.log('dataQR', JSON.stringify(data));
      //  console.log('dataQR', data.fields.Status__c.value);
        if (data) {
            console.log('data1111', JSON.stringify(data));
            const bookingStatus = data.fields.Status__c.value;
            this.mealBookingStatus = bookingStatus;

            this.bookingForName = data.fields.Booking_For__r.value.fields.Name.value;
            console.log(this.bookingForName);
            this.bookingForSRN = data.fields.Booking_For__r.value.fields.SRN_Number__c.value;
            console.log(this.bookingForSRN);
            this.bookingForPhone = data.fields.Booking_For__r.value.fields.Phone.value;
            console.log(this.bookingForPhone);
           // this.bookingForPhoto = data.fields.Booking_For__r.value.fields.File_Passport_Size_Photo__c.value;
           // console.log(this.bookingForPhoto);

            this.updateUrl(bookingStatus);
            // Set the flag to true after the wire service is invoked
            this.wireServiceInvoked = true;
        } else if (error) {
            console.error('Error loading record', error);
        } 
    }
   

   
   
    handleStatusUpdate(event) {
        if (event.detail.status === 'Availed') {
            this.fetchRecord();
        }
    }

    fetchRecord() {
        getBookingRecord({recordId : this.recordId})
        .then(result => {
            console.log(result);
            var bookingStatus = result.Status__c
            this.mealBookingStatus = result.Status__c

            this.bookingForName = result.Contact__r.Name;
            console.log(this.bookingForName);
            this.bookingForSRN = result.Contact__r.SRN_Number__c;
            console.log( this.bookingForSRN);
            this.bookingForPhone = result.Contact__r.Phone;
            console.log(this.bookingForPhone);
           // this.bookingForPhoto = result.Contact__r.File_Passport_Size_Photo__c;
           // console.log(this.bookingForPhoto);

            this.updateUrl(this.mealBookingStatus);
        //this.urlQRCode = 'http://api.qrserver.com/v1/create-qr-code/?data=HelloWorld!&size=300x300'
            console.log('resultt', bookingStatus);
        })
        .catch(error => {
            console.log('error', JSON.stringify(error));
        })
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

    getFiles() {
        console.log('inside method'+this.recordId);
        
        getContactImage({ recordId: this.recordId })
            .then(result => {
                console.log('inside result'+result);
                if (result) {
                  this.bookingForPhoto = result; 
                    
                 }else {
                    console.log('ERROR ----- ');
                }
            })
            .catch(error => {
                console.error('Error fetching files:', error);
            });
    }

    reloadData() {
        this.timeStamp = new Date().getTime();
        // Update the URL based on the stored data
        this.updateUrl(this.mealBookingStatus);
    }

    updateUrl(bookingStatus) {
        console.log('bookingStatus ',bookingStatus);
         this.urlQRCode = bookingStatus === 'Approved'
          ? `http://api.qrserver.com/v1/create-qr-code/?data=${this.recordId}-${this.timeStamp}&size=300x300`
            : `http://api.qrserver.com/v1/create-qr-code/?data=${this.recordId}-${this.timeStamp}&size=300x300` ;

    }

    
    // handleQRCodeScanned() {
    //     if (this.mealBookingStatus === 'Approved') {
    //         console.log("this.mealBookingStatus ", this.mealBookingStatus );
    //         updateBookingStatus({ recordId: this.recordId, newStatus: 'Missed meals' })
    //             .then(() => {
    //                 console.log(this.mealBookingStatus);
    //                 this.mealBookingStatus = 'Missed meals';
    //                 this.updateUrl(this.mealBookingStatus);
                    
    //             }
    //         )
    //             .catch(error => {
    //                 console.error('Error updating status', error);
    //             });
    //     }
    // }
}