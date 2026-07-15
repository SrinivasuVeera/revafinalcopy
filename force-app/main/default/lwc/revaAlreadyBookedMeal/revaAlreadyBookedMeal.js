import { LightningElement, api } from "lwc";
import updateFeedbackBookedmeal from "@salesforce/apex/RevaMealBookingController.updateFeedbackBookedmeal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class MealFeedbackForm extends LightningElement {
    headerText = "";
    selectedEmoji = "";
    description = "";
    isSpinner;
    @api bookedMealId;

    handleEmojiClick(event) {
        const selectedEmojiElement = event.target;
        const emoji = selectedEmojiElement.dataset.emoji;

        // Remove 'selected' class and reset size for all emojis
        this.template.querySelectorAll(".emoji").forEach((el) => {
            el.classList.remove("selected");
            el.style.transform = "scale(1)";
        });

        selectedEmojiElement.style.transform = "scale(1.5)";

        // Update previously selected emoji size to normal
        if (this.selectedEmoji !== "") {
            const prevSelectedEmojiElement = this.template.querySelector(`[data-emoji="${this.selectedEmoji}"]`);
            if (prevSelectedEmojiElement) {
                prevSelectedEmojiElement.style.transform = "scale(1)";
            }
        }

        this.selectedEmoji = emoji;
        this.updateHeaderText();
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleSubmit(event) {
        if (!this.selectedEmoji) {
            this.showToast("Error", "Please select an emoji.", "error");
            return;
        }
        this.isSpinner = true;
        // Define ratings based on selected emoji
        let rating;
        switch (this.selectedEmoji) {
            case "😡":
                rating = 1;
                break;
            case "😞":
                rating = 2;
                break;
            case "😐":
                rating = 3;
                break;
            case "😊":
                rating = 4;
                break;
            case "🤩":
                rating = 5;
                break;
            default:
                rating = 0;
        }
        // Call Apex method to update records
        updateFeedbackBookedmeal({
            mealId: this.bookedMealId,
            feedbackEmoji: this.selectedEmoji,
            feedbackName: this.headerText,
            description: this.description,
            rating: rating
        })
            .then(() => {
                console.log("Feedback saved successfully");
                this.showToast("Feedback Saved Successfully", "Thanks for your feedback", "success");

                this.dispatchEvent(new CustomEvent("feedbacksave"));
                this.isSpinner = false;
            })
            .catch((error) => {
                this.showToast("Error", "Error saving feedback", "error");
                this.isSpinner = false;
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    updateHeaderText() {
        switch (this.selectedEmoji) {
            case "😡":
                this.headerText = "Disappointing :(";
                break;
            case "😞":
                this.headerText = "Bland :|";
                break;
            case "😐":
                this.headerText = "Okay :\\ ";
                break;
            case "😊":
                this.headerText = "Tasty :)";
                break;
            case "🤩":
                this.headerText = "Delicious !";
                break;
            default:
                this.headerText = "No Rating";
        }
    }

    getEmojiClass(emoji) {
        return this.selectedEmoji === emoji ? "emoji selected" : "emoji";
    }
}