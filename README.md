# Chat走啦
<div align="center">
</div>
<div align="center">

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)   
![Swift](https://img.shields.io/badge/iOS%20-13-blue)
![Swift](https://img.shields.io/static/v1?style=flat&message=Swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=)

[![crazypoo - PTChatGPT](https://img.shields.io/static/v1?label=crazypoo&message=PTChatGPT&color=red&logo=github)](https://github.com/crazypoo/PTChatGPT "Go to GitHub repo")
[![stars - PTChatGPT](https://img.shields.io/github/stars/crazypoo/PTChatGPT?style=social)](https://github.com/crazypoo/PTChatGPT)
[![forks - PTChatGPT](https://img.shields.io/github/forks/crazypoo/PTChatGPT?style=social)](https://github.com/crazypoo/PTChatGPT)
[![GitHub release](https://img.shields.io/github/release/crazypoo/PTChatGPT?include_prereleases=&sort=semver&color=blue)](https://github.com/crazypoo/PTChatGPT/releases/)
[![issues - yoddchatgpt](https://img.shields.io/github/issues/crazypoo/PTChatGPT)](https://github.com/crazypoo/PTChatGPT/issues)
</div>

ChatGPT-iOS版,不是SwiftUI,SwiftUI,SwiftUI,(<-_<-)谁叫我不会.现在已经上架了
<div align="center">

<h2> 下载 </h2>
 
</div>

<div align="center">

[<img alt="AppStoreLink" width="100px" src="https://user-images.githubusercontent.com/92546954/219945025-697ad2cf-3f87-451a-95e5-ac191d4f20e0.png" />](https://apps.apple.com/us/app/chat%E8%B5%B0%E5%95%A6/id6446197340)
[<img alt="TestFlightLink" width="100px" src="https://user-images.githubusercontent.com/92546954/219945377-9b6c7f21-61f4-4cf9-bb8c-84cbac55f129.png" />](https://testflight.apple.com/join/6XpIFw9m)  
</div>

去openai api官網申請token就可以使用

現在支持ChatGPT和DallE

里面包含类似微信发送语音的方式来进行提问,其中语音输入使用了[OSSSpeechKit](https://github.com/crazypoo/OSSSpeechKit) ,点解唔用距本身噶库?因为距本身噶库太少功能,我在里面帮距补全,但系距呢条佬又唔pull我噶更新,所以我就唔len用距噶,距支持咩语音识别,就支持咩语音识别

聊天列表使用了3.8版本的[MessageKit](https://github.com/MessageKit/MessageKit) ,扑距街,最新版唔支持cocoapods

对于聊天列表的设置,我用了[ChromaColorPicker](https://github.com/joncardasis/ChromaColorPicker) ,来进行颜色设置

AI的API我是使用了自己魔改版的[OpenAISwift](https://github.com/adamrushy/OpenAISwift) ,因为条佬唔支持获取图片,然后真烦距唔支持cocoapods

App主框架使用了自己的工具框架[PTools](https://github.com/crazypoo/PTools)

# 主要功能
### 聊天界面
1.支持保存想要保存的回答和当前回答的问题

2.支持语音输入,这个要看[OSSSpeechKit](https://github.com/crazypoo/OSSSpeechKit)支持多少区域语言了,此功能类似微信的发送语音功能
### 设置界面
#### 主题
1.用户的头像更换

2.聊天界面对话框和文字的颜色选择

3.语言选择,简体,繁体,英语,西班牙语

4.主题设置,黑白色更换
#### Speech
1.设置[OSSSpeechKit](https://github.com/crazypoo/OSSSpeechKit)所提供的语言选项来选择
#### Chat
1.精选Q&A记录,列表支持单个删除

2.删除所有对话记录

3.删除语音输入的文件
#### API
1.更换AI的模型

2.更换AI的聪明程度

3.更改用户需要AI画画的图片大小

4.更改Token
