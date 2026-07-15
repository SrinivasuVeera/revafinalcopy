import { LightningElement, track } from 'lwc';
import fetchResultRecordsForCOE from '@salesforce/apex/RveDisplayPaidRVandPCResultsRecordsToCOE.fetchResultRecordsForCOE';
import uploadFile from '@salesforce/apex/RveExamPhotocopyFileUploadController.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteFile from '@salesforce/apex/RveExamPhotocopyFileUploadController.deleteFile';



export default class RveExamDisplayingRevaluationPhotocpyResultRecords extends LightningElement {
    @track resultDataList = [];
    @track showModal = false;
    @track selectedRecordId;
    @track isUploadDisabled = true;
    @track uploadedFileName = ''; 
    fileData;

    connectedCallback() {
        this.loadData();
    }

    async loadData() {
        try {
            const result = await fetchResultRecordsForCOE();
            this.resultDataList = result.map(res => ({
                ...res,
                appliedForPhotocopyText: res.appliedForPhotocopy ? 'Yes' : 'No',
                appliedForRevaluationText: res.appliedForRevaluation ? 'Yes' : 'No'
            }));
        } catch (error) {
            console.error('Error loading result data:', error);
        }
    }

    // handleUpload(event) {
    //     this.selectedRecordId = event.target.dataset.id;
    //     this.showModal = true;
    // }

    openUploadModal(event) {
        this.selectedRecordId = event.target.dataset.id;
        this.uploadedFileName = ''; // Reset previously selected file
        this.fileData = null;
        this.isUploadDisabled = true;
        this.showModal = true;
    }
    
    handleCloseModal() {
        this.showModal = false;
        this.loadData(); // Refresh after upload
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            this.uploadedFileName = file.name;
            const reader = new FileReader();
            reader.onload = () => {
                this.fileData = {
                    filename: file.name,
                    base64: reader.result.split(',')[1],
                    recordId: this.selectedRecordId
                };
                this.isUploadDisabled = false;
            };
            reader.readAsDataURL(file);
        }
    }

    handleUpload() {
        if (this.fileData) {
            this.isUploadDisabled = true;
            uploadFile({
                base64: this.fileData.base64,
                filename: this.fileData.filename,
                recordId: this.fileData.recordId
            })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: `File "${this.uploadedFileName}" uploaded successfully!`,
                    variant: 'success'
                }));
                this.handleCloseModal();
                window.location.reload();
                //this.loadData();
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'File upload failed!',
                    variant: 'error'
                }));
                this.isUploadDisabled = false;
            });
        }
    }


    handleRemoveFile(event) {
        const recordId = event.target.dataset.id;
        deleteFile({ recordId })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'File Removed',
                    message: 'Uploaded file was deleted successfully.',
                    variant: 'success'
                }));
               // this.loadData(); 
               window.location.reload();
            })
            .catch(error => {
                console.error('Error deleting file:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Could not delete file.',
                    variant: 'error'
                }));
            });
    }
}