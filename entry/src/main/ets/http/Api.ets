import { instance } from "./Axios";

//获取验证码
export function sendCode(phone: string) {
  return instance.get('/word/user/code', { params: { phone: phone } });
}

//登录
export function login(phone: string, code: string) {
  return instance.post('/word/user/login', new LoginBean(phone, code));
}

//获取全部打卡列表
export function getAllPost(page: number, size: number) {
  return instance.get('/word/post/getAll', { params: { page: page, size: size } })
}

//点赞
export function like(postId: number) {
  return instance.get('/word/like/create', { params: { postId: postId } })
}

//取消点赞
export function cancelLike(postId: number) {
  return instance.get('/word/like/cancel', { params: { postId: postId } })
}

//获取登录用户信息
export function info() {
  return instance.get('/word/user/info')
}

//获取我的登录打卡记录
export function getMyPost(page: number, size: number) {
  return instance.get('/word/post/getMine', { params: { page: page, size: size } })
}

interface PostCard {
  rightCount: number;
  answeredCount: number;
  timeUsed: number;
}

export function createPost(post: PostCard) {
  return instance.post('/word/post/create', post)
}



class LoginBean {
  phone: string;
  code: string;

  constructor(phone: string, code: string) {
    this.phone = phone;
    this.code = code;
  }
}