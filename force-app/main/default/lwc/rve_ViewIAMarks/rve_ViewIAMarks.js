import { LightningElement, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import formFactorPropertyName from "@salesforce/client/formFactor";
import IA_Marks_Acknowledgement_Days from '@salesforce/label/c.IA_Marks_Acknowledgement_Days';
// Import from Apex
import fetchData from '@salesforce/apex/ASM_StdIAMarksViewv2.fetchData';
import updateAcknowledgment from '@salesforce/apex/ASM_StdIAMarksViewv2.updateAcknowledgment';


export default class Rve_ViewIAMarks extends LightningElement {
    boolShowSpinner = true;
    @track screen=formFactorPropertyName;
    smallscreen =false;
    IATypesOptionSelected = 'IA1';
    showIAMarks = false;
    showProjectIA = false;
    showTheoryIA = false;
    activeSem = '';
    @track isActiveSemester = false;
    @track iaMarksRecords = []
    @track semesterOptions = [];
    selectedSemester = '';
    @track iaMarks = {
        activeSem : '',
        crsType : '',
        list_IAMarks : {
            Course_Offering__r : {
                hed__Course__r : {}
            }
        },
    };
    @track isModalOpen = false; 
    @track selectedRecordId = '';
    @track IA2resultDate = '';
     @track totalIAMarks;
     @track acknowledgmentClosingDate;
    get IATypesOptions() {
        return [
            { label: 'IA1', value: 'IA1' },
            { label: 'IA2', value: 'IA2' }
        ];
    }

    get isIA2Selected() {
    return this.IATypesOptionSelected === 'IA2';
}

    connectedCallback(){
        if(this.screen==='Small'){
            this.smallscreen=true;
        }
        this.fetchIAData(this.IATypesOptionSelected, null);
    }
    
   fetchIAData(iaType,semesterId){
        this.showIAMarks = false;
        this.boolShowSpinner = true;
        console.log("Fetching IA data for IA Type:", iaType);
        fetchData({iaType : iaType,semesterId: semesterId})
        .then(result => {
           console.log("Fetch result:", result);
            console.log('##### Response from Apex:', JSON.stringify(result));
            this.activeSem = result.activeSem;
            this.semesterOptions = result.semesters.map(sem => ({
                label: sem.Name,
                value: sem.Id
            }));

            if (!this.selectedSemester) {
                this.selectedSemester = result.activeSemesterId;
            }
            this.totalIAMarks = result.totalIAMarks;
            this.isActiveSemester = result.isActiveSemester;

            let lastAcknowledgmentDate = null;
            //console.log('id==',activeSem);
          /* console.log("result.list_IAMarks ###:", result.list_IAMarks);
            console.log("Semester__r ###:", result.list_IAMarks[0].Semester__r);
            console.log("Semester__r:IA_2_Result_Date__c ###:", result.list_IAMarks[0].Semester__r.IA_2_Result_Date__c);*/
           //this.IA2resultDate = result.list_IAMarks[0].Semester__r.IA_2_Result_Date__c;
           if (
            result.list_IAMarks &&
            result.list_IAMarks.length > 0 &&
            result.list_IAMarks[0].Semester__r &&
            result.list_IAMarks[0].Semester__r.IA_2_Result_Date__c
        ) {

            this.IA2resultDate =
                result.list_IAMarks[0].Semester__r.IA_2_Result_Date__c;

            const resultDate = new Date(this.IA2resultDate);
            resultDate.setHours(0, 0, 0, 0);

            lastAcknowledgmentDate = new Date(resultDate);
            lastAcknowledgmentDate.setDate(
                resultDate.getDate() + Number(IA_Marks_Acknowledgement_Days)
            );

            this.acknowledgmentClosingDate =
                lastAcknowledgmentDate.getDate().toString().padStart(2, '0') +
                '/' +
                (lastAcknowledgmentDate.getMonth() + 1)
                    .toString()
                    .padStart(2, '0') +
                '/' +
                lastAcknowledgmentDate.getFullYear();

            console.log(
                "Last Acknowledgment Allowed Date:",
                lastAcknowledgmentDate
            );
        }

        this.iaMarksRecords = result?.list_crsWpr.map(item => {

            let isTheoryCRSType = item.crsType === 'Theory';
            let isProjectCRSType = item.crsType === 'Project';
            let isPracticalCRSType = item.crsType === 'Practical';

            let hedCourse =
                item?.list_IAMarks[0]?.Course_Offering__r?.hed__Course__r;

            let showTable = hedCourse != null;

            let updatedList_IAMarks = item.list_IAMarks.map(course => {

                let isAcknowledgmentAllowed = false;

                if (lastAcknowledgmentDate) {

                    const normalizeDate = (date) =>
                        new Date(
                            date.getFullYear(),
                            date.getMonth(),
                            date.getDate()
                        );

                    const currentDate = normalizeDate(new Date());

                    const normalizedLastAckDate =
                        normalizeDate(lastAcknowledgmentDate);

                    isAcknowledgmentAllowed = this.isActiveSemester &&
                        currentDate <= normalizedLastAckDate;
                }

                return {
                    ...course,
                    Acknowledgment_Response__c:
                        course.Acknowledgment_Response__c || null,
                    isAcknowledgmentAllowed: isAcknowledgmentAllowed
                };
            });

            return {
                ...item,
                isTheoryCRSType,
                isProjectCRSType,
                isPracticalCRSType,
                hedCourse,
                showTable,
                list_IAMarks: updatedList_IAMarks
            };
        });

        this.showIAMarks =
            result?.list_crsWpr &&
            result.list_crsWpr.length > 0;

        this.boolShowSpinner = false;
    })
    .catch(error => {
        this.boolShowSpinner = false;
        console.error("##### Error Fetching Data:", error);
    });
}
    handleSemesterChange(event) {
    this.selectedSemester = event.detail.value;

    this.fetchIAData(
        this.IATypesOptionSelected,
        this.selectedSemester
    );
    }
   /*fetchIAData(iaType){
        this.showIAMarks = false;
        this.boolShowSpinner = true;
        fetchData({iaType : iaType})
        .then(result => {
            this.activeSem = result.activeSem;
            this.IA2resultDate = result.IA2resultDate; // Fetch IA2 result date from Apex
                
                const currentDate = new Date();
                if (this.IA2resultDate) {
                    const resultDate = new Date(this.IA2resultDate);
                    resultDate.setHours(0, 0, 0, 0); // Normalize date to avoid time mismatches
                    const lastAcknowledgmentDate = new Date(resultDate);
                    lastAcknowledgmentDate.setDate(resultDate.getDate() + 7);

            
            this.iaMarksRecords = result?.list_crsWpr.map(item => {
                let isTheoryCRSType = item.crsType == 'Theory' ? true : false;
                let isProjectCRSType = item.crsType == 'Project' ? true : false;
                let isPracticalCRSType = item.crsType == 'Practical' ? true : false;
                let hedCourse = item?.list_IAMarks[0]?.Course_Offering__r?.hed__Course__r;
                let showTable = hedCourse != null ? true : false;
                let updatedList_IAMarks = item.list_IAMarks.map(course => {
                        let isAcknowledgmentAllowed = currentDate <= lastAcknowledgmentDate;
                        return {
                            ...course,
                            Acknowledgment_Response__c: course.Acknowledgment_Response__c || null,
                            isAcknowledgmentAllowed: isAcknowledgmentAllowed
                        };
                });
                return {...item, isTheoryCRSType : isTheoryCRSType, isProjectCRSType : isProjectCRSType, isPracticalCRSType : isPracticalCRSType, hedCourse : hedCourse, showTable : showTable, list_IAMarks : updatedList_IAMarks };
            });
        }
            this.showIAMarks = result?.list_crsWpr.length > 0 ? true : false;
            this.boolShowSpinner = false;
        })
        .catch(error => {
            this.boolShowSpinner = false;
        })
    }*/

    handleChangeIATypes(event){
        this.IATypesOptionSelected = event.detail.value;
        this.fetchIAData(this.IATypesOptionSelected,this.selectedSemester);
    }
    /***************Newly added by veera **********************/
    handleAcknowledgementClick(event) {
        this.selectedRecordId = event.target.dataset.id; // Get recordId from button
        console.log('ia mark recod id:',this.selectedRecordId);
        this.isModalOpen = true;
    }

    handleCloseModal() {
    this.isModalOpen = false;
}
    // Close modal on Confirm (Yes)
    handleConfirm() {
        this.updateAcknowledge('Acknowledged by Student'); // Send 'Yes' to Apex
    }

    // Close modal on Cancel (No)
    /*handleCancel() {
        this.updateAcknowledge('No'); // Send 'No' to Apex
    }*/

    // Call Apex method to update acknowledgment
    
   updateAcknowledge(response) {
    updateAcknowledgment({ recordId: this.selectedRecordId, response: response })
        .then(() => {
            this.isModalOpen = false;
            this.iaMarksRecords = this.iaMarksRecords.map(item => {
                return {
                    ...item,
                    list_IAMarks: item.list_IAMarks.map(course => {
                        if (course.Id === this.selectedRecordId) {
                            return { ...course, Acknowledgment_Response__c: response };
                        }
                        return course;
                    })
                };
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `Acknowledgment updated: ${response}`,
                    variant: 'success',
                })
            );
        })
        .catch(error => {
            this.isModalOpen = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to update acknowledgment',
                    variant: 'error',
                })
            );
        });
}
    /******************************** */
}