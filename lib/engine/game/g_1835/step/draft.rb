# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1835
      module Step
        class Draft < Engine::Step::SimpleDraft
          attr_reader :companies, :choices, :grouped_companies

          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.select { |c| c.owner.nil? && !c.closed? }
            @tiered_companies = @companies.group_by(&:auction_row).values
          end

          def available
            @tiered_companies.flatten
          end

          def tiered_auction_companies
            @tiered_companies
          end

          def may_purchase?(_company)
            company = @game.companies.find{|c| c.sym == _company.sym }
            false unless company
            company_row = company.auction_row
            return true if company_row == 0
            return true if @tiered_companies[0...(company_row)].all?(&:empty?)
            return false unless @tiered_companies[0...(company_row - 1)].all?(&:empty?)
            return false unless @tiered_companies[company_row-1].size == 1
            @tiered_companies[company_row][0].sym == _company.sym
          end

          def may_choose?(_company)
            false
          end

          def auctioning; end

          def bids
            {}
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def name
            'Draft'
          end

          def description
            'Draft Private Companies'
          end

          def finished?
            @game.draft_finished = @companies.empty?
            @companies.empty? || entities.all?(&:passed?)
          end

          def actions(entity)
            return [] if finished?

            unless @companies.any? { |c| current_entity.cash >= min_bid(c) }
              @log << "#{current_entity.name} has no valid actions and passes  wololoooooo 1"
              return []
            end

            entity == current_entity ? ACTIONS : []
          end

          # def skip!
          #   @log << "#{current_entity.name} has no valid actions and passes wololoooooo"
          #   current_entity.pass!
          #   @round.next_entity_index!
          #   # @round.next_entity!
          # end

          def skip!
            super
            current_entity.pass! unless @acted
          end

          def log_skip(entity)
            @log << "#{entity.name} cannot afford any company and passes"
          end

          def process_bid(action)
            company = action.company
            player = action.entity
            price = action.price

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank)
            @tiered_companies.each do |row|
              next unless (index = row.index(company))
              row.delete(company)
            end
            @companies.delete(company)

            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

            @game.abilities(company, :shares) do |ability|
              ability.shares.each do |share|

                # In case someone else already holds 30% of BY SharePool#transfer_shares needs a previous president for
                # swapping the shares, thus we assign the buyer of the president share even if they immediately lose
                # the presidency. Which is technically correct, the buyer becomes the first president and then players
                # check whether there is someone else with more shares
                if share.president && share.corporation.name == "BY"
                  share.corporation.owner = player
                  @log << "#{player.name} becomes the president of #{share.corporation.name}"
                end
                @game.bank.spend(share.price, share.corporation)

                @game.share_pool.transfer_shares(ShareBundle.new(share), player, allow_president_change: @companies.find { |c| c.sym == "BY_D" }.nil? || share.corporation.id == "SX")
                maybe_place_home_token(share.corporation)

              end
            end
            if company.sym == 'BY_D'
              company.close!
            end

            corporation = @game.find_corporation(company)

            if corporation && corporation.type == :minor
              share = corporation.shares.first
              @game.share_pool.transfer_shares(ShareBundle.new(share), player)
              @game.bank.spend(price, corporation)
              company.close!
              maybe_place_home_token(corporation)
            end

            entities.each(&:unpass!)
            @round.next_entity_index!
            action_finalized
          end

          def maybe_place_home_token(corporation)
            if (@game.class::HOME_TOKEN_TIMING == :float && corporation.floated?) ||
              (@game.class::HOME_TOKEN_TIMING == :par && corporation.ipoed)
              @game.place_home_token(corporation)
            end
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            action.entity.pass!
            @round.next_entity_index!
            action_finalized
          end

          def action_finalized
            return unless finished?

            @round.reset_entity_index!
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def min_increment
            0
          end

          def may_bid?
            false
          end

          def min_bid(company)
            return unless company

            company.value
          end
          def max_bid(_player, object)
            player.cash
          end
          def max_place_bid(_player, _object)
            0
          end

          def ipo_type(_entity)
            nil
          end
        end
      end
    end
  end
end
