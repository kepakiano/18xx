# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1835
      module Round
        class Draft < Engine::Round::Draft
          def select_entities
            @game.players
          end

          def after_process(_action)
            return if active_step

            next_entity!
          end

          def next_entity!
            next_entity_index! if active_step
            return if finished?

            @steps.each(&:unpass!)
            skip_steps
            next_entity! unless active_step
          end

          def finished?
            @game.all_drafted? || @entities.all?(&:passed?)
          end
        end
      end
    end
  end
end
