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
            LOGGER.debug("can_buy?: #{entity.name} #{bundle&.corporation&.name} #{bundle&.owner&.name} #{bundle.owner.player?}")
            if bundle.owner.player?
              return false unless can_nationalize?(entity, bundle.corporation)

              return entity.cash >= nationalization_price(bundle.price) &&
                !@round.players_sold[entity][bundle.corporation] &&
                can_gain?(entity, bundle)
            end

            return false unless super

            # bundle = bundle.to_bundle
            # corporation = bundle.corporation
            # cert = bundle.shares.first
            #
            # # 2nd and last IPO shares may be double; they must be bought in order
            # if cert.owner == corporation.ipo_owner
            #   # Filter out investor shares
            #   ipo_shares = corporation.ipo_shares.select(&:buyable)
            #
            #   return cert.double_cert if corporation.second_share_double && ipo_shares.size == 6
            #
            #   return cert.double_cert if corporation.last_share_double && ipo_shares.size == 1
            #
            #   return false if cert.double_cert
            # end

            true
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
            player.percent_of(corporation) > 50
          end

        end
      end
    end
  end
end
