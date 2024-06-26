-- Initializing global variables to store the latest game state and game host process.
LatestGameState = LatestGameState or nil
InAction = InAction or false -- Prevents the agent from taking multiple actions at once.

Logs = Logs or {}

colors = {
  red = "\27[31m",
  green = "\27[32m",
  blue = "\27[34m",
  reset = "\27[0m",
  gray = "\27[90m"
}

function addLog(msg, text) -- Function definition commented for performance, can be used for debugging
  Logs[msg] = Logs[msg] or {}
  table.insert(Logs[msg], text)
end

-- Checks if two points are within a given range.
-- @param x1, y1: Coordinates of the first point.
-- @param x2, y2: Coordinates of the second point.
-- @param range: The maximum allowed distance between the points.
-- @return: Boolean indicating if the points are within the specified range.
function inRange(x1, y1, x2, y2, range)
    return math.abs(x1 - x2) <= range and math.abs(y1 - y2) <= range
end

-- Decides the next action based on player proximity and energy.
-- If any player is within range, it initiates an attack; otherwise, moves randomly.
function decideNextAction()
  local player = LatestGameState.Players[ao.id]
  local targetInRange = false

  if player.health < 25 then
    -- re up health
    Send({Target = CRED, Action = "Transfer", Quantity = "750", Recipient = Game})
  end

  for target, state in pairs(LatestGameState.Players) do
      if target ~= ao.id and inRange(player.x, player.y, state.x, state.y, 1) then
          targetInRange = true
          break
      end
  end

  if player.energy > 10 and targetInRange then
    print(colors.red .. "Player in range. Attacking..." .. colors.reset)
    ao.send({Target = Game, Action = "PlayerAttack", AttackEnergy = tostring(player.energy)})
  else
    -- print(colors.red .. "No player in range or insufficient energy. Moving randomly." .. colors.reset)
    local directionMap = {"Up", "Down", "Left", "Right", "UpRight", "UpLeft", "DownRight", "DownLeft"}
    local randomIndex = math.random(#directionMap)
    ao.send({Target = Game, Action = "PlayerMove", Direction = directionMap[randomIndex]})
  end
end

-- Handler for "Eliminated" events to trigger AutoPay
Handlers.add(
  "Eliminated-Autopay",
  Handlers.utils.hasMatchingTag("Action", "Eliminated"),
  function (msg)
    -- This will be triggered when an "Eliminated" event is received.
    print(colors.red .. "Elimination detected. Triggering autopay to re-enter round." .. colors.reset)
    ao.send({Target = ao.id, Action = "AutoPay"})
  end
)

-- Handler to automate payment confirmation when waiting period starts.
Handlers.add(
  "AutoPay",
  Handlers.utils.hasMatchingTag("Action", "AutoPay"),
  function (msg)
    InAction = false -- InAction logic added
    print("Auto-paying confirmation fees.")
    ao.send({ Target = CRED, Action = "Transfer", Recipient = Game, Quantity = "1000"})
  end
)

-- This Handler will get the bot moving by updating the gamestate after payment confirmation is recieved
Handlers.add(
  "Payment-GameState",
  Handlers.utils.hasMatchingTag("Action", "Payment-Received"),
  function (msg)
    print(colors.green .. "Waking up GRID Bot".. colors.reset)
    InAction = false
    Send({Target = Game, Action = "GetGameState", Name = Name , Owner = Owner})
  end
)

-- Handler to trigger game state updates.
Handlers.add(
  "GetGameStateOnTick",
  Handlers.utils.hasMatchingTag("Action", "Tick"),
  function ()
      -- print(colors.gray .. "Getting game state..." .. colors.reset)
      ao.send({Target = Game, Action = "GetGameState"})
  end
)


-- Handler to update the game state upon receiving game state information.
Handlers.add(
  "UpdateGameState",
  Handlers.utils.hasMatchingTag("Action", "GameState"),
  function (msg)
    local json = require("json")
    LatestGameState = json.decode(msg.Data)
    ao.send({Target = ao.id, Action = "UpdatedGameState"})
    --print(LatestGameState)
  end
)



-- Handler to decide the next best action.
Handlers.add(
  "decideNextAction",
  Handlers.utils.hasMatchingTag("Action", "UpdatedGameState"),
  function ()
    print("Looking around..")
    decideNextAction()
    ao.send({Target = ao.id, Action = "Tick"})
  end
)

-- Handler to automatically attack when hit by another player.
Handlers.add(
  "ReturnAttack",
  Handlers.utils.hasMatchingTag("Action", "Hit"),
  function (msg)
    local playerEnergy = LatestGameState.Players[ao.id].energy
    if playerEnergy < 10 then
      print(colors.red .. "Player Is too tired." .. colors.reset)
      ao.send({Target = Game, Action = "Attack-Failed", Reason = "Player has no energy."})
    else
      print(colors.red .. "Returning attack..." .. colors.reset)
      ao.send({Target = Game, Action = "PlayerAttack", AttackEnergy = tostring(playerEnergy)})
    end
    ao.send({Target = ao.id, Action = "Tick"})
  end
)