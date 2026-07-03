local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Palette = {
    Background   = Color3.fromRGB(15, 15, 18),
    Inline       = Color3.fromRGB(10, 10, 14),
    Surface      = Color3.fromRGB(22, 22, 27),
    Element      = Color3.fromRGB(38, 38, 46),
    Hover        = Color3.fromRGB(52, 52, 62),
    Border       = Color3.fromRGB(72, 72, 84),
    SubBorder    = Color3.fromRGB(50, 50, 58),
    TopHighlight = Color3.fromRGB(88, 88, 100),
    Text         = Color3.fromRGB(235, 235, 240),
    Dim          = Color3.fromRGB(140, 140, 150),
    Accent       = Color3.fromRGB(131, 154, 255),
    AccentHi     = Color3.fromRGB(168, 184, 255),
    AccentLo     = Color3.fromRGB(85, 100, 175),
    Risky        = Color3.fromRGB(220, 100, 100),
}

local ChangelogColors = {
    Added   = "#78DC82",
    Removed = "#DC6464",
    Fixed   = "#DCC864",
}

local DefaultLogo = "rbxassetid://74673150448574"
local FontUrl     = "https://github.com/SzNeo8083/SzNeo8083.github.io/raw/refs/heads/main/fonts/verdanab.ttf"

local RegularFont = Font.fromEnum(Enum.Font.Arial)
local BoldFont    = Font.fromEnum(Enum.Font.ArialBold)
do
    if writefile and isfile and getcustomasset then
        local assetsFolder = "polaris_assets"
        if makefolder and isfolder and not isfolder(assetsFolder) then pcall(makefolder, assetsFolder) end
        local fontPath = assetsFolder .. "/verdanab.ttf"
        if not isfile(fontPath) then
            local ok, data = pcall(function() return game:HttpGet(FontUrl) end)
            if ok and type(data) == "string" and #data > 0 then
                pcall(writefile, fontPath, data)
            end
        end
        if isfile(fontPath) then
            local ok, asset = pcall(getcustomasset, fontPath)
            if ok and asset then
                local fontOk, loadedFont = pcall(Font.new, asset)
                if fontOk and loadedFont then
                    RegularFont = loadedFont
                    BoldFont    = loadedFont
                end
            end
        end
    end
end

local function new(class, props)
    local instance = Instance.new(class)
    for key, value in pairs(props or {}) do instance[key] = value end
    return instance
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {
        Parent = parent,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Color = color or Palette.Border,
        Thickness = thickness or 1,
    })
end

local function topEdge(parent, inset, color)
    return new("Frame", {
        Parent = parent,
        BackgroundColor3 = color or Palette.TopHighlight,
        BorderSizePixel = 0,
        Position = UDim2.new(0, inset or 0, 0, inset or 0),
        Size = UDim2.new(1, -(inset or 0) * 2, 0, 1),
    })
end

local function bottomEdge(parent, inset, color)
    return new("Frame", {
        Parent = parent,
        BackgroundColor3 = color or Palette.Inline,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, inset or 0, 1, -(inset or 0)),
        Size = UDim2.new(1, -(inset or 0) * 2, 0, 1),
    })
end

local function tween(instance, info, props)
    local tweenObject = TweenService:Create(instance, info, props)
    tweenObject:Play()
    return tweenObject
end

local Tweens = {
    Drop      = TweenInfo.new(0.85, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Pop       = TweenInfo.new(0.55, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    Slide     = TweenInfo.new(0.5,  Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    Item      = TweenInfo.new(0.32, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    Button    = TweenInfo.new(0.42, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    ShutDrop  = TweenInfo.new(0.4,  Enum.EasingStyle.Back,   Enum.EasingDirection.In),
    ShutSlide = TweenInfo.new(0.3,  Enum.EasingStyle.Back,   Enum.EasingDirection.In),
    ShutItem  = TweenInfo.new(0.18, Enum.EasingStyle.Back,   Enum.EasingDirection.In),
    FadeOut   = TweenInfo.new(0.14, Enum.EasingStyle.Quad,   Enum.EasingDirection.In),
    FadeIn    = TweenInfo.new(0.28, Enum.EasingStyle.Quint,  Enum.EasingDirection.Out),
    Fast      = TweenInfo.new(0.15, Enum.EasingStyle.Quad,   Enum.EasingDirection.Out),
}

local OuterWidth     = 540
local OuterHeight    = 370
local SidePanelWidth = 160
local Padding        = 5

local Loader = {}
Loader.__index = Loader

function Loader.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Loader)
    self.Name     = opts.Name or "polaris.tech"
    self.Logo     = opts.Logo or DefaultLogo
    self.Games    = {}
    self.Current  = nil
    self._entries = {}
    self._closing = false
    self._opened  = false

    local ScreenGui = new("ScreenGui", {
        Name = "PolarisLoader_" .. HttpService:GenerateGUID(false),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999,
    })
    pcall(function() ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not ScreenGui.Parent then
        pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
    self.ScreenGui = ScreenGui

    local MainFrame = new("Frame", {
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(OuterWidth, OuterHeight),
        BackgroundColor3 = Palette.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
    })
    stroke(MainFrame, Palette.Border, 1)
    topEdge(MainFrame, 1)
    self.Frame = MainFrame
    self._homePosition = UDim2.new(0.5, 0, 0.5, 0)

    self._scaler = new("UIScale", {Parent = MainFrame, Scale = 1})

    local TitleBar = new("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Palette.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 20),
        Active = true,
    })
    self._titleBar = TitleBar

    new("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Palette.Border,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local hasLogo = self.Logo and self.Logo ~= "" and self.Logo ~= "rbxassetid://0"
    local titleX = 8
    if hasLogo then
        local Logo = new("ImageLabel", {
            Parent = TitleBar,
            Image = self.Logo,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
        })
        self._logoScale = new("UIScale", {Parent = Logo, Scale = 1})
        titleX = 30
    end

    self._title = new("TextLabel", {
        Parent = TitleBar,
        FontFace = BoldFont, TextSize = 12,
        Text = self.Name,
        TextColor3 = Palette.Text,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, titleX, 0.5, 0),
        Size = UDim2.new(0, 280, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local CloseButton = new("TextButton", {
        Parent = TitleBar,
        FontFace = BoldFont, TextSize = 12,
        AutoButtonColor = false, Text = "x",
        TextColor3 = Palette.Dim,
        BackgroundColor3 = Palette.Surface,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 12),
    })
    stroke(CloseButton, Palette.Border, 1)
    CloseButton.MouseEnter:Connect(function()
        tween(CloseButton, Tweens.Fast, {BackgroundColor3 = Palette.Risky, TextColor3 = Palette.Text})
    end)
    CloseButton.MouseLeave:Connect(function()
        tween(CloseButton, Tweens.Fast, {BackgroundColor3 = Palette.Surface, TextColor3 = Palette.Dim})
    end)
    CloseButton.MouseButton1Down:Connect(function() self:Exit() end)

    local InnerContainer = new("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Palette.Inline,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(Padding, 20 + Padding),
        Size = UDim2.new(1, -Padding * 2, 1, -20 - Padding * 2),
        ClipsDescendants = true,
    })
    stroke(InnerContainer, Palette.SubBorder, 1)
    self._inner = InnerContainer

    local function makePanel(headerText, x, width)
        local Panel = new("Frame", {
            Parent = InnerContainer,
            BackgroundColor3 = Palette.Surface,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(x, Padding),
            Size = UDim2.new(0, width, 1, -Padding * 2),
            ClipsDescendants = true,
        })
        stroke(Panel, Palette.Border, 1)

        local Header = new("Frame", {
            Parent = Panel,
            BackgroundColor3 = Palette.Element,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 18),
        })
        topEdge(Header, 0)
        new("Frame", {
            Parent = Panel,
            BackgroundColor3 = Palette.Border,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 18),
            Size = UDim2.new(1, 0, 0, 1),
        })
        new("TextLabel", {
            Parent = Header,
            FontFace = BoldFont, TextSize = 12,
            Text = headerText,
            TextColor3 = Palette.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 6, 0, 0),
            Size = UDim2.new(1, -12, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        return Panel
    end

    local LeftPanel = makePanel("Games", Padding, SidePanelWidth)
    self._leftPanel = LeftPanel
    self._leftPanelHome = LeftPanel.Position

    local GameList = new("ScrollingFrame", {
        Parent = LeftPanel,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 3, 0, 22),
        Size = UDim2.new(1, -6, 1, -25),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Palette.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Active = false,
        ClipsDescendants = true,
    })
    self._gameList = GameList
    new("UIListLayout", {
        Parent = GameList,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local rightPanelX = Padding + SidePanelWidth + Padding
    local innerWidth  = OuterWidth - Padding * 2
    local rightPanelWidth = innerWidth - rightPanelX - Padding
    local RightPanel = makePanel("Selection", rightPanelX, rightPanelWidth)
    self._rightPanel = RightPanel
    self._rightPanelHome = RightPanel.Position

    local PreviewImage = new("ImageLabel", {
        Parent = RightPanel,
        Image = "",
        BackgroundColor3 = Palette.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 26),
        Size = UDim2.new(1, -16, 0, 92),
        ScaleType = Enum.ScaleType.Crop,
    })
    stroke(PreviewImage, Palette.Border, 1)
    self._previewImage = PreviewImage
    self._previewImageScale = new("UIScale", {Parent = PreviewImage, Scale = 1})

    self._nameLabel = new("TextLabel", {
        Parent = RightPanel,
        FontFace = BoldFont, TextSize = 14,
        Text = "—",
        TextColor3 = Palette.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 124),
        Size = UDim2.new(1, -16, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    self._authorLabel = new("TextLabel", {
        Parent = RightPanel,
        FontFace = RegularFont, TextSize = 12,
        Text = "—",
        TextColor3 = Palette.Dim,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 142),
        Size = UDim2.new(1, -16, 0, 13),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    self._descriptionLabel = new("TextLabel", {
        Parent = RightPanel,
        FontFace = RegularFont, TextSize = 12,
        Text = "select a game on the left.",
        TextColor3 = Palette.Dim,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 162),
        Size = UDim2.new(1, -16, 1, -196),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
    })

    self._changelogScroll = new("ScrollingFrame", {
        Parent = RightPanel,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 162),
        Size = UDim2.new(1, -16, 1, -196),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Palette.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Active = false,
        Visible = false,
        ClipsDescendants = true,
    })
    new("UIListLayout", {
        Parent = self._changelogScroll,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local LoadButton = new("TextButton", {
        Parent = RightPanel,
        AutoButtonColor = false, Text = "",
        BackgroundColor3 = Palette.Accent,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -8, 1, -8),
        Size = UDim2.new(0, 100, 0, 24),
        ClipsDescendants = true,
    })
    local LoadButtonStroke = stroke(LoadButton, Palette.AccentHi, 1)
    topEdge(LoadButton, 0, Palette.AccentHi)
    bottomEdge(LoadButton, 0, Palette.AccentLo)

    local LoadIndicator = new("Frame", {
        Parent = LoadButton,
        BackgroundColor3 = Palette.Text,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(0, 4, 0, 4),
    })
    local LoadLabel = new("TextLabel", {
        Parent = LoadButton,
        FontFace = BoldFont, TextSize = 12,
        Text = "Load",
        TextColor3 = Palette.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 0),
        Size = UDim2.new(1, -22, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    LoadButton.MouseEnter:Connect(function()
        tween(LoadButton,       Tweens.Fast, {BackgroundColor3 = Palette.AccentHi})
        tween(LoadButtonStroke, Tweens.Fast, {Color = Palette.Text})
        tween(LoadIndicator,    Tweens.Fast, {Size = UDim2.new(0, 6, 0, 6)})
    end)
    LoadButton.MouseLeave:Connect(function()
        tween(LoadButton,       Tweens.Fast, {BackgroundColor3 = Palette.Accent})
        tween(LoadButtonStroke, Tweens.Fast, {Color = Palette.AccentHi})
        tween(LoadIndicator,    Tweens.Fast, {Size = UDim2.new(0, 4, 0, 4)})
    end)
    LoadButton.MouseButton1Down:Connect(function()
        if not self.Current or self._closing then return end
        local selectedGame = self.Current
        LoadLabel.Text = "loading..."
        self:Exit()
        task.delay(0.45, function()
            local ok, err = pcall(selectedGame.Callback, selectedGame)
            if not ok then warn("[polaris loader]", err) end
        end)
    end)
    self._loadButton = LoadButton
    self._loadButtonScale = new("UIScale", {Parent = LoadButton, Scale = 1})

    self:_makeDraggable(MainFrame)

    task.defer(function() self:_openAnim() end)

    return self
end

function Loader:_openAnim()
    if not self.Frame or not self.Frame.Parent then return end

    self._scaler.Scale            = 0.55
    self.Frame.Position           = UDim2.new(0.5, 0, 0.5, -150)
    self.Frame.Visible            = true
    self._leftPanel.Position      = UDim2.fromOffset(-SidePanelWidth - 30, Padding)
    self._rightPanel.Position     = UDim2.fromOffset(OuterWidth, Padding)
    self._previewImageScale.Scale = 0
    self._loadButtonScale.Scale   = 0
    if self._logoScale then self._logoScale.Scale = 0 end
    for _, entry in ipairs(self._entries) do
        if entry.Scale then entry.Scale.Scale = 0 end
    end

    tween(self._scaler, Tweens.Pop,  {Scale = 1})
    tween(self.Frame,   Tweens.Drop, {Position = self._homePosition})

    task.delay(0.12, function()
        if self._closing then return end
        tween(self._leftPanel, Tweens.Slide, {Position = self._leftPanelHome})
    end)
    task.delay(0.18, function()
        if self._closing then return end
        tween(self._rightPanel, Tweens.Slide, {Position = self._rightPanelHome})
    end)
    task.delay(0.28, function()
        if self._closing then return end
        tween(self._previewImageScale, Tweens.Pop, {Scale = 1})
        if self._logoScale then tween(self._logoScale, Tweens.Pop, {Scale = 1}) end
    end)
    task.delay(0.36, function()
        if self._closing then return end
        for index, entry in ipairs(self._entries) do
            if entry.Scale then
                task.delay((index - 1) * 0.045, function()
                    if entry.Scale and not self._closing then
                        tween(entry.Scale, Tweens.Item, {Scale = 1})
                    end
                end)
            end
        end
    end)
    task.delay(0.5, function()
        if self._closing then return end
        tween(self._loadButtonScale, Tweens.Button, {Scale = 1})
    end)

    task.delay(0.95, function() self._opened = true end)
end

function Loader:_makeDraggable(gui)
    local titleBar = self._titleBar or gui
    local dragging, dragStart, startPosition
    titleBar.InputBegan:Connect(function(input)
        if self._closing then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
            gui.Position = newPosition
            self._homePosition = newPosition
        end
    end)
end

function Loader:_hasChangelog(changelog)
    if type(changelog) ~= "table" then return false end
    for _, key in ipairs({"Added", "Removed", "Fixed"}) do
        if type(changelog[key]) == "table" and #changelog[key] > 0 then return true end
    end
    return false
end

function Loader:_rebuildChangelog(changelog)
    for _, child in ipairs(self._changelogScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    if not changelog then return end

    local layoutOrder = 0
    local function addEntry(prefix, hexColor, text)
        layoutOrder = layoutOrder + 1
        new("TextLabel", {
            Parent = self._changelogScroll,
            FontFace = RegularFont, TextSize = 12,
            RichText = true,
            Text = string.format('<font color="%s"><b>%s</b></font>  %s', hexColor, prefix, text),
            TextColor3 = Palette.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -6, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            LayoutOrder = layoutOrder,
        })
    end

    local categories = {
        {Key = "Added",   Prefix = "+", Hex = ChangelogColors.Added},
        {Key = "Removed", Prefix = "-", Hex = ChangelogColors.Removed},
        {Key = "Fixed",   Prefix = "~", Hex = ChangelogColors.Fixed},
    }
    for _, category in ipairs(categories) do
        local items = changelog[category.Key]
        if type(items) == "table" then
            for _, text in ipairs(items) do
                addEntry(category.Prefix, category.Hex, text)
            end
        end
    end
end

function Loader:_applyGame(gameRecord)
    self._previewImage.Image    = gameRecord.Image or ""
    self._nameLabel.Text        = gameRecord.Name
    self._authorLabel.Text      = "by " .. (gameRecord.Author or "unknown")
    if self:_hasChangelog(gameRecord.Changelog) then
        self._descriptionLabel.Visible = false
        self._changelogScroll.Visible  = true
        self:_rebuildChangelog(gameRecord.Changelog)
    else
        self._descriptionLabel.Visible = true
        self._changelogScroll.Visible  = false
        self._descriptionLabel.Text    = gameRecord.Description or ""
    end
end

function Loader:_select(gameRecord)
    if self._switchToken == gameRecord then return end
    self._switchToken = gameRecord
    self.Current = gameRecord

    for _, entry in ipairs(self._entries) do
        local isActive = entry.Game == gameRecord
        tween(entry.Button, Tweens.Fast, {BackgroundColor3 = isActive and Palette.Hover or Palette.Element})
        tween(entry.Label,  Tweens.Fast, {TextColor3 = isActive and Palette.Text or Palette.Dim})
        if entry.AccentBar then
            tween(entry.AccentBar, Tweens.Fast, {BackgroundTransparency = isActive and 0 or 1})
        end
    end

    if not self._opened then
        self:_applyGame(gameRecord)
        return
    end

    tween(self._previewImage, Tweens.FadeOut, {ImageTransparency = 1})
    tween(self._nameLabel,    Tweens.FadeOut, {TextTransparency = 1})
    tween(self._authorLabel,  Tweens.FadeOut, {TextTransparency = 1})
    if self._descriptionLabel.Visible then
        tween(self._descriptionLabel, Tweens.FadeOut, {TextTransparency = 1})
    end
    if self._changelogScroll.Visible then
        for _, child in ipairs(self._changelogScroll:GetChildren()) do
            if child:IsA("TextLabel") then
                tween(child, Tweens.FadeOut, {TextTransparency = 1})
            end
        end
    end

    task.delay(Tweens.FadeOut.Time, function()
        if self._switchToken ~= gameRecord or self._closing then return end
        self:_applyGame(gameRecord)

        tween(self._previewImage, Tweens.FadeIn, {ImageTransparency = 0})
        tween(self._nameLabel,    Tweens.FadeIn, {TextTransparency = 0})
        tween(self._authorLabel,  Tweens.FadeIn, {TextTransparency = 0})
        if self._descriptionLabel.Visible then
            self._descriptionLabel.TextTransparency = 1
            tween(self._descriptionLabel, Tweens.FadeIn, {TextTransparency = 0})
        end
        if self._changelogScroll.Visible then
            local labelIndex = 0
            for _, child in ipairs(self._changelogScroll:GetChildren()) do
                if child:IsA("TextLabel") then
                    labelIndex = labelIndex + 1
                    child.TextTransparency = 1
                    local staggeredInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, (labelIndex - 1) * 0.03)
                    tween(child, staggeredInfo, {TextTransparency = 0})
                end
            end
        end
    end)
end

function Loader:AddGame(opts)
    opts = opts or {}
    local gameRecord = {
        Name        = opts.Name or "Game",
        Author      = opts.Author or "unknown",
        Description = opts.Description or "",
        Image       = opts.Image or "",
        Changelog   = opts.Changelog,
        Callback    = opts.Callback or function() end,
    }

    local GameButton = new("TextButton", {
        Parent = self._gameList,
        FontFace = RegularFont, TextSize = 12,
        AutoButtonColor = false, Text = "",
        BackgroundColor3 = Palette.Element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 22),
        LayoutOrder = #self.Games + 1,
        ClipsDescendants = true,
    })

    local AccentBar = new("Frame", {
        Parent = GameButton,
        BackgroundColor3 = Palette.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundTransparency = 1,
    })

    local GameLabel = new("TextLabel", {
        Parent = GameButton,
        FontFace = RegularFont, TextSize = 12,
        Text = gameRecord.Name,
        TextColor3 = Palette.Dim,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local GameItemScale = new("UIScale", {Parent = GameButton, Scale = self._opened and 1 or 0})

    GameButton.MouseEnter:Connect(function()
        if self.Current == gameRecord then return end
        tween(GameButton, Tweens.Fast, {BackgroundColor3 = Palette.Hover})
        tween(GameLabel,  Tweens.Fast, {TextColor3 = Palette.Text})
    end)
    GameButton.MouseLeave:Connect(function()
        if self.Current == gameRecord then return end
        tween(GameButton, Tweens.Fast, {BackgroundColor3 = Palette.Element})
        tween(GameLabel,  Tweens.Fast, {TextColor3 = Palette.Dim})
    end)
    GameButton.MouseButton1Down:Connect(function() self:_select(gameRecord) end)

    table.insert(self._entries, {
        Button    = GameButton,
        Label     = GameLabel,
        AccentBar = AccentBar,
        Scale     = GameItemScale,
        Game      = gameRecord,
    })
    table.insert(self.Games, gameRecord)

    if self._opened then
        GameItemScale.Scale = 0
        tween(GameItemScale, Tweens.Item, {Scale = 1})
    end

    if #self.Games == 1 then self:_select(gameRecord) end
    return gameRecord
end

function Loader:Select(name)
    for _, gameRecord in ipairs(self.Games) do
        if gameRecord.Name == name then self:_select(gameRecord) return gameRecord end
    end
end

function Loader:Exit()
    if not self.ScreenGui or self._closing then return end
    self._closing = true

    local entryCount = #self._entries
    for index, entry in ipairs(self._entries) do
        if entry.Scale then
            task.delay((entryCount - index) * 0.025, function()
                if entry.Scale then tween(entry.Scale, Tweens.ShutItem, {Scale = 0}) end
            end)
        end
    end

    task.delay(0.1, function()
        tween(self._previewImageScale, Tweens.ShutItem, {Scale = 0})
        tween(self._loadButtonScale,   Tweens.ShutItem, {Scale = 0})
        if self._logoScale then tween(self._logoScale, Tweens.ShutItem, {Scale = 0}) end
    end)

    task.delay(0.16, function()
        tween(self._leftPanel,  Tweens.ShutSlide, {Position = UDim2.fromOffset(-SidePanelWidth - 30, Padding)})
        tween(self._rightPanel, Tweens.ShutSlide, {Position = UDim2.fromOffset(OuterWidth, Padding)})
    end)

    task.delay(0.28, function()
        tween(self._scaler, Tweens.ShutDrop, {Scale = 0.55})
        tween(self.Frame,   Tweens.ShutDrop, {
            Position = UDim2.new(
                self._homePosition.X.Scale, self._homePosition.X.Offset,
                self._homePosition.Y.Scale, self._homePosition.Y.Offset + 150
            ),
        })
    end)

    task.delay(0.72, function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
            self.ScreenGui = nil
        end
    end)
end