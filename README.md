# Chat走啦
<div align="center">
</div>
<div align="center">

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)   
![Swift](https://img.shields.io/badge/iOS%20-15-blue)
![Swift](https://img.shields.io/static/v1?style=flat&message=Swift&color=F05138&logo=Swift&logoColor=FFFFFF&label=)

[![crazypoo - PTChatGPT](https://img.shields.io/static/v1?label=crazypoo&message=PTChatGPT&color=red&logo=github)](https://github.com/crazypoo/PTChatGPT)
[![stars - PTChatGPT](https://img.shields.io/github/stars/crazypoo/PTChatGPT?style=social)](https://github.com/crazypoo/PTChatGPT)
[![forks - PTChatGPT](https://img.shields.io/github/forks/crazypoo/PTChatGPT?style=social)](https://github.com/crazypoo/PTChatGPT)
[![GitHub release](https://img.shields.io/github/release/crazypoo/PTChatGPT?include_prereleases=&sort=semver&color=blue)](https://github.com/crazypoo/PTChatGPT/releases/)
[![issues - yoddchatgpt](https://img.shields.io/github/issues/crazypoo/PTChatGPT)](https://github.com/crazypoo/PTChatGPT/issues)
</div>

ChatGPT-iOS版,不是SwiftUI,SwiftUI,SwiftUI,😒谁叫我不会.现在已经上架了
<div align="center">

<h2> 下载 </h2>
 
</div>

<div align="center">

[<img alt="AppStoreLink" width="100px" src="https://user-images.githubusercontent.com/92546954/219945025-697ad2cf-3f87-451a-95e5-ac191d4f20e0.png" />](https://apps.apple.com/us/app/chat%E8%B5%B0%E5%95%A6/id6446197340)
[<img alt="TestFlightLink" width="100px" src="https://user-images.githubusercontent.com/92546954/219945377-9b6c7f21-61f4-4cf9-bb8c-84cbac55f129.png" />](https://testflight.apple.com/join/6XpIFw9m)  
</div>

去openai api官网申请token就可以使用

现在支持ChatGPT和DallE

代码完全开源🤪但是我还没有时间写注释

App语言支持 🇨🇳 🇭🇰 🇺🇸 🇪🇸

App主框架使用了自己的工具框架[PTools](https://github.com/crazypoo/PTools)

里面包含类似微信发送语音的方式来进行提问,其中语音输入使用了[OSSSpeechKit](https://github.com/crazypoo/OSSSpeechKit) ,为什么不用他本身的库?因为他本身的库太少功能,我在里面帮他补全,但是他又不pull我的更新,所以我就不用他的,他支持什么语音识别,就支持什么语音识别

聊天列表使用了最新版本的[MessageKit](https://github.com/MessageKit/MessageKit)

对于聊天列表的设置,我用了[ChromaColorPicker](https://github.com/joncardasis/ChromaColorPicker) ,来进行颜色设置

AI的API我是使用了自己魔改版的[OpenAISwift](https://github.com/adamrushy/OpenAISwift)(因为他不支持获取图片和模型太少,現在我又懒得改🤪)和[OpenAIKit](https://github.com/MarcoDotIO/OpenAIKit)

# 主要功能
### 聊天界面
1.支持保存想要保存的回答和当前回答的问题

2.支持语音输入,这个要看[OSSSpeechKit](https://github.com/crazypoo/OSSSpeechKit)支持多少区域语言了,此功能类似微信的发送语音功能
### 设置界面
#### 主题
1.用户的头像更换

2.聊天界面对话框和文字的颜色选择

3.语言选择 🇨🇳 🇭🇰 🇺🇸 🇪🇸

4.主题设置,黑白色更换
#### Speech
1.设置[OSSSpeechKit](https://github.com/crazypoo/OSSSpeechKit)所提供的语言选项来选择
#### Chat
1.聊天界面支持类似当前最新微信的语音发送功能,AI回答支持文字结果或者图片结果

2.聊天界面可以保存理想的结果和这个结果对应的问题

3.精选Q&A记录,列表支持单个删除

4.删除所有对话记录

5.删除语音输入的文件

6.聊天界面支持类似微信的引用功能,以作为修改某内容的展示支持

7.支持根据图片查找类似的图片

8.支持根据原图和遮罩图和需求来使AI修改图片

9.支持对AI对文字内容是否敏感的检测
#### API
1.更换AI的模型,已经支持GPT4x的模型

2.更换AI的聪明程度

3.更改用户需要AI画画的图片大小

4.支持获取图片的数量

5.更改Token

#### iCloud
支持iCloud备份同步
