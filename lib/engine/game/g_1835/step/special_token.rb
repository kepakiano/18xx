# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def available_tokens(entity)
            return available_tokens(@round.current_operator) if entity == @game.company_by_id('NF')
            return [] unless entity.corporation?

            entity.tokens_by_type
          end

          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            # No special treatment needed if the entity is a player. This happens in the case of NF
            return [token, nil] if entity.player?

            super
          end
        end
      end
    end
  end
end
