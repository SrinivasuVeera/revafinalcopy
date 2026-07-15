/**
 * @description       : 
 * @author            : owais.ahanger@cloudodyssey.co
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : owais.ahanger@cloudodyssey.co
**/
import { LightningElement } from 'lwc';
import { getDocumentScanner } from "lightning/mobileCapabilities";

export default class BusinessCardReaderSF extends LightningElement {

  // Scan results (if any)
  scannerError;
  scannedDocument;
  parsedData;

  handleScanFromCameraClick() {
    this.scanDocument("DEVICE_CAMERA");
  }

  handleScanFromPhotoLibraryClick() {
    this.scanDocument("PHOTO_LIBRARY");
  }

  scanDocument(imageSource) {
    // Clear previous results / errors
    this.resetScanResults();

    // Main document scan cycle
    const myScanner = getDocumentScanner();
    if (myScanner.isAvailable()) {
      // Configure the scan
      const options = {
        imageSource: imageSource,
        scriptHint: "LATIN",
        returnImageBytes: true,
      };

      // Perform document scan
      myScanner
        .scan(options)
        .then((results) => {
          // Do something with the results
          this.processScannedDocuments(results);
        })
        .catch((error) => {
          // Handle errors
          this.scannerError =
            "Error code: " + error.code + "\nError message: " + error.message;
        });
    } else {
      // Scanner not available
      this.scannerError =
        "Problem initiating scan. Are you using a mobile device?";
    }
  }

  resetScanResults() {
    this.scannedDocument = null;
    this.scannerError = null;
  }

  processScannedDocuments(documents) {
    // DocumentScanner only processes the first scanned document in an array
    this.scannedDocument = documents[0];
    // And this is where you take over; process results as desired
     const scannedText = this.scannedDocument.text;
      // Extract data using regex
    this.parsedData = this.extractData(scannedText);
  }



/**
   * Extract data fields using regular expressions
   * @param {String} text
   * @returns {Object} Parsed data
   */
  extractData(text) {
    const data = {
      Name: '',
      Email: '',
      Phone: '',
      Company: '',
    };

    // Regex patterns
    const emailPattern = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/;
    const phonePattern = /\+?[0-9\-()\s]{7,15}/;
    const namePattern = /^[A-Z][a-z]+(?: [A-Z][a-z]+)+/; // Basic pattern for names with proper capitalization
    const companyPattern = /(Inc|LLC|Corp|Ltd|Company|Technologies)/i;

    // Match text for each field
    const lines = text.split('\n');
    lines.forEach((line) => {
      if (!data.Email && emailPattern.test(line)) {
        data.Email = line.match(emailPattern)[0];
      }
      if (!data.Phone && phonePattern.test(line)) {
        data.Phone = line.match(phonePattern)[0];
      }
      if (!data.Company && companyPattern.test(line)) {
        data.Company = line;
      }
      if (!data.Name && namePattern.test(line)) {
        data.Name = line;
      }
    });

    return data;
  }


  // Build an annotation overlay graphic, to display on top of the scanned image
  addImageHighlights(event) {
    const textBlocks = this.scannedDocument?.blocks;
    if (!textBlocks) {
      return;
    }

    const img = event.srcElement;
    const cWidth = img.clientWidth;
    const cHeight = img.clientHeight;
    const nWidth = img.naturalWidth;
    const nHeight = img.naturalHeight;
    const width = Math.min(cWidth, nWidth);
    const height = Math.min(cHeight, nHeight);

    let svg =
      `<svg version="1.1" xmlns="http://www.w3.org/2000/svg" ` +
      `xmlns:xlink="http://www.w3.org/1999/xlink" ` +
      `width="${width}" height="${height}" viewBox="0, 0, ${nWidth}, ${nHeight}">`;
    textBlocks.forEach((block) =>
      block.lines.forEach((line) =>
        line.elements.forEach((element) => {
          const frame = element.frame;
          svg +=
            `<rect x="${frame.x}" y="${frame.y}" width="${frame.width}" ` +
            `height="${frame.height}" style="fill:green;fill-opacity:0.5" />`;
        })
      )
    );
    svg += "</svg>";

    // Manually attach the overlay SVG to the LWC DOM to render it
    this.template.querySelector(".contour").innerHTML = svg;
  }
}