import { LightningElement, track, wire,api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import createRevaHostelSupportCase from '@salesforce/apex/CaseController.createRevaHostelSupportCase';
import getRevaHostelSupportCasesForUser from '@salesforce/apex/CaseController.getRevaHostelSupportCasesForUser';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SUPPORT_CATEGORY_FIELD from '@salesforce/schema/Case.Hostel_Category__c';
import HOSTEL_SUB_CATEGORY_FIELD from '@salesforce/schema/Case.Hostel_Sub_Category__c';
import SUPPORT_CASE_COMPLAINT_FIELD from '@salesforce/schema/Case.Support_Case_Complaints__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import  getCurrentUserId  from '@salesforce/apex/CaseController.getCurrentUserId';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/CaseController.uploadFile';
import getCases from '@salesforce/apex/CaseListViewController.getHostelCases';
import getCaseAttachments from '@salesforce/apex/CaseController.getCaseAttachments';
import getAttachmentContent from '@salesforce/apex/CaseController.getAttachmentContent';
import updateCase from '@salesforce/apex/CaseController.updateCase';

import getSupportCaseComplaintsBySubCategory from '@salesforce/apex/CaseController.getSupportCaseComplaintsBySubCategory';

import USER_ID from '@salesforce/user/Id';
//import { refreshApex } from '@salesforce/apex';
export default class RevaHostelSupportRequestCaseCreation extends NavigationMixin(LightningElement) {
    @track description;
    @track priority;
    @track supportCategory;
    @track hostelSubCategory;
    @track status = 'New'; // Default value for status
    @track hostelBlock;
    @track cases = [];
    @track showNewCaseForm = false; // Track whether to display the new case form
    @track supportCategoryOptions = [];
    @track hostelSubCategoryOptions = [];
    hostelSubCategoryField;
    @track supportCaseComplaintField;
    currentUserId;
    @track uploadedFileName;
    fileData;
    @track fileName;
    @track fileUploaded = false;
    recordTypeName = 'REVA Hostel Support Request';
    @track selectedCaseRecord = {};
    @track showCaseDetailModal = false;
    @track selectedCaseDetails;
    @track selectedCaseAttachmentsVar;
    @api selectedCaseAttachments;
    @track saving = false;
    //Newly added for new categories;
   // @track generalComplaints;
   @track generalComplaints = [];
    @track supportCaseComplaints = [];
     @track subCategory = '';
     @track error;
    @track updatedStatus;
    @track updateRemarks;
    @track updatedhostelBlock;
    @track updatedSupportCategory;
    @track updatesHostelSubCategory;
    @track updatedPriority;
    @track updatedDescription;
    @track openedCaseId;
    // Priority options for dropdown
    priorityOptions = [
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' }
    ];
    

    get recordId() {
        return this.selectedCaseRecord.Id ?? '-';
    }


/********addinig new one***** */

@wire(getCases, { contactId: '$contactId', recordTypeName: '$recordTypeName', userId: USER_ID, wireKey: '$wireKey' })
wiredCases(result) {
    this.wiredCase = result;

    if (result.data) {
        console.log('resultnew:;;;;' + JSON.stringify(result.data));
        this.cases = result.data.map(eachCase => {
            // Convert DateTime to Date object
            const createdDate = eachCase.CreatedDate ? new Date(eachCase.CreatedDate) : null;
            console.log('createdDate:', createdDate);

            // Extract year, month, and day components
            const year = createdDate ? createdDate.getFullYear() : null;
            console.log('year:', year);
            
            const month = createdDate ? createdDate.getMonth() + 1 : null; // Note: Month is zero-based
            console.log('month:', month);

            const day = createdDate ? createdDate.getDate() : null;
            console.log('day:', day);

            // Construct date string in the format 'dd-mm-yyyy'
            const formattedDate = createdDate ? `${day}-${month}-${year}` : null;
            console.log('formattedDate:', formattedDate);

            return {
                ...eachCase,
                CreatedDate: formattedDate,
            }
        });
    } else if (result.error) {
        this.isSpinner = false;
        console.error('Error when fetching cases ' + error);
    }
}




     @wire(CurrentPageReference)
     pageRef;
    // Wire methods to get picklist values
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseInfo;

    @wire(getPicklistValues, { recordTypeId: '$caseInfo.data.defaultRecordTypeId', fieldApiName: SUPPORT_CATEGORY_FIELD })
    supportCategoryFieldInfo({ data, error }) {
        if (data) this.supportCategoryOptions = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: '$caseInfo.data.defaultRecordTypeId', fieldApiName:        
      HOSTEL_SUB_CATEGORY_FIELD })
    hostelSubCategoryFieldInfo({ data, error }) {
        if (data) this.hostelSubCategoryField = data;
    }

    @wire(getPicklistValues, { recordTypeId: '$caseInfo.data.defaultRecordTypeId', fieldApiName: SUPPORT_CASE_COMPLAINT_FIELD })
supportCaseComplaintsInfo({ data, error }) {
    if (data) {
        this.supportCaseComplaintField = data;
        this.supportCaseComplaints = data.values; // Set the options for the combobox
        console.log('supportCaseComplaints:', JSON.stringify(this.supportCaseComplaints));
    } else if (error) {
        console.error('Error fetching support case complaints:', error);
    }
}


    // Wire method to get the current user's Id
     @wire(getCurrentUserId)
    wiredUser({ data, error }) {
        if (data) {
            this.currentUserId = data; // Assuming getCurrentUserId returns the user Id directly
            this.loadCases(); // Call loadCases after getting the user Id
        } else if (error) {
            console.error('Error retrieving user Id:', error);
        }
    }

    // Event handler for input change on description field
    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    // Event handler for input change on priority field
    handlePriorityChange(event) {
        this.priority = event.detail.value;
    }

    // Event handler for input change on support category field
    handleSupportCategoryChange(event) {
        let key = this.hostelSubCategoryField.controllerValues[event.target.value];
        this.hostelSubCategoryOptions = this.hostelSubCategoryField.values.filter(category => category.validFor.includes(key));
        this.supportCategory = event.detail.value;
    }

    // Event handler for input change on hostel sub category field
    /******************Working one****************************** */
    /*handleHostelSubCategoryChange(event) {
        this.hostelSubCategory = event.detail.value;
        console.log('hostelSubCategory'+ this.hostelSubCategory);
    }*/
    handleHostelSubCategoryChange(event) {
        this.hostelSubCategory = event.detail.value;
        console.log('hostelSubCategory: ' + this.hostelSubCategory);

        // Call the Apex method to get support case complaints based on the selected subcategory
        this.fetchSupportCaseComplaints();
    }

    // Method to fetch support case complaints from Apex
    /*fetchSupportCaseComplaints() {
        getSupportCaseComplaintsBySubCategory({ subCategory: this.hostelSubCategory })
            .then(result => {
                console.log('result-->'+JSON.stringify(result));
                // Map result to desired format for the dual-listbox
                this.supportCaseComplaints = result.map(record => ({
                    label: record.General_Complaints__c,
                    value: record.General_Complaints__c
                }));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.supportCaseComplaints = [];
                console.error('Error fetching support case complaints: ', error);
            });
    }*/
   fetchSupportCaseComplaints() {
    getSupportCaseComplaintsBySubCategory({ subCategory: this.hostelSubCategory })
        .then(result => {
            console.log('result --> ' + JSON.stringify(result));

            // Assuming result is an array of objects and each object has the General_Complaints__c field
            if (result && result.length > 0) {
                // Split the General_Complaints__c field from the first record into an array
                const complaintsString = result[0].General_Complaints__c || '';
                const complaintsArray = complaintsString.split(',').map(item => item.trim());

                // Map the array to the desired format for the dual-listbox
                this.supportCaseComplaints = complaintsArray.map(complaint => ({
                    label: complaint,
                    value: complaint
                }));
            } else {
                // Handle case when no results are returned
                this.supportCaseComplaints = [];
            }
            
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.supportCaseComplaints = [];
            console.error('Error fetching support case complaints: ', error);
        });
}

    /*********************************************** */

    handleHostelGeneralComplaintChange(event) {
    this.generalComplaints = event.detail.value;
    console.log('Selected General Complaints:', this.generalComplaints);
}

    // Event handler for creating a new case
    handleCreateCase() {
        
        createRevaHostelSupportCase({ 
            description: this.description, 
            priority: this.priority, 
            supportCategory: this.supportCategory,
            hostelSubCategory: this.hostelSubCategory,
            generalComplaints: this.generalComplaints.join(';')
            //generalComplaints: this.generalComplaints
        })
        .then(result => {
            
            console.log('New Case Id:2 ' + result);
           
        })
        .catch(error => {
            
            console.error('Error creating case: ' + JSON.stringify(error));
        });
    }

    // Event handler for showing the new case form
    handleShowNewCaseForm() {
        this.showNewCaseForm = true;
    }

    // Method to load cases for the current user
    loadCases() {
        if (this.currentUserId) {
            console.log('user Id-->',this.currentUserId);
            getRevaHostelSupportCasesForUser({ userId: this.currentUserId })
                .then(result => {
                    console.log('entered 171');
                    console.log('result-->',result);
                    this.cases = result;
                     //this.selectedCaseAttachments = result.caseattachments;
                    console.log('result cases172'+JSON.stringify(result));
                })
                .catch(error => {
                    console.error('Error fetching cases: ' + JSON.stringify(error));
                });
        }
    }
    


    
    openfileUpload(event) {
        const file = event.target.files[0];
        var reader = new FileReader();
        reader.onload = () => {
            var base64 = reader.result.split(',')[1];
            this.fileData = {
                'filename': file.name,
                'base64': base64
            };
            console.log(this.fileData);
        };
        reader.readAsDataURL(file);
    }

    
     /* handleClick() {
        const { base64, filename } = this.fileData;
        uploadFile({ base64, filename })
            .then(result => {
                this.fileData = null;
                let title = `${filename} uploaded successfully!!`;
                this.toast(title);
            })
            .catch(error => {
                console.error('Error uploading file: ' + JSON.stringify(error));
            });
    }*/
     // Handle click event for uploading file
     handleClick() {
       if (this.fileData) {
           const { base64, filename } = this.fileData;
          uploadFile({ base64, filename })
            .then(() => {
                this.fileData = null;
                this.toast(`${filename} uploaded successfully!`);
            })
            .catch(error => {
                console.error('Upload error: ', JSON.stringify(error));
            });
        } else {
         this.toast('No file uploaded, proceeding...');
         
        }
      }

    // Method to display toast message
    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }

   handleFileChange(event) {
    if (event.target.files.length > 0) {
        const file = event.target.files[0];
        this.fileData = {
            name: file.name,
            base64: null // Reset base64 data
        };
        this.fileName = file.name; // Set the filename property
        this.fileUploaded = true;
        const reader = new FileReader();
        reader.onload = () => {
            this.fileData.base64 = reader.result.split(',')[1];
        };
        reader.readAsDataURL(file);
    }
}


    handleSave() {
    if (!this.description ||!this.priority ||!this.supportCategory ||!this.hostelSubCategory) {
        //this.showToast('Please fill in all required fields.', 'error');
       this.showToast('Error', 'Please fill in all required fields.', 'error'); //added by veera on 11-02-2025

        return;
    }
     /*if (!this.fileData) {
        // Show an error message or alert
        this.showToast('Error', 'Please upload a document before submitting.', 'error');
        return;
        }*/
    this.saving = true; // Start saving operation

    let filename = '';
    let base64 = '';
   
    if (this.fileData) {
        filename = this.fileData.name;
        base64 = this.fileData.base64;
    }

    createRevaHostelSupportCase({
        description: this.description,
        priority: this.priority,
        supportCategory: this.supportCategory,
        hostelSubCategory: this.hostelSubCategory,
        generalComplaints: this.generalComplaints,

        filename: filename,
        base64: base64
    })
   .then(result => {
        if (result) {
            this.showToast('Success', 'Case created successfully.', 'success');
            console.log('result::::'+result);
            this.description = '';
            this.priority = '';
            this.supportCategory = '';
            this.hostelSubCategory = '';
            
            this.fileData = null;
            this.showNewCaseForm = false;
            
            location.reload();
           // this.loadCases();
            //this.navigateToRecordPage(result); // assuming result is the Case Id
        } else {
            this.showToast('Failed to create case.', 'error');
        }
        this.saving = false;
    })
   .catch(error => {
        this.showToast( 'An error occurred while creating the case.', 'error');
        console.error('Error occurred while creating case:', error);
    })
}
    
    handleCancel() {
        
        this.fileUploaded = false;
        console.log('File Uploaded:', this.fileUploaded);
        this.file = null;
        this.fileName = null;
        
    }

    handleClose() {
    this.showNewCaseForm = false;
    this.showCaseDetailModal = false;

}
   
    showToast(title, message, variant) {
    const toastEvent = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(toastEvent);
}

    fetchCaseAttachments(caseId) {
        console.log('result324-->',caseId);
        getCaseAttachments({ caseId: caseId })
            .then(result => {
                this.selectedCaseAttachments = result;
                this.selectedCaseAttachmentsVar=false;
                console.log('result325-->',result);
            })
            .catch(error => {
                console.error('Error fetching case attachments: ' + JSON.stringify(error));
            });
    }



    showCaseDetail(event) {
    console.log('Event:', event);
    const caseId = event.currentTarget.dataset.id;
    this.openedCaseId = event.currentTarget.dataset.id;
    console.log('caseId:', caseId); 
    console.log('this.cases:', this.cases); 
    this.selectedCaseRecord = this.cases.find(caseRec => caseRec.Id === caseId);
    console.log('this.selectedCaseRecord:', this.selectedCaseRecord); 
    this.showCaseDetailModal = true;
    this.fetchCaseAttachments(caseId);
}



    handleCloseCaseDetail() {
        this.showCaseDetailModal = false;
        this.selectedCaseDetails = null;
        this.selectedCaseAttachments = null;
    }
    isSelectedCaseAttachment() {
        return this.selectedCaseAttachments && this.selectedCaseAttachments.length > 0;
    }

    hasSelectedCaseAttachments() {
        return !this.isSelectedCaseAttachment();
    }
    
    /****************************workig one********************************************************* */
    /*handleAttachmentClick(event) {
    const attachmentId = event.currentTarget.dataset.attachmentId;
    console.log('Attachment ID:', attachmentId); // Log the attachment ID
    // Call Apex method to fetch attachment content
    getAttachmentContent({ attachmentId: attachmentId })
        .then(result => {
            const img = new Image();
            img.src = 'data:image/png;base64,' + result; // Assuming the attachment is a PNG image
            const newWindow = window.open();
            newWindow.document.body.appendChild(img);
        })
        .catch(error => {
            console.error('Error fetching attachment content:', error);
        });
}*/

    /*handleAttachmentClick(event) {
    const attachmentId = event.currentTarget.dataset.attachmentId;
    console.log('Attachment ID:', attachmentId);
    
    // Call Apex method to fetch attachment content
    getAttachmentContent({ attachmentId: attachmentId })
        .then(result => {
            const fileType = this.getFileType(result);
            
            if (fileType.startsWith('image/')) {
                // Display image
                const img = new Image();
                img.src = 'data:' + fileType + ';base64,' + result;
                const newWindow = window.open('', '_blank');
                newWindow.document.write('<html><body></body></html>');
                newWindow.document.body.appendChild(img);
                newWindow.document.close();
            } else if (fileType === 'application/pdf') {
                // Display PDF
                const base64Pdf = 'data:application/pdf;base64,' + result;
                const newWindow = window.open('', '_blank');
                newWindow.document.write('<html><body><embed src="' + base64Pdf + '" type="application/pdf" width="100%" height="100%"></embed></body></html>');
                newWindow.document.close();
            } else {
                console.error('Unsupported file type');
            }
        })
        .catch(error => {
            console.error('Error fetching attachment content:', error);
        });
}

// Method to determine file type based on content or file extension
getFileType(base64Content) {
    if (base64Content.startsWith('iVBORw0KGgo')) {
        return 'image/png';
    } else if (base64Content.startsWith('/9j/')) {
        return 'image/jpeg';
    } else if (base64Content.startsWith('R0lGODdh')) {
        return 'image/gif';
    } else if (base64Content.startsWith('Qk02')) {
        return 'image/bmp';
    } else if (base64Content.startsWith('JVBERi0')) {
        return 'application/pdf';
    }
    return 'unknown';
}*/




    /*handleAttachmentClick(event) {
    const attachmentId = event.currentTarget.dataset.attachmentId;
    console.log('Attachment ID:', attachmentId); // Log the attachment ID
    
    // Call Apex method to fetch attachment content
    getAttachmentContent({ attachmentId: attachmentId })
        .then(result => {
            const fileType = this.getFileType(result); // Determine file type
            
            if (fileType.startsWith('image/')) {
                // Display image
                const img = new Image();
                img.src = 'data:' + fileType + ';base64,' + result;
                const newWindow = window.open('', '_blank'); // Open a new window
                newWindow.document.write('<html><body></body></html>'); // Write basic HTML structure
                newWindow.document.body.appendChild(img);
                newWindow.document.close(); // Close the document for rendering
            } else if (fileType === 'application/pdf') {
                // Display PDF
                const base64Pdf = 'data:application/pdf;base64,' + result;
                const newWindow = window.open('', '_blank'); // Open a new window
                newWindow.document.write('<html><body><iframe src="' + base64Pdf + '" style="width:100%; height:100%;"></iframe></body></html>'); // Embed PDF in iframe
                newWindow.document.close(); // Close the document for rendering
            } else {
                console.error('Unsupported file type');
            }
        })
        .catch(error => {
            console.error('Error fetching attachment content:', error);
        });
}

// Method to determine file type based on content or file extension
getFileType(base64Content) {
    // File type detection based on base64 content (simplified)
    if (base64Content.startsWith('iVBORw0KGgo')) {
        return 'image/png'; // Base64 header for PNG images
    } else if (base64Content.startsWith('/9j/')) {
        return 'image/jpeg'; // Base64 header for JPG images
    } else if (base64Content.startsWith('R0lGODdh')) {
        return 'image/gif'; // Base64 header for GIF images
    } else if (base64Content.startsWith('Qk02')) {
        return 'image/bmp'; // Base64 header for BMP images
    } else if (base64Content.startsWith('JVBERi0')) {
        return 'application/pdf'; // Base64 header for PDF files
    }
    return 'unknown';
}*/

handleAttachmentClick(event) {
    const attachmentId = event.currentTarget.dataset.attachmentId;
    console.log('Attachment ID:', attachmentId); // Log the attachment ID
    
    // Call Apex method to fetch attachment content
    getAttachmentContent({ attachmentId: attachmentId })
        .then(result => {
            this.previewHandler(result); // Use the previewHandler method to handle the file
        })
        .catch(error => {
            console.error('Error fetching attachment content:', error);
        });
}

// Preview Handler for displaying file content
/*previewHandler(base64String) {
    const byteCharacters = atob(base64String);
    const byteNumbers = new Array(byteCharacters.length);
    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    const byteArray = new Uint8Array(byteNumbers);

    let blob;
    let mimeType = 'application/octet-stream'; // Default MIME type

    // Determine MIME type based on base64 content
    if (base64String.startsWith("/9j/")) { 
        mimeType = 'image/jpeg';
    } else if (base64String.startsWith("iVBORw0KGgo=")) { 
        mimeType = 'image/png';
    } else if (base64String.startsWith("R0lGODdh")) { 
        mimeType = 'image/gif';
    } else if (base64String.startsWith("Qk02")) { 
        mimeType = 'image/bmp';
    } else if (base64String.startsWith("JVBERi0xL")) { 
        mimeType = 'application/pdf';
    } else {
        console.error("Unsupported file type");
        return;
    }

    blob = new Blob([byteArray], { type: mimeType });
    const fileUrl = URL.createObjectURL(blob);

    // Open the file in a new window/tab
    window.open(fileUrl, '_blank');
}*/

    previewHandler(base64String) {
    try {
        // Split the base64 string if it contains the MIME type information
        if (base64String.includes(',')) {
            base64String = base64String.split(',')[1];
        }

        const byteCharacters = atob(base64String);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);

        let mimeType = this.getMimeType(base64String);

        if (!mimeType) {
            console.error("Unsupported file type");
            return;
        }

        const blob = new Blob([byteArray], { type: mimeType });
        const fileUrl = URL.createObjectURL(blob);

        // Open the file in a new window/tab
        window.open(fileUrl, '_blank');
    } catch (error) {
        console.error('Error processing the base64 string:', error);
    }
}

// Method to determine MIME type from base64 string
getMimeType(base64String) {
    if (base64String.startsWith("/9j/")) { 
        return 'image/jpeg';
    } else if (base64String.startsWith("iVBORw0KGgo")) { 
        return 'image/png';
    } else if (base64String.startsWith("R0lGODdh")) { 
        return 'image/gif';
    } else if (base64String.startsWith("Qk02")) { 
        return 'image/bmp';
    } else if (base64String.startsWith("JVBERi0xL")) { 
        return 'application/pdf';
    } else if (base64String.startsWith("UEsDBBQAB")) { 
        return 'application/zip';
    } else {
        return null;
    }
}
  
/*******************************************************************/
handleUpdateCase(event) {
    
      
       //event.preventDefault(); 
                updateCase({ openedCaseId: this.openedCaseId, hostelBlock: this.updatedHostelBlock, status: this.updatedStatus, priority: this.updatedPriority, hostelCategory: this.updatedSupportCategory, subCategory: this.updatedHostelSubCategory, description: this.updatedDescription, remarks: this.updateRemarks})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case updated successfully',
                        variant: 'success',
                    })
                );
                this.showCaseDetailModal = false;
                location.reload();
                // Refresh the case list after update
                //return refreshApex(this.wiredCase);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                    //    title: 'Error',
                        message: 'Failed to update case',
                        variant: 'error',
                    })
                );
                console.error('Error updating case:', error);   
            });
           
            console.log('After update:', JSON.stringify(this.selectedCaseRecord));
    }



}