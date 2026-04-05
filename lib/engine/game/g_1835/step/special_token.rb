require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialToken < Engine::Step::SpecialToken

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
          def available_tokens(entity)
            super(current_entity)
          end

          def place_token(entity, city, token, connected: nil, extra_action: nil, special_ability: nil, check_tokenable: nil, spender: nil, same_hex_allowed: nil)
            entity = current_entity
            super
          end
          def adjust_token_price_ability!(_entity, token, hex, _city, special_ability: nil)
            _entity = current_entity
            LOGGER.debug("adjust_token_price_ability! entity: #{_entity} token: #{token} hex: #{hex.id} _city: #{_city} special_ability: #{special_ability}")
            super
          end
        end
      end
    end
  end
end
