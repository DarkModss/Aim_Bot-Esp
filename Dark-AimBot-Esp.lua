-- =============================================
-- [PROTEÇÕES LEVES - NÃO AFETAM JOGABILIDADE]
-- =============================================

-- 1. OFUSCAÇÃO DE VARIÁVEIS (Nomes aleatórios)
local function obfuscateVar()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, math.random(8, 15) do
        result = result .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

-- 2. AMBIENTE SEGURO (Isola variáveis)
local SafeEnv = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = workspace,
    Camera = workspace.CurrentCamera,
    HttpService = game:GetService("HttpService"),
    UserInputService = game:GetService("UserInputService"),
}

-- 3. ANTI-ANÁLISE (Detecta se estão analisando)
local function antiAnalysis()
    local detected = false
    -- Verifica sinais comuns de análise
    if syn and syn.crypt then detected = true end
    if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then detected = true end
    if _G and _G.getgc then detected = true end
    if getgenv and getgenv()._G then detected = true end
    return detected
end

-- Se detectar análise, entra em modo silencioso
if antiAnalysis() then
    -- Mostra mensagem falsa e sai
    print("Darkness HUB - Modo de compatibilidade ativado")
    -- Não executa o resto do script
    return
end

-- 4. INTERFACE FALSA (Mostra loading por 2 segundos)
local function fakeUI()
    local success, err = pcall(function()
        local fakeGui = Instance.new("ScreenGui")
        fakeGui.Name = "Loading_" .. obfuscateVar()
        fakeGui.ResetOnSpawn = false
        fakeGui.Parent = SafeEnv.CoreGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 80)
        frame.Position = UDim2.new(0.5, -125, 0.5, -40)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = fakeGui
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = "Carregando Configurações..."
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.BackgroundTransparency = 1
        label.Parent = frame
        
        -- Mostra por 2 segundos e some
        task.wait(2)
        fakeGui:Destroy()
    end)
end

-- 5. ANTI-KICK (Bloqueia expulsão)
local function antiKick()
    local success, err = pcall(function()
        local player = SafeEnv.Players.LocalPlayer
        if player then
            -- Sobrescreve a função de kick
            local originalKick = player.Kick
            player.Kick = function(...)
                warn("[Proteção] Tentativa de kick bloqueada!")
                return false
            end
            -- Tenta remover scripts de kick
            local playerScripts = player:FindFirstChild("PlayerScripts")
            if playerScripts then
                local kickScript = playerScripts:FindFirstChild("Kick")
                if kickScript then
                    kickScript:Destroy()
                end
            end
        end
    end)
end

-- 6. PROTEÇÃO CONTRA ERROS (pcall em tudo)
local function safeExecute(func, ...)
    local args = {...}
    local success, result = pcall(function()
        return func(unpack(args))
    end)
    if not success then
        warn("[Proteção] Erro capturado:", result)
    end
    return success, result
end

-- 7. LIMPEZA AUTOMÁTICA (Remove vestígios)
local function autoCleanup()
    SafeEnv.RunService.Heartbeat:Connect(function()
        local player = SafeEnv.Players.LocalPlayer
        -- Se o jogador sair, limpa tudo
        if not player or not player.Parent then
            -- Para todos os loops
            for _, connection in ipairs(getconnections and getconnections(SafeEnv.RunService.Heartbeat) or {}) do
                if connection and connection.Disconnect then
                    connection:Disconnect()
                end
            end
        end
    end)
end

-- EXECUTA AS PROTEÇÕES
safeExecute(fakeUI)
safeExecute(antiKick)
safeExecute(autoCleanup)

print("[Darkness HUB] Proteções leves ativadas com sucesso!")

-- =============================================
-- [SEU CÓDIGO ORIGINAL AQUI]
-- =============================================

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Darkness HUB",
   Icon = 0,
   LoadingTitle = "Loading Darkness",
   LoadingSubtitle = "by Dark Dev",
   ShowText = "Dark Mods",
   Theme = "DarkBlue",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = true,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "Dark Hub"
   },

   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/8kDBARjETR",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "Digite a Key",
      Subtitle = "Key do Sistema",
      Note = "Insira a chave padrão para acessar",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"KeyTest"}
   }
})

local TabVisual = Window:CreateTab("Visual & Player", 4483362458)
local TabCombat = Window:CreateTab("Combate", 4483362458)

-- Variáveis Globais
local Players = SafeEnv.Players
local RunService = SafeEnv.RunService
local localPlayer = SafeEnv.Players.LocalPlayer
local Camera = SafeEnv.Camera

local espEnabled = false
local aimbotEnabled = false
local aimbotPart = "Head"

-- Configurações do FOV e Suavidade
local fovEnabled = false
local fovRadius = 100
local smoothness = 0.1

-- Criando o Círculo de FOV
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Thickness = 1
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Visible = false

------------------------------------------------------------------------
-- [SISTEMA: ESP]
------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            if char then
                local antigoHighlight = char:FindFirstChild("MeuESP")
                
                if espEnabled then
                    if not antigoHighlight then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "MeuESP"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = char
                    end
                else
                    if antigoHighlight then
                        antigoHighlight:Destroy()
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------------
-- [SISTEMA: ENCONTRAR ALVO NO FOV + VERIFICAÇÃO DE PAREDE]
------------------------------------------------------------------------
local function obterJogadorNoFOV()
    local menorDistancia2D = math.huge
    local jogadorAlvo = nil

    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = fovRadius
    FovCircle.Visible = fovEnabled

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(aimbotPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local parteAlvo = player.Character[aimbotPart]
                local screenPosition, onScreen = Camera:WorldToViewportPoint(parteAlvo.Position)
                
                if onScreen then
                    local centroTela = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local posicaoAlvo2D = Vector2.new(screenPosition.X, screenPosition.Y)
                    local distancia2D = (posicaoAlvo2D - centroTela).Magnitude

                    if (not fovEnabled or distancia2D <= fovRadius) and distancia2D < menorDistancia2D then
                        
                        -- Configura as regras do Raycast (Filtro de Parede)
                        local parametrosRaycast = RaycastParams.new()
                        -- Ignora seu próprio boneco e a câmera para o raio não colidir em você
                        parametrosRaycast.FilterDescendantsInstances = {localPlayer.Character, Camera}
                        parametrosRaycast.FilterType = Enum.RaycastFilterType.Exclude

                        -- Calcula o vetor de direção da sua câmera até o alvo
                        local origem = Camera.CFrame.Position
                        local direcao = parteAlvo.Position - origem
                        local resultadoRaycast = workspace:Raycast(origem, direcao, parametrosRaycast)

                        -- Se o raio não bateu em nada (espaço aberto) OU bateu direto em uma parte do alvo
                        if not resultadoRaycast or resultadoRaycast.Instance:IsDescendantOf(player.Character) then
                            menorDistancia2D = distancia2D
                            jogadorAlvo = player
                        end
                    end
                end
            end
        end
    end
    return jogadorAlvo
end

------------------------------------------------------------------------
-- [SISTEMA: MOVIMENTAÇÃO ESTÁVEL DA CÂMERA]
------------------------------------------------------------------------
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if aimbotEnabled then
            local alvo = obterJogadorNoFOV()
            if alvo and alvo.Character and alvo.Character:FindFirstChild(aimbotPart) then
                local posicaoAlvo = alvo.Character[aimbotPart].Position
                local novaDirecao = CFrame.new(Camera.CFrame.Position, posicaoAlvo)
                Camera.CFrame = Camera.CFrame:Lerp(novaDirecao, smoothness)
            end
        else
            if fovEnabled then
                FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                FovCircle.Visible = true
            else
                FovCircle.Visible = false
            end
        end
    end)
end)

------------------------------------------------------------------------
-- [INTERFACE: VISUAL & PLAYER]
------------------------------------------------------------------------
local Button
Button = TabVisual:CreateButton({
   Name = "Esp (Desativado)",
   Callback = function()
       espEnabled = not espEnabled
       if espEnabled then
           Button:SetText("Esp (Ativado)")
       else
           Button:SetText("Esp (Desativado)")
       end
   end,
})

local SpeedSlider = TabVisual:CreateSlider({
   Name = "Velocidade (WalkSpeed)",
   Range = {16, 150},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 16,
   Flag = "SpeedSlider", 
   Callback = function(Value)
       if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
           localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
       end
   end,
})

local JumpSlider = TabVisual:CreateSlider({
   Name = "Força do Pulo (JumpPower)",
   Range = {50, 250},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JumpSlider", 
   Callback = function(Value)
       if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
           localPlayer.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
           localPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
       end
   end,
})

------------------------------------------------------------------------
-- [INTERFACE: COMBATE]
------------------------------------------------------------------------
local AimbotToggle = TabCombat:CreateToggle({
   Name = "Ativar Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
       aimbotEnabled = Value
   end,
})

local FovToggle = TabCombat:CreateToggle({
   Name = "Mostrar/Usar Círculo de FOV",
   CurrentValue = false,
   Flag = "FovToggle",
   Callback = function(Value)
       fovEnabled = Value
   end,
})

local FovSlider = TabCombat:CreateSlider({
   Name = "Tamanho do FOV",
   Range = {30, 500},
   Increment = 5,
   Suffix = "Pixels",
   CurrentValue = 100,
   Flag = "FovSlider", 
   Callback = function(Value)
       fovRadius = Value
   end,
})

local SmoothSlider = TabCombat:CreateSlider({
   Name = "Suavidade da Mira (Smoothness)",
   Range = {1, 30},
   Increment = 1,
   Suffix = "%",
   CurrentValue = 10,
   Flag = "SmoothSlider", 
   Callback = function(Value)
       smoothness = Value / 100
   end,
})

local TargetDropdown = TabCombat:CreateDropdown({
   Name = "Onde Mirar",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "TargetDropdown",
   Callback = function(Option)
       aimbotPart = Option[1]
   end,
})

Rayfield:LoadConfiguration()
