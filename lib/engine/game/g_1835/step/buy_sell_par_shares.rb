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
            if action.bundle.owner.player?
              action.bundle.share_price = nationalization_price(action.bundle.price)
            end
            super

            bundle = action.bundle
            corp   = bundle.corporation

            all_in_block_sold = @game.corporations_in_same_block(corp).all?{|corporation| corporation.shares.select{|share| share.buyable}.none?{|share| share.owner == corporation}}
            if all_in_block_sold
              @game.ipo_next_block(corp)
            end
          end

          def allow_president_change?(_corporation)
            _corporation != @game.pr
          end

          def can_buy?(entity, bundle)

            if bundle&.owner&.player?
              return false unless can_nationalize?(entity, bundle.corporation)

              return entity.cash >= nationalization_price(bundle.price) &&
                !@round.players_sold[entity][bundle.corporation] &&
                can_gain?(entity, bundle)
            end

            return false unless super

            bundle = bundle.to_bundle
            return false unless bundle

            # does this ever happen in 1835?
            return false unless bundle.shares.length == 1

            corporation = bundle.corporation
            cert = bundle.shares.first
            return false unless cert.buyable

            # ensure 20% shares of BA, WT and HE cannot be bought before all 10% shares are gone
            corporation.shares[0] == cert
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return false if bundle.owner.player? && !@game.can_gain_from_player?(entity, bundle)

            corporation = bundle.corporation

            corporation.holding_ok?(entity, bundle.common_percent) &&
              (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity))
          end

          def can_buy_any_from_player?(entity)
            return false if bought?

            @game.corporations.select(&:floated?).any? do |corporation|
              can_nationalize?(entity, corporation) && entity.cash >= nationalization_price(corporation.share_price.price)
            end
          end
          def nationalization_price(price)
            (price * 1.5).ceil
          end
          def can_nationalize?(player, corporation)
            false unless player
            player.percent_of(corporation) > 50
          end

        end
      end
    end
  end
end
