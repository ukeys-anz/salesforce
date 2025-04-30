import LightningAlert from "lightning/alert";

export async function openAlert() {
  await LightningAlert.open({
    message: this.message,
    label: this.title,
    variant: this.variant,
    theme: this.theme
  });
  this.addCaseComment();
}
