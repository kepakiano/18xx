# frozen_string_literal: true

module Engine
  module Game
    module G1835
      module Step

        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay
        end
      end
    end
  end
end
