import { LightningElement, track, wire } from "lwc";
import { getBarcodeScanner } from "lightning/mobileCapabilities";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateIsPresent from "@salesforce/apex/RPL_StudentRegisterDriveController.updateIsPresent";

export default class Rpl_QrCodeScanner extends LightningElement {
  @track scannedItems = [];
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
        instructionText: "Scan a QR, UPC, EAN 13, Code 39",
        successText: "Scanning complete."
      };

      this.myScanner
        .beginCapture(scanningOptions)
        .then((result) => {
          this.handleScannedBarcode(result.value);
        })
        .catch((error) => {
          this.error = error + "Line 34";
          this.showError("Error", error);
        })
        .finally(() => {
          this.myScanner.endCapture();
        });
    } else {
      this.showError("Error", "Scanner not supported on this device");
    }
  }

  /* handleScannedBarcode(barcode) {
    try {
      let jsonFormattedBarcode = JSON.parse(barcode);
      this.updateIsPresentInApex(
        jsonFormattedBarcode.studentRegCollegeId,
        jsonFormattedBarcode.driveNumber
      );
      //this.jsonFormat = JSON.stringify(jsonFormattedBarcode);
      //this.showSuccess('Success', `Scanned Barcode: ${barcode}`);
    } catch (error) {
      this.error = error + "Line 53";
      this.showError("Error", error);
    }
  } */

  handleScannedBarcode(barcode) {
    try {
      // Attempt to parse JSON directly
      let jsonFormattedBarcode;

      try {
        jsonFormattedBarcode = JSON.parse(barcode);
      } catch (e) {
        // If JSON parsing fails, try to extract using regex (as a fallback)
        let srnMatch = barcode.match(/"studentRegCollegeId"\s*:\s*"([^"]+)"/);
        let driveMatch = barcode.match(/"driveNumber"\s*:\s*"([^"]+)"/);

        if (srnMatch && driveMatch) {
          jsonFormattedBarcode = {
            studentRegCollegeId: srnMatch[1],
            driveNumber: driveMatch[1]
          };
        } else {
          throw new Error("Failed to parse barcode data");
        }
      }

      this.updateIsPresentInApex(
        jsonFormattedBarcode.studentRegCollegeId,
        jsonFormattedBarcode.driveNumber
      );
    } catch (error) {
      this.error = error + " Line 54";
      this.showError("Error", "Scanned content: " + barcode);
    }
  }

  updateIsPresentInApex(studentRegCollegeId, driveNumber) {
    // Call the Apex method
    updateIsPresent({ SRN_Number: studentRegCollegeId, DriveName: driveNumber })
      .then((result) => {
        if (result === "true") {
          this.showSuccess("Attendance Updated Successfully");
        } else {
          this.showError(
            "Attendance Update Failed",
            "Student Was Blocked From Attending Placement Drives."
          );
        }
      })
      .catch((error) => {
        // Handle errors
        this.error = JSON.stringify(error) + "Line 67";
        this.showError("Attendance Update Failed", error);
      });
  }

  showError(title, msg) {
    const event = new ShowToastEvent({
      title: title,
      message: msg,
      variant: "error"
    });
    this.dispatchEvent(event);
  }

  showSuccess(title, msg) {
    const event = new ShowToastEvent({
      title: title,
      message: msg,
      variant: "success"
    });
    this.dispatchEvent(event);
  }
}