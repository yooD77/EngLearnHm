export interface PostBean {
  id: number;
  postText: string;
  rightCount: number;
  answeredCount: number;
  timeUsed: number;
  createTime: string;
  likeCount: number;
  nickname: string;
  avatarUrl: string;
  isLike: boolean;
}

@Observed
export class PostInfo {
  id: number;
  postText: string;
  rightCount: number;
  answeredCount: number;
  timeUsed: number;
  createTime: string;
  likeCount: number;
  nickname: string;
  avatarUrl: string
  isLike: boolean;

  constructor(post: PostBean) {
    this.id = post.id;
    this.postText = post.postText;
    this.rightCount = post.rightCount;
    this.answeredCount = post.answeredCount;
    this.timeUsed = post.timeUsed;
    this.createTime = post.createTime;
    this.likeCount = post.likeCount;
    this.nickname = post.nickname;
    this.avatarUrl = post.avatarUrl;
    this.isLike = post.isLike;
  }
}