import { LightningElement, track, wire } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateMealStatus from '@salesforce/apex/RevaMealBookingController.updateMealStatus';
import invalidStatus from '@salesforce/apex/RevaMealBookingController.invalidStatus';
export default class RevaHostelQrCodeScanner extends LightningElement {
    @track scannedItems = [];
    myScanner;
    error;
    jsonFormat;
    updateStatusInApex;
    recordId;
    barCode;
    timestamp;
    currenTtimeStamp;
    isSpinner = false;


    connectedCallback() {
        //this.myScanner = getBarcodeScanner();

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
                    this.showError('QR Code Scan Incomplete', error);
                })
                .finally(() => {
                    this.myScanner.endCapture();

                });
        }

        else {
            this.showError('Error', 'Scanner not supported on this device');

        }


    }
    /*************************Working one************************************* */
    /* handleScannedBarcode(barcode) {
         try {
             this.barCode = barcode;
             let [recordId, timestamp] = barcode.split('-');
             this.recordId = recordId;
             this.updateMealStatus(recordId);
         } catch (error) {
             this.error = `Error: ${error.message} ${error.stack}`;
             this.showError("Error", this.error);
             console.error('Error:', this.error);
         }
     }*/

    /*************************New one with server time validation ( Devender) - 02-12-2025*******************/
    handleScannedBarcode(barcode) {
        try {
            this.barCode = barcode;
            let [recordId, timestamp] = barcode.split('-');
            let qrTimestamp = Number(timestamp);

            if (isNaN(qrTimestamp)) {
                this.showError('Invalid QR Code Timestamp');
                return;
            }

            if (recordId !== undefined && timestamp !== undefined) {
                this.recordId = recordId;
                this.updateMealStatus(recordId, timestamp);
            } else {
                this.showError('Invalid QR !!');

                this.recordId = recordId;
               // this.invalidStatus(recordId);
            }


        } catch (error) {
            this.error = `Error: ${error.message}`;
            this.showError('Invalid Barcode', error.message);
            console.error('Error:', this.error);
        }
    }

    /********************************************************************************/

    updateMealStatus(recordId, timestamp) {
        this.isSpinner = true;
        updateMealStatus({ recordId: recordId, status: "Availed", qrTimestamp: timestamp })
            .then((result) => {
                if (result.startsWith('Success:')) {
                    this.showSuccess('Success', 'Your QR Code scanned successfully.', 'success');
                } else if (result.startsWith('Error:')) {

                  //  this.invalidStatus(recordId);
                    const message = result.replace('Error: ', '');
                    this.showError('Error', message, 'error');
                } else {
                   // this.invalidStatus(recordId);
                    this.showError('Unexpected', result, 'warning');
                }
                setTimeout(() => {
                    this.isSpinner = false;
                    // return refreshApex(this.wiredData); // Ensure refresh is awaited
                }, 300);
            })
            .catch((error) => {
               // this.invalidStatus(recordId);
                this.isSpinner = false;
                const message = error?.body?.message || error.message || 'Unexpected error';
                this.showError('Error', message, 'error');
            });
    }
    /*********************** End Devender ** 02-12-2025*****************************************************/

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


    invalidStatus(recordId) {
        invalidStatus({ recordId: recordId, status: "Invalid" })
            .then((result) => {
                // this.showSuccess('Success', 'Your QR Code Scanned Successfully.');
                console.log('Invalid');
            })
            .catch((error) => {

            });
    }
}