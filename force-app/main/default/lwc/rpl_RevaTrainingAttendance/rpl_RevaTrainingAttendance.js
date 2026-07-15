import { LightningElement , api, wire, track} from 'lwc';
import getAttendanceData from '@salesforce/apex/rpl_Placement_Training_Controller.getAttendanceData';

export default class Rpl_RevaTrainingAttendance extends LightningElement {

    @api contactId;
    showCalendar;
    presentDates = [];
    absentDates = [];
    showNoAttendance;
    isSpinner = true;

    @track transformedData = {};
    @track modules = [];
    selectedMonth;
    selectedYear;
    month = '';
    weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    months = [
        { label: 'January', value: '0' },
        { label: 'February', value: '1' },
        { label: 'March', value: '2' },
        { label: 'April', value: '3' },
        { label: 'May', value: '4' },
        { label: 'June', value: '5' },
        { label: 'July', value: '6' },
        { label: 'August', value: '7' },
        { label: 'September', value: '8' },
        { label: 'October', value: '9' },
        { label: 'November', value: '10' },
        { label: 'December', value: '11' },
    ];
    handleCardClick(event){
        this.showCalendar = true;
        const moduleName = event.currentTarget.dataset.module;
        const selectedObject = this.modules.find(module => module.name === moduleName);
        if(selectedObject){
            this.presentDates = selectedObject.presentDates;
            this.absentDates = selectedObject.absentDates;
        }
        this.generateCalendar();
    }
    handleModalClose(){
        this.showCalendar = false;
    }
    connectedCallback() {
        const currentDate = new Date();
        this.selectedMonth = String(currentDate.getMonth());
        this.selectedYear = String(currentDate.getFullYear());
        this.generateCalendar();
    }

    handleMonthChange(event) {
        this.selectedMonth = event.detail.value;
        this.generateCalendar();
    }

    handleYearChange(event) {
        this.selectedYear = event.detail.value;
        this.generateCalendar();
    }

    generateCalendar() {
        const currentMonth = parseInt(this.selectedMonth);
        const currentYear = parseInt(this.selectedYear);
        const firstDayOfMonth = new Date(currentYear, currentMonth, 1).getDay();
        const lastDayOfMonth = new Date(currentYear, currentMonth + 1, 0).getDate();

        this.month = new Date(currentYear, currentMonth, 1).toLocaleString('default', { month: 'long' });

        let calendar = [];
        let week = [];

        for (let i = 1; i <= lastDayOfMonth; i++) {
            const date = new Date(currentYear, currentMonth, i+1);
            const dayOfWeek = date.getDay();
            let classes = '';


            if (this.presentDates && this.presentDates.includes(date.toISOString().split('T')[0])) {
                classes = 'present';
            } else if (this.absentDates && this.absentDates.includes(date.toISOString().split('T')[0])) {
                classes = 'absent';
            } else {
                classes = 'blank';
            }
            i = i < 10 ? '0'+ i : i;
            week.push({ value: i, classes: classes });

            if (dayOfWeek === 0) {
                calendar.push(week);
                week = [];
            }
        }

        if (week.length > 0) {
            calendar.push(week);
        }

        this.calendar = calendar;
    }

    get years() {
        const years = [];
        const currentYear = new Date().getFullYear();
        for (let year = currentYear - 5; year <= currentYear + 5; year++) {
            years.push({ label: String(year), value: String(year) });
        }
        return years;
    }


    @wire(getAttendanceData , {contactId : '$contactId'})
    wiredData({data, error}){
        
        if(data){
            this.isSpinner = false;
            if(data && data.length == 0){
                this.showNoAttendance = true;
                return;
            }
            data.forEach(record => {
                const moduleName = record.Rpl_Training_Module__r.Name;
                const attendance = record.Rpl_Attendance__c;
             
                if (!this.transformedData[moduleName]) {
                    this.transformedData[moduleName] = {
                        present: 0,
                        absent: 0,
                        total: 0,
                        attendancePercentage: 0,
                        presentDates : [],
                        absentDates : []
                    };
                }
                if (attendance === 'Present') {
                    this.transformedData[moduleName].present++;
                    this.transformedData[moduleName].presentDates.push(record.Rpl_Date__c);
                } else if (attendance === 'Absent' || attendance === null) {
                    this.transformedData[moduleName].absent++;
                    this.transformedData[moduleName].absentDates.push(record.Rpl_Date__c);
                }

                this.transformedData[moduleName].total++;
            });
            Object.keys(this.transformedData).forEach(moduleName => {
                const { present, absent, total } = this.transformedData[moduleName];
                this.transformedData[moduleName].attendancePercentage = total > 0 ? ((present / total) * 100).toFixed(2)  : 0;
            });
            this.modules = Object.keys(this.transformedData).map(key => {
               
                const percentage = this.transformedData[key].attendancePercentage;
                const circumference = 2 * Math.PI * 40;
                const offset = circumference * (1 - percentage / 100);
                let strokeColor = percentage >= 90 ? 'rgb(142, 204, 142)' : percentage >= 70 ? '#ffdb24' : 'rgb(255, 95, 95)';
                let style = `stroke : ${strokeColor}; stroke-dashoffset:${offset}`;

                return {
                    name: key,
                    style,
                    ...this.transformedData[key]
                };
            });
        }else if(error){
            this.isSpinner = false;
        }
    }

}