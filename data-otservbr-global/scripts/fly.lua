TP_MODAL_SYSTEM = {
	id = 1060, -- se nao souber do que se trata, nao mude
	title = "Teleport System", -- titulo da janela
	message = "Choose your destiny below:", -- mensagem da janela

	cooldownModal = 60, -- Tempo em segundos para o jogador poder utilizar o sistema novamente

	-- CONFIG DE HOUSES --
	houseShowedInModal = true, -- se deseja exibir a house do jogador no modal de teleport, true/false
	houseTeleportNeedPay = true, -- se o player precisa pagar para se teleportar para a house, true/false
	houseTeleportCost = 2000, -- custo do teleport para a house, caso tenha colocado true acima
	-- FIM DE CONFIG DOS HOUSES --

	playerProtectZone = true, -- se o player precisa ta em uma zona segura para utilizar o comando, true/false

	messages = {
		ptz = "You need to be in a protected zone to use the teleport system!",
		mny = "You do not have %d gold coins to this trip!",
		exh = "You need to wait %d seconds to can use teleport system again!",
	},

	locals = {
		[1] = {
			nome = 'Ab Dendriel', -- Nome do local a ser mostrado na janela
			isPaid = true, -- caso o jogador tenha que pagar para usar o teleport -> true/false
			value = 1000, -- custo da viagem, caso tenha colocado true acima
			pos = Position(32681, 31686, 7)
		},
		[2] = {
			nome = 'Ankrahmun',
			isPaid = true,
			value = 1000,
			pos = Position(33127, 32843, 7)

		},
		[3] = {
			nome = 'Carlin',
			isPaid = true,
			value = 1000,
			pos = Position(32332, 31782, 7)
		},
		[4] = {
			nome = 'Darashia',
			isPaid = true,
			value = 1000,
			pos = Position(33214, 32461, 8)
		},
		[5] = {
			nome = 'Edron',
			isPaid = true,
			value = 1000,
			pos = Position(33168, 31805, 8)
		},
		[6] = {
			nome = 'Issavi',
			isPaid = true,
			value = 1000,
			pos = Position(33918, 31480, 7)
		},
		[7] = {
			nome = 'Liberty Bay',
			isPaid = true,
			value = 1000,
			pos = Position(32332, 32835, 7)
		},
		[8] = {
			nome = 'Oramond',
			isPaid = true,
			value = 1000,
			pos = Position(33625, 31895, 7)
		},
		[9] = {
			nome = 'Port Hope',
			isPaid = true,
			value = 1000,
			pos = Position(32632, 32746, 7)
		},
		[10] = {
			nome = 'Svargrond',
			isPaid = true,
			value = 1000,
			pos = Position(32264, 31141, 7)
		},
		[11] = {
			nome = 'Thais',
			isPaid = true,
			value = 1000,
			pos = Position(32345, 32223, 7)
		},
		[12] = {
			nome = 'Yalahar',
			isPaid = true,
			value = 1000,
			pos = Position(32790, 31247, 7)
		},
		[13] = {
			nome = 'Rookgaard',
			isPaid = true,
			value = 1000,
			pos = Position(32097, 32219, 7)
		},
	},

	locals_wp = {},
	storage = 556734, -- Storage que irÃ¡ controlar o tempo para utilizar o sistema novamente
}

local function createModal(id, title, message, teleport, player)
	local modalWindow = ModalWindow(id, title, message)

	for i, v in pairs(teleport.locals) do
		local value = transformValue(v.value)
		modalWindow:addChoice(i, v.nome .. ' | value: ' .. ((v.isPaid and value) or 0))
	end

	local start_tp = #teleport.locals

	if (TP_MODAL_SYSTEM.houseShowedInModal) then
		local playerHouse = player:getHouse()
		if (playerHouse) then
			teleport.locals_wp[player:getGuid()] = {}
			table.insert(teleport.locals_wp[player:getGuid()], {
				nome = "House",
				isPaid = teleport.houseTeleportNeedPay,
				value = teleport.houseTeleportCost,
				pos = playerHouse:getExitPosition()
			})
		end
		if (teleport.locals_wp[player:getGuid()]) then
			for i, v in pairs(teleport.locals_wp[player:getGuid()]) do
				local value = transformValue(v.value)
				modalWindow:addChoice(i + start_tp, v.nome .. ' | value: ' .. ((v.isPaid and value) or 0))
			end
		end
	end

	modalWindow:addButton(101, "Teleport")
	modalWindow:addButton(100, "Cancel")
	modalWindow:setDefaultEnterButton(101)
	modalWindow:setDefaultEscapeButton(100)
	modalWindow:sendToPlayer(player)
end

function transformValue(value)
	if value > 0 then
		value = (value / 1000) .. " k"
	end
	return value
end

local function checkCondition(player)
	if player:getGroup():getAccess() or player:getAccountType() == ACCOUNT_TYPE_GOD then
		return true
	end

	if (player:getStorageValue(TP_MODAL_SYSTEM.storage) >= os.time()) then
		player:sendCancelMessage((TP_MODAL_SYSTEM.messages.exh):format(player:getStorageValue(TP_MODAL_SYSTEM.storage) - os.time()))
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if (TP_MODAL_SYSTEM.playerProtectZone) then
		if not (Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE)) then
			player:sendCancelMessage(TP_MODAL_SYSTEM.messages.ptz)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end
	return true
end

local fly = TalkAction("!fly")
function fly.onSay(player, words, param, type)
	if not (checkCondition(player)) then
		return false
	end

	createModal(TP_MODAL_SYSTEM.id, TP_MODAL_SYSTEM.title, TP_MODAL_SYSTEM.message, TP_MODAL_SYSTEM, player)
	player:setStorageValue(TP_MODAL_SYSTEM.storage, os.time() + TP_MODAL_SYSTEM.cooldownModal)
	player:registerEvent("flyModalWindow")
	return true
	
	
end

fly:register()

--------------------- Modal Fly ---------------------

local function teleportPlayer(player, teleport)
	if (teleport.isPaid) then
		local teleportValue = teleport.value
		if not (player:removeMoneyBank(teleportValue)) then
			player:sendCancelMessage(TP_MODAL_SYSTEM.messages.mny:format(teleportValue))
			return false
		end
	end
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	player:teleportTo(teleport.pos)
	player:getPosition():sendMagicEffect(CONST_ME_BATS)
end

local function removePlayer(player)
	if (TP_MODAL_SYSTEM.locals_wp[player:getGuid()]) then
		TP_MODAL_SYSTEM.locals_wp[player:getGuid()] = nil
	end
end

local modalFlyEvent = CreatureEvent("flyModalWindow")
function modalFlyEvent.onModalWindow(player, modalWindowId, buttonId, choiceId)
	if (modalWindowId == TP_MODAL_SYSTEM.id) then
		if (buttonId == 101) then
			local teleportTarget = TP_MODAL_SYSTEM.locals[choiceId]
			if (teleportTarget) then
				teleportPlayer(player, teleportTarget)
			else
				local teleportTargetWaypoint = TP_MODAL_SYSTEM.locals_wp[player:getGuid()]
				if (teleportTargetWaypoint) then
					teleportPlayer(player, TP_MODAL_SYSTEM.locals_wp[player:getGuid()][choiceId - #TP_MODAL_SYSTEM.locals])
				end
			end
		end
		removePlayer(player)
	end
	player:unregisterEvent("flyModalWindow")
	return true
end

modalFlyEvent:register()
