import notificationManager from '@ohos.notificationManager';
import { Course } from '../model/Course';
import { SectionItem } from '../model/AppSettings';
import promptAction from '@ohos.promptAction';

export class NotificationService {
  private static instance: NotificationService | null = null;

  static getInstance(): NotificationService {
    if (NotificationService.instance === null) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  async requestPermission(): Promise<boolean> {
    try {
      const enabled: boolean = await notificationManager.isNotificationEnabled();
      if (!enabled) {
        await notificationManager.requestEnableNotification();
      }
      return true;
    } catch (e) {
      promptAction.showToast({ message: '通知权限申请失败' });
      return false;
    }
  }

  async sendInstantNotice(title: string, text: string): Promise<void> {
    const hasPermission: boolean = await this.requestPermission();
    if (!hasPermission) {
      return;
    }

    const request: notificationManager.NotificationRequest = {
      id: Math.floor(Date.now() % 100000),
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: title,
          text: text,
          additionalText: '课程表提醒'
        }
      }
    };
    await notificationManager.publish(request);
  }

  async setCourseReminder(course: Course, sections: SectionItem[], beforeMin: number): Promise<void> {
    const hasPermission: boolean = await this.requestPermission();
    if (!hasPermission || !course.isRemind) {
      return;
    }

    const startSection: SectionItem | undefined = sections[course.startSection - 1];
    if (startSection === undefined) {
      return;
    }

    const timeStr: string = startSection.startTime;
    const timeArr: string[] = timeStr.split(':');
    const hour: number = parseInt(timeArr[0]);
    const minute: number = parseInt(timeArr[1]);

    const remindTime: Date = new Date();
    remindTime.setHours(hour, minute - beforeMin, 0, 0);

    if (remindTime.getTime() < Date.now()) {
      remindTime.setDate(remindTime.getDate() + 1);
    }

    const request: notificationManager.NotificationRequest = {
      id: course.id,
      deliveryTime: remindTime.getTime(),
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '上课提醒',
          text: course.name + ' 将在 ' + beforeMin.toString() + ' 分钟后开始\n教室：' + course.classroom,
          additionalText: '课程表'
        }
      }
    };
    await notificationManager.publish(request);
  }

  async cancelCourseReminder(courseId: number): Promise<void> {
    try {
      await notificationManager.cancel(courseId);
    } catch (e) {
      // 忽略取消失败
    }
  }
}