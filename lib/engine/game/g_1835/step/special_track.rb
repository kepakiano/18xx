require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack

          # def abilities(entity, **kwargs, &block)
          #   LOGGER.debug("abilties called for #{entity.id} is minor? #{entity.type == :minor} is major? #{entity.type == :major}")
          #   a = nil
          #   if entity.type == :major
          #     a = super
          #     if a
          #       LOGGER.debug("got: #{a}")
          #     end
          #   end
          #   LOGGER.debug("returning: #{a}")
          #   a
          # end

          # def abilities(entity, type = nil, time: nil, on_phase: nil, passive_ok: nil, strict_time: nil)
          #   a = super
          #   if a && entity.type == :minor
          #     LOGGER.debug("abilties called for minor #{entity.id} type: #{type} time: #{time} on_phase: #{on_phase} passive_ok: #{passive_ok} strict_time: #{strict_time}  #{a}")
          #     return [a.first, a.last]
          #   end
          #   if a
          #     LOGGER.debug("abilties called for #{entity.id} type: #{type} time: #{time} on_phase: #{on_phase} passive_ok: #{passive_ok} strict_time: #{strict_time}  #{a}")
          #   end
          #
          #   a
          # end
        end
      end
    end
  end
end
