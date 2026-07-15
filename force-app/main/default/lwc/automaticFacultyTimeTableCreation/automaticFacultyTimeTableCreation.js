import { LightningElement, api, wire, track } from 'lwc';
import getTimetableData from '@salesforce/apex/AutomaticFacultyTimeTableCreationCtrl.generateTimetable';
import saveSchedules from '@salesforce/apex/AutomaticFacultyTimeTableCreationCtrl.saveSchedules';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { subscribe, onError, setDebugFlag } from 'lightning/empApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import REFRESH_TIME_LABEL from '@salesforce/label/c.Time_Table_Allocation_refresh_Time';

export default class AutomaticFacultyTimeTableCreation extends LightningElement {
  @api recordId;
  isLoaded = false;

  @track headerSlots = [];     // [{ id: 'startMs-endMs', startTimeLabel, endTimeLabel, slot }]
  @track weekDays = [];        // ['Monday',...]
  @track sections = [];        // [{Id, Name}, ...]
  @track sectionGridRows = new Map(); // sectionId -> [{day, slots:[{slotKey, allocation}]}]
  @track activeGridRows = [];
  @track activeTab = null;

  @track unallocatedCourses = [];
  @track timetableData;
  @track error;
  @track isLoading = false;
  @track isSaveDisabled = false;
  @track isTimetableCreated = false;

  wiredResult;

  // day -> rangeKey -> blockId (built from timeBlocks)
  _dayRangeToBlock = {};

  unallocatedColumns = [
    { label: 'Course Name', fieldName: 'courseName', type: 'text' },
    { label: 'Faculty Name(s)', fieldName: 'professorNames', type: 'text' },
    { label: 'Section Name', fieldName: 'sectionName', type: 'text' },
    { label: 'Reason', fieldName: 'reason', type: 'text' }
  ];

  @track status = 'Not Started Batch';
  channelName = '/event/Time_table_scheduled_Creation__e';
  subscription = {};


  @wire(CurrentPageReference)
  getStateParameters(pageRef) {
    if (pageRef) {
      this.isLoading = true;
      this.recordId = pageRef.state?.recordId || null;
    }
  }

  renderedCallback() {
    if (this.isLoaded) {
      return;
    }
    const STYLE = document.createElement("style")
    STYLE.innerText = `
        .uiModal--medium .modal-container {
            max-width: 85% ;
            max-height: 100% ;
            width: 100% !important;
            min-width: 480px;
            min-height: 480px;
        }
        .specialization-header {
            background-color: #f3f2f2;
            font-weight: bold;
        }
        .specialization-header td {
            padding-top: 0.75rem;
            padding-bottom: 0.75rem;
        }
    `;
    this.template.querySelector('lightning-card').appendChild(STYLE);
    this.isLoaded = true;
  }

  connectedCallback() {
    this.loadTimetableData();
    this.registerErrorListener();
    this.handleSubscribe();
    this.startAutoDisableSave();
  }

  startAutoDisableSave() {
    let REFRESH_TIME = Number(REFRESH_TIME_LABEL); // label like 1,2,3

    // Default to 1 minute if label is invalid
    if (isNaN(REFRESH_TIME) || REFRESH_TIME <= 0) {
      REFRESH_TIME = 1;
    }

    // Convert minutes → milliseconds
    REFRESH_TIME = REFRESH_TIME * 60000;
    setInterval(() => {
      if (!this.isSaveDisabled && !this.isTimetableCreated) {
        this.isLoading = false;
        this.sections = null;
        this.activeGridRows = null;
        this.isSaveDisabled = true;
      }
    }, REFRESH_TIME);
  }

  handleSubscribe() {
    const messageCallback = (response) => {
      const payload = response.data.payload;
      if (payload.Record_Id__c === this.recordId) {
        this.status = payload.Batch_Message__c;
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'success',
            message: this.status,
            variant: 'success'
          })
        );
      } else {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'error',
            message: 'No timetable data available to save.',
            variant: 'error'
          })
        );
      }
      this.isLoading = false;

      // window.location.reload();
      this.timetableData = '';
      this.dispatchEvent(new CloseActionScreenEvent());

    };

    subscribe(this.channelName, -1, messageCallback).then((response) => {
      this.subscription = response;
    });
  }

  registerErrorListener() {
    onError((error) => {
    });
  }

  handleRefresh() {
    this.loadTimetableData();
  }

  async loadTimetableData() {
    this.isLoading = true;
    try {
      const data = await getTimetableData({ recordId: this.recordId });

      if (data.isTimetableCreated) {
        this.isTimetableCreated = true;
      }

      // ✅ Process and set up UI data
      this.processTimetableData(data);
      this.isLoading = false;
    } catch (error) {
      this.isLoading = false;
      this.handleError(error);
    }
  }

  processTimetableData(data) {
    this.timetableData = data;
    console.log('Timetable Data:', data);

    this.weekDays = Array.isArray(data.weekDays) ? data.weekDays : [];
    this.sections = Array.isArray(data.sections) ? data.sections : [];
    this.unallocatedCourses = Array.isArray(data.unallocatedCourses) ? data.unallocatedCourses : [];
    // 1️⃣ Sort time blocks
    const blocks = Array.isArray(data.timeBlocks) ? data.timeBlocks.slice() : [];
    blocks.sort((a, b) => {
      const as = a.Slot__c || 0, bs = b.Slot__c || 0;
      if (as !== bs) return as - bs;
      return this.toMinutes(a.hed__Start_Time__c) - this.toMinutes(b.hed__Start_Time__c);
    });

    // 2️⃣ Build dayRangeToBlock map
    const dayRangeToBlock = {};
    this.weekDays.forEach(d => (dayRangeToBlock[d] = {}));
    for (const tb of blocks) {
      const startMs = Number(tb.hed__Start_Time__c);
      const endMs = Number(tb.hed__End_Time__c);
      const rangeKey = `${startMs}-${endMs}`;
      if (tb.Monday__c) dayRangeToBlock['Monday'][rangeKey] = tb.Id;
      if (tb.Tuesday__c) dayRangeToBlock['Tuesday'][rangeKey] = tb.Id;
      if (tb.Wednesday__c) dayRangeToBlock['Wednesday'][rangeKey] = tb.Id;
      if (tb.Thursday__c) dayRangeToBlock['Thursday'][rangeKey] = tb.Id;
      if (tb.Friday__c) dayRangeToBlock['Friday'][rangeKey] = tb.Id;
      if (tb.Saturday__c) dayRangeToBlock['Saturday'][rangeKey] = tb.Id;
      if (tb.Sunday__c) dayRangeToBlock['Sunday'][rangeKey] = tb.Id;
    }
    this._dayRangeToBlock = dayRangeToBlock;

    // 3️⃣ Unique header time ranges
    const uniq = new Map();
    for (const tb of blocks) {
      const startMs = Number(tb.hed__Start_Time__c);
      const endMs = Number(tb.hed__End_Time__c);
      const key = `${startMs}-${endMs}`;
      if (!uniq.has(key)) uniq.set(key, { startMs, endMs, slot: tb.Slot__c || 0 });
    }
    const uniqueRanges = Array.from(uniq.values()).sort((a, b) => a.slot - b.slot || a.startMs - b.startMs);
    this.headerSlots = uniqueRanges.map(r => ({
      id: `${r.startMs}-${r.endMs}`,
      startTimeLabel: this.formatTime(r.startMs),
      endTimeLabel: this.formatTime(r.endMs),
      slot: r.slot
    }));

    // 4️⃣ Build section grids
    this.sectionGridRows = new Map();
    const sws = data.sectionWiseSchedules || {};

    this.sections.forEach(section => {
      const list = Array.isArray(sws[section.Name]) ? sws[section.Name] : [];

      // Step 1: find first date for each weekday
      const weekdayToFirstDate = {};
      this.weekDays.forEach(day => {
        const dates = list
          .filter(s => this.getWeekdayFromDate(s.Date__c) === day)
          .map(s => new Date(s.Date__c));
        if (dates.length > 0) {
          dates.sort((a, b) => a - b);
          weekdayToFirstDate[day] = dates[0];
        }
      });

      // Step 2: Initialize allocations per weekday based on first date
      const allocations = {};
      this.weekDays.forEach(day => {
        allocations[day] = {};
        this.headerSlots.forEach(h => (allocations[day][h.id] = null));
      });

      // Step 3: Place schedules into correct weekday row
      for (const s of list) {
        const weekday = this.getWeekdayFromDate(s.Date__c);
        if (!weekday || !allocations[weekday]) continue;

        const startMs = Number(s.hed__Start_Time__c);
        const endMs = Number(s.hed__End_Time__c);
        const rangeKey = `${startMs}-${endMs}`;

        if (!this._dayRangeToBlock[weekday] || !this._dayRangeToBlock[weekday][rangeKey]) continue;

        allocations[weekday][rangeKey] = {
          CourseName: s.CourseId != null ? s.CourseName + '(' + s.CourseId + ')' : s.CourseName || '',
          FacultyName: s.FacultyName || '',
          FacilityName: s.FacilityName || '',
          isBreak: s.CourseName == 'Break' ? true : false,
          isFreeSlot: s.CourseName == 'Free_Slot' ? true : false,
          isCourseSlot: (s.CourseName != 'Break' && s.CourseName != 'Free_Slot') ? true : false,
          ProfessorId: s.Professor__c || null,
          FacilityId: s.hed__Facility__c || null,
          OfferingId: s.hed__Course_Offering__c || null,
          CourseId: s.CourseId || null,
          SectionId: s.Section__c || null,
          StartLabel: this.formatTime(startMs),
          EndLabel: this.formatTime(endMs),
          Date: s.Date__c,
          cellClass: s.CourseName === 'Break'
            ? 'break-cell'
            : s.CourseName === 'Free_Slot'
              ? 'free-slot-cell'
              : 'course-cell'
        };
      }

      // Step 4: Convert allocations to rows ordered by weekdays
      const rows = [];
      this.weekDays.forEach(day => {
        rows.push({
          day,
          date: weekdayToFirstDate[day]
            ? weekdayToFirstDate[day].toISOString().split('T')[0]
            : null,
          slots: this.headerSlots.map(h => ({
            slotKey: h.id,
            allocation: allocations[day][h.id]
          }))
        });
      });

      this.sectionGridRows.set(section.Id, rows);
    });

    // 5️⃣ Set first tab active
    if (this.sections.length > 0) {
      this.activeTab = this.sections[0].Id;
      this.setActiveGridRows();
    }

    this.isLoading = false;
    this.isSaveDisabled = false;
    refreshApex(this.wiredResult);

  }

  handleError(error) {
    const message = error.body ? error.body.message : error.message;
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Error loading timetable',
        message,
        variant: 'error'
      })
    );
  }

  handleTabChange(event) {
    this.activeTab = event.target.value;
    this.setActiveGridRows();
  }

  setActiveGridRows() {
    this.activeGridRows = this.sectionGridRows.get(this.activeTab) || [];
  }


  getHM(sfTime) {
    if (sfTime == null) return null;

    if (typeof sfTime === 'number') {
      const totalMs = Number(sfTime);
      const totalMin = Math.floor(totalMs / 60000);
      const h = Math.floor(totalMin / 60);
      const m = totalMin % 60;
      return { h, m };
    }
    if (typeof sfTime === 'object') {
      const h = Number(sfTime.hours ?? 0);
      const m = Number(sfTime.minutes ?? 0);
      return { h, m };
    }
    if (typeof sfTime === 'string') {
      const [hStr, mStr] = sfTime.split(':');
      const h = parseInt(hStr, 10) || 0;
      const m = parseInt(mStr, 10) || 0;
      return { h, m };
    }
    return null;
  }

  toMinutes(sfTime) {
    const hm = this.getHM(sfTime);
    return hm ? (hm.h * 60 + hm.m) : 0;
  }

  formatTime(sfTime) {
    const hm = this.getHM(sfTime);
    if (!hm) return '';
    let { h, m } = hm;
    const ampm = h >= 12 ? 'PM' : 'AM';
    const h12 = (h % 12) || 12;
    return `${h12}:${m.toString().padStart(2, '0')} ${ampm}`;
  }

  getWeekdayFromDate(dateVal) {
    try {
      const d = new Date(dateVal);
      return d.toLocaleDateString('en-US', { weekday: 'long' });
    } catch (e) {
      return '';
    }
  }

  async handleSave() {
    this.isSaveDisabled = true;
    this.isLoading = false;
    if (!this.timetableData) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'No timetable data available to save.',
          variant: 'error'
        })
      );
      this.isSaveDisabled = false;
      return;

    }

    try {
      this.isLoading = true;;
      const filteredData = this.prepareSlimmedDownData();
      const timetableDataJson = JSON.stringify(filteredData);
      console.log('Payload size:', timetableDataJson);
      const dayToDatesMap = this.timetableData.dayToDatesMap || {};

      await saveSchedules({ recordId: this.recordId, timetableDataJson: timetableDataJson, dayToDatesMap: dayToDatesMap });

      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Batch Started',
          message: 'Batch execution initiated successfully',
          variant: 'info'
        })
      );

    } catch (error) {
      this.isSaveDisabled = false;
      // ✅ Handle Apex errors
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message:
            'Error saving schedules: ' +
            (error?.body?.message || error?.message || 'Unknown error'),
          variant: 'error'
        })
      );
      this.isLoading = false;
    }
  }

  prepareSlimmedDownData() {
    const requiredFields = [
      'Section__c',
      'Batch_Group__c',
      'hed__Time_Block__c',
      'hed__Course_Offering__c',
      'Date__c',
      'Monday__c',
      'Tuesday__c',
      'Wednesday__c',
      'Thursday__c',
      'Friday__c',
      'Saturday__c',
      'Sunday__c',
      'All_Professors__c',
      'Professor__c',
      'Faculty_Course_Connection__c',
      'hed__Facility__c'
    ];

    // Clean up each section’s schedule set
    const cleanSectionSchedules = {};
    for (const sectionKey in this.timetableData.sectionWiseSchedules) {
      const schedules = this.timetableData.sectionWiseSchedules[sectionKey] || [];
      const filtered = schedules.map(item => {
        const clean = {};
        requiredFields.forEach(field => {
          if (item[field] !== undefined && item[field] !== null) {
            clean[field] = item[field];
          }
        });
        return clean;
      });
      cleanSectionSchedules[sectionKey] = filtered;
    }

    // Rebuild minimal object for Apex
    return {
      sectionWiseSchedules: cleanSectionSchedules
    };
  }

}