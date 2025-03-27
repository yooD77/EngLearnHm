import { font, promptAction, router } from '@kit.ArkUI'
import { AxiosResponse } from '@ohos/axios';
import { AnswerStatus } from '../enums/AnswerStatus';
import { OptionStatus } from '../enums/OptionStatus';
import { PracticeStatus } from '../enums/PraticeState'
import { createPost } from '../http/Api';
import { getRandomQuestion, Question } from '../model/Question';
import { convertMillisecondsToTime } from '../utils/DateUtil';
import emitter from '@ohos.events.emitter';

@Component
export struct PracticePage {
  @State practiceStatus: PracticeStatus = PracticeStatus.Stopped;
  @State totalCount: number = 10
  @State questions: Question[] = getRandomQuestion(this.totalCount);
  @State currentIndex: number = 0;
  @State answerStatus: AnswerStatus = AnswerStatus.Answering;
  @State selectedOption: string = '';
  @State answeredCount: number = 0
  @State rightCount: number = 0
  //controller声明
  timerController: TextTimerController = new TextTimerController();
  timeUsed: number = 0
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ResultDialog({
      answeredCount: this.answeredCount,
      rightCount: this.rightCount,
      timeUsed: this.timeUsed,
      resetPractice: () => {
        this.questions = getRandomQuestion(this.totalCount)
        this.currentIndex = 0
        this.answeredCount = 0
        this.rightCount = 0
        this.timeUsed = 0
        this.timerController.reset()
        this.answerStatus = AnswerStatus.Answering
      },
      startPractice: () => {
        this.startPractice()
      }
    }), autoCancel: false,
    customStyle: true
  })

  startPractice() {
    this.practiceStatus = PracticeStatus.Running
    //启动计时器
    this.timerController.start()
  }

  pausedPractice() {
    this.practiceStatus = PracticeStatus.Paused
    //停止计时器
    this.timerController.pause()

  }

  stopPractice() {
    this.practiceStatus = PracticeStatus.Stopped;
    //停止计时器
    this.timerController.pause()
    //弹窗
    this.dialogController.open()
  }

  build() {
    Column() {
      Column() {
        //todo:统计面板
        //准确率
        StatItem({
          icon: $r('app.media.ic_accuracy'),
          name: '准确率',

        }) {
          //大括号传入ui组件
          //toFixed()-->传入参数保留几位小数
          Text((this.answeredCount === 0 ? 0 : this.rightCount / this.answeredCount * 100).toFixed() + "% ")
            .width(100)
            .textAlign(TextAlign.Center)
        }

        //进度
        StatItem({
          icon: $r('app.media.ic_progress'),
          name: '进度',

        }) {
          Progress({ value: this.answeredCount, total: this.totalCount }).width(100)
        }

        //个数
        StatItem({
          icon: $r('app.media.ic_count'),
          name: '个数',

        }) {
          // Text('10').backgroundColor("#55aaaaaa").height(25).width(100).borderRadius(20 ).textAlign(TextAlign.Center)

          Button(this.totalCount.toString())
            .width(100)
            .height(25)
            .backgroundColor('#ebebeb')
            .fontColor(Color.Black)
            .onClick(() => {
              TextPickerDialog.show({
                range: ['5', '10', '15', '20'],
                value: this.totalCount.toString(),
                onAccept: (result) => {
                  this.totalCount = parseInt(result.value.toString())
                  this.questions = getRandomQuestion(this.totalCount)
                }
              })
            })
            .enabled(this.practiceStatus == PracticeStatus.Stopped)
        }

        //用时
        StatItem({
          icon: $r('app.media.ic_timer'),
          name: '用时',
          fontColor: Color.Black
        }) {
          Row() {
            TextTimer({ controller: this.timerController })
              .onTimer((utc, elapsedTime) => {
                this.timeUsed = elapsedTime * 10
              })
          }.width(100)
          .justifyContent(FlexAlign.Center)
        }

      }.stateBgStyle()

      //题目
      Column() {
        Text(this.questions[this.currentIndex].word)
          .wordStyle()
        Text(this.questions[this.currentIndex].sentence)
          .sentenceStyle()
      }

      //选项
      Column({ space: 10 }) {
        ForEach(this.questions[this.currentIndex].options, (option: string) => {
          OptionButton({
            optionContent: option,
            answerStatus: this.answerStatus,
            answer: this.questions[this.currentIndex].answer,
            selectedOption: this.selectedOption
          })
            .enabled(this.answerStatus === AnswerStatus.Answering)
            .onClick(() => {
              //判断练习状态
              if (this.practiceStatus !== PracticeStatus.Running) {
                promptAction.showToast({ message: '请先点击开始测试' })
                return
              }
              //判断正误
              this.selectedOption = option;


              //更新 统计信息
              this.answeredCount++
              if (option === this.questions[this.currentIndex].answer) {
                this.rightCount++
              }

              //切换题目
              this.answerStatus = AnswerStatus.Answered
              if (this.currentIndex < this.questions.length - 1) {
                setTimeout(() => {
                  this.currentIndex++
                  this.answerStatus = AnswerStatus.Answering
                }, 500)
              } else {
                this.stopPractice()

              }
            })
        }, (option: String) => this.questions[this.currentIndex].word + '-' + option)
      }

      //控制容器
      Row({ space: 50 }) {
        Button('停止测试')
          .controlButtonStyle({
            bg: Color.Transparent,
            font: this.practiceStatus === PracticeStatus.Stopped ? Color.Gray : Color.Black,
            border: this.practiceStatus === PracticeStatus.Stopped ? Color.Gray : Color.Black
          })
          .onClick(() => {
            this.stopPractice()
          })
          .enabled(this.practiceStatus !== PracticeStatus.Stopped)
        Button(this.practiceStatus === PracticeStatus.Running ? '暂停测试' : '开始测试')
          .controlButtonStyle({
            bg: this.practiceStatus === PracticeStatus.Running ? Color.Gray : Color.Black,
            font: Color.White,
            border: this.practiceStatus === PracticeStatus.Running ? Color.Gray : Color.Black
          })
          .stateEffect(false)
          .onClick(() => {
            if (this.practiceStatus === PracticeStatus.Running) {
              this.stopPractice()
            } else {
              this.startPractice()
            }
          })
      }
    }.practiceBgStyle()
  }
}

class MyComponent {
  resetPractice: () => void;

  constructor() {
    this.resetPractice = () => {
      // 方法的实现
    };
  }
}


@CustomDialog
struct ResultDialog {
  answeredCount: number = 0
  rightCount: number = 0
  timeUsed: number = 0
  resetPractice: () => void = () => {
  }; // 添加默认值
  startPractice: () => void = () => {
  }; // 添加默认值
  controller: CustomDialogController = new CustomDialogController({
    builder: ResultDialog()
  })
  @StorageProp('token') token: string = ''
  @StorageLink('currentTabIndex') currentTabIndex: number = 0;

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.ic_close'))
        .width(25)
        .height(25)
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          this.resetPractice?.()
          this.controller.close()

        })

      Column({ space: 10 }) {
        Image($r('app.media.img_post'))
          .width('100%')
          .borderRadius(10)
        StatItem({
          icon: $r('app.media.ic_timer'),
          name: '用时',
          fontColor: Color.Black
        }) {
          Text(convertMillisecondsToTime(this.timeUsed))
          // Text(this.timeUsed + "")
        }

        StatItem({
          icon: $r('app.media.ic_accuracy'),
          name: '准确率',
          fontColor: Color.Black
        }) {
          Text((this.answeredCount == 0 ? 0 : this.rightCount / this.answeredCount * 100).toFixed() + "%")
        }

        StatItem({
          icon: $r('app.media.ic_count'),
          name: '个数',
          fontColor: Color.Black
        }) {
          Text(this.answeredCount.toString())
        }

        Divider()

        Row({ space: 30 }) {
          Button('再来一局')
            .controlButtonStyle({
              bg: Color.Transparent,
              border: Color.Black,
              font: Color.Black
            }).onClick(() => {
            this.controller.close()
            this.resetPractice()
            this.startPractice()
          })
          Button(this.token ? '立即打卡' : '登陆打卡')
            .controlButtonStyle({
              bg: Color.Black,
              border: Color.Black,
              font: Color.White
            }).onClick(async () => {
            this.controller.close()
            this.resetPractice()
            // 登陆并打卡
            if (this.token) {
              await createPost({
                rightCount: this.rightCount,
                answeredCount: this.answeredCount,
                timeUsed: this.timeUsed
              })
              promptAction.showToast({ message: '打卡成功' })
              //通知
              emitter.emit({ eventId: 1 })
              //  发送打卡请求
              //  跳转  打卡圈
              this.currentTabIndex = 1
            } else {
              // 跳转到登陆页面-->登陆成功后执行下列两步
              router.pushUrl({
                url: 'pages/LoginPage', params: {
                  rightCount: this.rightCount,
                  answeredCount: this.answeredCount,
                  timeUsed: this.timeUsed
                }
              })
              // todo 发送打卡请求
              // todo 跳转打卡圈
            }
          })
        }

      }.backgroundColor(Color.White)
      .width('100%')
      .padding(20)
      .borderRadius(10)
    }
    .backgroundColor(Color.Transparent)
    .width('80%')
  }
}


@Builder
function MyBuilderFunction(): void {
}


@Component
export struct StatItem {
  @BuilderParam statComp: () => void = MyBuilderFunction
  icon: Resource | string = ''
  name: string = ''
  fontColor: Color | string = ''

  build() {
    Row({ space: 10 }) {
      Image(this.icon).height(14).width(14)
      Text(this.name).fontWeight(FontWeight.Medium).fontSize(14).fontColor(this.fontColor)
      Blank()
      this.statComp()
    }
    .width('100%')
    .height(30)
  }
}

@Extend(Column)
function practiceBgStyle() {
  .width('100%')
  .height('100%')
  .backgroundImage($r('app.media.img_practice_bg'))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.SpaceEvenly)

}

@Styles
function stateBgStyle() {
  .backgroundColor(Color.White)
  .width('90%')
  .borderRadius(10)
  .padding(20)
}


@Extend(Text)
function wordStyle() {
  .fontSize(50)
  .fontWeight(FontWeight.Bold)
}

@Extend(Text)
function sentenceStyle() {
  .height(40)
  .fontSize(16)
  .fontColor('#9ba1a5')
  .fontWeight(FontWeight.Medium)
  .width('80%')
  .textAlign(TextAlign.Center)
}


interface ColorOptionChange {
  bg: ResourceColor;
  font: ResourceColor;
}

@Extend(Button)
function optionButtonStyle(color: ColorOptionChange) {
  .width(240)
  .height(48)
  .fontSize(16)
  .type(ButtonType.Normal)
  .fontWeight(FontWeight.Medium)
  .borderRadius(8)
  .backgroundColor(color.bg)
  .fontColor(color.font)
}

interface ControlButton {
  bg: ResourceColor;
  font: ResourceColor;
  border: ResourceColor;
}

@Extend(Button)
function controlButtonStyle(color: ControlButton) {
  .borderRadius(10)
  .backgroundColor(color.bg)
  .borderColor(color.border)
  .borderWidth(1)
  .fontColor(color.font)
  .fontSize(16)
}

@Component
struct OptionButton {
  optionContent: string = '';
  answer: string = ' ';
  //先声明的先更新 后声明的后更新
  @State optionStatus: OptionStatus = OptionStatus.Default
  @Prop selectedOption: string
  @Prop @Watch('onAnswerStatusChange') answerStatus: AnswerStatus

  onAnswerStatusChange() {
    if (this.optionContent == this.answer) {
      this.optionStatus = OptionStatus.Right
    } else {
      if (this.optionContent == this.selectedOption) {
        this.optionStatus = OptionStatus.Wrong
      } else {
        this.optionStatus = OptionStatus.Default;
      }
    }
  }

  getBgColor() {
    switch (this.optionStatus) {
      case OptionStatus.Right:
        return "#1DBF7B"
      case OptionStatus.Wrong:
        return "#FA635F"
      case OptionStatus.Default:
        return Color.White
    }
  }

  build() {
    Stack() {
      Button(this.optionContent)
        .optionButtonStyle({
          bg: this.getBgColor(),
          font: this.optionStatus == OptionStatus.Default ? Color.Black : Color.White
        })
      if (this.optionStatus === OptionStatus.Right) {
        Image($r('app.media.ic_right'))
          .width(22)
          .height(22)
          .offset({ x: 10 })
      } else if (this.optionStatus === OptionStatus.Wrong) {
        Image($r('app.media.ic_wrong'))
          .width(22)
          .height(22)
          .offset({ x: 10 })
      }
    }.alignContent(Alignment.Start)
  }
}
