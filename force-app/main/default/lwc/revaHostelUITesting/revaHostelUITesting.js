import { LightningElement, track, wire, api } from "lwc";
import bookAndFetchMeals from "@salesforce/apex/RevaMealBookingController.bookAndFetchMeals";
import REVA_Hostel_Static_Resources from "@salesforce/resourceUrl/REVA_Hostel_Static_Resources";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";
import instantMealBooking from '@salesforce/apex/RevaMealBookingController.instantMealBooking';
import hasStatusUpdated from '@salesforce/apex/RevaMealBookingController.hasStatusUpdated';

//for staff penalty 
import isNotStudentRecordType from '@salesforce/apex/RevaMealBookingController.isNotStudentRecordType';
import getMessPenaltyUrl from '@salesforce/apex/RevaMealBookingController.getMessPenaltyUrl';
////////////////////////////////////////
import updateMealStatus from "@salesforce/apex/RevaMealBookingController.updateMealStatus";
import getMessMenuItems from "@salesforce/apex/RevaMealBookingController.getMessMenuItems";
import callBookMeal from "@salesforce/apex/RevaMealBookingController.bookMeal";
import ifUserOnLeave from "@salesforce/apex/RevaMealBookingController.ifUserOnLeave";
////////////////////////////////////////
import missedMealsByTheUser from '@salesforce/apex/RevaMealBookingController.missedMealsByTheUser';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID_FIELD from '@salesforce/schema/User.ContactId';
import { NavigationMixin } from 'lightning/navigation';
import getMissedMealCount from '@salesforce/apex/RevaMealBookingController.getMissedMealCount';

//import NUMBER_OF_DAYS_FIELD from '@salesforce/schema/Student_Fee__c.No_of_Days_Due__c';
// import checkActivePenaltiesForTheUser from '@salesforce/apex/RevaMealBookingController.checkActivePenaltiesForTheUser';
import Id from '@salesforce/user/Id'; // Get the logged-in user's ID
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name'; 
export default class RevaHostelUITesting  extends NavigationMixin (LightningElement) {
    strBannerMessage = '';
    dynamicId;
    tickIcon;
    calendarIcon;
    mealIcon;
    timeIcon;
    cancelIcon;
    feedbackIcon;
    wiredData;
    bookedMealId;
    showFeedback;
    isSpinner;
    showMessMenuItems;
    isMessMenuItemsAvailable;
    @track messMenuItems = [];
    @track bookedMeals = [];
    @track mealsToBook = [];
    startTimeAndDate;
    @track isSuccess = false;
    currentTime;
    fetchDate;
    isAfterNinePM = false;
    showQRModal = false;
    bookingIdSelected;
    disableBookMeal = true;
    meals2bookId;
    contactId;
    isInstantButtonDisabled;
    showInstantMealBooking;
    @track instantMealBookingMeal = {};
    wiredResult;
    isNonteachingOrProfessor =false;
    @track missedMealCount = 0;
    @track error;
/*************************************19102024 by veera********************************* */
    userId = Id;
    profileName;
    showBackButton = true;
 @wire(getRecord, { recordId: '$userId', fields: [PROFILE_NAME_FIELD] })
    userHandler({ error, data }) {
        if (data) {
            // If data is received, store the profile name
            this.profileName = data.fields.Profile.displayValue || data.fields.Profile.value;
            if (this.profileName === 'Student Profile' || this.profileName === 'Student Portal Profile') {
                this.showBackButton = false;
            }
        } else if (error) {
            // Handle any error that occurs while fetching the user profile
            console.error('Error fetching user profile:', error);
        }
    }
 /*******************************Newly added by veera to display the missed meal count in the UI*********************************/   
 /*@wire(getMissedMealCount)
    wiredMissedMealCount({ error, data }) {
        if (data) {
            this.missedMealCount = data; // Update missedMealCount
        } else if (error) {
            console.error('Error fetching missed meal count:', error);
        }
    }*/
    @wire(getMissedMealCount)
    wiredMissedMealCount({ error, data }) {
        if (data !== undefined) {
            this.missedMealCount = data;
             console.log('Missed Meal Count:', data); // Assign the returned missed meal count
        } else if (error) {
            this.error = error;
            console.error('Error fetching missed meal count:', error);
        }
    }
 /************************************************************* */

    @wire(bookAndFetchMeals)
    wiredMealsData(result) {
        this.wiredData = result;
        if (result.data) {
            const currentTime = new Date();
            console.log("currentTime1", currentTime);         
            this.bookedMeals = result.data.BookedMeals.map(meal => {
                const mealDate = meal.Reva_Mess_Menu__r.Date__c;
                console.log("this.MealDate1", mealDate);
                const mealEndTime= new Date(meal.Reva_Mess_Menu__r.End_Time__c);
                console.log("mealEndTime1", mealEndTime);
                const hours1 = Math.floor(mealEndTime / (1000 * 60 * 60));
                const minutes1 = Math.floor((mealEndTime % (1000 * 60 * 60)) / (1000 * 60));
                const seconds1 = Math.floor((mealEndTime % (1000 * 60)) / 1000);
                const mealEndTimeMillis = `${String(hours1).padStart(2, '0')}:${String(minutes1).padStart(2, '0')}:${String(seconds1).padStart(2, '0')}`;
                console.log("mealEndTime1", mealEndTimeMillis);
                const mealEndDateTime = new Date(`${mealDate}T${mealEndTimeMillis}`);
                console.log("mealEndDateTime1", mealEndDateTime);

                const mealDisplayTime = new Date(mealEndTime.getTime() - 10 * 60 * 1000);
                console.log("mealDisplayTime",mealDisplayTime);
                const hours2 = Math.floor(mealDisplayTime / (1000 * 60 * 60));
                const minutes2 = Math.floor((mealDisplayTime % (1000 * 60 * 60)) / (1000 * 60));
                const seconds2 = Math.floor((mealDisplayTime % (1000 * 60)) / 1000);
                const mealDisplayTimeMillis = `${String(hours2).padStart(2, '0')}:${String(minutes2).padStart(2, '0')}:${String(seconds2).padStart(2, '0')}`;
                console.log("mealDisplayTimeMillis", mealDisplayTimeMillis);

                const feedbackAllowed = (currentTime - mealEndDateTime) <= 24 * 60 * 60 * 1000;
                return {
                    ...meal,
                   
                    isFeedbackAllowed: (meal.Reva_Meal_Booking_Status__c === 'Availed' || meal.Reva_Meal_Booking_Status__c === 'Instant Meal') && feedbackAllowed,
                    isMealBooked: (meal.Reva_Meal_Booking_Status__c === 'Booked' || meal.Reva_Meal_Booking_Status__c === 'Instant Meal')
                /*here above veera added the Instant Meal condition on 03-12-2024*/    
                }; 
            }); 
            
            console.log('OUTPUT1 : ', this.bookedMeals);

            const messMenuIds = this.bookedMeals.map((meal) => meal.Reva_Mess_Menu__r.Id);
            console.log("messMenuIds1", JSON.stringify(messMenuIds));

            this.mealsToBook = result.data.MealsToBook.filter((meal) => !messMenuIds.includes(meal.Id)).map((meal) => {
                return { ...meal, isSelected: false };
            });
            this.mealsToBook = [...this.mealsToBook];
            console.log("Booked Meals Data1", JSON.stringify(this.bookedMeals));
            console.log("Meals To Book1", JSON.stringify(this.mealsToBook));

        } else if (result.error) {
            console.error("Error when fetching meals data1  " + JSON.stringify(result.error));
        }
    }

    handleFeedback(event) {
        const mealId = event.target.dataset.mealId;
        const selectedMeal = this.bookedMeals.find(meal => meal.Id === mealId);
            console.log("selectedMeal2", selectedMeal);
        if (selectedMeal && selectedMeal.isFeedbackAllowed) {
            this.bookedMealId = mealId;
            this.showFeedback = true;
            console.log("2",this.bookedMealId);
        } else {
            this.showToast("Feedback not allowed", "Feedback can only be given for availed meals", "error");
        }
    }


    connectedCallback() {
        this.startStatusCheck();
        this.tickIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/tick-mark.png";
        this.calendarIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/calendar-icon.png";
        this.mealIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/meal-booking.png";
        this.timeIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/time-icon.png";
        this.cancelIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/cancel-icon.png";
        this.feedbackIcon = REVA_Hostel_Static_Resources + "/REVA_Hostel_Static_Resources/feedback-icon.png";
 
        const currentTime = new Date();
        console.log("currentTime3", currentTime);

        const cutoffTime = new Date();
        cutoffTime.setHours(21, 0, 0);
        console.log("cutoffTime3", cutoffTime);
        this.isAfterNinePM = currentTime >= cutoffTime;

        this.checkMissedMeals();
    }

    async checkMissedMeals() {
        try {
            const missedMealsCount = await getMissedMealCount();
            if (missedMealsCount >= 10) {
                this.disableBookMeal = true;
                this.showBanner = true;
                this.setBannerMessage('', 'You have missed more than 10 meals for the month, please pay the Missed Meal Fee to unlock the bookings!');
                this.mealsToBook = [];
                this.bookedMeals = [];
                this.isNonteachingOrProfessor = await isNotStudentRecordType();
            } else {
                this.disableBookMeal = false;
                this.showBanner = false;
                this.setBannerMessage('', ''); // Clear any existing banner message
            }
        } catch (error) {
            console.error('Error while checking missed meals: ' + JSON.stringify(error));
        }
    }
    get showMealsSection() {
        return !this.showBanner;
    }
  
    handleShowQRCode(event) {
        event.stopPropagation();
        const mealId = event.target.dataset.mealId;
        const selectedMeal = this.bookedMeals.find(meal => meal.Id === mealId);
        console.log("selectedMeal-qrcode", selectedMeal); 
        if (selectedMeal) {
            const mealTiming = new Date(selectedMeal.Reva_Mess_Menu__r.Start_Time__c);
            console.log("mealStartTime4", mealTiming);
            const mealDate = selectedMeal.Reva_Mess_Menu__r.Date__c;
            console.log("this.MealDate4", mealDate);
            const hours = Math.floor(mealTiming / (1000 * 60 * 60));
            const minutes = Math.floor((mealTiming % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((mealTiming % (1000 * 60)) / 1000);
            const mealStartTime = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
            console.log("Formatted MealStartTime4", mealStartTime);
            const mealStartDateTime = new Date(`${mealDate}T${mealStartTime}`);
            console.log("mealStartDateTime4", mealStartDateTime);

            const mealEndDate = new Date(selectedMeal.Reva_Mess_Menu__r.End_Time__c);
            console.log("mealEndDate4", mealEndDate);
            const hours1 = Math.floor(mealEndDate / (1000 * 60 * 60));
            const minutes1 = Math.floor((mealEndDate % (1000 * 60 * 60)) / (1000 * 60));
            const seconds1 = Math.floor((mealEndDate % (1000 * 60)) / 1000);
            const mealEndTimeMillis = `${String(hours1).padStart(2, '0')}:${String(minutes1).padStart(2, '0')}:${String(seconds1).padStart(2, '0')}`;
            console.log("mealEndTime4", mealEndTimeMillis);
            const mealEndDateTime = new Date(`${mealDate}T${mealEndTimeMillis}`);
            console.log("mealEndDateTime4", mealEndDateTime);

            const currentTime = new Date();
            console.log("currentTime4", currentTime);
            const tenMinutesBeforeStart = (mealStartDateTime- 10 * 60 * 1000);
            console.log("tenMinutesBeforeStart4", tenMinutesBeforeStart);
        
            if (currentTime >= tenMinutesBeforeStart && currentTime <= mealEndDateTime) {
                this.bookingIdSelected = mealId;
                this.showQRModal = true;
                console.log('Iiiddddddddddd'+this.bookingIdSelected);
            }
            else {
                this.showToast('','QR code will be available during scheduled meal time','error');
            }
        } else {
            this.showToast('','Meal details not found.', 'error');
        }
    }
 
    closeQRCodeModal() {
        this.showQRModal = false;
        console.log("QR modal closed"); 
         return refreshApex(this.wiredData);
    }
   
    handleModalClose() {
        this.showMessMenuItems = false;
        this.showFeedback = false;
    }
    handleFeedbackSave() {
        this.showFeedback = false;
        return refreshApex(this.wiredData);
    }

  
    async handleCancel(event) {
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
            this.currentTime = new Date();
            console.log("currentTime5", this.currentTime);
            const sixHoursBeforeMealStart = new Date(mealStartDateTime);
            sixHoursBeforeMealStart.setHours(sixHoursBeforeMealStart.getHours() - 6);
            console.log("sixHoursBeforeMealStart5", sixHoursBeforeMealStart);

    
            if (this.currentTime < mealStartDateTime && this.currentTime < sixHoursBeforeMealStart) {
                console.log("checkin",this.currentTime < mealStartDateTime && this.currentTime < sixHoursBeforeMealStart);
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
            .then(() => {
                this.isSpinner = false;
                this.showToast("","Meal Cancelled Successfully", "success");
                return refreshApex(this.wiredData); // Refresh the apex data
            })
            .catch((error) => {
                console.error("Error when updating " + JSON.stringify(error));
                this.isSpinner = false;
                this.showToast("Error", error.body.message, "error");
            });
    }


    handleSelectMeals(event) {
        const id = event.currentTarget.dataset.mealId;
        console.log("Id 6" + id);
        const selectedCard = this.mealsToBook.find((meal) => meal.Id === id);
        console.log("Selected Card 6" + JSON.stringify(selectedCard));
        if (selectedCard) {
            selectedCard.isSelected = !selectedCard.isSelected;
            this.mealsToBook = [...this.mealsToBook];
        }
    }

 showMessMenus(event) {
        this.showMessMenuItems = true;
        const mealId = event.target.dataset.bookedMealId;
        console.log('Meal Id 7' + mealId);
        const selectedMeal = this.mealsToBook.find(meal => meal.Id === mealId);
        console.log('Selected Meal 7' + JSON.stringify(selectedMeal));

        const bookedMealId = event.target.dataset.bookedMealId;
        console.log('Booked Meal Id 7' + bookedMealId);
        const selectedMeal1 = this.bookedMeals.find(meal => meal.Id === bookedMealId);
        console.log('Selected Meal1 7' + selectedMeal1);

        if (selectedMeal) {
            const messItems = selectedMeal.Mess_Items__c;
            if (messItems) {
                this.messMenuItems = messItems.split(';').map((item, index) => {
                    return {
                        itemNo: index + 1,
                        name: item
                    };
                });
            } else {
                this.messMenuItems = [];
            }
            this.isMessMenuItemsAvailable = this.messMenuItems.length > 0;
            console.log('messMenuItems7', JSON.stringify(this.messMenuItems));
        } 
        
        else if (selectedMeal1) {
            const messItems1 = selectedMeal1.Reva_Mess_Menu__r.Mess_Items__c;
            if (messItems1) {
                this.messMenuItems = messItems1.split(';').map((item, index) => {
                    return {
                        itemNo: index + 1,
                        name: item
                    };
                });
            } else {
                this.messMenuItems = [];
            }
            this.isMessMenuItemsAvailable = this.messMenuItems.length > 0;
            console.log('messMenuItems71', JSON.stringify(this.messMenuItems));
        } 
        else {
            this.messMenuItems = [];
            this.isMessMenuItemsAvailable = false;
        }
    }
    

    fetchSelectedMealMenus(type) {
        if (type === 'Normal') {
            return this.mealsToBook.filter((menu) => menu.isSelected).map((menu) => menu.Id);
        }
        // else {
        //     return this.instantMealBookingMeal ? [this.instantMealBookingMeal.Id] : [];
        // }
    }
    
    bookNormalMeals(event) {
        
        this.bookMeals(event.target.dataset.type);
    }
    
    async bookMeals(type) {
        this.disableBookMeal = true;
        try {
            const selectedMealMenus = this.fetchSelectedMealMenus(type);
            console.log("Selected Meals leave 8", JSON.stringify(selectedMealMenus));

            if (selectedMealMenus.length === 0) {
                this.disableBookMeal = false;
                this.showToast("Click on tiles to select Meal", "", "error");
                return; // Early return if no meals are selected
            }
           
            let mealsToBookIds = [];
            let mealsOnLeave = [];
    
            // Check leave status for all selected meals
            for (let menuId of selectedMealMenus) {
                const meal = this.mealsToBook.find(menu => menu.Id === menuId);// || this.instantMealBookingMeal;
                if (!meal) continue;
    
                const mealTiming = meal.Start_Time__c;
                console.log("mealStartTimeleave8", mealTiming);
                const mealDate = meal.Date__c;
                console.log("this.MealDateleave8", mealDate);
                const hours = Math.floor(mealTiming / (1000 * 60 * 60));
                const minutes = Math.floor((mealTiming % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((mealTiming % (1000 * 60)) / 1000);
                const mealStartTime = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
                console.log("Formatted MealStartTimeleave8", mealStartTime);
                const mealStartDateTime = new Date(`${mealDate}T${mealStartTime}`);
                console.log("mealStartDateTimeLeave8", mealStartDateTime);
    
                const isUserOnLeave = await ifUserOnLeave({ mealDateTime: mealStartDateTime });
                console.log("isUserOnLeave8: ", isUserOnLeave);
    
                if (isUserOnLeave > 0) {
                    this.disableBookMeal = false;
                    console.log("User is on leave for the selected day.");
                    mealsOnLeave.push(meal);
                } else {
                    mealsToBookIds.push(meal.Id);
                    console.log(isUserOnLeave > 0);
                    console.log("mealsToBookIds.length > 0", mealsToBookIds.length);
                }
            }
    
            if (mealsOnLeave.length > 0) {
                this.showToast('','You cannot book the meal for the selected day as you are on leave.', 'error');
            }
    
            if (mealsToBookIds.length > 0) { 
                this.isSpinner = true;
                try {
                    console.log("Booking meals with IDs: ", mealsToBookIds);
                    await callBookMeal({ messMenuIds: mealsToBookIds });
                    this.isSuccess =true;
                    console.log("Meals booked successfully");
                    this.showToast('','Meal Booked Successfully','success');

                    this.showInstantMealBooking = false;
                    await refreshApex(this.wiredData);
                    await refreshApex(this.wiredResult);
                } catch (error) {
                    console.error("Meal Booking Failed: ", error);
                    this.showToast("Meal Booking Failed", error.body.message, "error");
                } finally {
                    this.isSpinner = false;
                }
                this.disableBookMeal = false;
            }
        } catch (error) {
            console.log("Unexpected error: ", error);
            this.showToast("Error", "An unexpected error occurred.", "error");
        }
    
        if (this.disableBookMeal && !this.isSuccess)  {
            this.showToast('','Meal booking is disabled due to missed meals.', 'error');
            return;
        }
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
  
    setBannerMessage(error, warning) {
        if (error) {
            this.strBannerMessage = error;
            this.showError = true;
            this.showBanner = true;
        }
        if (warning) {
            this.strBannerMessage = warning;
            this.showWarning = true;
            this.showBanner = true;
        }
    }



//    // ************************
@track timerRunning = false;
@track timeRemaining = '';

renderedCallback() {
    // Check if the timer is already running to avoid starting it multiple times
    if (!this.timerRunning) {
        // Start the timer
        this.startTimer();
    }
}

startTimer() {
    this.updateTimeRemaining();
    this.intervalId = setInterval(() => {
        this.updateTimeRemaining();
    }, 1000);
    this.timerRunning = true;
}

updateTimeRemaining() {
    const currentTime = new Date();
    const cutoffTime = new Date();
    cutoffTime.setHours(21, 0, 0, 0); // Assuming cutoff time is 9:00 PM

    if (currentTime >= cutoffTime) {
        this.timeRemaining = 'Meal Booking will start tomorrow';
        clearInterval(this.intervalId);
        this.timerRunning = false;
    } else {
        const diff = cutoffTime - currentTime;
        const hours = Math.floor(diff / 3600000);
        const minutes = Math.floor((diff % 3600000) / 60000);
        const seconds = Math.floor((diff % 60000) / 1000);

        this.timeRemaining = `${hours}h ${minutes}m ${seconds}s`;
    }
}
/////////////////////////////

intervalId;

 

    disconnectedCallback() {
        this.stopStatusCheck();
    }

    startStatusCheck() {
        // Check status every 5 seconds
        this.intervalId = setInterval(() => {
            this.checkStatusUpdate();
        }, 5000);
    }

    stopStatusCheck() {
        clearInterval(this.intervalId);
    }

    checkStatusUpdate() {
        hasStatusUpdated({ mealBookingId: this.bookingIdSelected })
            .then((statusUpdated) => {
                console.log('Hello::'+ statusUpdated);
                if (statusUpdated) {
                    this.closeQRCodeModal();
                    this.stopStatusCheck(); // Stop checking once the modal is closed
                }
            })
            .catch((error) => {
                console.error('Error checking status update:', error);
            });
    }

    handlePenaltyFee(event){
        getMessPenaltyUrl()
            .then((result) => {
                this.penaltyFeeUrl = result;
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: this.penaltyFeeUrl,
                    }
                });
        
            })
            .catch((error) => {
               console.error('Error checking status update:', error);
            });


        }

        /******************************************************************* */
        handleBackButtonClick() {
             if(window.location.origin.includes('site.com')){
                if (this.profileName === 'Student Portal Profile' || this.profileName ==='Student Profile') {
        window.location.href = '/StudentPortal/s/';
             } else {
                 window.location.href = '/NonTeachingStaff/s/quartersfornonteachingstaff';
             }
            }
              else {
                    location.reload();
             }
             }

}
        /********************************************************************/