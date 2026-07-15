import { LightningElement, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getRelatedFilesByRecordId from "@salesforce/apex/filePreviewAndDownloadController.getRelatedFilesByRecordId";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";

export default class RevaHostelLeaveRequestAttachments extends LightningElement {
    filesList = [];
    wiredData;
    @api recordId;

    @wire(getRelatedFilesByRecordId, { recordId: "$recordId" })
    wiredResult(result) {
        this.wiredData = result;
        if (result.data) {
            console.log(result.data);
            this.filesList = Object.keys(result.data).map((item) => ({
                value: result.data[item],
                label: item,
                url: `/sfc/servlet.shepherd/document/download/${item}`
            }));
            console.log(this.filesList);
        }
        if (result.error) {
            console.log(result.error);
        }
    }

    handleUploadFinished() {
        this.showToast("File uploaded successfully", "", "success");
        refreshApex(this.wiredData);
    }

    /*previewHandler(event) {
        console.log(event.target.dataset.id);
    // Create a Blob from the byte array
    const blob = event.target.dataset.id;

    // Create an object URL from the Blob
    const blobUrl = URL.createObjectURL(blob);

    // Open the PDF in a new window
    const newWindow = window.open();
    newWindow.document.write(
        `<iframe src="${blobUrl}" width="100%" height="100%" style="border:none;"></iframe>`
    );
        /* const img = new Image();
            img.src = 'data:image/png;base64,' + event.target.dataset.id; // Assuming the attachment is a PNG image
            const newWindow = window.open();
            newWindow.document.body.appendChild(img); */
        /* this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                name: "filePreview"
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        }); 
    } */
    /*previewHandler(event) {
        console.log(event.target.dataset.id);
        const byteCharacters = atob(event.target.dataset.id);
    const byteNumbers = new Array(byteCharacters.length);

    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }

    const byteArray = new Uint8Array(byteNumbers);
    const blob = new Blob([byteArray], { type: 'application/pdf' }); 
    const fileURL = URL.createObjectURL(blob);
    window.open(fileURL, '_blank');  
    }*/
    previewHandler(event) {
 
    const base64String = event.target.dataset.id;


    const byteCharacters = atob(base64String);
    const byteNumbers = new Array(byteCharacters.length);
    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    const byteArray = new Uint8Array(byteNumbers);
    
   
    let blob;
    if (base64String.startsWith("/9j/") || base64String.startsWith("iVBORw0KGgo=")) { 
        blob = new Blob([byteArray], { type: 'image/jpeg' });
        const fileUrl = URL.createObjectURL(blob);

        window.open(fileUrl, '_blank');
    } else if (base64String.startsWith("JVBERi0xL")) { 
        blob = new Blob([byteArray], { type: 'application/pdf' });
        const fileUrl = URL.createObjectURL(blob);

        window.open(fileUrl, '_blank');
    } else {
     /*   console.error("Unsupported file type");
        return;*/

        blob = new Blob([byteArray], { type: 'image/jpeg' }); 
        const imageUrl = URL.createObjectURL(blob);
        window.open(imageUrl, '_blank');
    
    }
   

}

    handleUploadFile() {
        console.log("File Upload Clikced");
        const fileUpload = this.refs.fileUpload;
        /*  const inputFile = fileUpload.shadowRoot.querySelector('lightning-input[type="file"]'); */
        console.log("File tag " + fileUpload);
        const inputTag = fileUpload.querySelector("input");
        console.log("Input tag " + inputTag);
        fileUpload.click();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}