export default interface IChatter {
  postChatterComment(commentType?: string): Promise<void>;
  verifyChatterComment(commentType?: string): Promise<void>;
}
