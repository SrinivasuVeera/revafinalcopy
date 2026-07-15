import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitSurvey from '@salesforce/apex/CaseSurveyController.submitSurvey';
import hasSurvey from '@salesforce/apex/CaseSurveyController.hasSurvey';
import getSurveyQuestions from '@salesforce/apex/CaseSurveyController.getSurveyQuestions';
import STATUS_FIELD from '@salesforce/schema/Branding_Case__c.Status__c';
import { CurrentPageReference } from 'lightning/navigation';

export default class BrandingCaseSurvey extends LightningElement {
    @api recordId; // Case Id passed from the record page
    recordId;
    questions = [];
    responses = [];
    showSurvey = false;
    surveyExists = false;
    caseStatus = null;
    noQuestions = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
            console.log('Record ID:', this.recordId);
        }
    }

    // Wire to get Case record data
    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    caseRecord({ error, data }) {
        if (data) {
            console.log('caseRecord: caseStatus = ', getFieldValue(data, STATUS_FIELD));
            this.caseStatus = getFieldValue(data, STATUS_FIELD);
            this.checkSurveyExistence();
        } else if (error) {
            console.error('caseRecord error: ', JSON.stringify(error));
            this.showToast('Error', 'Error loading case data: ' + (error.body?.message || error.message), 'error');
        }
    }

    // Wire to get survey questions
    @wire(getSurveyQuestions)
    wiredQuestions({ error, data }) {
        if (data) {
            console.log('wiredQuestions: ', JSON.stringify(data));
            this.noQuestions = data.length === 0;
            this.questions = data.map(question => ({
                id: question.Id,
                questionText: question.Question__c,
                rating: 0,
                feedback: ''
            }));
            this.responses = this.questions.map(q => ({
                questionId: q.id,
                rating: 0,
                feedback: ''
            }));
            this.updateShowSurvey();
        } else if (error) {
            console.error('wiredQuestions error: ', JSON.stringify(error));
            this.noQuestions = true;
            this.showToast('Error', 'Error loading survey questions: ' + (error.body?.message || error.message), 'error');
            this.updateShowSurvey();
        }
    }

    // Imperatively check if survey exists
    async checkSurveyExistence() {
        try {
            console.log('checkSurveyExistence: caseId = ', this.recordId);
            const result = await hasSurvey({ caseId: this.recordId });
            console.log('checkSurveyExistence: surveyExists = ', result);
            this.surveyExists = result;
            this.updateShowSurvey();
        } catch (error) {
            console.error('checkSurveyExistence error: ', JSON.stringify(error));
            this.showToast('Error', 'Error checking survey existence: ' + (error.body?.message || error.message), 'error');
            this.surveyExists = true; // Hide survey on error
            this.updateShowSurvey();
        }
    }

    // Determine if survey should be shown
    updateShowSurvey() {
        this.showSurvey = this.caseStatus === 'Closed' && !this.surveyExists && !this.noQuestions;
        console.log('updateShowSurvey: caseStatus = ', this.caseStatus, ', surveyExists = ', this.surveyExists, ', noQuestions = ', this.noQuestions, ', showSurvey = ', this.showSurvey);
    }

    // Define stars for rating (1 to 5)
    get stars() {
        return [1, 2, 3, 4, 5];
    }

    // Handle star rating selection
    handleRating(event) {
        const questionId = event.target.dataset.questionId;
        const rating = parseInt(event.target.dataset.value, 10);
        console.log('handleRating: questionId = ', questionId, ', rating = ', rating);
        this.responses = this.responses.map(resp => 
            resp.questionId === questionId ? { ...resp, rating } : resp
        );
        const stars = this.template.querySelectorAll(`.star[data-question-id="${questionId}"]`);
        stars.forEach(star => {
            star.classList.remove('selected');
            if (parseInt(star.dataset.value, 10) <= rating) {
                star.classList.add('selected');
            }
        });
    }

    // Handle feedback text input
    handleFeedbackChange(event) {
        const questionId = event.target.dataset.questionId;
        const feedback = event.target.value;
        console.log('handleFeedbackChange: questionId = ', questionId, ', feedback = ', feedback);
        this.responses = this.responses.map(resp => 
            resp.questionId === questionId ? { ...resp, feedback } : resp
        );
    }

    // Submit survey
    async handleSubmit() {
        // Validate all questions have rating and feedback
        const invalidResponses = this.responses.some(resp => resp.rating === 0 || !resp.feedback.trim());
        if (invalidResponses) {
            this.showToast('Error', 'Please provide a rating and feedback for all questions.', 'error');
            console.log('handleSubmit: Validation failed, responses = ', JSON.stringify(this.responses));
            return;
        }

        try {
            console.log('handleSubmit: Submitting survey for caseId = ', this.recordId, ', responses = ', JSON.stringify(this.responses));
            await submitSurvey({
                caseId: this.recordId,
                responses: this.responses
            });
            this.showToast('Success', 'Survey submitted successfully', 'success');
            this.responses = this.responses.map(resp => ({
                questionId: resp.questionId,
                rating: 0,
                feedback: ''
            }));
            this.surveyExists = true;
            this.showSurvey = false;
            this.template.querySelectorAll('.star').forEach(star => star.classList.remove('selected'));
            this.template.querySelectorAll('lightning-textarea').forEach(textarea => textarea.value = '');
            console.log('handleSubmit: Initiating page refresh');
            window.location.reload();
        } catch (error) {
            console.error('handleSubmit error: ', JSON.stringify(error));
            this.showToast('Error', 'Error submitting survey: ' + (error.body?.message || error.message), 'error');
        }
    }

    // Utility to show toast messages
    showToast(title, message, variant) {
        console.log('showToast: ', title, message, variant);
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
}