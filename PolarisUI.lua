--[[
	PolarisUI
	A modern, mobile + PC friendly Roblox UI library.
	Loader screen styled after "polaris.tech | loader" with a full tabbed
	dashboard (toggles, sliders, dropdowns, buttons, keybinds, notifications).

	Usage:
		local Polaris = loadstring(game:HttpGet("<raw file url>"))()
		-- or: local Polaris = require(pathToModuleScript)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGuiService = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Polaris = {}
Polaris.__index = Polaris
Polaris.Flags = {}

local Theme = {
	Background = Color3.fromRGB(13, 15, 21),
	Sidebar = Color3.fromRGB(16, 18, 26),
	Panel = Color3.fromRGB(19, 21, 30),
	Element = Color3.fromRGB(24, 26, 37),
	ElementHover = Color3.fromRGB(30, 33, 46),
	Stroke = Color3.fromRGB(38, 41, 56),
	Accent = Color3.fromRGB(120, 134, 240),
	AccentDark = Color3.fromRGB(92, 104, 205),
	Green = Color3.fromRGB(93, 214, 138),
	Text = Color3.fromRGB(236, 237, 245),
	SubText = Color3.fromRGB(143, 146, 168),
	Faint = Color3.fromRGB(100, 103, 122),
}

local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED = Enum.Font.GothamMedium

--------------------------------------------------------------------
-- Utility
--------------------------------------------------------------------

local function New(class, props, children)
	local inst = Instance.new(class)
	for key, value in pairs(props or {}) do
		if key ~= "Parent" then
			inst[key] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function Round(inst, radius)
	New("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = inst })
	return inst
end

local function Stroke(inst, color, thickness, transparency)
	New("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0.4,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inst,
	})
	return inst
end

local function Pad(inst, l, r, t, b)
	New("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
		Parent = inst,
	})
	return inst
end

local function Tween(inst, props, time, style, dir)
	local info = TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(inst, info, props)
	tw:Play()
	return tw
end

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function GetGui()
	local ok, hui = pcall(function()
		return (gethui and gethui()) or CoreGuiService
	end)
	if ok and hui then
		return hui
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- Drag support for both PC (mouse) and mobile (touch)
local function MakeDraggable(handle, target)
	local dragging = false
	local dragStart, startPos
	local dragInput

	local function update(input)
		local delta = input.Position - dragStart
		local pos = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		Tween(target, { Position = pos }, 0.08, Enum.EasingStyle.Quad)
	end

	handle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = input.Position
			startPos = target.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

--------------------------------------------------------------------
-- Window
--------------------------------------------------------------------

function Polaris:CreateWindow(config)
	config = config or {}

	local self = setmetatable({}, Polaris)
	self.OpenDropdown = nil
	self.Tabs = {}
	self.TabButtons = {}

	local Gui = New("ScreenGui", {
		Name = "PolarisUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
	})
	Gui.Parent = GetGui()
	self.Gui = Gui

	local width, height = 700, 430
	if IsMobile then
		width, height = 360, 480
	end

	local Main = New("Frame", {
		Name = "Main",
		Size = UDim2.new(0, width, 0, height),
		Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2 - 40),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Gui,
	})
	Round(Main, 12)
	Stroke(Main, Theme.Stroke, 1, 0.2)
	self.Main = Main

	-- entrance animation
	Main.Size = UDim2.new(0, width, 0, height * 0.9)
	task.defer(function()
		Tween(Main, { BackgroundTransparency = 0 }, 0.25)
		Tween(Main, {
			Size = UDim2.new(0, width, 0, height),
			Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
		}, 0.45, Enum.EasingStyle.Back)
	end)

	-- Top bar
	local TopBar = New("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = Main,
	})
	Round(TopBar, 12)
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = TopBar,
	})
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = TopBar,
	})

	New("TextLabel", {
		Text = "\226\156\166",
		Font = FONT_BOLD,
		TextSize = 15,
		TextColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 24, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Parent = TopBar,
	})

	local TitleLabel = New("TextLabel", {
		Name = "Title",
		Text = config.Name or "polaris.tech | loader",
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 36, 0, 0),
		Parent = TopBar,
	})

	local CloseButton = New("TextButton", {
		Text = "\226\156\149",
		Font = FONT,
		TextSize = 15,
		TextColor3 = Theme.SubText,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 34, 1, 0),
		Position = UDim2.new(1, -34, 0, 0),
		Parent = TopBar,
	})
	CloseButton.MouseButton1Click:Connect(function()
		Tween(Main, { BackgroundTransparency = 1, Size = UDim2.new(0, width, 0, height * 0.9) }, 0.2)
		task.wait(0.2)
		Gui.Enabled = false
	end)
	CloseButton.MouseEnter:Connect(function()
		Tween(CloseButton, { TextColor3 = Color3.fromRGB(240, 100, 100) }, 0.15)
	end)
	CloseButton.MouseLeave:Connect(function()
		Tween(CloseButton, { TextColor3 = Theme.SubText }, 0.15)
	end)

	local MinButton = New("TextButton", {
		Text = "\226\128\146",
		Font = FONT,
		TextSize = 15,
		TextColor3 = Theme.SubText,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 34, 1, 0),
		Position = UDim2.new(1, -68, 0, 0),
		Parent = TopBar,
	})
	local minimized = false
	MinButton.MouseButton1Click:Connect(function()
		minimized = not minimized
		self.Body.Visible = not minimized
		Tween(Main, { Size = minimized and UDim2.new(0, width, 0, 38) or UDim2.new(0, width, 0, height) }, 0.25)
	end)
	MinButton.MouseEnter:Connect(function()
		Tween(MinButton, { TextColor3 = Theme.Text }, 0.15)
	end)
	MinButton.MouseLeave:Connect(function()
		Tween(MinButton, { TextColor3 = Theme.SubText }, 0.15)
	end)

	MakeDraggable(TopBar, Main)

	local Body = New("Frame", {
		Name = "Body",
		Size = UDim2.new(1, 0, 1, -38),
		Position = UDim2.new(0, 0, 0, 38),
		BackgroundTransparency = 1,
		Parent = Main,
	})
	self.Body = Body

	self:_buildLoader(Body, config)
	self:_buildDashboard(Body, config)

	-- global click to close dropdowns
	UserInputService.InputBegan:Connect(function(input, gpe)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if self.OpenDropdown then
			local dd = self.OpenDropdown
			local pos = UserInputService:GetMouseLocation()
			local within = false
			for _, frame in ipairs({ dd.Button, dd.List }) do
				local ap, asz = frame.AbsolutePosition, frame.AbsoluteSize
				if pos.X >= ap.X and pos.X <= ap.X + asz.X and pos.Y >= ap.Y and pos.Y <= ap.Y + asz.Y then
					within = true
				end
			end
			if not within then
				dd:Close()
			end
		end
	end)

	-- mobile floating show/hide bubble
	if IsMobile or config.ShowMobileToggle then
		local Bubble = New("ImageButton", {
			Name = "PolarisBubble",
			Size = UDim2.new(0, 46, 0, 46),
			Position = UDim2.new(0, 14, 0.5, -23),
			BackgroundColor3 = Theme.Element,
			Image = "",
			Parent = Gui,
		})
		Round(Bubble, 23)
		Stroke(Bubble, Theme.Stroke, 1, 0.2)
		New("TextLabel", {
			Text = "\226\156\166",
			Font = FONT_BOLD,
			TextSize = 18,
			TextColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = Bubble,
		})
		MakeDraggable(Bubble, Bubble)
		local moved = false
		Bubble.MouseButton1Down:Connect(function()
			moved = false
		end)
		Bubble.InputChanged:Connect(function()
			moved = true
		end)
		Bubble.MouseButton1Click:Connect(function()
			if not moved then
				Main.Visible = not Main.Visible
			end
		end)
	else
		-- PC keybind toggle (RightControl)
		UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then
				return
			end
			if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightControl) then
				Main.Visible = not Main.Visible
			end
		end)
	end

	return self
end

--------------------------------------------------------------------
-- Loader screen (matches the reference screenshot style)
--------------------------------------------------------------------

function Polaris:_buildLoader(parent, config)
	local Loader = New("Frame", {
		Name = "Loader",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	self.Loader = Loader

	local listWidth = IsMobile and 0 or 170

	local GamesPanel
	if not IsMobile then
		GamesPanel = New("Frame", {
			Size = UDim2.new(0, listWidth, 1, 0),
			BackgroundColor3 = Theme.Sidebar,
			BorderSizePixel = 0,
			Parent = Loader,
		})
		New("Frame", {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0),
			BackgroundColor3 = Theme.Stroke,
			BorderSizePixel = 0,
			Parent = GamesPanel,
		})

		New("TextLabel", {
			Text = config.LoaderListTitle or "Games",
			Font = FONT_MED,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -24, 0, 30),
			Position = UDim2.new(0, 14, 0, 8),
			Parent = GamesPanel,
		})

		local List = New("ScrollingFrame", {
			Size = UDim2.new(1, -16, 1, -50),
			Position = UDim2.new(0, 8, 0, 40),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Faint,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = GamesPanel,
		})
		New("UIListLayout", { Padding = UDim.new(0, 4), Parent = List })

		local items = config.LoaderItems or { config.LoaderGameName or "Game" }
		for i, item in ipairs(items) do
			local Item = New("TextButton", {
				Text = "",
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = i == 1 and Theme.Element or Theme.Sidebar,
				AutoButtonColor = false,
				Parent = List,
			})
			Round(Item, 6)
			New("TextLabel", {
				Text = item,
				Font = FONT_MED,
				TextSize = 13,
				TextColor3 = i == 1 and Theme.Text or Theme.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				Parent = Item,
			})
			Item.MouseEnter:Connect(function()
				Tween(Item, { BackgroundColor3 = Theme.Element }, 0.15)
			end)
			Item.MouseLeave:Connect(function()
				Tween(Item, { BackgroundColor3 = Theme.Sidebar }, 0.15)
			end)
		end
	end

	local Selection = New("Frame", {
		Size = UDim2.new(1, -listWidth, 1, 0),
		Position = UDim2.new(0, listWidth, 0, 0),
		BackgroundTransparency = 1,
		Parent = Loader,
	})
	Pad(Selection, 16, 16, 12, 12)

	if not IsMobile then
		New("TextLabel", {
			Text = "Selection",
			Font = FONT_MED,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Parent = Selection,
		})
	end

	local Preview = New("Frame", {
		Size = UDim2.new(1, 0, 0, IsMobile and 130 or 170),
		Position = UDim2.new(0, 0, 0, IsMobile and 0 or 28),
		BackgroundColor3 = Theme.Panel,
		Parent = Selection,
	})
	Round(Preview, 10)
	Stroke(Preview, Theme.Stroke, 1, 0.2)
	New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 32, 46)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 16, 24)),
		}),
		Rotation = 45,
		Parent = Preview,
	})
	New("TextLabel", {
		Text = "\226\156\166",
		Font = FONT_BOLD,
		TextSize = 40,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 46),
		Position = UDim2.new(0, 0, 0.5, -46),
		Parent = Preview,
	})
	New("TextLabel", {
		Text = string.lower(config.Name and config.Name:gsub("%s*|.*", "") or "polaristech"),
		Font = FONT_MED,
		TextSize = 22,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0.5, 2),
		Parent = Preview,
	})

	local infoY = (IsMobile and 130 or 170) + (IsMobile and 12 or 40)

	New("TextLabel", {
		Text = config.LoaderGameName or "Untitled Game",
		Font = FONT_BOLD,
		TextSize = 17,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 0, infoY),
		Parent = Selection,
	})

	New("TextLabel", {
		Text = config.LoaderAuthor or "by unknown",
		Font = FONT,
		TextSize = 12,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 0, infoY + 22),
		Parent = Selection,
	})

	local featuresY = infoY + 44
	local status = config.LoaderStatus
	if status then
		New("TextLabel", {
			Text = "+ Status: " .. status,
			Font = FONT,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.new(0, 0, 0, featuresY),
			Parent = Selection,
		})
		featuresY = featuresY + 18
	end

	for _, feature in ipairs(config.LoaderFeatures or {}) do
		local Row = New("Frame", {
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.new(0, 0, 0, featuresY),
			BackgroundTransparency = 1,
			Parent = Selection,
		})
		New("TextLabel", {
			Text = "+",
			Font = FONT_BOLD,
			TextSize = 12,
			TextColor3 = Theme.Green,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 14, 1, 0),
			Parent = Row,
		})
		New("TextLabel", {
			Text = feature,
			Font = FONT,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -14, 1, 0),
			Position = UDim2.new(0, 14, 0, 0),
			Parent = Row,
		})
		featuresY = featuresY + 18
	end

	local LoadButton = New("TextButton", {
		Text = "",
		Size = UDim2.new(0, 120, 0, 34),
		Position = UDim2.new(1, -120, 1, -34),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Theme.Accent,
		AutoButtonColor = false,
		Parent = Selection,
	})
	Round(LoadButton, 7)
	New("TextLabel", {
		Text = "\226\150\160  " .. (config.LoadButtonText or "Load"),
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = LoadButton,
	})
	LoadButton.MouseEnter:Connect(function()
		Tween(LoadButton, { BackgroundColor3 = Theme.AccentDark }, 0.15)
	end)
	LoadButton.MouseLeave:Connect(function()
		Tween(LoadButton, { BackgroundColor3 = Theme.Accent }, 0.15)
	end)

	local switching = false
	LoadButton.MouseButton1Click:Connect(function()
		if switching then
			return
		end
		switching = true
		Tween(Loader, { BackgroundTransparency = 1 }, 0.2)
		for _, d in ipairs(Loader:GetDescendants()) do
			if d:IsA("GuiObject") then
				pcall(function()
					Tween(d, { BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1 }, 0.2)
				end)
			end
		end
		task.wait(0.2)
		Loader.Visible = false
		self.Dashboard.Visible = true
		self.Dashboard.Position = UDim2.new(0, 20, 0, 0)
		self.Dashboard.BackgroundTransparency = 1
		Tween(self.Dashboard, { Position = UDim2.new(0, 0, 0, 0) }, 0.35)
		if config.OnLoad then
			task.spawn(config.OnLoad)
		end
	end)
end

--------------------------------------------------------------------
-- Dashboard (tabs + sidebar)
--------------------------------------------------------------------

function Polaris:_buildDashboard(parent, config)
	local Dashboard = New("Frame", {
		Name = "Dashboard",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})
	self.Dashboard = Dashboard

	local sideWidth = IsMobile and 90 or 150

	local Sidebar = New("Frame", {
		Size = UDim2.new(0, sideWidth, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = Dashboard,
	})
	New("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = Sidebar,
	})

	local TabList = New("ScrollingFrame", {
		Size = UDim2.new(1, -12, 1, -16),
		Position = UDim2.new(0, 6, 0, 8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Faint,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = Sidebar,
	})
	New("UIListLayout", { Padding = UDim.new(0, 4), Parent = TabList })
	self.TabList = TabList

	local Content = New("Frame", {
		Size = UDim2.new(1, -sideWidth, 1, 0),
		Position = UDim2.new(0, sideWidth, 0, 0),
		BackgroundTransparency = 1,
		Parent = Dashboard,
	})
	self.Content = Content
end

function Polaris:CreateTab(name)
	local index = #self.Tabs + 1

	local TabButton = New("TextButton", {
		Text = "",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = index == 1 and Theme.Element or Theme.Sidebar,
		AutoButtonColor = false,
		Parent = self.TabList,
	})
	Round(TabButton, 6)
	New("TextLabel", {
		Text = name,
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = index == 1 and Theme.Text or Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Parent = TabButton,
	})

	local Page = New("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Faint,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = index == 1,
		Parent = self.Content,
	})
	New("UIListLayout", { Padding = UDim.new(0, 10), Parent = Page })

	local Tab = { Button = TabButton, Page = Page, Window = self }
	table.insert(self.Tabs, Tab)

	TabButton.MouseButton1Click:Connect(function()
		for i, t in ipairs(self.Tabs) do
			t.Page.Visible = (t == Tab)
			Tween(t.Button, { BackgroundColor3 = (t == Tab) and Theme.Element or Theme.Sidebar }, 0.15)
			for _, c in ipairs(t.Button:GetChildren()) do
				if c:IsA("TextLabel") then
					Tween(c, { TextColor3 = (t == Tab) and Theme.Text or Theme.SubText }, 0.15)
				end
			end
		end
	end)
	TabButton.MouseEnter:Connect(function()
		if Page.Visible then
			return
		end
		Tween(TabButton, { BackgroundColor3 = Theme.Element }, 0.15)
	end)
	TabButton.MouseLeave:Connect(function()
		if Page.Visible then
			return
		end
		Tween(TabButton, { BackgroundColor3 = Theme.Sidebar }, 0.15)
	end)

	function Tab:CreateSection(sectionName)
		return self.Window:_createSection(self.Page, sectionName)
	end

	return Tab
end

--------------------------------------------------------------------
-- Sections + Elements
--------------------------------------------------------------------

function Polaris:_createSection(page, name)
	local Section = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Panel,
		Parent = page,
	})
	Round(Section, 10)
	Stroke(Section, Theme.Stroke, 1, 0.3)

	New("TextLabel", {
		Text = name,
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -28, 0, 30),
		Position = UDim2.new(0, 14, 0, 4),
		Parent = Section,
	})

	local ItemHolder = New("Frame", {
		Size = UDim2.new(1, -20, 0, 0),
		Position = UDim2.new(0, 10, 0, 36),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = Section,
	})
	local Layout = New("UIListLayout", { Padding = UDim.new(0, 8), Parent = ItemHolder })
	New("UIPadding", { PaddingBottom = UDim.new(0, 12), Parent = ItemHolder })

	local SectionApi = { Holder = ItemHolder, Window = self }

	function SectionApi:CreateButton(opts)
		opts = opts or {}
		local Btn = New("TextButton", {
			Text = "",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Element,
			AutoButtonColor = false,
			Parent = ItemHolder,
		})
		Round(Btn, 7)
		New("TextLabel", {
			Text = opts.Name or "Button",
			Font = FONT_MED,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -24, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Parent = Btn,
		})
		Btn.MouseEnter:Connect(function()
			Tween(Btn, { BackgroundColor3 = Theme.ElementHover }, 0.15)
		end)
		Btn.MouseLeave:Connect(function()
			Tween(Btn, { BackgroundColor3 = Theme.Element }, 0.15)
		end)
		Btn.MouseButton1Click:Connect(function()
			Tween(Btn, { BackgroundColor3 = Theme.AccentDark }, 0.08)
			task.wait(0.08)
			Tween(Btn, { BackgroundColor3 = Theme.Element }, 0.18)
			if opts.Callback then
				task.spawn(opts.Callback)
			end
		end)
		return Btn
	end

	function SectionApi:CreateToggle(opts)
		opts = opts or {}
		local state = opts.Default or false

		local Row = New("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Element,
			Parent = ItemHolder,
		})
		Round(Row, 7)
		New("TextLabel", {
			Text = opts.Name or "Toggle",
			Font = FONT_MED,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -70, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Parent = Row,
		})

		local Track = New("Frame", {
			Size = UDim2.new(0, 40, 0, 20),
			Position = UDim2.new(1, -52, 0.5, -10),
			BackgroundColor3 = state and Theme.Accent or Theme.Stroke,
			Parent = Row,
		})
		Round(Track, 10)

		local Knob = New("Frame", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = Track,
		})
		Round(Knob, 8)

		local function setState(newState, fire)
			state = newState
			Tween(Track, { BackgroundColor3 = state and Theme.Accent or Theme.Stroke }, 0.2)
			Tween(Knob, { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.2, Enum.EasingStyle.Back)
			if opts.Flag then
				Polaris.Flags[opts.Flag] = state
			end
			if fire ~= false and opts.Callback then
				task.spawn(opts.Callback, state)
			end
		end

		Row.MouseButton1Click:Connect(function()
			setState(not state)
		end)

		if opts.Flag then
			Polaris.Flags[opts.Flag] = state
		end

		return {
			Set = function(_, v)
				setState(v)
			end,
			Get = function()
				return state
			end,
		}
	end

	function SectionApi:CreateSlider(opts)
		opts = opts or {}
		local min = opts.Min or 0
		local max = opts.Max or 100
		local increment = opts.Increment or 1
		local value = math.clamp(opts.Default or min, min, max)

		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Theme.Element,
			Parent = ItemHolder,
		})
		Round(Holder, 7)
		Pad(Holder, 12, 12, 6, 6)

		New("TextLabel", {
			Text = opts.Name or "Slider",
			Font = FONT_MED,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -50, 0, 18),
			Parent = Holder,
		})

		local ValueLabel = New("TextLabel", {
			Text = tostring(value),
			Font = FONT_MED,
			TextSize = 13,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 50, 0, 18),
			Position = UDim2.new(1, -50, 0, 0),
			Parent = Holder,
		})

		local Track = New("Frame", {
			Size = UDim2.new(1, 0, 0, 6),
			Position = UDim2.new(0, 0, 1, -10),
			BackgroundColor3 = Theme.Stroke,
			Parent = Holder,
		})
		Round(Track, 3)

		local Fill = New("Frame", {
			Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
			BackgroundColor3 = Theme.Accent,
			Parent = Track,
		})
		Round(Fill, 3)

		local Knob = New("Frame", {
			Size = UDim2.new(0, 14, 0, 14),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
			Parent = Track,
		})
		Round(Knob, 7)

		local dragging = false

		local function updateFromPos(xPos)
			local abs = Track.AbsolutePosition.X
			local size = Track.AbsoluteSize.X
			local pct = math.clamp((xPos - abs) / size, 0, 1)
			local raw = min + (max - min) * pct
			raw = math.floor(raw / increment + 0.5) * increment
			raw = math.clamp(raw, min, max)
			value = raw
			local newPct = (value - min) / (max - min)
			Fill.Size = UDim2.new(newPct, 0, 1, 0)
			Knob.Position = UDim2.new(newPct, 0, 0.5, 0)
			ValueLabel.Text = tostring(value)
			if opts.Flag then
				Polaris.Flags[opts.Flag] = value
			end
			if opts.Callback then
				task.spawn(opts.Callback, value)
			end
		end

		local function beginDrag(input)
			dragging = true
			updateFromPos(input.Position.X)
		end

		Track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				beginDrag(input)
			end
		end)
		Knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				beginDrag(input)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromPos(input.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		if opts.Flag then
			Polaris.Flags[opts.Flag] = value
		end

		return {
			Set = function(_, v)
				updateFromPos(Track.AbsolutePosition.X + (v - min) / (max - min) * Track.AbsoluteSize.X)
			end,
			Get = function()
				return value
			end,
		}
	end

	function SectionApi:CreateDropdown(opts)
		opts = opts or {}
		local options = opts.Options or {}
		local selected = opts.Default or options[1]
		local open = false

		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			Parent = ItemHolder,
			ZIndex = 5,
		})

		local Button = New("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Element,
			ZIndex = 5,
			Parent = Holder,
		})
		Round(Button, 7)

		New("TextLabel", {
			Text = opts.Name or "Dropdown",
			Font = FONT_MED,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, 0, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			ZIndex = 5,
			Parent = Button,
		})

		local SelectedLabel = New("TextLabel", {
			Text = tostring(selected or "Select"),
			Font = FONT_MED,
			TextSize = 13,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -36, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			ZIndex = 5,
			Parent = Button,
		})

		local Arrow = New("TextLabel", {
			Text = "\226\150\190",
			Font = FONT,
			TextSize = 11,
			TextColor3 = Theme.SubText,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 24, 1, 0),
			Position = UDim2.new(1, -26, 0, 0),
			ZIndex = 5,
			Parent = Button,
		})

		local List = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 1, 4),
			BackgroundColor3 = Theme.Element,
			ClipsDescendants = true,
			ZIndex = 10,
			Parent = Holder,
		})
		Round(List, 7)
		Stroke(List, Theme.Stroke, 1, 0.2)
		local ListLayout = New("UIListLayout", { Padding = UDim.new(0, 2), Parent = List })
		Pad(List, 4, 4, 4, 4)

		local Dropdown = { Button = Button, List = List }

		for _, option in ipairs(options) do
			local OptButton = New("TextButton", {
				Text = "",
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = Theme.Element,
				ZIndex = 11,
				Parent = List,
			})
			Round(OptButton, 5)
			New("TextLabel", {
				Text = tostring(option),
				Font = FONT,
				TextSize = 12,
				TextColor3 = Theme.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				ZIndex = 11,
				Parent = OptButton,
			})
			OptButton.MouseEnter:Connect(function()
				Tween(OptButton, { BackgroundColor3 = Theme.ElementHover }, 0.1)
			end)
			OptButton.MouseLeave:Connect(function()
				Tween(OptButton, { BackgroundColor3 = Theme.Element }, 0.1)
			end)
			OptButton.MouseButton1Click:Connect(function()
				selected = option
				SelectedLabel.Text = tostring(option)
				if opts.Flag then
					Polaris.Flags[opts.Flag] = selected
				end
				if opts.Callback then
					task.spawn(opts.Callback, selected)
				end
				Dropdown:Close()
			end)
		end

		function Dropdown:Open()
			open = true
			self.Window = self.Window
			Holder.ZIndex = 20
			List.Visible = true
			local target = #options * 30 + 8
			Tween(List, { Size = UDim2.new(1, 0, 0, target) }, 0.22)
			Tween(Arrow, { Rotation = 180 }, 0.22)
			self.Window = self
		end

		function Dropdown:Close()
			open = false
			Tween(List, { Size = UDim2.new(1, 0, 0, 0) }, 0.18)
			Tween(Arrow, { Rotation = 0 }, 0.18)
			task.delay(0.18, function()
				if not open then
					Holder.ZIndex = 5
				end
			end)
		end

		Button.MouseButton1Click:Connect(function()
			if self.Window.OpenDropdown and self.Window.OpenDropdown ~= Dropdown then
				self.Window.OpenDropdown:Close()
			end
			if open then
				Dropdown:Close()
				self.Window.OpenDropdown = nil
			else
				Dropdown:Open()
				self.Window.OpenDropdown = Dropdown
			end
		end)

		if opts.Flag then
			Polaris.Flags[opts.Flag] = selected
		end

		return Dropdown
	end

	function SectionApi:CreateTextbox(opts)
		opts = opts or {}
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Element,
			Parent = ItemHolder,
		})
		Round(Holder, 7)

		local Box = New("TextBox", {
			Text = opts.Default or "",
			PlaceholderText = opts.Placeholder or opts.Name or "Enter text",
			Font = FONT_MED,
			TextSize = 13,
			TextColor3 = Theme.Text,
			PlaceholderColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			Size = UDim2.new(1, -24, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Parent = Holder,
		})

		Box.FocusLost:Connect(function(enterPressed)
			if opts.Flag then
				Polaris.Flags[opts.Flag] = Box.Text
			end
			if opts.Callback then
				task.spawn(opts.Callback, Box.Text, enterPressed)
			end
		end)

		return Box
	end

	function SectionApi:CreateKeybind(opts)
		opts = opts or {}
		local bound = opts.Default or Enum.KeyCode.RightControl
		local listening = false

		local Row = New("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Element,
			Parent = ItemHolder,
		})
		Round(Row, 7)
		New("TextLabel", {
			Text = opts.Name or "Keybind",
			Font = FONT_MED,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -100, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Parent = Row,
		})

		local KeyLabel = New("TextLabel", {
			Text = bound.Name,
			Font = FONT_MED,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			BackgroundColor3 = Theme.Panel,
			Size = UDim2.new(0, 80, 0, 22),
			Position = UDim2.new(1, -90, 0.5, -11),
			Parent = Row,
		})
		Round(KeyLabel, 5)

		Row.MouseButton1Click:Connect(function()
			listening = true
			KeyLabel.Text = "..."
		end)

		UserInputService.InputBegan:Connect(function(input, gpe)
			if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
				bound = input.KeyCode
				KeyLabel.Text = bound.Name
				listening = false
				if opts.Flag then
					Polaris.Flags[opts.Flag] = bound
				end
				return
			end
			if not gpe and input.KeyCode == bound and opts.Callback then
				task.spawn(opts.Callback, bound)
			end
		end)

		return { Get = function() return bound end }
	end

	function SectionApi:CreateLabel(text)
		local Label = New("TextLabel", {
			Text = text,
			Font = FONT,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Parent = ItemHolder,
		})
		return Label
	end

	return SectionApi
end

--------------------------------------------------------------------
-- Notifications
--------------------------------------------------------------------

function Polaris:Notify(opts)
	opts = opts or {}
	local Holder = self.Gui

	local Notif = New("Frame", {
		Size = UDim2.new(0, 260, 0, 62),
		Position = UDim2.new(1, 20, 1, -80),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Theme.Panel,
		Parent = Holder,
	})
	Round(Notif, 9)
	Stroke(Notif, Theme.Stroke, 1, 0.2)
	Pad(Notif, 12, 12, 8, 8)

	New("TextLabel", {
		Text = opts.Title or "Notification",
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = Notif,
	})
	New("TextLabel", {
		Text = opts.Content or "",
		Font = FONT,
		TextSize = 12,
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0, 20),
		Parent = Notif,
	})

	Tween(Notif, { Position = UDim2.new(1, -280, 1, -80) }, 0.35, Enum.EasingStyle.Back)
	task.delay(opts.Duration or 3.5, function()
		Tween(Notif, { Position = UDim2.new(1, 20, 1, -80) }, 0.3)
		task.wait(0.3)
		Notif:Destroy()
	end)
end

function Polaris:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

return Polaris
