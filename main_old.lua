
-- On load les ressources nécéssaires (images)
function love.load()
    blanc_square = love.graphics.newImage("pictures/blanc_square.png")
    love.window.setTitle("Snake")

    -- love.window.maximize()
    -- success = love.window.setFullscreen( true )
    -- without the panel bar

    height = love.graphics.getHeight()
    width = love.graphics.getWidth()
    atomic_move = 20 -- == size of blanc_square

    food_x = love.math.random(0, math.floor(width/atomic_move)) * atomic_move
    food_y = love.math.random(0, math.floor(height/atomic_move)) * atomic_move

    -- initial position of the player square
    x = 0
    y = 0
    -- number of frame already displayed
    update_count = 0
    
end



-- Rafraîchissement de l'écran (on re-draw)
function love.draw()
    love.graphics.draw(blanc_square, x, y)

    -- dessin des lignes
    for i=0, math.floor(width/atomic_move) do
        love.graphics.line(i*atomic_move,0, i*atomic_move, height)
    end
        
    -- dessin des colonnes
    for j=0, math.floor(height/atomic_move) do
        love.graphics.line(0, j*atomic_move, width, j*atomic_move)    
    end

    love.graphics.draw(blanc_square, food_x, food_y)

    love.graphics.draw(love.graphics.newText(love.graphics.newFont(10), love.timer.getFPS()), width/2, height/2)
end

-- On update nos variables en fonction de touches tapées
function love.update(dt)
    update_count = update_count + 1
    
    if update_count > 11111 then
        update_count = 1
    end

    if love.keyboard.isDown('z') then
        y = y - atomic_move
    -- comment faire un else ;) ?
    end
    if love.keyboard.isDown('s') then
        y = y + atomic_move
    end
    if love.keyboard.isDown('q') then
        x = x - atomic_move
    end
    if love.keyboard.isDown('d') then
        x = x + atomic_move
    end

    if y<0 then
        y = height - atomic_move
    end
    if y>height then
        y = 0
    end
    if x<0 then
        x = width - atomic_move
    end
    if x>width then
        x=0
    end
end