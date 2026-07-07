import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import Want from '@ohos.app.ability.Want';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formData: Record<string, Object> = {} as Record<string, Object>;
    formData['todayCourses'] = [] as Object;
    return formBindingData.createFormBindingData(formData);
  }

  onUpdateForm(formId: string): formBindingData.FormBindingData {
    const formData: Record<string, Object> = {} as Record<string, Object>;
    formData['todayCourses'] = [] as Object;
    return formBindingData.createFormBindingData(formData);
  }
}