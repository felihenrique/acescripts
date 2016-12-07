#-----------------------------------------------------------------------------
#                       KL Tool Bar 1.0
#                       Criador: Klarth
#  Termos de uso:
#     -Você pode usar livremente esse script em seu projeto, seja ele comercial
#      ou não, mas caso uso dê os devidos créditos.
#    - Você pode modificar o script para uso próprio, não distribua versões
#      modificadas do script.
#    - Caso for postar em algum lugar mantenha os créditos
#  
#   Descrição do script: Esse script cria uma barra de ferramentas no mapa com
#   comandos que podem ser chamadas por uma tecla configurável.
#  
#-----------------------------------------------------------------------------
 
module Tool_Bar_Conf
  # Caso o segundo valor seja true um evento comum com a id do terceiro valor
  # é chamado. Caso o segundo valor seja false, o comando contido no terceiro
  # valor é executado.
 
  # Id do icone; Evento comum = true, false; id do evento comum ou comando; tecla
  Itens = [
  [12, true, 1, :X],
  [40, true, 4, :Y],
  [22, false, "msgbox('Teste')", :Z],
  [33, false, "SceneManager.call(Scene_Menu); Window_MenuCommand::init_command_position", :R],
  ]
  # Posição Y da tool bar
  Position_y = 368
  # Cor da borda da toolbar
  Border_Color = Color.new(15,15,30)
  # Cor do fundo principal
  Back_Color = Color.new(32,32,47)
  # Cor da caixa onde ficam os icones
  Box_Color = Color.new(49,49,64)
  # Se que toca quando o botão é apertado, caso seja "" nada é tocado
  Se_Trigger = "Audio/SE/Key"
end
 
class Bitmap
#------------------------------------------------------------------------------
# Novo método que desenha um ícone dentro de um bitmap
# icon_index: índice do ícone
# x,y: coordenadas dentro do bitmap
#------------------------------------------------------------------------------
  def fill_icon(icon_index, x, y)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    blt(x, y, bitmap, rect)
  end
#-----------------------------------------------------------------------------
# Novo método que desenha uma borda dentro de um bitmap.
# size: tamanho da borda
# color: cor da borda
#-----------------------------------------------------------------------------
  def fill_border(size, color)
    bw = self.width
    bh = self.height
    rect1 = Rect.new(0,0,size,bh)
    rect2 = Rect.new(size,0,bw-size*2,size)
    rect3 = Rect.new(size,bh-size,bw-size*2,size)
    rect4 = Rect.new(bw-size,0,size,bh)
    fill_rect(rect1, color)
    fill_rect(rect2, color)
    fill_rect(rect3, color)
    fill_rect(rect4, color)
  end
end
 
class Tool_Bar
  include Tool_Bar_Conf
#------------------------------------------------------------------------------
# Inicializa a tool bar
#------------------------------------------------------------------------------
  def initialize
    @back = Sprite.new
    @icons = []
    @cursor = Sprite.new
    @item_index = 0
   
    @border_color = Border_Color
    @back_color = Back_Color
    @box_color = Box_Color
   
    refresh
  end
#------------------------------------------------------------------------------
# Cria a tool bar, desenhando todo o conteúdo necessário
#------------------------------------------------------------------------------
  def refresh
    size = Itens.size
   
    @back.bitmap = Bitmap.new(12 + 28*size + (size+1)*2, 42)
    @back.bitmap.fill_border(6, @border_color)
    bw = @back.bitmap.width
    @back.bitmap.fill_rect(6,6,bw-12,30, @back_color)
    @back.z = 800
    @back.x = (Graphics.width - bw)/2
    @back.y = Position_y
   
    @cursor.bitmap = Bitmap.new(28,28)
    @cursor.bitmap.fill_rect(0,0,28,28,@box_color)
    @cursor.x = @back.x + 8 + 30*@item_index
    @cursor.y = @back.y + 7
    @cursor.z = 950
   
    for i in 0...size
      rect = Rect.new(8+30*i,7,28,28)
      @back.bitmap.fill_rect(rect, @box_color)
 
      @icons.push(Sprite.new)
      @icons[i].bitmap = Bitmap.new(24,24)
      @icons[i].bitmap.fill_icon(Itens[i][0],0,0)
 
      x = @back.x + 10 + 30*i
      y = @back.y + 9
      @icons[i].x = x
      @icons[i].y = y
      @icons[i].z = 1000
    end
  end
#------------------------------------------------------------------------------
# Atualiza a tool bar
#-----------------------------------------------------------------------------
  def update
    @cursor.x = @back.x + 8 + 30*@item_index
    @cursor.y = @back.y + 7
    @cursor.update
    Itens.each_index { |i|
      if Input.trigger?(Itens[i][3])
        @item_index = i
        @cursor.flash(Color.new(255,255,255,100), 30)
        Audio.se_stop
        Audio.se_play(Se_Trigger) if Se_Trigger != ""
        if Itens[i][1]
          $game_temp.reserve_common_event(Itens[i][2])
        else
          eval(Itens[i][2])
        end
      end
    }
  end
#------------------------------------------------------------------------------
# Apaga os dados das imagens da memoria
#------------------------------------------------------------------------------
  def dispose
    @back.dispose
    @icons.each do |i|
      i.dispose
    end
    @cursor.dispose
  end
 
end
#----------------------------------------------------------------------------
# Modificações necessárias para colocar a tool bar no mapa
#----------------------------------------------------------------------------
class Scene_Map
  alias kl_start start
  alias kl_update update
  alias kl_terminate terminate
  def start
    @tool_bar = Tool_Bar.new
    kl_start
  end
 
  def update
    kl_update
    @tool_bar.update
  end
 
  def terminate
    @tool_bar.dispose
    kl_terminate
  end
end