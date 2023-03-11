# PTChatGPT
ChatGPT-iOS版,不是SwiftUI,SwiftUI,SwiftUI,(<-_<-)谁叫我不会.

去openai api官網申請token就可以使用
現在支持ChatGPT和DallE
里面包含类似微信发送语音的方式来进行提问,其中语音输入使用了OSSSpeechKit(https://github.com/crazypoo/OSSSpeechKit) ,点解唔用距本身噶库?因为距本身噶库太少功能,我在里面帮距补全,但系距呢条佬又唔pull我噶更新,所以我就唔len用距噶,距支持咩语音识别,就支持咩语音识别
聊天列表使用了3.8版本的MessageKit(https://github.com/MessageKit/MessageKit) ,扑距街,最新版唔支持cocoapods
对于聊天列表的设置,我用了ChromaColorPicker(https://github.com/joncardasis/ChromaColorPicker) ,来进行颜色设置
AI的API我是使用了自己魔改版的OpenAISwift(https://github.com/adamrushy/OpenAISwift) ,因为条佬唔支持获取图片,然后真烦距唔支持cocoapods

# 主要功能
### 聊天界面
1.支持保存想要保存的回答和当前回答的问题
2.支持语音输入,这个要看OSSSpeechKit支持多少区域语言了,此功能类似微信的发送语音功能
### 设置界面
#### 主题
1.用户的头像更换
2.聊天界面对话框和文字的颜色选择
3.语言选择,简体,繁体,英语,西班牙语
4.主题设置,黑白色更换
#### Speech
1.设置OSSSpeechKit所提供的语言选项来选择
#### Chat
1.精选Q&A记录,列表支持单个删除
2.删除所有对话记录
3.删除语音输入的文件
#### API
1.更换AI的模型
2.更换AI的聪明程度
3.更改用户需要AI画画的图片大小
4.更改Token
