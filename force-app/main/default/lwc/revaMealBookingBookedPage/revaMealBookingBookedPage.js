import { LightningElement, track, wire, api } from 'lwc';
import REVA_Hostel_Static_Resources from "@salesforce/resourceUrl/REVA_Hostel_Static_Resources";
import bookAndFetchMeals from "@salesforce/apex/RevaMealBookingController.bookAndFetchMeals";
import LightningConfirm from "lightning/confirm";
import updateMealStatus from "@salesforce/apex/RevaMealBookingController.updateMealStatus";
import hasStatusUpdated from '@salesforce/apex/RevaMealBookingController.hasStatusUpdated';
import hascheckUpdated from '@salesforce/apex/RevaMealBookingController.hascheckUpdated';
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import invalidStatus from '@salesforce/apex/RevaMealBookingController.invalidStatus';
import SuccessStatus from '@salesforce/apex/RevaMealBookingController.SuccessStatus';
import FailedStatus from '@salesforce/apex/RevaMealBookingController.FailedStatus';
import getServerDateTime from '@salesforce/apex/RevaMealBookingController.getServerDateTime';

export default class RevaMealBookingBookedPage extends LightningElement {
    showBanner = false;
    timeIcon;
    mealIcon;
    calendarIcon;
    @track bookedMeals = [];
    isBookedMealsopen = false;
    @track wiredData;
    @track currentTime;
    showQRModal = false;
    @track bookingIdSelected;
    @api isValied;
    bookedMealId;
    showFeedback;
    intervalId;
    isSpinner = false;

    @track noAvailedMealsMessage ='YOU HAVE NOT AVAILED ANY MEALS.';
    @track noBookedMealsMessage = 'YOU HAVE NOT BOOKED ANY MEALS YET. PLEASE GO TO THE MEALS TO BOOK TAB TO BOOK YOUR MEALS.';
    @track serverCurrentTime;

    connectedCallback() {
        this.fetchServerTime();
        this.startStatusCheck();
        this.calendarIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/calendar-icon.png";
        this.mealIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/meal-booking.png";
        this.timeIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/time-icon.png";
    }

    fetchServerTime() {
    getServerDateTime()
        .then(result => {
            console.log('result of server time:', result);

            // Remove Z so JS does NOT convert timezone
            const localDateString = result.replace('Z', '');

            this.currentTime = new Date(localDateString);

            console.log('Converted Date:', this.currentTime);
        })
        .catch(error => {
            console.error('Error fetching server time', error);
        });
}


    @wire(bookAndFetchMeals)
    wiredMealsData(result) {
        console.log('is ava  wire-->' + this.isValied);
        this.wiredData = result;
        if (result.data) {
            const currentTime = new Date();
            console.log("currentTime1", currentTime);

            if (!this.isValied) {
                this.bookedMeals = result.data.BookedMeals
                    .filter(meal => meal.Reva_Meal_Booking_Status__c === 'Booked' || meal.Reva_Meal_Booking_Status__c === 'Instant Meal' || meal.Reva_Meal_Booking_Status__c === 'Missed Meal' || meal.Reva_Meal_Booking_Status__c === 'Cancelled')
                    .map(meal => {
                        return {
                            ...meal,
                            isFeedbackAllowed: false,
                            isMealBookedPage: (meal.Reva_Meal_Booking_Status__c === 'Booked' || meal.Reva_Meal_Booking_Status__c === 'Instant Meal' || meal.Reva_Meal_Booking_Status__c === 'Missed Meal'),
                            isCancelButton: (meal.Reva_Meal_Booking_Status__c === 'Booked'),
                            isQrCodeButton: (meal.Reva_Meal_Booking_Status__c === 'Booked' || meal.Reva_Meal_Booking_Status__c === 'Instant Meal'),
                            messItemsList: meal.Reva_Mess_Menu__r.Mess_Items__c ? meal.Reva_Mess_Menu__r.Mess_Items__c.split(';') : [],
                            ImageURL: this.getMealImage(meal.Reva_Mess_Menu__r.Type__c)
                        };
                    });
                console.log('this.bookedMeals----' + JSON.stringify(this.bookedMeals));

            } else {
                this.bookedMeals = result.data.BookedMeals
                    .filter(meal => meal.Reva_Meal_Booking_Status__c === 'Availed')
                    .map(meal => {
                        const mealDate = meal.Reva_Mess_Menu__r.Date__c;
                        console.log("this.MealDate1", mealDate);
                        const mealEndTime = new Date(meal.Reva_Mess_Menu__r.End_Time__c);
                        console.log("mealEndTime1", mealEndTime);
                        const hours1 = Math.floor(mealEndTime / (1000 * 60 * 60));
                        const minutes1 = Math.floor((mealEndTime % (1000 * 60 * 60)) / (1000 * 60));
                        const seconds1 = Math.floor((mealEndTime % (1000 * 60)) / 1000);
                        const mealEndTimeMillis = `${String(hours1).padStart(2, '0')}:${String(minutes1).padStart(2, '0')}:${String(seconds1).padStart(2, '0')}`;
                        console.log("mealEndTime1", mealEndTimeMillis);
                        const mealEndDateTime = new Date(`${mealDate}T${mealEndTimeMillis}`);
                        console.log("mealEndDateTime1", mealEndDateTime);

                        const feedbackAllowed = (currentTime - mealEndDateTime) <= 24 * 60 * 60 * 1000;
                        return {
                            ...meal,
                            isFeedbackAllowed: (meal.Reva_Meal_Booking_Status__c === 'Availed' && feedbackAllowed),
                            isAvaliedMeal: (meal.Reva_Meal_Booking_Status__c === 'Availed'),
                            messItemsList: meal.Reva_Mess_Menu__r.Mess_Items__c ? meal.Reva_Mess_Menu__r.Mess_Items__c.split(';') : [],
                            ImageURL: this.getMealImage(meal.Reva_Mess_Menu__r.Type__c)
                        };
                    });
            }
            if (this.bookedMeals.length > 0) {
                this.isBookedMealsopen = true;
            } else {
                this.isBookedMealsopen = false;
            }

            console.log("Booked Meals Data1", JSON.stringify(this.bookedMeals));

        } else if (result.error) {
            console.error("Error when fetching meals data1  " + JSON.stringify(result.error));
        }
    }

    getMealImage(mealType) {
        switch (mealType) {
            case 'Dinner':
                return REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/dinner.avif";
            //return 'https://www.feastingathome.com/wp-content/uploads/2024/01/Moroccan-Chickpea-Bowl-4.jpg';
            case 'Snacks':
                return REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/snacks.jpg";
            //return 'https://www.shutterstock.com/shutterstock/photos/2159316021/display_1500/stock-photo-fried-samosas-with-vegetable-filling-popular-indian-snacks-on-wooden-board-2159316021.jpg';
            case 'Lunch':
                return REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/lunch.jpeg";
            // return 'https://traditionallymodernfood.com/wp-content/uploads/2022/01/south-indian-lunch-combo-cooking-for-guest-scaled.jpeg';
            case 'Breakfast':
                return REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/breakfast.jpg";
            // return 'https://media-cdn.tripadvisor.com/media/photo-s/12/85/12/66/tiffin-items.jpg'; // Updated Breakfast Image
            default:
                return 'https://via.placeholder.com/150'; // Default image if Type__c is unknown
        }
    }

    async handleMealSelection(event) {
        let recordId = event.target.dataset.mealId;
        console.log("MEAL ID--------------5 " + recordId);
        console.log("this.wiredData5", this.wiredData);

        const bookedMealDetails = this.wiredData.data.BookedMeals.find(meal => meal.Id === recordId);
        // if (bookedMealDetails && bookedMealDetails.Reva_Meal_Booking_Status__c === 'Booked'){
        if (bookedMealDetails) {
            const mealStartTimeMillis = bookedMealDetails.Reva_Mess_Menu__r.Start_Time__c;
            console.log("this.MealStartTime5", mealStartTimeMillis);
            const mealDate = bookedMealDetails.Reva_Mess_Menu__r.Date__c;
            console.log("this.MealDate5", mealDate);
            const hours = Math.floor(mealStartTimeMillis / (1000 * 60 * 60));
            const minutes = Math.floor((mealStartTimeMillis % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((mealStartTimeMillis % (1000 * 60)) / 1000);

            const mealStartTime = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
            console.log("Formatted MealStartTime5", mealStartTime);
            const mealStartDateTime = new Date(`${mealDate}T${mealStartTime}`);
            console.log("mealStartDateTime5", mealStartDateTime);
            // this.currentTime = new Date();
            console.log("currentTime5", this.currentTime);
            const sixHoursBeforeMealStart = new Date(mealStartDateTime);
            sixHoursBeforeMealStart.setHours(sixHoursBeforeMealStart.getHours() - 6);
            console.log("sixHoursBeforeMealStart5", sixHoursBeforeMealStart);
           
           const currentTimeMs = this.currentTime.getTime();
            const sixHoursBeforeMs = sixHoursBeforeMealStart.getTime();

            console.log('currentTimeMs', currentTimeMs);
            console.log('sixHoursBeforeMs', sixHoursBeforeMs);
            console.log('diff minutes', (sixHoursBeforeMs - currentTimeMs) / 60000);



            if (this.currentTime < mealStartDateTime && this.currentTime < sixHoursBeforeMealStart) {
                console.log("checkin", this.currentTime < mealStartDateTime && this.currentTime < sixHoursBeforeMealStart);
                const result = await LightningConfirm.open({
                    message: "Are you sure you want to cancel this meal?",
                    variant: "headerless",
                    label: "Cancel",
                    header: "Cancel Confirmation",
                    type: "success"
                });

                if (result) {
                    console.log("MEAL ID1-------------- 51" + recordId);
                    this.cancelMeal(recordId);

                }
            } else {
                this.showToast("Meal Cannot be cancelled as it's less than 6 hours before meal start time", "", "error");
                console.log("Meal cannot be cancelled as it's less than 6 hours before meal start time");
            }
        } else {
            console.error("Meal not found with ID:", recordId);

        }
    }
    cancelMeal(recordId) {
        this.isSpinner = true;
        updateMealStatus({ recordId: recordId, status: "Cancelled" })
            .then((result) => {
                if (result.startsWith('Success:')) {
                    this.showToast('Success', 'Your meal has been successfully cancelled.', 'success');
                } else if (result.startsWith('Error:')) {
                    this.showToast("Error", 'Meal booking not found.', "error");
                } 
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.isSpinner = false;
                    return refreshApex(this.wiredData); // Ensure refresh is awaited
                }, 300); 
            })
            .catch((error) => {
                console.error("Error when updating " + JSON.stringify(error));
                this.isSpinner = false;
                this.showToast("Error", error.body.message, "error");
            });
    }

    handleShowQRCode(event) {
        event.stopPropagation();
        const mealId = event.target.dataset.mealId;
        const selectedMeal = this.bookedMeals.find(meal => meal.Id === mealId);
        console.log("selectedMeal-qrcode", selectedMeal);
        if (selectedMeal) {
            const mealTiming = selectedMeal.Reva_Mess_Menu__r.Start_Time__c;
           
            console.log("mealStartTime",  mealTiming);
            
            const mealDate = selectedMeal.Reva_Mess_Menu__r.Date__c;

            console.log("MealDate", mealDate);
            const hours = Math.floor(mealTiming / (1000 * 60 * 60));
            const minutes = Math.floor((mealTiming % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((mealTiming % (1000 * 60)) / 1000);
            const mealStartTime = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
            console.log("Formatted MealStartTime4", mealStartTime);
            const mealStartDateTime = new Date(`${mealDate}T${mealStartTime}`);
            console.log("mealStartDateTime4", mealStartDateTime);

            const mealEndTime = selectedMeal.Reva_Mess_Menu__r.End_Time__c;
            console.log("mealEndDate4", mealEndTime);
            const hours1 = Math.floor(mealEndTime / (1000 * 60 * 60));
            const minutes1 = Math.floor((mealEndTime % (1000 * 60 * 60)) / (1000 * 60));
            const seconds1 = Math.floor((mealEndTime % (1000 * 60)) / 1000);
            const mealEndTimeMillis = `${String(hours1).padStart(2, '0')}:${String(minutes1).padStart(2, '0')}:${String(seconds1).padStart(2, '0')}`;
            console.log("mealEndTime4", mealEndTimeMillis);
            const mealEndDateTime = new Date(`${mealDate}T${mealEndTimeMillis}`);
            console.log("mealEndDateTime4", mealEndDateTime);

            console.log('currentime from server time----',this.currentTime);
            const tenMinutesBeforeStart = (mealStartDateTime - 10 * 60 * 1000);
            console.log("tenMinutesBeforeStart4", tenMinutesBeforeStart);

            if (this.currentTime >= tenMinutesBeforeStart && this.currentTime <= mealEndDateTime) {
                this.bookingIdSelected = mealId;
                this.showQRModal = true;
                console.log('Iiiddddddddddd' + this.bookingIdSelected);
            }
            else {
                this.showToast('', 'QR code will be available during scheduled meal time', 'error');
            }
        } else {
            this.showToast('', 'Meal details not found.', 'error');
        }
    }

    closeQRCodeModal() {
        this.showQRModal = false;
        console.log("QR modal closed");
   
         this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message: 'Your meal status is availed. Enjoy your meal!',
            variant: 'success'
        })
    );
    this.SuccessStatus(this.bookingIdSelected);
        return refreshApex(this.wiredData);
    }


 closeQRCodeModalbutton(){
     this.showQRModal = false;
        console.log("QR modal closed");
        this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: 'Sorry! Your scan has failed. Please try again.',
            variant: 'error'
        })
    );
    this.FailedStatus(this.bookingIdSelected);
         return refreshApex(this.wiredData);
 }
closeQRCodeModalIcon(){
     this.showQRModal = false;
         return refreshApex(this.wiredData);
 }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    disconnectedCallback() {
        this.stopStatusCheck();
    }

    startStatusCheck() {
        // Check status every 5 seconds
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.intervalId = setInterval(() => {
            this.checkStatusUpdate();
            this.checkCheckStatusUpdate();
        }, 1000);
    }

    stopStatusCheck() {
        clearInterval(this.intervalId);
    }

    checkStatusUpdate() {
        
        hasStatusUpdated({ mealBookingId: this.bookingIdSelected })
            .then((statusUpdated) => {
               // console.log('Hello::' + statusUpdated);
                if (statusUpdated) {
                    this.closeQRCodeModal();
                    this.stopStatusCheck(); // Stop checking once the modal is closed
                }
            })
            .catch((error) => {
                console.error('Error checking status update:', error);
            });
    }

 checkCheckStatusUpdate() {

    hascheckUpdated({ mealBookingId: this.bookingIdSelected })
        .then((checkUpdated) => {
           // console.log('Check Updated:', checkUpdated);
            if (checkUpdated) {

                this.closeQRCodeModalbutton();
                //this.stopStatusCheck();
                this.invalidStatus(this.bookingIdSelected);
            }
        })
        .catch((error) => {
            console.error('Error checking check status update:', error);
        });
}
invalidStatus(recordId) {
        invalidStatus({ recordId: recordId ,status: "Success"})
            .then((result) => {
               // this.showSuccess('Success', 'Your QR Code Scanned Successfully.');
             console.log('Success');
            })
            .catch((error) => {
               
            });
    }
  
  SuccessStatus(recordId) {
        SuccessStatus({ recordId: recordId ,status: "QrSuccess"})
            .then((result) => {
               // this.showSuccess('Success', 'Your QR Code Scanned Successfully.');
             console.log('Success');
            })
            .catch((error) => {
               
            });
    }
  
  FailedStatus(recordId) {
        FailedStatus({ recordId: recordId ,status: "QrFailed"})
            .then((result) => {
               // this.showSuccess('Success', 'Your QR Code Scanned Successfully.');
             console.log('Success');
            })
            .catch((error) => {
               
            });
    }
  

    handleFeedback(event) {
        const mealId = event.target.dataset.mealId;
        const selectedMeal = this.bookedMeals.find(meal => meal.Id === mealId);
        console.log("selectedMeal2", selectedMeal);
        if (selectedMeal && selectedMeal.isFeedbackAllowed) {
            this.bookedMealId = mealId;
            this.showFeedback = true;
            console.log("2", this.bookedMealId);
        } else {
            this.showToast("Feedback not allowed", "Feedback can only be given for availed meals", "error");
        }
    }
    handleModalClose() {
        this.showFeedback = false;
    }
    handleFeedbackSave() {
        this.showFeedback = false;
        return refreshApex(this.wiredData);
    }
}