--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                         YYS UI LIBRARY  •  v3.1                            ║
║           Pink Theme  •  Floating Icon  •  Full Professional API             ║
║                                                                              ║
║  Usage:                                                                      ║
║    local Library = loadstring(game:HttpGet("YOUR_RAW_LINK"))()               ║
║    local Window  = Library:CreateWindow({                                    ║
║        Title    = "YYS Hub",                                            ║
║        SubTitle = "YYS V10",                                            ║
║    })                                                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ContentProvider  = game:GetService("ContentProvider")
local LocalPlayer      = Players.LocalPlayer
if not LocalPlayer then return end

-- ═══════════════════════════════════════════════════════════════
--  FIXED CONFIG  (edit di sini saja)
-- ═══════════════════════════════════════════════════════════════
local LOGO_ASSET_ID = 18946113650  -- ganti dengan Asset ID logo kamu
local WINDOW_SIZE_X = 360
local WINDOW_SIZE_Y = 360
local TOGGLE_KEY    = Enum.KeyCode.RightControl

-- ═══════════════════════════════════════════════════════════════
--  INTERNAL UTILS
-- ═══════════════════════════════════════════════════════════════
local function randName(n)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local t = table.create(n)
    for i = 1, n do
        local k = math.random(1, #chars)
        t[i] = chars:sub(k, k)
    end
    return table.concat(t)
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(o, r)
    return make("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o)
end

local function pad(o, t, r, b, l)
    return make("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
    }, o)
end

local C = {
    BG     = Color3.fromRGB(18, 10, 18),
    PANEL  = Color3.fromRGB(32, 18, 32),
    HOVER  = Color3.fromRGB(48, 28, 48),
    PINK   = Color3.fromRGB(255, 105, 180),
    PINK2  = Color3.fromRGB(255, 160, 210),
    DEEP   = Color3.fromRGB(140, 40, 90),
    WHITE  = Color3.fromRGB(255, 255, 255),
    GRAY   = Color3.fromRGB(170, 140, 165),
    HI     = Color3.fromRGB(255, 220, 240),
    GREEN  = Color3.fromRGB(80, 220, 140),
    RED    = Color3.fromRGB(255, 90, 110),
}

local function sweepSeq(base, hi)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, base),
        ColorSequenceKeypoint.new(0.38, base),
        ColorSequenceKeypoint.new(0.50, hi),
        ColorSequenceKeypoint.new(0.62, base),
        ColorSequenceKeypoint.new(1.00, base),
    })
end

-- ═══════════════════════════════════════════════════════════════
--  LIBRARY TABLE
-- ═══════════════════════════════════════════════════════════════
local Library = {
    _version = "3.1",
    _windows = {},
}

local env = (getgenv and getgenv()) or _G
if env.__YYSLibCleanup then pcall(env.__YYSLibCleanup) end

local allTweens = {}
local allConns  = {}
local sweepGens = {}

local function trackTween(tw)
    table.insert(allTweens, tw)
    return tw
end

local function trackConn(conn)
    table.insert(allConns, conn)
    return conn
end

local function addSweep(inst, base, hi)
    local g = make("UIGradient", {
        Color  = sweepSeq(base, hi),
        Offset = Vector2.new(-1, 0),
    }, inst)
    sweepGens[g] = true
    return g
end

local function shine(label, base)
    label.TextColor3 = C.WHITE
    return addSweep(label, base or C.PINK2, C.WHITE)
end

local function glowFill(frame, base)
    frame.BackgroundColor3 = C.WHITE
    return addSweep(frame, base or C.PINK, C.HI)
end

local function glowStroke(obj, th)
    local s = make("UIStroke", {
        Color = C.WHITE,
        Thickness = th or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
    addSweep(s, C.PINK, C.WHITE)
    return s
end

local function spinStroke(st)
    local sg = make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, C.DEEP),
            ColorSequenceKeypoint.new(0.35, C.PINK),
            ColorSequenceKeypoint.new(0.50, C.WHITE),
            ColorSequenceKeypoint.new(0.65, C.PINK),
            ColorSequenceKeypoint.new(1.00, C.DEEP),
        }),
    }, st)
    local tw = TweenService:Create(sg,
        TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0),
        { Rotation = 360 })
    tw:Play()
    trackTween(tw)
end

local function applyLogo(holder, sizeOffset)
    sizeOffset = sizeOffset or 6
    if not LOGO_ASSET_ID or tonumber(LOGO_ASSET_ID) == nil or tonumber(LOGO_ASSET_ID) == 0 then
        return
    end
    local img = make("ImageLabel", {
        Size = UDim2.new(1, -sizeOffset, 1, -sizeOffset),
        Position = UDim2.fromOffset(sizeOffset / 2, sizeOffset / 2),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Image = "rbxassetid://" .. tostring(LOGO_ASSET_ID),
        Visible = false,
        ZIndex = (holder.ZIndex or 1) + 1,
    }, holder)
    task.spawn(function()
        pcall(function()
            ContentProvider:PreloadAsync({ img }, function(_, status)
                if status == Enum.AssetFetchStatus.Success and img.Parent then
                    img.Visible = true
                    if holder:IsA("TextLabel") then
                        holder.Text = ""
                    end
                end
            end)
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  MOUNT GUI
-- ═══════════════════════════════════════════════════════════════
local function coreGuiOk()
    local okc, core = pcall(function() return game:GetService("CoreGui") end)
    if not okc or not core then return nil end
    local test = pcall(function()
        local f = Instance.new("Folder")
        f.Parent = core
        f:Destroy()
    end)
    return test and core or nil
end

local function mountGui(g)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(g)
        elseif protectgui then
            protectgui(g)
        elseif protect_gui then
            protect_gui(g)
        end
    end)
    local target = coreGuiOk()
    if not target then
        local okh, ui = pcall(function() return gethui and gethui() end)
        if okh and ui then target = ui end
    end
    if not target then
        target = LocalPlayer:WaitForChild("PlayerGui")
    end
    local okp = pcall(function() g.Parent = target end)
    if not okp or not g.Parent then
        g.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local rootGui = make("ScreenGui", {
    Name = randName(18),
    ResetOnSpawn = false,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})
mountGui(rootGui)

local sweepVal = make("NumberValue", { Value = -1 }, rootGui)
trackConn(sweepVal.Changed:Connect(function(v)
    local off = Vector2.new(v, 0)
    for g in pairs(sweepGens) do
        if g.Parent then
            g.Offset = off
        else
            sweepGens[g] = nil
        end
    end
end))
do
    local tw = TweenService:Create(sweepVal,
        TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 0),
        { Value = 1 })
    tw:Play()
    trackTween(tw)
end

local function destroyAll()
    for _, tw in ipairs(allTweens) do pcall(function() tw:Cancel() end) end
    for _, c in ipairs(allConns) do pcall(function() c:Disconnect() end) end
    table.clear(sweepGens)
    if rootGui and rootGui.Parent then rootGui:Destroy() end
    env.__YYSLibCleanup = nil
end
env.__YYSLibCleanup = destroyAll
Library.Destroy = destroyAll

-- ═══════════════════════════════════════════════════════════════
--  GLOBAL NOTIFY
-- ═══════════════════════════════════════════════════════════════
local notifFrame = make("Frame", {
    Size = UDim2.fromOffset(280, 44),
    Position = UDim2.new(0.5, -140, 0, -70),
    BackgroundColor3 = C.BG,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 200,
}, rootGui)
corner(notifFrame, 10)
glowStroke(notifFrame, 1.2)

local notifText = make("TextLabel", {
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = C.WHITE,
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 201,
}, notifFrame)

function Library:Notify(text, duration)
    duration = duration or 2.8
    notifText.Text = tostring(text)
    notifFrame.Visible = true
    notifFrame.Position = UDim2.new(0.5, -140, 0, -70)
    TweenService:Create(notifFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -140, 0, 18)
    }):Play()
    task.delay(duration, function()
        if not notifFrame.Parent then return end
        local tw = TweenService:Create(notifFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.5, -140, 0, -70)
        })
        tw:Play()
        tw.Completed:Wait()
        if notifFrame.Parent then notifFrame.Visible = false end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local Title    = cfg.Title or cfg.title or "YYS Hub"
    local SubTitle = cfg.SubTitle or cfg.Subtitle or cfg.subtitle or "YYS Hub"

    local HEADER_H = 48
    local W, H = WINDOW_SIZE_X, WINDOW_SIZE_Y

    -- Floating Icon
    local floatBtn = make("TextButton", {
        Name = "FloatIcon",
        Size = UDim2.fromOffset(52, 52),
        Position = UDim2.new(1, -70, 0.5, -26),
        BackgroundColor3 = C.WHITE,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 50,
        Visible = false,
    }, rootGui)
    corner(floatBtn, 14)
    glowFill(floatBtn, C.PINK)
    spinStroke(make("UIStroke", {
        Color = C.WHITE,
        Thickness = 1.8,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, floatBtn))

    local floatLbl = make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "Y",
        TextColor3 = C.WHITE,
        Font = Enum.Font.GothamBlack,
        TextSize = 24,
        ZIndex = 51,
    }, floatBtn)
    applyLogo(floatLbl, 8)

    do
        local dragging, dragStart, startPos
        floatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, floatBtn.Position
            end
        end)
        trackConn(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                floatBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end))
        trackConn(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end

    -- Main Window
    local main = make("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(W, H),
        Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
        BackgroundColor3 = C.BG,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
    }, rootGui)
    corner(main, 12)
    local scale = make("UIScale", { Scale = 1 }, main)
    spinStroke(make("UIStroke", {
        Color = C.WHITE,
        Thickness = 1.6,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, main))

    local header = make("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, HEADER_H),
        BackgroundTransparency = 1,
    }, main)

    local logoBg = make("Frame", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.fromOffset(12, 8),
        BorderSizePixel = 0,
        BackgroundColor3 = C.WHITE,
    }, header)
    corner(logoBg, 9)
    glowFill(logoBg, C.PINK)
    local logoLbl = make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "Y",
        TextColor3 = C.WHITE,
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
    }, logoBg)
    applyLogo(logoLbl, 6)

    local titleLbl = make("TextLabel", {
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.fromOffset(54, 7),
        BackgroundTransparency = 1,
        Text = Title,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    shine(titleLbl, C.PINK2)

    local subLbl = make("TextLabel", {
        Size = UDim2.fromOffset(0, 14),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.fromOffset(54, 26),
        BackgroundTransparency = 1,
        Text = SubTitle,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    shine(subLbl, C.GRAY)

    local minBtn = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -70, 0, 10),
        BackgroundColor3 = C.PANEL,
        Text = "−",
        TextColor3 = C.WHITE,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
        ZIndex = 6,
    }, header)
    corner(minBtn, 8)
    glowStroke(minBtn, 1)

    local closeBtn = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -36, 0, 10),
        BackgroundColor3 = C.PANEL,
        Text = "×",
        TextColor3 = C.WHITE,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
        ZIndex = 6,
    }, header)
    corner(closeBtn, 8)
    glowStroke(closeBtn, 1)

    local dragArea = make("Frame", {
        Size = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 5,
    }, header)

    local line = make("Frame", {
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.fromOffset(12, HEADER_H),
        BorderSizePixel = 0,
        BackgroundColor3 = C.WHITE,
    }, main)
    addSweep(line, C.DEEP, C.PINK2)

    local body = make("ScrollingFrame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -(HEADER_H + 1)),
        Position = UDim2.fromOffset(0, HEADER_H + 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.PINK,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, main)
    pad(body, 10, 12, 14, 12)

    make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, body)

    local order = 0
    local function nextOrder()
        order = order + 1
        return order
    end

    local Window = {
        _main = main,
        _body = body,
        _elements = {},
    }

    local minimized = false
    local function showMain(v)
        if v then
            floatBtn.Visible = false
            main.Visible = true
            scale.Scale = 0.85
            TweenService:Create(scale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Scale = 1
            }):Play()
        else
            main.Visible = false
            floatBtn.Visible = true
        end
    end

    minBtn.MouseEnter:Connect(function() minBtn.BackgroundColor3 = C.HOVER end)
    minBtn.MouseLeave:Connect(function() minBtn.BackgroundColor3 = C.PANEL end)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            body.Visible = false
            line.Visible = false
            minBtn.Text = "+"
            TweenService:Create(main, TweenInfo.new(0.22), {
                Size = UDim2.fromOffset(W, HEADER_H)
            }):Play()
        else
            minBtn.Text = "−"
            TweenService:Create(main, TweenInfo.new(0.22), {
                Size = UDim2.fromOffset(W, H)
            }):Play()
            task.delay(0.22, function()
                if not minimized and body.Parent then
                    body.Visible = true
                    line.Visible = true
                end
            end)
        end
    end)

    closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = C.HOVER end)
    closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = C.PANEL end)
    closeBtn.MouseButton1Click:Connect(function()
        showMain(false)
    end)

    floatBtn.MouseButton1Click:Connect(function()
        showMain(true)
    end)

    do
        local dragging, dragStart, startPos
        dragArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, main.Position
            end
        end)
        trackConn(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end))
        trackConn(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end

    trackConn(UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == TOGGLE_KEY then
            if main.Visible then
                showMain(false)
            else
                showMain(true)
            end
        end
    end))

    -- Loading Screen
    local loading = make("Frame", {
        Size = UDim2.fromOffset(280, 130),
        Position = UDim2.new(0.5, -140, 0.5, -65),
        BackgroundColor3 = C.BG,
        BorderSizePixel = 0,
    }, rootGui)
    corner(loading, 12)
    spinStroke(make("UIStroke", {
        Color = C.WHITE,
        Thickness = 1.6,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, loading))

    local lLogo = make("Frame", {
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.fromOffset(16, 16),
        BorderSizePixel = 0,
        BackgroundColor3 = C.WHITE,
    }, loading)
    corner(lLogo, 11)
    glowFill(lLogo, C.PINK)
    local lLogoLbl = make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "Y",
        TextColor3 = C.WHITE,
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
    }, lLogo)
    applyLogo(lLogoLbl, 6)

    local lTitle = make("TextLabel", {
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.fromOffset(68, 16),
        BackgroundTransparency = 1,
        Text = Title,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, loading)
    shine(lTitle, C.PINK2)

    local lSub = make("TextLabel", {
        Size = UDim2.fromOffset(0, 14),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.fromOffset(68, 38),
        BackgroundTransparency = 1,
        Text = SubTitle,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, loading)
    shine(lSub, C.GRAY)

    local track = make("Frame", {
        Size = UDim2.new(1, -32, 0, 8),
        Position = UDim2.fromOffset(16, 78),
        BackgroundColor3 = C.PANEL,
        BorderSizePixel = 0,
    }, loading)
    corner(track, 4)
    local fill = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
    }, track)
    corner(fill, 4)
    glowFill(fill, C.PINK)

    local lText = make("TextLabel", {
        Size = UDim2.new(1, -80, 0, 16),
        Position = UDim2.fromOffset(16, 96),
        BackgroundTransparency = 1,
        Text = "Memuat...",
        TextColor3 = C.GRAY,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, loading)
    local lPct = make("TextLabel", {
        Size = UDim2.fromOffset(48, 16),
        Position = UDim2.new(1, -64, 0, 96),
        BackgroundTransparency = 1,
        Text = "0%",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, loading)
    shine(lPct, C.PINK2)

    task.spawn(function()
        local steps = { "Menyiapkan UI", "Memuat komponen", "Memuat tema pink", "Selesai" }
        for i, text in ipairs(steps) do
            if not rootGui.Parent then return end
            lText.Text = text
            TweenService:Create(fill, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
                Size = UDim2.new(i / #steps, 0, 1, 0)
            }):Play()
            lPct.Text = math.floor(i / #steps * 100) .. "%"
            task.wait(0.35)
        end
        task.wait(0.1)
        if not rootGui.Parent then return end
        loading:Destroy()
        scale.Scale = 0.85
        main.Visible = true
        TweenService:Create(scale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1
        }):Play()
    end)

    -- ═══════════════════════════════════════════════════════════
    --  ELEMENT CREATORS
    -- ═══════════════════════════════════════════════════════════

    function Window:CreateSection(text)
        local f = make("Frame", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
        }, body)
        local lbl = make("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "•  " .. tostring(text),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = C.PINK2,
        }, f)
        shine(lbl, C.PINK2)
        return f
    end

    function Window:CreateLabel(cfg)
        cfg = type(cfg) == "table" and cfg or { Text = tostring(cfg) }
        local f = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
        }, body)
        local lbl = make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = cfg.Text or "",
            TextColor3 = C.GRAY,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        }, f)
        local api = {}
        function api:SetText(t)
            lbl.Text = tostring(t)
        end
        return api
    end

    function Window:CreateButton(cfg)
        cfg = cfg or {}
        local Name     = cfg.Name or cfg.Text or "Button"
        local Callback = cfg.Callback or function() end

        local b = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = C.PANEL,
            Text = Name,
            TextColor3 = C.WHITE,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            AutoButtonColor = false,
            LayoutOrder = nextOrder(),
        }, body)
        corner(b, 8)
        glowStroke(b, 1)

        b.MouseEnter:Connect(function() b.BackgroundColor3 = C.HOVER end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = C.PANEL end)
        b.MouseButton1Click:Connect(function()
            local ok, err = pcall(Callback)
            if not ok then warn("[YYS] Button error: " .. tostring(err)) end
        end)

        local api = {}
        function api:SetText(t)
            b.Text = tostring(t)
        end
        return api
    end

    function Window:CreateToggle(cfg)
        cfg = cfg or {}
        local Name     = cfg.Name or "Toggle"
        local Default  = cfg.Default or false
        local Callback = cfg.Callback or function() end

        local state = Default

        local btn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = C.PANEL,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = nextOrder(),
        }, body)
        corner(btn, 8)
        glowStroke(btn, 1)

        local fillFrame = make("Frame", {
            Size = UDim2.fromScale(1, 1),
            BorderSizePixel = 0,
            Visible = state,
            ZIndex = 1,
        }, btn)
        corner(fillFrame, 8)
        glowFill(fillFrame, C.PINK)

        local txt = make("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = Name .. (state and "  :  ON" or "  :  OFF"),
            TextColor3 = C.WHITE,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            ZIndex = 2,
        }, btn)

        local function refresh()
            txt.Text = Name .. (state and "  :  ON" or "  :  OFF")
            fillFrame.Visible = state
            btn.BackgroundColor3 = C.PANEL
        end

        btn.MouseEnter:Connect(function()
            if not state then btn.BackgroundColor3 = C.HOVER end
        end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = C.PANEL end)
        btn.MouseButton1Click:Connect(function()
            state = not state
            refresh()
            local ok, err = pcall(Callback, state)
            if not ok then warn("[YYS] Toggle error: " .. tostring(err)) end
        end)

        local api = {}
        function api:Set(v)
            state = not not v
            refresh()
        end
        function api:Get()
            return state
        end
        return api
    end

    function Window:CreateCheckbox(cfg)
        cfg = cfg or {}
        local Name     = cfg.Name or "Checkbox"
        local Default  = cfg.Default or false
        local Callback = cfg.Callback or function() end

        local state = Default

        local row = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = C.PANEL,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = nextOrder(),
        }, body)
        corner(row, 7)
        glowStroke(row, 1)

        local box = make("Frame", {
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.fromOffset(10, 6),
            BackgroundColor3 = C.BG,
            BorderSizePixel = 0,
        }, row)
        corner(box, 4)
        glowStroke(box, 1)

        local check = make("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = C.WHITE,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
        }, box)

        make("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.fromOffset(36, 0),
            BackgroundTransparency = 1,
            Text = Name,
            TextColor3 = C.WHITE,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local function refresh()
            check.Text = state and "✓" or ""
            box.BackgroundColor3 = state and C.PINK or C.BG
        end
        refresh()

        row.MouseEnter:Connect(function() row.BackgroundColor3 = C.HOVER end)
        row.MouseLeave:Connect(function() row.BackgroundColor3 = C.PANEL end)
        row.MouseButton1Click:Connect(function()
            state = not state
            refresh()
            local ok, err = pcall(Callback, state)
            if not ok then warn("[YYS] Checkbox error: " .. tostring(err)) end
        end)

        local api = {}
        function api:Set(v)
            state = not not v
            refresh()
        end
        function api:Get()
            return state
        end
        return api
    end

    function Window:CreateDropdown(cfg)
        cfg = cfg or {}
        local Name     = cfg.Name or "Dropdown"
        local Options  = cfg.Options or { "Option 1", "Option 2" }
        local Default  = cfg.Default or Options[1]
        local Callback = cfg.Callback or function() end

        local selected = Default

        local section = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
            ClipsDescendants = false,
        }, body)

        local ddBtn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = C.PANEL,
            Text = "",
            AutoButtonColor = false,
        }, section)
        corner(ddBtn, 8)
        glowStroke(ddBtn, 1)

        local ddText = make("TextLabel", {
            Size = UDim2.new(1, -36, 1, 0),
            Position = UDim2.fromOffset(12, 0),
            BackgroundTransparency = 1,
            Text = Name .. ": " .. tostring(selected),
            TextColor3 = C.WHITE,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, ddBtn)

        local arrow = make("TextLabel", {
            Size = UDim2.fromOffset(22, 34),
            Position = UDim2.new(1, -26, 0, 0),
            BackgroundTransparency = 1,
            Text = "▾",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = C.PINK2,
        }, ddBtn)

        local list = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.fromOffset(0, 38),
            BackgroundColor3 = C.BG,
            Visible = false,
            BorderSizePixel = 0,
            ZIndex = 20,
        }, section)
        corner(list, 8)
        glowStroke(list, 1)

        make("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, list)
        pad(list, 4, 4, 4, 4)

        local optionFills = {}

        local function refreshList()
            for name, fillFrame in pairs(optionFills) do
                fillFrame.Visible = (name == selected)
            end
            ddText.Text = Name .. ": " .. tostring(selected)
        end

        for i, opt in ipairs(Options) do
            local b = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = C.PANEL,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 21,
                LayoutOrder = i,
            }, list)
            corner(b, 6)

            local f = make("Frame", {
                Size = UDim2.fromScale(1, 1),
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 22,
            }, b)
            corner(f, 6)
            glowFill(f, C.PINK)
            optionFills[opt] = f

            make("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = opt,
                TextColor3 = C.WHITE,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                ZIndex = 23,
            }, b)

            b.MouseEnter:Connect(function()
                if opt ~= selected then b.BackgroundColor3 = C.HOVER end
            end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = C.PANEL end)
            b.MouseButton1Click:Connect(function()
                selected = opt
                list.Visible = false
                arrow.Text = "▾"
                list.Size = UDim2.new(1, 0, 0, 0)
                refreshList()
                local ok, err = pcall(Callback, selected)
                if not ok then warn("[YYS] Dropdown error: " .. tostring(err)) end
            end)
        end
        refreshList()

        ddBtn.MouseButton1Click:Connect(function()
            list.Visible = not list.Visible
            arrow.Text = list.Visible and "▴" or "▾"
            if list.Visible then
                list.Size = UDim2.new(1, 0, 0, #Options * 28 + 8)
            else
                list.Size = UDim2.new(1, 0, 0, 0)
            end
        end)
        ddBtn.MouseEnter:Connect(function() ddBtn.BackgroundColor3 = C.HOVER end)
        ddBtn.MouseLeave:Connect(function() ddBtn.BackgroundColor3 = C.PANEL end)

        local api = {}
        function api:Set(v)
            if table.find(Options, v) then
                selected = v
                refreshList()
            end
        end
        function api:Get()
            return selected
        end
        return api
    end

    function Window:CreateSlider(cfg)
        cfg = cfg or {}
        local Name      = cfg.Name or "Slider"
        local Min       = cfg.Min or 0
        local Max       = cfg.Max or 100
        local Default   = cfg.Default or Min
        local Callback  = cfg.Callback or function() end
        local Increment = cfg.Increment or nil

        local value = math.clamp(Default, Min, Max)

        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundColor3 = C.PANEL,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
        }, body)
        corner(row, 8)
        glowStroke(row, 1)

        make("TextLabel", {
            Size = UDim2.new(0.55, 0, 0, 18),
            Position = UDim2.fromOffset(12, 6),
            BackgroundTransparency = 1,
            Text = Name,
            TextColor3 = C.WHITE,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local valLbl = make("TextLabel", {
            Size = UDim2.new(0.4, 0, 0, 18),
            Position = UDim2.new(0.55, 0, 0, 6),
            BackgroundTransparency = 1,
            Text = tostring(value),
            TextColor3 = C.PINK2,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)
        shine(valLbl, C.PINK2)

        local track = make("Frame", {
            Size = UDim2.new(1, -24, 0, 6),
            Position = UDim2.fromOffset(12, 32),
            BackgroundColor3 = C.BG,
            BorderSizePixel = 0,
        }, row)
        corner(track, 3)

        local fill = make("Frame", {
            Size = UDim2.new((value - Min) / math.max(Max - Min, 1), 0, 1, 0),
            BorderSizePixel = 0,
        }, track)
        corner(fill, 3)
        glowFill(fill, C.PINK)

        local knob = make("Frame", {
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new((value - Min) / math.max(Max - Min, 1), -7, 0.5, -7),
            BackgroundColor3 = C.WHITE,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, track)
        corner(knob, 7)
        glowStroke(knob, 1)

        local function setValue(v)
            v = math.clamp(v, Min, Max)
            if Increment then
                v = math.floor(v / Increment + 0.5) * Increment
            else
                if Max - Min <= 10 then
                    v = math.floor(v * 10 + 0.5) / 10
                else
                    v = math.floor(v + 0.5)
                end
            end
            value = v
            local ratio = (v - Min) / math.max(Max - Min, 1)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            knob.Position = UDim2.new(ratio, -7, 0.5, -7)
            valLbl.Text = tostring(v)
        end

        local sliding = false
        local function fromInput(input)
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            setValue(Min + rel * (Max - Min))
            local ok, err = pcall(Callback, value)
            if not ok then warn("[YYS] Slider error: " .. tostring(err)) end
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                fromInput(input)
            end
        end)
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
            end
        end)
        trackConn(UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                fromInput(input)
            end
        end))
        trackConn(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end))

        local api = {}
        function api:Set(v)
            setValue(v)
        end
        function api:Get()
            return value
        end
        return api
    end

    function Window:CreateProgress(cfg)
        cfg = cfg or {}
        local Name = cfg.Name or "Progress"

        local wrap = make("Frame", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
        }, body)

        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = Name,
            TextColor3 = C.GRAY,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, wrap)

        local track = make("Frame", {
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.fromOffset(0, 18),
            BackgroundColor3 = C.PANEL,
            BorderSizePixel = 0,
        }, wrap)
        corner(track, 3)

        local fill = make("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0,
        }, track)
        corner(fill, 3)
        glowFill(fill, C.PINK)

        local api = {}
        function api:Set(fraction)
            TweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(math.clamp(tonumber(fraction) or 0, 0, 1), 0, 1, 0)
            }):Play()
        end
        return api
    end

    function Window:CreateStatus(cfg)
        cfg = cfg or {}
        local Default = cfg.Default or "Idle"

        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
        }, body)

        local dot = make("Frame", {
            Size = UDim2.fromOffset(8, 8),
            Position = UDim2.fromOffset(2, 7),
            BackgroundColor3 = C.GRAY,
            BorderSizePixel = 0,
        }, row)
        corner(dot, 4)

        local lbl = make("TextLabel", {
            Size = UDim2.new(1, -18, 1, 0),
            Position = UDim2.fromOffset(16, 0),
            BackgroundTransparency = 1,
            Text = "Status: " .. Default,
            TextColor3 = C.GRAY,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local api = {}
        function api:Set(text, active)
            lbl.Text = "Status: " .. tostring(text)
            lbl.TextColor3 = active and C.WHITE or C.GRAY
            dot.BackgroundColor3 = active and C.PINK2 or C.GRAY
        end
        return api
    end

    table.insert(Library._windows, Window)
    return Window
end

return Library
