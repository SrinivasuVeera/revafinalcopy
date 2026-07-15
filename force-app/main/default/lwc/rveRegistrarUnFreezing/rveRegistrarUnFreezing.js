import { LightningElement,track,api,wire } from 'lwc';
import getSchools from '@salesforce/apex/rveRegistrarUnFreezingController.getSchools';
import getRelatedSemester from '@salesforce/apex/rveRegistrarUnFreezingController.getRelatedSemester';
import getRelatedProgramBatch from '@salesforce/apex/rveRegistrarUnFreezingController.getRelatedProgramBatch';
import updateSchoolDirectorFreezingStatus from '@salesforce/apex/rveRegistrarUnFreezingController.updateSchoolDirectorFreezingStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RveRegistrarUnFreezing extends LightningElement {


    @track SchoolOptions = [];
    @track SemesterOptions = [];
    @track ProgramOptions = [];
    SelectedSchool;
    SelectedProgramBatch;
    SelectedSem;
    EnableSem=false;
    DisableSem;
    EnableProgram;
    DisableProgram;
    @wire(getSchools)
    wiredSchools({error,data}){
        if(data){
            console.log('Data: '+JSON.stringify(data));
            for(let key in data){
                console.log('Key: '+JSON.stringify(data[key]));
                let tempArray = [...this.SchoolOptions]; // Clone the existing array
                tempArray.push({ label: data[key].Name, value: data[key].Id });
                this.SchoolOptions = tempArray; // Assign a new reference
                console.log('SchoolOptions: '+JSON.stringify(this.SchoolOptions));
            }
        }
        else if(error){
            console.error('Error: '+error.message);
        }
    }

    @wire(getRelatedProgramBatch,{SchoolId:'$SelectedSchool'})
    wiredProgramBatch({error,data}){
        if(error){
            console.error('Error: '+error.message);
        }
        else if(data){
            console.log('Program=>: '+JSON.stringify(data));
            this.ProgramOptions = [];
            this.EnableProgram = false;
            this.DisableProgram = false;
            this.SemesterOptions = [];
            this.SelectedSem = '';
            this.EnableSem = false;
            this.DisableSem = false;
            this.EnableProgram = data.length>0?true:false;
            this.DisableProgram = data.length === 0 ? true : false;
            for(let key in data){
                console.log('Key: '+JSON.stringify(data[key]));
                let tempArray = [...this.ProgramOptions]; // Clone the existing array
                tempArray.push({ label: data[key].Name, value: data[key].Id });
                this.ProgramOptions = tempArray; // Assign a new reference
                console.log('ProgramOptions: '+JSON.stringify(this.ProgramOptions));
            }
        }
    }

    @wire(getRelatedSemester,{ProgramBatchId:'$SelectedProgramBatch'})
    wiredSemesters({error,data}){
        if(error){
            console.error('Error: '+error.message);
        }
        else if(data){
            console.log('Semester: '+JSON.stringify(data));
            this.EnableSem = data.length>0?true:false;
            this.DisableSem = data.length === 0 ? true : false;
            this.SemesterOptions = [];
            this.SelectedSem = '';
            for(let key in data){
                console.log('Key: '+JSON.stringify(data[key]));
                let buttonenable = data[key].SchoolDirectorFreeze__c==true?false:true;
                const instance = {
                    id: data[key].Id,
                    Name: data[key].Name,
                    FreezeCheck: buttonenable,
                }
                this.SemesterOptions.push(instance) // Assign a new reference
                console.log('SemesterOptions: '+JSON.stringify(this.SemesterOptions));
            }
        }
    }

    handleSchoolChange(event){
        this.SelectedSchool = event.target.value;
        console.log('Selected School: '+this.SelectedSchool);
    }

    handleProgramChange(event){
        this.SemesterOptions = [];
        this.SelectedProgramBatch = event.target.value;
        console.log('Selected Program Batch: '+this.SelectedProgramBatch);
    }

    handleSemChange(event){
        this.SelectedSem = event.target.value;
        console.log('Selected Semester: '+this.SelectedSem);
    }

    handleUnfreezeClick(event){
        console.log('Unfreeze Clicked'+event.target.dataset.id);
        let semId = event.target.dataset.id;
        updateSchoolDirectorFreezingStatus({
            SemId:semId
        })
        .then(res=>{
            console.log('Unfreeze Response: '+JSON.stringify(res));
            this.SemesterOptions.filter(sem => sem.id == semId).forEach(sem => {
                sem.FreezeCheck = true;
            })
             this.showToast('Registrar Unfrozen IA Marks Successfully', 'success');
        })
    }

    showToast(msg,variant){
        const evt = new ShowToastEvent({
        title: 'Status',
        message: msg,
        variant: variant,
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
    }
}