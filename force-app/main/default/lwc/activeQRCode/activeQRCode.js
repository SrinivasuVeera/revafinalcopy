import { LightningElement, wire, api, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import getBookingRecord from "@salesforce/apex/getMealBookingRecord.getRecord";
import REVA_MEAL_BOOKING from '@salesforce/schema/Reva_Meal_Booking__c';
import BOOKING_STATUS from '@salesforce/schema/Reva_Meal_Booking__c.Reva_Meal_Booking_Status__c';
import IMAGES from "@salesforce/resourceUrl/revaIcons";
import getContactImage from '@salesforce/apex/getMealBookingRecord.getContactImage';
import getServerTime from "@salesforce/apex/getMealBookingRecord.getServerTime";



const fields = [BOOKING_STATUS];
export default class LwcRecordViewForm extends LightningElement {

    @api recordId;
    objectApiName = REVA_MEAL_BOOKING;
    @track timeStamp;//= new Date().getTime();
    @track urlQRCode;
    @track mealBookingStatus;

    @track bookingForName;
    @track bookingForEmail;
    @track bookingForPhone;
    @track bookingForPhoto;
    photoUrl;
    // Flag to track whether the wire service has been invoked
    wireServiceInvoked = false;

    @track countdown = 30;
    timer;

    @wire(getRecord, {
        recordId: { recordId: '$recordId', fields }//'a351e000000Gw5gAAC'
    })


    getFiles() {
        console.log('inside method' + this.recordId);

        getContactImage({ recordId: this.recordId })
            .then(result => {
                console.log('inside result' + result);
                if (result) {
                    this.photoUrl = result;

                } else {
                    console.log('ERROR ----- ');
                }
            })
            .catch(error => {
                console.error('Error fetching files:', error);
            });
    }


    getMealBookingRecord({ data, error }) {
        console.log('recordIdQR ' + this.recordId);
        console.log('fieldsQR ' + JSON.stringify(fields));
        console.log('dataQR', JSON.stringify(data));
        if (data) {
            console.log('data1111', JSON.stringify(data));
            const bookingStatus = data.fields.Reva_Meal_Booking_Status__c.value;
            this.mealBookingStatus = bookingStatus;

            this.bookingForName = data.fields.Booking_For__r.value.fields.Name.value;
            console.log(this.bookingForName);
            this.bookingForSRN = data.fields.Booking_For__r.value.fields.SRN_Number__c.value;
            console.log(this.bookingForSRN);
            this.bookingForPhone = data.fields.Booking_For__r.value.fields.Phone.value;
            console.log(this.bookingForPhone);
            this.bookingForPhoto = data.fields.Booking_For__r.value.fields.File_Passport_Size_Photo__c.value;
            console.log(this.bookingForPhoto);

            this.updateUrl(bookingStatus);
            // Set the flag to true after the wire service is invoked
            this.wireServiceInvoked = true;
        } else if (error) {
            console.error('Error loading record', error);
        }
    }

    connectedCallback() {
        this.startCountdown();
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

    handleStatusUpdate(event) {
        if (event.detail.status === 'Availed') {
            this.fetchRecord();
        }
    }

    fetchRecord() {
        getBookingRecord({ recordId: this.recordId })
            .then(result => {
                console.log(result);
                var bookingStatus = result.Reva_Meal_Booking_Status__c
                this.mealBookingStatus = result.Reva_Meal_Booking_Status__c

                this.bookingForName = result.Booking_For__r.Name;
                console.log(this.bookingForName);
                this.bookingForSRN = result.Booking_For__r.SRN_Number__c;
                console.log(this.bookingForSRN);
                this.bookingForPhone = result.Booking_For__r.Phone;
                console.log(this.bookingForPhone);
                this.updateUrl(this.mealBookingStatus);
            })
            .catch(error => {
                console.log('error', JSON.stringify(error));
            })
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
        clearInterval(this.timer);
    }

    reloadData() {

        // THIS LINE RUNS IMMEDIATELY — BEFORE the Apex call finishes!
        this.updateUrl(this.mealBookingStatus);
    }

    /***************Working one***************************/
    /*updateUrl(bookingStatus) {
        console.log('bookingStatus ',bookingStatus);
         this.urlQRCode = bookingStatus === 'Booked'
          ? `http://api.qrserver.com/v1/create-qr-code/?data=${this.recordId}-${this.timeStamp}!&size=300x300`
            : `${IMAGES}/verified.png`;

    }*/

    updateUrl(bookingStatus) {

        console.log('bookingStatus ', bookingStatus);

        // invalid statuses
        if (!['Booked', 'Pending', 'Instant Meal'].includes(bookingStatus)) {
            this.urlQRCode = `${IMAGES}/invalid_status.png`;
            return;
        }

        // Fetch SERVER time, then generate QR
        getServerTime()
            .then(result => {
                this.timeStamp = result;
                console.log('Server TimeStamp:', this.timeStamp);

                // Now generate QR code AFTER timestamp is ready
                this.urlQRCode =
                    bookingStatus === 'Booked' || bookingStatus === 'Instant Meal'
                        ? `http://api.qrserver.com/v1/create-qr-code/?data=${this.recordId}-${this.timeStamp}&size=300x300`
                        : `${IMAGES}/verified.png`;
            })
            .catch(error => {
                this.error = error;
                console.error('Error fetching server time', error);
            });
    }


    /************************************************************** */


    handleQRCodeScanned() {
        if (this.mealBookingStatus === 'Booked') {
            console.log("this.mealBookingStatus ", this.mealBookingStatus);
            updateBookingStatus({ recordId: this.recordId, newStatus: 'Missed meals' })
                .then(() => {
                    console.log(this.mealBookingStatus);
                    this.mealBookingStatus = 'Missed meals';
                    this.updateUrl(this.mealBookingStatus);

                }
                )
                .catch(error => {
                    console.error('Error updating status', error);
                });
        }
    }



    startCountdown() {
        this.timer = setInterval(() => {
            if (this.countdown > 1) {
                this.countdown--;
            } else {
                // Reset countdown to 30 to start again
                this.countdown = 30;
            }
        }, 1000); // runs every 1 second
    }

    // Optional: clear timer when component is destroyed
    // disconnectedCallback() {
    //     clearInterval(this.timer);
    // }
}