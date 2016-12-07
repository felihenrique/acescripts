###------------------------------------------------------------------------###
### > Map Window Status                                                    ###
### > Criado por Klarth                                                    ###
### > Esse script permite que toda vez que algum personagem mude o seu     ###
###     status no mapa, uma janela de aviso apareça informando a mudança.  ###
#-----------------------------------------------------------------------------#
# Configurações do script:                                                    #
#-----------------------------------------------------------------------------#
module Status_Win_Conf
#### Texto que aparece caso o grupo ganhe um status
  TEXT_GROUP_GAIN = "O grupo ganhou o status: "
#### Texto que aparece caso o grupo perca um status
  TEXT_GROUP_LOSE = "O grupo perdeu o status: "
#### Texto que aparece antes do nome do personagem
  TEXT_ACTOR = ""
#### Texto que aparece caso um personagem ganhe um status
  TEXT_ACTOR_GAIN = " ganhou o status: "
#### Texto que aparece caso um personagem perca um status
  TEXT_ACTOR_LOSE = " perdeu o status: "
###### Tempo em frames que a janela ficará no mapa
  TIME = 140
###### Caminho completo da SE que tocará. Deixe em branco caso não queira
  SE_NAME = "Audio/SE/Item1"
##### Cor do texto quando um personagem ganhar um status
  COLOR_GAIN = Color.new(0,255,0,255)
##### Cor do texto quando um personagem perder um status
  COLOR_LOSE = Color.new(255,100,100,255)
##### Nome da windowskin da janela (Obs: Deve estar dentro da pasta System)
  WINDOWSKIN = "Window"
end

class Window_StatusChange < Window_Base
  include Status_Win_Conf
  def initialize
    super(0,0,0,0)
    #---------------------------------------------------------------------
    # Algumas configurações da janela
    #---------------------------------------------------------------------
    self.arrows_visible = false
    self.opacity = 0
    self.padding = 0
    self.tone = Tone.new(0,0,0,0)
    @wait_time = 0
    @text = ""
    self.windowskin = Cache.system(WINDOWSKIN)
    self.hide
  end
  #-------------------------------------------------------------------------
  # status_id: Id do estado que ganhou
  #
  # actor_id: Id do actor que ganhou o estado. 
  # Se for 0 todo o grupo ganhou o estado
  # 
  # type - 0: adicionou status 
  #        1: retirou status
  #-------------------------------------------------------------------------
  def show_window(status_id, actor_id, type)
    #-------------------------------------------------------------------------
    # Aqui é montado o texto a ser exibido
    #-------------------------------------------------------------------------
    @text = ""    
    if (type == 0)
      actor_id == 0 ? @text += TEXT_GROUP_GAIN : 
      @text += TEXT_ACTOR + $data_actors[actor_id].name + 
      TEXT_ACTOR_GAIN      
      @text += $data_states[status_id].name + "!"
    else
      actor_id == 0 ? @text += TEXT_GROUP_LOSE : 
      @text += TEXT_ACTOR + $data_actors[actor_id].name + 
      TEXT_ACTOR_LOSE      
      @text += $data_states[status_id].name + "!"
    end
    #-------------------------------------------------------------------------
    # Nessa parte são calculados a largura, a altura, o x e o y
    # de acordo com o tamanho do texto
    #-------------------------------------------------------------------------
    self.contents.font.size = 18
    t_size = text_size(@text).width
    self.width = t_size + 60
    self.height = 40
    self.x = (Graphics.width - self.width)/2
    self.y = -10
    self.contents = Bitmap.new(self.width, self.height)
    #-------------------------------------------------------------------------
    # Aqui é desenhado o icone do status
    #-------------------------------------------------------------------------
    draw_icon($data_states[status_id].icon_index, 14, 8)
    #--------------------------------------------------------------------------
    # Aqui é desenhado o texto
    #--------------------------------------------------------------------------
    type == 0 ? self.contents.font.color = COLOR_GAIN : 
    self.contents.font.color = COLOR_LOSE
    self.contents.font.size = 18
    self.contents.draw_text(45, 10, t_size + 300, 20, @text)
    self.show
    self.open
  end
  #--------------------------------------------------------------------------
  # Atualiza a janela. É chamado todo frame.
  #--------------------------------------------------------------------------
  def update
    super
    self.y += 3 if self.y < 16
    self.opacity += 13 if self.opacity < 200
    @wait_time += 1
    self.close if @wait_time >= TIME      
  end
  #--------------------------------------------------------------------------
  # Abre a janela realizando a animação
  #--------------------------------------------------------------------------
  def open    
    super    
    self.y = -10
    self.opacity = 0
    @wait_time = 0
    Audio.se_play(SE_NAME) if SE_NAME != ""
  end
end
#----------------------------------------------------------------------------
#  Modificação no metódo que muda o status da classe Game_Interpreter
#----------------------------------------------------------------------------
class Game_Interpreter
  def command_313
    iterate_actor_var(@params[0], @params[1]) do |actor|
      already_dead = actor.dead?
      if @params[2] == 0
        actor.add_state(@params[3])
      else
        actor.remove_state(@params[3])
      end
      actor.perform_collapse_effect if actor.dead? && !already_dead
    end
    if SceneManager.scene.is_a?(Scene_Map)
      SceneManager.scene.status_window.show_window(@params[3], @params[1], @params[2])
    end
  end
end
#-----------------------------------------------------------------------------
# Modificações necessárias na classe Scene_Map
#-----------------------------------------------------------------------------
class Scene_Map
  attr_accessor :status_window
  alias klarth_start start
  alias klarth_update update
  alias klarth_terminate terminate
  def start
    klarth_start
    @status_window = Window_StatusChange.new
  end
  def update
    klarth_update
    @status_window.update
  end
  def terminate
    @status_window.dispose    
    klarth_terminate
  end
end