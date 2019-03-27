
-- On load les ressources nécéssaires (images)
function love.load()
    -- Pictures
    blanc_square = love.graphics.newImage("pictures/blanc_square.png")
    red_head_big = love.graphics.newImage("pictures/blanc_square.png")
    head_square = love.graphics.newImage("pictures/red_head.png")
    
    -- Sounds
    eat_sound = love.audio.newSource("sounds/eat_sound.wav", "static")

    -- love.window.maximize()
    -- success = love.window.setFullscreen( true )
    -- without the panel bar

    height = love.graphics.getHeight()
    width = love.graphics.getWidth()
    atomic_move = 20 -- == snake_size of blanc_square

    table_food = generateFood()

    -- initial position of the player square
    snake = {{x=40, y=0}, {x=20, y=0}, {x=0, y=0}, {x=0, y=0}}
    y = 0
    x = 0

    lastscancodedown = 's'
    snake_size = 4
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
        if lastscancodedown == 'w' then
        y = y - atomic_move
    elseif lastscancodedown == 's' then
        y = y + atomic_move
    elseif lastscancodedown == 'a' then
        x = x - atomic_move
    else
        x = x + atomic_move
    end
    if not love.keyboard.isScancodeDown(lastscancodedown) then
        if love.keyboard.isScancodeDown('w') and lastscancodedown ~='s' then
            lastscancodedown = 'w'
        elseif love.keyboard.isScancodeDown('s') and lastscancodedown ~='w' then
            lastscancodedown = 's'
        elseif love.keyboard.isScancodeDown('a') and lastscancodedown ~='d' then
            lastscancodedown = 'a'
        elseif love.keyboard.isScancodeDown('d') and lastscancodedown ~='a' then
            lastscancodedown = 'd'
        end
    end
    love.timer.sleep(1/snake_size)

    if y<0 then
        y = height - atomic_move
    end
    if y>=height then
        y = 0
    end
    if x<0 then
        x = width - atomic_move
    end
    if x>=width then
        x=0
    end

    if atomicSquareEqual({x=x, y=y}, table_food) then
        snake_size = snake_size+2
        snake[snake_size-1] = snake[snake_size-2]
        snake[snake_size] = snake[snake_size-2]
        
        eat_sound:play()
        love.graphics.draw(red_head_big, x, y)

        table_food = generateFood()
    end
    for i=2, snake_size do
        if atomicSquareEqual(snake[1], snake[i]) then
            snake_size = i-1
            if snake_size < 4 then
                snake_size = 4
            end
            break
        end
    end
    if x ~= snake[1].x or y ~= snake[1].y then
        for i=snake_size-1, 1, -1 do
            snake[i+1] = snake[i] 
        end
        snake[1] = {x=x, y=y}
    end
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