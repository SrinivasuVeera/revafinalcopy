import { LightningElement, track, api } from 'lwc';
import RevalOnlyFee from '@salesforce/label/c.Fee_For_Exam_Revalution';
import PhotocopyOnlyFee from '@salesforce/label/c.Fee_For_Photocopy';
import CombinedFee from '@salesforce/label/c.Fee_For_Revalution_Photocopy';
import fetchStudentResults from '@salesforce/apex/ASM_StudentResultView.fetchStudentResults';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLoggedInUserContactId from '@salesforce/apex/RevaExamPhotocopyRevaluationController.getLoggedInUserContactId';
import { NavigationMixin } from 'lightning/navigation';
import processStudentApplications from '@salesforce/apex/RevaExamPhotocopyRevaluationController.processStudentApplications';
import RevaluationDays from '@salesforce/label/c.Revaluation_Days';
import PhotocopyDays from '@salesforce/label/c.Photocopy_Days';
import getPhotocopyRecordsWithFiles from '@salesforce/apex/RveExamPhotocopyFileUploadController.getPhotocopyRecordsWithFiles';



export default class RvePhotocopyRevalution extends NavigationMixin(LightningElement) {
    @track showInstructions = true;
    @track isDisabled = true;
    @track resultDataList = [];
    @track Spinner = true;
    @track totalAmount = 0;
    @track contactId;
    @track isDisabled = true;
    @track selectedOptions = [];
    @track isSubmitting = false;
    @api contactId;
    /****Newly added *******/
    @track revalEndDate;
    @track photocopyEndDate;
    @track firstRevalEndDate = 'N/A';
@track firstPhotocopyEndDate = 'N/A';
    /*************/

    label = {
        RevalOnlyFee,
        PhotocopyOnlyFee,
        CombinedFee
    };


    get revalFee() {
        return parseFloat(this.label.RevalOnlyFee) || 0;
        // return this.label.RevalOnlyFee;
    }

    get photoFee() {
        //return this.label.PhotocopyOnlyFee;
        return parseFloat(this.label.PhotocopyOnlyFee) || 0;
    }

    get combinedFee() {
        //return this.label.CombinedFee;
        return parseFloat(this.label.CombinedFee) || 0;
    }

    get isdisabled() {
        return !this.resultDataList.some(item => item.selectedOptions.length > 0);
    }
    get isSubmitDisabled() {
        return !this.userHasInteracted; // ✅ Only enable the button when the user selects an option
    }
    get isButtonDisabled() {
        return this.isSubmitting || this.isSubmitDisabled;
    }

   // @track isPGStudent = false;

    get options() {
        return [
            { label: 'Revaluation Only', value: 'Revaluation' },
            { label: 'Photocopy Only', value: 'Photocopy' }
        ];
    }

    /*handlePhotocopyClick(event) {
        const previewUrl = event.target.dataset.url;
        const recordId = event.target.dataset.id;
    
        if (previewUrl) {
            // Opens in a new tab and shows download options by default (Salesforce handles download headers)
            window.open(previewUrl, '_blank');
            console.log(`Opened Photocopy Preview for Record ID: ${recordId}`);
        } else {
            console.warn(`Preview URL not found for Record ID: ${recordId}`);
            this.showToast('Warning', 'Photocopy file not available for preview.', 'warning');
        }
    }*/
     handlePhotocopyClick(event) {
    const previewUrl = event.target.dataset.url;
    const recordId = event.target.dataset.id;

    console.log("Preview URL:", previewUrl); // Debugging

    if (previewUrl) {
        window.open(previewUrl, "_blank");
        console.log(`Opened Photocopy Preview for Record ID: ${recordId}`);
    } else {
        console.warn(`Preview URL not found for Record ID: ${recordId}`);
        this.showToast("Warning", "Photocopy file not available for preview.", "warning");
    }
}
    
    /*connectedCallback() {
        this.fetchContactId();
        this.loadResultData();
        this.loadPhotocopyRecords();
    }*/
        connectedCallback() {
            this.fetchContactId();
            this.loadResultData().then(() => {
                this.loadPhotocopyRecords();
            });
        }

       /*connectedCallback() {
            Promise.all([this.fetchContactId(), this.loadResultData()])
                .then(() => {
                    console.log('Contact ID & Student Results Loaded');
                })
                .catch(error => {
                    console.error('Error initializing data:', error);
                });
        }*/
    async fetchContactId() {
        try {
            const result = await getLoggedInUserContactId();
            this.contactId = result;
        } catch (error) {
            console.error('Error fetching Contact ID:', error);
            this.showToast('Error', 'Failed to retrieve Contact ID.', 'error');
        }
    }



    
    async loadResultData() {
        try {
            this.Spinner = true;
            console.log('Calling Apex fetchStudentResults()...');
            
            const result = await fetchStudentResults();
            console.log('Raw Apex result:', JSON.stringify(result));
    
            if (result && Array.isArray(result.list_Results) && result.list_Results.length > 0) {
                console.log('Mapping result data...');


                //const today = new Date();
                const revaluationDays = RevaluationDays ? parseInt(RevaluationDays) : 10; 
                const photocopyDays = PhotocopyDays ? parseInt(PhotocopyDays) : 5; 

                const toMidnight = date => new Date(date.getFullYear(), date.getMonth(), date.getDate());
           

            const today = toMidnight(new Date());



                let appliedCourses = new Set();
                result.list_Results.forEach(item => {
                    if (item.AppliedForRevaluation__c) {
                        appliedCourses.add(item.Course__r.Id); // Track courses with Revaluation applied
                    }
                });


                /*****************new added11072025 adding end dates in UI********************** */
                // ✅ NEW: Find latest Results_Announced_Date__c
           /* let latestResultDate = null;
            result.list_Results.forEach(item => {
                if (item.Results_Announced_Date__c) {
                    const currentDate = toMidnight(new Date(item.Results_Announced_Date__c));
                    if (!latestResultDate || currentDate > latestResultDate) {
                        latestResultDate = currentDate;
                    }
                }
            });

            
            this.firstRevalEndDate = latestResultDate
                ? new Date(latestResultDate.getTime() + revaluationDays * 24 * 60 * 60 * 1000).toLocaleDateString('en-GB')
                : 'N/A';

            this.firstPhotocopyEndDate = latestResultDate
                ? new Date(latestResultDate.getTime() + photocopyDays * 24 * 60 * 60 * 1000).toLocaleDateString('en-GB')
                : 'N/A';*/
                /*********************ended here********************************** */
    
                this.resultDataList = result.list_Results.map(item => {
                   

                const appliedForRevaluation = item.AppliedForRevaluation__c || false;
                const appliedForPhotocopy = item.AppliedForPhotoCopy__c || false;
                /******************************newly added******************* */
                


                /************************working one******************* */
               /* const resultDate = item?.hed__Term__r?.Results_Announced_Date__c ? new     
                     Date(item.hed__Term__r.Results_Announced_Date__c) : null;*/

                     const resultDate = item?.Results_Announced_Date__c
                     ? toMidnight(new Date(item.Results_Announced_Date__c))
                     : null;
                     
                const daysSinceResult = resultDate ? Math.floor((today - resultDate) / (1000 * 60 * 60 * 24))+1 : null;
               /**********Nealy added**************** */
               /*const firstItem = result.list_Results[0];
this.firstRevalEndDate = firstItem?.Revaluation_End_Date__c
    ? new Date(firstItem.Revaluation_End_Date__c).toLocaleDateString('en-GB')
    : 'N/A';
this.firstPhotocopyEndDate = firstItem?.Photocopy_End_Date__c
    ? new Date(firstItem.Photocopy_End_Date__c).toLocaleDateString('en-GB')
    : 'N/A';*/
                /********************ended here********/
                        let options = [
                            { label: 'Revaluation Only', value: 'Revaluation' },
                            { label: 'Photocopy Only', value: 'Photocopy' }
                        ];
        
                        
        
                        options.forEach(opt => {
                            opt.disabled = false;/**********Newly added on 12062025************/
                            if (opt.value === 'Revaluation' && appliedForRevaluation) {
                                opt.disabled = true;
                            }
                            if (opt.value === 'Photocopy' && appliedForPhotocopy) {
                                opt.disabled = true;
                            }
                            if (opt.value === 'Photocopy' && appliedCourses.has(item.Course__r.Id)) {
                                opt.disabled = true; // Restrict Photocopy if Revaluation applied for this course
                            }
                            if (!resultDate || (opt.value === 'Revaluation' && daysSinceResult > revaluationDays)) {
                                opt.disabled = true; // Restrict based on SEE Result Date
                            }
                            if (!resultDate || (opt.value === 'Photocopy' && daysSinceResult > photocopyDays)) {
                                opt.disabled = true; // Restrict based on SEE Result Date
                            }
                            opt.isPhotocopy = opt.value === 'Photocopy';/**********Newly added on 12062025************/
                        });
        
                        // ✅ Ensure applied options are selected but not editable
                        let selected = [];
                        if (appliedForRevaluation) selected.push('Revaluation');
                        if (appliedForPhotocopy) selected.push('Photocopy');
        
                
    
                    return {
                        id: item.Id,
                        courseName: item.Course__r ? item.Course__r.Name : 'N/A',
                        courseId: item.Course__r ? item.Course__r.hed__Course_ID__c : 'N/A',
                        grade: item.Grade__c || 'N/A',
                        sgpa: item.SGPA__c || 'N/A',
                        cgpa: item.CGPA__c || 'N/A',
                        noOfCredits: item.No_of_Credits__c || 'N/A',
                        gradePoints: item.Grade_Points__c || 'N/A',
                        creditPoints: item.Credit_Points__c || 'N/A',
                        result: item.hed__Result__c || 'N/A',
                        securedMarks: item.Total_Secured_Marks_Course__c || 'N/A',
                        maxMarks: item.Course__r ? item.Course__r.Total_Maximum_Marks_IA_External__c : 'N/A',
                        appliedForRevaluation,
                         appliedForPhotocopy,
                         selectedOptions: selected,
                   //working one selectedOptions: appliedForRevaluation ? ['Revaluation'] : appliedForPhotocopy ? ['Photocopy'] : [], 
                       availableOptions: options,
                       showPhotocopyLink:
                        appliedForPhotocopy &&
                        item.Fee_Paid_For_Photocopy__c &&
                        item.Photocopy_Uploaded__c,
                        previewUrl: item.ContentDocumentId
                        ? `/sfc/servlet.shepherd/document/download/${item.ContentDocumentId}`
                        : null,
                        
                    isChanged: false // used in handleFinalSubmit
                      
                      
   
                        
                    };
                });
    
                console.log('Processed resultDataList:', JSON.stringify(this.resultDataList));
            } else {
                console.warn('No result records found.');
                this.resultDataList = [];
            }
    
            this.Spinner = false;
        } catch (error) {
            this.Spinner = false;
           // this.showToast('Error', 'Error fetching student results: ' + error.body.message, 'error');
           // console.error('Error fetching student results:', error);
            const errorMessage = error?.body?.message || 'Unexpected error occurred while fetching student results.';
        this.showToast('Error', errorMessage, 'error');
        console.error('Error fetching student results:', error);
        }
    }
    
    /***************Newly added on 12062025***************** */
    async loadPhotocopyRecords() {
        try {
            const resultIds = this.resultDataList.map(r => r.id);
            const photocopyRecords = await getPhotocopyRecordsWithFiles({ resultIds });
            /***********working one*************************** */
            /*this.resultDataList = this.resultDataList.map(result => {
                const match = photocopyRecords.find(p => p.resultId === result.id);
                if (match) {
                    result.previewUrl = match.previewUrl;
                    result.showPhotocopyLink = true;
                }
                return result;
            });*/
            const today = new Date();
            const photocopyDays = 10;
            this.resultDataList = this.resultDataList.map(result => {
                const match = photocopyRecords.find(p => p.resultId === result.id);
            
                if (match) {
                    const resultDate = match.seeResultDate ? new Date(match.seeResultDate) : null;
                    const daysSinceResult = resultDate
                        ? Math.floor((new Date() - resultDate) / (1000 * 60 * 60 * 24)) + 1
                        : null;
            
                    result.previewUrl = match.previewUrl;
                    result.showPhotocopyLink = (
                        match.previewUrl &&
                        match.fileUploaded &&
                        daysSinceResult !== null &&
                        daysSinceResult <= 10
                    );
                } else {
                    result.showPhotocopyLink = false;
                }
            
                return result;
            });
            
            
            
            /****************chnages ended here************************ */
        } catch (error) {
            console.error('Error loading photocopy records:', error);
        }
    }
    
   
/******************************************************* */

    handleCheckboxChange(event) {
        this.isDisabled = !event.target.checked;
    }

    handleProceed() {
        this.showInstructions = false;

        // Reload data just in case results were not loaded during connectedCallback
        if (!this.resultDataList || this.resultDataList.length === 0) {
            this.Spinner = true;
            this.loadResultData();
        }
    }

    redirectToStudentFeePaymentComponent() {
        window.location.href = '/StudentPortal/s/student-fee';
    }
    /**********Newly added on 12062025************/
    isPhotocopyOption(value) {
        return value === 'Photocopy';
    }
    getFilePreviewUrl(contentDocumentId) {
        return `/sfc/servlet.shepherd/document/download/${contentDocumentId}`;
    }
    

    

    /**************Changes ended here**********************/


    /************************************************ */
    
        /**************************************************** */
       
                    handleOptionChange(event) {
                        const rowId = event.target.dataset.id;
                        const selectedValue = event.target.dataset.value;
                        const isChecked = event.target.checked;
                    
                        this.resultDataList = this.resultDataList.map(item => {
                            if (item.id === rowId) {
                                console.log(`Updating selection for Record ID ${rowId} | Checked: ${isChecked} | Value: ${selectedValue}`);
                                this.userHasInteracted = true;
                                if (isChecked && !item.selectedOptions.includes(selectedValue)) {
                                    if (selectedValue === 'Revaluation') {
                                        console.warn(`Revaluation selected for ${rowId}, ensuring Photocopy is removed.`);
                                        item.selectedOptions = item.selectedOptions.filter(option => option !== 'Photocopy');
                                    }
                    
                                    item.selectedOptions.push(selectedValue);
                                    item.isChanged = true; // ✅ Mark this record as changed!
                                } else if (!isChecked) {
                                    item.selectedOptions = item.selectedOptions.filter(option => option !== selectedValue);
                                    item.isChanged = true; // ✅ Track deselection as a change.
                                }
                    
                                console.log(`Updated selection after change for Record ID ${rowId}:`, JSON.stringify(item.selectedOptions));
                            }
                            return item;
                        });
                    
                        console.log('Updated resultDataList after selection change:', JSON.stringify(this.resultDataList));
                    }
    /************************************************* */
       
    /************************************************** */
                /*******************Working one************************* */
        
                           handleFinalSubmit() {
                                console.log('Submitting selected applications...');
                                this.isSubmitting = true;
                                console.log('Before submitting, resultDataList:', JSON.stringify(this.resultDataList));
                            
                                const applications = [];
                            
                                this.resultDataList.forEach(item => {
                                    console.log(`Processing Record ID: ${item.id} | Selected Options: ${JSON.stringify(item.selectedOptions)}`);
                            
                                    // 🚨 **Only submit records where user actually made changes**
                                    if (!item.isChanged) {
                                        console.warn(`Skipping Record ID ${item.id} because it was not changed.`);
                                        return;
                                    }
                            
                                    if (item.selectedOptions.includes('Photocopy')) {
                                        applications.push({
                                            resultRecordId: item.id,
                                            contactId: this.contactId,
                                            feeType: 'PC Fee',
                                            amount: this.photoFee.toString(),
                                            courseCode: item.courseId
                                        });
                                    }
                            
                                    if (item.selectedOptions.includes('Revaluation')) {
                                        applications.push({
                                            resultRecordId: item.id,
                                            contactId: this.contactId,
                                            feeType: 'RV Fee',
                                            amount: this.revalFee.toString(),
                                            courseCode: item.courseId
                                        });
                                    }
                                });
                            
                                console.log('Final applications array before Apex:', JSON.stringify(applications));
                            
                                if (applications.length === 0) {
                                    console.warn('No applications to submit. Verify selections.');
                                    this.showToast('Warning', 'Please select an option before submitting.', 'warning');
                                    this.isSubmitting = false;
                                    return;
                                }
                            
                                processStudentApplications({ applications })
                                    .then(() => {
                                        console.log('Applications processed successfully.');
                                        this.showToast('Success', 'Applications submitted successfully.', 'success');
                                        console.log('Redirecting to payment page...');
                                        this.redirectToStudentFeePaymentComponent();
                                    })
                                    .catch(error => {
                                        console.error('Error processing applications:', error);
                                        this.showToast('Error', 'Submission failed.', 'error');
                                        this.isSubmitting = false;
                                    });
                            }
                                            
    /************************************************************** */
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
                mode: 'dismissible'
            })
        );
    }
}