module Trail_Conf
 #Cor do sprite  
  COLOR =  Color.new(255, 255, 255, 100)
 #Switch que ativa ou desativa o efeito
  SWITCH = 1
 #Caso o rastro fique desalinhado você pode ajustar a posição dele aqui
  AJUSTE_X = 16 # Ajuste no eixo X
  AJUSTE_Y = 32 # Ajuste no eixo Y
end

# Valor correspondente a cada direção para ajudar no script. OBs: Nao mexa aqui
module Direction
  UP = 8
  DOWN = 2
  RIGHT = 6
  LEFT = 4
end

# Inicio da classe Character trail
class Character_Trail
  # Parametros:
  # amount: quantidade de rastros
  # color: cor do rastro 
  # lifetime: tempo que o rastro fica no mapa
  def initialize(amount, color, lifetime, viewport)
    @char_sprites = Array.new(amount + 1)
    @current_index = 0
    @char_color = color
    @lifetime = lifetime
    @fade = Array.new(amount + 1)
    @amount = amount + 1
    @actual_graphic = $game_player.character_name
    @player_x = $game_player.real_x
    @player_y = $game_player.real_y
    @viewport = viewport
    @hided = false
    @current_scroll_x = $game_map.display_x
    @current_scroll_y =  $game_map.display_y
    @actual_direction = $game_player.direction
    refresh
  end
  
  
  # Metodo para atualizar o grafico do rastro
  # é chamado uma vez no initialize
  # é necessário chamá-lo mais tarde caso o gráfico do personagem seja alterado
  def refresh
    for i in 0...@amount
      @char_sprites[i] = Sprite.new(@viewport)
      @char_sprites[i].bitmap = Cache.character($game_player.character_name)
      @char_sprites[i].opacity = 0
      @char_sprites[i].z = $game_player.screen_z - 30
      @char_sprites[i].color = @char_color
      @fade[i] = false
    end
  end
  
  # Método que contem toda a lógica do script  
  def update
    # Verifica se o gráfico do personagem mudou
    if $game_player.character_name != @actual_graphic
      refresh
      @actual_graphic = $game_player.character_name
    end
    # Parte principal que analise se o character se moveu e outras coisas
    if Graphics.frame_count % (@lifetime / (@amount - 1)) == 0
    if (@player_x != $game_player.real_x) || 
      (@player_y != $game_player.real_y)
      if @fade[@current_index] == false
        @player_x = $game_player.real_x
        @player_y = $game_player.real_y
        @char_sprites[@current_index].x = $game_player.screen_x - 
        Trail_Conf::AJUSTE_X
        @char_sprites[@current_index].y = $game_player.screen_y - 
        Trail_Conf::AJUSTE_Y
        set_graphic(@current_index,$game_player.character_index,
        $game_player.pattern, $game_player.direction)
        @fade[@current_index] = true
        @char_sprites[@current_index].opacity = 255
      end
      @current_index += 1
      @current_index = 0 if @current_index == @char_sprites.size
    else
      @current_index = 0
    end
  end
    update_z
    update_position
    update_opacity
  end
      
  def update_position
    if (@current_scroll_x != $game_map.display_x ||
      @current_scroll_y != $game_map.display_y)
      diference_x = @current_scroll_x - $game_map.display_x
      diference_y = @current_scroll_y - $game_map.display_y
      for i in 0...@amount
        if @fade[i]
          @char_sprites[i].x += diference_x * 32
          @char_sprites[i].y += diference_y * 32
        else
          @char_sprites[i].x += $game_player.screen_x * 32
          @char_sprites[i].y += $game_player.screen_y * 32
        end
      end
      @current_scroll_x = $game_map.display_x
      @current_scroll_y = $game_map.display_y
    end
  end
  def update_z
    if @actual_direction != $game_player.direction
      if $game_player.direction == Direction::UP
        @char_sprites.each do |char|
         char.z = $game_player.screen_z + 20
        end      
      else
        @char_sprites.each do |char|
         char.z = $game_player.screen_z - 20
        end
      end
      @actual_direction = $game_player.direction
    end
  end
  # Controla a opacidade de cada sprite
  def update_opacity
    dec = 255 / @lifetime
    for i in 0...@amount
      if @fade[i]
        @char_sprites[i].opacity -= dec
        if @char_sprites[i].opacity <= 0
          @fade[i] = false
        end
      end
    end
  end
  
  # Controla qual sprite derá desenhado no rastro
  def set_graphic(index, character_index, pattern, direction)
    cw = @char_sprites[index].bitmap.width / 12
    ch = @char_sprites[index].bitmap.height / 8
    n = character_index
    src_rect1 = Rect.new((n%4)*cw*3, (n/4*4)*ch, cw, ch)
    src_rect2 = Rect.new((n%4)*cw*3 + cw, (n/4*4)*ch, cw, ch)
    src_rect3 = Rect.new((n%4)*cw*3 + cw*2, (n/4*4)*ch, cw, ch)
    case direction
    when Direction::DOWN
      if pattern == 0 || pattern == 2
        src_rect = src_rect2
      elsif pattern == 1
        src_rect = src_rect3
      elsif pattern == 3
        src_rect = src_rect1
      end
    when Direction::LEFT
      if pattern == 0 || pattern == 2
        src_rect = src_rect2
        src_rect.y += ch
      elsif pattern == 1
        src_rect = src_rect3
        src_rect.y += ch
      elsif pattern == 3
        src_rect = src_rect1
        src_rect.y += ch
      end
    when Direction::RIGHT
      if pattern == 0 || pattern == 2
        src_rect = src_rect2
        src_rect.y += ch * 2
      elsif pattern == 1
        src_rect = src_rect3
        src_rect.y += ch * 2
      elsif pattern == 3
        src_rect = src_rect1
        src_rect.y += ch * 2
      end
     when Direction::UP
      if pattern == 0 || pattern == 2
        src_rect = src_rect2
        src_rect.y += ch * 3
      elsif pattern == 1
        src_rect = src_rect3
        src_rect.y += ch * 3
      elsif pattern == 3
        src_rect = src_rect1
        src_rect.y += ch * 3
      end
    end
    @char_sprites[index].src_rect = src_rect
  end
  # Esconde o Trail
  def hide
    if !@hided
      for i in 0...@amount
        @char_sprites[i].opacity = 0
      end
      @hided = true
    end
  end
  def show
    @hided = false
  end
end

# Aliases para atualizar o rastro
class Scene_Map  
  attr_reader   :spriteset
  alias update_old update
  alias start_old start
  
  def start
    start_old
    @character_trail = Character_Trail.new(6, Trail_Conf::COLOR, 60,
    spriteset.character_sprites[0].viewport)
  end
  
  def update
    update_old
    if $game_switches[Trail_Conf::SWITCH]
       @character_trail.show
       @character_trail.update
    else
       @character_trail.hide
    end       
  end  
end
class Spriteset_Map
  attr_reader   :character_sprites
end