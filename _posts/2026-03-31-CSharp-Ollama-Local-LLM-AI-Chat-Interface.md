---
layout: post
title: "C#调用Ollama本地大模型：零基础实现AI对话接口"
date: 2026-03-31 14:00:00 +0800
categories: [.NET, AI, 大模型]
tags: [C#, Ollama, 本地大模型, AI对话, .NET 9]
toc: true
---

## 前言

当下AI与开发结合已成趋势，作为.NET开发者，掌握本地大模型调用技巧，能快速实现AI对话、文本生成等功能，既保护数据隐私（无需联网上传），又能灵活集成到自己的项目中。本文基于Ollama（轻量级本地大模型部署工具），从零讲解C#如何调用本地大模型，实现完整的AI对话接口，适配.NET 9，全程实操，新手也能轻松上手，同时结合前几篇的WebAPI基础，可直接集成到已有项目中。

## 一、环境准备

- 已完成.NET 9环境搭建（Windows/WSL2均可）；

- 安装Ollama（本地大模型部署工具）：访问Ollama官网，下载对应系统版本（Windows/WSL2/Linux），默认安装即可；

- 部署本地大模型：打开终端，输入命令拉取模型（推荐轻量级模型，适合本地运行）：`ollama pull qwen:7b`（qwen:7b模型体积小、响应快，新手首选，也可替换为llama2、gemma等模型）；

- 工具：Visual Studio 2022、Postman（可选，用于调试接口）。

## 二、核心原理（快速了解）

Ollama提供了HTTP API接口，C#通过发送HTTP请求（GET/POST）与本地Ollama服务交互，实现模型调用。核心流程：启动Ollama服务 → C#封装HTTP请求 → 调用Ollama API → 解析返回结果 → 实现AI对话。

关键说明：Ollama默认启动后，服务地址为 http://localhost:11434，所有API请求都基于该地址，无需额外配置。

## 三、新建C#控制台项目（基础调用演示）

### 1. 新建项目

1. 打开Visual Studio 2022，点击“创建新项目”，搜索“控制台应用（.NET）”，选择模板，点击“下一步”；

2. 项目名称：OllamaDemo，保存路径自定义，框架选择“.NET 9”，点击“创建”。

### 2. 安装依赖包

需要安装HTTP请求相关依赖包，用于发送请求和解析JSON结果：

1. 右键项目 → “管理NuGet程序包”；

2. 搜索并安装以下两个包（最新稳定版即可）：
    - Newtonsoft.Json（解析JSON返回结果）；
    - System.Net.Http.Json（简化HTTP请求发送）。

### 3. 编写基础调用代码（单次对话）

修改Program.cs文件，编写代码调用Ollama本地模型，实现单次AI对话，关键代码有注释：

```csharp
using System.Net.Http;
using System.Net.Http.Json;
using Newtonsoft.Json;

namespace OllamaDemo;

class Program
{
    // Ollama本地服务地址（默认固定）
    private static readonly string OllamaUrl = "http://localhost:11434/api/generate";
    // 要调用的模型名称（与之前拉取的模型一致，如qwen:7b、llama2:7b）
    private static readonly string ModelName = "qwen:7b";

    static async Task Main(string[] args)
    {
        // 1. 创建HTTP客户端
        using var httpClient = new HttpClient();

        // 2. 准备请求参数（对话内容）
        var request = new
        {
            model = ModelName,
            prompt = "用C#写一个简单的HelloWorld程序，带注释", // 你的提问
            stream = false // 关闭流式返回，适合新手（流式返回需额外处理，后续进阶讲解）
        };

        try
        {
            // 3. 发送POST请求到Ollama API
            var response = await httpClient.PostAsJsonAsync(OllamaUrl, request);
            // 4. 验证请求是否成功
            response.EnsureSuccessStatusCode();

            // 5. 解析返回结果（JSON格式）
            var responseContent = await response.Content.ReadAsStringAsync();
            var result = JsonConvert.DeserializeObject<OllamaResponse>(responseContent);

            // 6. 输出AI回复
            Console.WriteLine($"AI回复：\n{result.Response}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"调用失败：{ex.Message}");
        }

        // 防止程序直接退出
        Console.ReadLine();
    }
}

// 定义Ollama返回结果的实体类（用于解析JSON）
public class OllamaResponse
{
    [JsonProperty("response")]
    public string Response { get; set; } = string.Empty;

    [JsonProperty("model")]
    public string Model { get; set; } = string.Empty;

    [JsonProperty("done")]
    public bool Done { get; set; }
}
```

### 4. 运行测试（关键步骤）

1. 先启动Ollama服务：打开终端，输入命令 `ollama serve`，启动成功后，终端会显示“listening on 127.0.0.1:11434”；

2. 回到VS，点击“启动”按钮，运行OllamaDemo项目；

3. 等待几秒（模型首次调用会加载，耗时稍长），控制台会输出AI回复的C# HelloWorld代码，说明基础调用成功。

## 四、进阶：实现上下文会话（多轮对话）

上面的代码只能实现单次对话，无法记住上下文（比如追问“修改这个程序，添加异常处理”，AI会忘记上一轮的HelloWorld程序）。下面修改代码，实现多轮上下文会话，核心是保存历史对话记录，每次请求时携带历史信息。

```csharp
using System.Net.Http;
using System.Net.Http.Json;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace OllamaDemo;

class Program
{
    private static readonly string OllamaUrl = "http://localhost:11434/api/chat"; // 对话API（区别于generate API）
    private static readonly string ModelName = "qwen:7b";
    // 保存历史对话记录（上下文）
    private static readonly List<ChatMessage> ChatHistory = new List<ChatMessage>();

    static async Task Main(string[] args)
    {
        using var httpClient = new HttpClient();

        Console.WriteLine("AI对话助手（输入'退出'结束对话）：");
        while (true)
        {
            // 输入用户提问
            Console.Write("你：");
            var userInput = Console.ReadLine();
            if (userInput == "退出") break;

            // 添加用户提问到历史记录
            ChatHistory.Add(new ChatMessage { Role = "user", Content = userInput });

            // 准备请求参数（携带历史对话）
            var request = new
            {
                model = ModelName,
                messages = ChatHistory,
                stream = false
            };

            try
            {
                var response = await httpClient.PostAsJsonAsync(OllamaUrl, request);
                response.EnsureSuccessStatusCode();

                var responseContent = await response.Content.ReadAsStringAsync();
                var result = JsonConvert.DeserializeObject<ChatResponse>(responseContent);

                // 添加AI回复到历史记录（用于上下文关联）
                ChatHistory.Add(new ChatMessage { Role = "assistant", Content = result.Message.Content });

                // 输出AI回复
                Console.WriteLine($"AI：\n{result.Message.Content}\n");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"调用失败：{ex.Message}\n");
            }
        }
    }
}

// 对话消息实体类（用户/AI的消息）
public class ChatMessage
{
    [JsonProperty("role")]
    public string Role { get; set; } = string.Empty; // role：user（用户）、assistant（AI）

    [JsonProperty("content")]
    public string Content { get; set; } = string.Empty; // 消息内容
}

// 对话API返回结果实体类
public class ChatResponse
{
    [JsonProperty("message")]
    public ChatMessage Message { get; set; } = new ChatMessage();

    [JsonProperty("done")]
    public bool Done { get; set; }
}
```

### 测试上下文会话

启动Ollama服务后，运行项目，输入以下对话，测试上下文是否生效：

1. 你：用C#写一个简单的HelloWorld程序，带注释；

2. AI：返回对应的代码；

3. 你：修改这个程序，添加异常处理；

4. AI：会基于上一轮的HelloWorld程序，添加try-catch异常处理，说明上下文会话成功。

## 五、集成到WebAPI（实战落地）

结合第二篇的WebApiDemo项目，将AI对话功能集成到WebAPI中，实现接口调用，方便前后端分离项目使用。

### 1. 新增AI对话接口（Program.cs中添加）

```csharp
// 注入HTTP客户端（用于调用Ollama API）
builder.Services.AddHttpClient();

// 后续添加AI对话接口（在CRUD接口之后）
var httpClient = app.Services.GetRequiredService<HttpClient>();
var ollamaUrl = "http://localhost:11434/api/chat";
var modelName = "qwen:7b";

// AI对话接口（POST请求，接收用户提问和历史对话）
app.MapPost("/api/ai/chat", async (ChatRequest request) =>
{
    try
    {
        // 准备Ollama请求参数
        var ollamaRequest = new
        {
            model = modelName,
            messages = request.ChatHistory,
            stream = false
        };

        // 调用Ollama API
        var response = await httpClient.PostAsJsonAsync(ollamaUrl, ollamaRequest);
        response.EnsureSuccessStatusCode();

        var responseContent = await response.Content.ReadAsStringAsync();
        var result = JsonConvert.DeserializeObject<ChatResponse>(responseContent);

        // 返回AI回复
        return Results.Ok(new { Success = true, AiResponse = result.Message.Content });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { Success = false, Message = ex.Message });
    }
});

// 定义接口请求实体类（放在Services或Models文件夹中）
public class ChatRequest
{
    public List<ChatMessage> ChatHistory { get; set; } = new List<ChatMessage>();
}
```

### 2. 调试接口

1. 启动Ollama服务（ollama serve）；

2. 启动WebApiDemo项目，打开Swagger页面（https://localhost:xxxx/swagger）；

3. 找到“/api/ai/chat”接口，点击“Try it out”，输入请求参数（示例）：
   ```json
   {
     "chatHistory": [
       {
         "role": "user",
         "content": "用C#写一个简单的HelloWorld程序"
       }
     ]
   }
   ```

4. 点击“Execute”，接口会返回AI回复，说明集成成功。

## 六、常见报错及解决方法

- 报错1：“无法连接到目标服务器 http://localhost:11434”——解决：检查Ollama服务是否启动（输入ollama serve），确保服务地址正确；

- 报错2：“model not found”——解决：确认终端输入`ollama pull qwen:7b`拉取模型，拉取完成后再启动服务；

- 报错3：请求超时、响应缓慢——解决：更换更轻量级的模型（如qwen:4b），关闭电脑后台占用内存的程序，确保本地内存≥8GB。

## 七、总结

本文从零实现了C#调用Ollama本地大模型，涵盖基础单次对话、进阶上下文会话，以及WebAPI集成实战，适配.NET 9，全程实操无废话。掌握这个技巧，可快速将AI功能集成到自己的.NET项目中（如接口文档生成、代码辅助编写、智能问答等）。后续会讲解流式返回、模型切换、Docker打包.NET+Ollama服务等进阶内容，喜欢的同学收藏关注~ 有问题评论区留言交流。

## 八、进阶技巧：流式返回（优化用户体验）

前面的案例中，我们将`stream`设为`false`，属于一次性返回完整AI回复，当模型响应较慢时，用户需要长时间等待，体验较差。流式返回（`stream=true`）可实现“边生成边返回”，类似ChatGPT的对话效果，下面修改代码实现流式调用。

### 1. 控制台项目流式返回实现

```csharp
using System.Net.Http;
using System.Net.Http.Json;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Text;

namespace OllamaDemo;

class Program
{
    private static readonly string OllamaUrl = "http://localhost:11434/api/chat";
    private static readonly string ModelName = "qwen:7b";
    private static readonly List<ChatMessage> ChatHistory = new List<ChatMessage>();

    static async Task Main(string[] args)
    {
        using var httpClient = new HttpClient();

        Console.WriteLine("AI对话助手（输入'退出'结束对话）：");
        while (true)
        {
            Console.Write("你：");
            var userInput = Console.ReadLine();
            if (userInput == "退出") break;

            ChatHistory.Add(new ChatMessage { Role = "user", Content = userInput });

            var request = new
            {
                model = ModelName,
                messages = ChatHistory,
                stream = true // 开启流式返回
            };

            try
            {
                // 发送流式请求，获取响应流
                var response = await httpClient.PostAsJsonAsync(OllamaUrl, request, CancellationToken.None);
                response.EnsureSuccessStatusCode();

                Console.Write("AI：\n");
                // 逐行读取响应流（Ollama流式返回为每行一个JSON对象）
                using var streamReader = new StreamReader(await response.Content.ReadAsStreamAsync());
                string line;
                var aiResponse = new StringBuilder();

                while ((line = await streamReader.ReadLineAsync()) != null)
                {
                    if (string.IsNullOrWhiteSpace(line)) continue;

                    // 解析每行JSON，获取当前片段
                    var result = JsonConvert.DeserializeObject<ChatResponse>(line);
                    if (result == null || string.IsNullOrWhiteSpace(result.Message.Content)) continue;

                    // 实时输出片段，实现“边生成边显示”
                    Console.Write(result.Message.Content);
                    aiResponse.Append(result.Message.Content);

                    // 当done为true时，说明响应完成
                    if (result.Done)
                    {
                        Console.WriteLine("\n");
                        // 将完整AI回复添加到历史记录
                        ChatHistory.Add(new ChatMessage { Role = "assistant", Content = aiResponse.ToString() });
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"调用失败：{ex.Message}\n");
            }
        }
    }
}

// 对话消息实体类（不变）
public class ChatMessage
{
    [JsonProperty("role")]
    public string Role { get; set; } = string.Empty;

    [JsonProperty("content")]
    public string Content { get; set; } = string.Empty;
}

// 对话API返回结果实体类（不变）
public class ChatResponse
{
    [JsonProperty("message")]
    public ChatMessage Message { get; set; } = new ChatMessage();

    [JsonProperty("done")]
    public bool Done { get; set; }
}
```

### 2. WebAPI流式返回实现

将流式返回集成到WebAPI，适配前后端分离场景，前端可通过流式接收实现实时显示AI回复：

```csharp
// 在WebApiDemo的Program.cs中添加流式对话接口
app.MapPost("/api/ai/chat/stream", async (ChatRequest request, HttpContext httpContext) =>
{
    try
    {
        var ollamaRequest = new
        {
            model = "qwen:7b",
            messages = request.ChatHistory,
            stream = true
        };

        // 发送流式请求
        var response = await httpClient.PostAsJsonAsync("http://localhost:11434/api/chat", ollamaRequest);
        response.EnsureSuccessStatusCode();

        // 配置响应头，告知前端为流式返回
        httpContext.Response.ContentType = "text/event-stream";
        httpContext.Response.Headers.CacheControl = "no-cache";
        httpContext.Response.Headers.Connection = "keep-alive";

        // 逐行读取流并推送给前端
        using var streamReader = new StreamReader(await response.Content.ReadAsStreamAsync());
        string line;
        while ((line = await streamReader.ReadLineAsync()) != null)
        {
            if (string.IsNullOrWhiteSpace(line)) continue;

            var result = JsonConvert.DeserializeObject<ChatResponse>(line);
            if (result == null || string.IsNullOrWhiteSpace(result.Message.Content)) continue;

            // 以SSE格式推送数据（前端可通过EventSource接收）
            await httpContext.Response.WriteAsync($"data: {JsonConvert.SerializeObject(result.Message.Content)}\n\n");
            await httpContext.Response.Body.FlushAsync(); // 立即推送，不缓存

            if (result.Done) break;
        }

        return Results.Ok();
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { Success = false, Message = ex.Message });
    }
});
```

### 关键说明

- 流式返回需引用`System.Text`命名空间（用于StringBuilder）；

- WebAPI流式返回采用SSE（Server-Sent Events）格式，前端可通过`EventSource`对象接收实时数据；

- 流式调用适合长文本生成场景（如代码生成、文档撰写），可显著提升用户体验。

## 九、模型切换与自定义配置（灵活适配需求）

Ollama支持多种本地大模型，可根据需求切换，同时支持自定义模型参数（如温度、最大生成长度），优化回复效果。

### 1. 模型切换方法

只需修改代码中`ModelName`的值，前提是已通过终端拉取对应模型：

```csharp
// 切换为llama2:7b模型（需先执行 ollama pull llama2:7b）
private static readonly string ModelName = "llama2:7b";

// 切换为gemma:7b模型（需先执行 ollama pull gemma:7b）
// private static readonly string ModelName = "gemma:7b";

// 切换为轻量级qwen:4b模型（适合内存较小的电脑，需先执行 ollama pull qwen:4b）
// private static readonly string ModelName = "qwen:4b";
```

### 2. 自定义模型参数

在请求参数中添加额外配置，调整AI回复的风格、长度等：

```csharp
var request = new
{
    model = ModelName,
    messages = ChatHistory,
    stream = false,
    temperature = 0.7, // 温度（0-1，值越高，回复越灵活；值越低，回复越严谨）
    max_tokens = 1024, // 最大生成长度（防止回复过长，超出内存）
    top_p = 0.9 // 采样阈值（0-1，值越低，回复越集中；值越高，回复越多样）
};
```

## 十、实战拓展：集成到WinForm桌面应用

除了控制台和WebAPI，还可将Ollama调用集成到WinForm桌面应用，实现可视化AI对话界面，步骤如下：

1. 新建WinForm项目（.NET 9），项目名称：OllamaWinFormDemo；

2. 设计界面：添加`RichTextBox`（显示对话记录）、`TextBox`（输入提问）、`Button`（发送按钮）；

3. 安装Newtonsoft.Json、System.Net.Http.Json依赖包；

4. 编写按钮点击事件（调用Ollama API，流式显示回复）：

```csharp
private async void btnSend_Click(object sender, EventArgs e)
{
    var userInput = txtInput.Text.Trim();
    if (string.IsNullOrWhiteSpace(userInput))
    {
        MessageBox.Show("请输入提问内容！");
        return;
    }

    // 显示用户提问
    richTextBox1.AppendText($"你：{userInput}\n\n");
    txtInput.Clear();

    using var httpClient = new HttpClient();
    var chatHistory = new List<ChatMessage>
    {
        new ChatMessage { Role = "user", Content = userInput }
    };

    var request = new
    {
        model = "qwen:7b",
        messages = chatHistory,
        stream = true
    };

    try
    {
        var response = await httpClient.PostAsJsonAsync("http://localhost:11434/api/chat", request);
        response.EnsureSuccessStatusCode();

        richTextBox1.AppendText("AI：\n");
        using var streamReader = new StreamReader(await response.Content.ReadAsStreamAsync());
        string line;

        while ((line = await streamReader.ReadLineAsync()) != null)
        {
            if (string.IsNullOrWhiteSpace(line)) continue;

            var result = JsonConvert.DeserializeObject<ChatResponse>(line);
            if (result == null || string.IsNullOrWhiteSpace(result.Message.Content)) continue;

            // 实时追加AI回复
            richTextBox1.AppendText(result.Message.Content);
            richTextBox1.ScrollToCaret(); // 自动滚动到末尾

            if (result.Done)
            {
                richTextBox1.AppendText("\n\n");
                break;
            }
        }
    }
    catch (Exception ex)
    {
        richTextBox1.AppendText($"调用失败：{ex.Message}\n\n");
    }
}
```

## 十一、补充报错及解决方法（新增高频问题）

- 报错4：“StreamReader读取失败，提示流已关闭”——解决：检查Ollama服务是否正常运行，若服务意外终止，重启`ollama serve`；同时确保请求参数中`stream`与读取方式匹配（流式请求对应流式读取）。

- 报错5：“前端接收流式数据乱码”——解决：WebAPI中设置响应编码为UTF-8，添加代码`httpContext.Response.ContentEncoding = Encoding.UTF8;`。

- 报错6：“拉取模型失败，提示网络超时”——解决：更换网络环境，或手动指定Ollama镜像源（国内用户可搜索“Ollama国内镜像”，修改拉取命令）。

## 十二、进阶规划（后续拓展方向）

掌握基础调用后，可进一步学习以下内容，提升实战能力：

1. Docker打包.NET+Ollama服务：将.NET项目与Ollama服务一起打包为Docker镜像，实现一键部署；

2. 模型微调：基于Ollama对模型进行微调，适配特定场景（如行业术语、自定义回复风格）；

3. 多模型对比：集成多个Ollama模型，实现模型切换、回复质量对比；

4. 权限控制：在WebAPI中添加接口权限，限制Ollama模型调用次数、频率。

## 十三、总结

本文在基础调用的基础上，补充了流式返回、模型切换、WinForm集成等进阶内容，覆盖控制台、WebAPI、桌面应用三种常见场景，适配.NET 9，全程实操可复现。C#调用Ollama本地大模型的核心是通过HTTP请求与Ollama服务交互，关键在于理解请求参数、响应格式，以及流式返回的实现逻辑。

相比在线大模型API，本地调用的优势在于数据隐私可控、无需联网、响应速度快，适合企业内部系统、离线应用等场景。后续会持续更新进阶内容，帮助大家更灵活地将AI与.NET开发结合，喜欢的同学收藏关注，有任何问题可在评论区留言交流，一起避坑成长~
