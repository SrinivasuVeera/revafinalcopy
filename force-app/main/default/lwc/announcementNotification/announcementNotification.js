import { LightningElement, track } from 'lwc';
import getBlockPicklistValues from '@salesforce/apex/HostelNotification.getBlockPicklistValues';
import createAndSendAnnouncement from '@salesforce/apex/HostelNotification.createAndSendAnnouncement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AnnouncementNotification extends LightningElement {
    @track showModal = false;
    @track blockOptions = [];
    @track selectedBlocks = [];
    @track messageBody = '';
    @track studentName = 'John Doe';
    @track startDateTime;
    @track endDateTime;
    @track fileUploaded = false;
    @track announcementTitle = '';

    @track isAllChecked = false;
    @track isBoysChecked = false;
    @track isGirlsChecked = false;

    uploadedFileId;

    // Block groups
    boysBlocks = ['A', 'B', 'C', 'D','RBS Boys'];
    girlsBlocks = ['G1', 'G2', 'G3', 'RBS'];

    connectedCallback() {
        this.loadBlockOptions();
    }

    loadBlockOptions() {
        getBlockPicklistValues()
            .then(result => {
                this.blockOptions = result.map(value => ({
                    label: value,
                    value: value
                }));
            })
            .catch(error => {
                this.showToast('Error loading blocks', error.body.message, 'error');
            });
    }

    handleOpenModal() {
        this.showModal = true;
    }

    handleCloseModal() {
        this.showModal = false;
        this.messageBody = '';
        this.selectedBlocks = [];
        this.uploadedFileId = null;
        this.fileUploaded = false;
        this.announcementTitle = '';
        this.isAllChecked = false;
        this.isBoysChecked = false;
        this.isGirlsChecked = false;
    }

    handleStartDateTimeChange(event) {
        this.startDateTime = event.target.value;
    }

    handleEndDateTimeChange(event) {
        this.endDateTime = event.target.value;
    }

    handleBlockChange(event) {
        this.selectedBlocks = event.detail.value;
    }

    handleBodyChange(event) {
        this.messageBody = event.detail.value;
    }

    handleTitleChange(event) {
        this.announcementTitle = event.detail.value;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            this.uploadedFileId = uploadedFiles[0].documentId;
            this.fileUploaded = true;
        }
    }

    handleSingleCheckboxChange(event) {
        const value = event.target.value;
        const checked = event.target.checked;

        // Reset all initially
        if (value === 'All') {
            this.isAllChecked = checked;
            this.isBoysChecked = checked;
            this.isGirlsChecked = checked;
        } else if (value === 'Boys') {
            this.isBoysChecked = checked;
            this.isAllChecked = this.isGirlsChecked && checked;
        } else if (value === 'Girls') {
            this.isGirlsChecked = checked;
            this.isAllChecked = this.isBoysChecked && checked;
        }

        // Compute final selected list
        let selected = new Set();

        if (this.isBoysChecked) {
            this.boysBlocks.forEach(b => selected.add(b));
        }
        if (this.isGirlsChecked) {
            this.girlsBlocks.forEach(g => selected.add(g));
        }

        // Add any manually selected earlier blocks that were not in boys/girls
        this.selectedBlocks.forEach(existing => {
            if (!this.boysBlocks.includes(existing) && !this.girlsBlocks.includes(existing)) {
                selected.add(existing);
            }
        });

        this.selectedBlocks = Array.from(selected);
    }

    handleSendNotification() {
        if (!this.messageBody.trim() || !this.selectedBlocks.length) {
            this.showToast('Validation Error', 'Please provide a message and select at least one block.', 'warning');
            return;
        }

        if (!this.startDateTime || !this.endDateTime) {
            this.showToast('Validation Error', 'Please provide both start and end date/time.', 'warning');
            return;
        }

        createAndSendAnnouncement({
            studentName: this.announcementTitle,
            messageBody: this.messageBody,
            selectedBlocks: this.selectedBlocks,
            uploadedFileId: this.uploadedFileId,
            startDateTime: this.startDateTime,
            endDateTime: this.endDateTime,
            announcementTitle: this.announcementTitle
        })
        .then(() => {
            this.showToast('Success', 'Announcement sent successfully!', 'success');
            this.handleCloseModal();
        })
        .catch(error => {
            console.error('Send error:', error);
            this.showToast('Error', error.body.message || 'Something went wrong.', 'error');
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}