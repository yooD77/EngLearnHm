import { AxiosResponse } from '@ohos/axios'
import { createPost, login, sendCode } from '../http/Api'
import { promptAction, router, Router } from '@kit.ArkUI'
import emitter from '@ohos.events.emitter';

@Entry
@Component
struct LoginPage {
  @State phone: string = ""
  @State code: string = ""
  @StorageLink('token') token: string = ''
  @StorageLink('currentTabIndex') currentTabIndex: number = 0;

  build() {
    Column() {
      Image($r("app.media.ic_back"))
        .width(25)
        .height(25)
        .alignSelf(ItemAlign.Start)
        .margin({ left: 20, top: 10 })
        .onClick(() => {
          //todo 返回上一页
          router.back()
        })

      Blank()
      Column() {
        Text('欢迎登陆').fontSize(22).fontColor(Color.Black).fontWeight(FontWeight.Bold)
        Row() {
          Image($r('app.media.ic_phone')).letterIconStyle()
          TextInput({ placeholder: "请输入手机号码", text: this.phone }).inputStyle().onChange((value) => {
            this.phone = value
          })
        }.margin({ top: 30 })

        Divider().color(Color.Black)

        Row() {
          Image($r('app.media.ic_code'))
            .iconStyle()
          TextInput({ placeholder: "请输入验证码", text: this.code }).inputStyle().onChange((value) => {
            this.code = value
          })
          Button('获取验证码').buttonStyle1(Color.White, Color.Black).onClick(async () => {
            // 获取验证码
            let response: AxiosResponse = await sendCode(this.phone)
            this.code = response.data.data
          })
        }.margin({ top: 20 })

        Divider().margin({ right: 120 }).color(Color.Black)


        Button('立即登陆')
          .width('100%')
          .buttonStyle1(Color.Black, Color.White)
          .margin({ top: 50 })
          .onClick(async () => {
            // 登陆
            let response: AxiosResponse = await login(this.phone, this.code)
            this.token = response.data.data
            console.log("token:" + this.token)
            if (this.currentTabIndex === 0) {
              // todo 发送打卡请求
              let params = router.getParams()
              await createPost({
                rightCount: Reflect.get(params, 'rightCount'),
                answeredCount: Reflect.get(params, 'answeredCount'),
                timeUsed: Reflect.get(params, 'timeUsed')
              })
              promptAction.showToast({ message: '打卡成功  ' })
              emitter.emit({ eventId: 1 })
              // todo 跳转打卡圈
              this.currentTabIndex = 1
            }
            router.back()
          })
        Row() {
          Text('登陆即表示已同意').fontSize(10).fontColor('#546B9D')
          Text('《用户使用协议》').fontSize(10).fontColor('#00B3FF')
        }.margin({ top: 20 })
      }.loginBoxStyle()

      Row({ space: 10 }) {
        Image($r('app.media.ic_logo')).width(36).height(36)
        Text('快速记单词神器').fontColor('#546B9D').fontWeight(FontWeight.Bold).fontSize(20)
      }.margin({ top: 70 })

      Text('Developed by Atguigu').fontSize(12).margin(20).fontColor('#546B9D')
    }.loginStyle()
  }
}

@Extend(Button)
function buttonStyle1(bgColor: Color, fontColor: Color) {
  .type(ButtonType.Normal)
  .fontSize(14)
  .fontWeight(FontWeight.Medium)
  .borderWidth(1)
  .borderRadius(5)
  .backgroundColor(bgColor)
  .fontColor(fontColor)
}

@Extend(Image)
function iconStyle() {
  .width(24)
  .height(24)
}

@Extend(TextInput)
function inputStyle() {
  .height(40)
  .layoutWeight(1)
  .fontSize(14)
  .backgroundColor(Color.Transparent)
}

@Styles
function letterIconStyle() {
  .width(24).height(24)
}

@Styles
function loginBoxStyle() {
  .width('90%')
  .height('45%')
  .backgroundColor(Color.White)
  .borderRadius(20)
  .padding(20)
}

@Styles
function loginStyle() {
  .width('100%')
  .height('100%')
  .backgroundImage($r("app.media.img_login_bg"))
  .backgroundImageSize({ width: '100%', height: '100%' })

}