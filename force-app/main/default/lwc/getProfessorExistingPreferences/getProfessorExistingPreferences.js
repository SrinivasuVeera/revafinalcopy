import { LightningElement, track } from 'lwc';
import getExistingPrefCollection from '@salesforce/apex/GetProfessorExistingPreferencesCtrl.getExistingPrefCollection';
import freezeProPreference from '@salesforce/apex/GetProfessorExistingPreferencesCtrl.freezeProPreference';
import updatePreferences from '@salesforce/apex/GetProfessorExistingPreferencesCtrl.updatePreferences';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GetProfessorExistingPreferences extends LightningElement {
    @track courseData = [];
    @track showConfirmModal = false;
    @track showPreferenceError = false;
    @track theoryErrorMessage;
    @track practicalErrorMessage;
    @track coursePreferenceData = [];
    @track isLoading = false;
    @track isFreezingAllowed = false;
    @track requiredOptions ;
    @track isEditMode = false;
    @track originalCourseData = [];
    @track maxTheory = 0;
    @track maxPractical = 0;

    preferenceOptions = [
    { label: 'Preference - 1', value: '1' },
    { label: 'Preference - 2', value: '2' },
    { label: 'Preference - 3', value: '3' },
    { label: 'Preference - 4', value: '4' },
    { label: 'Preference - 5', value: '5' },
    { label: 'Preference - 6', value: '6' }
];

    // Disable freeze if preferences are invalid
    get isDisableFreeze() {
        return this.hasInvalidPreferences();
    }

    get theoryCourses() {
        return this.courseData.filter(row => row.subtype === 'Theory' && row.preference > 0);
    }

    get practicalCourses() {
        return this.courseData.filter(row => row.subtype !== 'Theory' && row.preference > 0 );
    }

    get hasTheoryCourses() {
        return this.theoryCourses.length > 0;
    }

    get hasPracticalCourses() {
        return this.practicalCourses.length > 0;
    }

    connectedCallback() {
        this.getProfessorExistingPreferences();
    }

    getProfessorExistingPreferences() {
        getExistingPrefCollection()
            .then(result => {
                if (result && result.preferences && result.preferences.length > 0) {
                    this.coursePreferenceData = result.preferences;
                }

                if (result && result.isAllowFreezing) {
                    this.isFreezingAllowed = result.isAllowFreezing;
                }
                if (result && result.requiredOptions != 'Allow') {
                    this.requiredOptions = result.requiredOptions
                }
                this.maxTheory = result.maxTheory || 0;
                this.maxPractical = result.maxPractical || 0;


                const data = result.preferences.map((course, index) => ({
                    ...course,
                    id: index + 1,
                    recordId: course.Id,
                    OfferedByschool: course.Course_Offering__r?.Offered_By_School__r?.Name || '',
                    schoolName: course.Course_Offering__r?.School__c || '',
                    program: course.Semester__r?.hed__Account__r?.Name || '',
                    programBatch: course.Semester__r?.Program_Batch__r?.Name || '',
                    semester: course.Semester__r?.Name || '',
                    semesterId: course.Semester__c || '',
                    courseName: course.Course_Offering__r?.hed__Course__r?.Name || '',
                    courseId: course.Course_ID__c || '',
                    category: course.Course_Offering__r?.hed__Course__r?.Category__c || '',
                    subtype: course.Course_Offering__r?.hed__Course__r?.HardCore_Sub_Type__c || '',
                    preference: course.Preference__c,
                    originalPreference: course.Preference__c,
                    isPreferenceOne: course.Preference__c === '1' || course.Preference__c === 'Preference - 1',
                    freezed: course.Professor_Preference__c,
                }));

                this.courseData = data.sort((a, b) => a.preference - b.preference);
                this.originalCourseData = JSON.parse(JSON.stringify(this.courseData));

                if (this.courseData) {
                    this.dispatchEvent(
                        new CustomEvent('coursedata', {
                            detail: { data: this.courseData }
                        })
                    );
                }

                // Check for preference gaps
                this.validatePreferences();
            })
            .catch(error => {
                console.log('Error fetching preferences:', error);
            });
    }
    handleEdit() {
    this.isEditMode = true;
    }
    handleCancel() {

    this.courseData =
        JSON.parse(JSON.stringify(this.originalCourseData));

    this.isEditMode = false;

    this.validatePreferences();
}
    handlePreferenceChange(event) {
    const recordId = event.target.dataset.id;
    const value = event.target.value;

    // Update UI data
    this.courseData = this.courseData.map(row => {
        if (row.recordId === recordId) {
            return {
                ...row,
                preference: value
            };
        }
        return row;
    });

    // Update Apex payload data
    this.coursePreferenceData = this.coursePreferenceData.map(row => {
        if (row.Id === recordId) {
            return {
                ...row,
                Preference__c: value
            };
        }
        return row;
    });

    this.validatePreferences();
    }
    getChangedPreferences() {
    return this.courseData
        .filter(row => String(row.preference) !== String(row.originalPreference))
        .map(row => ({
            Id: row.recordId,
            Preference__c: String(row.preference)
        }));
    }

    handleFreeze() {
        this.validatePreferences();
        if (!this.isDisableFreeze) {
            this.showConfirmModal = true;
        }
    }

   handleYes() {
    if (this.isFreezingAllowed == false) {
        this.showConfirmModal = false;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'You must select at least ' + this.requiredOptions + ' preferences across all schools/semesters.',
                variant: 'error'
            })
        );
        return;
    }

    this.showConfirmModal = false;
    this.freezePreference();
}   
    handleNo() {
        this.showConfirmModal = false;
    }
    handleSavePreferences() {

    const theoryPrefs = this.theoryCourses
    .map(r => r.preference)
    .filter(p => p);

    const practicalPrefs = this.practicalCourses
        .map(r => r.preference)
        .filter(p => p);

    const theoryDuplicate =
        theoryPrefs.length !== new Set(theoryPrefs).size;

    const practicalDuplicate =
        practicalPrefs.length !== new Set(practicalPrefs).size;

    if (theoryDuplicate || practicalDuplicate) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Duplicate preferences are not allowed within Theory or Practical.',
                variant: 'error'
            })
        );

        return;
    }

    const changedRecords = this.getChangedPreferences();

    if (changedRecords.length === 0) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Info',
                message: 'No preference changes found.',
                variant: 'info'
            })
        );

        this.isEditMode = false;
        return;
    }

    this.isLoading = true;

    updatePreferences({
        updatedPreferences: changedRecords
    })
    .then(() => {

        this.courseData = this.courseData.map(row => ({
            ...row,
            originalPreference: row.preference
        }));

        this.originalCourseData = JSON.parse(JSON.stringify(this.courseData));

        this.isEditMode = false;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Preferences updated successfully.',
                variant: 'success'
            })
        );

        this.isLoading = false;
    })
    .catch(error => {
    console.log('Save Error => ', JSON.stringify(error));

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: error.body?.message || error.message || JSON.stringify(error),
            variant: 'error'
        })
    );
});
}

    validatePreferences() {
        this.showPreferenceError = false;
        this.theoryErrorMessage = '';
        this.practicalErrorMessage = '';

        const theoryMissing = this.findMissingPreferences(this.theoryCourses);
        const practicalMissing = this.findMissingPreferences(this.practicalCourses);

        if (this.maxTheory > 0 && this.theoryCourses.length < this.maxTheory) {
            this.showPreferenceError = true;

            this.theoryErrorMessage =
                `Minimum ${this.maxTheory} Theory preferences are required.`;
        }

        if (this.maxPractical > 0 && this.practicalCourses.length < this.maxPractical) {
            this.showPreferenceError = true;

            this.practicalErrorMessage =
                `Minimum ${this.maxPractical} Practical preferences are required.`;
        }

        if ((theoryMissing.length > 0 || practicalMissing.length > 0) && !this.courseData.some(row => row.freezed === true)) {
            this.showPreferenceError = true;

            if (theoryMissing.length > 0) {
                this.theoryErrorMessage = `You have missed selecting Preference(s): '${theoryMissing.join(', ')}' for Theory.`;
            }

            if (practicalMissing.length > 0) {
                this.practicalErrorMessage = `You have missed selecting Preference(s): '${practicalMissing.join(', ')}' for Practical/Project.`;
            }
        }
    }

    hasInvalidPreferences() {
        const theoryMissing = this.findMissingPreferences(this.theoryCourses);
        const practicalMissing = this.findMissingPreferences(this.practicalCourses);
        const insufficientTheory = this.maxTheory > 0 && this.theoryCourses.length < this.maxTheory;
        const insufficientPractical = this.maxPractical > 0 && this.practicalCourses.length < this.maxPractical;

        return (
            insufficientTheory || insufficientPractical || (theoryMissing.length > 0 && !(theoryMissing.length === 1 && theoryMissing[0] === 1)) ||
            (practicalMissing.length > 0 && !(practicalMissing.length === 1 && practicalMissing[0] === 1)) ||
            this.courseData.some(row => row.freezed === true) ||
            this.courseData.length <= 0
        );
    }

    findMissingPreferences(courseList) {
        const preferences = courseList
            .map(c => parseInt(c.preference, 10))
            .filter(p => !isNaN(p));

        if (preferences.length === 0) return [];

        preferences.sort((a, b) => a - b);
        const max = preferences[preferences.length - 1];
        const missing = [];

        for (let i = 1; i <= max; i++) {
            if (!preferences.includes(i)) {
                missing.push(i);
            }
        }

        return missing;
    }

    freezePreference() {
        this.isLoading = true;
        freezeProPreference({ savedProPreference: this.coursePreferenceData })
            .then(resultMessage => {
                let variant = 'success';

                if (
                    resultMessage.includes('No preferences') ||
                    resultMessage.includes('No eligible preferences') ||
                    resultMessage.includes('Error') ||
                    resultMessage.includes('Unexpected')
                ) {
                    variant = 'error';
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: variant === 'success' ? 'Success' : 'Error',
                        message: resultMessage,
                        variant: variant
                    })
                );

                if (variant === 'success') {
                    setTimeout(() => {
                        window.location.reload();
                    }, 2000);
                }

                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'An error occurred while freezing preferences: ' + error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}