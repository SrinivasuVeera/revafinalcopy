import { LightningElement, api } from 'lwc';



export default class RevacetDateComponent extends LightningElement {

  @api error = "";

  @api minDate = "";

  @api maxDate = "";

  @api dateVal;


  connectedCallback() {

    let today = new Date().toJSON().slice(0, 10);

    if (this.minDate > today) {
      this.dateVal = this.minDate;

    }
    else {

      this.dateVal = "";
      this.error = "Select a date";
    }



  }


  changedate(event) {
    let selectedDate = new Date(event.target.value);
    let formattedDate = selectedDate.toISOString().substring(0, 10);
    let currentDate = new Date().toISOString().substring(0, 10);
    if (formattedDate >= currentDate) {
      this.dateVal = event.target.value;
      this.error = false;
    }
    else if (selectedDate == "") {
      this.error = "Select a date";
      this.dateVal = "";
    }
    else {
      this.error = "Selected date is in the past";
      this.dateVal = "";

    }



  }
}