
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
    table_x = {40, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    table_y = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    y = 0
    x = 0
    -- number of frame already displayed
    update_count = 0

    lastscancodedown = 'w'
    snake_size = 10
end


-- Rafraîchissement de l'écran (on re-draw)
function love.draw()
        
    love.graphics.draw(head_square, table_x[1], table_y[1])
    for i=2, snake_size do
        love.graphics.draw(blanc_square, table_x[i], table_y[i])
    end

    -- dessin des lignes
    for i=0, math.floor(width/atomic_move) do
        love.graphics.line(i*atomic_move,0, i*atomic_move, height)
    end
        
    -- dessin des colonnes
    for j=0, math.floor(height/atomic_move) do
        love.graphics.line(0, j*atomic_move, width, j*atomic_move)    
    end

    love.graphics.draw(blanc_square, table_food[1], table_food[2])
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
        if love.keyboard.isScancodeDown('w') and lastscancodedown ~='s' then
            lastscancodedown = 'w'
        elseif love.keyboard.isScancodeDown('s') and lastscancodedown ~='w' then
            lastscancodedown = 's'
        elseif love.keyboard.isScancodeDown('a') and lastscancodedown ~='d' then
            lastscancodedown = 'a'
        elseif love.keyboard.isScancodeDown('d') and lastscancodedown ~='a' then
            lastscancodedown = 'd'
        end
    love.timer.sleep(1/15)

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

    if x ~= table_x[1] or y ~= table_y[1] then
        for i=snake_size-1, 1, -1 do
            table_x[i+1] = table_x[i] 
            table_y[i+1] = table_y[i]
        end
        table_x[1] = x
        table_y[1] = y
    end

    if atomicSquareEqual(x, y, table_food[1], table_food[2]) then
        snake_size = snake_size+2
        table_x[snake_size-1] = table_x[snake_size-2]
        table_y[snake_size-1] = table_y[snake_size-2]
        table_x[snake_size] = table_x[snake_size-2]
        table_y[snake_size] = table_y[snake_size-2]
        table_food = generateFood()

        eat_sound:play()
        love.graphics.draw(red_head_big, x, y)
    end
    for i=2, snake_size do
        if atomicSquareEqual(table_x[1], table_y[1], table_x[i], table_y[i]) then
            snake_size = i-1
            if snake_size < 4 then
                snake_size = 4
            end
            break
        end
    end
end

function atomicNumber(a)
    return math.floor(a/atomic_move)
end

function atomicSquareEqual(x1, y1, x2, y2)
    if atomicNumber(x1) == atomicNumber(x2) and atomicNumber(y1) == atomicNumber(y2) then
        return true
    end
    return false
end

function generateFood(food_a, food_b)
    food_a = love.math.random(0, math.floor(width/atomic_move)-1) * atomic_move
    food_b = love.math.random(0, math.floor(height/atomic_move)-1) * atomic_move
    return {food_a, food_b}
end