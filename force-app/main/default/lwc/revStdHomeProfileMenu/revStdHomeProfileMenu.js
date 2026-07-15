import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
import STUDENTPORTALICONS from '@salesforce/resourceUrl/SR_STUDENTPORTALASSETS';
import getAttendancePercent from '@salesforce/apex/ATT_StudentAttendance_Ctrl.DisplayAttendance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const CONTACT_FIELDS = ['Contact.File_Passport_Size_Photo__c', 'Contact.hed__Gender__c', 'Contact.Name', 'Contact.MailingStreet', 'Contact.MailingCity', 'Contact.MailingState', 'Contact.MailingCountry', 'Contact.MailingPostalCode', 'Contact.Application_Number__c', 'Contact.SRN_Number__c', 'Contact.MobilePhone', 'Contact.School_Name__c', 'Contact.Active_Section__c	', 'Contact.Program_Batch_Name__c', 'Contact.Date_of_Admission_in_Institute__c', 'Contact.Admission_Mode__c', 'Contact.Enrollment_Type__c', 'Contact.Student_Status__c', 'Contact.Birthdate', 'Contact.Email',];
const SEMESTER_FIELDS = ['hed__Term__c.Name'];
const DATE_OPTIONS = { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' };
const baseImageUrl = `${STUDENTPORTALICONS}/StudentPortalAssests/Icons/Profile-Menu-Icons/`;

export default class RevStdHomeProfileMenu extends NavigationMixin(LightningElement) {

	currentDate;
	showMainMenuSection = true;
	showProfileSection = false;
	circumference = 2 * Math.PI * 15; // 2 * π * radius

	userContactId;
	contactRecord;
	activeSemesterId;
	activeSemesterRecord;


	showButtonIconUrl = `${baseImageUrl}show.png`;
	hideButtonIconUrl = `${baseImageUrl}hide.png`;

	@track totalClassesCompleted = 0;
	@track totalClassesAttended = 0;
	@track totalAttendancePercentage;

	connectedCallback() {
		this.currentDate = this.formattedCurrentDate();

	}
	/**
	 * Computes the current date and returns it in a user-friendly format.
	 * @returns {string} Formatted current date.
	 */
	formattedCurrentDate() {
		const now = new Date();
		const parts = new Intl.DateTimeFormat('en-US', DATE_OPTIONS).formatToParts(now);
		const day = parts.find(part => part.type === 'day').value;
		const month = parts.find(part => part.type === 'month').value;
		const year = parts.find(part => part.type === 'year').value;
		const weekday = parts.find(part => part.type === 'weekday').value;

		return `${weekday}, ${day} ${month}, ${year}`;
	}


	@wire(getRecord, { recordId: USER_ID, fields: CONTACT_ID_FIELD })
	wiredUser({ error, data }) {
		if (data) {
			this.userContactId = getFieldValue(data, CONTACT_ID_FIELD);

		} else if (error) {
			this.showErrorToast(error.body.message);

		}
	}

	// Retrieve the Contact record based on the ContactId retrieved from the User record
	@wire(getRecord, { recordId: '$userContactId', fields: CONTACT_FIELDS })
	wiredContactRecord({ error, data }) {
		if (data) {
			this.contactRecord = data;
			this.activeSemesterId = getFieldValue(this.contactRecord, 'Contact.Active_Section__c') || 'N/A';

		} else if (error) {
			this.showErrorToast(error.body.message);

		}
	}


	@wire(getRecord, { recordId: "$activeSemesterId", fields: SEMESTER_FIELDS })
	wiredActiveSection({ error, data }) {
		if (error) {
			this.showErrorToast(error.body.message);
		} else if (data) {
			this.activeSemesterRecord = data;

		}
	}

	get calculatePercentage() {
		if (this.totalClassesCompleted > 0) {
			const percentage = (this.totalClassesAttended / this.totalClassesCompleted) * 100;
			return Math.floor(percentage);
		}
		return 0;
	}
	get determineAttendanceCategory() {
		if (this.totalAttendancePercentage >= 90) {
			return 'Excellent';
		} else if (this.totalAttendancePercentage >= 75) {
			return 'Good';
		} else if (this.totalAttendancePercentage >= 50) {
			return 'Average';
		} else {
			return 'Below Average';
		}
	}

	handleProfileSection() {
		this.getAttendenceData();
		this.showMainMenuSection = false;
		this.showProfileSection = true;

	}
	getAttendenceData() {
		getAttendancePercent()
			.then(data => {
				let classCompleted = 0;
				let classAttended = 0;
				if (data.map_Faculty) {
					Object.keys(data.map_Faculty).forEach(key => {
						const facultyValue = data.map_Faculty[key];
						classCompleted += facultyValue.TotalClassCom || 0;
						classAttended += facultyValue.TotalClassAtt || 0;
					});
				}
				this.totalClassesCompleted = classCompleted;
				this.totalClassesAttended = classAttended;
				this.totalAttendancePercentage = this.calculatePercentage; //getter Method
			})
			.catch(error => {

				this.showErrorToast(error.body.message);
			});
	}
	handleMenuSection() {
		this.showProfileSection = false;
		this.showMainMenuSection = true;
	}
	get strokeOffset() {
		return this.circumference * (1 - (this.totalAttendancePercentage / 100));
	}

	//Getters
	get userIconUrl() {
		const passPortPhotoUrl = getFieldValue(this.contactRecord, 'Contact.File_Passport_Size_Photo__c');
		const genderValue = getFieldValue(this.contactRecord, 'Contact.hed__Gender__c');
		if (passPortPhotoUrl) {
			return passPortPhotoUrl;
		} else {
			// If passport photo is null or empty, check gender and assign default icon
			if (genderValue && genderValue.toLowerCase() === 'male') {
				return `${baseImageUrl}male.png`;
			}
			return `${baseImageUrl}female.png`;

		}

	}
	get name() {
		return this.capitalizeFirstLetterOfEachWord(getFieldValue(this.contactRecord, 'Contact.Name'));
	}

	get mailingStreet() {
		return this.capitalizeFirstLetterOfEachWord(getFieldValue(this.contactRecord, 'Contact.MailingStreet'));
	}

	get mailingCity() {
		return this.capitalizeFirstLetterOfEachWord(getFieldValue(this.contactRecord, 'Contact.MailingCity'));
	}

	get mailingState() {
		return this.capitalizeFirstLetterOfEachWord(getFieldValue(this.contactRecord, 'Contact.MailingState'));
	}

	get mailingCountry() {
		const countryValue = getFieldValue(this.contactRecord, 'Contact.MailingCountry');
		return this.capitalizeFirstLetter(countryValue);
	}

	get mailingPostalCode() {
		return getFieldValue(this.contactRecord, 'Contact.MailingPostalCode') || 'N/A';
	}


	get applicationNumber() {
		return getFieldValue(this.contactRecord, 'Contact.Application_Number__c') || 'N/A';
	}
	get srnNumber() {
		return getFieldValue(this.contactRecord, 'Contact.SRN_Number__c') || 'N/A';
	}

	get mobilePhone() {
		return getFieldValue(this.contactRecord, 'Contact.MobilePhone') || 'N/A';
	}

	get schoolName() {
		return getFieldValue(this.contactRecord, 'Contact.School_Name__c') || 'N/A';
	}

	get programName() {
		return getFieldValue(this.contactRecord, 'Contact.Program_Batch_Name__c') || 'N/A';
	}
	get semesterName() {
		return getFieldValue(this.activeSemesterRecord, 'hed__Term__c.Name') || 'N/A';
	}

	get admissionDate() {
		return getFieldValue(this.contactRecord, 'Contact.Date_of_Admission_in_Institute__c') || 'N/A';
	}
	get admiossionMode() {
		return getFieldValue(this.contactRecord, 'Contact.Admission_Mode__c') || 'N/A';
	}
	//get personalEmail(){
	//	return getFieldValue(this.contactRecord, 'Contact.Personal_Email__c') || 'N/A';
	//}
		
		
	get status() {
		return getFieldValue(this.contactRecord, 'Contact.Student_Status__c') || 'N/A';
	}

	get birthdate() {
		return getFieldValue(this.contactRecord, 'Contact.Birthdate') || 'N/A';
	}

	get email() {
		const emailValue = getFieldValue(this.contactRecord, 'Contact.Email');
		return emailValue ? emailValue.toLowerCase() : 'N/A';
	}
      get enrollmentType() {
		return getFieldValue(this.contactRecord, 'Contact.Enrollment_Type__c') || 'N/A';
	}



	// Helper method to capitalize the first letter of each word in a string
	capitalizeFirstLetterOfEachWord(value) {
		// Check if the value is null or undefined, return 'N/A'
		if (value === null || value === undefined) {
			return 'N/A';
		}

		const stringValue = typeof value === 'string' ? value : String(value);
		return stringValue
			.split(' ')
			.map(word => word ? word.charAt(0).toUpperCase() + word.slice(1).toLowerCase() : '')
			.join(' ');
	}
	// Helper method to capitalize the first letter of a value and ensure the rest are lowercase
	capitalizeFirstLetter(value) {
		// If the value is null or undefined, return 'N/A'
		if (value === null || value === undefined) {
			return 'N/A';
		}
		const stringValue = typeof value === 'string' ? value : String(value);
		return stringValue.charAt(0).toUpperCase() + stringValue.slice(1).toLowerCase();
	}


	//Error Notification
	showErrorToast(errorMessage) {

		const event = new ShowToastEvent({
			title: 'Error',
			message: errorMessage,
			variant: 'error',
			mode: 'dismissable'
		});
		this.dispatchEvent(event);
	}
}