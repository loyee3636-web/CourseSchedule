export interface SectionItem {
  section: number;
  startTime: string;
  endTime: string;
}

export interface AppSettings {
  currentSemester: string;
  remindBeforeMin: number;
  sectionList: SectionItem[];
}

export const DEFAULT_SECTIONS: SectionItem[] = [
  { section: 1, startTime: '08:00', endTime: '08:45' },
  { section: 2, startTime: '08:55', endTime: '09:40' },
  { section: 3, startTime: '10:00', endTime: '10:45' },
  { section: 4, startTime: '10:55', endTime: '11:40' },
  { section: 5, startTime: '14:00', endTime: '14:45' },
  { section: 6, startTime: '14:55', endTime: '15:40' },
  { section: 7, startTime: '16:00', endTime: '16:45' },
  { section: 8, startTime: '16:55', endTime: '17:40' },
  { section: 9, startTime: '19:00', endTime: '19:45' },
  { section: 10, startTime: '19:55', endTime: '20:40' }
];

export const DEFAULT_SETTINGS: AppSettings = {
  currentSemester: '2025-2026-1',
  remindBeforeMin: 10,
  sectionList: DEFAULT_SECTIONS
};