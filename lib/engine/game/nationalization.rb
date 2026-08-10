# frozen_string_literal: true

module Engine
  module Step
    module Nationalization
      def nationalize(player, bundle)
        price = nationalization_price(bundle.price)
        owner = bundle.owner
        corporation = bundle.corporation

        raise GameError, 'Cannot nationalize this corporation' unless can_nationalize?(player, corporation)
        raise GameError, 'Not enough cash for nationalization' unless player.cash >= price

        @log << "-- Nationalization: #{player.name} buys a #{bundle.percent}% share"\
                " of #{corporation.name} from #{owner.name} for #{@game.format_currency(price)} --"

        @game.share_pool.transfer_shares(bundle,
                                         player,
                                         spender: player,
                                         receiver: owner,
                                         price: price)
      end
    end
  end
end
