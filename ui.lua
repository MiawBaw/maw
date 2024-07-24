

local Christmas = false
local AprilFools = false
do
	local time = os.date("*t")
	if time.month == 12 and (time.day >= 24 and time.day <= 26) then
		Christmas = true
	elseif time.month == 4 and time.day == 1 then
		AprilFools = true
	end
end

local lib = {
	GuiObjects = {},
	Mouse = game:GetService("Players").LocalPlayer:GetMouse(),
	Keybinds = {},
	ProtectedInstances = {}
}

function lib.Create(class, props)
	local new = Instance.new(class)
	lib.ProtectedInstances[new] = true
	if props then
		for i,v in pairs(props) do
			if i ~= "Parent" then
				if typeof(v) == "Instance" then
					v.Parent = new
				else
					new[i] = v
				end
			end
		end
		
		new.Parent = props.Parent
	end
	return new
end

function lib.DimColor(color, percent)
	local r,g,b = percent or 0.3725, percent or 0.3764, percent or 0.3882
	return Color3.fromRGB(color.r * 255 * r, color.g * 255 * g, color.b * 255 * b)
end

function lib.CalculatePercentFromVal(min, max, val)
	--return (val-min)/(max-min)
	return 1 - (max-val)/(max-min)
end

function lib.CalculateValFromPercent(min, max, percent)
	return max*percent + (min * (1-percent))
end

function lib.RelativePosition(obj1, obj2, pos) --pos = Vector2
	--x axis--
	local xResult = obj2.AbsolutePosition.X + obj2.AbsoluteSize.X * obj2.AnchorPoint.X
	local x1 = obj1.AbsolutePosition.X
	local x2 = pos.X
	
	if x2 < 0 then
		xResult = x1 - x2 - obj2.AbsoluteSize.X * obj2.AnchorPoint.X
	elseif x2 > 0 then
		xResult = x1 + obj1.AbsoluteSize.X + x2 + obj2.AbsoluteSize.X * obj2.AnchorPoint.X
	end
	
	--y axis--
	local yResult = obj2.AbsolutePosition.Y + obj2.AbsoluteSize.Y * obj2.AnchorPoint.Y
	local y1 = obj1.AbsolutePosition.Y
	local y2 = pos.Y
	
	if y2 < 0 then
		yResult = y1 - y2 - obj2.AbsoluteSize.Y * (1 - obj2.AnchorPoint.Y)
	elseif y2 > 0 then
		yResult = y1 + obj1.AbsoluteSize.Y + y2 + obj2.AbsoluteSize.X * obj2.AnchorPoint.Y
	end
	
	return UDim2.new(0,xResult,0,yResult)
end

function lib.Tween(time, obj, prop, val)
	local new = game:GetService("TweenService"):Create(obj, TweenInfo.new(time), {
		[prop] = val
	})
	new:Play()
	return new
end

function lib:RegisterKeybind(key, callback)
	self.Keybinds[key] = callback
end

function lib:RemoveKeybind(key)
	self.Keybinds[key] = nil
end

function lib:RegisterGlobalClickEvent(callback)
	self.GlobalClickEvent = callback
end

function lib:RaiseGlobalClickEvent(obj)
	if self.GlobalClickEvent then
		self.GlobalClickEvent(obj)
	end
end

--Keybinds--
local GuiService = game:GetService("GuiService")
local EscMenuOpen = GuiService.MenuIsOpen

GuiService.MenuOpened:Connect(function()
	EscMenuOpen = true
end)

GuiService.MenuClosed:Connect(function()
	EscMenuOpen = false
end)

game:GetService("UserInputService").InputBegan:Connect(function(iobj, gp)
	if not gp or EscMenuOpen then
		local bind = lib.Keybinds[iobj.KeyCode]
		if bind then
			bind()
		end
	end
end)
--End of keybinds--

local uiBase = {}
uiBase.__index = uiBase

local uiTab = {}
uiTab.__index = uiTab

function uiTab:CheckBox(name, callback, id)
	local new = {
		Checked = false,
		Enabled = true,
		Type = "CheckBox",
		Children = {},
		Callback = callback,
		ParentObj = self,
		Id = id
	}
	
	new.CheckBoxFrame = lib.Create("Frame", {
		Name = name,
		BackgroundTransparency = 1,
		LayoutOrder = #self.Children,
		Size = UDim2.new(1,0,0,25),
		Parent = self.ContentFrame,
		
		lib.Create("ImageButton", {
			Name = "Toggle",
			BackgroundTransparency = 1,
			Position = UDim2.new(0,12,0,0),
			Size = UDim2.new(0,19,0,19),
			Image = "rbxassetid://2260429633",
			ImageColor3 = Color3.fromRGB(43, 47, 55),
			ScaleType = "Slice",
			SliceCenter = Rect.new(12,12,13,13),
			
			lib.Create("ImageButton", {
				Name = "Filler",
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5,0,0.5,0),
				Size = UDim2.new(0,13,0,13),
				Image = "rbxassetid://2260429633",
				ImageColor3 = Color3.fromRGB(26, 28, 32),
				ScaleType = "Slice",
				SliceCenter = Rect.new(12,12,13,13),
				
				lib.Create("ImageButton", {
					Name = "Inner",
					AnchorPoint = Vector2.new(0.5,0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5,0,0.5,0),
					Size = UDim2.new(0,9,0,9),
					Image = "rbxassetid://2260429633",
					ImageColor3 = Color3.fromRGB(26, 28, 32),
					ScaleType = "Slice",
					SliceCenter = Rect.new(12,12,13,13)
				})
			}),
			
			lib.Create("TextButton", {
				Name = "Label",
				AnchorPoint = Vector2.new(0,0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(1,5,0.5,0),
				Size = UDim2.new(1,0,1,0),
				Font = "GothamSemibold",
				Text = name,
				TextColor3 = Color3.fromRGB(95, 96, 99),
				TextSize = 15,
				TextXAlignment = "Left"
			})
		})
	})
	
	new.Components = {
		Toggle = {
			Object = new.CheckBoxFrame.Toggle,
			DefaultColor = Color3.fromRGB(255, 170, 0),
			DisabledColor = Color3.fromRGB(43, 47, 55),
			ChangeColor = true,
			Property = "ImageColor3"
		},
		Filler = {
			Object = new.CheckBoxFrame.Toggle.Filler,
			DefaultColor = Color3.fromRGB(26, 28, 32),
			ChangeColor = false,
		},
		Inner = {
			Object = new.CheckBoxFrame.Toggle.Filler.Inner,
			DefaultColor = Color3.fromRGB(255, 170, 0),
			DisabledColor = Color3.fromRGB(26, 28, 32),
			ChangeColor = true,
			Property = "ImageColor3"
		},
		Label = {
			Object = new.CheckBoxFrame.Toggle.Label,
			DefaultColor = Color3.new(1,1,1),
			DisabledColor = Color3.fromRGB(95, 96, 99),
			ChangeColor = true,
			Property = "TextColor3"
		}
	}
	
	do
		local label = new.Components.Label.Object
		label.Size = UDim2.new(0,game:GetService("TextService"):GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(999,999)).X, 1, 0)
	end
	
	function new:SetLabelColor(color)
		local label = self.Components.Label
		label.DefaultColor = color
		label.DisabledColor = lib.DimColor(color)
		if self.Checked then
			label.Object.TextColor3 = label.DefaultColor
		else
			label.Object.TextColor3 = label.DisabledColor
		end
	end
	
	function new:SetMultiLine()
		local label = self.Components.Label.Object
		label.TextYAlignment = "Top"
		local y = game:GetService("TextService"):GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(999,999)).Y
		y = y + 7
		self.CheckBoxFrame.Size = UDim2.new(1,0,0,y)
		self.ParentObj:Resize()
	end
	
	function new:Keybind(key, id)
		local bindBox = lib.Create("TextBox", {
			Name = "Keybind",
			BackgroundTransparency = 1,
			Position = UDim2.new(1,-37,0,0),
			Size = UDim2.new(0,32,0,22),
			Font = "GothamSemibold",
			TextColor3 = self.Checked and Color3.new(1,1,1) or Color3.fromRGB(95, 96, 99),
			TextSize = 16,
			Text = "(" .. key.Name .. ")",
			TextEditable = false,
			TextTruncate = "AtEnd",
			Parent = self.CheckBoxFrame
		})
		
		self.Components.Keybind = {
			Object = bindBox,
			CurrentKey = key,
			Type = "Keybind",
			Id = id,
			DefaultColor = Color3.new(1,1,1),
			DisabledColor = Color3.fromRGB(95, 96, 99),
			ChangeColor = true,
			Property = "TextColor3",
			SetKey = function(self, keyCode)
				lib:RemoveKeybind(new.Components.Keybind.CurrentKey)
				if keyCode == Enum.KeyCode.Delete or keyCode == Enum.KeyCode.Backspace then
					self.CurrentKey = "-"
					bindBox.Text = "-"
					return
				end
				self.CurrentKey = keyCode
				lib:RegisterKeybind(self.CurrentKey, new.Click)
				wait()
				bindBox.Text = "(" .. keyCode.Name .. ")"
			end
		}
		
		local isFocused = false
		bindBox.Focused:Connect(function()
			isFocused = true
		end)
		bindBox.FocusLost:Connect(function()
			isFocused = false
		end)
		game:GetService("UserInputService").InputBegan:Connect(function(iobj, gp)
			if gp and iobj.KeyCode ~= Enum.KeyCode.Unknown and not lib.Keybinds[iobj.KeyCode] and isFocused then
				self.Components.Keybind:SetKey(iobj.KeyCode)
				lib:RaiseGlobalClickEvent(self.Components.Keybind)
			end
		end)
		
		lib:RegisterKeybind(key, self.Click)
		table.insert(lib.GuiObjects, self.Components.Keybind)
	end
	
	function new:UpdateState(checked, triggerCallback)
		if self.Checked == checked then
			return
		end

		self.Checked = checked
		local index = self.Checked and "DefaultColor" or "DisabledColor"
		
		for _, v in pairs(self.Components) do
			if v.ChangeColor then
				if v.Tween then
					v.Tween:Pause()
				end
				v.Tween = lib.Tween(0.1, v.Object, v.Property, v[index])
			end
		end
		
		if triggerCallback then
			self.Callback(self.Checked)
		end
	end
	
	function new.Click(invoke, ...)
		if not new.Enabled then
			return
		end
		
		new:UpdateState(not new.Checked, false)
		
		if invoke ~= false then
			lib:RaiseGlobalClickEvent(new)
			new.Callback(new.Checked, ...)
		end
	end
	
	new.PrimaryFrame = new.CheckBoxFrame
	
	new.Components.Toggle.Object.MouseButton1Click:Connect(new.Click)
	new.Components.Filler.Object.MouseButton1Click:Connect(new.Click)
	new.Components.Inner.Object.MouseButton1Click:Connect(new.Click)
	new.Components.Label.Object.MouseButton1Click:Connect(new.Click)

	self:Resize()
	table.insert(self.Children, new)
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:Slider(options, callback, id)
	local new = {
		Min = options.Min,
		Max = options.Max,
		Value = options.Default or 0,
		Fraction = options.Fraction or 0,
		ValuePercent = 0,
		Type = "Slider",
		Callback = callback,
		SliderParent = options.Parent,
		Id = id
	}
	
	new.SliderFrame = lib.Create("Frame", {
		Name = "Slider",
		AnchorPoint = Vector2.new(0,0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0,12,0,45),
		Size = UDim2.new(1,-24,0,37),
		LayoutOrder = #self.Children,
		Parent = options.Parent and options.Parent.PrimaryFrame or self.ContentFrame,
		
		lib.Create("ImageLabel", {
			Name = "Bar",
			AnchorPoint = Vector2.new(0,0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0,0,0.25,0),
			Size = UDim2.new(1,0,0,4),
			Image = "rbxassetid://2260429633",
			ImageColor3 = Color3.fromRGB(43, 47, 55),
			ScaleType = "Slice",
			SliceCenter = Rect.new(12,12,13,13),
			
			lib.Create("ImageLabel", {
				Name = "Filler",
				BackgroundTransparency = 1,
				Size = UDim2.new(0,3,1,0), --x scale changes with the slider
				Image = "rbxassetid://2260429633",
				ImageColor3 = Color3.fromRGB(255, 170, 0),
				ScaleType = "Slice",
				SliceCenter = Rect.new(12,12,13,13)
			}),
			
			lib.Create("ImageButton", {
				Name = "DraggableBtn",
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0,0,0.5,0), --x scale changes with the slider
				Size = UDim2.new(0,10,0,17),
				Image = "rbxassetid://2260429633",
				ImageColor3 = Color3.new(1,1,1),
				ScaleType = "Slice",
				SliceCenter = Rect.new(12,12,13,13)
			}),
		}),
		
		lib.Create("TextBox", {
			Name = "Label",
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,-5),
			Font = "GothamSemibold",
			Text = "",
			TextSize = 12,
			TextYAlignment = "Bottom",
			TextColor3 = Color3.new(1,1,1)
		}),
		
		lib.Create("TextButton", {
			Name = "ClickCapture",
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,-14), -- -14 to make space for label clicking
			Text = ""
		})
	})
	
	new.PrimaryFrame = new.SliderFrame
	new.Bar = new.SliderFrame.Bar
	new.Draggable = new.Bar.DraggableBtn
	new.Filler = new.Bar.Filler
	new.Label = new.SliderFrame.Label
	new.ClickCapture = new.SliderFrame.ClickCapture
	
	if options.Parent then
		new.SliderFrame.Size = new.SliderFrame.Size + UDim2.new(0,12,0,0) --padding is added in the dummy frame
		
		local parentFrame = options.Parent.PrimaryFrame --only for checkboxes but eh
		--parentFrame.Size = parentFrame.Size + UDim2.new(0,0,0,37) --multiple sliders?
		
		if options.Parent.Type == "CheckBox" then
			local cbComponents = options.Parent.Components
			
			if #options.Parent.Children == 0 then
				local dummy = lib.Create("Frame", {
					Name = "Dummy",
					BackgroundTransparency = 1,
					Position = UDim2.new(0,12,0,0), --Padding
					Size = UDim2.new(1,-12,1,0),
					Parent = parentFrame,
					
					lib.Create("UIListLayout", {
						SortOrder = "LayoutOrder",
						Padding = UDim.new(0,5)
					})
				})
				
				options.Parent.DummyFrame = dummy
				options.Parent.DummyContentUILayout = dummy.UIListLayout
			
				cbComponents.Toggle.Object.Parent = dummy
			end
			new.SliderFrame.Parent = options.Parent.DummyFrame
			
			local idx = #options.Parent.Children + 1
			new.SliderFrame.LayoutOrder = idx
			
			cbComponents["SliderFiller" .. idx] = {
				Object = new.Filler,
				
				DefaultColor = Color3.fromRGB(255, 170, 0),
				DisabledColor = Color3.fromRGB(95, 96, 99),
				ChangeColor = true,
				Property = "ImageColor3"
			}
			cbComponents["SliderLabel" .. idx] = {
				Object = new.Label,
				
				DefaultColor = Color3.new(1,1,1),
				DisabledColor = Color3.fromRGB(95, 96, 99),
				ChangeColor = true,
				Property = "TextColor3"
			}
			
			if not options.Parent.Checked then
				new.Filler.ImageColor3 = cbComponents["SliderFiller" .. idx].DisabledColor
				new.Label.TextColor3 = cbComponents["SliderLabel" .. idx].DisabledColor
			end
			
			parentFrame.Size = UDim2.new(1,0,0,options.Parent.DummyContentUILayout.AbsoluteContentSize.Y)
			table.insert(options.Parent.Children, new)
		end
	end
	
	--position the stuff--
	local percent = lib.CalculatePercentFromVal(new.Min, new.Max, new.Value)
	new.Draggable.Position = UDim2.new(percent,0,0.5,0)
	new.Filler.Size = UDim2.new(percent,3,1,0)
	
	function new:SetValue(val)
		self.Value = val
		self.ValuePercent = lib.CalculatePercentFromVal(self.Min, self.Max, val)
		
		self.Draggable.Position = UDim2.new(self.ValuePercent,0,0.5,0)
		self.Filler.Size = UDim2.new(self.ValuePercent,3,1,0)
		self.Label.Text = self.Callback(self.Value)
	end
	
	function new:SetValuePercent(p)
		self.ValuePercent = p
		self.Value = math.floor(lib.CalculateValFromPercent(self.Min, self.Max, p) * 10^self.Fraction)/10^self.Fraction
		
		self.Draggable.Position = UDim2.new(self.ValuePercent,0,0.5,0)
		self.Filler.Size = UDim2.new(self.ValuePercent,3,1,0)
		self.Label.Text = self.Callback(self.Value)
	end
	
	--drag handler--
	local isMouseDown = false
	
	local function mouseDown()
		if isMouseDown then
			return
		end
		isMouseDown = true
		
		local size = new.Bar.AbsoluteSize.X
		local offset = new.Draggable.AbsoluteSize.X/2 --grab it in the middle
		
		local p = math.clamp((lib.Mouse.X - new.Bar.AbsolutePosition.X - offset)/size,0,1)
		while isMouseDown do
			local p = math.clamp((lib.Mouse.X - new.Bar.AbsolutePosition.X - offset)/size,0,1)
			
			if p > 0.03 and p < 0.97 then --otherwise it's sliding
				new.Draggable:TweenPosition(UDim2.new(p,0,0.5,0), nil, nil, 1/15, true)
				new.Filler:TweenSize(UDim2.new(p,3,1,0), nil, nil, 1/15, true)
			else
				new.Draggable.Position = UDim2.new(p,0,0.5,0)
				new.Filler.Size = UDim2.new(p,3,1,0)
			end
			new.ValuePercent = new.Draggable.Position.X.Scale
			new.Value = math.floor(lib.CalculateValFromPercent(new.Min, new.Max, new.ValuePercent) * 10^new.Fraction)/10^new.Fraction
			
			new.Label.Text = new.Callback(new.Value)
			wait()
		end
	end
	new.ClickCapture.MouseButton1Down:Connect(mouseDown)
	new.Draggable.MouseButton1Down:Connect(mouseDown)
	
	game:GetService("UserInputService").InputEnded:Connect(function(iobj, _gp)
		if isMouseDown and (iobj.UserInputType == Enum.UserInputType.MouseButton1) then
			isMouseDown = false
			new.ValuePercent = new.Draggable.Position.X.Scale
			new.Value = math.floor(lib.CalculateValFromPercent(new.Min, new.Max, new.ValuePercent) * 10^new.Fraction)/10^new.Fraction
			new.Draggable:TweenPosition(UDim2.new(new.ValuePercent,0,0.5,0), nil, nil, 0, true)
			new.Filler:TweenSize(UDim2.new(new.ValuePercent,3,1,0), nil, nil, 0, true)
			
			lib:RaiseGlobalClickEvent(new)
			new.Label.Text = new.Callback(new.Value)
		end
	end)
	
	--maually entering the value--
	new.Label.FocusLost:Connect(function()
		local val = tonumber(new.Label.Text)
		if not val then
			new.Label.Text = callback(new.Value)
		else
			new:SetValue(math.clamp(val,new.Min,new.Max))
			lib:RaiseGlobalClickEvent(new)
		end
	end)
	
	new.Label.Text = callback(new.Value)
	table.insert(self.Children, new)
	self:Resize()
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:Button(text, callback)
	local new = {
		Type = "Button",
		Callback = callback,
		DefaultColor = Color3.fromRGB(255, 170, 0)
	}
	
	new.ButtonFrame = lib.Create("Frame", {
		Name = text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,27),
		LayoutOrder = #self.Children,
		Parent = self.ContentFrame,
		
		lib.Create("ImageButton", {
			Name = "Button",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5,0),
			Position = UDim2.new(0.5,0,0,0),
			Size = UDim2.new(1,-12,0,22),
			Image = "rbxassetid://2260429633",
			ImageColor3 = new.DefaultColor,
			ScaleType = "Slice",
			SliceCenter = Rect.new(12,12,13,13),
			
			lib.Create("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Font = "GothamSemibold",
				Text = text,
				TextColor3 = Color3.new(1,1,1),
				TextSize = 16,
				TextTruncate = "AtEnd"
			}),
		}),

		lib.Create("Sound", {
			SoundId = "rbxassetid://903267862",
			Volume = 0.5
		})
	})
	
	new.PrimaryFrame = new.ButtonFrame
	new.Button = new.ButtonFrame.Button
	new.Label = new.Button.Label
	new.Sound = new.ButtonFrame.Sound
	
	function new:SetButtonColor(color)
		self.DefaultColor = color
		self.Button.ImageColor3 = color
	end
	
	local btnPressed = false
	new.Button.MouseButton1Down:Connect(function()
		btnPressed = true

		if new.ButtonTween then
			new.ButtonTween:Pause()
		end
		if new.LabelTween then
			new.LabelTween:Pause()
		end
		new.ButtonTween = lib.Tween(0.1, new.Button, "ImageColor3", lib.DimColor(new.DefaultColor, 0.7))
		new.LabelTween = lib.Tween(0.1, new.Label, "TextColor3", lib.DimColor(Color3.new(1,1,1), 0.7))
		
		--workaround for roblox being dumb--
		local ev
		ev = game:GetService("UserInputService").InputEnded:Connect(function(iobj)
			if iobj.UserInputType == Enum.UserInputType.MouseButton1 then
				ev:Disconnect()
				btnPressed = false
				if new.ButtonTween then
					new.ButtonTween:Pause()
				end
				if new.LabelTween then
					new.LabelTween:Pause()
				end
				new.ButtonTween = lib.Tween(0.1, new.Button, "ImageColor3", new.DefaultColor)
				new.LabelTween = lib.Tween(0.1, new.Label, "TextColor3", Color3.new(1,1,1))
			end
		end)
	end)
	new.Button.MouseButton1Up:Connect(function()
		if not btnPressed then
			return
		end
		btnPressed = false

		new.Sound:Play()
		new.Callback()
	end)
	
	table.insert(self.Children, new)
	self:Resize()
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:Label(text)
	local new = {
		Type = "Label",
		SetLabelColor = function(self, color)
			self.LabelObj.TextColor3 = color
		end
	}
	
	new.LabelObj = lib.Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,29),
		LayoutOrder = #self.Children,
		Text = text,
		Font = "GothamSemibold",
		TextColor3 = Color3.new(1,1,1),
		TextSize = 15,
		Parent = self.ContentFrame
	})
	
	new.PrimaryFrame = new.LabelObj
	
	table.insert(self.Children, new)
	self:Resize()
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:Dropdown(options, callback, id)
	local new = {
		Type = "Dropdown",
		Enabled = true,
		Values = options.Values,
		Callback = callback,
		ParentObj = self,
		Radio = options.Radio,
		Opened = false,
		Selected = nil,
		Id = id
	}
	
	new.DropdownFrame = lib.Create("Frame", {
		Name = "Dropdown - " .. options.Text,
		BackgroundTransparency = 1,
		LayoutOrder = #self.Children,
		Size = UDim2.new(1,0,0,35),
		Parent = self.ContentFrame,
		
		lib.Create("Frame", {
			Name = "Dummy",
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.new(1,0,0,30),
			ZIndex = 2,
			
			lib.Create("UIListLayout", {
				HorizontalAlignment = "Center",
				SortOrder = "LayoutOrder"
			}),
			
			lib.Create("TextLabel", {
				Name = "Title",
				BackgroundColor3 = Color3.fromRGB(27, 42, 53),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,30),
				Font = "GothamBold",
				Text = options.Text,
				TextColor3 = Color3.new(1,1,1),
				TextSize = 15,
				
				lib.Create("TextButton", {
					Name = "Expand",
					BackgroundTransparency = 1,
					Position = UDim2.new(1,-30,0,0),
					Size = UDim2.new(0,30,1,0),
					Font = "GothamBold",
					Text = "V",
					TextColor3 = Color3.new(1,1,1),
					TextSize = 15
				})
			})
		})
	})
	
	new.PrimaryFrame = new.DropdownFrame
	new.Dummy = new.DropdownFrame.Dummy
	new.ContentUILayout = new.Dummy.UIListLayout
	new.Components = {
		Values = {}
	}
	
	function new:CreateValueButtons()
		for i, v in ipairs(self.Values) do
			local btn = lib.Create("TextButton", {
				Name = v,
				BackgroundColor3 = Color3.fromRGB(32, 34, 40),
				BorderSizePixel = 0,
				LayoutOrder = i-1,
				Size = UDim2.new(1,0,0,30),
				Font = "GothamSemibold",
				Text = v,
				TextColor3 = Color3.new(1,1,1),
				TextSize = 16,
				ZIndex = 2,
				Parent = self.Dummy
			})
			self.Components.Values[i] = btn
			btn.MouseButton1Click:Connect(function()
				self:Select(i)
			end)
		end
	end
	
	new:CreateValueButtons()
	
	function new:Expand(bool)
		if bool then
			local y = self.ContentUILayout.AbsoluteContentSize.Y
			
			self.DropdownFrame.Size = UDim2.new(1,0,0,y+5)
			self.Dummy.Size = UDim2.new(1,0,0,y)
		else
			self.DropdownFrame.Size = UDim2.new(1,0,0,35)
			self.Dummy.Size = UDim2.new(1,0,0,30)
		end
		self.ParentObj:Resize(true, 0.4)
	end
		
	function new:Select(idx)
		if self.Radio then
			local old = self.Selected
			self.Selected = idx
			
			if old then
				if self.Components.Values[old] then
					self.Components.Values[old].BackgroundColor3 = Color3.fromRGB(32, 34, 40)
				else
					warn("[KiriotHub] This isn't supposed to print #1", old)
				end
			end
			if self.Components.Values[idx] then
				self.Components.Values[idx].BackgroundColor3 = Color3.fromRGB(255, 170, 0)
			else
				warn("[KiriotHub] This isn't supposed to print #2", idx)
			end
		end
		
		lib:RaiseGlobalClickEvent(self)
		self.Callback(self.Values[idx])
	end
	
	function new:Update(newValues, keepSelection)
		-- Clear existing buttons
		for _, btn in pairs(self.Components.Values) do
			btn:Destroy()
		end
		
		-- Update values
		self.Values = newValues
		self.Components.Values = {}
		
		-- Recreate buttons
		self:CreateValueButtons()
		
		-- Update selection
		if keepSelection and self.Selected and self.Selected <= #newValues then
			self:Select(self.Selected)
		elseif #newValues > 0 then
			self:Select(1)
		else
			self.Selected = nil
		end
		
		-- Update size
		if self.Opened then
			self:Expand(true)
		end
	end
	
	if options.Radio then
		local default = options.Default or 1
		new:Select(default)
	end
	
	new.ExpandBtn = new.Dummy.Title.Expand
	new.ExpandBtn.MouseButton1Click:Connect(function()
		new.Opened = not new.Opened
		new:Expand(new.Opened)
	end)
	
	table.insert(self.Children, new)
	self:Resize()
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:List(options)
	local new = setmetatable({
		Type = "List",
		Children = {},
	}, uiTab)
	
	new.ListFrame = lib.Create("ScrollingFrame", {
		Name = "List",
		BackgroundColor3 = Color3.fromRGB(48, 51, 59),
		BorderSizePixel = 0,
		Size = UDim2.new(1,options.NoPadding and 0 or -24,0,options.Height),
		ClipsDescendants = true,
		CanvasSize = UDim2.new(0,0,0,0),
		ScrollBarThickness = 6,
		LayoutOrder = #self.Children,
		Parent = self.ContentFrame,
		
		lib.Create("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-6,1,0),
			
			lib.Create("UIListLayout", {
				HorizontalAlignment = "Center",
				SortOrder = "LayoutOrder"
			})
		})
	})
	
	new.PrimaryFrame = new.ListFrame
	new.ContentFrame = new.ListFrame.Content
	new.ContentUILayout = new.ContentFrame.UIListLayout
	
	new.ContentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		new:Resize()
	end)
	
	table.insert(self.Children, new)
	self:Resize()
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:TextBox(options, callback, id)
	local new = {
		Type = "TextBox",
		Callback = callback,
		Id = id,
		Text = "",
	}

	new.TextBoxFrame = lib.Create("Frame", {
		Name = "TextBoxFrame",
		BackgroundTransparency = 1,
		LayoutOrder = #self.Children,
		Size = UDim2.new(1,-20,0,31),
		Parent = self.ContentFrame,

		lib.Create("TextBox", {
			Name = "TextBox",
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(39, 39, 39),
			BorderSizePixel = 3,
			BorderColor3 = Color3.new(0,0,0),
			ClearTextOnFocus = options.ClearOnFocus or options.ClearOnFocus == nil and true, --avoid "false or true", only "nil or true"
			Position = UDim2.new(0.5,0,0,2),
			Size = UDim2.new(1,0,0,21),
			TextEditable = not options.ReadOnly,
			Font = "Gotham",
			PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
			PlaceholderText = options.PlaceholderText or "",
			Text = options.DefaultText or "",
			TextColor3 = Color3.new(1,1,1),
			TextSize = 14,
			TextWrapped = true,
			TextTruncate = "AtEnd"
		})
	})

	new.TextBox = new.TextBoxFrame.TextBox

	local truncated = false
	function new:SetText(text)
		self.Text = text
		self.TextBox.Text = text
		--[[if not self.TextBox.TextFits and #text > 1 then
			truncated = true
			if #text > 40 then
				self.TextBox.Text = text:sub(1, 40)
			end
			while not self.TextBox.TextFits and #self.TextBox.Text > 1 do
				self.TextBox.Text = self.TextBox.Text:sub(1, #self.TextBox.Text - 1)
			end
			local tmp = self.TextBox.Text
			self.TextBox.Text = tmp .. "(...)"
			while not self.TextBox.TextFits and #self.TextBox.Text > 1 do
				tmp = tmp:sub(1, #tmp - 1)
				self.TextBox.Text = tmp .. "(...)"
			end
		else
			truncated = false
		end]]
	end

	new.TextBox.Focused:Connect(function()
		if truncated and not new.TextBox.ClearTextOnFocus then
			new.TextBox.Text = new.Text
		end
	end)

	new.TextBox.FocusLost:Connect(function(...)
		new:SetText(new.TextBox.Text)
		lib:RaiseGlobalClickEvent(self)
		if new.Callback(new.Text, ...) then
			new:SetText("")
		end
	end)

	table.insert(self.Children, new)
	self:Resize()
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:AddCustomObject(obj)
	local new = {
		Type = "CustomObject",
		Object = obj,
		PrimaryFrame = obj
	}
	obj.Parent = self.ContentFrame
	obj.LayoutOrder = #self.Children
	
	table.insert(self.Children, new)
	self:Resize()
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:Clear()
	for i,v in pairs(self.Children) do
		self.Children[i] = nil
		v.PrimaryFrame:Destroy()
		
		local i = table.find(lib.GuiObjects, v)
		if i then
			table.remove(lib.GuiObjects, i)
		end
	end
end

function uiTab:Draggable()
	if self.Type ~= "Tab" and self.Type ~= "Popup" and self.Type ~= "Box" then
		return
	end
	
	local topBar = self.Topbar
	local isDragging = false
	local dragStart,startPos,dragInputObj
	
	topBar.InputBegan:Connect(function(iobj)
		if iobj.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			dragStart = iobj.Position
			startPos = self.PrimaryFrame.Position
		end
		iobj.Changed:Connect(function()
			if iobj.UserInputState == Enum.UserInputState.End then
				isDragging = false
			end
		end)
	end)
	topBar.InputChanged:Connect(function(iobj)
		if iobj.UserInputType == Enum.UserInputType.MouseMovement then
			dragInputObj = iobj
		end
	end)
	game:GetService("UserInputService").InputChanged:Connect(function(iobj)
		if iobj == dragInputObj and isDragging then
			local offset = iobj.Position - dragStart
			self.PrimaryFrame.Position = startPos + UDim2.new(0,offset.X,0,offset.Y)
		end
	end)
end

function uiTab:Group(name)
	local new = setmetatable({
		Opened = true,
		Type = "Group",
		Children = {},
		ParentObj = self
	}, uiTab)
	
	new.GroupFrame = lib.Create("Frame", {
		BackgroundTransparency = 1,
		Name = "Group - " .. name,
		ClipsDescendants = true,
		LayoutOrder = #self.Children, --0, 1, 2
		Size = UDim2.new(1,0,0,35),
		Parent = self.ContentFrame,
		
		lib.Create("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			Position = UDim2.new(0,0,0,35),
			Size = UDim2.new(1,0,1,-35),
			ClipsDescendants = true, --might help?
			
			--uilist or uigrid
			lib.Create("UIListLayout", {
				HorizontalAlignment = "Center",
				SortOrder = "LayoutOrder"
			})
		}),
		
		lib.Create("TextLabel", {
			Name = "Title",
			BackgroundColor3 = Color3.fromRGB(48, 51, 59),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,30),
			Font = "GothamBold",
			Text = name,
			TextColor3 = Color3.new(1,1,1),
			TextSize = 15,
			
			lib.Create("TextButton", {
				Name = "Expand",
				BackgroundTransparency = 1,
				Position = UDim2.new(1,-30,0,0),
				Size = UDim2.new(0,30,1,0),
				Font = "GothamBold",
				Text = "-",
				TextColor3 = Color3.new(1,1,1),
				TextSize = 20,
			})
		})
	})
	
	new.PrimaryFrame = new.GroupFrame
	new.ContentFrame = new.GroupFrame.Content
	new.ContentUILayout = new.ContentFrame.UIListLayout
	new.ExpandBtn = new.GroupFrame.Title.Expand
	new.ExpandBtn.MouseButton1Click:Connect(function()
		new.Opened = not new.Opened
		new:Expand(new.Opened)
	end)
	
	table.insert(self.Children, new)
	
	if self.Type == "Group" then
		self:Expand(true)
	elseif self.Type == "Tab" then
		self:Resize()
	end
	
	table.insert(lib.GuiObjects, new)
	return new
end

function uiTab:SetOrder(obj, order)
	local i = table.find(self.Children, obj)
	if not obj then
		return
	end
	
	table.remove(self.Children, i)
	table.insert(self.Children, order+1, obj)
	for i,v in pairs(self.Children) do
		v.PrimaryFrame.LayoutOrder = i-1
	end
end

function uiTab:Grid(cellPadding, cellSize, center) --mostly for Groups
	self.IsGrid = true
	self.ContentUILayout:Destroy()
	self.ContentUILayout = lib.Create("UIGridLayout", {
		CellPadding = cellPadding,
		CellSize = cellSize,
		SortOrder = "LayoutOrder",
		Parent = self.ContentFrame,
		HorizontalAlignment = center and "Center" or nil
	})
	
	--UIGridLayout moves elements to the next row when the width is too small, so it cannot be Scale (independent of parent)
	if self.ParentObj and self.ParentObj.Size then
		self.ContentFrame.Size = UDim2.new(0,self.ParentObj.Size.X.Offset,self.ContentFrame.Size.Y.Scale,self.ContentFrame.Size.Y.Offset)
	end
end

function uiTab:Expand(bool) --for groups mostly
	if self.Type == "Tab" then
		if bool then
			self.NoRoundFrame:TweenSize(UDim2.new(1,0,0,10),nil,nil,0.1,true)
			wait(0.1)
			self:Resize(true, 0.4)
		else
			self:Resize(true, 0.4, UDim2.new(0,self.TabFrame.Size.X.Offset,0,34))
			wait(0.4)
			self.NoRoundFrame:TweenSize(UDim2.new(1,0,0,0),nil,nil,0.1,true)
		end
		self.Opened = bool
	elseif self.Type == "Group" then
		self.Opened = bool
		if bool then
			self:Resize(true, 0.4)
			self.ExpandBtn.Text = "-"
		else
			self:Resize(true, 0.4, UDim2.new(1,0,0,35))
			self.ExpandBtn.Text = "+"
		end
		self.ParentObj:Resize(true, 0.4)
	end
end

function uiTab:GetMaxSize()
	local size = UDim2.new(0,self.TabFrame.Size.X.Offset,0,0)
	for i,v in pairs(self.Children) do
		if v.Type == "Group" then
			size = size + UDim2.new(0,0,0,v.ContentUILayout.AbsoluteContentSize.Y + 35)
		else
			size = size + UDim2.new(0,0,0,v.PrimaryFrame.AbsoluteSize.Y)
		end
	end
	return size
end

function uiTab:GetActiveSize() --mostly for tabs
	local size = UDim2.new(0,self.PrimaryFrame.Size.X.Offset,0,0)
	if self.Type == "Popup" and self.Opened then --no idea why but it works (the self.Opened is supposed to be false, perhaps a race condition?)
		size = UDim2.new(0,self.Size.X.Offset,0,0)
	elseif self.Type == "BoxGroup" then
		return self:GetSize()
	end
	for i,v in pairs(self.Children) do
		if v.Type == "Group" or v.Type == "Dropdown" then
			if v.Opened then
				size = size + UDim2.new(0,0,0,v.ContentUILayout.AbsoluteContentSize.Y + 35)
			else
				size = size + UDim2.new(0,0,0,35) --35 or 30?
			end
		else
			size = size + UDim2.new(0,0,0,v.PrimaryFrame.AbsoluteSize.Y)
		end
	end
	return size
end

function uiTab:GetSize() --beware of tweening!
	if self.Type == "Tab" then
		return UDim2.new(0,self.TabFrame.Size.X.Offset,0,self.ContentUILayout.AbsoluteContentSize.Y + 35) --35
	elseif self.Type == "Group" then
		return UDim2.new(1,0,0,self.ContentUILayout.AbsoluteContentSize.Y + 35) --35
	elseif self.Type == "List" then
		return UDim2.new(0,0,0,self.ContentUILayout.AbsoluteContentSize.Y)
	elseif self.Type == "BoxGroup" then
		return UDim2.new(0,self.PrimaryFrame.Size.X.Offset,0,self.ContentUILayout.AbsoluteContentSize.Y + 34)
	end
end

function uiTab:Resize(tween, time, size)
	local obj
	
	if self.Type == "Tab" or self.Type == "BoxGroup" or (self.Type == "Popup" and self.Opened) then
		if not size then
			size = self:GetActiveSize()
			if self.Topbar then
				size = size + UDim2.new(0,0,0,self.Topbar.Size.Y.Offset)
			end
		end
		obj = self.PrimaryFrame
		
		--hardcoding time--
		local last = self.Children[#self.Children] --TODO: slider is also in children!!!
		if last and last.Type == "Group" then
			local lastChild = last.Children[#last.Children]
			
			if lastChild and lastChild.Type == "Dropdown" and last.Opened then
				size = size + UDim2.new(0,0,0,10)
			elseif not last.Opened then
				size = size + UDim2.new(0,0,0,5)
			end
		end
	elseif self.Type == "Group" then
		if not size then
			if self.Opened then
				size = self:GetSize()
			else
				size = UDim2.new(1,0,0,35)
			end
		end
		
		obj = self.GroupFrame
		self.ParentObj:Resize(tween, time)
	elseif self.Type == "List" then
		size = self:GetSize()
		obj = self.ListFrame
		
		obj.CanvasSize = size
		return
	end
	
	if not obj then --invalid type?
		return
	end
	
	if tween then
		local ev
		if self.Type == "BoxGroup" then --lazy fix for repositioning the groups in box ui on tween
			ev = obj:GetPropertyChangedSignal("Size"):Connect(function()
				self:Position()
				self.ParentObj:Resize()
			end)
		end
		obj:TweenSize(size, nil, nil, time, true, function()
			if ev then
				ev:Disconnect()
			end
		end)
	else
		obj.Size = size
		if self.Type == "BoxGroup" then
			self:Position()
			self.ParentObj:Resize()
		end
	end
end

function uiTab:Align()
	local pos = UDim2.new(0,0,0,0)
	
	local idx = table.find(self.ParentObj.Tabs, self)
	for i=1,idx-1 do
		local tab = self.ParentObj.Tabs[i]
		pos = pos + UDim2.new(0,tab.TabFrame.AbsoluteSize.X + 8,0,0)
	end
	
	self.TabFrame.Position = pos
end

function uiBase:Tab(title, options)
	local new = setmetatable({
		Type = "Tab",
		Children = {},
		Size = UDim2.new(0,options and options.Width or 167,0,35),
		ParentObj = self
	}, uiTab)
	
	new.TabFrame = lib.Create("ImageLabel", {
		Name = title,
		BackgroundTransparency = 1,
		ClipsDescendants = true, --weee
		Size = new.Size,
		Image = "rbxassetid://2260429633",
		ImageColor3 = Color3.fromRGB(26, 28, 32),
		ScaleType = "Slice",
		SliceCenter = Rect.new(12,12,13,13),
		LayoutOrder = #self.Tabs, --0, 1, 2
		Parent = self.TabsFrame,
		
		lib.Create("Frame", {
			Name = "Topbar",
			Size = UDim2.new(1,0,0,35), --35
			BackgroundTransparency = 1,
			ZIndex = 2,
			
			lib.Create("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0,0,0,-1),
				Size = UDim2.new(1,0,1,0),
				Image = "rbxassetid://2260429633",
				ImageColor3 = Color3.fromRGB(255, 170, 0),
				ScaleType = "Slice",
				SliceCenter = Rect.new(12,12,13,13),
				
				lib.Create("Frame", {
					Name = "NoRound",
					BackgroundColor3 = Color3.fromRGB(255, 170, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0,0,1,-10),
					Size = UDim2.new(1,0,0,10)
				})
			}),
			
			lib.Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Font = "GothamBold",
				Text = title,
				TextSize = 20,
				TextColor3 = Color3.new(1,1,1)
			})
		}),
		
		lib.Create("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			Position = UDim2.new(0,0,0,34),
			Size = UDim2.new(1,0,1,-34),
			
			lib.Create("UIListLayout", {
				HorizontalAlignment = "Center",
				SortOrder = "LayoutOrder"
			})
		})
	})
	
	new.PrimaryFrame = new.TabFrame
	new.Topbar = new.TabFrame.Topbar
	new.NoRoundFrame = new.TabFrame.Topbar.ImageLabel.NoRound
	new.ContentFrame = new.TabFrame.Content
	new.ContentUILayout = new.ContentFrame.UIListLayout
	
	local lastClickStart, lastClickEnd
	new.Topbar.InputBegan:Connect(function(iobj, gp)
		if gp then return end
		if iobj.UserInputType == Enum.UserInputType.MouseButton1 then
			lastClickStart = tick()
		end
	end)
	new.Topbar.InputEnded:Connect(function(iobj, gp)
		if gp then return end
		if iobj.UserInputType == Enum.UserInputType.MouseButton1 then
			if lastClickEnd and lastClickStart and tick() - lastClickEnd < 0.5 and tick() - lastClickStart < 0.5 then
				new:Align()
				--not setting the tick on purpose here
			else
				lastClickEnd = tick()
			end
		end
	end)
	
	new:Draggable()
	
	table.insert(self.Tabs, new)
	self:AlignTabs()

	--snow--
	if Christmas then
		local rnd = Random.new()
		local rs = game:GetService("RunService").Heartbeat
		local flakes = {}
		local last
		spawn(function()
			while not shared.NoSnow do
				--creating new snowflakes--
				if not last or tick()-last > 0.1 and #new.TabFrame:GetChildren() < 22 then
					local modifier = rnd:NextInteger(1, 5)

					local flake = Instance.new("ImageLabel")
					flake.BackgroundTransparency = 1
					flake.Size = UDim2.new(0,5*modifier,0,5*modifier)
					flake.Image = "rbxassetid://320426443"
					flake.AnchorPoint = Vector2.new(0.5,0.5)
					flake.Position = UDim2.new(0,rnd:NextInteger(0, new.TabFrame.Size.X.Offset),0,-3)
					flake.Parent = new.TabFrame
					table.insert(flakes, {
						Obj = flake,
						Speed = modifier,
						StartPos = flake.Position,
						Sine = rnd:NextNumber(0, math.rad(180)),
					})
					last = tick()
				end

				local i = 1
				while i <= #flakes do
					local v = flakes[i]
					v.Obj.Position = UDim2.new(0, v.StartPos.X.Offset + math.sin((tick() + v.Sine) * 1.5) * 100/(6 - v.Speed), 0, v.Obj.Position.Y.Offset + v.Speed)
					if v.Obj.Position.Y.Offset > (new.TabFrame.AbsolutePosition.Y + new.TabFrame.AbsoluteSize.Y + 3) then
						v.Obj:Destroy()
						table.remove(flakes, i)
						i = i - 1
					end
					i = i + 1
				end
				--updating snowflakes--
				rs:Wait()
				rs:Wait()
			end
			for i,v in pairs(flakes) do
				v.Obj:Destroy()
			end
		end)
	end
	return new
end

function uiBase:Popup(title, options)
	local new = setmetatable({
		Type = "Popup",
		Children = {},
		Size = options and options.Size or UDim2.new(0,290,0,305),
		Opened = false
	}, uiTab)
	
	new.PopupFrame = lib.Create("ImageLabel", {
		Name = title,
		AnchorPoint = Vector2.new(0.5,0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0.5,0,0.5,0),
		Size = UDim2.new(0,0,0,0),
		Parent = self.Gui,
		Image = "rbxassetid://2260429633",
		ImageColor3 = Color3.fromRGB(26, 28, 32),
		ScaleType = "Slice",
		SliceCenter = Rect.new(12,12,13,13),
		
		lib.Create("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			Position = UDim2.new(0,0,0,71),
			Size = UDim2.new(1,0,1,-71),
			
			lib.Create("UIListLayout", {
				HorizontalAlignment = "Center",
				SortOrder = "LayoutOrder"
			})
		}),
		
		lib.Create("Frame", {
			Name = "Topbar",
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.new(1,0,0,72),
			ZIndex = 2,
			
			lib.Create("ImageLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0,0,0,-1),
				Size = UDim2.new(1,0,1,0),
				Image = "rbxassetid://2260429633",
				ImageColor3 = Color3.fromRGB(255, 170, 0),
				ScaleType = "Slice",
				SliceCenter = Rect.new(12,12,13,13),
				
				lib.Create("Frame", {
					Name = "NoRound",
					BackgroundColor3 = Color3.fromRGB(255, 170, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0,0,1,-10),
					Size = UDim2.new(1,0,0,10),
				})
			}),
			
			lib.Create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Font = "GothamBold",
				Text = title,
				TextColor3 = Color3.new(1,1,1),
				TextSize = 32
			})
		})
	})
	
	new.PrimaryFrame = new.PopupFrame
	new.ContentFrame = new.PopupFrame.Content
	new.ContentUILayout = new.ContentFrame.UIListLayout
	new.Topbar = new.PopupFrame.Topbar
	
	new:Draggable()
	
	function new:Toggle(bool)
		if bool == nil then
			bool = not self.Opened
		end
		
		self.Opened = bool
		if bool then
			--self.PrimaryFrame:TweenSize(self.Size, nil, nil, 0.3, true)
			self:Resize(true, 0.3)
		else
			self.PrimaryFrame:TweenSize(UDim2.new(0,0,0,0), nil, nil, 0.3, true)
		end
	end
	
	return new
end

function uiBase:AlignTabs()
	if #self.Tabs < 1 then
		return
	end
	
	table.sort(self.Tabs, function(a,b)
		return a.TabFrame.LayoutOrder < b.TabFrame.LayoutOrder
	end)
	
	self.Tabs[1].Position = UDim2.new(0,0,0,0)
	for i=2,#self.Tabs do
		local tab = self.Tabs[i].TabFrame
		local prev = self.Tabs[i-1].TabFrame
		
		tab.Position = UDim2.new(0,prev.Position.X.Offset + prev.AbsoluteSize.X + 8,0,0) --8 is padding
	end
end

function lib.UiBase()
	local new = setmetatable({
		Type = "WindowBase",
		Tabs = {}
	}, uiBase)
	
	new.Gui = lib.Create("ScreenGui", {
		Name = math.random(),
		DisplayOrder = 1, --new escape menu
		Parent = game.CoreGui,
		
		lib.Create("Frame", {
			Name = "Tabs",
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			
			--[[lib.Create("UIListLayout", {
				Padding = UDim.new(0,8),
				FillDirection = "Horizontal",
				SortOrder = "LayoutOrder"
			})]]
		})
	})

	new.TabsFrame = new.Gui.Tabs
	lib.Gui = new.Gui
	
	lib:RegisterKeybind(Enum.KeyCode.RightShift, function()
		new.Gui.Enabled = not new.Gui.Enabled
	end)

	if AprilFools then
		local gui = Instance.new("ScreenGui")
		gui.Name = math.random()
		gui.Parent = game.CoreGui

		lib.ProtectedInstances[gui] = true
		local troll = Instance.new("ImageLabel")
		troll.BackgroundTransparency = 1
		troll.Size = UDim2.new(0,200,0,200)
		troll.Image = "rbxassetid://5873794859"
		troll.Position = UDim2.new(1,0,0.7,0)
		troll.Parent = gui
		troll.Rotation = -20
		local sound = Instance.new("Sound", gui)
		sound.Volume = 1

		local rnd = Random.new()
		spawn(function()
			while not shared.NoTroll do
				wait(rnd:NextInteger(30, 240))
				sound:Play()
				troll:TweenPosition(UDim2.new(1,-150,0.7,0), nil, nil, 5, true)
				wait(5 + 7)
				troll:TweenPosition(UDim2.new(1,0,0.7,0), nil, nil, 5, true)
				wait(5)
				sound:Stop()
			end
		end)

	end
	
	return new
end

--box ui go brrr--
local uiBox = {}
uiBox.__index = uiBox
uiBox.Draggable = uiTab.Draggable

local uiBoxTab = {}
uiBoxTab.__index = uiBoxTab
function lib.BoxUiBase(title)
	local new = setmetatable({
		Type = "Box",
		Tabs = {},
		Selected = nil
	}, uiBox)

	new.Gui = lib.Create("ScreenGui", {
		Name = math.random(),
		DisplayOrder = 1, --new escape menu
		
		lib.Create("Frame", {
			Name = "Main",
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(255, 170, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5,0,0.5,0),
			Size = UDim2.new(0,700,0,539),
			
			lib.Create("Frame", {
				Name = "Topbar",
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,40),
			}),
			lib.Create("TextButton", {
				Name = "MouseUnlock",
				BackgroundTransparency = 1,
				BorderSizePixel = 1,
				Modal = true,
				Size = UDim2.new(0,0,0,0),
				Text = ""
			}),
			lib.Create("UICorner", {
				CornerRadius = UDim.new(0,13)
			}),
			lib.Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0,20,0,0),
				Size = UDim2.new(1,-20,0,40),
				Font = "SourceSansSemibold",
				Text = title or "",
				TextSize = 32,
				TextXAlignment = "Left",
				TextColor3 = Color3.new(1,1,1)
			}),
			lib.Create("Frame", {
				Name = "NoRound",
				BackgroundColor3 = Color3.fromRGB(255, 170, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(0,0,1,-10),
				Size = UDim2.new(1,0,0,10)
			}),
	
			lib.Create("Frame", {
				Name = "Inner",
				BackgroundTransparency = 1,
				Position = UDim2.new(0,10,0,40),
				Size = UDim2.new(1,-10,1,-40),
	
				lib.Create("Frame", {
					Name = "NoRoundBottom",
					BackgroundColor3 = Color3.fromRGB(26, 28, 32),
					BorderSizePixel = 0,
					Position = UDim2.new(0,0,1,-10),
					Size = UDim2.new(1,0,0,10)
				}),
				lib.Create("Frame", {
					Name = "Content",
					BackgroundColor3 = Color3.fromRGB(26, 28, 32),
					BorderSizePixel = 0,
					Size = UDim2.new(1,0,1,0),
	
					lib.Create("UICorner", {
						CornerRadius = UDim.new(0,13)
					}),
					lib.Create("Frame", {
						Name = "Carousel",
						BackgroundTransparency = 1,
						Size = UDim2.new(0,150,1,0),
	
						lib.Create("Frame", {
							Name = "NoRound",
							BackgroundColor3 = Color3.fromRGB(48, 51, 59),
							BorderSizePixel = 0,
							Position = UDim2.new(0,0,1,-10),
							Size = UDim2.new(1,0,0,10)
						}),
						lib.Create("Frame", {
							Name = "NoRoundTop",
							BackgroundColor3 = Color3.fromRGB(48, 51, 59),
							BorderSizePixel = 0,
							Position = UDim2.new(1,-20,0,0),
							Size = UDim2.new(0,20,0,10)
						}),
	
						lib.Create("Frame", {
							Name = "Content",
							BackgroundColor3 = Color3.fromRGB(48, 51, 59),
							BorderSizePixel = 0,
							Size = UDim2.new(1,0,1,0),
							--ZIndex = 1, --prevent scrollbar from clipping behind NoRoundTop, edit: ordering bullshit, doesn't work
	
							lib.Create("UICorner", {
								CornerRadius = UDim.new(0,13)
							}),
							lib.Create("ScrollingFrame", {
								Name = "List",
								BackgroundTransparency = 1,
								Size = UDim2.new(1,0,1,0),
								ClipsDescendants = true,
								ScrollBarThickness = 6,
								CanvasSize = UDim2.new(),
	
								lib.Create("UIListLayout", {
									SortOrder = "LayoutOrder",
								})
							})
						})
					}),
					lib.Create("Frame", {
						Name = "Tabs",
						BackgroundColor3 = Color3.fromRGB(26, 28, 32),
						BorderSizePixel = 0,
						Position = UDim2.new(0,150,0,0),
						Size = UDim2.new(1,-150,1,0),
					})
				})
			})
		})
	})


	new.BoxFrame = new.Gui.Main
	new.Topbar = new.BoxFrame.Topbar
	new.PrimaryFrame = new.BoxFrame
	new.TabsFrame = new.BoxFrame.Inner.Content.Tabs
	new.CarouselFrame = new.BoxFrame.Inner.Content.Carousel
	new.CarouselContentFrame = new.CarouselFrame.Content.List
	new.CarouselUILayout = new.CarouselContentFrame.UIListLayout
	new:Draggable()

	lib.Gui = new.Gui
	
	local UIS = game:GetService("UserInputService")
	lib:RegisterKeybind(Enum.KeyCode.RightShift, function()
		new.Gui.Enabled = not new.Gui.Enabled
		UIS.OverrideMouseIconBehavior = new.Gui.Enabled and 1 or 0
	end)

	UIS:GetPropertyChangedSignal("OverrideMouseIconBehavior"):Connect(function()
		if new.Gui.Enabled then
			UIS.OverrideMouseIconBehavior = 1
		end
	end)
	UIS.OverrideMouseIconBehavior = 1
	
	return new
end

function uiBox:Select(idx)
	if self.Selected then
		local tab = self.Tabs[self.Selected]
		tab.CarouselTab.Filler.Visible = false
		tab.ContentFrame.Visible = false
	end
	local tab = self.Tabs[idx]
	
	--workaround for roblox's stupid delayed AbsoluteSize when the frame isn't visible--
	for i,v in pairs(tab.Children) do
		v:Position()
	end

	tab.CarouselTab.Filler.Visible = true
	tab.ContentFrame.Visible = true
	self.Selected = idx
end

function uiBox:Tab(title)
	local new = setmetatable({
		Type = "BoxTab",
		Children = {},
		ParentObj = self
	}, uiBoxTab)

	new.CarouselTab = lib.Create("Frame", {
		Name = title,
		BackgroundTransparency = 1,
		LayoutOrder = #self.Tabs,
		Size = UDim2.new(1,-6,0,50), -- -6 = ScrollBarThickness
		Parent = self.CarouselContentFrame,

		lib.Create("Frame", {
			Name = "Filler",
			BackgroundColor3 = Color3.fromRGB(61, 65, 75),
			BorderSizePixel = 0,
			Position = UDim2.new(0,10,0,7),
			Size = UDim2.new(1,-20,1,-14),
			Visible = false, -- <--
			--ZIndex = 0,

			lib.Create("UICorner", {
				CornerRadius = UDim.new(0,13)
			})
		}),
		lib.Create("Frame", {
			Name = "Separator",
			BackgroundColor3 = Color3.fromRGB(213, 213, 213),
			BorderSizePixel = 0,
			Position = UDim2.new(0,10,1,-2),
			Size = UDim2.new(1,-20,0,2),
		}),
		lib.Create("TextButton", {
			Name = "ClickCapture",
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Text = "",
			ZIndex = 2
		}),
		lib.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Font = "SourceSansSemibold",
			TextSize = 19,
			Text = title,
			TextColor3 = Color3.fromRGB(213, 213, 213),
		})
	})

	new.ContentFrame = lib.Create("ScrollingFrame", {
		Name = title,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,1,0),
		ClipsDescendants = true,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(), --calculated below
		Parent = self.TabsFrame,
		Visible = false
	})

	new.ClickCapture = new.CarouselTab.ClickCapture
	new.ClickCapture.MouseButton1Down:Connect(function()
		self:Select(new.Index)
	end)

	table.insert(self.Tabs, new)
	new.Index = #self.Tabs
	if #self.Tabs == 1 then
		self:Select(1)
	end

	function new:Resize()
		for i,v in pairs(self.Children) do
			v:Position()
		end
		local Y = 10
		for i,v in pairs(self.Children) do
			local posY = v.PrimaryFrame.Position.Y.Offset + v.PrimaryFrame.Size.Y.Offset + 10
			if posY > Y then
				Y = posY
			end
		end
		self.ContentFrame.CanvasSize = UDim2.new(0,0,0,Y)
	end

	return new
end

function uiBoxTab:Group(name, options)
	local new = setmetatable({
		Type = "BoxGroup",
		Children = {},
		Collumn = options.Collumn,
		ParentObj = self
	}, uiTab)

	new.GroupFrame = lib.Create("Frame", {
		Name = "Group - " .. name,
		BackgroundTransparency = 1,
		--Position =
		Size = UDim2.new(0, options.Width or 200, 0, 25 --[[this one is calculated on the go]]),
		ClipsDescendants = true,
		LayoutOrder = #self.Children, --for keeping track of the order
		Parent = self.ContentFrame,

		lib.Create("Frame", {
			Name = "Group",
			BackgroundColor3 = Color3.fromRGB(213, 213, 213),
			BorderSizePixel = 0,
			Position = UDim2.new(0,0,0,10),
			Size = UDim2.new(1,0,1,-10),

			lib.Create("UICorner", {
				CornerRadius = UDim.new(0,13)
			}),
			lib.Create("Frame", {
				Name = "Filler",
				BackgroundColor3 = Color3.fromRGB(26, 28, 32),
				BorderSizePixel = 0,
				Position = UDim2.new(0,1,0,1),
				Size = UDim2.new(1,-2,1,-2),

				lib.Create("UICorner", {
					CornerRadius = UDim.new(0,13)
				})
			}),
			lib.Create("Frame", {
				Name = "Content",
				BackgroundTransparency = 1,
				Position = UDim2.new(0,2,0,20),
				Size = UDim2.new(1,-4,1,-24),

				lib.Create("UIListLayout", {
					SortOrder = "LayoutOrder",
					HorizontalAlignment = "Center"
				})
			})
		}),
		lib.Create("TextLabel", {
			Name = "Title",
			BackgroundColor3 = Color3.fromRGB(26, 28, 32),
			BorderSizePixel = 0,
			Position = UDim2.new(0,20,0,0),
			--Size = UDim2.new(0,x,0,20),
			Font = "SourceSans",
			Text = name,
			TextColor3 = Color3.fromRGB(213, 213, 213),
			TextSize = 20,
		})
	})

	do
		local titleLabel = new.GroupFrame.Title
		titleLabel.Size = UDim2.new(0, game:GetService("TextService"):GetTextSize(titleLabel.Text, titleLabel.TextSize, titleLabel.Font, Vector2.new(999,999)).X + 22, 0, 20)
	end

	new.PrimaryFrame = new.GroupFrame
	new.ContentFrame = new.GroupFrame.Group.Content
	new.ContentUILayout = new.ContentFrame.UIListLayout

	function new:Position() --determine the collumns basing on the first horizontal row
		local collumn = options.Collumn
		local X, Y = 20, 10
		if self.GroupFrame.LayoutOrder > 0 then
			--figure out the X and Y pos
			local found = false
			for i,v in pairs(self.ParentObj.Children) do
				if v == self then
					break
				end
				if v.Collumn == collumn then
					X = v.GroupFrame.Position.X.Offset
					Y = v.GroupFrame.Position.Y.Offset + v.GroupFrame.AbsoluteSize.Y + 10
					found = true
				end
			end

			if not found then --first group in the 2nd collumn
				local prev = self.ParentObj.Children[self.GroupFrame.LayoutOrder].PrimaryFrame
				X = prev.Position.X.Offset + prev.AbsoluteSize.X + 20
			end
		end
		new.GroupFrame.Position = UDim2.new(0,X,0,Y)
	end

	if options.Position then
		new.GroupFrame.Position = options.Position
	else
		new:Position()
	end
	
	table.insert(self.Children, new)
	self:Resize()

	return new
end

return lib
