import preferences from '@ohos.data.preferences';
import { AppSettings, DEFAULT_SETTINGS } from '../model/AppSettings';

export class PreferencesUtil {
  private static readonly PREF_NAME: string = 'course_schedule_pref';
  private static readonly KEY_SETTINGS: string = 'settings';
  private static instance: PreferencesUtil | null = null;
  private pref: preferences.Preferences | null = null;

  static getInstance(): PreferencesUtil {
    if (PreferencesUtil.instance === null) {
      PreferencesUtil.instance = new PreferencesUtil();
    }
    return PreferencesUtil.instance;
  }

  async init(context: Context): Promise<void> {
    this.pref = await preferences.getPreferences(context, PreferencesUtil.PREF_NAME);
  }

  async getSettings(): Promise<AppSettings> {
    if (this.pref === null) {
      return DEFAULT_SETTINGS;
    }
    const value: string = await this.pref.get(PreferencesUtil.KEY_SETTINGS, JSON.stringify(DEFAULT_SETTINGS)) as string;
    return JSON.parse(value) as AppSettings;
  }

  async saveSettings(settings: AppSettings): Promise<void> {
    if (this.pref === null) {
      return;
    }
    await this.pref.put(PreferencesUtil.KEY_SETTINGS, JSON.stringify(settings));
    await this.pref.flush();
  }

  async setCurrentSemester(semester: string): Promise<void> {
    const settings: AppSettings = await this.getSettings();
    settings.currentSemester = semester;
    await this.saveSettings(settings);
  }

  async setRemindBeforeMin(min: number): Promise<void> {
    const settings: AppSettings = await this.getSettings();
    settings.remindBeforeMin = min;
    await this.saveSettings(settings);
  }
}