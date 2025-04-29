import LightningConfirm from "lightning/confirm";

export async function openConfirm() {
  const confirmed = await LightningConfirm.open({
    message: this.message,
    label: this.title,
    variant: this.variant,
    theme: this.theme
  });

  if (!confirmed) {
    this.showWarning();
    return;
  }
  this.addCaseComment();
}
