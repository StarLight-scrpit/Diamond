local Library = (function()
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex
    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new
    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new
    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local UDim2FromOffset = UDim2.fromOffset
    local Vector2New = Vector2.new
    local Vector3New = Vector3.new
    local MathClamp = math.clamp
    local MathFloor = math.floor
    local MathAbs = math.abs
    local MathSin = math.sin
    local MathMin = math.min
    local MathMax = math.max
    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack
    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringLen = string.len
    local InstanceNew = Instance.new
    local RectNew = Rect.new

    local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local Lucide = nil
    pcall(function()
        Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/lucide-roblox.luau"))()
    end)

    local function GetIcon(name, size)
        size = size or 48
        if Lucide then
            local ok, asset = pcall(function()
                return Lucide.GetAsset(name, size)
            end)
            if ok and asset then
                return asset.Url, asset.ImageRectOffset, asset.ImageRectSize
            end
        end
        return nil, nil, nil
    end

    Library = {
        Theme = {},
        Flags = {},
        Tween = {
            Time = 0.3,
            Style = Enum.EasingStyle.Quad,
            Direction = Enum.EasingDirection.Out
        },
        FadeSpeed = 0.2,
        Folders = {
            Directory = "lyapossss",
            Configs = "lyapossss/Configs",
            Assets = "lyapossss/Assets",
        },
        Pages = {},
        Sections = {},
        Groups = {},
        Connections = {},
        Threads = {},
        ThemeMap = {},
        ThemeItems = {},
        OpenFrames = {},
        SetFlags = {},
        UnnamedConnections = 0,
        UnnamedFlags = 0,
        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,
        Font = nil,
        KeyList = nil,
        IsMobile = IsMobile,
        Lucide = Lucide,
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages
    Library.Groups.__index = Library.Groups

    local Themes = {
        ["Preset"] = {
            ["AccentGradient"] = FromRGB(0, 195, 255),
            ["Background 2"] = FromRGB(10, 10, 12),
            ["Background"] = FromRGB(12, 12, 14),
            ["Text"] = FromRGB(235, 235, 235),
            ["Outline"] = FromRGB(25, 25, 28),
            ["Section Top"] = FromRGB(28, 27, 31),
            ["Section Background"] = FromRGB(10, 10, 12),
            ["Section Background 2"] = FromRGB(14, 14, 16),
            ["Accent"] = FromRGB(0, 116, 224),
            ["Element"] = FromRGB(16, 16, 18)
        }
    }

    Library.Theme = TableClone(Themes["Preset"])

    for _, Value in Library.Folders do
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

    local Tween = {}
    Tween.__index = Tween

    function Tween.Create(self, Item, Info, Goal, IsRawItem)
        Item = IsRawItem and Item or Item.Instance
        Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
        local NewTween = {
            Tween = TweenService:Create(Item, Info, Goal),
            Info = Info,
            Goal = Goal,
            Item = Item
        }
        NewTween.Tween:Play()
        setmetatable(NewTween, Tween)
        return NewTween
    end

    function Tween.GetProperty(self, Item)
        Item = Item or self.Item
        if Item:IsA("Frame") then
            return { "BackgroundTransparency" }
        elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
            return { "BackgroundTransparency", "ImageTransparency" }
        elseif Item:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Item:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("UIStroke") then
            return { "Transparency" }
        end
    end

    function Tween.FadeItem(self, Item, Property, Visibility, Speed)
        local Item = Item or self.Item
        local OldTransparency = Item[Property]
        Item[Property] = Visibility and 1 or OldTransparency
        local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
            [Property] = Visibility and OldTransparency or 1
        }, true)
        Library:Connect(NewTween.Tween.Completed, function()
            if not Visibility then
                task.wait()
                Item[Property] = OldTransparency
            end
        end)
        return NewTween
    end

    function Tween.Get(self)
        if not self.Tween then return end
        return self.Tween, self.Info, self.Goal
    end

    function Tween.Pause(self)
        if not self.Tween then return end
        self.Tween:Pause()
    end

    function Tween.Play(self)
        if not self.Tween then return end
        self.Tween:Play()
    end

    function Tween.Clean(self)
        if not self.Tween then return end
        self:Pause()
        self = nil
    end

    local Instances = {}
    Instances.__index = Instances

    function Instances.Create(self, Class, Properties)
        local NewItem = {
            Instance = InstanceNew(Class),
            Properties = Properties,
            Class = Class
        }
        setmetatable(NewItem, Instances)
        for Property, Value in NewItem.Properties do
            NewItem.Instance[Property] = Value
        end
        return NewItem
    end

    function Instances.FadeItem(self, Visibility, Speed)
        local Item = self.Instance
        if Visibility == true then
            Item.Visible = true
        end
        local Descendants = Item:GetDescendants()
        TableInsert(Descendants, Item)
        local NewTween
        for _, Value in Descendants do
            local TransparencyProperty = Tween:GetProperty(Value)
            if not TransparencyProperty then continue end
            if type(TransparencyProperty) == "table" then
                for _, Property in TransparencyProperty do
                    NewTween = Tween:FadeItem(Value, Property, not Visibility, Speed)
                end
            else
                NewTween = Tween:FadeItem(Value, TransparencyProperty, not Visibility, Speed)
            end
        end
    end

    function Instances.AddToTheme(self, Properties)
        if not self.Instance then return end
        Library:AddToTheme(self, Properties)
    end

    function Instances.ChangeItemTheme(self, Properties)
        if not self.Instance then return end
        Library:ChangeItemTheme(self, Properties)
    end

    function Instances.Connect(self, Event, Callback, Name)
        if not self.Instance then return end
        if not self.Instance[Event] then return end
        if IsMobile then
            if Event == "MouseButton1Down" or Event == "MouseButton1Click" then
                Event = "TouchTap"
            elseif Event == "MouseButton2Down" or Event == "MouseButton2Click" then
                Event = "TouchLongPress"
            end
        end
        return Library:Connect(self.Instance[Event], Callback, Name)
    end

    function Instances.Tween(self, Info, Goal)
        if not self.Instance then return end
        return Tween:Create(self, Info, Goal)
    end

    function Instances.Disconnect(self, Name)
        if not self.Instance then return end
        return Library:Disconnect(Name)
    end

    function Instances.Clean(self)
        if not self.Instance then return end
        self.Instance:Destroy()
        self = nil
    end

    function Instances.MakeDraggable(self)
        if not self.Instance then return end
        local Gui = self.Instance
        local Dragging = false
        local DragStart
        local StartPosition
        local function Set(Input)
            local DragDelta = Input.Position - DragStart
            local NewX = StartPosition.X.Offset + DragDelta.X
            local NewY = StartPosition.Y.Offset + DragDelta.Y
            local ScreenSize = Gui.Parent.AbsoluteSize
            local GuiSize = Gui.AbsoluteSize
            NewX = MathClamp(NewX, 0, ScreenSize.X - GuiSize.X)
            NewY = MathClamp(NewY, 0, ScreenSize.Y - GuiSize.Y)
            self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(0, NewX, 0, NewY) })
        end
        local InputChanged
        self:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position
                StartPosition = Gui.Position
                if InputChanged then return end
                InputChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                        InputChanged:Disconnect()
                        InputChanged = nil
                    end
                end)
            end
        end)
        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if Dragging then
                    Set(Input)
                end
            end
        end)
        return Dragging
    end

    function Instances.MakeResizeable(self, Minimum, Maximum, Window)
        if not self.Instance then return end
        local Gui = self.Instance
        local Resizing = false
        local CurrentSide = nil
        local StartMouse = nil
        local StartPosition = nil
        local StartSize = nil
        local EdgeThickness = 2
        local function MakeEdge(Name, Position, Size)
            local Button = Instances:Create("TextButton", {
                Name = "\0",
                Size = Size,
                Position = Position,
                BackgroundColor3 = FromRGB(166, 147, 243),
                BackgroundTransparency = 1,
                Text = "",
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Parent = Gui,
                ZIndex = 99999,
            })
            Button:AddToTheme({ BackgroundColor3 = "Accent" })
            return Button
        end
        local Edges = {
            { Button = MakeEdge("Left", UDim2New(0, 0, 0, 0), UDim2New(0, EdgeThickness, 1, 0)), Side = "L" },
            { Button = MakeEdge("Right", UDim2New(1, -EdgeThickness, 0, 0), UDim2New(0, EdgeThickness, 1, 0)), Side = "R" },
            { Button = MakeEdge("Top", UDim2New(0, 0, 0, 0), UDim2New(1, 0, 0, EdgeThickness)), Side = "T" },
            { Button = MakeEdge("Bottom", UDim2New(0, 0, 1, -EdgeThickness), UDim2New(1, 0, 0, EdgeThickness)), Side = "B" },
        }
        local function BeginResizing(Side)
            Resizing = true
            CurrentSide = Side
            StartMouse = UserInputService:GetMouseLocation()
            StartPosition = Vector2New(Gui.Position.X.Offset, Gui.Position.Y.Offset)
            StartSize = Vector2New(Gui.Size.X.Offset, Gui.Size.Y.Offset)
            for _, Value in Edges do
                Value.Button:Tween(nil, { BackgroundTransparency = (Value.Side == Side) and 0 or 1 })
            end
        end
        local function EndResizing()
            Resizing = false
            CurrentSide = nil
            for _, Value in Edges do
                Value.Button.Instance.BackgroundTransparency = 1
            end
        end
        for _, Value in Edges do
            Value.Button:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    BeginResizing(Value.Side)
                end
            end)
        end
        Library:Connect(UserInputService.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if Resizing then
                    EndResizing()
                end
            end
        end)
        Library:Connect(RunService.RenderStepped, function()
            if not Resizing or not CurrentSide then return end
            local MouseLocation = UserInputService:GetMouseLocation()
            local dx = MouseLocation.X - StartMouse.X
            local dy = MouseLocation.Y - StartMouse.Y
            local x, y = StartPosition.X, StartPosition.Y
            local w, h = StartSize.X, StartSize.Y
            if CurrentSide == "L" then
                x = StartPosition.X + dx
                w = StartSize.X - dx
            elseif CurrentSide == "R" then
                w = StartSize.X + dx
            elseif CurrentSide == "T" then
                y = StartPosition.Y + dy
                h = StartSize.Y - dy
            elseif CurrentSide == "B" then
                h = StartSize.Y + dy
            end
            if w < Minimum.X then
                if CurrentSide == "L" then x = x - (Minimum.X - w) end
                w = Minimum.X
            end
            if h < Minimum.Y then
                if CurrentSide == "T" then y = y - (Minimum.Y - h) end
                h = Minimum.Y
            end
            self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2FromOffset(x, y) })
            self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2FromOffset(w, h) })
        end)
    end

    function Instances.OnHover(self, Function)
        if not self.Instance then return end
        return Library:Connect(self.Instance.MouseEnter, Function)
    end

    function Instances.OnHoverLeave(self, Function)
        if not self.Instance then return end
        return Library:Connect(self.Instance.MouseLeave, Function)
    end

    local CustomFont = {}
    function CustomFont:New(Name, Weight, Style, Data)
        if not isfile(Data.Id) then
            writefile(Data.Id, game:HttpGet(Data.Url))
        end
        local Data = {
            name = Name,
            faces = {
                {
                    name = Name,
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Data.Id)
                }
            }
        }
        writefile(StringFormat("%s/%s.font", Library.Folders.Assets, Name), HttpService:JSONEncode(Data))
        return getcustomasset(StringFormat("%s/%s.font", Library.Folders.Assets, Name))
    end

    local SemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    local Regular = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    local Light = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal)

    Library.Fonts = {
        ["SemiBold"] = SemiBold,
        ["Regular"] = Regular,
        ["Light"] = Light
    }
    Library.Font = SemiBold

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "\0",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 0, 1, 0),
        BorderColor3 = FromRGB(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })

    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        Name = "\0",
        Padding = UDimNew(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Instances:Create("UIPadding", {
        Parent = Library.NotifHolder.Instance,
        Name = "\0",
        PaddingTop = UDimNew(0, 12),
        PaddingBottom = UDimNew(0, 12),
        PaddingRight = UDimNew(0, 12),
        PaddingLeft = UDimNew(0, 12)
    })

    function Library.Unload(self)
        for _, Value in self.Connections do
            Value.Connection:Disconnect()
        end
        for _, Value in self.Threads do
            coroutine.close(Value)
        end
        if self.Holder then
            self.Holder:Clean()
        end
        Library = nil
        getgenv().Library = nil
    end

    function Library.Round(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    function Library.Thread(self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()
        TableInsert(self.Threads, NewThread)
        return NewThread
    end

    function Library.SafeCall(self, Function, ...)
        local Arguements = { ... }
        local Success, Result = pcall(Function, TableUnpack(Arguements))
        if not Success then
            warn(Result)
            return false
        end
        return Success
    end

    function Library.Connect(self, Event, Callback, Name)
        Name = Name or StringFormat("connection_number_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))
        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }
        Library:Thread(function()
            NewConnection.Connection = Event:Connect(Callback)
        end)
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    function Library.Disconnect(self, Name)
        for _, Connection in self.Connections do
            if Connection.Name == Name then
                Connection.Connection:Disconnect()
                break
            end
        end
    end

    function Library.NextFlag(self)
        local FlagNumber = self.UnnamedFlags + 1
        return StringFormat("flag_number_%s_%s", FlagNumber, HttpService:GenerateGUID(false))
    end

    function Library.AddToTheme(self, Item, Properties)
        Item = Item.Instance or Item
        local ThemeData = {
            Item = Item,
            Properties = Properties,
        }
        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value]
            else
                Item[Property] = Value()
            end
        end
        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    function Library.ToRich(self, Text, Color)
        return StringFormat('<font color="rgb(%d, %d, %d)">%s</font>', MathFloor(Color.R * 255), MathFloor(Color.G * 255), MathFloor(Color.B * 255), Text)
    end

    function Library.GetConfig(self)
        local Config = {}
        Library:SafeCall(function()
            for Index, Value in Library.Flags do
                if type(Value) == "table" and Value.Key then
                    Config[Index] = { Key = tostring(Value.Key), Mode = Value.Mode }
                elseif type(Value) == "table" and Value.Color then
                    Config[Index] = { Color = "#" .. Value.HexValue, Alpha = Value.Alpha }
                else
                    Config[Index] = Value
                end
            end
        end)
        return HttpService:JSONEncode(Config)
    end

    function Library.LoadConfig(self, Config)
        local Decoded = HttpService:JSONDecode(Config)
        local Success, Result = Library:SafeCall(function()
            for Index, Value in Decoded do
                local SetFunction = Library.SetFlags[Index]
                if not SetFunction then continue end
                if type(Value) == "table" and Value.Key then
                    SetFunction(Value)
                elseif type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
        end)
        return Success, Result
    end

    function Library.DeleteConfig(self, Config)
        if isfile(Library.Folders.Configs .. "/" .. Config) then
            delfile(Library.Folders.Configs .. "/" .. Config)
        end
    end

    function Library.RefreshConfigsList(self, Element)
        local CurrentList = {}
        local List = {}
        local ConfigFolderName = StringGSub(Library.Folders.Configs, Library.Folders.Directory .. "/", "")
        for Index, Value in listfiles(Library.Folders.Configs) do
            local FileName = StringGSub(Value, Library.Folders.Directory .. "\\" .. ConfigFolderName .. "\\", "")
            List[Index] = FileName
        end
        local IsNew = #List ~= CurrentList
        if not IsNew then
            for Index = 1, #List do
                if List[Index] ~= CurrentList[Index] then
                    IsNew = true
                    break
                end
            end
        else
            CurrentList = List
            Element:Refresh(CurrentList)
        end
    end

    function Library.ChangeItemTheme(self, Item, Properties)
        Item = Item.Instance or Item
        if not self.ThemeMap[Item] then return end
        self.ThemeMap[Item].Properties = Properties
        self.ThemeMap[Item] = self.ThemeMap[Item]
    end

    function Library.ChangeTheme(self, Theme, Color)
        self.Theme[Theme] = Color
        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    function Library.IsMouseOverFrame(self, Frame)
        Frame = Frame.Instance or Frame
        local MousePosition = Vector2New(Mouse.X, Mouse.Y)
        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X
            and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    function Library.Lerp(self, Start, Finish, Time)
        return Start + (Finish - Start) * Time
    end

    function Library.CompareVectors(self, PointA, PointB)
        return (PointA.X < PointB.X) or (PointA.Y < PointB.Y)
    end

    function Library.IsClipped(self, Object, Column)
        local Parent = Column
        local BoundryTop = Parent.AbsolutePosition
        local BoundryBottom = BoundryTop + Parent.AbsoluteSize
        local Top = Object.AbsolutePosition
        local Bottom = Top + Object.AbsoluteSize
        return Library:CompareVectors(Top, BoundryTop) or Library:CompareVectors(BoundryBottom, Bottom)
    end

    function Library.GetCalculatedRayPosition(self, Position, Normal, Origin, Direction)
        local N = Normal
        local D = Direction
        local V = Origin - Position
        local Number = (N.x * V.x) + (N.y * V.y) + (N.z * V.z)
        local Den = (N.x * D.x) + (N.y * D.y) + (N.z * D.z)
        local A = -Number / Den
        return Origin + (A * Direction)
    end

    function Library.UpdateText(self)
        for _, Value in self.UnusedHolder.Instance:GetDescendants() do
            if Value:IsA("TextLabel") or Value:IsA("TextButton") or Value:IsA("TextBox") then
                Value.FontFace = Library.Font
            end
        end
        for _, Value in self.Holder.Instance:GetDescendants() do
            if Value:IsA("TextLabel") or Value:IsA("TextButton") or Value:IsA("TextBox") then
                Value.FontFace = Library.Font
            end
        end
    end

    function Library.MakeBlurred(self, Item, Window)
        Item = Item.Instance
        local BlurItem = Item
        local Part = Instances:Create("Part", {
            Material = Enum.Material.Glass,
            Transparency = 1,
            Reflectance = 1,
            CastShadow = false,
            Anchored = true,
            CanCollide = false,
            CanQuery = false,
            CollisionGroup = " ",
            Size = Vector3New(1, 1, 1) * 0.01,
            Color = FromRGB(0, 0, 0),
            Parent = Camera
        })
        local BlockMesh = Instances:Create("BlockMesh", { Parent = Part.Instance })
        local DepthOfField = Instances:Create("DepthOfFieldEffect", {
            Parent = Lighting,
            Enabled = true,
            FarIntensity = 0,
            FocusDistance = 0,
            InFocusRadius = 1000,
            NearIntensity = 1,
            Name = ""
        })
        Library:Connect(RunService.RenderStepped, function()
            if Window.IsOpen then
                if Item.Visible then
                    DepthOfField:Tween(nil, { NearIntensity = 1 })
                    Part:Tween(nil, { Transparency = 0.97 })
                    Part:Tween(nil, { Size = Vector3New(1, 1, 1) * 0.01 })
                    local Corner0 = BlurItem.AbsolutePosition
                    local Corner1 = Corner0 + BlurItem.AbsoluteSize
                    local Ray0 = Camera:ScreenPointToRay(Corner0.X, Corner0.Y, 1)
                    local Ray1 = Camera:ScreenPointToRay(Corner1.X, Corner1.Y, 1)
                    local Origin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ)
                    local Normal = Camera.CFrame.LookVector
                    local Position0 = Library:GetCalculatedRayPosition(Origin, Normal, Ray0.Origin, Ray0.Direction)
                    local Position1 = Library:GetCalculatedRayPosition(Origin, Normal, Ray1.Origin, Ray1.Direction)
                    Position0 = Camera.CFrame:PointToObjectSpace(Position0)
                    Position1 = Camera.CFrame:PointToObjectSpace(Position1)
                    local Size = Position1 - Position0
                    local Center = (Position0 + Position1) / 2
                    BlockMesh.Instance.Offset = Center
                    BlockMesh.Instance.Scale = Size / 0.0101
                    Part.Instance.CFrame = Camera.CFrame
                else
                    DepthOfField:Tween(nil, { NearIntensity = 0 })
                    BlockMesh.Instance.Offset = Vector3New(0, 0, 0)
                    BlockMesh.Instance.Scale = Vector3New(0, 0, 0)
                end
            else
                DepthOfField:Tween(nil, { NearIntensity = 0 })
                BlockMesh.Instance.Offset = Vector3New(0, 0, 0)
                BlockMesh.Instance.Scale = Vector3New(0, 0, 0)
            end
        end)
    end

    function Library.EscapePattern(self, String)
        local ShouldEscape = false
        if string.match(String, "[%(%)%.%%%+%-%*%?%[%]%^%$]") then
            ShouldEscape = true
        end
        if ShouldEscape then
            return StringGSub(String, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
        end
        return String
    end

    function Library.CreateColorpicker(self, Data)
        local Colorpicker = {
            Flag = Data.Flag,
            Hue = 0,
            Saturation = 0,
            Value = 0,
            Alpha = 0,
            Color = FromRGB(0, 0, 0),
            HexValue = "#000000",
            SavedColors = {},
            IsOpen = false
        }

        local Items = {}
        Items["ColorpickerButton"] = Instances:Create("TextButton", {
            Parent = Data.Parent.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(0, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2New(0, 100, 0, 20),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })

        if Data.Parent2 and not Data.Parent2.Instance:FindFirstChild("palette_icon") then
            local iconUrl, iconOffset, iconSize = GetIcon("palette", 48)
            Items["PaletteIcon"] = Instances:Create("ImageLabel", {
                Parent = Data.Parent2.Instance,
                ImageColor3 = FromRGB(141, 141, 150),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 16, 0, 16),
                AnchorPoint = Vector2New(0.5, 1),
                Image = iconUrl or "",
                Name = "palette_icon",
                BackgroundTransparency = 1,
                Position = UDim2New(1, -16, 1, -6),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            if iconOffset then
                Items["PaletteIcon"].Instance.ImageRectOffset = iconOffset
                Items["PaletteIcon"].Instance.ImageRectSize = iconSize
            end
            Items["PaletteIcon"]:OnHover(function()
                Items["PaletteIcon"]:Tween(nil, { ImageColor3 = Library.Theme.Accent })
            end)
            Items["PaletteIcon"]:OnHoverLeave(function()
                Items["PaletteIcon"]:Tween(nil, { ImageColor3 = FromRGB(141, 141, 150) })
            end)
        end

        Items["Color"] = Instances:Create("Frame", {
            Parent = Items["ColorpickerButton"].Instance,
            Name = "\0",
            Size = UDim2New(0, 15, 0, 15),
            Position = UDim2New(0, 0, 0, 2),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(124, 163, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["Color"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(1, 0)
        })
        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["ColorpickerButton"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "#7842ff",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 25, 0, 2),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Text"]:AddToTheme({ TextColor3 = "Text" })

        Items["ColorpickerWindow"] = Instances:Create("TextButton", {
            Parent = Library.UnusedHolder.Instance,
            AutoButtonColor = false,
            Text = "",
            Name = "\0",
            Visible = false,
            Position = UDim2New(0.01075268816202879, 0, 0.0336427167057991, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 235, 0, 270),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 25)
        })
        Items["ColorpickerWindow"]:AddToTheme({ BackgroundColor3 = "Background" })
        Instances:Create("UICorner", {
            Parent = Items["ColorpickerWindow"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 6)
        })

        Items["Palette"] = Instances:Create("TextButton", {
            Parent = Items["ColorpickerWindow"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            Position = UDim2New(0, 15, 0, 10),
            Size = UDim2New(1, -31, 1, -159),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = FromRGB(124, 163, 255)
        })
        Items["Saturation"] = Instances:Create("Frame", {
            Parent = Items["Palette"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(1, 1, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UIGradient", {
            Parent = Items["Saturation"].Instance,
            Name = "\0",
            Transparency = NumSequence { NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0) }
        })
        Instances:Create("UICorner", {
            Parent = Items["Saturation"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })
        Items["Value"] = Instances:Create("Frame", {
            Parent = Items["Palette"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(1, 1, 1, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(0, 0, 0)
        })
        Instances:Create("UIGradient", {
            Parent = Items["Value"].Instance,
            Name = "\0",
            Rotation = 90,
            Transparency = NumSequence { NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0) }
        })
        Instances:Create("UICorner", {
            Parent = Items["Value"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })
        Instances:Create("UICorner", {
            Parent = Items["Palette"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })
        Items["PaletteDragger"] = Instances:Create("Frame", {
            Parent = Items["Palette"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = UDim2New(0, 15, 0, 15),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 10, 0, 10),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UIStroke", {
            Parent = Items["PaletteDragger"].Instance,
            Name = "\0",
            Color = FromRGB(255, 255, 255),
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        Instances:Create("UICorner", {
            Parent = Items["PaletteDragger"].Instance,
            Name = "\0"
        })

        Items["Hue"] = Instances:Create("TextButton", {
            Parent = Items["ColorpickerWindow"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(0, 1),
            Position = UDim2New(0, 15, 1, -131),
            Size = UDim2New(1, -31, 0, 6),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["Hue"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(1, 0)
        })
        Items["HueInline"] = Instances:Create("TextButton", {
            Parent = Items["Hue"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["HueInline"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(1, 0)
        })
        Instances:Create("UIGradient", {
            Parent = Items["HueInline"].Instance,
            Name = "\0",
            Color = RGBSequence {
                RGBSequenceKeypoint(0, FromRGB(255, 0, 0)),
                RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)),
                RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)),
                RGBSequenceKeypoint(0.5, FromRGB(0, 255, 255)),
                RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)),
                RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)),
                RGBSequenceKeypoint(1, FromRGB(255, 0, 0))
            }
        })
        Items["HueDragger"] = Instances:Create("Frame", {
            Parent = Items["HueInline"].Instance,
            Name = "\0",
            AnchorPoint = Vector2New(0, 0.5),
            Position = UDim2New(0, 15, 0.5, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 12, 0, 12),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["HueDragger"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(1, 0)
        })

        Items["Alpha"] = Instances:Create("TextButton", {
            Parent = Items["ColorpickerWindow"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(0, 1),
            Position = UDim2New(0, 15, 1, -107),
            Size = UDim2New(1, -31, 0, 6),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = FromRGB(124, 163, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["Alpha"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(1, 0)
        })
        Instances:Create("UIGradient", {
            Parent = Items["Alpha"].Instance,
            Name = "\0",
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(0, 0, 0)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255)) }
        })
        Items["AlphaDragger"] = Instances:Create("Frame", {
            Parent = Items["Alpha"].Instance,
            Name = "\0",
            AnchorPoint = Vector2New(0, 0.5),
            Position = UDim2New(0, 15, 0.5, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 12, 0, 12),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["AlphaDragger"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(1, 0)
        })

        Items["SavedColors"] = Instances:Create("ScrollingFrame", {
            Parent = Items["ColorpickerWindow"].Instance,
            Name = "\0",
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            AnchorPoint = Vector2New(0, 1),
            BorderSizePixel = 0,
            CanvasSize = UDim2New(0, 0, 0, 0),
            ScrollBarImageColor3 = FromRGB(124, 163, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            ScrollBarThickness = 0,
            Size = UDim2New(1, -20, 0, 69),
            Selectable = false,
            Position = UDim2New(0, 10, 1, -30),
            BackgroundTransparency = 1,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UIGridLayout", {
            Parent = Items["SavedColors"].Instance,
            Name = "\0",
            SortOrder = Enum.SortOrder.LayoutOrder,
            CellPadding = UDim2New(0, 10, 0, 10),
            CellSize = UDim2New(0, 25, 0, 25)
        })
        Instances:Create("UIPadding", {
            Parent = Items["SavedColors"].Instance,
            Name = "\0",
            PaddingLeft = UDimNew(0, 5),
            PaddingTop = UDimNew(0, 5),
            PaddingRight = UDimNew(0, -125),
            PaddingBottom = UDimNew(0, 5)
        })

        Items["HEXInput"] = Instances:Create("TextBox", {
            Parent = Items["ColorpickerWindow"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            ClearTextOnFocus = false,
            Text = "#7ca3ff",
            AnchorPoint = Vector2New(1, 1),
            Size = UDim2New(0, 140, 0, 20),
            TextTransparency = 0.5,
            PlaceholderColor3 = FromRGB(185, 185, 185),
            Position = UDim2New(1, -8, 1, -8),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = FromRGB(30, 29, 31)
        })
        Items["HEXInput"]:AddToTheme({ BackgroundColor3 = "Outline" })
        Instances:Create("UIPadding", {
            Parent = Items["HEXInput"].Instance,
            Name = "\0",
            PaddingLeft = UDimNew(0, 5),
        })
        Items["HexLabel"] = Instances:Create("TextLabel", {
            Parent = Items["ColorpickerWindow"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "Custom:",
            TextTransparency = 0.5,
            AnchorPoint = Vector2New(0, 1),
            Size = UDim2New(0, 40, 0, 20),
            Position = UDim2New(0, 10, 1, -8),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundTransparency = 1,
            BackgroundColor3 = FromRGB(30, 29, 31)
        })
        Items["HexLabel"]:AddToTheme({ TextColor3 = "Text" })
        Instances:Create("UICorner", {
            Parent = Items["HEXInput"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        function Colorpicker:Get()
            return Colorpicker.Color, Colorpicker.Alpha
        end

        function Colorpicker:Update(IsFromAlpha)
            local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
            Colorpicker.Color = FromHSV(Hue, Saturation, Value)
            Colorpicker.HexValue = Colorpicker.Color:ToHex()
            Library.Flags[Colorpicker.Flag] = {
                Alpha = Colorpicker.Alpha,
                Color = Colorpicker.Color,
                HexValue = Colorpicker.HexValue,
                Transparency = 1 - Colorpicker.Alpha
            }
            Items["Color"]:Tween(nil, { BackgroundColor3 = Colorpicker.Color })
            Items["Palette"]:Tween(nil, { BackgroundColor3 = FromHSV(Hue, 1, 1) })
            Items["Text"].Instance.Text = StringFormat("#%s", Colorpicker.HexValue):upper()
            Items["HEXInput"].Instance.Text = "#" .. Colorpicker.HexValue
            if not IsFromAlpha then
                Items["Alpha"]:Tween(nil, { BackgroundColor3 = Colorpicker.Color })
            end
            if Data.Callback then
                Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)
            end
        end

        local SlidingPalette = false
        local PaletteChanged
        function Colorpicker:SlidePalette(Input)
            if not Input or not SlidingPalette then return end
            local ValueX = MathClamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
            local ValueY = MathClamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)
            Colorpicker.Saturation = ValueX
            Colorpicker.Value = ValueY
            local SlideX = MathClamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.955)
            local SlideY = MathClamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.955)
            Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(SlideX, 0, SlideY, 0) })
            Colorpicker:Update()
        end

        local SlidingHue = false
        local HueChanged
        function Colorpicker:SlideHue(Input)
            if not Input or not SlidingHue then return end
            local ValueX = MathClamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 1)
            Colorpicker.Hue = ValueX
            local SlideX = MathClamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 0.955)
            Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(SlideX, 0, 0.5, 0) })
            Colorpicker:Update()
        end

        local SlidingAlpha = false
        local AlphaChanged
        function Colorpicker:SlideAlpha(Input)
            if not Input or not SlidingAlpha then return end
            local ValueX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 1)
            Colorpicker.Alpha = ValueX
            local SlideX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 0.955)
            Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(SlideX, 0, 0.5, 0) })
            Colorpicker:Update(true)
        end

        local Debounce = false
        local RenderStepped
        function Colorpicker:SetOpen(Bool)
            if Debounce then return end
            Colorpicker.IsOpen = Bool
            Debounce = true
            if Colorpicker.IsOpen then
                Items["ColorpickerWindow"].Instance.Visible = true
                Items["ColorpickerWindow"].Instance.Parent = Library.Holder.Instance
                RenderStepped = RunService.RenderStepped:Connect(function()
                    Items["ColorpickerWindow"].Instance.Position = UDim2New(
                        0,
                        Items["ColorpickerButton"].Instance.AbsolutePosition.X,
                        0,
                        Items["ColorpickerButton"].Instance.AbsolutePosition.Y + Items["ColorpickerButton"].Instance.AbsoluteSize.Y + 5
                    )
                end)
                if Data.Section.IsSettings ~= true then
                    for _, Value in Library.OpenFrames do
                        if Value ~= Colorpicker then
                            Value:SetOpen(false)
                        end
                    end
                end
                Library.OpenFrames[Colorpicker] = Colorpicker
            else
                if not Data.Section.IsSettings then
                    if Library.OpenFrames[Colorpicker] then
                        Library.OpenFrames[Colorpicker] = nil
                    end
                end
                if RenderStepped then
                    RenderStepped:Disconnect()
                    RenderStepped = nil
                end
            end
            local Descendants = Items["ColorpickerWindow"].Instance:GetDescendants()
            TableInsert(Descendants, Items["ColorpickerWindow"].Instance)
            local NewTween
            for _, Value in Descendants do
                local TransparencyProperty = Tween:GetProperty(Value)
                if not TransparencyProperty then continue end
                if not Value.ClassName:find("UI") then
                    Value.ZIndex = (Colorpicker.IsOpen and Data.Section.IsSettings and 9) or (Colorpicker.IsOpen and not Data.Section.IsSettings and 3) or 1
                end
                if type(TransparencyProperty) == "table" then
                    for _, Property in TransparencyProperty do
                        NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                end
            end
            NewTween.Tween.Completed:Connect(function()
                Debounce = false
                Items["ColorpickerWindow"].Instance.Visible = Colorpicker.IsOpen
                task.wait(0.2)
                Items["ColorpickerWindow"].Instance.Parent = not Colorpicker.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
            end)
        end

        function Colorpicker:Set(Color, Alpha)
            if type(Color) == "table" then
                Color = FromRGB(Color[1], Color[2], Color[3])
                Alpha = Color[4]
            elseif type(Color) == "string" then
                Color = FromHex(Color)
            end
            Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
            Colorpicker.Alpha = Alpha or 0
            local PaletteValueX = MathClamp(1 - Colorpicker.Saturation, 0, 0.955)
            local PaletteValueY = MathClamp(1 - Colorpicker.Value, 0, 0.955)
            local AlphaPositionX = MathClamp(Colorpicker.Alpha, 0, 0.955)
            local HuePositionX = MathClamp(Colorpicker.Hue, 0, 0.955)
            Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(PaletteValueX, 0, PaletteValueY, 0) })
            Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(HuePositionX, 0, 0.5, 0) })
            Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(AlphaPositionX, 0, 0.5, 0) })
            Colorpicker:Update()
        end

        Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
            Colorpicker:SetOpen(not Colorpicker.IsOpen)
        end)

        Items["Palette"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                SlidingPalette = true
                Colorpicker:SlidePalette(Input)
                if PaletteChanged then return end
                PaletteChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        SlidingPalette = false
                        PaletteChanged:Disconnect()
                        PaletteChanged = nil
                    end
                end)
            end
        end)

        Items["HueInline"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                SlidingHue = true
                Colorpicker:SlideHue(Input)
                if HueChanged then return end
                HueChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        SlidingHue = false
                        HueChanged:Disconnect()
                        HueChanged = nil
                    end
                end)
            end
        end)

        Items["Alpha"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                SlidingAlpha = true
                Colorpicker:SlideAlpha(Input)
                if AlphaChanged then return end
                AlphaChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        SlidingAlpha = false
                        AlphaChanged:Disconnect()
                        AlphaChanged = nil
                    end
                end)
            end
        end)

        function AddColor(Color)
            local SaveIndex = #Colorpicker.SavedColors + 1
            local SavedColor = Instances:Create("TextButton", {
                Parent = Items["SavedColors"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Size = UDim2New(0, 200, 0, 50),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundTransparency = 1,
                ZIndex = 4,
                BackgroundColor3 = Color
            })
            Instances:Create("UICorner", {
                Parent = SavedColor.Instance,
                Name = "\0",
                CornerRadius = UDimNew(0, 6),
            })
            local UIStroke = Instances:Create("UIStroke", {
                Parent = SavedColor.Instance,
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = FromRGB(255, 255, 255),
                Thickness = 1.5,
                Transparency = 1
            })
            SavedColor:OnHover(function()
                UIStroke:Tween(nil, { Transparency = 0 })
            end)
            SavedColor:OnHoverLeave(function()
                UIStroke:Tween(nil, { Transparency = 1 })
            end)
            Colorpicker.SavedColors[SaveIndex] = {
                Color = Color,
                Alpha = Colorpicker.Alpha,
            }
            SavedColor:Connect("MouseButton1Down", function()
                local NewColorData = Colorpicker.SavedColors[SaveIndex]
                Colorpicker:Set(NewColorData.Color, NewColorData.Alpha)
            end)
            SavedColor:Tween(nil, { BackgroundTransparency = 0 })
        end

        local Colors = {
            ["Orange"] = FromRGB(245, 114, 66),
            ["Pink"] = FromRGB(245, 66, 191),
            ["Purple"] = FromRGB(124, 54, 245),
            ["Pink 2"] = FromRGB(202, 110, 255),
            ["Pink 3"] = FromRGB(250, 142, 239),
            ["Yellow"] = FromRGB(214, 206, 92),
            ["Orange 2"] = FromRGB(255, 93, 48),
            ["Orange 3"] = FromRGB(255, 169, 56),
            ["Green"] = FromRGB(0, 171, 0),
            ["Blue"] = FromRGB(0, 116, 224),
            ["Maroon"] = FromRGB(120, 0, 76),
            ["Whiteish Pink"] = FromRGB(255, 194, 245),
            ["White"] = FromRGB(255, 255, 255),
            ["Red"] = FromRGB(255, 0, 0),
            ["Sky Blue"] = FromRGB(171, 209, 255),
        }

        for _, Color in Colors do
            AddColor(Color)
        end

        Items["HEXInput"]:Connect("FocusLost", function()
            Colorpicker:Set(tostring(Items["HEXInput"].Instance.Text), Colorpicker.Alpha)
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if SlidingPalette then Colorpicker:SlidePalette(Input) end
                if SlidingHue then Colorpicker:SlideHue(Input) end
                if SlidingAlpha then Colorpicker:SlideAlpha(Input) end
            end
        end)

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if not Colorpicker.IsOpen then return end
                if Library:IsMouseOverFrame(Items["ColorpickerWindow"]) or (Items["PaletteIcon"] and Library:IsMouseOverFrame(Items["PaletteIcon"]) and not Data.Section.IsSettings) then
                    return
                end
                Colorpicker:SetOpen(false)
            end
        end)

        if Data.Default then
            Colorpicker:Set(Data.Default, Data.Alpha)
        end

        Library.SetFlags[Colorpicker.Flag] = function(Value, Alpha)
            Colorpicker:Set(Value, Alpha)
        end

        return Colorpicker, Items
    end

    function Library.KeybindList(self, Title)
        local KeybindList = {}
        Library.KeyList = KeybindList

        local Items = {}
        Items["KeybindsList"] = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(0, 0.5),
            BackgroundTransparency = 0.3,
            Position = UDim2New(0, 20, 0.5, 20),
            Size = UDim2New(0, 100, 0, 30),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })
        Items["KeybindsList"]:AddToTheme({ BackgroundColor3 = "Section Background" })
        Items["KeybindsList"]:MakeDraggable()

        Instances:Create("UICorner", {
            Parent = Items["KeybindsList"].Instance,
            Name = "\0"
        })

        Items["Top"] = Instances:Create("Frame", {
            Parent = Items["KeybindsList"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(1, -12, 0, 40),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(31, 31, 36)
        })
        Items["Top"]:AddToTheme({ BackgroundColor3 = "Section Background 2" })

        local iconUrl, iconOffset, iconSize = GetIcon("keyboard", 48)
        Items["Icon"] = Instances:Create("ImageLabel", {
            Parent = Items["Top"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(255, 255, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 21, 0, 20),
            AnchorPoint = Vector2New(0, 0.5),
            Image = iconUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(0, 15, 0.5, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if iconOffset then
            Items["Icon"].Instance.ImageRectOffset = iconOffset
            Items["Icon"].Instance.ImageRectSize = iconSize
        end
        Instances:Create("UIGradient", {
            Parent = Items["Icon"].Instance,
            Name = "\0",
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(131, 131, 131)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255)) }
        }):AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["Top"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(248, 248, 248),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = Title,
            AutomaticSize = Enum.AutomaticSize.X,
            AnchorPoint = Vector2New(0, 0.5),
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 45, 0.5, -1),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 15,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Title"]:AddToTheme({ TextColor3 = "Text" })
        Instances:Create("UICorner", {
            Parent = Items["Top"].Instance,
            Name = "\0"
        })

        Items["Content"] = Instances:Create("Frame", {
            Parent = Items["KeybindsList"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 0, 0, 40),
            Size = UDim2New(1, 0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UIListLayout", {
            Parent = Items["Content"].Instance,
            Name = "\0",
            Padding = UDimNew(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Instances:Create("UIPadding", {
            Parent = Items["Content"].Instance,
            Name = "\0",
            PaddingTop = UDimNew(0, 8),
            PaddingBottom = UDimNew(0, 8),
            PaddingRight = UDimNew(0, 8),
            PaddingLeft = UDimNew(0, 8)
        })

        function KeybindList:SetVisibility(Bool)
            Items["KeybindsList"].Instance.Visible = Bool
        end

        function KeybindList:Add(Name, Key)
            local NewKey = Instances:Create("TextButton", {
                Parent = Items["Content"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 0, 20),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local NewKeyAccent = Instances:Create("Frame", {
                Parent = NewKey.Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0.5, 0),
                Size = UDim2New(0, 6, 0, 6),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            Instances:Create("UIGradient", {
                Parent = NewKeyAccent.Instance,
                Name = "\0",
                Rotation = -115,
                Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
            }):AddToTheme({
                Color = function()
                    return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
                end
            })
            Instances:Create("UICorner", {
                Parent = NewKeyAccent.Instance,
                Name = "\0"
            })

            local NewKeyText = Instances:Create("TextLabel", {
                Parent = NewKey.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(255, 255, 255),
                TextTransparency = 0.3,
                Text = Name .. " [" .. Key .. "]",
                Size = UDim2New(0, 0, 0, 15),
                AnchorPoint = Vector2New(0, 0.5),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0.5, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            NewKeyText:AddToTheme({ TextColor3 = "Text" })

            function NewKey:Set(Name, Key)
                NewKeyText.Instance.Text = Name .. " [" .. Key .. "]"
            end

            function NewKey:SetStatus(Bool)
                if Bool then
                    NewKeyText:Tween(nil, { Position = UDim2New(0, 15, 0.5, 0), TextTransparency = 0 })
                    NewKeyAccent:Tween(nil, { BackgroundTransparency = 0 })
                else
                    NewKeyText:Tween(nil, { Position = UDim2New(0, 0, 0.5, 0), TextTransparency = 0.3 })
                    NewKeyAccent:Tween(nil, { BackgroundTransparency = 1 })
                end
            end

            return NewKey
        end

        return KeybindList
    end

    function Library.Notification(self, Data)
        local Items = {}
        Items["Notification"] = Instances:Create("Frame", {
            Parent = Library.NotifHolder.Instance,
            Name = "\0",
            BackgroundTransparency = 0.35,
            BorderColor3 = FromRGB(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["Notification"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(255, 255, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = Data.Title,
            BackgroundTransparency = 1,
            Size = UDim2New(0, 0, 0, 15),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Title"]:AddToTheme({ TextColor3 = "Text" })

        Instances:Create("UIPadding", {
            Parent = Items["Notification"].Instance,
            Name = "\0",
            PaddingTop = UDimNew(0, 8),
            PaddingBottom = UDimNew(0, 8),
            PaddingRight = UDimNew(0, 8),
            PaddingLeft = UDimNew(0, 8)
        })
        Instances:Create("UICorner", {
            Parent = Items["Notification"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 5)
        })

        Items["Description"] = Instances:Create("TextLabel", {
            Parent = Items["Notification"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(255, 255, 255),
            TextTransparency = 0.3,
            Text = Data.Description,
            Size = UDim2New(0, 0, 0, 15),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 0, 0, 20),
            BorderColor3 = FromRGB(0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Description"]:AddToTheme({ TextColor3 = "Text" })

        Items["Accent"] = Instances:Create("Frame", {
            Parent = Items["Notification"].Instance,
            Name = "\0",
            Position = UDim2New(0, 0, 0, Items["Description"].Instance.AbsoluteSize.Y + Items["Title"].Instance.AbsoluteSize.Y + 12),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 0, 0, 6),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(1, 0)
        })
        Instances:Create("UIGradient", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
        }):AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        local iconUrl, iconOffset, iconSize = GetIcon(Data.Icon or "bell", 48)
        Items["Icon"] = Instances:Create("ImageLabel", {
            Parent = Items["Notification"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(255, 255, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(1, 0),
            Image = iconUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(1, 0, 0, 0),
            Size = UDim2New(0, 16, 0, 16),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if iconOffset then
            Items["Icon"].Instance.ImageRectOffset = iconOffset
            Items["Icon"].Instance.ImageRectSize = iconSize
        end
        Instances:Create("UIGradient", {
            Parent = Items["Icon"].Instance,
            Name = "\0",
            Rotation = -115,
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
        }):AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        local Size = Items["Notification"].Instance.AbsoluteSize
        Items["Notification"].Instance.Size = UDim2New(0, 0, 0, 0)
        for _, Value in Items do
            if Value.Instance:IsA("Frame") then
                Value.Instance.BackgroundTransparency = 1
            elseif Value.Instance:IsA("TextLabel") then
                Value.Instance.TextTransparency = 1
            elseif Value.Instance:IsA("ImageLabel") then
                Value.Instance.ImageTransparency = 1
            end
        end

        task.wait(0.2)
        Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.Y

        Library:Thread(function()
            for _, Value in Items do
                if Value.Instance:IsA("Frame") then
                    Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), { BackgroundTransparency = 0 })
                elseif Value.Instance:IsA("TextLabel") then
                    Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), { TextTransparency = 0 })
                elseif Value.Instance:IsA("ImageLabel") then
                    Value:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), { ImageTransparency = 0 })
                end
            end
            Items["Notification"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), { Size = UDim2New(0, Size.X, 0, Size.Y) })
            Items["Accent"]:Tween(TweenInfo.new(Data.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), { Size = UDim2New(1, 0, 0, 6) })
            task.delay(Data.Duration + 0.15, function()
                for _, Value in Items do
                    if Value.Instance:IsA("Frame") then
                        Value:Tween(nil, { BackgroundTransparency = 1 })
                    elseif Value.Instance:IsA("TextLabel") then
                        Value:Tween(nil, { TextTransparency = 1 })
                    elseif Value.Instance:IsA("ImageLabel") then
                        Value:Tween(nil, { ImageTransparency = 1 })
                    end
                end
                Items["Notification"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), { Size = UDim2New(0, 0, 0, 0) })
                task.wait(0.5)
                Items["Notification"]:Clean()
            end)
        end)
    end

    function Library.Window(self, Data)
        Data = Data or {}
        local Window = {
            Name = Data.Name or Data.name or "Window",
            SubName = Data.SubName or Data.subname or "Fine-tuning for sure wins",
            Logo = Data.Logo or Data.logo or "1l20959262762131",
            BackgroundImage = Data.BackgroundImage or Data.backgroundimage or nil,
            BackgroundImageTransparency = Data.BackgroundImageTransparency or Data.backgroundimagetransparency or 0.5,
            Pages = {},
            Items = {},
            IsOpen = false,
            CurrentAlignment = "LeftTabs"
        }

        local Items = {}
        Items["MainFrame"] = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(0.5, 0.5),
            BackgroundTransparency = 0.12,
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = UDim2New(0, 677, 0, 644),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })
        Items["MainFrame"]:AddToTheme({ BackgroundColor3 = "Background" })

        local MainUIScale = Instances:Create("UIScale", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
        })

        local function UpdateMainScale()
            local vp = Workspace.CurrentCamera.ViewportSize
            local padding = 40
            local scaleX = (vp.X - padding) / 677
            local scaleY = (vp.Y - padding) / 644
            local scale = MathMin(scaleX, scaleY, 1)
            if IsMobile then
                scale = MathMin(scale, 0.75)
            end
            MainUIScale.Instance.Scale = MathMax(scale, 0.35)
        end

        UpdateMainScale()
        Library:Connect(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
            UpdateMainScale()
        end)

        if Window.BackgroundImage then
            Items["BackgroundImage"] = Instances:Create("ImageLabel", {
                Parent = Items["MainFrame"].Instance,
                Name = "\0",
                Image = Window.BackgroundImage,
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 1, 0),
                ZIndex = 0,
                ScaleType = Enum.ScaleType.Crop,
                ImageTransparency = Window.BackgroundImageTransparency
            })
            Instances:Create("UICorner", {
                Parent = Items["BackgroundImage"].Instance,
                Name = "\0",
                CornerRadius = UDimNew(0, 4)
            })
            Items["MainFrame"].Instance.BackgroundTransparency = 1
        end

        Items["MainFrame"]:MakeResizeable(Vector2New(Items["MainFrame"].Instance.AbsoluteSize.X, Items["MainFrame"].Instance.AbsoluteSize.Y), Vector2New(9999, 9999))
        Library:MakeBlurred(Items["MainFrame"], Window)

        Items["LeftTabs"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            Visible = true,
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(1, 0),
            BackgroundTransparency = 0.15,
            Size = UDim2New(0, 225, 1, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })
        Items["LeftTabs"]:AddToTheme({ BackgroundColor3 = "Background" })
        Library:MakeBlurred(Items["LeftTabs"], Window)

        local Gui = Items["MainFrame"].Instance
        local Dragging = false
        local DragStart
        local StartPosition
        local function Set(Input)
            local DragDelta = Input.Position - DragStart
            Items["MainFrame"]:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y) })
        end
        Items["MainFrame"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position
                StartPosition = Gui.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)
        Items["LeftTabs"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position
                StartPosition = Gui.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)
        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if Dragging then
                    Set(Input)
                end
            end
        end)

        if IsMobile then
            Items["FloatingButton"] = Instances:Create("TextButton", {
                Parent = Library.Holder.Instance,
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Position = UDim2New(0.5, 0, 0, 20),
                AnchorPoint = Vector2New(0.5, 0),
                Visible = true,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 40, 0, 40),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.5,
                ZIndex = 127,
                BackgroundColor3 = Library.Theme.Background
            })
            Items["FloatingButton"]:AddToTheme({ BackgroundColor3 = "Background" })

            local GuiFloating = Items["FloatingButton"].Instance
            local DraggingFloating = false
            local DragStartFloating
            local StartPositionFloating
            local function SetFloating(Input)
                local DragDelta = Input.Position - DragStartFloating
                Items["FloatingButton"]:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(StartPositionFloating.X.Scale, StartPositionFloating.X.Offset + DragDelta.X, StartPositionFloating.Y.Scale, StartPositionFloating.Y.Offset + DragDelta.Y) })
            end
            Items["FloatingButton"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingFloating = true
                    DragStartFloating = Input.Position
                    StartPositionFloating = GuiFloating.Position
                    Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            DraggingFloating = false
                        end
                    end)
                end
            end)
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if DraggingFloating then
                        SetFloating(Input)
                    end
                end
            end)

            Items["FloatingLogo"] = Instances:Create("ImageLabel", {
                Parent = Items["FloatingButton"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Name = "\0",
                Image = "rbxassetid://" .. Window.Logo,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                ZIndex = 127,
                Size = UDim2New(1, -20, 1, -20),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            Instances:Create("UICorner", {
                Parent = Items["FloatingButton"].Instance,
                CornerRadius = UDimNew(1, 0)
            })
            Instances:Create("UIGradient", {
                Parent = Items["FloatingLogo"].Instance,
                Name = "\0",
                Enabled = true,
                Rotation = -115,
                Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
            }):AddToTheme({
                Color = function()
                    return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
                end
            })
        end

        Instances:Create("UIListLayout", {
            Parent = Items["LeftTabs"].Instance,
            Name = "\0",
            Padding = UDimNew(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Instances:Create("UIPadding", {
            Parent = Items["LeftTabs"].Instance,
            Name = "\0",
            PaddingTop = UDimNew(0, 15),
            PaddingBottom = UDimNew(0, 15),
            PaddingRight = UDimNew(0, 12),
            PaddingLeft = UDimNew(0, 12)
        })

        Items["Logo"] = Instances:Create("ImageLabel", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(255, 255, 255),
            ScaleType = Enum.ScaleType.Fit,
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 35, 0, 35),
            Image = "rbxassetid://" .. Window.Logo,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 12, 0, 12),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UIGradient", {
            Parent = Items["Logo"].Instance,
            Name = "\0",
            Enabled = true,
            Rotation = -115,
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
        }):AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = Window.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 52, 0, 13),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 16,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Title"]:AddToTheme({ TextColor3 = "Text" })

        Items["SubTitle"] = Instances:Create("TextLabel", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.4,
            Text = Window.SubName,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 52, 0, 30),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["SubTitle"]:AddToTheme({ TextColor3 = "Text" })

        Items["Content"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 0.75,
            Position = UDim2New(0, 0, 0, 55),
            Size = UDim2New(1, 0, 1, -55),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })
        Items["Content"]:AddToTheme({ BackgroundColor3 = "Background" })

        Items["CloseButton"] = Instances:Create("TextButton", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 0.2,
            Position = UDim2New(1, -14, 0, 11),
            Size = UDim2New(0, 32, 0, 32),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })
        Items["CloseButton"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["CloseButton"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 7)
        })

        local closeIconUrl, closeIconOffset, closeIconSize = GetIcon("x", 48)
        Items["CloseIcon"] = Instances:Create("ImageLabel", {
            Parent = Items["CloseButton"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(240, 240, 240),
            ImageTransparency = 0.3,
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 11, 0, 11),
            AnchorPoint = Vector2New(0.5, 0.5),
            Image = closeIconUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(0.5, 0, 0.5, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if closeIconOffset then
            Items["CloseIcon"].Instance.ImageRectOffset = closeIconOffset
            Items["CloseIcon"].Instance.ImageRectSize = closeIconSize
        end
        Items["CloseIcon"]:AddToTheme({ ImageColor3 = "Text" })
        Items["CloseButton"]:Connect("MouseButton1Down", function()
            Library:Unload()
        end)

        Instances:Create("UICorner", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })
        Instances:Create("UICorner", {
            Parent = Items["LeftTabs"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        local Settings = {
            IsOpen = false,
            Name = "",
            Items = {},
            IsSettings = true,
            Elements = {}
        }

        local SettingsItems = {}
        SettingsItems["Settings"] = Instances:Create("Frame", {
            Parent = Library.UnusedHolder.Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(0.5, 0.5),
            BorderSizePixel = 0,
            Position = UDim2New(0.8949604630470276, 0, 0.2945185601711273, 0),
            Size = UDim2New(0, 245, 0, 159),
            ZIndex = 2,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = FromRGB(21, 21, 24)
        })
        SettingsItems["Settings"]:AddToTheme({ BackgroundColor3 = "Section Background 2" })
        Instances:Create("UICorner", {
            Parent = SettingsItems["Settings"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 6)
        })

        SettingsItems["CloseButton"] = Instances:Create("TextButton", {
            Parent = SettingsItems["Settings"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(0, 1),
            BorderSizePixel = 0,
            Position = UDim2New(0, 8, 1, -8),
            Size = UDim2New(1, -16, 0, 32),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        SettingsItems["CloseButton"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = SettingsItems["CloseButton"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })
        SettingsItems["Text"] = Instances:Create("TextLabel", {
            Parent = SettingsItems["CloseButton"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = "Close",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            AnchorPoint = Vector2New(0.5, 0.5),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(0.5, 0, 0.5, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })

        SettingsItems["Content"] = Instances:Create("ScrollingFrame", {
            Parent = SettingsItems["Settings"].Instance,
            Name = "\0",
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Selectable = false,
            Size = UDim2New(1, -8, 1, -46),
            Position = UDim2New(0, 4, 0, 4),
            ScrollBarThickness = 2,
            BackgroundColor3 = FromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = FromRGB(0, 0, 0),
            BorderSizePixel = 0,
            CanvasSize = UDim2New(0, 0, 0, 0)
        })
        SettingsItems["Content"]:AddToTheme({ ScrollBarImageColor3 = "Accent" })
        Instances:Create("UIListLayout", {
            Parent = SettingsItems["Content"].Instance,
            Name = "\0",
            Padding = UDimNew(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Instances:Create("UIPadding", {
            Parent = SettingsItems["Content"].Instance,
            Name = "\0",
            PaddingTop = UDimNew(0, 4),
            PaddingBottom = UDimNew(0, 4),
            PaddingRight = UDimNew(0, 4),
            PaddingLeft = UDimNew(0, 4)
        })

        SettingsItems["CloseButton"]:Connect("MouseButton1Down", function()
            Settings:SetOpen(false)
        end)

        local RenderStepped
        local Debounce = false
        function Settings:SetOpen(Bool)
            if Debounce then return end
            Settings.IsOpen = Bool
            Debounce = true
            if Settings.IsOpen then
                for _, Value in Settings.Elements do
                    Value:RefreshPosition(true)
                    task.wait(0.03)
                end
                SettingsItems["Settings"].Instance.Visible = true
                SettingsItems["Settings"].Instance.Parent = Library.Holder.Instance
                RenderStepped = RunService.RenderStepped:Connect(function()
                    SettingsItems["Settings"].Instance.Position = UDim2New(0, Items["SettingsIcon"].Instance.AbsolutePosition.X, 0, Items["SettingsIcon"].Instance.AbsolutePosition.Y + Items["SettingsButton"].Instance.AbsoluteSize.Y + 108)
                    SettingsItems["Settings"].Instance.Size = UDim2New(0, 325, 0, 230)
                end)
                for _, Value in Library.OpenFrames do
                    if Value ~= Settings then
                        Value:SetOpen(false)
                    end
                end
                Library.OpenFrames[Settings] = Settings
            else
                for _, Value in Settings.Elements do
                    Value:RefreshPosition(false)
                end
                if Library.OpenFrames[Settings] then
                    Library.OpenFrames[Settings] = nil
                end
                if RenderStepped then
                    RenderStepped:Disconnect()
                    RenderStepped = nil
                end
            end
            local Descendants = SettingsItems["Settings"].Instance:GetDescendants()
            TableInsert(Descendants, SettingsItems["Settings"].Instance)
            local NewTween
            for _, Value in Descendants do
                local TransparencyProperty = Tween:GetProperty(Value)
                if not TransparencyProperty then continue end
                if not Value.ClassName:find("UI") then
                    Value.ZIndex = Settings.IsOpen and 7 or 1
                    SettingsItems["Text"].Instance.ZIndex = 8
                end
                if type(TransparencyProperty) == "table" then
                    for _, Property in TransparencyProperty do
                        NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                end
            end
            NewTween.Tween.Completed:Connect(function()
                Debounce = false
                SettingsItems["Settings"].Instance.Visible = Settings.IsOpen
                task.wait(0.2)
                SettingsItems["Settings"].Instance.Parent = not Settings.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
            end)
        end

        Settings.Items = SettingsItems
        setmetatable(Settings, Library.Sections)

        Items["SettingsButton"] = Instances:Create("TextButton", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 0.2,
            Position = UDim2New(1, -56, 0, 11),
            Size = UDim2New(0, 32, 0, 32),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })
        Items["SettingsButton"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["SettingsButton"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 7)
        })

        local settingsIconUrl, settingsIconOffset, settingsIconSize = GetIcon("settings", 48)
        Items["SettingsIcon"] = Instances:Create("ImageLabel", {
            Parent = Items["SettingsButton"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(240, 240, 240),
            ImageTransparency = 0.3,
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 15, 0, 14),
            AnchorPoint = Vector2New(0.5, 0.5),
            Image = settingsIconUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(0.5, 0, 0.5, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if settingsIconOffset then
            Items["SettingsIcon"].Instance.ImageRectOffset = settingsIconOffset
            Items["SettingsIcon"].Instance.ImageRectSize = settingsIconSize
        end
        Items["SettingsIcon"]:AddToTheme({ ImageColor3 = "Text" })

        Items["SettingsButton"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Settings:SetOpen(not Settings.IsOpen)
            end
        end)

        Settings:Label("First gradient color"):Colorpicker({
            Flag = "AccentColor",
            Default = Library.Theme.Accent,
            Callback = function(Color)
                Library.Theme.Accent = Color
                Library:ChangeTheme("Accent", Color)
            end
        })
        Settings:Label("Second gradient color"):Colorpicker({
            Flag = "AccentGradientColor",
            Default = Library.Theme.AccentGradient,
            Callback = function(Color)
                Library.Theme.AccentGradient = Color
                Library:ChangeTheme("AccentGradient", Color)
            end
        })
        Settings:Dropdown({
            Name = "Font weight",
            Flag = "FontStyle",
            Default = "SemiBold",
            Items = { "Light", "Regular", "SemiBold" },
            Callback = function(Value)
                local FontData = Library.Fonts[Value]
                if FontData then
                    Library.Font = FontData
                    Library:UpdateText()
                end
            end
        })
        Settings:Slider({
            Name = "Background Transparency",
            Default = 0.12,
            Decimals = 0.01,
            Max = 1,
            Min = 0,
            Suffix = "%",
            Flag = "BackgroundTransparency",
            Callback = function(Value)
                if Items["BackgroundImage"] then
                    Items["MainFrame"].Instance.BackgroundTransparency = 1
                else
                    Items["MainFrame"].Instance.BackgroundTransparency = Value
                end
                Items["LeftTabs"].Instance.BackgroundTransparency = Value
                if IsMobile then
                    Items["FloatingButton"].Instance.BackgroundTransparency = Value
                end
            end
        })

        Window.Items = Items

        local DebounceWindow = false
        function Window:SetOpen(Bool)
            if DebounceWindow then return end
            Window.IsOpen = Bool
            DebounceWindow = true
            if Window.IsOpen then
                Items["MainFrame"].Instance.Visible = true
            end
            local Descendants = Items["MainFrame"].Instance:GetDescendants()
            TableInsert(Descendants, Items["MainFrame"].Instance)
            local NewTween
            for _, Value in Descendants do
                local TransparencyProperty = Tween:GetProperty(Value)
                if not TransparencyProperty then continue end
                if type(TransparencyProperty) == "table" then
                    for _, Property in TransparencyProperty do
                        NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                end
            end
            NewTween.Tween.Completed:Connect(function()
                DebounceWindow = false
                Items["MainFrame"].Instance.Visible = Window.IsOpen
            end)
        end

        if IsMobile then
            Items["FloatingButton"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Window:SetOpen(not Window.IsOpen)
                end
            end)
        end

        function Window:Init()
            for _, Value in Window.Pages do
                if Value.Active then
                    for _, Value2 in Value.Sections do
                        task.spawn(function()
                            Value2:TweenElements(true)
                        end)
                    end
                end
            end
        end

        task.wait()
        Window:SetOpen(true)
        return setmetatable(Window, Library)
    end

    function Library.Category(self, Name)
        Instances:Create("TextLabel", {
            Parent = self.Items["LeftTabs"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.4,
            Text = Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(1, 0, 0, 15),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        }):AddToTheme({ TextColor3 = "Text" })
    end

    function Library.Page(self, Data)
        Data = Data or {}
        local Page = {
            Window = self,
            Name = Data.Name or Data.name or "Page",
            Icon = Data.Icon or Data.icon or "file",
            Columns = Data.Columns or Data.columns or 2,
            Items = {},
            ColumnsData = {},
            Sections = {},
            Active = false
        }

        local Items = {}
        Items["Inactive"] = Instances:Create("TextButton", {
            Parent = Page.Window.Items["LeftTabs"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2New(0, 200, 0, 40),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(124, 163, 255)
        })
        Items["Inactive"]:AddToTheme({ BackgroundColor3 = "Accent" })
        Instances:Create("UICorner", {
            Parent = Items["Inactive"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 5)
        })

        local pageIconUrl, pageIconOffset, pageIconSize = GetIcon(Page.Icon, 48)
        Items["Icon"] = Instances:Create("ImageLabel", {
            Parent = Items["Inactive"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(255, 255, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 18, 0, 18),
            AnchorPoint = Vector2New(0, 0.5),
            Image = pageIconUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(0, 16, 0.5, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if pageIconOffset then
            Items["Icon"].Instance.ImageRectOffset = pageIconOffset
            Items["Icon"].Instance.ImageRectSize = pageIconSize
        end
        Instances:Create("UIGradient", {
            Parent = Items["Icon"].Instance,
            Name = "\0",
            Rotation = -115
        }):AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Inactive"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = Page.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            AnchorPoint = Vector2New(0, 0.5),
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 45, 0.5, 0),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Text"]:AddToTheme({ TextColor3 = "Text" })

        Items["Page"] = Instances:Create("Frame", {
            Parent = Library.UnusedHolder.Instance,
            Name = "\0",
            Visible = false,
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 1, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            Position = UDim2New(0, 0, 0, 60),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UIListLayout", {
            Parent = Items["Page"].Instance,
            Name = "\0",
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDimNew(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalFlex = Enum.UIFlexAlignment.Fill
        })
        Instances:Create("UIPadding", {
            Parent = Items["Page"].Instance,
            Name = "\0",
            PaddingTop = UDimNew(0, 10),
            PaddingBottom = UDimNew(0, 10),
            PaddingRight = UDimNew(0, 10),
            PaddingLeft = UDimNew(0, 10)
        })

        for Index = 1, Page.Columns do
            local NewColumn = Instances:Create("ScrollingFrame", {
                Parent = Items["Page"].Instance,
                Name = "\0",
                ScrollBarImageColor3 = FromRGB(0, 0, 0),
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 0,
                BorderColor3 = FromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                Size = UDim2New(0, 100, 0, 100),
                BackgroundColor3 = FromRGB(255, 255, 255),
                ZIndex = 2,
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0)
            })
            Instances:Create("UIListLayout", {
                Parent = NewColumn.Instance,
                Name = "\0",
                Padding = UDimNew(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            Page.ColumnsData[Index] = NewColumn
        end

        Page.Items = Items

        local Debounce = false
        function Page:Turn(Bool)
            if Debounce then return end
            Page.Active = Bool
            Debounce = true
            Items["Page"].Instance.Visible = Bool
            Items["Page"].Instance.Parent = Bool and Page.Window.Items["Content"].Instance or Library.UnusedHolder.Instance
            if Page.Active then
                Items["Inactive"]:Tween(nil, { BackgroundTransparency = 0.25 })
                Items["Page"]:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 0) })
                for _, Value in Page.Sections do
                    task.spawn(function()
                        Value:TweenElements(true)
                    end)
                end
            else
                Items["Inactive"]:Tween(nil, { BackgroundTransparency = 1 })
                Items["Page"]:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 60) })
            end
            local AllInstances = Items["Page"].Instance:GetDescendants()
            TableInsert(AllInstances, Items["Page"].Instance)
            local NewTween
            for _, Value in AllInstances do
                local TransparencyProperty = Tween:GetProperty(Value)
                if not TransparencyProperty then continue end
                if type(TransparencyProperty) == "table" then
                    for _, Property in TransparencyProperty do
                        NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                end
            end
            Library:Connect(NewTween.Tween.Completed, function()
                Debounce = false
                if not Page.Active then
                    for _, Value in Page.Sections do
                        task.spawn(function()
                            Value:TweenElements(false, true)
                        end)
                    end
                end
            end)
        end

        Items["Inactive"]:Connect("MouseButton1Down", function()
            for _, Value in Page.Window.Pages do
                if Value == Page and Page.Active then return end
                Value:Turn(Value == Page)
            end
        end)

        if #Page.Window.Pages == 0 then
            Page:Turn(true)
        end

        TableInsert(Page.Window.Pages, Page)
        return setmetatable(Page, Library.Pages)
    end

    function Library.Pages.GlobalChat(self, Side)
        local GlobalChat = {}
        Library.GlobalChatt = GlobalChat

        local Items = {}
        Items["GlobalChat"] = Instances:Create("Frame", {
            Parent = self.ColumnsData[Side].Instance,
            Name = "\0",
            BackgroundTransparency = 0.3,
            Position = UDim2New(0, 0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(1, 0, 1, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })
        Items["GlobalChat"]:AddToTheme({ BackgroundColor3 = "Section Background 2" })
        Items["GlobalChat"]:MakeDraggable()
        Instances:Create("UICorner", {
            Parent = Items["GlobalChat"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 6)
        })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["GlobalChat"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "GLOBAL CHAT",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 12, 0, 13),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 16,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Title"]:AddToTheme({ TextColor3 = "Text" })

        Items["SubTitle"] = Instances:Create("TextLabel", {
            Parent = Items["GlobalChat"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.4,
            Text = "Chat with other users here.",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 14, 0, 30),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["SubTitle"]:AddToTheme({ TextColor3 = "Text" })

        Items["Message"] = Instances:Create("Frame", {
            Parent = Items["GlobalChat"].Instance,
            Name = "\0",
            Active = true,
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(0, 1),
            Selectable = true,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 12, 1, -12),
            Size = UDim2New(1, -66, 0, 32),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["Message"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["Message"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Background"] = Instances:Create("Frame", {
            Parent = Items["Message"].Instance,
            Name = "\0",
            Active = true,
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(1, 0, 1, 0),
            Selectable = true,
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["Background"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Input"] = Instances:Create("TextBox", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            ZIndex = 2,
            Size = UDim2New(1, -20, 0, 15),
            Position = UDim2New(0, 10, 0, 8),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            PlaceholderColor3 = FromRGB(185, 185, 185),
            TextXAlignment = Enum.TextXAlignment.Left,
            PlaceholderText = "Message...",
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Input"]:AddToTheme({ TextColor3 = "Text" })

        Items["SendButton"] = Instances:Create("TextButton", {
            Parent = Items["GlobalChat"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(1, 1),
            Position = UDim2New(1, -12, 1, -12),
            Size = UDim2New(0, 32, 0, 32),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["SendButton"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["SendButton"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        local sendIconUrl, sendIconOffset, sendIconSize = GetIcon("send", 48)
        Items["SendIcon"] = Instances:Create("ImageLabel", {
            Parent = Items["SendButton"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(255, 255, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            ImageTransparency = 0.2,
            AnchorPoint = Vector2New(0.5, 0.5),
            Image = sendIconUrl or "",
            BackgroundTransparency = 1,
            ZIndex = 3,
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = UDim2New(0, 22, 0, 22),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if sendIconOffset then
            Items["SendIcon"].Instance.ImageRectOffset = sendIconOffset
            Items["SendIcon"].Instance.ImageRectSize = sendIconSize
        end

        Items["Messages"] = Instances:Create("ScrollingFrame", {
            Parent = Items["GlobalChat"].Instance,
            Name = "\0",
            ScrollBarImageColor3 = FromRGB(124, 163, 255),
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            Size = UDim2New(1, -24, 1, -115),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 12, 0, 60),
            BackgroundColor3 = FromRGB(255, 255, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            BorderSizePixel = 0,
            CanvasSize = UDim2New(0, 0, 0, 0)
        })
        Items["Messages"]:AddToTheme({ ScrollBarImageColor3 = "Accent" })
        Instances:Create("UIListLayout", {
            Parent = Items["Messages"].Instance,
            Name = "\0",
            Padding = UDimNew(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Instances:Create("UIPadding", {
            Parent = Items["Messages"].Instance,
            Name = "\0",
            PaddingTop = UDimNew(0, 0),
            PaddingBottom = UDimNew(0, 0),
            PaddingRight = UDimNew(0, 10),
            PaddingLeft = UDimNew(0, 0)
        })

        Items["Status"] = Instances:Create("Frame", {
            Parent = Items["GlobalChat"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2New(1, -12, 0, 10),
            Size = UDim2New(0, 100, 0, 20),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["StatusCircle"] = Instances:Create("Frame", {
            Parent = Items["Status"].Instance,
            Name = "\0",
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, 0, 0.5, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 12, 0, 12),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 210, 62)
        })
        Instances:Create("UICorner", {
            Parent = Items["StatusCircle"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(1, 0)
        })
        Items["StatusText"] = Instances:Create("TextLabel", {
            Parent = Items["Status"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(255, 210, 62),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "67 Active | Connected",
            AnchorPoint = Vector2New(1, 0.5),
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2New(1, -20, 0.5, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })

        function GlobalChat:SetVisibility(Bool)
            Items["GlobalChat"].Instance.Visible = Bool
            Items["GlobalChat"].Instance.Parent = Bool and self.ColumnsData[1].Instance.Parent or Library.UnusedHolder
        end

        function GlobalChat:SetStatus(Text, Color)
            Items["StatusText"].Instance.Text = Text
            Items["StatusText"].Instance.TextColor3 = Color
            Items["StatusCircle"].Instance.BackgroundColor3 = Color
        end

        function GlobalChat:GetTypedMessage()
            return Items["Input"].Instance.Text
        end

        function GlobalChat:ClearText()
            Items["Input"].Instance.Text = ""
        end

        local OnMessagePressed
        function GlobalChat:OnMessageSendPressed(Func)
            OnMessagePressed = Func
        end

        Items["SendButton"]:Connect("MouseButton1Down", function()
            if GlobalChat:GetTypedMessage() == "" then return end
            if OnMessagePressed then OnMessagePressed() end
        end)

        Items["Messages"]:Connect("ChildAdded", function()
            task.wait()
            Items["Messages"]:Tween(nil, { CanvasPosition = Vector2New(0, Items["Messages"].Instance.AbsoluteCanvasSize.Y - Items["Messages"].Instance.AbsoluteSize.Y) })
        end)

        for _, Value in Items["GlobalChat"].Instance:GetDescendants() do
            if Value.ClassName:find("UI") then continue end
            Value.ZIndex = 2
        end
        Items["GlobalChat"].Instance.ZIndex = 2
        Items["SendIcon"].Instance.ZIndex = 3

        return GlobalChat
    end

    function Library.Pages.Section(self, Data)
        Data = Data or {}
        local Section = {
            Window = self.Window,
            Page = self,
            Name = Data.Name or Data.name or "Section",
            Description = Data.Description or Data.Description or "",
            Icon = Data.Icon or Data.icon or "folder",
            Side = Data.Side or Data.side or 1,
            Items = {},
            IsActive = true,
            Elements = {},
            Groups = {}
        }

        local Items = {}
        Items["Section"] = Instances:Create("Frame", {
            Parent = Section.Page.ColumnsData[Section.Side].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 0.65,
            ClipsDescendants = true,
            BorderSizePixel = 0,
            Size = UDim2New(1, 0, 0, 45),
            ZIndex = 2,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = FromRGB(29, 28, 32)
        })
        Items["Section"]:AddToTheme({ BackgroundColor3 = "Section Background 2" })

        Items["Top"] = Instances:Create("Frame", {
            Parent = Items["Section"].Instance,
            Name = "\0",
            BackgroundTransparency = 0.65,
            Size = UDim2New(1, 0, 0, 55),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(31, 31, 36)
        })
        Items["Top"]:AddToTheme({ BackgroundColor3 = "Outline" })

        Items["TopBackground"] = Instances:Create("Frame", {
            Parent = Items["Top"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 0.65,
            Position = UDim2New(0, 1, 0, 1),
            Size = UDim2New(1, -2, 1, -2),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(26, 26, 30)
        })
        Items["TopBackground"]:AddToTheme({ BackgroundColor3 = "Section Top" })

        local sectionIconUrl, sectionIconOffset, sectionIconSize = GetIcon(Section.Icon, 48)
        Items["Icon"] = Instances:Create("ImageLabel", {
            Parent = Items["TopBackground"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(255, 255, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 21, 0, 20),
            AnchorPoint = Vector2New(0, 0.5),
            Image = sectionIconUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(0, 15, 0.5, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if sectionIconOffset then
            Items["Icon"].Instance.ImageRectOffset = sectionIconOffset
            Items["Icon"].Instance.ImageRectSize = sectionIconSize
        end
        Instances:Create("UIGradient", {
            Parent = Items["Icon"].Instance,
            Name = "\0",
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(131, 131, 131)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255)) }
        }):AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        Items["Description"] = Instances:Create("TextLabel", {
            Parent = Items["TopBackground"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(183, 183, 183),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = Section.Description,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 50, 0, 28),
            BorderSizePixel = 0,
            TextTransparency = 0.4,
            ZIndex = 2,
            TextSize = 15,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Description"]:AddToTheme({ TextColor3 = "Text" })

        Instances:Create("UICorner", {
            Parent = Items["TopBackground"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["TopBackground"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(248, 248, 248),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = Section.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 50, 0, 10),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 15,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Title"]:AddToTheme({ TextColor3 = "Text" })

        Items["Toggle"] = Instances:Create("TextButton", {
            Parent = Items["Top"].Instance,
            Name = "\0",
            Active = false,
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(1, 0.5),
            Selectable = false,
            Position = UDim2New(1, -15, 0.5, 0),
            Size = UDim2New(0, 26, 0, 16),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Circle"] = Instances:Create("Frame", {
            Parent = Items["Toggle"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, -4, 0.5, 0),
            Size = UDim2New(0, 8, 0, 8),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Circle"]:AddToTheme({ BackgroundColor3 = "Text" })
        Instances:Create("UICorner", {
            Parent = Items["Circle"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 99999)
        })
        Instances:Create("UICorner", {
            Parent = Items["Toggle"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 9)
        })
        Items["Gradient"] = Instances:Create("UIGradient", {
            Parent = Items["Toggle"].Instance,
            Name = "\0",
            Rotation = -115,
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
        })
        Items["Gradient"]:AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        Instances:Create("UICorner", {
            Parent = Items["Top"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Fill"] = Instances:Create("Frame", {
            Parent = Items["Top"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 1, 1, -4),
            Size = UDim2New(1, -2, 0, 4),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(26, 26, 30)
        })
        Items["Fill"]:AddToTheme({ BackgroundColor3 = "Section Background" })
        Instances:Create("UICorner", {
            Parent = Items["Fill"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Instances:Create("UICorner", {
            Parent = Items["Section"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Background"] = Instances:Create("Frame", {
            Parent = Items["Section"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 0.65,
            Position = UDim2New(0, 1, 0, 55),
            Size = UDim2New(1, -2, 1, -56),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(24, 22, 25)
        })
        Items["Background"]:AddToTheme({ BackgroundColor3 = "Section Background" })

        Items["Content"] = Instances:Create("Frame", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 12, 0, 15),
            Size = UDim2New(1, -24, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UIListLayout", {
            Parent = Items["Content"].Instance,
            Name = "\0",
            Padding = UDimNew(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Items["Fade"] = Instances:Create("TextButton", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Size = UDim2New(0, 0, 10, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            AutoButtonColor = false,
            Visible = false,
            Text = "",
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(24, 22, 25)
        })
        Items["Fade"]:AddToTheme({ BackgroundColor3 = "Section Background" })
        Instances:Create("UICorner", {
            Parent = Items["Fade"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })
        Instances:Create("UIPadding", {
            Parent = Items["Content"].Instance,
            Name = "\0",
            PaddingBottom = UDimNew(0, 10)
        })

        Section.Items = Items

        function Section:ToggleBackground()
            Section.IsActive = not Section.IsActive
            if not Section.IsActive then
                Items["Fade"].Instance.Visible = true
                Items["Fade"]:Tween(nil, { BackgroundTransparency = 0.3 })
                Items["Gradient"].Instance.Enabled = false
                Items["Toggle"]:ChangeItemTheme({ BackgroundColor3 = "Element" })
                Items["Toggle"]:Tween(nil, { BackgroundColor3 = Library.Theme.Element })
                Items["Circle"]:Tween(nil, { AnchorPoint = Vector2New(0, 0.5), Position = UDim2New(0, 4, 0.5, 0), BackgroundColor3 = Library.Theme.Text, BackgroundTransparency = 0.6 })
            else
                Items["Fade"]:Tween(nil, { BackgroundTransparency = 1 })
                task.spawn(function()
                    task.wait(Library.Tween.Time)
                    Items["Fade"].Instance.Visible = false
                end)
                Items["Gradient"].Instance.Enabled = true
                Items["Toggle"]:ChangeItemTheme({ BackgroundColor3 = "Text" })
                Items["Toggle"]:Tween(nil, { BackgroundColor3 = Library.Theme.Text })
                Items["Circle"]:Tween(nil, { AnchorPoint = Vector2New(1, 0.5), Position = UDim2New(1, -4, 0.5, 0), BackgroundColor3 = Library.Theme.Text, BackgroundTransparency = 0 })
            end
        end

        Library:Connect(Items["Content"].Instance.Changed, function(Property)
            if Property == "AbsoluteSize" then
                Items["Fade"].Instance.Size = UDim2New(1, 0, 0, Items["Content"].Instance.AbsoluteSize.Y + 10)
            end
        end)

        function Section:TweenElements(Bool, Debounce)
            for _, Value in Section.Elements do
                Value:RefreshPosition(Bool)
                if not Debounce then
                    task.wait(0.03)
                end
            end
        end

        Items["Toggle"]:Connect("MouseButton1Down", function()
            Section:ToggleBackground()
        end)

        Section.Page.Sections[Section.Name] = Section
        return setmetatable(Section, Library.Sections)
    end

    function Library.Sections.Group(self, Data)
        Data = Data or {}
        local Group = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Data.Name or Data.name or "Group",
            Description = Data.Description or Data.description or "",
            Items = {},
            Elements = {},
            IsActive = true,
            IsSettings = false
        }

        local Items = {}
        Items["Group"] = Instances:Create("Frame", {
            Parent = self.Items["Content"].Instance,
            Name = "\0",
            BackgroundTransparency = 0.5,
            BorderColor3 = FromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2New(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            ClipsDescendants = true,
            BackgroundColor3 = FromRGB(24, 22, 25)
        })
        Items["Group"]:AddToTheme({ BackgroundColor3 = "Section Background 2" })
        Instances:Create("UICorner", {
            Parent = Items["Group"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["Group"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            Text = Group.Name,
            Size = UDim2New(1, -24, 0, 15),
            Position = UDim2New(0, 12, 0, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            BorderColor3 = FromRGB(0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            TextSize = 14,
            AutomaticSize = Enum.AutomaticSize.X
        })
        Items["Title"]:AddToTheme({ TextColor3 = "Text" })

        Items["Content"] = Instances:Create("Frame", {
            Parent = Items["Group"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = UDim2New(0, 12, 0, 32),
            Size = UDim2New(1, -24, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2
        })
        Instances:Create("UIListLayout", {
            Parent = Items["Content"].Instance,
            Name = "\0",
            Padding = UDimNew(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Instances:Create("UIPadding", {
            Parent = Items["Content"].Instance,
            Name = "\0",
            PaddingBottom = UDimNew(0, 10)
        })

        Group.Items = Items
        Group.Items.Section = Items["Group"]
        Group.Items.Fade = self.Items["Fade"]

        function Group:RefreshPosition(Bool)
            for _, Value in self.Elements do
                Value:RefreshPosition(Bool)
            end
        end

        function Group:TweenElements(Bool, Debounce)
            for _, Value in self.Elements do
                Value:RefreshPosition(Bool)
                if not Debounce then
                    task.wait(0.03)
                end
            end
        end

        self.Groups[#self.Groups + 1] = Group
        self.Elements[#self.Elements + 1] = Group

        return setmetatable(Group, Library.Sections)
    end

    function Library.Sections.Toggle(self, Data)
        Data = Data or {}
        local Toggle = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Data.Name or Data.name or "Toggle",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Default = Data.Default or Data.default or false,
            Callback = Data.Callback or Data.callback or function() end,
            Value = false
        }

        local Items = {}
        Items["Toggle"] = Instances:Create("TextButton", {
            Parent = Toggle.Section.Items["Content"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2New(1, 0, 0, 18),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Indicator"] = Instances:Create("Frame", {
            Parent = Items["Toggle"].Instance,
            Name = "\0",
            Size = UDim2New(0, 18, 0, 18),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(124, 163, 255)
        })
        Items["Indicator"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["Indicator"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 3)
        })

        Items["Accent"] = Instances:Create("Frame", {
            Parent = Items["Indicator"].Instance,
            Name = "\0",
            Size = UDim2New(0, 0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255),
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0.5, 0, 0.5, 0)
        })
        Instances:Create("UICorner", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 3)
        })

        local checkUrl, checkOffset, checkSize = GetIcon("check", 48)
        Items["CheckImage"] = Instances:Create("ImageLabel", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 0, 0, 0),
            AnchorPoint = Vector2New(0.5, 0.5),
            Image = checkUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(0.5, 0, 0.5, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            ImageTransparency = 1,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if checkOffset then
            Items["CheckImage"].Instance.ImageRectOffset = checkOffset
            Items["CheckImage"].Instance.ImageRectSize = checkSize
        end
        Items["CheckImage"]:AddToTheme({ ImageColor3 = "Text" })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Toggle"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = Toggle.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            Position = UDim2New(0, 24, 0, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Text"]:AddToTheme({ TextColor3 = "Text" })

        Items["Gradient"] = Instances:Create("UIGradient", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            Enabled = true,
            Rotation = -115,
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
        })
        Items["Gradient"]:AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        Items["Toggle"]:OnHover(function()
            Items["Indicator"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2New(0, 21, 0, 21), Position = UDim2New(0, -3, 0, -3) })
        end)
        Items["Toggle"]:OnHoverLeave(function()
            Items["Indicator"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2New(0, 18, 0, 18), Position = UDim2New(0, 0, 0, 0) })
        end)

        Items["Indicator"].Instance.Position = UDim2New(0, 60, 0, 0)
        Items["Text"].Instance.Position = UDim2New(0, 84, 0, 0)

        function Toggle:Get()
            return Toggle.Value
        end

        function Toggle:Set(Value)
            Toggle.Value = Value
            Library.Flags[Toggle.Flag] = Value
            if Toggle.Value then
                Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 0, Size = UDim2New(1, 0, 1, 0) })
                Items["CheckImage"]:Tween(nil, { ImageTransparency = 0, Size = UDim2New(0, 10, 0, 9) })
            else
                Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 1, Size = UDim2New(0, 0, 0, 0) })
                Items["CheckImage"]:Tween(nil, { ImageTransparency = 1, Size = UDim2New(0, 0, 0, 0) })
            end
            if Toggle.Callback then
                Library:SafeCall(Toggle.Callback, Toggle.Value)
            end
        end

        function Toggle:SetVisibility(Bool)
            Items["Toggle"].Instance.Visible = Bool
        end

        function Toggle:RefreshPosition(Bool)
            if Bool then
                Items["Indicator"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 0) })
                Items["Text"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 24, 0, 0) })
            else
                Items["Indicator"].Instance.Position = UDim2New(0, 60, 0, 0)
                Items["Text"].Instance.Position = UDim2New(0, 84, 0, 0)
            end
        end

        Items["Toggle"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Toggle:Set(not Toggle.Value)
            end
        end)

        Toggle:Set(Toggle.Default)
        Library.SetFlags[Toggle.Flag] = function(Value)
            Toggle:Set(Value)
        end

        Toggle.Section.Elements[#Toggle.Section.Elements + 1] = Toggle
        return Toggle
    end

    function Library.Sections.Button(self, Data)
        Data = Data or {}
        local Button = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Data.Name or Data.name or "Button",
            Icon = Data.Icon or Data.icon or nil,
            Callback = Data.Callback or Data.callback or function() end
        }

        local Items = {}
        Items["Button"] = Instances:Create("TextButton", {
            Parent = Button.Section.Items["Content"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Size = UDim2New(1, 0, 0, 32),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["Button"]:AddToTheme({ BackgroundColor3 = "Element" })

        Items["Accent"] = Instances:Create("Frame", {
            Parent = Items["Button"].Instance,
            Name = "\0",
            Size = UDim2New(0, 0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            BackgroundColor3 = FromRGB(255, 255, 255),
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0.5, 0, 0.5, 0)
        })
        Items["Gradient"] = Instances:Create("UIGradient", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            Enabled = true,
            Rotation = -115,
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
        })
        Items["Gradient"]:AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })
        Instances:Create("UICorner", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })
        Instances:Create("UICorner", {
            Parent = Items["Button"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Button"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = Button.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            AnchorPoint = Vector2New(0.5, 0.5),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(0.5, 0, 0.5, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Text"]:AddToTheme({ TextColor3 = "Text" })

        if Button.Icon then
            local btnIconUrl, btnIconOffset, btnIconSize = GetIcon(Button.Icon, 48)
            Items["Icon"] = Instances:Create("ImageLabel", {
                Parent = Items["Text"].Instance,
                Name = "\0",
                ImageColor3 = FromRGB(240, 240, 240),
                ImageTransparency = 0.3,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 18, 0, 18),
                AnchorPoint = Vector2New(1, 0.5),
                Image = btnIconUrl or "",
                BackgroundTransparency = 1,
                Position = UDim2New(0, -8, 0.5, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            if btnIconOffset then
                Items["Icon"].Instance.ImageRectOffset = btnIconOffset
                Items["Icon"].Instance.ImageRectSize = btnIconSize
            end
            Items["Icon"]:AddToTheme({ ImageColor3 = "Text" })
        end

        Items["Button"]:OnHover(function()
            Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 0 })
        end)
        Items["Button"]:OnHoverLeave(function()
            Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2New(0, 0, 0, 0), BackgroundTransparency = 1 })
        end)

        function Button:SetVisibility(Bool)
            Items["Button"].Instance.Visible = Bool
        end

        function Button:Press()
            Items["Button"]:ChangeItemTheme({ BackgroundColor3 = "Accent" })
            Items["Button"]:Tween(nil, { BackgroundColor3 = Library.Theme.Accent })
            Items["Text"]:Tween(nil, { TextColor3 = FromRGB(0, 0, 0), TextTransparency = 0 })
            if Button.Icon then
                Items["Icon"]:Tween(nil, { ImageColor3 = FromRGB(0, 0, 0), ImageTransparency = 0 })
            end
            task.wait(0.2)
            Library:SafeCall(Button.Callback)
            Items["Button"]:ChangeItemTheme({ BackgroundColor3 = "Element" })
            Items["Button"]:Tween(nil, { BackgroundColor3 = Library.Theme.Element })
            Items["Text"]:Tween(nil, { TextColor3 = Library.Theme.Text, TextTransparency = 0.3 })
            if Button.Icon then
                Items["Icon"]:Tween(nil, { ImageColor3 = Library.Theme.Text, ImageTransparency = 0.3 })
            end
        end

        Items["Button"]:Connect("MouseButton1Down", function()
            Button:Press()
        end)

        return Button
    end

    function Library.Sections.Slider(self, Data)
        Data = Data or {}
        local Slider = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Data.Name or Data.name or "Slider",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Min = Data.Min or Data.min or 0,
            Default = Data.Default or Data.default or 0,
            Max = Data.Max or Data.max or 100,
            Suffix = Data.Suffix or Data.suffix or "",
            Decimals = Data.Decimals or Data.decimals or 1,
            Callback = Data.Callback or Data.callback or function() end,
            Value = 0,
            Sliding = false
        }

        local Items = {}
        Items["Slider"] = Instances:Create("Frame", {
            Parent = Slider.Section.Items["Content"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 0, 35),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Slider"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = Slider.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Text"]:AddToTheme({ TextColor3 = "Text" })

        Items["RealSlider"] = Instances:Create("TextButton", {
            Parent = Items["Slider"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(0, 1),
            BorderSizePixel = 0,
            Position = UDim2New(0, 20, 1, -3),
            Size = UDim2New(1, -40, 0, 7),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["RealSlider"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["RealSlider"].Instance,
            Name = "\0"
        })

        Items["Accent"] = Instances:Create("Frame", {
            Parent = Items["RealSlider"].Instance,
            Name = "\0",
            Size = UDim2New(0.5, 0, 1, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["Accent"].Instance,
            Name = "\0"
        })

        local sliderIconUrl, sliderIconOffset, sliderIconSize = GetIcon("grip-horizontal", 48)
        Items["Icon"] = Instances:Create("ImageLabel", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 16, 0, 12),
            AnchorPoint = Vector2New(0.5, 0.5),
            Image = sliderIconUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(1, 5, 0.5, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if sliderIconOffset then
            Items["Icon"].Instance.ImageRectOffset = sliderIconOffset
            Items["Icon"].Instance.ImageRectSize = sliderIconSize
        end

        Instances:Create("UIGradient", {
            Parent = Items["Accent"].Instance,
            Name = "\0",
            Rotation = -102,
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(166, 166, 166)) }
        }):AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        Items["Plus"] = Instances:Create("TextButton", {
            Parent = Items["RealSlider"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = "+",
            BorderColor3 = FromRGB(0, 0, 0),
            AutoButtonColor = false,
            AnchorPoint = Vector2New(0, 0.5),
            Size = UDim2New(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Position = UDim2New(1, 0, 0.5, -3),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Plus"]:AddToTheme({ TextColor3 = "Text" })

        Items["Minus"] = Instances:Create("TextButton", {
            Parent = Items["RealSlider"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = "-",
            BorderColor3 = FromRGB(0, 0, 0),
            AutoButtonColor = false,
            AnchorPoint = Vector2New(1, 0.5),
            Size = UDim2New(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Position = UDim2New(0, -2, 0.5, -2),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Minus"]:AddToTheme({ TextColor3 = "Text" })

        Items["Value"] = Instances:Create("TextLabel", {
            Parent = Items["Slider"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = "50%",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            AnchorPoint = Vector2New(1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(1, 0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Value"]:AddToTheme({ TextColor3 = "Text" })

        Items["RealSlider"]:OnHover(function()
            Items["Icon"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2New(0, 18, 0, 14) })
        end)
        Items["RealSlider"]:OnHoverLeave(function()
            Items["Icon"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2New(0, 16, 0, 12) })
        end)

        Items["RealSlider"].Instance.Position = UDim2New(0, 80, 1, -3)
        Items["Text"].Instance.Position = UDim2New(0, 80, 0, 0)

        function Slider:Get()
            return Slider.Value
        end

        function Slider:SetVisibility(Bool)
            Items["Slider"].Instance.Visible = Bool
        end

        function Slider:RefreshPosition(Bool)
            if Bool then
                Items["RealSlider"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 20, 1, -3) })
                Items["Text"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 0) })
            else
                Items["RealSlider"].Instance.Position = UDim2New(0, 80, 1, -3)
                Items["Text"].Instance.Position = UDim2New(0, 80, 0, 0)
            end
        end

        function Slider:Set(Value)
            Slider.Value = Library:Round(MathClamp(Value, Slider.Min, Slider.Max), Slider.Decimals)
            Library.Flags[Slider.Flag] = Slider.Value
            Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2New((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0) })
            Items["Value"].Instance.Text = StringFormat("%s%s", Slider.Value, Slider.Suffix)
            if Slider.Value >= Slider.Max then
                Items["Icon"].Instance.Position = UDim2New(1, -5, 0.5, 0)
            else
                Items["Icon"].Instance.Position = UDim2New(1, 5, 0.5, 0)
            end
            if Slider.Callback then
                Library:SafeCall(Slider.Callback, Slider.Value)
            end
        end

        Items["Plus"]:Connect("MouseButton1Down", function()
            Slider:Set(Slider.Value + Slider.Decimals)
        end)
        Items["Minus"]:Connect("MouseButton1Down", function()
            Slider:Set(Slider.Value - Slider.Decimals)
        end)

        local InputChanged
        Items["RealSlider"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Slider.Sliding = true
                local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min
                Slider:Set(Value)
                if InputChanged then return end
                InputChanged = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Slider.Sliding = false
                        InputChanged:Disconnect()
                        InputChanged = nil
                    end
                end)
            end
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                if Slider.Sliding then
                    local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min
                    Slider:Set(Value)
                end
            end
        end)

        if Slider.Default then
            Slider:Set(Slider.Default)
        end

        Library.SetFlags[Slider.Flag] = function(Value)
            Slider:Set(Value)
        end

        Slider.Section.Elements[#Slider.Section.Elements + 1] = Slider
        return Slider
    end

    function Library.Sections.Dropdown(self, Data)
        Data = Data or {}
        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Data.Name or Data.name or "Dropdown",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Items = Data.Items or Data.items or { "One", "Two", "Three" },
            Default = Data.Default or Data.default or nil,
            Callback = Data.Callback or Data.callback or function() end,
            Size = Data.Size or Data.size or 125,
            OptionHolderSize = Data.OptionHolderSize or Data.optionholder or 125,
            Multi = Data.Multi or Data.multi or false,
            Value = {},
            Options = {},
            OptionsWithIndexes = {},
            IsOpen = false
        }

        local Items = {}
        Items["Dropdown"] = Instances:Create("Frame", {
            Parent = Dropdown.Section.Items["Content"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 0, 25),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Dropdown"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = Dropdown.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            AnchorPoint = Vector2New(0, 0.5),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 0, 0.5, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Text"]:AddToTheme({ TextColor3 = "Text" })

        Items["RealDropdown"] = Instances:Create("TextButton", {
            Parent = Items["Dropdown"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            Size = UDim2New(0, Dropdown.Size or 125, 0, 25),
            AutoButtonColor = false,
            AnchorPoint = Vector2New(1, 0),
            Position = UDim2New(1, 0, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["RealDropdown"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["RealDropdown"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 6)
        })

        Items["Value"] = Instances:Create("TextLabel", {
            Parent = Items["RealDropdown"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = "-",
            Size = UDim2New(1, -40, 0, 15),
            AnchorPoint = Vector2New(0, 0.5),
            BorderSizePixel = 0,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 10, 0.5, -1),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Value"]:AddToTheme({ TextColor3 = "Text" })

        Items["Liner"] = Instances:Create("Frame", {
            Parent = Items["RealDropdown"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(1, 0),
            Position = UDim2New(1, -25, 0, 0),
            Size = UDim2New(0, 2, 1, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(34, 32, 36)
        })
        Items["Liner"]:AddToTheme({ BackgroundColor3 = "Outline" })

        local arrowUrl, arrowOffset, arrowSize = GetIcon("chevron-down", 48)
        Items["ArrowIcon"] = Instances:Create("ImageLabel", {
            Parent = Items["RealDropdown"].Instance,
            Name = "\0",
            ImageColor3 = FromRGB(141, 141, 150),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 16, 0, 8),
            AnchorPoint = Vector2New(1, 0.5),
            Image = arrowUrl or "",
            BackgroundTransparency = 1,
            Position = UDim2New(1, -5, 0.5, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        if arrowOffset then
            Items["ArrowIcon"].Instance.ImageRectOffset = arrowOffset
            Items["ArrowIcon"].Instance.ImageRectSize = arrowSize
        end

        Items["OptionHolder"] = Instances:Create("TextButton", {
            Parent = Library.UnusedHolder.Instance,
            Text = "",
            AutoButtonColor = false,
            Name = "\0",
            Visible = false,
            Position = UDim2New(0, 897, 0, 101),
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0, 159, 0, 87),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })
        Items["OptionHolder"]:AddToTheme({ BackgroundColor3 = "Background" })

        Instances:Create("UIStroke", {
            Parent = Items["OptionHolder"].Instance,
            Name = "\0",
            Color = FromRGB(35, 33, 38),
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }):AddToTheme({ Color = "Outline" })

        Instances:Create("UICorner", {
            Parent = Items["OptionHolder"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 5)
        })

        Items["Holder"] = Instances:Create("ScrollingFrame", {
            Parent = Items["OptionHolder"].Instance,
            Name = "\0",
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            Size = UDim2New(1, -16, 1, -16),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 8, 0, 8),
            BackgroundColor3 = FromRGB(255, 255, 255),
            BorderColor3 = FromRGB(0, 0, 0),
            BorderSizePixel = 0,
            CanvasSize = UDim2New(0, 0, 0, 0)
        })
        Items["Holder"]:AddToTheme({ ScrollBarImageColor3 = "Accent" })

        Instances:Create("UIListLayout", {
            Parent = Items["Holder"].Instance,
            Name = "\0",
            Padding = UDimNew(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Items["Text"].Instance.Position = UDim2New(0, 30, 0.5, 0)
        Items["RealDropdown"].Instance.Position = UDim2New(1, 30, 0, 0)

        function Dropdown:Get()
            return Dropdown.Value
        end

        function Dropdown:SetVisibility(Bool)
            Items["Dropdown"].Instance.Visible = Bool
        end

        function Dropdown:RefreshPosition(Bool)
            if Bool then
                Items["Text"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0.5, 0) })
                Items["RealDropdown"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(1, 0, 0, 0) })
            else
                Items["Text"].Instance.Position = UDim2New(0, 30, 0.5, 0)
                Items["RealDropdown"].Instance.Position = UDim2New(1, 30, 0, 0)
            end
        end

        local RenderStepped
        local Debounce = false
        function Dropdown:SetOpen(Bool)
            if Debounce then return end
            Dropdown.IsOpen = Bool
            Debounce = true
            if Dropdown.IsOpen then
                Items["OptionHolder"].Instance.Visible = true
                Items["OptionHolder"].Instance.Parent = Library.Holder.Instance
                Items["ArrowIcon"]:Tween(nil, { Rotation = 180, ImageColor3 = FromRGB(255, 255, 255) })
                Library:Thread(function()
                    for _, Value in Dropdown.OptionsWithIndexes do
                        task.spawn(function()
                            Value:RefreshPosition(true)
                        end)
                        task.wait(0.05)
                    end
                end)
                RenderStepped = RunService.RenderStepped:Connect(function()
                    Items["OptionHolder"].Instance.Position = UDim2New(0, Items["RealDropdown"].Instance.AbsolutePosition.X, 0, Items["RealDropdown"].Instance.AbsolutePosition.Y + Items["RealDropdown"].Instance.AbsoluteSize.Y + 5)
                    Items["OptionHolder"].Instance.Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, Dropdown.OptionHolderSize)
                end)
                for _, Value in Library.OpenFrames do
                    if Value ~= Dropdown and not Dropdown.Section.IsSettings then
                        Value:SetOpen(false)
                    end
                end
                Library.OpenFrames[Dropdown] = Dropdown
            else
                if not Dropdown.IsOpen then
                    for _, Value in Dropdown.OptionsWithIndexes do
                        task.spawn(function()
                            Value:RefreshPosition(false)
                        end)
                    end
                end
                if Library.OpenFrames[Dropdown] then
                    Library.OpenFrames[Dropdown] = nil
                end
                if RenderStepped then
                    RenderStepped:Disconnect()
                    RenderStepped = nil
                end
                Items["ArrowIcon"]:Tween(nil, { Rotation = 0, ImageColor3 = FromRGB(141, 141, 150) })
            end
            local Descendants = Items["OptionHolder"].Instance:GetDescendants()
            TableInsert(Descendants, Items["OptionHolder"].Instance)
            local NewTween
            for _, Value in Descendants do
                local TransparencyProperty = Tween:GetProperty(Value)
                if not TransparencyProperty then continue end
                if not Value.ClassName:find("UI") then
                    Value.ZIndex = (Dropdown.IsOpen and Dropdown.Section.IsSettings and 8) or (Dropdown.IsOpen and 3) or 1
                end
                if type(TransparencyProperty) == "table" then
                    for _, Property in TransparencyProperty do
                        NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                end
            end
            NewTween.Tween.Completed:Connect(function()
                Debounce = false
                Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                task.wait(0.2)
                Items["OptionHolder"].Instance.Parent = not Dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
            end)
        end

        function Dropdown:Set(Option)
            if Dropdown.Multi then
                if type(Option) ~= "table" then return end
                Dropdown.Value = Option
                Library.Flags[Dropdown.Flag] = Option
                for _, Value in Option do
                    local OptionData = Dropdown.Options[Value]
                    if not OptionData then continue end
                    OptionData.Selected = true
                    OptionData:Toggle("Active")
                end
                Items["Value"].Instance.Text = TableConcat(Option, ", ")
            else
                if not Dropdown.Options[Option] then return end
                local OptionData = Dropdown.Options[Option]
                Dropdown.Value = Option
                Library.Flags[Dropdown.Flag] = Option
                for _, Value in Dropdown.Options do
                    if Value ~= OptionData then
                        Value.Selected = false
                        Value:Toggle("Inactive")
                    else
                        Value.Selected = true
                        Value:Toggle("Active")
                    end
                end
                Items["Value"].Instance.Text = Option
            end
            if Dropdown.Callback then
                Library:SafeCall(Dropdown.Callback, Dropdown.Value)
            end
        end

        function Dropdown:Add(Option)
            local OptionButton = Instances:Create("TextButton", {
                Parent = Items["Holder"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 0, 20),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local OptionAccent = Instances:Create("Frame", {
                Parent = OptionButton.Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0.5, 0),
                Size = UDim2New(0, 6, 0, 6),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            Instances:Create("UIGradient", {
                Parent = OptionAccent.Instance,
                Name = "\0",
                Enabled = true,
                Rotation = -115,
                Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
            }):AddToTheme({
                Color = function()
                    return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
                end
            })
            Instances:Create("UICorner", {
                Parent = OptionAccent.Instance,
                Name = "\0"
            })

            local OptionText = Instances:Create("TextLabel", {
                Parent = OptionAccent.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(255, 255, 255),
                TextTransparency = 0.3,
                Text = Option,
                Size = UDim2New(0, 0, 0, 15),
                AnchorPoint = Vector2New(0, 0.5),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 30, 0.5, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            OptionText:AddToTheme({ TextColor3 = "Text" })

            local OptionData = {
                Button = OptionButton,
                Name = Option,
                OptionText = OptionText,
                OptionAccent = OptionAccent,
                Selected = false
            }

            function OptionData:Toggle(Value)
                if Value == "Active" then
                    OptionText:Tween(nil, { TextTransparency = 0, Position = UDim2New(0, 15, 0.5, 0) })
                    OptionAccent:Tween(nil, { BackgroundTransparency = 0 })
                else
                    OptionText:Tween(nil, { TextTransparency = 0.3, Position = UDim2New(0, 0, 0.5, 0) })
                    OptionAccent:Tween(nil, { BackgroundTransparency = 1 })
                end
            end

            function OptionData:RefreshPosition(Bool)
                if Bool then
                    if OptionData.Selected then
                        OptionAccent:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0.5, 0) })
                        OptionText:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 15, 0.5, 0) })
                    else
                        OptionText:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0.5, 0) })
                    end
                else
                    if OptionData.Selected then
                        OptionAccent.Instance.Position = UDim2New(0, 30, 0.5, 0)
                        OptionText.Instance.Position = UDim2New(0, 45, 0.5, 0)
                    else
                        OptionText.Instance.Position = UDim2New(0, 30, 0.5, 0)
                    end
                end
            end

            function OptionData:Set()
                OptionData.Selected = not OptionData.Selected
                if Dropdown.Multi then
                    local Index = TableFind(Dropdown.Value, OptionData.Name)
                    if Index then
                        TableRemove(Dropdown.Value, Index)
                    else
                        TableInsert(Dropdown.Value, OptionData.Name)
                    end
                    OptionData:Toggle(Index and "Inactive" or "Active")
                    Library.Flags[Dropdown.Flag] = Dropdown.Value
                    local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "..."
                    Items["Value"].Instance.Text = TextFormat
                else
                    if OptionData.Selected then
                        Dropdown.Value = OptionData.Name
                        Library.Flags[Dropdown.Flag] = OptionData.Name
                        OptionData.Selected = true
                        OptionData:Toggle("Active")
                        for _, Value in Dropdown.Options do
                            if Value ~= OptionData then
                                Value.Selected = false
                                Value:Toggle("Inactive")
                            end
                        end
                        Items["Value"].Instance.Text = OptionData.Name
                    else
                        Dropdown.Value = nil
                        Library.Flags[Dropdown.Flag] = nil
                        OptionData.Selected = false
                        OptionData:Toggle("Inactive")
                        Items["Value"].Instance.Text = "..."
                    end
                end
                if Dropdown.Callback then
                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end
            end

            OptionData.Button:Connect("MouseButton1Down", function()
                OptionData:Set()
            end)

            Dropdown.Options[OptionData.Name] = OptionData
            Dropdown.OptionsWithIndexes[#Dropdown.OptionsWithIndexes + 1] = OptionData
            OptionData:RefreshPosition(false)

            return OptionData
        end

        function Dropdown:Remove(Option)
            if Dropdown.Options[Option] then
                Dropdown.Options[Option].Button:Clean()
                Dropdown.Options[Option] = nil
            end
        end

        function Dropdown:Refresh(List)
            for _, Value in Dropdown.Options do
                Dropdown:Remove(Value.Name)
            end
            for _, Value in List do
                Dropdown:Add(Value)
            end
        end

        Items["RealDropdown"]:Connect("MouseButton1Down", function()
            Dropdown:SetOpen(not Dropdown.IsOpen)
        end)

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if Dropdown.IsOpen then
                    if Library:IsMouseOverFrame(Items["OptionHolder"]) then
                        return
                    end
                    Dropdown:SetOpen(false)
                end
            end
        end)

        Items["RealDropdown"]:Connect("Changed", function(Property)
            if Property == "AbsolutePosition" and Dropdown.IsOpen then
                Dropdown.IsOpen = not Library:IsClipped(Items["OptionHolder"].Instance, Dropdown.Section.Items["Section"].Instance.Parent)
                Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
            end
        end)

        for _, Value in Dropdown.Items do
            Dropdown:Add(Value)
        end

        if Dropdown.Default then
            Dropdown:Set(Dropdown.Default)
        end

        Library.SetFlags[Dropdown.Flag] = function(Value)
            Dropdown:Set(Value)
        end

        Dropdown.Section.Elements[#Dropdown.Section.Elements + 1] = Dropdown
        return Dropdown
    end

    function Library.Sections.Label(self, Name)
        local Label = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Name or "Label"
        }

        local Items = {}
        Items["Label"] = Instances:Create("Frame", {
            Parent = Label.Section.Items["Content"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 0, 20),
            BorderColor3 = FromRGB(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Label"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = Label.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 30, 0, 5),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Text"]:AddToTheme({ TextColor3 = "Text" })

        function Label:SetText(Text)
            Text = tostring(Text)
            Items["Text"].Instance.Text = Text
        end

        function Label:SetVisibility(Bool)
            Items["Label"].Instance.Visible = Bool
        end

        function Label:RefreshPosition(Bool)
            if Bool then
                Items["Text"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 5) })
                if Items["SubElements"] then
                    Items["SubElements"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 30) })
                    local paletteIcon = Items["Label"].Instance:FindFirstChild("palette_icon")
                    if paletteIcon then
                        Tween:Create(paletteIcon, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(1, -16, 1, -6) }, true)
                    end
                end
            else
                Items["Text"].Instance.Position = UDim2New(0, 30, 0, 5)
                if Items["SubElements"] then
                    Items["SubElements"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 30, 0, 30) })
                    local paletteIcon = Items["Label"].Instance:FindFirstChild("palette_icon")
                    if paletteIcon then
                        Tween:Create(paletteIcon, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(1, 30, 1, -6) }, true)
                    end
                end
            end
        end

        function Label:Colorpicker(Data)
            Data = Data or {}
            local Colorpicker = {
                Window = Label.Window,
                Page = Label.Page,
                Section = Label.Section,
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                Callback = Data.Callback or Data.callback or function() end,
                Alpha = Data.Alpha or Data.alpha or false
            }
            if not Items["SubElements"] then
                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    Size = UDim2New(1, 0, 0, 30),
                    Position = UDim2New(0, 0, 0, 30),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })
                Items["SubElements"]:AddToTheme({ BackgroundColor3 = "Element" })
                Instances:Create("UICorner", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                Instances:Create("UIPadding", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 6)
                })
            end
            local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                Parent = Items["SubElements"],
                Page = Colorpicker.Page,
                Section = Colorpicker.Section,
                Flag = Colorpicker.Flag,
                Default = Colorpicker.Default,
                Callback = Colorpicker.Callback,
                Parent2 = Items["Label"],
                Alpha = Colorpicker.Alpha
            })
            return NewColorpicker
        end

        Label.Section.Elements[#Label.Section.Elements + 1] = Label
        return Label
    end

    function Library.Sections.Keybind(self, Data)
        Data = Data or {}
        local Keybind = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Data.Name or Data.name or "Keybind",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Default = Data.Default or Data.default or Enum.KeyCode.RightShift,
            Callback = Data.Callback or Data.callback or function() end,
            Mode = Data.Mode or Data.mode or Enum.KeyCode.RightShift,
            Value = "",
            ModeSelected = "Toggle",
            Toggled = false,
            Picking = false,
            SyncToggleState = Data.SyncToggleState or false,
            ParentToggle = Data.ParentToggle or nil,
            ChangedCallback = Data.ChangedCallback or nil,
            NoUI = Data.NoUI or false,
        }

        local Items = {}
        Items["Label"] = Instances:Create("Frame", {
            Parent = Keybind.Section.Items["Content"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 0, 20),
            BorderColor3 = FromRGB(0, 0, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })

        Items["SubElements"] = Instances:Create("Frame", {
            Parent = Items["Label"].Instance,
            Name = "\0",
            Size = UDim2New(1, 0, 0, 30),
            Position = UDim2New(0, 0, 0, 30),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["SubElements"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["SubElements"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 5)
        })
        Instances:Create("UIListLayout", {
            Parent = Items["SubElements"].Instance,
            Name = "\0",
            VerticalAlignment = Enum.VerticalAlignment.Center,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDimNew(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Instances:Create("UIPadding", {
            Parent = Items["SubElements"].Instance,
            Name = "\0",
            PaddingLeft = UDimNew(0, 6)
        })

        Items["KeyButton"] = Instances:Create("TextButton", {
            Parent = Items["SubElements"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = "MouseButton2",
            AutoButtonColor = false,
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            SelectionOrder = 2,
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["KeyButton"]:AddToTheme({ TextColor3 = "Text" })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Label"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.3,
            Text = Keybind.Name,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2New(0, 0, 0, 15),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 0, 0, 5),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Text"]:AddToTheme({ TextColor3 = "Text" })

        Items["Modes"] = Instances:Create("Frame", {
            Parent = Items["Label"].Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(1, 0),
            Position = UDim2New(1, 0, 0, 0),
            Size = UDim2New(0, 200, 0, 25),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["Modes"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["Modes"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 5)
        })

        Items["Background"] = Instances:Create("Frame", {
            Parent = Items["Modes"].Instance,
            Name = "\0",
            Size = UDim2New(0.35, 0, 1, 0),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundTransparency = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Instances:Create("UICorner", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 5)
        })
        Instances:Create("UIGradient", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            Rotation = -115,
            Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(166, 166, 166)) }
        }):AddToTheme({
            Color = function()
                return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
            end
        })

        Items["Toggle"] = Instances:Create("TextButton", {
            Parent = Items["Modes"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(0, 0, 0),
            TextTransparency = 0.3,
            Text = "Toggle",
            AutoButtonColor = false,
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(0.35, 0, 1, 0),
            BackgroundTransparency = 1,
            Position = UDim2New(0, 0, 0, -1),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Toggle"]:AddToTheme({
            TextColor3 = function()
                return Library.Theme.Text
            end
        })

        Items["Hold"] = Instances:Create("TextButton", {
            Parent = Items["Modes"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.2,
            Text = "Hold",
            BorderColor3 = FromRGB(0, 0, 0),
            AutoButtonColor = false,
            AnchorPoint = Vector2New(0, 0),
            Size = UDim2New(0.35, 0, 1, 0),
            BackgroundTransparency = 1,
            Position = UDim2New(0.35, 0, 0, -1),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Hold"]:AddToTheme({
            TextColor3 = function()
                return Library.Theme.Text
            end
        })

        Items["Always"] = Instances:Create("TextButton", {
            Parent = Items["Modes"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            TextTransparency = 0.2,
            Text = "Always",
            BorderColor3 = FromRGB(0, 0, 0),
            AutoButtonColor = false,
            AnchorPoint = Vector2New(0, 0),
            Size = UDim2New(0.4, 0, 1, 0),
            BackgroundTransparency = 1,
            Position = UDim2New(0.7, -12, 0, -1),
            BorderSizePixel = 0,
            ZIndex = 2,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Always"]:AddToTheme({
            TextColor3 = function()
                return Library.Theme.Text
            end
        })

        local KeyListItem
        if Library.KeyList and not Keybind.NoUI then
            KeyListItem = Library.KeyList:Add("", "")
        end

        local Update = function()
            if KeyListItem then
                KeyListItem:Set(Keybind.Name, Keybind.Value)
                KeyListItem:SetStatus(Keybind.Toggled)
            end
        end

        function Keybind:RefreshPosition(Bool)
            if Bool then
                Items["Text"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 5) })
                Items["SubElements"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 30) })
                Items["Modes"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(1, 0, 0, 0) })
            else
                Items["Text"].Instance.Position = UDim2New(0, 30, 0, 5)
                Items["SubElements"].Instance.Position = UDim2New(0, 30, 0, 30)
                Items["Modes"].Instance.Position = UDim2New(1, 30, 0, 0)
            end
        end

        function Keybind:SetMode(Mode)
            Keybind.ModeSelected = Mode
            if Mode == "Toggle" then
                Items["Background"]:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 0), Size = UDim2New(0.35, 0, 1, 0) })
                Items["Toggle"]:ChangeItemTheme({ TextColor3 = function() return FromRGB(0, 0, 0) end })
                Items["Toggle"]:Tween(nil, { TextColor3 = FromRGB(0, 0, 0) })
                Items["Hold"]:ChangeItemTheme({ TextColor3 = function() return Library.Theme.Text end })
                Items["Hold"]:Tween(nil, { TextColor3 = Library.Theme.Text })
                Items["Always"]:ChangeItemTheme({ TextColor3 = function() return Library.Theme.Text end })
                Items["Always"]:Tween(nil, { TextColor3 = Library.Theme.Text })
            elseif Mode == "Hold" then
                Items["Background"]:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(0.35, 0, 0, 0), Size = UDim2New(0.35, 0, 1, 0) })
                Items["Toggle"]:ChangeItemTheme({ TextColor3 = function() return Library.Theme.Text end })
                Items["Toggle"]:Tween(nil, { TextColor3 = Library.Theme.Text })
                Items["Hold"]:ChangeItemTheme({ TextColor3 = function() return FromRGB(0, 0, 0) end })
                Items["Hold"]:Tween(nil, { TextColor3 = FromRGB(0, 0, 0) })
                Items["Always"]:ChangeItemTheme({ TextColor3 = function() return Library.Theme.Text end })
                Items["Always"]:Tween(nil, { TextColor3 = Library.Theme.Text })
            elseif Mode == "Always" then
                Items["Background"]:Tween(TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2New(0.7, 0, 0, 0), Size = UDim2New(0.3, 0, 1, 0) })
                Items["Toggle"]:ChangeItemTheme({ TextColor3 = function() return Library.Theme.Text end })
                Items["Toggle"]:Tween(nil, { TextColor3 = Library.Theme.Text })
                Items["Hold"]:ChangeItemTheme({ TextColor3 = function() return Library.Theme.Text end })
                Items["Hold"]:Tween(nil, { TextColor3 = Library.Theme.Text })
                Items["Always"]:ChangeItemTheme({ TextColor3 = function() return FromRGB(0, 0, 0) end })
                Items["Always"]:Tween(nil, { TextColor3 = FromRGB(0, 0, 0) })
            end
            Library.Flags[Keybind.Flag] = {
                Mode = Keybind.ModeSelected,
                Key = Keybind.Key,
                Toggled = Keybind.Toggled
            }
            if Keybind.ChangedCallback then
                Library:SafeCall(Keybind.ChangedCallback, Keybind.Key, Keybind.ModeSelected)
            end
        end

        function Keybind:Press(Bool)
            if Keybind.ModeSelected == "Toggle" then
                Keybind.Toggled = not Keybind.Toggled
            elseif Keybind.ModeSelected == "Hold" then
                Keybind.Toggled = Bool
            elseif Keybind.ModeSelected == "Always" then
                Keybind.Toggled = true
            end
            if Keybind.SyncToggleState and Keybind.ParentToggle then
                Keybind.ParentToggle:Set(Keybind.Toggled)
            end
            Library.Flags[Keybind.Flag] = {
                Mode = Keybind.ModeSelected,
                Key = Keybind.Key,
                Toggled = Keybind.Toggled
            }
            if Keybind.Callback then
                Library:SafeCall(Keybind.Callback, Keybind.Toggled)
            end
            Update()
        end

        function Keybind:Get()
            return Keybind.Key, Keybind.ModeSelected, Keybind.Toggled
        end

        function Keybind:Set(Key)
            if type(Key) == "table" then
                if Key.Mode then
                    Keybind:SetMode(Key.Mode)
                end
                local realKey = Key.Key == "Backspace" and "None" or Key.Key
                Keybind.Key = tostring(Key.Key)
                Keybind.Value = realKey or "None"
                Items["KeyButton"].Instance.Text = Keybind.Value
            elseif type(Key) == "string" or type(Key) == "EnumItem" then
                if type(Key) == "EnumItem" then
                    Keybind.Key = tostring(Key)
                    Keybind.Value = Key.Name == "Backspace" and "None" or Key.Name
                else
                    Keybind.Key = Key
                    Keybind.Value = Key
                end
                Items["KeyButton"].Instance.Text = Keybind.Value
            end
            Library.Flags[Keybind.Flag] = {
                Mode = Keybind.ModeSelected,
                Key = Keybind.Key,
                Toggled = Keybind.Toggled
            }
            if Keybind.ChangedCallback then
                Library:SafeCall(Keybind.ChangedCallback, Keybind.Key, Keybind.ModeSelected)
            end
            Update()
            Keybind.Picking = false
        end

        Items["KeyButton"]:Connect("MouseButton1Click", function()
            Keybind.Picking = true
            Items["KeyButton"].Instance.Text = "."
            Library:Thread(function()
                local Count = 1
                while true do
                    if not Keybind.Picking then break end
                    if Count == 4 then Count = 1 end
                    Items["KeyButton"].Instance.Text = Count == 1 and "." or Count == 2 and ".." or Count == 3 and "..."
                    Count += 1
                    task.wait(0.35)
                end
            end)
            local InputBegan
            InputBegan = UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    Keybind:Set(Input.KeyCode)
                else
                    Keybind:Set(Input.UserInputType)
                end
                InputBegan:Disconnect()
                InputBegan = nil
            end)
        end)

        Library:Connect(UserInputService.InputBegan, function(Input)
            if Keybind.Value == "None" then return end
            if tostring(Input.KeyCode) == Keybind.Key then
                if Keybind.ModeSelected == "Toggle" then
                    Keybind:Press()
                elseif Keybind.ModeSelected == "Hold" then
                    Keybind:Press(true)
                elseif Keybind.ModeSelected == "Always" then
                    Keybind:Press(true)
                end
            elseif tostring(Input.UserInputType) == Keybind.Key then
                if Keybind.ModeSelected == "Toggle" then
                    Keybind:Press()
                elseif Keybind.ModeSelected == "Hold" then
                    Keybind:Press(true)
                elseif Keybind.ModeSelected == "Always" then
                    Keybind:Press(true)
                end
            end
        end)

        Library:Connect(UserInputService.InputEnded, function(Input)
            if Keybind.Value == "None" then return end
            if tostring(Input.KeyCode) == Keybind.Key then
                if Keybind.ModeSelected == "Hold" then
                    Keybind:Press(false)
                elseif Keybind.ModeSelected == "Always" then
                    Keybind:Press(true)
                end
            elseif tostring(Input.UserInputType) == Keybind.Key then
                if Keybind.ModeSelected == "Hold" then
                    Keybind:Press(false)
                elseif Keybind.ModeSelected == "Always" then
                    Keybind:Press(true)
                end
            end
        end)

        Items["Toggle"]:Connect("MouseButton1Down", function()
            Keybind:SetMode("Toggle")
        end)
        Items["Hold"]:Connect("MouseButton1Down", function()
            Keybind:SetMode("Hold")
        end)
        Items["Always"]:Connect("MouseButton1Down", function()
            Keybind:SetMode("Always")
        end)

        if Keybind.Default then
            Keybind:Set({
                Mode = Keybind.Mode or "Toggle",
                Key = Keybind.Default,
            })
        end

        Library.SetFlags[Keybind.Flag] = function(Value)
            Keybind:Set(Value)
        end

        Keybind.Section.Elements[#Keybind.Section.Elements + 1] = Keybind
        return Keybind
    end

    function Library.Sections.Textbox(self, Data)
        Data = Data or {}
        local Textbox = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Default = Data.Default or Data.default or "",
            Callback = Data.Callback or Data.callback or function() end,
            Placeholder = Data.Placeholder or Data.placeholder or "Placeholder",
            Numeric = Data.Numeric or Data.numeric or false,
            Finished = Data.Finished or Data.finished or false,
            Value = ""
        }

        local Items = {}
        Items["Textbox"] = Instances:Create("Frame", {
            Parent = Textbox.Section.Items["Content"].Instance,
            Name = "\0",
            Active = true,
            BorderColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Selectable = true,
            Size = UDim2New(1, 0, 0, 32),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Instances:Create("UICorner", {
            Parent = Items["Textbox"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Background"] = Instances:Create("Frame", {
            Parent = Items["Textbox"].Instance,
            Name = "\0",
            Active = true,
            BorderColor3 = FromRGB(0, 0, 0),
            Size = UDim2New(1, 0, 1, 0),
            Selectable = true,
            ZIndex = 2,
            ClipsDescendants = true,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["Background"]:AddToTheme({ BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 4)
        })

        Items["Input"] = Instances:Create("TextBox", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            ZIndex = 2,
            Size = UDim2New(1, -20, 0, 15),
            Position = UDim2New(0, 10, 0, 8),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            PlaceholderColor3 = FromRGB(185, 185, 185),
            TextXAlignment = Enum.TextXAlignment.Left,
            PlaceholderText = Textbox.Placeholder,
            TextSize = 14,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })
        Items["Input"]:AddToTheme({ TextColor3 = "Text" })

        function Textbox:Get()
            return Textbox.Value
        end

        function Textbox:SetVisibility(Bool)
            Items["Textbox"].Instance.Visible = Bool
        end

        function Textbox:RefreshPosition(Bool)
            if Bool then
                Items["Background"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 0) })
            else
                Items["Background"].Instance.Position = UDim2New(0, 30, 0, 0)
            end
        end

        function Textbox:Set(Value)
            if Textbox.Numeric then
                if (not tonumber(Value)) and StringLen(tostring(Value)) > 0 then
                    Value = Textbox.Value
                end
            end
            Textbox.Value = Value
            Items["Input"].Instance.Text = Value
            Library.Flags[Textbox.Flag] = Value
            if Textbox.Callback then
                Library:SafeCall(Textbox.Callback, Value)
            end
        end

        if Textbox.Finished then
            Items["Input"]:Connect("FocusLost", function(PressedEnterQuestionMark)
                if PressedEnterQuestionMark then
                    Textbox:Set(Items["Input"].Instance.Text)
                end
            end)
        else
            Library:Connect(Items["Input"].Instance:GetPropertyChangedSignal("Text"), function()
                Textbox:Set(Items["Input"].Instance.Text)
            end)
        end

        if Textbox.Default then
            Textbox:Set(Textbox.Default)
        end

        Library.SetFlags[Textbox.Flag] = function(Value)
            Textbox:Set(Value)
        end

        Textbox.Section.Elements[#Textbox.Section.Elements + 1] = Textbox
        return Textbox
    end

    function Library.Sections.Listbox(self, Data)
        Data = Data or {}
        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Items = Data.Items or Data.items or { "One", "Two", "Three" },
            Default = Data.Default or Data.default or nil,
            Callback = Data.Callback or Data.callback or function() end,
            Size = Data.Size or Data.size or 125,
            Multi = Data.Multi or Data.multi or false,
            Value = {},
            Options = {},
            IsOpen = false
        }

        local Items = {}
        Items["Listbox"] = Instances:Create("Frame", {
            Parent = Dropdown.Section.Items["Content"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 0, Dropdown.Size),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255)
        })

        Items["Search"] = Instances:Create("TextBox", {
            Parent = Items["Listbox"].Instance,
            Name = "\0",
            FontFace = Library.Font,
            CursorPosition = -1,
            TextColor3 = FromRGB(240, 240, 240),
            BorderColor3 = FromRGB(0, 0, 0),
            Text = "",
            ZIndex = 2,
            Size = UDim2New(1, 0, 0, 30),
            BorderSizePixel = 0,
            PlaceholderColor3 = FromRGB(185, 185, 185),
            TextXAlignment = Enum.TextXAlignment.Left,
            PlaceholderText = "Search..",
            TextSize = 14,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["Search"]:AddToTheme({ TextColor3 = "Text", BackgroundColor3 = "Element" })
        Instances:Create("UICorner", {
            Parent = Items["Search"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 6)
        })
        Instances:Create("UIPadding", {
            Parent = Items["Search"].Instance,
            Name = "\0",
            PaddingTop = UDimNew(0, 4),
            PaddingLeft = UDimNew(0, 8)
        })

        Items["Background"] = Instances:Create("Frame", {
            Parent = Items["Listbox"].Instance,
            Name = "\0",
            Active = true,
            Size = UDim2New(1, 0, 1, -30),
            BorderColor3 = FromRGB(0, 0, 0),
            Position = UDim2New(0, 0, 0, 30),
            BackgroundColor3 = FromRGB(27, 26, 29),
            ZIndex = 2,
            BorderSizePixel = 0,
        })
        Items["Background"]:AddToTheme({ BackgroundColor3 = "Element" })

        Items["Holder"] = Instances:Create("ScrollingFrame", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            ScrollBarImageColor3 = FromRGB(0, 0, 0),
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            Size = UDim2New(1, -4, 1, -8),
            BorderColor3 = FromRGB(0, 0, 0),
            Position = UDim2New(0, 0, 0, 4),
            BackgroundColor3 = FromRGB(27, 26, 29),
            ZIndex = 2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2New(0, 0, 0, 0)
        })
        Items["Holder"]:AddToTheme({ ScrollBarImageColor3 = "Accent" })

        Instances:Create("UICorner", {
            Parent = Items["Background"].Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 6)
        })
        Instances:Create("UIListLayout", {
            Parent = Items["Holder"].Instance,
            Name = "\0",
            Padding = UDimNew(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Instances:Create("UIPadding", {
            Parent = Items["Holder"].Instance,
            Name = "\0",
            PaddingTop = UDimNew(0, 8),
            PaddingBottom = UDimNew(0, 8),
            PaddingRight = UDimNew(0, 12),
            PaddingLeft = UDimNew(0, 8)
        })

        Items["_"] = Instances:Create("Frame", {
            Parent = Items["Listbox"].Instance,
            Name = "\0",
            Size = UDim2New(1, 0, 0, 10),
            Position = UDim2New(0, 0, 0, 25),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 26, 29)
        })
        Items["_"]:AddToTheme({ BackgroundColor3 = "Element" })

        Instances:Create("Frame", {
            Parent = Items["_"].Instance,
            Name = "\0",
            Size = UDim2New(1, 0, 0, 1),
            Position = UDim2New(0, 0, 1, -3),
            AnchorPoint = Vector2New(0, 1),
            BorderColor3 = FromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 26, 29),
        }):AddToTheme({ BackgroundColor3 = "Outline" })

        function Dropdown:Get()
            return Dropdown.Value
        end

        function Dropdown:SetVisibility(Bool)
            Items["Listbox"].Instance.Visible = Bool
        end

        function Dropdown:RefreshPosition(Bool)
            if Bool then
                Items["Background"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 30) })
                Items["Search"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 0) })
                Items["_"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2New(0, 0, 0, 25) })
            else
                Items["Background"].Instance.Position = UDim2New(0, 30, 0, 30)
                Items["Search"].Instance.Position = UDim2New(0, 30, 0, 0)
                Items["_"].Instance.Position = UDim2New(0, 30, 0, 25)
            end
        end

        function Dropdown:Set(Option)
            if Dropdown.Multi then
                if type(Option) ~= "table" then return end
                Dropdown.Value = Option
                Library.Flags[Dropdown.Flag] = Option
                for _, Value in Option do
                    local OptionData = Dropdown.Options[Value]
                    if not OptionData then continue end
                    OptionData.Selected = true
                    OptionData:Toggle("Active")
                end
            else
                if not Dropdown.Options[Option] then return end
                local OptionData = Dropdown.Options[Option]
                Dropdown.Value = Option
                Library.Flags[Dropdown.Flag] = Option
                for _, Value in Dropdown.Options do
                    if Value ~= OptionData then
                        Value.Selected = false
                        Value:Toggle("Inactive")
                    else
                        Value.Selected = true
                        Value:Toggle("Active")
                    end
                end
            end
            if Dropdown.Callback then
                Library:SafeCall(Dropdown.Callback, Dropdown.Value)
            end
        end

        function Dropdown:Add(Option)
            local OptionButton = Instances:Create("TextButton", {
                Parent = Items["Holder"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 0, 20),
                BorderSizePixel = 0,
                ZIndex = 2,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local OptionAccent = Instances:Create("Frame", {
                Parent = OptionButton.Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0, 0.5),
                BackgroundTransparency = 1,
                ZIndex = 2,
                Position = UDim2New(0, 0, 0.5, 0),
                Size = UDim2New(0, 6, 0, 6),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            Instances:Create("UIGradient", {
                Parent = OptionAccent.Instance,
                Name = "\0",
                Enabled = true,
                Rotation = -115,
                Color = RGBSequence { RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143)) }
            }):AddToTheme({
                Color = function()
                    return RGBSequence { RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient) }
                end
            })
            Instances:Create("UICorner", {
                Parent = OptionAccent.Instance,
                Name = "\0"
            })

            local OptionText = Instances:Create("TextLabel", {
                Parent = OptionButton.Instance,
                Name = "\0",
                FontFace = Library.Font,
                TextColor3 = FromRGB(255, 255, 255),
                TextTransparency = 0.3,
                Text = Option,
                Size = UDim2New(0, 0, 0, 15),
                AnchorPoint = Vector2New(0, 0.5),
                BorderSizePixel = 0,
                ZIndex = 2,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0.5, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })
            OptionText:AddToTheme({ TextColor3 = "Text" })

            local OptionData = {
                Button = OptionButton,
                Name = Option,
                OptionText = OptionText,
                IsSearching = false,
                OptionAccent = OptionAccent,
                Selected = false
            }

            function OptionData:Toggle(Value)
                if Value == "Active" then
                    OptionText:Tween(nil, { TextTransparency = 0, Position = UDim2New(0, 15, 0.5, 0) })
                    OptionAccent:Tween(nil, { BackgroundTransparency = 0 })
                else
                    OptionText:Tween(nil, { TextTransparency = 0.3, Position = UDim2New(0, 0, 0.5, 0) })
                    OptionAccent:Tween(nil, { BackgroundTransparency = 1 })
                end
            end

            function OptionData:Search(Bool)
                Library:Thread(function()
                    if Bool then
                        OptionData.IsSearching = true
                        OptionText:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 1 })
                        task.wait(0.08)
                        OptionButton:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2New(1, 0, 0, 0) })
                        if OptionData.Selected then
                            OptionAccent:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
                        end
                    else
                        OptionData.IsSearching = false
                        OptionText:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = OptionData.Selected and 0 or 0.3 })
                        task.wait(0.08)
                        OptionButton:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2New(1, 0, 0, 20) })
                        if OptionData.Selected then
                            OptionAccent:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
                        end
                    end
                end)
            end

            function OptionData:Set()
                OptionData.Selected = not OptionData.Selected
                if Dropdown.Multi then
                    local Index = TableFind(Dropdown.Value, OptionData.Name)
                    if Index then
                        TableRemove(Dropdown.Value, Index)
                    else
                        TableInsert(Dropdown.Value, OptionData.Name)
                    end
                    OptionData:Toggle(Index and "Inactive" or "Active")
                    Library.Flags[Dropdown.Flag] = Dropdown.Value
                else
                    if OptionData.Selected then
                        Dropdown.Value = OptionData.Name
                        Library.Flags[Dropdown.Flag] = OptionData.Name
                        OptionData.Selected = true
                        OptionData:Toggle("Active")
                        for _, Value in Dropdown.Options do
                            if Value ~= OptionData and not Value.IsSearching then
                                Value.Selected = false
                                Value:Toggle("Inactive")
                            end
                        end
                    else
                        Dropdown.Value = nil
                        Library.Flags[Dropdown.Flag] = nil
                        OptionData.Selected = false
                        OptionData:Toggle("Inactive")
                    end
                end
                if Dropdown.Callback then
                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end
            end

            OptionData.Button:Connect("MouseButton1Down", function()
                OptionData:Set()
            end)

            Dropdown.Options[OptionData.Name] = OptionData
            return OptionData
        end

        function Dropdown:Remove(Option)
            if Dropdown.Options[Option] then
                Dropdown.Options[Option].Button:Clean()
                Dropdown.Options[Option] = nil
            end
        end

        function Dropdown:Refresh(List)
            for _, Value in Dropdown.Options do
                Dropdown:Remove(Value.Name)
            end
            for _, Value in List do
                Dropdown:Add(Value)
            end
        end

        Library:Connect(Items["Search"].Instance:GetPropertyChangedSignal("Text"), function()
            Library:Thread(function()
                for _, Value in Dropdown.Options do
                    local InputText = Items["Search"].Instance.Text
                    if InputText ~= "" then
                        if StringFind(StringLower(Value.Name), Library:EscapePattern(StringLower(InputText))) then
                            Value.Button.Instance.Visible = true
                            Value:Search(false)
                        else
                            Value:Search(true)
                            Value.Button.Instance.Visible = false
                        end
                    else
                        Value:Search(false)
                        Value.Button.Instance.Visible = true
                    end
                end
            end)
        end)

        for _, Value in Dropdown.Items do
            Dropdown:Add(Value)
        end

        if Dropdown.Default then
            Dropdown:Set(Dropdown.Default)
        end

        Library.SetFlags[Dropdown.Flag] = function(Value)
            Dropdown:Set(Value)
        end

        Dropdown.Section.Elements[#Dropdown.Section.Elements + 1] = Dropdown
        return Dropdown
    end

    function Library.CreateSettingsPage(self, Window, KeybindList)
        local Page = Window:Page({ Name = "Settings", Icon = "settings" })
        local ConfigsSection = Page:Section({ Name = "Configs", Side = 2 })
        local ConfigName
        local ConfigSelected

        local ConfigsDropdown = ConfigsSection:Listbox({
            Flag = "ConfigsList",
            Items = {},
            Multi = false,
            Callback = function(Value)
                ConfigSelected = Value
            end
        })

        ConfigsSection:Textbox({
            Flag = "ConfigsName",
            Placeholder = "Name",
            Numeric = false,
            Finished = true,
            Callback = function(Value)
                ConfigName = Value
            end
        })

        ConfigsSection:Button({
            Name = "Create",
            Callback = function()
                if ConfigName and ConfigName ~= "" then
                    if not isfile(Library.Folders.Configs .. "/" .. ConfigName .. ".json") then
                        writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())
                        Library:RefreshConfigsList(ConfigsDropdown)
                    end
                end
            end
        })
        ConfigsSection:Button({
            Name = "Delete",
            Callback = function()
                if ConfigSelected then
                    Library:DeleteConfig(ConfigSelected)
                    Library:RefreshConfigsList(ConfigsDropdown)
                end
            end
        })
        ConfigsSection:Button({
            Name = "Load",
            Callback = function()
                if ConfigSelected then
                    Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. ConfigSelected))
                end
            end
        })
        ConfigsSection:Button({
            Name = "Save",
            Callback = function()
                if ConfigSelected then
                    writefile(Library.Folders.Configs .. "/" .. ConfigSelected, Library:GetConfig())
                end
            end
        })
        ConfigsSection:Button({
            Name = "Refresh",
            Callback = function()
                Library:RefreshConfigsList(ConfigsDropdown)
            end
        })

        return Page
    end

    getgenv().Library = Library
    return Library
end)()

return Library
