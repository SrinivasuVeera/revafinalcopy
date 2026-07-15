import { LightningElement, track, wire } from 'lwc';

import REVA_Hostel_Static_Resources from "@salesforce/resourceUrl/REVA_Hostel_Static_Resources";
import bookAndFetchMeals from "@salesforce/apex/RevaMealBookingController.bookAndFetchMeals";
import getMissedMealCount from '@salesforce/apex/RevaMealBookingController.getMissedMealCount';
import missedMealsByTheUser from '@salesforce/apex/RevaMealBookingController.missedMealsByTheUser';
import isNotStudentRecordType from '@salesforce/apex/RevaMealBookingController.isNotStudentRecordType';
import getMessPenaltyUrl from '@salesforce/apex/RevaMealBookingController.getMessPenaltyUrl';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { refreshApex } from "@salesforce/apex";

import ifUserOnLeave from "@salesforce/apex/RevaMealBookingController.ifUserOnLeave";
import callBookMeal from "@salesforce/apex/RevaMealBookingController.bookMeal";

export default class RevaMealBookingMealToBookPage extends NavigationMixin (LightningElement) {
    isSpinner;
    isAfterNinePM;
    @track disableBookMeal = true;
    @track timeRemaining = '';
    @track timerRunning = false;
    @track missedMealCount = 0;
    @track isSuccess = false;
    isTomorrowMealBooked = false;

    strBannerMessage = '';
    isNonteachingOrProfessor;
    penaltyFeeUrl;
    wiredData;
    mealsToBook = [];
    bookedMeals;
    isMealsToBook = false;

    @track alredyBookedMealsMessgae ='YOU HAVE ALREADY BOOKED MEALS FOR TOMORROW';
    @track noCreatedMealsMessage ='MEALS ARE NOT YET READY FOR TOMORROW`S';
    @wire(bookAndFetchMeals)
    wiredMealsData(result) {
        this.wiredData = result;
        if (result.data) {
            const currentTime = new Date();
            console.log("currentTime1", currentTime);
            this.bookedMeals = result.data.BookedMeals.map(meal => {
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

                const mealDisplayTime = new Date(mealEndTime.getTime() - 10 * 60 * 1000);
                console.log("mealDisplayTime", mealDisplayTime);
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
                return {
                    ...meal, isSelected: false, messItemsList: meal.Mess_Items__c ? meal.Mess_Items__c.split(';') : [],
                    ImageURL: this.getMealImage(meal.Type__c), buttonLabel: "SELECT MEAL"
                };
            });
            this.mealsToBook = [...this.mealsToBook];
            if (this.mealsToBook.length > 0) {
                this.isMealsToBook = true;
            }
            else {
                this.isMealsToBook = false;
            }

            const tomorrowDate = new Date();
            tomorrowDate.setDate(tomorrowDate.getDate() + 1);
            const tomorrowDateString = tomorrowDate.toISOString().split('T')[0];

            this.isTomorrowMealBooked = this.mealsToBook.length === 0
                && this.bookedMeals.some(meal => meal.Reva_Mess_Menu__r.Date__c === tomorrowDateString);
            console.log("Booked Meals Data1", JSON.stringify(this.bookedMeals));
            console.log("Meals To Book1", JSON.stringify(this.mealsToBook));

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

    handleMealSelection(event) {
        const mealId = event.target.dataset.id;
        console.log('mealId---' + mealId);

        this.mealsToBook = this.mealsToBook.map(meal => {
            console.log('meal.isSelected', meal.isSelected);
            if (meal.Id === mealId) {
                return {
                    ...meal,
                    isSelected: !meal.isSelected,
                    buttonLabel: meal.isSelected == false ? "MEAL SELECTED" : "SELECT MEAL"
                };
            }

            return { ...meal };
        });
        // Check if at least one meal is selected
        this.disableBookMeal = !this.mealsToBook.some(meal => meal.isSelected);
        setTimeout(() => {
            this.applyDynamicStyles();
        }, 0);
        console.log('this.mealsToBook---', JSON.stringify(this.mealsToBook));
    }

    applyDynamicStyles() {
        this.template.querySelectorAll('.selectmealbtn').forEach(button => {
            const mealId = button.dataset.id;
            const meal = this.mealsToBook.find(m => m.Id === mealId);
            if (meal?.isSelected) {
                button.style.backgroundColor = 'green';
                button.style.color = 'white';
                button.style.border = '1px solid darkgreen';
            } else {
                button.style.backgroundColor = '#baafaf';
                button.style.color = 'black';
                button.style.hover = '#e67e00';
            }
        });
    }

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
    connectedCallback() {
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
            const today = new Date();
            const isLastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate() === today.getDate();
            const missedMealsCount = await getMissedMealCount();
            if (missedMealsCount >= 10 && !isLastDayOfMonth ) {
                this.disableBookMeal = true;
                this.showBanner = true;
                this.setBannerMessage('', 'You have missed more than 10 meals for the month, please pay the Missed Meal Fee to unlock the bookings!');
                this.mealsToBook = [];
                this.bookedMeals = [];
                this.isNonteachingOrProfessor = await isNotStudentRecordType();
            } else {
                // this.disableBookMeal = false;
                this.showBanner = false;
                this.setBannerMessage('', ''); // Clear any existing banner message
            }
        } catch (error) {
            console.error('Error while checking missed meals: ' + JSON.stringify(error));
        }
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
    handlePenaltyFee(event) {
        getMessPenaltyUrl()
            .then((result) => {
                console.log('result paylink --'+result);
                
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
    handleBokkMeal(event) {

        this.bookMeals();
    }

    async bookMeals() {
        console.log('Booked meaks');

        this.disableBookMeal = true;
        try {
            const selectedMealMenus = this.fetchSelectedMealMenus();
            console.log("Selected Meals leave 8", JSON.stringify(selectedMealMenus));

            if (selectedMealMenus.length === 0) {
                this.disableBookMeal = false;
                this.showToast("Click on select Meal Bitton then select your meal", "", "error");
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
                this.showToast('', 'You cannot book the meal for the selected day as you are on leave.', 'error');
            }

            if (mealsToBookIds.length > 0) {
                this.isSpinner = true;
                try {
                    console.log("Booking meals with IDs: ", mealsToBookIds);
                    await callBookMeal({ messMenuIds: mealsToBookIds });
                    this.isSuccess = true;
                    this.disableBookMeal = true;
                    console.log("Meals booked successfully");
                    this.showToast('Success', 'Meal Booked Successfully', 'success');

                    await refreshApex(this.wiredData);

                    //await refreshApex(this.wiredResult);
                } catch (error) {
                    console.error("Meal Booking Failed: ", error);
                    this.showToast("Meal Booking Failed", error.body.message, "error");
                } finally {
                    this.isSpinner = false;
                }
                //this.disableBookMeal = false;
            }
        } catch (error) {
            console.log("Unexpected error: ", error);
            this.showToast("Error", "An unexpected error occurred.", "error");
        }

        if (this.disableBookMeal && !this.isSuccess) {
            this.showToast('', 'Meal booking is disabled due to missed meals.', 'error');
            return;
        }
    }
    fetchSelectedMealMenus() {

        return this.mealsToBook.filter((menu) => menu.isSelected).map((menu) => menu.Id);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}