local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer

-- Função para converter "1K", "10M", etc. em número real
local function converterTextoParaNumeroSimples(texto)
	texto = texto:upper():gsub("%s+", "")
	local valor = texto:match("([%d%.]+)")
	local sufixo = texto:match("[KMB]") or ""

	valor = tonumber(valor)
	if not valor then return 0 end

	if sufixo == "K" then
		valor = valor * 1_000
	elseif sufixo == "M" then
		valor = valor * 1_000_000
	elseif sufixo == "B" then
		valor = valor * 1_000_000_000
	end

	return valor
end

-- Função para converter "$1.5M/s" em número real
local function converterTextoGerado(texto)
	local valor = texto:match("%$([%d%.]+)")
	local sufixo = texto:match("%d+([KMB])/s") or ""

	valor = tonumber(valor)
	if not valor then return 0 end

	if sufixo == "K" then
		valor = valor * 1_000
	elseif sufixo == "M" then
		valor = valor * 1_000_000
	elseif sufixo == "B" then
		valor = valor * 1_000_000_000
	end

	return valor
end

-- Cria o texto flutuante
local function criarTextoFlutuante(objeto, texto)
	if objeto:FindFirstChild("GeracaoTexto") then
		objeto.GeracaoTexto:Destroy()
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "GeracaoTexto"
	billboard.Adornee = objeto
	billboard.Size = UDim2.new(15, 0, 4, 0)
	billboard.StudsOffset = Vector3.new(0, 8, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 1000
	billboard.Parent = objeto

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "💰 " .. texto
	label.TextColor3 = Color3.fromRGB(0, 255, 100)
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextStrokeTransparency = 0.2
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Parent = billboard

	if not objeto:FindFirstChild("Destaque") then
		local hl = Instance.new("Highlight")
		hl.Name = "Destaque"
		hl.FillColor = Color3.fromRGB(0, 255, 100)
		hl.FillTransparency = 0.8
		hl.OutlineColor = Color3.fromRGB(0, 255, 0)
		hl.OutlineTransparency = 0
		hl.Parent = objeto
	end
end

-- Função para aplicar os destaques com base em um limite
local function aplicarDestaque(limite)
	local plotsFolder = Workspace:FindFirstChild("Plots")
	if not plotsFolder then return false end

	for _, antigo in ipairs(plotsFolder:GetDescendants()) do
		if antigo:IsA("BillboardGui") and antigo.Name == "GeracaoTexto" then
			antigo:Destroy()
		elseif antigo:IsA("Highlight") and antigo.Name == "Destaque" then
			antigo:Destroy()
		end
	end

	local encontrou = false
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		local podiums = plot:FindFirstChild("AnimalPodiums")
		if podiums then
			for _, podium in ipairs(podiums:GetChildren()) do
				for _, obj in ipairs(podium:GetDescendants()) do
					if obj:IsA("TextLabel") and obj.Text and obj.Text:find("/s") then
						local valor = converterTextoGerado(obj.Text)
						if valor >= limite then
							encontrou = true
							criarTextoFlutuante(podium, obj.Text)
						end
					end
				end
			end
		end
	end

	return encontrou
end

-- Função para trocar de servidor
local function trocarServidor()
	local gameId = game.PlaceId
	local servers = HttpService:JSONDecode(game:HttpGet(
		"https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"
	))

	for _, server in ipairs(servers.data) do
		if server.playing < server.maxPlayers then
			TeleportService:TeleportToPlaceInstance(gameId, server.id, localPlayer)
			break
		end
	end
end

-- Interface gráfica
local gui = Instance.new("ScreenGui")
gui.Name = "ValorMinimoGui"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -20, 0, 40)
input.Position = UDim2.new(0, 10, 0, 10)
input.PlaceholderText = "Digite ex: 1M, 10K..."
input.Text = ""
input.Font = Enum.Font.SourceSans
input.TextSize = 22
input.TextColor3 = Color3.new(1, 1, 1)
input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
input.BorderSizePixel = 0
input.ClearTextOnFocus = false
input.Parent = frame

local botao = Instance.new("TextButton")
botao.Size = UDim2.new(1, -20, 0, 35)
botao.Position = UDim2.new(0, 10, 0, 55)
botao.Text = "✅ Confirmar"
botao.Font = Enum.Font.SourceSansBold
botao.TextSize = 20
botao.TextColor3 = Color3.new(1, 1, 1)
botao.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
botao.BorderSizePixel = 0
botao.Parent = frame

local botaoTrocar = Instance.new("TextButton")
botaoTrocar.Size = UDim2.new(1, -20, 0, 30)
botaoTrocar.Position = UDim2.new(0, 10, 0, 95)
botaoTrocar.Text = "🌍 Trocar Servidor"
botaoTrocar.Font = Enum.Font.SourceSansBold
botaoTrocar.TextSize = 18
botaoTrocar.TextColor3 = Color3.new(1, 1, 1)
botaoTrocar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
botaoTrocar.BorderSizePixel = 0
botaoTrocar.Parent = frame

-- Label de status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 135)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 18
statusLabel.TextScaled = true
statusLabel.TextWrapped = true
statusLabel.Parent = frame

local valorLimiteAtual = 0

botao.MouseButton1Click:Connect(function()
	local texto = input.Text
	local valorLimite = converterTextoParaNumeroSimples(texto)

	if valorLimite > 0 then
		valorLimiteAtual = valorLimite
		local ok = aplicarDestaque(valorLimiteAtual)

		if not ok then
			local arquivoJson = nil
			if valorLimite >= 500_000 and valorLimite < 1_000_000 then
				arquivoJson = "https://0e10eb52-c6ae-47e5-8889-982f073de2b2-00-39484ldvyw3w.janeway.replit.dev:3000/500K_1M_2.json"
			elseif valorLimite >= 1_000_000 and valorLimite < 10_000_000 then
				arquivoJson = "https://0e10eb52-c6ae-47e5-8889-982f073de2b2-00-39484ldvyw3w.janeway.replit.dev:3000/1M_10M.json"
			elseif valorLimite >= 10_000_000 and valorLimite <= 1_000_000_000 then
				arquivoJson = "https://0e10eb52-c6ae-47e5-8889-982f073de2b2-00-39484ldvyw3w.janeway.replit.dev:3000/10M_1B.json"
			end

			if arquivoJson then
				local success, response = pcall(function()
    if syn and syn.request then
        return syn.request({Url = arquivoJson, Method = "GET"}).Body
    elseif request then
        return request({Url = arquivoJson, Method = "GET"}).Body
    else
        error("Executor não suporta HTTP Requests")
    end
end)


				if success then
					local dados = HttpService:JSONDecode(response)
					local jobId = dados.job_id_pc
					if jobId then
						statusLabel.Text = "✅ JobID encontrado: " .. jobId
						statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
						print("🔹 Teleportando para Job ID:", jobId)
						TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, Players.LocalPlayer)
						return
					else
						statusLabel.Text = "⚠️ JobID não encontrado no JSON"
						statusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
						warn("Job ID não encontrado no JSON")
					end
				else
					statusLabel.Text = "❌ Erro ao ler o JSON"
					statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
					warn("Não foi possível ler o JSON:", response)
				end
			else
				statusLabel.Text = "⚠️ Nenhum arquivo JSON correspondente"
				statusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
				warn("Nenhum arquivo JSON correspondente ao valor")
			end

			trocarServidor()
		end
	else
		statusLabel.Text = "⚠️ Valor inválido"
		statusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
		warn("Valor inválido:", texto)
	end
end)

botaoTrocar.MouseButton1Click:Connect(function()
	trocarServidor()
end)

task.spawn(function()
	while task.wait(30) do
		if valorLimiteAtual > 0 then
			local ok = aplicarDestaque(valorLimiteAtual)
			if not ok then
				trocarServidor()
			end
		end
	end
end)

if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://github.com/Goulace/Auto-Joiner/edit/main/autojoiner.lua"))()
    ]])
end
