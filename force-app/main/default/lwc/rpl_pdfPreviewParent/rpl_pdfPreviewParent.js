import { LightningElement, api, track, wire } from 'lwc';
import updateStudentRegDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.updateStudentRegDetails';
import getRelatedFilesByRecordId from '@salesforce/apex/RPL_PDFViewerController.getRelatedFilesByRecordId';
import {NavigationMixin} from 'lightning/navigation';
import fetchStudentRegDetails from '@salesforce/apex/RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

export default class Rpl_pdfPreviewParent extends  NavigationMixin(LightningElement)  {
    // Current record ID. *recordId* is a reserved identifier
    @api recordId;
    studentRegistration;
    fieldMapping = {}
    studentGeneralDetails ={}
    filesList =[];
    wiredResult;
    @wire(fetchStudentRegDetails, { recordId: '$recordId' })
    wiredFetchStudentRegDetails(result) {
        this.wiredResult = result
        if (result.data) {
            this.studentRegistration = { ...result.data[0] };
            this.fieldMapping = {
                "Tenth Marksheet": this.studentRegistration.Rpl_10th_Percentage__c ? this.studentRegistration.Rpl_10th_Percentage__c : this.studentRegistration.Rpl_Tenth_CGPA__c ? this.studentRegistration.Rpl_Tenth_CGPA__c : 0,
                "Twelveth Marksheet": this.studentRegistration.Rpl_12th_Percentage__c ? this.studentRegistration.Rpl_12th_Percentage__c : this.studentRegistration.Rpl_Twelfth_CGPA__c ? this.studentRegistration.Rpl_Twelfth_CGPA__c : 0,
                "Diploma Marksheet": this.studentRegistration.Rpl_Diploma_Percentage__c || 0,
                "Resume" : '-',
                "UG Semester 1 Marksheet": this.studentRegistration.Rpl_Sem_1_CGPA__c ? this.studentRegistration.Rpl_Sem_1_CGPA__c : 0,
                "UG Semester 2 Marksheet": this.studentRegistration.Rpl_Sem_2_CGPA__c ? this.studentRegistration.Rpl_Sem_2_CGPA__c : 0,
                "UG Semester 3 Marksheet": this.studentRegistration.Rpl_Sem_3_CGPA__c ? this.studentRegistration.Rpl_Sem_3_CGPA__c : 0,
                "UG Semester 4 Marksheet": this.studentRegistration.Rpl_Sem_4_CGPA__c ? this.studentRegistration.Rpl_Sem_4_CGPA__c : 0,
                "UG Semester 5 Marksheet": this.studentRegistration.Rpl_Sem_5_CGPA__c ? this.studentRegistration.Rpl_Sem_5_CGPA__c : 0,
                "UG Semester 6 Marksheet": this.studentRegistration.Rpl_Sem_6_CGPA__c ? this.studentRegistration.Rpl_Sem_6_CGPA__c : 0,
                "UG Semester 7 Marksheet": this.studentRegistration.Rpl_Sem_7_CGPA__c ? this.studentRegistration.Rpl_Sem_7_CGPA__c : 0,
                "UG Semester 8 Marksheet": this.studentRegistration.Rpl_Sem_8_CGPA__c ? this.studentRegistration.Rpl_Sem_8_CGPA__c : 0,
                "PG Semester 1 Marksheet": this.studentRegistration.Rpl_PG1_Sem_CGPA__c ? this.studentRegistration.Rpl_PG1_Sem_CGPA__c : 0,
                "PG Semester 2 Marksheet": this.studentRegistration.Rpl_PG2_Sem_CGPA__c ? this.studentRegistration.Rpl_PG2_Sem_CGPA__c : 0,
                "PG Semester 3 Marksheet": this.studentRegistration.Rpl_PG3_Sem_CGPA__c ? this.studentRegistration.Rpl_PG3_Sem_CGPA__c : 0,
                "PG Semester 4 Marksheet": this.studentRegistration.Rpl_PG4_Sem_CGPA__c ? this.studentRegistration.Rpl_PG4_Sem_CGPA__c : 0,
                "UG Cumulative Marksheet": this.studentRegistration.Rpl_UG_Overall_Percentage__c ? this.studentRegistration.Rpl_UG_Overall_Percentage__c : this.studentRegistration.Rpl_UG_Overall_CGPA__c ? this.studentRegistration.Rpl_UG_Overall_CGPA__c : 0,
            };
            this.studentGeneralDetails = {
                "Student Details" : '-',
            }
            this.fetchAttachments();
        } else if (result.error) {
            //console.log(JSON.stringify(result.error));
            console.error('Error fetching student registration details:', result.error);
        }
    }
   
    fetchAttachments(){
        getRelatedFilesByRecordId({recordId : this.recordId})
        .then(data => {
      //console.log(JSON.stringify(data));
        this.filesList = [];
        Object.keys(this.studentGeneralDetails).forEach(detail => {
            let fieldMappingKey = detail;

            let value = this.studentGeneralDetails[fieldMappingKey];
            let approveLabel = "Approve";
            let rejectLabel = "Reject";
            const isVerifiedField = `Rpl_Is_${fieldMappingKey.replace(/ /g, '_')}_Verified__c`;
            const isRejectedField = `Rpl_Is_${fieldMappingKey.replace(/ /g, '_')}_Rejected__c`;
            if (this.studentRegistration[isVerifiedField]) {
                approveLabel = 'Approved';  
            } else if (this.studentRegistration[isRejectedField]) {
                rejectLabel = 'Rejected';
            }
            this.filesList.push({
                "label": fieldMappingKey,
                "id": fieldMappingKey,
                "value": '-',
                "approveLabel" : approveLabel,
                "rejectLabel" : rejectLabel,
                "rejectBrand" : rejectLabel == 'Rejected' ? 'destructive' : 'brand-outline',
                "approveBrand" : approveLabel == 'Approved' ? 'success' : 'brand-outline',
                "previewDisabled" : true,
            });

        })

        Object.keys(data).forEach(item => {
            const fieldMappingKey = Object.keys(this.fieldMapping).find(key => data[item].includes(key));
            console.log('Field Mapping Key ' + fieldMappingKey);
            let value = fieldMappingKey ? this.fieldMapping[fieldMappingKey] : null;
            let approveLabel = 'Approve';
            let rejectLabel = 'Reject';
            let approveBrand = "brand";
            let rejectBrand = "brand";
            if (value != undefined) {
                if (value > 10) {
                    value = value.toString() + ' %';
                } else if (value <= 10) {
                    value = value.toString() + ' CGPA';
                } else {
                    value = null;
                }
                //console.log('VALUE   '+value);
            } else {
                value = null;
            } 
           
            if (fieldMappingKey == 'Tenth Marksheet' || fieldMappingKey == 'Twelveth Marksheet'
                || fieldMappingKey == 'Resume' || fieldMappingKey == 'Diploma Marksheet') {
                    const isVerifiedField = `Rpl_Is_${fieldMappingKey.replace(/ /g, '_')}_Verified__c`;
                    const isRejectedField = `Rpl_Is_${fieldMappingKey.replace(/ /g, '_')}_Rejected__c`;

                    if (this.studentRegistration[isVerifiedField]) {
                        approveLabel = 'Approved';
                    } else if (this.studentRegistration[isRejectedField]) {
                        rejectLabel = 'Rejected';
                    }
            } else if (data[item].includes('UG Semester') || data[item].includes('PG Semester')) {
                const semesterNumber = this.extractSemesterNumber(data[item]);
                //console.log('UG or PG Semester' + semesterNumber);
                if (data[item].includes('UG Semester')) {
                    //console.log('UG Semester');
                    //console.log(JSON.stringify(this.studentRegistration));
                    ////console.log(JSON.stringify(this.studentRegistration[Rpl_UG_Rejected_Semester_Marksheets__c]));
                    this.studentRegistration.Rpl_UG_Rejected_Semester_Marksheets__c = this.studentRegistration.Rpl_UG_Rejected_Semester_Marksheets__c ? this.studentRegistration.Rpl_UG_Rejected_Semester_Marksheets__c : '';
                    this.studentRegistration.Rpl_UG_Verified_Semester_Marksheets__c = this.studentRegistration.Rpl_UG_Verified_Semester_Marksheets__c ? this.studentRegistration.Rpl_UG_Verified_Semester_Marksheets__c : '';
                    if (this.studentRegistration.Rpl_UG_Rejected_Semester_Marksheets__c.includes(semesterNumber)) {
                        rejectLabel = 'Rejected';
                    } else if (this.studentRegistration.Rpl_UG_Verified_Semester_Marksheets__c.includes(semesterNumber)) {
                        approveLabel = 'Approved';
                    }
                } else if (data[item].includes('PG Semester')) {
                    //console.log(JSON.stringify(this.studentRegistration));
                    this.studentRegistration.Rpl_PG_Rejected_Semester_Marksheets__c = this.studentRegistration.Rpl_PG_Rejected_Semester_Marksheets__c ? this.studentRegistration.Rpl_PG_Rejected_Semester_Marksheets__c : '';
                    this.studentRegistration.Rpl_PG_Verified_Semester_Marksheets__c = this.studentRegistration.Rpl_PG_Verified_Semester_Marksheets__c ? this.studentRegistration.Rpl_PG_Verified_Semester_Marksheets__c : '';
                    //console.log(JSON.stringify(this.studentRegistration.Rpl_PG_Rejected_Semester_Marksheets__c));
                    if (this.studentRegistration.Rpl_PG_Rejected_Semester_Marksheets__c.includes(semesterNumber)) {
                        rejectLabel = 'Rejected';
                    } else if (this.studentRegistration.Rpl_PG_Verified_Semester_Marksheets__c.includes(semesterNumber)) {
                        approveLabel = 'Approved';
                    }
                }
            }else if(fieldMappingKey== 'UG Cumulative Marksheet'){
                const isVerifiedField = `Rpl_Is_UG_Aggregate_Verified__c`;
                    const isRejectedField = 'Rpl_Is_UG_Aggregate_Rejected__c';

                    if (this.studentRegistration[isVerifiedField]) {
                        approveLabel = 'Approved';
                    } else if (this.studentRegistration[isRejectedField]) {
                        rejectLabel = 'Rejected';
                    }
            }
            approveBrand = approveLabel == 'Approved' ? "success" : "brand-outline" ;
            rejectBrand = rejectLabel == 'Rejected' ? "destructive" : "brand-outline";
            this.filesList.push({
                "label": fieldMappingKey == 'UG Cumulative Marksheet' ? 'UG Cumulative Marksheet': data[item].replace('.pdf', ''),
                "id": item,
                "value": value,
                "approveLabel" : approveLabel,
                "rejectLabel" : rejectLabel,
                "rejectBrand" : rejectBrand,
                "approveBrand" : approveBrand,
                "previewDisabled" : false,
            });

            //console.log(JSON.stringify(this.filesList));

        });
        //console.log('Attachment Data ' + JSON.stringify(this.filesList)); 
        }).catch(error => {
            //console.log(error);
        })
    }

previewHandler(event) {
    //console.log(event.target.dataset.id);
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'filePreview'
        },
        state: {
            selectedRecordId: event.target.dataset.id
        }
    });
}   

approveHandler(event){
    let rowId = event.target.dataset.id;
    let selectedRow = this.filesList.find(row => row.id == rowId);
    let label = selectedRow.label;
    label = label.replace('.pdf', '');
    if (selectedRow.label.includes("Tenth Marksheet") ||
        selectedRow.label.includes("Twelveth Marksheet") ||
        selectedRow.label.includes("Resume") ||
        selectedRow.label.includes("Graduation Details") ||
        selectedRow.label.includes("Diploma Marksheet") ||
        selectedRow.label.includes("Student Details")) {
        const isVerifiedField = `Rpl_Is_${label.replace(/ /g, '_')}_Verified__c`;
        const isRejectedField = `Rpl_Is_${label.replace(/ /g, '_')}_Rejected__c`;
        //console.log('Selected Label '  + label);
        this.studentRegistration[isVerifiedField] = true;
        this.studentRegistration[isRejectedField] = false;
        this.updateVerifyResult(label);
    }else if(selectedRow.label.includes("UG Cumulative Marksheet")){
        const isVerifiedField = `Rpl_Is_UG_Aggregate_Verified__c`;
        const isRejectedField = 'Rpl_Is_UG_Aggregate_Rejected__c';
        this.studentRegistration[isVerifiedField] = true;
        this.studentRegistration[isRejectedField] = false;
        this.updateVerifyResult(label);
    }else if(selectedRow.label.includes("UG Semester") || selectedRow.label.includes("PG Semester")){
        const semesterNumber = this.extractSemesterNumber(selectedRow.label);

        if (selectedRow.label.includes("UG Semester")) {
            this.handleSemesterVerification(semesterNumber, 'UG');
            this.updateVerifyResult(label);
        } else if (selectedRow.label.includes("PG Semester")) {
            this.handleSemesterVerification(semesterNumber, 'PG');
            this.updateVerifyResult(label);
        }
    }
}
 
rejectHandler(event){
    let rowId = event.target.dataset.id;
    let selectedRow = this.filesList.find(row => row.id == rowId);
    let label = selectedRow.label;
    label = label.replace('.pdf', '');
    if (selectedRow.label.includes("Tenth Marksheet") ||
        selectedRow.label.includes("Twelveth Marksheet") ||
        
        selectedRow.label.includes("Resume") ||
        selectedRow.label.includes("Graduation Details") ||
        selectedRow.label.includes("Student Details") || 
      selectedRow.label.includes("Diploma Marksheet") ) {  
        const isVerifiedField = `Rpl_Is_${label.replace(/ /g, '_')}_Verified__c`;
        const isRejectedField = `Rpl_Is_${label.replace(/ /g, '_')}_Rejected__c`;
        //console.log('Selected Label '  + label);
        this.studentRegistration[isVerifiedField] = false;
        this.studentRegistration[isRejectedField] = true;
        this.updateRejectResult(label);
    }else if(selectedRow.label.includes("UG Cumulative Marksheet")){
        const isVerifiedField = `Rpl_Is_UG_Aggregate_Verified__c`;
        const isRejectedField = 'Rpl_Is_UG_Aggregate_Rejected__c';
        this.studentRegistration[isVerifiedField] = false;
        this.studentRegistration[isRejectedField] = true;
        this.updateRejectResult(label);
    }else if(selectedRow.label.includes("UG Semester") || selectedRow.label.includes("PG Semester")){
        const semesterNumber = this.extractSemesterNumber(selectedRow.label);
        if (selectedRow.label.includes("UG Semester")) {
            this.handleSemesterRejection(semesterNumber, 'UG');
            this.updateRejectResult(label);
        } else if (selectedRow.label.includes("PG Semester")) {
            this.handleSemesterRejection(semesterNumber, 'PG');
            this.updateRejectResult(label);
        }
    }
}
handleSemesterRejection(semesterNumber, type) {
    const rejectedField = `Rpl_${type}_Rejected_Semester_Marksheets__c`;
    const verifiedField = `Rpl_${type}_Verified_Semester_Marksheets__c`;

    // Split the existing values into an array
    let rejectedSemesters = this.studentRegistration[rejectedField] ? this.studentRegistration[rejectedField].split(',').map(item => item.trim()) : [];
    let verifiedSemesters = this.studentRegistration[verifiedField] ? this.studentRegistration[verifiedField].split(',').map(item => item.trim()) : [];

    // Remove the semesterNumber from verifiedSemesters
    verifiedSemesters = verifiedSemesters.filter(semester => semester != semesterNumber);

    // Add semesterNumber to rejectedSemesters if not present
    if (!rejectedSemesters.includes(semesterNumber)) {
        rejectedSemesters.push(semesterNumber);
    }

    // Convert arrays to sets to ensure uniqueness
    const uniqueRejectedSemesters = Array.from(new Set(rejectedSemesters));
    const uniqueVerifiedSemesters = Array.from(new Set(verifiedSemesters));

    // Join the sets into comma-separated strings
    this.studentRegistration[rejectedField] = uniqueRejectedSemesters.join(', ');
    this.studentRegistration[verifiedField] = uniqueVerifiedSemesters.join(', ');

    // Log the updated values
    //console.log(`Updated ${type} Semester Marksheets - Rejected: ${this.studentRegistration[rejectedField]}, Verified: ${this.studentRegistration[verifiedField]}`);
}

handleSemesterVerification(semesterNumber, type) {
    const rejectedField = `Rpl_${type}_Rejected_Semester_Marksheets__c`;
    const verifiedField = `Rpl_${type}_Verified_Semester_Marksheets__c`;

    // Split the existing values into an array
    let rejectedSemesters = this.studentRegistration[rejectedField] ? this.studentRegistration[rejectedField].split(',').map(item => item.trim()) : [];
    let verifiedSemesters = this.studentRegistration[verifiedField] ? this.studentRegistration[verifiedField].split(',').map(item => item.trim()) : [];

    // Remove the semesterNumber from rejectedSemesters
    rejectedSemesters = rejectedSemesters.filter(semester => semester != semesterNumber);

    // Add semesterNumber to verifiedSemesters if not present
    if (!verifiedSemesters.includes(semesterNumber)) {
        verifiedSemesters.push(semesterNumber);
    }

    // Convert arrays to sets to ensure uniqueness
    const uniqueRejectedSemesters = Array.from(new Set(rejectedSemesters));
    const uniqueVerifiedSemesters = Array.from(new Set(verifiedSemesters));

    // Join the sets into comma-separated strings
    this.studentRegistration[rejectedField] = uniqueRejectedSemesters.join(', ');
    this.studentRegistration[verifiedField] = uniqueVerifiedSemesters.join(', ');

    // Log the updated values
    //console.log(`Updated ${type} Semester Marksheets - Rejected: ${this.studentRegistration[rejectedField]}, Verified: ${this.studentRegistration[verifiedField]}`);
}

updateVerifyResult(documentName){
    updateStudentRegDetails({stdRegDetails : this.studentRegistration})
    .then(result => {
        this.showSuccessToast(`${documentName} Verified Successfully`)
    }).catch(error => {
        //console.log(error);
    })
}

updateRejectResult(documentName){
    updateStudentRegDetails({stdRegDetails : this.studentRegistration})
    .then(result => {
        this.showSuccessToast(`${documentName} Rejected Successfully`);
    }).catch(error => {
        //console.log(error);
    })
}

 extractSemesterNumber(documentName) {
    const match = documentName.match(/\d+/);
    return match ? parseInt(match[0], 10) : null;
    }

    isSemesterVerified(verifiedSemesterField, semesterNumber) {
        //console.log(verifiedSemesterField + '-----------------------' + semesterNumber);
        // Check if the semesterNumber is present in the verified semester field
        return verifiedSemesterField.includes(semesterNumber.toString());
    }

    showSuccessToast(message, title = 'Success') {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success',
        });
        this.dispatchEvent(event);
        return refreshApex(this.wiredResult);
    }


    showErrorToast(error, title = 'Error') {
        //console.log(JSON.stringify(error));
        const event = new ShowToastEvent({
            title: title,
            message: error.body.message || error.message || 'An error occurred',
            variant: 'error',
        });
        this.dispatchEvent(event);
    }
}