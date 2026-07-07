export interface Course {
  id: number;
  name: string;
  teacher: string;
  classroom: string;
  semester: string;
  dayOfWeek: number;
  startSection: number;
  endSection: number;
  weekList: number[];
  isRemind: boolean;
}