# PTChatGPT
ChatGPT-iOS版

去openai api官網申請token就可以使用
現在支持ChatGPT和DallE
里面包含类似微信发送语音的方式来进行提问,其中语音输入使用了OSSSpeechKit(https://github.com/crazypoo/OSSSpeechKit)(点解唔用距本身噶库?因为距本身噶库太少功能,我在里面帮距补全,但系距呢条佬又唔pull我噶更新,所以我就唔len用距噶),距支持咩语音识别,就支持咩语音识别
聊天列表使用了3.8版本的MessageKit(https://github.com/MessageKit/MessageKit),扑距街,最新版唔支持cocoapods
对于聊天列表的设置,我用了ChromaColorPicker(https://github.com/joncardasis/ChromaColorPicker),来进行颜色设置
AI的API我是使用了自己魔改版的OpenAISwift(https://github.com/adamrushy/OpenAISwift),因为条佬唔支持获取图片,然后真烦距唔支持cocoapods