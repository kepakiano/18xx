# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'entities'
require_relative '../../round/operating'

module Engine
  module Game
    module G1835
      class Game < Game::Base
        attr_accessor :draft_finished
        include_meta(G1835::Meta)
        include G1835::Entities
        include G1835::Map

        register_colors(black: '#37383a',
                        seRed: '#f72d2d',
                        bePurple: '#2d0047',
                        peBlack: '#000',
                        beBlue: '#c3deeb',
                        heGreen: '#78c292',
                        oegray: '#6e6966',
                        weYellow: '#ebff45',
                        beBrown: '#54230e',
                        gray: '#6e6966',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '%sM'
        # game end current or, when the bank is empty
        GAME_END_CHECK = { bank: :current_or }.freeze
        # bankrupt is allowed, player leaves game
        BANKRUPTCY_ALLOWED = true

        BANK_CASH = 12_000
        PAR_PRICES = {
          'PR' => 154,
          'BY' => 92,
          'SX' => 88,
          'BA' => 84,
          'WT' => 84,
          'HE' => 84,
          'MS' => 80,
          'OL' => 80,
        }.freeze
        CERT_LIMIT = { 3 => 19, 4 => 15, 5 => 12, 6 => 11, 7 => 9 }.freeze

        STARTING_CASH = { 3 => 6000, 4 => 475, 5 => 390, 6 => 340, 7 => 310 }.freeze
        # money per initial share sold
        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        MARKET = [['',
                   '',
                   '',
                   '',
                   '132',
                   '148',
                   '166',
                   '186',
                   '208',
                   '232',
                   '258',
                   '286',
                   '316',
                   '348',
                   '382',
                   '418'],
                  ['',
                   '',
                   '98',
                   '108',
                   '120',
                   '134',
                   '150',
                   '168',
                   '188',
                   '210',
                   '234',
                   '260',
                   '288',
                   '318',
                   '350',
                   '384'],
                  %w[82
                     86
                     92p
                     100
                     110
                     122
                     136
                     152
                     170
                     190
                     212
                     236
                     262
                     290
                     320],
                  %w[78
                     84p
                     88p
                     94
                     102
                     112
                     124
                     138
                     154p
                     172
                     192
                     214],
                  %w[72 80p 86 90 96 104 114 126 140],
                  %w[64 74 82 88 92 98 106],
                  %w[54 66 76 84 90]].freeze

        PHASES = [
          {
            name: '1.1',
            on: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '1.2',
            on: '2+2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2.1',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.2',
            on: '3+3',
            train_limit: { major: 4, minor: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.3',
            on: '4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.4',
            on: '4+4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3.1',
            on: '5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green],
            operating_rounds: 3,
            events: { close_companies: true },
          },
          {
            name: '3.2',
            on: '5+5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.3',
            on: '6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.4',
            on: '6+6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 9 },
                  { name: '2+2', distance: 2, price: 120, rusts_on: '4+4', num: 4 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 4 },
                  { name: '3+3', distance: 3, price: 270, rusts_on: '6+6', num: 3 },
                  { name: '4', distance: 4, price: 360, num: 3 },
                  { name: '4+4', distance: 4, price: 440, num: 1 },
                  { name: '5', distance: 5, price: 500, num: 2 },
                  { name: '5+5', distance: 5, price: 600, num: 1 },
                  { name: '6', distance: 6, price: 600, num: 2 },
                  { name: '6+6', distance: 6, price: 720, num: 4 }].freeze

        LAYOUT = :pointy

        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :float

        STARTING_PACKAGE_SOLD = false
        BUY_SHARE_FROM_OTHER_PLAYER = true

        YELLOW_OR_UPGRADE = [{ lay: true, upgrade: true }].freeze
        ONE_YELLOW = [{ lay: true, upgrade: false }].freeze
        TWO_YELLOW = [{ lay: true, upgrade: false }, { lay: true, upgrade: false }].freeze

        def setup

          @can_buy_conditions = {
            "BY" => { corporation: "BY", sold: 0 },
            "SX" => { corporation: "BY", sold: 0 },
            "BA" => { corporation: "BY", sold: 0 },
            "WT" => { corporation: "BA", sold: 50 },
            "HE" => { corporation: "WT", sold: 50 },
            "PR" => { corporation: "BA", sold: 20 },
            "MS" => { corporation: "BY", sold: 20 },
            "OL" => { corporation: "MS", sold: 20 },
          }

          # Reserve Preußen shares to be exchanged for Vorpreußen and Privates
          pr.shares.last(8).each { |s| s.buyable = false }

          # override share_percent so that MS and OL aren't created as 5-share company
          corporation_by_id("MS").forced_share_percent = 10
          corporation_by_id("OL").forced_share_percent = 10

          corporation_by_id("BA").shares.last.double_cert = true
          corporation_by_id("WT").shares.last.double_cert = true
          corporation_by_id("HE").shares.last.double_cert = true
          corporation_by_id("MS").shares[1].double_cert = true
          corporation_by_id("MS").shares[2].double_cert = true
          corporation_by_id("OL").shares[1].double_cert = true
          corporation_by_id("OL").shares[2].double_cert = true

          @draft_finished = false
          @turn = 0
          @draft_round_num = 1
          LOGGER.debug("@stock_market.par_prices #{@stock_market.par_prices}")
          @corporations.select{|corp| corp.type == :major}.each do |i|
            share_price = @stock_market.par_prices.find{|share_price| share_price.price == PAR_PRICES[i.id]}
            LOGGER.debug("share_price for #{i.name}: #{share_price}")
            @stock_market.set_par(i, share_price)
            if i.id == "BY" || i.id == "SX"
              i.ipoed = true
            end
          end

        end

        def corporations_in_same_block(corporation)
          first_block = %w[BY SX]
          second_block = %w[BA WT HE PR]
          third_block = %w[MS OL]

          block = if first_block.include?(corporation.id)
                    first_block
                    elsif
           second_block.include?(corporation.id)
             second_block
           else
             third_block
           end
           block.map{|c| corporation_by_id(c)}
        end

        def ipo_next_block(corporation)
          first_block = %w[BY SX]
          second_block = %w[BA WT HE PR]
          third_block = %w[MS OL]

          block = if first_block.include?(corporation.id)
                    second_block
                    elsif
           second_block.include?(corporation.id)
                      third_block
           else
             []
           end
           block.map{|c| corporation_by_id(c)}.each{|corp_to_ipo| corp_to_ipo.ipoed = true}
        end

        def corporation_available?(corp)
          false unless corp.type == :major
          condition = @can_buy_conditions[corp.id]
          other_corp = @corporations.find{|c| c.id == condition[:corporation] }
          false unless other_corp
          other_corp.ipo_owner.percent_of(other_corp) <= 100 - condition[:sold]
        end

        def find_corporation(company)
          corporation_by_id(company.id)
        end

        def pr
          corporation_by_id('PR')
        end

        def sorted_corporations
          @corporations.select { |c| c.type == :major && c.ipoed}
        end

        def can_par?(corporation, _parrer)
          # LOGGER.debug("can_par?: #{corporation.name} #{_parrer.name}")
          super
        end

        def cert_limit(_player = nil)
          @cert_limit + @corporations.count{|corporation| corporation.type == :major && _player.percent_of(corporation) >= 80}
        end

        def tile_lays(_entity)
          return YELLOW_OR_UPGRADE if _entity.type == :minor
          return YELLOW_OR_UPGRADE if @phase.name.to_i >= 3
          TWO_YELLOW
        end

        def init_round
          @log << "-- init_round-- wololooooooo "
          new_draft_round
        end
        def new_draft_round
          @log << "-- Draft Round #{@turn} -- "
          G1835::Round::Draft.new(self,
                                    [G1835::Step::Draft],)
        end

        def stock_round
          @log << "-- stock_round-- wololooooooo "
          Engine::Round::Stock.new(self, [
            G1835::Step::BuySellParShares,
          ])
        end

        def next_round! # Draft is Turn 0
          @log << "-- next_round! -- wololooooooo "
          if @draft_finished
            @turn = 1 if @turn.zero?

            return super
          end

          clear_programmed_actions
          @round =
            case @round
            when G1835::Round::Draft
              new_operating_round(@draft_round_num)
            when G1835::Round::Operating
              @draft_round_num += 1
              new_draft_round
            end
        end

        def operating_round(round_num)
          @log << "-- Operating Round #{round_num} -- wololooooooo "
          G1835::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end
      end
    end
  end
end
