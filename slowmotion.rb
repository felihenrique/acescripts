module Slow_Conf
  SWIT = 5 # Switch para ativar o efeito
  FATOR = 15 # Fator que muda a velocidade
end

class Game_Map
  def update(main = false)
    refresh if @need_refresh
    update_interpreter if main
    update_scroll
    if $game_switches[Slow_Conf::SWIT]
      if Graphics.frame_count % Slow_Conf::FATOR == 0
      update_events
      end
    else
      update_events
    end
    update_vehicles
    update_parallax
    @screen.update
  end
end