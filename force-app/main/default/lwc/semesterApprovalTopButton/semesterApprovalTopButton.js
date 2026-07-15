import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';

import getApprovalSteps from '@salesforce/apex/SemesterApprovalCtrl.getApprovalSteps';
import getCourseOfferings from '@salesforce/apex/SemesterApprovalCtrl.getCourseOfferings';
import processAction from '@salesforce/apex/SemesterApprovalCtrl.processAction';

const HISTORY_COLUMNS = [
    { label: 'Step Name', fieldName: 'stepName' },
    { label: 'Date', fieldName: 'createdDate', type: 'date', typeAttributes: { hour: '2-digit', minute: '2-digit' }},
    { label: 'Status', fieldName: 'status' },
    { label: 'Assigned To', fieldName: 'assignedTo' },
    { label: 'Actual Approver', fieldName: 'actualApprover' },
    { label: 'Comments', fieldName: 'comments' }
];

const COURSE_COLUMNS = [    
    { label: 'Course ID',     fieldName: 'courseId',         type: 'text', initialWidth: 100,  wrapText: true },
    { label: 'Course Name',   fieldName: 'courseName',       type: 'text',initialWidth: 130,  wrapText: true },
    { label: 'Category',      fieldName: 'category',         type: 'text', initialWidth: 100,  wrapText: true},
    { label: 'LCourse',          fieldName: 'lcoursetype',     type: 'text',initialWidth: 95,  wrapText: true },
    { label: 'Type',          fieldName: 'subType',          type: 'text',initialWidth: 80,  wrapText: true },
    { label: 'LMandatory',          fieldName: 'lmandatory',     type: 'text',initialWidth: 80,  wrapText: true },
    { label: 'L:T:P',         fieldName: 'ltp',              type: 'text', initialWidth: 80,  wrapText: true},
    { label: 'Credits',       fieldName: 'credits',          type: 'number', typeAttributes: { minimumFractionDigits: 1 }, initialWidth: 85, cellAttributes: { alignment: 'center' } },
    { label: 'Credits Hours',       fieldName: 'creditsHours',          type: 'number', typeAttributes: { minimumFractionDigits: 1 }, initialWidth: 95, cellAttributes: { alignment: 'center' } },
    { label: 'IAs',           fieldName: 'noOfIAs',          type: 'number', initialWidth: 60, cellAttributes: { alignment: 'center' }},
    { label: 'Theory',        fieldName: 'theoryMarks',      type: 'number', initialWidth: 85, cellAttributes: { alignment: 'center' } },
    { label: 'Sem',       fieldName: 'seminarMarks',     type: 'number', initialWidth: 70, cellAttributes: { alignment: 'center' } },
    { label: 'Quiz',          fieldName: 'quizMarks',        type: 'number', initialWidth: 70, cellAttributes: { alignment: 'center' } },
    { label: 'Practical',       fieldName: 'resultsMarks',     type: 'number', initialWidth: 100, cellAttributes: { alignment: 'center' } },
    { label: 'Project',    fieldName: 'continuousMarks',  type: 'number', initialWidth: 90, cellAttributes: { alignment: 'center' } },
    { label: 'Max IM',    fieldName: 'Maxinternal',  type: 'number', initialWidth: 90, cellAttributes: { alignment: 'center' } },
    { label: 'Max EM',    fieldName: 'Maxexternal',  type: 'number', initialWidth: 90, cellAttributes: { alignment: 'center' } },
    { label: 'Total Max IA',    fieldName: 'totalmaxmarks',  type: 'number', initialWidth: 100, cellAttributes: { alignment: 'center' } },
    { label: 'LSubType',          fieldName: 'lsubtype',          type: 'text',initialWidth: 95,  wrapText: true }
];

export default class SemesterApprovalCustomHistory extends LightningElement {
    @api recordId;
    historyColumns = HISTORY_COLUMNS;
    courseColumns = COURSE_COLUMNS;
    history = [];
    courses = [];
    workItemId;
    showPopup = false;
    showCommentModal = false;
    actionType = '';
    comment = '';
    isLoading = false;
    wiredHistory;

    // Load Approval History
    @wire(getApprovalSteps, { recordId: '$recordId' })
    wiredSteps(result) {
        this.wiredHistory = result;
        const { data } = result;
        if (data) {
            this.history = data.map(s => ({
                id: s.id,
                stepName: s.stepName,
                createdDate: s.createdDate,
                status: s.status,
                assignedTo: s.assignedTo,
                actualApprover: s.actualApprover,
                comments: s.comments || '',
                workItemId: s.workItemId
            }));

            // Find pending step for current user
            const pending = data.find(s => s.status === 'Pending');
            this.workItemId = pending?.workItemId || null;
        }
    }

    // Open Course Popup
    async handleApproveClick() {
        if (!this.workItemId) return;
        this.isLoading = true;
        try {
            const data = await getCourseOfferings({ semesterId: this.recordId });
            this.courses = data;
            this.showPopup = true;
        } catch (err) {
            this.showToast('Error', 'Failed to load courses', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // Popup Actions
    handlePopupApprove() { this.actionType = 'Approve'; this.openCommentModal(); }
    handlePopupReject()  { this.actionType = 'Reject';  this.openCommentModal(); }
    handlePopupCancel()  { this.showPopup = false; }

    openCommentModal() {
        this.showPopup = false;
        this.showCommentModal = true;
    }

    // Comment Modal
    handleCommentChange(e) { this.comment = e.target.value; }

    async handleFinalSubmit() {
        this.isLoading = true;
        try {
            await processAction({
                workItemId: this.workItemId,
                action: this.actionType,
                comments: this.comment
            });
            this.showToast('Success', `${this.actionType}ed successfully`, 'success');
            this.closeAll();
            await refreshApex(this.wiredHistory);
        } catch (err) {
            this.showToast('Error', err.body?.message || 'Failed', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleCommentCancel() { this.closeAll(); }

    closeAll() {
        this.showPopup = false;
        this.showCommentModal = false;
        this.comment = '';
    }

    showToast(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message: msg, variant }));
    }

    get showApproveButton() { return this.workItemId != null; }
}