# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            super
          end

          def description
            'Buy/Sell Shares'
          end

          # def ipo_type(_entity)
          #   nil
          # end

          def process_buy_shares(action)
            super
            LOGGER.debug("process_buy_shares?: #{action}")
            entity = action.entity
            bundle = action.bundle
            corp   = bundle.corporation

            all_in_block_sold = @game.corporations_in_same_block(corp).all?{|corporation| corporation.shares.none?{|share| share.owner == corporation}}
            LOGGER.debug("all_in_block_sold?: #{all_in_block_sold}")
            if all_in_block_sold
              @game.ipo_next_block(corp)
            end
          end

          def can_buy?(entity, bundle)
            # LOGGER.debug("can_buy?: #{entity.name} #{bundle&.corporation&.name}")
            super
          end

        end
      end
    end
  end
end
