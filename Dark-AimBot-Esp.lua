-- -- Versão com FOV e Movimento Suave - Spectro Loader -- --

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
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"KeyTest"}
   }
})

local TabVisual = Window:CreateTab("Visual & Player", 4483362458)
local TabCombat = Window:CreateTab("Combate", 4483362458)

-- Variáveis Globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espEnabled = false
local aimbotEnabled = false
local aimbotPart = "Head"

-- Novas Variáveis para Aimbot Humanizado
local fovEnabled = false
local fovRadius = 100
local smoothness = 0.1 -- Quanto menor, mais suave/lento o movimento (Ex: 0.05 a 0.2)

-- Criando o Círculo de FOV usando a API Drawing
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
-- [SISTEMA: AIMBOT HUMANIZADO COM FOV]
------------------------------------------------------------------------
local function obterJogadorNoFOV()
    local menorDistancia2D = math.huge
    local jogadorAlvo = nil

    -- Atualiza a posição do círculo de FOV para o centro da tela
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = fovRadius
    FovCircle.Visible = fovEnabled

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(aimbotPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Converte a posição 3D do alvo para as coordenadas 2D da tela do jogador
                local screenPosition, onScreen = Camera:WorldToViewportPoint(player.Character[aimbotPart].Position)
                
                if onScreen then
                    -- Calcula a distância entre o centro da tela e a posição do alvo na tela
                    local centroTela = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local posicaoAlvo2D = Vector2.new(screenPosition.X, screenPosition.Y)
                    local distancia2D = (posicaoAlvo2D - centroTela).Magnitude

                    -- Se o jogador estiver dentro do raio do FOV e for o mais próximo do centro
                    if (not fovEnabled or distancia2D <= fovRadius) and distancia2D < menorDistancia2D then
                        menorDistancia2D = distancia2D
                        jogadorAlvo = player
                    end
                end
            end
        end
    end
    return jogadorAlvo
end

-- RenderStepped cuida da atualização visual a cada frame
RunService.RenderStepped:Connect(function()
    local alvo = obterJogadorNoFOV()
    
    if aimbotEnabled and alvo and alvo.Character and alvo.Character:FindFirstChild(aimbotPart) then
        -- Calcula para onde a câmera deve olhar
        local posicaoAlvo = alvo.Character[aimbotPart].Position
        local novaDirecao = CFrame.new(Camera.CFrame.Position, posicaoAlvo)
        
        -- CFrame:Lerp faz a transição suave de forma "humanizada" com base no valor de smoothness
        Camera.CFrame = Camera.CFrame:Lerp(novaDirecao, smoothness)
    end
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
   Range = {1, 30}, -- Escalonado para facilitar o controle no Slider
   Increment = 1,
   Suffix = "%",
   CurrentValue = 10,
   Flag = "SmoothSlider", 
   Callback = function(Value)
       -- Converte a porcentagem inteira do slider para valores decimais (0.01 a 0.3)
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