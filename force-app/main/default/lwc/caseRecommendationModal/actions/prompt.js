import LightningPrompt from "lightning/prompt";

export async function openPrompt() {
  const response = await LightningPrompt.open({
    message: this.message,
    label: this.title,
    variant: this.variant,
    theme: this.theme
  });
  this.addCaseComment(response);
}
