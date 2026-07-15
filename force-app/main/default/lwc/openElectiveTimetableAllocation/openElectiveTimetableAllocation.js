import { LightningElement, track } from 'lwc';
import generateTimetable from '@salesforce/apex/OpenElectiveProfessorAllotment_Ctrl.generateTimetable';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpenElectiveTimetableAllocation extends LightningElement {
    @track preferences = [];
    @track timetableData = { schedules: [], weeklyView: {} };
    @track weeklyEntries = [];
    isLoading = false;

    dayOptions = [
        { label: 'Monday', value: 'Monday' },
        { label: 'Tuesday', value: 'Tuesday' },
        { label: 'Wednesday', value: 'Wednesday' },
        { label: 'Thursday', value: 'Thursday' },
        { label: 'Friday', value: 'Friday' },
        { label: 'Saturday', value: 'Saturday' }
    ];

    slotOptions = Array.from({ length: 10 }, (_, i) => ({
        label: `Slot ${i + 1}`,
        value: `${i + 1}`
    }));

    connectedCallback() {
        // Start with 1 empty preference row
        this.preferences = [{ id: Date.now() + 1, day: '', slot: '' }];
    }

    addPreference() {
        this.preferences = [...this.preferences, { id: Date.now(), day: '', slot: '' }];
    }

    handleDayChange(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const value = event.detail.value;
        if (this.preferences[index]) {
            this.preferences[index].day = value;
            this.preferences = [...this.preferences];
            this.checkDuplicate();
        }
    }

    handleSlotChange(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const value = event.detail.value;
        if (this.preferences[index]) {
            this.preferences[index].slot = value;
            this.preferences = [...this.preferences];
            this.checkDuplicate();
        }
    }

    removePair(event) {
        const index = parseInt(event.currentTarget.dataset.index, 10);
        this.preferences = this.preferences.filter((_, i) => i !== index);
    }

    checkDuplicate() {
        const seen = new Set();
        for (let pref of this.preferences) {
            if (pref.day && pref.slot) {
                const key = `${pref.day}-${pref.slot}`;
                if (seen.has(key)) {
                    this.showToast('Duplicate Preference', 'Duplicate Day+Slot found', 'error');
                    // remove duplicate slot (reset)
                    pref.slot = '';
                    this.preferences = [...this.preferences];
                    return;
                }
                seen.add(key);
            }
        }
    }

    savePreferences() {
        // Basic validation: at least one filled pair
        const filled = this.preferences.filter(p => p.day && p.slot);
        if (!filled.length) {
            this.showToast('Validation', 'Please select at least one Day + Slot', 'warning');
            return;
        }

        this.isLoading = true;
        // Keep UI responsive: clear previous results
        this.weeklyEntries = [];
        this.timetableData = { schedules: [], weeklyView: {} };

        const daySlotsJson = JSON.stringify(this.preferences);

        generateTimetable({ daySlotsJson })
            .then(result => {
                // Expect result.weeklyView as map: { "Monday": [ScheduleDTO,...], ... }
                this.timetableData = result || { schedules: [], weeklyView: {} };

                // Safe normalization: produce weeklyEntries array for template
                const weekly = this.timetableData.weeklyView || {};
                this.weeklyEntries = Object.keys(weekly).map(day => {
                    const entries = (weekly[day] || []).map((sched, idx) => {
                        return {
                            id: `${day}-${idx}`,
                            groupName: sched.groupName || '',
                            courseName: sched.courseName || '',
                            professorName: sched.professorName || '',
                            parentSemesterName: sched.parentSemesterName || '',
                            professorId: sched.professorId || '',
                            startTime: sched.startTime || null,
                            endTime: sched.endTime || null,
                            formattedTime:
                                (sched.startTime != null && sched.endTime != null)
                                    ? `${this.formatTime(sched.startTime)} - ${this.formatTime(sched.endTime)}`
                                    : ''
                        };
                    });
                    // Sort entries by startTime
                    entries.sort((a, b) => (a.startTime || 0) - (b.startTime || 0));
                    return { day, entries };
                });

                this.showToast('Success', 'Schedule generated successfully.', 'success');
            })
            .catch(error => {
                // Log full error and show a useful message
                console.error('Apex error:', JSON.stringify(error));
                const msg = (error && error.body && error.body.message) ? error.body.message : 'Error generating timetable';
                this.showToast('Error', msg, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    resetToPreferences() {
        // Clear results but keep preferences for editing
        this.weeklyEntries = [];
        this.timetableData = { schedules: [], weeklyView: {} };
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    formatTime(ms) {
    // Input: milliseconds from midnight (number). E.g. 0 => 12:00 AM, 3600000 => 1:00 AM, 48600000 => 1:30 PM
    if (ms == null || isNaN(ms)) return '';

    // Convert ms -> total minutes (avoids fractional minute issues)
    const totalMinutes = Math.floor(Number(ms) / 60000);
    let hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;

    // 12-hour conversion
    const period = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    if (hours === 0) hours = 12; // midnight or noon -> 12

    // Pad
    const hh = String(hours).padStart(2, '0');
    const mm = String(minutes).padStart(2, '0');

    return `${hh}:${mm} ${period}`;
}


    get hasResults() {
        return this.weeklyEntries && this.weeklyEntries.length > 0;
    }
}