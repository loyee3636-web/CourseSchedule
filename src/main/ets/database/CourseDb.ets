import relationalStore from '@ohos.data.relationalStore';
import { Course } from '../model/Course';

export class CourseDb {
  private static readonly DB_NAME: string = 'course.db';
  private static readonly TABLE_NAME: string = 'course';
  private static instance: CourseDb | null = null;
  private rdbStore: relationalStore.RdbStore | null = null;

  static getInstance(): CourseDb {
    if (CourseDb.instance === null) {
      CourseDb.instance = new CourseDb();
    }
    return CourseDb.instance;
  }

  async initDb(context: Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: CourseDb.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.rdbStore = await relationalStore.getRdbStore(context, config);
    const sql: string = `
      CREATE TABLE IF NOT EXISTS ${CourseDb.TABLE_NAME} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        teacher TEXT,
        classroom TEXT,
        semester TEXT NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        startSection INTEGER NOT NULL,
        endSection INTEGER NOT NULL,
        weekList TEXT NOT NULL,
        isRemind INTEGER NOT NULL DEFAULT 1
      )
    `;
    await this.rdbStore.executeSql(sql);
  }

  private courseToValues(course: Course): relationalStore.ValuesBucket {
    const values: relationalStore.ValuesBucket = {
      name: course.name,
      teacher: course.teacher,
      classroom: course.classroom,
      semester: course.semester,
      dayOfWeek: course.dayOfWeek,
      startSection: course.startSection,
      endSection: course.endSection,
      weekList: JSON.stringify(course.weekList),
      isRemind: course.isRemind ? 1 : 0
    };
    return values;
  }

  private rowToCourse(result: relationalStore.ResultSet): Course {
    const idIndex: number = result.getColumnIndex('id');
    const nameIndex: number = result.getColumnIndex('name');
    const teacherIndex: number = result.getColumnIndex('teacher');
    const classroomIndex: number = result.getColumnIndex('classroom');
    const semesterIndex: number = result.getColumnIndex('semester');
    const dayIndex: number = result.getColumnIndex('dayOfWeek');
    const startIndex: number = result.getColumnIndex('startSection');
    const endIndex: number = result.getColumnIndex('endSection');
    const weekIndex: number = result.getColumnIndex('weekList');
    const remindIndex: number = result.getColumnIndex('isRemind');

    const course: Course = {
      id: result.getLong(idIndex),
      name: result.getString(nameIndex),
      teacher: result.getString(teacherIndex),
      classroom: result.getString(classroomIndex),
      semester: result.getString(semesterIndex),
      dayOfWeek: result.getLong(dayIndex),
      startSection: result.getLong(startIndex),
      endSection: result.getLong(endIndex),
      weekList: JSON.parse(result.getString(weekIndex)) as number[],
      isRemind: result.getLong(remindIndex) === 1
    };
    return course;
  }

  async addCourse(course: Course): Promise<number> {
    if (this.rdbStore === null) {
      return -1;
    }
    return await this.rdbStore.insert(CourseDb.TABLE_NAME, this.courseToValues(course));
  }

  async deleteCourse(id: number): Promise<number> {
    if (this.rdbStore === null) {
      return 0;
    }
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseDb.TABLE_NAME);
    predicates.equalTo('id', id);
    return await this.rdbStore.delete(predicates);
  }

  async updateCourse(course: Course): Promise<number> {
    if (this.rdbStore === null) {
      return 0;
    }
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseDb.TABLE_NAME);
    predicates.equalTo('id', course.id);
    return await this.rdbStore.update(this.courseToValues(course), predicates);
  }

  async getCoursesBySemester(semester: string): Promise<Course[]> {
    if (this.rdbStore === null) {
      return [];
    }
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseDb.TABLE_NAME);
    predicates.equalTo('semester', semester);
    const result: relationalStore.ResultSet = await this.rdbStore.query(predicates);
    const list: Course[] = [];
    while (result.goToNextRow()) {
      list.push(this.rowToCourse(result));
    }
    result.close();
    return list;
  }

  async getCourseById(id: number): Promise<Course | null> {
    if (this.rdbStore === null) {
      return null;
    }
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(CourseDb.TABLE_NAME);
    predicates.equalTo('id', id);
    const result: relationalStore.ResultSet = await this.rdbStore.query(predicates);
    if (result.goToFirstRow()) {
      const course: Course = this.rowToCourse(result);
      result.close();
      return course;
    }
    result.close();
    return null;
  }

  async checkConflict(course: Course, excludeId?: number): Promise<Course[]> {
    const all: Course[] = await this.getCoursesBySemester(course.semester);
    let list: Course[] = all;
    if (excludeId !== undefined) {
      list = all.filter((item: Course): boolean => item.id !== excludeId);
    }

    return list.filter((item: Course): boolean => {
      if (item.dayOfWeek !== course.dayOfWeek) {
        return false;
      }
      if (item.endSection < course.startSection || item.startSection > course.endSection) {
        return false;
      }
      return item.weekList.some((w: number): boolean => course.weekList.indexOf(w) >= 0);
    });
  }

  async getAllSemesters(): Promise<string[]> {
    if (this.rdbStore === null) {
      return [];
    }
    const sql: string = `SELECT DISTINCT semester FROM ${CourseDb.TABLE_NAME}`;
    const result: relationalStore.ResultSet = await this.rdbStore.querySql(sql);
    const semesters: string[] = [];
    while (result.goToNextRow()) {
      semesters.push(result.getString(0));
    }
    result.close();
    return semesters;
  }
}