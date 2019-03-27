
-- On load les ressources nécéssaires (images)
function love.load()
    -- Pictures
    blanc_square = love.graphics.newImage("pictures/blanc_square.png")
    red_head_big = love.graphics.newImage("pictures/blanc_square.png")
    head_square = love.graphics.newImage("pictures/red_head.png")
    
    -- Sounds
    eat_sound = love.audio.newSource("sounds/eat_sound.wav", "static")
    crunch_sound = love.audio.newSource("sounds/crunch_sound.wav", "static")

    -- love.window.maximize()
    -- success = love.window.setFullscreen( true )
    -- without the panel bar

    height = love.graphics.getHeight()
    width = love.graphics.getWidth()
    atomic_move = 20 -- == snake_size of blanc_square

    table_food = generateFood()

    last_scancode_down = 's'

    -- | GameOptions | --
    game_options = {speed_mode=1}

    -- | Snake Var | --
    -- initial snake position
    snake = {{x=200, y=200}, {x=200, y=180}, {x=200, y=160}, {x=140, y=200}}
    snake_size = 4
    snake_direction = {x=0, y=1}
    snake_rate = 10
    
    -- timer
    time = love.timer.getTime()
    last_action_time = time
end


-- Rafraîchissement de l'écran (on re-draw)
function love.draw()
    
    love.graphics.draw(head_square, snake[1].x, snake[1].y)
    for i=2, snake_size do
        love.graphics.draw(blanc_square, snake[i].x, snake[i].y)
    end

    -- dessin des lignes
    for i=0, math.floor(width/atomic_move) do
        love.graphics.line(i*atomic_move,0, i*atomic_move, height)
    end
        
    -- dessin des colonnes
    for j=0, math.floor(height/atomic_move) do
        love.graphics.line(0, j*atomic_move, width, j*atomic_move)    
    end

    love.graphics.draw(blanc_square, table_food.x, table_food.y)
end

-- On update nos variables en fonction de touches tapées
function love.update(dt)
    moveSnake(captureDirection())
    secureSnakePosition()
end

function moveSnake(direction)
    time = love.timer.getTime()
    if (direction.x+2*direction.y == -snake_direction.x-2*snake_direction.y) then
        direction = snake_direction
    end
    if (snake_rate*(time - last_action_time) > 1) then
        for i=snake_size-1, 1, -1 do
            snake[i+1] = snake[i] 
        end
        snake[1] = {x=snake[1].x + direction.x * atomic_move, y=snake[1].y + direction.y * atomic_move}
        last_action_time = time
        snake_direction = direction
    end
end

function captureDirection()
    if not love.keyboard.isScancodeDown(last_scancode_down) then
        if love.keyboard.isScancodeDown('w') and last_scancode_down ~='s' then
            last_scancode_down = 'w'
        elseif love.keyboard.isScancodeDown('s') and last_scancode_down ~='w' then
            last_scancode_down = 's'
        elseif love.keyboard.isScancodeDown('a') and last_scancode_down ~='d' then
            last_scancode_down = 'a'
        elseif love.keyboard.isScancodeDown('d') and last_scancode_down ~='a' then
            last_scancode_down = 'd'
        end
    end
    if last_scancode_down == 'w' then
        return {x=0, y=-1}
    elseif last_scancode_down == 's' then
        return {x=0, y=1}
    elseif last_scancode_down == 'a' then
        return {x=-1, y=0}
    else
        return {x=1, y=0}
    end
end

function secureSnakePosition()
    if snake[1].y<0 then
        snake[1].y = height - atomic_move
    end
    if snake[1].y>=height then
        snake[1].y = 0
    end
    if snake[1].x<0 then
        snake[1].x = width - atomic_move
    end
    if snake[1].x>=width then
        snake[1].x=0
    end

    if atomicSquareEqual(snake[1], table_food) then
        snake_size = snake_size+2
        snake[snake_size-1] = snake[snake_size-2]
        snake[snake_size] = snake[snake_size-2]
        eat_sound:play()
        love.graphics.draw(red_head_big, snake[1].x, snake[1].y)
        table_food = generateFood()
    end
    for i=2, snake_size do
        if atomicSquareEqual(snake[1], snake[i]) then
            snake_size = i-1
            if snake_size < 4 then
                snake_size = 4
            end
            crunch_sound:play()
            break
        end
    end
    snake_rate = calculateSnakeRate()
end

function calculateSnakeRate()
    -- should be a method of snake class
    if game_options.speed_mode == 1 then
        return snake_size/2 + 6
    end
    return 10
end

function atomicNumber(a)
    return math.floor(a/atomic_move)
end

function atomicSquareEqual(t1, t2)
    if atomicNumber(t1.x) == atomicNumber(t2.x) and atomicNumber(t1.y) == atomicNumber(t2.y) then
        return true
    end
    return false
end

function generateFood(food_a, food_b)
    food_a = love.math.random(0, math.floor(width/atomic_move)-1) * atomic_move
    food_b = love.math.random(0, math.floor(height/atomic_move)-1) * atomic_move
    return {x=food_a, y=food_b}
end