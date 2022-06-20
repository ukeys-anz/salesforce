import { FieldDefinition } from "../../types/field";
import KnowledgeFields from "./knowledgeFields";

export default new Map<string, FieldDefinition>([
  [KnowledgeFields.Title, { label: KnowledgeFields.Title, type: "text" }],
  [
    KnowledgeFields.Publication_Status,
    { label: KnowledgeFields.Publication_Status, type: "readonly" }
  ],
  [KnowledgeFields.Body, { label: KnowledgeFields.Body, type: "iframe" }]
]);
