import { LightningElement,track,api,wire } from 'lwc';
//import fetchData from '@salesforce/apex/ASM_IAMarksEntry.fetchData';
import getCourseWiseIAMarks from '@salesforce/apex/rveExaminationVerticalHeadFreezeClass.getCourseWiseIAMarks'
export default class RveViewFreezeIAMarks extends LightningElement {

   @api course;
   @api IAType;
   currentPage =1
   totalRecords
   recordSize = 5
   totalPage = 0
   @track data = [];
   enableData=false;
   nodata=false;

    @track columns = [
        { label: 'SRN', fieldName: 'Id', type: 'text' },
        { label: 'Name', fieldName: 'Name', type: 'text'},
        { label: 'IA Marks', fieldName: 'Rating', type: 'text'}
      
    ];

    @wire(getCourseWiseIAMarks, { CourseID: '$course' })
    wiredIAMarks({ data, error }) {
    if (data) {
        this.data = []; // Initialize data array
        console.log('Data:', data); // No JSON.parse needed
        if(data.length > 0) {
        this.enableData = true
        for(let key in data) {
            const instance = {
                index: parseInt(key) + 1,
                SRN: data[key].StudentSRN,
                Name: data[key].StudentName,
                IA1Marks: data[key].IA1Marks, // Map IA1 marks
                IA2Marks: data[key].IA2Marks,
                Marks: data[key].Marks
            }
            this.data.push(instance);
            console.log('Instance:', instance);
            console.log('Data:', this.data);
        }
    }
        else{
            this.nodata = true;
        }
        }
     else if (error) {
        console.error('Error:', error.message);
    }
}


  /*  get disablePrevious(){ 
        return this.currentPage<=1
    }
    get disableNext(){ 
        return this.currentPage>=this.totalPage
    }
    previousHandler(){ 
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1
            this.updateRecords()
        }
    }
    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1
            this.updateRecords()
        }
    }
    updateRecords(){ 
        const start = (this.currentPage-1)*this.recordSize
        const end = this.recordSize*this.currentPage
        this.visibleRecords = this.totalRecords.slice(start, end)
    }*/

}