-- SpinHelper by Axxre
-- Jujutsu Zero – Clans

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------

local KEY_LINK_LINKVERTISE = "https://link-hub.net/2522229/FhciEmte8qIE"
local ACCESS_KEY           = "XMAS"

local TARGET_CODES = { "XMAS", "80Kmembers", "90smthKmembersYAY", "20KLIKES", "oopsMBgg" }

local CLAN_LIST = {
    "Itadori","Fujiwara","Miwa",
    "Nanami","Kugisaki","Inumaki","Todo",
    "Fushiguro","Abe","Okkotsu","Kamo",
    "Zen'in","Gojo","Geto",
    "Sukuna","Tengen",
}

-- ИСПРАВЛЕНО: Дефолтные таргет кланы
local DEFAULT_TARGET_CLANS = {"Sukuna", "Tengen"}

local TARGET_SPINS_PER_SEC = 5
local TARGET_INTERVAL      = 1 / TARGET_SPINS_PER_SEC
local CONFIGS_FOLDER       = "JJK_Zero_Configs"

---------------------------------------------------------------------
-- SERVICES / OBJECTS
---------------------------------------------------------------------

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local clanRoll  = playerGui:WaitForChild("ClanRoll")
local clansRoll = clanRoll:WaitForChild("ClansRoll")

local currentCLAN = clansRoll:WaitForChild("CurrentCLAN")
local clanDisplay = currentCLAN:WaitForChild("ClanDisplay")
local descLabel   = clanDisplay:WaitForChild("Desc")

local rollRemote   = ReplicatedStorage:WaitForChild("NetworkComm"):WaitForChild("PlayerService"):WaitForChild("RollClan_Method")
local redeemRemote = ReplicatedStorage:FindFirstChild("RedeemCode_Method", true)

print("Found rollRemote:", rollRemote and rollRemote:GetFullName() or "NIL")
print("Found redeemRemote:", redeemRemote and redeemRemote:GetFullName() or "NIL")

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------

local selectedClans = {}
for _, n in ipairs(CLAN_LIST) do
    selectedClans[n] = false
end

-- ИСПРАВЛЕНО: Изначально false, включается только через кнопку
local autoSpinEnabled    = false
local autoLoadConfigName = nil
local Rayfield, Window

---------------------------------------------------------------------
-- KEY GUI
---------------------------------------------------------------------

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "SpinHelper_KeyGui"
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyGui.Parent = CoreGui

local RootFrame = Instance.new("Frame")
RootFrame.AnchorPoint = Vector2.new(0.5, 0.5)
RootFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
RootFrame.Size = UDim2.new(0, 420, 0, 210)
RootFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
RootFrame.BorderSizePixel = 0
RootFrame.ZIndex = 20
RootFrame.Active = true
RootFrame.Draggable = true
RootFrame.Parent = KeyGui

local RootCorner = Instance.new("UICorner")
RootCorner.CornerRadius = UDim.new(0, 14)
RootCorner.Parent = RootFrame

local RootStroke = Instance.new("UIStroke")
RootStroke.Color = Color3.fromRGB(50, 55, 80)
RootStroke.Thickness = 1
RootStroke.Transparency = 0.35
RootStroke.Parent = RootFrame

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -40, 0, 24)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(235, 235, 245)
Title.Text = "SpinHelper by Axxre – Key"
Title.ZIndex = 21
Title.Parent = RootFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -10, 0, 22)
CloseBtn.BackgroundColor3 = Color3.fromRGB(32, 33, 42)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(220, 120, 120)
CloseBtn.Text = "X"
CloseBtn.ZIndex = 21
CloseBtn.Parent = RootFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    KeyGui:Destroy()
end)

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Size = UDim2.new(1, -20, 0, 18)
Subtitle.Position = UDim2.new(0, 10, 0, 36)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 13
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextColor3 = Color3.fromRGB(170, 175, 190)
Subtitle.Text = "Jujutsu Zero – Clans"
Subtitle.ZIndex = 21
Subtitle.Parent = RootFrame

local KeyLabel = Instance.new("TextLabel")
KeyLabel.BackgroundTransparency = 1
KeyLabel.Size = UDim2.new(1, -20, 0, 18)
KeyLabel.Position = UDim2.new(0, 10, 0, 60)
KeyLabel.Font = Enum.Font.Gotham
KeyLabel.TextSize = 13
KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
KeyLabel.TextColor3 = Color3.fromRGB(180, 185, 200)
KeyLabel.Text = "Enter your key:"
KeyLabel.ZIndex = 21
KeyLabel.Parent = RootFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -20, 0, 32)
KeyBox.Position = UDim2.new(0, 10, 0, 80)
KeyBox.BackgroundColor3 = Color3.fromRGB(26, 27, 34)
KeyBox.BorderSizePixel = 0
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.TextColor3 = Color3.fromRGB(230, 235, 245)
KeyBox.PlaceholderText = "xxxx-xxxx"
KeyBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 140)
KeyBox.ClearTextOnFocus = false
KeyBox.Text = ""
KeyBox.ZIndex = 21
KeyBox.Parent = RootFrame

local KB_Corner = Instance.new("UICorner")
KB_Corner.CornerRadius = UDim.new(0, 8)
KB_Corner.Parent = KeyBox

local KB_Stroke = Instance.new("UIStroke")
KB_Stroke.Color = Color3.fromRGB(60, 65, 90)
KB_Stroke.Thickness = 1
KB_Stroke.Transparency = 0.4
KB_Stroke.Parent = KeyBox

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Size = UDim2.new(1, -20, 0, 18)
Status.Position = UDim2.new(0, 10, 0, 116)
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextColor3 = Color3.fromRGB(170, 175, 190)
Status.Text = "Get key via Linkvertise, then paste it above."
Status.ZIndex = 21
Status.Parent = RootFrame

local function copyLink(link)
    if typeof(setclipboard) == "function" then
        pcall(setclipboard, link)
        Status.Text = "Link copied to clipboard."
        Status.TextColor3 = Color3.fromRGB(150, 220, 150)
    else
        Status.Text = "Copy manually: "..link
        Status.TextColor3 = Color3.fromRGB(230, 210, 150)
    end
end

local LinkBtn = Instance.new("TextButton")
LinkBtn.Size = UDim2.new(1, -20, 0, 30)
LinkBtn.Position = UDim2.new(0, 10, 0, 146)
LinkBtn.BackgroundColor3 = Color3.fromRGB(35, 37, 46)
LinkBtn.BorderSizePixel = 0
LinkBtn.Font = Enum.Font.GothamBold
LinkBtn.TextSize = 14
LinkBtn.TextColor3 = Color3.fromRGB(235, 238, 245)
LinkBtn.Text = "Get Key (Linkvertise)"
LinkBtn.ZIndex = 21
LinkBtn.Parent = RootFrame

local LB_Corner = Instance.new("UICorner")
LB_Corner.CornerRadius = UDim.new(0, 8)
LB_Corner.Parent = LinkBtn

local LB_Stroke = Instance.new("UIStroke")
LB_Stroke.Color = Color3.fromRGB(80, 90, 130)
LB_Stroke.Thickness = 1
LB_Stroke.Transparency = 0.35
LB_Stroke.Parent = LinkBtn

LinkBtn.MouseButton1Click:Connect(function()
    copyLink(KEY_LINK_LINKVERTISE)
end)

local function tryUnlock()
    if KeyBox.Text == ACCESS_KEY then
        Status.Text = "Key accepted. Loading UI..."
        Status.TextColor3 = Color3.fromRGB(150, 220, 150)
        task.delay(0.25, function()
            KeyGui:Destroy()
            loadMainUI()
        end)
    else
        Status.Text = "Wrong key."
        Status.TextColor3 = Color3.fromRGB(230, 130, 130)
    end
end

KeyBox.FocusLost:Connect(function(enter)
    if enter then
        tryUnlock()
    end
end)

---------------------------------------------------------------------
-- GAME LOGIC
---------------------------------------------------------------------

local function anySelected()
    for _, v in pairs(selectedClans) do
        if v then return true end
    end
    return false
end

local function isTargetClan(name)
    return name and selectedClans[name] == true
end

local function doRollAndWaitClan(maxWait)
    if not rollRemote then 
        print("❌ rollRemote is nil!")
        return nil 
    end
    maxWait = maxWait or 0.45

    local before = descLabel.Text
    print("🎲 Rolling... Current clan:", before)
    
    local finished = false
    local resultClan

    local conn
    conn = descLabel:GetPropertyChangedSignal("Text"):Connect(function()
        local new = descLabel.Text
        print("📝 Text changed:", before, "->", new)
        if new ~= before then
            resultClan = new
            finished = true
            if conn then conn:Disconnect() conn = nil end
        end
    end)

    local success, err = pcall(function()
        rollRemote:InvokeServer()
    end)
    
    if not success then
        print("❌ InvokeServer error:", err)
        if conn then conn:Disconnect() end
        return nil
    end
    
    print("✅ InvokeServer called successfully")

    local start = time()
    while not finished and (time() - start) < maxWait do
        task.wait()
    end

    if conn then conn:Disconnect() end
    
    if finished then
        print("✅ Got result:", resultClan or descLabel.Text)
        return resultClan or descLabel.Text
    else
        print("⏱️ Timeout waiting for result")
        local current = descLabel.Text
        if current ~= before then
            print("🔍 But text DID change to:", current)
            return current
        end
    end
    
    return nil
end

local function redeemAllCodes()
    if not redeemRemote then return end
    for _, code in ipairs(TARGET_CODES) do
        pcall(function()
            redeemRemote:InvokeServer(code)
        end)
        task.wait(0.15)
    end
end

---------------------------------------------------------------------
-- CONFIGS
---------------------------------------------------------------------

local function ensureFolder()
    if not isfolder or not makefolder then return end
    if not isfolder(CONFIGS_FOLDER) then
        pcall(makefolder, CONFIGS_FOLDER)
    end
end

local function listConfigs()
    ensureFolder()
    local files = {}
    if isfolder and listfiles and isfolder(CONFIGS_FOLDER) then
        local all = listfiles(CONFIGS_FOLDER)
        for _, path in ipairs(all) do
            local name = path:match("[/\\]([^/\\\\]+)%.json$")
            if name then
                table.insert(files, name)
            end
        end
    end
    table.sort(files)
    return files
end

local function saveConfig(name)
    ensureFolder()
    local data = {
        SelectedClans = selectedClans,
        AutoSpin      = autoSpinEnabled,
        AutoLoad      = (autoLoadConfigName == name)
    }
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then return false, "encode_failed" end
    if not writefile then return false, "no_writefile" end
    local path = CONFIGS_FOLDER.."/"..name..".json"
    local ok2, err = pcall(writefile, path, encoded)
    if not ok2 then return false, err end
    return true
end

local function loadConfig(name)
    local path = CONFIGS_FOLDER.."/"..name..".json"
    if not isfile or not isfile(path) then
        return false, "nofile"
    end
    local ok, contents = pcall(readfile, path)
    if not ok then return false, "readfail" end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, contents)
    if not ok2 or type(data) ~= "table" then
        return false, "decodefail"
    end
    if type(data.SelectedClans) == "table" then
        for _, n in ipairs(CLAN_LIST) do
            selectedClans[n] = data.SelectedClans[n] == true
        end
    end
    -- ИСПРАВЛЕНО: НЕ загружаем AutoSpin из конфига при autoload
    -- if type(data.AutoSpin) == "boolean" then
    --     autoSpinEnabled = data.AutoSpin
    -- end
    if data.AutoLoad then
        autoLoadConfigName = name
    end
    return true
end

---------------------------------------------------------------------
-- MAIN UI (RAYFIELD)
---------------------------------------------------------------------

function loadMainUI()
    print("🔵 loadMainUI() STARTED")
    
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    print("🔵 Rayfield loaded")

    Window = Rayfield:CreateWindow({
        Name = "SpinHelper by Axxre",
        Icon = 0,
        LoadingTitle = "Jujutsu Zero – Clans",
        LoadingSubtitle = "Auto Spin / Codes / Configs",
        Theme = "Default",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings   = false,
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "JJK_Zero",
            FileName = "SpinHelper_Main"
        },
        Discord = { Enabled = false },
        KeySystem = false
    })
    print("🔵 Window created")

    local MainTab   = Window:CreateTab("🎯 Auto Spin", 4483362458)
    local CodesTab  = Window:CreateTab("💎 Codes", 4483362458)
    local ConfigTab = Window:CreateTab("📁 Configs", 4483362458)
    print("🔵 Tabs created")

    -----------------------------------------------------------------
    -- TAB: AUTO SPIN
    -----------------------------------------------------------------

    MainTab:CreateSection("Auto Spin")

    local StatusLabel = MainTab:CreateLabel("Status: idle")
    local function setStatus(txt) StatusLabel:Set(txt) end

    local ClanDropdown = MainTab:CreateDropdown({
        Name = "🎮 Target Clans",
        Options = CLAN_LIST,
        CurrentOption = {},
        MultipleOptions = true,
        Flag = "JJK_Clans_Selected",
        Callback = function(options)
            for _, n in ipairs(CLAN_LIST) do
                selectedClans[n] = false
            end
            for _, n in ipairs(options) do
                selectedClans[n] = true
            end
            if #options == 0 then
                setStatus("Status: select at least 1 clan.")
            else
                setStatus("Status: "..#options.." clans selected.")
            end
        end
    })

    local AutoSpinToggle = MainTab:CreateToggle({
        Name = "🚀 Auto Spin",
        CurrentValue = false,
        Flag = "JJK_AutoSpin",
        Callback = function(value)
            print("🎚️ AutoSpinToggle callback called! Value:", value)
            autoSpinEnabled = value
            print("🎚️ autoSpinEnabled set to:", autoSpinEnabled)
            if value then
                setStatus("Status: spinning...")
            else
                setStatus("Status: idle.")
            end
        end
    })
    
    -- ИСПРАВЛЕНО: Устанавливаем дефолтные кланы после создания dropdown
    task.spawn(function()
        task.wait(0.5) -- Даем UI загрузиться
        for _, clanName in ipairs(DEFAULT_TARGET_CLANS) do
            selectedClans[clanName] = true
        end
        ClanDropdown:Set(DEFAULT_TARGET_CLANS)
        setStatus("Status: "..#DEFAULT_TARGET_CLANS.." clans selected (Sukuna, Tengen).")
        print("✅ Default clans set:", table.concat(DEFAULT_TARGET_CLANS, ", "))
    end)
    
    print("🔵 MainTab completed")

    -----------------------------------------------------------------
    -- TAB: CODES
    -----------------------------------------------------------------

    CodesTab:CreateSection("Codes")

    CodesTab:CreateLabel("Codes: "..table.concat(TARGET_CODES, ", "))
    CodesTab:CreateButton({
        Name = "💰 Redeem All Codes",
        Callback = function()
            setStatus("Status: redeeming codes...")
            task.spawn(function()
                redeemAllCodes()
                setStatus("Status: codes redeemed.")
            end)
        end
    })
    
    print("🔵 CodesTab completed")

    -----------------------------------------------------------------
    -- TAB: CONFIGS
    -----------------------------------------------------------------

    ConfigTab:CreateSection("Clan Configs")

    local currentConfigName = ""
    local configListOptions = listConfigs()
    local ConfigListDropdown

    local function refreshConfigList(selectedName)
        configListOptions = listConfigs()
        ConfigListDropdown.Options = configListOptions

        if #configListOptions == 0 then
            ConfigListDropdown:Set({})
            currentConfigName = ""
            return
        end

        local toSelect = selectedName
        if not toSelect or toSelect == "" then
            toSelect = configListOptions[1]
        end

        ConfigListDropdown:Set(toSelect)
        currentConfigName = toSelect
    end

    local ConfigNameBox = ConfigTab:CreateInput({
        Name = "Config Name",
        PlaceholderText = "my_config",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            currentConfigName = text
        end
    })

    ConfigListDropdown = ConfigTab:CreateDropdown({
        Name = "Existing Configs",
        Options = configListOptions,
        CurrentOption = {},
        MultipleOptions = false,
        Flag = "JJK_Config_Selected",
        Callback = function(option)
            if type(option) == "table" then option = option[1] end
            currentConfigName = option or currentConfigName
        end
    })

    ConfigTab:CreateButton({
        Name = "📄 Create",
        Callback = function()
            local name = ConfigNameBox.CurrentValue or currentConfigName
            if not name or name == "" then
                setStatus("Config: enter name first.")
                return
            end
            local path = CONFIGS_FOLDER.."/"..name..".json"
            if isfile and isfile(path) then
                setStatus("Config already exists, use Overwrite.")
                return
            end
            local ok, err = saveConfig(name)
            if ok then
                setStatus("Config '"..name.."' created.")
                refreshConfigList(name)
            else
                setStatus("Create failed: "..tostring(err))
            end
        end
    })

    ConfigTab:CreateButton({
        Name = "✏ Overwrite",
        Callback = function()
            local name = ConfigNameBox.CurrentValue or currentConfigName
            if not name or name == "" then
                setStatus("Config: enter name.")
                return
            end
            local ok, err = saveConfig(name)
            if ok then
                setStatus("Config '"..name.."' overwritten.")
                refreshConfigList(name)
            else
                setStatus("Overwrite failed: "..tostring(err))
            end
        end
    })

    ConfigTab:CreateButton({
        Name = "📂 Load",
        Callback = function()
            local name = ConfigNameBox.CurrentValue or currentConfigName
            if not name or name == "" then
                setStatus("Load: select config.")
                return
            end
            local ok, err = loadConfig(name)
            if ok then
                local opts = {}
                for _, n in ipairs(CLAN_LIST) do
                    if selectedClans[n] then table.insert(opts, n) end
                end
                ClanDropdown:Set(opts)
                -- ИСПРАВЛЕНО: НЕ включаем AutoSpin при загрузке конфига
                -- AutoSpinToggle:Set(autoSpinEnabled)
                setStatus("Config '"..name.."' loaded.")
            else
                setStatus("Load failed: "..tostring(err))
            end
        end
    })

    ConfigTab:CreateToggle({
        Name = "⚙ Autoload this config on inject",
        CurrentValue = false,
        Flag = "JJK_AutoLoadFlag",
        Callback = function(value)
            local name = ConfigNameBox.CurrentValue or currentConfigName
            if value and name and name ~= "" then
                autoLoadConfigName = name
                setStatus("Autoload: "..name)
                saveConfig(name)
            elseif not value then
                autoLoadConfigName = nil
                setStatus("Autoload disabled.")
            end
        end
    })

    ConfigTab:CreateButton({
        Name = "🔃 Refresh List",
        Callback = function()
            refreshConfigList(currentConfigName)
            setStatus("Config list refreshed.")
        end
    })
    
    print("🔵 ConfigTab completed, starting autoload...")

    -- autoload config - ЗАЩИЩЁННАЯ ВЕРСИЯ
    do
        local success, err = pcall(function()
            local configs = listConfigs()
            print("Found configs:", #configs)
            for _, name in ipairs(configs) do
                print("Checking config:", tostring(name))
                if name and name ~= "" then
                    local path = CONFIGS_FOLDER.."/"..name..".json"
                    if isfile and isfile(path) then
                        local ok, contents = pcall(readfile, path)
                        if ok and contents then
                            local ok2, data = pcall(HttpService.JSONDecode, HttpService, contents)
                            if ok2 and type(data) == "table" and data.AutoLoad then
                                print("Loading autoload config:", name)
                                loadConfig(name)
                                local opts = {}
                                for _, n in ipairs(CLAN_LIST) do
                                    if selectedClans[n] then table.insert(opts, n) end
                                end
                                pcall(ClanDropdown.Set, ClanDropdown, opts)
                                -- ИСПРАВЛЕНО: НЕ включаем AutoSpin при autoload
                                -- pcall(AutoSpinToggle.Set, AutoSpinToggle, autoSpinEnabled)
                                autoLoadConfigName = name
                                break
                            end
                        end
                    end
                end
            end
            pcall(refreshConfigList, autoLoadConfigName or "")
        end)
        if not success then
            print("⚠️ Autoload error (non-critical):", err)
        end
    end
    
    print("🔵 Autoload completed, creating AUTOSPIN loop...")

    -----------------------------------------------------------------
    -- AUTOSPIN LOOP (5 spins/sec)
    -----------------------------------------------------------------

    task.spawn(function()
        print("✅ AUTOSPIN LOOP STARTED!")
        task.wait(1)
        
        local startTime = time()
        local spinIndex = 0

        while true do
            if autoSpinEnabled and rollRemote then
                print("🎯 Spin cycle active - anySelected:", anySelected())
                
                local elapsed = time() - startTime
                local shouldBe = math.floor(elapsed / TARGET_INTERVAL)

                while autoSpinEnabled and spinIndex < shouldBe do
                    spinIndex += 1
                    print("🎲 Spin attempt #"..spinIndex)

                    if not anySelected() then
                        setStatus("Status: select at least 1 clan.")
                        print("⚠️ No clans selected!")
                        break
                    end

                    local dropped = doRollAndWaitClan(0.45)

                    if dropped then
                        print("📦 Result:", dropped, "| Is target?", isTargetClan(dropped))
                        if isTargetClan(dropped) then
                            autoSpinEnabled = false
                            AutoSpinToggle:Set(false)
                            setStatus("🎉 GOT: "..dropped)
                            Rayfield:Notify({
                                Title = "Target clan!",
                                Content = dropped,
                                Duration = 5
                            })
                            break
                        else
                            setStatus("Last: "..dropped)
                        end
                    else
                        print("❌ Spin returned nil")
                        setStatus("Status: spin timeout.")
                    end
                end
            else
                startTime = time()
                spinIndex = 0
            end

            task.wait(0.02)
        end
    end)

    Rayfield:LoadConfiguration()
    print("🏁 loadMainUI() completed!")
end
