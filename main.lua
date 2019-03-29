
-- Load of necessary resources (pictures, sounds) and variables
function love.load()

    love.window.setTitle("Snake")
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

    
    
    -- screen resolution
    height = love.graphics.getHeight()
    width = love.graphics.getWidth()
    
    -- also equal to snake_size of blanc_square
    atomic_move = 20 

    -- initial food position
    table_food = generateFood()

    last_scancode_down = 's'

    -- | GameOptions | --
    -- snake_lives: number of possible tail-eats
    game = {options = {speed_mode=1, snake_lives = 3}, pause = false, menu=true}

    -- | Snake Var | --
    -- initial snake position
    snake = {{x=200, y=200}, {x=200, y=180}, {x=200, y=160}, {x=140, y=200}}
    snake_size = 4
    -- maximum size reached during the game
    max_snake_size = snake_size
    snake_direction = {x=0, y=1}
    snake_rate = 10
    
    -- timer
    time = love.timer.getTime()
    last_action_time = time
    
    isGameEnded = false
end


-- Screen refresh ~60 time/s (re-draw)
function love.draw()
    if game.menu then
        if (game.options.speed_mode == 1) then
            love.graphics.print("\n> Choose a speed mode: accelerate (space to change). Then, press Enter to play.")
        else
            love.graphics.print("\n> Choose a speed mode: constant (space to change). Then, press Enter to play.")
        end
        return
    end
    if isGameEnded then
        love.graphics.print("You lost ! Maximum size: " .. max_snake_size .. ". Press Enter to play.", width/2, height/2)
        return
    end
    
    love.graphics.draw(head_square, snake[1].x, snake[1].y)
    for i=2, snake_size do
        love.graphics.draw(blanc_square, snake[i].x, snake[i].y)
    end

    -- we draw the lines # TODO: change the color to grey
    for i=0, math.floor(width/atomic_move) do
        love.graphics.line(i*atomic_move,0, i*atomic_move, height)
    end
        
    -- we draw the columns 
    for j=0, math.floor(height/atomic_move) do
        love.graphics.line(0, j*atomic_move, width, j*atomic_move)    
    end

    -- print lives
    love.graphics.print(
        -- first parameter { color, string }
        -- color : { red, green, blue, alpha } values between 0 and 1 (not 0 and 255)
        { {1, 0, 0,1}, "Lives: " .. game.options.snake_lives},
        -- "Lives: " .. snake_lives, 
        math.floor(math.floor(width/atomic_move)*0.8)*atomic_move,
        math.floor(math.floor(height/atomic_move)*0.1)*atomic_move,
        0, -- rotation (rad)
        1.5, -- scale  (x)
        1.5 -- scale (y)
    )

    -- print max_snake_size
    love.graphics.print(
        "Max size: " .. max_snake_size, 
        math.floor(math.floor(width/atomic_move)*0.8)*atomic_move,
        math.floor(math.floor(height/atomic_move)*0.15)*atomic_move,
        0,
        1.5,
        1.5
    )

    love.graphics.draw(blanc_square, table_food.x, table_food.y)
end

-- Update of the variables (state) ~60 time/s
function love.update(dt)
    
    if isGameEnded or game.pause then 
        return
    end
    direction = captureDirection()
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

    --eating food
    if atomicSquareEqual(snake[1], table_food) then
        snake_size = snake_size+2
        -- Update maximum snake size
        if snake_size > max_snake_size then
            max_snake_size = snake_size
        end
        snake[snake_size-1] = snake[snake_size-2]
        snake[snake_size] = snake[snake_size-2]
        love.audio.stop()
        eat_sound:play()
        love.graphics.draw(red_head_big, snake[1].x, snake[1].y)
        table_food = generateFood()
    end
    -- eating self
    for i=2, snake_size do
        if atomicSquareEqual(snake[1], snake[i]) then
            snake_size = i-1
            love.audio.stop()
            crunch_sound:play()
            game.options.snake_lives = game.options.snake_lives - 1
            if game.options.snake_lives <=0 then
                isGameEnded = true
            end
            -- minimum size of the snake
            if snake_size < 4 then
                snake_size = 4
            end
        end
    end
    snake_rate = calculateSnakeRate()
end

function calculateSnakeRate()
    -- should be a method of snake class
    if game.options.speed_mode == 1 then
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

function love.keypressed(key, scancode, isrepeat)
    if scancode == "p" or scancode == "pause"then
        game.pause = not game.pause
    end
    if (scancode == "r" or scancode == "return") and isGameEnded then
        love.load()
        return
    end
    if scancode == "space" and game.menu then
        game.options.speed_mode = -(game.options.speed_mode - 1 )
        if game.options.speed_mode == 1 then
            game.options.snake_lives = 3
        else
            game.options.snake_lives = 1
        end
    end
    if scancode == "return" and game.menu then
        game.menu = false
        game.pause = false
    end
end