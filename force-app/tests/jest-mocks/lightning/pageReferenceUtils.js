export const encodeDefaultFieldValues = (values) => {
  return new URLSearchParams(values).toString();
};
