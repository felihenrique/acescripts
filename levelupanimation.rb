#-----------------------------------------------------------------------------
# Level Up Animation 1.0
# Criador: Klarth
# Descri��o: Esse script permite que toda vez que o jogador upe de lvl uma 
# anima��o seja exibida
# Intru��es para configura��o:
#       ANIMATION_ID: Coloque aqui a id da anima��o que ser� exibida.
#-----------------------------------------------------------------------------
module Ani_Conf
  ANIMATION_ID = 37
end
class Game_Actor
  alias old_lvl level_up
  alias old_change change_level
  def level_up
    old_lvl
    if SceneManager.scene.is_a?(Scene_Map)
      $game_player.animation_id = Ani_Conf::ANIMATION_ID
    end
  end
  def change_level(level,show)
    old_change(level,show)
    if SceneManager.scene.is_a?(Scene_Map)
      $game_player.animation_id = Ani_Conf::ANIMATION_ID
    end
  end
end