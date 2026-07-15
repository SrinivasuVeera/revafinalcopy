import { LightningElement, api, wire, track} from 'lwc';
import getChangeSchoolPrograms from '@salesforce/apex/RegistrationFormUtilityTestForTicket.getChangeSchoolPrograms';

export default class ChangeSchoolProgramPLTest extends LightningElement {
    data;
  error;
  @api programType;
  @api currentProgramName;
  @api selectedSchool = '';
  @api selectedProgram = '';
  schools = [];
  programs = [];
  schoolPrograms = new Map(); //Key = School Name, Value = Set() of Program Name (Display)s

  @wire(getChangeSchoolPrograms, {programType : '$programType', currentProgramName : '$currentProgramName'}) 
  wiredSchoolPrograms({data, error}) {
    if (data) {
      console.log('apex class data'+ JSON.stringify(data));
      data.forEach(item => {
        if (!this.schoolPrograms.has(item.School_Name__c)) {
          this.schoolPrograms.set(item.School_Name__c, new Set());
        }
        this.schoolPrograms.get(item.School_Name__c).add(item.Program_Name_Display__c);
      });
      this.setSchoolOptions();
    }
    if (error) {
      console.log(error);
    }
  }
  
  setSchoolOptions() {
    this.schools = [];
    this.schools.push({
        value: '',
        label: 'Select a School'
    });
    console.log(this.schoolPrograms.size);
    for (const [school, programs] of this.schoolPrograms) {
      this.schools.push({
        value: school,
        label: school
      });
    };        
  }

  setProgramOptions() {
    this.programs = [];
    this.programs.push({
        value: '',
        label: 'Select a Program'
    });
    // this.schoolPrograms.get(this.selectedSchool).forEach(program => {
    for (const program of this.schoolPrograms.get(this.selectedSchool)) {
      this.programs.push({
          value: program,
          label: program
      });
    };     
    //console.log(this.programs);   
  }

  onSchoolChange(event){
    this.selectedProgram = '';
    this.selectedSchool = event.target.value;
    this.setProgramOptions();
  }

  onProgramChange(event) {
      this.selectedProgram = event.target.value;
      console.log(this.selectedSchool, this.selectedProgram)
      // const nextNavigationEvent = new FlowNavigationNextEvent();       
      // this.dispatchEvent(nextNavigationEvent);
  }   
}