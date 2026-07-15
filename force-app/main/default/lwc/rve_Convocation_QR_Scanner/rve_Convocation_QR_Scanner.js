import { LightningElement } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateIsPresent from '@salesforce/apex/rve_ConvocationQR_PDFController.updateIsPresent';

export default class Rve_Convocation_QR_Scanner extends LightningElement {

    // @track scannedItems = [];
    myScanner;
    error;
    jsonFormat;
 
    connectedCallback() {
        this.myScanner = getBarcodeScanner();
    }
 
    handleBarcodeClick(event) {
        if (this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [
                    this.myScanner.barcodeTypes.QR,
                    this.myScanner.barcodeTypes.UPC_E,
                    this.myScanner.barcodeTypes.EAN_13,
                    this.myScanner.barcodeTypes.CODE_39
                ],
                instructionText: 'Scan a QR Code ',
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
        try{
        let jsonFormattedBarcode = JSON.parse(barcode);
        this.updateIsPresentInApex( jsonFormattedBarcode.studentRegCollegeId);
        this.jsonFormat = JSON.stringify(jsonFormattedBarcode);
        //this.showSuccess('Success', `Scanned Barcode: ${barcode}`);
        }
        catch(error){
            this.error = error + 'Line 53';
            this.showError("Error" , error);
        }
       
    }
 
    updateIsPresentInApex(studentRegCollegeId) {
        // Call the Apex method
        updateIsPresent({ SRN_Number: studentRegCollegeId })
            .then((result) => {
                if(result === 'true'){
                    this.showSuccess('Attendance Updated Successfully');
                }
                else if(result === 'false'){
                    this.showError('Attendance Update Failed', 'Student is not in record.');
                }
                else{
                     this.showError('Attendance Update Failed', 'Student is allowed in already.');
                }
            })
            .catch((error) => {
                // Handle errors
                this.error = error + 'Line 67';
                this.showError('Attendance Update Failed', error);
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