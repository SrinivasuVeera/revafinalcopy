import { LightningElement,track,api } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateCheckStatus from '@salesforce/apex/RevaHostelLeaveRequestController.updateCheckStatus';
export default class RevaHostelLeaveQRCodeScenner extends LightningElement {
  
    myScanner;
    error;
    jsonFormat;
    updateStatusInApex;
    recordId;
    barCode;
    timestamp;
    currenTtimeStamp;


    connectedCallback() {
       // this.myScanner = getBarcodeScanner();
    }

    handleBarcodeClick(event) {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [
                    this.myScanner.barcodeTypes.QR,
                    this.myScanner.barcodeTypes.UPC_E,
                    this.myScanner.barcodeTypes.EAN_13,
                    this.myScanner.barcodeTypes.CODE_39
                ],
                instructionText: 'Scan a QR', //UPC, EAN 13, Code 39',
                successText: 'Scanning complete.'
                
            };
            

            this.myScanner.beginCapture(scanningOptions)
                .then((result) => {
                    this.handleScannedBarcode(result.value);
          
                })
                .catch((error) => {
                    this.error = error + 'Line 34';
                    this.showError('Error', error);
                })
                .finally(() => {
                    this.myScanner.endCapture();
                });
        } else {
           this.showError('Error', 'Scanner not supported on this device');
           
        }
    }

    handleScannedBarcode(barcode) {
        try {
            this.barCode = barcode;
            let [recordId, timestamp] = barcode.split('-');
            this.currenTtimeStamp = new Date().getTime();


                   // Calculate the difference in seconds
        const differenceInMilliseconds = this.currenTtimeStamp - timestamp;
       
        // Check if the difference is within 0 to 30 seconds
        if (differenceInMilliseconds >= 0 && differenceInMilliseconds <= 30000) {
            console.log('Allowed: The time difference is within the allowed range (0-30 seconds).');
             
            this.recordId = recordId;
            this.updateCheckStatus(recordId);
        } else {
            this.showError('Invalid QR code /QR code expired!!');
            console.log('Error: Time difference is outside the allowed range.');
            //window.location.reload();
           
        } 



        // Validate recordId format
        if (!recordId || recordId.length !== 18 ) {
            throw new Error('Invalid QR code /QR code expired!!');
        }

        } catch (error) {
            this.error = `Error: ${error.message}`;
            this.showError('Invalid Barcode', error.message);
            console.error('Error:', this.error);
        }
    }

    updateCheckStatus(recordId) {
        updateCheckStatus({ recordId: recordId , status: true})
            .then((result) => {
                this.showSuccess('Success', 'Updated Successfully.');
             
            })
            .catch((error) => {
                this.error = JSON.stringify(error.body.message);
                this.showError('Update Failed', error.body.message);
            });
    }
   

    showError(title, msg) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    showSuccess(title, msg) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'success'
        });
        this.dispatchEvent(event);
    } 
}