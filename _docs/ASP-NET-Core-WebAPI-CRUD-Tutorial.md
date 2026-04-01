---
layout: post
title: "ASP.NET Core WebAPI从零搭建：完整CRUD实战教程"
date: 2026-03-30 11:00:00 +0800
categories: [.NET, WebAPI]
tags: [ASP.NET Core, WebAPI, CRUD, Swagger, 依赖注入]
excerpt: ".NET开发中，WebAPI是最常用的场景之一（接口开发、前后端分离、服务对接都离不开），本文从零开始，搭建一个完整的ASP.NET Core WebAPI项目，实现数据的增删改查（CRUD），集成Swagger调试、依赖注入、模型校验等核心功能，新手也能轻松上手。"
---

.NET开发中，WebAPI是最常用的场景之一（接口开发、前后端分离、服务对接都离不开），本文从零开始，搭建一个完整的ASP.NET Core WebAPI项目，实现数据的增删改查（CRUD），集成Swagger调试、依赖注入、模型校验等核心功能，新手也能轻松上手，适合刚接触WebAPI的.NET开发者，也是面试中高频考察的基础技能。

## 一、环境前提（必看）

已完成第一篇《.NET 9环境搭建》（Windows/WSL2均可），确保：

- .NET 9 SDK已安装
- Visual Studio 2022已安装（勾选ASP.NET和Web开发组件）
- 可选：SQLite（轻量级数据库，无需额外安装，适合demo开发）

## 二、创建WebAPI项目（3分钟快速搭建）

### 1. 创建新项目

打开终端（Windows Terminal/WSL2），输入：

```bash
# 创建WebAPI项目
dotnet new webapi -n WebApiDemo

# 进入项目目录
cd WebApiDemo
```

### 2. 项目结构说明

```
WebApiDemo/
├── Controllers/          # 控制器层（API接口）
├── Models/              # 模型层（数据实体）
├── Properties/          # 属性配置
├── appsettings.json     # 配置文件
├── Program.cs           # 程序入口（核心配置）
└── WebApiDemo.csproj    # 项目文件
```

### 3. 运行项目验证

```bash
# 运行项目
dotnet run
```

打开浏览器访问 `https://localhost:7001/weatherforecast`（端口号可能不同），应能看到JSON响应。

## 三、核心配置（Program.cs）

打开 `Program.cs` 文件，编写以下代码（关键步骤有注释）：

```csharp
var builder = WebApplication.CreateBuilder(args);

// 1. 添加Swagger（接口调试工具，必加）
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "WebApiDemo", Version = "v1" });
});

// 2. 添加依赖注入
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();

// 3. 添加SQLite数据库
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// 4. 启用Swagger中间件
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "WebApiDemo v1"));
}

// 5. 启用HTTPS重定向
app.UseHttpsRedirection();

// 6. 启用跨域（可选）
app.UseCors(policy => policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());

// 7. 启用认证授权（可选）
app.UseAuthentication();
app.UseAuthorization();

// 8. 映射控制器
app.MapControllers();

app.Run();
```

### 配置说明

| 配置项 | 作用 | 必要性 |
|-------|------|-------|
| AddSwaggerGen | 生成Swagger文档 | ✅ 必需 |
| AddScoped | 注册服务生命周期 | ✅ 必需 |
| AddDbContext | 配置数据库上下文 | ✅ 必需 |
| UseSwagger | 启用Swagger中间件 | ✅ 必需 |
| UseHttpsRedirection | HTTPS重定向 | ✅ 必需 |
| UseCors | 跨域支持 | ⚠️ 可选 |
| UseAuthentication | 认证中间件 | ⚠️ 可选 |

## 四、创建数据模型

### 1. User实体类

在 `Models` 文件夹下创建 `User.cs`：

```csharp
public class User
{
    public int Id { get; set; }
    public string? UserName { get; set; }
    public string? Email { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

### 2. UserDto数据传输对象

在 `Models/Dtos` 文件夹下创建 `UserDto.cs`：

```csharp
public class UserDto
{
    public string? UserName { get; set; }
    public string? Email { get; set; }
}
```

### 3. 数据库上下文

在 `Data` 文件夹下创建 `AppDbContext.cs`：

```csharp
using Microsoft.EntityFrameworkCore;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .Property(u => u.CreatedAt)
            .HasDefaultValueSql("datetime('now')");
    }
}
```

## 五、创建仓储层

### 1. 仓储接口

在 `Interfaces` 文件夹下创建 `IUserRepository.cs`：

```csharp
public interface IUserRepository
{
    Task<List<User>> GetAllAsync();
    Task<User?> GetByIdAsync(int id);
    Task<User> AddAsync(User user);
    Task<bool> UpdateAsync(User user);
    Task<bool> DeleteAsync(int id);
}
```

### 2. 仓储实现

在 `Repositories` 文件夹下创建 `UserRepository.cs`：

```csharp
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<User>> GetAllAsync()
    {
        return await _context.Users.ToListAsync();
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        return await _context.Users.FindAsync(id);
    }

    public async Task<User> AddAsync(User user)
    {
        user.CreatedAt = DateTime.Now;
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }

    public async Task<bool> UpdateAsync(User user)
    {
        _context.Users.Update(user);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return false;

        _context.Users.Remove(user);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }
}
```

## 六、创建服务层

### 1. 服务接口

在 `Interfaces` 文件夹下创建 `IUserService.cs`：

```csharp
public interface IUserService
{
    Task<List<User>> GetAllUsersAsync();
    Task<User?> GetUserByIdAsync(int id);
    Task<User> AddUserAsync(UserDto userDto);
    Task<bool> UpdateUserAsync(int id, UserDto userDto);
    Task<bool> DeleteUserAsync(int id);
}
```

### 2. 服务实现

在 `Services` 文件夹下创建 `UserService.cs`：

```csharp
public class UserService : IUserService
{
    private readonly IUserRepository _repository;

    public UserService(IUserRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<User>> GetAllUsersAsync()
    {
        return await _repository.GetAllAsync();
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        return await _repository.GetByIdAsync(id);
    }

    public async Task<User> AddUserAsync(UserDto userDto)
    {
        var user = new User
        {
            UserName = userDto.UserName,
            Email = userDto.Email
        };
        return await _repository.AddAsync(user);
    }

    public async Task<bool> UpdateUserAsync(int id, UserDto userDto)
    {
        var user = await _repository.GetByIdAsync(id);
        if (user == null) return false;

        user.UserName = userDto.UserName;
        user.Email = userDto.Email;

        return await _repository.UpdateAsync(user);
    }

    public async Task<bool> DeleteUserAsync(int id)
    {
        return await _repository.DeleteAsync(id);
    }
}
```

## 七、编写CRUD接口（核心功能）

在 `Controllers` 文件夹下创建 `UsersController.cs`：

```csharp
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    // 1. 查所有用户（GET请求）
    [HttpGet]
    public async Task<ActionResult<List<User>>> GetAll()
    {
        var users = await _userService.GetAllUsersAsync();
        return Ok(users);
    }

    // 2. 按ID查用户（GET请求）
    [HttpGet("{id}")]
    public async Task<ActionResult<User>> GetById(int id)
    {
        var user = await _userService.GetUserByIdAsync(id);
        if (user == null)
        {
            return NotFound("用户不存在");
        }
        return Ok(user);
    }

    // 3. 新增用户（POST请求）
    [HttpPost]
    public async Task<ActionResult<User>> Create([FromBody] UserDto userDto)
    {
        try
        {
            var user = await _userService.AddUserAsync(userDto);
            return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
        }
        catch (Exception ex)
        {
            return BadRequest(ex.Message);
        }
    }

    // 4. 修改用户（PUT请求）
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UserDto userDto)
    {
        var result = await _userService.UpdateUserAsync(id, userDto);
        if (!result)
        {
            return NotFound("用户不存在");
        }
        return Ok("修改成功");
    }

    // 5. 删除用户（DELETE请求）
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _userService.DeleteUserAsync(id);
        if (!result)
        {
            return NotFound("用户不存在");
        }
        return Ok("删除成功");
    }
}
```

## 八、配置数据库连接

### 1. 添加SQLite包

```bash
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
```

### 2. 配置连接字符串

打开 `appsettings.json`，添加：

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=WebApiDemo.db"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

## 九、数据库迁移

### 1. 添加迁移包

```bash
dotnet add package Microsoft.EntityFrameworkCore.Design
```

### 2. 创建迁移

```bash
# 添加迁移
dotnet ef migrations add InitialCreate

# 更新数据库
dotnet ef database update
```

### 3. 验证数据库

迁移完成后，项目根目录会生成 `WebApiDemo.db` 文件。

## 十、运行与测试

### 1. 运行项目

```bash
dotnet run
```

### 2. 访问Swagger

打开浏览器访问 `https://localhost:7001/swagger`，应能看到Swagger UI界面。

### 3. 测试API

在Swagger界面中，可以测试所有CRUD接口：

- **GET /api/users** - 获取所有用户
- **GET /api/users/{id}** - 按ID获取用户
- **POST /api/users** - 新增用户
- **PUT /api/users/{id}** - 修改用户
- **DELETE /api/users/{id}** - 删除用户

## 十一、项目优化建议

### 1. 添加模型校验

在 `UserDto.cs` 中添加数据注解：

```csharp
public class UserDto
{
    [Required(ErrorMessage = "用户名不能为空")]
    [StringLength(50, ErrorMessage = "用户名不能超过50个字符")]
    public string? UserName { get; set; }

    [Required(ErrorMessage = "邮箱不能为空")]
    [EmailAddress(ErrorMessage = "邮箱格式不正确")]
    public string? Email { get; set; }
}
```

### 2. 添加全局异常处理

在 `Program.cs` 中添加：

```csharp
app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsync("{\"error\":\"服务器内部错误\"}");
    });
});
```

### 3. 添加日志记录

在 `Program.cs` 中添加：

```csharp
builder.Logging.AddConsole();
builder.Logging.AddDebug();
```

## 十二、总结

本文完整讲解了ASP.NET Core WebAPI的搭建流程，包含：

- ✅ 项目创建与结构说明
- ✅ 核心配置（Swagger、依赖注入、数据库）
- ✅ 数据模型创建（实体、DTO、上下文）
- ✅ 仓储层实现（接口、实现）
- ✅ 服务层实现（接口、实现）
- ✅ CRUD接口编写（增删改查）
- ✅ 数据库迁移与验证
- ✅ 项目优化建议

后续会讲解接口权限、性能优化、单元测试等进阶内容，欢迎收藏关注~

---

**相关文章**：
- [.NET 9环境搭建全教程（Windows+WSL双平台）](#)
- [Docker打包.NET Core项目：镜像优化+最小化部署方案](#)

**标签**：#ASP.NET Core #WebAPI #CRUD #Swagger #依赖注入 #后端开发
