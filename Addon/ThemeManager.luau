local ThemeManager = {}
local Library = getgenv().Library

if not Library then
    warn("[ThemeManager] Library not loaded. Load Library.lua first.")
    return ThemeManager
end

local HttpService = game:GetService("HttpService")

local Presets = {
    ["Default"] = {
        Accent = Color3.fromRGB(0, 116, 224),
        AccentGradient = Color3.fromRGB(0, 195, 255),
        Background = Color3.fromRGB(12, 12, 14),
        ["Background 2"] = Color3.fromRGB(10, 10, 12),
        Text = Color3.fromRGB(235, 235, 235),
        Outline = Color3.fromRGB(25, 25, 28),
        ["Section Top"] = Color3.fromRGB(28, 27, 31),
        ["Section Background"] = Color3.fromRGB(10, 10, 12),
        ["Section Background 2"] = Color3.fromRGB(14, 14, 16),
        Element = Color3.fromRGB(16, 16, 18),
    },
    ["Midnight"] = {
        Accent = Color3.fromRGB(120, 80, 200),
        AccentGradient = Color3.fromRGB(180, 130, 255),
        Background = Color3.fromRGB(8, 8, 12),
        ["Background 2"] = Color3.fromRGB(6, 6, 10),
        Text = Color3.fromRGB(220, 220, 230),
        Outline = Color3.fromRGB(20, 18, 26),
        ["Section Top"] = Color3.fromRGB(22, 20, 28),
        ["Section Background"] = Color3.fromRGB(8, 8, 12),
        ["Section Background 2"] = Color3.fromRGB(12, 10, 16),
        Element = Color3.fromRGB(14, 12, 18),
    },
    ["Rose"] = {
        Accent = Color3.fromRGB(200, 60, 100),
        AccentGradient = Color3.fromRGB(255, 120, 160),
        Background = Color3.fromRGB(14, 10, 12),
        ["Background 2"] = Color3.fromRGB(12, 8, 10),
        Text = Color3.fromRGB(240, 230, 235),
        Outline = Color3.fromRGB(28, 22, 26),
        ["Section Top"] = Color3.fromRGB(32, 24, 30),
        ["Section Background"] = Color3.fromRGB(12, 8, 10),
        ["Section Background 2"] = Color3.fromRGB(16, 12, 14),
        Element = Color3.fromRGB(18, 14, 16),
    },
}

local function ApplyPreset(Name)
    local Preset = Presets[Name]
    if not Preset then return end
    for Property, Color in Preset do
        Library.Theme[Property] = Color
        Library:ChangeTheme(Property, Color)
    end
end

function ThemeManager:SetPreset(Name)
    ApplyPreset(Name)
end

function ThemeManager:SaveTheme(Path)
    Path = Path or "lyapossss/Theme.json"
    local Folder = Path:match("^(.*)/")
    if Folder and not isfolder(Folder) then
        makefolder(Folder)
    end
    local Data = {}
    for Name, Color in Library.Theme do
        Data[Name] = Color:ToHex()
    end
    writefile(Path, HttpService:JSONEncode(Data))
    return Path
end

function ThemeManager:LoadTheme(Path)
    Path = Path or "lyapossss/Theme.json"
    if not isfile(Path) then
        return false, "Theme file not found"
    end
    local Success, Data = pcall(function()
        return HttpService:JSONDecode(readfile(Path))
    end)
    if not Success then
        return false, "Invalid theme file"
    end
    for Name, Hex in Data do
        local Color = Color3.fromHex(Hex)
        Library.Theme[Name] = Color
        Library:ChangeTheme(Name, Color)
    end
    return true
end

function ThemeManager:GetPresets()
    local Names = {}
    for Name in Presets do
        table.insert(Names, Name)
    end
    return Names
end

function ThemeManager:RegisterPreset(Name, Preset)
    if type(Name) ~= "string" or type(Preset) ~= "table" then
        return false
    end
    Presets[Name] = Preset
    return true
end

getgenv().ThemeManager = ThemeManager
return ThemeManager
